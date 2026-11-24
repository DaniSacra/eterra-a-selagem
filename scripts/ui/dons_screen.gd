class_name DonsScreen
extends Control
## "Dons do Guerreiro" (docs/art/dons_medallion_spec.md, PT-12): the hero's Gifts on a medallion. The ground and the
## figure of the hero (DonsArt), the ring of nodes with their lit lines (MedallionView), the banner with the hero's name,
## the counters of Vagas and the wallet, the detail panel (DonsPanel) and the trace from the focused node to it. Opened by
## the Santuário's Árvore de Dons station (and --title --screen=dons [--hero=warrior|maga]).
## The rules are the Gifts chapter's of the Livro de Ahk, through HeroLoadout: a press puts a Gift on or takes it off, a
## sealed Gift is opened by HOLDING the press HOLD_TIME seconds (HoldGauge) with Memória, an ultimate is chosen; every
## change is written to the save at once. Direction keys and the stick walk the focus to the nearest node on that side,
## LB and RB (tab_prev, tab_next) jump a sector, Y (menu_reroll) swaps the hero, B or Esc closes (the host closes it).
## The mouse hovers for the focus and presses and holds like the confirm button.

signal closed

const STAGE := Vector2(1280, 720)
const HOLD_TIME := 1.0
const HOLD_DRAIN := 0.2
const ENTER_TIME := 0.6
const COUNT_TIME := 0.3
const BANNER := Rect2(460, 48, 320, 48)
const PANEL_AT := Vector2(962, 175)
const PANEL_SIZE_X := 302.0
const TRACE_Y := Vector2(190, 470)
const DIRS := {&"ui_left": Vector2.LEFT, &"ui_right": Vector2.RIGHT, &"ui_up": Vector2.UP, &"ui_down": Vector2.DOWN}

var loadout: HeroLoadout
var hero_id := "warrior"
var view: MedallionView
var panel: DonsPanel
var focus_id: StringName = MedallionDef.CROWN_ID
var hold := HoldGauge.new(HOLD_TIME, HOLD_DRAIN)
var in_hub := false
var _data: Dictionary
var _content: Control
var _stage: Control
var _counters: Counters
var _hold_node: StringName = &""
var _mem_shown := 0.0
var _mem_tween: Tween
var _trace: Trace


## data: the save data to read and edit (Save.data in the game; tests give their own); hero: the hero shown ("" the one
## picked at the Santuário, --hero forces it for captures).
func open(data: Dictionary = {}, hero: String = "") -> void:
	_data = data if not data.is_empty() else Save.data
	hero_id = hero if hero != "" else (Dev.arg("hero") if Dev.has("hero") else SaveData.picked_hero(_data))
	theme = UiKit.theme()
	name = "dons_screen"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_place_stage)
	Controls.device_changed.connect(func(_pad: bool) -> void: _tell(focus_id))
	_build()
	_attach_bar()


func _build() -> void:
	if is_instance_valid(_content):
		_content.queue_free()
	hold = HoldGauge.new(HOLD_TIME, HOLD_DRAIN)
	_hold_node = &""
	loadout = HeroLoadout.new(HeroDef.maga() if hero_id == "maga" else HeroDef.warrior(), _data)
	focus_id = first_focus()
	_content = Control.new()
	_content.name = "content"
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)
	_content.add_child(_ground())
	_stage = Control.new()
	_stage.name = "stage"
	_stage.custom_minimum_size = STAGE
	_stage.size = STAGE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_stage)
	_place_stage()
	_stage.add_child(Halo.new())
	_stage.add_child(_figure())
	view = MedallionView.new().setup(loadout)
	view.focus_id = focus_id
	view.focused.connect(_focus.bind(true))
	view.press_began.connect(press)
	view.press_ended.connect(release)
	_trace = Trace.new()
	_trace.screen = self
	_trace.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trace.size = STAGE
	_stage.add_child(_trace)
	_stage.add_child(view)
	_stage.add_child(Banner.new().setup(hero_id))
	_stage.add_child(_logo())
	_counters = Counters.new()
	_counters.setup(_data)
	_stage.add_child(_counters)
	_counters.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_counters.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_counters.offset_right = -16.0
	_counters.offset_top = 36.0
	panel = DonsPanel.new()
	panel.position = PANEL_AT
	panel.pressed.connect(func() -> void: press(focus_id))
	panel.released.connect(release)
	_stage.add_child(panel)
	_stage.add_child(_notes())
	_stage.add_child(_howto())
	_stage.add_child(Legend.new())
	_mem_shown = loadout.memory()
	# --dons-focus=id puts the focus on a node at once (captures)
	if Dev.has("dons-focus") and view.nav.pos.has(StringName(Dev.arg("dons-focus"))):
		focus_id = StringName(Dev.arg("dons-focus"))
		view.focus_id = focus_id
	_refresh()
	_enter()


