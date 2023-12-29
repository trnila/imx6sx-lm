#!/bin/bash
set -ex

./apply_patches.sh
./build_uboot.sh
./build_linux.sh
./build_recovery.sh
./build_rootfs.sh
