"""
Main configuration file

Warning: this feature (i.e., centralized config file) is still in development
It will be
"""
from core.abstract_config import AbstractConfig
from environment import GenericEnvironment, ASanEnvironment


class Config(AbstractConfig):
    """
    Example config
    """

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
        "mpxcount": "bin/pin/pin -t bin/pin/mpxinscount.so -o mpxcount.tmp --",
        "none": "",
    }
