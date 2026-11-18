"""Runner tremor in a drawn_probe.gd csv (docs/qa/t5b_boss_fight.md, Corredor).
python3 runner.py file.csv [id]
Per frame of each enemy of that id (default runner), from the drawn body:
- walk frames: the drawn centroid's height p5..p95 and its frame-to-frame step, the feet (lowest vertex) p50/p95/max
  and the share of frames with the whole body over 0.12 m;
- clip flips: changes of the sim's anim between walk and idle per second of presence, and the ones that come back
  within 0.3 s (a flicker);
- turn: the drawn yaw's change per frame (p95, max, frames over 15 degrees);
- sway: the drawn body's tilt off the upright while running (tilt column, when there): p95, its change per frame and
  how many times a second it turns back (the 9 Hz rock turned back 18 times a second);
- speed: the drawn root's speed (m/s) and its direction reversals (more than 120 degrees between two frames while
  moving over 0.5 m/s) per second."""
import sys, math, collections

path = sys.argv[1]
want = sys.argv[2] if len(sys.argv) > 2 else "runner"
rows = collections.defaultdict(list)
for line in open(path):
    p = line.rstrip().split(",")
    if p[0] == "f" or p[1] == "HIT" or p[1] != want:
        continue
    rows[p[2]].append(p)
cy, steps, feet, yawd, spd, tilt, dtilt = [], [], [], [], [], [], []
turns = 0
run_frames = 0
air = flips = flick = rev = frames = 0
for u, rs in rows.items():
    prev = None
    pv = None
    last_dt = None
    last_flip = -99
    last_anim = None
    for p in rs:
        f = int(p[0])
        frames += 1
        anim = p[5]
        clip = p[6].split(":")[0]
        dy, lo, yaw = float(p[12]), float(p[14]), float(p[18])
        ax, az = float(p[16]), float(p[17])
        if clip == "walk" and p[3] == "1":
            cy.append(dy)
            feet.append(lo)
            if lo > 0.12:
                air += 1
        has_tilt = len(p) > 29
        if clip == "walk" and has_tilt:
            tilt.append(float(p[29]))
        if prev is not None and int(prev[0]) == f - 1:
            if clip == "walk" and prev[6].split(":")[0] == "walk":
                steps.append(abs(dy - float(prev[12])))
                if has_tilt:
                    run_frames += 1
                    dt = float(p[29]) - float(prev[29])
                    dtilt.append(abs(dt))
                    if last_dt is not None and dt * last_dt < 0 and abs(dt) > 0.05:
                        turns += 1
                    if abs(dt) > 0.05:
                        last_dt = dt
            d = (yaw - float(prev[18]) + 180) % 360 - 180
            yawd.append(abs(d))
            vx, vz = ax - float(prev[16]), az - float(prev[17])
            v = math.hypot(vx, vz) * 60
            spd.append(v)
            if pv is not None and v > 0.5 and math.hypot(*pv) * 60 > 0.5:
                c = (vx * pv[0] + vz * pv[1]) / (math.hypot(vx, vz) * math.hypot(*pv))
                if c < -0.5:
                    rev += 1
            pv = (vx, vz)
        else:
            pv = None
        if last_anim is not None and {anim, last_anim} == {"walk", "idle"}:
            flips += 1
            if f - last_flip < 18:
                flick += 1
            last_flip = f
        last_anim = anim
        prev = p


def pc(a, q):
    a = sorted(a)
    return a[min(len(a) - 1, int(q * len(a)))] if a else float("nan")


secs = max(frames / 60.0, 1e-9)
n = len(cy)
print("%s %s: %d enemies, %.1f s present, %d walk frames" % (path.split("/")[-1], want, len(rows), secs, n))
print("  walk: centroid y p5..p95 %.3f..%.3f (amp %.3f), step p95 %.4f max %.4f m/frame" % (
    pc(cy, .05), pc(cy, .95), pc(cy, .95) - pc(cy, .05), pc(steps, .95), max(steps or [0])))
print("  walk: feet p50 %.3f p95 %.3f max %.3f, whole body over 0.12 m in %.1f%% of frames" % (
    pc(feet, .5), pc(feet, .95), max(feet or [0]), 100 * air / max(1, n)))
print("  walk<->idle flips %.2f/s, back within 0.3 s %d (%.2f/s)" % (flips / secs, flick, flick / secs))
print("  yaw per frame p95 %.1f max %.1f deg, %d frames over 15" % (pc(yawd, .95), max(yawd or [0]), sum(1 for y in yawd if y > 15)))
if tilt:
    print("  sway: tilt p95 %.1f deg, change p95 %.2f deg/frame, turns back %.1f times a second of running" % (
        pc(tilt, .95), pc(dtilt, .95), turns / max(run_frames / 60.0, 1e-9)))
print("  drawn speed p50 %.2f p95 %.2f m/s, reversals %d (%.2f/s)" % (pc(spd, .5), pc(spd, .95), rev, rev / secs))
