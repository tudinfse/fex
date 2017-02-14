#!/usr/bin/env bash

echo "=== Downloading inputs ==="
cd ${DATA_PATH}/

if [ -d "inputs" ]; then
    rm -rf inputs/
fi

set +e
wget -nc https://github.com/tudinfse/fex-inputs/archive/master.zip
set -e

unzip master.zip
mv ${DATA_PATH}/fex-inputs-master/ ${DATA_PATH}/inputs/
rm master.zip

cd -
echo "Splash installed"
