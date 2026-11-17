import sys, collections
S = "ENTER CHASE SCYTHE BLADES STORM ERUPTIONS CURSE SUMMON DASH_WARN DASH ROAR TO_CENTER RITUAL STUNNED DYING RECOVER".split()
path = sys.argv[1]; f0 = int(sys.argv[2]) if len(sys.argv) > 2 else 0; f1 = int(sys.argv[3]) if len(sys.argv) > 3 else 10**9
mv = {}; bs = {}; snd = collections.defaultdict(list)
for line in open(path):
    p = line.rstrip("\n").split(",")
    if p[0] == "f": continue
    f = int(p[0])
    if p[1] == "BOSS": bs[f] = p
    elif p[1] == "SND": snd[f].append(p[2])
    elif p[1] == "morvath": mv[f] = p
prev = None; pz = {}
for f in sorted(bs):
    if f < f0 or f > f1: continue
    b = bs[f]; m = mv.get(f)
    clip = m[7].split(":")[0] if m else "-"
    key = (b[2], b[4], clip)
    zones = {}
    for z in b[7].split(";"):
        if z:
            src, lt = z.split(":"); zones.setdefault(src, []).append(lt)
    landed = [s for s in pz if len(zones.get(s, [])) < len(pz[s])]
    if key != prev or snd.get(f) or landed:
        print(f"f{f} {S[int(b[2])]:9s} {b[3]:9s} step{b[4]} t{float(b[5]):.2f} drawn {m[7] if m else '-'} pos({m[9]},{m[10]}) dist {m[15]} zones {dict((k, v[0]) for k, v in zones.items())} {'LAND:' + ','.join(landed) if landed else ''} {' '.join(snd.get(f, []))}")
    prev = key; pz = zones
