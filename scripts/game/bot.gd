class_name Bot
extends RefCounted
## A stand-in player for screenshots and smoke runs. Feeds Controls through a virtual pad:
## walks to the nearest enemy, plays the combos of the tree, steps out of warnings and dodges bolts.

## L attack, H special, C special held (Omega special), O attack held (Omega attack), Q circle of light, d dash.
## How near a shot being readied keeps the robot from the attack's Omega (shot_coming).
const SHOT_NEAR := 12.0
## L: a tap of the left; S: the Corte Circular (a tap of the right); O: the Esmagador (the left held); T: the Lança (the right held);
## d: a dodge. A blow that costs Magia the robot cannot pay, or that has nothing to hit, is a plain L.
const COMBOS: Array[String] = ["LLL", "S", "LLL", "O", "LL", "T", "dL", "LLL", "S"]
const GAP := 0.25
## C1b: the share of its poise left from which the bot breaks a common with the special.
const WORN := 0.55
const REACH := 3.6
## RP-09: the bot goes for a cracked column within COLUMN_NEAR m that would fall on COLUMN_PACK enemies or more
## (column_plan), round to its other side and swings at it from COLUMN_REACH m along the way it should fall.
## RP-16: the bot steps on a slab within SLIT_NEAR m whose slit's band holds SLIT_PACK enemies or more and not him.
const SLIT_PACK := 2
const SLIT_NEAR := 8.0
const COLUMN_PACK := 1
const COLUMN_NEAR := 10.0
const COLUMN_REACH := 2.2
## How near the spot he swings at a column from counts as there.
const COLUMN_STAND := 0.7
## RP-14: the bot charges a crystal within CRYSTAL_NEAR m whose column holds CRYSTAL_PACK enemies or more
## (crystal_plan), from CRYSTAL_SIDE m to its side (out of the column it will strike) and CRYSTAL_BACK m south of it.
const CRYSTAL_PACK := 2
const CRYSTAL_NEAR := 18.0
const CRYSTAL_SIDE := 2.1
const CRYSTAL_BACK := 1.4
## RP-12: the bot lights an oil urn within URN_NEAR m with URN_PACK enemies or more in its ring (urn_plan), from
## URN_REACH m off it on the side away from the pack (he steps out of the ring as it warns: _danger).
const URN_PACK := 2
const URN_NEAR := 10.0
const URN_REACH := 1.5
## Cover (CoverPlan): when a shooter readies a shot (or a shot flies at him) and a column that stops shots is within
## COVER_NEAR m, the bot steps behind it (as a person would), for at most COVER_MAX s a spell, then COVER_REST s off.
## It decides per spell with chance --bot-cover (default COVER_CHANCE = 0: off, measured no better, see docs/reference/engine.md), and only after `reaction`.
const COVER_NEAR := 4.5
## Enemies this close (m) that do not shoot keep him fighting: no cover then.
const COVER_CROWD := 4.0
const COVER_MAX := 1.5
const COVER_REST := 2.0
const COVER_LINGER := 0.5
const COVER_CHANCE := 0.0
const COVER_SIGHT := 18.0

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

## Its own way to where it walks (cycle C12): the arena's NavGrid, a FlowField toward its goal of the moment.
var _field: FlowField
## Cover: the chance a spell is taken, seconds the threat has been seen / the spell has lasted / until the next may start,
## whether this spell was chosen, and the seconds spent hidden from a shooter (RESULT bot.cover_time).
var cover_chance := COVER_CHANCE
var cover_time := 0.0
var cover_spells := 0
var _cover_seen := 0.0
var _cover_on := 0.0
var _cover_off := 0.0
var _cover_lost := 0.0
var _cover_pick := false


func _init() -> void:
	_rng.seed = 7
	reaction = maxf(0.0, Dev.num("bot-reaction", 0.0))
	kite = clampf(Dev.num("bot-kite", 0.0), 0.0, 1.0)
	cover_chance = clampf(Dev.num("bot-cover", COVER_CHANCE), 0.0, 1.0)


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
	if pad.move.length() > 0.1 and game.player.alive() and game.player.state == Player.State.MOVE and not game.player.runner.planted() \
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


## Enemies within the Brado's reach the robot waits for before it cries out.
const SHOUT_PACK := 3
const SHOUT_REACH := 4.0


## Below this share of his life a full charge is spent at once (KT 3): the Golpe Supremo is also the way out of a bad moment.
const HURT_ULT := 0.4
## How close an enemy must be for the hurt paladin's Golpe Supremo (m).
const HURT_ULT_NEAR := 9.0


