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
	var danger := _danger(game)
	if danger != Vector2.ZERO:
		# standing on a warning: get out, rolling if there is a charge
		pad.move = danger
		if game.player.dodge_charges > 0 and game.player.state != Player.State.DODGE:
			pad.press(&"dodge")
		pad.release(&"heavy_attack")
		_hold = 0.0
		_queue = ""
		return
	var spring: Variant = game.fountain_target()
	if spring != null and game.player.hp < game.player.max_hp * 0.6:
		pad.move = ((spring as Vector2) - game.player.position).normalized()
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


## Direction out of the enemy warning the paladin is standing on (zero when safe). Bullets nearby count too.
func _danger(game: Game) -> Vector2:
	var p := game.player.position
	for z in game.ground.zones:
		if z.kind != Ground.Kind.WARNING or z.life > 0.55:
			continue
		var grown := z.radius
		z.radius += 6.0
		var hit := Ground.inside(z, p)
		z.radius = grown
		if not hit:
			continue
		if z.shape == Ground.Shape.LINE:
			var side := z.dir.orthogonal()
			return side if (p - z.pos).dot(side) >= 0.0 else -side
		var away := p - z.pos
		return away.normalized() if away.length() > 0.5 else Vector2.RIGHT
	for shot in game.projectiles.shots:
		if shot.kind == Projectiles.Kind.WAVE:
			continue
		var to := p + Vector2(0, -7) - shot.pos
		if to.length() < 22.0 and to.dot(shot.vel) > 0.0:
			var side := shot.vel.normalized().orthogonal()
			return side if to.dot(side) >= 0.0 else -side
	if game.boss and game.boss.mist and p.distance_to(game.boss.center) > game.boss.mist.radius - 14.0:
		return (game.boss.center - p).normalized()
	return Vector2.ZERO
