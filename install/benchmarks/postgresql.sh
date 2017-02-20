#!/usr/bin/env bash

echo "Installing PostgreSQL..."

set -e
source ${PROJ_ROOT}/install/common.sh

mkdir -p ${DATA_PATH}/postgres/
cd ${DATA_PATH}/postgres/

wget -nc https://github.com/postgres/postgres/archive/REL9_5_1.tar.gz
tar -xzf REL9_5_1.tar.gz
cd postgres-REL9_5_1
set +e

useradd --no-create-home postgres || true  # non-root user is needed for interaction with postgres

install_dependency "YCSB traces (inputs)" "${PROJ_ROOT}/install/dependencies/ycsb_traces.sh"

echo "PostgreSQL installed"
