#!/bin/sh
set -ex

apply_patches() (
    cd "$1"
    git am ../patches/"$1"/*.patch
)

git submodule update --init
apply_patches u-boot
apply_patches linux