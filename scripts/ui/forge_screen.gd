class_name ForgeScreen
extends Control
## The Forja da Emeth at the Forjador (docs/art/forge_spec.md; the identity in docs/art/meta_identities.md 3): not a
## book but a bench. The Emeth lies on a cloth, tip to the right, with four points on it (Despertar at the pommel,
## Refinar at the guard's two arms, Inscrever on the blade, Temperar on the edge); the point in focus offers its
## choices as a strip of iron chips, and a plate below reads the choice in three seconds: what it is, what it changes
## with its numbers, what it costs and "você tem N". The second bench, the Oficina, lays the Picareta in the Emeth's
## place. LB and RB turn the benches.
## The gesture: spending takes three hammer strikes (ForgeHammer): a press is one, the piece stays hot a moment, B cools
## it without spending, holding the press gives the three. Usar, Despertar and Adormecer cost nothing: one press.
## The rules are the game's own (Forge.buy and put_on, Oficios.restore); the words of a choice come from ForgeInfo.
##   host.open(ForgeScreen.new(), [Save.data])          # forged(rank) after each purchase and each change
##   host.open(ForgeScreen.new(), [Save.data, ForgeScreen.Tab.WORKSHOP])

signal closed
signal forged(rank: StringName)
## The Picareta restored at the Oficina.
signal restored

enum Tab { EMETH, WORKSHOP }

const STAGE := Vector2(1280, 720)
const NAV: Array[StringName] = [&"awaken", &"attack", &"inscribe", &"temper"]
const ICON := {&"awaken": &"stone", &"attack": &"ring", &"special": &"ring", &"inscribe": &"letter", &"temper": &"ingot",
	&"pick": &"pick"}
const STRIP_Y := 372.0
const CHIP_GAP := 12.0
const PLATE_AT := Vector2(140, 456)
const TAB_AT: Array[Vector2] = [Vector2(574, 40), Vector2(706, 40)]
const TAB_SIZE := Vector2(132, 34)
const TAB_KEY: Array[StringName] = [&"forge_tab_emeth", &"forge_tab_workshop"]
const PURSE_RIGHT := 1252.0
const PICK_PITCH: Array[float] = [1.0, 1.15, 0.75]

var forge: Forge
var tab := Tab.EMETH
## The point in focus (ForgeBench.AT's keys), the chip in focus on its strip, and where the focus stands.
var mark: StringName = &"temper"
var chip_i := 0
var in_strip := false
var hammer := ForgeHammer.new()
## What the strip offers (ForgeInfo each) and its chips; info is the one in focus, shown its rank (null on the Oficina).
var infos: Array[ForgeInfo] = []
var chips: Array[ForgeChip] = []
var _bar: ActionBar
var info: ForgeInfo
var shown: ForgeRank
var bench: ForgeBench
var plate: ForgePlate
var _data: Dictionary
var _oficios: OficiosDef
var _stage: Control
var _title: Label
var _sub: Label
var _how: Label
## The first-visit sheet (null once it is closed or when it is not due).
var intro: Control
var _strip: Control
var _slot_label: Label
var _purse: HBoxContainer
var _tabs: Array[ForgeTab] = []
var _tab_keys: Array[Label] = []
var _touch: Dictionary = {}
var _tab_order: Array[Tab] = [Tab.EMETH]
var _bag_shown: Dictionary = {}
var _ground: Texture2D


## A tab of the two benches: an iron plate, the one open in ember with a gold rim.
class ForgeTab extends ForgeTouch:
	var text := ""
	var on := false:
		set(v):
			on = v
			queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_style_box(UiKit.box(ForgeBench.EMBER if on else Color("2a2620"), UiKit.OLD_GOLD if on else Color(0, 0, 0, 0), 2, 0, 5), r)
		draw_string(UiKit.TITLE_FONT, Vector2(0, 23), text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, UiKit.INK if on else UiKit.DIM)


