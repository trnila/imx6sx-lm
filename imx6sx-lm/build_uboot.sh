#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

make -C ../u-boot O="$BUILD_DIR/u-boot" mx6sxlm_defconfig
make -C ../u-boot O="$BUILD_DIR/u-boot" -j"$(nproc)"