## Whether the paladin is hurt enough to spend a full ultimate without waiting for a crowd.
static func hurt_for_ult(ready: bool, hp: float, max_hp: float) -> bool:
	return ready and max_hp > 0.0 and hp < max_hp * HURT_ULT


## The ultimate now: full and worth it (a pack in its reach, a big one), or full with the paladin hurt and a foe near.
func _ult_now(game: Game, p: Vector2, dir: Vector2) -> bool:
	if not game.player.ult_ready:
		return false
	if game.ults.worth(p, dir):
		return true
	if not hurt_for_ult(true, game.player.hp, game.player.max_hp):
		return false
	for e: Enemy in game.horde.list:
		if e.alive and not e.invulnerable and e.pos.distance_to(p) <= HURT_ULT_NEAR:
			return true
	return false


## GP-1: the Warrior's strong blows (the Corte Circular on a tap of the right button, the Esmagador and the Lança held). The robot
## sweeps when SWEEP_PACK or more stand within the circle, smashes what is within SMASH_NEAR m and throws the Lança at what is within
## LANCE_FAR m, each only with the Magia for it.
const SWEEP_PACK := 2
const SWEEP_REACH := 3.2
const SMASH_NEAR := 2.4
const LANCE_FAR := 11.0
## Seconds the robot holds the left button for the Esmagador (it fills in 0.6) and the right for the Lança (0.8).
const SMASH_HOLD := 0.8
const LANCE_HOLD := 1.0


## The Corte Circular is worth its Magia: it can pay and the pack (or a blow about to fall) is within the circle.
static func sweep_worth(game: Game, at: Vector2) -> bool:
	var p := game.player
	var node := ComboTree.find(p.tree.neutral, ComboNode.In.HEAVY)
	if node == null or not p.magick.can_pay(p._cost_now(node)):
		return false
	var near: Array[Enemy] = []
	game.horde.in_circle(at, SWEEP_REACH, near)
	return near.size() >= SWEEP_PACK


## A held blow (CHARGE_LIGHT or CHARGE) is paid for now.
static func can_hold(game: Game, input: ComboNode.In) -> bool:
	var node := ComboTree.find(game.player.tree.neutral, input)
	return node != null and game.player.magick.can_pay(game.player._cost_now(node))


## The paladin fell (Game._on_player_died): was it while pinned?
func on_died() -> void:
	died_pinned = _pin_t >= PIN_TIME or _pin_since < PIN_TIME


## Below this share of its life the bot walks to a fountain that still has light (B-2). C17 (QW-112): the share it
## picks the fountain's door at (Rooms.BOT_FOUNTAIN_BELOW, was 0.6: it walked in at 63% and left without drinking).
const DRINK_BELOW := Rooms.BOT_FOUNTAIN_BELOW


## Where the bot goes to drink: the fountain (`spring`, Game.fountain_target) when its life is under DRINK_BELOW of
## the most, else null.
static func drink_at(spring: Variant, hp: float, max_hp: float) -> Variant:
	if spring == null or hp >= max_hp * DRINK_BELOW:
		return null
	return spring


