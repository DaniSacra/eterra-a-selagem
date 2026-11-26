class_name ActionSlot
extends Control
## One of the paladin's four actions in the HUD: a diamond in the HUD's gold frame, the gift that changed the action
## (or the bare action), the key or button under it, and its state. Ready: the glyph in ivory. Recharging: the glyph
## dimmed over a dark gem that fills again from the bottom with a level of old gold as the recharge runs (how much
## is left reads at a glance, even on a bare action whose gem is near black) and a pale line that runs around the
## frame, then a short shine. The dodges show
## as gems in the lower half; a dull blue dash there says the held (Omega) version has no Magia.
## Someone standing behind the diamond (veil): only the body goes translucent; the glyph, the recharge and the key
## stay whole (cycle 7 faded all of it, and a recharging action almost vanished).
## Locked (a boss's curse): the gem veiled in the condition's violet, the glyph dimmed under a padlock, a violet line
## around the frame that shrinks as the lock runs out; the moment it lifts, a ring of light leaves the diamond
## (RELEASE seconds), stronger than the shine of a plain recharge.
## The Psalm of the Pastor (E4) on the special: the lights gathered as small diamonds over the top of the frame, lit in
## the Psalm's colour, dark sockets for the ones still to gather (lights_max 0: none drawn).
## The ultimate's diamond (T5): sealed while the Mastery has not unlocked it (dark gem, dimmed glyph, an old gold
## padlock), a short caption over it that says what is missing ("Maestria 2", "Carga 40%") or "Pronta", and, full, a
## slow pale pulse around the frame so a ready ultimate never looks like any idle action.
## Stage 1A of the art pack (2026-11-17): ready, the diamond wears a closed ring of light around its frame (READY_*),
## a brief pulse runs out of it once when it fills (READY_PULSE), then the ring only breathes a little. Tied to the
## real state: pulse is the charge being full (Hud._update_ult), the ring goes with it.

const DIAMOND := 54.0
const KEY_H := 17.0
const KEY_FONT := 14
## PT-26-4: the mouse icon under a diamond (px tall: the left and right buttons read apart) and the action's short
## name under the key (always there: what each diamond is).
const MOUSE_H := 30.0
const NAME_FONT := 13
const NAME_H := 15.0
## How long the frame shines after the recharge ends.
const READY_FLASH := 0.25
const IVORY := Color(1.0, 0.97, 0.88)
## The glyph while the action recharges, and the veil over the gem.
const BUSY_ALPHA := 0.6
const VEIL := Color(0.0, 0.0, 0.02, 0.62)
## The level of old gold that rises in the gem as it recharges (its opacity).
const REFILL_ALPHA := 0.42
## The body's opacity with someone behind it (Hud).
const SEE_THROUGH := 0.45
## The dodge gems: half width in pixels, the gap between them, lit and spent.
const CHARGE := 4.0
const CHARGE_GAP := 13.0
const CHARGE_LIT := Color(0.55, 0.88, 1.0)
const CHARGE_SPENT := Color(0.17, 0.19, 0.25)
## The dash under the glyph when the Omega cannot be paid: Magia's blue, dulled.
const STARVED := Color("44708c")
const STARVED_SIZE := Vector2(14.0, 3.0)
## The lock: its colour (the curse's violet, CurseAura.COLOR), the veil over the gem, the glyph under it and how
## long (seconds) and how far (pixels) the ring of its release runs.
const LOCK := Color(0.62, 0.32, 0.95)
const LOCK_VEIL := Color(0.16, 0.04, 0.24, 0.78)
const LOCK_GLYPH := 0.3
const RELEASE := 0.45
const RELEASE_REACH := 16.0
## The lights over the diamond: half width, the gap between them, how far above the top of the frame.
const LIGHT := 3.5
const LIGHT_GAP := 10.0
const LIGHT_RISE := 7.0
## The caption over the diamond (T5): its size, how far over the frame, and the ready pulse's period and reach.
const CAPTION_FONT := 14
const SECS_FONT := 17
const CAPTION_RISE := 6.0
## The ready ring: its gap from the frame, width, colour (Emeth's pale emerald, lit under the glow), how much it
## breathes and how fast; the pulse when it fills: seconds and reach.
const READY_GAP := 3.0
const READY_W := 2.0
const READY_COLOR := Color(0.72, 1.0, 0.86)
const READY_BREATH := 0.2
## The urgent ring (full charge, hero hurt): deeper breath, thicker line, faster.
const URGENT_BREATH := 0.55
const URGENT_W := 3.5
const URGENT_SPEED := 2.0
const PULSE_PERIOD := 1.6
const READY_PULSE := 0.55
const PULSE_REACH := 12.0
const SEAL_VEIL := Color(0.02, 0.016, 0.03, 0.7)
const SEAL_GLYPH := 0.35
## The Magia cost's gem: its half size against the diamond's, where its centre stands (share of the radius, up and
## right of the middle) and its number's size.
const COST_GEM := 0.46
const COST_AT := 0.62
const COST_FONT := 12
const COST_COLOR := Color("2a8fb8")
## GP-1: the red of a refused press, the charge ring and the Ritmo's arc.
const REFUSE_TIME := 0.5
const REFUSE_COLOR := Color(0.95, 0.3, 0.26)
const CHARGE_RING := Color(0.45, 0.8, 1.0)
const RHYTHM_COLOR := Color(1.0, 0.82, 0.36)
const RHYTHM_GAP := 4.0

