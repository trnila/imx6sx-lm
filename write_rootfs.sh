#!/bin/bash
source ./config.sh

DEV=$1
if [ -z "$DEV" ]; then
    echo "Usage: $0 /dev/sdX1"
    exit 1
fi

set -ex

TARGET_DIR="$BUILD_DIR/target"
mkdir -p "$TARGET_DIR"
sudo umount "$TARGET_DIR" || true
sudo mount "$DEV" "$TARGET_DIR"
sudo rsync -av --delete "$BUILD_DIR/rootfs/" "$TARGET_DIR/"
sudo umount "$TARGET_DIR" || true