## The bot's numbers for RESULT.
func stats() -> Dictionary:
	return {"stuck": pinned, "died_stuck": died_pinned, "cover_time": snappedf(cover_time, 0.1), "cover_spells": cover_spells}


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
	pad.release(&"ultimate")
	# C19, Q-13: the reward, a shop's item and a door are used with interact, as a player presses it there
	if game.rooms and game.rooms.usable() and not pad.held.has(&"interact"):
		pad.press(&"interact")
	else:
		pad.release(&"interact")
	if game.rooms and game.horde.count() == 0:
		# between fights: drink from the fountain when hurt (B-2), take the reward, buy what there is gold for, walk
		# through a door
		var goal: Variant = drink_at(game.fountain_target(), game.player.hp, game.player.max_hp)
		if goal == null:
			goal = game.rooms.bot_goal()
		pad.move = _steer(game, p, _way(game, p, goal as Vector2, dt)) if goal != null and p.distance_to(goal) > 0.3 else Vector2.ZERO
		if goal != null and not game.arena.gaps.is_empty():
			# PT-25-9: a stream only the dash crosses: from its bank, one dash toward the goal
			var hop := GapRule.hop(game.arena.gaps, p, goal as Vector2, Feel.live().dodge_speed * Feel.live().dodge_time * 0.75)
			if hop != Vector2.ZERO and game.player.dodge_charges > 0 and game.player.state == Player.State.MOVE:
				pad.move = hop
				pad.release(&"dodge")
				pad.press(&"dodge")
		_queue = ""
		_hold = 0.0
		_seen.clear()
		pad.release(&"heavy_attack")
		return
	var walking := pad.move.length() > 0.1 and game.player.state == Player.State.MOVE and not game.player.runner.planted()
	_stuck = _stuck + dt if walking and p.distance_to(_last) < dt * 1.0 else 0.0
	_last = p
	var target := _nearest(game)
	# a piece of the room turned on the pack (RP-09 column, RP-14 crystal, RP-12 oil urn): the same plan for all
	var column: Variant = column_plan(game, p)
	if column == null:
		column = crystal_plan(game, p)
	if column == null:
		column = urn_plan(game, p)
	if game.arcane != null:
		column = null  # (her shots do not topple columns: the Maga's robot fights the enemies)
	if column != null:
		target = column.center
	var to := target - p
	# C5: to the Varredor he goes to its feet (the bar does not hurt within sweep_clear) and does not step back from there
	var sweeper := _sweeper_at(game, target)
	var reach := SWEEPER_STAND if sweeper != null else REACH
	pad.aim = to.normalized() if to.length() > 0.01 else Vector2.DOWN
	pad.move = _steer(game, p, _way(game, p, target, dt)) if to.length() > reach else Vector2.ZERO
	if column != null:
		# RP-09: round to the column's far side from the pack, then swing along the way it should fall
		var stand: Vector2 = column.stand
		pad.move = _steer(game, p, _way(game, p, stand, dt)) if p.distance_to(stand) > COLUMN_STAND else Vector2.ZERO
		pad.aim = column.way
	else:
		var slab: Variant = slit_plan(game, p)
		if slab != null:
			pad.move = _steer(game, p, _way(game, p, slab as Vector2, dt))
	if _queue.is_empty() and _wait > 0.25 and sweeper == null:
		# hit and run: after a combo, step out of the crowd (around the bodies in the way)
		pad.move = _steer(game, p, -to.normalized().rotated(0.6))
	if _stuck > STUCK_TIME and pad.move != Vector2.ZERO and game.player.dodge_charges > 0:
		# the bodies of the crowd hold it: the dash goes through them
		pad.press(&"dodge")
		_stuck = 0.0
	var through: Variant = ring_dash(game, p)
	if through != null:
		pad.move = through as Vector2
		pad.release(&"dodge")
		pad.press(&"dodge")
		_hold = 0.0
		_queue = ""
		return
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
	var cover: Variant = _cover(game, p, dt)
	if cover != null:
		var at := cover as Vector2
		pad.move = _steer(game, p, _way(game, p, at, dt)) if p.distance_to(at) > 0.3 else Vector2.ZERO
	if _kiting:
		_keep_away(game, p, game.boss.e.pos, not was_kiting, dt)
		return
	if was_kiting:
		pad.release(&"heavy_attack")
		_hold = 0.0
	var spring: Variant = drink_at(game.fountain_target(), game.player.hp, game.player.max_hp)
	if spring != null:
		pad.move = ((spring as Vector2) - p).normalized()
	if game.arcane != null:
		_arcane_step(game, p, target, dt)
		return
	if not Dev.has("bot-mouse") and _ult_now(game, p, pad.aim):
		# the ultimate as soon as it is full and worth it (the pack in the band or the Voragem, or a big one)
		pad.press(&"ultimate")
		return
	if _hold > 0.0:
		_hold -= dt
		if _hold <= 0.0:
			pad.release(_held)
		return
	pad.release(&"heavy_attack")
	if _wait > 0.0:
		return
	if _queue.is_empty():
		if column != null and p.distance_to(column.stand) > COLUMN_STAND or column == null and to.length() > REACH + 2.0:
			return
		_queue = COMBOS[_pick % COMBOS.size()]
		_pick += 1
		if column == null and _guarded(game, target):
			_queue = "T" + _queue  # CB-0: the Lança (heavy) opens a shield's guard
		elif column == null and _worn(game, target):
			_queue = "O" + _queue  # C1b: a common worn halfway is broken by the Esmagador, not by one more blow
	var key := _queue[0]
	_queue = _queue.substr(1)
	_wait = GAP if not _queue.is_empty() else 0.7
	match key:
		"L":
			pad.press(&"light_attack")
		"S":
			if sweep_worth(game, p):
				pad.press(&"heavy_attack")  # a tap: let go in 0.06 s, before the hold threshold
				_held = &"heavy_attack"
				_hold = 0.06
			elif to.length() <= SMASH_NEAR and can_hold(game, ComboNode.In.CHARGE_LIGHT) and not shot_coming(game, p):
				# a lone target: the Esmagador in the Ritmo's window (GP-1) instead of the circle
				pad.press(&"light_attack")
				_held = &"light_attack"
				_hold = SMASH_HOLD
			else:
				pad.press(&"light_attack")
		"O":
			if to.length() <= SMASH_NEAR and can_hold(game, ComboNode.In.CHARGE_LIGHT) and not shot_coming(game, p):
				# (C19, combat_cadence.md 8.3: never planted in a charge with a shot being readied near)
				pad.press(&"light_attack")
				_held = &"light_attack"
				_hold = SMASH_HOLD
			else:
				pad.press(&"light_attack")
		"T":
			if to.length() <= LANCE_FAR and can_hold(game, ComboNode.In.CHARGE) and not shot_coming(game, p):
				pad.press(&"heavy_attack")
				_held = &"heavy_attack"
				_hold = LANCE_HOLD
			else:
				pad.press(&"light_attack")
		"d":
			pad.move = to.normalized() if to.length() > 0.1 else Vector2.RIGHT
			pad.press(&"dodge")
			_wait = 0.2


