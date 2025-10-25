#!/usr/bin/env bash
set -ex
source config.sh

dtc -I dts my.dts -@ -O dtb > my.dtbo
sudo mkimage -f boot.its boot.itb


#sudo umount /mnt /mnt/boot || true
#sudo mount /dev/mmcblk0p1 /mnt
#sudo cp boot.itb /mnt/
#sudo umount /mnt

ssh root@192.168.1.137 mount /dev/mmcblk0p1 /boot
scp boot.itb root@192.168.1.137:/boot
ssh root@192.168.1.137 sync
ssh root@192.168.1.137 reboot -f