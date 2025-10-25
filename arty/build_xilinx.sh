#!/usr/bin/env bash
set -ex

source /tools/petalinux/settings.sh
cd artyz7_linux/


sudo umount /mnt/boot /mnt || true

petalinux-config --get-hw-description ../vivado3/design_2_wrapper.xsa
petalinux-build
petalinux-package --boot --u-boot --fpga --force

DEVICE=/dev/mmcblk0
(
  echo o # create dos partion table
  echo -e "n\np\n1\n\n+500M" # add primary partion 1
  echo -e "t\nc\n" # partition type W95 FAT32 (LBA)
  echo -e "n\np\n2\n\n\n" # add primary partion 2 with rest of space
  echo -e "a\n1\n" # set bootable partition 1
  echo w # save table
) | sudo fdisk "$DEVICE" --noauto-pt --wipe-partitions always
sudo mkfs.vfat ${DEVICE}p1 -n BOOT
sudo mkfs.ext4 ${DEVICE}p2 -L rootfs

sudo mount ${DEVICE}p2 /mnt
sudo mkdir /mnt/boot
sudo mount ${DEVICE}p1 /mnt/boot

sudo cp -r images/linux/{BOOT.BIN,image.ub} /mnt/boot
sudo tar -C /mnt -xf images/linux/rootfs.tar.gz || true


sudo umount /mnt/boot /mnt