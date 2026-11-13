"""The paladin: idle, run, one animation per move of the combo tree, charge, dodge, hurt and death."""
import math

from px import Cv, Sheet
from rig import humanoid, legs, lying

ARMOR = ("S0", "S1", "S2")
OUT = "N4"


def _cape(geo):
    c, tx, ty, g, p = geo["c"], geo["tx"], geo["ty"], geo["g"], geo["p"]
    sway = p.get("cape", 0)
    n = g - ty - 1
    for i in range(n):
        w = 2 + (i * (2 + sway)) // 4
        y = ty + i
        c.rect(tx - w + 1, y, w, 1, "N1")
        c.put(tx - w + 1, y, "N0" if i < 3 else "N1")
        if i == n - 1:
            c.rect(tx - w + 1, y, w, 1, "N2")


def _legs(geo):
    legs(geo, ("N2", "S1", "S2"), "N3")


def _torso(geo):
    c, tx, ty, tw, th = geo["c"], geo["tx"], geo["ty"], geo["tw"], geo["th"]
    c.box(tx, ty, tw, th, ARMOR)
    c.rect(tx + 2, ty + 1, 2, 2, "L1")  # the lion's gold on the chest
    c.rect(tx, ty + th - 2, tw, 1, "L3")
    c.rect(tx, ty + th - 1, tw, 1, "N1")
    c.put(tx + tw - 1, ty + th - 1, "N2")


def _head(geo):
    c, x, y, p = geo["c"], geo["hx"], geo["hy"], geo["p"]
    c.rect(x + 1, y, 6, 1, "S1")
    c.rect(x + 1, y, 3, 1, "S0")
    c.rect(x, y + 1, 8, 1, "S1")
    c.rect(x, y + 1, 3, 1, "S0")
    c.put(x + 7, y + 1, "S2")
    c.rect(x, y + 2, 3, 1, "S1")
    c.rect(x + 3, y + 2, 5, 1, "L1")
    c.put(x + 7, y + 2, "L3")
    for r in (3, 4, 5):
        c.rect(x, y + r, 3 if r < 5 else 2, 1, "S1" if r == 3 else "S2")
        c.rect(x + (3 if r < 5 else 2), y + r, 5 if r < 5 else 6, 1, "T0")
    c.put(x + 7, y + 5, "T1")
    c.rect(x + 1, y + 6, 2, 1, "S2")
    c.rect(x + 3, y + 6, 4, 1, "T1")
    if p.get("hurt"):
        c.rect(x + 4, y + 4, 1, 1, "T2")
        c.rect(x + 6, y + 4, 1, 1, "T2")
        c.put(x + 5, y + 5, "P1")
    else:
        c.put(x + 4, y + 4, "N4")
        c.put(x + 6, y + 4, "N4")
    # red plume, trailing behind
    s = p.get("cape", 0)
    c.rect(x + 2, y - 1, 2, 1, "P0")
    c.put(x + 1, y - 1, "P1")
    c.put(x, y - (0 if s == 0 else 1), "P1")
    c.put(x - 1, y + (1 if s == 0 else 0), "P2")


def _sword(geo, hand, ang):
    c, p = geo["c"], geo["p"]
    n = p.get("blade", 8)
    glow = p.get("glow", 0)
    c.ray(hand[0], hand[1], ang, n, "L1" if glow else "S0", 1)
    a = math.radians(ang)
    c.put(hand[0] + math.cos(a) * n, hand[1] - math.sin(a) * n, "L0" if glow else "W0")
    # gold guard across the blade
    gx, gy = hand[0] + math.cos(a) * 1.2, hand[1] - math.sin(a) * 1.2
    c.put(gx - math.sin(a), gy - math.cos(a), "L2")
    c.put(gx + math.sin(a), gy + math.cos(a), "L2")
    c.put(hand[0], hand[1], "L3")


STYLE = dict(size=32, head=(8, 7), torso=(6, 6), legs=4, outline=OUT, arm="S2",
             cape=_cape, legs_fn=_legs, torso_fn=_torso, head_fn=_head, weapon=_sword)


def pose(**p):
    return humanoid(STYLE, **p)


def swing(angles, **common):
    return [pose(sword=a, **{**common, **(extra or {})}) for a, extra in angles]


