class_name Boss
extends RefCounted
## Morvath, the king who betrayed the light, in four phases (Daniel's request of 2026-11-15). Every number is his
## BossDef (data/bosses/morvath.tres, tools/make_data.gd); the choice of the next attack is BossDirector's; phases,
## patterns and the ritual's rules are BossRules' (all tested). This node keeps the states and draws them.
## 1 "O Despertar": the Sepulchral Scythe (half a circle), the Blades of the Souls (two parting crescents), the dash.
## 2 "O Ritual dos Mortos": he walks to the middle of the hall and raises a shield (the only time he cannot be hurt)
##    while his dead fight for him and the floor erupts; it ends when they fall or after ritual_time. Then eruptions
##    and a few summons join the rest.
## 3 "A Maldicao dos Condenados": the curse bolt (slower walking, no special for a few seconds).
## 4 "O Ultimo Suspiro": the hall's light turns to his fire, the blades become the Storm of the Six Souls.
## Every attack is announced on the floor before it lands; his life stops at each threshold, so each phase begins
## once and in order; when he falls everything of his goes with him (shots, warnings, summons, the curse).

signal defeated
signal phase_changed(phase: int)
## The moments of the fight (an attack chosen or landing, the ritual, the fall): captures wait on them
## (--shot-on=boss:<name>).
signal moment(name: StringName)

enum State { ENTER, CHASE, SCYTHE, BLADES, STORM, ERUPTIONS, CURSE, SUMMON, DASH_WARN, DASH, ROAR, TO_CENTER, RITUAL, STUNNED, DYING }

## The states the director's attack ids stand for.
const ATTACKS := {
	&"scythe": State.SCYTHE, &"blades": State.BLADES, &"storm": State.STORM, &"eruptions": State.ERUPTIONS,
	&"curse": State.CURSE, &"summon": State.SUMMON, &"dash": State.DASH_WARN,
}
const DEFS_DIR := "res://data/bosses/"
## His necromancy and the souls: a cold, pale spectral green (Emeth's is a warmer crystal green, Combat.EMETH).
const SPECTRAL := Color(0.38, 1.55, 1.1)
## The curse: dark purple.
const CURSE_COLOR := Color(1.0, 0.22, 1.5)
## Walking to the middle for the ritual: times his speed, and at most this long.
const CENTER_SPEED := 1.6
const CENTER_TIME := 4.0
## The shield grows in and fades out this fast (per second); it flares to SHIELD_FLARE when it breaks.
const SHIELD_SPEED := 2.5
const SHIELD_FLARE := 2.2
## His summons never rise closer than this to the paladin (m), on a ring this far from where they are called.
const SUMMON_CLEAR := 4.0
const SUMMON_RING := 5.0
const RITUAL_RING := 6.5
## The last phase: a wisp of his fire every this many seconds.
const FINAL_WISP := 0.35
## The paladin counts as standing still under this speed (m/s).
const STILL_SPEED := 0.6

var game: Game
var def: BossDef
var e: Enemy
var director: BossDirector
var phase := 1
var state := State.ENTER
## Where the fight ends (the ending plays here).
var center := Vector2.ZERO
## The fight in numbers, for RESULT (Game.boss_stats).
var stats := {}
var _middle := Vector2.ZERO
var _floor := Rect2()
var _t := 0.0
var _step := 0
var _mark := 0.0
var _cooldown := 1.0
var _dir := Vector2.DOWN
var _dirs := PackedVector2Array()
var _spots := PackedVector2Array()
var _from := Vector2.ZERO
var _stagger := 0
var _stagger_t := 0.0
var _stun_time := 0.0
var _ritual_done := false
var _ritual_t := 0.0
var _ritual_quake := 0.0
var _ritual_more := 0.0
## What the ritual raised (it ends when they all fall) and every summon of his still counted.
var _raised: Array[Enemy] = []
var _adds: Array[Enemy] = []
## His shots still flying (he waits for them before the next attack).
var _shots: Array[Projectiles.Shot] = []
var _shield: MeshInstance3D
var _shield_power := 0.0
var _player_last := Vector2.ZERO
var _player_vel := Vector2.ZERO
var _still_t := 0.0
var _wisp := 0.0
var _clock := 0.0
var _rng := RandomNumberGenerator.new()


