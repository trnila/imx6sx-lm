#!/usr/bin/env bash
set -ex

DEVICE=/dev/mmcblk0
sudo mkfs.ext4 "$DEVICE"p2 -L rootfs
sudo umount /mnt/boot /mnt || true
sudo mount ${DEVICE}p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount ${DEVICE}p1 /mnt/boot

sudo rsync -avzP ../stm/build/rootfs/* /mnt/
cat ~/.ssh/*.pub | sudo tee -a /mnt/root/.ssh/authorized_keys
sudo chmod 0600 /mnt/root/.ssh/authorized_keys
sync
sudo umount /mnt/boot /mnt