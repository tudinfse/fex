#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

SPECCPU_PATH=${SPECCPU_PATH:-""}
if [ -z "$SPECCPU_PATH" ]; then
    echo "INSTALLATION FAILED"
    echo "SPEC CPU 2006 is commercial software and we cannot distribute its source code."
    echo "If you want to use it, you can purchase the benchmarks from"
    echo "https://www.spec.org/cpu2006/"
    echo ""
    echo "Afterwards, download them on this machine and point the SPECCPU_PATH"
    echo "environmental variable to the download directory."
    exit 1
fi

supported_benchmarks=(
"400.perlbench"
"401.bzip2"
"403.gcc"
"429.mcf"
"433.milc"
"444.namd"
"445.gobmk"
"447.dealII"
"450.soplex"
"453.povray"
"456.hmmer"
"458.sjeng"
"462.libquantum"
"464.h264ref"
"470.lbm"
"471.omnetpp"
"473.astar"
"482.sphinx3"
"483.xalancbmk"
)

# copy benchmarks into the project
src_dir="$SPECCPU_PATH/benchspec/CPU2006"
install_dir="$PROJ_ROOT/benchmarks/speccpu"
for i in ${supported_benchmarks[*]}; do
    cp -r "$src_dir/$i/src" "$install_dir/$i/src"
    cp -r "$src_dir/$i/data" "$install_dir/$i/inputs"
done


# patch some file names to simplify builds
if [ -f "$install_dir/445.gobmk/src/engine/influence.c" ]; then
    mv "$install_dir/445.gobmk/src/engine/influence.c" "$install_dir/445.gobmk/src/engine/engine_influence.c"
fi

# patch file paths
sed -i "s:\"cpu2006_mhonarc:\"$install_dir/400.perlbench/inputs/all/input/cpu2006_mhonarc:g" "$install_dir/400.perlbench/inputs/all/input/splitmail.pl"
sed -i "s:SPEC-benchmark-ref.pov:$install_dir/453.povray/inputs/ref/input/SPEC-benchmark-ref.pov:g" "$install_dir/453.povray/inputs/ref/input/SPEC-benchmark-ref.ini"
sed -i "s:\"beams.dat:\"$install_dir/482.sphinx3/inputs/ref/input/beams.dat:g" "$install_dir/482.sphinx3/src/spec_main_live_pretend.c"  # yes, the file path is hardcoded in a source file. *facepalm*
sed -i "s:model/:$install_dir/482.sphinx3/inputs/ref/input/model/:g" "$install_dir/482.sphinx3/inputs/ref/input/args.an4" # and relative paths are hardcoded too
cp -r "$install_dir/482.sphinx3/inputs/all/input/model/" "$install_dir/482.sphinx3/inputs/ref/input/"
touch "$install_dir/482.sphinx3/inputs/ref/input/ctlfile"