var action: StringName
var slot: Boon.Slot
## The diamond's height in pixels (DIAMOND; the --hud=row test layout draws them smaller, Hud.ROW_DIAMOND).
var side := DIAMOND
## How far under the diamond's lower point the key's plate stands (0: over the point; the small diamonds of the row
## layout hang it below, or the plate and the little mouse would cover half the glyph).
var key_drop := 0.0
var boon: Boon
## 0..1: the part still recharging.
var wait := 0.0
## Charges, drawn as small gems in the lower half (the dodges); 0 for none.
var charges := 0
var charges_max := 0
## The held version of the action costs more Magia than there is.
var starved := false
## What the action costs in Magia, drawn as a small blue gem on the diamond's upper right (0: nothing; the rajada's 8).
var cost := 0:
	set(v):
		if v != cost:
			cost = v
			queue_redraw()
## GP-1: a button with two gestures (the Warrior's left and right). tap_cost and hold_cost are the Magia of the touch and of the
## hold (the touch gem sits on the diamond's upper left, the hold gem, ringed, on the upper right; 0 draws none and a button
## whose touch is free shows only the hold's); each dims on its own when the Magia lacks (tap_starved, hold_starved).
## hold_text is the hold's name beside label_text ("Ataque · Esmagador").
var tap_cost := 0
var hold_cost := 0
var tap_starved := false
var hold_starved := false
var hold_text := "":
	set(v):
		if v != hold_text:
			hold_text = v
			_fit_width()
			queue_redraw()
## 0..1: how much of the held blow is charged (a ring that fills round the frame; 0 hides it) and the Ritmo's share still to
## run (a thin gold arc outside the frame; 0 hides it).
var charge := 0.0:
	set(v):
		v = snappedf(clampf(v, 0.0, 1.0), 0.01)
		if v != charge:
			charge = v
			queue_redraw()
var rhythm := 0.0:
	set(v):
		v = snappedf(clampf(v, 0.0, 1.0), 0.02)
		if v != rhythm:
			rhythm = v
			queue_redraw()
## Seconds a refused press (no Magia) keeps the diamond's frame red.
var _refused := 0.0
## 0..1: someone stands behind the diamond (its body turns translucent).
var veil := 0.0:
	set(v):
		if not is_equal_approx(v, veil):
			veil = v
			queue_redraw()
## 0..1: the action is locked (a boss's curse) and this share of the lock is still to run.
var locked := 0.0:
	set(v):
		v = snappedf(clampf(v, 0.0, 1.0), 0.01)
		if v == locked:
			return
		if locked > 0.0 and v == 0.0:
			_release = 1.0
			set_process(true)
		locked = v
		queue_redraw()
## A glyph of its own instead of the action's (BoonIcon ids; -1: the action's or the gift's). The ultimate's diamond.
var glyph := -1:
	set(v):
		if v != glyph:
			glyph = v
			queue_redraw()