## The Maga's robot (04_PLANO C): it keeps ARC_NEAR to ARC_FAR m from the nearest enemy and plays the loop below; the
## Convergência goes by `_ult_now`. The Passo is the danger code's.
const ARC_NEAR := 3.5
const ARC_FAR := 5.0
## Enemies close enough for the Combustão and the Inverno Eterno to be worth their Magia, and how long their button is held (s: from the
## press, past the least charge, then let go: Maga Redesign V1, the held spells strike on the release). The Sopro Glacial (free) is
## breathed on whoever is within ARC_BREATH of her, so the Combustão that follows is a Choque Térmico.
const ARC_VOLT_PACK := 2
const ARC_FROST_PACK := 3
const ARC_CHARGE_HOLD := 0.9
## With the Mana for it, the Combustão is held to its full (1.5 s from the press) and costs the most.
const ARC_BURN_HOLD := 1.55
const ARC_BURN_FULL := 25.0
const ARC_BURN_RANGE := 9.0
const ARC_BREATH := 5.0


## The Maga's loop (GP-5): keep her distance; the Arco (hold the left) on two or more, the Geada (hold the right) on a pack, the Estilhaço
## (tap the right) down the line while the Magia is there, the Centelha (tap the left, free) otherwise (three of them set the target alight).
func _arcane_step(game: Game, p: Vector2, target: Vector2, dt: float) -> void:
	var a := game.arcane
	var player := game.player
	var to := target - p
	var dist := to.length()
	var dir := to.normalized() if dist > 0.01 else Vector2.DOWN
	var holding := _hold > 0.0
	if not holding:
		pad.aim = dir
		pad.release(&"heavy_attack")
	if dist > ARC_FAR:
		pad.move = _steer(game, p, _way(game, p, target, 0.0))
	elif dist < ARC_NEAR:
		pad.move = _steer(game, p, -dir)
	else:
		pad.move = Vector2.ZERO
	if holding:
		_hold -= dt
		if _hold <= 0.0:
			pad.release(_held)
		return
	if player.state != Player.State.MOVE:
		return
	if _ult_now(game, p, dir):
		pad.press(&"ultimate")
		return
	if _wait > 0.0:
		return
	var busy := player.runner.is_attacking()
	var in_range := dist <= a.kit.spark_range
	var pack: Array[Enemy] = []
	game.horde.in_circle(target, a.kit.frost_radius, pack)
	var frost_worth := in_range and dist <= a.kit.frost_range and pack.size() >= ARC_FROST_PACK
	# the Geada on a pack (held on the right)
	if not busy and frost_worth and can_hold(game, ComboNode.In.CHARGE):
		pad.aim = dir
		pad.press(&"heavy_attack")
		_held = &"heavy_attack"
		_hold = ARC_CHARGE_HOLD
		_wait = 0.6
		return
	# the Combustão on two or more within reach (held on the left, let go to throw)
	if not busy and can_hold(game, ComboNode.In.CHARGE_LIGHT):
		var close: Array[Enemy] = []
		game.horde.in_circle(p, ARC_BURN_RANGE, close)
		if close.size() >= ARC_VOLT_PACK:
			pad.press(&"light_attack")
			_held = &"light_attack"
			_hold = ARC_BURN_HOLD if player.magick.value >= ARC_BURN_FULL else ARC_CHARGE_HOLD
			_wait = 0.6
			return
	# the Sopro Glacial (a tap on the right, free) on whoever is close, the Centelha (a tap on the left, free) otherwise
	if in_range:
		if not busy and dist <= ARC_BREATH:
			pad.press(&"heavy_attack")
			_hold = 0.06
			_held = &"heavy_attack"
			_wait = 0.3
			return
		pad.press(&"light_attack")
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
		elif _wait <= 0.0 and can_hold(game, ComboNode.In.CHARGE):
			pad.press(&"heavy_attack")
			_held = &"heavy_attack"
			_hold = LANCE_HOLD
			_wait = KITE_THROW
		return
	var out := away.normalized() if away.length() > 0.1 else Vector2.RIGHT
	pad.move = _steer(game, p, _escape(game, p, out))
	pad.press(&"dodge")  # held: the dodge, then the run


