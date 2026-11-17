extends SceneTree
## QA tool (E2, Morvath harder): plays the real boss fight without a screen and times every attack of Morvath from
## his states: the attack state (approach + wind-up + active), the recovery (the window to punish), the rest before
## the next choice, and the life he lost in each recovery. Prints a line per attack and a table by attack id.
##   godot --headless --path . --fixed-fps 60 -s res://tools/boss_cadence.gd -- --start=boss --bot --nosave --seed=5 \
##     --boons=5 --bot-reaction=0.25 [--cadence-log]
## Times are seconds of the game's clock (60 frames a second). For docs/design/combat_cadence.md (Morvath).

var _game: Node = null
var _log := false
var _state := -1
var _since := 0.0
## The attack being timed: id, phase, attack seconds, recovery seconds, rest seconds, life lost in the recovery.
var _cur := {}
var _hp_at := 0.0
var _rows: Array[Dictionary] = []


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--cadence-log":
			_log = true
	change_scene_to_file("res://scenes/boot.tscn")


func _process(_dt: float) -> bool:
	if _game == null:
		for n in root.find_children("*", "Node", true, false):
			if n.has_method(&"result_line"):
				_game = n
		return false
	var g = _game
	var boss = g.boss
	if boss == null or boss.e == null:
		if not _rows.is_empty():
			_done()
		return false
	var states: Array = boss.State.keys()
	var st: int = boss.state
	var t: float = boss._clock
	if st != _state:
		_change(boss, states, st, t)
	if not boss.e.alive or not g.player.alive():
		_done()
	return false


func _change(boss: Object, states: Array, st: int, t: float) -> void:
	var was: String = states[_state] if _state >= 0 else ""
	var now: String = states[st]
	var spent := t - _since
	if was == "RECOVER" and not _cur.is_empty():
		_cur.recover = spent
		_cur.punish = _hp_at - boss.e.hp
	elif was == "CHASE" and not _cur.is_empty() and _cur.has("recover"):
		_cur.rest = spent
	if boss.ATTACKS.values().has(st):
		_close()
		_cur = {"id": boss._attack, "phase": boss.phase, "at": t}
	if now == "RECOVER" and not _cur.is_empty():
		_cur.attack = t - float(_cur.at)
		_hp_at = boss.e.hp
	if now in ["ROAR", "RITUAL", "STUNNED", "TO_CENTER"]:
		_close()
	if _log:
		print("t=%7.2f %-10s -> %-10s (%.2f s) attack=%s phase=%d" % [t, was, now, spent, boss._attack, boss.phase])
	_state = st
	_since = t


func _close() -> void:
	if not _cur.is_empty() and _cur.has("recover"):
		_rows.append(_cur)
	_cur = {}


func _done() -> void:
	_close()
	var by := {}
	for r in _rows:
		var k := "%s p%d" % [r.id, r.phase]
		if not by.has(k):
			by[k] = []
		(by[k] as Array).append(r)
	var keys := by.keys()
	keys.sort()
	print("CADENCE attack phase: n, attack s (min/median/max), recovery s, rest s, punished n, life lost per window")
	for k: String in keys:
		var list: Array = by[k]
		var a := _col(list, "attack")
		var r := _col(list, "recover")
		var s := _col(list, "rest")
		var hit := 0
		var lost := 0.0
		for row: Dictionary in list:
			if float(row.get("punish", 0.0)) > 0.0:
				hit += 1
			lost += float(row.get("punish", 0.0))
		print("  %-14s n=%2d attack %s recover %s rest %s punished %d/%d lost/window %.0f" % [k, list.size(), a, r, s, hit, list.size(), lost / maxf(list.size(), 1)])
	quit()


func _col(list: Array, key: String) -> String:
	var v: Array[float] = []
	for row: Dictionary in list:
		if row.has(key):
			v.append(float(row[key]))
	if v.is_empty():
		return "-"
	v.sort()
	return "%.2f/%.2f/%.2f" % [v[0], v[v.size() / 2], v[v.size() - 1]]
