class_name Horde
extends Node3D
## All enemies in one loop: no physics bodies, a spatial hash keeps them apart, CrowdRenderer draws them from baked
## poses. Every enemy attack is announced (a swing windup, a warning on the floor) before it can hurt.

signal killed(e: Enemy)
signal hit_player(amount: float, from: Vector2)
## An enemy's armor (yellow bar) just broke.
signal armor_broken(e: Enemy)

const CELL := 1.5
const KNOCKBACK_DECAY := 7.0
const FLASH_TIME := 0.14
## Flash of an ordinary blow (a strong one flashes at 1, so its first frame or two are pure white: crowd.gdshader).
const WEAK_FLASH := 0.45
## A boss's strongest flash (art review P4: a strong frost blow sent Morvath's dark robe to the pale ivory of the
## first frame for one frame, crowd.gdshader's white_from 0.85): his body only gets lighter and warmer, never ivory.
const BOSS_FLASH := 0.8
## Numbers of blows that land on armor.
const ARMOR_COLOR := Color(1.0, 0.82, 0.3)
## Seconds the fan of a crossbowman's volley shows (in its EnemyDef.magic_color).
const VOLLEY_TIME := 0.22
## A killing blow throws light bodies: base speed away, upward speed, gravity.
const THROW := 7.0
const THROW_UP := 6.0
const GRAVITY := 24.0
const BURN_TICK := 0.5
const HURT_TIME := 0.3
## A heavy body does not reel: only the first jolt of its hit pose shows, this long.
const HEAVY_HURT := 0.12
## How much of the squash of a blow a heavy body takes.
const HEAVY_SQUASH := 0.4
## Only drawn (EnemyDef.sway, windup_shake): the unsteady runner's trunk sways this many times a second as it
## runs, and it trembles this fast while it winds up; its stride is uneven by this share.
const SWAY_HZ := 9.0
const SHAKE_HZ := 14.0
const UNEVEN_STEP := 0.12
const DEATH_SHOW := 1.5
const DISSOLVE_FROM := 0.85
const MAX_DYING := 90
const DEFS_DIR := "res://data/enemies/"
## Share of an attack clip at which the blow lands (the windup is stretched to end there).
const IMPACT_SHARE := 0.55
const MELEE_COOLDOWN := 1.3
## Skeletons the elder priest raises around itself in one cast (fewer when the fight is full: room_for).
const PRIEST_RAISES := 3
## Ranged enemies: the last seconds of a wind-up in which the aim no longer follows the paladin (his sidestep is
## the answer), how far past its reach a shot flies, how far ahead it looks for floor when it runs, and how close
## (a part of keep_away) the paladin must be for it to keep running instead of stopping to shoot.
const RANGED_LOCK := 0.25
const RANGED_REACH := 1.5
const RANGED_LOOK := 2.0
const RANGED_SHOOT_WHILE_RUNNING := 0.75
## Each tick of a burst pushes the shooter back a little less (Hades: FireTickSelfVelocityConsecutiveMultiplier).
const RANGED_RECOIL_FADE := 0.95
## How far a ranged enemy looks for a pillar to wait behind.
const RANGED_COVER_FIND := 10.0
## A shot creeping on the floor (the vines): flat and long.
const LOW_SHOT_SCALE := Vector3(1.2, 0.45, 1.8)
## Ways round what blocks (cycle C12): the way along the arena's FlowField is looked up again every WAY_EVERY seconds
## (straight while the floor between is clear: the open hall walks as before); closer than WAY_NEAR it walks straight.
const WAY_EVERY := 0.12
const WAY_NEAR := 1.2
## A shooter only winds up with a clear line of fire (Arena.clear_shot, a shot this round) and with its body inside
## this share of the screen (never shooting from off it: VIEW_EDGE to 1 - VIEW_EDGE), else it walks until it is.
const LINE_OF_FIRE := 0.3
const VIEW_EDGE := 0.05
## An enemy that wants to come closer and has not moved STUCK_MOVE meters in STUCK_TIME seconds is stuck (RESULT
## stuck; it should never happen).
const STUCK_TIME := 3.0
const STUCK_MOVE := 0.5

var list: Array[Enemy] = []
var dying: Array[Enemy] = []
var arena: Arena
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var renderer: CrowdRenderer
## The lights of the wind-ups and of the armor (never red: the warnings on the floor are Ground's).
var tells: EnemyFx
var hp_scale := 1.0
## Summons never raise anyone past this many standing (EncounterGen.Fight.ceiling, set by Rooms for each fight;
## 0: no ceiling, the endless hall --horde).
var alive_cap := 0
var damage_scale := 1.0
var target := Vector2.ZERO
var target_alive := true
## The kind (EnemyDef.id) acting now, while the crowd steps (&"" outside it): the warnings and shots it lays carry it
## (Ground.Zone.by, Projectiles.Shot.by), so the game knows what hurt the paladin ("Derrotado por").
var acting: StringName = &""
## Where the kind acting now stands (Vector2.INF outside the crowd's step): its warnings know if it was on the screen.
var acting_pos := Vector2.INF
## The kind whose blow hurt the paladin last (its own swing, no warning in between), read as hit_player is emitted.
var last_by: StringName = &""
## That blow's warning (the seconds its swing was raised) and whether it came from off the screen (1), on it (0) or
## unknown (-1), for the run's log (RoomTally.hurt_context; GP-02).
var last_warn := -1.0
var last_offscreen := -1
## Where a floor point shows on the screen (0 to 1; Game sets it from its camera; unset: everywhere is seen).
var view := Callable()
## Enemies that got stuck this run, by kind (RESULT stuck; Bot.stats).
var stuck_by := {}
## The way the enemy behaving now walks toward the paladin (_way).
var _walk := Vector2.ZERO
var _dt := 0.0
var _hash := SpatialHash.new(CELL)
## The widest body filed in the hash (rehash), and the bodies stop_walker last looked at (kept, not reallocated).
var _widest := 0.0
var _centers := PackedVector2Array()
var _reaches := PackedFloat32Array()
var _allowed := PackedFloat32Array()
var _defs: Dictionary = {}
var _frame := 0
var _rng := RandomNumberGenerator.new()
## How many were ever spawned: each takes a number of its own for what is only drawn (Enemy.look).
var _born := 0


