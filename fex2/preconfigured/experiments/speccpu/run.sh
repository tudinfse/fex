#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/experiments/common.sh
# END HEADER

is_benchmark_suite=1
benchmarks=(
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

if [ "$NUM_THREADS" != "1" ]; then
    error_exit "speccpu/run.sh: SPEC CPU 2006 contains only single-threaded benchmarks. Multithreaded experiments are not possible."
fi

if [ "$EXPERIMENT_TYPE" == "perf" ]; then
    command='perf stat ??bin ??input 2>&1 > /dev/null'
else
    error_exit "speccpu/run.sh: Unknown experiment type" 1
fi
execute_experiment
