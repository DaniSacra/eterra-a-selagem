class_name GiftEntry
extends BaseButton
## One Gift of the Livro de Ahk as an entry of the page (meta_screens_identity.md 1.1 and 1.2): a capital by the rung
## (a plain letter for the entry, one with filigree for the middle, an illuminated one for the apex), the name and a
## line of what it does, its cost as small candles, and the thread of the prerequisite in the margin. The five states
## of HeroLoadout are told by drawing and by words, never by colour alone:
## - LOCKED: pencilled rules, the capital only an outline, the name faded, "Maestria N";
## - SEALED: the paragraph written but held by a cord and a lacre of wax with the Memória's price pressed in it;
## - OPEN: full ink, the capital a line only;
## - EQUIPPED: the capital filled with the branch's colour (from the bottom up), a leaf of gold in the right margin;
## - BLOCKED: faded ink and a small hand of the margin pointing at the reason, in words ("Pede: X").
## Enter, A or a click is the verb (HeroScreen picks); focus (mouse, keys, pad: the mouse takes it) is a rubric line.

const HEIGHT := 66.0
const HEIGHT_COMPACT := 58.0
const THREAD_X := 8.0
const CAP_X := 20.0
const NAME_SIZE := 18
const LINE_SIZE := 15
const NOTE_SIZE := 14
const FILL_SPEED := 3.3
const CRACK_TIME := 0.38
const LEAF := Color("c99a2e")

## Cord states of a segment: none, the prerequisite is worn (gold), or it is missing (dashes).
enum Cord { NONE, MET, MISSING }

var def: TalentDef
var rung := DropCap.Rung.PLAIN
var compact := false
var state := HeroLoadout.State.OPEN
## The second line under the name: what it does, or "Maestria N" or the short reason it is refused.
var line := ""
var line_is_reason := false
## The margin note in rubric (an apex: "com um Dom de Fúria"; a bridge: the two branches it joins).
var note := ""
var note_tint := Book.RUBRIC
var thread_in := Cord.NONE
var thread_out := Cord.NONE
## The entry shares its action with the one above ("ou" between them: one Gift per action).
var or_above := false
var seal_cost := 0
var _fill := 0.0
var _crack := 0.0
var _flash := 0.0
var _mark: Control
var _letter := ""


func setup(p_def: TalentDef, hero: HeroDef) -> GiftEntry:
	def = p_def
	name = String(def.id)
	_letter = T.t(def.name_key).substr(0, 1).to_upper()
	match def.tier:
		TalentDef.Tier.MIDDLE, TalentDef.Tier.BRIDGE:
			rung = DropCap.Rung.FILIGREE
		TalentDef.Tier.APEX:
			rung = DropCap.Rung.ILLUMINATED
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	if def.slot != Boon.Slot.NONE and def.slot != Boon.Slot.ULT:
		_mark = ActionSlot.mark(def.slot, 18.0)
		_mark.size = Vector2(18, 18)
		add_child(_mark)
	set_meta(&"hero", hero.id)
	set_compact(false)
	set_process(false)
	return self


func set_compact(on: bool) -> void:
	compact = on
	custom_minimum_size.y = HEIGHT_COMPACT if on else HEIGHT


## The state and the words, written by the page after every change. `animate`: the capital fills or empties, the lacre breaks.
func set_state(s: HeroLoadout.State, p_line: String, is_reason: bool, animate: bool = true) -> void:
	var was := state
	state = s
	line = p_line
	line_is_reason = is_reason
	var target := 1.0 if s == HeroLoadout.State.EQUIPPED else 0.0
	if animate and not is_equal_approx(_fill, target):
		set_process(true)
	else:
		_fill = target
	if animate and was == HeroLoadout.State.SEALED and s != HeroLoadout.State.SEALED:
		_crack = 0.001
		set_process(true)
	queue_redraw()


## A short shake of the cord when a rule refuses it.
func refuse() -> void:
	_flash = 1.0
	set_process(true)


func fill() -> float:
	return _fill


func is_cracking() -> bool:
	return _crack > 0.0