## Lights gathered (the Pastor) and how many it holds; their colour.
var lights := 0
var lights_max := 0
var light_color := UiKit.OLD_GOLD
## Not unlocked yet (the ultimate before its Mastery level): sealed, nothing to press.
var sealed := false:
	set(v):
		if v != sealed:
			sealed = v
			queue_redraw()
## A short text over the diamond ("" none) and its colour.
var caption := "":
	set(v):
		if v != caption:
			caption = v
			queue_redraw()
var caption_color := UiKit.DIM:
	set(v):
		if v != caption_color:
			caption_color = v
			queue_redraw()
## Full and ready (the ultimate): the closed ring of light, and the brief pulse when it turns on.
var pulse := false:
	set(v):
		if v != pulse:
			pulse = v
			_pulse_t = 0.0
			_ready_pulse = 1.0 if v else 0.0
			set_process(true)
			queue_redraw()
## UI 10: full and the hero hurt (below Hud.ULT_HURT): the ring breathes harder, wider and faster.
var urgent := false
var _pulse_t := 0.0
## 1 -> 0 over READY_PULSE seconds after it fills.
var _ready_pulse := 0.0
## PT-26-4: the short name under the key ("" none).
var label_text := "":
	set(v):
		if v != label_text:
			label_text = v
			_fit_width()
			queue_redraw()
## PT-26: whole seconds left of a long recharge (Q, E), written over the diamond; 0: none.
var secs_left := 0
var _key := ""
var _mouse := 0
var _flash := 0.0
var _release := 0.0


func setup(action_name: StringName, action_slot: Boon.Slot, side_px: float = DIAMOND, drop: float = 0.0) -> ActionSlot:
	action = action_name
	slot = action_slot
	side = side_px
	key_drop = drop
	_fit_width()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	return self


## The slot is as wide as its diamond, or as its name when "Ataque · Esmagador" is wider.
func _fit_width() -> void:
	var w := UiKit.BOLD_FONT.get_string_size(full_name(), HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_FONT).x + 6.0
	custom_minimum_size = Vector2(maxf(side + 12.0, w), height_for(side, key_drop))


## The name under the key: the touch's, then the hold's when the button has both.
func full_name() -> String:
	return label_text if hold_text == "" else "%s · %s" % [label_text, hold_text]


## A press without the Magia for it: the frame goes red for a moment.
func refuse() -> void:
	_refused = REFUSE_TIME
	set_process(true)
	queue_redraw()


## The slot's height: the diamond, the key or mouse hanging under its point, and the name under them.
static func height_for(side_px: float, drop: float) -> float:
	return side_px + maxf(KEY_H, MOUSE_H) * 0.5 + drop + NAME_H


## Called every frame by the HUD; redraws only when something changed.
func refresh(b: Boon, wait_ratio: float, n: int = 0, n_max: int = 0, no_magick: bool = false, secs: float = 0.0) -> void:
	var key := UiKit.action_label(action)
	var mouse := UiKit.action_mouse_button(action)
	wait_ratio = snappedf(clampf(wait_ratio, 0.0, 1.0), 0.01)
	var whole_secs := ceili(secs) if wait_ratio > 0.0 else 0
	if whole_secs != secs_left:
		secs_left = whole_secs
		queue_redraw()
	if b == boon and wait_ratio == wait and n == charges and n_max == charges_max and key == _key and mouse == _mouse and no_magick == starved:
		return
	if wait > 0.0 and wait_ratio == 0.0:
		_flash = 1.0
		set_process(true)
	_mouse = mouse
	boon = b
	wait = wait_ratio
	charges = n
	charges_max = n_max
	starved = no_magick
	_key = key
	queue_redraw()


## The lights of the Pastor over the diamond (n_max 0 hides them).
func show_lights(n: int, n_max: int, col: Color = UiKit.OLD_GOLD) -> void:
	if n == lights and n_max == lights_max and col == light_color:
		return
	lights = n
	lights_max = n_max
	light_color = col
	queue_redraw()


