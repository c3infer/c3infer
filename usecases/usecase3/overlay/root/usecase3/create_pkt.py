#!/usr/bin/env python3
# create_pkt.py  (OFFLINE VM)

import base64
from scapy.all import Ether, IP, UDP, Raw, raw

# Fully offline-safe: no iface lookups, no ARP, no routing.
# Put placeholders; sender VM can keep or patch them.
pkt = (
    Ether(src="02:00:00:00:00:01", dst="02:00:00:00:00:02") /
    IP(src="198.51.100.2", dst="192.0.2.10") /
    UDP(sport=12345, dport=9999) /
    Raw(b"hello")
)

b = raw(pkt)
b64 = base64.b64encode(b).decode("ascii")

with open("packet.txt", "w", encoding="utf-8") as f:
    f.write(b64 + "\n")

print(f"Wrote packet.txt (base64), {len(b)} raw bytes")