## data: the save data (Save.data in the game; tests give their own); start: the bench open first (the Oficina only once
## a vein was noted).
func open(data: Dictionary = {}, start: Tab = Tab.EMETH) -> void:
	_data = data if not data.is_empty() else Save.data
	_oficios = OficiosDef.live()
	forge = Forge.new(Forge.load_catalog())
	name = "forge_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_ground = ForgeArt.texture("bg.png")
	_stage = Control.new()
	_stage.name = "stage"
	_stage.size = STAGE
	_stage.custom_minimum_size = STAGE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	resized.connect(_place_stage)
	_place_stage()
	_build_top()
	bench = ForgeBench.new().setup()
	bench.plain_fx = OS.has_feature("web") or RenderingServer.get_current_rendering_method() == "gl_compatibility"
	_stage.add_child(bench)
	if bench.emeth != null:
		bench.emeth.show_rank(Forge.temper(_data))
	_strip = Control.new()
	_strip.name = "strip"
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_strip)
	_slot_label = UiKit.label("", UiKit.DIM, 15)
	_slot_label.name = "slot"
	_strip.add_child(_slot_label)
	plate = ForgePlate.new().setup()
	plate.position = PLATE_AT
	plate.down.connect(press)
	plate.up.connect(release)
	_stage.add_child(plate)
	_tab_order = [Tab.EMETH]
	if workshop_open():
		_tab_order.append(Tab.WORKSHOP)
	_build_tabs()
	_attach_bar()
	Controls.device_changed.connect(func(_pad: bool) -> void: _refresh())
	_show_tab(start if _tab_order.has(start) else Tab.EMETH, false)
	if Dev.has("forge-mark") and marks().has(StringName(Dev.arg("forge-mark"))):
		focus_mark(StringName(Dev.arg("forge-mark")), true)
	_enter()
	if intro_due(_data):
		_open_intro()


func _build_top() -> void:
	_title = UiKit.label(T.t(&"forge_title"), UiKit.GOLD, 30, UiKit.TITLE_FONT)
	_title.name = "title"
	_title.position = Vector2(40, 22)
	_stage.add_child(_title)
	_sub = UiKit.label(T.t(&"forge_emeth_only"), UiKit.DIM, 16)
	_sub.name = "emeth_only"
	_sub.position = Vector2(42, 62)
	_sub.visible = Dev.arg("hero") == "maga"
	_stage.add_child(_sub)
	# PT-26-6: what the bench is for, always in sight under the title (the first visit also opens the full sheet)
	_how = UiKit.label(T.t(&"forge_how_line"), UiKit.PALE, 16)
	_how.name = "how_line"
	_how.position = Vector2(42, 62)
	_how.size = Vector2(500, 44)
	_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_how.visible = not _sub.visible
	_stage.add_child(_how)
	_purse = HBoxContainer.new()
	_purse.name = "purse"
	_purse.add_theme_constant_override(&"separation", 18)
	_purse.alignment = BoxContainer.ALIGNMENT_END
	_purse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_purse.add_theme_constant_override(&"separation", 16)
	CoinCorner.place(_purse, PURSE_RIGHT, 24.0)
	_stage.add_child(_purse)


func _build_tabs() -> void:
	if _tab_order.size() < 2:
		return
	for i in _tab_order.size():
		var t := ForgeTab.new()
		t.name = "tab_" + ["emeth", "workshop"][_tab_order[i]]
		t.text = T.t(TAB_KEY[_tab_order[i]])
		t.size = TAB_SIZE
		t.position = TAB_AT[i] - TAB_SIZE * 0.5
		t.down.connect(_show_tab.bind(_tab_order[i], true))
		_stage.add_child(t)
		_tabs.append(t)
	for k in 2:
		var action: StringName = &"tab_prev" if k == 0 else &"tab_next"
		var l := UiKit.label(UiKit.action_label(action), UiKit.DIM, 18, UiKit.BOLD_FONT)
		l.name = "key_" + String(action)
		l.size = Vector2(40, 24)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(TAB_AT[0].x - TAB_SIZE.x * 0.5 - 46.0, 28.0) if k == 0 else Vector2(TAB_AT[1].x + TAB_SIZE.x * 0.5 + 6.0, 28.0)
		_stage.add_child(l)
		_tab_keys.append(l)


func _attach_bar() -> void:
	var keys := [ActionBar.entry(&"ui_accept", T.t(&"bar_hammer"), func() -> void:
			press()
			release()),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())]
	if _tab_order.size() > 1:
		keys.push_front(ActionBar.entry(&"tab_next", T.t(&"bar_next"), func() -> void: _turn(1), true))
		keys.push_front(ActionBar.entry(&"tab_prev", T.t(&"bar_prev"), func() -> void: _turn(-1), true))
	_bar = ActionBar.attach(self, keys)


