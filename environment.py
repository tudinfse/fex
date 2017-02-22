"""
Example of environment definitions
"""
from core.environment import Environment
import os

CURR_PATH = os.path.dirname(os.path.abspath(__file__))


class GenericEnvironment(Environment):
    forced_variables = {}

    updated_variables = {
        'LD_LIBRARY_PATH': '/usr/local/lib64/:/usr/local/lib/:%s/bin/libs/' % CURR_PATH,
    }

    default_variables = {
        'PROJ_ROOT': CURR_PATH,
        'DATA_PATH': CURR_PATH + '/data/',
        'BIN_PATH': CURR_PATH + '/bin/'
    }

    debug_variables = {}


class ASanEnvironment(Environment):
    default_variables = {
        'ASAN_OPTIONS': 'verbosity=0:' +
                        'detect_leaks=false:' +
                        'print_summary=true:' +
                        'halt_on_error=true:' +
                        'poison_heap=true:' +
                        'alloc_dealloc_mismatch=0:' +
                        'new_delete_type_mismatch=0',
    }

    only_build_variables = {
        "ASAN_OPTIONS": 'verbosity=0:' +
                        'detect_leaks=false:' +
                        'print_summary=false:' +
                        'halt_on_error=false:' +
                        'poison_heap=false',
    }

    debug_variables = {
        "ASAN_OPTIONS": 'verbosity=1:' +
                        'detect_leaks=false:' +
                        'print_summary=false:' +
                        'halt_on_error=false:' +
                        'poison_heap=false:' +
                        'alloc_dealloc_mismatch=0:' +
                        'new_delete_type_mismatch=0',
    }
