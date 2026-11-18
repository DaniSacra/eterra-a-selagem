import sys, collections
for path in sys.argv[1:]:
    tot=collections.Counter(); air=collections.Counter(); walk=collections.Counter(); hi=collections.defaultdict(list)
    for line in open(path):
        p=line.split(",")
        if p[0]=="f" or p[1]=="HIT": continue
        k=p[1]; clip=p[6].split(":")[0]
        tot[k]+=1
        if p[3]=="1" and clip=="walk": walk[k]+=1
        if float(p[14])>0.12 and p[3]!="4": air[k]+=1
        hi[(k,clip)].append(float(p[15]))
    s=" ".join("%s: %d/%d frames off floor (%.0f%%), walk %d" % (k, air[k], tot[k], 100*air[k]/max(1,tot[k]), walk[k]) for k in ("skeleton","mage"))
    print("%-18s %s" % (path.split("/")[-2]+"/"+path.split("/")[-1], s))
