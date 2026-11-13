"""Shared humanoid rig: every two-legged character is the same skeleton with its own head, torso and weapon."""
import math

from px import Cv


def humanoid(st, **p):
    """st = style (sizes and part painters), p = pose. Returns one frame facing right."""
    size = st.get("size", 32)
    c = Cv(size, size)
    cx = size // 2 + p.get("dx", 0)
    g = size - 5 + p.get("dy", 0)  # feet row
    bob, lean = p.get("bob", 0), p.get("lean", 0)
    hw, hh = st["head"]
    tw, th = st["torso"]
    lh = st["legs"] - p.get("crouch", 0)
    ty = g - lh - th + 1 + bob
    tx = cx - tw // 2 + (1 if lean > 1 else -1 if lean < -1 else 0)
    hx, hy = cx - hw // 2 + lean, ty - hh + p.get("head_dy", 0)
    shoulder = (tx + tw - 2, ty + 1)
    ang = p.get("sword")
    geo = dict(c=c, cx=cx, g=g, tx=tx, ty=ty, tw=tw, th=th, hx=hx, hy=hy, hw=hw, hh=hh, lh=lh, p=p, shoulder=shoulder)

    def weapon():
        if ang is None or "weapon" not in st:
            return
        a = math.radians(ang)
        reach = p.get("arm", 2.2)
        hand = (shoulder[0] + round(reach * math.cos(a)), shoulder[1] - round(reach * math.sin(a)))
        c.line(shoulder[0], shoulder[1], hand[0], hand[1], st["arm"])
        st["weapon"](geo, hand, ang)

    if p.get("back"):
        weapon()
    if "cape" in st:
        st["cape"](geo)
    st["legs_fn"](geo)
    st["torso_fn"](geo)
    st["head_fn"](geo)
    if not p.get("back"):
        weapon()
    c.outline(st["outline"])
    if "post" in st:
        st["post"](geo)
    return c


def legs(geo, tones, foot, width=2):
    """Two legs with a four-step run cycle (p['run'] = 0..3) and a foot that points forward."""
    c, cx, g, tw, lh, p = geo["c"], geo["cx"], geo["g"], geo["tw"], geo["lh"], geo["p"]
    run = p.get("run")
    offs = {None: ((0, 0), (0, 0)), 0: ((1, 0), (-1, -1)), 1: ((0, 0), (0, 0)), 2: ((-1, -1), (1, 0)), 3: ((0, 0), (0, 0))}[run]
    spread = p.get("spread", 0)
    xs = (cx - tw // 2 - spread, cx + tw // 2 - width + spread)
    for (x0, (ox, oy)) in zip(xs, offs):
        for i in range(lh):
            y = g - lh + 1 + i + oy
            col = tones[min(i * len(tones) // max(lh, 1), len(tones) - 1)]
            c.rect(x0 + ox, y, width, 1, col)
        c.rect(x0 + ox, g + oy, width + 1, 1, foot)


def lying(frame, st_outline=None):
    """A fallen pose: the standing frame turned on its side, resting on the ground line."""
    out = Cv(frame.w, frame.h)
    g = frame.h - 5
    for y in range(frame.h):
        for x in range(frame.w):
            col = frame.g[y][x]
            if col:
                out.put(frame.w // 2 + (g - y) - 8, g - (frame.w - 1 - x) + frame.w // 2 - 3, col)
    return out
