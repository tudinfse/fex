#!/usr/bin/env bash

echo "Installing native LLVM..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

export NAME="llvm-native"
export VERSION="5.0.0"
${PROJ_ROOT}/install/compilers/llvm.sh

echo "Native LLVM installed"
