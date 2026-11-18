class_name TrialSeal
extends Control
## The Provação's mark (E5, docs/art/e5_spec.md 5.3; decision E5-D7): a grey-lilac diamond with a crack down it. In the
## HUD, beside the hero's medallion while a curse of the Provação is carried, with the fights still to win inside it
## and the curse's name beside it; nothing on the hero's body, on Emeth or on the floor (the violet aura is Morvath's
## curse). No ring that empties (that is ConditionBadge, seconds; this one counts fights).
## The turn (turn()): the crack fills with old gold in TURN_FILL seconds, the diamond turns gold and fades after
## TURN_HOLD. The same drawing (draw_seal) is the card's crest (BoonCard.setup_trial), the slab's pictogram (DoorGlyph)
## and the "Provação vencida" greeting's medallion (EloBanner.show_trial).
##   var seal := TrialSeal.new().setup(22.0, true)   # in the HUD: the number and the name beside it
##   seal.carry(rooms.trials.active, rooms.trials.left)

## The seal's colours (spec 5.3): the grey lilac of its edge, the dark lilac ink inside, the pale lilac of its words.
const LILAC := Color(0.62, 0.56, 0.74)
const INK := Color(0.16, 0.12, 0.22)
const PALE := Color(0.82, 0.76, 0.92)
## The lilac of the slab's light and the chamber's veins (Rooms.TRIAL_COLOR), for glows.
const GLOW := Color(0.52, 0.36, 0.78)
## Seconds the crack takes to fill with gold, and the gold seal stays before it fades.
const TURN_FILL := 0.4
const TURN_HOLD := 2.2
const FADE := 0.35
const NAME_SIZE := 14
const NUMBER_SIZE := 13
## How much of the crack shows behind the count.
const CRACK_BEHIND := 0.45
const TEXT_GAP := 6.0

## The diamond's width and height (pixels at 720 lines).
var side := 22.0
## Shows the count inside and the curse's name beside it (the HUD); the card and the sign show only the mark.
var with_text := false
## The fights still to carry (0: none) and the curse's name.
var left := 0
var curse_name := ""
## Hides the name beside it (the HUD, while Morvath's curse badge stands where the name would run).
var hide_name := false
## 0..1: how much of the crack is gold (the turn); 1 stays gold.
var gold := 0.0
var _show := 0.0
var _turn_t := -1.0


func setup(side_px: float, text: bool = false, gold_: float = 0.0) -> TrialSeal:
	side = side_px
	with_text = text
	gold = gold_
	_show = 0.0 if text else 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(side, side)
	size = custom_minimum_size
	set_process(text)
	return self


## What is carried now (the HUD, once a frame): the card (null: nothing) and the fights left.
func carry(card: Trials.Card, left_: int) -> void:
	if _turn_t >= 0.0:
		return
	if card != null:
		left = left_
		curse_name = T.t(card.curse.name_key)
		_resize()
	elif left > 0:
		left = 0
	queue_redraw()


## The curse turned into its blessing: the crack fills with gold, then the seal fades.
func turn(card: Trials.Card = null) -> void:
	if card != null:
		curse_name = T.t(card.blessing.name_key)
		_resize()
	left = 0
	_turn_t = 0.0
	_show = 1.0
	set_process(true)


## How much of it shows (0 hidden, 1 whole; the tests read it).
func shown() -> float:
	return _show


## Whether it is turning to gold now.
func turning() -> bool:
	return _turn_t >= 0.0


func _resize() -> void:
	var w := side
	if with_text and curse_name != "":
		w += TEXT_GAP + UiKit.BOLD_FONT.get_string_size(curse_name, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE).x + 4.0
	custom_minimum_size = Vector2(w, side)
	size = custom_minimum_size


func _process(delta: float) -> void:
	if not with_text:
		set_process(false)
		return
	if _turn_t >= 0.0:
		_turn_t += delta
		gold = clampf(_turn_t / TURN_FILL, 0.0, 1.0)
		_show = clampf((TURN_FILL + TURN_HOLD + FADE - _turn_t) / FADE, 0.0, 1.0)
		if _turn_t >= TURN_FILL + TURN_HOLD + FADE:
			_turn_t = -1.0
			gold = 0.0
			_show = 0.0
	else:
		_show = move_toward(_show, 1.0 if left > 0 else 0.0, delta / FADE)
	queue_redraw()


func _draw() -> void:
	if _show <= 0.0:
		return
	var c := Vector2(side * 0.5, side * 0.5)
	# with the count inside, the crack steps back so the number reads first (until the turn fills it with gold)
	var counting := with_text and left > 0 and gold <= 0.0
	draw_seal(self, c, side * 0.5, gold, _show, CRACK_BEHIND if counting else 1.0)
	if not with_text:
		return
	if left > 0 and gold <= 0.0:
		var n := str(left)
		var font := UiKit.number_font()
		var w := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER_SIZE).x
		var at := c + Vector2(-w * 0.5, NUMBER_SIZE * 0.36)
		draw_string_outline(font, at, n, HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER_SIZE, 3, Color(UiKit.INK, _show))
		draw_string(font, at, n, HORIZONTAL_ALIGNMENT_LEFT, -1, NUMBER_SIZE, Color(PALE.lightened(0.3), _show))
	if curse_name != "" and not hide_name:
		var at := Vector2(side + TEXT_GAP, side * 0.5 + NAME_SIZE * 0.36)
		var ink := PALE.lerp(UiKit.GOLD, gold)
		draw_string_outline(UiKit.BOLD_FONT, at + Vector2(0, UiKit.SHADOW_DROP), curse_name, HORIZONTAL_ALIGNMENT_LEFT, -1,
				NAME_SIZE, UiKit.SHADOW_SPREAD, Color(UiKit.SHADOW, UiKit.SHADOW.a * _show))
		draw_string_outline(UiKit.BOLD_FONT, at, curse_name, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE, 4, Color(UiKit.INK, _show))
		draw_string(UiKit.BOLD_FONT, at, curse_name, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE, Color(ink, _show))