func _ready() -> void:
	Dev.seed_rng(_rng, 5)
	renderer = CrowdRenderer.new()
	renderer.layers = Arena.CROWD_LAYER
	add_child(renderer)
	tells = EnemyFx.new()
	tells.layers = Arena.CROWD_LAYER
	add_child(tells)


func def(id: StringName) -> EnemyDef:
	if not _defs.has(id):
		var d: EnemyDef = load(DEFS_DIR + id + ".tres")
		_defs[id] = d
		renderer.register(d)
	return _defs[id]


func spawn(d: EnemyDef, at: Vector2, rising: bool = true) -> Enemy:
	def(d.id)
	var e := Enemy.new()
	e.def = d
	e.pos = at
	var scaled := not d.elite and d.behavior != EnemyDef.Behavior.BOSS
	e.max_hp = d.hp * (hp_scale if scaled else 1.0)
	e.hp = e.max_hp
	e.max_armor = d.armor
	e.armor = d.armor
	e.cooldown = d.attack_cooldown * _rng.randf_range(0.4, 1.0)
	e.side = 1.0 if _rng.randf() < 0.5 else -1.0
	e.dir = (target - at).normalized() if target.distance_to(at) > 0.1 else Vector2.DOWN
	_born += 1
	e.look = fposmod(_born * 0.618034, 1.0)
	if rising:
		e.state = Enemy.State.RISE
		e.anim = &"rise"
	list.append(e)
	return e


func count() -> int:
	return list.size()


## How many of `want` summoned enemies may still rise under alive_cap (fewer, or none).
func room_for(want: int) -> int:
	return want if alive_cap <= 0 else EncounterGen.room_for(list.size(), alive_cap, want)


func step(dt: float) -> void:
	_frame += 1
	_dt = dt
	rehash()
	if arena != null and arena.flow != null and not list.is_empty():
		# the shared way to the paladin, made again as he moves (at most 4 times a second, spread over frames)
		arena.flow.aim(target, dt)
	var i := 0
	for e in list:
		var reach := e.def.radius + Player.RADIUS
		e.was_in_target = depth_in_target(e) if e.pos.distance_squared_to(target) < reach * reach else 0.0
		e.last_pos = e.pos
	for e in list:
		i += 1
		_timers(e, dt)
		if e.alive and not e.helpless():
			acting = e.def.id
			acting_pos = e.pos
			_behave(e, dt)
			acting = &""
			acting_pos = Vector2.INF
			_watch_stuck(e, dt)
		if (i + _frame) % 2 == 0:
			_separate(e)
		if e.push.length_squared() > 0.01:
			e.pos += e.push * dt
			e.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * dt)
	# after everyone moved and was kept apart (so the crowd's shoving cannot leave anyone inside him): nobody walks
	# into the paladin, nor is pressed into him by the others (a lunge in flight goes through him)
	for e in list:
		var reach := e.def.radius + Player.RADIUS
		if e.state != Enemy.State.ATTACK and e.pos.distance_squared_to(target) < reach * reach:
			keep_off_target(e, e.was_in_target, dt)
		# swept from where it stood: a push or a lunge stops at the abyss's edge, never across a hole (D-28)
		e.pos = arena.sweep(e.last_pos, e.pos, e.def.radius)
		e.y = e.height()
	_sweep()
	for d in dying:
		d.dead_t += dt
		if d.push.length_squared() > 0.01:
			d.pos = arena.sweep(d.pos, d.pos + d.push * dt, d.def.radius)
			d.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * 0.6 * dt)
		if d.vy != 0.0 or d.y > 0.0:
			d.y += d.vy * dt
			d.vy -= GRAVITY * dt
			if d.y <= 0.0:
				d.y = 0.0
				d.vy = -d.vy * 0.3 if d.vy < -4.0 else 0.0


func _timers(e: Enemy, dt: float) -> void:
	e.state_t += dt
	e.cooldown -= dt
	e.flash_t -= dt
	e.hurt_t -= dt
	e.stun_t = maxf(0.0, e.stun_t - dt)
	e.air_t = maxf(0.0, e.air_t - dt)
	e.blind_t = maxf(0.0, e.blind_t - dt)
	e.slow_t = maxf(0.0, e.slow_t - dt)
	if e.frozen_t > 0.0:
		e.frozen_t = maxf(0.0, e.frozen_t - dt)
	else:
		e.anim_t += dt
	if e.burn_t > 0.0:
		e.burn_t -= dt
		e.burn_tick -= dt
		if e.burn_tick <= 0.0:
			e.burn_tick = BURN_TICK
			# a tick of fire is no blow: the embers on the body show it (M-1: a flash every tick, on top of the
			# blows' own, kept a burning boss lit nearly white)
			damage(e, e.burn_dps * BURN_TICK, Vector2.ZERO, 0.0, Color(1.0, 0.5, 0.2), true, false, false)
	if e.state == Enemy.State.RISE and e.state_t > 0.9:
		_set_state(e, Enemy.State.WALK, &"walk")


## How fast a walking enemy's clips play (its pace; a boss posing a clip divides by it: Boss._pose).
func clip_rate(e: Enemy) -> float:
	return clampf(_speed(e) / 2.3, 0.6, 1.6)


