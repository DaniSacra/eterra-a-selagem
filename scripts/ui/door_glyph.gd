class_name DoorGlyph
extends Control
## The pictogram on a door's sign (E5-D9, docs/art/e5_spec.md 7.1), left of its name, as tall as the name's capitals:
## the kind of room behind the door read before the words. A fight with an elite one chevron of old gold (the HUD's
## elite chevron, upright), the guardian two, Morvath three; the fountain a drop, the shop a coin, the altar a candle's
## flame, the Provação's slab the cracked diamond (TrialSeal). A common fight has none. Ivory strokes 2 px at 1080 lines
## over a dark outline; the chevrons in old gold.
## Stage 1A of the art pack (2026-11-17): the rewards have their own marks too, the same wherever the reward shows
## (of_reward): on the door's sign left of the reward's name (the room's chevrons then go to the line under it), on the
## shop's signs, and on the altar's cards beside what is given and got. A Blessing is the cards' own ornament (a ring
## around the diamond of their rule), a pomegranate the altar's (SealMedal's), the heart the life's, the cut gem the
## Magia's (the Provação's Magia ampla), a coin the gold, a drop the healing. setup(kind, height) draws any of them at
## any height (the cards use 18 to 20 px).

## UNKNOWN (DV-1, MAP-03): a room of the descent's map whose content stays hidden until its slab shows (Q-25 a: the
## Provação's room only), a question mark in the same ivory stroke.
## SILVER and MEMORY (Rejogabilidade, Fatia 1): Prata Antiga an ingot of old silver, Fragmento de Memória a leaf of
## parchment torn at its corner with lines of ink (the in-world medallion's own marks, RewardGem.Mark INGOT and LEAF);
## the same wherever a material shows (doors, the map, the Forja, the Livro, the end screen, the hub: MaterialCount).
enum Kind { NONE, HARD, GUARDIAN, BOSS, FOUNTAIN, SHOP, ALTAR, TRIAL, BLESSING, POMEGRANATE, HEART, MAGICK, GOLD, HEAL, UNKNOWN, SILVER, MEMORY }

## Height of the glyph on the sign's canvas (the name's capitals are about 13; a little taller reads better).
const HEIGHT := 17.0
## Stroke (2 px at 1080 lines) and its dark outline, at HEIGHT (they grow with a taller glyph).
const STROKE := 1.4
const OUTLINE := 3.4
const IVORY := Color(0.97, 0.93, 0.84)
const OUTLINE_COLOR := DoorSign.OUTLINE_COLOR
## The chevrons' old gold, lit enough to read over the dark (the HUD's OLD_GOLD is a frame colour, too dim for a mark).
const CHEVRON_GOLD := Color(0.83, 0.68, 0.4)
## The rewards' fills: the pomegranate's red, the life's rose, the Magia's blue, the gold's old gold, the healing's
## green (the hues of the gems over the doors, Rooms._reward_color, darkened to read on ink).
const POM_RED := Color(0.78, 0.26, 0.32)
const LIFE_ROSE := Color(0.86, 0.3, 0.4)
const MAGICK_BLUE := Color(0.42, 0.62, 0.95)
const COIN_GOLD := Color(0.86, 0.68, 0.36)
const HEAL_GREEN := Color(0.5, 0.86, 0.6)
## The materials' fills: old silver (cool, greyed, never white) and parchment, with ink lines on the leaf.
const SILVER_FILL := Color(0.62, 0.65, 0.7)
const PARCHMENT_FILL := Color(0.84, 0.74, 0.55)
const LEAF_INK := Color(0.2, 0.14, 0.09)

var kind := Kind.NONE
var height := HEIGHT


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


## The mark of a reward (NONE for none).
static func of_reward(r: RunMap.Reward) -> Kind:
	match r:
		RunMap.Reward.BOON:
			return Kind.BLESSING
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return Kind.POMEGRANATE
		RunMap.Reward.HEART:
			return Kind.HEART
		RunMap.Reward.MAGICK:
			return Kind.MAGICK
		RunMap.Reward.GOLD:
			return Kind.GOLD
		RunMap.Reward.HEAL:
			return Kind.HEAL
		RunMap.Reward.SILVER:
			return Kind.SILVER
		RunMap.Reward.MEMORY:
			return Kind.MEMORY
	return Kind.NONE


