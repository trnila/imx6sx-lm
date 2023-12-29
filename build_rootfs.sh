#!/bin/bash
set -ex
source ./config.sh

ROOTFS_DIR="$BUILD_DIR/rootfs"
ROOTFS_TARBALL="$BUILD_DIR/ArchLinuxARM-armv7-latest.tar.gz"
ROOTFS_IMG="$BUILD_DIR/rootfs.img"
PACMAN_CACHE_DIR="$BUILD_DIR/pacman_cache"

on_exit() {
    mount | grep "$ROOT_DIR" | cut -d' ' -f 3 | xargs sudo umount || true
}

if [ ! -f "$ROOTFS_TARBALL" ]; then
    wget http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz -O "$ROOTFS_TARBALL"
fi

on_exit
trap on_exit EXIT

sudo rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"
sudo bsdtar -xpf "$ROOTFS_TARBALL" -C "$ROOTFS_DIR"

mkdir -p "$PACMAN_CACHE_DIR"
sudo mount --bind "$PACMAN_CACHE_DIR" "$ROOTFS_DIR/var/cache/pacman/pkg/"

sudo mount --bind /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"
sudo mount -t proc proc "$ROOTFS_DIR/proc"
sudo mount -t sysfs sys "$ROOTFS_DIR/sys"
sudo mount -t devtmpfs dev "$ROOTFS_DIR/dev"
sudo mount -t devpts devpts "$ROOTFS_DIR/dev/pts"
sudo mount -t tmpfs tmpfs "$ROOTFS_DIR/tmp"
sudo chroot "$ROOTFS_DIR" /bin/sh << 'EOF'
    set -ex
    echo ttymxc5 >> /etc/securetty
    sed -i 's/#\s*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen

    sed -i 's/CheckSpace/#CheckSpace/' /etc/pacman.conf
    pacman-key --init
    pacman-key --populate archlinuxarm
    for pkg in linux-armv7 mkinitcpio mkinitcpio-busybox linux-firmware-whence linux-firmware; do
        pacman -Rns --noconfirm "$pkg" || true
    done
    pacman -Syu --noconfirm
    pacman -S --noconfirm base-devel htop tmux vim strace git gdb python wget cmake ninja
    (
        cd /tmp
        wget https://aur.archlinux.org/cgit/aur.git/snapshot/can-utils.tar.gz
        tar -xf can-utils.tar.gz
        cd can-utils
        chown nobody -R .
        sudo -u nobody makepkg
        pacman -U --noconfirm *.pkg.*
    )

    userdel -r alarm
    sed -Ei 's/\s*#\s*PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
    sed -Ei 's/\s*#\s*PasswordAuthentication (yes|no)/PasswordAuthentication no/' /etc/ssh/sshd_config

    cat > /etc/systemd/network/can.network << FILE
[Match]
Name=can0

[CAN]
BitRate=500000
RestartSec=1
FILE

    mkdir -p /etc/systemd/system/serial-getty@ttymxc5.service.d/
    cat > /etc/systemd/system/serial-getty@ttymxc5.service.d/autologin.conf << 'FILE'
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin root %I $TERM
FILE
EOF

# setup SSH keys
sudo mkdir -p "$ROOTFS_DIR/root/.ssh/"
sudo cp ~/.ssh/id_rsa.pub "$ROOTFS_DIR/root/.ssh/authorized_keys"
sudo chown -R root "$ROOTFS_DIR/root/.ssh/"