## C1d: where the boss's curse in flight is when it comes at the paladin from CURSE_CUT_FROM m or less (null: none to cut).
static func curse_aim(game: Game, p: Vector2) -> Variant:
	if game.boss == null or not game.boss.def.curse_cut:
		return null
	for s in game.projectiles.shots:
		if s.kind == Projectiles.Kind.CURSE and s.life > 0.0 and s.pos.distance_to(p) < CURSE_CUT_FROM and s.pos.distance_to(p) > 1.5 \
				and s.vel.dot(p - s.pos) > 0.0:
			return s.pos
	return null


const CURSE_CUT_FROM := 9.0


## True when an enemy that shoots (ARCHER, PRIEST: the mage, the archer, the priests, the Elder) readies a shot within
## SHOT_NEAR m: the robot does not plant itself in the attack's Omega then (C19, combat_cadence.md 8.3 (a): the Elder's
## fan hit it while it charged).
static func shot_coming(game: Game, p: Vector2) -> bool:
	for e in game.horde.list:
		if e.alive and e.state == Enemy.State.WINDUP and p.distance_to(e.pos) < SHOT_NEAR \
				and (e.def.behavior == EnemyDef.Behavior.ARCHER or e.def.behavior == EnemyDef.Behavior.PRIEST):
			return true
	return false


## Where the ranged threats are: enemies that shoot (ARCHER, CASTER, PRIEST) readying a shot beyond melee reach, and
## hostile shots flying at p. Generic: any shooter counts.
static func shooters(game: Game, p: Vector2) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for e in game.horde.list:
		if e.alive and e.state == Enemy.State.WINDUP and e.def.behavior in [EnemyDef.Behavior.ARCHER, EnemyDef.Behavior.PRIEST, EnemyDef.Behavior.CASTER] \
				and p.distance_to(e.pos) > REACH and p.distance_to(e.pos) < COVER_SIGHT:
			out.append(e.pos)
	for s in game.projectiles.shots:
		if (s.kind == Projectiles.Kind.ORB or s.kind == Projectiles.Kind.BOLT) and s.life > 0.0 and not s.seen.has(game.player) \
				and s.pos.distance_to(p) < 12.0 and s.vel.dot(p - s.pos) > 0.0:
			out.append(s.pos)
	return out


## The spot to stand at to keep a stone between him and the shooters (null: not hiding). Keeps the spell's clock.
func _cover(game: Game, p: Vector2, dt: float) -> Variant:
	if game.arena == null or game.arena.cover.is_empty() or cover_chance <= 0.0:
		return null
	var list := shooters(game, p)
	for e in game.horde.list:
		if e.alive and e.def.behavior not in [EnemyDef.Behavior.ARCHER, EnemyDef.Behavior.PRIEST, EnemyDef.Behavior.CASTER] and p.distance_to(e.pos) < COVER_CROWD:
			list.clear()
			_cover_on = 0.0
			break
	var seen_shooters: Array[Vector2] = []
	for e in game.horde.list:
		if e.alive and e.def.behavior in [EnemyDef.Behavior.ARCHER, EnemyDef.Behavior.PRIEST, EnemyDef.Behavior.CASTER] \
				and p.distance_to(e.pos) < COVER_SIGHT:
			seen_shooters.append(e.pos)
	for q in seen_shooters:
		if CoverPlan.hidden(q, p, game.arena.cover):
			cover_time += dt
			break
	_cover_off -= dt
	if _stuck > STUCK_TIME:
		_cover_lost = 2.0
	_cover_lost -= dt
	if list.is_empty():
		_cover_seen = 0.0
		if _cover_on > 0.0:
			_cover_on = maxf(0.0, _cover_on - dt) if _cover_on <= COVER_LINGER else COVER_LINGER
		_cover_pick = false
		if _cover_on <= 0.0:
			return null
	else:
		if _cover_seen <= 0.0:
			_cover_pick = _cover_off <= 0.0 and game.player.dodge_charges == 0 and _rng.randf() < cover_chance
		_cover_seen += dt
		if not _cover_pick or _cover_seen < reaction or _cover_lost > 0.0:
			return null
		if _cover_on <= 0.0:
			cover_spells += 1
		_cover_on = maxf(_cover_on, COVER_LINGER) + dt
		_cover_on = minf(_cover_on, COVER_MAX + COVER_LINGER)
		if _cover_seen > COVER_MAX * (2.0 if game.player.dodge_charges == 0 else 1.0):
			_cover_off = COVER_REST
			_cover_pick = false
			_cover_on = 0.0
			return null
	var from := list if not list.is_empty() else seen_shooters
	return CoverPlan.pick(p, from, game.arena.cover, COVER_NEAR, Player.RADIUS,
			func(q: Vector2) -> bool: return game.arena.resolve(q, Player.RADIUS).distance_to(q) < 0.05)


