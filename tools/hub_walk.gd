extends SceneTree
## Art tool (ENV-HB6, BH-07; outside the game's code): opens the game into the hub (scenes/boot.tscn with --hub) and
## walks the hero from where he arrives to a station's use point through the Controls autoload's VirtualPad, saving frames on the way,
## so a strip shows the arrival and the light of the station he walks to.
##   tools/gpu.sh run -s res://tools/hub_walk.gd -- --hub --look=stylized --walk-to=smith \
##     --walk-frames=C:/x/walk_ --walk-every=0.4 --walk-count=12 [--walk-wait=1.0]
## --walk-to: a station id (HubPlan.STATIONS); --walk-wait: seconds standing at the arrival before walking (the first
## frames show the arrival); frames are <prefix>NN.png every --walk-every seconds from the start, --walk-count of them.

## Scripts by path: a -s tool compiles before the autoloads exist, and the hub's classes name the Controls autoload.
const HUB := "res://scripts/game/hub.gd"
const PLAN := "res://scripts/core/hub_plan.gd"
## How near the use point the walk stops (m).
const ARRIVED := 0.3

var _to := &"smith"
var _prefix := ""
var _every := 0.4
var _count := 12
var _wait := 1.0
var _t := 0.0
var _next := 0.0
var _saved := 0
var _hub: Node = null
var _controls: Node = null
var _pad: Object = null


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--walk-to="):
			_to = StringName(a.trim_prefix("--walk-to="))
		elif a.begins_with("--walk-frames="):
			_prefix = a.trim_prefix("--walk-frames=")
		elif a.begins_with("--walk-every="):
			_every = float(a.trim_prefix("--walk-every="))
		elif a.begins_with("--walk-count="):
			_count = int(a.trim_prefix("--walk-count="))
		elif a.begins_with("--walk-wait="):
			_wait = float(a.trim_prefix("--walk-wait="))
	change_scene_to_file("res://scenes/boot.tscn")


func _process(delta: float) -> bool:
	if _hub == null:
		for n in root.find_children("*", "Node3D", true, false):
			if n.get_script() != null and (n.get_script() as Script).resource_path == HUB:
				_hub = n
		if _hub == null or _hub.get(&"player") == null:
			return false
		# the autoload by path: a -s script compiles before autoloads exist
		_controls = root.get_node(^"/root/Controls")
		_pad = load("res://scripts/controls.gd").VirtualPad.new()
		_controls.set(&"virtual", _pad)
	_t += delta
	var player: Node = _hub.get(&"player")
	var goal: Vector2 = load(PLAN).use_point(_to)
	var way: Vector2 = goal - (player.get(&"pos") as Vector2)
	_pad.set(&"move", Vector2.ZERO if _t < _wait or way.length() < ARRIVED else way.normalized())
	if _prefix != "" and _t >= _next and _saved < _count:
		_next += _every
		var img := root.get_viewport().get_texture().get_image()
		img.save_png("%s%02d.png" % [_prefix, _saved])
		_saved += 1
		if _saved >= _count:
			quit()
	return false
