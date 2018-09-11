#!/usr/bin/env bash

echo "Installing SQLite3..."

source ${PROJ_ROOT}/install/common.sh

install_dependency "YCSB traces (inputs)" "${PROJ_ROOT}/install/dependencies/ycsb_traces.sh"

echo "SQLite3 installed"
