class_name VineScreen
extends Control
## A Videira (V2, redone as the plant 2026-11-23, docs/art/vine_spec.md): the account's roots as a plant that grows from a vase
## under the stone arch. Three curved branches (Vida, Provisão, Perseverança) with a bud on each root and a clay tag beside it
## (name and price); the reading panel on the right says, for the root in focus, its name, its state in words, what it
## changes with its numbers, what it costs and "você tem N", and holds the Regar button with the price written on it. No
## scrolling and no question: Regar is the confirmation. The rules stay in Vine (state, buy) and the save in Save.
## Keys, gamepad and mouse walk the same buds (VineLayout.neighbor): up grows, left and right change branch; accept on a bud
## that can grow moves the focus to Regar, accept there waters it; cancel goes back to the bud, and closes the screen from it.
## The 1280 x 720 stage scales evenly to the window and is centred.
##   var s := VineScreen.new()
##   host.open(s, [Save.data]); s.bought.connect(func(id: StringName) -> void: ...)

signal closed
signal bought(id: StringName)

const STAGE := VineLayout.STAGE
const PANEL_RECT := Rect2(960, 110, 304, 450)
const WATER_SIZE := Vector2(270, 50)
const BUD_HIT := 64.0
const OPEN_TIME := 0.6
const BLOOM_TIME := 0.6
const AMBER := Color("f0a040")
const MOSS := Color("9aa84e")
const RUBRIC_LIT := Color(0.92, 0.42, 0.34)
const WOOD_PANEL := Color("241a12")
const CLAY := Color("8a5a3a")

var _data: Dictionary
var vine: Vine
## The buds (focus carriers) and the clay tags by root id.
var buds: Dictionary = {}
var tags: Dictionary = {}
var water_button: Button
## The root whose Regar is in focus (&"": none).
var pending: StringName = &""
## The root the panel shows (the one focused).
var shown: StringName = &""
var plant: VinePlant
var _stage: Control
var _purse: HBoxContainer
var _count: Label
var _line: Label
var _panel: Control
var _name: Label
var _step: Label
var _state: Label
var _desc: RichTextLabel
var _life: RichTextLabel
var _cost: MaterialCount
var _have: Label
var _tween: Tween


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	vine = Vine.new(Vine.load_catalog())
	name = "vine_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ground := ColorRect.new()
	ground.color = UiKit.INK
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	_stage = Control.new()
	_stage.name = "stage"
	_stage.size = STAGE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	resized.connect(_place_stage)
	_place_stage()
	plant = VinePlant.new().setup(vine)
	_stage.add_child(plant)
	_stage.add_child(_vignette())
	_head()
	for n in vine.catalog:
		_stage.add_child(_tag(n))
	for n in vine.catalog:
		_stage.add_child(_bud(n))
	_build_panel()
	_foot()
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_water"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), _back)])
	_refresh()
	var first := VineLayout.first_focus(vine, _data)
	_show(first)
	(buds[first] as Button).grab_focus.call_deferred()
	_opening()


## The stage at the largest even scale that fits the window, centred (1280 x 720 up to 1920 x 1080 and over).
func _place_stage() -> void:
	if _stage == null:
		return
	var k := minf(size.x / STAGE.x, size.y / STAGE.y)
	_stage.scale = Vector2(k, k)
	_stage.position = ((size - STAGE * k) * 0.5).floor()


func _vignette() -> Control:
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0))
	grad.set_color(1, Color(0, 0, 0, 0.55))
	grad.set_offset(0, 0.55)
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	var v := TextureRect.new()
	v.name = "vignette"
	v.texture = tex
	v.stretch_mode = TextureRect.STRETCH_SCALE
	v.size = STAGE
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v


func _head() -> void:
	var title := UiKit.label(T.t(&"vine_title"), UiKit.GOLD, 30, UiKit.TITLE_FONT)
	title.position = Vector2(40, 18)
	_stage.add_child(UiKit.shadow(title))
	_line = UiKit.label(T.t(&"vine_line"), UiKit.DIM, 16)
	_line.name = "line"
	_line.position = Vector2(42, 60)
	_stage.add_child(_line)
	_purse = CoinCorner.wallet(_data)
	CoinCorner.place(_purse, 1256.0, 24.0)
	_stage.add_child(_purse)


func _tag(n: VineNode) -> VineTag:
	var t := VineTag.new().setup(n)
	t.home = VineLayout.tag(n.branch, n.step)
	t.position = t.home
	t.pressed.connect(_choose.bind(n.id))
	t.mouse_entered.connect(func() -> void: (buds[n.id] as Button).grab_focus())
	tags[n.id] = t
	return t


## A bud: a flat button, the one that holds the focus; the plant draws it and its ring.
func _bud(n: VineNode) -> Button:
	var b := Button.new()
	b.name = String(n.id)
	b.flat = true
	b.size = Vector2(BUD_HIT, BUD_HIT)
	b.position = VineLayout.bud(n.branch, n.step) - b.size * 0.5
	var empty := StyleBoxEmpty.new()
	for style: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		b.add_theme_stylebox_override(style, empty)
	b.focus_entered.connect(_show.bind(n.id))
	b.mouse_entered.connect(b.grab_focus)
	b.pressed.connect(_choose.bind(n.id))
	buds[n.id] = b
	return b


