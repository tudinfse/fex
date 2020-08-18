#!/usr/bin/env bash
###############################################################################
# !!!! WARNING !!!!
# This file is used across all experiments.
# Modify it only if you *know* what you are doing!
###############################################################################

# Prepare a safe scripting environment
set -euo pipefail
IFS=$'\n\t'

# Load fex2 run lib
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}/bash/run.sh"

# at exit, kill all descendants
trap "trap - SIGTERM && set +e; kill -- -$$ 2>/dev/null" SIGINT SIGTERM
trap "exit_code=\$?; set +e; kill -- -$$ 2>/dev/null ; exit \$exit_code" EXIT

# Check mandatory variables
fex2::util::check_argument "$NAME"
fex2::util::check_argument "$EXPERIMENT_TYPE"
fex2::util::check_argument "$BUILD_TYPES"
fex2::util::check_argument "$NUM_THREADS"
fex2::util::check_argument "$ITERATIONS"

# Read experiment parameters or set their defaults
BUILD_LOG=${BUILD_LOG:-/dev/stdout}
EXPERIMENT_OUTPUT=${EXPERIMENT_OUTPUT:-/dev/stdout}
FORCE_OUTPUT_OVERWRITE="${FORCE_OUTPUT_OVERWRITE:-false}"
DRY_RUN="${DRY_RUN:-false}"
NO_BUILD="${NO_BUILD:-false}"
NO_RUN="${NO_RUN:-false}"
INCREMENTAL_BUILD="${INCREMENTAL_BUILD:-false}"
BENCHMARK_NAME=${BENCHMARK_NAME:-""}
COLORED_LOGS="${COLORED_LOGS:-false}"

BUILD_ROOT=${BUILD_ROOT:-${PROJ_ROOT}/build} # TODO: these two lines are duplicated in common.mk. Fix it
BUILD_DIR=${BUILD_DIR:-${BUILD_ROOT}/${NAME}}

# Initialize local variables
IFS=' ' read -r -a types <<<"$BUILD_TYPES"
IFS=' ' read -r -a thread_counts <<<"$NUM_THREADS"

# These values are set in the run script of each experiment
experiment_is_benchmark_suite=false
experiment_has_binary=true
experiment_benchmarks=""
experiment_command=""

# shell output colors
if fex2::util::is "$COLORED_LOGS" ; then
    fex2::util::activate_colored_output
fi

##############################
# Iterators
##############################

function for_types() {
    fex2::util::check_argument "$types"
    local type
    for type in ${types[*]}; do
        fex2::run::header_push "type: $type;"
        "$@"
        fex2::run::header_pop
    done
}

function for_benchmarks() {
    fex2::util::check_argument "$benchmarks"
    local benchmark
    for benchmark in ${benchmarks[*]}; do
        fex2::run::header_push "benchmark: $benchmark;"
        "$@"
        fex2::run::header_pop
    done
}

function for_thread_counts() {
    fex2::util::check_argument "$thread_counts"
    local thread_count
    for thread_count in ${thread_counts[*]}; do
        fex2::run::header_push "thread_count: $thread_count;"
        "$@"
        fex2::run::header_pop
    done
}

function for_iterations() {
    fex2::util::check_argument "$ITERATIONS"
    local iteration
    for iteration in $(seq 1 $ITERATIONS); do
        fex2::run::header_push "iteration: $iteration;"
        "$@"
        fex2::run::header_pop
    done
}

################################
# Actions
################################

function setup() {
    fex2::util::debug "No experiment setup required"
}

