from __future__ import annotations

import csv
import os
import re
from typing import Generator, Callable, Dict, List

CONST_HEADER_KEYWORD = '[FEX2_HEADER] '
CONST_EXPERIMENT_KEYWORD = '[FEX2_EXPERIMENT] '


class Experiments:

    def __init__(self, experiments_output: str, default_parsers=True):
        assert os.path.isfile(experiments_output), f"No experiment file at {experiments_output}"
        self.__experiments_output = experiments_output
        self.parsers: Dict[str, Callable[[Experiment], None]] = {}
        if default_parsers:
            self.parsers.update({
                'benchmark': lambda experiment: get_run_argument('benchmark', experiment.header),
                'thread_count': lambda experiment: get_run_argument('thread_count', experiment.header),
                'type': lambda experiment: get_run_argument('type', experiment.header).split('_')[0],
                'subtype': lambda experiment: "_".join(get_run_argument('type', experiment.header).split('_')[1:])})
        # main header
        self.type: str
        self.name: str
        self.__parse_main_header()

    def __parse_main_header(self):
        with open(self.__experiments_output, 'r') as infile:
            for line in infile:
                if line.startswith(CONST_HEADER_KEYWORD):
                    self.type = get_run_argument('experiment_type', line)
                    self.name = get_run_argument('name', line)
                    return
        raise ValueError('Could not parse experiment output. Please make sure your output contains something like:'
                         '[FEX2_HEADER] name: <SOME_NAME>; experiment_type: <SOME_TYPE>;')

    def __iter__(self) -> Generator[Experiment]:
        with open(self.__experiments_output, 'r') as infile:
            experiment = None
            for line in infile:
                if line.startswith(CONST_HEADER_KEYWORD):
                    continue
                elif line.startswith(CONST_EXPERIMENT_KEYWORD):
                    if experiment:
                        experiment.parse(self.parsers)
                        yield experiment
                    experiment = Experiment(line)
                elif experiment is not None:
                    experiment.lines += [line]
            # We should not forget the last experiment
            assert experiment is not None, "There were no experiments to collect"
            experiment.parse(self.parsers)
            yield experiment

    def create_csv(self, parsed_csv: str):
        with open(parsed_csv, 'w') as outfile:
            writer = csv.DictWriter(outfile, list(self.parsers.keys()), extrasaction='ignore')
            writer.writeheader()
            writer.writerows([experiment.values for experiment in self])


class Experiment:
    def __init__(self, header: str):
        self.header: str = header
        self.lines: List[str] = []
        self.values: Dict[str, any] = {}

    def parse(self, parses: Dict[str, Callable[[Experiment], None]]):
        self.values.update({key: parses[key](self) for key in parses.keys()})


def line_parser(key: str, line_parse_function: Callable[[str], None]):
    return lambda experiment: in_line_with(experiment, key, line_parse_function)


def in_line_with(experiment: Experiment, key: str, line_parse_function: Callable[[str], None]):
    for line in experiment.lines:
        if key in line:
            return line_parse_function(line)
    return None


def locale_neutral_number(s: str, ignore_period, ignore_comma):
    if ignore_period:
        s = s.replace('.', '')
    if ignore_comma:
        s = s.replace(',', '')
    return s


def parse_time(s: str, ignore_period=False, ignore_comma=True):
    """
    Parse time as reported by /usr/bin/time, i.e., [hours:]minutes:seconds"
    and return it as number of seconds (float )
    Return 0.0 if does not match
    """
    s = locale_neutral_number(s, ignore_period, ignore_comma)

    pattern = r"((\d{0,2}):)?(\d{1,2}):(\d{1,2}\.\d{1,5})"
    match = re.search(pattern, s)
    if not match:
        return 0.0

    hours = int(match.group(2)) if match.group(2) else 0
    minutes = int(match.group(3))
    seconds = float(match.group(4))

    return hours * 3600 + minutes * 60 + seconds


def get_float_from_string(s: str, ignore_period=False, ignore_comma=True):
    s = locale_neutral_number(s, ignore_period, ignore_comma)
    pattern = r'\d{1,10}\.\d{1,10}'
    match = re.search(pattern, s)
    if match:
        match = match.group(0)
        result = float(match)
        return result
    return 0.0


def get_int_from_string(s: str, ignore_period=True, ignore_comma=True):
    s = locale_neutral_number(s, ignore_period, ignore_comma)
    pattern = r'\d{1,20}'
    match = re.search(pattern, s)
    if match:
        match = match.group(0)
        result = int(match)
        return result
    return 0


def get_run_argument(name, line):
    try:
        return re.search(r'%s: (\S+);' % name, line).group(1)
    except AttributeError as e:
        print("Wrong format of the log file")
        raise e
