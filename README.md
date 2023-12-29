# imx6sx-lm board with latest u-boot and linux kernel

```shell-session
$ ./build.sh
```

## boot recovery
```shell-session
$ uuu recovery.uu
=> bootz 0x80800000 0x83500000 0x83000000
$ ./write_rootfs.sh /dev/sdb1
```
