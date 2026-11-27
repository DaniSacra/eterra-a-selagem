class_name OpeningDots
extends Control
## GP-2: the boss's Abertura under his bar. Two rows of small dots, the Frio's (ice blue) and the Impacto's (old gold),
## one dot per point of the meter that fills (CelRules.METER_COLD, METER_IMPACT); they show only while a meter has
## points (nothing permanent), and when it fills they all light up and the word "Abertura" shows while the window
## lasts (CelRules.WINDOW_TIME). Reads CelState only; display, never touches the fight.
##   dots.show_state(boss.cel, CelRules.METER_COLD, celestial.impact_need())

const HEIGHT := 10.0
const DOT := 2.6
const GAP := 7.0
const COLD := Color(0.58, 0.8, 0.95)
const IMPACT := Color(0.95, 0.8, 0.45)
const OPEN := Color(1.0, 0.92, 0.7)
const EMPTY := Color(0.05, 0.04, 0.06, 0.55)
const GROUP_GAP := 18.0

var cold := 0
var cold_need := 0
var impact := 0
var impact_need := 0
var open := 0.0
var _word: Label


func _init() -> void:
	custom_minimum_size = Vector2(0, HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_word = UiKit.shadow(UiKit.label(T.t(&"boss_opening"), OPEN, 12, UiKit.BOLD_FONT))
	_word.visible = false
	_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_word)


## The pure reading: what the state asks to draw (tests). open: seconds of the window left.
static func read(st: CelState, c_need: int, i_need: int) -> Dictionary:
	if st == null:
		return {"cold": 0, "impact": 0, "open": 0.0}
	return {"cold": clampi(st.meter_c, 0, c_need), "impact": clampi(st.meter_i, 0, i_need), "open": st.window_t}


func show_state(st: CelState, c_need: int, i_need: int) -> void:
	var r := read(st, c_need, i_need)
	if r.cold == cold and r.impact == impact and cold_need == c_need and impact_need == i_need and is_equal_approx(r.open, open):
		return
	cold = r.cold
	impact = r.impact
	cold_need = c_need
	impact_need = i_need
	open = r.open
	_word.visible = open > 0.0
	queue_redraw()


func shown() -> bool:
	return cold > 0 or impact > 0 or open > 0.0


func _draw() -> void:
	if not shown():
		return
	var w_c := (cold_need - 1) * GAP + DOT * 2.0
	var w_i := (impact_need - 1) * GAP + DOT * 2.0
	var x := (size.x - (w_c + w_i + GROUP_GAP)) * 0.5
	var y := size.y * 0.5
	_row(Vector2(x + DOT, y), cold_need, cold, COLD)
	_row(Vector2(x + w_c + GROUP_GAP + DOT, y), impact_need, impact, IMPACT)
	if _word.visible:
		_word.position = Vector2(x + w_c + w_i + GROUP_GAP + 14.0, (size.y - _word.size.y) * 0.5)


func _row(at: Vector2, count: int, lit: int, color: Color) -> void:
	for i in count:
		var p := at + Vector2(i * GAP, 0)
		draw_circle(p, DOT + 1.0, Color(UiKit.INK, 0.8))
		if open > 0.0:
			draw_circle(p, DOT, OPEN)
		elif i < lit:
			draw_circle(p, DOT, color)
		else:
			draw_circle(p, DOT, EMPTY)
