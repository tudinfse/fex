#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

version="12.3"
install_dir="$PROJ_ROOT/benchmarks/postgresql"

sudo apt-get install -y bison flex

# download postgres
src_dir="$install_dir/postgres-$version/src"
mkdir -p "$src_dir"
download_and_untar "https://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.gz" "$src_dir" 1

# create a postgres user (non-root user is needed for interaction with postgres)
id -u fex2_postgres || sudo useradd --no-create-home fex2_postgres

# Install ycsb-traces inputs
inputs_dir="$install_dir/inputs/ycsb-traces"
mkdir -p $"inputs_dir"
download_and_untar https://wwwpub.zih.tu-dresden.de/~s7030030/ycsb-traces.tar.gz "$inputs_dir" 1
