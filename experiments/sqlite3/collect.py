from core import collect


def main():
    collect.collect("sqlite3", user_parameters={
        "total_tput": ["total_tput", lambda l: collect.get_float_from_string(l)],
        "total_lat": ["total_lat", lambda l: collect.get_float_from_string(l)]
    })
