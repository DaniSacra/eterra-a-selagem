class_name ActionSlot
extends Control
## One of the paladin's four actions in the HUD: a diamond with a gold frame, the gift that changed the action (or the
## bare action, dimmed), the key or button under it, and how it recharges (a dark part that empties from the top).

const DIAMOND := 54.0
const KEY_H := 17.0
const KEY_FONT := 13

var action: StringName
var slot: Boon.Slot
var boon: Boon
## 0..1: the part still recharging.
var wait := 0.0
## Charges, drawn as small gems in the lower half (the dodges); 0 for none.
var charges := 0
var charges_max := 0
var _key := ""
var _mouse := 0


func setup(action_name: StringName, action_slot: Boon.Slot) -> ActionSlot:
	action = action_name
	slot = action_slot
	custom_minimum_size = Vector2(DIAMOND + 12.0, DIAMOND + KEY_H * 0.5)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


## Called every frame by the HUD; redraws only when something changed.
func refresh(b: Boon, wait_ratio: float, n: int = 0, n_max: int = 0) -> void:
	var key := UiKit.action_label(action)
	var mouse := UiKit.action_mouse_button(action)
	wait_ratio = snappedf(clampf(wait_ratio, 0.0, 1.0), 0.01)
	if b == boon and wait_ratio == wait and n == charges and n_max == charges_max and key == _key and mouse == _mouse:
		return
	_mouse = mouse
	boon = b
	wait = wait_ratio
	charges = n
	charges_max = n_max
	_key = key
	queue_redraw()


func _draw() -> void:
	var c := Vector2(size.x * 0.5, DIAMOND * 0.5)
	var r := DIAMOND * 0.5
	var gem := boon.color() if boon else Color(0.3, 0.32, 0.36)
	draw_colored_polygon(_diamond(c, r + 1.5), Color(0.02, 0.01, 0.03, 0.9))
	draw_colored_polygon(_diamond(c, r), UiKit.EDGE if boon else UiKit.EDGE.darkened(0.25))
	draw_colored_polygon(_diamond(c, r - 2.5), gem.darkened(0.78) if boon else Color(0.05, 0.04, 0.06, 0.92))
	if boon:
		draw_colored_polygon(_diamond(c + Vector2(0, -r * 0.08), r * 0.72), gem.darkened(0.5))
		draw_colored_polygon(_diamond(c + Vector2(0, -r * 0.16), r * 0.4), Color(gem.darkened(0.1), 0.55))
	var lift := r * 0.14 if charges_max > 0 else 0.0
	var ink := Color(1.0, 0.97, 0.88) if boon else UiKit.PALE.darkened(0.25)
	BoonIcon.glyph(self, boon.icon if boon else BoonIcon.ACTION_GLYPH + slot, c - Vector2(0, lift), r * 0.42, ink, gem.darkened(0.5))
	if wait > 0.0:
		var clip := PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, DIAMOND * wait), Vector2(0, DIAMOND * wait)])
		for part in Geometry2D.intersect_polygons(_diamond(c, r - 2.5), clip):
			draw_colored_polygon(part, Color(0.0, 0.0, 0.02, 0.62))
	draw_polyline(_closed(_diamond(c, r - 5.0)), Color(UiKit.GOLD, 0.35 if boon else 0.15), 1.0, true)
	for i in charges_max:
		var p := c + Vector2((i - (charges_max - 1) * 0.5) * 11.0, r * 0.46)
		draw_colored_polygon(_diamond(p, 4.8), Color(0.02, 0.01, 0.03))
		draw_colored_polygon(_diamond(p, 3.4), Color(0.55, 0.88, 1.0) if i < charges else Color(0.32, 0.36, 0.44))
	_draw_key(Vector2(c.x, DIAMOND))


## The key or button on a small dark plate over the diamond's lower point (a little mouse for the mouse buttons).
func _draw_key(at: Vector2) -> void:
	if _mouse in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		_draw_mouse(at)
		return
	var font := UiKit.BOLD_FONT
	var w := maxf(KEY_H, font.get_string_size(_key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT).x + 8.0)
	var plate := Rect2(at - Vector2(w * 0.5, KEY_H * 0.5), Vector2(w, KEY_H))
	draw_style_box(UiKit.box(Color(0.04, 0.03, 0.05, 0.95), UiKit.EDGE, 1, 0, 3), plate)
	var base := Vector2(plate.position.x + 4.0 + (w - 8.0 - font.get_string_size(_key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT).x) * 0.5, at.y + (font.get_ascent(KEY_FONT) - font.get_descent(KEY_FONT)) * 0.5)
	draw_string(font, base, _key, HORIZONTAL_ALIGNMENT_LEFT, -1, KEY_FONT, UiKit.PALE)


## A mouse seen from above with the bound button lit.
func _draw_mouse(at: Vector2) -> void:
	var body := Rect2(at - Vector2(8.5, 11.0), Vector2(17, 22))
	draw_style_box(UiKit.box(Color(0.04, 0.03, 0.05, 0.95), UiKit.EDGE, 1, 0, 8), body)
	var top := body.position.y + 2.0
	var half := Vector2(6.0, 8.0)
	var lit := Color(1.0, 0.9, 0.6)
	match _mouse:
		MOUSE_BUTTON_LEFT:
			draw_rect(Rect2(Vector2(at.x - 6.5, top + 0.5), half), lit)
		MOUSE_BUTTON_RIGHT:
			draw_rect(Rect2(Vector2(at.x + 0.5, top + 0.5), half), lit)
		_:
			draw_rect(Rect2(Vector2(at.x - 1.5, top + 1.0), Vector2(3, 6)), lit)
	draw_line(Vector2(at.x, body.position.y + 1.0), Vector2(at.x, top + half.y), Color(UiKit.EDGE, 0.8), 1.0)
	draw_line(Vector2(body.position.x + 1.0, top + half.y), Vector2(body.end.x - 1.0, top + half.y), Color(UiKit.EDGE, 0.8), 1.0)


static func _diamond(c: Vector2, r: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])


static func _closed(p: PackedVector2Array) -> PackedVector2Array:
	p.append(p[0])
	return p
