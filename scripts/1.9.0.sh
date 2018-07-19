#!/usr/bin/env bash

function patch_configs () {
    (
        # Patch Configuration Script
        sed -e 's|libmklml_intel.so|libmklml.dylib|' \
            -e 's|libiomp5.so|libiomp5.dylib|'  \
            -i.bak third_party/mkl/{,mkl.}BUILD

        sed -e 's| "-fopenmp"\,||' \
            -i.bak tensorflow/tensorflow.bzl

        curl -LsS 'https://github.com/tensorflow/tensorflow/commit/7dd78367a19e101b45f0cafb5c4fbe6a3c840828.patch' \
            | git apply 2>/dev/null

        # Cleanup Files
        find . -type f -name '*.bak' -delete -exec \
            printf "Modified: %s\n" '{}' \; | sed 's|.bak$||'

    )
    return $?
}

function tf_configure () {
    (
        # Parameterize the rest
        CC_OPT_FLAGS='-Wno-c++11-narrowing -march=native -mavx -mavx2 -mfma -msse4.1 -msse4.2 -msse3' \
        PYTHON_BIN_PATH="/usr/local/bin/python${py_version::1}" \
        PYTHON_LIB_PATH="/usr/local/lib/python${py_version}/site-packages" \
        MKL_INSTALL_PATH="${TF_MKL_ROOT}" TF_MKL_ROOT="${TF_MKL_ROOT}" \
        TF_NEED_CUDA=0 TF_NEED_MKL=0 TF_DOWNLOAD_CLANG=1 \
        TF_NEED_S3=1 TF_NEED_OPENCL_SYCL=0 \
        TF_SET_ANDROID_WORKSPACE=0 TF_NEED_KAFKA=1 \
        TF_NEED_GCP=1  TF_ENABLE_XLA=1 TF_NEED_HDFS=1 \
        TF_NEED_GDR=0  TF_NEED_MPI=0   TF_NEED_VERBS=0 \
        TF_NEED_OPENCL=0  TF_DOWNLOAD_MKL=0 ./configure
    )
    return $?

}

function tf_build () {
    (
        # Build Package
        TF_MKL_ROOT="${TF_MKL_ROOT}" bazel build \
                    -c opt \
                    --config=opt \
                    --config=mkl \
                    --linkopt="-Wl,-rpath,${TF_MKL_ROOT}/lib" \
                    --linkopt="-L${TF_MKL_ROOT}/lib" \
                    --linkopt="-lmklml" \
                    --linkopt="-iomp5" \
        //tensorflow/tools/pip_package:build_pip_package && \
        bazel-bin/tensorflow/tools/pip_package/build_pip_package "${tmpdir}/pkg"
    )
    return $?
}