func setup(g: Game, enemy_def: EnemyDef) -> void:
	game = g
	Dev.seed_rng(_rng, 3)
	var path := DEFS_DIR + String(enemy_def.id) + ".tres"
	def = load(path) as BossDef if ResourceLoader.exists(path) else BossDef.new()
	director = BossDirector.new(def)
	_middle = g.arena.resolve(Vector2.ZERO, enemy_def.radius)
	var m := 1.2 + Player.RADIUS
	_floor = Rect2(-g.arena.half + Vector2(m, m), (g.arena.half - Vector2(m, m)) * 2.0)
	center = _middle
	e = g.horde.spawn(enemy_def, g.arena.door_pos + Vector2(0, Arena.STAIRS_DEPTH + enemy_def.radius), false)
	e.dir = Vector2.DOWN
	e.hp = e.max_hp * Dev.num("boss-hp", 1.0)
	# --boss-hp starts him further down (dev): the phase of that life, without the ones before
	phase = BossRules.phase_for(e.hp / e.max_hp, def.thresholds)
	_ritual_done = phase > def.ritual_phase
	e.hp_floor = BossRules.hp_floor(phase, def.thresholds) * e.max_hp
	_player_last = g.player.pos
	stats = {"phase_at": [], "max_phase": phase, "ritual": 0.0, "ritual_raised": 0, "adds_peak": 0, "adds_total": 0, "curses": 0, "attacks": {}}
	g.boss_stats = stats
	g.combat.enemy_struck.connect(_on_struck)
	g.horde.killed.connect(_on_killed)
	g.fx.burst(&"soul", Vector3(e.pos.x, 1.0, e.pos.y))
	g.fx.beam(e.pos, SPECTRAL, 2.0, 14.0, 1.0)
	_shield = _make_shield()
	g.add_child(_shield)
	if phase >= def.final_light_phase:
		g.arena.open_door(SPECTRAL)


func step(dt: float) -> void:
	_clock += dt
	_step_shield(dt)
	if state == State.DYING:
		_step_dying(dt)
		return
	if e == null or not e.alive:
		return
	_t += dt
	_cooldown -= dt
	_stagger_t -= dt
	if _stagger_t <= 0.0:
		_stagger = 0
	director.step(dt)
	_track_player(dt)
	stats.adds_peak = maxi(stats.adds_peak, _standing(_adds))
	var p := game.player.pos
	var to := p - e.pos
	var toward := to.normalized() if to.length() > 0.2 else Vector2.DOWN
	if state != State.ENTER and state != State.ROAR and state != State.TO_CENTER and state != State.RITUAL:
		var want := BossRules.next_phase(phase, e.hp / e.max_hp, def.thresholds)
		if want > phase:
			_change_phase(want)
			return
	if phase >= def.final_light_phase:
		_wisp -= dt
		if _wisp <= 0.0:
			_wisp = FINAL_WISP
			game.fx.burst(&"soul", Vector3(e.pos.x + _rng.randf_range(-0.8, 0.8), _rng.randf_range(0.5, 3.5), e.pos.y + _rng.randf_range(-0.8, 0.8)))
	match state:
		State.ENTER:
			e.pos += Vector2.DOWN * 3.2 * dt
			_anim(&"walk")
			if _t > 2.4:
				game.hud.show_notice(T.t("boss_phase_%d" % phase), 2.5)
				_rest(0.6)
		State.CHASE:
			e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0))
			if to.length() > def.scythe_reach * 0.7:
				e.pos += toward * e.def.speed * (1.0 + 0.08 * (phase - 1)) * dt
				_anim(&"walk")
			else:
				_anim(&"idle")
			if _cooldown <= 0.0 and game.player.alive() and not _shots_flying():
				_choose(to.length())
		State.SCYTHE:
			_step_scythe(dt, to, toward)
		State.BLADES:
			_step_blades()
		State.STORM:
			_step_storm()
		State.ERUPTIONS:
			_step_eruptions()
		State.CURSE:
			_step_curse()
		State.SUMMON:
			_step_summon()
		State.DASH_WARN:
			_anim(&"dash_windup")
			if _step == 0:
				_step = 1
				_dir = toward
				e.dir = _dir
				game.ground.add_line_warning(e.pos, _dir, def.dash_length, def.dash_width, _windup(def.dash_windup), def.dash_damage)
			if _t >= _windup(def.dash_windup):
				_from = e.pos
				_go(State.DASH)
				Audio.play(&"boss_dash")
		State.DASH:
			_anim(&"dash")
			e.pos = _from + _dir * def.dash_length * minf(_t / def.dash_time, 1.0)
			if int(_t * 30.0) % 2 == 0:
				game.fx.burst(&"soul", Vector3(e.pos.x, 0.6, e.pos.y))
			if _t >= def.dash_time:
				_rest(def.dash_recovery)
		State.ROAR:
			_anim(&"roar")
			if _t >= def.roar_time:
				if phase == def.ritual_phase and not _ritual_done:
					_go(State.TO_CENTER)
				else:
					_rest(0.6)
		State.TO_CENTER:
			var way := _middle - e.pos
			_anim(&"walk")
			if way.length() > 0.6 and _t < CENTER_TIME:
				e.dir = e.dir.slerp(way.normalized(), minf(1.0, dt * 8.0))
				e.pos += way.normalized() * minf(way.length(), e.def.speed * CENTER_SPEED * dt)
			else:
				_start_ritual()
		State.RITUAL:
			_step_ritual(dt, toward)
		State.STUNNED:
			_anim(&"stunned")
			e.stun_t = 0.1
			if _t >= _stun_time:
				_stagger = 0
				e.armor = e.max_armor
				_rest(0.5)
	e.pos = game.arena.resolve(e.pos, e.def.radius)