## The mark of a material (MaterialPurse.SILVER, MEMORY; NONE for the others).
static func of_material(id: StringName) -> Kind:
	match id:
		MaterialPurse.SILVER:
			return Kind.SILVER
		MaterialPurse.MEMORY:
			return Kind.MEMORY
	return Kind.NONE


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


func setup(k: Kind, height_px: float = HEIGHT) -> DoorGlyph:
	kind = k
	height = height_px
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := chevrons(k)
	custom_minimum_size = Vector2(height * (0.8 + 0.42 * maxi(n - 1, 0)) if n > 0 else height, height)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return self


func _draw() -> void:
	var h := height
	var k := h / HEIGHT
	var stroke := STROKE * k
	var c := size * 0.5
	match kind:
		Kind.HARD, Kind.GUARDIAN, Kind.BOSS:
			# upright chevrons side by side, like the ranks on a sleeve
			var n := chevrons(kind)
			var w := h * 0.8
			for i in n:
				var x := (size.x - (w + h * 0.42 * (n - 1))) * 0.5 + i * h * 0.42
				var pts := PackedVector2Array([Vector2(x + w * 0.08, h * 0.86), Vector2(x + w * 0.5, h * 0.2), Vector2(x + w * 0.92, h * 0.86)])
				_stroke(pts, CHEVRON_GOLD, stroke + 1.3 * k)
		Kind.FOUNTAIN, Kind.HEAL:
			var drop := PackedVector2Array()
			for j in 13:
				var a := PI * 0.5 + (j / 12.0 - 0.5) * PI * 1.5
				drop.append(c + Vector2(cos(a), sin(a) * 0.95) * h * 0.3 + Vector2(0, h * 0.14))
			drop.insert(0, c + Vector2(0, -h * 0.44))
			drop.append(drop[0])
			if kind == Kind.HEAL:
				draw_colored_polygon(drop, HEAL_GREEN.darkened(0.25))
			_stroke(drop, IVORY, stroke)
		Kind.SHOP, Kind.GOLD:
			# a coin: a ring and a short upright stroke (the gold's, filled in old gold)
			if kind == Kind.GOLD:
				draw_circle(c, h * 0.36, COIN_GOLD.darkened(0.2))
			draw_arc(c, h * 0.36, 0.0, TAU, 24, OUTLINE_COLOR, stroke + (OUTLINE - STROKE) * k, true)
			draw_arc(c, h * 0.36, 0.0, TAU, 24, IVORY, stroke, true)
			_stroke(PackedVector2Array([c + Vector2(0, -h * 0.17), c + Vector2(0, h * 0.17)]), IVORY, stroke)
		Kind.ALTAR:
			# a candle's flame over a short stub of wax
			var flame := PackedVector2Array([c + Vector2(0, -h * 0.46), c + Vector2(h * 0.16, -h * 0.14), c + Vector2(h * 0.1, h * 0.04),
				c + Vector2(-h * 0.1, h * 0.04), c + Vector2(-h * 0.16, -h * 0.14), c + Vector2(0, -h * 0.46)])
			_stroke(flame, IVORY, stroke)
			_stroke(PackedVector2Array([c + Vector2(-h * 0.14, h * 0.18), c + Vector2(-h * 0.14, h * 0.46), c + Vector2(h * 0.14, h * 0.46),
				c + Vector2(h * 0.14, h * 0.18), c + Vector2(-h * 0.14, h * 0.18)]), IVORY, stroke)
		Kind.TRIAL:
			TrialSeal.draw_seal(self, c, h * 0.5)
		Kind.BLESSING:
			# the cards' ornament: a ring of ivory around the diamond of their rule, in old gold
			draw_arc(c, h * 0.4, 0.0, TAU, 28, OUTLINE_COLOR, stroke + (OUTLINE - STROKE) * k, true)
			draw_arc(c, h * 0.4, 0.0, TAU, 28, IVORY, stroke, true)
			var d := h * 0.2
			var dia := PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)])
			draw_colored_polygon(dia, CHEVRON_GOLD)
		Kind.POMEGRANATE:
			draw_circle(c + Vector2(0, h * 0.06), h * 0.42, OUTLINE_COLOR)
			SealMedal.draw_glyph(self, SealMedal.Glyph.POMEGRANATE, c, h * 0.48, maxf(1.0, stroke * 0.8), POM_RED)
		Kind.HEART:
			BoonIcon.glyph(self, 6, c + Vector2(0, h * 0.02), h * 0.5, OUTLINE_COLOR, OUTLINE_COLOR)
			BoonIcon.glyph(self, 6, c, h * 0.42, LIFE_ROSE, LIFE_ROSE)
		Kind.MAGICK:
			BoonIcon.glyph(self, BoonIcon.MAGICK_GLYPH, c, h * 0.52, OUTLINE_COLOR, OUTLINE_COLOR)
			BoonIcon.glyph(self, BoonIcon.MAGICK_GLYPH, c, h * 0.44, MAGICK_BLUE, MAGICK_BLUE.darkened(0.45))
		Kind.SILVER, Kind.MEMORY:
			material(self, kind, c, h)
		Kind.UNKNOWN:
			# a question mark drawn in the signs' stroke: a hook over a short stem, and a dot
			var hook := PackedVector2Array()
			for j in 11:
				var a := PI * 1.05 + j / 10.0 * PI * 1.35
				hook.append(c + Vector2(cos(a) * h * 0.22, sin(a) * h * 0.2 - h * 0.18))
			hook.append(c + Vector2(0, h * 0.04))
			hook.append(c + Vector2(0, h * 0.16))
			_stroke(hook, IVORY, stroke * 1.15)
			draw_circle(c + Vector2(0, h * 0.36), stroke * 1.9 + (OUTLINE - STROKE) * k * 0.5, OUTLINE_COLOR)
			draw_circle(c + Vector2(0, h * 0.36), stroke * 1.2, IVORY)


