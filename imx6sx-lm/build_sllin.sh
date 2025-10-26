#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

make -C ../linux O="$BUILD_DIR/linux" M="$(pwd)/../linux-lin/sllin/" modules
