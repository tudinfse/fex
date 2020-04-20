#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

clone_git_repo https://github.com/SakalisC/Splash-3.git /tmp/splash/ ''

for i in $(ls /tmp/splash/codes/apps) ; do
    cp -r /tmp/splash/codes/apps/$i/ benchmarks/splash/$i/src/;
    if [ -d benchmarks/splash/$i/src/inputs/ ]; then
        mv benchmarks/splash/$i/src/inputs/ benchmarks/splash/$i/inputs/
    fi
done

for i in $(ls /tmp/splash/codes/kernels) ; do
    cp -r /tmp/splash/codes/kernels/$i/ benchmarks/splash/$i/src/;
    if [ -d benchmarks/splash/$i/src/inputs/ ]; then
        mv benchmarks/splash/$i/src/inputs/ benchmarks/splash/$i/inputs/
    fi
done

cp -r /tmp/splash/codes/pthread_macros benchmarks/splash/pthread_macros

# patch input paths
sed -i 's:inputs:benchmarks/splash/raytrace/inputs:g' benchmarks/splash/raytrace/inputs/car.env