## The nearest enemy that can be hurt (behind his ritual's shield the boss waits: his dead come first).
## RP-16: the middle of a slab within SLIT_NEAR whose slit (HazardDef.aims) may arm now and whose band holds SLIT_PACK
## enemies or more and not him (null: none): he steps on it, as a player lures the pack into the band.
static func slit_plan(game: Game, p: Vector2) -> Variant:
	var pf: PlateFloor = game.rooms.plates if game.rooms else null
	if pf == null or not pf.hazard.awake or pf.hazard.calm > 0.0:
		return null
	var h := pf.hazard
	var def := h.def
	if h.busy() >= PlateHazard.MOST_AT_ONCE:
		return null
	for i in h.count():
		if not def.aims_away(i) or h.phase[i] != PlateHazard.Phase.IDLE or h.live[i] == 0:
			continue
		var c := h.from[i] + h.dirs[i] * h.lengths[i] * 0.5
		if p.distance_to(c) > SLIT_NEAR:
			continue
		var a := Vector2(def.aims[i].x, def.aims[i].y)
		var b := Vector2(def.aims[i].z, def.aims[i].w)
		if in_band(a, b, def.aim_width, p):
			continue
		var n := 0
		for e in game.horde.list:
			if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS and in_band(a, b, def.aim_width, e.pos):
				n += 1
		if n >= SLIT_PACK:
			return c
	return null


## Whether q lies in the band from a to b, `width` across.
static func in_band(a: Vector2, b: Vector2, width: float, q: Vector2) -> bool:
	var d := (b - a).normalized()
	var along := (q - a).dot(d)
	return along >= 0.0 and along <= a.distance_to(b) and absf((q - a).cross(d)) <= width * 0.5


## RP-09: a cracked column within COLUMN_NEAR that would fall on COLUMN_PACK enemies or more, struck from the other
## side: {"center", "way" (where it would fall, toward the pack), "stand" (where he swings from, COLUMN_REACH m back
## from it against the way)}, or null. The pack is counted along the way from each enemy near it (its band, as wide as
## a body touching it).
static func column_plan(game: Game, p: Vector2) -> Variant:
	var floor_ := game.rooms.columns if game.rooms else null
	if floor_ == null:
		return null
	var fall := floor_.fall
	var best: Variant = null
	var best_n := COLUMN_PACK - 1
	for i in fall.columns.size():
		if fall.stage[i] >= ColumnFall.Stage.LEANING:
			continue
		var o := fall.columns[i]
		if p.distance_to(o.center) > COLUMN_NEAR:
			continue
		for lead in game.horde.list:
			if not lead.alive or lead.def.behavior == EnemyDef.Behavior.BOSS:
				continue
			var off := lead.pos - o.center
			if off.length() < 0.5 or off.length() > o.fall_length:
				continue
			var way := off.normalized()
			var n := 0
			for e in game.horde.list:
				if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS:
					continue
				var q := e.pos - o.center
				var along := q.dot(way)
				if along >= 0.0 and along <= o.fall_length + e.def.radius and absf(q.cross(way)) <= o.fall_width * 0.5 + e.def.radius:
					n += 1
			if n > best_n:
				best_n = n
				best = {"center": o.center, "way": way, "stand": o.center - way * COLUMN_REACH}
	return best


## RP-14: a crystal of the Câmara das Runas B within CRYSTAL_NEAR whose column holds CRYSTAL_PACK enemies or more
## and that may take a charge now: {"center", "way" (toward the crystal), "stand" (to its side, out of the column, on
## his side of it, CRYSTAL_BACK m south)}, or null. He swings at it until it discharges.
static func crystal_plan(game: Game, p: Vector2) -> Variant:
	var rf: RuneFloor = game.rooms.runes if game.rooms else null
	if rf == null or rf.crystals == null or not rf.crystals.awake or rf.hazard.discharging() \
			or rf.hazard.phase == ArenaHazard.Phase.CALM:
		return null
	var def := rf.hazard.def
	var best: Variant = null
	var best_n := CRYSTAL_PACK - 1
	for i in rf.crystals.count():
		var c: Vector2 = rf.crystals.def.crystals[i]
		if p.distance_to(c) > CRYSTAL_NEAR:
			continue
		var x0 := def.origin.x + rf.crystals.col(i) * def.tile
		var n := 0
		for e in game.horde.list:
			if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS and e.pos.x >= x0 - e.def.radius and e.pos.x <= x0 + def.tile + e.def.radius:
				n += 1
		if n > best_n:
			best_n = n
			var side := -1.0 if p.x < c.x else 1.0
			var stand := game.arena.resolve(c + Vector2(side * CRYSTAL_SIDE, CRYSTAL_BACK), Player.RADIUS)
			best = {"center": c, "way": (c - stand).normalized(), "stand": stand}
	return best


