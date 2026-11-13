"""Small things: gift icons, light orbs, the light fountain, and the props of the final scene."""
from px import Cv, Sheet, save

# 10x10 pictograms. o = lightest tone, # = main tone, x = shade, w = white. The family gives the colours.
ICONS = [
    ("P", ["..........", "....#.....", "...##..#..", "..#o#.##..", "..#oo##...", ".#ooo#....", ".#owo#.x..", "..###..x..", ".x..x.x...", ".........."]),  # brasas
    ("P", ["...###....", "..#ooo#...", ".#o...o#..", ".#o.##.o#.", ".#o.#o.o#.", ".#o..o.o#.", "..#ooo.o#.", "...###o#..", "......#...", ".........."]),  # redemoinho
    ("P", [".......w..", "......wo..", ".....wo#..", "....wo#...", "...wo#.#..", "..wo#.##..", ".xo#..#o#.", "xxx....#..", ".x........", ".........."]),  # lamina ardente
    ("N", ["....o.....", ".o..o..o..", "..o.o.o...", "...ooo....", "ooooooooo.", "...ooo....", "..o.o.o...", ".o..o..o..", "....o.....", ".........."]),  # toque da geada
    ("N", ["..........", "..o....#..", ".oo#..##..", ".o##.#o#..", "..#..oo...", ".....o..#.", ".#o....##.", ".##o..#o#.", "..##...#..", ".........."]),  # estilhaco
    ("N", ["..######..", ".#oooooo#.", ".#o####x#.", ".#o####x#.", "..#xxxx#..", "....##....", "....#x....", "....#x....", "....#x....", "....xx...."]),  # peso do inverno
    ("L", ["..........", ".##...##..", "#oo#.#oo#.", "#owo#ooo#.", "#ooooooo#.", ".#ooooo#..", "..#ooo#...", "...#o#....", "....#.....", ".........."]),  # consolo
    ("L", ["..........", ".#....#...", "..#....#..", "..o#...o#.", "..o#...o#.", "..o#...o#.", "..o#...o#.", "..#....#..", ".#....#...", ".........."]),  # mare de luz
    ("L", ["....w.....", "....o.....", ".#.ooo.#..", "..ooooo...", "wooowooow.", "..ooooo...", ".#.ooo.#..", "....o.....", "....w.....", ".........."]),  # flagelo
    ("V", [".########.", ".#oooo##x.", ".#oo####x.", ".#o#####x.", ".#o#####x.", ".#######x.", "..#####x..", "...###x...", "....#x....", ".........."]),  # escudo
    ("V", ["..........", ".....###..", "....#oo#..", "...#oo#...", "o..#o#....", ".o.#o#....", "o..#oo###.", "...#ooooo#", "...######.", ".........."]),  # passos
    ("V", ["....##....", "....##....", "..######..", "..#o####..", "..#o####..", "....##....", "....##....", "...####...", "..xxxxxx..", ".........."]),  # firmeza
    ("M", ["..........", "...oo.....", "..oooo.oo.", ".oooooooo.", ".oo#ooo#o.", "..########", ".#x#.#x#..", "..........", ".x..x..x..", ".........."]),  # vapor
    ("M", ["....o.....", "..o.o.o...", "...ooo....", ".ooooooo..", "...ooo....", "..o.o.o...", "#...o...#.", ".##...##..", "...###....", ".........."]),  # aurora
    ("M", ["....#.....", "...#o#....", "..#ooo#...", "..#owo#...", "...#o#....", ".#..#..#..", "..#...#...", "..o#.#o...", "...###....", ".........."]),  # chama viva
    ("M", ["o...#...o.", ".o.###.o..", "..#ooo#...", ".##o#o##..", "###o#o###.", ".##ooo##..", "..#####...", ".o.###.o..", "o...#...o.", ".........."]),  # bastiao
    ("M", ["..........", "......##..", ".....#oo#.", "..x.#oo#..", ".x#.#o#...", "x#o.###...", ".#x..x....", "x.#.x.#...", ".x..#.x...", ".........."]),  # rastro
    ("M", ["..........", "..o...###.", ".ooo.#oo#.", "..o.#oo#..", "....#o#...", ".o..#oo##.", "ooo.#oooo#", ".o..#####.", "..........", ".........."]),  # passo frio
]