# ---------- choosing ----------

func _choose(dist: float) -> void:
	var blocked: Array[StringName] = []
	if _summon_room(def.summon_raise.size(), BossRules.adds_cap(def.adds_cap, phase)) <= 0:
		blocked.append(&"summon")
	if game.player.curse.active() or game.player.curse.immune_left > 0.0:
		blocked.append(&"curse")
	var id := director.choose(phase, dist, _still_t, blocked, _rng)
	# dev, for captures: --boss-only=<attack> plays that one whenever the phase has it
	if Dev.has("boss-only") and ATTACKS.has(StringName(Dev.arg("boss-only"))):
		var only := StringName(Dev.arg("boss-only"))
		if director.valid(phase, dist, blocked, 0).any(func(a: BossAttack) -> bool: return a.id == only):
			id = only
	if not ATTACKS.has(id):
		_rest(0.5)
		return
	director.used(id)
	var counts: Dictionary = stats.attacks
	counts[id] = int(counts.get(id, 0)) + 1
	_go(ATTACKS[id])
	moment.emit(id)


## The paladin's way and how long he has stood still (the director and the aim read them).
func _track_player(dt: float) -> void:
	var p := game.player.pos
	if dt > 0.0:
		_player_vel = _player_vel.lerp((p - _player_last) / dt, minf(1.0, dt * 8.0))
	_player_last = p
	_still_t = _still_t + dt if _player_vel.length() < STILL_SPEED else 0.0


func _aim(speed: float) -> Vector2:
	return BossRules.aim_at(e.pos, game.player.pos, _player_vel, speed, def.lead)


# ---------- the attacks ----------

## The Sepulchral Scythe: walks in, lifts the blade over half a circle of red (scythe_windup), sweeps, and stands
## spent for scythe_recovery: the window to punish.
func _step_scythe(dt: float, to: Vector2, toward: Vector2) -> void:
	match _step:
		0:
			if to.length() > def.scythe_reach * 0.55 and _t < def.scythe_approach:
				e.dir = e.dir.slerp(toward, 0.3)
				e.pos += toward * e.def.speed * 1.25 * dt
				_anim(&"walk")
				return
			_step = 1
			_mark = _t
			_dir = toward
			e.dir = _dir
			game.ground.add_arc_warning(e.pos, _dir, def.scythe_reach, def.scythe_degrees, _windup(def.scythe_windup), def.scythe_damage)
			moment.emit(&"scythe_warn")
			_anim(&"dash_windup")
			game.fx.burst(&"soul", Vector3(e.pos.x, 2.2, e.pos.y))
		1:
			if _t - _mark >= _windup(def.scythe_windup):
				_step = 2
				_mark = _t
				e.anim = &"slash1"
				e.anim_t = 0.0
				game.fx.slash(e.pos, _dir, def.scythe_reach, def.scythe_degrees, SPECTRAL, 0.3, false, 1.0)
				game.fx.crescent(e.pos, _dir, def.scythe_reach, def.scythe_degrees, SPECTRAL)
				game.fx.shake(2.0)
				Audio.play(&"scythe")
				moment.emit(&"scythe_strike")
		2:
			if _t - _mark >= def.scythe_recovery * 0.5:
				_anim(&"idle")
			if _t - _mark >= def.scythe_recovery:
				_rest()


