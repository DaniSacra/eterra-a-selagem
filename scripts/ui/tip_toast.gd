class_name TipToast
extends Control
## GP-9 and 10B-2: the first descents' tips (FirstTips) as one small dark box low in the room, above the action row,
## never over the hero: a line with the keys, gone by itself after TIME seconds. It never pauses and takes no input.
## The keys read from the bindings (UiKit.action_label), so the keyboard, the mouse and the pad all say it right.
## Written in the save the moment it shows. Display only: it reads the game and never touches the run.

const TIME := 5.5
const GAP := 3.0
const FADE := 0.3
const WIDTH := 460.0
const BOTTOM := 172.0
const TEXT_PX := 17
const NEAR_ARMOR := 14.0
const VEIL := Color(0.035, 0.027, 0.04, 0.86)

var game: Game
var showing := &""
var _t := 0.0
var _fight_t := 0.0
var _quiet := 0.0
var _label: Label
var _box: PanelContainer
## --tips forces them without writing: what was shown this time is kept here.
var _scratch := {"runs": 0}


func _ready() -> void:
	name = "TipToast"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box = PanelContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_stylebox_override(&"panel", UiKit.box(VEIL, UiKit.OLD_GOLD, 1, 10, 3))
	_label = UiKit.label("", UiKit.PALE, TEXT_PX, UiKit.TEXT_FONT)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.custom_minimum_size.x = WIDTH
	_box.add_child(_label)
	_box.anchor_left = 0.5
	_box.anchor_right = 0.5
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.offset_bottom = -BOTTOM
	_box.modulate.a = 0.0
	_box.visible = false
	add_child(_box)


## The text of a tip, with the keys of the actions as they are bound now.
static func text_of(id: StringName) -> String:
	# (SW-O4: a tip of the guided descent is a whole text key, first_tip_*)
	var key := id if String(id).begins_with("first_tip_") else StringName("tip_" + String(id))
	return T.t(key, {
		"attack": UiKit.action_label(&"light_attack"), "special": UiKit.action_label(&"heavy_attack"),
		"dodge": UiKit.action_label(&"dodge")})


func _process(delta: float) -> void:
	if game == null or game.player == null:
		return
	delta = game.fx.real_dt if game.fx and game.fx.real_dt > 0.0 else delta
	if game.mode != Game.Mode.PLAY:
		_box.visible = false
		return
	var fighting := game.rooms != null and game.rooms.phase == Rooms.Phase.FIGHT and game.boss == null \
			and game.horde.count() > 0
	_fight_t = _fight_t + delta if fighting else 0.0
	_quiet = maxf(0.0, _quiet - delta)
	if showing != &"":
		_t -= delta
		_label.text = text_of(showing)
		_box.modulate.a = clampf(minf(TIME - _t, _t) / FADE, 0.0, 1.0)
		_box.visible = true
		if _t <= 0.0:
			showing = &""
			_quiet = GAP
			_box.visible = false
		return
	if _quiet > 0.0 or not FirstTips.enabled():
		return
	var id := FirstTips.pick(_data(), context(fighting))
	if id != &"":
		show_tip(id)


func _data() -> Dictionary:
	return _scratch if Dev.has("tips") else Save.data


## What the tips look at: the room's fight, an armored enemy near, the Blessings and Elos owned.
func context(fighting: bool) -> Dictionary:
	var armored := false
	if fighting:
		for e in game.horde.list:
			if e.max_armor > 0.0 and e.armor > 0.0 and e.pos.distance_to(game.player.pos) < NEAR_ARMOR:
				armored = true
				break
	return {"fighting": fighting, "fight_t": _fight_t, "armored": armored,
			"boons": game.boons.owned().size(), "elos": game.boons.new_elos({}).size(), "tutorial": Objective.tutorial()}


func show_tip(id: StringName) -> void:
	showing = id
	_t = TIME
	_label.text = text_of(id)
	_box.reset_size()
	FirstTips.mark(_data(), id)
	if not Dev.has("tips"):
		Save.write()
