# Fex

Fex is a software evaluation framework.
It is:
* _extensible_: can be easily extended with custom experiment types,
* _practical_: supports composition of different benchmark suites and real-world applications,
* _reproducible_: it is built on container technology to guarantee the same software stack across platforms.

Fex provides an interface for unified building, running, and processing results of evaluation experiments.
Out of the box, it supports the following workloads:

* Benchmark suites: Parsec 3.0, Phoenix, Splash 3
* Applications: SQLite, PostgreSQL, Memcached, Nginx, Apache

## Installing Fex

Fex does not require installation and only has to be downloaded:

```
git clone https://github.com/tudinfse/fex.git
```

Fex has been mainly tested in combination with Docker and it is recommended to do all experiments in it.
For that, build the corresponding Docker image:

```
make
```

## Trying it out

First, run the container:

```sh
make run
```

Inside the container, run one of the experiments:

```sh
./fex.py install -n phoenix
./fex.py run -n phoenix -t gcc_native -m 2 --num_runs 1
```

This will install all dependencies of Phoenix benchmark suite, compile the benchmarks with GCC, and run them on 2 threads.

The results of benchmark runs are aggregated in a log file, saved under `/data/results/phoenix/`.
This directory is also mounted into your host machine, under `your_project_dir/data/results/phoenix`:

```sh
vim your_project_dir/data/results/phoenix/raw.csv
```


## Using Fex

Full Fex documentation is on our [wiki page](https://github.com/tudinfse/fex/wiki).


## Dependencies for building plots

```
pip install coloredlogs py-cpuinfo scipy pandas matplotlib
```