## The Blades of the Souls: two crescents part from him, one at the paladin (with a little lead), the other
## blade_spread degrees aside; both lanes are on the floor for blade_windup.
func _step_blades() -> void:
	var windup := _windup(def.blade_windup)
	if _step == 0:
		_step = 1
		var aim := _aim(def.blade_speed)
		_dirs = BossRules.soul_pair(aim, def.blade_spread, 1.0 if _rng.randf() < 0.5 else -1.0)
		e.dir = (_dirs[0] + _dirs[1]).normalized()
		for d in _dirs:
			game.ground.add_line_warning(e.pos, d, def.blade_range, def.blade_width, windup, 0.0)
		_anim(&"dash_windup")
		game.fx.burst(&"soul", Vector3(e.pos.x, 2.0, e.pos.y))
	elif _step == 1 and _t >= windup:
		_step = 2
		_fire_souls(_dirs, def.blade_damage)
		moment.emit(&"blades_fire")
		e.anim = &"slash2"
		e.anim_t = 0.0
	elif _step == 2 and _t >= windup + def.blade_recovery:
		_rest()


## The Storm of the Six Souls: storm_count crescents all around (never closing every way out), then a second wave
## turned storm_turn degrees after storm_gap seconds.
func _step_storm() -> void:
	var windup := _windup(def.storm_windup)
	var beat := windup + def.storm_gap
	var wave := _step / 2
	if wave >= def.storm_waves:
		if _t >= beat * def.storm_waves - def.storm_gap + def.storm_recovery:
			_rest()
		return
	var start := wave * beat
	if _step % 2 == 0 and _t >= start:
		_step += 1
		var offset := rad_to_deg(_aim(def.blade_speed).angle()) + def.storm_turn * wave
		_dirs = BossRules.storm(def.storm_count, offset, def.storm_jitter, def.storm_min_gap, _rng)
		for d in _dirs:
			game.ground.add_line_warning(e.pos, d, def.blade_range, def.blade_width, windup, 0.0)
		_anim(&"rain")
		game.fx.ring(e.pos, 3.0, SPECTRAL, 0.5)
		game.fx.burst(&"soul", Vector3(e.pos.x, 2.5, e.pos.y))
	elif _step % 2 == 1 and _t >= start + windup:
		_step += 1
		_fire_souls(_dirs, def.storm_damage)
		moment.emit(&"storm_fire")
		e.anim = &"roar"
		e.anim_t = 0.0
		game.fx.shake(2.5)


func _fire_souls(dirs: PackedVector2Array, damage: float) -> void:
	for d in dirs:
		_shots.append(game.projectiles.fire_soul(e.pos + d * 0.8, d, def.blade_speed, damage, def.blade_width, def.blade_range, SPECTRAL))
	game.fx.shake(1.2)
	Audio.play(&"souls")


## His shots still in the air (pruned as they go).
func _shots_flying() -> bool:
	var i := _shots.size() - 1
	while i >= 0:
		if not game.projectiles.shots.has(_shots[i]):
			_shots.remove_at(i)
		i -= 1
	return not _shots.is_empty()


## The Sepulchral Eruptions: eruption_sequences of 2 or 3 circles, one on the paladin, the lane to the middle of
## the hall always free; each sequence lands before the next appears.
func _step_eruptions() -> void:
	_anim(&"rain")
	var beat := _windup(def.eruption_delay) + def.eruption_gap
	if _step < def.eruption_sequences and _t >= _step * beat:
		_step += 1
		_erupt()
	if _t >= beat * def.eruption_sequences - def.eruption_gap + def.eruption_recovery:
		_rest()


