#!/usr/bin/env bash

# cleanup if the test is terminated
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT


cd $PROJ_ROOT

if [ $1 = "fast" ]; then

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

    printf "\n  ==  COMPILERS  ==\n"

    printf "Y\nY\n" | ./fex.py install -n gcc-6.1
    printf "Y\n" | ./fex.py install -n llvm-3.8.0

    printf "\n  ==  MICRO  ==\n"


    printf "\n  ==  BENCHMARK SUITES  ==\n"

    printf "\n  ==  Phoenix  ==\n"
    printf "Y\n" | ./fex.py install -n phoenix
    ./fex.py run -n phoenix_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  Splash  ==\n"
    printf "Y\n" | ./fex.py install -n splash
    ./fex.py run -n splash_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  Parsec  ==\n"
    printf "Y\nY\n" | ./fex.py install -n parsec
    ./fex.py run -n parsec_perf -t gcc_native gcc_asan --multithreaded_build -i test


    printf "\n  ==  APPS  ==\n"

    printf "\n  ==  Nginx  ==\n"
    ./fex.py install -n nginx
    ./fex.py run -n nginx_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  Memcached  ==\n"
    ./fex.py install -n memcached
    ./fex.py run -n memcached_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  SQLite  ==\n"
    printf "Y\n" | ./fex.py install -n sqlite3
    ./fex.py run -n sqlite3_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  Postgres  ==\n"
    printf "Y\n" | ./fex.py install -n postgresql
    ./fex.py run -n postgresql_perf -t gcc_native gcc_asan --multithreaded_build -i test
    printf "\n  ==  Apache  ==\n"
    printf "Y\n" | ./fex.py install -n apache
    ./fex.py run -n apache_perf -t gcc_native gcc_asan --multithreaded_build -i test

fi

cd -
