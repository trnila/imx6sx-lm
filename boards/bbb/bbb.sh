#!/usr/bin/env bash

build_uboot() (
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" am335x_evm_config
    # shellcheck disable=SC2016
    (cd "$BUILD_DIR/u-boot" && "$ROOT_DIR/u-boot/scripts/config" --set-val CONFIG_BOOTCOMMAND '"fatload mmc 0:1 ${loadaddr} bbb.itb; bootm ${loadaddr}"')
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" -j"$(nproc)" all
)

build_linux() (
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" multi_v7_defconfig
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" -j"$(nproc)"
)

build_linux_dtb() (
    dtc -I dts bbb.dts -@ -O dtb -o "$BUILD_DIR/bbb.dtbo"
)

build_fit() (
    mkimage -f bbb.its "$BUILD_DIR/bbb.itb"
)

build_sllin() (
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" M="$ROOT_DIR/linux-lin/sllin/" modules
)

rootfs_partition() (
    (
        echo o # create dos partion table
        echo -e "n\np\n1\n\n+500M" # add primary partion 1
        echo -e "t\nc\n" # partition type W95 FAT32 (LBA)
        echo -e "n\np\n2\n\n\n" # add primary partion 2 with rest of space
        echo -e "a\n1\n" # set bootable partition 1
        echo w # save table
    ) | sudo fdisk "$SDCARD" --noauto-pt --wipe-partitions always
    sudo mkfs.vfat -F "$(partition "$SDCARD" 1)" -n BOOT
    sudo mkfs.ext4 -F "$(partition "$SDCARD" 2)" -L rootfs
)

rootfs_mount() (
    sudo mount "$(partition "$SDCARD" 2)" "$MNT"
    sudo mkdir -p "/$MNT/boot"
    sudo mount "$(partition "$SDCARD" 1)" "$MNT/boot"
)

rootfs_write() (
    sudo cp "$BUILD_DIR/u-boot/MLO" "$MNT/boot"
    sudo cp "$BUILD_DIR/u-boot/u-boot.img" "$MNT/boot"
    sudo cp "$BUILD_DIR/bbb.itb" "$MNT/boot"

    sudo rsync -avzP "$ROOTFS_DIR/" "$MNT"
    sudo make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" modules_install INSTALL_MOD_PATH="$MNT"
)
