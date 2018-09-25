#!/usr/bin/env bash

echo "Installing Parsec libraries..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

WORK_DIR="${DATA_PATH}/parsec_libs"
mkdir -p ${WORK_DIR}

download_and_untar https://wwwpub.zih.tu-dresden.de/~s7030030/parsec_libs.tar.gz ${WORK_DIR} 0

cd ${WORK_DIR}
for lib in *; do
    if [ -d "${lib}" ]; then
        cp -r ${lib}/src/ ${PROJ_ROOT}/src/libs/${lib}/
    fi
done

echo "Parsec libraries installed"