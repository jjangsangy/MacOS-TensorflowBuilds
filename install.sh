#!/usr/bin/env bash

declare tmpdir=$(mktemp -dq /tmp/$(date | md5))

function cleanup () {
    if test -O ${tmpdir}; then
        printf "\nCleaning up %s\n" "${tmpdir}"
        rm -rf "${tmpdir}"
    fi
    bazel shutdown
    return
}

function usage() {

    local -i i=1
    for C in {RED,GRE,YEL,BLU,PUR,CYA,WHI,GRY}; do
        local $C=$(tput setaf ${i})
        i=$((i + 1))
    done
    local END=$(tput sgr0)

    cat <<- _EOF

    ${GRE}DESCRIPTION:${END}
    Installer script

    ${GRE}USAGE:${END}
    ./install.sh --py ${py_version} --tf ${tf_version} --mkl ${mkl_dir}

    ${GRE}OPTIONS:${END}
    ${WHI}-h| --help:${END} Print this help message andn exit
    ${WHI}-p| --py version:${END} [default 3.6]
        Spcify version of python
    ${WHI}-t| --tf version:${END} [default 1.4.0rc0]
        Specify version of tensorflow
    ${WHI}-m| --mkl path:${END}  [default /opt/intel]
        Specify mkl library path
    ${WHI}-i| --inplace${END} [default off]
        Install tensorflow inplace right after compilation

_EOF
exit 1
}

trap cleanup EXIT
declare py_version="3.6" tf_version="1.4.0-rc0" mkl_dir="/opt/intel" inplace=0

while [ $# -gt 0 ]; do
    OPTION="${1-}" VALUE="${2-}"
    case "${OPTION}" in
        -h| --help) usage; ;;
        -p| --py) py_version="${VALUE}"
            shift; ;;
        -t| --tf) tf_version="${VALUE}"
            shift; ;;
        -m| --mkl) mkl_dir="${VALUE}"
            shift; ;;
        --py=?*) py_version="${OPTION#*=}" ;;
        --tf=?*) tf_version="${OPTION#*=}" ;;
        --mkl=?*) mkl_dir="${OPTION#*=}" ;;
        -i| --inplace) inplace=1
    esac
    shift
done

source "scripts/${tf_version}.sh" || exit

declare mkl_version=("0.10" "2018.0.20170720")
declare mkl_url="https://github.com/01org/mkl-dnn/releases/download/v${mkl_version[0]}/mklml_mac_${mkl_version[1]}.tgz"
declare tf_url="https://github.com/tensorflow/tensorflow/archive/v${tf_version}.tar.gz"

export TF_MKL_ROOT="${mkl_dir}/mklml"

function setup() {
    # Untar into ${mkl_dir}
    otool -D ${mkl_dir}/mklml/lib/libmklml.dylib &>/dev/null || (
        sudo command mkdir -m 1777 -p "${mkl_dir}"
        curl -LSs "${mkl_url}" | \
        tar -xvzf- \
            -C "${mkl_dir}" \
            -s "/_mac_${mkl_version[1]}//" \
    brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/fe69832dd62821767996f10d8a4bc1a960bde899/Formula/bazel.rb
    )

    otool -D /usr/local/lib/libmklml.dylib &>/dev/null || (
        for lib in lib/{libmklml,libiomp5}.dylib; do
            command ln -sfv       {${mkl_dir}/mklml,'/usr/local'}/${lib}
            install_name_tool -id {${mkl_dir}/mklml,'/usr/local'}/${lib}
        done
    brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/fe69832dd62821767996f10d8a4bc1a960bde899/Formula/bazel.rb
    )
}

function print_config () {
    printf "\nConfiguring:\n============\n"
    printf "\t%s %s %s\n" {,$}{tf_version,py_version,mkl_dir} | column -t
    printf "\n"
}

function tf_install () {
    /usr/local/bin/python${py_version::1} -m \
    pip install --upgrade "${tmpdir}/pkg/*.whl"
    return $?
}

if test -O $tmpdir && curl -LSs "$tf_url" | tar -xzf- -C "${tmpdir}"; then

    echo "Moving into Tensorflow Repo"
    builtin pushd "${tmpdir}/tensorflow-${tf_version}" \
        && setup \
        && print_config \
        && patch_configs \
        && tf_configure \
        && tf_build
    builtin popd

    [ -d "${tmpdir}/pkg" ] && cp -R "${tmpdir}/pkg" .
    [  "${inplace}" = 1  ] && tf_install
fi
