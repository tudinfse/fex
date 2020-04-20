from fex2 import collect, helpers


def parse(infile, outfile, experiment_type):
    if experiment_type != "perf":
        helpers.error_exit(1, "Unknown experiment type")

    parsers = {
        "cycles": ["cycles", lambda l: collect.get_int_from_string(l, ignore_comma=True)],
        "instructions": [" instructions ", lambda l: collect.get_int_from_string(l, ignore_comma=True)],
        "time": ["seconds time elapsed", lambda l: collect.get_float_from_string(l)],
    }
    collect.parse_logs(infile, outfile, parsers)
