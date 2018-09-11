#!/usr/bin/env python
from __future__ import absolute_import

import os

from core import collect


def main():
    res_path = os.environ['PROJ_ROOT'] + '/results/parsec/raw.csv'
    collect.collect("parsec", result_file=res_path)
