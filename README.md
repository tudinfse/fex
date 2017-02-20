# Warning: the documentation is highly outdated!

The current version is Work in Progress and correct instructions will be added later.

If you're interested in the framework anyway, please, send me a message.

# Fex

Unified, extensible and ready-to-use benchmarking infrastructure.
Provides a single interface for building, running and processing results
of Parsec 3.0 and Phoenix benchmark suites, SQLite, PostgreSQL and Memcached benchmarks,
and can be extended with any other applications.

It is similar to Parsec, but contains results processing, has hooks for controlling both build
and run stages and can be easily extended with more applications and other benchmark suites.
Also, features isolated experiments in Docker containers.

## Image Management

Experiment can be run in a Docker container, which is controlled by the Makefile:

* Build

```sh
make
```

* Create a new container

```sh
make run
```

* Inside container, try running one of the experiments:

```sh
./fex.py install -n sqlite3
./fex.py run -n sqlite3_perf --num_threads 1 2 --num_runs 1
```

The results of benchmark runs are aggregated in a log file, saved in your current directory (on host machine, not container) under `data/results/sqlite3_perf`:

```sh
vim data/results/sqlite3_perf/raw.csv
```

For more commands, see Makefile.


## Running an experiment

Here is a sequence of commands needed to set up the environment:

```sh
# install benchmarks' dependencies and download required inputs
./fex.py install -n memcached parsec phoenix postgresql spec sqlite3

# if needed, setup SGX environment
sudo service aesmd stop
sudo rmmod isgx; make -C $HOME/code/sgx/sgx-intel-driver; sudo insmod $HOME/code/sgx/sgx-intel-driver/isgx.ko
sudo sysctl vm.mmap_min_addr=0
export HEAP=0xF0000
export MUSL_VERSION=1
export MUSL_ETHREADS=4
export MUSL_STHREADS=4
```

If you're doing separate build and run, prepare different environments:

* build - ignore bugs during the build

```sh
export ASAN_OPTIONS=verbosity=0:detect_leaks=false:print_summary=false:halt_on_error=false:poison_heap=false
```

* catch all bugs when running

```sh
export ASAN_OPTIONS=verbosity=2:print_summary=true:halt_on_error=true:poison_heap=true
```

Afterwards, we can run tests. For example:

* Build and run Phoenix benchmarks with debug info (careful, debug is slower!)

```sh
./fex.py -d run -n phoenix_perf --num_runs 1 --num_threads 1 -t gcc_native gcc_mpx ...
```

* Build but not run Phoenix benchmarks without debug info

```sh
./fex.py run -n phoenix_perf --num_runs 1 --num_threads 1 --partial_experiment build -t gcc_native gcc_mpx ...
```

* Run but not rebuild Phoenix benchmarks

```sh
 example 3:
./fex.py -d run -n phoenix_perf --num_runs 5 --num_threads 1 --partial_experiment run -t gcc_native gcc_mpx ...
```


## Entrypoint

The `fex.py` file is a central point of managing benchmarks. It has two main commands:

* **install** - installs a benchmark/compiler by name

```sh
./fex.py install -n foo
```

Under the hood it looks at all installation scripts in the `install` directory and runs the first one that matches the name `foo.sh`.

* **run** - runs an experiment

```sh
./fex.py run -n foo_bar --num_threads N --num_runs M --type baz
```

This command runs the experiment named *foo_bar* (located in `experiments/exp_foo_bar`) M times and using, if possible, N threads.
Build constants (and any other parameters) are defined in Makefile `makefiles/Makefile.baz`.

* **collect** - collect statistics based on received results

```sh
./fex.py collect -n foo_bar --stats perf
```

* **plot** - build plot based on received results (**under construction**)

```sh
./fex.py plot -n foo_bar -t memory
```

### Run arguments

Full CLI of **run** command:

* `--names, -n`: Names of experiments to run
* `--num_runs`: How much times to run the experiments (results will be averaged on the collection stage)
* `--num_threads`: Maximum number of threads (multiple values possible)
* `--types, -t`: Build type (multiple values possible). E.g `-t gcc_native icc_native`
* `--stats`: Statistics tool used for measurement like perf-stat, time, etc
* `--partial_experiment`: Perform an experiment partially: `--partial_experiment build` - only build benchmarks, `--partial_experiment run` - only run them
* `--benchmark_name, -b`: Run only one benchmark from the benchmark suite
* Debug mode (`./fex.py -d run ...`): shows much more information about build and execution,
and may set some helpful environmental variables.

For the most up-to-date information run:

```sh
./fex.py --help
```

### Environmental variables

Default values for environmental variables are set in the `fex.py:Manager.set_environment` function.
If you want to replace default value with you own, simply export it in the environment, e.g.:

```
export DATA_PATH=~/results/
```


## Adding an experiment

All experiments should be put in the `experiments` directory.
To be accessible though the `fex.py`, each experiment have to be located in the separate directory named `exp_experiment_name`.
That is, if an experiment is called `foo`, the directory name should be `exp_foo`.

Each such directory has to contain a following files:
* `run.sh` - script for running the experiment.
* `collect.py` - script for processing an output. `experiments/generic_collect.py` can be used to simplify parsing
* `__init__.py` - to make a python package

## Testing

All tests should be located under the `tests/` directory.

To run all tests, execute:

```sh
nose2 -c tests/nose2.cfg tests
```

You can run only a subset of test using two variables:

* `NAME`: name of the test to run. E.g.:

```sh
NAME=parsec-x264 nose2 -c tests/nose2.cfg tests
```

* `BUILD_TYPE`: build type. E.g.:

```sh
BUILD_TYPE=gcc_native nose2 -c tests/nose2.cfg tests
```

* `BUILD_THREADS_NUM`: number of threads used for a build.

These variables can also be used in combination.

For more usage details, refer to [nose2 documentation](http://nose2.readthedocs.io/en/latest/getting_started.html).

## Development

For development documentation, refer to [wiki](https://github.com/OleksiiOleksenko/mpx_evaluation/wiki/Development).

