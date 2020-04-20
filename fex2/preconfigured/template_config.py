"""
Main configuration file

Warning: this feature (i.e., centralized config file) is still in development
It is going to be largely extended in future
"""
from fex2 import AbstractConfig
from fex2 import get_float_from_string, get_int_from_string, parse_time
from example.environment import GenericEnvironment


class Config(AbstractConfig):
    """
    Example config

    Note that Config is a singleton
    """

    # ========================
    # Run and Build parameters
    # ========================

    # default input type
    input_type = ""

    # list of used environments
    environments = (
        GenericEnvironment,
    )

    # measurement tools
    stats_action = {
        "perf": "perf stat -e cycles -e instructions",
        "time": "/usr/bin/time --verbose",
        "none": "",
    }

    # ========================
    # Data preparation
    # ========================

    # Results processing (how data is gathered from raw logs)

    # the format is as follows:
    # name of field in csv file: [ keyword to identify a necessary line in logs, function to process the line]
    parsed_data = {
        "perf": {
            "exit": ["[Exit code]", lambda l: get_int_from_string(l)],
            "cycles": ["cycles", lambda l: get_int_from_string(l)],
            "instructions": [" instructions ", lambda l: get_int_from_string(l)],
            "time": ["seconds time elapsed", lambda l: get_float_from_string(l)],
        },
        "time": {
            "time": ["Elapsed (wall clock) time", lambda l: parse_time(l)],
            "user_time": ["User time (seconds)", lambda l: get_float_from_string(l)],
            "sys_time": ["System time (seconds)", lambda l: get_float_from_string(l)],

            "major_faults": ["Major (requiring I/O) page faults", lambda l: get_int_from_string(l)],
            "minor_faults": ["Minor (reclaiming a frame) page faults", lambda l: get_int_from_string(l)],

            "voluntary_context_switches": ["Voluntary context switches", lambda l: get_int_from_string(l)],
            "involuntary_context_switches": ["Involuntary context switches", lambda l: get_int_from_string(l)],

            "maxsize": ["Maximum resident set size", lambda l: get_int_from_string(l)],
        },
        "none": {},
    }

    # Results aggregation (what means to calculate)

    # the format is as follows:
    # type: (what column to aggregate, what columns to keep untouched)
    aggregated_data = {
        "perf": (["time"], ["compiler", "type", "name", "input", "threads"]),
        "mem": (["maxsize"], ["compiler", "type", "name", "input", "threads"]),
        "multi": (["time"], ["compiler", "type", "name", "input", "threads"]),
        "tput": (["tput", "lat"], ["compiler", "type", "name", "num_clients", "input", "threads"]),
        "instr": (["instructions"], ["compiler", "type", "name", "input", "threads"]),
        "cache": (
            ["instructions", "l1_dcache_loads", "l1_dcache_load_misses", "l1_dcache_stores", "l1_dcache_store_misses", "llc_loads", "llc_load_misses", "llc_stores", "llc_store_misses"],
            ["compiler", "type", "name", "input", "threads"]
        ),
    }

    # ========================
    # Plotting
    # ========================
    build_names = {
        "long": {
            "gcc-native":  "Native (GCC)",
            "gcc-asan":    "ASan (GCC)",
        },
        "short": {
            "gcc-native":  "Native (GCC)",
            "gcc-asan":    "ASan",
        },
        "tiny": {
            "Native (GCC)": r"$N$",
            "ASan (GCC)":   r"$A$",
        },
        "empty": {
            "gcc-native": "",
            "gcc-asan":   "",
        },
    }

    input_names = {
        "long": {
            0: "Small",
            1: "Medium",
            2: "Large",
            3: "Extra Large",
            4: "XXL"
        },
        "short": {
            0: "S",
            1: "M",
            2: "L",
            3: "XL",
            4: "XXL"
        }
    }

    default_build_order = (
        "gcc-native",
        "gcc-asan",
    )
    other_build_orders = {
        "multi": (
            "gcc-native",
            "gcc-asan",
        ),
        "cache": (
            "gcc-asan",
            "gcc-native",
        ),
    }
