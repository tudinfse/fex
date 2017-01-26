#!/usr/bin/env bash

set -e
source ${COMP_BENCH}/install/common.sh
download_and_link ycsb-traces https://bitbucket.org/alexo_o/simd-swift-dependencies/downloads/ycsb-traces.tar.gz ${BIN_PATH}/benchmarks/ycsb-traces

mkdir -p ${DATA_PATH}/postgres/
cd ${DATA_PATH}/postgres/

wget -nc https://github.com/postgres/postgres/archive/REL9_5_1.tar.gz
tar -xzf REL9_5_1.tar.gz
cd postgres-REL9_5_1
set +e

useradd --no-create-home postgres || true  # non-root user is needed for interaction with postgres
