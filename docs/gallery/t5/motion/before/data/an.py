import sys, csv, math, collections
"""T5 scratch: reads t5_probe.csv. Prints (1) per enemy the state timeline with drawn clip runs, warnings and
sounds, (2) jitter metrics while in WALK."""
path = sys.argv[1]
mode = sys.argv[2] if len(sys.argv) > 2 else "both"
only = sys.argv[3] if len(sys.argv) > 3 else None
STATES = {0: "RISE", 1: "WALK", 2: "WINDUP", 3: "ATTACK", 4: "DEAD", 5: "RECOVER"}
by = collections.defaultdict(list)
snd = []
for line in open(path):
    p = line.strip().split(",")
    if p[0] == "f":
        continue
    if p[1] == "SND":
        snd.append((int(p[0]), p[2]))
        continue
    if p[1] == "HIT":
        snd.append((int(p[0]), "HIT" + p[2]))
        continue
    r = dict(f=int(p[0]), id=p[1], uid=int(p[2]), st=int(p[3]), stt=float(p[4]), anim=p[5], drawn=p[6], pose=p[7],
             fade=float(p[8]), x=float(p[9]), z=float(p[10]), vx=float(p[11]), vz=float(p[12]), sp=float(p[13]),
             yaw=float(p[14]), dist=float(p[15]), cd=float(p[16]), stun=float(p[17]), hurt=float(p[18]),
             wl=float(p[19]), wt=float(p[20]), walking=int(p[21]), straight=int(p[22]))
    by[(r["id"], r["uid"])].append(r)

def angdiff(a, b):
    d = (a - b + 180) % 360 - 180
    return d

if mode in ("both", "jit"):
    print("== jitter while state WALK (per enemy) ==")
    print("who frames walkfr idlefr walk<->idle_switches/s yaw|d|>8deg/fr yaw_reversals/s pos_reversals/s mean_speed mean|dyaw| max|dyaw|")
    for k, rs in sorted(by.items()):
        if only and k[0] != only:
            continue
        n = 0; sw = 0; big = 0; rev = 0; prev_dy = 0; prv = None; prevmove = None; posrev = 0; spd = 0; walkfr = 0; idlefr = 0; sumdy = 0; maxdy = 0
        for r in rs:
            if r["st"] != 1 or r["stun"] > 0 or r["hurt"] > 0:
                prv = None; prevmove = None
                continue
            n += 1
            spd += r["sp"]
            if r["drawn"] == "walk": walkfr += 1
            if r["drawn"] == "idle": idlefr += 1
            if prv is not None:
                if prv["drawn"] != r["drawn"] and {prv["drawn"], r["drawn"]} == {"walk", "idle"}:
                    sw += 1
                dy = angdiff(r["yaw"], prv["yaw"])
                sumdy += abs(dy); maxdy = max(maxdy, abs(dy))
                if abs(dy) > 8: big += 1
                if dy * prev_dy < 0 and abs(dy) > 1 and abs(prev_dy) > 1: rev += 1
                prev_dy = dy if abs(dy) > 1 else prev_dy
                mv = (r["x"] - prv["x"], r["z"] - prv["z"])
                if prevmove is not None:
                    dot = mv[0] * prevmove[0] + mv[1] * prevmove[1]
                    if dot < 0 and math.hypot(*mv) > 0.002: posrev += 1
                prevmove = mv
            prv = r
        if n == 0: continue
        s = n / 60.0
        print(f"{k[0]}#{k[1]} {n} {walkfr} {idlefr} {sw/s:.2f} {big} {rev/s:.2f} {posrev/s:.2f} {spd/n:.2f} {sumdy/max(n-1,1):.2f} {maxdy:.1f}")

if mode in ("both", "tl"):
    print("== timelines ==")
    for k, rs in sorted(by.items()):
        if only and k[0] != only:
            continue
        print(f"--- {k[0]}#{k[1]}")
        cur = None
        start = None
        runs = []
        last = None
        for r in rs:
            key = (r["st"], r["drawn"])
            if cur is None or key != cur:
                if cur is not None:
                    runs.append((start, last["f"], cur, first_pose, last["pose"], startr, last))
                cur = key; start = r["f"]; first_pose = r["pose"]; startr = r
            last = r
        if cur is not None:
            runs.append((start, last["f"], cur, first_pose, last["pose"], startr, last))
        for a, b, (st, dr), p0, p1, r0, r1 in runs:
            if st == 1 and dr in ("walk", "idle") and b - a > 30 and r0["stun"] <= 0:
                print(f"  f{a}-{b} ({b-a+1}f) {STATES[st]} {dr}")
                continue
            w = f" warn {r0['wl']:.2f}/{r0['wt']:.2f}->{r1['wl']:.2f}" if r0['wl'] > 0 or r1['wl'] > 0 else ""
            print(f"  f{a}-{b} ({b-a+1}f) {STATES[st]} {dr} {p0}->{p1} dist {r0['dist']:.1f} stun {r0['stun']:.2f}{w}")
    print("== sounds/hits ==")
    print(" ".join(f"{f}:{s}" for f, s in snd))
