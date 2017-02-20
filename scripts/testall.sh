#!/usr/bin/env bash

# cleanup if the test is terminated
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT


cd $PROJ_ROOT

if [ ${1} = "fast" ]; then

    FAIL=0

    echo "Starting Phoenix..."
    ./fex.py run -n phoenix_perf -t gcc_native  --multithreaded_build -i test &

    echo "Starting Parsec..."
    ./fex.py run -n parsec_perf -t gcc_native --multithreaded_build -i test &

    echo "Starting Apache..."
    ./fex.py run -n apache_perf -t gcc_native  --multithreaded_build -i test &

    for job in `jobs -p`
    do
        wait $job || let "FAIL+=1"
    done

    echo "Number of failed programs: $FAIL"

    if [ "$FAIL" == "0" ];
    then
        echo "Everything worked out."
    else
        echo "Something failed! See logs above."
    fi

else
    printf "\n  ==  MICRO  ==\n"

    printf "\n  ==  BENCHMARK SUITES  ==\n"

    echo "  ==  Phoenix  =="
    ./fex.py run -n phoenix_perf -t gcc_native gcc_asan --multithreaded_build -i test

    printf "\n  ==  Splash  ==\n"
    ./fex.py run -n splash_perf -t gcc_native gcc_asan --multithreaded_build -i test

    printf "\n  ==  Parsec  ==\n"
    ./fex.py run -n parsec_perf -t gcc_native gcc_asan --multithreaded_build -i test


    printf "\n  ==  APPS  ==\n"

    printf "\n  ==  Apache  ==\n"
    ./fex.py run -n apache_perf -t gcc_native gcc_asan --multithreaded_build -i test

    printf "\n  ==  Memcached  ==\n"
    printf "\n  ==  Nginx  ==\n"
    printf "\n  ==  Postgres  ==\n"
    printf "\n  ==  SQLite  ==\n"
fi

cd -
