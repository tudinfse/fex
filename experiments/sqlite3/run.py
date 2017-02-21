#!/usr/bin/env python
from __future__ import print_function

from core.common_functions import *
from core.run import Runner


class SQLitePerf(Runner):
    """
    Runs SQLite benchmark with YCSB inputs
    """
    name = "sqlite3"
    exp_name = "sqlite3"
    bench_suite = False

    benchmarks = {
        "sqlite3": "a_kv1M_op1M",
        # "sqlite3": "b_kv1M_op1M",
        # "sqlite3": "c_kv1M_op1M",
        # "sqlite3": "d_kv1M_op1M",
    }

    input_dir = env["BIN_PATH"] + "benchmarks/ycsb-traces"
    args = " -l {input_dir}/{input}.load -r {input_dir}/{input}.run -d 6.0 -t {thread}"

    def per_benchmark_action(self, type_, benchmark, args):
        build_path = "/".join([self.dirs["build"], type_])
        self.current_exe = build_path + '/' + benchmark

        build_benchmark(
            b=benchmark,
            t=type_,
            makefile=self.dirs['bench_src'],
            build_path=build_path
        )

    def per_thread_action(self, type_, benchmark, args, thread_num):
        # small confusion here - sqlite has a bit different interface,
        # thus what is called args in the superclass here means an input
        self.current_args = self.args.format(thread=thread_num, input_dir=self.input_dir, input=args)

        msg = self.run_message.format(input='native', **locals())
        real_threads = str(int(thread_num) - 1)

        with open(self.dirs["log_file"], "a") as f:
            self.log_run(msg)
            f.write("[run] " + msg + "\n")
            out = self.run(real_threads)
            f.write(out)
            f.write("[done]\n")


def main(benchmark_name=None):
    runner = SQLitePerf()
    runner.main()
