import sys, collections, math
for path in sys.argv[1:]:
    first={}; firstatk={}; risee={}
    for line in open(path):
        p=line.split(",")
        if p[0]=="f" or p[1] in ("HIT","morvath"): continue
        k=(p[1],p[2]); f=int(p[0])
        if k not in first:
            first[k]=(f,p[3],math.hypot(float(p[9])-float(p[19]),float(p[10])-float(p[20])),p[22],p[23])
        if p[3]=="1" and k not in risee: risee[k]=f
        if p[3]=="2" and k not in firstatk: firstatk[k]=f
    d=sorted(v[2] for v in first.values())
    near=[ (k,v) for k,v in first.items() if v[2]<3.0]
    ttа=[ (firstatk[k]-risee[k])/60 for k in firstatk if k in risee]
    print("%-24s spawned %d, dist to hero at spawn min %.2f p10 %.2f p50 %.2f; <3 m: %d; <2 m: %d; rise->first windup s p10 %.2f min %.2f"%(path.split('/')[-2]+'/'+path.split('/')[-1],len(d),d[0],d[len(d)//10],d[len(d)//2],len(near),sum(1 for x in d if x<2),sorted(ttа)[len(ttа)//10] if ttа else -1,min(ttа) if ttа else -1))
    for k,v in sorted(near,key=lambda kv:kv[1][2])[:4]: print("     ",k,"f%d dist %.2f boss=%s/%s"%(v[0],v[2],v[3],v[4]))
