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
sudo parted $DEVICE mklabel msdos
sudo parted -a optimal $DEVICE mkpart primary fat32 1MiB 100MiB
sudo parted -a optimal $DEVICE mkpart primary ext4 100MiB 100%
sudo mkfs.vfat ${DEVICE}p1 -n BOOT
sudo mkfs.ext4 ${DEVICE}p2 -L rootfs

sudo mount ${DEVICE}p2 /mnt
sudo mkdir /mnt/boot
sudo mount ${DEVICE}p1 /mnt/boot

sudo dd if=./u-boot/MLO of=${DEVICE}
sudo dd if=./u-boot/u-boot.img of=${DEVICE} bs=512 seek=768
sudo cp ./linux/arch/arm/boot/zImage /mnt/boot
sync
#sudo cp ./u-boot/MLO /mnt/boot
#sudo cp ./u-boot/u-boot.img /mnt/boot/u-boot.img


#sudo umount /mnt/boot /mnt
