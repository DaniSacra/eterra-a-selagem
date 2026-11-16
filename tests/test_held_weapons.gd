extends GutTest
## E1a-4 (VX-07): the held KayKit weapons are repainted in the figures' own tones (tools/bake.gd SWATCHES, painted
## into the first row of the palette strip of each baked figure), and the brute's legs are evened (both feet come
## down to the floor in its walk).

const BAKE := preload("res://tools/bake.gd")
## The figures that carry KayKit weapons.
const HOLDERS: Array[StringName] = [&"skeleton", &"mage", &"archer", &"knight", &"priest_elder", &"morvath"]
const WALKERS: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"knight", &"priest_elder", &"morvath"]
## How far a planted foot may stay over the floor at its lowest in a walk loop (meters); the elder priest's right
## foot, under the robe, stays 5.5 cm over it (its rig's right knee rests a little bent, not evened).
const FOOT_ON_FLOOR := 0.05
const FOOT_ON_FLOOR_ROBED := {&"priest_elder": 0.06}
## The compressed atlas keeps a swatch's mean this close (sRGB, per channel).
const SWATCH_TOLERANCE := 0.04


func _model(id: StringName) -> BakedModel:
	return load("res://assets/baked/%s.res" % id)


## The mean colour of one swatch cell of a figure's atlas, inside its margins.
func _cell_mean(img: Image, cell: int) -> Color:
	var top := int(BAKE.ATLAS * BAKE.BODY)
	var w := img.get_width() / BAKE.COLS
	var h := (img.get_height() - top) / BAKE.ROWS
	var x0 := (cell % BAKE.COLS) * w
	var y0 := top + (cell / BAKE.COLS) * h
	var sum := Color(0, 0, 0, 0)
	var n := 0
	for y in range(y0 + h / 4, y0 + h * 3 / 4):
		for x in range(x0 + w / 4, x0 + w * 3 / 4):
			sum += img.get_pixel(x, y)
			n += 1
	return sum / n


func test_every_holder_carries_its_swatches() -> void:
	for id in HOLDERS:
		var img := _model(id).albedo.get_image()
		if img.is_compressed():
			img.decompress()
		var used := {}
		for h: Dictionary in BAKE.MODELS[String(id)].held:
			for sw: String in h.get("paint", {}).values():
				used[sw] = true
		for sw: String in used:
			var want: Color = BAKE.SWATCHES[sw].color
			var got := _cell_mean(img, BAKE.SWATCHES[sw].cell)
			for ch in 3:
				assert_almost_eq(got[ch], want[ch], SWATCH_TOLERANCE, "%s: swatch %s channel %d" % [id, sw, ch])


func test_old_gold_is_old_not_toy_yellow() -> void:
	var gold: Color = BAKE.SWATCHES.gold.color
	assert_gt(gold.b / gold.r, 0.35, "blue over 0.35 of red (V-P1)")
	assert_lt(gold.s, 0.5)


func test_no_weapon_keeps_a_palette_cell() -> void:
	for spec: Dictionary in BAKE.MODELS.values():
		for h: Dictionary in spec.get("held", []):
			if h.has("file"):
				assert_true(h.has("paint"), "%s is repainted" % h.file)
				assert_false(h.has("remap"), "%s: no KayKit cell left" % h.file)


func test_both_feet_come_down_in_every_walk() -> void:
	for id in WALKERS:
		var walk: Array = _model(id).feet[&"walk"]
		for foot in 2:
			var low := INF
			for pose: PackedVector3Array in walk[foot]:
				for at in pose:
					low = minf(low, at.y)
			assert_lt(low, float(FOOT_ON_FLOOR_ROBED.get(id, FOOT_ON_FLOOR)), "%s: foot %d reaches the floor (%.3f m)" % [id, foot, low])
