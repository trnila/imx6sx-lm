#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

"$ROOT_DIR/apply_patches.sh"
./build_uboot.sh
./build_linux.sh
./build_sllin.sh
./build_recovery.sh
./build_rootfs.sh
