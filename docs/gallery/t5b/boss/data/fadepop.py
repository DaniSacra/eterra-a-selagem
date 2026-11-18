import sys, collections, math
for path in sys.argv[1:]:
    prev={}
    c=collections.Counter(); w=collections.defaultdict(float); ex={}
    for line in open(path):
        p=line.rstrip().split(",")
        if p[0]=="f" or p[1]=="HIT" or len(p)<29: continue
        f=int(p[0]); k=(p[1],p[2])
        rx=float(p[11])-float(p[9]); rz=float(p[13])-float(p[10]); ry=float(p[12])
        ra,rb=p[26],p[27]
        fading = ra.split(":")[0]!=rb.split(":")[0]
        if k in prev and prev[k][0]==f-1:
            _,px,pz,py,pra,prb=prev[k]
            rel=math.hypot(rx-px,rz-pz); vy=abs(ry-py)
            if rel>0.12 or vy>0.12:
                tag=(p[1], "fade" if fading else "clip", (prb if fading else rb).split(":")[0])
                c[tag]+=1; 
                if max(rel,vy)>w[tag]: w[tag]=max(rel,vy); ex[tag]=(f,pra+">"+prb,ra+">"+rb)
        prev[k]=(f,rx,rz,ry,ra,rb)
    print("==",path.split("/")[-1])
    for t,n in c.most_common(25): print("  %-40s %4d worst %.2f m/frame %s"%("/".join(t),n,w[t],ex[t]))
