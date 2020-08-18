#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
 # shellcheck source=install/common.sh
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

# configurable variables
NAME=${NAME:-"llvm"}
VERSION=${VERSION:-"5.0.0"}

# ============
# LLVM
# ============
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"
BUILD_DIR="${WORK_DIR}/build"

mkdir -p ${WORK_DIR}

# download
fex2::install::download_and_untar http://llvm.org/releases/${VERSION}/llvm-${VERSION}.src.tar.xz ${SRC_DIR} 1

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
CLANG_DIR="${SRC_DIR}/tools/cfe-${VERSION}.src"
RT_DIR="${SRC_DIR}/tools/compiler-rt-${VERSION}.src"

# download
fex2::install::download_and_untar http://llvm.org/releases/${VERSION}/cfe-${VERSION}.src.tar.xz ${CLANG_DIR} 1
fex2::install::download_and_untar http://llvm.org/releases/${VERSION}/compiler-rt-${VERSION}.src.tar.xz ${RT_DIR} 1

# configure
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} ../src

# install
make -j8
make -j8 install

# make the LLVM installation directory discoverable
ln -sf "${BUILD_DIR}/bin/llvm-config" "/usr/bin/${NAME}-${VERSION}-config"

fex2::install::install_dependency "Gold Linker" "${PROJ_ROOT}/install/dependencies/gold-linker.sh"

echo "LLVM installed"
