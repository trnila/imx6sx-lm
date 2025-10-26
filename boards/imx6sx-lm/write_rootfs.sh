#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../common.sh"

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

# configure hostname
echo imx6-lm | sudo tee "$TARGET_DIR/etc/hostname"

# setup SSH keys
sudo mkdir -p "$TARGET_DIR/root/.ssh/"
sudo cp ~/.ssh/id_rsa.pub "$TARGET_DIR/root/.ssh/authorized_keys"
sudo chown -R root "$TARGET_DIR/root/.ssh/"

sudo umount "$TARGET_DIR" || true
