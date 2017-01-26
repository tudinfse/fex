#!/usr/bin/env bash
# Download inputs

source ${COMP_BENCH}/install/common.sh

set -e
download_and_link ycsb-traces https://bitbucket.org/alexo_o/simd-swift-dependencies/downloads/ycsb-traces.tar.gz ${BIN_PATH}/benchmarks/ycsb-traces
set +e
