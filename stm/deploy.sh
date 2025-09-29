scp linux/arch/arm/boot/zImage stm:/boot/myimage
ssh stm sync
ssh stm reboot -f