## The action cannot be used now: it recharges and (when it has charges) none is left.
func busy() -> bool:
	return wait > 0.0 and (charges_max == 0 or charges <= 0)


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta / READY_FLASH)
	_release = maxf(0.0, _release - delta / RELEASE)
	_refused = maxf(0.0, _refused - delta)
	_pulse_t = fmod(_pulse_t + delta * (URGENT_SPEED if urgent else 1.0), PULSE_PERIOD)
	_ready_pulse = maxf(0.0, _ready_pulse - delta / READY_PULSE)
	if _flash == 0.0 and _release == 0.0 and _refused == 0.0 and not pulse:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var c := Vector2(size.x * 0.5, side * 0.5)
	var r := side * 0.5
	var gem := boon.color() if boon else Color(0.3, 0.32, 0.36)
	var core := r - UiKit.FRAME - 0.5
	var waiting := wait > 0.0
	var rim := UiKit.OLD_GOLD.darkened(0.5) if waiting else UiKit.OLD_GOLD.lerp(UiKit.PALE, _flash)
	var body := lerpf(1.0, SEE_THROUGH, veil)
	draw_colored_polygon(_diamond(c, r + 2.0), Color(UiKit.INK, 0.92 * body))
	draw_colored_polygon(_diamond(c, r), Color(rim, body))
	draw_colored_polygon(_diamond(c, r - UiKit.FRAME), Color(UiKit.INK, body))
	draw_colored_polygon(_diamond(c, core), Color(gem.darkened(0.78), body) if boon else Color(0.06, 0.045, 0.06, 0.94 * body))
	if boon:
		draw_colored_polygon(_diamond(c + Vector2(0, -r * 0.08), r * 0.72), Color(gem.darkened(0.5), body))
		draw_colored_polygon(_diamond(c + Vector2(0, -r * 0.16), r * 0.4), Color(gem.darkened(0.1), 0.55 * body))
	var lift := r * 0.14 if charges_max > 0 or starved else 0.0
	var ink := Color(IVORY, BUSY_ALPHA) if busy() else IVORY
	if busy():
		draw_colored_polygon(_diamond(c, core), VEIL)
		for part in band(c, core, wait, 1.0):
			draw_colored_polygon(part, Color(UiKit.OLD_GOLD, REFILL_ALPHA))
	if locked > 0.0:
		draw_colored_polygon(_diamond(c, core), LOCK_VEIL)
		ink = Color(IVORY, LOCK_GLYPH)
	if sealed:
		draw_colored_polygon(_diamond(c, core), SEAL_VEIL)
		ink = Color(IVORY, SEAL_GLYPH)
	var shape := glyph if glyph >= 0 else boon.icon if boon else BoonIcon.ACTION_GLYPH + slot
	BoonIcon.glyph(self, shape, c - Vector2(0, lift), r * 0.42, ink, gem.darkened(0.5))
	if locked > 0.0:
		# the violet line around the frame, shrinking from the top as the lock runs out, and the padlock over the glyph
		draw_polyline(_closed(_diamond(c, r - UiKit.FRAME * 0.5)), Color(LOCK.darkened(0.5), 0.9), UiKit.FRAME, true)
		var left := _sweep(c, r - UiKit.FRAME * 0.5, locked)
		if left.size() > 1:
			draw_polyline(left, LOCK.lightened(0.2), UiKit.FRAME + 1.0, true)
		padlock(self, c + Vector2(0, r * 0.08), r * 0.34, LOCK.lightened(0.55))
	if sealed:
		padlock(self, c + Vector2(0, r * 0.08), r * 0.34, UiKit.OLD_GOLD.lightened(0.35))
	if pulse and not busy():
		_draw_ready(c, r)
	if _release > 0.0:
		var k := 1.0 - _release
		draw_polyline(_closed(_diamond(c, r + 2.0 + RELEASE_REACH * ease(k, 0.4))), Color(UiKit.PALE, _release * 0.9), 2.0, true)
		draw_colored_polygon(_diamond(c, core), Color(LOCK.lightened(0.6), 0.35 * _release * _release))
	if waiting:
		# the recharge: a pale line running around the frame, from the top, clockwise
		var done := _sweep(c, r - UiKit.FRAME * 0.5, 1.0 - wait)
		if done.size() > 1:
			draw_polyline(done, UiKit.PALE, UiKit.FRAME, true)
	if _flash > 0.0:
		draw_polyline(_closed(_diamond(c, r + 2.0 + 4.0 * (1.0 - _flash))), Color(UiKit.PALE, _flash * 0.8), 1.5, true)
	if secs_left > 0 and waiting:
		# last, over the sweep line and the pips: one style for every slot (UI review 2026-11-26, item 16)
		_draw_secs(c)
	for i in charges_max:
		var p := c + Vector2((i - (charges_max - 1) * 0.5) * CHARGE_GAP, r * 0.46)
		draw_colored_polygon(_diamond(p, CHARGE + 1.5), UiKit.INK)
		draw_colored_polygon(_diamond(p, CHARGE), CHARGE_LIT if i < charges else CHARGE_SPENT)
	if starved:
		var bar := Rect2(c + Vector2(-STARVED_SIZE.x * 0.5, r * 0.46 - STARVED_SIZE.y * 0.5), STARVED_SIZE)
		draw_rect(bar.grow(1.0), UiKit.INK)
		draw_rect(bar, STARVED)
	for i in lights_max:
		var p := Vector2(c.x + (i - (lights_max - 1) * 0.5) * LIGHT_GAP, c.y - r - LIGHT_RISE)
		draw_colored_polygon(_diamond(p, LIGHT + 1.5), UiKit.INK)
		draw_colored_polygon(_diamond(p, LIGHT), light_color if i < lights else CHARGE_SPENT)
	if cost > 0:
		_draw_cost(c + Vector2(r * COST_AT, -r * COST_AT), r * COST_GEM, cost, starved)
	if hold_cost > 0:
		var at := c + Vector2(r * COST_AT, -r * COST_AT)
		_draw_cost(at, r * COST_GEM, hold_cost, hold_starved)
		# the hold's gem wears a ring (a touch has none)
		draw_arc(at, r * COST_GEM + 3.0, 0.0, TAU, 16, Color(COST_COLOR.lightened(0.3), 0.4 if hold_starved else 0.9), 1.5, true)
	if tap_cost > 0:
		_draw_cost(c + Vector2(-r * COST_AT, -r * COST_AT), r * COST_GEM, tap_cost, tap_starved)
	if rhythm > 0.0:
		var arc := _sweep(c, r + 2.0 + RHYTHM_GAP, rhythm)
		if arc.size() > 1:
			draw_polyline(arc, Color(UiKit.INK, 0.8), 4.0, true)
			draw_polyline(arc, RHYTHM_COLOR, 2.0, true)
	if charge > 0.0:
		var ring := _sweep(c, r - UiKit.FRAME * 0.5, charge)
		if ring.size() > 1:
			draw_polyline(ring, Color(UiKit.INK, 0.85), UiKit.FRAME + 3.0, true)
			draw_polyline(ring, READY_COLOR if charge >= 1.0 else CHARGE_RING, UiKit.FRAME + 1.0, true)
	if _refused > 0.0:
		draw_polyline(_closed(_diamond(c, r + 1.0)), Color(REFUSE_COLOR, minf(1.0, _refused / REFUSE_TIME * 1.4)), 3.0, true)
	_draw_key(Vector2(c.x, side + key_drop))
	if full_name() != "":
		_draw_name(Vector2(c.x, side + key_drop + maxf(KEY_H, MOUSE_H) * 0.5 + NAME_H - 3.0))
	if caption != "":
		_draw_caption(Vector2(c.x, c.y - r - CAPTION_RISE))


