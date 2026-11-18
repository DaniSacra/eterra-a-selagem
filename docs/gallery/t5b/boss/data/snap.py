import sys, collections, math
ST={0:"RISE",1:"WALK",2:"WINDUP",3:"ATTACK",4:"DEAD",5:"RECOVER"}
for path in sys.argv[1:]:
    rows=collections.defaultdict(dict); 
    for line in open(path):
        p=line.split(",")
        if p[0]=="f" or p[1]=="HIT": continue
        rows[int(p[0])][(p[1],p[2])]=p
    c=collections.Counter(); mx=collections.defaultdict(float)
    for f in sorted(rows):
        if f-1 not in rows: continue
        m=[v for k,v in rows[f].items() if k[0]=="morvath"]
        for k,p in rows[f].items():
            if k[0]=="morvath" or k not in rows[f-1]: continue
            q=rows[f-1][k]
            s=math.hypot(float(p[9])-float(q[9]),float(p[10])-float(q[10]))
            if s>0.12 and p[3]!="3":
                nearb = bool(m) and math.hypot(float(p[9])-float(m[0][9]),float(p[10])-float(m[0][10]))<2.4
                hero=math.hypot(float(p[9])-float(p[19]),float(p[10])-float(p[20]))<1.3
                hurt=float(p[8])>0 or float(p[7])>0
                key=(k[0],ST[int(p[3])],"nearMorvath" if nearb else "", "nearHero" if hero else "", "hurt/stun" if hurt else "")
                c[key]+=1; mx[key]=max(mx[key],s)
    print("==",path.split('/')[-2]+'/'+path.split('/')[-1])
    for k,v in c.most_common(12): print("   %-55s %4d  max %.2f m/frame"%(" ".join(x for x in k if x),v,mx[k]))
