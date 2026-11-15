#!/usr/bin/env python3
"""Value and colour metrics of a 1672x941 capture against the arena reference (docs/art/arena_reference.md,
"Criterios de fidelidade"). Usage: python3 -I art_metrics.py shot.png [more.png]. Needs ffmpeg; no other deps.
Regions are pixel boxes in the showcase framing (--showcase --seed=5, RES=1672x941); the HUD rows (y<60, y>820)
are left out of the global numbers.
Per-region statistics (mean, sd, detail = mean |laplacian| of luminance, saturation, green share, warm halo share) and
the pass/fail lines of the cycle 4 acceptance table (docs/art/cycle4_spec.md, section (e)) follow the palette lines."""
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

STATS = {  # name: x0, y0, x1, y1 (cycle 4 regions, docs/art/cycle4_spec.md (e))
    "facade": (1050, 0, 1672, 330), "facade_right": (1450, 0, 1672, 250), "portal_open": (1270, 110, 1350, 240),
    "statues_portal": (1110, 60, 1220, 240), "east_brazier": (1300, 560, 1500, 720), "floor_clean_a": (1000, 620, 1200, 760),
    "floor_clean_b": (250, 420, 450, 520), "floor_far_r": (1180, 380, 1380, 470), "abyss_left_cols": (0, 180, 260, 420),
    "abyss_left": (0, 100, 260, 700), "abyss_right": (1560, 560, 1672, 900), "obelisk_s": (370, 530, 490, 780),
}
# name: (region, label, predicate on the stats dict); the reference value is in the spec table.
ACCEPT = [
    ("facade", "green <= 0.20", lambda s: s["green"] <= 0.20),
    ("portal_open", "sd >= 35, median L >= 150, G >= R + 120",
     lambda s: s["sd"] >= 35 and s["median_l"] >= 150 and s["median"][1] >= s["median"][0] + 120),
    ("statues_portal", "green <= 0.25", lambda s: s["green"] <= 0.25),
    ("facade", "detail >= 9", lambda s: s["detail"] >= 9),
    ("facade_right", "detail >= 7", lambda s: s["detail"] >= 7),
    ("statues_portal", "detail >= 10", lambda s: s["detail"] >= 10),
    ("east_brazier", "warmhalo <= 0.16", lambda s: s["warm"] <= 0.16),
    ("east_brazier", "detail >= 9", lambda s: s["detail"] >= 9),
    ("floor_clean_a", "detail >= 8.5", lambda s: s["detail"] >= 8.5),
    ("floor_far_r", "sd >= 25", lambda s: s["sd"] >= 25),
    ("abyss_left_cols", "median G >= R + 20 and B >= R + 25",
     lambda s: s["median"][1] >= s["median"][0] + 20 and s["median"][2] >= s["median"][0] + 25),
    ("abyss_left_cols", "detail >= 4.5", lambda s: s["detail"] >= 4.5),
    ("obelisk_s", "detail >= 6.5", lambda s: s["detail"] >= 6.5),
]

def region_stats(d, box):
    """Every second pixel inside the box (one pixel margin for the laplacian)."""
    x0, y0, x1, y1 = box
    L = lambda x, y: lum(*px(d, x, y))
    vals, cols, lap, sat, green, warm = [], [], 0.0, 0.0, 0, 0
    for y in range(y0 + 1, y1 - 1, 2):
        for x in range(x0 + 1, x1 - 1, 2):
            r, g, b = px(d, x, y)
            v = lum(r, g, b)
            vals.append(v)
            cols.append((r, g, b))
            lap += abs(4 * v - L(x - 1, y) - L(x + 1, y) - L(x, y - 1) - L(x, y + 1))
            mx, mn = max(r, g, b), min(r, g, b)
            sat += (mx - mn) / (mx + 1)
            green += g > r + 40 and g > b + 15
            warm += v > 120 and r > g > b and r - b > 60
    n = len(vals)
    m = sum(vals) / n
    cols.sort(key=lambda c: lum(*c))
    med = cols[n // 2]
    return {"mean": m, "sd": (sum((v - m) ** 2 for v in vals) / n) ** .5, "detail": lap / n, "sat": sat / n,
            "green": green / n, "warm": warm / n, "median": med, "median_l": lum(*med)}

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
    print("  global luminance p1 p5 p25 p50 p75 p95 p99:", [round(allv[int(q * (n - 1))], 1) for q in (.01, .05, .25, .5, .75, .95, .99)])
    print("  share < 20: %.2f   share > 150: %.3f" % (sum(v < 20 for v in allv) / n, sum(v > 150 for v in allv) / n))
    for name, (x0, y0, x1, y1) in REGIONS.items():
        cs = sorted((px(d, x, y) for y in range(y0, y1, 2) for x in range(x0, x1, 2)), key=lambda c: lum(*c))
        k = max(1, len(cs) // 10)
        mean = lambda s: [sum(c[i] for c in s) / len(s) for i in range(3)]
        print("  %-20s dark10 %s  median %s  bright10 %s" % (name, hexc(mean(cs[:k])), hexc(cs[len(cs) // 2]), hexc(mean(cs[-k:]))))
    q = {p: allv[int(p / 100 * (n - 1))] for p in (1, 5, 50, 95, 99)}
    share = {"dark": sum(v < 20 for v in allv) / n}
    for name, ((x0, y0, x1, y1), pred) in TESTS.items():
        tot = (x1 - x0) * (y1 - y0)
        hit = sum(1 for y in range(y0, y1) for x in range(x0, x1) if pred(*px(d, x, y)))
        share[name] = hit / tot
        print("  %-20s %.3f" % (name, hit / tot))
    glob = [  # cycle 3 global acceptance (docs/art/arena_reference.md, "Medidas globais")
        ("p1 4 to 10", 4 <= q[1] <= 10), ("p5 10 to 16", 10 <= q[5] <= 16), ("p50 42 to 50", 42 <= q[50] <= 50),
        ("p95 >= 105", q[95] >= 105), ("p99 >= 170", q[99] >= 170), ("share < 20 in 0.09 to 0.17", .09 <= share["dark"] <= .17),
        ("floor_blue_dominant 0.40 to 0.65", .40 <= share["floor_blue_dominant"] <= .65),
        ("warm_hot_px >= 0.007", share["warm_hot_px"] >= .007),
        ("violet_left >= 0.06", share["violet_left"] >= .06), ("violet_right >= 0.03", share["violet_right"] >= .03),
        ("green_spill_floor >= 0.08", share["green_spill_floor"] >= .08),
    ]
    for label, ok in glob:
        print("  %s global %s" % ("PASS" if ok else "FAIL", label))
    print("  cycle 3 global criteria: %d/%d pass" % (sum(ok for _, ok in glob), len(glob)))
    st = {name: region_stats(d, box) for name, box in STATS.items()}
    for name, v in st.items():
        print("  %-16s mean %5.1f sd %5.1f detail %5.2f sat %.2f green %.3f warmhalo %.3f median %s" % (
            name, v["mean"], v["sd"], v["detail"], v["sat"], v["green"], v["warm"], hexc(v["median"])))
    passed = 0
    for name, label, test in ACCEPT:
        ok = test(st[name])
        passed += ok
        print("  %s %-16s %s" % ("PASS" if ok else "FAIL", name, label))
    print("  cycle 4 region criteria: %d/%d pass (hero gold and skeleton contrast are measured by hand)" % (passed, len(ACCEPT)))
