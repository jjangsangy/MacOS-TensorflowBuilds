MacOS TensorflowBuilds
======================
[![Apache License Version 2.0](https://img.shields.io/badge/license-Apache_2.0-green.svg)](LICENSE)
![PyPI](https://img.shields.io/pypi/format/Django.svg)
![v0.10 beta](https://img.shields.io/badge/v0.10-beta-orange.svg)

# Optimized Tensorflow Binaries for MacOS
Serving the underserved

## 1. (Intel MKL-DNN 2018)

| Version                | Release                                        | Optimization               | OS          |
| ---------------------- | ---------------------------------------------- | -------------------------- | ----------- |
| [v1.3.1][v1.3.1]       | [2.7][py2.7 v1.3.1],    [3.6][py3.6 v1.3.1]    | MKL MSSE4.2 MAVX2 MAVX     | High Sierra |
| [v1.4.0rc0][v1.4.0rc0] | [2.7][py2.7 v1.4.0rc0], [3.6][py3.6 v1.4.0rc0] | XLA MKL MSSE4.2 MAVX2 MAVX | High Sierra |
| [v1.4.0][v1.4.0]       | [2.7][py2.7 v1.4.0],    [3.6][py3.6 v1.4.0]    | XLA MKL MSSE4.2 MAVX2 MAVX | High Sierra |
| [v1.4.1][v1.4.1]       | [2.7][py2.7 v1.4.1],    [3.6][py3.6 v1.4.1]    | XLA MKL MSSE4.2 MAVX2 MAVX | High Sierra |
| [v1.7.0rc1][v1.7.0rc1] | [2.7][py2.7 v1.7.0rc1], [3.6][py3.6 v1.7.0rc1] | XLA MKL MSSE4.2 MAVX2 MAVX | High Sierra |


## Note `v1.7.0rc1` is slow

The suggested version to run currently running on MKL is `1.4.1`

## Intel MKL-DNN

Intel MKL-DNN includes functionality similar to 
[Intel(R) Math Kernel Library (Intel(R) MKL) 2017](https://software.intel.com/en-us/intel-mkl), but is not API compatible.
We are investigating how to unify the APIs in future Intel MKL releases.

This release contains a range of performance critical functions used in modern image recognition topologies including Cifar\*, AlexNet\*, VGG\*,  GoogleNet\* and ResNet\* optimized for wide range of Intel processors.


## Python 3 Install

```sh
    $ TF_URL='https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.1/tensorflow-1.4.1-cp36-cp36m-macosx_10_13_x86_64.whl'
    $ pip3 installl --upgrade --force-upgrade "$TF_URL"
```

## Python 2 Install

```sh
    $ TF_URL='https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.1/tensorflow-1.4.1-cp27-cp27m-macosx_10_13_x86_64.whl'
    $ pip2 installl --upgrade --force-upgrade "$TF_URL"
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
        -i| --inplace [default off]
            Install tensorflow inplace right after compilation
```

[v1.3.1]: https://github.com/tensorflow/tensorflow/releases/tag/v1.3.1
[v1.4.0rc0]: https://github.com/tensorflow/tensorflow/releases/tag/v1.4.0-rc0
[v1.4.0]: https://github.com/tensorflow/tensorflow/releases/tag/v1.4.0
[v1.4.1]: https://github.com/tensorflow/tensorflow/releases/tag/v1.4.1
[v1.7.0rc1]: https://github.com/tensorflow/tensorflow/releases/tag/v1.7.0-rc1

[py2.7 v1.3.1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/v1.3.1/tensorflow-1.3.1-cp27-cp27m-macosx_10_13_x86_64.whl
[py3.6 v1.3.1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/v1.3.1/tensorflow-1.3.1-cp36-cp36m-macosx_10_13_x86_64.whl
[py2.7 v1.4.0rc0]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0rc0/tensorflow-1.4.0rc0-cp27-cp27m-macosx_10_13_x86_64.whl
[py3.6 v1.4.0rc0]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0rc0/tensorflow-1.4.0rc0-cp36-cp36m-macosx_10_13_x86_64.whl
[py2.7 v1.4.0]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0/tensorflow-1.4.0-cp27-cp27m-macosx_10_13_x86_64.whl
[py3.6 v1.4.0]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.0/tensorflow-1.4.0-cp36-cp36m-macosx_10_13_x86_64.whl
[py2.7 v1.4.1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.1/tensorflow-1.4.1-cp27-cp27m-macosx_10_13_x86_64.whl
[py3.6 v1.4.1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.4.1/tensorflow-1.4.1-cp36-cp36m-macosx_10_13_x86_64.whl
[py2.7 v1.7.0rc1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.7.0rc1/tensorflow-1.7.0rc1-cp27-cp27m-macosx_10_13_x86_64.whl
[py3.6 v1.7.0rc1]: https://github.com/jjangsangy/MacOS-TensorflowBuilds/releases/download/1.7.0rc1/tensorflow-1.7.0rc1-cp36-cp36m-macosx_10_13_x86_64.whl