func _erupt() -> void:
	var n := _rng.randi_range(def.eruption_count.x, maxi(def.eruption_count.x, def.eruption_count.y))
	for at in BossRules.eruptions(game.player.pos, n, def.eruption_radius, _middle, def.eruption_lane, _floor, _rng):
		var z := game.ground.add_warning(at, def.eruption_radius, _windup(def.eruption_delay), def.eruption_damage, SPECTRAL)
		z.eruption = true
	Audio.play(&"eruption")


## The curse: he raises his hand in a ring of dark purple, the lane of the bolt shows on the floor, and the bolt
## follows the paladin a little (curse_turn degrees a second for curse_homing seconds). A dodge passes through it.
func _step_curse() -> void:
	var windup := _windup(def.curse_windup)
	if _step == 0:
		_step = 1
		_dir = _aim(def.curse_speed)
		e.dir = _dir
		game.ground.add_line_warning(e.pos, _dir, def.curse_speed * def.curse_homing, 1.4, windup, 0.0)
		game.fx.ring(e.pos, 2.4, Color(0.55, 0.15, 0.8), windup)
		game.fx.burst(&"curse", Vector3(e.pos.x, 2.6, e.pos.y))
		_anim(&"volley")
		Audio.play(&"curse")
	elif _step == 1 and _t >= windup:
		_step = 2
		_shots.append(game.projectiles.fire_curse(e.pos + _dir * 1.6, _aim(def.curse_speed), def.curse_speed, def.curse_damage, def.curse_radius,
			def.curse_life, def.curse_turn, def.curse_homing, CURSE_COLOR))
	elif _step == 2 and _t >= windup + def.curse_recovery:
		_rest()


## A few of his dead rise around him (a warning on each spot first), never past the phase's ceiling.
func _step_summon() -> void:
	_anim(&"summon")
	if _step == 0:
		_step = 1
		var n := _summon_room(def.summon_raise.size(), BossRules.adds_cap(def.adds_cap, phase))
		_spots = _ring_spots(e.pos, SUMMON_RING, n)
		for at in _spots:
			game.ground.add_warning(at, 1.2, def.summon_windup, 0.0, SPECTRAL)
	elif _step == 1 and _t >= def.summon_windup:
		_step = 2
		for i in _spots.size():
			_raise(def.summon_raise[i % def.summon_raise.size()], _spots[i])
		Audio.play(&"summon")
	elif _step == 2 and _t >= def.summon_windup + 0.8:
		_rest()


func _raise(id: StringName, at: Vector2) -> Enemy:
	var add := game.horde.spawn(game.horde.def(id), at, true)
	_adds.append(add)
	stats.adds_total += 1
	game.fx.burst(&"soul", Vector3(at.x, 0.4, at.y))
	return add


## How many of `want` may rise now: under his own ceiling and the hall's (Horde.room_for).
func _summon_room(want: int, cap: int) -> int:
	var n := BossRules.summon_count(want, _standing(_adds), cap)
	return mini(n, game.horde.room_for(n))


static func _standing(list: Array[Enemy]) -> int:
	var n := 0
	for a in list:
		if a.alive:
			n += 1
	return n


