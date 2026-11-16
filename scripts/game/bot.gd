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
## Seconds it has been walking without getting anywhere (wedged by bodies: it dodges through them, STUCK_TIME).
var _stuck := 0.0
var _last := Vector2.ZERO
## Spells of being pinned (PIN_TIME or more), seconds of the one going on and since the last ended, and whether the
## paladin fell pinned (RESULT "bot").
var pinned := 0
var died_pinned := false
var _pin_t := 0.0
var _pin_since := INF
var _pin_last := Vector2.ZERO
## The share of a boss fight it keeps away (--bot-kite; 0: never).
var kite := 0.0
var _kiting := false
## Seconds into this KITE_PERIOD, seconds still to spend far from the boss in it, and the most it may still take.
var _kite_cycle := 0.0
var _kite_left := 0.0
var _kite_cap := 0.0
const STUCK_TIME := 0.4
## "Pinned" (cycle C11, counted for RESULT): it wants to walk, walks under PIN_SPEED m/s and a body or the floor's
## edge stands right where it walks, for PIN_TIME seconds or more in a row (one count per spell). A fall while pinned
## or less than PIN_TIME after a spell ended is a death by being pinned.
const PIN_TIME := 1.0
const PIN_SPEED := 0.5
const PIN_PROBE := 0.2
## Seconds ahead a warning still counts when the bot looks for a way out (it never runs into the next to land).
const ESCAPE_AHEAD := 1.0
## Meters of free floor it wants ahead of its way out of danger.
const ESCAPE_PROBE := 2.0
## --bot-kite=0.2: that share of every KITE_PERIOD seconds of a boss fight it spends far from the boss, past
## KITE_DISTANCE (it runs there first, the dodge held), and throws the special at him from there, as a person who
## keeps away would (QW-004 of cycle 10: the bot that always stays close never saw Morvath's dash, which needs 9 m).
const KITE_PERIOD := 10.0
## Seconds a spell of keeping away may take beyond its share (to get there; cornered, it gives up then).
const KITE_RUN := 2.0
const KITE_DISTANCE := 11.0
const KITE_THROW := 0.8


func _init() -> void:
	_rng.seed = 7
	reaction = maxf(0.0, Dev.num("bot-reaction", 0.0))
	kite = clampf(Dev.num("bot-kite", 0.0), 0.0, 1.0)


## One step of keeping away: true while it should keep away from the boss. Each KITE_PERIOD (the first after one
## period) it owes kite * KITE_PERIOD seconds far from him (far: past KITE_DISTANCE); running there does not count,
## but a spell never lasts more than KITE_RUN beyond its share.
func kite_step(dt: float, far: bool) -> bool:
	if kite <= 0.0:
		return false
	_kite_cycle += dt
	if _kite_cycle >= KITE_PERIOD:
		_kite_cycle -= KITE_PERIOD
		_kite_left = kite * KITE_PERIOD
		_kite_cap = _kite_left + KITE_RUN
	if _kite_left <= 0.0 or _kite_cap <= 0.0:
		return false
	_kite_cap -= dt
	if far:
		_kite_left -= dt
	return true


## The way out of danger as the bot knows it now: what it saw `reaction` seconds ago.
func _react(now: Vector2) -> Vector2:
	if reaction <= 0.0:
		return now
	_seen.append([_t, now])
	while _seen.size() > 1 and float(_seen[1][0]) <= _t - reaction:
		_seen.pop_front()
	return _seen[0][1] if float(_seen[0][0]) <= _t - reaction else Vector2.ZERO


## How long it has been pinned against a body or the floor's edge (the step before told where it wanted to go).
func _track_pinned(dt: float, game: Game) -> void:
	var p := game.player.pos
	var moved := p.distance_to(_pin_last)
	_pin_last = p
	if game.fx.stop_left > 0.0 or game.mode != Game.Mode.PLAY:
		# a hit stop or a menu: nobody moves, nothing is counted
		return
	var held := false
	if pad.move.length() > 0.1 and game.player.alive() and game.player.state == Player.State.MOVE and not game.player.runner.is_swinging() \
			and dt > 0.0 and moved < PIN_SPEED * dt:
		var probe := p + pad.move.normalized() * PIN_PROBE
		held = game.horde.body_at(probe, Player.RADIUS) or game.arena.resolve(probe, Player.RADIUS).distance_to(probe) > 0.02
	if held:
		_pin_t += dt
		if _pin_t >= PIN_TIME and _pin_t - dt < PIN_TIME:
			pinned += 1
	else:
		if _pin_t >= PIN_TIME:
			_pin_since = 0.0
		_pin_t = 0.0
		_pin_since += dt


## The paladin fell (Game._on_player_died): was it while pinned?
func on_died() -> void:
	died_pinned = _pin_t >= PIN_TIME or _pin_since < PIN_TIME


## The bot's numbers for RESULT.
func stats() -> Dictionary:
	return {"stuck": pinned, "died_stuck": died_pinned}


