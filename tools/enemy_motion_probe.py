"""T5 (docs/design/combat_cadence.md 6.1): reads the CSVs of tools/enemy_motion_probe.gd and prints the measures of
the acceptance. python3 tools/enemy_motion_probe.py out1.csv [out2.csv ...]

1. Jitter of every soldier (and every kind) while in WALK (T5-10): frames turning more than 8 degrees, turn reversals
   a second, walk/idle switches a second, idle runs of 1 to 3 frames, 2-frame place reversals a second.
2. Per blow on the paladin (HIT rows): who dealt it (the crowd's body, a warning landing on the floor, a shot), the
   gap from the body that dealt it to him (crowd: its body's edge for a charge, the blade's reach for a soldier) and
   the frame its warning ended against the blow's (0 to 1 frame).
3. Per attack: the longest run of one pose drawn in RECOVER (at most 0.3 s) and in WINDUP before its hold.
"""
import sys, collections, math

STATES = {0: "RISE", 1: "WALK", 2: "WINDUP", 3: "ATTACK", 4: "DEAD", 5: "RECOVER"}
FPS = 60.0
HERO_R = 0.45  # Player.RADIUS


def angdiff(a, b):
    return (a - b + 180) % 360 - 180


def read(path):
    by = collections.defaultdict(list)
    hits = []
    for line in open(path):
        p = line.strip().split(",")
        if p[0] == "f":
            continue
        if p[1] == "HIT":
            hits.append(dict(f=int(p[0]), amount=float(p[2]), x=float(p[3]), z=float(p[4]),
                             channel=p[5] if len(p) > 5 else "?", by=p[6] if len(p) > 6 else "",
                             hx=float(p[7]) if len(p) > 7 else 0.0, hz=float(p[8]) if len(p) > 8 else 0.0))
            continue
        if p[1] in ("SND", "BOSS"):
            continue
        r = dict(f=int(p[0]), id=p[1], uid=int(p[2]), st=int(p[3]), stt=float(p[4]), anim=p[5], drawn=p[6],
                 pose=p[7], x=float(p[9]), z=float(p[10]), sp=float(p[13]), yaw=float(p[14]), dist=float(p[15]),
                 stun=float(p[17]), hurt=float(p[18]), wl=float(p[19]), wt=float(p[20]),
                 radius=float(p[24]) if len(p) > 24 else 0.5, reach=float(p[25]) if len(p) > 25 else 1.5,
                 windup=float(p[26]) if len(p) > 26 else 0.0, hold=float(p[27]) if len(p) > 27 else 0.3)
        by[(r["id"], r["uid"])].append(r)
    return by, hits


def jitter(by, secs):
    print("== jitter while WALK (T5-10; per 10 s: turns >8 deg; per s: turn reversals, walk/idle switches, 2-frame place reversals)")
    tot = collections.defaultdict(lambda: [0, 0, 0, 0, 0, 0])
    for (kind, u), rs in sorted(by.items()):
        n = big = rev = sw = blips = posrev = 0
        prev = None
        prev_dy = 0.0
        prevmove = None
        idle_run = 0
        for r in rs:
            if r["st"] != 1 or r["stun"] > 0 or r["hurt"] > 0:
                prev = None
                prevmove = None
                idle_run = 0
                continue
            n += 1
            if r["drawn"] == "idle":
                idle_run += 1
            else:
                if 1 <= idle_run <= 3:
                    blips += 1
                idle_run = 0
            if prev is not None:
                if {prev["drawn"], r["drawn"]} == {"walk", "idle"}:
                    sw += 1
                dy = angdiff(r["yaw"], prev["yaw"])
                if abs(dy) > 8:
                    big += 1
                if dy * prev_dy < 0 and abs(dy) > 1 and abs(prev_dy) > 1:
                    rev += 1
                if abs(dy) > 1:
                    prev_dy = dy
                mv = (r["x"] - prev["x"], r["z"] - prev["z"])
                if prevmove is not None and math.hypot(*mv) > 0.005 and math.hypot(*prevmove) > 0.005:
                    if mv[0] * prevmove[0] + mv[1] * prevmove[1] < -0.8 * math.hypot(*mv) * math.hypot(*prevmove):
                        posrev += 1
                prevmove = mv
            prev = r
        if n < 30:
            continue
        s = n / FPS
        t = tot[kind]
        for i, v in enumerate([n, big, rev, sw, blips, posrev]):
            t[i] += v
        print(f"  {kind}#{u}: {n} f, turns>8 {big / s * 10:.1f}/10s, reversals {rev / s:.2f}/s, walk<->idle {sw / s:.2f}/s, "
              f"idle blips {blips}, place reversals {posrev / s:.2f}/s")
    for kind, t in sorted(tot.items()):
        s = t[0] / FPS
        print(f"  ALL {kind}: {t[0]} f, turns>8 {t[1] / s * 10:.1f}/10s, reversals {t[2] / s:.2f}/s, walk<->idle {t[3] / s:.2f}/s, "
              f"idle blips {t[4]}, place reversals {t[5] / s:.2f}/s")


