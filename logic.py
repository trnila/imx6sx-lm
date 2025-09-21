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

sample_rate = 5_000_000
sample_time_s = 10
#out = subprocess.check_output(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} -P uart:rx=8:baudrate=19200 -A uart=rx-data --protocol-decoder-samplenum"), text=True)

subprocess.check_call(shlex.split(f"sigrok-cli --driver asix-sigma --config samplerate={sample_rate} --samples={sample_time_s * sample_rate} --output-file /tmp/a.sr"), text=True)
out = subprocess.check_output(shlex.split(f"sigrok-cli -i /tmp/a.sr -P uart:rx=8:baudrate=19200 -A uart=rx-data --protocol-decoder-samplenum"), text=True)


diff = []
header_end_ts = 0
regexp = re.compile(r"\d+-(?P<ts>\d+) uart-1: (?P<byte>[0-9A-F]+)")
for line in out.splitlines():
    groups = regexp.match(line).groupdict()
    ts = int(groups['ts'])
    byte = int(groups['byte'], 16)

    if byte == 0x14:
        header_end_ts = ts
    elif byte == 0x11:
        diff.append((ts - header_end_ts) / sample_rate * 1000_000)
        header_end_ts = 0

    #print(ts, hex(byte))

df = pd.DataFrame(diff)
print(df.describe())

fig, axes = plt.subplots(nrows=1, ncols=2)
df.plot(ax=axes[0])
df.plot.box(ax=axes[1], showfliers=False)
plt.show()