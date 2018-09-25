#!/usr/bin/env bash

echo "Installing Gold Linker..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

apt-get install -y texinfo

NAME="binutils_gold"
VERSION="master"

STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"
BUILD_DIR="${WORK_DIR}/build"
INSTALL_DIR="${BIN_PATH}/${NAME}/install"

mkdir -p ${WORK_DIR}

# download
clone_git_repo git://sourceware.org/git/binutils-gdb.git ${STORED_SRC_DIR} '' ''
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
${SRC_DIR}/configure --enable-gold --enable-plugins --disable-werror --prefix=${INSTALL_DIR}

# build
make
make install

# replace the linker
rm ${INSTALL_DIR}/bin/ld
ln ${INSTALL_DIR}/bin/ld.gold ${INSTALL_DIR}/bin/ld

echo "Gold Linker installed"
