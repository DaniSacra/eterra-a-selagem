class_name DoorGlyph
extends Control
## The pictogram on a door's sign (E5-D9, docs/art/e5_spec.md 7.1), left of its name, as tall as the name's capitals:
## the kind of room behind the door read before the words. A fight with an elite one chevron of old gold (the HUD's
## elite chevron, upright), the guardian two, Morvath three; the fountain a drop, the shop a coin, the altar a candle's
## flame, the Provação's slab the cracked diamond (TrialSeal). A common fight has none. Ivory strokes 2 px at 1080 lines
## over a dark outline; the chevrons in old gold.

enum Kind { NONE, HARD, GUARDIAN, BOSS, FOUNTAIN, SHOP, ALTAR, TRIAL }

## Height of the glyph on the sign's canvas (the name's capitals are about 13; a little taller reads better).
const HEIGHT := 17.0
## Stroke (2 px at 1080 lines) and its dark outline.
const STROKE := 1.4
const OUTLINE := 3.4
const IVORY := Color(0.97, 0.93, 0.84)
const OUTLINE_COLOR := DoorSign.OUTLINE_COLOR
## The chevrons' old gold, lit enough to read over the dark (the HUD's OLD_GOLD is a frame colour, too dim for a mark).
const CHEVRON_GOLD := Color(0.83, 0.68, 0.4)

var kind := Kind.NONE


## The glyph for what a door tells (Rooms.door_info: kind, hard, guardian).
static func of(info: Dictionary) -> Kind:
	if info.is_empty():
		return Kind.NONE
	match int(info.get("kind", RunMap.Kind.COMBAT)):
		RunMap.Kind.BOSS:
			return Kind.BOSS
		RunMap.Kind.MINIBOSS:
			return Kind.GUARDIAN
		RunMap.Kind.FOUNTAIN:
			return Kind.FOUNTAIN
		RunMap.Kind.SHOP:
			return Kind.SHOP
		RunMap.Kind.ALTAR:
			return Kind.ALTAR
		RunMap.Kind.TRIAL:
			return Kind.TRIAL
	return Kind.HARD if bool(info.get("hard", false)) else Kind.NONE


## How many chevrons a kind has (0 for the others).
static func chevrons(k: Kind) -> int:
	match k:
		Kind.HARD:
			return 1
		Kind.GUARDIAN:
			return 2
		Kind.BOSS:
			return 3
	return 0


func setup(k: Kind) -> DoorGlyph:
	kind = k
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := chevrons(k)
	custom_minimum_size = Vector2(HEIGHT * (0.8 + 0.42 * maxi(n - 1, 0)) if n > 0 else HEIGHT, HEIGHT)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return self


func _draw() -> void:
	var h := HEIGHT
	var c := size * 0.5
	match kind:
		Kind.HARD, Kind.GUARDIAN, Kind.BOSS:
			# upright chevrons side by side, like the ranks on a sleeve
			var n := chevrons(kind)
			var w := h * 0.8
			for i in n:
				var x := (size.x - (w + h * 0.42 * (n - 1))) * 0.5 + i * h * 0.42
				var pts := PackedVector2Array([Vector2(x + w * 0.08, h * 0.86), Vector2(x + w * 0.5, h * 0.2), Vector2(x + w * 0.92, h * 0.86)])
				_stroke(pts, CHEVRON_GOLD, STROKE + 1.3)
		Kind.FOUNTAIN:
			var drop := PackedVector2Array()
			for k in 13:
				var a := PI * 0.5 + (k / 12.0 - 0.5) * PI * 1.5
				drop.append(c + Vector2(cos(a), sin(a) * 0.95) * h * 0.3 + Vector2(0, h * 0.14))
			drop.insert(0, c + Vector2(0, -h * 0.44))
			drop.append(drop[0])
			_stroke(drop, IVORY, STROKE)
		Kind.SHOP:
			draw_arc(c, h * 0.36, 0.0, TAU, 24, OUTLINE_COLOR, OUTLINE, true)
			draw_arc(c, h * 0.36, 0.0, TAU, 24, IVORY, STROKE, true)
			_stroke(PackedVector2Array([c + Vector2(0, -h * 0.17), c + Vector2(0, h * 0.17)]), IVORY, STROKE)
		Kind.ALTAR:
			# a candle's flame over a short stub of wax
			var flame := PackedVector2Array([c + Vector2(0, -h * 0.46), c + Vector2(h * 0.16, -h * 0.14), c + Vector2(h * 0.1, h * 0.04),
				c + Vector2(-h * 0.1, h * 0.04), c + Vector2(-h * 0.16, -h * 0.14), c + Vector2(0, -h * 0.46)])
			_stroke(flame, IVORY, STROKE)
			_stroke(PackedVector2Array([c + Vector2(-h * 0.14, h * 0.18), c + Vector2(-h * 0.14, h * 0.46), c + Vector2(h * 0.14, h * 0.46),
				c + Vector2(h * 0.14, h * 0.18), c + Vector2(-h * 0.14, h * 0.18)]), IVORY, STROKE)
		Kind.TRIAL:
			TrialSeal.draw_seal(self, c, h * 0.5)


func _stroke(pts: PackedVector2Array, col: Color, width: float) -> void:
	draw_polyline(pts, OUTLINE_COLOR, width + OUTLINE - STROKE, true)
	draw_polyline(pts, col, width, true)
