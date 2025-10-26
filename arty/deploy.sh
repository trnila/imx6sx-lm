#!/usr/bin/env bash
set -ex

DEVICE=/dev/mmcblk0
sudo mkfs.ext4 -F "$DEVICE"p2 -L rootfs
sudo umount /mnt/boot /mnt || true
sudo mount ${DEVICE}p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount ${DEVICE}p1 /mnt/boot

sudo rsync -avzP ../stm/build/rootfs/* /mnt/
sudo rsync -avzP ./artyz7_linux/build/tmp/work/zynq_generic_7z020-amd-linux-gnueabi/linux-xlnx/6.12.10+git/package/lib/modules /mnt/lib/
cat ~/.ssh/*.pub | sudo tee -a /mnt/root/.ssh/authorized_keys
sudo chmod 0600 /mnt/root/.ssh/authorized_keys
sync
sudo umount /mnt/boot /mnt