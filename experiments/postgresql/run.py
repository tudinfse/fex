#!/usr/bin/env python
"""
Run PostgreSQL:
    - start postgres on server in background (under perf)
    - start pgbench with init phase (scale=200), wait till finish
    - start pgbench with run phase  (scale=200, run=60s),  wait till finish
    - kill postgres on server
    - save client load&run phases and server logs in separate files
"""
from __future__ import print_function

import os
import logging
from time import sleep
from subprocess import Popen
from pwd import getpwnam
from shutil import rmtree

from core.common_functions import *
from core.run import Runner


class PostgreSQLPerf(Runner):
    """
    Runs PostgreSQL with YCSB input
    """
    name = "postgresql"
    exp_name = "postgresql"
    bench_suite = False

    benchmarks = {"postgresql": "-s 200 -T 60 -S"}
    # client_numbers = (32, 64, 128, 192, 256, 320, 384, 448, 512)
    client_numbers = (32,)

    db_name = "test"
    inputs_dir = env["BIN_PATH"] + "benchmarks/ycsb-traces"
    server = ''

    def experiment_setup(self):
        self.set_common_dirs()
        self.dirs["init_log_file"] = env["DATA_PATH"] + "/results/" + self.exp_name + "/" + "postgres-init.log"
        self.set_experiment_parameters()
        self.set_logging()

        self.remove_old_results([self.dirs["log_file"], self.dirs["init_log_file"]])
        self.remove_old_build()

    def per_run_action(self, i):
        try:
            c("killall -q postgres")
        except CalledProcessError:
            # ignore if Postger doesn't run
            pass

    def per_benchmark_action(self, type_, benchmark, args):
        # build
        build_path = "/".join([self.dirs["build"], type_])
        self.current_exe = build_path + '/' + benchmark

        build_benchmark(
            b=benchmark,
            t=type_,
            makefile=self.dirs['bench_src'],
            build_path=build_path
        )

        # give access rights to the "postgres" user
        c("mkdir -p %s/data" % build_path)
        c("rm -f /postgresql_build")
        c("ln -s %s /postgresql_build" % build_path)
        c("chown postgres:postgres /postgresql_build")
        c("chown -R postgres:postgres %s" % build_path)
        c("chmod -R 0700 /postgresql_build/")  # yeah, I know, I will burn in hell for this

    def per_thread_action(self, type_, benchmark, args, thread_num):
        # prepare the server
        with open(self.dirs["init_log_file"], "a") as f:
            # initialize a DB
            f.write("-- Initializing a DB --")
            rmtree("/postgresql_build/bin/data")
            out = my_check_output("sudo -u postgres /postgresql_build/bin/initdb -D /postgresql_build/bin/data")
            f.write(out)

            # start the server
            cmd = "/postgresql_build/bin/postgres -D /postgresql_build/bin/data"
            logging.debug("Starting a DB server: %s" % cmd)
            server = Popen(cmd, shell=True, preexec_fn=postgres_user())
            sleep(1)

            # create a DB
            f.write("-- Creating the DB --")
            out = my_check_output("sudo -u postgres /postgresql_build/bin/createdb %s" % self.db_name)

        # run the benchmark
        with open(self.dirs["log_file"], "a") as f:
            for client_number in self.client_numbers:
                # initialize
                out = my_check_output("sudo -u postgres /postgresql_build/bin/pgbench -i %s" % self.db_name)
                f.write(out)

                # run
                msg = self.run_message.format(input=client_number, **locals())
                self.log_run(msg)
                f.write("[run] " + msg)

                out = my_check_output("sudo -u postgres /postgresql_build/bin/pgbench {args} -c {client_number}  -j {thread_num} {db_name}".format(
                    db_name=self.db_name,
                    ** locals()
                ))

                f.write(out)

        # clean
        try:
            server.kill()
            c("killall -q postgres")  # to be absolutely sure
            sleep(1)
        except CalledProcessError:
            # ignore if Postgres doesn't run
            pass


def postgres_user():
    def result():
        p_uid = getpwnam("postgres").pw_uid
        p_gid = getpwnam("postgres").pw_gid
        os.setgid(p_uid)
        os.setuid(p_gid)
    return result


def main(benchmark_name=None):
    runner = PostgreSQLPerf()
    runner.main()
