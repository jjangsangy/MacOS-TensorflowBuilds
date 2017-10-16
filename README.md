Tensorflow Wheels
=================

## 1. (Intel MKL-DNN 2018)

Intel MKL-DNN includes functionality similar to [Intel(R) Math Kernel
Library (Intel(R) MKL) 2017](https://software.intel.com/en-us/intel-mkl), but is not
API compatible. We are investigating how to unify the APIs in future Intel MKL releases.

This release contains a range of performance critical functions used in modern
image recognition topologies including Cifar\*, AlexNet\*, VGG\*, 
GoogleNet\* and ResNet\* optimized for wide range of Intel processors.

## Install MKL Libraries

```bash
# Specify Installation
declare mkl_version=("0.10" "2018.0.20170720")
declare mkl_url="https://github.com/01org/mkl-dnn/releases/download/v${mkl_version[0]}/mklml_mac_${mkl_version[1]}.tgz"
declare py_version="3.6"
declare tf_version="1.3.1"
declare tf_url="https://github.com/tensorflow/tensorflow/archive/v${tf_version}.tar.gz"
declare basedir="/opt/intel"

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
```

## Create Work Directory

```sh
declare tmpdir=$(mktemp -dq /tmp/$(date | md5))

function cleanup () {
    test -O ${tmpdir} && rm -rf "${tmpdir}"
    return 0
}

# Ensures Cleanup
trap cleanup EXIT
```
## Setup Installation

```bash

function patch_configs () {
    # Patch Configuration Script
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

    # Cleanup Files
    find . -type f -name '*.bak' -delete
}

function tf_configure () {
    # Parameterize the rest
    PYTHON_BIN_PATH="/usr/local/bin/python${py_version::1}" \
    PYTHON_LIB_PATH="/usr/local/lib/python${py_version}/site-packages" \
    MKL_INSTALL_PATH="${basedir}/mklml" CC_OPT_FLAGS='-march=native' \
    TF_DOWNLOAD_MKL=0 TF_NEED_CUDA=0  TF_NEED_MKL=1 \
    TF_NEED_GCP=0    TF_ENABLE_XLA=0 TF_NEED_HDFS=0 \
    TF_NEED_OPENCL=0  TF_NEED_MPI=0   TF_NEED_VERBS=0 ./configure
}

function tf_build () {
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
                --linkopt="-Wl,-rpath,${basedir}/mklml/lib" \
                --linkopt="-L${basedir}/mklml/lib" \
                --linkopt="-lmklml" \
                --linkopt="-iomp5" \
    //tensorflow/tools/pip_package:build_pip_package || exit 1

    # Build Wheel
    bazel-bin/tensorflow/tools/pip_package/build_pip_package ${tmpdir}/pkg || exit 1
}

function tf_install () {
    # Install
    /usr/local/bin/python${py_version::1} -m \
    pip install --upgrade --force-reinstall ${tmpdir}/pkg/*.whl
}


if test -O $tmpdir && curl -LSs "$tf_url" | tar -xzf- -C "${tmpdir}"; then

    builtin pushd "${tmpdir}/tensorflow-${tf_version}"

    if cat configure third_party/mkl/BUILD | grep 'libmklml_intel.so'; then
        patch_configs
    fi

    tf_configure && tf_build && tf_install

    builtin popd
fi
```