## RP-12: an oil urn of the Crypt A within URN_NEAR, unlit and awake, with URN_PACK enemies or more in its ring:
## {"center", "way" (toward the urn), "stand" (URN_REACH m off it, away from the pack)}, or null.
static func urn_plan(game: Game, p: Vector2) -> Variant:
	var uf: UrnFloor = game.rooms.urns if game.rooms else null
	if uf == null or not uf.hazard.awake:
		return null
	var h := uf.hazard
	var best: Variant = null
	var best_n := URN_PACK - 1
	for i in h.count():
		if h.stage[i] != UrnHazard.Stage.IDLE:
			continue
		var c: Vector2 = h.def.urns[i]
		if p.distance_to(c) > URN_NEAR:
			continue
		var n := 0
		var pack := Vector2.ZERO
		for e in game.horde.list:
			if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS and e.pos.distance_to(c) <= h.def.urn_radius + e.def.radius:
				n += 1
				pack += e.pos - c
		if n > best_n:
			best_n = n
			var away := -pack.normalized() if pack.length() > 0.01 else (p - c).normalized()
			var stand := game.arena.resolve(c + away * URN_REACH, Player.RADIUS)
			best = {"center": c, "way": (c - stand).normalized(), "stand": stand}
	return best


func _nearest(game: Game) -> Vector2:
	var p := game.player.pos
	var best := p + Vector2(cos(_t * 0.5), sin(_t * 0.5)) * 6.0
	var best_d := INF
	for e in game.horde.list:
		var d := p.distance_squared_to(e.pos)
		if e.def.ward_count > 0 and d < WARDER_NEAR * WARDER_NEAR:
			d *= 0.25  # CB-0: the priest that armors the others first
		if e.alive and not e.invulnerable and d < best_d:
			best_d = d
			best = e.pos
	return best


## C5: how near the robot stands to a Varredor (inside its sweep_clear of 1.6 m), and the one standing at `at`, if any.
const SWEEPER_STAND := 1.1


func _sweeper_at(game: Game, at: Vector2) -> Enemy:
	for e in game.horde.list:
		if e.alive and e.def.behavior == EnemyDef.Behavior.SWEEP and e.pos.distance_to(at) < 0.1:
			return e
	return null


## How far the robot goes for a priest before whoever is nearer.
const WARDER_NEAR := 10.0


## The enemy standing at `at` blocks him from the front now.
## C1b: the enemy at `at` is a common whose poise the blows have worn to half or less (and is not broken yet).
static func _worn(game: Game, at: Vector2) -> bool:
	for e in game.horde.list:
		if e.alive and e.def.poise > 0.0 and e.pos.distance_to(at) < 0.1:
			return e.broken_t <= 0.0 and e.poise <= e.def.poise * WORN
	return false


static func _guarded(game: Game, at: Vector2) -> bool:
	for e in game.horde.list:
		if e.alive and e.def.front_block > 0.0 and e.pos.distance_to(at) < 0.1 and game.horde.blocks_front(e, game.player.pos):
			return true
	return false


## C1e, lote B: the way out of the square a Saltador is about to land on (it marks it through its wind-up and its flight): straight away
## from the spot's middle, zero when `p` is clear of every square or the jump is not yet in its last LEAP_SEEN seconds.
const LEAP_SEEN := 0.55


static func leap_escape(list: Array[Enemy], p: Vector2) -> Vector2:
	for e in list:
		if not e.alive or e.def.behavior != EnemyDef.Behavior.LEAP:
			continue
		var left := e.def.attack_windup - e.state_t if e.state == Enemy.State.WINDUP else e.def.leap_time - e.state_t if e.state == Enemy.State.ATTACK else INF
		if left > LEAP_SEEN + (e.def.leap_time if e.state == Enemy.State.WINDUP else 0.0):
			continue
		if LeapRules.in_area(e.lands_at, p, e.def.leap_half, 0.9):
			var off := p - e.lands_at
			return off.normalized() if off.length() > 0.1 else Vector2.RIGHT
	return Vector2.ZERO


