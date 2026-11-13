class_name Bot
extends RefCounted
## A stand-in player for screenshots and smoke runs. Feeds Controls through a virtual pad:
## walks to the nearest enemy, plays the combos of the tree and dodges now and then.

const COMBOS: Array[String] = ["LLLL", "LLLH", "LH", "LLH", "HHL", "C", "dL", "dH"]
const GAP := 0.27

var pad := Controls.VirtualPad.new()
var _t := 0.0
var _queue := ""
var _wait := 0.0
var _hold := 0.0
var _rng := RandomNumberGenerator.new()
var _pick := 0


func _init() -> void:
	_rng.seed = 7


func step(dt: float, game: Game) -> void:
	pad.end_frame()
	_t += dt
	_wait -= dt
	pad.release(&"light_attack")
	pad.release(&"dodge")
	var target := _nearest(game)
	var to := target - game.player.position
	pad.aim = to
	var reach := 22.0
	pad.move = to.normalized() if to.length() > reach else Vector2.ZERO
	if game.player.hp < game.player.max_hp * 0.4 and to.length() < 40.0:
		pad.move = -to.normalized().rotated(0.6)
	if _hold > 0.0:
		_hold -= dt
		if _hold <= 0.0:
			pad.release(&"heavy_attack")
		return
	pad.release(&"heavy_attack")
	if _wait > 0.0:
		return
	if _queue.is_empty():
		if to.length() > reach + 14.0:
			return
		_queue = COMBOS[_pick % COMBOS.size()]
		_pick += 1
	var key := _queue[0]
	_queue = _queue.substr(1)
	_wait = GAP if not _queue.is_empty() else 0.75
	match key:
		"L":
			pad.press(&"light_attack")
		"H":
			pad.press(&"heavy_attack")
			_hold = 0.06
		"C":
			pad.press(&"heavy_attack")
			_hold = 0.6
		"d":
			pad.move = to.normalized() if to.length() > 1.0 else Vector2.RIGHT
			pad.press(&"dodge")
			_wait = 0.19


func _nearest(game: Game) -> Vector2:
	var best := game.player.position + Vector2(cos(_t), sin(_t)) * 40.0
	var best_d := INF
	for e in game.enemies.list:
		var d := e.pos.distance_squared_to(game.player.position)
		if d < best_d:
			best_d = d
			best = e.pos
	return best