func _place_stage() -> void:
	if is_instance_valid(_stage):
		_stage.position = ((size - STAGE) * 0.5).floor()
	queue_redraw()


## The opening: the ground comes in, the Emeth slides onto the cloth and the marks appear from the pommel to the tip.
func _enter() -> void:
	if not is_inside_tree():
		return
	_stage.modulate.a = 0.0
	bench.reveal = 0.0
	bench.position.x = -160.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_stage, ^"modulate:a", 1.0, 0.2)
	tw.tween_property(bench, ^"position:x", 0.0, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(bench, ^"reveal", 1.0, 0.5).set_delay(0.1)


## Whether the Oficina has its bench: a vein was noted (the Forjador's order) or the Picareta is restored.
func workshop_open() -> bool:
	return Oficios.noted(_data) or Oficios.has_tool(_data, _oficios)


## Whether the Despertar and the Inscrever show on the Emeth: the Forjador's first tool was found (each then says what it asks).
func arts_open() -> bool:
	return Forge.has_tool(_data, Forge.TOOL_REFINE) or Forge.has_tool(_data, Forge.TOOL_AWAKEN) \
		or Forge.has_tool(_data, Forge.TOOL_INSCRIBE)


## The points on the bench now, in the order the weapon lays them from the pommel to the tip.
func marks() -> Array[StringName]:
	if tab == Tab.WORKSHOP:
		return [&"pick"]
	var out: Array[StringName] = []
	for m in NAV:
		if (m == &"awaken" or m == &"inscribe") and not arts_open():
			continue
		out.append(m)
	return out


# ---- the first visit ----

## The sheet "Como a Forja funciona" comes once per save (the tips' list), never in a run without a save, the robot or a
## test; `--forge-intro` forces it for captures.
static func intro_due(data: Dictionary) -> bool:
	if Dev.has("forge-intro"):
		return true
	return Save.enabled and FirstTips.enabled() and not FirstTips.shown(data).has("forge")


func _open_intro() -> void:
	intro = Control.new()
	intro.name = "intro"
	intro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro.mouse_filter = Control.MOUSE_FILTER_STOP
	intro.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_close_intro())
	add_child(intro)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro.add_child(dim)
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro.add_child(centre)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(660, 0)
	panel.add_theme_stylebox_override(&"panel", UiKit.box(Color(0.1, 0.085, 0.07, 0.97), UiKit.OLD_GOLD, 2, 26, 6))
	centre.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 12)
	panel.add_child(col)
	var head := UiKit.label(T.t(&"forge_how_title"), UiKit.GOLD, 28, UiKit.TITLE_FONT)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(head)
	for k in [&"forge_how_1", &"forge_how_2", &"forge_how_3"]:
		var l := UiKit.label(T.t(k), UiKit.PALE, 19)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(l)
	var go := UiKit.label(T.t(&"forge_how_go", {"key": UiKit.action_label(&"ui_accept")}), UiKit.GOLD, 18)
	go.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(go)


func _close_intro() -> void:
	if intro == null:
		return
	intro.queue_free()
	intro = null
	Audio.play(&"ui_ok")
	if not Dev.has("forge-intro"):
		FirstTips.mark(_data, &"forge")
		_write()


# ---- the benches ----