## Where the focus starts: the first Dom that can be equipped now, else the crown (the screen never opens on a closed door).
func first_focus() -> StringName:
	var def := MedallionDef.of(hero_id)
	for n in def.nodes:
		if n.kind == MedallionNodeDef.Kind.GIFT and loadout.book.find(n.id) != null \
				and loadout.state(loadout.book.find(n.id)) == HeroLoadout.State.OPEN:
			return n.id
	return MedallionDef.CROWN_ID


func _place_stage() -> void:
	if is_instance_valid(_stage):
		_stage.position = ((size - STAGE) * 0.5).floor()


func _ground() -> Control:
	var info := DonsArt.bg(hero_id)
	var r := TextureRect.new()
	r.name = "ground"
	r.texture = info.tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.material = DonsArt.shader_material(0.004 if info.placeholder else 0.0, 0.5 if info.placeholder else 1.0, 0.55, 0.0, 0.85 if info.placeholder else 0.0)
	return r


func _figure() -> Control:
	var info := DonsArt.figure(hero_id)
	var r := TextureRect.new()
	r.name = "figure"
	r.texture = info.tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.position = (info.rect as Rect2).position
	r.size = (info.rect as Rect2).size
	if info.placeholder:
		r.material = DonsArt.shader_material(0.0, 1.0, 0.0, 0.18)
	return r


func _logo() -> Control:
	var box := VBoxContainer.new()
	box.name = "logo"
	box.position = Vector2(50, 30)
	box.add_theme_constant_override(&"separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(UiKit.label(T.t(&"title"), UiKit.GOLD, 26, UiKit.TITLE_FONT))
	var sub := UiKit.label(T.t(&"subtitle").to_upper(), UiKit.OLD_GOLD.lightened(0.3), 12, UiKit.TITLE_FONT)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	return box


## The keys at the foot, the same bar as the other screens: the sectors and the hero on the left, the way back on the right.
func _attach_bar() -> void:
	var keys: Array = [ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())]
	if SaveData.open_heroes(_data).size() > 1:
		keys.push_front(ActionBar.entry(&"menu_reroll", T.t(&"bar_swap_hero"), swap_hero, true))
	keys.push_front(ActionBar.entry(&"tab_next", T.t(&"bar_sector_next"), func() -> void: _focus(view.nav.sector_step(focus_id, 1)), true))
	keys.push_front(ActionBar.entry(&"tab_prev", T.t(&"bar_sector_prev"), func() -> void: _focus(view.nav.sector_step(focus_id, -1)), true))
	ActionBar.attach(self, keys)


## One plain sentence of what each counter is (the children's test: the two currencies were mixed up).
func _notes() -> Control:
	var box := VBoxContainer.new()
	box.name = "notes"
	box.position = Vector2(PANEL_AT.x, 78)
	box.custom_minimum_size.x = PANEL_SIZE_X
	box.add_theme_constant_override(&"separation", 4)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key: StringName in [&"dons_devotion_note", &"dons_memory_note"]:
		var l := UiKit.label(T.t(key), UiKit.STRONG, 18)
		l.custom_minimum_size.x = PANEL_SIZE_X
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_constant_override(&"outline_size", 3)
		box.add_child(l)
	return box


