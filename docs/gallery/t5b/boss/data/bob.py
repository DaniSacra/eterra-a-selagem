import sys, collections
for path in sys.argv[1:]:
    d = collections.defaultdict(list)
    for line in open(path):
        p = line.split(",")
        if p[0]=="f" or p[1]=="HIT": continue
        clip = p[6].split(":")[0]
        d[(p[1], p[3], clip)].append((float(p[12]), float(p[14])))
    print("==", path.split("/")[-1])
    for k in sorted(d):
        v = d[k]
        if len(v) < 30: continue
        ys = sorted(a for a,b in v); los = sorted(b for a,b in v)
        n=len(v); air = sum(1 for a,b in v if b>0.12)/n
        print("  %-28s n=%5d centroid y p5..p95 %.2f..%.2f (amp %.2f)  feet p50 %.2f p95 %.2f max %.2f  air%%=%.0f" % ("/".join(k), n, ys[n//20], ys[-n//20], ys[-n//20]-ys[n//20], los[n//2], los[-n//20], los[-1], 100*air))
