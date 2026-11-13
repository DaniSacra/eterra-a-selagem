class_name Hud
extends Control
## In-run interface, drawn in palette colours at the 320x180 base: life and dodge charges at the bottom left,
## experience along the top, clock, gifts, combo counter, the name of the move just landed and the boss bar.

const FONT: Font = preload("res://art/fonts/eterra.fnt")
const TITLE_TIME := 1.3

var game: Game
var _title := ""
var _title_t := 0.0
var _title_family: StringName = &"luz"
var _combo_pop := 0.0
var _notice := ""
var _notice_t := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_move(node: ComboNode, family: StringName) -> void:
	_title = T.t(node.title)
	_title_t = TITLE_TIME
	_title_family = family


func show_notice(text: String, time: float = 3.0) -> void:
	_notice = text
	_notice_t = time


func on_combo(count: int) -> void:
	if count > 0:
		_combo_pop = 0.12


func _process(delta: float) -> void:
	_title_t = maxf(0.0, _title_t - delta)
	_combo_pop = maxf(0.0, _combo_pop - delta)
	_notice_t = maxf(0.0, _notice_t - delta)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var dark := Palette.c(&"perigo", 4)
	var p := game.player
	# experience along the top
	draw_rect(Rect2(0, 0, w, 4), Palette.c(&"noite", 4))
	draw_rect(Rect2(0, 0, w * game.xp_ratio(), 3), Palette.c(&"luz", 1))
	draw_rect(Rect2(0, 0, w * game.xp_ratio(), 1), Palette.c(&"luz", 0))
	_text(T.t(&"hud_level", {"n": game.level}), Vector2(w - 4, 13), Palette.c(&"luz", 0), HORIZONTAL_ALIGNMENT_RIGHT)
	_text(SaveData.format_time(game.time), Vector2(w * 0.5, 13), Palette.c(&"neve", 0), HORIZONTAL_ALIGNMENT_CENTER)
	# life
	var bar := Rect2(6, h - 13, 64, 7)
	draw_rect(bar.grow(1), dark)
	draw_rect(bar, Palette.c(&"perigo", 3))
	var ratio := p.hp / p.max_hp
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), Palette.c(&"perigo", 1))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, 2)), Palette.c(&"perigo", 0))
	_text("%d" % ceili(p.hp), bar.position + Vector2(bar.size.x * 0.5, 7), Palette.c(&"neve", 0), HORIZONTAL_ALIGNMENT_CENTER)
	# dodge charges, as small diamonds over the life bar
	for i in p.dodge_max:
		var c := Vector2(10 + i * 9, h - 20)
		var full := i < p.dodge_charges
		_diamond(c, 4.0, dark)
		_diamond(c, 3.0, Palette.c(&"noite", 0 if full else 3))
		if not full and i == p.dodge_charges:
			draw_rect(Rect2(c.x - 1, c.y + 2 - 4.0 * p.recharge_ratio(), 2, 4.0 * p.recharge_ratio()), Palette.c(&"noite", 1))
	if p.shield_cooldown > 0.0:
		var c := Vector2(10 + p.dodge_max * 9 + 4, h - 20)
		draw_circle(c, 4.0, dark)
		draw_circle(c, 3.0, Palette.c(&"vida", 1 if p.shield_ready else 4))
	# gifts
	var x := 78.0
	for b in game.boons.owned():
		draw_rect(Rect2(x - 1, h - 17, 12, 12), dark)
		draw_rect(Rect2(x, h - 16, 10, 10), Palette.c(b.color_family(), 3))
		_icon(b.icon, Vector2(x, h - 16))
		for i in game.boons.level(b.id):
			draw_rect(Rect2(x + 1 + i * 3, h - 5, 2, 2), Palette.c(b.color_family(), 0))
		x += 14.0
	# combo counter
	if game.combat.combo > 1:
		var big := 33 if _combo_pop > 0.0 else 22
		var col := Palette.c(&"luz", 0 if game.combat.combo < 20 else 1)
		_text(str(game.combat.combo), Vector2(w - 8, 62), col, HORIZONTAL_ALIGNMENT_RIGHT, big)
		_text(T.t(&"hud_combo"), Vector2(w - 8, 72), Palette.c(&"luz", 2), HORIZONTAL_ALIGNMENT_RIGHT)
	if _title_t > 0.0:
		var rise := 4.0 * (1.0 - _title_t / TITLE_TIME)
		_text(_title, Vector2(w * 0.5, h - 36 - rise), Palette.c(_title_family, 0 if _title_t > 0.25 else 2), HORIZONTAL_ALIGNMENT_CENTER, 22)
	if _notice_t > 0.0:
		_text(_notice, Vector2(w * 0.5, 44), Palette.c(&"luz", 0), HORIZONTAL_ALIGNMENT_CENTER)
	_draw_boss(w)


func _draw_boss(w: float) -> void:
	var boss: Enemy = game.boss_enemy()
	if boss == null:
		return
	var dark := Palette.c(&"perigo", 4)
	var bw := 180.0 if boss.def.behavior == EnemyDef.Behavior.BOSS else 110.0
	var bar := Rect2((w - bw) * 0.5, 22, bw, 5)
	_text(T.t(boss.def.name_key), Vector2(w * 0.5, 21), Palette.c(&"misterio", 0), HORIZONTAL_ALIGNMENT_CENTER)
	draw_rect(bar.grow(1), dark)
	draw_rect(bar, Palette.c(&"misterio", 4))
	var ratio := clampf(boss.hp / boss.max_hp, 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(bw * ratio, 5)), Palette.c(&"misterio", 1))
	draw_rect(Rect2(bar.position, Vector2(bw * ratio, 1)), Palette.c(&"misterio", 0))
	if boss.def.behavior == EnemyDef.Behavior.BOSS:
		for mark: float in [0.6, 0.25]:
			draw_rect(Rect2(bar.position.x + bw * mark, bar.position.y - 1, 1, 7), dark)


func _icon(frame: int, at: Vector2) -> void:
	var tex := Art.tex(&"icons")
	var s := Art.size(&"icons")
	draw_texture_rect_region(tex, Rect2(at, s), Rect2(frame * s.x, 0, s.x, s.y))


func _diamond(c: Vector2, r: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), color)


## Text with a one-pixel dark drop, aligned around a point.
func _text(text: String, at: Vector2, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, font_size: int = 11) -> void:
	var tw := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var p := at
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		p.x -= tw * 0.5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT:
		p.x -= tw
	p = p.round()
	draw_string(FONT, p + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Palette.c(&"perigo", 4))
	draw_string(FONT, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
