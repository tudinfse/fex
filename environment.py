"""
Example of environment definitions
"""
from core.environment import Environment
from os import environ as env

PROJ_ROOT = env['PROJ_ROOT']
if not PROJ_ROOT:
    print("Env. variable PROJ_ROOT must be set!\n")
    exit(1)


class GenericEnvironment(Environment):
    forced_variables = {}

    updated_variables = {
        'LD_LIBRARY_PATH': '/usr/local/lib64/:/usr/local/lib/:%s/bin/libs/' % PROJ_ROOT,
    }

    default_variables = {
        'PROJ_ROOT': PROJ_ROOT,
        'DATA_PATH': PROJ_ROOT + '/data/',
        'BIN_PATH': PROJ_ROOT + '/bin/'
    }

    debug_variables = {}

