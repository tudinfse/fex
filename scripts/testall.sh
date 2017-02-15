#!/usr/bin/env bash

cd $PROJ_ROOT

echo "  ==  Phoenix  =="
./fex.py run -n phoenix_perf -t gcc_native gcc_asan --multithreaded_build -i test

printf "\n  ==  Parsec  ==\n"
./fex.py run -n parsec_perf -t gcc_native gcc_asan --multithreaded_build -i test

cd -
