#!/usr/bin/env bash

echo "Installing Apache..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

apt-get install -y libtext-lorem-perl apache2-utils automake

NAME="httpd"
VERSION="2.4.18"
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
SRC_DIR="${BIN_PATH}/${NAME}/src"

mkdir -p ${BIN_PATH}/${NAME}
download_and_untar https://archive.apache.org/dist/httpd/httpd-${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

install_dependency "Apache libraries" "${PROJ_ROOT}/install/dependencies/apache_libs.sh"

echo "Apache installed"