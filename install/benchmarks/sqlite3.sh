#!/usr/bin/env bash

echo "Installing SQLite3..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

install_dependency "YCSB traces (inputs)" "${PROJ_ROOT}/install/dependencies/ycsb_traces.sh"

echo "SQLite3 installed"
