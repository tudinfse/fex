#!/usr/bin/env python
from __future__ import print_function

from core.common_functions import *
from core.run import Runner


class SplashPerf(Runner):
    """
    Runs Splash-3 benchmarks
    """

    name = "splash"
    exp_name = "splash_perf"
    bench_suite = True

    benchmarks = {
        "barnes": " < {input_dir}/n16384-p{thread}",
        "cholesky": " -p{thread} < {input_dir}/tk15.O ",
        "fft": " -p{thread} -m16",
        "fmm": " < {input_dir}/input.{thread}.16384",
        "lu": "-p{thread} -n512",
        "ocean": " -p{thread} -n258",
        "radiosity": " -p {thread} -ae 5000 -bf 0.1 -en 0.05 -room -batch",
        "radix": " -p{thread} -n1048576",
        "raytrace": " -p{thread} -m64 {input_dir}/car.env",
        "volrend": " {thread} {input_dir}/head",
        "water-nsquared": " < {input_dir}/n512-p{thread}",
        "water-spatial": " < {input_dir}/n512-p{thread}",
    }

    def per_benchmark_action(self, type_, benchmark, args):
        build_path = "/".join([self.dirs["build"], benchmark, type_])
        self.current_exe = build_path + '/' + benchmark

        build_benchmark(
            b=benchmark,
            t=type_,
            makefile=self.dirs['suite_src'] + "/" + benchmark,
            build_path=build_path
        )


def main(benchmark_name=None):
    runner = SplashPerf(benchmark_name)
    runner.main()
