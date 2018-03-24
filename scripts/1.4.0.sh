#!/usr/bin/env bash

function patch_configs () {
    (
        # Patch Configuration Script
        sed -e 's|libmklml_intel.so|libmklml.dylib|' \
            -e 's|libiomp5.so|libiomp5.dylib|'  \
            -i.bak third_party/mkl/{,mkl.}BUILD
 
        sed -e 's| "-fopenmp"\,||' \
            -i.bak tensorflow/tensorflow.bzl

        # Cleanup Files
        find . -type f -name '*.bak' -delete -exec \
            printf "Modified: %s\n" '{}' \; | sed 's|.bak$||'
        curl -LsS 'https://raw.githubusercontent.com/jjangsangy/MacOS-TensorflowBuilds/master/patches/0001-Fix-casting-to-size_t-for-mkl-conv-filter-dims.patch' \
            | git apply 2>/dev/null
    )
    return $?
}

function tf_configure () {
    (
        # Parameterize the rest
        PYTHON_BIN_PATH="/usr/local/bin/python${py_version::1}" \
        PYTHON_LIB_PATH="/usr/local/lib/python${py_version}/site-packages" \
        MKL_INSTALL_PATH="${TF_MKL_ROOT}" TF_MKL_ROOT="${TF_MKL_ROOT}" \
        TF_NEED_CUDA=0 TF_NEED_MKL=1   CC_OPT_FLAGS='-march=native' \
        TF_NEED_S3=1 TF_NEED_OPENCL_SYCL=0 \
        TF_NEED_GCP=0  TF_ENABLE_XLA=1 TF_NEED_HDFS=0 \
        TF_NEED_GDR=0  TF_NEED_MPI=0   TF_NEED_VERBS=0 \
        TF_NEED_OPENCL=0  TF_DOWNLOAD_MKL=0 ./configure
    )
    return $?

}

function tf_build () {
    (
        # Build Package
        TF_MKL_ROOT="${TF_MKL_ROOT}" bazel build -c opt \
                    --config=opt \
                    --config=mkl \
                    --copt="-DEIGEN_USE_VML" \
                    --copt=-mavx \
                    --copt=-mavx2 \
                    --copt=-mfma \
                    --copt=-msse4.1 \
                    --copt=-msse4.2 \
                    --linkopt="-Wl,-rpath,${TF_MKL_ROOT}/lib" \
                    --linkopt="-L${TF_MKL_ROOT}/lib" \
                    --linkopt="-lmklml" \
                    --linkopt="-iomp5" \
        //tensorflow/tools/pip_package:build_pip_package && \
        bazel-bin/tensorflow/tools/pip_package/build_pip_package "${tmpdir}/pkg"
    )
    return $?
}
