#!/usr/bin/env python3
"""Value and saturation of captures (cycle C18 acceptance, art report 2026-11-18): the image is scaled to 640 px wide
and measured by ffmpeg's signalstats (YAVG luma mean, SATAVG saturation mean, SATHIGH its 90th percentile, the
numbers of the art report's table); also the share of the frame that is violet (hue 250 to 320 degrees) with HSV
saturation above 60% (the "no violet area above 60% bigger than 5% of the screen" rule), and, with --box=x,y,w,h in
the full image's pixels, the same for a box (the hero's: green-cyan share and pink share inside it).
  python3 -I tools/frame_stats.py a.jpg b.jpg [--box=x,y,w,h]"""
import colorsys
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
        if s > 0.35 and v > 0.3 and (h >= 300 or h <= 345 and h >= 300):
            pink += 1
    return 100.0 * violet / n, 100.0 * green / n, 100.0 * pink / n


def main():
    box = None
    files = []
    for a in sys.argv[1:]:
        if a.startswith("--box="):
            box = tuple(int(x) for x in a[6:].split(","))
        else:
            files.append(a)
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


main()