func _process(delta: float) -> void:
	var target := 1.0 if state == HeroLoadout.State.EQUIPPED else 0.0
	_fill = move_toward(_fill, target, delta * FILL_SPEED)
	_flash = maxf(_flash - delta / 0.35, 0.0)
	if _crack > 0.0:
		_crack += delta / CRACK_TIME
		if _crack >= 1.0:
			_crack = 0.0
	queue_redraw()
	if is_equal_approx(_fill, target) and _flash <= 0.0 and _crack <= 0.0:
		_fill = target
		set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _mark != null:
		_mark.position = Vector2(size.x - 34.0, 5.0)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var locked := state == HeroLoadout.State.LOCKED
	var blocked := state == HeroLoadout.State.BLOCKED
	var sealed := state == HeroLoadout.State.SEALED
	var worn := state == HeroLoadout.State.EQUIPPED
	var shake := Vector2(sin(_flash * 40.0) * 3.0 * _flash, 0.0)
	if worn:
		draw_rect(Rect2(Vector2(r.end.x - 6.0, 4.0), Vector2(3.0, r.size.y - 8.0)), LEAF)
		draw_rect(Rect2(Vector2(r.end.x - 6.0, 4.0), Vector2(1.0, r.size.y - 8.0)), LEAF.lightened(0.4))
	if has_focus():
		draw_rect(r, Color(Book.BUTTON_LIT.r, Book.BUTTON_LIT.g, Book.BUTTON_LIT.b, 0.3))
		draw_rect(r.grow(-1.0), Book.RUBRIC, false, 1.6)
	var ink := GiftArt.gift_ink(def)
	var ink2 := GiftArt.ink2(def)
	var side: float = DropCap.RUNG_SIDE[rung]
	if compact:
		side = minf(side, HEIGHT_COMPACT - 8.0)
	var cap := Rect2(Vector2(CAP_X, (r.size.y - side) * 0.5), Vector2(side, side))
	var cy := r.size.y * 0.5
	# the thread of the prerequisite in the margin: gold when the one before it is worn, dashes when it is missing
	_thread(Vector2(THREAD_X, -3.0), Vector2(THREAD_X, cy), thread_in)
	_thread(Vector2(THREAD_X, cy), Vector2(THREAD_X, r.size.y + 3.0), thread_out)
	if thread_in != Cord.NONE or thread_out != Cord.NONE:
		draw_circle(Vector2(THREAD_X, cy), 3.0, Book.GILT if thread_in != Cord.MISSING else Book.FADED)
	DropCap.gift(self, cap, _letter, rung, ink, ink2, _fill, locked)
	if or_above:
		var f := UiKit.BOLD_FONT
		var w := f.get_string_size(T.t(&"codex_or"), HORIZONTAL_ALIGNMENT_LEFT, -1, NOTE_SIZE).x
		var at := Vector2(CAP_X + side * 0.5 - w * 0.5, 4.0)
		draw_string(f, at + Vector2(0, 7.0), T.t(&"codex_or"), HORIZONTAL_ALIGNMENT_LEFT, -1, NOTE_SIZE, Book.RUBRIC)
	# the words
	var x := CAP_X + side + 12.0
	var right_pad := 62.0 + (0.0 if not sealed else 34.0)
	var width := maxf(size.x - x - right_pad, 40.0)
	var name_col := Book.INK
	var line_col := Book.INK
	if locked:
		name_col = Color(Book.FADED, 0.5)
		line_col = Color(Book.FADED, 0.7)
	elif blocked:
		name_col = Book.FADED
		line_col = Book.WARN if line_is_reason else Book.FADED
	var lines := 3 if note != "" and not compact else 2
	var line_h := 22.0 if lines == 2 else 20.0
	var y0 := cy - (lines * line_h) * 0.5 + 16.0
	var text_at := Vector2(x, y0) + shake
	draw_string(UiKit.BOLD_FONT, text_at, _fit(T.t(def.name_key), UiKit.BOLD_FONT, NAME_SIZE, width), HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE, name_col)
	var second := text_at + Vector2(0, line_h - 1.0)
	if blocked and line_is_reason:
		_hand(second + Vector2(0, -9.0), Book.RUBRIC)
		second.x += 22.0
	if locked:
		# pencilled rules where the words will be written
		draw_line(second + Vector2(0, 4.0), second + Vector2(width * 0.9, 4.0), Color(Book.FADED, 0.22), 1.0)
	draw_string(UiKit.TEXT_FONT, second, _fit(line, UiKit.TEXT_FONT, LINE_SIZE, width - (second.x - text_at.x)), HORIZONTAL_ALIGNMENT_LEFT, -1, LINE_SIZE, line_col)
	if note != "" and not compact:
		var n_at := second + Vector2(0.0, line_h - 2.0)
		draw_rect(Rect2(Vector2(x, n_at.y - 9.0), Vector2(8.0, 3.0)), Color(note_tint, 0.3 if locked else 1.0))
		draw_string(UiKit.TEXT_FONT, n_at + Vector2(12.0, 0.0), _fit(note, UiKit.TEXT_FONT, NOTE_SIZE, width - 12.0), HORIZONTAL_ALIGNMENT_LEFT, -1, NOTE_SIZE,
			Color(Book.RUBRIC, 0.55 if locked else 0.95))
	elif note != "" and compact:
		# the compact entries put their note (a bridge's two branches) at the right of the name
		var f := UiKit.TEXT_FONT
		var nt := _fit(note, f, NOTE_SIZE, width * 0.5)
		var nw := f.get_string_size(nt, HORIZONTAL_ALIGNMENT_LEFT, -1, NOTE_SIZE).x
		draw_string(f, Vector2(x + width - nw, text_at.y), nt, HORIZONTAL_ALIGNMENT_LEFT, -1, NOTE_SIZE, Color(Book.RUBRIC, 0.55 if locked else 0.95))
	# the cost, as small candles at the right (and the lacre beside it when the entry is sealed)
	if def.cost > 0:
		var cx := size.x - 14.0 - (34.0 if sealed else 0.0)
		for i in def.cost:
			Candles.paint(self, Vector2(cx - i * 10.0 - 5.0, size.y - 6.0), 6.0, not locked and not blocked)
	if sealed:
		SealedMark.lacre(self, Vector2(CAP_X + side + 6.0, size.y - 4.0) + shake, Vector2(size.x - 40.0, size.y - 4.0) + shake,
			Vector2(size.x - 30.0, cy) + shake, 15.0, str(seal_cost))
	elif _crack > 0.0:
		SealedMark.lacre(self, Vector2(CAP_X + side + 6.0, size.y - 4.0), Vector2(size.x - 40.0, size.y - 4.0),
			Vector2(size.x - 30.0, cy), 15.0, "", _crack)


