#!/usr/bin/env bash

echo "Installing GCC 6.1 ..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

export NAME="gcc"
export VERSION="6.1"
${PROJ_ROOT}/install/compilers/gcc.sh

echo "Native GCC 6.1"