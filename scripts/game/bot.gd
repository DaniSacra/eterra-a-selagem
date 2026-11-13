class_name Bot
extends RefCounted
## A stand-in player for screenshots and smoke runs. Feeds Controls through a virtual pad:
## walks to the nearest enemy, plays the combos of the tree, steps out of warnings and dodges bolts.

const COMBOS: Array[String] = ["LLLL", "LLLH", "LH", "LLH", "HHL", "C", "dL", "dH"]
const GAP := 0.25
const REACH := 2.6

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
	var p := game.player.pos
	var target := _nearest(game)
	var to := target - p
	pad.aim = to.normalized() if to.length() > 0.01 else Vector2.DOWN
	pad.move = to.normalized() if to.length() > REACH else Vector2.ZERO
	if _queue.is_empty() and _wait > 0.25:
		# hit and run: after a combo, step out of the crowd
		pad.move = -to.normalized().rotated(0.6)
	var danger := _danger(game)
	if danger != Vector2.ZERO:
		pad.move = danger
		if game.player.dodge_charges > 0 and game.player.state != Player.State.DODGE:
			pad.press(&"dodge")
		pad.release(&"heavy_attack")
		_hold = 0.0
		_queue = ""
		return
	var spring: Variant = game.fountain_target()
	if spring != null and game.player.hp < game.player.max_hp * 0.6:
		pad.move = ((spring as Vector2) - p).normalized()
	if _hold > 0.0:
		_hold -= dt
		if _hold <= 0.0:
			pad.release(&"heavy_attack")
		return
	pad.release(&"heavy_attack")
	if _wait > 0.0:
		return
	if _queue.is_empty():
		if to.length() > REACH + 2.0:
			return
		_queue = COMBOS[_pick % COMBOS.size()]
		_pick += 1
	var key := _queue[0]
	_queue = _queue.substr(1)
	_wait = GAP if not _queue.is_empty() else 0.7
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
			pad.move = to.normalized() if to.length() > 0.1 else Vector2.RIGHT
			pad.press(&"dodge")
			_wait = 0.2


func _nearest(game: Game) -> Vector2:
	var p := game.player.pos
	var best := p + Vector2(cos(_t * 0.5), sin(_t * 0.5)) * 6.0
	var e := game.horde.nearest(p)
	if e:
		best = e.pos
	return best


## Direction out of the enemy warning the paladin is standing on (zero when safe). Bolts nearby count too.
func _danger(game: Game) -> Vector2:
	var p := game.player.pos
	for z in game.ground.zones:
		if z.kind != Ground.Kind.WARNING or z.life > 0.55:
			continue
		if not Ground.inside(z, p, 0.9):
			continue
		if z.shape == Ground.Shape.LINE:
			var side := z.dir.orthogonal()
			return side if (p - z.pos).dot(side) >= 0.0 else -side
		var away := p - z.pos
		return away.normalized() if away.length() > 0.1 else Vector2.RIGHT
	for shot in game.projectiles.shots:
		if shot.kind != Projectiles.Kind.BOLT and shot.kind != Projectiles.Kind.ORB:
			continue
		var to := p - shot.pos
		if to.length() < 3.0 and to.dot(shot.vel) > 0.0:
			var side := shot.vel.normalized().orthogonal()
			return side if to.dot(side) >= 0.0 else -side
	if game.boss and game.boss.mist and p.distance_to(game.boss.center) > game.boss.mist_radius - 2.0:
		return (game.boss.center - p).normalized()
	return Vector2.ZERO
