#!/usr/bin/env bash

echo "Installing YCSB traces..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

WORK_DIR="${DATA_PATH}/inputs/ycsb-traces"
mkdir -p ${WORK_DIR}

download_and_untar https://wwwpub.zih.tu-dresden.de/~s7030030/ycsb-traces.tar.gz ${WORK_DIR} 1

echo "YCSB traces installed"