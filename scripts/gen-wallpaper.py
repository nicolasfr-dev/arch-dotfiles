#!/usr/bin/env python3
"""Gera o wallpaper Tokyo Night (PNG puro, sem dependencias externas).

Uso: gen-wallpaper.py [saida.png] [largura] [altura]
"""
import math
import struct
import sys
import zlib

W = int(sys.argv[2]) if len(sys.argv) > 2 else 1920
H = int(sys.argv[3]) if len(sys.argv) > 3 else 1080
OUT = sys.argv[1] if len(sys.argv) > 1 else "tokyonight.png"

# Tokyo Night
TOP = (0x1A, 0x1B, 0x26)
BOTTOM = (0x10, 0x10, 0x18)
GLOWS = [
    # (cx, cy, raio, cor, intensidade)
    (0.26, 0.30, 0.62, (0x7A, 0xA2, 0xF7), 0.30),   # azul
    (0.78, 0.72, 0.55, (0xBB, 0x9A, 0xF7), 0.22),   # magenta
    (0.60, 0.14, 0.38, (0x7D, 0xCF, 0xFF), 0.12),   # ciano
    (0.10, 0.92, 0.40, (0xFF, 0x9E, 0x64), 0.07),   # laranja
]


def smoothstep(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def build():
    rows = bytearray()
    aspect = W / H
    for y in range(H):
        fy = y / (H - 1)
        # base: gradiente vertical
        br = TOP[0] + (BOTTOM[0] - TOP[0]) * fy
        bg = TOP[1] + (BOTTOM[1] - TOP[1]) * fy
        bb = TOP[2] + (BOTTOM[2] - TOP[2]) * fy

        rows.append(0)  # filtro None
        for x in range(W):
            fx = x / (W - 1)
            r, g, b = br, bg, bb

            # halos radiais suaves
            for cx, cy, rad, (gr, gg, gb), amp in GLOWS:
                dx = (fx - cx) * aspect
                dy = fy - cy
                d = math.sqrt(dx * dx + dy * dy) / rad
                if d < 1.0:
                    w = smoothstep(1.0 - d) ** 2 * amp
                    r += (gr - r) * w
                    g += (gg - g) * w
                    b += (gb - b) * w

            # vinheta
            vx = (fx - 0.5) * 2.0
            vy = (fy - 0.5) * 2.0
            vig = 1.0 - 0.28 * smoothstep(math.sqrt(vx * vx + vy * vy) / 1.45)
            r *= vig
            g *= vig
            b *= vig

            # grao sutil, deterministico (evita banding no gradiente)
            n = ((x * 73856093) ^ (y * 19349663)) & 0xFF
            d = (n / 255.0 - 0.5) * 4.0
            r += d
            g += d
            b += d

            rows.append(max(0, min(255, int(r + 0.5))))
            rows.append(max(0, min(255, int(g + 0.5))))
            rows.append(max(0, min(255, int(b + 0.5))))
    return bytes(rows)


def chunk(tag, data):
    out = struct.pack(">I", len(data)) + tag + data
    return out + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


raw = build()
png = b"\x89PNG\r\n\x1a\n"
png += chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
png += chunk(b"IDAT", zlib.compress(raw, 9))
png += chunk(b"IEND", b"")

with open(OUT, "wb") as f:
    f.write(png)

print(f"{OUT}  {W}x{H}  {len(png) / 1024:.0f} KiB")
