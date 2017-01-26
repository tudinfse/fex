#!/usr/bin/env bash

echo "=== Downloading inputs ==="
mkdir -p ${DATA_PATH}/inputs/
rsync -r alex@141.76.44.133:shared/inputs/splash/  "${DATA_PATH}/inputs/splash/"
echo "Splash installed"
