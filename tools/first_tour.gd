extends SceneTree
## A first run to watch (outside the game's code): the hub as a new player sees it, a walk past each station, the Portal,
## a whole descent played by the robot with a human-like reaction until it dies or wins, back to the hub, a last walk.
##   tools/gpu.sh run -s res://tools/first_tour.gd -- --hub --nosave [--tour-reaction=0.45] [--seed=N]
## Scripts by path: a -s tool compiles before the autoloads exist.

const HUB := "res://scripts/game/hub.gd"
const GAME := "res://scripts/game/game.gd"
const PLAN := "res://scripts/core/hub_plan.gd"
const GO := "res://scripts/game/scene_go.gd"
const DEV := "res://scripts/dev.gd"
## The hub walk before the descent, and after it.
const FIRST_WALK: Array[StringName] = [&"tree", &"book", &"smith", &"vendor", &"portal"]
const LAST_WALK: Array[StringName] = [&"smith", &"book", &"tree"]
const ARRIVED := 0.4
const STAND := 1.6
const WALK_MAX := 9.0
const AFTER_END := 5.0

var _reaction := "0.45"
var _phase := 0
var _walk: Array[StringName] = []
var _i := 0
var _t := 0.0
var _standing := 0.0
var _hub: Node = null
var _game: Node = null
var _pad: Object = null
var _ended := -1.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tour-reaction="):
			_reaction = a.trim_prefix("--tour-reaction=")
	_walk = FIRST_WALK.duplicate()
	change_scene_to_file("res://scenes/boot.tscn")


func _find(path: String) -> Node:
	for n in root.find_children("*", "", true, false):
		if n.get_script() != null and (n.get_script() as Script).resource_path == path:
			return n
	return null


func _process(delta: float) -> bool:
	match _phase:
		0, 2:
			_step_hub(delta)
		1:
			_step_game(delta)
	return false


func _step_hub(delta: float) -> void:
	if not is_instance_valid(_hub):
		_hub = _find(HUB)
		if _hub == null or _hub.get(&"player") == null:
			return
		_pad = load("res://scripts/controls.gd").VirtualPad.new()
		root.get_node(^"/root/Controls").set(&"virtual", _pad)
		_i = 0
		_t = 0.0
		_standing = 0.0
	if _i >= _walk.size():
		_pad.set(&"move", Vector2.ZERO)
		if _phase == 2:
			_t += delta
			if _t > 3.0:
				quit()
		return
	var station := _walk[_i]
	var goal: Vector2 = load(PLAN).use_point(station)
	var way: Vector2 = goal - (_hub.get(&"player").get(&"pos") as Vector2)
	_t += delta
	if way.length() > ARRIVED and _t < WALK_MAX:
		_pad.set(&"move", way.normalized())
		return
	_pad.set(&"move", Vector2.ZERO)
	_standing += delta
	if _standing < STAND:
		return
	if station == &"portal" and _phase == 0:
		var dev: Script = load(DEV)
		dev.call(&"put", "bot")
		dev.call(&"put", "bot-reaction", _reaction)
		root.get_node(^"/root/Controls").set(&"virtual", null)
		_phase = 1
		_hub.call(&"descend")
		_hub = null
		return
	_i += 1
	_t = 0.0
	_standing = 0.0


func _step_game(delta: float) -> void:
	if not is_instance_valid(_game):
		_game = _find(GAME)
		if _game != null:
			_game.connect(&"run_logged", func(_o: String, _e: Dictionary) -> void: _ended = 0.0)
		return
	if _ended < 0.0:
		return
	_ended += delta
	if _ended < AFTER_END:
		return
	var dev: Script = load(DEV)
	dev.call(&"drop", "bot")
	dev.call(&"drop", "bot-reaction")
	_phase = 2
	_walk = LAST_WALK.duplicate()
	_game = null
	load(GO).call(&"to", self, load(GO).get(&"HUB"))