func _speed(e: Enemy) -> float:
	return e.def.speed * (0.45 if e.slow_t > 0.0 else 1.0)


func _behave(e: Enemy, dt: float) -> void:
	var to := target - e.pos
	var dist := to.length()
	var toward := to / dist if dist > 0.01 else Vector2.DOWN
	if e.blind_t > 0.0:
		# blinded by steam: stumbles sideways, attacks nothing
		e.pos += toward.rotated(e.side * 1.4) * _speed(e) * 0.5 * dt
		return
	_walk = _way(e, toward, dist)
	match e.def.behavior:
		EnemyDef.Behavior.CHASE:
			_behave_melee(e, dt, toward, dist)
		EnemyDef.Behavior.ARCHER:
			_behave_ranged(e, dt, toward, dist, false)
		EnemyDef.Behavior.CASTER:
			_behave_ranged(e, dt, toward, dist, true)
		EnemyDef.Behavior.RUNNER:
			_behave_runner(e, dt, toward, dist)
		EnemyDef.Behavior.KNIGHT:
			_behave_knight(e, dt, toward, dist)
		EnemyDef.Behavior.PRIEST:
			_behave_priest(e, dt, toward, dist)
		EnemyDef.Behavior.PULSE:
			_behave_pulse(e, dt, toward, dist)
		EnemyDef.Behavior.CONE:
			_behave_cone(e, dt, toward, dist)


