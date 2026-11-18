"""T5b: reads drawn_probe.gd CSVs and finds the "jumps": drawn body moving faster than the sim, drawn body off the
floor, sim place snapping. python3 an.py a.csv [b.csv ...] [--events]"""
import sys, collections, math

ST = {0: "RISE", 1: "WALK", 2: "WINDUP", 3: "ATTACK", 4: "DEAD", 5: "RECOVER"}
EV = "--events" in sys.argv
files = [a for a in sys.argv[1:] if not a.startswith("--")]


def clipname(s):
    return s.split(":")[0]


for path in files:
    by = collections.defaultdict(list)
    for line in open(path):
        p = line.rstrip().split(",")
        if p[0] == "f" or p[1] == "HIT":
            continue
        r = dict(f=int(p[0]), id=p[1], u=int(p[2]), st=int(p[3]), stt=float(p[4]), anim=p[5], drawn=p[6],
                 stun=float(p[7]), hurt=float(p[8]), px=float(p[9]), pz=float(p[10]), dx=float(p[11]), dy=float(p[12]),
                 dz=float(p[13]), lo=float(p[14]), hi=float(p[15]), ax=float(p[16]), az=float(p[17]), yaw=float(p[18]),
                 hx=float(p[19]), hz=float(p[20]), bst=p[21], batk=p[22], ph=p[23], rate=float(p[24]), inst=float(p[25]))
        by[(r["id"], r["u"])].append(r)
    cnt = collections.Counter()
    frames = collections.Counter()
    worst = {}
    events = []
    airborne = collections.Counter()
    for (kid, u), rs in by.items():
        prev = None
        for r in rs:
            frames[kid] += 1
            key = (kid, ST[r["st"]], clipname(r["drawn"]))
            # feet off the floor (lowest vertex above 12 cm), not dying
            if r["lo"] > 0.12:
                airborne[key] += 1
            if prev is not None and r["f"] == prev["f"] + 1:
                sim = math.hypot(r["px"] - prev["px"], r["pz"] - prev["pz"])
                drw = math.hypot(r["dx"] - prev["dx"], r["dz"] - prev["dz"])
                rel = math.hypot((r["dx"] - r["px"]) - (prev["dx"] - prev["px"]), (r["dz"] - r["pz"]) - (prev["dz"] - prev["pz"]))
                vy = r["dy"] - prev["dy"]
                vlo = r["lo"] - prev["lo"]
                tags = []
                if sim > 0.25:
                    tags.append("SIMSNAP")
                if rel > 0.12:
                    tags.append("DRAWPOP")
                if abs(vy) > 0.06:
                    tags.append("VERT")
                if vlo > 0.06:
                    tags.append("FEETUP")
                for t in tags:
                    cnt[(t,) + key] += 1
                    w = worst.get((t,) + key, (0, None))
                    val = {"SIMSNAP": sim, "DRAWPOP": rel, "VERT": abs(vy), "FEETUP": vlo}[t]
                    if val > w[0]:
                        worst[(t,) + key] = (val, r, prev)
                if tags:
                    events.append((r["f"], kid, u, ",".join(tags), ST[prev["st"]] + ">" + ST[r["st"]], prev["drawn"] + ">" + r["drawn"], sim, drw, rel, vy, vlo, r))
            prev = r
    print("=====", path.split("/")[-1], "frames per kind:", dict(frames))
    print("-- airborne frames (lowest vertex > 0.12 m) by kind/state/clip")
    for k, v in airborne.most_common(12):
        print("  %-40s %5d" % ("/".join(k), v))
    print("-- events by tag/kind/state/clip (count, worst value m per frame, at frame)")
    for k, v in sorted(cnt.items(), key=lambda kv: -kv[1])[:40]:
        w = worst[k]
        r = w[1]
        print("  %-48s %5d  worst %.3f f%d %s>%s stt=%.2f dist=%.2f" % ("/".join(k), v, w[0], r["f"], w[2]["drawn"], r["drawn"], r["stt"], math.hypot(r["px"] - r["hx"], r["pz"] - r["hz"])))
    if EV:
        for e in events[:400]:
            r = e[11]
            print("   f%d %s#%d %s %s %s sim=%.3f drw=%.3f rel=%.3f vy=%.3f vlo=%.3f dy=%.2f lo=%.2f stt=%.2f d=%.2f boss=%s/%s" % (e[0], e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8], e[9], e[10], r["dy"], r["lo"], r["stt"], math.hypot(r["px"] - r["hx"], r["pz"] - r["hz"]), r["bst"], r["batk"]))
