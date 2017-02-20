#!/usr/bin/env bash

echo "Installing Splash..."

source ${PROJ_ROOT}/install/common.sh

install_dependency "Splash inputs" "${PROJ_ROOT}/install/dependencies/splash_inputs.sh"

echo "Splash installed"
