#!/usr/bin/env bash

# == Manage fex2 dependencies ==

fex2::run::load_dependencies() {
    local my_dir="$( dirname "${BASH_SOURCE[0]}" )"
    [ "${FEX2_UTIL_LOADED:-false}" = true ] || source $my_dir/util.sh
    FEX2_RUN_LOADED=true
}
fex2::run::load_dependencies


# == Execution header and iterators ==

FEX2_EXECUTION_HEADER=()
fex2::run::header_push() {
    local item="$1" ; fex2::util::check_argument "$item"
    FEX2_EXECUTION_HEADER+=("$item")
}

fex2::run::header_pop() {
    local top=("${!FEX2_EXECUTION_HEADER[@]}")
    local top_index=${#FEX2_EXECUTION_HEADER[@]}
    if [ "$top_index" -le 0 ]; then
        echo "Current Header: " "${FEX2_EXECUTION_HEADER[@]}"
        fex2::util::error_exit "header_pop: unbalanced pop from the header" 1
    fi
    unset 'FEX2_EXECUTION_HEADER[${top[@]: -1}]'
}


# == Helper functions ==

fex2::run::read_benchmark_arguments() {
    local input_type=$1 ; fex2::util::check_argument "$input_type"
    declare -n _input=$2 # Return variable
    local input_file="${PROJ_ROOT}/experiments/${NAME}/inputs.csv"

    fex2::util::check_argument "$benchmark"

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
        fex2::util::error_exit "read_benchmark_arguments: did not find the requested input type \"$input_type\"" 1
    fi

    # find the benchmark (row)
    while IFS=, read -r -a line; do
        [ -z "$line" ] && continue
        if [ ${line[0]} == $benchmark ]; then
            _input=${line[$input_index]}
            return # i.e. _input
        fi
    done <$input_file
    fex2::util::error_exit "read_benchmark_arguments: Did not find $benchmark in $input_file" 1
}

fex2::run::get_source_path() {
    fex2::util::check_argument "$benchmark"
    declare -n _source_path=$1 # Return variable

    if fex2::util::is "$experiment_is_benchmark_suite"; then
        _source_path="${PROJ_ROOT}/benchmarks/$NAME/$benchmark"
    else
        _source_path="${PROJ_ROOT}/benchmarks/$NAME"
    fi
    return # i.e. _source_path
}

fex2::run::get_build_path() {
    fex2::util::check_argument "$benchmark"
    fex2::util::check_argument "$type"
    declare -n _build_path=$1 # Return variable

    if fex2::util::is "$experiment_is_benchmark_suite"; then
        _build_path=${BUILD_DIR}/${benchmark}/${type}
    else
        _build_path=${BUILD_DIR}/${type}
    fi
    return # i.e. _build_path
}
