#!/bin/bash
# usage: uncrop.sh in_crop.png out.png  (crop painting of base x180 y120 1500x1000 -> 1536x1024 plate, uniform mapping 938/1024;
# margins = the crop's border pixels smeared outward and blurred smooth, crop pasted with a 70 px feather)
ffmpeg -loglevel error -y -i $1 -filter_complex "[0]scale=1198:798,split[x][y];[x]pad=1536:1024:144:96,fillborders=left=144:right=194:top=96:bottom=130:mode=smear,gblur=sigma=70[b];[y]pad=1536:1024:144:96,format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255*clip(min(min(X-144,1342-X),min(Y-96,894-Y))/70,0,1)'[f];[b][f]overlay=0:0,format=rgb24" $2
