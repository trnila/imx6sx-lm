# imx6sx-lm board with latest u-boot and linux kernel

Run `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes` if you are not having qemu-user-static.

```shell-session
$ git clone --recurse-submodules --shallow-submodules https://github.com/trnila/imx6sx-lm
$ ./build.sh
```

## boot recovery
1. Load u-boot, kernel and recovery image over USB
   ```sh
   pc$ uuu recovery.uu
   ```
2. Interrupt bootloader and load recovery image
   ```sh
   => bootz 0x80800000 0x83500000 0x83000000
   ```
3. Recovery image exposes /dev/sdX block device, write rootfs with:
   ```sh
   pc$ ./write_rootfs.sh /dev/sdX1`
   ```
4. Power reset the board
