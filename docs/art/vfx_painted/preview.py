# usage: python3 -I preview.py sheet.png cols rows frames life_ms cell_px out.gif
# Animated preview: the sheet tinted with the guide's colours (edge #F2B84D, body #FFD161, core #F4EEDC, core added on top)
# over a dark floor crop of assets/rooms/painted/sala01.png. Plays at the real timing, pauses, then 4x slower, pauses.
import subprocess,sys
sheet,C,R,N,LIFE,S,out=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]),int(sys.argv[4]),float(sys.argv[5]),int(sys.argv[6]),sys.argv[7]
FW,FH=640,400; FLOOR='/home/dani/games/eterra-a-selagem/assets/rooms/painted/sala01.png'
floor=subprocess.run(['ffmpeg','-v','error','-i',FLOOR,'-vf',f'crop={FW}:{FH}:450:330','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True).stdout
def cell(i):
    x,y=(i%C)*512,(i//C)*512
    return subprocess.run(['ffmpeg','-v','error','-i',sheet,'-vf',f'crop=512:512:{x}:{y},scale={S}:{S}:flags=area','-f','rawvideo','-pix_fmt','gray','-'],capture_output=True).stdout
EDGE,BODY,CORE=(0xF2,0xB8,0x4D),(0xFF,0xD1,0x61),(0xF4,0xEE,0xDC)
def lerp(a,b,t): return tuple(a[k]+(b[k]-a[k])*t for k in range(3))
lut=[]
for v in range(256):
    t=v/255; col=lerp(EDGE,BODY,min(1,t/0.6)) if t<0.85 else lerp(BODY,CORE,(t-0.85)/0.15)
    a=min(1.0,t*1.2); add=max(0.0,(t-0.85)/0.15)*0.25
    lut.append((col,a,add))
ox,oy=(FW-S)//2,(FH-S)//2; cache={}
def comp(i):
    if i in cache: return cache[i]
    f=bytearray(floor)
    if i is not None:
        g=cell(i)
        for y in range(S):
            for x in range(S):
                v=g[y*S+x]
                if v<=4: continue
                col,a,add=lut[v]; o=((oy+y)*FW+ox+x)*3
                for k in range(3): f[o+k]=min(255,int(f[o+k]*(1-a)+col[k]*a+255*add))
    cache[i]=bytes(f); return cache[i]
seq=[]
for slow in (1,4):
    t=0
    while t<LIFE*slow: seq.append(min(N-1,int(t/(LIFE*slow)*N))); t+=20
    seq+= [None]*(30 if slow==1 else 40)
frames=b''.join(comp(i) for i in seq)
subprocess.run(['ffmpeg','-v','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s',f'{FW}x{FH}','-r','50','-i','-','-filter_complex','split[a][b];[a]palettegen=max_colors=192[p];[b][p]paletteuse=dither=bayer','-loop','0',out],input=frames,check=True)
print(out,len(seq),'gif frames')
