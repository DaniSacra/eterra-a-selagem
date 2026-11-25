class_name AskPage
extends Control
## A small question page over a screen (the menus' page, UiKit.page): a title, one line and two buttons, "no" in focus
## (the safe answer, or "yes" with focus_yes) and reached with left and right. Esc or B answers no (esc_is_no) or only
## emits cancelled. Used by the pause (skip the first descent) and the save choice (do the guided descent?). Emits
## answered(yes) once; the caller frees it.
##   var q := AskPage.new().setup("Pular?", "Uma linha.", "Pular", "Voltar")
##   parent.add_child(q); q.answered.connect(func(yes: bool) -> void: ...)

signal answered(yes: bool)
signal cancelled

const WIDTH := 560.0
const LINE_WIDTH := 500.0

## Esc and B mean "no" (the pause); false: they only cancel the question (the save choice).
var esc_is_no := true
## The focus starts on "yes" (the recommended answer).
var focus_yes := false
var yes: Button
var no: Button
var _title := ""
var _line := ""
var _yes_text := ""
var _no_text := ""
var _done := false


func setup(title: String, line: String, yes_text: String, no_text: String) -> AskPage:
	_title = title
	_line = line
	_yes_text = yes_text
	_no_text = no_text
	return self


func _ready() -> void:
	name = "ask"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var page := UiKit.page(self, _title, WIDTH, 0.7, 28)
	var line := UiKit.shadow(UiKit.label(_line, UiKit.PALE, 18))
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size.x = LINE_WIDTH
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(line)
	var foot := UiKit.foot(18)
	page.add_child(foot)
	yes = UiKit.button(_yes_text, _answer.bind(true), 230)
	yes.name = "yes"
	foot.add_child(yes)
	no = UiKit.button(_no_text, _answer.bind(false), 230)
	no.name = "no"
	foot.add_child(no)
	for b: Button in [yes, no]:
		b.focus_neighbor_top = b.get_path_to(b)
		b.focus_neighbor_bottom = b.get_path_to(b)
		b.focus_neighbor_left = b.get_path_to(yes)
		b.focus_neighbor_right = b.get_path_to(no)
	(yes if focus_yes else no).grab_focus.call_deferred()


func _answer(value: bool) -> void:
	if _done:
		return
	_done = true
	Audio.play(&"ui_ok")
	answered.emit(value)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		if esc_is_no:
			_answer(false)
		else:
			cancelled.emit()
