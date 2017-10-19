#!/usr/bin/env bash

set -euf -o pipefail

# Specify Installation
declare mkl_version=("0.10" "2018.0.20170720")
declare mkl_url="https://github.com/01org/mkl-dnn/releases/download/v${mkl_version[0]}/mklml_mac_${mkl_version[1]}.tgz"
declare py_version="3.6"
declare tf_version="1.4.0rc0"
declare tf_url="https://github.com/tensorflow/tensorflow/archive/v${tf_version}.tar.gz"
declare basedir="/opt/intel"
declare TF_MKL_ROOT="${basedir}/mklml"

brew install 'https://raw.githubusercontent.com/Homebrew/homebrew-core/fe69832dd62821767996f10d8a4bc1a960bde899/Formula/bazel.rb'


# Untar into ${basedir}
sudo command mkdir -m 1777 -p "${basedir}"
curl -LSs "${mkl_url}" | \
tar -xvzf- \
    -C "${basedir}" \
    -s "/_mac_${mkl_version[1]}//"

# Write Shared Headers
for lib in lib/{libmklml,libiomp5}.dylib; do
    command ln -sfv       {${basedir}/mklml,'/usr/local'}/${lib}
    install_name_tool -id {${basedir}/mklml,'/usr/local'}/${lib}
done

declare tmpdir=$(mktemp -dq /tmp/$(date | md5))

function cleanup () {
    test -O ${tmpdir} && rm -rf "${tmpdir}"
    return 0
}

function patch_configs () {
    # Patch Configuration Script
    sed -e 's|libmklml_intel.so|libmklml.dylib|' \
        -e 's|libiomp5.so|libiomp5.dylib|'  \
        -i.bak third_party/mkl/{,mkl.}BUILD
    sed -e 's| "-fopenmp,"||' \
        -i.bak tensorflow/tensorflow.bzl

    # Cleanup Files
    find . -type f -name '*.bak' -delete -exec \
        printf "Modified: %s\n" '{}' \; | sed 's|.bak$||'
    curl -LsS 'https://raw.githubusercontent.com/jjangsangy/MacOS-TensorflowBuilds/master/patches/0001-Fix-casting-to-size_t-for-mkl-conv-filter-dims.patch' \
        | git apply 2>/dev/null
}

function tf_configure () {
    # Parameterize the rest
    PYTHON_BIN_PATH="/usr/local/bin/python${py_version::1}" \
    PYTHON_LIB_PATH="/usr/local/lib/python${py_version}/site-packages" \
    MKL_INSTALL_PATH="${TF_MKL_ROOT}" TF_MKL_ROOT="${TF_MKL_ROOT}" \
    TF_NEED_CUDA=0 TF_NEED_MKL=1   CC_OPT_FLAGS='-march=native' \
    TF_NEED_GCP=0  TF_ENABLE_XLA=1 TF_NEED_HDFS=0 \
    TF_NEED_GDR=0  TF_NEED_MPI=0   TF_NEED_VERBS=0 \
    TF_NEED_OPENCL=0  TF_DOWNLOAD_MKL=0 ./configure
}

function tf_build () {
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
    //tensorflow/tools/pip_package:build_pip_package

    # Build Wheel
    bazel-bin/tensorflow/tools/pip_package/build_pip_package ${tmpdir}/pkg
}

function tf_install () {
    # Install
    /usr/local/bin/python${py_version::1} -m \
    pip install --upgrade --force-reinstall ${tmpdir}/pkg/*.whl
}


if test -O $tmpdir && curl -LSs "$tf_url" | tar -xzf- -C "${tmpdir}"; then

    builtin pushd "${tmpdir}/tensorflow-${tf_version}"

    tf_configure

    cat third_party/mkl/{mkl.,}BUILD | grep 'libmklml_intel.so' &>/dev/null && patch_configs

    tf_build && tf_install && builtin popd && cleanup
fi
