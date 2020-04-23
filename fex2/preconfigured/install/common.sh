#!/usr/bin/env bash
###############################################################################
# !!!! WARNING !!!!
# This file is used across all experiments.
# Modify it only if you *know* what you are doing!
###############################################################################

# == Prepare a safe scripting environment ==

set -euo pipefail
IFS=$'\n\t'

# == Set common variables ==

BIN_PATH=${BIN_PATH:-"./bin/"}

# == Define common functions ==

function required_str {
    if [ -z $1 ]; then
        echo "The string argument is empty!"
        exit 1
    fi
}

# Download a tar archive from URL $1
# and unpack it to $2
# Optionally, set $3 to 1 to skip the uppermost directory of the archive
function download_and_untar {
    local url=$1 ; required_str ${url}
    local unpack_path=$2 ; required_str ${unpack_path}
    local strip=${3:-0} ;

    if [ -d ${unpack_path} ] && [ ! -z "$(ls -A ${unpack_path})" ]; then
        echo "The directory ${unpack_path} already exist."
        while true; do
            read -p "Do you wish to reinstall ${unpack_path} [Yn]?" yn
            case $yn in
                [Yy]* ) rm -rf ${unpack_path}; break;;
                [Nn]* ) echo "Skip"; return;;
                * ) echo "Please answer 'y' or 'n'.";;
            esac
        done
    fi

    wget -N -O tmp.tar ${url}
    mkdir -p ${unpack_path}
    tar xf tmp.tar -C ${unpack_path} --strip-components=${strip}
    rm tmp.tar
}


# Clone a git repo from URL $1
# to directory $2
# Optionally, checkout $3
function clone_git_repo {
    local url=$1 ; required_str ${url}
    local path=$2 ; required_str ${path}
    local checkout=$3

    if [ -d ${path} ] && [ ! -z "$(ls -A ${path})" ]; then
        echo "The directory ${path} already exist."
        while true; do
            read -p "Do you wish to reinstall ${path} [Yn]?" yn
            case $yn in
                [Yy]* ) rm -rf ${path}; break;;
                [Nn]* ) echo "Skip"; return;;
                * ) echo "Please answer 'y' or 'n'.";;
            esac
        done
    fi

    if [ ! -z ${checkout} ]; then
        set +e
        git clone ${url} ${path}
        set -e
        pushd ${path}
        git checkout ${checkout}
        popd
    else
        set +e
        git clone --depth 1 ${url} ${path}
        set -e
    fi
}


function install_dependency {
    local name=$1 ; required_str $name
    local path=$2 ; required_str $path

    while true; do
        read -p "Do you wish to install $1 [Yn]?" yn
        case $yn in
            [Yy]* ) eval "$2"; break;;
            [Nn]* ) echo "Skip"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}
