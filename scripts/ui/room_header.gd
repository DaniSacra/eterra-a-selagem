class_name RoomHeader
extends Control
## HUD v3: the top left corner: a hollow gold diamond, "Sala 8 de 14" (and, small beside it, what lies beyond the doors), and a thin
## gold rule fading out under them; the objective line (ObjectiveLine) stands right under the rule. Pure display: the HUD sets the
## words of `room` and `ahead`.
##   var head := RoomHeader.new().setup()
##   head.room.text = "Sala 8 de 14"

const HEIGHT := 38.0
const RULE_W := 250.0
const MARK_D := 7.0
const ROOM_FONT := 22
const AHEAD_FONT := 15
const TEXT_LEFT := 24.0
const GAP := 14

var room: Label
var ahead: Label


func setup() -> RoomHeader:
	name = "RoomHeader"
	custom_minimum_size = Vector2(RULE_W + 60.0, HEIGHT)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.name = "top_left"
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.position = Vector2(TEXT_LEFT, 0.0)
	row.size = Vector2(size.x - TEXT_LEFT, HEIGHT - 4.0)
	add_child(row)
	# every number of the HUD in lining figures (UiKit.number_font): Cinzel's 1 is a bare stroke
	room = UiKit.shadow(UiKit.label("", UiKit.PALE, ROOM_FONT, UiKit.number_font()))
	room.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(room)
	ahead = UiKit.shadow(UiKit.label("", UiKit.PALE, AHEAD_FONT, UiKit.number_font()))
	ahead.name = "ahead"
	ahead.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ahead)
	return self


func _draw() -> void:
	var y := HEIGHT - 3.0
	HudArt.diamond(self, Vector2(MARK_D + 3.0, (HEIGHT - 4.0) * 0.5), MARK_D, Color(UiKit.INK, 0.8), true)
	HudArt.diamond(self, Vector2(MARK_D + 3.0, (HEIGHT - 4.0) * 0.5), MARK_D - 0.5, UiKit.GOLD, false)
	HudArt.diamond(self, Vector2(MARK_D + 3.0, (HEIGHT - 4.0) * 0.5), MARK_D * 0.35, UiKit.GOLD, true)
	var steps := 24
	for i in steps:
		var a := Vector2(RULE_W * i / steps, y)
		var b := Vector2(RULE_W * (i + 1) / steps, y)
		var k := 1.0 - float(i) / steps
		draw_line(a, b, Color(UiKit.OLD_GOLD.lightened(0.2), 0.25 + 0.75 * k), 1.5, true)
