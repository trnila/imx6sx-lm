#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "matplotlib",
#     "pandas",
#     "pyserial",
# ]
# ///
import subprocess
import shlex
import re
import pandas as pd
import matplotlib.pyplot as plt
import threading
import serial
import time

sample_rate = 5_000_000
sample_time_s = 10
#out = subprocess.check_output(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} -P uart:rx=8:baudrate=19200 -A uart=rx-data --protocol-decoder-samplenum"), text=True)


def writer(stop_event: threading.Event):
    with serial.Serial("/dev/ttyUSB1", baudrate=115200) as ser:
        while not stop_event.is_set():
            ser.write(b"a")
            time.sleep(0.1)

stop_event = threading.Event()
t = threading.Thread(target=writer, args=(stop_event,))
t.start()

subprocess.check_call(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} --output-file /tmp/a.sr"), text=True)
out = subprocess.check_output(f"sigrok-cli -i /tmp/a.sr -P uart:rx=6:baudrate=115200 -A uart=rx-data,counter -P counter:data=5:data_edge=rising --protocol-decoder-samplenum | sort", text=True, shell=True)


diff = []
trigger_sample = 0
regexp = re.compile(r"(?P<ts_start>\d+)+-(?P<ts_end>\d+) (?P<decoder>[^:]+): (?P<byte>[0-9A-F]+)")
for line in out.splitlines():
    print(line)
    groups = regexp.match(line).groupdict()
    ts_start = int(groups['ts_start'])
    ts_end = int(groups['ts_end'])
    byte = int(groups['byte'], 16)
    decoder = groups['decoder']

    if decoder == 'uart-1':
        trigger_sample = ts_end
    elif decoder == 'counter-1' and trigger_sample:
        diff.append((ts_start - trigger_sample) / sample_rate * 1000_000)
        trigger_sample = 0

    #print(ts, hex(byte))

stop_event.set()

df = pd.DataFrame(diff)
print(df.describe())

fig, axes = plt.subplots(nrows=1, ncols=2)
df.plot(ax=axes[0], marker='.', linestyle='None')
df.plot.box(ax=axes[1], showfliers=False)
plt.show()