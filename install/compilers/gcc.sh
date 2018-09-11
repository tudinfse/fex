#!/usr/bin/env bash

echo "Installing GCC..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

# dependencies
apt-get install -y libgmp3-dev libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg libmpc-dev build-essential libc6-dev-i386 zlib1g-dev libncurses-dev libtool

# configurable variables
NAME=${NAME:-"gcc"}
VERSION=${VERSION:-"6.0"}

# installation paths
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
SRC_DIR="${BIN_PATH}/${NAME}/src"
BUILD_DIR="${BIN_PATH}/${NAME}/build"

mkdir -p ${BIN_PATH}/${NAME}

# download
download_and_untar ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-${VERSION}/gcc-${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# isl
STORED_SRC_DIR="${DATA_PATH}/isl"
download_and_untar ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2 ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}/isl

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
${SRC_DIR}/configure --enable-languages=c,c++ --enable-libmpx --enable-multilib --prefix=${BUILD_DIR} --with-system-zlib

# install
make -j8
make install

install_dependency "BinUtils" "${PROJ_ROOT}/install/dependencies/binutils.sh"

echo "GCC installed"
