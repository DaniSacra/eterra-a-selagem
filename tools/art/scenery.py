"""Catacomb scenery: floor, walls, columns, ossuaries, candles, tombs, broken stained glass. No outlines."""
import random

from px import Cv, Sheet, save


def floor_tiles():
    """Eight 16x16 stone slabs: soft seams, chips, a little moss. Calm, so characters read on top."""
    rnd = random.Random(7)
    frames = []
    for v in range(8):
        c = Cv(16, 16)
        c.rect(0, 0, 16, 16, "T6")
        c.rect(0, 15, 16, 1, "T7")
        c.rect(15, 0, 1, 16, "T7")
        c.rect(0, 0, 15, 1, "T5")
        c.rect(0, 0, 1, 15, "T5")
        if v == 1:  # a slab split in two
            c.rect(0, 7, 15, 1, "T7")
            c.rect(0, 8, 15, 1, "T5")
        for _ in range(3 + v):
            x, y = rnd.randrange(1, 15), rnd.randrange(1, 15)
            if c.get(x, y) == "T6":
                c.put(x, y, "T7" if rnd.random() < 0.6 else "T5")
        if v in (3, 6):  # crack
            x, y = rnd.randrange(3, 9), 2
            for _ in range(9):
                c.put(x, y, "P4")
                x += rnd.choice((0, 1, 1))
                y += 1
        if v in (5, 7):  # moss in a corner
            for _ in range(10):
                c.put(rnd.randrange(1, 6), rnd.randrange(9, 15), rnd.choice(("V3", "V4", "V3", "V2")))
        frames.append(c)
    save("floor", frames, origin=[0, 0])


def wall():
    """Top wall, 16x40: bricks lit from above, with a dark foot."""
    frames = []
    for v in range(3):
        c = Cv(16, 40)
        c.rect(0, 0, 16, 40, "N3")
        c.rect(0, 0, 16, 4, "T7")  # capstone
        c.rect(0, 0, 16, 1, "T5")
        c.rect(0, 3, 16, 1, "P4")
        for row in range(6):
            y = 4 + row * 6
            c.rect(0, y + 5, 16, 1, "N4")
            off = 0 if row % 2 == 0 else 8
            c.rect((off + 7) % 16, y, 1, 5, "N4")
            c.rect(0, y, 16, 1, "N2")
            c.put((off + 7) % 16, y, "N4")
        if v == 1:
            c.rect(3, 17, 2, 1, "V3")
            c.rect(2, 18, 4, 1, "V4")
        if v == 2:
            c.rect(10, 23, 3, 2, "N4")
        c.rect(0, 37, 16, 3, "N4")
        frames.append(c)
    save("wall", frames, origin=[0, 0])


def column():
    c = Cv(16, 40)
    c.rect(2, 0, 12, 3, "T6")
    c.rect(2, 0, 12, 1, "T5")
    c.rect(3, 3, 10, 1, "T7")
    for x in range(4, 12):
        tone = "T5" if x < 6 else "T6" if x < 10 else "T7"
        c.rect(x, 4, 1, 28, tone)
    c.rect(7, 4, 1, 28, "T7")  # fluting
    c.rect(3, 32, 10, 2, "T6")
    c.rect(1, 34, 14, 4, "T6")
    c.rect(1, 34, 14, 1, "T5")
    c.rect(1, 37, 14, 1, "T7")
    c.rect(12, 35, 3, 2, "T7")
    c.rect(4, 14, 2, 1, "V3")
    c.rect(4, 15, 1, 2, "V4")
    save("column", [c], origin=[8, 36])


def candle():
    frames = []
    for i in range(3):
        c = Cv(8, 20)
        c.rect(3, 8, 2, 9, "T3")  # iron stand
        c.rect(1, 17, 6, 1, "T4")
        c.rect(2, 18, 4, 1, "T4")
        c.rect(2, 7, 4, 1, "T3")
        c.rect(3, 4, 2, 3, "L0")  # wax
        c.put(4, 5, "L1")
        fx = (0, 1, 0)[i]
        c.put(3 + fx, 1, "L1")
        c.rect(3, 2, 2, 2, "L1")
        c.put(3 + (i % 2), 3, "L0")
        c.put(3 + fx, 0, "L2" if i != 1 else None)
        frames.append(c)
    save("candle", frames, {"burn": ([0, 1, 2], 7, True)}, origin=[4, 18])


def ossuary():
    """Wall niche packed with skulls and long bones, 32x24, set into the top wall."""
    c = Cv(32, 24)
    c.rect(0, 0, 32, 24, "N4")
    c.rect(0, 0, 32, 2, "T7")
    c.rect(0, 0, 32, 1, "T6")
    c.rect(0, 2, 1, 22, "T7")
    c.rect(31, 2, 1, 22, "T7")
    rnd = random.Random(3)
    for row in range(3):
        for col in range(5):
            x = 2 + col * 6 + (3 if row % 2 else 0)
            y = 4 + row * 7
            if x > 26:
                continue
            c.ell(x + 2, y + 2, 2.4, 2.2, ("S0", "S1", "S2"))
            c.put(x + 1, y + 2, "N4")
            c.put(x + 3, y + 2, "N4")
            c.rect(x + 1, y + 4, 3, 1, "S2")
            if rnd.random() < 0.5:
                c.rect(x - 2, y + 5, 4, 1, "S3")
    save("ossuary", [c], origin=[0, 0])


