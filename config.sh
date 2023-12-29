#!/bin/bash
ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export ROOT_DIR
export BUILD_DIR="$ROOT_DIR/build"