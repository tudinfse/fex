#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source ${COMP_BENCH}/install/common.sh

apt-get install -y pkg-config gettext \
                   libbsd-dev libx11-dev x11proto-xext-dev libxext-dev libxt-dev libxi-dev libxmu-dev \
                   libglib2.0-dev

echo "Downloading inputs..."
cd ${DATA_PATH}/

if [ -d "inputs" ]; then
    rm -rf inputs/parsec/
fi
mkdir inputs/

set +e
wget -nc https://wwwpub.zih.tu-dresden.de/~s7030030/inputs.tar.gz
set -e

tar xf inputs.tar.gz -C inputs/
rm inputs.tar.gz

cd -

echo "Downloading libraries..."
cd ${DATA_PATH}/

if [ -d "parsec_libs" ]; then
    rm -rf parsec_libs/
fi
mkdir parsec_libs/

set +e
wget -nc https://wwwpub.zih.tu-dresden.de/~s7030030/parsec_libs.tar.gz
set -e

tar xf parsec_libs.tar.gz -C parsec_libs/
rm parsec_libs.tar.gz

cd -

echo "Preparing libraries..."
cd ${DATA_PATH}/parsec_libs/

for lib in *; do
    if [ -d "${lib}" ]; then
        cp -r ${lib}/src/ ${COMP_BENCH}/src/libs/${lib}/src/
    fi
done

echo "Parsec installed"
