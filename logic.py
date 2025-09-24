#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "matplotlib",
#     "pandas",
# ]
# ///
import subprocess
import shlex
import re
import pandas as pd
import matplotlib.pyplot as plt
from enum import Enum

class State(Enum):
    UNKNOWN = 0
    PID = 0
    PID_STOP = 1
    DATA_START = 2
    DATA = 3

sample_rate = 5_000_000
sample_time_s = 10
#out = subprocess.check_output(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} -P uart:rx=8:baudrate=19200 -A uart=rx-data --protocol-decoder-samplenum"), text=True)

subprocess.check_call(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} --output-file /tmp/a.sr"), text=True)
out = subprocess.check_output(shlex.split(f"sigrok-cli -i /tmp/a.sr -P uart:rx=6:baudrate=19200 -A uart=rx-data:rx-start:rx-stop --protocol-decoder-samplenum"), text=True)

diff = []
header_end_ts = 0
regexp = re.compile(r"(?P<ts_start>\d+)+-(?P<ts_end>\d+) (?P<decoder>[^:]+): (?P<content>.+)")

state = State.UNKNOWN
START_BIT = 'Start bit'
STOP_BIT = 'Stop bit'
history = []
for line in out.splitlines():
    groups = regexp.match(line).groupdict()
    ts_start = int(groups['ts_start'])
    ts_end = int(groups['ts_end'])
    content = groups['content']

    history.append((content, ts_start, ts_end))

    # [00 55 14] [11 22 B8]
    #[('14', 49204701, 49206785), ('Stop bit', 49206784, 49207045), ('Start bit', 49207546, 49207807), ('11', 49207807, 49209891)]
    match history[-4:]:
        case [('14', _, start), ("Stop bit", _, _), ("Start bit", end, _), ('11', _, _)]:
            diff.append((end - start) / sample_rate * 1000_000)


    continue

    if content == 'Start bit':
        pass
    elif content == 'Stop bit':
        pass
    else:
        byte = int(groups['byte'], 16)


    
    #if content == 'Start bit':


    byte = int(groups['byte'], 16)

    # [00 55 14] [11 22 B8]
    if byte == 0x14:
        header_end_ts = ts_end
    elif byte == 0x11:
        diff.append((ts_start - header_end_ts) / sample_rate * 1000_000)
        header_end_ts = 0

    #print(ts, hex(byte))

df = pd.DataFrame(diff)
print(df.describe())

#fig, axes = plt.subplots(nrows=1, ncols=2)

df.plot(marker='.', linestyle='none', legend=False, figsize=(8, 4))
#df.plot.box(ax=axes[1])
plt.title("Latency between LIN header and response on imx6sx\nwith rx-trigger\ncpuidle.off=1 and performance governor")
plt.ylabel("Time (us)")
plt.xlabel("LIN frame")
plt.ylim(bottom=0)

plt.show()