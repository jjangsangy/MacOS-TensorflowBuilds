MacOS TensorflowBuilds
======================
[![Apache License Version 2.0](https://img.shields.io/badge/license-Apache_2.0-green.svg)](LICENSE)
![PyPI](https://img.shields.io/pypi/format/Django.svg)
![v0.10 beta](https://img.shields.io/badge/v0.10-beta-orange.svg)

# Optimized Tensorflow Binaries for MacOS
Serving the underserved

## 1. (Intel MKL-DNN 2018)

| Release                                                                                                                                      | Interpreter | Optimization                            | OS          |
|----------------------------------------------------------------------------------------------------------------------------------------------|-------------|-----------------------------------------|-------------|
| [v1.3.1](https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/v1.3.1/tensorflow-1.3.1-cp27-cp27m-macosx_10_13_x86_64.whl)       | Python 2.7  | MKL MSSE4.2 MSSE4.1 MFMA MAVX2 MAVX     | High Sierra |
| [v1.3.1](https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/v1.3.1/tensorflow-1.3.1-cp36-cp36m-macosx_10_13_x86_64.whl)       | Python 3.6  | MKL MSSE4.2 MSSE4.1 MFMA MAVX2 MAVX     | High Sierra |
| [v1.4.0rc0](https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0rc0/tensorflow-1.4.0rc0-cp27-cp27m-macosx_10_13_x86_64.whl) | Python 2.7  | XLA MKL MSSE4.2 MSSE4.1 MFMA MAVX2 MAVX | High Sierra |
| [v1.4.0rc0](https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0rc0/tensorflow-1.4.0rc0-cp36-cp36m-macosx_10_13_x86_64.whl) | Python 3.6  | XLA MKL MSSE4.2 MSSE4.1 MFMA MAVX2 MAVX | High Sierra |

Intel MKL-DNN includes functionality similar to [Intel(R) Math Kernel
Library (Intel(R) MKL) 2017](https://software.intel.com/en-us/intel-mkl), but is not
API compatible. We are investigating how to unify the APIs in future Intel MKL releases.

This release contains a range of performance critical functions used in modern
image recognition topologies including Cifar\*, AlexNet\*, VGG\*, 
GoogleNet\* and ResNet\* optimized for wide range of Intel processors.


## Install


```sh
    $ TF_URL='https://github.com/jjangsangy/MacOS-TensorflowBuilds/raw/master/python3.6/tensorflow-1.4.0rc0-cp36-cp36m-macosx_10_13_x86_64.whl'
    $ pip3 installl --upgrade --force-upgrade "$TF_URL"
```

## Optimizations
* MKL: Intel Math Kernel Library
* XLA: Accelerated Linear Algebra
* MSSE4 etc.: SIMD Vectorization Extensions


## Build It Yourself

```sh
    $ ./install.sh -h

        DESCRIPTION:
        Installer script

        USAGE:
        ./install.sh --py ${py_version} --tf ${tf_version} --mkl ${mkl_dir}

        OPTIONS:
        -h| --help: Print this help message andn exit
        -p| --py version: [default 3.6]
            Spcify version of python
        -t| --tf version: [default 1.4.0rc0]
            Specify version of tensorflow
        -m| --mkl path: [default /opt/intel]
            Specify mkl library path
```
