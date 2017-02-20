#!/usr/bin/env bash

cd $PROJ_ROOT

printf "\n  ==  MICRO  ==\n"

printf "\n  ==  BENCHMARK SUITES  ==\n"

echo "  ==  Phoenix  =="
./fex.py run -n phoenix_perf -t gcc_native gcc_asan --multithreaded_build -i test

printf "\n  ==  Splash  ==\n"

printf "\n  ==  Parsec  ==\n"
./fex.py run -n parsec_perf -t gcc_native gcc_asan --multithreaded_build -i test


printf "\n  ==  APPS  ==\n"

printf "\n  ==  Apache  ==\n"
./fex.py run -n apache_perf -t gcc_native gcc_asan --multithreaded_build -i test

printf "\n  ==  Memcached  ==\n"
printf "\n  ==  Nginx  ==\n"
printf "\n  ==  Postgres  ==\n"
printf "\n  ==  SQLite  ==\n"

cd -
