#!/usr/bin/env python3
"""Value, saturation and hue of captures (cycle C18 acceptance, art report 2026-11-18; room redesign RS-0.5).
Default table: the image is scaled to 640 px wide and measured by ffmpeg's signalstats (YAVG luma mean, SATAVG
saturation mean, SATHIGH its 90th percentile, the numbers of the art report's table); also the share of the frame that is
violet (hue 250 to 320 degrees) with HSV saturation above 60% (the "no violet area above 60% bigger than 5% of the
screen" rule), and, with --box=x,y,w,h in the full image's pixels, the same for a box (the hero's: green-cyan share,
hue 130 to 200, and pink share, magenta to rose, hue 300 to 345, red left out).
  python3 -I tools/frame_stats.py a.jpg b.jpg [--box=x,y,w,h]

--hue adds a second table, per pixel in HSV (dark pixels count, as in the redesign matrix), for the whole frame
(scaled to 640), for --scene (the frame without the HUD: x 5 to 95%, y 8 to 85%, full resolution) and for every
--box (repeatable; with --hue each box gets its own row):
  hue      mean hue, circular, weighted by HSV saturation (the matrix's "matiz")
  h10/50/90 hue percentiles of the pixels with saturation above --sat-min (default 0.1), taken around the mean so
           they never wrap at 0/360 (a range like 350/5/20 reads as it is)
  sat50    HSV saturation p50 (the matrix's "sat HSV p50")
  y10/50/90 luma percentiles, Rec.601 on 0..255 (the "luma p50" and the "p90 minus p10" rules)
  bands, % of the region's pixels:
    warm   hue below 50 or from 340, sat > 0.35, value > 0.35 (the lot A "parte quente da cena")
    red    hue below 15 or from 345, sat > 0.35, value > 0.3 (inside warm)
    green  hue 90 to 160, sat > 0.35, value > 0.3
    cyan   hue 160 to 200, sat > 0.35, value > 0.3
    g+c    hue 130 to 200, sat > 0.45, value > 0.3 (the hero box rule "green and cyan up to 2%", as the default table)
    violet hue 250 to 320, sat > 0.6, value > 0.15 (as the default table)
  python3 -I tools/frame_stats.py a.jpg --hue --scene --box=1152,432,192,162 --box=0,324,96,324 [--sat-min=0.1]
Only the standard library and ffmpeg (no PIL)."""
import colorsys
import math
import subprocess
import sys


def stats(path):
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-vf",
                          "scale=640:-1:out_range=tv,format=yuv420p,signalstats,metadata=print:file=-", "-f", "null", "-"],
                         capture_output=True, text=True).stdout
    vals = {}
    for line in out.splitlines():
        if "=" in line and "lavfi.signalstats." in line:
            k, v = line.split("lavfi.signalstats.")[1].split("=")
            vals[k] = float(v)
    return vals


def size(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height",
                          "-of", "csv=p=0", path], capture_output=True, text=True).stdout
    w, h = out.strip().split(",")[:2]
    return int(w), int(h)


def pixels(path, crop=None):
    vf = "scale=640:-1"
    if crop:
        x, y, w, h = crop
        vf = "crop=%d:%d:%d:%d" % (w, h, x, y)
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-vf", vf, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
                         capture_output=True).stdout
    return [raw[i:i + 3] for i in range(0, len(raw), 3)]


def shares(px):
    n = max(len(px), 1)
    violet = green = pink = 0
    for p in px:
        h, s, v = colorsys.rgb_to_hsv(p[0] / 255, p[1] / 255, p[2] / 255)
        h *= 360
        if s > 0.6 and v > 0.15 and 250 <= h <= 320:
            violet += 1
        if s > 0.45 and v > 0.3 and 130 <= h <= 200:
            green += 1
        if s > 0.35 and v > 0.3 and 300 <= h <= 345:
            pink += 1
    return 100.0 * violet / n, 100.0 * green / n, 100.0 * pink / n


BANDS = ("warm", "red", "green", "cyan", "g+c", "violet")