## Walks up, raises the blade (the warning) and swings. Only the swing hurts, and only if the paladin is still close.
func _behave_melee(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var reach := e.def.radius + Player.RADIUS + 0.7 * e.def.size
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= _windup(e):
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				if target_alive and dist < reach + 0.5:
					last_by = e.def.id
					last_warn = e.state_t
					last_offscreen = screen_flag(e.pos)
					hit_player.emit(e.def.damage * damage_scale, e.pos)
		Enemy.State.ATTACK:
			if e.state_t >= 0.35:
				e.cooldown = MELEE_COOLDOWN * _rng.randf_range(0.8, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = e.dir.slerp(_walk if dist > reach else toward, minf(1.0, dt * 8.0))
			if dist > reach * 0.8:
				e.pos += _walk * _speed(e) * dt
			if dist < reach and e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"attack")


func _windup(e: Enemy) -> float:
	return e.def.attack_windup if e.def.behavior != EnemyDef.Behavior.CHASE else 0.5


## Keeps to the far end of its reach: walks in only while out of reach, runs from the paladin once he is closer than
## keep_away of it (around the walls, never into them; cornered it shoots from close) and shoots from there (Daniel,
## 2026-11-16). With Hades II's numbers (study of 2026-11-16): a burst of shot_ticks, each pushing it back (the
## mage); between attacks behind the nearest pillar (cover_hug, HideAndPeekAI); after an attack it runs retreat_far
## for retreat_time (the crossbowman); at most max_attackers of its kind at once. A caster (CASTER) conjures a circle
## under him instead (no enemy uses it now: circles on the floor are Morvath's).
func _behave_ranged(e: Enemy, dt: float, toward: Vector2, dist: float, caster: bool) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		# it follows him until the last moment, unless its aim is marked on the floor (then it is locked there)
		if not d.shot_line and e.state_t < d.attack_windup - RANGED_LOCK:
			e.aim = toward
		e.dir = e.aim
		if e.state_t >= d.attack_windup:
			if caster:
				ground.add_warning(target, 2.3, 1.1, d.attack_damage * damage_scale, d.magic_color)
			e.memo = 0
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		var ticks := 0 if caster else maxi(1, d.shot_ticks)
		while e.memo < ticks and e.state_t >= e.memo * d.shot_interval:
			if e.memo > 0 and not d.shot_line:
				e.aim = toward
			shoot(e, e.aim)
			if d.recoil > 0.0:
				e.push = -e.aim * d.recoil * pow(RANGED_RECOIL_FADE, e.memo)
			e.memo += 1
		if e.state_t >= maxi(0, ticks - 1) * d.shot_interval + 0.4:
			e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
			if d.retreat_far > 0.0:
				e.retreat_t = _rng.randf_range(d.retreat_time.x, d.retreat_time.y)
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	var sp := _speed(e)
	if sp <= 0.0:
		pass
	elif e.retreat_t > 0.0:
		# after its attack it gets away from him (Hades: RetreatAfterAttack), then comes back to its reach
		e.retreat_t -= dt
		if dist < d.retreat_far:
			var away := flee_dir(e.pos, -toward, d.radius, e.side)
			e.pos += away * sp * dt
			if away != Vector2.ZERO:
				e.dir = away
		return
	var near := dist < d.attack_range * d.keep_away
	var cornered := false
	var cover: Variant = cover_spot(e.pos, d.cover_hug) if d.cover_hug > 0.0 and e.cooldown > 0.0 and not near else null
	if sp <= 0.0:
		pass
	elif cover != null:
		# waiting for its next attack behind a pillar, out of his way
		var to_cover: Vector2 = (cover as Vector2) - e.pos
		if to_cover.length() > 0.3:
			e.pos += to_cover.normalized() * minf(sp * dt, to_cover.length())
			e.dir = to_cover.normalized()
	elif dist > d.attack_range or (e.cooldown <= 0.0 and not _can_fire(e)):
		# out of reach, or ready with no line of fire or off the screen: it walks the way to him until it has one
		e.pos += _walk * sp * dt
		e.dir = _walk
	elif near:
		var away := flee_dir(e.pos, -toward, d.radius, e.side)
		cornered = away == Vector2.ZERO
		e.pos += away * sp * dt
		if not cornered:
			e.dir = away
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * sp * 0.35 * dt
	var running := sp > 0.0 and dist < d.attack_range * d.keep_away * RANGED_SHOOT_WHILE_RUNNING and not cornered
	if e.cooldown <= 0.0 and dist < d.attack_range + 2.0 and not running and target_alive and arena.inside(e.pos, 1.0) \
			and (d.max_attackers <= 0 or attackers(d) < d.max_attackers) and _can_fire(e):
		e.aim = toward
		e.dir = toward
		_set_state(e, Enemy.State.WINDUP, &"cast" if caster or d.shot_orb else &"aim")
		if d.shot_line and not caster:
			# the line on the floor ends where the bolt will die on cover
			ground.add_line_warning(e.pos, toward, arena.shot_reach(e.pos, toward, d.attack_range * RANGED_REACH, Projectiles.SHOT_EDGE), 0.5,
				d.attack_windup, 0.0)


## How many of this kind (the common one and its elite count together) are winding up or shooting now.
func attackers(d: EnemyDef) -> int:
	var n := 0
	for o in list:
		if o.alive and o.def.name_key == d.name_key and (o.state == Enemy.State.WINDUP or o.state == Enemy.State.ATTACK):
			n += 1
	return n


## Where to wait behind the pillar nearest to `from` (within RANGED_COVER_FIND): `hug` meters past its middle on
## the side away from the paladin, on the floor. null: no pillar near, or no floor behind it.
func cover_spot(from: Vector2, hug: float) -> Variant:
	var best: Variant = null
	var best_d := RANGED_COVER_FIND
	for p in arena.pillars:
		var c := Vector2(p.x, p.y)
		var dd := c.distance_to(from)
		if dd >= best_d:
			continue
		var away := c - target
		if away.length_squared() < 0.01:
			continue
		var spot := c + away.normalized() * maxf(hug, p.z + 0.8)
		if arena.inside(spot, 0.8):
			best = arena.resolve(spot, 0.6)
			best_d = dd
	return best


## Its shots (EnemyDef.shot_*): a fan of shot_count around dir.
func shoot(e: Enemy, dir: Vector2) -> void:
	var d := e.def
	var n := maxi(1, d.shot_count)
	var reach := d.shot_range if d.shot_range > 0.0 else d.attack_range * RANGED_REACH
	var life := reach / maxf(0.1, d.shot_speed)
	for i in n:
		var turn := 0.0 if n == 1 else deg_to_rad(d.shot_spread) * (float(i) / float(n - 1) - 0.5)
		var aim := dir.rotated(turn)
		var s := projectiles.fire(Projectiles.Kind.ORB if d.shot_orb else Projectiles.Kind.BOLT, e.pos + aim * (d.radius + 0.2), aim,
			d.shot_speed, d.attack_damage * damage_scale, 0.45 if d.shot_orb else 0.4, life, d.magic_color)
		# its warning so far: the aim it held (a shot of a burst, the time since the burst began too)
		s.warned = e.state_t + (d.attack_windup if e.state == Enemy.State.ATTACK else 0.0)
		if d.shot_turn > 0.0:
			s.turn = deg_to_rad(d.shot_turn)
			s.turn_decay = deg_to_rad(d.shot_turn_decay)
			s.homing = life
		if d.shot_low:
			s.low = true
			s.node.scale = LOW_SHOT_SCALE


## Where a ranged enemy runs to get away from the paladin: straight away, else turned along the wall (its own side
## first), never off the floor. ZERO: cornered, nowhere to go.
func flee_dir(from: Vector2, away: Vector2, radius: float, side: float) -> Vector2:
	for deg: float in [0.0, 35.0, -35.0, 70.0, -70.0, 105.0, -105.0]:
		var dir := away.rotated(deg_to_rad(deg) * (side if side != 0.0 else 1.0))
		if arena.inside(from + dir * RANGED_LOOK, radius + 0.3) and arena.free_at(from + dir * RANGED_LOOK, radius):
			return dir
	return Vector2.ZERO


## Runs in, stops, marks a line on the floor and lunges along it.
func _behave_runner(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			e.pos += e.aim * d.lunge_speed * dt
			if e.state_t >= d.lunge_time:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.8, 1.3)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range or not e.straight:
				e.pos += _walk * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive:
				e.aim = toward
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"windup")
				ground.add_line_warning(e.pos, toward, d.lunge_speed * d.lunge_time + d.radius + 1.0, 1.3, d.attack_windup + d.lunge_time * 0.5, d.attack_damage * damage_scale)
			else:
				var circle := (toward.rotated(e.side * PI * 0.5) + toward * (0.3 if dist > d.attack_range * 0.6 else -0.5)).normalized()
				e.pos += circle * _speed(e) * 0.8 * dt


## Elite: walks the paladin down, then marks a long line and charges along it.
func _behave_knight(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				fx.shake(1.5)
		Enemy.State.ATTACK:
			if e.memo == 1:
				# the close slam: stands still while it lands
				if e.state_t >= 0.5:
					e.memo = 0
					e.cooldown = d.attack_cooldown * 0.6
					_set_state(e, Enemy.State.WALK, &"walk")
				return
			e.pos += e.aim * d.lunge_speed * dt
			if _frame % 3 == 0:
				fx.burst(&"dust", Vector3(e.pos.x, 0.2, e.pos.y), Vector3(-e.aim.x, 0, -e.aim.y))
			if e.state_t >= d.lunge_time:
				e.cooldown = d.attack_cooldown
				e.stun_t = 0.8
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			_behave_melee_walk(e, dt, toward, dist)
			if d.close_damage > 0.0 and e.cooldown <= 0.0 and dist < d.close_range and target_alive:
				e.memo = 1
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"attack")
				ground.add_arc_warning(e.pos, toward, d.close_range + 0.8, 120.0, d.close_windup, d.close_damage * damage_scale)
				e.state_t = d.attack_windup - d.close_windup
				return
			if e.cooldown <= 0.0 and dist < d.attack_range and dist > d.close_range and target_alive and e.straight:
				e.aim = toward
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"idle")
				ground.add_line_warning(e.pos, toward, d.lunge_speed * d.lunge_time + d.radius, 2.4, d.attack_windup, d.attack_damage * damage_scale)


