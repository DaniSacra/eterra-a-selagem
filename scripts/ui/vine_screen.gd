class_name VineScreen
extends Control
## A Videira (V2; SW-M1 2026-11-25: the plant became a constellation map): the account's roots as figures of Eterra in a night
## sky (VineLayout: Vida the lion, Provisão the chalice, Perseverança the sword), each node a star joined by lines of light.
## The map opens on the whole sky; choosing a figure (accept, click, or the wheel) closes the camera on it (SkyCamera, a smooth
## zoom), and cancel opens it out again. Closed on a figure, a clay tag hangs by each star (name and price) and the reading
## panel on the right is the node's tip (NodeTip, SW-M2): its name and text, "agora -> depois" with the real numbers, the price
## with the icon of its material and "você tem N", "Abra o anterior primeiro" when something comes before it, and the Regar
## button. No question: Regar is the confirmation. The rules stay in Vine (state, buy) and the save in Save.
## Keys, gamepad and mouse walk the same stars (VineLayout.neighbor): up grows, left and right change figure; holding the press
## (left mouse, accept key or pad) on a star that can grow fills its ring and waters it, as the Dons do. The 1280 x 720 stage scales evenly to the window.
##   var s := VineScreen.new()
##   host.open(s, [Save.data]); s.bought.connect(func(id: StringName) -> void: ...)

signal closed
signal bought(id: StringName)

const STAGE := VineLayout.STAGE
const PANEL_RECT := Rect2(960, 110, 304, 450)
const WATER_SIZE := Vector2(270, 50)
const BUD_HIT := 64.0
const OPEN_TIME := 0.6
const BLOOM_TIME := 0.7
## The star's hit square: small in the whole sky (the figures are small there), full size closed on a figure.
const HIT_FAR := 34.0
const NAME_W := 260.0
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
## The hold of each star (PT-26-5): the ring fills on the star itself.
var holds: Dictionary = {}
## The hold that confirms Regar (PT-25-3): hold accept or the mouse on the button until the ring is full.
var hold: HoldPress
var bar: ActionBar
## The root whose Regar is in focus (&"": none).
var pending: StringName = &""
## The root the panel shows (the one focused).
var shown: StringName = &""
var sky: VineSky
var cam := VineLayout.sky_camera()
## The figure the camera is closed on (&"": the whole sky).
var zoomed: StringName = &""
var ground: SkyGround
var _names: Dictionary = {}
var _stage: Control
var _purse: HBoxContainer
var _count: Label
var _line: Label
var _panel: Control
var _name: Label
var _step: Label
var _state: Label
var _desc: RichTextLabel
var _values: RichTextLabel
var _needs: Label
var _cost: MaterialCount
var _have: Label
var _tween: Tween


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	vine = Vine.new(Vine.load_catalog())
	name = "vine_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var clouds: Array[Color] = [Color("3a2a6a"), Color("1c4a5a"), Color("5a3a1c")]
	ground = SkyGround.new().setup(7, clouds)
	add_child(ground)
	_stage = Control.new()
	_stage.name = "stage"
	_stage.size = STAGE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	resized.connect(_place_stage)
	_place_stage()
	sky = VineSky.new().setup(vine, cam)
	_stage.add_child(sky)
	_stage.add_child(_vignette())
	_head()
	for b in vine.branches():
		_stage.add_child(_figure_name(b))
	for n in vine.catalog:
		_stage.add_child(_tag(n))
	for n in vine.catalog:
		_stage.add_child(_bud(n))
		(holds[n.id] as HoldPress).forward(tags[n.id])
	_build_panel()
	_foot()
	bar = ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_water"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), _back)])
	_refresh()
	var first := VineLayout.first_focus(vine, _data)
	# --vine-zoom=vida|provisao|perseveranca opens already closed on a figure (captures); the focus is that figure's first
	# star from the start (the deferred grab below took the camera to the figure of the save's first focus: sweep P0)
	var zoom_to := StringName(Dev.arg("vine-zoom")) if Dev.has("vine-zoom") else &""
	if VineLayout.CENTER.has(zoom_to):
		first = buds_of(zoom_to)[0]
	else:
		zoom_to = &""
	_show(first)
	_place()
	(buds[first] as Button).grab_focus.call_deferred()
	_opening()
	if zoom_to != &"":
		zoom_in(zoom_to)
		cam.snap()
		_place()


