#!/usr/bin/env python3
"""Keep only the base block + first extension (CTA-861) of an EDID.

Usage: trim-edid.py IN OUT
Drops all extension blocks after the first (on the PG42UQ: the DisplayID
block carrying 3840x1080/1600, 3440x1440 and one 4K@120 timing), fixes the
extension count (byte 126) and the base-block checksum (byte 127).
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
d = open(src, "rb").read()

def fail(msg):
    sys.exit(f"trim-edid: {msg}")

if len(d) == 0 or len(d) % 128:
    fail(f"bad size {len(d)}")
if d[:8] != bytes.fromhex("00ffffffffffff00"):
    fail("bad header")
if d[126] != len(d) // 128 - 1:
    fail(f"extension count {d[126]} does not match size {len(d)}")
for i in range(0, len(d), 128):
    if sum(d[i:i + 128]) % 256:
        fail(f"bad checksum in block {i // 128}")
if d[126] < 1 or d[128] != 0x02:
    fail("first extension is not a CTA-861 block")

t = bytearray(d[:256])
t[126] = 1
t[127] = (-sum(t[:127])) % 256
open(dst, "wb").write(t)
