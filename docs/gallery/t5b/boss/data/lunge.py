import sys, collections, math
for path in sys.argv[1:]:
    by=collections.defaultdict(list)
    for line in open(path):
        p=line.split(",")
        if p[0]=="f" or p[1]!="skeleton": continue
        by[int(p[2])].append((int(p[0]),int(p[3]),float(p[9]),float(p[10]),p[6]))
    L=[]
    for u,rs in by.items():
        cur=None
        for f,st,x,z,dr in rs:
            if st==3:
                if cur is None: cur=[f,x,z,x,z,0.0,f]
                else:
                    cur[5]+=math.hypot(x-cur[3],z-cur[4]); cur[3]=x; cur[4]=z; cur[6]=f
            elif cur is not None:
                L.append((cur[5],(cur[6]-cur[0]+1))); cur=None
    if not L: continue
    d=sorted(a for a,b in L)
    n=len(d)
    print("%-28s attacks=%3d travel p50 %.2f p90 %.2f max %.2f m; >1.5 m: %d; frames p50 %d" % (path.split('/')[-2]+'/'+path.split('/')[-1], n, d[n//2], d[int(n*.9)], d[-1], sum(1 for x in d if x>1.5), sorted(b for a,b in L)[n//2]))
