#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

make -C ../linux O="$BUILD_DIR/linux" nxp/imx/imx6sx-lm.dtb
