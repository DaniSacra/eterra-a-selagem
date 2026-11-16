class_name Bot
extends RefCounted
## A stand-in player for screenshots and smoke runs. Feeds Controls through a virtual pad:
## walks to the nearest enemy, plays the combos of the tree, steps out of warnings and dodges bolts.

## L attack, H special, C special held (Omega special), O attack held (Omega attack), Q circle of light, d dash.
const COMBOS: Array[String] = ["LLL", "Q", "H", "LLL", "O", "LL", "H", "C", "dL", "LLL"]
const GAP := 0.25
const REACH := 3.6

var pad := Controls.VirtualPad.new()
var _t := 0.0
var _queue := ""
var _wait := 0.0
var _hold := 0.0
## The button being held down for _hold more seconds.
var _held := &"heavy_attack"
var _rng := RandomNumberGenerator.new()
var _pick := 0
## Seconds between seeing a danger and acting on it (--bot-reaction=0.25: a person's reaction time, so the boss
## simulations are honest; 0: the old bot, who answers the same frame). What it does is what it saw that long ago.
var reaction := 0.0
## What it saw, oldest first: [time, the way out (zero when safe)].
var _seen: Array[Array] = []


func _init() -> void:
	_rng.seed = 7
	reaction = maxf(0.0, Dev.num("bot-reaction", 0.0))


## The way out of danger as the bot knows it now: what it saw `reaction` seconds ago.
func _react(now: Vector2) -> Vector2:
	if reaction <= 0.0:
		return now
	_seen.append([_t, now])
	while _seen.size() > 1 and float(_seen[1][0]) <= _t - reaction:
		_seen.pop_front()
	return _seen[0][1] if float(_seen[0][0]) <= _t - reaction else Vector2.ZERO


func step(dt: float, game: Game) -> void:
	pad.end_frame()
	_t += dt
	_wait -= dt
	if _held != &"light_attack" or _hold <= 0.0:
		pad.release(&"light_attack")
	pad.release(&"dodge")
	pad.release(&"cast")
	var p := game.player.pos
	if game.rooms and game.horde.count() == 0:
		# between fights: take the reward, buy what there is gold for, walk through a door
		var goal: Variant = game.rooms.bot_goal()
		pad.move = _steer(game, p, ((goal as Vector2) - p).normalized()) if goal != null and p.distance_to(goal) > 0.3 else Vector2.ZERO
		_queue = ""
		_hold = 0.0
		_seen.clear()
		pad.release(&"heavy_attack")
		return
	var target := _nearest(game)
	var to := target - p
	pad.aim = to.normalized() if to.length() > 0.01 else Vector2.DOWN
	pad.move = _steer(game, p, to.normalized()) if to.length() > REACH else Vector2.ZERO
	if _queue.is_empty() and _wait > 0.25:
		# hit and run: after a combo, step out of the crowd
		pad.move = -to.normalized().rotated(0.6)
	var danger := _react(_danger(game))
	if danger != Vector2.ZERO:
		pad.move = danger
		if game.player.dodge_charges > 0 and game.player.state != Player.State.DODGE:
			pad.press(&"dodge")
		pad.release(&"heavy_attack")
		pad.release(&"light_attack")
		_hold = 0.0
		_queue = ""
		return
	var spring: Variant = game.fountain_target()
	if spring != null and game.player.hp < game.player.max_hp * 0.6:
		pad.move = ((spring as Vector2) - p).normalized()
	if _hold > 0.0:
		_hold -= dt
		if _hold <= 0.0:
			pad.release(_held)
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
			_held = &"heavy_attack"
			_hold = 0.06
		"C":
			pad.press(&"heavy_attack")
			_held = &"heavy_attack"
			_hold = 0.75
		"O":
			pad.press(&"light_attack")
			_held = &"light_attack"
			_hold = 0.9
		"Q":
			pad.press(&"cast")
		"d":
			pad.move = to.normalized() if to.length() > 0.1 else Vector2.RIGHT
			pad.press(&"dodge")
			_wait = 0.2


## The nearest enemy that can be hurt (behind his ritual's shield the boss waits: his dead come first).
func _nearest(game: Game) -> Vector2:
	var p := game.player.pos
	var best := p + Vector2(cos(_t * 0.5), sin(_t * 0.5)) * 6.0
	var best_d := INF
	for e in game.horde.list:
		var d := p.distance_squared_to(e.pos)
		if e.alive and not e.invulnerable and d < best_d:
			best_d = d
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
		if not Projectiles.hostile(shot) or shot.seen.has(game.player):
			continue
		var to := p - shot.pos
		var ahead := shot.vel.normalized()
		# a crescent is wide across its flight: step out of its lane, not just away from its middle
		var lane := shot.half_width + 0.9 if shot.kind == Projectiles.Kind.SOUL else 1.2
		if to.dot(ahead) > -0.5 and to.dot(ahead) < 4.0 and absf(to.cross(ahead)) < lane:
			var side := ahead.orthogonal()
			return side if to.dot(side) >= 0.0 else -side
	return Vector2.ZERO


## Walks around what blocks the way (pillars, stairs, rubble): the first direction, turning a little more each
## try to either side, that is not stopped by a wall or a prop.
func _steer(game: Game, from: Vector2, dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return dir
	for k in [0, 1, -1, 2, -2, 3, -3]:
		var d := dir.rotated(k * PI / 7.0)
		var probe := from + d * 1.2
		if game.arena.resolve(probe, Player.RADIUS).distance_to(probe) < 0.05:
			return d
	return dir
