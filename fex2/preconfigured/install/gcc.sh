#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
 # shellcheck source=install/common.sh
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

# dependencies
apt-get install -y libgmp3-dev libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg libmpc-dev build-essential libc6-dev-i386 zlib1g-dev libncurses-dev libtool

# configurable variables
NAME=${NAME:-"gcc"}
VERSION=${VERSION:-"6.0"}

# installation paths
SRC_DIR="${BIN_PATH}/${NAME}/src"
BUILD_DIR="${BIN_PATH}/${NAME}/build"

mkdir -p ${BIN_PATH}/${NAME}

# download
download_and_untar ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-${VERSION}/gcc-${VERSION}.tar.gz ${SRC_DIR} 1

# isl
SRC_DIR="${DATA_PATH}/isl"
download_and_untar ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2 ${SRC_DIR} 1

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
${SRC_DIR}/configure --enable-languages=c,c++ --enable-libmpx --enable-multilib --prefix=${BUILD_DIR} --with-system-zlib

# install
make -j8
make install

install_dependency "BinUtils" "${PROJ_ROOT}/install/dependencies/binutils.sh"