## Between charges the knight still swings at whoever is close.
func _behave_melee_walk(e: Enemy, dt: float, _toward: Vector2, dist: float) -> void:
	e.dir = e.dir.slerp(_walk, minf(1.0, dt * 6.0))
	if dist > e.def.radius + Player.RADIUS + 0.5:
		e.pos += _walk * _speed(e) * dt


## Where the k-th skeleton an elder raises from `from` stands: on a ring of 3.5 m, on the floor and out of stone.
func raise_spot(from: Vector2, k: int) -> Vector2:
	return arena.resolve(from + Vector2.from_angle(TAU * k / PRIEST_RAISES) * 3.5, 0.5)


## Elite: stays back, raises skeletons around itself and shoots a fan of orbs.
func _behave_priest(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		if e.state_t >= d.attack_windup:
			e.memo += 1
			# every other cast raises skeletons, as many as the fight has room for (none: it conjures circles)
			var raised := room_for(PRIEST_RAISES) if e.memo % 2 == 1 else 0
			if raised > 0:
				var skeleton := def(&"skeleton")
				for k in raised:
					var at := raise_spot(e.pos, k)
					spawn(skeleton, at, true)
					fx.burst(&"shadow", Vector3(at.x, 0.3, at.y))
				Audio.play(&"summon")
			else:
				# the circles on the floor are Morvath's alone (Daniel, 2026-11-16): a fan of orbs
				shoot(e, toward)
			e.cooldown = d.attack_cooldown
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		if e.state_t >= 0.5:
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	if dist > d.attack_range or not _can_fire(e):
		e.pos += _walk * _speed(e) * dt
	elif dist < d.attack_range * 0.6:
		e.pos -= toward * _speed(e) * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt
	if e.cooldown <= 0.0 and target_alive and _can_fire(e):
		_set_state(e, Enemy.State.WINDUP, &"cast")


## Runs in close, stops, glows (the warning ring) and bursts all around itself.
func _behave_pulse(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			if e.state_t >= 0.4:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range:
				e.pos += _walk * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"windup")
				ground.add_warning(e.pos, d.attack_width, d.attack_windup, d.attack_damage * damage_scale, d.magic_color)
			else:
				e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt


## Comes to mid range, plants itself and blasts a wide cone ahead.
func _behave_cone(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				if d.magic_color.a > 0.0:
					# the fan of bolts flying out over the cone that was marked
					fx.slash(e.pos, e.aim, d.attack_range + 0.5, d.attack_width, d.magic_color, VOLLEY_TIME, false, 0.9, false)
		Enemy.State.ATTACK:
			if e.state_t >= 0.5:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range * 0.8:
				e.pos += _walk * _speed(e) * dt
			if dist < d.attack_range and e.cooldown <= 0.0 and target_alive:
				e.aim = toward
				_set_state(e, Enemy.State.WINDUP, &"aim")
				ground.add_arc_warning(e.pos, toward, d.attack_range + 0.5, d.attack_width, d.attack_windup, d.attack_damage * damage_scale)


## The way to walk toward the paladin (cycle C12): straight while the floor between is clear (or he is near), else
## along the arena's FlowField round what blocks; kept WAY_EVERY seconds. Enemy.straight says which it is.
func _way(e: Enemy, toward: Vector2, dist: float) -> Vector2:
	if arena == null or arena.flow == null:
		e.straight = true
		return toward
	e.way_t -= _dt
	if e.way_t <= 0.0:
		e.way_t = WAY_EVERY * (0.75 + 0.5 * e.look)
		e.straight = dist < WAY_NEAR or arena.nav.clear_line(e.pos, target)
		if not e.straight:
			e.way = arena.flow.next_step(e.pos)
			if e.way == Vector2.ZERO:
				e.straight = true
	return toward if e.straight else e.way


## A shooter may wind up: a clear line of fire to the paladin and its body on the screen (VIEW_EDGE).
func _can_fire(e: Enemy) -> bool:
	if not arena.clear_shot(e.pos, target, LINE_OF_FIRE):
		return false
	return on_screen(e.pos)


## True when a body at p shows on the screen, VIEW_EDGE inside its edges (always, without a view).
func on_screen(p: Vector2) -> bool:
	if not view.is_valid():
		return true
	var s: Vector2 = view.call(p)
	return s.x >= VIEW_EDGE and s.x <= 1.0 - VIEW_EDGE and s.y >= VIEW_EDGE and s.y <= 1.0 - VIEW_EDGE


## For the run's log: 1 when a body at p is off the screen, 0 on it, -1 unknown (no view, or p is Vector2.INF).
func screen_flag(p: Vector2) -> int:
	if not view.is_valid() or not p.is_finite():
		return -1
	return 0 if on_screen(p) else 1


## Counts an enemy that wants to come closer and has not moved for STUCK_TIME seconds (once each).
func _watch_stuck(e: Enemy, dt: float) -> void:
	if e.pos.distance_squared_to(e.anchor) > STUCK_MOVE * STUCK_MOVE:
		e.anchor = e.pos
		e.anchor_t = 0.0
		return
	# a shooter waiting out its cooldown behind cover is not stuck; Morvath stands where Boss puts him
	var waiting := (e.def.behavior == EnemyDef.Behavior.ARCHER and e.cooldown > 0.0) or e.def.behavior == EnemyDef.Behavior.BOSS
	var wants := e.state == Enemy.State.WALK and _speed(e) > 0.0 and e.retreat_t <= 0.0 and not waiting \
		and e.pos.distance_to(target) > e.def.attack_range + e.def.radius + 2.0 and target_alive
	if not wants:
		e.anchor_t = 0.0
		return
	e.anchor_t += dt
	if e.anchor_t >= STUCK_TIME and not e.stuck:
		e.stuck = true
		stuck_by[String(e.def.id)] = int(stuck_by.get(String(e.def.id), 0)) + 1


## How many got stuck this run.
func stuck_count() -> int:
	var n := 0
	for k in stuck_by:
		n += int(stuck_by[k])
	return n


func _set_state(e: Enemy, state: Enemy.State, anim: StringName, restart: bool = true) -> void:
	e.state = state
	e.state_t = 0.0
	if e.anim != anim or restart:
		e.anim = anim
		e.anim_t = 0.0


func _separate(e: Enemy) -> void:
	var cx := int(floor(e.pos.x / CELL - 0.5))
	var cy := int(floor(e.pos.y / CELL - 0.5))
	for oy in 2:
		for ox in 2:
			for other: Enemy in _hash.at_cell(cx + ox, cy + oy):
				if other == e:
					continue
				var d := e.pos - other.pos
				var min_d := e.def.radius + other.def.radius
				var len_sq := d.length_squared()
				if len_sq < min_d * min_d and len_sq > 0.0001:
					var len := sqrt(len_sq)
					var shove := d / len * (min_d - len) * 0.5
					if not e.def.heavy or other.def.heavy:
						e.pos += shove
					if not other.def.heavy or e.def.heavy:
						other.pos -= shove


## Files every enemy in the spatial hash under where it stands now (Horde.step does it each frame; between two
## steps the hash is a frame old, which bodies_near allows for).
func rehash() -> void:
	_hash.clear()
	_widest = 0.0
	for e in list:
		_hash.insert(e.pos, e)
		_widest = maxf(_widest, e.def.radius)


## Whether an enemy's body stops the paladin and is stopped by him (alive, and a solid kind: EnemyDef.blocks_body).
static func blocks(e: Enemy) -> bool:
	return e.alive and e.def.blocks_body


## How deep an enemy stands in the paladin's body (0: apart, or a kind he walks through).
func depth_in_target(e: Enemy) -> float:
	if not blocks(e):
		return 0.0
	return maxf(0.0, BodyBlock.depth(e.pos, target, e.def.radius + Player.RADIUS))


## An enemy that moved stops at the paladin's edge, never pushing him; one that was already inside him (a dash or a
## lunge ended there) works its way out, at most as deep as it was (`was`) less BodyBlock.EASE a second.
func keep_off_target(e: Enemy, was: float, dt: float) -> void:
	if not blocks(e):
		return
	var keep := e.def.radius + Player.RADIUS - BodyBlock.allowance(was, dt)
	var off := e.pos - target
	var len_sq := off.length_squared()
	if keep <= 0.0 or len_sq >= keep * keep:
		return
	var dir := off / sqrt(len_sq) if len_sq > 0.0001 else -e.dir
	e.pos = target + dir * keep


## The bodies around `pos` that stop a walker of `radius` (BodyBlock.hold): centres, reaches (both radii), and how
## deep he may stay in each (as deep as he stands at `pos`: a dash that ended inside an enemy does not snap out).
## `extra`: meters more around `pos` to look (how far he is about to move).
func bodies_near(pos: Vector2, radius: float, extra: float, centers: PackedVector2Array, reaches: PackedFloat32Array, allowed: PackedFloat32Array) -> void:
	centers.clear()
	reaches.clear()
	allowed.clear()
	# the hash is up to a frame old: look a cell further than the widest body could reach
	var r := radius + _widest + extra + CELL
	var x0 := int(floor((pos.x - r) / CELL))
	var x1 := int(floor((pos.x + r) / CELL))
	var y0 := int(floor((pos.y - r) / CELL))
	var y1 := int(floor((pos.y + r) / CELL))
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			for e: Enemy in _hash.at_cell(cx, cy):
				if not blocks(e):
					continue
				var reach := e.def.radius + radius
				if e.pos.distance_squared_to(pos) > (reach + extra) * (reach + extra):
					continue
				centers.append(e.pos)
				reaches.append(reach)
				allowed.append(maxf(0.0, BodyBlock.depth(pos, e.pos, reach)))


## Where a walker of `radius` going from `start` to `to` ends against the enemies' bodies: it stops at their edge and
## slides along it, pushing no one (`resolve`: the walls, applied again after each push, so a body against a wall
## cannot push him through it). If no spot both clear of the walls and of the bodies is found (wedged between
## them), he stays at `start`, which always fits (he may stay as deep as he stands there): no overlap traps him,
## and every step that does not go deeper is taken.
func stop_walker(start: Vector2, to: Vector2, radius: float, resolve: Callable = Callable()) -> Vector2:
	bodies_near(start, radius, start.distance_to(to), _centers, _reaches, _allowed)
	if _centers.is_empty() or BodyBlock.fits(to, _centers, _reaches, _allowed):
		return to
	var p := to
	for pass_ in 3:
		p = BodyBlock.hold(p, _centers, _reaches, _allowed)
		if resolve.is_valid():
			p = resolve.call(p, radius)
		if BodyBlock.fits(p, _centers, _reaches, _allowed):
			return p
	return start


## True when a body of `radius` at `pos` would stand inside an enemy (the bot looks for a way around them).
func body_at(pos: Vector2, radius: float, ignore: Enemy = null) -> bool:
	for e in list:
		if e != ignore and blocks(e) and e.pos.distance_squared_to(pos) < (e.def.radius + radius) * (e.def.radius + radius):
			return true
	return false


## Damage to an enemy. Returns true when it died.
## `flash` false: no flash of a blow on the body (a burn's tick).
func damage(e: Enemy, amount: float, from_dir: Vector2, knockback: float, color: Color = Fx.GOLD, show_number: bool = true, big: bool = false, flash: bool = true) -> bool:
	if not e.alive or e.invulnerable:
		return false
	if e.armor > 0.0:
		# armor takes the blow: no push, no flinch; breaking it staggers (Game listens to armor_broken)
		e.armor = DamageCalc.against_armor(e.armor, amount)[0]
		e.flash_t = FLASH_TIME
		e.flash_power = WEAK_FLASH
		e.absorbed = true
		var chest := Vector3(e.pos.x, e.y + 1.2 * e.def.size, e.pos.y)
		if show_number:
			fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, ARMOR_COLOR, big, e.get_instance_id())
			tells.armor_hit(chest, from_dir)
		if e.armor <= 0.0:
			tells.armor_break(chest, e.def.size)
			armor_broken.emit(e)
		return false
	e.absorbed = false
	e.hp = maxf(e.hp - amount, e.hp_floor)
	if flash:
		e.flash_t = FLASH_TIME
		e.flash_power = 1.0 if big else WEAK_FLASH
		if e.def.behavior == EnemyDef.Behavior.BOSS:
			e.flash_power = minf(e.flash_power, BOSS_FLASH)
	if e.state == Enemy.State.WALK and not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
		e.hurt_t = HURT_TIME
	if knockback > 0.0:
		e.push = from_dir * knockback * (0.35 if e.def.heavy else 1.0)
	if show_number:
		fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, color, big, e.get_instance_id())
	if e.hp <= 0.0:
		e.alive = false
		e.state = Enemy.State.DEAD
		if e.def.behavior == EnemyDef.Behavior.BOSS:
			e.flash_t = 0.0  # the blow that fells a boss leaves no flash on him (BUG-004)
		e.dead_t = 0.0
		e.anim = &"death"
		if from_dir != Vector2.ZERO:
			e.dir = -from_dir
			if not e.def.heavy and e.def.behavior != EnemyDef.Behavior.BOSS:
				var power := THROW + knockback * 0.8 + (5.0 if big else 0.0)
				e.push = from_dir * power * _rng.randf_range(0.8, 1.2)
				e.vy = THROW_UP * _rng.randf_range(0.7, 1.2) + (3.0 if big else 0.0)
				e.spin = _rng.randf_range(0.6, 1.0)
		Audio.play(&"bone")
		fx.burst(&"bone" if e.def.undead else &"dust", Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(from_dir.x, 0, from_dir.y))
		killed.emit(e)
		return true
	return false


