# usage: python3 -I register.py in.png out.png [fit]  -> crush the near-black to 0 (levels 12..255) and, with 'fit',
# move each cell so the circle fitted to its OUTER edge is centred in the cell (arcs only). Prints centre/radius per cell.
import subprocess,sys,math
src,dst=sys.argv[1],sys.argv[2]; fit=len(sys.argv)>3; fixr=len(sys.argv)>3 and sys.argv[3]=='fitR'; scl=len(sys.argv)>3 and sys.argv[3]=='fitscale'; R0=None; W,H=1536,1024; LO=12
raw=subprocess.run(['ffmpeg','-v','error','-i',src,'-vf','scale=1536:1024','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True).stdout
out=bytearray(W*H*3)
def solve(A,b):
    n=3; M=[A[i]+[b[i]] for i in range(n)]
    for i in range(n):
        p=max(range(i,n),key=lambda r:abs(M[r][i])); M[i],M[p]=M[p],M[i]
        for r in range(n):
            if r!=i:
                f=M[r][i]/M[i][i]; M[r]=[M[r][k]-f*M[i][k] for k in range(n+1)]
    return [M[i][n]/M[i][i] for i in range(n)]
for c in range(6):
    cx,cy=(c%3)*512,(c//3)*512; dx=dy=0; k_=1.0
    if fit:
        bins={}
        for y in range(0,512,2):
            for x in range(0,512,2):
                i=((cy+y)*W+cx+x)*3
                if max(raw[i:i+3])>60:
                    a=int((math.degrees(math.atan2(y-256,x-256))+360)%360)//3; d=math.hypot(x-256,y-256)
                    if d>bins.get(a,(0,0,0))[0]: bins[a]=(d,x,y)
        md=max([v[0] for v in bins.values()] or [0]); pts=[(x,y) for d,x,y in bins.values() if d>0.85*md]
        if len(pts)>8:
            Sxx=sum(x*x for x,y in pts);Syy=sum(y*y for x,y in pts);Sxy=sum(x*y for x,y in pts);Sx=sum(x for x,y in pts);Sy=sum(y for x,y in pts);n=len(pts)
            Sz=[x*x+y*y for x,y in pts]
            A=[[Sxx,Sxy,Sx],[Sxy,Syy,Sy],[Sx,Sy,n]]; b=[sum(z*x for z,(x,y) in zip(Sz,pts)),sum(z*y for z,(x,y) in zip(Sz,pts)),sum(Sz)]
            a1,a2,a3=solve(A,b); ox,oy=a1/2,a2/2; r=math.sqrt(a3+ox*ox+oy*oy)
            if fixr and R0 is not None:
                best=None
                for ty in range(-80,81,2):
                    for tx in range(-80,81,2):
                        e=sum(abs(math.hypot(x-256-tx,y-256-ty)-R0) for x,y in pts)
                        if best is None or e<best[0]: best=(e,tx,ty)
                ox,oy,r=256+best[1],256+best[2],R0
            dx,dy=round(256-ox),round(256-oy)
            if R0 is None: R0=r
            if scl: k_=r/R0
            print(f"cell{c+1}: outer circle centre=({ox:.0f},{oy:.0f}) r={r:.0f} shift=({dx},{dy}) bins={n}")
    for y in range(512):
        sy=round(256+(y-256)*k_)-dy
        if not 0<=sy<512: continue
        for x in range(512):
            sx=round(256+(x-256)*k_)-dx
            if not 0<=sx<512: continue
            i=((cy+sy)*W+cx+sx)*3; o=((cy+y)*W+cx+x)*3
            for k in range(3):
                v=raw[i+k]; out[o+k]=0 if v<=LO else min(255,(v-LO)*255//(255-LO))
subprocess.run(['ffmpeg','-v','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1536x1024','-i','-',dst],input=bytes(out))