## The one fixed instruction, under the panel.
func _howto() -> Control:
	var l := UiKit.label(T.t(&"dons_howto", {"key": UiKit.action_label(&"ui_accept")}), UiKit.STRONG, 16)
	l.name = "howto"
	l.position = Vector2(PANEL_AT.x, 502)
	l.custom_minimum_size.x = PANEL_SIZE_X
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _enter() -> void:
	view.reveal = 0.0
	_content.modulate.a = 0.0
	if not is_inside_tree():
		view.reveal = 1.0
		_content.modulate.a = 1.0
		return
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_content, ^"modulate:a", 1.0, 0.2)
	tw.tween_property(view, ^"reveal", 1.0, ENTER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


# ---- focus and presses ----

func _focus(id: StringName, _hover: bool = false) -> void:
	if id == &"" or id == focus_id or not view.nav.pos.has(id):
		return
	hold.cancel()
	focus_id = id
	view.focus_id = id
	Audio.play(&"ui_move")
	_tell(id)


## A press on a node (the confirm button, the mouse button or the panel's button): puts a Gift on or takes it off,
## chooses an ultimate, or starts holding a sealed Gift.
func press(id: StringName) -> void:
	var n := view.def.find(id)
	if n == null:
		return
	match n.kind:
		MedallionNodeDef.Kind.ULT:
			if loadout.choose_ult(id):
				_done(id)
			else:
				view.refuse(id)
		MedallionNodeDef.Kind.GIFT:
			var t := view.nav.talent(id)
			match loadout.state(t):
				HeroLoadout.State.SEALED:
					if loadout.can_open(t) == Talents.Problem.OK:
						_hold_node = id
						hold.start()
						Audio.play(&"ui_move")
					else:
						view.refuse(id)
				HeroLoadout.State.OPEN, HeroLoadout.State.EQUIPPED:
					if loadout.toggle(id):
						_done(id)
					else:
						view.refuse(id)
				_:
					view.refuse(id)


## The press ended: letting go before the bar fills cancels the opening.
func release() -> void:
	hold.cancel()


func _done(id: StringName) -> void:
	Audio.play(&"ui_ok")
	_save()
	view.pop(id)
	_refresh()


func _process(delta: float) -> void:
	if view == null:
		return
	if hold.step(delta):
		_finish_open(_hold_node)
	var showing := hold.held or hold.progress > 0.0
	view.hold_id = _hold_node if showing else &""
	view.hold_progress = hold.progress
	panel.set_progress(hold.progress)


## The bar is full: the Gift opens with Memória (HeroLoadout.open, the Livro's rule) and the number counts down.
func _finish_open(id: StringName) -> void:
	var before := loadout.memory()
	if not loadout.open(id):
		view.refuse(id)
		return
	view.burst(id)
	_save()
	Audio.play(&"ui_ok")
	_count_memory(before, loadout.memory())
	_refresh()


func _count_memory(from: int, to: int) -> void:
	_mem_shown = from
	if _mem_tween != null:
		_mem_tween.kill()
	if not is_inside_tree():
		_mem_shown = to
		return
	_mem_tween = create_tween()
	_mem_tween.tween_method(func(v: float) -> void:
		_mem_shown = v
		_counters.update(loadout, v), float(from), float(to), COUNT_TIME)


func _save() -> void:
	if is_same(_data, Save.data):
		Save.write()


func _refresh() -> void:
	if _mem_tween == null or not _mem_tween.is_running():
		_mem_shown = loadout.memory()
	_counters.update(loadout, _mem_shown)
	_tell(focus_id)


# ---- input ----

func _unhandled_input(event: InputEvent) -> void:
	if view == null:
		return
	for action: StringName in DIRS:
		if event.is_action_pressed(action, true):
			get_viewport().set_input_as_handled()
			_focus(view.nav.neighbor(focus_id, DIRS[action]))
			return
	if event.is_action_pressed(&"tab_next", true) or event.is_action_pressed(&"tab_prev", true):
		get_viewport().set_input_as_handled()
		_focus(view.nav.sector_step(focus_id, 1 if event.is_action_pressed(&"tab_next", true) else -1))
	elif event.is_action_pressed(&"menu_reroll"):
		get_viewport().set_input_as_handled()
		swap_hero()
	elif event.is_action_pressed(&"ui_accept") and not event.is_echo():
		get_viewport().set_input_as_handled()
		press(focus_id)
	elif event.is_action_released(&"ui_accept"):
		get_viewport().set_input_as_handled()
		release()


## The other open hero's medallion (only when more than one is open in this save).
func swap_hero() -> void:
	var open := SaveData.open_heroes(_data)
	if open.size() < 2:
		return
	hero_id = open[(open.find(hero_id) + 1) % open.size()]
	_build()


# ---- the panel ----

func _tell(id: StringName) -> void:
	if panel == null:
		return
	_trace.queue_redraw()
	var n := view.def.find(id)
	if n == null:
		return
	match n.kind:
		MedallionNodeDef.Kind.CROWN:
			panel.tell_hero(_hero_info())
			view.caption = ""
		MedallionNodeDef.Kind.ULT:
			var u := _ult_info(id, n)
			panel.tell_node(u)
			view.caption = short_line(u.reason) if u.reason != "" else String(u.name)
		_:
			var g := _gift_info(id, n)
			panel.tell_node(g)
			view.caption = short_line(g.reason) if g.reason != "" else String(g.name)


## The first sentence of a text, cut at MedallionView.CAPTION_MAX characters on a word.
static func short_line(text: String) -> String:
	var first := text.split(". ")[0].trim_suffix(".")
	if first.length() <= MedallionView.CAPTION_MAX:
		return first
	var cut := first.substr(0, MedallionView.CAPTION_MAX)
	return cut.substr(0, maxi(cut.rfind(" "), 12)) + "..."


func _paint(id: StringName, n: MedallionNodeDef) -> Callable:
	var hero := loadout.hero
	var ink := view.tint_of(id)
	return func(ci: CanvasItem, c: Vector2, r: float) -> void:
		MedallionView.draw_icon(ci, hero, id, n, c, r, MedallionView.IVORY, ink)


func _hero_info() -> Dictionary:
	var next := loadout.next_unlocks()
	var h := loadout.hero
	return {"name": T.t(h.name_key), "sub": T.t(&"hero_level", {"n": loadout.level()}),
		"paint": _paint(MedallionDef.CROWN_ID, view.def.find(MedallionDef.CROWN_ID)),
		"curve": h.mastery, "xp": loadout.xp(),
		"reveals": T.t(&"dons_hero_reveals", {"n": loadout.level() + 1, "what": ", ".join(next)}) if not next.is_empty() else T.t(&"dons_hero_top"),
		"phrase": T.t(&"dons_phrase_maga" if GiftArt.is_maga(h) else &"dons_phrase_warrior")}


func _gift_info(id: StringName, n: MedallionNodeDef) -> Dictionary:
	var t := view.nav.talent(id)
	var st := loadout.state(t)
	var info := {"name": T.t(t.name_key), "desc": T.t(t.desc_key), "paint": _paint(id, n), "tint": view.tint_of(id),
		"key": UiKit.action_label(&"ui_accept"), "slot": int(t.slot) if t.slot != Boon.Slot.NONE else -1,
		"sub": _place(t), "cost_kind": "devotion", "cost_n": t.cost,
		"verb": "", "enabled": false, "reason": "", "hold": false}
	match st:
		HeroLoadout.State.LOCKED:
			info.reason = T.t(&"dons_locked", {"n": t.unlock_level})
		HeroLoadout.State.SEALED:
			info.cost_kind = "memory"
			info.cost_n = t.memory_cost
			info.cost_right = T.t(&"dons_cost_have", {"n": loadout.memory()})
			info.hold = true
			if loadout.can_open(t) == Talents.Problem.OK:
				info.verb = T.t(&"dons_do_open")
				info.enabled = true
			else:
				info.reason = T.t(&"dons_short_memory", {"n": t.memory_cost - loadout.memory()})
		HeroLoadout.State.OPEN:
			info.verb = T.t(&"dons_do_equip")
			info.enabled = true
		HeroLoadout.State.EQUIPPED:
			info.verb = T.t(&"dons_do_remove")
			info.enabled = true
		HeroLoadout.State.BLOCKED:
			info.reason = _blocked(t)
	return info


func _blocked(t: TalentDef) -> String:
	if loadout.problem(t) == Talents.Problem.DEVOTION:
		return T.t(&"dons_block_devotion", {"n": t.cost - (loadout.devotion() - loadout.used())})
	var why := loadout.short_why(t)
	return T.t(why.key, why.args) if not why.is_empty() else ""


## "Dom · Ímpeto · Meio".
func _place(t: TalentDef) -> String:
	return T.t(&"dons_sub_tier", {"branch": T.t(HeroLoadout.BRANCH_KEY[t.branch]), "tier": T.t(HeroLoadout.TIER_KEY[t.tier]).capitalize()})


func _ult_info(id: StringName, n: MedallionNodeDef) -> Dictionary:
	var u := loadout.hero.ultimate(id)
	var info := {"name": T.t(u.name_key), "desc": T.t(u.desc_key), "paint": _paint(id, n), "tint": GiftArt.ULT_INK,
		"key": UiKit.action_label(&"ui_accept"), "sub": T.t(&"dons_sub_ult", {"n": u.mastery_level}), "cost_kind": "",
		"verb": T.t(&"dons_do_choose"), "enabled": true, "reason": "", "hold": false}
	if not loadout.ult_open(u):
		info.verb = ""
		info.enabled = false
		info.reason = T.t(&"dons_locked", {"n": u.mastery_level})
	elif loadout.ultimate() == id:
		info.verb = T.t(&"dons_do_chosen")
		info.enabled = false
	return info


# ---- pieces ----

## The soft light behind the head (spec 1: centre (620, 222), radius 150, amber at 35% to nothing).
class Halo:
	extends Control

	func _init() -> void:
		name = "halo"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = DonsScreen.STAGE

	func _draw() -> void:
		var c := Vector2(620, 222)
		for k in 14:
			var f := 1.0 - k / 14.0
			draw_circle(c, 150.0 * (0.35 + 0.65 * f), Color(0.96, 0.8, 0.45, 0.35 / 14.0 * 1.6))


## The strip with the hero's name (320 x 48) and the hero's weapon over it.
class Banner:
	extends Control

	var hero := "warrior"

	func setup(p_hero: String) -> Banner:
		hero = p_hero
		name = "banner"
		position = DonsScreen.BANNER.position - Vector2(0, 30)
		custom_minimum_size = DonsScreen.BANNER.size + Vector2(0, 30)
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		return self

	func _draw() -> void:
		var r := Rect2(Vector2(0, 30), DonsScreen.BANNER.size)
		draw_style_box(UiKit.box(Color(0.04, 0.03, 0.04, 0.96), UiKit.GOLD, 2, 0, 3), r)
		draw_rect(r.grow(-5.0), Color(UiKit.OLD_GOLD, 0.5), false, 1.0)
		var title := T.t(&"dons_title_maga" if hero == "maga" else &"dons_title_warrior")
		var f := UiKit.TITLE_FONT
		var fs := 25
		while f.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > r.size.x - 28.0 and fs > 14:
			fs -= 1
		var w := f.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(f, Vector2((size.x - w) * 0.5, r.position.y + r.size.y * 0.5 + f.get_ascent(fs) * 0.36), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiKit.STRONG)
		_ornament(Vector2(size.x * 0.5, 14.0))

	## The Warrior's sword or the Maga's staff, 34 px tall, point up.
	func _ornament(c: Vector2) -> void:
		var col := UiKit.GOLD
		if hero == "maga":
			draw_line(c + Vector2(0, -6), c + Vector2(0, 17), col, 2.0, true)
			draw_arc(c + Vector2(0, -10), 5.0, 0.0, TAU, 16, col, 2.0, true)
		else:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -17), c + Vector2(3, -9), c + Vector2(3, 6), c + Vector2(-3, 6), c + Vector2(-3, -9)]), col)
			draw_line(c + Vector2(-8, 6), c + Vector2(8, 6), col, 2.5, true)
			draw_line(c + Vector2(0, 6), c + Vector2(0, 16), col, 3.0, true)


