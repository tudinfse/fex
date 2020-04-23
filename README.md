# Fex2

Fex2 is a software evaluation framework.
Its main focus is on evaluation of academic systems projects, though you could probably use it for non-academic projects as well.

Our goal was to create a flexible yet simple tool that you could start using when you need a quick and dirty experiment that verifies your idea, and you can keep extending it until you have a complete, publishable evaluation.
Our secondary goal was to help you avoid committing [Benchmarking crimes](https://www.cse.unsw.edu.au/~gernot/benchmarking-crimes.html), though this is still work in progress.

**NOTE**: This is a revised version of Fex, with a similar functionality, but a considerably different interface. If you're looking for Fex v1, you can find it in the branch `fex-1`.

# Install

```shell script
$ git clone https://github.com/tudinfse/fex.git
$ cd fex
$ sudo python ./setup.py bdist_egg && sudo pip install .
$ fex2
No action specified
usage: fex2 [-h] {...
```

# Preparing evaluation

Initialize the working directory

```shell script
$ cd your_project
$ mkdir evaluation
$ cd evaluation
$ fex2 init
```

This command will initialize the standard directory structure:
* `install` contains bash scripts for installing benchmarks and supporting tools.
* `benchmarks` contains the source code of the benchmarks (if applicable).
 Each benchmark directory also contains at least one makefile describing how to build the benchmark in a generic way (i.e., without specifying the compiler, build flags, etc.).
* `build_types` contains makefiles, each describing a single build configuration (this is where we specify the compiler, build flags, and similar).
These configurations are later used to build the benchmarks.
By default, this directory contains a sample build type: `gcc_native`.
You can use them as a reference.
* `experiments` contains bash and/or python scripts that describe how to run experiments.
Normally, every subdirectory within `experiments` describes how to measure a single parameter of a single benchmark or a benchmark suite.

The initialization will also create a configuration file `config.py` which is the central configuration point for all experiment.

# Example 1: Benchmarking GCC optimizations on SPLASH 3.0

## TL;DR

```shell script
$ fex2 template splash
$ fex2 install splash
$ cat <<EOF >> build_types/gcc_optimized.mk
include gcc_native.mk
include common.mk

CFLAGS += -O3
EOF
$ fex2 run splash -b gcc_native gcc_optimized -t perf -m 1 4 -r 10 -o splash-raw.txt
$ fex2 collect splash -t perf -i splash-raw.txt -o splash-collected.csv
$ fex2 plot splash -p speedup -i splash-collected.csv -o splash.pdf
```

This will produce a plot (`splash.pdf`) showing the performance improvement of GCC -O3 optimization on SPLASH benchmarks, averaged over 10 runs.

## Explanation

```shell script
$ fex2 template splash
```

Fex2 comes with several benchmarks and benchmarks suites ready to use ([list](#list-of-pre-configured-workloads)).
Accordingly, this command (`template`) copies all the necessary scripts and creates directories for later experiments on SPLASH.
If you want to run a benchmark not shipped with Fex2, you have to write the scripts yourself ([instructions](#manual-experiment-configuration)).

Specifically, the `template` command will:
* create an installation script in the `install` directory
* create a `splash` subdirectory in `experiments` and, within it, create scripts for running performance measurements over SPLASH benchmarks, collecting results, and building plots.
* create makefiles in `bencharms` that will be used to build the SPLASH benchmarks
Your are later free to modify these scripts as you wish.

```shell script
$ fex2 install splash
```

This command invokes `install/splash.sh` (created by the previous command), which in turn downloads the source code of the benchmarks into `benchmarks/splash`.
It also copies all the necessary makefiles to build the benchmarks (e.g., `benchmarks/splash/fft/Makefile`).

Again, if you want to use your own benchmarks, you need to write the installation script yourself (optional) and create the corresponding makefiles (required).

```shell script
$ cat <<EOF >> gcc_optimized.mk
include gcc_native.mk
include common.mk

CFLAGS += -O3
EOF
```

The only thing that you have to actually write in this experiment is the build description.
We want to test the optimizations of GCC - accordingly, we add `-O3` to `CFLAGS`.

```shell script
$ fex2 run splash -b gcc_native gcc_optimized -t perf -r 10 -m 1 4 -o splash-raw.txt
```

This will build all the benchmarks in SPLASH in two build configurations (using `build_types/gcc_native.mk` and `build_types/gcc_optimized.mk`),
run them 10 times (`-r 10`), and measure their runtime (`-t perf`). The benchmarks are running in two configurations, with one and four execution threads (`-m 1 4`).

The experiment itself is described in `experiments/splash/run.sh`.

The output of the experiment is stored in `splash-raw.txt`.
If you do not provide the `-o` option, the output will be printed into `stdout`.

If you do not want to see the build logs, you can redirect them into a file with a flag ` --build-output build.txt`.

By default, the builds are stored into `evaluation/build/splash`.
You can change it in `config.py` (see [configuration](#configpy)).

```shell script
$ fex2 collect splash -t perf -i splash-raw.txt -o splash-collected.csv
```

Usually, we need to parse the raw output of the experiments before further processing it.
For this purpose, we have `collect.py` scripts (e.g., `experiments/splash/collect.py`).
This command invokes the script for SPLASH.

```shell script
$ fex2 plot splash -p speedup -i splash-collected.csv -o splash.pdf
```

This command calculates the speedup of `gcc_optimized` over `gcc_native` (`*_native` is always used as a baseline) and
build a bar plot of the results.
The procedure is described in `experiments/splash/plot.py`.

Internally, we use matplotlib, but you're free to use anything else in your experiments - just re-write `plot.py`.

# Example 2: Modifying an existing experiment

TBD

# Example 3: Creating an experiment from scratch

TBD

# Config.py

TBD

# List of pre-configured workloads

Benchmark suites:
* Splash
* SPEC [Under reconstruction]
* Parsec [Under reconstruction]
* Phoenix [Under reconstruction]

Applications:
* Apache [Under reconstruction]
* Memcached [Under reconstruction]
* Nginx [Under reconstruction]
* PostgreSQL [Under reconstruction]
* SQLite [Under reconstruction]

