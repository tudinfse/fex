#!/usr/bin/env bash

apt-get install -y wget libc6-dev-i386

set -e
cd ${PROJ_ROOT}src/phoenix_pthread
./copyinputs.sh
set +e
