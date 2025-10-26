#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

make -C ../linux O="$BUILD_DIR/linux" imx_v6_v7_defconfig
make -C ../linux O="$BUILD_DIR/linux" -j"$(nproc)"
