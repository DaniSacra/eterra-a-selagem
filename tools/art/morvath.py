"""Morvath, the king who betrayed the light: broken crown, torn royal mantle, dark blade. 64x64 frames."""
import math

from px import Cv, Sheet

OUT = "M4"
CX, G = 32, 58


def morvath(sword=-60, lean=0, bob=0, sway=0, arms_up=False, crouch=0, glow=0, eyes="P0", blade=20, orb=False, fade=0, back=False):
    c = Cv(64, 64)
    g = G
    top = g - 40 + bob + crouch * 3  # shoulder line
    cx = CX + lean

    def weapon():
        if sword is None:
            return
        a = math.radians(sword)
        sx, sy = cx + 7, top + 4
        hx, hy = sx + round(5 * math.cos(a)), sy - round(5 * math.sin(a))
        c.line(sx, sy, hx, hy, "M3")
        c.line(sx, sy + 1, hx, hy + 1, "M3")
        for off, tone in ((-1, "M1" if glow else "M2"), (0, "K0"), (1, "P4")):
            c.line(hx + math.cos(a) * 3 - math.sin(a) * off, hy - math.sin(a) * 3 - math.cos(a) * off,
                   hx + math.cos(a) * blade - math.sin(a) * off, hy - math.sin(a) * blade - math.cos(a) * off, tone)
        c.put(hx + math.cos(a) * (blade + 1), hy - math.sin(a) * (blade + 1), "M0" if glow else "M1")
        for k in (-3, -2, 2, 3):
            c.put(hx + math.cos(a) * 3 - math.sin(a) * k, hy - math.sin(a) * 3 - math.cos(a) * k, "L3")
        c.rect(hx - 1, hy - 1, 2, 2, "S2")

    if back:
        weapon()
    # torn mantle, widening to a ragged hem
    hem = g - crouch * 2
    n = hem - top
    for i in range(n):
        y = top + i
        half = 8 + (i * 6) // n
        x0 = cx - half - (sway * i) // (n * 1)
        w = half * 2
        for x in range(x0, x0 + w):
            rel = (x - x0) / w
            tone = "M1" if rel < 0.14 else "M2" if rel < 0.62 else "M3"
            c.put(x, y, tone)
        if i > n - 6:  # tears in the hem
            for k in range(x0 + 2, x0 + w, 5):
                if (k + i) % 3 != 0:
                    for yy in range(y, hem):
                        c.clear(k + (i % 2), yy)
    # dark mail under the open mantle, gold trim of a king
    c.rect(cx - 3, top + 3, 6, n - 12, "P4")
    c.rect(cx - 3, top + 3, 1, n - 12, "L3")
    c.rect(cx + 2, top + 3, 1, n - 12, "L4")
    c.rect(cx - 1, top + 6, 2, 2, "P1")
    c.rect(cx - 3, top + 14, 6, 1, "L3")
    # fur collar
    c.rect(cx - 10, top - 1, 20, 4, "S1")
    c.rect(cx - 10, top - 1, 8, 2, "S0")
    c.rect(cx - 9, top + 3, 18, 1, "S2")
    for x in range(cx - 8, cx + 9, 4):
        c.put(x, top + 1, "S3")
    # skull
    hy = top - 10
    c.rect(cx - 3, hy, 7, 1, "S0")
    c.rect(cx - 4, hy + 1, 9, 5, "S1")
    c.rect(cx - 4, hy + 1, 3, 3, "S0")
    c.rect(cx + 4, hy + 3, 1, 3, "S2")
    c.rect(cx - 2, hy + 6, 6, 2, "S2")
    c.rect(cx - 2, hy + 3, 2, 2, "K0")
    c.rect(cx + 2, hy + 3, 2, 2, "K0")
    c.put(cx - 1, hy + 4, eyes)
    c.put(cx + 3, hy + 4, eyes)
    c.put(cx, hy + 7, "K0")
    c.put(cx + 2, hy + 7, "K0")
    # broken crown: the right prongs are gone
    c.rect(cx - 4, hy - 2, 9, 2, "L2")
    c.rect(cx - 4, hy - 2, 4, 1, "L1")
    c.put(cx - 4, hy - 4, "L1")
    c.put(cx - 4, hy - 3, "L2")
    c.put(cx - 1, hy - 5, "L1")
    c.rect(cx - 1, hy - 4, 1, 2, "L2")
    c.put(cx + 2, hy - 3, "L3")
    c.put(cx - 1, hy - 1, "P1")
    c.clear(cx + 4, hy - 2)
    # off arm
    if arms_up:
        c.line(cx - 8, top + 3, cx - 12, top - 8, "M3")
        c.line(cx - 7, top + 3, cx - 11, top - 8, "M2")
        c.rect(cx - 13, top - 10, 2, 2, "S2")
        if orb:
            c.ell(cx - 12, top - 14, 2.4, 2.4, ("M0", "M1", "M2"))
            c.put(cx - 13, top - 15, "W0")
    if not back:
        weapon()
    c.outline(OUT)
    if fade:
        for y in range(64):
            for x in range(64):
                if (x + y * 3) % (4 - fade) == 0 or y < 18 + fade * 10:
                    c.clear(x, y) if (x * 7 + y * 5) % 3 < fade else None
    return c


