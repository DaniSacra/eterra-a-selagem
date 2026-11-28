# usage: python3 -I drift.py painting.png base.png  -> per-block (dx,dy) in 1536x1024 px of painting relative to base
import subprocess, sys
W, H = 256, 170
def gray(p):
    raw = subprocess.run(["ffmpeg","-v","error","-i",p,"-vf",f"scale={W}:{H},format=gray","-f","rawvideo","-"],capture_output=True).stdout
    g = [raw[y*W:(y+1)*W] for y in range(H)]
    # gradient magnitude
    return [[abs(g[y][x+1]-g[y][x-1])+abs(g[y+1][x]-g[y-1][x]) if 0<x<W-1 and 0<y<H-1 else 0 for x in range(W)] for y in range(H)]
P, B = gray(sys.argv[1]), gray(sys.argv[2])
S, R = 32, 14
sc = 1536/W
for by in range(R+1, H-S-R, 22):
    row = []
    for bx in range(R+1, W-S-R, 30):
        best = None
        for dy in range(-R, R+1):
            for dx in range(-R, R+1):
                s = 0
                for y in range(by, by+S, 2):
                    pr = P[y+dy]; br = B[y]
                    for x in range(bx, bx+S, 2):
                        s += abs(pr[x+dx]-br[x])
                if best is None or s < best[0]: best = (s, dx, dy)
        row.append(f"({best[1]*sc:+4.0f},{best[2]*sc:+4.0f})")
    print(f"y{(by+S/2)*sc/1024*100:3.0f}%", " ".join(row))
