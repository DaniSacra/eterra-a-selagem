# usage: python3 -I point.py in.png out.png scale  (hit spark) per cell: find the core (centroid of the brightest blob),
# move it to the cell centre and scale by 'scale' (cells with no core keep the previous cell's core). Crushes near-black.
import subprocess,sys
src,dst,S=sys.argv[1],sys.argv[2],float(sys.argv[3]); W,H=1536,1024; LO=12
raw=subprocess.run(['ffmpeg','-v','error','-i',src,'-vf','scale=1536:1024','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True).stdout
out=bytearray(W*H*3); prev=(256,256)
for c in range(6):
    cx,cy=(c%3)*512,(c//3)*512
    pts=[(x,y) for y in range(512) for x in range(512) if sum(raw[((cy+y)*W+cx+x)*3:((cy+y)*W+cx+x)*3+3])>660]
    # the core is round: keep the densest cluster (pixels within 30 px of the brightest pixels' median)
    if len(pts)>15:
        mx=sorted(p[0] for p in pts)[len(pts)//2]; my=sorted(p[1] for p in pts)[len(pts)//2]
        cl=[p for p in pts if abs(p[0]-mx)<30 and abs(p[1]-my)<30]
        core=(sum(p[0] for p in cl)/len(cl),sum(p[1] for p in cl)/len(cl)) if len(cl)>15 else prev
    else: core=prev
    print(f"cell{c+1}: core=({core[0]:.0f},{core[1]:.0f}) bright={len(pts)}"); prev=core
    for y in range(512):
        sy=round(core[1]+(y-256)/S)
        if not 0<=sy<512: continue
        for x in range(512):
            sx=round(core[0]+(x-256)/S)
            if not 0<=sx<512: continue
            i=((cy+sy)*W+cx+sx)*3; o=((cy+y)*W+cx+x)*3
            for q in range(3):
                v=raw[i+q]; out[o+q]=0 if v<=LO else min(255,(v-LO)*255//(255-LO))
subprocess.run(['ffmpeg','-v','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1536x1024','-i','-',dst],input=bytes(out))
