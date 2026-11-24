class_name VineTag
extends Button
## The clay tag hung beside a root's bud (docs/art/vine_spec.md 1.1): the root's name over its price in the right material,
## the price in rubric when it is out of reach. A root that has grown turns the tag over: a blank back with a green check
## (never text). A mouse-only button: the bud beside it carries the keyboard and gamepad focus, the tag only points at it.

const FACE := Color("9a6a48")
const BURNT := Color("5a3a24")
const DARK_INK := Color("2a1a10")
const RUBRIC_LIT := Color(0.62, 0.12, 0.08)
const CHECK := Color("5f6b2e")
const NAME_SIZE := 15
const NAME_MIN := 13
const PAD := 6

var id: StringName
var owned := false
var cost: MaterialCount
var _name: Label
var home := Vector2.ZERO


func setup(n: VineNode) -> VineTag:
	id = n.id
	name = "tag_%s" % n.id
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = VineLayout.TAG_SIZE
	size = VineLayout.TAG_SIZE
	var empty := StyleBoxEmpty.new()
	for style: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		add_theme_stylebox_override(style, empty)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, PAD)
	col.add_theme_constant_override(&"separation", 0)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(col)
	var text := T.t(n.name_key)
	var px := NAME_SIZE
	var room := VineLayout.TAG_SIZE.x - PAD * 2.0 - 4.0
	while px > NAME_MIN and UiKit.BOLD_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > room:
		px -= 1
	_name = UiKit.label(text, DARK_INK, px, UiKit.BOLD_FONT)
	_name.name = "name"
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.clip_text = true
	for shadow: StringName in [&"font_shadow_color", &"font_outline_color"]:
		_name.add_theme_color_override(shadow, Color(0, 0, 0, 0))
	col.add_child(_name)
	cost = MaterialCount.new().setup(n.material, n.cost, DARK_INK, 16, 16.0)
	cost.name = "cost"
	cost.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(cost)
	return self


## `short`: the price is out of reach (rubric); `owned`: the tag shows its back.
func show_state(is_owned: bool, short: bool) -> void:
	owned = is_owned
	_name.visible = not is_owned
	cost.visible = not is_owned
	cost.set_color(RUBRIC_LIT if short else DARK_INK)
	queue_redraw()


## The tag rises a little under the focus.
func lift(on: bool) -> void:
	position = home + (Vector2(0, -4) if on else Vector2.ZERO)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var file := "tag_back.png" if owned else "tag.png"
	var tex := VineArt.texture(file)
	if tex != null:
		draw_texture_rect(tex, r, false)
	else:
		draw_rect(r, FACE if not owned else FACE.darkened(0.12))
		draw_rect(r, BURNT, false, 2.0)
		draw_circle(Vector2(size.x * 0.5, 6.0), 2.5, BURNT.darkened(0.5))
	if owned:
		var c := r.get_center()
		draw_polyline(PackedVector2Array([c + Vector2(-11, 1), c + Vector2(-3, 9), c + Vector2(12, -9)]), CHECK, 4.0, true)