def blows(by, hits):
    print("== blows on the paladin (6.1: from the body, warning full on the blow's frame)")
    rows_at = collections.defaultdict(list)
    for k, rs in by.items():
        for r in rs:
            rows_at[r["f"]].append(r)
    by_uid = {k: {r["f"]: r for r in rs} for k, rs in by.items()}
    for h in hits:
        if h["channel"] == "shots":
            print(f"  f{h['f']} shot {h['by']} {h['amount']}")
            continue
        # the enemy that dealt it: the same kind whose body is nearest the source of the blow
        best = None
        for r in rows_at.get(h["f"] - 1, []) + rows_at.get(h["f"], []):
            if h["by"] and r["id"] != h["by"]:
                continue
            d = math.hypot(r["x"] - h["x"], r["z"] - h["z"])
            if best is None or d < best[0]:
                best = (d, r)
        if best is None:
            print(f"  f{h['f']} {h['channel']} {h['by']} {h['amount']}: no body found")
            continue
        r = best[1]
        gap = math.hypot(h["hx"] - h["x"], h["hz"] - h["z"]) if h["hx"] or h["hz"] else r["dist"]
        # the warning: the last frame this enemy had one alive
        rs = by[(r["id"], r["uid"])]
        last_warn = None
        for q in rs:
            if q["f"] > h["f"]:
                break
            if q["wl"] > 0:
                last_warn = q["f"]
        warn = (last_warn + 1) if last_warn is not None else None
        reach = r["reach"] + HERO_R
        body = r["radius"] + HERO_R
        # no warning of its own (Morvath's blows: Boss draws his, not the crowd): "-"
        late = "-" if warn is None else f"{h['f'] - warn:+d}"
        print(f"  f{h['f']} {h['channel']} {r['id']}#{r['uid']} {STATES.get(r['st'], r['st'])} {h['amount']}: "
              f"{gap:.2f} m from him (body {body:.2f}, blade {reach:.2f}), warning ends f{warn} ({late} f)")


def poses(by):
    print("== longest run of one pose drawn (6.1: RECOVER at most 0.3 s; WINDUP before its hold)")
    worst = collections.defaultdict(lambda: [0.0, 0.0])
    for (kind, u), rs in by.items():
        run = 0
        last = None
        for r in rs:
            if r["st"] not in (2, 5) or r["stun"] > 0 or r["hurt"] > 0:
                run = 0
                last = None
                continue
            # its hold (the last windup_hold of its wind-up; the warning may last longer, to the blow)
            windup = r["windup"] if r["windup"] > 0 else r["wt"]
            if r["st"] == 2 and windup > 0 and r["stt"] >= (1.0 - r["hold"]) * windup:
                run = 0
                last = None
                continue
            key = (r["st"], r["pose"])
            run = run + 1 if key == last else 1
            last = key
            i = 0 if r["st"] == 2 else 1
            worst[kind][i] = max(worst[kind][i], run / FPS)
    for kind, (w, rec) in sorted(worst.items()):
        print(f"  {kind}: WINDUP still {w:.2f} s, RECOVER still {rec:.2f} s")


def main():
    for path in sys.argv[1:]:
        print(f"##### {path}")
        by, hits = read(path)
        frames = max((r["f"] for rs in by.values() for r in rs), default=0)
        jitter(by, frames / FPS)
        blows(by, hits)
        poses(by)


main()
