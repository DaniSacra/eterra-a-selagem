"""Enemies of the catacombs: skeleton, skeleton archer, frost wolf, grey hooded, and the two elites."""
import math

from px import Cv, Sheet
from rig import humanoid, legs

BONE = ("S0", "S1", "S2")
BONE_OUT = "S4"
DARK_OUT = "P4"


# ---------- skeleton ----------
def _skull(geo):
    c, x, y, p = geo["c"], geo["hx"], geo["hy"], geo["p"]
    c.rect(x + 1, y, 5, 1, "S0")
    c.rect(x, y + 1, 7, 3, "S1")
    c.rect(x, y + 1, 2, 2, "S0")
    c.put(x + 6, y + 3, "S2")
    c.rect(x + 3, y + 2, 1, 2, "N4")  # eye sockets, looking right
    c.rect(x + 5, y + 2, 1, 2, "N4")
    if p.get("angry"):
        c.put(x + 3, y + 3, "P0")
        c.put(x + 5, y + 3, "P0")
    c.rect(x + 2, y + 4, 5, 1, "S2")
    c.rect(x + 2, y + 5, 4, 1, "S1")
    c.put(x + 3, y + 5, "N4")
    c.put(x + 5, y + 5, "N4")


def _ribs(geo):
    c, tx, ty, tw, th = geo["c"], geo["tx"], geo["ty"], geo["tw"], geo["th"]
    for i in range(th):
        if i % 2 == 0:
            c.rect(tx, ty + i, tw, 1, "S1")
            c.put(tx, ty + i, "S0")
            c.put(tx + tw - 1, ty + i, "S2")
        else:
            c.put(tx + tw // 2, ty + i, "S2")
    c.rect(tx + 1, ty + th - 1, tw - 2, 1, "S2")


def _bone_legs(geo):
    legs(geo, ("S1", "S2"), "S1", width=1)


def _rusty(geo, hand, ang):
    c = geo["c"]
    n = geo["p"].get("blade", 6)
    c.ray(hand[0], hand[1], ang, n, "T5", 1)
    a = math.radians(ang)
    c.put(hand[0] + math.cos(a) * n, hand[1] - math.sin(a) * n, "S0")
    c.put(hand[0], hand[1], "T3")


def _bow(geo, hand, ang):
    c, p = geo["c"], geo["p"]
    x, y = hand
    for i in range(-4, 5):
        c.put(x + 2 - (abs(i) // 2), y + i, "T3")
    pull = p.get("pull", 0)
    c.line(x + 1 - pull, y, x, y - 4, "S2")
    c.line(x + 1 - pull, y, x, y + 4, "S2")
    if pull:
        c.rect(x - pull, y, 5 + pull, 1, "T1")
        c.put(x + 5, y, "S0")


SKELETON = dict(size=32, head=(7, 6), torso=(5, 5), legs=4, outline=BONE_OUT, arm="S2",
                legs_fn=_bone_legs, torso_fn=_ribs, head_fn=_skull, weapon=_rusty)
ARCHER = dict(SKELETON, weapon=_bow)


def skeleton():
    s = Sheet()
    s.add("walk", [humanoid(SKELETON, run=i, sword=40 + (15 if i % 2 else 0), bob=(-1 if i % 2 else 0)) for i in range(4)], 7, True)
    s.add("attack", [humanoid(SKELETON, sword=120, lean=-1, angry=1), humanoid(SKELETON, sword=-20, lean=1, angry=1)], 6)
    s.add("rise", [humanoid(SKELETON, sword=None, crouch=3, dy=4), humanoid(SKELETON, sword=None, crouch=2, dy=2),
                   humanoid(SKELETON, sword=60)], 8)
    s.save("skeleton", origin=[16, 27])


def archer():
    s = Sheet()
    s.add("walk", [humanoid(ARCHER, run=i, sword=0, bob=(-1 if i % 2 else 0)) for i in range(4)], 7, True)
    s.add("attack", [humanoid(ARCHER, sword=0, pull=2, lean=-1, angry=1), humanoid(ARCHER, sword=0, pull=3, lean=-1, angry=1),
                     humanoid(ARCHER, sword=0)], 6)
    s.save("archer", origin=[16, 27])


# ---------- grey hooded ----------
def _hood(geo):
    c, x, y, p = geo["c"], geo["hx"], geo["hy"], geo["p"]
    w = geo["hw"]
    c.rect(x + 2, y - 1, w - 5, 1, "T5")  # pointed hood
    c.rect(x + 1, y, w - 2, 1, "T5")
    c.rect(x, y + 1, w, geo["hh"] - 2, "T6")
    c.rect(x, y + 1, 2, 3, "T5")
    c.rect(x + 1, y + geo["hh"] - 1, w - 2, 1, "T7")
    c.rect(x + 3, y + 2, w - 3, geo["hh"] - 4, "P4")  # the dark under the hood
    c.put(x + w - 3, y + 3, "P0" if not p.get("cast") else "M0")  # one eye shows
    c.put(x + w - 1, y + 3, "P0" if not p.get("cast") else "M0")


def _robe(geo):
    c, tx, ty, tw, th, g, p = geo["c"], geo["tx"], geo["ty"], geo["tw"], geo["th"], geo["g"], geo["p"]
    c.box(tx, ty, tw, th, ("T5", "T6", "T7"))
    c.rect(tx + tw // 2, ty, 1, th, "T7")
    c.rect(tx, ty + th - 2, tw, 1, st_trim(p))


def st_trim(p):
    return p.get("trim", "P1")


def _robe_legs(geo):
    c, tx, tw, g, lh, p = geo["c"], geo["tx"], geo["tw"], geo["g"], geo["lh"], geo["p"]
    sway = {None: 0, 0: 1, 1: 0, 2: -1, 3: 0}[p.get("run")]
    for i in range(lh + 1):
        y = g - lh + i
        w = tw + (i + 1) // 2
        x = tx - (i + 1) // 4 + (sway if i > lh // 2 else 0)
        c.rect(x, y, w, 1, "T6")
        c.put(x, y, "T5")
        c.put(x + w - 1, y, "T7")
    c.rect(tx - 1 + sway, g, tw + 2, 1, "T7")


def _curved(geo, hand, ang):
    c, p = geo["c"], geo["p"]
    if p.get("cast"):
        c.put(hand[0], hand[1] - 1, "M0")
        c.put(hand[0] + 1, hand[1] - 2, "M1")
        c.put(hand[0] - 1, hand[1] - 2, "M1")
        c.put(hand[0], hand[1] - 3, "M0")
        return
    a = math.radians(ang)
    for i in range(1, 6):
        bend = (i * i) / 10.0
        c.put(hand[0] + math.cos(a) * i - math.sin(a) * bend, hand[1] - math.sin(a) * i - math.cos(a) * bend, "S1" if i < 5 else "S0")


def _staff(geo, hand, ang):
    c, p = geo["c"], geo["p"]
    x, y = hand
    c.rect(x, y - 9, 1, 16, "T4")
    orb = "P0" if not p.get("cast") else "M0"
    c.rect(x - 1, y - 12, 3, 3, orb)
    c.put(x - 1, y - 12, "W0" if p.get("cast") else "L0")
    c.put(x + 1, y - 10, "P1" if not p.get("cast") else "M1")


HOODED = dict(size=32, head=(7, 7), torso=(6, 5), legs=4, outline=DARK_OUT, arm="T7",
              legs_fn=_robe_legs, torso_fn=_robe, head_fn=_hood, weapon=_curved)
PRIEST = dict(size=48, head=(10, 9), torso=(8, 8), legs=7, outline=DARK_OUT, arm="T7",
              legs_fn=_robe_legs, torso_fn=_robe, head_fn=_hood, weapon=_staff)


def hooded():
    s = Sheet()
    s.add("walk", [humanoid(HOODED, run=i, sword=50, bob=(-1 if i % 2 else 0)) for i in range(4)], 6, True)
    s.add("attack", [humanoid(HOODED, sword=90, cast=1, bob=-1), humanoid(HOODED, sword=80, cast=1)], 6, True)
    s.save("hooded", origin=[16, 27])


def priest():
    s = Sheet()
    s.add("walk", [humanoid(PRIEST, run=i, sword=10, bob=(-1 if i % 2 else 0), trim="M1") for i in range(4)], 5, True)
    s.add("attack", [humanoid(PRIEST, sword=60, cast=1, bob=-1, trim="M1"), humanoid(PRIEST, sword=75, cast=1, bob=-2, trim="M0")], 5, True)
    s.save("priest", origin=[24, 43])


# ---------- skeleton knight (elite) ----------
def _helm(geo):
    c, x, y, p = geo["c"], geo["hx"], geo["hy"], geo["p"]
    w, h = geo["hw"], geo["hh"]
    c.rect(x + 1, y, w - 2, 1, "T5")
    c.rect(x, y + 1, w, h - 2, "T6")
    c.rect(x, y + 1, 3, 3, "T5")
    c.rect(x + w - 1, y + 2, 1, h - 3, "T7")
    c.rect(x + 1, y + h - 1, w - 2, 1, "T7")
    c.rect(x + 3, y + 4, w - 3, 2, "P4")  # visor slit
    c.put(x + w - 4, y + 4, "P0")
    c.put(x + w - 2, y + 4, "P0")
    c.rect(x + 4, y - 2, 2, 2, "P1")  # torn crest
    c.put(x + 3, y - 3, "P1")
    c.put(x + 2, y - 2, "P2")
    c.put(x - 1, y + 1, "S1")  # horn
    c.put(x - 2, y, "S0")


def _plate(geo):
    c, tx, ty, tw, th = geo["c"], geo["tx"], geo["ty"], geo["tw"], geo["th"]
    c.box(tx, ty, tw, th, ("T5", "T6", "T7"))
    c.rect(tx + 2, ty + 2, tw - 4, th - 4, "P1")  # faded tabard
    c.rect(tx + 3, ty + 3, tw - 6, 1, "P0")
    c.rect(tx, ty + th - 2, tw, 1, "T7")
    c.rect(tx - 1, ty, 3, 3, "T5")  # pauldrons
    c.rect(tx + tw - 2, ty, 3, 3, "T6")


def _greaves(geo):
    legs(geo, ("T7", "T6", "T6", "T7"), "P4", width=3)


def _greatsword(geo, hand, ang):
    c, p = geo["c"], geo["p"]
    n = 12
    a = math.radians(ang)
    for off in (-0.5, 0.5):
        c.line(hand[0] + math.cos(a) * 2 - math.sin(a) * off, hand[1] - math.sin(a) * 2 - math.cos(a) * off,
               hand[0] + math.cos(a) * n - math.sin(a) * off, hand[1] - math.sin(a) * n - math.cos(a) * off,
               "S1" if off < 0 else "S2")
    c.put(hand[0] + math.cos(a) * (n + 1), hand[1] - math.sin(a) * (n + 1), "S0")
    for k in (-2, -1, 1, 2):
        c.put(hand[0] + math.cos(a) * 2 - math.sin(a) * k, hand[1] - math.sin(a) * 2 - math.cos(a) * k, "L3")
    c.put(hand[0], hand[1], "T4")


KNIGHT = dict(size=48, head=(9, 8), torso=(9, 8), legs=6, outline=DARK_OUT, arm="T6",
              legs_fn=_greaves, torso_fn=_plate, head_fn=_helm, weapon=_greatsword)


def knight():
    s = Sheet()
    s.add("walk", [humanoid(KNIGHT, run=i, sword=70, bob=(-1 if i % 2 else 0), arm=3) for i in range(4)], 6, True)
    s.add("windup", [humanoid(KNIGHT, sword=10, lean=-2, crouch=1, arm=3), humanoid(KNIGHT, sword=5, lean=-2, crouch=1, arm=4)], 8, True)
    s.add("attack", [humanoid(KNIGHT, sword=0, lean=2, run=0, arm=3), humanoid(KNIGHT, sword=0, lean=2, run=2, arm=3)], 12, True)
    s.save("knight", origin=[24, 43])


# ---------- frost wolf ----------
def _wolf(phase=0, mode="run"):
    c = Cv(32, 24)
    low = 1 if mode == "crouch" else 0
    stretch = 2 if mode == "lunge" else 0
    by = 13 + low
    c.ell(14, by, 7 + stretch * 0.5, 3.4 - low * 0.6, BONE)
    c.rect(9, by + 2, 9, 1, "S2")
    # tail
    c.line(7 - stretch, by - 1, 4 - stretch, by - 3 + (phase % 2), "S1")
    c.put(3 - stretch, by - 3 + (phase % 2), "S0")
    # head
    hx, hy = 22 + stretch, by - 3 + low
    c.ell(hx, hy, 3, 2.6, BONE)
    c.rect(hx + 2, hy, 3, 2, "S1")
    c.put(hx + 4, hy, "N4")
    c.put(hx + 4, hy + 1, "S2")
    if mode != "run":
        c.put(hx + 3, hy + 2, "W0")  # bared fang
    c.put(hx + 1, hy - 1, "N0")  # ice-blue eye
    c.put(hx - 2, hy - 3, "S1")
    c.put(hx - 2, hy - 4, "S0")
    c.put(hx + 1, hy - 3, "S1")
    c.put(hx + 1, hy - 4, "S0")
    # frost along the back
    for x in range(10, 19, 3):
        c.put(x, by - 4 + low, "N0")
    # legs
    gy = 20
    if mode == "lunge":
        for (x0, x1) in ((9, 4), (11, 6), (19, 25), (21, 27)):
            c.line(x0, by + 2, x1, by + 4, "S2")
    else:
        offs = [(0, 0, 0, 0), (1, -1, -1, 1), (0, 0, 0, 0), (-1, 1, 1, -1)][phase % 4]
        for i, x in enumerate((9, 12, 17, 20)):
            lift = 1 if (phase % 4 in (1, 3) and offs[i] < 0) else 0
            c.line(x, by + 2, x + offs[i], gy - lift, "S2")
            c.put(x + offs[i] + 1, gy - lift, "S1")
    c.outline(BONE_OUT)
    return c


def wolf():
    s = Sheet()
    s.add("walk", [_wolf(i) for i in range(4)], 12, True)
    s.add("windup", [_wolf(0, "crouch"), _wolf(1, "crouch")], 8, True)
    s.add("attack", [_wolf(0, "lunge")], 8, True)
    s.save("wolf", origin=[16, 20])


def build():
    skeleton()
    archer()
    hooded()
    priest()
    knight()
    wolf()