def bands_of(h, s, v):
    out = []
    if s > 0.35 and v > 0.35 and (h < 50 or h >= 340):
        out.append("warm")
    if s > 0.35 and v > 0.3:
        if h < 15 or h >= 345:
            out.append("red")
        elif 90 <= h < 160:
            out.append("green")
        elif 160 <= h < 200:
            out.append("cyan")
    if s > 0.45 and v > 0.3 and 130 <= h <= 200:
        out.append("g+c")
    if s > 0.6 and v > 0.15 and 250 <= h <= 320:
        out.append("violet")
    return out


def pct(sorted_vals, q):
    if not sorted_vals:
        return float("nan")
    i = min(len(sorted_vals) - 1, max(0, int(round(q * (len(sorted_vals) - 1)))))
    return sorted_vals[i]


def hue_stats(px, sat_min):
    n = max(len(px), 1)
    cx = cy = 0.0
    hs = []
    sats = []
    lumas = []
    count = dict.fromkeys(BANDS, 0)
    for p in px:
        r, g, b = p[0], p[1], p[2]
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        h *= 360
        a = math.radians(h)
        cx += s * math.cos(a)
        cy += s * math.sin(a)
        sats.append(s)
        lumas.append(0.299 * r + 0.587 * g + 0.114 * b)
        if s > sat_min:
            hs.append(h)
        for k in bands_of(h, s, v):
            count[k] += 1
    mean = math.degrees(math.atan2(cy, cx)) % 360 if (cx or cy) else float("nan")
    centre = mean if mean == mean else 0.0
    rel = sorted(((h - centre + 180) % 360) - 180 for h in hs)
    sats.sort()
    lumas.sort()
    hp = [(centre + pct(rel, q)) % 360 if rel else float("nan") for q in (0.1, 0.5, 0.9)]
    return {"hue": mean, "h": hp, "sat50": pct(sats, 0.5), "y": [pct(lumas, q) for q in (0.1, 0.5, 0.9)],
            "bands": {k: 100.0 * c / n for k, c in count.items()}}


def hue_row(name, region, st):
    def f(x):
        return "-" if x != x else "%.0f" % x
    return "| %s | %s | %s | %s | %.2f | %s | %s | %s | " % (
        name, region, f(st["hue"]), "/".join(f(x) for x in st["h"]), st["sat50"],
        f(st["y"][0]), f(st["y"][1]), f(st["y"][2])) + " | ".join("%.1f" % st["bands"][k] for k in BANDS) + " |"


def main():
    boxes = []
    files = []
    hue = scene = False
    sat_min = 0.1
    for a in sys.argv[1:]:
        if a.startswith("--box="):
            boxes.append(tuple(int(x) for x in a[6:].split(",")))
        elif a == "--hue":
            hue = True
        elif a == "--scene":
            scene = True
        elif a.startswith("--sat-min="):
            sat_min = float(a[10:])
        else:
            files.append(a)
    box = boxes[0] if boxes else None
    print("| Imagem | Luma média | Saturação média | Saturação p90 | Violeta > 60% (% da tela) |" +
          (" Verde/ciano na caixa (%) | Rosa na caixa (%) |" if box else ""))
    print("|---|---|---|---|---|" + ("---|---|" if box else ""))
    for f in files:
        s = stats(f)
        v, _, _ = shares(pixels(f))
        row = "| %s | %.0f | %.0f | %.0f | %.1f |" % (f.split("/")[-1], s.get("YAVG", 0), s.get("SATAVG", 0),
                                                      s.get("SATHIGH", 0), v)
        if box:
            _, g, p = shares(pixels(f, box))
            row += " %.1f | %.1f |" % (g, p)
        print(row)
    if not hue:
        return
    print()
    print("| Imagem | Região | Matiz | Matiz p10/p50/p90 (sat > %.2f) | Sat p50 | Luma p10 | Luma p50 | Luma p90 | "
          % sat_min + " | ".join("%s %%" % k for k in BANDS) + " |")
    print("|---|---|---|---|---|---|---|---|" + "---|" * len(BANDS))
    for f in files:
        name = f.split("/")[-1]
        print(hue_row(name, "quadro", hue_stats(pixels(f), sat_min)))
        if scene:
            w, h = size(f)
            r = (round(w * 0.05), round(h * 0.08), round(w * 0.9), round(h * 0.77))
            print(hue_row(name, "cena", hue_stats(pixels(f, r), sat_min)))
        for b in boxes:
            print(hue_row(name, ",".join(str(x) for x in b), hue_stats(pixels(f, b), sat_min)))


main()
