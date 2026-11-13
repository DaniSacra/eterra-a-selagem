extends Node
## Single door to every texture (autoload "Art"). A sprite comes from its grid in art/grids,
## unless a hand-drawn strip with the same name exists in art/png (same frame size, frames in a row).

const PNG_DIR := "res://art/png/"
const FLASH := &"flash"
const FROZEN := &"frozen"

var _defs: Dictionary = {}
var _tex: Dictionary = {}
var _frames: Dictionary = {}
var _variants: Dictionary = {}


func def(sprite: StringName) -> Dictionary:
	if not _defs.has(sprite):
		_defs[sprite] = GridSprite.load_def(sprite)
	return _defs[sprite]


## Registers a palette-swap variant: { "#from": "#to" }.
func add_variant(sprite: StringName, variant: StringName, hex_map: Dictionary) -> void:
	_variants[_key(sprite, variant)] = hex_map


func tex(sprite: StringName, variant: StringName = &"") -> Texture2D:
	var key := _key(sprite, variant)
	if _tex.has(key):
		return _tex[key]
	var png := PNG_DIR + (String(sprite) if variant == &"" else "%s_%s" % [sprite, variant]) + ".png"
	var out: Texture2D
	if ResourceLoader.exists(png):
		out = load(png)
	else:
		out = ImageTexture.create_from_image(GridSprite.to_strip(_variant_def(sprite, variant)))
	_tex[key] = out
	return out


func frames(sprite: StringName, variant: StringName = &"") -> SpriteFrames:
	var key := _key(sprite, variant)
	if not _frames.has(key):
		_frames[key] = GridSprite.to_sprite_frames(def(sprite), tex(sprite, variant))
	return _frames[key]


func size(sprite: StringName) -> Vector2i:
	return GridSprite.size_of(def(sprite))


func origin(sprite: StringName) -> Vector2:
	var o: Array = def(sprite).origin
	return Vector2(o[0], o[1])


func count(sprite: StringName) -> int:
	return GridSprite.frame_count(def(sprite))


## Frame indexes, fps and loop of one animation.
func anim(sprite: StringName, anim_name: StringName) -> Dictionary:
	return def(sprite).anims.get(anim_name, {"frames": [0], "fps": 1, "loop": true})


## A Sprite2D whose position is the sprite's origin (the feet), showing one frame of the strip.
func sprite(sprite_name: StringName, frame: int = 0, variant: StringName = &"") -> Sprite2D:
	var s := Sprite2D.new()
	setup(s, sprite_name, variant)
	s.frame = frame
	return s


func setup(s: Sprite2D, sprite_name: StringName, variant: StringName = &"") -> void:
	s.texture = tex(sprite_name, variant)
	s.hframes = count(sprite_name)
	s.centered = false
	s.offset = -origin(sprite_name)


func animated(sprite_name: StringName) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames(sprite_name)
	s.centered = false
	s.offset = -origin(sprite_name)
	return s


func _variant_def(sprite: StringName, variant: StringName) -> Dictionary:
	var base := def(sprite)
	if variant == &"":
		return base
	if variant == FLASH:
		return GridSprite.recolor_hex(base, GridSprite.tone_map(base, PackedStringArray(["#ffffff"])))
	if variant == FROZEN:
		return GridSprite.recolor_hex(base, GridSprite.tone_map(base, Palette.main().tones(&"neve")))
	return GridSprite.recolor_hex(base, _variants.get(_key(sprite, variant), {}))


func _key(sprite: StringName, variant: StringName) -> String:
	return "%s:%s" % [sprite, variant]