def roll(i):
    """Dodge: the paladin tucked into a rolling ball of armour and cape."""
    c = Cv(32, 32)
    cx, cy = 16, 22
    c.ell(cx, cy, 5.2, 4.6, ARMOR)
    a0 = i * 120
    for k in range(0, 150, 12):
        a = math.radians(a0 + k)
        c.put(cx + math.cos(a) * 4, cy - math.sin(a) * 3.5, "N1")
        c.put(cx + math.cos(a) * 3, cy - math.sin(a) * 2.5, "N2")
    a = math.radians(a0 + 200)
    c.put(cx + math.cos(a) * 4, cy - math.sin(a) * 3.5, "P0")
    c.put(cx + math.cos(a + 0.4) * 2, cy - math.sin(a + 0.4) * 2, "L1")
    c.outline(OUT)
    return c


def build():
    s = Sheet()
    s.add("idle", [pose(sword=-55), pose(sword=-55, bob=1, head_dy=0)], 3, True)
    s.add("run", [pose(run=i, sword=-35 + (12 if i % 2 else 0), bob=(-1 if i % 2 else 0), cape=1 + (i % 2), lean=1)
                  for i in range(4)], 11, True)
    # E E E E
    s.add("cut1", swing([(125, None), (15, dict(lean=1)), (-50, dict(lean=1))], cape=1), 16)
    s.add("cut2", swing([(-70, None), (25, dict(lean=1)), (105, dict(lean=1))], cape=1), 16)
    s.add("cut3", swing([(150, dict(lean=-1)), (0, dict(lean=2, arm=3)), (-65, dict(lean=2))], cape=2), 16)
    spin = swing([(0, dict(arm=3)), (90, dict(back=True))], cape=2, blade=9, glow=1)
    spin_back = swing([(0, dict(arm=3)), (-90, None)], cape=2, blade=9, glow=1)
    s.add("spin", [spin[0], spin[1], spin_back[0].flip(), spin_back[1], spin[0]], 18)
    # E E E D
    s.add("thrust", swing([(175, dict(lean=-1, back=True)), (0, dict(lean=2, arm=4, blade=10, glow=1)),
                           (0, dict(lean=2, arm=3, blade=10))], cape=2), 12)
    # E D
    s.add("launch", swing([(-85, dict(crouch=1)), (40, dict(lean=1)), (100, dict(bob=-1, glow=1)),
                           (110, dict(bob=-1))], cape=1), 14)
    # E E D
    s.add("cross", swing([(135, None), (-45, dict(lean=1, glow=1)), (45, dict(lean=1)), (-135, dict(lean=1, glow=1, back=True))],
                         cape=1), 16)
    # D D E
    s.add("heavy1", swing([(160, dict(lean=-1, crouch=1)), (100, dict(bob=-1)), (-30, dict(lean=2, arm=3)),
                           (-55, dict(lean=2, crouch=1))], cape=1, blade=9), 10)
    s.add("heavy2", swing([(200, dict(lean=-1, back=True)), (90, dict(bob=-1)), (-15, dict(lean=2, arm=3)),
                           (-35, dict(lean=1))], cape=2, blade=9), 10)
    s.add("wave", swing([(165, dict(lean=-1, back=True, glow=1)), (20, dict(lean=2, arm=3, glow=1)),
                         (5, dict(lean=1, glow=1)), (5, dict(lean=1))], cape=2, blade=9), 12)
    # D held
    s.add("charge", [pose(sword=165, crouch=1, lean=-1, back=True), pose(sword=165, crouch=1, lean=-1, back=True, glow=1)], 10, True)
    s.add("burst", swing([(95, dict(bob=-2, glow=1)), (-70, dict(crouch=1, lean=1, glow=1)),
                          (-80, dict(crouch=1, lean=1))], blade=9), 10)
    # dodge + E, dodge + D
    s.add("dash_cut", swing([(30, dict(lean=2, arm=3, glow=1)), (-25, dict(lean=2, arm=3))], cape=3, run=0), 10)
    s.add("slam", swing([(90, dict(bob=-2, glow=1)), (-90, dict(crouch=1, lean=1, glow=1)),
                         (-90, dict(crouch=1, lean=1))], blade=9), 10)
    s.add("dodge", [roll(0), roll(1), roll(2)], 16, True)
    s.add("hurt", [pose(sword=-100, lean=-2, hurt=1, cape=0)], 8)
    kneel = pose(sword=-90, crouch=2, lean=1, hurt=1)
    s.add("death", [pose(sword=-100, lean=-2, hurt=1), kneel, lying(pose(sword=None, hurt=1))], 5)
    s.save("paladin", origin=[16, 27])
