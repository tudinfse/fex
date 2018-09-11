#!/usr/bin/env python
from core import collect
import os


def main():
    res_path = os.environ['PROJ_ROOT'] + '/results/phoenix/raw.csv'
    collect.collect("phoenix", result_file=res_path)
