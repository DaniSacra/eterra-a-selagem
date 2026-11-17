import sys, collections
"""Per attack cycle (WINDUP start -> next WALK): frames of windup, attack, recover; warning total and the frame it
landed (relative to windup start); drawn clips; distance at windup start, at warning landing and min during attack;
cut (WINDUP followed by WALK)."""
rows = collections.defaultdict(list)
snd = []
for path in sys.argv[1:]:
    for line in open(path):
        p = line.strip().split(",")
        if p[0] == "f": continue
        if p[1] in ("SND", "HIT"): snd.append((path, int(p[0]), p[2])); continue
        rows[(path, p[1], int(p[2]))].append(p)
out = collections.defaultdict(list)
for (path, kind, u), rs in rows.items():
    i = 0
    while i < len(rs):
        if rs[i][3] == "2" and (i == 0 or rs[i-1][3] != "2"):
            s = int(rs[i][0]); j = i
            clipsW = []; clipsA = []; clipsR = []
            wt = -1; land = None; prevwl = None; dmin = 99; d0 = float(rs[i][15]); dland = None
            nW = nA = nR = 0; cut = False
            while j < len(rs):
                st = rs[j][3]; f = int(rs[j][0])
                wl = float(rs[j][19])
                if wl > 0: wt = float(rs[j][20])
                if prevwl is not None and prevwl > 0 and wl < 0 and land is None:
                    land = f - s; dland = float(rs[j][15])
                prevwl = wl
                cl = rs[j][7].split(":")[0]
                if st == "2": nW += 1; clipsW.append(cl)
                elif st == "3": nA += 1; clipsA.append(cl); dmin = min(dmin, float(rs[j][15]))
                elif st == "5": nR += 1; clipsR.append(cl)
                elif st == "1":
                    if nA == 0: cut = True
                    break
                j += 1
            def u_(l): return "/".join(dict.fromkeys(l))
            out[kind].append(dict(W=nW, A=nA, R=nR, wt=wt, land=land, d0=d0, dland=dland, dmin=dmin if nA else None, cut=cut, cw=u_(clipsW), ca=u_(clipsA), cr=u_(clipsR)))
            i = j
        i += 1
for kind, cs in sorted(out.items()):
    full = [c for c in cs if not c["cut"]]
    print(f"== {kind}: cycles {len(cs)} cut {len(cs)-len(full)}")
    for c in full[:4]:
        print(f"  W {c['W']}f [{c['cw']}] A {c['A']}f [{c['ca']}] R {c['R']}f [{c['cr']}] warn {c['wt']:.2f}s lands f+{c['land']} d0 {c['d0']:.1f} dland {c['dland']} dminA {c['dmin']}")
