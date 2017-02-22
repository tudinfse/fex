"""
Main configuration file

Warning: this feature (i.e., centralized config file) is still in development
It is going to be largely extended in future
"""
from core.abstract_config import AbstractConfig
from core.collect import get_float_from_string, get_int_from_string, parse_time
from environment import GenericEnvironment, ASanEnvironment


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
        ASanEnvironment
    )

    # measurement tools
    stats_action = {
        "perf": "perf stat " +
                "-e cycles,instructions " +
                "-e branch-instructions,branch-misses " +
                "-e major-faults,minor-faults " +
                "-e dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses ",
        "perf_cache": "perf stat " +
                      "-e instructions " +
                      "-e L1-dcache-loads,L1-dcache-load-misses " +
                      "-e L1-dcache-stores,L1-dcache-store-misses " +
                      "-e LLC-loads,LLC-load-misses " +
                      "-e LLC-store-misses,LLC-stores ",
        "perf_instr": "perf stat " +
                      "-e instructions " +
                      "-e instructions:u " +
                      "-e instructions:k " +
                      "-e mpx:mpx_new_bounds_table",
        "perf_ports": "perf stat " +  # ports for Intel Skylake!
                      "-e r02B1 " +  # UOPS_EXECUTED.CORE
                      "-e r01A1,r02A1 " +  # ports 0 and 1 (UOPS_DISPATCHED_PORT.PORT_X)
                      "-e r04A1,r08A1 " +  # ports 2 and 3
                      "-e r10A1,r20A1 " +  # ports 4 and 5
                      "-e r40A1,r80A1 ",  # ports 6 and 7
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
            "cycles": ["cycles", lambda l: get_int_from_string(l)],
            "instructions": [" instructions ", lambda l: get_int_from_string(l)],  # spaces are added not to confuse with branch-instructions

            "branch_instructions": ["branch-instructions", lambda l: get_int_from_string(l)],
            "branch_misses": ["branch-misses", lambda l: get_int_from_string(l)],

            "major_faults": ["major-faults", lambda l: get_int_from_string(l)],
            "minor_faults": ["minor-faults", lambda l: get_int_from_string(l)],

            "dtlb_loads": ["dTLB-loads", lambda l: get_int_from_string(l)],
            "dtlb_load_misses": ["dTLB-load-misses", lambda l: get_int_from_string(l)],
            "dtlb_stores": ["dTLB-stores", lambda l: get_int_from_string(l)],
            "dtlb_store_misses": ["dTLB-store-misses", lambda l: get_int_from_string(l)],

            "time": ["seconds time elapsed", lambda l: get_float_from_string(l)],
        },
        "perf_cache": {
            "l1_dcache_loads": ["L1-dcache-loads", lambda l: get_int_from_string(l)],
            "l1_dcache_load_misses": ["L1-dcache-load-misses", lambda l: get_int_from_string(l)],
            "l1_dcache_stores": ["L1-dcache-stores", lambda l: get_int_from_string(l)],
            "l1_dcache_store_misses": ["L1-dcache-store-misses", lambda l: get_int_from_string(l)],

            "llc_loads": ["LLC-loads", lambda l: get_int_from_string(l)],
            "llc_load_misses": ["LLC-load-misses", lambda l: get_int_from_string(l)],
            "llc_store_misses": ["LLC-store-misses", lambda l: get_int_from_string(l)],
            "llc_stores": ["LLC-stores", lambda l: get_int_from_string(l)],

            "time": ["seconds time elapsed", lambda l: get_float_from_string(l)],
            "instructions": [" instructions ", lambda l: get_int_from_string(l)],
        },
        "perf_instr": {
            "instructions": [" instructions ", lambda l: get_int_from_string(l)],
            "instructions:u": [" instructions:u ", lambda l: get_int_from_string(l)],
            "instructions:k": [" instructions:k ", lambda l: get_int_from_string(l)],

            "mpx_new_bounds_table ": ["mpx:mpx_new_bounds_table ", lambda l: get_int_from_string(l)],
            "time": ["seconds time elapsed", lambda l: get_float_from_string(l)],
        },
        "perf_ports": {
            "UOPS_EXECUTED.CORE": ["r02B1", lambda l: get_int_from_string(l)],
            "PORT_0": ["r01A1", lambda l: get_int_from_string(l)],
            "PORT_1": ["r02A1", lambda l: get_int_from_string(l)],
            "PORT_2": ["r04A1", lambda l: get_int_from_string(l)],
            "PORT_3": ["r08A1", lambda l: get_int_from_string(l)],
            "PORT_4": ["r10A1", lambda l: get_int_from_string(l)],
            "PORT_5": ["r20A1", lambda l: get_int_from_string(l)],
            "PORT_6": ["r40A1", lambda l: get_int_from_string(l)],
            "PORT_7": ["r80A1", lambda l: get_int_from_string(l)],
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
