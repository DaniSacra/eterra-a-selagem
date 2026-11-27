#!/bin/bash
# usage: luma.sh room image.png -> mean luma (0-255) of the floor-centre box of a 1536x1024 painting
case $1 in sala01) C=300:150:620:420;; sala00) C=180:120:560:560;; antessala) C=250:100:450:600;; esac
ffmpeg -loglevel info -i "$2" -vf "scale=1536:1024,crop=$C,format=gray,signalstats,metadata=print:key=lavfi.signalstats.YAVG" -f null - 2>&1 | grep -o 'YAVG=[0-9.]*' | head -1
