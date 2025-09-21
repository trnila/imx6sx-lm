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
import matplotlib.pyplot as plt
import time
import pandas as pd

def ssh(cmd):
    print(cmd)
    print(["ssh", "imx6"] + shlex.split(cmd))
    subprocess.check_call(["ssh", "imx6"] + shlex.split(cmd))


first, second = "imx_uart_int", "sllin_receive_buf"
first, second = "sllin_receive_buf", "sllin_send_tx_buff"
#first, second = "imx_uart_int", "sllin_send_tx_buff"


if 1:
    ssh("echo 0 > /sys/kernel/debug/tracing/tracing_on")
    ssh("echo function > /sys/kernel/debug/tracing/current_tracer")
    ssh(f"echo {first} {second} > /sys/kernel/debug/tracing/set_ftrace_filter")
    ssh("bash -c '\"echo 1 > /sys/kernel/debug/tracing/tracing_on; sleep 10; echo 0 > /sys/kernel/debug/tracing/tracing_on\"'")


diff = []
last_irq = 0
try:
    with subprocess.Popen(["ssh", "imx6", "cat", "/sys/kernel/debug/tracing/trace"], stdout=subprocess.PIPE, text=True) as proc:
        for line in proc.stdout:
            if line[0] == '#':
                continue
            print(line.rstrip())

            parts = line.rstrip().split()
            time = float(parts[3][:-1])
            fn = parts[4]

            if fn == first:
                last_irq = time
            elif fn == second and last_irq != 0:
                diff.append((time - last_irq) * 1000 * 1000)
except KeyboardInterrupt:
    pass

df = pd.DataFrame(diff)
print(df.describe())

fig, axes = plt.subplots(nrows=1, ncols=2)
df.plot(ax=axes[0])
df.plot.box(ax=axes[1], showfliers=False)
plt.show()