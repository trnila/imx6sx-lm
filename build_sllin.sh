#!/bin/bash
set -ex
source ./config.sh

make -C linux M=$(pwd)/linux-lin/sllin/ modules