func _sweep() -> void:
	var i := list.size() - 1
	while i >= 0:
		var e := list[i]
		if not e.alive:
			dying.append(e)
			list[i] = list[list.size() - 1]
			list.pop_back()
		i -= 1
	var j := dying.size() - 1
	while j >= 0:
		if dying[j].dead_t > DEATH_SHOW:
			dying.remove_at(j)
		j -= 1
	while dying.size() > MAX_DYING:
		dying.pop_front()


## Removes the common crowd (the crypt doors opened): no experience, no drops. Elites and bosses stay.
func clear_crowd() -> void:
	for e in list:
		if not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
			e.alive = false
			e.state = Enemy.State.DEAD
			e.anim = &"death"
			fx.burst(&"shadow", Vector3(e.pos.x, 0.6, e.pos.y))
	_sweep()


## Up to this many enemies on the floor, every one shows its life bar (as in Hades II); more, only the hurt.
## Cycle 8: a room holds 4 to 20 at once, so in the game every enemy always shows its bar (the bar is how a
## wounded one is told from a fresh one, and an elite by its frame); only the stress tests thin them out.
const BARS_FOR_ALL := 24
## A blow tips the body back, away from the paladin, for an instant (radians at a full flash; a heavy body less).
const RECOIL_TILT := 0.2
## The pale trails on the life bars (only drawn).
var bar_trails := BarTrails.new()


