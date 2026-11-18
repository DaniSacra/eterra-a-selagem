"""T5b P1-2 and P1-5 after: what a risen body does once its RISE ends (drawn_probe CSVs).

Per enemy that rose: over the 0.3 s from the last RISE frame, the most its drawn centre rises in a frame and in all
(m, against the last RISE frame), the most its top rises, the most it turns in a frame (degrees); and the seconds from
the end of the RISE to its first wind-up. Prints per kind the worst and the share within the review's limits
(0.05 m a frame, 0.15 m in all, top 0.2 m, 8 degrees a frame; 0.6 s to the first wind-up).
python3 risen.py run.csv ...
"""
import sys, collections

for path in sys.argv[1:]:
    by = collections.defaultdict(list)
    for line in open(path):
        p = line.rstrip().split(",")
        if p[0] == "f" or p[1] == "HIT" or len(p) < 29 or p[1] == "morvath":
            continue
        by[(p[1], p[2])].append((int(p[0]), int(p[3]), float(p[12]), float(p[15]), float(p[18])))
    out = collections.defaultdict(lambda: {"n": 0, "step": 0.0, "rise": 0.0, "top": 0.0, "turn": 0.0, "wait": [], "ok": 0})
    for (kind, _), rows in by.items():
        last = None
        for i, r in enumerate(rows):
            if r[1] == 0:
                last = i
        if last is None or last == len(rows) - 1 or rows[0][1] != 0:
            continue
        f0, _, y0, top0, yaw0 = rows[last]
        o = out[kind]
        o["n"] += 1
        step = rise = top = turn = 0.0
        prev = rows[last]
        for r in rows[last + 1:]:
            if r[0] - f0 > 18:
                break
            if r[0] != prev[0] + 1:
                break
            step = max(step, r[2] - prev[2])
            rise = max(rise, r[2] - y0)
            top = max(top, r[3] - top0)
            turn = max(turn, abs((r[4] - prev[4] + 180) % 360 - 180))
            prev = r
        for r in rows[last + 1:]:
            if r[1] == 2:
                o["wait"].append((r[0] - f0) / 60.0)
                break
        o["step"] = max(o["step"], step); o["rise"] = max(o["rise"], rise); o["top"] = max(o["top"], top); o["turn"] = max(o["turn"], turn)
        if step <= 0.05 and rise <= 0.15 and top <= 0.2 and turn <= 8.5:
            o["ok"] += 1
    print("== %s" % path.split("/")[-1])
    for kind, o in sorted(out.items()):
        w = sorted(o["wait"])
        print("  %-14s risen %3d, within the limits %3d; worst: %.3f m a frame, %.2f m in all, top %.2f m, %.1f deg a frame; first wind-up after %s s" % (
            kind, o["n"], o["ok"], o["step"], o["rise"], o["top"], o["turn"],
            "min %.2f p10 %.2f (%d)" % (w[0], w[len(w) // 10], len(w)) if w else "-"))