func _show_tab(t: Tab, by_hand: bool = false) -> void:
	var swap := by_hand and t != tab and is_inside_tree()
	tab = t
	for i in _tabs.size():
		_tabs[i].on = _tab_order[i] == t
	_title.text = T.t(&"forge_title_workshop" if t == Tab.WORKSHOP else &"forge_title")
	if _how != null:
		_how.text = T.t(&"forge_workshop_lead" if t == Tab.WORKSHOP else &"forge_how_line")
	if by_hand:
		Audio.play(&"ui_ok")
	_cool()
	_build_touch()
	mark = _first_mark()
	in_strip = false
	chip_i = -1
	_refresh()
	if swap:
		# the other piece comes in from the side (the first goes out the other: the cloth stays)
		bench.position.x = -260.0 if _tab_order.find(t) > 0 else 260.0
		bench.modulate.a = 0.0
		var tw := create_tween().set_parallel(true)
		tw.tween_property(bench, ^"position:x", 0.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(bench, ^"modulate:a", 1.0, 0.2)


## The bench's touch places: one per mark.
func _build_touch() -> void:
	for t: Variant in _touch.values():
		(t as Node).queue_free()
	_touch.clear()
	for m in marks():
		var t := ForgeTouch.new()
		t.name = "touch_" + String(m)
		var r := ForgeBench.touch_rect(m)
		t.position = r.position
		t.size = r.size
		t.hovered.connect(focus_mark.bind(m))
		t.down.connect(func() -> void:
			focus_mark(m)
			press())
		t.up.connect(release)
		bench.add_child(t)
		_touch[m] = t


## The bench before (-1) or after (1), as LB and RB.
func _turn(step: int) -> void:
	if _tab_order.size() < 2:
		return
	var i := clampi(_tab_order.find(tab) + step, 0, _tab_order.size() - 1)
	if _tab_order[i] != tab:
		_show_tab(_tab_order[i], true)


## Where the focus starts: the point with the cheapest thing to forge now, else the Temperar.
func _first_mark() -> StringName:
	if tab == Tab.WORKSHOP:
		return &"pick"
	var best: StringName = &"temper"
	var cost := 1 << 30
	for m in marks():
		for i in _infos_of(m):
			if i.look == ForgeInfo.Look.READY and i.cost < cost:
				cost = i.cost
				best = m
	return best


# ---- what a point offers ----

func _ranks_of(m: StringName) -> Array[ForgeRank]:
	match m:
		&"awaken":
			return forge.track(Forge.AWAKEN)
		&"attack", &"special":
			return forge.refine_options(m)
		&"inscribe":
			return forge.track(Forge.INSCRIBE)
	return forge.track(Forge.TEMPER)


func _infos_of(m: StringName) -> Array[ForgeInfo]:
	var out: Array[ForgeInfo] = []
	if m == &"pick":
		out.append(ForgeInfo.pick(_data, _oficios))
		return out
	for r in _ranks_of(m):
		out.append(ForgeInfo.of(forge, _data, r))
	return out


## The chip a point rests on when the focus arrives: the first to forge now, then a lack or a wait, then the one on.
static func default_chip(list: Array[ForgeInfo]) -> int:
	for look: ForgeInfo.Look in [ForgeInfo.Look.READY, ForgeInfo.Look.SHORT, ForgeInfo.Look.NEEDS, ForgeInfo.Look.NO_TOOL,
			ForgeInfo.Look.ON, ForgeInfo.Look.STORED]:
		for i in list.size():
			if list[i].look == look:
				return i
	return 0


# ---- the focus ----

## The focus goes to a point (the strip leaves the weapon's zone and shows the point's choices).
func focus_mark(m: StringName, silent: bool = false) -> void:
	if m == mark and not in_strip and chip_i >= 0:
		return
	_cool()
	mark = m
	in_strip = false
	chip_i = -1
	if not silent:
		Audio.play(&"ui_move")
	_refresh()


func focus_chip(i: int) -> void:
	if i < 0 or i >= infos.size() or (i == chip_i and in_strip):
		return
	_cool()
	chip_i = i
	in_strip = true
	Audio.play(&"ui_move")
	_refresh()


## The direction pad, the arrows and the stick: along the weapon from the pommel to the tip, down into the strip and
## along its chips, up back to the weapon; on the guard, up and down choose the arm of the Ataque or the Especial.
func move(dir: Vector2i) -> void:
	var list := marks()
	if in_strip:
		if dir.x != 0:
			focus_chip(clampi(chip_i + dir.x, 0, infos.size() - 1))
		elif dir.y < 0:
			_cool()
			in_strip = false
			Audio.play(&"ui_move")
			_refresh()
		return
	if dir.x != 0:
		var at := list.find(&"attack" if mark == &"special" else mark)
		var to := clampi(at + dir.x, 0, list.size() - 1)
		if to != at:
			focus_mark(list[to])
	elif dir.y > 0:
		if mark == &"attack":
			focus_mark(&"special")
		else:
			focus_chip(maxi(chip_i, 0))
	elif dir.y < 0 and mark == &"special":
		focus_mark(&"attack")


# ---- the hammer ----

## A press (the key, the pad's A, the left button): a strike when the choice spends, the change itself when it is free.
func press() -> void:
	if info == null:
		return
	match info.action:
		ForgeInfo.Action.NONE:
			Audio.play(&"ui_move")
		ForgeInfo.Action.HAMMER:
			_landed(hammer.press())
		_:
			_free_change()


func release() -> void:
	hammer.release()


## The strike number n landed (the hold gives two and three by itself).
func _landed(n: int) -> void:
	bench.hit(mark, n)
	Audio.play(&"mat_armor", PICK_PITCH[clampi(n - 1, 0, 2)])
	bench.heat_at = mark
	bench.heat_target = 0.0 if n >= ForgeHammer.STRIKES else 0.25 * n
	if n >= ForgeHammer.STRIKES:
		_spend()
	plate.queue_redraw()


## Cools the piece without spending (B, or the focus going elsewhere).
func _cool() -> void:
	if hammer != null:
		hammer.cancel()
	if bench != null:
		bench.heat_target = 0.0
	if plate != null:
		plate.queue_redraw()


## The third strike: spends (Forge.buy or Oficios.restore), writes the save and says so.
func _spend() -> bool:
	var i := info
	if i == null or i.action != ForgeInfo.Action.HAMMER:
		return false
	var ok := false
	if i.id == &"pick":
		ok = Oficios.restore(_data, _oficios)
	else:
		ok = forge.buy(_data, i.id)
	if not ok:
		return false
	_write()
	Audio.play(&"ui_ok")
	if i.id == &"pick":
		restored.emit()
	else:
		forged.emit(i.id)
	if i.rank != null and i.rank.track == Forge.TEMPER:
		if bench.emeth != null:
			bench.emeth.show_rank(Forge.temper(_data), true)
	_after_spend(i)
	return true


## After a spend the screen reads the save again; on the Temperar the focus goes on to the next rank.
func _after_spend(i: ForgeInfo) -> void:
	if i.rank != null and i.rank.track == Forge.TEMPER:
		chip_i = -1
	_refresh()


## Usar, Despertar, Adormecer: free, one press.
func _free_change() -> void:
	var r := info.rank
	if r == null:
		return
	match info.action:
		ForgeInfo.Action.USE:
			if not forge.put_on(_data, r.id):
				return
		ForgeInfo.Action.AWAKEN:
			if not forge.put_on(_data, r.id):
				return
		ForgeInfo.Action.SLEEP:
			forge.take_off(_data, Forge.AWAKEN)
	_write()
	Audio.play(&"ui_ok")
	forged.emit(r.id)
	_refresh()


func _write() -> void:
	if is_same(_data, Save.data):
		Save.write()


## Restores the Picareta without the gesture (the Oficina's own rule, kept for callers and tests).
func restore() -> bool:
	if not Oficios.restore(_data, _oficios):
		return false
	_write()
	Audio.play(&"ui_ok")
	restored.emit()
	_refresh()
	return true


# ---- showing ----

## Everything on the bench and the plate from the save as it is now.
func _refresh() -> void:
	infos = _infos_of(mark)
	if chip_i < 0:
		chip_i = default_chip(infos)
	chip_i = clampi(chip_i, 0, maxi(infos.size() - 1, 0))
	info = infos[chip_i] if not infos.is_empty() else null
	shown = info.rank if info != null else null
	_bench_state()
	_strip_state()
	if info != null:
		plate.show_info(info, hammer, ICON.get(mark, &"ingot"))
	_purse_state()
	if _bar != null and info != null and info.verb() != "":
		_bar.item(&"ui_accept").set_verb(info.verb())


func _bench_state() -> void:
	bench.workshop = tab == Tab.WORKSHOP
	if bench.emeth != null:
		bench.emeth.visible = not bench.workshop
	if bench.emeth_tex != null:
		bench.emeth_tex.visible = not bench.workshop
	bench.marks = marks()
	bench.focus = mark
	bench.temper = Forge.temper(_data)
	for slot: StringName in [&"attack", &"special"]:
		var on := _on_of(slot)
		bench.rings[slot] = String(ForgeBench.LETTER.get(on.id, "?")) if on != null else ""
	var awake := forge.awake(_data)
	bench.gem = awake.id if awake != null else &""
	bench.lines = forge.track(Forge.INSCRIBE).filter(func(r: ForgeRank) -> bool: return forge.state(_data, r) == Forge.State.OWNED).size()
	bench.pick_look = _pick_look()
	bench.sealed = {&"attack": not Forge.has_tool(_data, Forge.TOOL_REFINE), &"special": not Forge.has_tool(_data, Forge.TOOL_REFINE),
		&"awaken": not Forge.has_tool(_data, Forge.TOOL_AWAKEN), &"inscribe": not Forge.has_tool(_data, Forge.TOOL_INSCRIBE)}
	bench.causes = _causes()
	bench.doing.clear()
	for m in marks():
		for i in (_infos_of(m) if m != mark else infos):
			if i.look == ForgeInfo.Look.READY:
				bench.doing[m] = true
	bench.queue_redraw()


## Why each point is closed now, one short line: the missing tool, or the cheapest thing it lacks (UI 9). The two arms
## of the guard share one name, so only one of them speaks when both are closed alike.
func _causes() -> Dictionary:
	var out := {}
	if tab == Tab.WORKSHOP:
		return out
	for m in marks():
		if bench.sealed.get(m, false):
			out[m] = T.t(&"forge_state_no_tool")
			continue
		var lack := 0
		var what := ""
		var open := false
		for i in (_infos_of(m) if m != mark else infos):
			if i.look in [ForgeInfo.Look.READY, ForgeInfo.Look.ON, ForgeInfo.Look.STORED]:
				open = true
			elif i.look == ForgeInfo.Look.SHORT and (lack == 0 or i.cost - i.have < lack):
				lack = i.cost - i.have
				what = MaterialCount.short_of(i.material)
		if not open and lack > 0:
			out[m] = T.t(&"forge_lack", {"n": lack, "name": what})
	return out


func _pick_look() -> PickMark.Look:
	var problem := Oficios.restore_problem(_data, _oficios)
	if problem == Oficios.DONE:
		return PickMark.Look.WHOLE
	return PickMark.Look.HEAD if Oficios.has_find(_data, _oficios.head) else PickMark.Look.LOST


func _on_of(slot: StringName) -> ForgeRank:
	for r in forge.refine_options(slot):
		if forge.is_on(_data, r):
			return r
	return null


func _strip_state() -> void:
	while chips.size() > infos.size():
		chips.pop_back().queue_free()
	while chips.size() < infos.size():
		var chip := ForgeChip.new()
		var i := chips.size()
		chip.name = "chip_%d" % i
		chip.hovered.connect(func() -> void: focus_chip(i))
		chip.down.connect(func() -> void:
			focus_chip(i)
			press())
		chip.up.connect(release)
		_strip.add_child(chip)
		chips.append(chip)
	var n := infos.size()
	var w := n * ForgeChip.SIZE.x + maxf(n - 1, 0.0) * CHIP_GAP
	var x0 := (STAGE.x - w) * 0.5
	for i in n:
		chips[i].setup(infos[i])
		chips[i].position = Vector2(x0 + i * (ForgeChip.SIZE.x + CHIP_GAP), STRIP_Y)
		chips[i].focused = in_strip and i == chip_i
		chips[i].current = not in_strip and i == chip_i
		chips[i].queue_redraw()
	var slot := mark == &"attack" or mark == &"special"
	_slot_label.visible = slot
	if slot:
		_slot_label.text = T.t(StringName("forge_refine_slot_" + String(mark)))
		_slot_label.position = Vector2(x0 - 100.0, STRIP_Y + 20.0)
		_slot_label.size = Vector2(88, 24)
		_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


## The bag: only the materials this bench uses (Prata and Esmeralda on the Emeth; Prata and Pedra Funda on the Oficina);
## a number that changed counts to the new one in 0.3 s.
func _purse_state() -> void:
	var want: Array[StringName] = CoinCorner.WALLET_ORDER.duplicate()
	if tab == Tab.WORKSHOP and MaterialCount.shown(_data).has(DoorGlyph.STONE_ID):
		want.append(DoorGlyph.STONE_ID)
	var key := "%s%s" % [tab, want]
	if _bag_shown.get("key", "") != key:
		for c in _purse.get_children():
			c.queue_free()
		for m in want:
			_purse.add_child(MaterialCount.new().setup(m, MaterialCount.amount_of(_data, m), UiKit.PALE, 18, 22.0, true))
		_bag_shown = {"key": key}
		return
	for c in _purse.get_children():
		var mc := c as MaterialCount
		var now := MaterialCount.amount_of(_data, mc.id)
		if mc != null and mc.amount != now:
			if is_inside_tree():
				var tw := create_tween()
				tw.tween_method(mc.set_amount, mc.amount, now, 0.3)
			else:
				mc.set_amount(now)


# ---- input and frame ----

func _process(delta: float) -> void:
	if hammer == null or info == null:
		return
	var n := hammer.step(delta)
	if hammer.cooled:
		bench.heat_target = 0.0
		plate.queue_redraw()
	if n > 0:
		_landed(n)
	elif hammer.gauge.progress > 0.0 or hammer.strikes > 0:
		plate.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if intro != null:
		if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			_close_intro()
		return
	if info == null:
		return
	for action: StringName in [&"ui_left", &"ui_right", &"ui_up", &"ui_down"]:
		if event.is_action_pressed(action, true):
			get_viewport().set_input_as_handled()
			move(_dir_of(action))
			return
	if (event.is_action_pressed(&"tab_next") or event.is_action_pressed(&"tab_prev")) and not event.is_echo():
		get_viewport().set_input_as_handled()
		_turn(1 if event.is_action_pressed(&"tab_next") else -1)
	elif event.is_action_pressed(&"ui_accept") and not event.is_echo():
		get_viewport().set_input_as_handled()
		press()
	elif event.is_action_released(&"ui_accept"):
		get_viewport().set_input_as_handled()
		release()
	elif event.is_action_pressed(&"ui_cancel") and (hammer.strikes > 0 or hammer.gauge.progress > 0.0):
		# a hot piece first: B cools it without spending; cold, B closes the screen (ScreenHost)
		get_viewport().set_input_as_handled()
		_cool()
		Audio.play(&"ui_move")


static func _dir_of(action: StringName) -> Vector2i:
	match action:
		&"ui_left":
			return Vector2i(-1, 0)
		&"ui_right":
			return Vector2i(1, 0)
		&"ui_up":
			return Vector2i(0, -1)
	return Vector2i(0, 1)


## The ground of the workshop: the painted one when it is there, else soot with the glow of the embers and a vignette.
func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if _ground != null:
		draw_texture_rect(_ground, r, false)
		return
	draw_rect(r, UiKit.INK)
	var base := size.y
	var top := maxf(0.0, size.y * 0.5 - 70.0)
	draw_polygon(PackedVector2Array([Vector2(0, top), Vector2(size.x, top), Vector2(size.x, base), Vector2(0, base)]),
		PackedColorArray([Color(ForgeBench.EMBER, 0.0), Color(ForgeBench.EMBER, 0.0), Color(ForgeBench.EMBER, 0.3), Color(ForgeBench.EMBER, 0.3)]))
	var d := 220.0
	var dark := Color(0, 0, 0, 0.6)
	var clear := Color(0, 0, 0, 0.0)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(d, 0), Vector2(d, size.y), Vector2(0, size.y)]), PackedColorArray([dark, clear, clear, dark]))
	draw_polygon(PackedVector2Array([Vector2(size.x - d, 0), Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(size.x - d, size.y)]), PackedColorArray([clear, dark, dark, clear]))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, 120), Vector2(0, 120)]), PackedColorArray([dark, dark, clear, clear]))


## The demo save of the capture (--screen=forge): a Prata purse, the three tools found, a Temperar forged, the Fio on.
static func demo_data() -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, 47)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 3)
	for t in Forge.TOOLS:
		Forge.add_tool(d, t)
	Forge.block(d).temper = 1
	var f := Forge.new(Forge.load_catalog())
	MaterialPurse.give(d, MaterialPurse.SILVER, 40)
	f.buy(d, &"refine_fio")
	return d
