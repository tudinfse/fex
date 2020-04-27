#!/usr/bin/env bash
# MANDATORY HEADER: DO NOT MODIFY!
if [ -z "${PROJ_ROOT}" ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source "${PROJ_ROOT}"/install/common.sh
# END HEADER

# get the benchmark sources
clone_git_repo https://github.com/SakalisC/Splash-3.git /tmp/splash/ ''

# copy the sources into correct paths
tmp_dir=/tmp/splash

apps_dir=${tmp_dir}/codes/apps
for i in $(ls ${apps_dir}); do
    install_dir=./benchmarks/splash/$i/src
    cp -r ${apps_dir}/$i/ ${install_dir}
    if [ -d ${install_dir}/inputs/ ]; then
        mv ${install_dir}/inputs/ ${install_dir}/../inputs
    fi
done

kernels_dir=${tmp_dir}/codes/kernels
for i in $(ls ${kernels_dir}); do
    install_dir=./benchmarks/splash/$i/src
    cp -r ${kernels_dir}/$i/ ${install_dir}
    if [ -d ${install_dir}/inputs/ ]; then
        mv ${install_dir}/inputs/ ${install_dir}/../inputs
    fi
done

# copy m4 macros
cp -r /tmp/splash/codes/pthread_macros benchmarks/splash/pthread_macros

# patch input paths
sed -i 's:inputs:benchmarks/splash/raytrace/inputs:g' benchmarks/splash/raytrace/inputs/car.env
