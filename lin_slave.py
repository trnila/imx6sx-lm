#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "plin-linux",
# ]
# ///
from plin.device import PLIN
from plin.structs import PLINMessage
from plin.enums import (
    PLINMode,
    PLINMessageType,
    PLINFrameDirection,
    PLINFrameChecksumType,
)
import os

plin = PLIN(interface="/dev/plin0")
plin.start(mode=PLINMode.SLAVE, baudrate=19200)
plin.set_id_filter(bytearray([0xFF] * 8))

data = [0x11]
plin.set_frame_entry(
    0x12,
    PLINFrameDirection.PUBLISHER,
    PLINFrameChecksumType.ENHANCED,
    data=data,
    len=len(data),
)

while True:
    try:
        frame = os.read(plin.fd, PLINMessage.buffer_length)
        frame = PLINMessage.from_buffer_copy(frame)
        if frame.type == PLINMessageType.FRAME:
            print(f"{frame.id:02x}: {bytearray(frame.data[: frame.len]).hex(' ')}")
        elif frame.type == PLINMessageType.SLEEP:
            print("Sleep")
        else:
            print(frame)
    except ValueError as e:
        print(e)