## The star ids of a branch in order of purchase.
func buds_of(branch: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for n in vine.nodes_of(branch):
		out.append(n.id)
	return out


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
	_line = UiKit.label(T.t(&"vine_pick"), UiKit.DIM, 16)
	_line.name = "line"
	_line.position = Vector2(42, 60)
	_stage.add_child(_line)
	_purse = CoinCorner.wallet(_data)
	CoinCorner.place(_purse, 1256.0, 24.0)
	_stage.add_child(_purse)


func _tag(n: VineNode) -> VineTag:
	var t := VineTag.new().setup(n)
	t.pressed.connect(_choose.bind(n.id))
	t.mouse_entered.connect(func() -> void: (buds[n.id] as Button).grab_focus())
	tags[n.id] = t
	return t


## A bud: a flat button, the one that holds the focus; the sky draws it and its ring.
func _bud(n: VineNode) -> Button:
	var b := Button.new()
	b.name = String(n.id)
	b.flat = true
	b.size = Vector2(BUD_HIT, BUD_HIT)
	var empty := StyleBoxEmpty.new()
	for style: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		b.add_theme_stylebox_override(style, empty)
	b.focus_entered.connect(_show.bind(n.id))
	b.mouse_entered.connect(b.grab_focus)
	b.pressed.connect(_choose.bind(n.id))
	buds[n.id] = b
	# PT-26-5: like the Dons, holding the press (left mouse, accept key or pad) on a star that can grow waters it
	var h := HoldPress.attach(b)
	h.gate = _can_hold.bind(n.id)
	h.completed.connect(_water_hold.bind(n.id))
	holds[n.id] = h
	return b


## True when a press on this star starts the hold: closed on a figure and the root can grow now.
func _can_hold(id: StringName) -> bool:
	return zoomed != &"" and vine.state(_data, id) == Vine.State.AVAILABLE


func _water_hold(id: StringName) -> void:
	pending = id
	confirm()


## The name of a figure under it in the whole sky; closed on it, at the top of the stage.
func _figure_name(branch: StringName) -> Label:
	var l := UiKit.label(T.t(VineLayout.NAME_KEY[branch]), VineLayout.tint(branch).lightened(0.3), 22, UiKit.TITLE_FONT)
	l.name = "figure_%s" % branch
	l.size = Vector2(NAME_W, 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiKit.shadow(l)
	_names[branch] = l
	return l


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
	_values = UiKit.rich("", UiKit.PALE, 18)
	_values.name = "values"
	col.add_child(_values)
	_needs = UiKit.label("", UiKit.GOLD, 16, UiKit.BOLD_FONT)
	_needs.name = "needs"
	_needs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_needs)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(fill)
	var rule := ColorRect.new()
	rule.color = CLAY
	rule.custom_minimum_size = Vector2(0, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(rule)
	var price := HBoxContainer.new()
	price.add_theme_constant_override(&"separation", 10)
	price.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(price)
	_cost = MaterialCount.new().setup(MaterialPurse.SILVER, 0, UiKit.GOLD, 32, 32.0)
	_cost.name = "cost"
	price.add_child(_cost)
	_have = UiKit.label("", UiKit.DIM, 16)
	_have.name = "have"
	_have.size_flags_vertical = Control.SIZE_SHRINK_END
	_have.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_have.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price.add_child(_have)
	water_button = UiKit.button("", Callable(), WATER_SIZE.x)
	water_button.name = "water"
	water_button.custom_minimum_size = WATER_SIZE
	UiKit.primary(water_button)
	water_button.focus_exited.connect(func() -> void: pending = &"")
	hold = HoldPress.attach(water_button)
	hold.completed.connect(confirm)
	col.add_child(water_button)


func _foot() -> void:
	_count = UiKit.label("", UiKit.PALE, 16, UiKit.BOLD_FONT)
	_count.name = "count"
	# at the foot on the left, level with the row of keys (it floated at the lower right, under the panel of an open figure)
	_count.position = Vector2(42, 720.0 - ActionBar.BOTTOM - ActionBar.HEIGHT * 0.5 - 12.0)
	_count.size = Vector2(420, 24)
	_stage.add_child(_count)
	var hint := UiKit.label("", UiKit.DIM, 15)
	hint.name = "hint"
	hint.position = Vector2(PANEL_RECT.position.x, 612)
	hint.size = Vector2(PANEL_RECT.size.x, 40)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stage.add_child(hint)


## The sky lights in (0,6 s); the figures come with their stars.
func _opening() -> void:
	sky.reveal = 0.0
	_stage.modulate.a = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_stage, "modulate:a", 1.0, 0.2)
	_tween.tween_property(sky, "reveal", 1.0, OPEN_TIME).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if sky == null:
		return
	cam.step(delta)
	_place()


## Everything that follows the camera, from where it is now: the stars' hit squares, the tags, the names, the panel, the sky.
func _place() -> void:
	var k := cam.progress()
	var hit := lerpf(HIT_FAR, BUD_HIT, k)
	for n in vine.catalog:
		var c := cam.to_screen(VineLayout.bud(n.branch, n.step))
		var b: Button = buds[n.id]
		b.size = Vector2(hit, hit)
		b.position = c - b.size * 0.5
		var t: VineTag = tags[n.id]
		t.home = VineLayout.tag_corner(n.branch, n.step, c)
		t.position = t.home + (Vector2(0, -4) if shown == n.id else Vector2.ZERO)
		t.modulate.a = _tag_alpha(n.id)
		t.visible = zoomed == n.branch
	for b in vine.branches():
		var l: Label = _names[b]
		var in_sky := cam.to_screen(VineLayout.center(b) + Vector2(0, VineLayout.NAME_BELOW))
		var read := VineLayout.NAME_READ_AT
		l.position = (in_sky.lerp(read, k) if b == zoomed else in_sky) - Vector2(NAME_W * 0.5, 15.0)
		l.modulate.a = 1.0 if b == zoomed else clampf(1.0 - k * 1.2, 0.0, 1.0)
	_panel.visible = zoomed != &""
	_panel.modulate.a = k
	ground.shift = -(cam.center - VineLayout.SKY_CENTER) * cam.zoom * 0.12


func _tag_alpha(id: StringName) -> float:
	var dim := 0.72 if vine.state(_data, id) == Vine.State.LOCKED else 1.0
	return dim * cam.progress() * sky.reveal


## Everything from the save as it is now: the balance, the figures' states, each tag and the foot.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	var sts := {}
	for n in vine.catalog:
		var st := vine.state(_data, n.id)
		sts[n.id] = st
		(tags[n.id] as VineTag).show_state(st == Vine.State.OWNED, st == Vine.State.SHORT)
	sky.set_states(sts)
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
	shown = id
	sky.focus_id = id
	# closed on a figure, the focus passing to another figure takes the camera along
	var branch := vine.find(id).branch
	if zoomed != &"" and branch != zoomed:
		zoom_in(branch)
	_fill(id)
	_neighbors()


func _fill(id: StringName) -> void:
	var n := vine.find(id)
	var tip := NodeTip.of_vine(vine, _data, id)
	var st := tip.state
	_name.text = T.t(tip.name_key)
	_step.text = T.t(&"vine_step", {"b": T.t(StringName("vine_branch_%s" % n.branch)), "n": n.step})
	_desc.text = BoonCard.strong_numbers(T.t(tip.desc_key))
	# "agora -> depois": the real numbers of the node, a share or a count (a switch has none)
	_values.visible = tip.has_values
	if tip.has_values:
		# "+0%" reads as a bonus that is zero: a node with nothing yet says "nothing" (docs/qa UI review P2-1)
		var values_key := &"vine_tip_values_none" if tip.now == 0.0 else &"vine_tip_values"
		_values.text = T.t(values_key, {"a": UiKit.strong(tip.now_text()), "b": UiKit.strong(tip.next_text())})
	_needs.visible = tip.needs != &""
	_needs.text = T.t(&"vine_needs", {"a": T.t(tip.needs)}) if tip.needs != &"" else ""
	_cost.set_id(tip.material)
	_cost.set_amount(tip.cost)
	_cost.set_color(UiKit.GOLD if st == Vine.State.AVAILABLE else RUBRIC_LIT if st == Vine.State.SHORT else UiKit.DIM)
	_cost.visible = st != Vine.State.OWNED
	_have.visible = st != Vine.State.OWNED
	_have.text = T.t(&"vine_have", {"n": tip.have})
	var word := _state_word(n, st)
	_state.text = word
	_state.visible = can_water(st)  # otherwise the button already says it (B7: "Faltam N" three times)
	_state.add_theme_color_override(&"font_color", _state_color(st))
	var can := st == Vine.State.AVAILABLE
	water_button.disabled = not can
	water_button.text = ("%s  %s" % [UiKit.action_label(&"ui_accept"), T.t(&"vine_water", {"n": n.cost, "m": MaterialCount.short_of(n.material)})]) \
		if can else word
	_verb()


## The bar's accept verb: open the figure from the whole sky, water a star that can grow, else why not.
func _verb() -> void:
	if bar == null or shown == &"":
		return
	var st := vine.state(_data, shown)
	var verb := T.t(&"vine_open_figure") if zoomed == &"" else T.t(&"bar_water") if st == Vine.State.AVAILABLE else _state_word(vine.find(shown), st)
	bar.item(&"ui_accept").set_verb(verb)


static func can_water(st: Vine.State) -> bool:
	return st == Vine.State.AVAILABLE


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


## A star or tag pressed: from the whole sky it closes the camera on its figure; closed on a figure, a root that can grow
## sends the focus to Regar and any other just shows why on the panel.
func _choose(id: StringName) -> void:
	(buds[id] as Button).grab_focus()
	if zoomed == &"":
		zoom_in(vine.find(id).branch)
		return
	select(id)


## Closes the camera on a figure (a smooth zoom).
func zoom_in(branch: StringName) -> void:
	zoomed = branch
	sky.branch_in = branch
	VineLayout.close_on(cam, branch)
	_set_line()
	_verb()
	_place()


## Opens the camera out to the whole sky.
func zoom_out() -> void:
	zoomed = &""
	sky.branch_in = &""
	cam.open_out()
	_set_line()
	_verb()
	_place()


func _set_line() -> void:
	_line.text = T.t(&"vine_line") if zoomed != &"" else T.t(&"vine_pick")


## Moves the focus to Regar for a root that can grow now (true); the others stay as they are.
func select(id: StringName) -> bool:
	if vine.state(_data, id) != Vine.State.AVAILABLE:
		return false
	_show(id)
	if zoomed == &"":
		zoom_in(vine.find(id).branch)
	pending = id
	water_button.grab_focus.call_deferred()
	return true


## Waters the root asked about: spent once, written in the save, the star lights. False with nothing selected.
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


## The star lights: a ring of light spreads from it and a glint flashes (0,7 s).
func _water(id: StringName) -> void:
	sky.bloom_id = id
	sky.bloom = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(sky, "bloom", 1.0, BLOOM_TIME).set_ease(Tween.EASE_OUT)


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
	elif zoomed != &"":
		zoom_out()
	else:
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and (water_button.has_focus() or pending != &"" or zoomed != &""):
		# (sweep P0-1: with a figure open Esc goes back to the sky; it never reaches the host, which closes the screen)
		get_viewport().set_input_as_handled()
		_back()
		return
	if event is InputEventMouseButton and event.pressed:
		var wheel := (event as InputEventMouseButton).button_index
		if wheel == MOUSE_BUTTON_WHEEL_UP or wheel == MOUSE_BUTTON_WHEEL_DOWN:
			get_viewport().set_input_as_handled()
			wheel_zoom(1 if wheel == MOUSE_BUTTON_WHEEL_UP else -1)
			return
	if event.is_action_pressed(&"tab_next") or event.is_action_pressed(&"tab_prev"):
		_go(VineLayout.neighbor(vine, shown, Vector2.RIGHT if event.is_action_pressed(&"tab_next") else Vector2.LEFT))


## The mouse wheel: closer closes on the focused star's figure (then closer still), farther goes back out to the whole sky.
func wheel_zoom(dir: int) -> void:
	if zoomed == &"":
		if dir > 0 and shown != &"":
			zoom_in(vine.find(shown).branch)
		return
	cam.wheel(dir)
	if dir < 0 and cam.target_zoom < SkyCamera.ZOOM_IN * 0.9:
		zoom_out()


func _go(id: StringName) -> void:
	if buds.has(id):
		(buds[id] as Button).grab_focus()
