set -ex

source ./config.sh
make -C u-boot am335x_evm_config
make -C u-boot -j"$(nproc)" all

#make -C linux multi_v7_defconfig
#make -C linux -j"$(nproc)"

#sudo rsync -avzP ./build/rootfs/* /mnt/


# u-boot/u-boot-dtb.img
# ./linux/arch/arm/boot/dts/ti/omap/am335x-boneblack-wireless.dtb # mozna prihodit i do u-bootu



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

#sudo dd if=./u-boot/MLO of=${DEVICE}
#sudo dd if=./u-boot/u-boot.img of=${DEVICE} bs=512 seek=768

sudo cp ./u-boot/MLO /mnt/boot
sudo cp ./u-boot/u-boot.img /mnt/boot/

sudo cp ./linux/arch/arm/boot/zImage /mnt/boot
sudo cp ./linux/arch/arm/boot/dts/ti/omap/am335x-boneblack-wireless.dtb /mnt/boot
sudo rsync -avzP ../stm/build/rootfs/* /mnt/
sync

sudo umount /mnt/boot /mnt


# fatload mmc 0:1 ${loadaddr} zImage
# fatload mmc 0:1 ${fdtaddr} am335x-boneblack-wireless.dtb
# setenv bootargs 'console=ttyS0,115200n8 root=/dev/mmcblk0p2 rw rootwait'
# bootz ${loadaddr} - ${fdtaddr}