def tomb():
    """Stone sarcophagus seen from the front and above, 32x22."""
    c = Cv(32, 22)
    c.box(1, 6, 30, 14, ("T6", "T7", "N3"))
    c.box(0, 2, 32, 7, ("T5", "T6", "T7"))
    c.rect(4, 4, 24, 1, "T7")
    c.rect(14, 3, 4, 4, "T5")  # worn carving on the lid
    c.rect(15, 4, 2, 2, "T7")
    c.rect(4, 12, 6, 5, "N3")
    c.rect(13, 12, 6, 5, "N3")
    c.rect(22, 12, 6, 5, "N3")
    c.rect(1, 20, 30, 1, "P4")
    c.rect(24, 9, 3, 1, "V3")
    save("tomb", [c], origin=[16, 19])


def glass():
    """Tall broken stained-glass window for the top wall, 24x36. Some panes are gone and let the light in."""
    c = Cv(24, 36)
    panes = ["L1", "N0", "P0", "V1", "L2", "N1", "M0", "L0"]
    rnd = random.Random(11)
    for y in range(36):
        half = 11 if y > 9 else (3 + y * 8 // 9)
        for x in range(12 - half, 12 + half):
            c.put(x, y, "T7")
    for y in range(2, 34):
        half = 9 if y > 9 else (1 + y * 8 // 9)
        for x in range(12 - half, 12 + half):
            cell = (x // 4) + (y // 5) * 6
            col = panes[(cell * 7 + 3) % len(panes)]
            broken = (cell * 13 + 5) % 7 < 2
            c.put(x, y, "L0" if broken else col)
            if x % 4 == 0 or y % 5 == 0:
                c.put(x, y, "N4")
    for _ in range(14):  # shards missing along a crack
        c.put(8 + rnd.randrange(8), 10 + rnd.randrange(16), "L0")
    c.rect(11, 2, 1, 32, "N4")
    save("glass", [c], origin=[12, 0])


def door():
    """Crypt door in the top wall, 48x40: closed, then open on the dark stair."""
    frames = []
    for is_open in (False, True):
        c = Cv(48, 40)
        c.rect(0, 0, 48, 40, "T7")
        c.rect(0, 0, 48, 2, "T5")
        c.rect(2, 2, 44, 2, "T6")
        c.rect(6, 6, 36, 34, "K0")
        if not is_open:
            c.box(7, 7, 17, 33, ("T3", "T4", "K0"))
            c.box(24, 7, 17, 33, ("T3", "T4", "K0"))
            for y in (12, 22, 32):
                c.rect(7, y, 34, 1, "T7")
            c.rect(20, 21, 3, 3, "L3")
            c.rect(25, 21, 3, 3, "L3")
            c.rect(22, 6, 4, 2, "P1")  # the cut eye of the brotherhood? no: the king's seal, in red wax
        else:
            c.box(4, 7, 5, 33, ("T3", "T4", "K0"))
            c.box(39, 7, 5, 33, ("T3", "T4", "K0"))
            for i in range(5):
                c.rect(10 + i * 2, 34 - i * 5, 28 - i * 4, 5, ("M3", "M4", "K0", "K0", "K1")[i])
            c.rect(18, 12, 12, 2, "M2")
        c.rect(0, 0, 2, 40, "T6")
        c.rect(46, 0, 2, 40, "N3")
        frames.append(c)
    save("door", frames, origin=[24, 0])


def rubble():
    frames = []
    rnd = random.Random(5)
    for v in range(4):
        c = Cv(16, 12)
        if v < 2:  # loose bones
            c.rect(2, 8, 7, 1, "S1")
            c.put(2, 7, "S0")
            c.put(8, 9, "S2")
            c.ell(11, 7, 2.2, 2, ("S0", "S1", "S2"))
            c.put(10, 7, "N4")
            c.put(12, 7, "N4")
            if v == 1:
                c.rect(4, 4, 1, 4, "S2")
        else:  # broken stone
            for _ in range(5):
                x, y = rnd.randrange(2, 12), rnd.randrange(5, 10)
                c.rect(x, y, 3, 2, "T6")
                c.put(x, y, "T5")
                c.put(x + 2, y + 1, "N3")
        frames.append(c)
    save("rubble", frames, origin=[8, 10])


def build():
    floor_tiles()
    wall()
    column()
    candle()
    ossuary()
    tomb()
    glass()
    door()
    rubble()
