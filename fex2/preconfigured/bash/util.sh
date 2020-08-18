#!/usr/bin/env bash

# == Manage fex2 dependencies ==

FEX2_UTIL_LOADED=true


# == Basic functions ==

fex2::util::check_argument() {
    if [[ -z "$1" ]]; then
        fex2::util::error_exit_with_backtrace "Variable is not defined" 1
    fi
}

fex2::util::is() {
    local value="$1" ; fex2::util::check_argument "$value"
    if [[ "$value" == true ]]; then
        true
        return
    elif [[ "$value" == false ]]; then
        false
        return
    else
        fex2::util::error_exit_with_backtrace "Invalid boolean value $value" 1
    fi;
}


# == Debug functions ==

# shell output colors
FEX2_DEBUG=''
FEX2_WARNING=''
FEX2_ERROR=''
FEX2_ENDC=''
fex2::util::activate_colored_output() {
    FEX2_DEBUG='\033[94m\033[1m'
    FEX2_WARNING='\033[93m\033[1m'
    FEX2_ERROR='\033[91m\033[1m'
    FEX2_ENDC='\033[0m'
}

fex2::util::debug() {
    echo -e "${FEX2_DEBUG}[DEBUG]" "$@" "$FEX2_ENDC"
}

fex2::util::error_exit() {
    local error_message="$1" ; fex2::util::check_argument "$error_message"
    local exit_code="$2" ; fex2::util::check_argument "$exit_code"
    echo -e "${FEX2_ERROR}[ERROR] $error_message $FEX2_ENDC"
    exit "$exit_code"
}

fex2::util::error_exit_with_backtrace() {
    local error_message="$1" ; fex2::util::check_argument "$error_message"
    local exit_code="$2" ; fex2::util::check_argument "$exit_code"
    echo -e "${FEX2_ERROR}[UNEXPECTED ERROR] $error_message $FEX2_ENDC"
    fex2::util::backtrace
    exit "$exit_code"
}

fex2::util::backtrace() {
    local depth=${#FUNCNAME[@]}

    for ((i=1; i<depth; i++)); do
        local function="${FUNCNAME[$i]}"
        local line="${BASH_LINENO[$((i-1))]}"
        local file="${BASH_SOURCE[$((i-1))]}"
        printf '%*s' $i '' # indent
        echo -e "at: $function(), $file, line $line"
    done
}


# == Other useful functions ==

fex2::util::switchable_eval() {
    local do_not_eval="$1" ; fex2::util::check_argument "$do_not_eval"
    local cmd="$2" ; fex2::util::check_argument "$cmd"
    if fex2::util::is "$do_not_eval"; then
        echo "$cmd"
    else
        eval "$cmd"
    fi
}

fex2::util::can_ask_user() {
    tty -s
}
