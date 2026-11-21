extends SceneTree
## QA (DT-RS3): plays the game as boot would (user args after --) and logs every rendered frame slower than
## --spike-ms (default 50), plus the worst frame of the first --first-frames (default 90) after each new arena/room.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/frame_spikes.gd -- --bot --seed=5 ...
## Reads the game only through node properties (nothing named at compile time).

var _t0 := 0
var _last := 0
var _key := ""
var _since := 0
var _worst := 0.0
var _spike := 50.0
var _first := 90
var _max_all := 0.0
var _frames := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--spike-ms="):
			_spike = float(a.get_slice("=", 1))
		elif a.begins_with("--first-frames="):
			_first = int(a.get_slice("=", 1))
	change_scene_to_file.call_deferred("res://scenes/boot.tscn")
	_t0 = Time.get_ticks_usec()
	_last = _t0


func _where() -> String:
	var g := _find_game(root)
	if g == null:
		var sc := current_scene
		return "scene:" + (str(sc.name) if sc else "?")
	var arena = g.get("arena")
	var rooms = g.get("rooms")
	var depth := -1
	if rooms and rooms.has_method("depth"):
		depth = rooms.depth()
	var aid := "?"
	if arena:
		aid = str(arena.get("id"))
	return "room%d:%s" % [depth, aid]


func _find_game(n: Node) -> Node:
	if n.get("arena") != null and n.get("rooms") != null:
		return n
	for c in n.get_children():
		var f := _find_game(c)
		if f:
			return f
	return null


func _process(_delta: float) -> bool:
	var now := Time.get_ticks_usec()
	var ms := (now - _last) / 1000.0
	_last = now
	_frames += 1
	var key := _where()
	if key != _key:
		if _key != "":
			print("FIRST %s worst %.1f ms over %d frames" % [_key, _worst, mini(_since, _first)])
		_key = key
		_since = 0
		_worst = 0.0
	_since += 1
	if _since <= _first:
		_worst = maxf(_worst, ms)
	if _frames > 5:
		_max_all = maxf(_max_all, ms)
	if ms > _spike:
		print("SPIKE %.1f ms at %.1f s real, frame %d, %s (frame %d there)" % [ms, (now - _t0) / 1e6, _frames, key, _since])
	return false


func _finalize() -> void:
	print("FIRST %s worst %.1f ms over %d frames" % [_key, _worst, mini(_since, _first)])
	print("FRAMES %d max %.1f ms over %.1f s" % [_frames, _max_all, (Time.get_ticks_usec() - _t0) / 1e6])
