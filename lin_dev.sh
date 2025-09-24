#!/bin/bash
set -ex
source ./config.sh

make -C linux M="$(pwd)/linux-lin/sllin/" modules
scp linux-lin/sllin/sllin.ko "${TARGET_HOST}":

ssh "${TARGET_HOST}" 'sh -c "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"'
ssh "${TARGET_HOST}" killall ldattach || true
ssh "${TARGET_HOST}" rmmod sllin || true
ssh "${TARGET_HOST}" insmod ./sllin.ko -- "$1"
ssh "${TARGET_HOST}" ldattach 28 /dev/ttymxc0
ssh "${TARGET_HOST}" ip link set sllin0 up
