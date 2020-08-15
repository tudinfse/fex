from fex2.helpers import error_exit
from fex2.collect import get_int_from_string, get_float_from_string, Experiments, line_parser


def parse(infile, outfile):
    exp = Experiments(infile)

    if exp.type == "pgbench":
        exp.parsers.update({
            "num_clients": line_parser("number of clients", lambda l: get_int_from_string(l)),
            "latency": line_parser("latency average", lambda l: get_float_from_string(l)),
            "tps": line_parser("excluding connections establishing", lambda l: get_float_from_string(l))})
    else:
        return error_exit(1, f"Unknown experiment type {exp.type}")

    exp.create_csv(outfile)