## Draws every living and dying enemy. Called every frame, also while the game is paused for hit stop.
func render() -> void:
	renderer.begin()
	var few := list.size() <= BARS_FOR_ALL
	var crowded := not few
	var now := Time.get_ticks_msec() * 0.001
	if bar_trails.size() > list.size() + 32:
		bar_trails.prune(func(who: Object) -> bool: return (who as Enemy).alive)
	tells.begin()
	for e in list:
		var d := e.def
		var kind := renderer.kind(d)
		var anim := e.anim
		var t := e.anim_t
		var at := Vector3(e.pos.x, e.y, e.pos.y)
		var lean := 0.0
		var tell := 0.0
		if e.state == Enemy.State.WALK:
			if e.hurt_t > 0.0 and (not d.heavy or e.hurt_t > HURT_TIME - HEAVY_HURT):
				anim = &"hit"
				t = HURT_TIME - e.hurt_t
			elif e.stun_t > 0.0:
				anim = &"idle"
			else:
				t = e.anim_t * clip_rate(e)
				if d.sway > 0.0 and e.frozen_t <= 0.0:
					# unsteady: the trunk rocks from side to side and the stride is uneven (the place does not change)
					lean = deg_to_rad(d.sway) * sin(TAU * (SWAY_HZ * e.anim_t + e.look))
					t = maxf(0.0, t + UNEVEN_STEP * sin(TAU * (1.7 * e.anim_t + e.look)))
		elif e.state == Enemy.State.WINDUP:
			tell = clampf(e.state_t / maxf(_windup(e), 0.01), 0.0, 1.0)
			tells.tell(e, tell)
			if anim == &"attack":
				# stretch the swing so the blade comes down when the windup ends
				t = e.state_t / _windup(e) * kind.attack_time * IMPACT_SHARE
			elif anim == &"idle" and kind.has_brace:
				# the charge is announced standing still: braced behind the shield, when the figure has that pose
				anim = &"brace"
			if d.windup_shake > 0.0 and e.frozen_t <= 0.0:
				var side := Vector2(e.dir.y, -e.dir.x) * d.windup_shake * sin(TAU * SHAKE_HZ * e.state_t)
				at += Vector3(side.x, 0, side.y)
		elif e.state == Enemy.State.ATTACK:
			tells.loosed(e, e.state_t)
			if anim == &"attack":
				t = kind.attack_time * IMPACT_SHARE + e.state_t * 1.4
		var k := clampf(e.flash_t / FLASH_TIME, 0.0, 1.0)
		var state := CrowdRenderer.state(k * e.flash_power, e.frozen_t > 0.0, e.burn_t > 0.0, 0.0, e.absorbed, tell,
			e.max_armor > 0.0 and e.armor <= 0.0)
		# a blow flattens and widens the body for an instant, and lifts it a little; less on a heavy body, and not at
		# all when its armor took it
		var give := 0.0 if e.absorbed else k * (HEAVY_SQUASH if d.heavy else 1.0)
		var squash := Vector3(1.0 + 0.25 * give, 1.0 - 0.2 * give, 1.0 + 0.25 * give)
		renderer.add_kind(kind, d, anim, t, at + Vector3(0, 0.18 * give, 0), e.yaw(), state, squash, -RECOIL_TILT * give, lean)
		# the thin life bar over the head (the boss has its own at the top of the screen); with a big crowd only
		# the hurt and the armored show one, thinner and fainter, so the screen stays clear
		if d.behavior != EnemyDef.Behavior.BOSS and (few or e.hp < e.max_hp or e.armor > 0.0):
			var top := e.y + kind.model.height * d.size
			var life := e.hp / maxf(e.max_hp, 0.001)
			renderer.add_bar(d, Vector3(e.pos.x, top, e.pos.y), life,
				e.armor / maxf(e.max_armor, 0.001) if e.max_armor > 0.0 else 0.0, crowded, bar_trails.shown(e, life, now))
	for e in dying:
		var dissolve := clampf((e.dead_t - DISSOLVE_FROM) / (DEATH_SHOW - DISSOLVE_FROM), 0.0, 1.0)
		var sink := maxf(0.0, e.dead_t - DISSOLVE_FROM) * 1.2
		var tumble := -e.spin * sin(clampf(e.dead_t * 2.2, 0.0, 1.0) * PI) * 1.1
		renderer.add(e.def, &"death", e.dead_t * 1.3, Vector3(e.pos.x, e.y - sink, e.pos.y), e.yaw(), Color(death_flash(e), 0, 0, dissolve), Vector3.ONE, tumble)
	renderer.commit()
	tells.commit()


