#!/bin/bash
set -ex
source config.sh
make -C u-boot mx6sxlm_defconfig
make -C u-boot -j"$(nproc)"