#!/usr/bin/env bash

build_uboot() (
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" stm32mp15_basic_defconfig
    # shellcheck disable=SC2016
    (cd "$BUILD_DIR/u-boot" && "$ROOT_DIR/u-boot/scripts/config" --set-val CONFIG_BOOTCOMMAND '"ext4load mmc 0:4 0xc4400000 /boot/stm32mp1.itb; bootm 0xc4400000"')
    DEVICE_TREE=st/stm32mp157c-dk2 make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" -j"$(nproc)" all
)

build_linux() (
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" multi_v7_defconfig
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" -j"$(nproc)"
)

build_linux_dtb() (
    dtc -I dts -O dtb -o "$BUILD_DIR/overlay.dtbo" overlay.dts
)

build_fit() (
    mkimage -f stm32mp1.its "$BUILD_DIR/stm32mp1.itb"
)

build_sllin() (
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" M="$ROOT_DIR/linux-lin/sllin/" modules
)

rootfs_partition() (
    sudo sgdisk -g -o "$SDCARD"
    sudo sgdisk --resize-table=128 -a 1 \
    -n 1:34:545 -c 1:fsbl1 \
    -n 2:546:1057 -c 2:fsbl2 \
    -n 3:1058:5153 -c 3:ssbl \
    -n 4:5154: -c 4:rootfs -A 4:set:2 \
    -p "$SDCARD"

    sudo mkfs.ext4 -F "$(partition "$SDCARD" 4)"
)

rootfs_mount() (
    sudo mount "$(partition "$SDCARD" 4)" "$MNT"
)

rootfs_write() (
    sudo dd if="$BUILD_DIR/u-boot/u-boot-spl.stm32" of="$(partition "$SDCARD" 1)"
    sudo dd if="$BUILD_DIR/u-boot/u-boot-spl.stm32" of="$(partition "$SDCARD" 2)"
    sudo dd if="$BUILD_DIR/u-boot/u-boot.img" of="$(partition "$SDCARD" 3)"

    sudo mkdir "$MNT/boot"
    sudo cp "$BUILD_DIR/stm32mp1.itb" "$MNT/boot"
    sudo rsync -avzP "$ROOTFS_DIR/" "$MNT/"
)
