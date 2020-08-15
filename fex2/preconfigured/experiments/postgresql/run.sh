#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/experiments/common.sh
# END HEADER

# TODO: Add trap and make Ctrl+C work

RUN_INIT_LOG="$BUILD_LOG"
DB_NAME="test"
DB_PORT=5433

experiment_is_benchmark_suite=false
experiment_has_binary=false

function run_loop() {
    for_types for_benchmarks for_thread_counts for_client_numbers for_iterations single_execution
}

function for_client_numbers() {
    local build_path
    get_build_path build_path

    # initialize a DB
    echo "-- Initializing a DB --" >>"$RUN_INIT_LOG"
    sudo [ -e "$build_path/data" ] && sudo -u fex2_postgres rm -r "$build_path/data"
    sudo -u fex2_postgres "$build_path/bin/initdb" -D "$build_path/data" >>"$RUN_INIT_LOG"

    debug "Starting the DB server at $build_path"
    sudo -u fex2_postgres "$build_path/bin/postgres" -D "$build_path/data" -p "$DB_PORT" &
    sleep 1s

    # create a DB
    echo "-- Creating the DB --" >>"$RUN_INIT_LOG"
    sudo -u fex2_postgres "$build_path/bin/createdb" -p "$DB_PORT" $DB_NAME

    # Iterate over client numbers
    local client_numbers_as_string
    read_benchmark_arguments "client_numbers" client_numbers_as_string

    local original_IFS="$IFS"; IFS=" "
    local client_numbers=($client_numbers_as_string)
    IFS="$original_IFS"

    local client_number
    for client_number in ${client_numbers[*]}; do
        header_push "client_number: $client_number;"
        "$@"
        header_pop
    done

    # clean
    sudo killall -u fex2_postgres
    sleep 1s
}

function pgbench_experiment_function() {
    local original_IFS="$IFS"; IFS=" "
    local input_array=($input)
    IFS="$original_IFS"

    sudo -u fex2_postgres "$build_path/bin/pgbench" -p "$DB_PORT" -i "$DB_NAME"
    sudo -u fex2_postgres "$build_path/bin/pgbench" -p "$DB_PORT" -c "$client_number" -j "$thread_count" "${input_array[@]}" "$DB_NAME"
}

if [ "$EXPERIMENT_TYPE" == "pgbench" ]; then
    experiment_command='pgbench_experiment_function'
else
    error_exit "postgresql/run.sh: Unknown experiment type" 1
fi
execute_experiment
