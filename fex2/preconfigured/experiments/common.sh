#!/usr/bin/env bash
###############################################################################
# !!!! WARNING !!!!
# This file is used across all experiments.
# Modify it only if you *know* what you are doing!
###############################################################################

# Prepare a safe scripting environment
set -euo pipefail
IFS=$'\n\t'

# at exit, kill all descendants
trap "trap - SIGTERM && set +e; kill -- -$$ 2>/dev/null" SIGINT SIGTERM
trap "exit_code=\$?; set +e; kill -- -$$ 2>/dev/null ; exit \$exit_code" EXIT

# Logging and errors
DEBUG=''
WARNING=''
ERROR=''
ENDC=''

# TODO: Remove function keyword as it's deprecated
function debug() {
    echo -e "${DEBUG}[DEBUG]" "$@" "$ENDC"
}

function error_exit() {
    echo -e "${ERROR}[ERROR] $1 $ENDC"
    exit "$2"
}

function unexpected_error_exit() {
    echo -e "${ERROR}[UNEXPECTED ERROR] $1 $ENDC"
    backtrace
    exit "$2"
}

function check_argument() {
    if [[ -z "$1" ]]; then
        unexpected_error_exit "Variable is not defined" 1
    fi
}

function backtrace() {
    local depth=${#FUNCNAME[@]}

    for ((i=1; i<depth; i++)); do
        local function="${FUNCNAME[$i]}"
        local line="${BASH_LINENO[$((i-1))]}"
        local file="${BASH_SOURCE[$((i-1))]}"
        printf '%*s' $i '' # indent
        echo -e "at: $function(), $file, line $line"
    done
}

# Check mandatory variables
check_argument "$NAME"
check_argument "$EXPERIMENT_TYPE"
check_argument "$BUILD_TYPES"
check_argument "$NUM_THREADS"
check_argument "$ITERATIONS"

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
experiment_benchmarks=""
experiment_command=""

# shell output colors
if [ $COLORED_LOGS == true ]; then
    DEBUG='\033[94m\033[1m'
    WARNING='\033[93m\033[1m'
    ERROR='\033[91m\033[1m'
    ENDC='\033[0m'
fi

##############################
# Shortcuts and helpers
##############################
function is() {
    local value=$1
    if [[ "$value" == true ]]; then
        return 0;
    elif [[ "$value" == false ]]; then
        return 1;
    else
        unexpected_error_exit "Invalid boolean value $value" 1
    fi;
}

function read_benchmark_arguments() {
    local input_type=$1
    declare -n out_input=$2
    local input_file="${PROJ_ROOT}/experiments/${NAME}/inputs.csv"

    check_argument "$type"
    check_argument "$benchmark"

    # find the index of the necessary input (column)
    IFS=',' read -r -a header <$input_file
    local input_index=0
    for element in ${header[*]}; do
        if [ "$element" == "$input_type" ]; then
            break
        fi
        input_index=$((input_index + 1))
    done
    if [ $input_index -eq "${#header[*]}" ]; then
        error_exit "read_benchmark_arguments: did not find the requested input type" 1
    fi

    # find the benchmark (row)
    while IFS=, read -r -a line; do
        [ -z "$line" ] && continue
        if [ ${line[0]} == $benchmark ]; then
            out_input=${line[$input_index]}
            return
        fi
    done <$input_file
    error_exit "read_benchmark_arguments: Did not find $benchmark in $input_file" 1
}

function switchable_eval() {
    if is "$DRY_RUN"; then
        echo "$@"
    else
        eval "$@"
    fi
}

##############################
# Iterators
##############################

function for_types() {
    check_argument "$types"
    local type
    for type in ${types[*]}; do
        "$@"
    done
}

function for_benchmarks() {
    check_argument "$benchmarks"
    local benchmark
    for benchmark in ${benchmarks[*]}; do
        "$@"
    done
}

function for_thread_counts() {
    check_argument "$thread_counts"
    local thread_count
    for thread_count in ${thread_counts[*]}; do
        "$@"
    done
}

function for_iterations() {
    check_argument "$ITERATIONS"
    local iteration
    for iteration in $(seq 1 $ITERATIONS); do
        "$@"
    done
}

################################
# Actions
################################
function setup() {
    debug "No experiment setup required"
}

function build() {
    check_argument "$type"
    check_argument "$benchmark"
    local execution_header="type: $type; benchmark: $benchmark;"
    debug "Building $execution_header"

    local cmd="make BUILD_TYPE=$type -I${PROJ_ROOT}/build_types -C ${PROJ_ROOT}/benchmarks/$NAME/$benchmark"
    if is "$experiment_is_benchmark_suite"; then
        cmd+=" BENCH_SUITE=${NAME}"
    fi
    if is "$INCREMENTAL_BUILD"; then
        cmd+=" clean all"
    fi

    echo "[FEX2_EXPERIMENT] $execution_header" >>$BUILD_LOG
    switchable_eval "$cmd" >>$BUILD_LOG 2>&1
}

function single_execution() {
    check_argument "$type"
    check_argument "$benchmark"
    check_argument "$thread_count"
    local execution_header="type: $type; benchmark: $benchmark; thread_count: $thread_count;"
    debug "Running $execution_header"

    local bin=${BUILD_DIR}/${benchmark}/${type}/${benchmark}
    if ! [[ -f "$bin" ]]; then
        error_exit "Binary $bin does not exits" 1
    fi

    local input
    read_benchmark_arguments "default" input

    # expand the command parameters
    local cmd="$experiment_command"
    cmd=${cmd/\?\?bin/$bin}
    cmd=${cmd/\?\?input/$input}

    echo "[FEX2_EXPERIMENT] $execution_header" >>$EXPERIMENT_OUTPUT
    switchable_eval "$cmd" >>$EXPERIMENT_OUTPUT 2>&1
}

function cleanup() {
    debug "No cleanup required"
}

# Main function
function execute_experiment() {
    check_argument "$experiment_is_benchmark_suite"
    check_argument "$experiment_command"

    # list of benchmarks to run
    local benchmarks
    if is "$experiment_is_benchmark_suite"; then
        check_argument "$experiment_benchmarks"
        benchmarks="${experiment_benchmarks[*]}"
    else
        benchmarks=("$NAME")
    fi

    # running a single benchmark in a suite
    if [ -n "$BENCHMARK_NAME" ]; then
        # check if this benchmark exits
        if [[ ! " ${benchmarks[@]} " =~ " ${BENCHMARK_NAME} " ]]; then
            error_exit "execute_experiment: $BENCHMARK_NAME is not listed in $NAME" 1
        fi
        benchmarks=("$BENCHMARK_NAME")
    fi

    if [ -f $BUILD_LOG ]; then
        if is "$FORCE_OUTPUT_OVERWRITE"; then
            echo "" >$BUILD_LOG
        else
            error_exit "$BUILD_LOG already exists. Exiting to avoid corruption. Add '-f' to ignore this error." 1
        fi
    fi
    if [ -f $EXPERIMENT_OUTPUT ]; then
        if is "$FORCE_OUTPUT_OVERWRITE"; then
            echo "" >$EXPERIMENT_OUTPUT
        else
            error_exit "$EXPERIMENT_OUTPUT already exists. Exiting to avoid corruption. Add '-f' to ignore this error." 1
        fi
    fi
    touch $BUILD_LOG $EXPERIMENT_OUTPUT

    echo "[FEX2_HEADER] name: $NAME; experiment_type: $EXPERIMENT_TYPE;" >>"$EXPERIMENT_OUTPUT"
    setup
    if is "$NO_BUILD"; then
        debug No build
    else
        for_types for_benchmarks build
    fi
    if is "$NO_RUN"; then
        debug No run
    else
        for_types for_benchmarks for_thread_counts for_iterations single_execution
    fi
    cleanup
}
