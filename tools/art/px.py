"""Tiny pixel canvas for authoring Eterra grid sprites (one letter per colour).

The game never runs this: it only reads the grids written to art/grids/*.json.
Colours are named by family and tone (L0 = lightest of "luz"), exactly as in data/palette.tres.
"""
import json
import math
import os

FAMILIES = {
    "L": ["#fff6c0", "#f0d860", "#e8b840", "#c89c38", "#8a5418"],  # luz
    "N": ["#8ac0f0", "#3a78c8", "#2c3c80", "#1c2860", "#151e4e"],  # noite
    "V": ["#90e0b0", "#4ad08a", "#3a9a6a", "#2a5440", "#14402a"],  # vida
    "M": ["#f0a8f8", "#a84ad8", "#72308e", "#40145a", "#3a1448"],  # misterio
    "P": ["#e86a7a", "#a8323e", "#7a1a24", "#4a0c14", "#26202e"],  # perigo
    "S": ["#e8eff8", "#cbd8ec", "#a4b8da", "#7488b8", "#4a5a8c"],  # neve
    "T": ["#f4cca0", "#d8a478", "#b07c58", "#9a6232", "#6a3a1a", "#a2a2ac", "#7a7a82", "#55555e"],  # materia
    "W": ["#ffffff"],  # pure white (retratos)
    "K": ["#141018", "#060408"],  # deepest darks (retratos)
}
PAL = {f"{fam}{i}": hexv for fam, tones in FAMILIES.items() for i, hexv in enumerate(tones)}
_LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
LETTER = {name: _LETTERS[i] for i, name in enumerate(PAL)}

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "art", "grids")


class Cv:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.g = [[None] * w for _ in range(h)]

    def put(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if c and 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = c

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.g[y][x]
        return None

    def clear(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = None

    def rect(self, x, y, w, h, c):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.put(xx, yy, c)

    def box(self, x, y, w, h, tones):
        """Lit box: light on the top and left edges, shade on the bottom and right."""
        hi, mid, lo = tones
        self.rect(x, y, w, h, mid)
        if w > 2 and h > 1:
            self.rect(x, y, w - 1, 1, hi)
            self.rect(x, y, 1, h - 1, hi)
            self.rect(x + w - 1, y + 1, 1, h - 1, lo)
            self.rect(x + 1, y + h - 1, w - 1, 1, lo)

    def ell(self, cx, cy, rx, ry, tones):
        """Filled ellipse; tones may be one colour or (hi, mid, lo) lit from the top left."""
        if isinstance(tones, str):
            tones = (tones, tones, tones)
        hi, mid, lo = tones
        for y in range(int(math.floor(cy - ry)), int(math.ceil(cy + ry)) + 1):
            for x in range(int(math.floor(cx - rx)), int(math.ceil(cx + rx)) + 1):
                dx, dy = (x - cx) / max(rx, 0.01), (y - cy) / max(ry, 0.01)
                if dx * dx + dy * dy <= 1.0:
                    k = dx + dy
                    self.put(x, y, hi if k < -0.55 else lo if k > 0.6 else mid)

    def line(self, x0, y0, x1, y1, c):
        x0, y0, x1, y1 = int(round(x0)), int(round(y0)), int(round(x1)), int(round(y1))
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            self.put(x0, y0, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def ray(self, x, y, deg, length, c, start=0):
        """Line from (x, y) at an angle (0 = right, 90 = up)."""
        a = math.radians(deg)
        self.line(x + math.cos(a) * start, y - math.sin(a) * start,
                  x + math.cos(a) * length, y - math.sin(a) * length, c)

    def outline(self, c):
        """Dark rim of the sprite's own colour family around every opaque pixel."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.g[y][x] is None and any(
                        self.get(x + ox, y + oy) for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    add.append((x, y))
        for x, y in add:
            self.g[y][x] = c

    def blit(self, other, dx=0, dy=0):
        for y in range(other.h):
            for x in range(other.w):
                if other.g[y][x]:
                    self.put(x + dx, y + dy, other.g[y][x])

    def flip(self):
        out = Cv(self.w, self.h)
        for y in range(self.h):
            out.g[y] = list(reversed(self.g[y]))
        return out

    def swap(self, mapping):
        for y in range(self.h):
            for x in range(self.w):
                if self.g[y][x] in mapping:
                    self.g[y][x] = mapping[self.g[y][x]]
        return self

    def rows(self):
        return ["".join(LETTER[c] if c else "." for c in row) for row in self.g]


def save(name, frames, anims=None, origin=None):
    """Write one sprite: frames is a list of Cv, anims maps a name to (frame indexes, fps, loop)."""
    w, h = frames[0].w, frames[0].h
    used = sorted({c for f in frames for row in f.g for c in row if c})
    data = {
        "size": [w, h],
        "origin": origin or [w // 2, h - 1],
        "pal": {LETTER[c]: PAL[c] for c in used},
        "anims": {k: {"frames": v[0], "fps": v[1], "loop": v[2]} for k, v in (anims or {}).items()},
        "frames": [f.rows() for f in frames],
    }
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, name + ".json"), "w") as fh:
        fh.write(_dump(data))


def _dump(data):
    """JSON with one grid row per line, so the art stays readable and diffable."""
    head = {k: v for k, v in data.items() if k != "frames"}
    out = json.dumps(head, ensure_ascii=False)[:-1] + ', "frames": [\n'
    blocks = []
    for rows in data["frames"]:
        blocks.append("[\n" + ",\n".join(f'"{r}"' for r in rows) + "\n]")
    return out + ",\n".join(blocks) + "\n]}\n"


class Sheet:
    """Collects frames and named animations for one sprite."""

    def __init__(self):
        self.frames, self.anims = [], {}

    def add(self, name, cvs, fps=10, loop=False):
        start = len(self.frames)
        self.frames.extend(cvs)
        self.anims[name] = (list(range(start, start + len(cvs))), fps, loop)

    def save(self, name, origin=None):
        save(name, self.frames, self.anims, origin)
