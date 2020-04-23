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
function debug() {
    echo -e "${DEBUG}[DEBUG]" "$@" "$ENDC"
}

function error_exit() {
    echo -e "${ERROR}[ERROR]" "$1" "$ENDC"
    exit "$2"
}

function check_argument() {
    if [[ -z "$1" ]]; then
        error_exit "$3: Variable \$$2 is not defined" 1
    fi
}

# Check mandatory variables
check_argument "$NAME" "NAME" "common.sh"
check_argument "$BUILD_TYPES" "BUILD_TYPES" "common.sh"
check_argument "$NUM_THREADS" "NUM_THREADS" "common.sh"
check_argument "$ITERATIONS" "ITERATIONS" "common.sh"

# Read experiment parameters or set their defaults
BUILD_LOG=${BUILD_LOG:-/dev/stdout}
EXPERIMENT_OUTPUT=${EXPERIMENT_OUTPUT:-/dev/stdout}
FORCE_OUTPUT_OVERWRITE=${FORCE_OUTPUT_OVERWRITE:-0}
DRY_RUN=${DRY_RUN:-0}
NO_BUILD=${NO_BUILD:-0}
NO_RUN=${NO_RUN:-0}
INCREMENTAL_BUILD=${INCREMENTAL_BUILD:-0}
BENCHMARK_NAME=${BENCHMARK_NAME:-""}

BUILD_ROOT=${BUILD_ROOT:-${PROJ_ROOT}/build}   # TODO: these two lines are duplicated in common.mk. Fix it
BUILD_DIR=${BUILD_DIR:-${BUILD_ROOT}/${NAME}}

# Initialize local variables
IFS=' ' read -r -a types <<< "$BUILD_TYPES"
IFS=' ' read -r -a thread_counts <<< "$NUM_THREADS"

is_benchmark_suite=0
command=""
execution_header=()
input=""
bin=""

declare -a execution_header

# shell output colors
DEBUG='\033[94m\033[1m'
WARNING='\033[93m\033[1m'
ERROR='\033[91m\033[1m'
ENDC='\033[0m'

##############################
# Shortcuts and helpers
##############################
function header_push() {
    execution_header+=("$1")
}

function header_pop() {
    local top=("${!execution_header[@]}")
    local top_index=${#execution_header[@]}
    if [ "$top_index" -le 0 ]; then
        echo "Current Header: " "${execution_header[@]}"
        error_exit "header_pop: unbalanced pop from the header" 1
    fi
    unset 'execution_header[${top[@]: -1}]'
}

function read_benchmark_arguments() {
    local input_type=$1
    local input_file="${PROJ_ROOT}/experiments/${NAME}/inputs.csv"

    check_argument "$type" "type" "read_benchmark_arguments"
    check_argument "$benchmark" "benchmark" "read_benchmark_arguments"

    # find the index of the necessary input (column)
    IFS=',' read -r -a header <$input_file
    input_index=0
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
        if [ ${line[0]} == $benchmark ]; then
            input=${line[$input_index]}
            return
        fi
    done <$input_file
    error_exit "read_benchmark_arguments: Did not find $benchmark in $input_file" 1
}

function switchable_eval() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "$@"
    else
        eval "$@"
    fi
}

##############################
# Iterators
##############################

function for_types() {
    check_argument "$types" "types" "for_types"
    for type in ${types[*]}; do
        header_push "type: $type;"
        "$@"
        header_pop
    done
}

function for_benchmarks() {
    check_argument "$benchmarks" "benchmarks" "for_benchmarks"
    for benchmark in ${benchmarks[*]}; do
        header_push "benchmark: $benchmark;"
        "$@"
        header_pop
    done
}

function for_thread_counts() {
    check_argument "$thread_counts" "thread_counts" "for_thread_counts"
    for thread_count in ${thread_counts[*]}; do
        header_push "thread_count: $thread_count;"
        "$@"
        header_pop
    done
}

function for_iterations() {
    # No need to check, already done in the header
    debug "Running" "${execution_header[@]}"
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
    check_argument "$type" "type" "build"
    check_argument "$benchmark" "benchmark" "build"
    debug "Building" "${execution_header[@]}"

    cmd="make BUILD_TYPE=$type -I${PROJ_ROOT}/build_types -C ${PROJ_ROOT}/benchmarks/$NAME/$benchmark"
    if [ "$is_benchmark_suite" -eq 1 ]; then
        cmd+=" BENCH_SUITE=${NAME}"
    fi
    if [ "$INCREMENTAL_BUILD" -ne 1 ]; then
        cmd+=" clean all"
    fi

    echo "[FEX2]" "${execution_header[@]}" >> $BUILD_LOG
    switchable_eval "$cmd" >> $BUILD_LOG 2>&1
}

function single_execution() {
    check_argument "$benchmark" "benchmark" "build"
    check_argument "$type" "type" "build"
    check_argument "$thread_count" "thread_count" "build"

    bin=${BUILD_DIR}/${benchmark}/${type}/${benchmark}
    if ! [[ -f "$bin" ]]; then
        error_exit "Binary $bin does not exits" 1
    fi

    read_benchmark_arguments "default"

    # expand the command parameters
    cmd=${command/??bin/$bin}
    cmd=${cmd/??input/$input}
    echo "[FEX2]" "${execution_header[@]}" >> $EXPERIMENT_OUTPUT
    switchable_eval "$cmd" >> $EXPERIMENT_OUTPUT 2>&1
}

function cleanup() {
    debug "No cleanup required"
}

# Main function
function execute_experiment() {
    check_argument "$command" "command" "execute_experiment"

    # list of benchmarks to run
    if [ "$is_benchmark_suite" -eq 1 ]; then
        check_argument "$benchmarks" "benchmarks" "execute_experiment"
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


    if [ -f $BUILD_LOG ] && [ "$FORCE_OUTPUT_OVERWRITE" -ne 1 ]; then
        error_exit "$BUILD_LOG already exists. Exiting to avoid corruption of old experiment results" 1
    fi
    if [ -f $EXPERIMENT_OUTPUT ] && [ "$FORCE_OUTPUT_OVERWRITE" -ne 1 ]; then
        error_exit "$EXPERIMENT_OUTPUT already exists. Exiting to avoid corruption of old experiment results" 1
    fi
    touch $BUILD_LOG $EXPERIMENT_OUTPUT

    setup
    if [ "$NO_BUILD" -ne 1 ]; then
        for_types for_benchmarks build
    fi
    if [ "$NO_RUN" -ne 1 ]; then
        for_types for_benchmarks for_thread_counts for_iterations single_execution
    fi
    cleanup
}
