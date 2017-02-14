#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source ${COMP_BENCH}/install/common.sh

apt-get install -y pkg-config gettext \
                   libbsd-dev libx11-dev x11proto-xext-dev libxext-dev libxt-dev libxi-dev libxmu-dev \
                   libglib2.0-dev

echo "=== Downloading inputs ==="
cd ${DATA_PATH}/

if [ -d "inputs" ]; then
    rm -rf inputs/
fi
mkdir inputs/

set +e
wget -nc https://wwwpub.zih.tu-dresden.de/~s7030030/inputs.tar.gz
set -e

tar xf inputs.tar.gz -C inputs/
rm inputs.tar.gz

cd -

echo "Parsec installed"