func _build_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "panel"
	panel.position = PANEL_RECT.position
	panel.size = PANEL_RECT.size
	var base := UiKit.box(Color(WOOD_PANEL, 0.94), CLAY, 2, 18, 4)
	panel.add_theme_stylebox_override(&"panel", VineArt.box("panel.png", 24, base))
	_stage.add_child(panel)
	_panel = panel
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 6)
	panel.add_child(col)
	_name = UiKit.label("", UiKit.STRONG, 24, UiKit.TITLE_FONT)
	_name.name = "name"
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_name)
	_step = UiKit.label("", UiKit.DIM, 15)
	_step.name = "step"
	col.add_child(_step)
	_state = UiKit.label("", AMBER, 17, UiKit.BOLD_FONT)
	_state.name = "state"
	col.add_child(_state)
	_desc = UiKit.rich("", UiKit.PALE, 19)
	_desc.name = "desc"
	col.add_child(_desc)
	_life = UiKit.rich("", UiKit.PALE, 17)
	_life.name = "life"
	col.add_child(_life)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(fill)
	var rule := ColorRect.new()
	rule.color = CLAY
	rule.custom_minimum_size = Vector2(0, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(rule)
	_cost = MaterialCount.new().setup(MaterialPurse.SILVER, 0, UiKit.GOLD, 32, 32.0)
	_cost.name = "cost"
	col.add_child(_cost)
	_have = UiKit.label("", UiKit.DIM, 15)
	_have.name = "have"
	col.add_child(_have)
	water_button = UiKit.button("", confirm, WATER_SIZE.x)
	water_button.name = "water"
	water_button.custom_minimum_size = WATER_SIZE
	UiKit.primary(water_button)
	water_button.focus_exited.connect(func() -> void: pending = &"")
	col.add_child(water_button)


func _foot() -> void:
	_count = UiKit.label("", UiKit.PALE, 16, UiKit.BOLD_FONT)
	_count.name = "count"
	_count.position = Vector2(PANEL_RECT.position.x, 586)
	_count.size = Vector2(PANEL_RECT.size.x, 24)
	_stage.add_child(_count)
	var hint := UiKit.label("", UiKit.DIM, 15)
	hint.name = "hint"
	hint.position = Vector2(PANEL_RECT.position.x, 612)
	hint.size = Vector2(PANEL_RECT.size.x, 40)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stage.add_child(hint)


## The plant grows from the vase to what the save holds (0,6 s); the tags come with their buds.
func _opening() -> void:
	plant.grow = 0.0
	_stage.modulate.a = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_stage, "modulate:a", 1.0, 0.2)
	_tween.tween_property(plant, "grow", 1.0, OPEN_TIME).set_ease(Tween.EASE_OUT)


func _process(_delta: float) -> void:
	if plant == null:
		return
	for id: StringName in tags:
		(tags[id] as Control).modulate.a = _tag_alpha(id)


func _tag_alpha(id: StringName) -> float:
	var dim := 0.72 if vine.state(_data, id) == Vine.State.LOCKED else 1.0
	return dim * plant.reveal(id)


## Everything from the save as it is now: the balance, the plant's states, each tag and the foot.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	var sts := {}
	for n in vine.catalog:
		var st := vine.state(_data, n.id)
		sts[n.id] = st
		(tags[n.id] as VineTag).show_state(st == Vine.State.OWNED, st == Vine.State.SHORT)
	plant.set_states(sts)
	var done := vine.bought_count(_data)
	_count.text = T.t(&"vine_count", {"n": done, "m": vine.catalog.size()})
	(_stage.get_node("hint") as Label).text = T.t(&"vine_none") if done == 0 else ""
	if shown != &"":
		_fill(shown)
	_neighbors()


## The panel for the root in focus.
func _show(id: StringName) -> void:
	if shown != id:
		Audio.play(&"ui_move")
	if shown != &"" and tags.has(shown):
		(tags[shown] as VineTag).lift(false)
	shown = id
	(tags[id] as VineTag).lift(true)
	plant.focus_id = id
	_fill(id)
	_neighbors()


func _fill(id: StringName) -> void:
	var n := vine.find(id)
	var st := vine.state(_data, id)
	_name.text = T.t(n.name_key)
	_step.text = T.t(&"vine_step", {"b": T.t(StringName("vine_branch_%s" % n.branch)), "n": n.step})
	_desc.text = BoonCard.strong_numbers(T.t(n.desc_key))
	var life := vine.life_total(id)
	_life.visible = life > 0
	_life.text = BoonCard.strong_numbers(T.t(&"vine_life_total", {"n": life})) if life > 0 else ""
	_cost.set_id(n.material)
	_cost.set_amount(n.cost)
	_cost.set_color(UiKit.GOLD if st == Vine.State.AVAILABLE else RUBRIC_LIT if st == Vine.State.SHORT else UiKit.DIM)
	_cost.visible = st != Vine.State.OWNED
	var held := vine.balance(_data, id)
	_have.visible = st != Vine.State.OWNED
	_have.text = T.t(&"vine_have", {"n": held})
	var word := _state_word(n, st)
	_state.text = word
	_state.add_theme_color_override(&"font_color", _state_color(st))
	var can := st == Vine.State.AVAILABLE
	water_button.disabled = not can
	water_button.text = ("%s  %s" % [UiKit.action_label(&"ui_accept"), T.t(&"vine_water", {"n": n.cost, "m": MaterialCount.short_of(n.material)})]) \
		if can else word


