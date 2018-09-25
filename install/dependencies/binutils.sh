#!/usr/bin/env bash

echo "Installing BinUtils..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

NAME="binutils"
VERSION="2.26.1"

STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"
BUILD_DIR="${WORK_DIR}/build"

mkdir -p ${WORK_DIR}

# download
download_and_untar http://ftp.gnu.org/gnu/binutils/binutils-${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
CXXFLAGS="-Wno-unused-function -O2" ${SRC_DIR}/configure --enable-gold=yes --enable-ld=yes

# install
make -j8
make install

echo "BinUtils installed"