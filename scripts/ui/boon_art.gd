class_name BoonArt
extends RefCounted
## Painted medallions of the gift cards, found by the gift's id: assets/ui/boons/<id>.png (transparent outside the
## frame; cut from the reference boards by tools/cut_medallions.gd). A gift without its own painting keeps the drawn
## BoonIcon. Only the gift card uses them; the HUD and the gifts panel keep the drawn icons (the same motif, small).
## Stage 1A of the art pack (2026-11-17): Brasas, Toque da Geada, Maré de Luz and Escudo da Vigília joined Vapor,
## Aurora Gelada and Redemoinho de Fogo; the events' medallions are in assets/ui/events/ (event: the altar's
## pomegranate, candles and passage, the Provação's cracked seal).

const DIR := "res://assets/ui/boons/"
const EVENT_DIR := "res://assets/ui/events/"

static var _cache: Dictionary = {}


## The painted medallion of a gift, or null when it has none.
static func medallion(id: StringName) -> Texture2D:
	return _load(DIR + String(id) + ".png")


## An event's painted medallion by name (pomegranate, candles, passage, trial_seal), or null.
static func event(name_: StringName) -> Texture2D:
	return _load(EVENT_DIR + String(name_) + ".png")


static func _load(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[path] = tex
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
