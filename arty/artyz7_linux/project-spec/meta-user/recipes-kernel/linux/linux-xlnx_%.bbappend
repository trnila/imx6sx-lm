FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://bsp.cfg"
KERNEL_FEATURES:append = " bsp.cfg"
SRC_URI += "file://user_2025-10-26-09-31-00.cfg \
            file://user_2025-10-26-10-26-00.cfg \
            "

