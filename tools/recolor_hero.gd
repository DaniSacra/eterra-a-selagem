extends SceneTree
## Repaints the hero's texture toward the approved "Explorador" sheet (docs/art/hero_explorer.md) without touching the
## mesh, the skeleton or the clips: every texel of the atlas is found on the model in its rest pose (by rasterizing the
## triangles in UV space), and the black cloth of the "Sombra" becomes the explorer's leathers by where it sits on the
## body (boots, trousers, belt, vest with crossed straps, bracers); the scarf turns to the sheet's deep teal; hair and
## skin stay. Provisional until a real model of the explorer is made (Meshy plan in docs/art/hero_explorer.md).
##   ~/tools/godot/godot --headless --path . -s tools/recolor_hero.gd

const SOURCE := "res://assets/models/meshy/hero_sombra/hero_sombra-rigged_Image_0.jpg"
const OUT := "res://assets/models/meshy/hero_sombra/hero_explorer_albedo.png"
## Heights on the 1.8 m model (meters): boot tops, belt, chest, elbows; how far out the arms start.
const BOOT_TOP := 0.5
const BELT := Vector2(1.06, 1.15)
const CHEST_TOP := 1.47
const ELBOW := 1.18
const ARM_X := 0.17
## The sheet's colours (hex picked from it, docs/art/hero_explorer.md).
const BOOTS := Color("6a3e27")
const TROUSERS := Color("3d2a26")
const BELT_LEATHER := Color("7a4a2c")
const VEST := Color("4b2e29")
const STRAP := Color("975b36")
const BRACER := Color("6a3e27")
const GLOVE := Color("402621")
const SKIN := Color("e28e61")
const TEAL := Color("2f6b5e")
## The value the black cloth has on average: texels darker or lighter keep their shading around the new colour.
const CLOTH_VALUE := 0.17


func _init() -> void:
	var scene := (load("res://assets/models/meshy/hero_sombra/hero_sombra-rigged.glb") as PackedScene).instantiate()
	var mi := scene.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var arr := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var src := (load(SOURCE) as Texture2D).get_image()
	src.decompress()
	src.convert(Image.FORMAT_RGB8)
	var out := src.duplicate() as Image
	var size := Vector2(src.get_width(), src.get_height())
	var done := 0
	for t in range(0, idx.size(), 3):
		var a := uvs[idx[t]] * size
		var b := uvs[idx[t + 1]] * size
		var c := uvs[idx[t + 2]] * size
		var pa := verts[idx[t]]
		var pb := verts[idx[t + 1]]
		var pc := verts[idx[t + 2]]
		var lo := a.min(b).min(c).floor() - Vector2.ONE
		var hi := a.max(b).max(c).ceil() + Vector2.ONE
		var den := (b.y - c.y) * (a.x - c.x) + (c.x - b.x) * (a.y - c.y)
		if absf(den) < 1e-9:
			continue
		for y in range(maxi(0, int(lo.y)), mini(int(size.y), int(hi.y) + 1)):
			for x in range(maxi(0, int(lo.x)), mini(int(size.x), int(hi.x) + 1)):
				var p := Vector2(x + 0.5, y + 0.5)
				var w1 := ((b.y - c.y) * (p.x - c.x) + (c.x - b.x) * (p.y - c.y)) / den
				var w2 := ((c.y - a.y) * (p.x - c.x) + (a.x - c.x) * (p.y - c.y)) / den
				var w3 := 1.0 - w1 - w2
				# a little past the edges, so the seams of the atlas get the new colour too
				if w1 < -0.08 or w2 < -0.08 or w3 < -0.08:
					continue
				var at := pa * w1 + pb * w2 + pc * w3
				out.set_pixel(x, y, _paint(src.get_pixel(x, y), at))
		done += 1
	out.save_png(OUT)
	print("recolor_hero: %d triangles, saved %s" % [done, OUT])
	quit()


## The new colour of a texel of colour c at the rest-pose point p (meters, +Z is the front).
static func _paint(c: Color, p: Vector3) -> Color:
	var v := c.v
	# keep the cloth's folds, at half their contrast (full contrast speckles the new colours)
	var shade := clampf(lerpf(1.0, v / CLOTH_VALUE, 0.5), 0.7, 1.3)
	var ax := absf(p.x)
	var upper_arm := ax > ARM_X and p.y > ELBOW + 0.03 and p.y < CHEST_TOP + 0.02
	var skin_or_hair := c.s > 0.5 and c.h < 0.12
	# bare upper arms, as on the sheet: smooth skin over whatever the sleeve had
	if upper_arm and not skin_or_hair:
		return SKIN * 0.92
	# the scarf: the sheet's deeper, greener teal, keeping its folds
	if c.s > 0.25 and c.h > 0.42 and c.h < 0.58 and v > 0.25:
		return TEAL * clampf(v / 0.55, 0.6, 1.4)
	# only the dark, unsaturated cloth changes; hair and skin stay
	if v > 0.36 or c.s > 0.5:
		return c
	if ax > ARM_X and p.y > 0.85:
		if ax > 0.31:
			return GLOVE * shade
		return BRACER * shade
	if p.y < BOOT_TOP:
		# a wide cuff at the top of the boot, lighter
		return (BOOTS * 1.25 if p.y > BOOT_TOP - 0.07 else BOOTS) * shade
	if p.y < BELT.x:
		return TROUSERS * shade
	if p.y < BELT.y:
		return BELT_LEATHER * shade
	if p.y < CHEST_TOP:
		# crossed straps over the chest (front and back), a square plate where they cross
		var mid := (BELT.y + CHEST_TOP) * 0.5
		var plate := ax < 0.035 and absf(p.y - mid) < 0.035
		var strap := absf(ax - (p.y - mid) * 0.55) < 0.022 or absf(ax + (p.y - mid) * 0.55) < 0.022
		if plate:
			return STRAP * 1.3 * shade
		if strap:
			return STRAP * shade
		return VEST * shade
	return VEST * shade
