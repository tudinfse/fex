#!/usr/bin/env bash

echo "Installing MemSlap..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

apt-get install -y libevent-dev

# below are installation instructions for libmemcached & memaslap client (install on client machine)
NAME="libmemcached"
VERSION="1.0.16"

STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${BIN_PATH}/${NAME}-${VERSION}/src"

mkdir -p ${WORK_DIR}

# download
download_and_untar https://launchpad.net/libmemcached/1.0/${VERSION}/+download/libmemcached-${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# build
cd ${SRC_DIR}
CFLAGS=-pthread LDFLAGS=-pthread LIBS=-levent ./configure --enable-memaslap
sed -i "s/#am__append_42 = clients\/memaslap/am__append_42 = clients\/memaslap/g" Makefile
sed -i "s/#am__EXEEXT_2 = clients\/memaslap/am__EXEEXT_2 = clients\/memaslap/g" Makefile
make -j

# install
make -j install

echo "MemSlap installed"
