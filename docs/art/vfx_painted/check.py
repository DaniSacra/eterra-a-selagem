# usage: python3 -I check.py sheet.png  -> per-cell bbox of lit pixels, outer extent from cell centre, bg stats, colour
import subprocess,sys,math
f=sys.argv[1]; W,H=1536,1024
raw=subprocess.run(['ffmpeg','-v','error','-i',f,'-vf','scale=1536:1024','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True).stdout
def px(x,y):
    i=(y*W+x)*3; return raw[i],raw[i+1],raw[i+2]
bgmax=0; sat=0; lit=0
for c in range(6):
    cx,cy=(c%3)*512,(c//3)*512
    xs=[];ys=[];edge=0;far=0;n=0
    for y in range(cy,cy+512,2):
        for x in range(cx,cx+512,2):
            r,g,b=px(x,y); v=max(r,g,b)
            if v>40:
                n+=1; xs.append(x-cx); ys.append(y-cy)
                d=math.hypot(x-cx-256,y-cy-256); far=max(far,d)
                if x-cx<6 or y-cy<6 or x-cx>505 or y-cy>505: edge+=1
                if v>60 and (v-min(r,g,b))>0.45*v: sat+=1
                if b>r+12 or (g>r+12 and g>b+12): sat+=1
            elif v>0: bgmax=max(bgmax,v)
    if n: print(f"cell{c+1}: n={n} bbox x{min(xs)}-{max(xs)} y{min(ys)}-{max(ys)} bboxcentre=({(min(xs)+max(xs))//2},{(min(ys)+max(ys))//2}) maxdist={far:.0f} edgepx={edge}")
    else: print(f"cell{c+1}: empty")
print("bg max (<=40):",bgmax," off-colour px:",sat)
