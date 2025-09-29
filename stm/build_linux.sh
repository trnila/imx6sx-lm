#!/bin/bash
set -ex
source ./config.sh

make -C u-boot stm32mp15_basic_defconfig
DEVICE_TREE=st/stm32mp157c-dk2 make -C u-boot -j"$(nproc)" all

sudo sgdisk -o /dev/mmcblk0
sudo sgdisk --resize-table=128 -a 1 \
-n 1:34:545         -c 1:fsbl1 \
-n 2:546:1057               -c 2:fsbl2 \
-n 3:1058:5153              -c 3:ssbl \
-n 4:5154:              -c 4:rootfs -A 4:set:2 \
-p /dev/mmcblk0

sudo dd if=./u-boot/u-boot-spl.stm32 of=/dev/mmcblk0p1
sudo dd if=./u-boot/u-boot-spl.stm32 of=/dev/mmcblk0p2
sudo dd if=./u-boot/u-boot.img of=/dev/mmcblk0p3

make -C linux multi_v7_defconfig
make -C linux -j"$(nproc)"

dtc -I dts -O dtb -o uart7.dtbo uart7.dts

sudo mkfs.ext4 /dev/mmcblk0p4
sudo mount /dev/mmcblk0p4 /mnt
sudo mkdir /mnt/boot
sudo cp linux/arch/arm/boot/zImage /mnt/boot
sudo cp linux/arch/arm/boot/dts/st/stm32mp157c-dk2.dtb /mnt/boot/a.dtb
sudo cp uart7.dtbo /mnt/boot/uart7.dtbo

sudo rsync -avzP ./build/rootfs/* /mnt/

sudo umount /mnt

#scp linux/arch/arm/boot/zImage stm:/boot/myimage
#scp linux/arch/arm/boot/dts/st/stm32mp157c-dk2.dtb stm:/boot/my.dtb
#ssh stm sync
#ssh stm reboot -f


exit 0
ext4ls mmc 0:4 /

#ext4load mmc 0:4 $loadaddr /boot/zImage; ext4load mmc 0:4 $fdt_addr_r /boot/a.dtb; setenv bootargs "console=ttySTM0,115200 root=/dev/mmcblk0p4 rw rootwait"; bootz $loadaddr - $fdt_addr_r

0) zapojit micro usb na uart, usb c u sd karty na napajeni
1) napalit sd kartu ./build_rootfs.sh && ./build_linux.sh
2) bootcmd z ubootu:
ext4load mmc 0:4 $loadaddr /boot/zImage; ext4load mmc 0:4 $fdt_addr_r /boot/a.dtb; load mmc 0:4 $fdtoverlay_addr_r /boot/uart7.dtbo; fdt addr $fdt_addr_r; fdt resize; fdt apply $fdtoverlay_addr_r; setenv bootargs "console=ttySTM0,115200 root=/dev/mmcblk0p4 rw rootwait"; bootz $loadaddr - $fdt_addr_r


