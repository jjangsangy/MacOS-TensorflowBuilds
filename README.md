MacOS TensorflowBuilds
======================
[![Apache License Version 2.0](https://img.shields.io/badge/license-Apache_2.0-green.svg)](LICENSE)
![PyPI](https://img.shields.io/pypi/format/Django.svg)
![v0.10 beta](https://img.shields.io/badge/v0.10-beta-orange.svg)

# Optimized Tensorflow Binaries for MacOS
Serving the underserved

## 1. (Intel MKL-DNN 2018)

| Release  | Interpreter | Optimization | OS          | Link                                                                                                                                                                                       |
|----------|-------------|--------------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1.3.0    | Python 2.7  | MKL          | High Sierra | [tensorflow-1.3.1-cp27-cp27m-macosx_10_13_x86_64.whl](https://github.com/jjangsangy/MacOS-TensorflowBuilds/raw/master/python2.7/tensorflow-1.3.1-cp27-cp27m-macosx_10_13_x86_64.whl)       |
| 1.3.0    | Python 3.6  | MKL          | High Sierra | [tensorflow-1.3.1-cp36-cp36m-macosx_10_13_x86_64.whl](https://github.com/jjangsangy/MacOS-TensorflowBuilds/raw/master/python3.6/tensorflow-1.3.1-cp36-cp36m-macosx_10_13_x86_64.whl)       |
| 1.4.0rc0 | Python 2.7  | MKL, XLA     | High Sierra | [tensorflow-1.4.0rc0-cp27-cp27m-macosx_10_13_x86_64.whl](https://github.com/jjangsangy/MacOS-TensorflowBuilds/raw/master/python2.7/tensorflow-1.4.0rc0-cp27-cp27m-macosx_10_13_x86_64.whl) |
| 1.4.0rc0 | Python 3.6  | MKL, XLA     | High Sierra | [tensorflow-1.4.0rc0-cp36-cp36m-macosx_10_13_x86_64.whl](https://github.com/jjangsangy/MacOS-TensorflowBuilds/raw/master/python3.6/tensorflow-1.4.0rc0-cp36-cp36m-macosx_10_13_x86_64.whl) |

Intel MKL-DNN includes functionality similar to [Intel(R) Math Kernel
Library (Intel(R) MKL) 2017](https://software.intel.com/en-us/intel-mkl), but is not
API compatible. We are investigating how to unify the APIs in future Intel MKL releases.

This release contains a range of performance critical functions used in modern
image recognition topologies including Cifar\*, AlexNet\*, VGG\*, 
GoogleNet\* and ResNet\* optimized for wide range of Intel processors.

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