class_name AngelArt
extends RefCounted
## The angels' painted portraits (AN-1, 2026-11-21): assets/ui/angels/angel_<n>.jpg, 512 x 768, scaled down from the
## 1024 x 1536 sources the Daniel made with the ChatGPT image tool (docs/art/angels_src/, not in the package). The angel
## stands at the left of the picture with the dark of the vaults to the right, so the bust is cut out of the top left
## (CROP) and shown in a frame of the angel's colour. 1 Sarael, 2 Nivael, 3 Lumael, 4 Shomael, 5 Velael, 6 Galael, 7 Qeshael, 8 Zerael, 9 Saarael (thunder). An angel without a file keeps its seal.
##   var p := AngelArt.portrait(angel, Vector2(220, 280))   # null: no portrait

const DIR := "res://assets/ui/angels/"
## Which source each angel is (AngelDef.id).
const NUMBER := {&"sarael": 1, &"nivael": 2, &"lumael": 3, &"shomael": 4, &"velael": 5, &"galael": 6, &"qeshael": 7, &"zerael": 8, &"thunder": 9}
## The part of the 512 x 768 picture shown (the face, the hand and the family's brooch).
const CROP := Rect2(0, 0, 400, 510)

static var _cache: Dictionary = {}


## The portrait's texture (the whole picture), or null when the angel has none.
static func texture(id: StringName) -> Texture2D:
	if not NUMBER.has(id):
		return null
	var path := "%sangel_%d.jpg" % [DIR, NUMBER[id]]
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _cache[path]


## The portrait as a framed control of this size (the crop fills it), the frame in the family's tint; null without a picture.
static func portrait(a: AngelDef, size_px: Vector2) -> Control:
	var tex := texture(a.id)
	if tex == null:
		return null
	var crop := AtlasTexture.new()
	crop.atlas = tex
	crop.region = CROP
	var holder := Control.new()
	holder.name = "angel_art"
	holder.custom_minimum_size = size_px
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := TextureRect.new()
	r.texture = crop
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(r)
	var tint := AngelSeal.tint(a.family)
	holder.draw.connect(func() -> void:
		var rect := Rect2(Vector2.ZERO, holder.size)
		holder.draw_rect(rect.grow(3.0), Color(UiKit.INK, 0.9))
		holder.draw_rect(rect.grow(2.0), Color(tint, 0.75), false, 2.0))
	# the line over the picture (a child draws after its parent's own _draw): a second control
	var frame := Control.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.draw.connect(func() -> void:
		var rect := Rect2(Vector2.ZERO, frame.size)
		frame.draw_rect(rect.grow(1.0), Color(UiKit.OLD_GOLD, 0.8), false, 1.5)
		frame.draw_rect(rect.grow(-1.0), Color(UiKit.INK, 0.5), false, 2.0))
	holder.add_child(frame)
	return holder


## BC-1 and BC-3: the whole painting as a figure that fades into the dark at its right and foot (no frame), as a
## control of this size; flip: mirrored, to look to the other side (the angel on the right of the meeting). The shader
## only multiplies the alpha. null without a picture.
const FADE := "shader_type canvas_item;\nuniform bool flip = false;\nvoid fragment() {\n\tvec2 uv = vec2(flip ? 1.0 - UV.x : UV.x, UV.y);\n\tvec4 c = texture(TEXTURE, uv);\n\tfloat inner = flip ? UV.x : 1.0 - UV.x;\n\tfloat outer = flip ? 1.0 - UV.x : UV.x;\n\tfloat a = smoothstep(0.0, 0.45, inner) * smoothstep(0.0, 0.14, outer) * smoothstep(0.0, 0.1, UV.y) * smoothstep(0.0, 0.3, 1.0 - UV.y);\n\tCOLOR = vec4(c.rgb, c.a * a);\n}\n"
static var _fade: Shader


static func figure(a: AngelDef, size_px: Vector2, flip := false) -> Control:
	var tex := texture(a.id)
	if tex == null:
		return null
	if _fade == null:
		_fade = Shader.new()
		_fade.code = FADE
	var holder := Control.new()
	holder.name = "angel_art"
	holder.custom_minimum_size = size_px
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := TextureRect.new()
	r.name = "Figure"
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = _fade
	m.set_shader_parameter(&"flip", flip)
	r.material = m
	holder.add_child(r)
	return holder
