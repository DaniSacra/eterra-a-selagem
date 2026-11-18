"""T5b P1-4 and P2-1 after: Morvath's drawn turn (drawn_probe CSVs).

The most his drawn body turns in one frame (degrees; the review's limit 15) and how many frames turn more than 15, and
per state the share of frames he faces more than 90 degrees away from the paladin (P2-1: ERUPTIONS, SUMMON, STORM and
RECOVER at most 10%).
python3 morvturn.py run.csv ...
"""
import sys, collections, math

NAMES = "ENTER CHASE SCYTHE BLADES STORM ERUPTIONS CURSE SUMMON DASH_WARN DASH ROAR TO_CENTER RITUAL STUNNED DYING RECOVER".split()
for path in sys.argv[1:]:
    rs = []
    for line in open(path):
        p = line.split(",")
        if p[0] == "f" or p[1] != "morvath":
            continue
        rs.append((int(p[0]), float(p[18]), int(p[21]) if p[21] != "-" else -1, float(p[9]), float(p[10]), float(p[19]), float(p[20])))
    worst = 0.0
    over = collections.Counter()
    tot = collections.Counter(); away = collections.Counter()
    for a, b in zip(rs, rs[1:]):
        if b[0] != a[0] + 1 or b[2] == 14:
            continue
        d = abs((b[1] - a[1] + 180) % 360 - 180)
        if d > worst:
            worst = d
        if d > 15:
            over[NAMES[b[2]]] += 1
        y = math.radians(b[1])
        hx, hz = b[5] - b[3], b[6] - b[4]
        L = math.hypot(hx, hz) or 1
        nm = NAMES[b[2]]
        tot[nm] += 1
        if (math.sin(y) * hx + math.cos(y) * hz) / L < 0.0:
            away[nm] += 1
    print("== %s: worst turn %.1f deg a frame; frames over 15: %s" % (path.split("/")[-1], worst, dict(over) or 0))
    print("   facing away (>90 deg) from the paladin: " + ", ".join("%s %.0f%%" % (k, 100 * away[k] / tot[k]) for k in NAMES if tot[k] > 30))
