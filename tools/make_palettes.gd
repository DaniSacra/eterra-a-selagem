extends SceneTree
## Paints one palette per enemy of the first region over the KayKit skeletons' palette (32 cells, 8 x 4, each a
## vertical gradient from light to shadow), after Daniel's sheet docs/art/ref/inimigos_fase1.png and
## docs/art/enemies_phase1.md. tools/bake.gd draws each enemy with its palette ("texture" in MODELS) and moves mesh
## parts and props to the cells below; the elite version of each one (EnemyDef.palette) is the same palette with old
## gold on its trims. Writes assets/models/palettes/<id>.png and <id>_elite.png.
##   ~/tools/godot/godot --headless --path . -s tools/make_palettes.gd
## then ~/tools/godot/godot --headless --path . --import (new files) and tools/bake.gd.

const BASE := "res://assets/models/characters/Skeleton_Minion_skeleton_texture.png"
const OUT := "res://assets/models/palettes/"
## Pixels of the written palettes (the cells keep their place: UVs are fractions).
const SIZE := 512
const COLS := 8
const ROWS := 4

## What each cell holds on the KayKit skeletons (tools/bake.gd moves parts between cells by these numbers):
## 2 black, 3 armor, 4 dark metal (helmet rims, pauldrons: the elites' trims), 5 the soldier's loincloth,
## 6 and 7 leathers, 9 bone, 11 blade steel, 16 and 21 robe trims, 17 robe second colour, 18 hood, cloak and robe,
## 22 handles and wood. Free cells used by the props: 24 red cloth, 25 old gold, 26 purple cloth, 27 white hair.
## Cells 28 to 31 glow (crowd.gdshader): 28 cold violet (the sorcerer), 29 purple (priests, Morvath), 30 embers,
## 31 the eyes.
const RED := 24
const GOLD := 25
const PURPLE := 26
const HAIR := 27
const GLOW_COLD := 28
const GLOW_PURPLE := 29
const EMBER := 30
const EYES := 31

## The faction (sheet: light bone, burnt bone, slate, black, dark blood red, purple, dark purple; old gold on trims).
## cell -> [light, shadow]
const FACTION := {
	2: ["2a2628", "0c0a0c"],
	3: ["7e8086", "2e3036"],
	4: ["4c4e54", "1e2026"],
	5: ["8c2420", "360c0e"],
	6: ["6c4630", "2a1810"],
	7: ["5c4c42", "261e1a"],
	9: ["f0e4c8", "6a503c"],
	11: ["c4ccd0", "565c62"],
	18: ["8c2420", "360c0e"],
	22: ["6a5040", "2a1c14"],
	RED: ["8c2420", "360c0e"],
	GOLD: ["8e7444", "34281a"],
	PURPLE: ["5e4474", "1e1428"],
	HAIR: ["f4f0e8", "9a948c"],
	GLOW_COLD: ["d2b4ff", "8a64f0"],
	GLOW_PURPLE: ["c050ff", "6c12c8"],
	EMBER: ["ffc050", "e8460e"],
	EYES: ["ff7a3a", "c42a10"],
}
const DARK_ROBE := ["4c3c54", "1a1420"]
const ROYAL_PURPLE := ["54386a", "1a1022"]
const DARK_BRONZE := ["8c6c48", "2c2014"]
## The priests (cycle 5, docs/art/cycle5_spec.md A1): dark metal, aged bone that does not burn white under the key
## light, and the hood in the black cell turned a little purple, a dark frame around the light skull.
const PRIESTS := ["priest", "priest_elder"]
const PRIEST_METAL := {3: ["4e4a52", "18161c"], 4: ["3a3436", "121012"], 9: ["d8cbb0", "4e3e30"], 2: ["2e2236", "0e0a12"]}

