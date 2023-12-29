#!/bin/bash
set -ex
source ./config.sh

make -C linux imx_v6_v7_defconfig
make -C linux -j"$(nproc)"