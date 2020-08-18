#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$BATS_TEST_DIRNAME/../../preconfigured/bash/run.sh"

@test "header_push and header_pop" {
    fex2::run::header_push "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"

    fex2::run::header_push "push_1"
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]}" "push_1"

    fex2::run::header_push "push_2"
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]}" "push_1"
    assert_equal "${FEX2_EXECUTION_HEADER[2]}" "push_2"

    fex2::run::header_pop
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]}" "push_1"
    assert_equal "${FEX2_EXECUTION_HEADER[2]:-absend}" "absend"

    fex2::run::header_push "push_2_again"
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]}" "push_1"
    assert_equal "${FEX2_EXECUTION_HEADER[2]}" "push_2_again"

    fex2::run::header_pop
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]}" "push_1"
    assert_equal "${FEX2_EXECUTION_HEADER[2]:-absend}" "absend"

    fex2::run::header_pop
    assert_equal "${FEX2_EXECUTION_HEADER[0]}" "push_0"
    assert_equal "${FEX2_EXECUTION_HEADER[1]:-absend}" "absend"

    fex2::run::header_pop
    assert_equal "${FEX2_EXECUTION_HEADER[0]:-absend}" "absend"

    error_called=false
    run fex2::run::header_pop
    assert_failure
}
