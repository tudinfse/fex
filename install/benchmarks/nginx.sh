#!/usr/bin/env bash

echo "Installing Nginx..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

apt-get install -y libssl-dev libtext-lorem-perl apache2-utils

NAME="nginx"
VERSION="1.4.0"
STORED_SRC_DIR="${DATA_PATH}/${NAME}-${VERSION}"
WORK_DIR="${BIN_PATH}/${NAME}-${VERSION}"
SRC_DIR="${WORK_DIR}/src"

# nginx requires X permission for all users on the path: http://stackoverflow.com/questions/6795350/nginx-403-forbidden-for-all-files
mkdir -p ${WORK_DIR}
chmod o+x ${WORK_DIR}

# download
download_and_untar http://nginx.org/download/nginx-${VERSION}.tar.gz ${STORED_SRC_DIR} 1
ln -sf ${STORED_SRC_DIR} ${SRC_DIR}

# patch
sed -i "s/name\[1\]/name\[0\]/g" ${SRC_DIR}/src/core/ngx_hash.h

echo "Nginx installed"
