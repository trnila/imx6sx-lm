#!/usr/bin/env bash
set -ex

BOARD_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[1]}")" &> /dev/null && pwd)
ROOT_DIR="$BOARD_DIR/.."
BOARD=$(basename "$BOARD_DIR")

export ROOT_DIR
export BOARD_DIR
export BOARD
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export BUILD_DIR="$ROOT_DIR/build/$BOARD"
export ROOTFS_DIR="$BUILD_DIR/rootfs"

build_rootfs() {
    ROOTFS_URL=http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
    IMAGE_NAME="archlinux-boards-$BOARD"
    BASE_IMAGE_NAME="archlinux-boards-base"
    DOCKERFILE="rootfs.Dockerfile"

    if [ -z "$(docker images -q "$BASE_IMAGE_NAME")" ]; then
        curl -L "$ROOTFS_URL" | docker import - "$BASE_IMAGE_NAME"
    fi

    docker build --build-arg FROM="$BASE_IMAGE_NAME" --build-arg BOARD="$BOARD" -t "$IMAGE_NAME" -f "../$DOCKERFILE" ..

    # extract into directory
    sudo rm -rf "$ROOTFS_DIR"
    mkdir -p "$ROOTFS_DIR"
    CONTAINER=$(docker container create "$IMAGE_NAME" true)
    docker export "$CONTAINER" | sudo bsdtar -xpf - -C "$ROOTFS_DIR/"
    rm -f "$ROOTFS_DIR/.dockerenv"
    docker rm "$CONTAINER"
}

cd "$BOARD_DIR"
