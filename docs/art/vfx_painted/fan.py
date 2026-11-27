# usage: python3 -I fan.py in.png out.png  (smash) per cell: find the top of the outer arc (centre band) and the bbox
# x-centre, estimate the fan radius R from frame 1 (half width / cos30), then move the pivot (top+R) to the cell
# centre and scale so the outer radius is 230 px. Also crushes the near-black to 0 like register.py.
import subprocess,sys,math
src,dst=sys.argv[1],sys.argv[2]; W,H=1536,1024; LO=12
raw=subprocess.run(['ffmpeg','-v','error','-i',src,'-vf','scale=1536:1024','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True).stdout
out=bytearray(W*H*3); R=None; prev=None; prev_xs=[]
def lit(x,y): i=(y*W+x)*3; return max(raw[i:i+3])>60
for c in range(6):
    cx,cy=(c%3)*512,(c//3)*512
    tops=[y for x in range(cx+226,cx+287,4) for y in range(cy,cy+512) if lit(x,y)][:0] or [next((y for y in range(cy,cy+512) if lit(x,y)),None) for x in range(cx+206,cx+307,4)]
    tops=[t-cy for t in tops if t is not None]; ty=sorted(tops)[len(tops)//4] if tops else 26
    xs=[x-cx for y in range(cy,cy+512,3) for x in range(cx,cx+512,3) if lit(x,y)]
    bx=(min(xs)+max(xs))/2
    if R is None: R=(max(xs)-min(xs))/2/math.cos(math.radians(30))
    px,py=bx,ty+R; k=R/230
    if len(xs)<len(prev_xs)*0.35: px,py=prev  # sparse last frame: keep the row's pivot
    prev=(px,py); prev_xs=xs
    print(f"cell{c+1}: top={ty} xcentre={bx:.0f} R={R:.0f} pivot=({px:.0f},{py:.0f})")
    for y in range(512):
        sy=round(py+(y-256)*k)
        if not 0<=sy<512: continue
        for x in range(512):
            sx=round(px+(x-256)*k)
            if not 0<=sx<512: continue
            i=((cy+sy)*W+cx+sx)*3; o=((cy+y)*W+cx+x)*3
            for q in range(3):
                v=raw[i+q]; out[o+q]=0 if v<=LO else min(255,(v-LO)*255//(255-LO))
subprocess.run(['ffmpeg','-v','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1536x1024','-i','-',dst],input=bytes(out))
