#!/usr/bin/env bash

echo "Installing Parsec..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

apt-get install -y pkg-config gettext automake \
                   libbsd-dev libx11-dev x11proto-xext-dev libxext-dev libxt-dev libxi-dev libxmu-dev \
                   libglib2.0-dev

install_dependency "Parsec inputs" "${PROJ_ROOT}/install/dependencies/parsec_inputs.sh"
install_dependency "Parsec libraries" "${PROJ_ROOT}/install/dependencies/parsec_libs.sh"

echo "Parsec installed"
