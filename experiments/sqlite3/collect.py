#!/usr/bin/env python
from __future__ import absolute_import

from core import collect


def main():
    # set parameters
    full_output_file = collect.data + "/sqlite3/sqlite3.log"
    results_file = collect.data + "/sqlite3/raw.csv"
    parameters = {
        "total_tput": ["total_tput", lambda l: collect.get_float_from_string(l)],
        "total_lat": ["total_lat", lambda l: collect.get_float_from_string(l)]
    }

    # collect
    collect.collect(results_file, full_output_file, parameters)