func step(dt: float, game: Game) -> void:
	_track_pinned(dt, game)
	pad.end_frame()
	_t += dt
	_wait -= dt
	if _held != &"light_attack" or _hold <= 0.0:
		pad.release(&"light_attack")
	var p := game.player.pos
	var was_kiting := _kiting
	var fighting := game.boss != null and game.boss.e != null and game.boss.e.alive
	_kiting = fighting and kite_step(dt, p.distance_to(game.boss.e.pos) >= KITE_DISTANCE)
	if not _kiting:
		pad.release(&"dodge")
	pad.release(&"cast")
	if game.rooms and game.horde.count() == 0:
		# between fights: take the reward, buy what there is gold for, walk through a door
		var goal: Variant = game.rooms.bot_goal()
		pad.move = _steer(game, p, ((goal as Vector2) - p).normalized()) if goal != null and p.distance_to(goal) > 0.3 else Vector2.ZERO
		_queue = ""
		_hold = 0.0
		_seen.clear()
		pad.release(&"heavy_attack")
		return
	var walking := pad.move.length() > 0.1 and game.player.state == Player.State.MOVE and not game.player.runner.is_swinging()
	_stuck = _stuck + dt if walking and p.distance_to(_last) < dt * 1.0 else 0.0
	_last = p
	var target := _nearest(game)
	var to := target - p
	pad.aim = to.normalized() if to.length() > 0.01 else Vector2.DOWN
	pad.move = _steer(game, p, to.normalized()) if to.length() > REACH else Vector2.ZERO
	if _queue.is_empty() and _wait > 0.25:
		# hit and run: after a combo, step out of the crowd (around the bodies in the way)
		pad.move = _steer(game, p, -to.normalized().rotated(0.6))
	if _stuck > STUCK_TIME and pad.move != Vector2.ZERO and game.player.dodge_charges > 0:
		# the bodies of the crowd hold it: the dash goes through them
		pad.press(&"dodge")
		_stuck = 0.0
	var danger := _react(_danger(game))
	if danger != Vector2.ZERO:
		pad.move = _escape(game, p, danger)
		if game.player.dodge_charges > 0 and game.player.state != Player.State.DODGE:
			pad.release(&"dodge")  # (held while it runs away: let go, or the press would not dodge)
			pad.press(&"dodge")
		pad.release(&"heavy_attack")
		pad.release(&"light_attack")
		_hold = 0.0
		_queue = ""
		return
	if _kiting:
		_keep_away(game, p, game.boss.e.pos, not was_kiting, dt)
		return
	if was_kiting:
		pad.release(&"heavy_attack")
		_hold = 0.0
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


## Runs away from the boss (around walls and bodies, the dodge held to sprint) until KITE_DISTANCE, then throws the
## special at him every KITE_THROW seconds. first: the first frame of a spell of keeping away.
func _keep_away(game: Game, p: Vector2, boss: Vector2, first: bool, dt: float) -> void:
	var away := p - boss
	var far := away.length() >= KITE_DISTANCE
	pad.aim = -away.normalized() if away.length() > 0.01 else Vector2.DOWN
	pad.release(&"light_attack")
	if first:
		_queue = ""
		_hold = 0.0
		_wait = 0.0
	if far:
		pad.move = Vector2.ZERO
		pad.release(&"dodge")
		if _hold > 0.0:
			_hold -= dt
			if _hold <= 0.0:
				pad.release(&"heavy_attack")
		elif _wait <= 0.0:
			pad.press(&"heavy_attack")
			_held = &"heavy_attack"
			_hold = 0.06
			_wait = KITE_THROW
		return
	var out := away.normalized() if away.length() > 0.1 else Vector2.RIGHT
	pad.move = _steer(game, p, _escape(game, p, out))
	pad.press(&"dodge")  # held: the dodge, then the run


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


## The way out of danger that the floor's edge and the other warnings leave open: the first direction, turning
## further each try to either side (all the way round: the dash goes through a body that stands in a corner with
## him), with floor ahead of it and no warning about to land there (in the storm: the gap between two lanes, cycle
## C11). When no direction is clear of warnings, the first with floor.
func _escape(game: Game, from: Vector2, dir: Vector2) -> Vector2:
	var floor_only := Vector2.ZERO
	for k in [0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6]:
		var d := dir.rotated(k * PI / 6.0)
		var probe := from + d * ESCAPE_PROBE
		if game.arena.resolve(probe, Player.RADIUS).distance_to(probe) >= 0.05:
			continue
		if not _threatened(game, probe):
			return d
		if floor_only == Vector2.ZERO:
			floor_only = d
	return floor_only if floor_only != Vector2.ZERO else dir


## True when a warning lands at q within ESCAPE_AHEAD seconds, or a crescent flies at it.
func _threatened(game: Game, q: Vector2) -> bool:
	for z in game.ground.zones:
		if z.kind == Ground.Kind.WARNING and z.rune != Ground.Rune.SUMMON and z.life <= ESCAPE_AHEAD and Ground.inside(z, q, 0.6):
			return true
	for shot in game.projectiles.shots:
		if shot.kind != Projectiles.Kind.SOUL or shot.seen.has(game.player):
			continue
		var to := q - shot.pos
		var ahead := shot.vel.normalized()
		if to.dot(ahead) > -0.5 and to.dot(ahead) < 6.0 and absf(to.cross(ahead)) < shot.half_width + 0.9:
			return true
	return false


## Walks around what blocks the way (pillars, stairs, rubble, the bodies of enemies): the first direction, turning a
## little more each try to either side, that is not stopped by a wall, a prop or a body.
func _steer(game: Game, from: Vector2, dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return dir
	for k in [0, 1, -1, 2, -2, 3, -3]:
		var d := dir.rotated(k * PI / 7.0)
		var probe := from + d * 1.2
		if game.arena.resolve(probe, Player.RADIUS).distance_to(probe) < 0.05 and not game.horde.body_at(probe, Player.RADIUS):
			return d
	return dir
