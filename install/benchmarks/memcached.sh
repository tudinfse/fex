#!/usr/bin/env bash

echo "Installing Memcached..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

NAME="memcached"
VERSION="1.4.15"
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"

mkdir -p ${WORK_DIR}
clone_git_repo https://github.com/memcached/memcached.git ${STORED_SRC_DIR} ${VERSION} ${PROJ_ROOT}/install/benchmarks/memcached/memcached.1.4.15.patch
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

install_dependency "Memslap" "${PROJ_ROOT}/install/dependencies/memslap.sh"

echo "Memcached installed"
