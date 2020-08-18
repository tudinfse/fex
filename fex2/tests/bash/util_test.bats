#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$BATS_TEST_DIRNAME/../../preconfigured/bash/util.sh"

@test "check_argument" {
    # When the value is present, success
    local value="Test"
    assert fex2::util::check_argument "$value"

    # When the value is empty, error is called
    local empty_value
    run fex2::util::check_argument "$empty_value"
    assert_failure
}

@test "is" {
    # Normal cases result in true and false
    assert fex2::util::is true
    refute fex2::util::is false

    # Invalid cases result in error call
    run fex2::util::is other_value
    run assert_equal "$error_called" "true"
    assert_failure
}

@test "switchable_eval" {
    # When true, the cmd is echoed
    run fex2::util::switchable_eval "true" "echo test"
    assert_output 'echo test'

    # When false, the cmd is executed
    run fex2::util::switchable_eval "false" "echo test"
    assert_output 'test'
}
