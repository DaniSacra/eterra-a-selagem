import re, sys
# counts stretches of >=3 frames drawn in idle with the body moving above 1 m/s (world time)
for fn in sys.argv[1:]:
    rows = []
    for l in open(fn):
        m = re.match(r"\s*(\d+) t=\s*([\d.]+) (\S+)\s+anim_t=\s*[-\d.]+ pos=\(([-\d.]+),([-\d.]+)\)", l)
        if m:
            rows.append((int(m[1]), float(m[2]), m[3], float(m[4]), float(m[5])))
    run = 0; stretches = 0; frames = 0; worst = 0; cur = 0
    for a, b in zip(rows, rows[1:]):
        dt = b[1] - a[1]
        d = ((b[3] - a[3]) ** 2 + (b[4] - a[4]) ** 2) ** .5
        # speed on the screen: the probe runs at a fixed 60 frames a second (hit stop slows the world, not the frames)
        v = d * 60.0 if b[0] == a[0] + 1 else 0
        if b[2].endswith('/idle') and v > 1.0:
            run += 1; cur += d
        else:
            if run >= 3:
                stretches += 1; frames += run; worst = max(worst, cur)
            run = 0; cur = 0
    print(fn.split('/')[-1], "frames", len(rows), "stretches", stretches, "frames_slid", frames, "worst_m", round(worst, 2))
