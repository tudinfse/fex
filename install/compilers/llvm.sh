#!/usr/bin/env bash

echo "Installing LLVM..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

# configurable variables
NAME=${NAME:-"llvm"}
VERSION=${VERSION:-"5.0.0"}

# ============
# LLVM
# ============
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"  # the directory where we store sources
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"  # the directory where we link the sources and build them
SRC_DIR="${WORK_DIR}/src"
BUILD_DIR="${WORK_DIR}/build"

mkdir -p ${WORK_DIR}

# download
download_and_untar http://llvm.org/releases/${VERSION}/llvm-${VERSION}.src.tar.xz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} ../src

# install
make -j8
make -j8 install

# ============
# CLang
# ============
STORED_CLANG_DIR="${DATA_PATH}/cfe-${NAME}-${VERSION}"
STORED_RT_DIR="${DATA_PATH}/compiler-rt-${NAME}-${VERSION}"

CLANG_DIR="${SRC_DIR}/tools/cfe-${VERSION}.src"
RT_DIR="${SRC_DIR}/tools/compiler-rt-${VERSION}.src"

# download
download_and_untar http://llvm.org/releases/${VERSION}/cfe-${VERSION}.src.tar.xz ${STORED_CLANG_DIR} 1
download_and_untar http://llvm.org/releases/${VERSION}/compiler-rt-${VERSION}.src.tar.xz ${STORED_RT_DIR} 1
ln -sf ${STORED_CLANG_DIR} ${CLANG_DIR}
ln -sf ${STORED_RT_DIR} ${RT_DIR}

# configure
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} ../src

# install
make -j8
make -j8 install

# make the LLVM installation directory discoverable
ln -sf ${BUILD_DIR}/bin/llvm-config /usr/bin/${NAME}-${VERSION}-config

install_dependency "Gold Linker" "${PROJ_ROOT}/install/dependencies/gold-linker.sh"

echo "LLVM installed"