def build():
    s = Sheet()
    s.add("idle", [morvath(), morvath(bob=1, sway=1)], 3, True)
    s.add("walk", [morvath(bob=(i % 2), sway=(-2, 0, 2, 0)[i], lean=(0, 1, 0, -1)[i], sword=-50 - 5 * (i % 2)) for i in range(4)], 6, True)
    s.add("slash1", [morvath(sword=140, lean=-1, back=True), morvath(sword=20, lean=3, glow=1), morvath(sword=-45, lean=3)], 9)
    s.add("slash2", [morvath(sword=-80, lean=-1), morvath(sword=10, lean=3, glow=1), morvath(sword=110, lean=2)], 9)
    s.add("slash3", [morvath(sword=95, bob=-2, glow=1), morvath(sword=-20, lean=3, crouch=1, glow=1), morvath(sword=-70, lean=3, crouch=1)], 9)
    s.add("dash_windup", [morvath(sword=5, lean=-3, crouch=1), morvath(sword=5, lean=-3, crouch=1, glow=1)], 8, True)
    s.add("dash", [morvath(sword=0, lean=4, sway=3, glow=1, blade=22)], 8, True)
    s.add("summon", [morvath(sword=-80, arms_up=True, orb=True), morvath(sword=-80, arms_up=True, orb=True, bob=-1, eyes="M0")], 6, True)
    s.add("rain", [morvath(sword=90, glow=1, bob=-1), morvath(sword=90, glow=1, bob=-2, eyes="M0")], 6, True)
    s.add("volley", [morvath(sword=-90, crouch=1, glow=1, arms_up=True), morvath(sword=-90, crouch=1, glow=1, arms_up=True, orb=True, eyes="W0")], 8, True)
    s.add("stunned", [morvath(sword=-110, crouch=2, lean=-1, eyes="K0"), morvath(sword=-112, crouch=2, lean=-2, eyes="K0")], 4, True)
    s.add("roar", [morvath(sword=60, arms_up=True, bob=-2, eyes="W0", glow=1), morvath(sword=65, arms_up=True, bob=-1, eyes="W0", glow=1, sway=2)], 8, True)
    s.add("death", [morvath(sword=-110, crouch=2, eyes="K0"), morvath(sword=None, crouch=2, eyes="K0", fade=1),
                    morvath(sword=None, crouch=2, eyes="K0", fade=2), morvath(sword=None, crouch=2, eyes="K0", fade=3)], 3)
    s.save("morvath", origin=[CX, G])