## The plates at the top right: the free Vagas of the whole, and the wallet (Prata, Memória, Esmeralda, the same corner
## as the other screens; the Memória counts down while a Dom opens).
class Counters:
	extends HBoxContainer

	var _vagas: Label
	var _wallet: HBoxContainer
	var _data: Dictionary

	func setup(data: Dictionary) -> void:
		name = "counters"
		_data = data
		add_theme_constant_override(&"separation", 12)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_vagas = _plate(null)
		_wallet = CoinCorner.wallet(data, 17, 20.0)
		_wallet.alignment = BoxContainer.ALIGNMENT_BEGIN
		_wallet.add_theme_constant_override(&"separation", 12)
		_plate(_wallet)

	func _plate(content: Control) -> Label:
		var p := PanelContainer.new()
		p.add_theme_stylebox_override(&"panel", UiKit.box(Color(0.045, 0.032, 0.04, 0.94), UiKit.OLD_GOLD, 2, 8, 16))
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(p)
		if content != null:
			p.add_child(content)
			return null
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 7)
		p.add_child(row)
		var icon := DonsPanel.CostIcon.new()
		row.add_child(icon)
		var l := UiKit.label("", UiKit.STRONG, 18, UiKit.BOLD_FONT)
		l.add_theme_constant_override(&"outline_size", 0)
		row.add_child(l)
		return l

	func update(loadout: HeroLoadout, memory_shown: float) -> void:
		_vagas.text = T.t(&"dons_devotion", {"free": loadout.devotion() - loadout.used(), "max": loadout.devotion()})
		for c in _wallet.get_children():
			var mc := c as MaterialCount
			mc.set_amount(roundi(memory_shown) if mc.id == MaterialPurse.MEMORY else MaterialCount.amount_of(_data, mc.id))

	func texts() -> Array[String]:
		var out: Array[String] = [_vagas.text]
		for c in _wallet.get_children():
			out.append((c as MaterialCount).number.text)
		return out


