#!/bin/bash
set -ex
source ./config.sh

make -C linux nxp/imx/imx6sx-lm.dtb
