#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/experiments/common.sh
# END HEADER

experiment_is_benchmark_suite=true
experiment_benchmarks=(
"barnes"
"cholesky"
"fft"
"fmm"
"lu"
"ocean"
"radiosity"
"radix"
"raytrace"
"volrend"
"water-nsquared"
"water-spatial"
)

if [ "$EXPERIMENT_TYPE" == "perf" ]; then
    experiment_command='perf stat ??bin ??input 2>&1 > /dev/null'
else
    fex2::util::error_exit "splash/run.sh: Unknown experiment type" 1
fi
execute_experiment
