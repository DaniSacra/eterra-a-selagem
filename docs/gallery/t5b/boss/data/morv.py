import sys, collections, math
NAMES="ENTER CHASE SCYTHE BLADES STORM ERUPTIONS CURSE SUMMON DASH_WARN DASH ROAR TO_CENTER RITUAL STUNNED DYING RECOVER".split()
FWD=(-0.574,-0.819)  # camera forward on the floor
def ad(a,b): return (a-b+180)%360-180
for path in sys.argv[1:]:
    rs=[]
    for line in open(path):
        p=line.split(",")
        if p[0]=="f" or p[1]!="morvath": continue
        rs.append(dict(f=int(p[0]),yaw=float(p[18]),bst=int(p[21]) if p[21]!="-" else -1,atk=p[22],px=float(p[9]),pz=float(p[10]),dx=float(p[11]),dz=float(p[13]),hx=float(p[19]),hz=float(p[20]),drawn=p[6]))
    snaps=collections.Counter(); worst=collections.defaultdict(float); back=collections.Counter(); tot=collections.Counter(); simj=[]
    awayhero=collections.Counter()
    for a,b in zip(rs,rs[1:]):
        if b["f"]!=a["f"]+1: continue
        d=abs(ad(b["yaw"],a["yaw"]))
        key=NAMES[a["bst"]]+">"+NAMES[b["bst"]] if a["bst"]!=b["bst"] else NAMES[b["bst"]]
        if d>25: snaps[key]+=1; worst[key]=max(worst[key],d)
        y=math.radians(b["yaw"]); fx,fz=math.sin(y),math.cos(y)
        nm=NAMES[b["bst"]]; tot[nm]+=1
        if fx*FWD[0]+fz*FWD[1]>0.5: back[nm]+=1
        hx,hz=b["hx"]-b["px"],b["hz"]-b["pz"]; L=math.hypot(hx,hz) or 1
        if (fx*hx+fz*hz)/L < 0.0: awayhero[nm]+=1
        s=math.hypot(b["px"]-a["px"],b["pz"]-a["pz"])
        if s>0.3: simj.append((b["f"],nm,round(s,2)))
    print("==",path.split("/")[-2]+"/"+path.split("/")[-1],"frames",len(rs))
    print("  yaw snaps >25 deg in 1 frame:", ", ".join("%s %d (max %.0f)"%(k,v,worst[k]) for k,v in snaps.most_common()))
    print("  back to camera (facing within 60 deg of camera forward) %:", ", ".join("%s %.0f%%/%d"%(k,100*back[k]/tot[k],tot[k]) for k in tot if tot[k]>30))
    print("  facing away from hero %:", ", ".join("%s %.0f%%"%(k,100*awayhero[k]/tot[k]) for k in tot if tot[k]>30))
    print("  sim steps >0.3 m/frame:", collections.Counter(n for f,n,s in simj).most_common(), "max", max([s for f,n,s in simj] or [0]))