## The action's short name centred under the key, in the HUD's shadow; dimmer while it recharges.
func _draw_name(at: Vector2) -> void:
	var font := UiKit.BOLD_FONT
	var text := full_name()
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_FONT).x
	var base := Vector2(at.x - w * 0.5, at.y)
	var col := Color(UiKit.PALE, 0.62 if busy() or sealed else 0.95)
	draw_string(font, base + Vector2(0, UiKit.SHADOW_DROP), text, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_FONT, Color(UiKit.INK, 0.9))
	draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_FONT, col)


## The seconds a recharge has left, in lining figures with an ink outline, over the middle of the diamond.
func _draw_secs(c: Vector2) -> void:
	var font := UiKit.number_font()
	var text := str(secs_left)
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, SECS_FONT).x
	draw_colored_polygon(_diamond(c, side * 0.25 + 1.0), Color(UiKit.INK, 0.78))
	var base := Vector2(c.x - w * 0.5, c.y + (font.get_ascent(SECS_FONT) - font.get_descent(SECS_FONT)) * 0.5).round()
	draw_string_outline(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, SECS_FONT, 5, UiKit.INK)
	draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, SECS_FONT, UiKit.PALE)


## The Magia cost: a small gem of Magia's blue with the number in lining figures, ink round both.
func _draw_cost(at: Vector2, half: float, amount: int, dim: bool) -> void:
	draw_colored_polygon(_diamond(at, half + 1.5), UiKit.INK)
	draw_colored_polygon(_diamond(at, half), COST_COLOR.darkened(0.55) if dim else COST_COLOR.darkened(0.2))
	var font := UiKit.number_font()
	var text := str(amount)
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, COST_FONT).x
	var base := Vector2(at.x - w * 0.5, at.y + (font.get_ascent(COST_FONT) - font.get_descent(COST_FONT)) * 0.5).round()
	draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, COST_FONT, UiKit.PALE if not dim else Color(UiKit.PALE, 0.6))


