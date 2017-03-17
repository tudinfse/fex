#!/usr/bin/env python
from __future__ import absolute_import

import re

from core import collect


def main():
    collect.collect("postgresql", user_parameters={
        "num_clients": ["clients", lambda l: int(re.search(r'clients: (\d{1,4})', l).group(1))],
        "latency": ["latency average", lambda l: collect.get_float_from_string(l)],
        "tps": ["excluding connections establishing", lambda l: collect.get_float_from_string(l)],
    })