func _state_word(n: VineNode, st: Vine.State) -> String:
	match st:
		Vine.State.OWNED:
			return T.t(&"vine_owned")
		Vine.State.AVAILABLE:
			return T.t(&"vine_can")
		Vine.State.SHORT:
			return T.t(&"vine_short_n", {"n": vine.missing(_data, n.id), "m": MaterialCount.short_of(n.material)})
	return T.t(&"vine_locked", {"a": T.t(vine.find(n.requires).name_key)})


func _state_color(st: Vine.State) -> Color:
	match st:
		Vine.State.OWNED:
			return MOSS
		Vine.State.AVAILABLE:
			return AMBER
		Vine.State.SHORT:
			return RUBRIC_LIT
	return UiKit.DIM


## Focus walks by VineLayout.neighbor; from the last branch to the right is the Regar button (when it can be pressed).
func _neighbors() -> void:
	var last := vine.branches()[-1]
	for n in vine.catalog:
		var b: Button = buds[n.id]
		for pair: Array in [[SIDE_TOP, Vector2.UP], [SIDE_BOTTOM, Vector2.DOWN], [SIDE_LEFT, Vector2.LEFT], [SIDE_RIGHT, Vector2.RIGHT]]:
			var to: Control = buds[VineLayout.neighbor(vine, n.id, pair[1])]
			if to == b and pair[0] == SIDE_RIGHT and n.branch == last and not water_button.disabled:
				to = water_button
			b.set_focus_neighbor(pair[0], b.get_path_to(to))
	var sel: Control = buds[shown] if buds.has(shown) else buds.values()[0]
	for side: Side in [SIDE_TOP, SIDE_BOTTOM, SIDE_RIGHT]:
		water_button.set_focus_neighbor(side, water_button.get_path_to(water_button))
	water_button.set_focus_neighbor(SIDE_LEFT, water_button.get_path_to(sel))


## A bud or tag pressed: a root that can grow sends the focus to Regar; any other just shows why on the panel.
func _choose(id: StringName) -> void:
	(buds[id] as Button).grab_focus()
	select(id)


## Moves the focus to Regar for a root that can grow now (true); the others stay as they are.
func select(id: StringName) -> bool:
	if vine.state(_data, id) != Vine.State.AVAILABLE:
		return false
	_show(id)
	pending = id
	water_button.grab_focus.call_deferred()
	return true


## Waters the root asked about: spent once, written in the save, the plant grows. False with nothing selected.
func confirm() -> bool:
	if pending == &"":
		return false
	var id := pending
	pending = &""
	if not vine.buy(_data, id):
		_refresh()
		return false
	Audio.play(&"ui_ok")
	if is_same(_data, Save.data):
		Save.write()
	bought.emit(id)
	_water(id)
	_refresh()
	(buds[id] as Button).grab_focus.call_deferred()
	return true


## The can over the bud, the drops, then the bud opens (0,6 s).
func _water(id: StringName) -> void:
	plant.water_id = id
	plant.water_t = 0.0
	plant.bloom_id = id
	plant.bloom = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(plant, "water_t", VinePlant.WATER_TIME, VinePlant.WATER_TIME)
	_tween.tween_callback(func() -> void: plant.water_id = &"")
	_tween.tween_property(plant, "bloom", 1.0, BLOOM_TIME).set_ease(Tween.EASE_OUT)


## Back to the bud, nothing spent.
func cancel() -> void:
	if pending == &"":
		return
	var id := pending
	pending = &""
	(buds[id] as Button).grab_focus()


func _back() -> void:
	if water_button.has_focus() or pending != &"":
		cancel()
	else:
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and (water_button.has_focus() or pending != &""):
		get_viewport().set_input_as_handled()
		cancel()
		return
	if event is InputEventMouseButton and event.pressed:
		var wheel := (event as InputEventMouseButton).button_index
		if wheel == MOUSE_BUTTON_WHEEL_UP or wheel == MOUSE_BUTTON_WHEEL_DOWN:
			_go(VineLayout.neighbor(vine, shown, Vector2.UP if wheel == MOUSE_BUTTON_WHEEL_UP else Vector2.DOWN))
			return
	if event.is_action_pressed(&"tab_next") or event.is_action_pressed(&"tab_prev"):
		_go(VineLayout.neighbor(vine, shown, Vector2.RIGHT if event.is_action_pressed(&"tab_next") else Vector2.LEFT))


func _go(id: StringName) -> void:
	if buds.has(id):
		(buds[id] as Button).grab_focus()