## The ready ultimate: the closed ring of light around the frame (over a dark line so it holds on a lit floor),
## breathing a little, and, just after it fills, one pulse running out of it.
func _draw_ready(c: Vector2, r: float) -> void:
	var ring := _closed(_diamond(c, r + 2.0 + READY_GAP))
	var breath := 1.0 - (URGENT_BREATH if urgent else READY_BREATH) * (0.5 + 0.5 * cos(TAU * _pulse_t / PULSE_PERIOD))
	var width := URGENT_W if urgent else READY_W
	draw_polyline(ring, Color(UiKit.INK, 0.8), width + 2.0, true)
	draw_polyline(ring, Color(READY_COLOR, breath), width, true)
	if _ready_pulse > 0.0:
		var k := 1.0 - _ready_pulse
		draw_polyline(_closed(_diamond(c, r + 2.0 + READY_GAP + PULSE_REACH * ease(k, 0.4))), Color(READY_COLOR, 0.9 * _ready_pulse), 2.0, true)
		draw_colored_polygon(_diamond(c, r - UiKit.FRAME - 0.5), Color(READY_COLOR, 0.25 * _ready_pulse * _ready_pulse))


## Whether the ready ring is drawn now (the tests read it).
func ready_ring() -> bool:
	return pulse and not busy()


## The caption centred over the frame, with the HUD's dark shadow so it holds over a lit floor.
func _draw_caption(at: Vector2) -> void:
	var font := UiKit.BOLD_FONT
	var w := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FONT).x
	var base := Vector2(at.x - w * 0.5, at.y)
	draw_string(font, base + Vector2(0, UiKit.SHADOW_DROP), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FONT, Color(UiKit.INK, 0.85))
	draw_string(font, base, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FONT, caption_color)


## A small padlock (body and shackle) in ink-outlined colour, centred at c, half as tall as 2 r.
static func padlock(ci: CanvasItem, c: Vector2, r: float, ink: Color) -> void:
	var body := Rect2(c + Vector2(-r * 0.75, -r * 0.1), Vector2(r * 1.5, r * 1.1))
	ci.draw_arc(c + Vector2(0, -r * 0.1), r * 0.48, PI, TAU, 12, UiKit.INK, r * 0.34 + 2.0, true)
	ci.draw_rect(body.grow(1.5), UiKit.INK)
	ci.draw_arc(c + Vector2(0, -r * 0.1), r * 0.48, PI, TAU, 12, ink, r * 0.34, true)
	ci.draw_rect(body, ink)
	ci.draw_circle(body.get_center() + Vector2(0, -r * 0.08), r * 0.17, UiKit.INK)


## The key or button on a small dark plate over the diamond's lower point (a little mouse for the mouse buttons).
func _draw_key(at: Vector2) -> void:
	if _mouse in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		_draw_mouse(at)
		return
	# UI 10: a ready ultimate keeps its chip lit (the line in the ring's colour), whatever the caption does
	if pulse and not busy():
		key_plate(self, at, _key, KEY_FONT, KEY_H, false, READY_COLOR, READY_COLOR.darkened(0.72))
	else:
		key_plate(self, at, _key, KEY_FONT, KEY_H)