## Each enemy over the faction. cell -> [light, shadow].
const PALETTES := {
	# the soldier: bone, a slate helmet and pauldron, red rags
	"skeleton": {},
	# the runner: bare bone, red rags, leather bracers, ember eyes (and embers on the chest, a prop)
	"runner": {3: ["5c4030", "22160e"], EYES: ["ffb040", "e05010"]},
	# the sorcerer: hood and robe almost black with red, cold violet eyes and staff gem (Daniel: violet, not green)
	"mage": {18: DARK_ROBE, 17: ["8c2a2a", "36100e"], 21: ["8c2a2a", "36100e"], 16: ["8c2a2a", "36100e"],
		PURPLE: ["54405e", "1c1424"], EYES: ["e0c8ff", "9a70ff"]},
	# the crossbowman: dark purple hood, red scarf, dark bronze and leather
	"archer": {18: ["4c2c5e", "1a0e24"], 3: DARK_BRONZE, 7: ["4c3c32", "1e1612"]},
	# the brute: dark bronze plate, red cloth
	"guard": {3: DARK_BRONZE, 4: ["5a4630", "1e160c"], 22: ["5a4430", "1e140c"]},
	# the priest: purple hood and robe with old gold trims, purple eyes
	"priest": {18: ROYAL_PURPLE, PURPLE: ROYAL_PURPLE, 17: ROYAL_PURPLE, 21: FACTION[GOLD],
		16: FACTION[GOLD], EYES: ["d070ff", "8a20e0"]},
	# the guardian knight: dark steel with gold, red cape, crown of spikes
	"knight": {3: ["6a6a74", "202028"], 4: FACTION[GOLD], 22: FACTION[GOLD]},
	# the elder: purple and gold, crown, staff with a purple orb
	"priest_elder": {18: ROYAL_PURPLE, PURPLE: ROYAL_PURPLE, 17: ROYAL_PURPLE, 21: FACTION[GOLD],
		16: FACTION[GOLD], EYES: ["d070ff", "8a20e0"]},
	# Morvath, the king who betrayed the light: pale bone, dark armor with gold, purple robes, white hair, purple gem
	"morvath": {9: ["f6eee0", "7a6a5c"], 3: ["4c4654", "18141e"], 4: FACTION[GOLD], 18: ROYAL_PURPLE, 22: FACTION[GOLD],
		EYES: ["d070ff", "8a20e0"]},
}

## The elite of each one: these cells turn old gold (the sheet's gilded trims). The guardians and Morvath have none.
const ELITE_TRIMS := {
	"skeleton": [4],
	"runner": [3],
	"mage": [16, 21, 22],
	"archer": [3],
	"guard": [4, 22],
	"priest": [17, 22],
}


func _init() -> void:
	var base := (load(BASE) as Texture2D).get_image()
	base.decompress()
	base.convert(Image.FORMAT_RGB8)
	base.resize(SIZE, SIZE, Image.INTERPOLATE_BILINEAR)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for id: String in PALETTES:
		var cells := FACTION.duplicate()
		if PRIESTS.has(id):
			cells.merge(PRIEST_METAL, true)
		cells.merge(PALETTES[id], true)
		_write(base, cells, OUT + id + ".png")
		if ELITE_TRIMS.has(id):
			for c: int in ELITE_TRIMS[id]:
				cells[c] = FACTION[GOLD]
			_write(base, cells, OUT + id + "_elite.png")
	quit()


func _write(base: Image, cells: Dictionary, path: String) -> void:
	var img := base.duplicate() as Image
	var w := SIZE / COLS
	var h := SIZE / ROWS
	for c: int in cells:
		var light := Color(cells[c][0])
		var shadow := Color(cells[c][1])
		var x0 := (c % COLS) * w
		var y0 := (c / COLS) * h
		for y in h:
			var col := light.lerp(shadow, float(y) / float(h - 1))
			for x in w:
				img.set_pixel(x0 + x, y0 + y, col)
	img.save_png(path)
	print("palette ", path)
