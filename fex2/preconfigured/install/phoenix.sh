#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

sudo apt-get install -y wget libc6-dev-i386

all_benchmarks=(
"histogram"
"kmeans"
"linear_regression"
"matrix_multiply"
"pca"
"string_match"
"word_count"
)

# get the benchmark sources
tmp_dir="/tmp/phoenix"
clone_git_repo https://github.com/kozyraki/phoenix.git "$tmp_dir" ''

# copy the sources into correct paths
install_dir="$PROJ_ROOT/benchmarks/phoenix"
mkdir -p "$install_dir/include/"
cp -r "$tmp_dir/phoenix-2.0/include/." "$install_dir/include/"
for benchmark in ${all_benchmarks[*]}; do
    mkdir -p "$install_dir/$benchmark/src/"
    cp -r "$tmp_dir/phoenix-2.0/tests/$benchmark/." "$install_dir/$benchmark/src/"
done

# Install inputs
if [ "$interactive_installation" = true ]; then
    read -p "Do you wish to install Phoenix inputs [Yn]?" do_install
else do_install="Y" ; fi
if [[ "$do_install" == [Yy] ]]; then
    cd "${PROJ_ROOT}/benchmarks/phoenix/" || exit 1
    for bm in "histogram" "linear_regression" "string_match" "word_count"; do
      wget --progress=bar:force:noscroll -nc http://csl.stanford.edu/~christos/data/$bm.tar.gz
      tar -xzf $bm.tar.gz
      mkdir -p $bm/inputs/
      mv -uf ${bm}_datafiles/* $bm/inputs/
      rm -rf ${bm}_datafiles/
    done
else
    echo "Skipped Phoenix inputs installation."
fi
