#!/usr/bin/env bash
rm -rf build
(cd linux && make mrproper)
(cd u-boot && make mrproper)