## n spots on a ring around a point, on the floor and never close to the paladin.
func _ring_spots(around: Vector2, radius: float, n: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	var from := _rng.randf() * TAU
	var p := game.player.pos
	for i in n:
		var at := game.arena.resolve(around + Vector2.from_angle(from + TAU * i / maxi(n, 1)) * radius, 0.6)
		if at.distance_to(p) < SUMMON_CLEAR:
			var away := (at - p).normalized() if at.distance_to(p) > 0.1 else Vector2.from_angle(from)
			at = game.arena.resolve(p + away * SUMMON_CLEAR, 0.6)
		out.append(at)
	return out


# ---------- the ritual ----------

func _start_ritual() -> void:
	_go(State.RITUAL)
	e.invulnerable = true
	_ritual_t = 0.0
	_ritual_quake = 2.0
	_ritual_more = def.ritual_reinforce_every
	_raised.clear()
	var n := _summon_room(def.ritual_raise.size(), def.ritual_cap)
	var spots := _ring_spots(e.pos, RITUAL_RING, n)
	for i in spots.size():
		_raised.append(_raise(def.ritual_raise[i], spots[i]))
	game.fx.ring(e.pos, def.shield_radius * 2.0, SPECTRAL, 0.6)
	game.fx.beam(e.pos, SPECTRAL, def.shield_radius, 12.0, 0.8)
	Audio.play(&"shield_up")
	Audio.play(&"summon")
	moment.emit(&"ritual")


## Behind the shield: his dead fight, the floor erupts every ritual_eruption_every seconds and more rise every
## ritual_reinforce_every (never past ritual_cap standing). Over when they all fall or the time runs out.
func _step_ritual(dt: float, toward: Vector2) -> void:
	_ritual_t += dt
	e.dir = e.dir.slerp(toward, minf(1.0, dt * 3.0))
	_anim(&"summon" if _ritual_t < 1.2 else &"rain")
	_ritual_quake -= dt
	if _ritual_quake <= 0.0:
		_ritual_quake = def.ritual_eruption_every
		_erupt()
	_ritual_more -= dt
	if _ritual_more <= 0.0:
		_ritual_more = def.ritual_reinforce_every
		var n := _summon_room(def.ritual_reinforce.size(), def.ritual_cap)
		var spots := _ring_spots(e.pos, RITUAL_RING, n)
		for i in spots.size():
			_raised.append(_raise(def.ritual_reinforce[i], spots[i]))
		if n > 0:
			Audio.play(&"summon")
	if BossRules.ritual_over(_ritual_t, def.ritual_time, _raised.size(), _standing(_raised)):
		_end_ritual()


func _end_ritual() -> void:
	_ritual_done = true
	e.invulnerable = false
	stats.ritual = snappedf(_ritual_t, 0.1)
	stats.ritual_raised = _raised.size()
	_shield_power = SHIELD_FLARE
	game.fx.ring(e.pos, def.shield_radius * 2.4, SPECTRAL, 0.5)
	game.fx.burst(&"soul", Vector3(e.pos.x, 2.0, e.pos.y))
	game.fx.shake(3.0)
	game.hud.show_notice(T.t(&"boss_ritual_end"), 2.0)
	Audio.play(&"shield_down")
	_stun(def.ritual_stun)


## True while the ritual's shield stands (the HUD draws his bar shielded).
func shielded() -> bool:
	return state == State.RITUAL and e != null and e.invulnerable


func _step_shield(dt: float) -> void:
	if _shield == null:
		return
	var want := 1.0 if shielded() else 0.0
	if _shield_power > 1.0:
		_shield_power = maxf(want, _shield_power - dt * SHIELD_SPEED * 2.0)
	else:
		_shield_power = move_toward(_shield_power, want, dt * SHIELD_SPEED)
	_shield.visible = _shield_power > 0.01 and e != null
	if _shield.visible:
		_shield.position = Vector3(e.pos.x, def.shield_radius * 0.7, e.pos.y)
		_shield.scale = Vector3.ONE * (0.6 + 0.4 * minf(_shield_power, 1.0) + 0.15 * maxf(0.0, _shield_power - 1.0))
		(_shield.material_override as ShaderMaterial).set_shader_parameter(&"power", _shield_power)


func _make_shield() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = def.shield_radius
	sphere.height = def.shield_radius * 2.0
	sphere.radial_segments = 32
	sphere.rings = 16
	mi.mesh = sphere
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/boss_shield.gdshader")
	mat.set_shader_parameter(&"color", Color(SPECTRAL.r / SPECTRAL.g, 1.0, SPECTRAL.b / SPECTRAL.g))
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visible = false
	return mi


# ---------- phases, stagger, the fall ----------

## A threshold is crossed: whatever he was doing stops (its warnings and shots go), he roars and the next phase begins.
func _change_phase(next: int) -> void:
	phase = next
	stats.max_phase = phase
	(stats.phase_at as Array).append(snappedf(_clock, 0.1))
	e.hp_floor = BossRules.hp_floor(phase, def.thresholds) * e.max_hp
	_cancel()
	_go(State.ROAR)
	game.fx.shake(5.0)
	game.fx.hit_stop(90)
	game.fx.kick_split(1.0)
	game.fx.impact_frame()
	game.fx.ring(e.pos, 9.0, SPECTRAL, 0.6)
	game.fx.beam(e.pos, SPECTRAL, 2.5, 18.0, 0.9)
	game.fx.burst(&"soul", Vector3(e.pos.x, 2.0, e.pos.y))
	game.hud.show_notice(T.t("boss_phase_%d" % phase), 3.0)
	Audio.play(&"roar")
	# the roar throws the paladin back, out of the king's reach
	var away := (game.player.pos - e.pos).normalized()
	game.player.place(game.player.pos + away * def.roar_push)
	if phase >= def.final_light_phase:
		game.arena.open_door(SPECTRAL)
	phase_changed.emit(phase)


## Everything he set going stops: his warnings on the floor and the shots in the air.
func _cancel() -> void:
	game.projectiles.clear_hostile()
	game.ground.clear_warnings()
	_shots.clear()


## His armor broke: he staggers, and stands up armored again.
func break_armor() -> void:
	if state == State.STUNNED or state == State.DYING or state == State.RITUAL:
		return
	_stun(def.stagger_time)


## From stagger_from_phase on, the paladin's heavy blows stagger the king.
func _on_struck(target: Enemy, tags: Array[StringName], _damage: float) -> void:
	if target != e or phase < def.stagger_from_phase or state in [State.STUNNED, State.ROAR, State.RITUAL, State.TO_CENTER, State.DYING]:
		return
	if not tags.has(&"heavy") or tags.has(&"mark"):
		return
	_stagger += 1
	_stagger_t = def.stagger_forget
	if _stagger >= def.stagger_hits:
		_stun(def.stagger_time)


func _stun(seconds: float) -> void:
	_go(State.STUNNED)
	_stun_time = seconds
	game.fx.shake(4.0)
	game.fx.burst(&"light", Vector3(e.pos.x, 2.5, e.pos.y))
	game.fx.word(Vector3(e.pos.x, 5.0, e.pos.y), T.t(&"word_stagger"), Combat.LIGHT)
	Audio.play(&"stagger")


## He falls: nothing of his outlives him (shots, warnings, summons, the shield, the curse on the paladin).
func _on_killed(dead: Enemy) -> void:
	if dead != e:
		return
	state = State.DYING
	_t = 0.0
	center = e.pos
	e.invulnerable = false
	_cancel()
	game.ground.clear()
	game.horde.clear_crowd.call_deferred()
	_adds.clear()
	_raised.clear()
	game.player.curse.clear()
	# the crypt's portal calms back to its own green
	game.arena.open_door(ArenaKit.PORTAL)
	game.fx.hit_stop(120)
	game.fx.slow_mo(0.15, 1.0, 0.8, 1.2, 1.0)
	game.fx.shake(6.0)
	game.fx.kick_split(1.0)
	game.fx.impact_frame()
	Audio.play(&"boss_down")
	Audio.music(&"")


func _step_dying(dt: float) -> void:
	_t += dt
	if _t > 0.2 and int(_t * 6.0) != int((_t - dt) * 6.0):
		game.fx.burst(&"light", Vector3(e.pos.x + _rng.randf_range(-1.5, 1.5), _rng.randf_range(0.5, 4.0), e.pos.y + _rng.randf_range(-1.5, 1.5)))
	if _t >= 2.4:
		# anything that slipped in while he fell goes too
		_cancel()
		if is_instance_valid(_shield):
			_shield.queue_free()
		_shield = null
		state = State.ENTER
		moment.emit(&"fallen")
		game.boss = null
		defeated.emit()


# ---------- small helpers ----------

func _go(next: State) -> void:
	state = next
	_t = 0.0
	_step = 0
	_mark = 0.0
	e.memo = 0


## Back to walking; the next attack comes after the phase's rest (plus `extra`).
func _rest(extra: float = 0.0) -> void:
	_cooldown = BossDef.by_phase(def.rest, phase, 1.0) + extra
	_go(State.CHASE)


func _windup(seconds: float) -> float:
	return seconds * BossDef.by_phase(def.windup_scale, phase, 1.0)


func _anim(anim: StringName) -> void:
	if e.anim != anim:
		e.anim = anim
		e.anim_t = 0.0