## The knight's shield in the air (Daniel, 2026-11-23): the way out of the square it lands on, in its last SHIELD_SEEN seconds.
const SHIELD_SEEN := 0.6


static func shield_escape(shields: Array[Horde.Shield], p: Vector2) -> Vector2:
	for sh in shields:
		if sh.total - sh.t <= SHIELD_SEEN and LeapRules.in_area(sh.land, p, sh.owner.def.throw_half, 0.9):
			var off := p - sh.land
			return off.normalized() if off.length() > 0.1 else Vector2.RIGHT
	return Vector2.ZERO


## The shield wave: the dodge is the only way through. It dashes when the band is RING_LEAD seconds from touching it, once a wave,
## with a RING_SKILL chance (a person misses the moment now and then), toward the wave's middle so it crosses the band.
const RING_LEAD := 0.09
const RING_SKILL := 0.75
var _ring_seen := {}


func ring_dash(game: Game, p: Vector2) -> Variant:
	if game.horde.waves.is_empty():
		_ring_seen.clear()
	for w in game.horde.waves:
		var id := w.get_instance_id()
		if _ring_seen.has(id):
			continue
		var d := w.owner.def
		var gap := p.distance_to(w.center) - ShockRing.radius_at(w.t, Horde.WAVE_START, d.ring_speed, d.ring_delay) - d.ring_thick * 0.5 - Player.RADIUS * 0.6
		if gap < -d.ring_thick:
			continue  # already past it
		var eta := maxf(0.0, d.ring_delay - w.t) + maxf(gap, 0.0) / d.ring_speed
		if eta <= RING_LEAD:
			_ring_seen[id] = true
			if _rng.randf() < RING_SKILL and game.player.dodge_charges > 0 and game.player.state != Player.State.DODGE:
				return (w.center - p).normalized() if p.distance_to(w.center) > 0.1 else Vector2.RIGHT
	return null


## Direction out of the enemy warning the paladin is standing on (zero when safe). Bolts nearby count too.
func _danger(game: Game) -> Vector2:
	var p := game.player.pos
	var leap := leap_escape(game.horde.list, p)
	if leap != Vector2.ZERO:
		return leap
	var shield := shield_escape(game.horde.shields, p)
	if shield != Vector2.ZERO:
		return shield
	for z in game.ground.zones:
		if z.kind != Ground.Kind.WARNING or z.life > 0.55 or z.tags.has(Horde.FAN_TAG):
			continue  # (C19-5: a fan's threads only show where its orbs leave; it dodges the orbs below)
		if not Ground.inside(z, p, 0.9):
			continue
		if z.tags.has(Horde.SWEEP_TAG):
			# C5, the Varredor's bar: at its feet nothing hurts; elsewhere he leaves it by its length, in to the pocket or out
			# past its tip, never across it (it comes round faster than he walks)
			var d: EnemyDef = game.horde.def(z.by)
			var off := p - z.pos
			if off.length() <= d.sweep_clear - 0.3:
				continue
			return -off.normalized() if off.length() < d.attack_range * 0.55 else off.normalized()
		if z.tags.has(Horde.BEAM_TAG) and z.by != &"" and (p - z.pos).length() <= game.horde.def(z.by).sweep_clear + 0.3:
			continue  # C1e lote C: at the Canalizador's feet its beam does not hurt (the robot goes in to strike it)
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
		if z.kind == Ground.Kind.WARNING and z.rune != Ground.Rune.SUMMON and z.life <= ESCAPE_AHEAD and not z.tags.has(Horde.FAN_TAG) \
				and Ground.inside(z, q, 0.6):
			return true
	for shot in game.projectiles.shots:
		if shot.kind != Projectiles.Kind.SOUL or shot.seen.has(game.player):
			continue
		var to := q - shot.pos
		var ahead := shot.vel.normalized()
		if to.dot(ahead) > -0.5 and to.dot(ahead) < 6.0 and absf(to.cross(ahead)) < shot.half_width + 0.9:
			return true
	return false


## The way toward a goal (cycle C12): straight while the floor between is clear, else along its own FlowField round
## holes and obstacles (made again for each arena).
func _way(game: Game, from: Vector2, goal: Vector2, dt: float) -> Vector2:
	var straight := (goal - from).normalized()
	var nav := game.arena.nav_dash
	if nav == null or nav.clear_line(from, goal):
		return straight
	if _field == null or _field.grid != nav:
		_field = FlowField.new(nav)
	_field.aim(goal, dt)
	var w := _field.next_step(from)
	return w if w != Vector2.ZERO else straight


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