## How white one of the fallen is drawn (crowd.gdshader's flash): a flash for an instant as it falls; a boss never
## (his fall is his ending: no white body, BUG-004 of cycle 10).
static func death_flash(e: Enemy) -> float:
	if e.def.behavior == EnemyDef.Behavior.BOSS:
		return 0.0
	return maxf(0.0, 1.0 - e.dead_t * 8.0)


# ---------- queries (only on the frames something lands, so a plain loop is enough) ----------

func in_circle(center: Vector2, radius: float, out: Array[Enemy]) -> void:
	out.clear()
	for e in list:
		var r := radius + e.def.radius
		if e.alive and e.pos.distance_squared_to(center) <= r * r:
			out.append(e)


func in_arc(center: Vector2, dir: Vector2, reach: float, degrees: float, out: Array[Enemy]) -> void:
	out.clear()
	var half := deg_to_rad(degrees) * 0.5
	for e in list:
		if not e.alive:
			continue
		var d := e.pos - center
		var r := reach + e.def.radius
		var len_sq := d.length_squared()
		if len_sq > r * r:
			continue
		# anything hugging the paladin is hit whatever the angle
		if len_sq < 1.0 or absf(dir.angle_to(d)) <= half + e.def.radius / maxf(sqrt(len_sq), 0.5):
			out.append(e)


func in_line(from: Vector2, dir: Vector2, length: float, width: float, out: Array[Enemy]) -> void:
	out.clear()
	for e in list:
		if not e.alive:
			continue
		var d := e.pos - from
		var along := d.dot(dir)
		if along < -e.def.radius or along > length + e.def.radius:
			continue
		if absf(d.cross(dir)) <= width * 0.5 + e.def.radius:
			out.append(e)


## The closest living enemy within a cone (half angle in radians) around dir.
func nearest_ahead(from: Vector2, dir: Vector2, max_dist: float, half_angle: float) -> Enemy:
	var best: Enemy = null
	var best_d := max_dist * max_dist
	for e in list:
		var d := e.pos.distance_squared_to(from)
		if e.alive and d < best_d and absf(dir.angle_to(e.pos - from)) < half_angle:
			best_d = d
			best = e
	return best


func nearest(from: Vector2, max_dist: float = INF) -> Enemy:
	var best: Enemy = null
	var best_d := max_dist * max_dist
	for e in list:
		var d := e.pos.distance_squared_to(from)
		if e.alive and d < best_d:
			best_d = d
			best = e
	return best