## A material's mark drawn on any canvas (the Gift tree's cost under a sealed Gift uses it), h tall around c.
static func material(ci: CanvasItem, k: Kind, c: Vector2, h: float) -> void:
	var o := maxf(1.0, h * 0.09)
	if k == Kind.SILVER:
		# an ingot seen from the front and a little above: the top narrower, a groove across it
		var w := h * 0.46
		var pts := PackedVector2Array([c + Vector2(-w * 0.62, -h * 0.24), c + Vector2(w * 0.62, -h * 0.24),
			c + Vector2(w, h * 0.26), c + Vector2(-w, h * 0.26)])
		ci.draw_colored_polygon(_grown(pts, c, o), OUTLINE_COLOR)
		ci.draw_colored_polygon(pts, SILVER_FILL)
		ci.draw_line(c + Vector2(-w * 0.72, -h * 0.08), c + Vector2(w * 0.72, -h * 0.08), SILVER_FILL.darkened(0.35), maxf(1.0, h * 0.06), true)
		ci.draw_line(c + Vector2(-w * 0.5, -h * 0.2), c + Vector2(w * 0.3, -h * 0.2), SILVER_FILL.lightened(0.35), maxf(1.0, h * 0.05), true)
		return
	# a leaf a little askew, its lower right corner torn away, three lines written on it
	var leaf := PackedVector2Array()
	for p: Vector2 in [Vector2(-0.3, -0.42), Vector2(0.34, -0.38), Vector2(0.32, 0.12), Vector2(0.2, 0.2), Vector2(0.24, 0.3),
			Vector2(0.06, 0.34), Vector2(0.0, 0.44), Vector2(-0.34, 0.4)]:
		leaf.append(c + p * h)
	ci.draw_colored_polygon(_grown(leaf, c, o), OUTLINE_COLOR)
	ci.draw_colored_polygon(leaf, PARCHMENT_FILL)
	for i in 3:
		var y := -0.22 + i * 0.17
		var reach := 0.22 if i < 2 else 0.04
		ci.draw_line(c + Vector2(-0.2, y) * h, c + Vector2(reach, y - 0.02) * h, LEAF_INK, maxf(1.0, h * 0.06), true)


static func _grown(pts: PackedVector2Array, c: Vector2, by: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p + (p - c).normalized() * by)
	return out


func _stroke(pts: PackedVector2Array, col: Color, width: float) -> void:
	draw_polyline(pts, OUTLINE_COLOR, width + (OUTLINE - STROKE) * height / HEIGHT, true)
	draw_polyline(pts, col, width, true)
