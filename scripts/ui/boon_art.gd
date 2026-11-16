class_name BoonArt
extends RefCounted
## Painted medallions of the gift cards, found by the gift's id: assets/ui/boons/<id>.png (transparent outside the
## frame; cut from the reference board by tools/cut_medallions.gd). A gift without its own painting keeps the drawn
## BoonIcon. Only the gift card uses them; the HUD and the gifts panel keep the drawn icons.

const DIR := "res://assets/ui/boons/"

static var _cache: Dictionary = {}


## The painted medallion of a gift, or null when it has none.
static func medallion(id: StringName) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var path := DIR + String(id) + ".png"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[id] = tex
	return tex


## A painted medallion as a control of this size, filtered with mipmaps (the board is 512 px, shown at 120 to 200).
static func rect(tex: Texture2D, side: float) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.custom_minimum_size = Vector2(side, side)
	r.size = Vector2(side, side)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