def icons():
    frames = []
    for fam, rows in ICONS:
        c = Cv(10, 10)
        tone = {"o": fam + "0", "#": fam + "1", "x": fam + "2", "w": "W0"}
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch in tone:
                    c.put(x, y, tone[ch])
        frames.append(c)
    save("icons", frames, origin=[0, 0])


def orb():
    frames = []
    for i in range(2):
        c = Cv(7, 7)
        c.ell(3, 3, 2.2 if i == 0 else 1.6, 2.2 if i == 0 else 1.6, ("L0", "L1", "L2"))
        c.put(3, 3, "W0")
        if i == 1:
            for x, y in ((3, 0), (0, 3), (6, 3), (3, 6)):
                c.put(x, y, "L1")
        frames.append(c)
    save("orb", frames, {"glow": ([0, 1], 6, True)}, origin=[3, 3])


def fountain():
    """A spring of light in a worn stone basin: two flowing frames and one spent."""
    frames = []
    for i in range(3):
        c = Cv(28, 26)
        c.ell(14, 19, 12, 5, ("T5", "T6", "T7"))
        c.ell(14, 18, 10, 3.6, "N3" if i == 2 else "L1")
        if i < 2:
            c.ell(14, 18, 7, 2.2, "L0")
            c.rect(13, 7 + i, 2, 10 - i, "L0")
            c.put(12, 9 + i, "L1")
            c.put(15, 10 - i, "L1")
            c.put(14, 5 + i, "W0")
            for x, y in ((8, 13 - i), (20, 12 + i), (11, 4 + 2 * i), (18, 6 - i + 1)):
                c.put(x, y, "L0")
        else:
            c.rect(13, 14, 2, 3, "T6")
        c.rect(6, 22, 16, 1, "T7")
        frames.append(c)
    save("fountain", frames, {"flow": ([0, 1], 5, True), "spent": ([2], 1, True)}, origin=[14, 21])


def ending():
    """The king's tomb sealed: the slab with the lion, and a paladin's sword raised (one per corner)."""
    c = Cv(40, 30)
    c.box(2, 10, 36, 18, ("T6", "T7", "N3"))
    c.box(0, 4, 40, 10, ("T5", "T6", "T7"))
    c.rect(4, 6, 32, 1, "T7")
    # the lion on the lid, in the gold of the light
    c.ell(20, 9, 4, 3, ("L1", "L2", "L3"))
    c.put(18, 8, "N4")
    c.put(22, 8, "N4")
    c.rect(19, 10, 3, 1, "L4")
    for x, y in ((15, 6), (25, 6), (14, 9), (26, 9), (16, 12), (24, 12)):
        c.put(x, y, "L2")
    c.rect(8, 18, 24, 6, "N3")
    for x in range(10, 30, 3):
        c.rect(x, 20, 2, 1, "T6")  # the carved line of the epitaph
        c.rect(x + 1, 22, 1, 1, "T6")
    c.rect(2, 28, 36, 1, "P4")
    save("seal_tomb", [c], origin=[20, 27])

    frames = []
    for glow in (0, 1):
        s = Cv(11, 26)
        s.rect(5, 2, 1, 16, "L0" if glow else "S0")
        s.rect(4, 3, 1, 15, "S1")
        s.rect(6, 3, 1, 15, "S2")
        s.put(5, 1, "W0")
        s.rect(2, 18, 7, 1, "L2")
        s.put(2, 18, "L1")
        s.rect(5, 19, 1, 4, "T4")
        s.rect(4, 23, 3, 1, "L3")
        s.outline("N4")
        if glow:
            for x, y in ((5, 0), (1, 6), (9, 9), (2, 13)):
                s.put(x, y, "L0")
        frames.append(s)
    save("seal_sword", frames, {"shine": ([0, 1], 4, True)}, origin=[5, 24])


def build():
    icons()
    orb()
    fountain()
    ending()
