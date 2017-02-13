#!/usr/bin/env python
from __future__ import absolute_import

from core import collect


def main():
    # set parameters
    full_output_file = collect.data + "/sqlite3_perf/sqlite3_perf.log"
    results_file = collect.data + "/sqlite3_perf/raw.csv"
    parameters = {
        "total_tput": ["total_tput", lambda l: collect.get_float_from_string(l)],
        "total_lat": ["total_lat", lambda l: collect.get_float_from_string(l)]
    }

    # collect
    collect.collect(results_file, full_output_file, parameters)
