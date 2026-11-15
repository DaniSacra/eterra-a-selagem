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

const DIAMOND := 54.0
const KEY_H := 17.0
const KEY_FONT := 13
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

var action: StringName
var slot: Boon.Slot
var boon: Boon
## 0..1: the part still recharging.
var wait := 0.0
## Charges, drawn as small gems in the lower half (the dodges); 0 for none.
var charges := 0
var charges_max := 0
## The held version of the action costs more Magia than there is.
var starved := false
## 0..1: someone stands behind the diamond (its body turns translucent).
var veil := 0.0:
	set(v):
		if not is_equal_approx(v, veil):
			veil = v
			queue_redraw()
var _key := ""
var _mouse := 0
var _flash := 0.0


func setup(action_name: StringName, action_slot: Boon.Slot) -> ActionSlot:
	action = action_name
	slot = action_slot
	custom_minimum_size = Vector2(DIAMOND + 12.0, DIAMOND + KEY_H * 0.5)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	return self


## Called every frame by the HUD; redraws only when something changed.
func refresh(b: Boon, wait_ratio: float, n: int = 0, n_max: int = 0, no_magick: bool = false) -> void:
	var key := UiKit.action_label(action)
	var mouse := UiKit.action_mouse_button(action)
	wait_ratio = snappedf(clampf(wait_ratio, 0.0, 1.0), 0.01)
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


## The action cannot be used now: it recharges and (when it has charges) none is left.
func busy() -> bool:
	return wait > 0.0 and (charges_max == 0 or charges <= 0)


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta / READY_FLASH)
	if _flash == 0.0:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var c := Vector2(size.x * 0.5, DIAMOND * 0.5)
	var r := DIAMOND * 0.5
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
	BoonIcon.glyph(self, boon.icon if boon else BoonIcon.ACTION_GLYPH + slot, c - Vector2(0, lift), r * 0.42, ink, gem.darkened(0.5))
	if waiting:
		# the recharge: a pale line running around the frame, from the top, clockwise
		var done := _sweep(c, r - UiKit.FRAME * 0.5, 1.0 - wait)
		if done.size() > 1:
			draw_polyline(done, UiKit.PALE, UiKit.FRAME, true)
	if _flash > 0.0:
		draw_polyline(_closed(_diamond(c, r + 2.0 + 4.0 * (1.0 - _flash))), Color(UiKit.PALE, _flash * 0.8), 1.5, true)
	for i in charges_max:
		var p := c + Vector2((i - (charges_max - 1) * 0.5) * CHARGE_GAP, r * 0.46)
		draw_colored_polygon(_diamond(p, CHARGE + 1.5), UiKit.INK)
		draw_colored_polygon(_diamond(p, CHARGE), CHARGE_LIT if i < charges else CHARGE_SPENT)
	if starved:
		var bar := Rect2(c + Vector2(-STARVED_SIZE.x * 0.5, r * 0.46 - STARVED_SIZE.y * 0.5), STARVED_SIZE)
		draw_rect(bar.grow(1.0), UiKit.INK)
		draw_rect(bar, STARVED)
	_draw_key(Vector2(c.x, DIAMOND))


## The key or button on a small dark plate over the diamond's lower point (a little mouse for the mouse buttons).
func _draw_key(at: Vector2) -> void:
	if _mouse in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		_draw_mouse(at)
		return
	var font := UiKit.BOLD_FONT
	var w := maxf(KEY_H, font.get_string_size(_key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT).x + 8.0)
	var plate := Rect2(at - Vector2(w * 0.5, KEY_H * 0.5), Vector2(w, KEY_H))
	draw_style_box(UiKit.box(Color(0.04, 0.03, 0.05, 0.95), UiKit.OLD_GOLD, int(UiKit.FRAME), 0, 3), plate)
	var base := Vector2(plate.position.x + 4.0 + (w - 8.0 - font.get_string_size(_key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT).x) * 0.5, at.y + (font.get_ascent(KEY_FONT) - font.get_descent(KEY_FONT)) * 0.5)
	draw_string(font, base, _key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT, UiKit.PALE)


## A mouse seen from above with the bound button lit.
func _draw_mouse(at: Vector2) -> void:
	var body := Rect2(at - Vector2(8.5, 11.0), Vector2(17, 22))
	draw_style_box(UiKit.box(Color(0.04, 0.03, 0.05, 0.95), UiKit.OLD_GOLD, int(UiKit.FRAME), 0, 8), body)
	var inside := body.grow(-UiKit.FRAME)
	var split := inside.position.y + 8.0
	var button := Rect2(inside.position, Vector2(inside.size.x * 0.5 - 0.5, 8.0))
	match _mouse:
		MOUSE_BUTTON_RIGHT:
			button.position.x = at.x + 0.5
		MOUSE_BUTTON_MIDDLE:
			button = Rect2(at.x - 1.5, inside.position.y + 1.0, 3.0, 6.0)
	for part in Geometry2D.intersect_polygons(_capsule(inside), PackedVector2Array([button.position, Vector2(button.end.x, button.position.y), button.end, Vector2(button.position.x, button.end.y)])):
		draw_colored_polygon(part, UiKit.PALE)
	draw_line(Vector2(at.x, inside.position.y), Vector2(at.x, split), UiKit.OLD_GOLD, 1.0)
	draw_line(Vector2(inside.position.x, split), Vector2(inside.end.x, split), UiKit.OLD_GOLD, 1.0)


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
