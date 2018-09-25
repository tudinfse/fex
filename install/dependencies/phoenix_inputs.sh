#!/usr/bin/env bash

echo "Installing Phoenix inputs..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

cd ${DATA_PATH}/

if [ -d "inputs" ]; then
    rm -rf inputs/phoenix/
fi
mkdir -p inputs/

set +e
wget -nc https://wwwpub.zih.tu-dresden.de/~s7030030/phoenix-inputs.tar.gz
set -e

tar xf phoenix-inputs.tar.gz -C inputs/
rm phoenix-inputs.tar.gz

echo "Phoenix inputs installed"