## The 2 px gold line from the focused node to the panel (only from the right half: from the left it would cross the
## figure).
class Trace:
	extends Control

	var screen: DonsScreen

	func _draw() -> void:
		if screen == null or screen.view == null or not screen.view.nav.pos.has(screen.focus_id):
			return
		var n := screen.view.def.find(screen.focus_id)
		var c := screen.view.spot(screen.focus_id)
		if n.kind == MedallionNodeDef.Kind.CROWN or c.x < MedallionDef.CENTER.x + 40.0:
			return
		var to := Vector2(DonsScreen.PANEL_AT.x, clampf(c.y, DonsScreen.TRACE_Y.x, DonsScreen.TRACE_Y.y))
		var from := c + (to - c).normalized() * (n.diameter * 0.5 + 8.0)
		draw_line(from, to, UiKit.GOLD, 2.0, true)


## The four looks of a node in words and drawing, under the instruction.
class Legend:
	extends Control

	const ROW := 24.0

	func _init() -> void:
		name = "legend"
		position = Vector2(DonsScreen.PANEL_AT.x, 566)
		size = Vector2(DonsScreen.PANEL_SIZE_X, ROW * 4)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var rows: Array = [[&"dons_legend_equipped", 0], [&"dons_legend_open", 1], [&"dons_legend_sealed", 2], [&"dons_legend_dark", 3]]
		var f := UiKit.TEXT_FONT
		for i in rows.size():
			var c := Vector2(12.0, ROW * i + 12.0)
			var kind: int = rows[i][1]
			var rim: Color = [UiKit.GOLD, MedallionView.LINE, MedallionView.LINE, MedallionView.IRON][kind]
			var fill: Color = [Color("9a5a2a"), Color("6a3d1c"), Color("4a4540"), MedallionView.DEEP][kind]
			draw_circle(c, 10.0, Color(UiKit.INK, 0.9))
			draw_circle(c, 9.0, rim)
			draw_circle(c, 6.5, fill)
			if kind == 2:
				ActionSlot.padlock(self, c, 4.0, MedallionView.SHELL)
			elif kind == 0:
				draw_arc(c, 12.0, 0.0, TAU, 20, Color(UiKit.GOLD, 0.35), 2.0, true)
			draw_string(f, Vector2(30.0, ROW * i + 17.0), T.t(rows[i][0]), HORIZONTAL_ALIGNMENT_LEFT, size.x - 34.0, 14, UiKit.PALE)
