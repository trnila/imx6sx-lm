#!/usr/bin/env bash

build_uboot() (
    echo Not implemented
)

build_linux() (
    source /tools/petalinux/settings.sh
    cd artyz7_linux
    petalinux-config --get-hw-description ../vivado3/design_2_wrapper.xsa --silentconfig
    petalinux-build
    petalinux-package --boot --u-boot --fpga --force
)

build_linux_dtb() (
    echo Not implemented
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
    sudo mkfs.vfat "$(partition "$SDCARD" 1)" -n BOOT
    sudo mkfs.ext4 "$(partition "$SDCARD" 2)" -L rootfs

)

write_rootfs() (
    sudo mount "$(partition "$SDCARD" 2)" "$MNT"
    sudo mkdir -p "$MNT/boot"
    sudo mount "$(partition "$SDCARD" 1)" "$MNT/boot"

    sudo cp -r artyz7_linux/images/linux/{BOOT.BIN,image.ub} "$MNT/boot"
    sudo tar -C "$MNT" -xf artyz7_linux/images/linux/rootfs.tar.gz || true
)
