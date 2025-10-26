#!/usr/bin/env bash

build_uboot() (
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" stm32mp15_basic_defconfig
    DEVICE_TREE=st/stm32mp157c-dk2 make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" -j"$(nproc)" all
)

build_linux() (
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" multi_v7_defconfig
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" -j"$(nproc)"
)

build_linux_dtb() (
    dtc -I dts -O dtb -o "$BUILD_DIR/uart7.dtbo" uart7.dts
)

build_fit() (
    mkimage -f bbb.its "$BUILD_DIR/bbb.itb"
)

build_sllin() (
    make -C "$ROOT_DIR/"linux O="$BUILD_DIR/linux" M="$ROOT_DIR/linux-lin/sllin/" modules
)

write_rootfs() (
    DEVICE="/dev/mmcblk0"
    sudo sgdisk -o "$DEVICE"
    sudo sgdisk --resize-table=128 -a 1 \
    -n 1:34:545 -c 1:fsbl1 \
    -n 2:546:1057 -c 2:fsbl2 \
    -n 3:1058:5153 -c 3:ssbl \
    -n 4:5154: -c 4:rootfs -A 4:set:2 \
    -p "$DEVICE"

    sudo dd if=./u-boot/u-boot-spl.stm32 of="$DEVICE"p1
    sudo dd if=./u-boot/u-boot-spl.stm32 of="$DEVICE"p2
    sudo dd if=./u-boot/u-boot.img of="$DEVICE"p3

    sudo mkfs.ext4 "$DEVICE"p4
    sudo mount "$DEVICE"p4 /mnt
    sudo mkdir /mnt/boot
    sudo cp linux/arch/arm/boot/zImage /mnt/boot
    sudo cp linux/arch/arm/boot/dts/st/stm32mp157c-dk2.dtb /mnt/boot/a.dtb
    sudo cp uart7.dtbo /mnt/boot/uart7.dtbo

    sudo rsync -avzP ./build/rootfs/* /mnt/

    sudo umount /mnt
)