## A key's name on a small dark plate with the old gold line, centred at `at` (the HUD's diamonds, the hub's sign);
## round when it is a gamepad's face button (one letter, rounded: true). Returns the plate's width.
static func key_plate(ci: CanvasItem, at: Vector2, text: String, font_size: int, h: float, rounded: bool = false,
		line: Color = UiKit.OLD_GOLD, fill: Color = Color(0.04, 0.03, 0.05, 0.95)) -> float:
	var font := UiKit.BOLD_FONT
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var w := maxf(h, tw + 8.0)
	var plate := Rect2(at - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	ci.draw_style_box(UiKit.box(fill, line, int(UiKit.FRAME), 0, int(h * 0.5) if rounded else 3), plate)
	var base := Vector2(at.x - tw * 0.5, at.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5)
	ci.draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UiKit.PALE)
	return w


## A mouse seen from above with the bound button lit (MouseGlyph).
func _draw_mouse(at: Vector2) -> void:
	MouseGlyph.draw(self, at + Vector2(0, (MOUSE_H - KEY_H) * 0.5 - 4.0), _mouse, MOUSE_H)


## The action's mark outside the HUD (stage 1A: the cards say the action with the HUD's own symbol): a small diamond
## of ink with the old gold rim and the action's glyph, side pixels tall.
## The Brado de Guerra (Q) is the CAST slot's action now: its mark is the cry, not the circle.
static func mark(action_slot: Boon.Slot, side: float) -> Control:
	return glyph_mark(BoonIcon.SHOUT_GLYPH if action_slot == Boon.Slot.CAST else BoonIcon.ACTION_GLYPH + action_slot, side)


## The same mark for any glyph of BoonIcon (the ultimates: BoonIcon.ULT_GLYPH + UltDef.Kind, on the hero page).
static func glyph_mark(glyph_id: int, side: float) -> Control:
	var m := Control.new()
	m.name = &"ActionMark"
	m.custom_minimum_size = Vector2(side, side)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	m.set_meta(&"glyph", glyph_id)
	m.draw.connect(func() -> void:
		var c := m.size * 0.5
		var r := side * 0.5
		m.draw_colored_polygon(_diamond(c, r), UiKit.OLD_GOLD)
		m.draw_colored_polygon(_diamond(c, r - 1.5), UiKit.INK)
		BoonIcon.glyph(m, glyph_id, c, r * 0.5, IVORY, UiKit.INK))
	return m


## A rectangle with round ends (as wide as it is), as a polygon.
static func _capsule(r: Rect2) -> PackedVector2Array:
	var k := r.size.x * 0.5
	var pts := PackedVector2Array()
	for i in 9:
		var a := PI + PI * i / 8.0
		pts.append(Vector2(r.get_center().x + cos(a) * k, r.position.y + k + sin(a) * k))
	for i in 9:
		var a := PI * i / 8.0
		pts.append(Vector2(r.get_center().x + cos(a) * k, r.end.y - k + sin(a) * k))
	return pts


## The part of a diamond (half size r around c) between two heights, as shares of its height from the top (0) to
## the bottom (1): the recharge's level fills from `from` down.
static func band(c: Vector2, r: float, from: float, to: float) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	from = clampf(from, 0.0, 1.0)
	to = clampf(to, 0.0, 1.0)
	if to <= from:
		return out
	var y0 := c.y - r + 2.0 * r * from
	var y1 := c.y - r + 2.0 * r * to
	var cut := PackedVector2Array([Vector2(c.x - r, y0), Vector2(c.x + r, y0), Vector2(c.x + r, y1), Vector2(c.x - r, y1)])
	for part in Geometry2D.intersect_polygons(_diamond(c, r), cut):
		out.append(part)
	return out


static func _diamond(c: Vector2, r: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])


## The first part (0..1) of a diamond's outline, from the top, clockwise.
static func _sweep(c: Vector2, r: float, part: float) -> PackedVector2Array:
	var corners := _closed(_diamond(c, r))
	var pts := PackedVector2Array([corners[0]])
	var sides := clampf(part, 0.0, 1.0) * 4.0
	for i in 4:
		if sides <= i:
			break
		pts.append(corners[i].lerp(corners[i + 1], minf(sides - i, 1.0)))
	return pts


static func _closed(p: PackedVector2Array) -> PackedVector2Array:
	p.append(p[0])
	return p
