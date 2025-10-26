#!/usr/bin/env bash
set -ex

apply_patches() (
    cd "$ROOT_DIR"
    git submodule update --init
    for repo in u-boot linux; do (
        cd "$repo"
        git am ../patches/"$repo"/*.patch
    )
    done

    cd linux
    git am ../linux-lin/sllin/linux-patches/*.patch
)

build_rootfs() {
    ROOTFS_URL=http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
    IMAGE_NAME="archlinux-boards-$BOARD"
    BASE_IMAGE_NAME="archlinux-boards-base"
    DOCKERFILE="rootfs.Dockerfile"

    if [ -z "$(docker images -q "$BASE_IMAGE_NAME")" ]; then
        curl -L "$ROOTFS_URL" | docker import - "$BASE_IMAGE_NAME"
    fi

    docker build --build-arg FROM="$BASE_IMAGE_NAME" --build-arg BOARD="$BOARD" -t "$IMAGE_NAME" -f "$ROOT_DIR/$DOCKERFILE" "$ROOT_DIR"

    # extract into directory
    sudo rm -rf "$ROOTFS_DIR"
    mkdir -p "$ROOTFS_DIR"
    CONTAINER=$(docker container create "$IMAGE_NAME" true)
    docker export "$CONTAINER" | sudo bsdtar -xpf - -C "$ROOTFS_DIR/"
    rm -f "$ROOTFS_DIR/.dockerenv"
    docker rm "$CONTAINER"
}

partition() {
    if [[ "$1" == /dev/mmcblk* ]]; then
        echo "${1}p${2}"
    else
        echo "${1}${2}"
    fi
}

action="$1"
BOARD="$2"
shift || true
shift || true
if [[ "$action" != "build" && "$action" != "write" ]]; then
    echo "Usage: $0 build"
    exit 1
fi

if [[ "$action" = "build" ]] && [[ -z "$BOARD" || "$BOARD" = "all" ]]; then
    for board in boards/*; do
        "$0" build "$(basename "$board")" "$@"
    done
    exit 0
fi

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export BUILD_DIR="$ROOT_DIR/out/$BOARD"
export ROOTFS_DIR="$BUILD_DIR/rootfs"
export BOARD
export ROOT_DIR

cd "boards/$BOARD"
# shellcheck disable=SC1090
source "$BOARD.sh"

if [ "$action" = "build" ]; then
    if [ "$#" -eq 0 ]; then
        apply_patches
        build_uboot
        build_linux
        build_linux_dtb
        declare -F build_fit && build_fit
        build_sllin
        declare -F build_recovery && build_recovery
        build_rootfs
    else
        for cmd in "$@"; do
            "$cmd"
        done
    fi
    echo OK
elif [ "$action" = "write" ]; then
    SDCARD="$1"
    if [ -z "$SDCARD" ]; then
        echo "Missing sdcard argument e.g. /dev/mmcblkX"
        exit
    fi

    MNT="$ROOT_DIR/mnt"
    mkdir -p "$MNT"

    cleanup() {
        mount | cut -f 3 -d ' ' | grep "$MNT" | xargs -I{} sudo umount -l {} || true
    }

    trap cleanup EXIT
    cleanup || true

    declare -F rootfs_partition && rootfs_partition
    rootfs_mount
    rootfs_write

    # configure hostname
    echo "$BOARD" | sudo tee "$MNT/etc/hostname"

    # setup SSH keys
    sudo mkdir -p "$MNT/root/.ssh/"
    cat ~/.ssh/*.pub | sudo tee -a "$MNT/root/.ssh/authorized_keys"
    sudo chown -R root "$MNT/root/.ssh/"

    # flush & umount
    sync
    cleanup
    trap - EXIT
    echo OK
fi
