#!/usr/bin/env bash

echo "Installing Parsec inputs..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

WORK_DIR="${DATA_PATH}/inputs"
mkdir -p ${WORK_DIR}

download_and_untar https://wwwpub.zih.tu-dresden.de/~s7030030/parsec-inputs.tar.gz ${WORK_DIR} 1

echo "Parsec inputs installed"
