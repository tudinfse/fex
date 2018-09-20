from core import collect
import os


def main():
    res_path = os.environ['PROJ_ROOT'] + '/results/nginx/raw.csv'
    collect.collect(
        "nginx",
        user_parameters={
            "num_clients": ["Concurrency Level", lambda l: collect.get_int_from_string(l)],
            "tput": ["Requests per second", lambda l: collect.get_float_from_string(l)],
            "lat": ["[ms] (mean)", lambda l: collect.get_float_from_string(l)],
            "complete_requests": ["Complete requests", lambda l: collect.get_int_from_string(l)],
            "failed_requests": ["Failed requests", lambda l: collect.get_int_from_string(l)],
        },
        result_file=res_path
    )
