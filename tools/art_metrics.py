#!/usr/bin/env python3
"""Value and colour metrics of a 1672x941 capture against the arena reference (docs/art/arena_reference.md,
"Criterios de fidelidade"). Usage: python3 -I art_metrics.py shot.png [more.png]. Needs ffmpeg; no other deps.
Regions are pixel boxes in the showcase framing (--showcase --seed=5, RES=1672x941); the HUD rows (y<60, y>820)
are left out of the global numbers."""
import subprocess, sys
W, H = 1672, 941

def load(path):
    return subprocess.run(["ffmpeg", "-loglevel", "error", "-i", path, "-vf", f"scale={W}:{H}", "-f", "rawvideo",
                           "-pix_fmt", "rgb24", "-"], capture_output=True, check=True).stdout

def lum(r, g, b):
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

REGIONS = {  # name: x0, y0, x1, y1
    "abyss_top_teal": (480, 0, 760, 120), "abyss_left_cols": (0, 180, 260, 420), "abyss_left_purple": (0, 420, 200, 640),
    "cliff_bottom_left": (0, 720, 380, 830), "floor_center": (560, 520, 1000, 760), "floor_far_mid": (700, 230, 1000, 330),
    "floor_green": (1150, 330, 1420, 430), "floor_warm_brazier": (1150, 560, 1380, 700), "portal_open": (1270, 110, 1350, 240),
    "stairs": (1060, 240, 1320, 300), "banner_l": (1040, 10, 1090, 140), "statue_nw": (300, 20, 400, 220),
    "obelisk_s": (370, 530, 490, 780), "balustrade_w": (230, 280, 450, 470), "candles_w": (410, 330, 470, 380),
    "chains": (380, 0, 700, 120),
}
TESTS = {  # name: box, pixel predicate
    "green_spill_floor": ((1150, 300, 1450, 450), lambda r, g, b: g > r + 40 and g > b + 15 and lum(r, g, b) > 70),
    "warm_hot_px": ((0, 60, 1672, 820), lambda r, g, b: lum(r, g, b) > 170 and r >= g >= b and r - b > 60),
    "violet_left": ((0, 300, 260, 700), lambda r, g, b: b > r + 20 and r > g + 15 and lum(r, g, b) > 45 and b > 120),
    "violet_right": ((1540, 550, 1672, 830), lambda r, g, b: b > r + 20 and r > g + 15 and lum(r, g, b) > 45 and b > 120),
    "floor_blue_dominant": ((500, 350, 1300, 650), lambda r, g, b: b > r + 15),
}

def px(d, x, y):
    i = (y * W + x) * 3
    return d[i], d[i + 1], d[i + 2]

def hexc(c):
    return "#%02x%02x%02x" % tuple(int(v) for v in c)

for path in sys.argv[1:]:
    d = load(path)
    print(path)
    allv = sorted(lum(*px(d, x, y)) for y in range(60, 820, 4) for x in range(0, W, 4))
    n = len(allv)
    print("  global luminance p1 p5 p25 p50 p75 p95 p99:", [round(allv[int(q * (n - 1))]) for q in (.01, .05, .25, .5, .75, .95, .99)])
    print("  share < 20: %.2f   share > 150: %.3f" % (sum(v < 20 for v in allv) / n, sum(v > 150 for v in allv) / n))
    for name, (x0, y0, x1, y1) in REGIONS.items():
        cs = sorted((px(d, x, y) for y in range(y0, y1, 2) for x in range(x0, x1, 2)), key=lambda c: lum(*c))
        k = max(1, len(cs) // 10)
        mean = lambda s: [sum(c[i] for c in s) / len(s) for i in range(3)]
        print("  %-20s dark10 %s  median %s  bright10 %s" % (name, hexc(mean(cs[:k])), hexc(cs[len(cs) // 2]), hexc(mean(cs[-k:]))))
    for name, ((x0, y0, x1, y1), pred) in TESTS.items():
        tot = (x1 - x0) * (y1 - y0)
        hit = sum(1 for y in range(y0, y1) for x in range(x0, x1) if pred(*px(d, x, y)))
        print("  %-20s %.3f" % (name, hit / tot))
