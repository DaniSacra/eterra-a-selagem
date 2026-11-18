"""T5b P1-3 after: jumps of the drawn body inside clip fades, against the clip's own.

For every enemy and frame of a drawn_probe CSV: the drawn centre relative to the simulated place, turned into the body's
own frame (so a turn of the body is not counted as a jump; columns yaw), and its change from the frame before. Frames in
a fade (the pose rows of two clips) are compared to the worst change the same clip makes on its own (no fade) in the
same run: a fade frame is a "step" when it jumps more than 0.12 m and more than its clip's own worst + 0.02 m.
Frames with the hit recoil or a death are left out (the body is thrown).
python3 fadestep.py run.csv ...
"""
import sys, math, collections

for path in sys.argv[1:]:
    rows = []
    for line in open(path):
        p = line.rstrip().split(",")
        if p[0] == "f" or p[1] == "HIT" or len(p) < 29:
            continue
        rows.append(p)
    prev = {}
    own = collections.defaultdict(float)
    fades = []
    for p in rows:
        f = int(p[0]); k = (p[1], p[2])
        yaw = math.radians(float(p[18]))
        rx = float(p[11]) - float(p[9]); rz = float(p[13]) - float(p[10]); ry = float(p[12])
        # into the body's frame (its +z forward)
        lx = rx * math.cos(yaw) - rz * math.sin(yaw)
        lz = rx * math.sin(yaw) + rz * math.cos(yaw)
        ra, rb = p[26], p[27]
        ca, cb = ra.split(":")[0], rb.split(":")[0]
        fading = ca != cb
        thrown = cb in ("death", "hit") or ca in ("death",) or float(p[8]) > 0
        if k in prev and prev[k][0] == f - 1 and not thrown:
            _, plx, plz, ply = prev[k]
            j = max(math.hypot(lx - plx, lz - plz), abs(ry - ply))
            if fading:
                fades.append((p[1], cb, j, f, ra + ">" + rb))
            else:
                own[(p[1], cb)] = max(own[(p[1], cb)], j)
        prev[k] = (f, lx, lz, ry)
    steps = collections.Counter(); worst = collections.defaultdict(float); ex = {}
    for who, clip, j, f, what in fades:
        if j > 0.12 and j > own[(who, clip)] + 0.02:
            steps[(who, clip)] += 1
            if j > worst[(who, clip)]:
                worst[(who, clip)] = j; ex[(who, clip)] = (f, what)
    print("== %s: %d fade frames, %d steps" % (path.split("/")[-1], len(fades), sum(steps.values())))
    for t, n in steps.most_common(20):
        print("  %-24s %4d worst %.2f m (own %.2f) %s" % ("/".join(t), n, worst[t], own[t], ex[t]))
