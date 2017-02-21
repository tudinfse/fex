#!/usr/bin/env python
from __future__ import absolute_import

from core import collect


def main():
    full_output_file = collect.data + "/micro/micro.log"
    results_file = collect.data + "/micro/raw.csv"
    collect.collect(results_file, full_output_file)
