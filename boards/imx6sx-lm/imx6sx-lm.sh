#!/usr/bin/env bash
build_uboot() (
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" mx6sxlm_defconfig
    make -C "$ROOT_DIR/u-boot" O="$BUILD_DIR/u-boot" -j"$(nproc)"
)

build_linux() (
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" imx_v6_v7_defconfig
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" -j"$(nproc)"
)

build_linux_dtb() (
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" nxp/imx/imx6sx-lm.dtb
)

build_sllin() (
    make -C "$ROOT_DIR/linux" O="$BUILD_DIR/linux" M="$ROOT_DIR/linux-lin/sllin/" modules
)

build_recovery() (
    RECOVERY_DIR="$BUILD_DIR"/recovery

    sudo rm -rf "$RECOVERY_DIR"
    mkdir -p "$RECOVERY_DIR"
    (
        cd "$RECOVERY_DIR"
        curl https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/armv7/alpine-minirootfs-3.19.0-armv7.tar.gz | tar -xzvf -
        echo nameserver 2606:4700:4700::1111 > etc/resolv.conf
        echo nameserver 1.1.1.1 >> etc/resolv.conf

        cat > init << EOF
#!/bin/sh
mount -t proc proc /proc
mount -t devtmpfs devtmpfs /dev
mount -t sysfs sysfs /sys

(
set -x
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/g1
cd /sys/kernel/config/usb_gadget/g1
echo 0xabcd > idVendor
echo 0x1234 > idProduct
mkdir configs/c.1
mkdir functions/mass_storage.0
echo /dev/mmcblk3 > functions/mass_storage.0/lun.0/file
ln -s functions/mass_storage.0 configs/c.1
echo ci_hdrc.0 > UDC
)

exec /bin/sh
EOF
        chmod a+x init
    )

    (
        sudo chroot "$RECOVERY_DIR" /bin/sh << EOF
export PATH=/bin:/usr/bin:/sbin/:/usr/sbin/
apk add openssh rsync dhclient
rm -rf var/cache/apk
EOF
    )

    RECOVERY_CPIO="$BUILD_DIR/recovery.cpio.gz"
    (
        cd "$RECOVERY_DIR"
        find . | cpio -H newc -ov --owner root:root | gzip > "$RECOVERY_CPIO"
    )
    mkimage -A arm -O linux -T ramdisk -d "$RECOVERY_CPIO" "$BUILD_DIR/recovery.img"
    rm "$RECOVERY_CPIO"
)

write_rootfs() (
    DEV=$1
    if [ -z "$DEV" ]; then
        echo "Usage: $0 /dev/sdX1"
        exit 1
    fi

    set -ex

    TARGET_DIR="$BUILD_DIR/target"
    mkdir -p "$TARGET_DIR"
    sudo umount "$TARGET_DIR" || true
    sudo mount "$DEV" "$TARGET_DIR"
    sudo rsync -av --delete "$BUILD_DIR/rootfs/" "$TARGET_DIR/"

    # configure hostname
    echo imx6-lm | sudo tee "$TARGET_DIR/etc/hostname"

    # setup SSH keys
    sudo mkdir -p "$TARGET_DIR/root/.ssh/"
    sudo cp ~/.ssh/id_rsa.pub "$TARGET_DIR/root/.ssh/authorized_keys"
    sudo chown -R root "$TARGET_DIR/root/.ssh/"

    sudo umount "$TARGET_DIR" || true
)
