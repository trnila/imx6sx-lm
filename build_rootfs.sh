#!/bin/bash
set -ex
source ./config.sh

ROOTFS_URL=http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
IMAGE_NAME=imx6sx-lm
BASE_IMAGE_NAME="$IMAGE_NAME"-base

if [ -z "$(docker images -q "$BASE_IMAGE_NAME")" ]; then
	curl -L "$ROOTFS_URL" | docker import - "$BASE_IMAGE_NAME"
fi

docker build --build-arg FROM="$BASE_IMAGE_NAME" -t "$IMAGE_NAME" -f rootfs.Dockerfile .

# extract into directory
sudo rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"
CONTAINER=$(docker container create "$IMAGE_NAME" true)
docker export "$CONTAINER" | sudo bsdtar -xpf - -C "$ROOTFS_DIR/"
rm -f "$ROOTFS_DIR/.dockerenv"
docker rm "$CONTAINER"
echo OK