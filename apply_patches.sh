#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

apply_patches() (
    cd "$1"
    git am ../patches/"$1"/*.patch
)

cd "$ROOT_DIR"
git submodule update --init
apply_patches u-boot
apply_patches linux

cd linux
git am ../linux-lin/sllin/linux-patches/*.patch