function build() {
    fex2::util::check_argument "$type"
    fex2::util::check_argument "$benchmark"
    fex2::util::debug "Building" "${FEX2_EXECUTION_HEADER[@]}"

    local source_path
    fex2::run::get_source_path source_path

    local cmd="make BUILD_TYPE=$type -I${PROJ_ROOT}/build_types -C ${source_path}"
    if fex2::util::is "$experiment_is_benchmark_suite"; then
        cmd+=" BENCH_SUITE=${NAME}"
    fi
    if fex2::util::is "$INCREMENTAL_BUILD"; then
        cmd+=" clean all"
    fi

    echo "[FEX2_EXPERIMENT]" "${FEX2_EXECUTION_HEADER[@]}" >>$BUILD_LOG
    fex2::util::switchable_eval "$DRY_RUN" "$cmd" >>$BUILD_LOG 2>&1
}

function single_execution() {
    fex2::util::check_argument "$type"
    fex2::util::check_argument "$benchmark"
    fex2::util::check_argument "$thread_count"
    fex2::util::debug "Running" "${FEX2_EXECUTION_HEADER[@]}"

    local build_path
    fex2::run::get_build_path build_path

    local bin=${build_path}/${benchmark}
    if fex2::util::is "$experiment_has_binary" && ! [[ -f "$bin" ]]; then
        fex2::util::error_exit "Binary $bin does not exits" 1
    fi

    local input
    fex2::run::read_benchmark_arguments "default" input

    # expand the command parameters
    local cmd="$experiment_command"
    cmd=${cmd/\?\?bin/$bin}
    cmd=${cmd/\?\?input/$input}

    echo "[FEX2_EXPERIMENT]" "${FEX2_EXECUTION_HEADER[@]}" >>$EXPERIMENT_OUTPUT
    fex2::util::switchable_eval "$DRY_RUN" "$cmd" >>$EXPERIMENT_OUTPUT 2>&1
}

function cleanup() {
    fex2::util::debug "No cleanup required"
}

function build_loop() {
    for_types for_benchmarks build
}

function run_loop() {
    for_types for_benchmarks for_thread_counts for_iterations single_execution
}

# Main function
function execute_experiment() {
    fex2::util::check_argument "$experiment_is_benchmark_suite"
    fex2::util::check_argument "$experiment_command"

    # list of benchmarks to run
    local benchmarks
    if fex2::util::is "$experiment_is_benchmark_suite"; then
        fex2::util::check_argument "$experiment_benchmarks"
        benchmarks=("${experiment_benchmarks[@]}")
    else
        benchmarks=("$NAME")
    fi

    # running a single benchmark in a suite
    if [ -n "$BENCHMARK_NAME" ]; then
        # check if this benchmark exits
        if [[ ! " ${benchmarks[@]} " =~ " ${BENCHMARK_NAME} " ]]; then
            fex2::util::error_exit "execute_experiment: $BENCHMARK_NAME is not listed in $NAME" 1
        fi
        benchmarks=("$BENCHMARK_NAME")
    fi

    if [ -f "$BUILD_LOG" ]; then
        if fex2::util::is "$FORCE_OUTPUT_OVERWRITE"; then
            echo "" >"$BUILD_LOG"
        else
            fex2::util::error_exit "$BUILD_LOG already exists. Exiting to avoid corruption. Add '-f' to ignore this error." 1
        fi
    fi
    if [ -f "$EXPERIMENT_OUTPUT" ]; then
        if fex2::util::is "$FORCE_OUTPUT_OVERWRITE"; then
            echo "" >"$EXPERIMENT_OUTPUT"
        else
            fex2::util::error_exit "$EXPERIMENT_OUTPUT already exists. Exiting to avoid corruption. Add '-f' to ignore this error." 1
        fi
    fi
    touch "$BUILD_LOG" "$EXPERIMENT_OUTPUT"

    echo "[FEX2_HEADER] name: $NAME; experiment_type: $EXPERIMENT_TYPE;" >>"$EXPERIMENT_OUTPUT"
    setup
    if fex2::util::is "$NO_BUILD"; then
        fex2::util::debug "No build"
    else
        build_loop
    fi
    if fex2::util::is "$NO_RUN"; then
        fex2::util::debug "No run"
    else
        run_loop
    fi
    cleanup
}
