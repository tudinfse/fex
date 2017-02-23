#!/usr/bin/env bash

RESULTSDIR=`pwd`/../raw_results
VERBOSE=-v

cd ..

set -x #echo on

# phoenix
./fex.py $VERBOSE plot -n phoenix -t perf               -f $RESULTSDIR/phoenix/perf.csv
./fex.py $VERBOSE plot -n phoenix -t instr              -f $RESULTSDIR/phoenix/perf.csv
./fex.py          plot -n phoenix -t misc_stat          -f $RESULTSDIR/phoenix/perf.csv
./fex.py          plot -n phoenix -t cache              -f $RESULTSDIR/phoenix/cache.csv
./fex.py $VERBOSE plot -n phoenix -t mem                -f $RESULTSDIR/phoenix/mem.csv
./fex.py $VERBOSE plot -n phoenix -t multi              -f $RESULTSDIR/phoenix/multithreading.csv
./fex.py          plot -n phoenix -t mpxcount           -f $RESULTSDIR/phoenix/mpx_instructions.csv
./fex.py $VERBOSE plot -n phoenix -t native_mem_access  -f $RESULTSDIR/phoenix/cache.csv
./fex.py $VERBOSE plot -n phoenix -t ku_instr           -f $RESULTSDIR/phoenix/ku_instructions.csv
./fex.py $VERBOSE plot -n phoenix -t mpx_feature_perf   -f $RESULTSDIR/phoenix/perf.csv
./fex.py $VERBOSE plot -n phoenix -t mpx_feature_mem    -f $RESULTSDIR/phoenix/mem.csv
./fex.py $VERBOSE plot -n phoenix -t ipc                -f $RESULTSDIR/phoenix/perf.csv

# phoenix varinput
./fex.py $VERBOSE plot -n phoenix_var_input -t perf -f $RESULTSDIR/phoenix/var_input_perf.csv
./fex.py $VERBOSE plot -n phoenix_var_input -t mem  -f $RESULTSDIR/phoenix/var_input_mem.csv

# parsec
./fex.py $VERBOSE plot -n parsec -t perf                -f $RESULTSDIR/parsec/perf.csv
./fex.py $VERBOSE plot -n parsec -t instr               -f $RESULTSDIR/parsec/perf.csv
./fex.py          plot -n parsec -t misc_stat           -f $RESULTSDIR/parsec/perf.csv
./fex.py          plot -n parsec -t cache               -f $RESULTSDIR/parsec/cache.csv
./fex.py $VERBOSE plot -n parsec -t mem                 -f $RESULTSDIR/parsec/mem.csv
./fex.py $VERBOSE plot -n parsec -t multi               -f $RESULTSDIR/parsec/multithreading.csv
./fex.py          plot -n parsec -t mpxcount            -f $RESULTSDIR/parsec/mpx_instructions.csv
./fex.py $VERBOSE plot -n parsec -t native_mem_access   -f $RESULTSDIR/parsec/cache.csv
./fex.py $VERBOSE plot -n parsec -t ku_instr            -f $RESULTSDIR/parsec/ku_instructions.csv
./fex.py $VERBOSE plot -n parsec -t mpx_feature_perf    -f $RESULTSDIR/parsec/perf.csv
./fex.py $VERBOSE plot -n parsec -t mpx_feature_mem     -f $RESULTSDIR/parsec/mem.csv
./fex.py $VERBOSE plot -n parsec -t ipc                 -f $RESULTSDIR/parsec/perf.csv

# parsec varinput
./fex.py $VERBOSE plot -n parsec_var_input -t perf -f $RESULTSDIR/parsec/var_input_perf.csv
./fex.py $VERBOSE plot -n parsec_var_input -t mem  -f $RESULTSDIR/parsec/var_input_mem.csv

# case studies
./fex.py $VERBOSE plot -n apache    -t tput -f $RESULTSDIR/casestudies/apache/raw.csv
./fex.py $VERBOSE plot -n memcached -t tput -f $RESULTSDIR/casestudies/memcached/raw.csv
./fex.py $VERBOSE plot -n nginx     -t tput -f $RESULTSDIR/casestudies/nginx/raw.csv

# microbenchmarks
./fex.py $VERBOSE plot -n micro -t perf -f $RESULTSDIR/micro/raw.csv

# merged
./fex.py $VERBOSE plot -n mergedplots -t tput     -f $RESULTSDIR/casestudies/raw.csv
./fex.py $VERBOSE plot -n mergedplots -t perf     -f $RESULTSDIR/merged/perf.csv
./fex.py $VERBOSE plot -n mergedplots -t mem      -f $RESULTSDIR/merged/mem.csv
./fex.py $VERBOSE plot -n mergedplots -t mpxcount -f $RESULTSDIR/merged/mpxcount.csv
./fex.py $VERBOSE plot -n mergedplots -t multi    -f $RESULTSDIR/merged/multithreading.csv
./fex.py $VERBOSE plot -n mergedplots -t cache    -f $RESULTSDIR/merged/cache.csv
./fex.py $VERBOSE plot -n mergedplots -t instr    -f $RESULTSDIR/merged/instr.csv
./fex.py $VERBOSE plot -n mergedplots -t ipc      -f $RESULTSDIR/merged/ipc.csv
./fex.py $VERBOSE plot -n mergedplots -t mpx_feature_perf -f $RESULTSDIR/merged/mpx_feature_perf.csv
./fex.py $VERBOSE plot -n mergedplots -t mpx_feature_mem  -f $RESULTSDIR/merged/mpx_feature_mem.csv
