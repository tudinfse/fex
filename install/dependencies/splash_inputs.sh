#!/usr/bin/env bash

echo "Downloading inputs..."

cd ${DATA_PATH}/

if [ -d "inputs" ]; then
    rm -rf inputs/splash/
fi
mkdir -p inputs/

set +e
wget -nc https://wwwpub.zih.tu-dresden.de/~s7030030/splash-inputs.tar.gz
set -e

tar xf splash-inputs.tar.gz
rm splash-inputs.tar.gz

cd -

echo "Inputs installed"
