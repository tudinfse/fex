#!/usr/bin/env bash

echo "Downloading inputs..."

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

echo "Inputs installed"