func _thread(a: Vector2, b: Vector2, kind: Cord) -> void:
	if kind == Cord.MET:
		draw_line(a, b, Book.GILT, 2.0, true)
	elif kind == Cord.MISSING:
		var n := int(a.distance_to(b) / 4.0)
		for k in range(0, n, 2):
			draw_line(a.lerp(b, float(k) / n), a.lerp(b, minf(float(k + 1) / n, 1.0)), Color(Book.FADED, 0.8), 1.4)


## A small hand of the margin pointing right (the manicule), `at` its middle.
func _hand(at: Vector2, color: Color) -> void:
	draw_rect(Rect2(at + Vector2(-9.0, -3.0), Vector2(4.0, 7.0)), color)
	draw_rect(Rect2(at + Vector2(-5.0, -3.0), Vector2(7.0, 6.0)), color)
	draw_colored_polygon(PackedVector2Array([at + Vector2(2.0, -2.0), at + Vector2(9.0, 0.5), at + Vector2(2.0, 2.0)]), color)
	draw_rect(Rect2(at + Vector2(-3.0, -5.0), Vector2(4.0, 2.0)), color)


## The text cut with an ellipsis to fit `width` (the page has no room for a second line).
static func _fit(text: String, font: Font, fs: int, width: float) -> String:
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= width:
		return text
	var cut := text
	while cut.length() > 1 and font.get_string_size(cut + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > width:
		cut = cut.substr(0, cut.length() - 1)
	return cut.strip_edges() + "…"
