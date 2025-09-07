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
    PLINFrameFlag,
    PLINFrameErrorFlag,
)
import os

SCHEDULER_SLOT = 0

plin = PLIN(interface="/dev/plin0")
plin.start(mode=PLINMode.MASTER, baudrate=19200)
plin.set_id_filter(bytearray([0xFF] * 8))

frame_id = 0x14
plin.set_frame_entry(
    frame_id,
    PLINFrameDirection.SUBSCRIBER_AUTO_LEN,
    PLINFrameChecksumType.ENHANCED,
    PLINFrameFlag.NONE,
)
plin.add_unconditional_schedule_slot(SCHEDULER_SLOT, 100, frame_id)
plin.start_schedule(SCHEDULER_SLOT)

while True:
    try:
        frame = os.read(plin.fd, PLINMessage.buffer_length)
        frame = PLINMessage.from_buffer_copy(frame)
        # print(frame)
        if frame.type == PLINMessageType.FRAME:
            flags = [
                flag.name
                for flag in PLINFrameErrorFlag
                if flag in PLINFrameErrorFlag(frame.flags)
            ]
            print(
                f"{frame.id:02x}: {bytearray(frame.data[: frame.len]).hex(' ')} {','.join(flags)}"
            )
        elif frame.type == PLINMessageType.SLEEP:
            print("Sleep")
        else:
            print(frame)
    except ValueError as e:
        print(e)
