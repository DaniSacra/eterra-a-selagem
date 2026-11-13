class_name GridSprite
extends RefCounted
## The one sprite format of Eterra, ported from src/gridsprite.js of the RPG:
## def = { size: [w, h], origin: [x, y], pal: { letter: "#rrggbb" }, frames: [[rows]], anims: { name: { frames, fps, loop } } }
## "." is transparent. Variants of a sprite come from a palette swap, never from a new grid.

const GRID_DIR := "res://art/grids/"


static func load_def(sprite_name: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(GRID_DIR + sprite_name + ".json")
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


static func size_of(def: Dictionary) -> Vector2i:
	return Vector2i(int(def.size[0]), int(def.size[1]))


static func frame_count(def: Dictionary) -> int:
	return (def.frames as Array).size()


## Problems with a definition (empty = valid).
static func check(def: Dictionary) -> PackedStringArray:
	var errs := PackedStringArray()
	var size := size_of(def)
	var frames: Array = def.frames
	for f in frames.size():
		var rows: Array = frames[f]
		if rows.size() != size.y:
			errs.append("frame %d: %d rows, expected %d" % [f, rows.size(), size.y])
		for y in rows.size():
			var row: String = rows[y]
			if row.length() != size.x:
				errs.append("frame %d row %d: width %d, expected %d" % [f, y, row.length(), size.x])
			for ch in row:
				if ch != "." and not def.pal.has(ch):
					errs.append("frame %d row %d: letter '%s' has no colour" % [f, y, ch])
	for anim_name: String in def.get("anims", {}):
		for idx: float in def.anims[anim_name].frames:
			if int(idx) < 0 or int(idx) >= frames.size():
				errs.append("anim %s: frame %d does not exist" % [anim_name, int(idx)])
	return errs


## Swap colours by hex, { "#from": "#to" }, without a new grid.
static func recolor_hex(def: Dictionary, map: Dictionary) -> Dictionary:
	var out := def.duplicate()
	var pal: Dictionary = (def.pal as Dictionary).duplicate()
	for letter: String in pal:
		if map.has(pal[letter]):
			pal[letter] = map[pal[letter]]
	out.pal = pal
	return out


## Every colour mapped onto the tones of one family by brightness (frozen, shadow and flash variants).
static func tone_map(def: Dictionary, tones: PackedStringArray) -> Dictionary:
	var map := {}
	for hex: String in (def.pal as Dictionary).values():
		var lum := Color.html(hex).get_luminance()
		map[hex] = tones[clampi(int((1.0 - lum) * tones.size()), 0, tones.size() - 1)]
	return map


static func to_image(def: Dictionary, frame: int = 0) -> Image:
	var size := size_of(def)
	var img := Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	_paint(def, frame, img, 0)
	return img


## All frames side by side, the layout of a hand-drawn PNG that may replace the grid later.
static func to_strip(def: Dictionary) -> Image:
	var size := size_of(def)
	var count := frame_count(def)
	var img := Image.create_empty(size.x * count, size.y, false, Image.FORMAT_RGBA8)
	for f in count:
		_paint(def, f, img, f * size.x)
	return img


static func _paint(def: Dictionary, frame: int, img: Image, x0: int) -> void:
	var colors := {}
	for letter: String in def.pal:
		colors[letter] = Color.html(def.pal[letter])
	var rows: Array = def.frames[frame]
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var ch := row[x]
			if ch != ".":
				img.set_pixel(x0 + x, y, colors[ch])


## SpriteFrames over a strip texture, one animation per entry of def.anims (or "default" with every frame).
static func to_sprite_frames(def: Dictionary, strip: Texture2D) -> SpriteFrames:
	var size := size_of(def)
	var sf := SpriteFrames.new()
	sf.remove_animation(&"default")
	var anims: Dictionary = def.get("anims", {})
	if anims.is_empty():
		var all: Array = []
		for i in frame_count(def):
			all.append(i)
		anims = {"default": {"frames": all, "fps": 6, "loop": true}}
	for anim_name: String in anims:
		var a: Dictionary = anims[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, float(a.fps))
		sf.set_animation_loop(anim_name, bool(a.loop))
		for idx: float in a.frames:
			var at := AtlasTexture.new()
			at.atlas = strip
			at.region = Rect2(int(idx) * size.x, 0, size.x, size.y)
			sf.add_frame(anim_name, at)
	return sf
