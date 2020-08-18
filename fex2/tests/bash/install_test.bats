#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$BATS_TEST_DIRNAME/../../preconfigured/bash/install.sh"

@test "ask" {
    # When the user says yes, success
    assert echo "Yes" | fex2::install::ask "<Some question>"

    # When the user says no, fail
    refute echo "No" | fex2::install::ask "<Some question>"

    # When the user says nonsense, wait for sense
    assert echo "42No\nYes" | fex2::install::ask "<Some question>"
}
