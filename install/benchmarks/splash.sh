#!/usr/bin/env bash

echo "Installing Splash..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

install_dependency "Splash inputs" "${PROJ_ROOT}/install/dependencies/splash_inputs.sh"

echo "Splash installed"
