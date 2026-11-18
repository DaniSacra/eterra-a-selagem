extends SceneTree
## QA tool (E1c, bug 3 "Morvath disappears and shows up elsewhere"): plays the real boss fight without a screen and
## watches Morvath every frame: where he is simulated, where he is drawn (CrowdRenderer, recoil included), the clip and
## the poses the crowd asks for, his state. Prints every frame where something looks wrong and a summary.
##   godot --headless --path . --fixed-fps 60 -s res://tools/boss_probe.gd -- --start=boss --bot --nosave --seed=5 [--probe-secs=120] [--probe-log]
## Wrong: a pose row outside his clips, a clip he does not have (drawn as another), a step of his place faster than he
## can move outside his charge, a drawn place more than a recoil away from the simulated one.

var _game: Node = null
var _boss: Object = null
var _last := Vector2.INF
var _frames := 0
var _bad := 0
var _secs := 120.0
var _log := false
var _counts := {}
var _max_step := 0.0
var _max_step_at := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probe-secs="):
			_secs = float(a.trim_prefix("--probe-secs="))
		if a == "--probe-log":
			_log = true
	change_scene_to_file("res://scenes/boot.tscn")


func _process(dt: float) -> bool:
	if _game == null:
		for n in root.find_children("*", "Node", true, false):
			if n.has_method(&"result_line"):
				_game = n
		return false
	var g = _game
	if g.boss == null or g.boss.e == null:
		return false
	var e = g.boss.e
	_frames += 1
	var horde = g.horde
	var kind = horde.renderer.kind(e.def)
	var model = kind.model
	var st: String = g.boss.State.keys()[g.boss.state]
	var anim: StringName = e.anim
	var shown_anim: StringName = anim
	if e.state == 1 and e.hurt_t > 0.0 and (not e.def.heavy or e.hurt_t > horde.HURT_TIME - horde.HEAVY_HURT):
		shown_anim = &"hit"
	var key := "%s/%s" % [st, shown_anim]
	_counts[key] = int(_counts.get(key, 0)) + 1
	var problems: Array[String] = []
	if model.frame_count(shown_anim) == 0:
		problems.append("no clip '%s' (drawn as another)" % shown_anim)
	var total := 0
	for k: String in model.frames:
		total += int(model.frames[k])
	if e.alive and _last != Vector2.INF and g.boss.state != g.boss.State.DASH:
		var step: float = e.pos.distance_to(_last)
		var allowed: float = e.def.speed * 1.6 * maxf(dt, 1.0 / 60.0) + 0.05
		if step > _max_step:
			_max_step = step
			_max_step_at = "%s t=%.2f" % [key, g.time]
		if step > allowed:
			problems.append("jump %.2f m (allowed %.2f)" % [step, allowed])
	if e.y != 0.0:
		problems.append("y=%.2f" % e.y)
	if e.state != 1:
		problems.append("horde state %d" % e.state)
	if not horde.list.has(e) and e.alive:
		problems.append("not in the horde's list")
	if _log or not problems.is_empty():
		print("%5d t=%6.3f %-22s anim_t=%5.2f pos=(%.3f,%.3f) hero=%.2f m hurt=%.2f stun=%.2f push=%.2f %s" % [_frames, g.time, key, e.anim_t, e.pos.x, e.pos.y, e.pos.distance_to(g.player.pos), e.hurt_t, e.stun_t, e.push.length(), " | ".join(problems)])
	if not problems.is_empty():
		_bad += 1
	_last = e.pos
	if g.time > _secs or not e.alive or not g.player.alive():
		print("PROBE frames=%d bad=%d max_step=%.3f at %s total_poses=%d" % [_frames, _bad, _max_step, _max_step_at, total])
		var keys := _counts.keys()
		keys.sort()
		for k: String in keys:
			print("  %s %d" % [k, _counts[k]])
		print("CLIPS ", model.frames)
		quit()
	return false
