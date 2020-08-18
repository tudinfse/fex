#!/usr/bin/env bash
###############################################################################
# !!!! WARNING !!!!
# This file is used across all experiment installations.
# Modify it only if you *know* what you are doing!
###############################################################################

# Prepare a safe scripting environment
set -euo pipefail
IFS=$'\n\t'

# Load fex2 install
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}/bash/install.sh"

# Set common variables
BIN_PATH=${BIN_PATH:-"./bin/"}

fex2::util::can_ask_user || echo "!! NO INTERACTIVE INSTALLATION: Yes is assumed for all questions"
