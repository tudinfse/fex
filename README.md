# Fex

Unified, extensible and ready-to-use evaluation infrastructure.
Fex is _extensible_ (can be easily extended with custom experiment types),
_practical_ (supports composition of different benchmark suites and real-world applications),
and _reproducible_ (it is built on container technology to guarantee the same software stack across platforms).

Out of the box, Fex provides a single interface for building, running and processing results of
Parsec 3.0 and Phoenix benchmark suites, SQLite, PostgreSQL and Memcached benchmarks.
However, it can be easily extended with any other applications.

## Installing Fex

Currently, Fex is not available as a package and can only be used directly:

```
git clone https://github.com/tudinfse/fex.git
```

Fex was mainly tested inside a predefined Docker container (see Dockerfile) and it is recommended to do all experiments in it.
For that, build the corresponding image:

```
make
```

## Trying it out

First, run the container:

```sh
make run
```

Inside the container, you can run one of the experiments:

```sh
./fex.py install -n phoenix
./fex.py run -n phoenix -t gcc_native -m 2 --num_runs 1
```

This will install all dependencies of Phoenix benchmark suite, compile the benchmarks with GCC, and run them on 2 threads.

The results of benchmark runs are aggregated in a log file, saved under `/data/results/phoenix/` inside the container.
This directory is also mounted into your host machine, in the project directory under `data/results/phoenix`:

```sh
vim data/results/phoenix/raw.csv
```


## Using Fex

Full documentation for Fex is in our [wiki page](https://github.com/tudinfse/fex/wiki).
