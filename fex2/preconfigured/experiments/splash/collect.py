from fex2.helpers import error_exit
from fex2.collect import get_int_from_string, get_float_from_string, Experiments, line_parser


def parse(infile, outfile):
    exp = Experiments(infile)

    if exp.type == "perf":
        exp.parsers.update({
            "cycles": line_parser("cycles", lambda l: get_int_from_string(l, ignore_comma=True)),
            "instructions": line_parser(" instructions ", lambda l: get_int_from_string(l, ignore_comma=True)),
            "time": line_parser("seconds time elapsed", lambda l: get_float_from_string(l))})
    else:
        return error_exit(1, f"Unknown experiment type {exp.type}")

    exp.create_csv(outfile)
