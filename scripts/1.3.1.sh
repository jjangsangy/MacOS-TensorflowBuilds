#!/usr/bin/env bash

function patch_configs () {
    # Patch Configuration Script
    (
        sed -e 's/$OSNAME/Linux/' \
            -e 's|"lib/libmklml_intel.so"|"lib/libmklml.dylib"|' \
            -e 's|"lib/libiomp5.so"|"lib/libiomp5.dylib"|' \
            -e '/libdl.so.2/ d' \
            -i.bak configure

        sed -e '/libdl.so.2/ d' \
            -e 's/\.so/\.dylib/' \
            -e 's/_intel//' \
            -i.bak third_party/mkl/BUILD

        sed -e 's| "-fopenmp"\,||' \
            -i.bak tensorflow/tensorflow.bzl

        find . -type f -name '*.bak' -delete -exec \
            printf "Modified: %s\n" '{}' \; | sed 's|.bak$||'
    )
    return $?
}

function tf_configure () {
    # Parameterize the rest
    if PYTHON_BIN_PATH="/usr/local/bin/python${py_version::1}" \
    PYTHON_LIB_PATH="/usr/local/lib/python${py_version}/site-packages" \
    MKL_INSTALL_PATH="${mkl_dir}/mklml" CC_OPT_FLAGS='-march=native' \
    TF_DOWNLOAD_MKL=0 TF_NEED_CUDA=0  TF_NEED_MKL=1 \
    TF_NEED_GCP=0    TF_ENABLE_XLA=0 TF_NEED_HDFS=0 \
    TF_NEED_OPENCL=0  TF_NEED_MPI=0   TF_NEED_VERBS=0 ./configure; then
        return 0
    else
        return 1
    fi
}

function tf_build () {
    (
        # Build Package
        bazel build -c opt \
                --config=opt \
                --config=mkl \
                --copt="-DEIGEN_USE_VML" \
                --copt=-mavx \
                --copt=-mavx2 \
                --copt=-mfma \
                --copt=-msse4.1 \
                --copt=-msse4.2 \
                --linkopt="-Wl,-rpath,${mkl_dir}/mklml/lib" \
                --linkopt="-L${mkl_dir}/mklml/lib" \
                --linkopt="-lmklml" \
                --linkopt="-iomp5" \
        //tensorflow/tools/pip_package:build_pip_package && \
        bazel-bin/tensorflow/tools/pip_package/build_pip_package ${tmpdir}/pkg
    )
    return $?
}