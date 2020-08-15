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

function error_exit_with_backtrace() {
    echo -e "${ERROR}[UNEXPECTED ERROR] $1 $ENDC"
    backtrace
    exit "$2"
}

function check_argument() {
    if [[ -z "$1" ]]; then
        error_exit_with_backtrace "Variable is not defined" 1
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
experiment_has_binary=true
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
execution_header=()
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

function is() {
    local value=$1
    if [[ "$value" == true ]]; then
        return 0;
    elif [[ "$value" == false ]]; then
        return 1;
    else
        error_exit_with_backtrace "Invalid boolean value $value" 1
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

function get_source_path() {
    check_argument "$benchmark"
    declare -n out_source_path=$1

    if is "$experiment_is_benchmark_suite"; then
        out_source_path="${PROJ_ROOT}/benchmarks/$NAME/$benchmark"
    else
        out_source_path="${PROJ_ROOT}/benchmarks/$NAME"
    fi
}

function get_build_path() {
    check_argument "$benchmark"
    check_argument "$type"
    declare -n out_build_path=$1

    if is "$experiment_is_benchmark_suite"; then
        out_build_path=${BUILD_DIR}/${benchmark}/${type}
    else
        out_build_path=${BUILD_DIR}/${type}
    fi
}

##############################
# Iterators
##############################

function for_types() {
    check_argument "$types"
    local type
    for type in ${types[*]}; do
        header_push "type: $type;"
        "$@"
        header_pop
    done
}

function for_benchmarks() {
    check_argument "$benchmarks"
    local benchmark
    for benchmark in ${benchmarks[*]}; do
        header_push "benchmark: $benchmark;"
        "$@"
        header_pop
    done
}

function for_thread_counts() {
    check_argument "$thread_counts"
    local thread_count
    for thread_count in ${thread_counts[*]}; do
        header_push "thread_count: $thread_count;"
        "$@"
        header_pop
    done
}

function for_iterations() {
    check_argument "$ITERATIONS"
    local iteration
    for iteration in $(seq 1 $ITERATIONS); do
        header_push "iteration: $iteration;"
        "$@"
        header_pop
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
    debug "Building" "${execution_header[@]}"

    local source_path
    get_source_path source_path

    local cmd="make BUILD_TYPE=$type -I${PROJ_ROOT}/build_types -C ${source_path}"
    if is "$experiment_is_benchmark_suite"; then
        cmd+=" BENCH_SUITE=${NAME}"
    fi
    if is "$INCREMENTAL_BUILD"; then
        cmd+=" clean all"
    fi

    echo "[FEX2_EXPERIMENT]" "${execution_header[@]}" >>$BUILD_LOG
    switchable_eval "$cmd" >>$BUILD_LOG 2>&1
}

function single_execution() {
    check_argument "$type"
    check_argument "$benchmark"
    check_argument "$thread_count"
    debug "Running" "${execution_header[@]}"

    local build_path
    get_build_path build_path

    local bin=${build_path}/${benchmark}
    if is "$experiment_has_binary" && ! [[ -f "$bin" ]]; then
        error_exit "Binary $bin does not exits" 1
    fi

    local input
    read_benchmark_arguments "default" input

    # expand the command parameters
    local cmd="$experiment_command"
    cmd=${cmd/\?\?bin/$bin}
    cmd=${cmd/\?\?input/$input}

    echo "[FEX2_EXPERIMENT]" "${execution_header[@]}" >>$EXPERIMENT_OUTPUT
    switchable_eval "$cmd" >>$EXPERIMENT_OUTPUT 2>&1
}

function cleanup() {
    debug "No cleanup required"
}

function build_loop() {
    for_types for_benchmarks build
}

function run_loop() {
    for_types for_benchmarks for_thread_counts for_iterations single_execution
}

# Main function
function execute_experiment() {
    check_argument "$experiment_is_benchmark_suite"
    check_argument "$experiment_command"

    # list of benchmarks to run
    local benchmarks
    if is "$experiment_is_benchmark_suite"; then
        check_argument "$experiment_benchmarks"
        benchmarks=("${experiment_benchmarks[@]}")
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
        debug "No build"
    else
        build_loop
    fi
    if is "$NO_RUN"; then
        debug "No run"
    else
        run_loop
    fi
    cleanup
}
