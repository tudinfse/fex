#!/usr/bin/env bash

echo "Installing Phoenix inputs..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

WORK_DIR="${DATA_PATH}/inputs/phoenix/"

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

declare -a benchmarks=("histogram" "linear_regression" "string_match" "word_count")
for bmidx in "${!benchmarks[@]}"; do
  bm="${benchmarks[$bmidx]}"

  wget -nc http://csl.stanford.edu/~christos/data/${bm}.tar.gz
  tar -xzf ${bm}.tar.gz
  mkdir -p ${bm}/input/
  mv -uf ${bm}_datafiles/* ${bm}/input/
  rm -rf ${bm}_datafiles/
done

echo "Phoenix inputs installed"