## The four corners of a diamond around c, half its width and height away (top, right, bottom, left).
static func diamond(c: Vector2, half: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -half), c + Vector2(half, 0), c + Vector2(0, half), c + Vector2(-half, 0)])


## The crack, in units of the half size from the middle: from the top corner down to the lower right edge, broken.
const CRACK: Array[Vector2] = [Vector2(-0.06, -0.92), Vector2(0.14, -0.5), Vector2(-0.12, -0.18), Vector2(0.2, 0.18), Vector2(0.06, 0.42), Vector2(0.42, 0.56)]
## A short branch off the crack.
const BRANCH: Array[Vector2] = [Vector2(-0.12, -0.18), Vector2(-0.46, -0.04)]


## The seal at c, half wide: ink outline, the grey-lilac edge, the dark lilac inside and the crack; gold (0..1) fills
## the crack and the edge with old gold (the turn). alpha fades it all; crack_alpha only the crack.
static func draw_seal(ci: CanvasItem, c: Vector2, half: float, gold_: float = 0.0, alpha: float = 1.0, crack_alpha: float = 1.0) -> void:
	var edge := LILAC.lerp(UiKit.OLD_GOLD.lightened(0.25), gold_)
	ci.draw_colored_polygon(diamond(c, half + 1.5), Color(UiKit.INK, 0.92 * alpha))
	ci.draw_colored_polygon(diamond(c, half), Color(edge, alpha))
	var rim := maxf(1.5, half * 0.16)
	ci.draw_colored_polygon(diamond(c, half - rim), Color(INK.lerp(UiKit.OLD_GOLD.darkened(0.55), gold_), alpha))
	var crack := PackedVector2Array()
	for p in CRACK:
		crack.append(c + p * (half - rim))
	var branch := PackedVector2Array()
	for p in BRANCH:
		branch.append(c + p * (half - rim))
	var w := maxf(1.0, half * 0.1)
	var line := Color(LILAC.lightened(0.15).lerp(UiKit.GOLD, gold_), alpha * crack_alpha)
	ci.draw_polyline(crack, Color(UiKit.INK, alpha * 0.8 * crack_alpha), w + 1.5, true)
	ci.draw_polyline(crack, line, w, true)
	ci.draw_polyline(branch, line, maxf(1.0, w * 0.7), true)


## A number of one half of a card as the player reads it (25%, 15): its first modifier at the rarity (a curse: 0).
static func value_text(d: TrialDef, rarity: int = 0) -> String:
	if d.mods.is_empty():
		return ""
	return BoonMod.format(d.mods[0].stat, absf(d.value(rarity)))


## What the blessing of a card gives, with its number at the card's rarity.
static func blessing_text(card: Trials.Card) -> String:
	return T.t(card.blessing.desc_key, {"value": value_text(card.blessing, card.rarity)})


## T5 (A-T5-5): the medallion of a blessing of the Provação, read from its first modifier (its tag: the action it
## strengthens; else its stat), so a new blessing with words that exist gets one with no code: [BoonIcon glyph, colour].
const BLESSING_LOOK := {
	&"light": [BoonIcon.ACTION_GLYPH + 1, Color(0.88, 0.54, 0.34)],
	&"heavy": [BoonIcon.ACTION_GLYPH + 2, Color(0.36, 0.76, 0.58)],
	&"cast": [BoonIcon.ACTION_GLYPH + 3, Color(0.86, 0.72, 0.42)],
	&"dash": [BoonIcon.ACTION_GLYPH + 4, Color(0.5, 0.72, 0.86)],
	&"max_hp": [6, Color(0.84, 0.36, 0.4)],
	&"magick_max": [BoonIcon.MAGICK_GLYPH, Color(0.25, 0.6, 0.78)],
}
## An unknown word: the plain gem (BoonIcon's default glyph) in old gold.
const BLESSING_PLAIN := [999, Color(0.83, 0.68, 0.4)]


## [glyph, colour] of a blessing's medallion.
static func blessing_look(d: TrialDef) -> Array:
	if d == null or d.mods.is_empty():
		return BLESSING_PLAIN
	var m: BoonMod = d.mods[0]
	return BLESSING_LOOK.get(m.tag if m.tag != &"" else m.stat, BLESSING_LOOK.get(m.stat, BLESSING_PLAIN))


## What the curse of a card does, with its number.
static func curse_text(card: Trials.Card) -> String:
	return T.t(card.curse.desc_key, {"value": value_text(card.curse)})
