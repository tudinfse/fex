#!/usr/bin/env bash

echo "Installing PostgreSQL..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

NAME="postgres"
VERSION="REL9_5_1"
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"

mkdir -p ${WORK_DIR}

# download
download_and_untar https://github.com/postgres/postgres/archive/${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# create a postgres user
useradd --no-create-home postgres || true  # non-root user is needed for interaction with postgres

install_dependency "YCSB traces (inputs)" "${PROJ_ROOT}/install/dependencies/ycsb_traces.sh"

echo "PostgreSQL installed"
