class_name Boss
extends RefCounted
## Morvath, the king who betrayed the light, in four phases (Daniel's request of 2026-11-15). Every number is his
## BossDef (data/bosses/morvath.tres, tools/make_data.gd); the choice of the next attack is BossDirector's; phases,
## patterns and the ritual's rules are BossRules' (all tested). This node keeps the states and draws them.
## 1 "O Despertar": the Sepulchral Scythe (half a circle), the Blades of the Souls (two parting crescents), the dash.
## 2 "O Ritual dos Mortos": he walks to the middle of the hall and raises a shield (the only time he cannot be hurt)
##    while his dead rise one by one and fight for him and the floor erupts; it ends when they fall or after
##    ritual_time. Then eruptions and a few summons join the rest.
## 3 "A Maldicao dos Condenados": opens on the curse bolt (slower walking, no special for a few seconds).
## 4 "O Ultimo Suspiro": the portal pulses with his fire, he is more corrupted, the blades become the Storm of the
##    Six Souls (each crescent in turn) and some attacks follow each other (BossAttack.then).
## Every attack is announced on the floor before it lands and ends in a recovery (the window to punish, counted in
## stats); his life stops at each threshold, so each phase begins once and in order; when he falls everything of
## his goes with him and a short ending plays (VICTORY_TIME) while the paladin keeps his control.
##
## For the art (cycle 9, the VFX and HUD fronts): `moment` names the beats of the fight (captures wait on them),
## `cue` gives each visual beat with its geometry (where, which way, how big, how long) so a look can be put on it
## without touching the fight. Cues (name: at, dir, size, seconds):
##   scythe_raise: him, the sweep's middle direction, reach, wind-up      scythe_sweep: him, dir, reach, sweep time
##   scythe_land: the far middle of the arc, dir, reach, 0                blades_gather / blades_release: him, aim
##   storm_wave: him, aim, crescents, wind-up                             storm_blade: exit point, its way, width
##   dash_aim: him, way, length, wind-up                                  dash_go: him, way, length, dash time
##   dash_land: the end, way, lane width, 0                               curse_gather / curse_release: hand, aim
##   curse_land: the paladin's feet, 0, 0, curse time                    phase_shift: him, 0, new phase, roar time
##   rune: a spot on the floor, 0, radius, seconds to the rise            rise: that spot (the dead comes up)
##   shield_up / shield_break: him, 0, shield radius                      ritual_end: him
##   victory_blow, victory_fade, victory_absorb (the portal), emeth_glow (the paladin), ritual_broken (the middle),
##   victory_done: the ending's beats (see _step_dying).

signal defeated
signal phase_changed(phase: int)
## The moments of the fight (an attack chosen or landing, the ritual, the fall): captures wait on them
## (--shot-on=boss:<name>).
signal moment(name: StringName)
## A visual beat with its geometry (see above): at and dir on the floor (x, z), size in meters (or a count), seconds.
signal cue(name: StringName, at: Vector2, dir: Vector2, size: float, seconds: float)
## The ritual's count changed (for the HUD's "Mortos: 3/4"): left of the dead that break the shield (the first ones
## raised, those still rising included; reinforcements never count), of total. Emitted when the ritual begins, at
## each of those dead falling and when it ends (left 0). Also readable at any time: ritual_left(), ritual_total().
signal ritual_changed(left: int, total: int)

enum State { ENTER, CHASE, SCYTHE, BLADES, STORM, ERUPTIONS, CURSE, SUMMON, DASH_WARN, DASH, ROAR, TO_CENTER, RITUAL, STUNNED, DYING, RECOVER }

## The states the director's attack ids stand for.
const ATTACKS := {
	&"scythe": State.SCYTHE, &"blades": State.BLADES, &"storm": State.STORM, &"eruptions": State.ERUPTIONS,
	&"curse": State.CURSE, &"summon": State.SUMMON, &"dash": State.DASH_WARN,
}
const DEFS_DIR := "res://data/bosses/"
## His palette (Daniel, cycle 9): deep violet, spectral blue-green, a corrupted emerald (murkier and colder than
## Emeth's crystal green, Combat.EMETH), old gold, dark stone. SPECTRAL is his necromancy and the souls.
const SPECTRAL := Color(0.38, 1.55, 1.1)
## His entrance (GP-01): a ring of this radius on the floor and souls rising from this height (no column).
const ENTRANCE_RING := 4.5
const ENTRANCE_SOULS := 0.3
const VIOLET := Color(0.62, 0.22, 1.2)
const CORRUPT := Color(0.315, 0.7, 0.604)
## The curse: dark purple.
const CURSE_COLOR := Color(1.0, 0.22, 1.5)
## Walking to the middle for the ritual: times his speed, and at most this long.
const CENTER_SPEED := 1.6
const CENTER_TIME := 4.0
## The shield grows in and fades out this fast (per second); it flares to SHIELD_FLARE when it breaks.
const SHIELD_SPEED := 2.5
const SHIELD_FLARE := 2.2
## The shield's middle stands this share of its radius over the floor.
const SHIELD_RISE := 0.7
## Where his summons rise (rings and clearance) is his BossDef's (summon_ring, summon_clear, ritual_ring).
## The rune under a rising dead (m); its column is the summoning circle's (Ground.SUMMON_*).
const RUNE_RADIUS := 1.0
## The ritual's first dead begin to rise this soon after the shield (s).
const RITUAL_FIRST_RISE := 0.7
## The last phase: a wisp of his fire every this many seconds, and the portal's slow violet pulse (per second).
const FINAL_WISP := 0.35
const PORTAL_PULSE_HZ := 0.35
const PORTAL_PULSE_EVERY := 0.1
## In the last phase his edge turns to the corrupted green and burns this much brighter.
const CORRUPT_RIM := 1.8
## The ritual's ring breaking at the end: old gold (the hall's), never a saturated yellow.
const OLD_GOLD := Color(0.72, 0.58, 0.32)
## The paladin counts as standing still under this speed (m/s).
const STILL_SPEED := 0.6

## The scythe: the share of slash3 that is the lift (held through the wind-up), how long the blade takes to cross
## the half circle, how long its trail and ashes last after, and how often the gathering specks come.
const SCYTHE_CLIP := &"slash3"
const SCYTHE_LIFT := 0.42
const SCYTHE_SWEEP := 0.16
const SCYTHE_LIFE := 0.55
const GATHER_EVERY := 0.07
## The dash: how long its lane of wake stays after he lands.
const DASH_WAKE := 0.5
## The Blades of the Souls and the curse: where the hands are (m up, m ahead of his middle).
const HAND := Vector2(2.3, 0.9)

## The ending (game seconds, the fall's slow motion makes them a little longer): the blow, his magic coming undone,
## the corrupted power drawn back to the altar and its portal, Emeth answering, the hall's ritual broken. The
## paladin keeps his control all through; the end screen comes at VICTORY_TIME.
const VICTORY_TIME := 3.6
const VICTORY_FADE := Vector2(0.0, 1.3)
const VICTORY_STREAM := Vector2(0.5, 2.3)
const VICTORY_PORTAL := 2.3
const VICTORY_EMETH := 2.5
const VICTORY_RITUAL := 2.8
const VICTORY_CALM := 3.1
## The portal's sealing (Arena.seal_portal: his energy gathers from where he fell into it, a ring of light closes on
## its core, it calms to its own green and dims) runs this long and ends at VICTORY_CALM, before the end screen.
const VICTORY_SEAL := 2.4
## As he falls his glow goes out and his body darkens to stone (ART_REVIEW B1 of cycle 9: never a white body at his
## fall), quickly at first (eased out over VICTORY_DIM_TIME game seconds, so it shows inside the fall's slow motion):
## his colour times VICTORY_DIM, VICTORY_GREY of the way to grey, his painted glow, edge and pale crest to nothing.
const VICTORY_DIM := 0.55
const VICTORY_GREY := 0.5
const VICTORY_DIM_TIME := 0.3
## The radial blur of his fall's slow motion (Fx.slow_mo; it also lifts the bright parts of the screen: kept low).
const VICTORY_BLUR := 0.2

var game: Game
var def: BossDef
var e: Enemy
var director: BossDirector
var phase := 1
var state := State.ENTER
## Where the fight ends (the ending plays here).
var center := Vector2.ZERO
## The fight in numbers, for RESULT (Game.boss_stats): see _init_stats.
var stats := {}
var _middle := Vector2.ZERO
## The floor of his room (Arena.shape: the chamber's circle): his lanes and flights are cut at its edge.
var _floor: FloorShape
## How far the charge goes this time (cut at the floor's edge, never more than dash_length).
var _dash_len := 0.0
## He keeps his place until the next attack (the opener of a phase begun from the middle).
var _held := false
## The storm's lanes on the floor, by crescent (null once it left), for their order of leaving (Ground.storm_rank).
var _lanes: Array[Ground.Zone] = []
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
## The ritual's first dead (the shield breaks when they all fall; its reinforcements are not here) and every summon
## of his still counted.
var _raised: Array[Enemy] = []
## How many dead the ritual began with (those that break the shield).
var _ritual_total := 0
var _adds: Array[Enemy] = []
## The dead still to rise: {at, id, t (seconds left), ritual (raised by the ritual), counts (one of its first, that
## break the shield), rune}.
var _rising: Array[Dictionary] = []
## His shots still flying (he waits for them before the next attack).
var _shots: Array[Projectiles.Shot] = []
## The attack going on now (its warnings and shots carry it, for the hurt_by count) and the next one of a
## combination (&"": none).
var _attack: StringName = &""
var _chain: StringName = &""
## The opener of the phase still to come (&"": none).
var _opener: StringName = &""
## The recovery now: how long, and its pose.
var _recover_time := 0.0
var _recover_anim: StringName = &"idle"
var _punished := false
## The storm: when each crescent of the wave leaves (seconds of _t; < 0 once gone), and the wave.
var _due := PackedFloat32Array()
var _wave := 0
var _wave_at := 0.0
var _gather := 0.0
var _shield: BossShield
var _shield_power := 0.0
var _player_last := Vector2.ZERO
var _player_vel := Vector2.ZERO
var _still_t := 0.0
var _wisp := 0.0
var _pulse := 0.0
var _clock := 0.0
## His material's tint, grey and crest when he fell (the ending darkens him from there): [Color, float, float];
## empty before.
var _dim_from: Array = []
var _rng := RandomNumberGenerator.new()


func setup(g: Game, enemy_def: EnemyDef) -> void:
	game = g
	Dev.seed_rng(_rng, 3)
	var path := DEFS_DIR + String(enemy_def.id) + ".tres"
	def = load(path) as BossDef if ResourceLoader.exists(path) else BossDef.new()
	director = BossDirector.new(def)
	_floor = g.arena.shape()
	_middle = g.arena.resolve(_floor.center, enemy_def.radius)
	center = _middle
	# in his chamber he stands on the seal (Arena.boss_spawn); in a hall he comes down the steps under the door
	var at := g.arena.boss_spawn if g.arena.round_floor() else g.arena.door_pos + Vector2(0, Arena.STAIRS_DEPTH + enemy_def.radius)
	e = g.horde.spawn(enemy_def, at, false)
	e.dir = Vector2.DOWN
	e.hp = e.max_hp * Dev.num("boss-hp", 1.0)
	# --boss-hp starts him further down (dev): the phase of that life, without the ones before
	phase = BossRules.phase_for(e.hp / e.max_hp, def.thresholds)
	_ritual_done = phase > def.ritual_phase
	e.hp_floor = BossRules.hp_floor(phase, def.thresholds) * e.max_hp
	_player_last = g.player.pos
	_init_stats()
	# his chamber's scenery follows the fight (BossChamber.on_cue: the seal's five states, the veil)
	var room := g.arena.chamber
	if room != null and room.has_method(&"on_cue"):
		cue.connect(Callable(room, &"on_cue"))
		room.call(&"set_phase", phase)
	g.combat.enemy_struck.connect(_on_struck)
	g.horde.killed.connect(_on_killed)
	# his entrance stays on the floor (GP-01 of cycle C12c): the cyan column over him left him a black shape for a
	# second; a ring of his spectral light and souls at his feet, nothing at the height of his body
	g.fx.burst(&"soul", Vector3(e.pos.x, ENTRANCE_SOULS, e.pos.y))
	g.fx.ring(e.pos, ENTRANCE_RING, SPECTRAL, 0.7, 0.15, true)
	_shield = _make_shield()
	g.add_child(_shield)
	if phase >= def.final_light_phase:
		_corrupt()


## The fight in numbers (RESULT "boss"): time (s from his entrance to his fall), phase_at (when each phase began),
## phase_time (s in each phase), attacks (how many of each), hurt_by and hits_by (the paladin's life lost to each
## attack, and how many blows; "adds" for his dead), windows (recoveries) and punished (those the paladin struck
## him in), adds_total and adds_peak, ritual (s) and ritual_raised, curses, died_phase (the phase the paladin fell in).
func _init_stats() -> void:
	stats = {"time": 0.0, "phase_at": [], "phase_time": [], "max_phase": phase, "ritual": 0.0, "ritual_raised": 0,
		"adds_peak": 0, "adds_total": 0, "curses": 0, "attacks": {}, "hurt_by": {}, "hits_by": {}, "windows": 0,
		"punished": 0, "chains": 0, "died_phase": 0}
	game.boss_stats = stats


func step(dt: float) -> void:
	_clock += dt
	_step_shield(dt)
	if state == State.DYING:
		_step_dying(dt)
		return
	if e == null or not e.alive:
		return
	var was := game.horde.depth_in_target(e)
	stats.time = snappedf(_clock, 0.1)
	_t += dt
	_cooldown -= dt
	_stagger_t -= dt
	if _stagger_t <= 0.0:
		_stagger = 0
	director.step(dt)
	_track_player(dt)
	_step_rising(dt)
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
		_step_final(dt)
	match state:
		State.ENTER:
			# in a hall he walks down from the door; in his chamber he already stands on the seal
			if not game.arena.round_floor():
				e.pos += Vector2.DOWN * 3.2 * dt
			_anim(&"idle" if game.arena.round_floor() else &"walk")
			if _t > 2.4:
				game.hud.show_notice(T.t("boss_phase_%d" % phase), 2.5)
				if phase == def.ritual_phase and not _ritual_done:
					# begun in the ritual's phase (--boss-hp): its name promises the ritual, so it runs (BUG-010)
					_go(State.TO_CENTER)
				else:
					_rest(0.6)
		State.CHASE:
			e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0))
			if to.length() > def.scythe_reach * 0.7 and not _held:
				e.pos += toward * e.def.speed * (1.0 + 0.08 * (phase - 1)) * dt
				_anim(&"walk")
			else:
				_anim(&"idle")
			if _cooldown <= 0.0 and game.player.alive() and not _shots_flying():
				_choose(to.length())
		State.SCYTHE:
			_step_scythe(dt, to, toward)
		State.BLADES:
			_step_blades(dt)
		State.STORM:
			_step_storm()
		State.ERUPTIONS:
			_step_eruptions()
		State.CURSE:
			_step_curse(dt)
		State.SUMMON:
			_step_summon()
		State.DASH_WARN:
			_step_dash_warn(dt, toward)
		State.DASH:
			_step_dash()
		State.RECOVER:
			_step_recover()
		State.ROAR:
			_anim(&"roar")
			if _t >= def.roar_time:
				if (phase == def.ritual_phase and not _ritual_done) or def.center_phases.has(phase):
					_go(State.TO_CENTER)
				else:
					_rest(0.4)
		State.TO_CENTER:
			var way := _middle - e.pos
			_anim(&"walk")
			if way.length() > 0.6 and _t < CENTER_TIME:
				e.dir = e.dir.slerp(way.normalized(), minf(1.0, dt * 8.0))
				e.pos += way.normalized() * minf(way.length(), e.def.speed * CENTER_SPEED * dt)
			elif phase == def.ritual_phase and not _ritual_done:
				_start_ritual()
			else:
				# the phase opens from the middle (BossDef.center_phases): he stands there through the rest a roar
				# always had (0.4 more than the phase's), then opens from there
				_rest(0.4)
				_held = true
		State.RITUAL:
			_step_ritual(dt, toward)
		State.STUNNED:
			_anim(&"stunned")
			e.stun_t = 0.1
			if _t >= _stun_time:
				_stagger = 0
				e.armor = e.max_armor
				_rest(0.5)
	# he stops at the paladin's body like everyone (his charge goes through: it is the blow)
	if state != State.DASH:
		game.horde.keep_off_target(e, was, dt)
	e.pos = game.arena.resolve(e.pos, e.def.radius)
	# where he stands, for the scenery that opens around him (masonry.gdshader's see_through)
	RenderingServer.global_shader_parameter_set(&"boss_pos", Vector3(e.pos.x, 0.0, e.pos.y))


# ---------- choosing ----------

func _choose(dist: float) -> void:
	_held = false
	var blocked: Array[StringName] = []
	if _call_room(def.summon_raise.size(), BossRules.adds_cap(def.adds_cap, phase)) <= 0:
		blocked.append(&"summon")
	if game.player.curse.active() or game.player.curse.immune_left > 0.0:
		blocked.append(&"curse")
	# the charge only when it has room to run before the floor's edge (dash_min_free)
	if _dash_room(game.player.pos - e.pos) < def.dash_min_free:
		blocked.append(&"dash")
	var id := director.choose(phase, dist, _still_t, blocked, _rng)
	var chained := false
	# a new phase opens on its own pattern; a combination goes on with its second blow (if the moment allows it)
	for forced: StringName in [_opener, _chain]:
		if forced != &"" and director.valid(phase, dist, blocked, 1).any(func(a: BossAttack) -> bool: return a.id == forced):
			chained = forced == _chain
			id = forced
			break
	_opener = &""
	_chain = &""
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
	if chained:
		stats.chains = int(stats.chains) + 1
	_attack = id
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


## How far a lane of his reaches from him along `dir` before the floor's edge (at most `length`): his warnings end
## there and never paint the abyss.
func _lane(dir: Vector2, length: float) -> float:
	return maxf(_floor.cut(e.pos, dir, length), 0.5)


## How far his charge could run toward `way` before his body meets the floor's edge.
func _dash_room(way: Vector2) -> float:
	return _floor.cut(e.pos, way, def.dash_length, e.def.radius) if way.length() > 0.01 else 0.0


# ---------- the attacks ----------

## The Sepulchral Scythe: walks in, lifts the blade (the first share of slash3, held through the wind-up while his
## violet gathers at it) over half a circle on the floor, sweeps it across exactly that half circle (Fx.boss_scythe:
## violet with blue-green edges, a short trail, ashes where it passed), and stands spent for scythe_recovery.
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
			var windup := _windup(def.scythe_windup)
			_warn(game.ground.add_arc_warning(e.pos, _dir, def.scythe_reach, def.scythe_degrees, windup, def.scythe_damage))
			moment.emit(&"scythe_warn")
			cue.emit(&"scythe_raise", e.pos, _dir, def.scythe_reach, windup)
			Audio.play(&"scythe_raise")
		1:
			var windup := _windup(def.scythe_windup)
			var k := clampf((_t - _mark) / windup, 0.0, 1.0)
			# the lift, slowed to the wind-up: the blade is highest when the warning fills
			_pose(SCYTHE_CLIP, SCYTHE_LIFT * (1.0 - pow(1.0 - k, 2.0)))
			# the blade starts on his left of the sweep: his magic gathers there, close to him (never on the paladin)
			_gathering(dt, e.pos + _dir.rotated(-PI * 0.5) * 1.1, VIOLET)
			if _t - _mark >= windup:
				_step = 2
				_mark = _t
				_pose(SCYTHE_CLIP, SCYTHE_LIFT)
				game.fx.boss_scythe(e.pos, _dir, def.scythe_reach, def.scythe_degrees, SCYTHE_SWEEP, SCYTHE_LIFE, VIOLET, SPECTRAL)
				game.fx.shake(2.0)
				game.fx.kick(_dir, 0.6)
				Audio.play(&"scythe")
				moment.emit(&"scythe_strike")
				cue.emit(&"scythe_sweep", e.pos, _dir, def.scythe_reach, SCYTHE_SWEEP)
		2:
			# the rest of the clip at its own pace: the follow-through
			_play_on(SCYTHE_CLIP, SCYTHE_LIFT)
			if _t - _mark >= SCYTHE_SWEEP:
				_scythe_ashes()
				_recover(def.scythe_recovery - SCYTHE_SWEEP, SCYTHE_CLIP, SCYTHE_SWEEP)


## Where the blade passed: ashes of violet and blue-green rise from inside the half circle (never past its edge),
## and the stone takes the blow at the far middle of the arc.
func _scythe_ashes() -> void:
	var half := deg_to_rad(def.scythe_degrees) * 0.5
	for i in 7:
		var a := -half + 2.0 * half * (i + 0.5) / 7.0
		var r := def.scythe_reach * _rng.randf_range(0.55, 0.85)
		var at := e.pos + _dir.rotated(a) * r
		game.fx.chips(Vector3(at.x, 0.35, at.y), Vector3.UP, VIOLET if i % 2 == 0 else SPECTRAL, 2, 1.6, 0.12, 0.6, 0.5)
	var far := e.pos + _dir * def.scythe_reach * 0.8
	game.fx.burst(&"dust", Vector3(far.x, 0.2, far.y))
	cue.emit(&"scythe_land", far, _dir, def.scythe_reach, 0.0)
	Audio.play(&"scythe_land")


## The Blades of the Souls: two crescents part from him, one at the paladin (with a little lead), the other
## blade_spread degrees aside; both lanes are on the floor for blade_windup while the souls gather in his hands.
func _step_blades(dt: float) -> void:
	var windup := _windup(def.blade_windup)
	if _step == 0:
		_step = 1
		var aim := _aim(def.blade_speed)
		_dirs = BossRules.soul_pair(aim, def.blade_spread, 1.0 if _rng.randf() < 0.5 else -1.0)
		e.dir = (_dirs[0] + _dirs[1]).normalized()
		for d in _dirs:
			_warn(game.ground.add_line_warning(e.pos, d, _lane(d, def.blade_range), def.blade_width, windup, 0.0))
		_anim(&"dash_windup")
		cue.emit(&"blades_gather", e.pos, e.dir, def.blade_range, windup)
	elif _step == 1:
		_gathering(dt, e.pos + e.dir * HAND.y, SPECTRAL)
		if _t >= windup:
			_step = 2
			_fire_souls(_dirs, def.blade_damage)
			moment.emit(&"blades_fire")
			cue.emit(&"blades_release", e.pos, e.dir, def.blade_range, 0.0)
			_pose(&"slash2", 0.0)
			_recover(def.blade_recovery, &"slash2")


## The Storm of the Six Souls: storm_count crescents all around (never closing every way out), each leaving in turn
## (storm_stagger apart, nearest the aim first, each lane warned until its own crescent leaves), then a second wave
## turned storm_turn degrees after storm_gap seconds.
func _step_storm() -> void:
	var windup := _windup(def.storm_windup)
	if _due.is_empty() and _wave < def.storm_waves and _t >= _wave_at:
		var aim := _aim(def.blade_speed)
		var offset := rad_to_deg(aim.angle()) + def.storm_turn * _wave
		_dirs = BossRules.storm(def.storm_count, offset, def.storm_jitter, def.storm_min_gap, _rng)
		var order := BossRules.storm_order(_dirs, aim)
		var wedges := GroundLook.storm_wedges(_dirs)
		_due.resize(_dirs.size())
		_lanes.clear()
		_lanes.resize(_dirs.size())
		for rank in order.size():
			var i := order[rank]
			var wait := windup + def.storm_stagger * rank
			_due[i] = _t + wait
			_lanes[i] = _warn(game.ground.add_line_warning(e.pos, _dirs[i], _lane(_dirs[i], def.blade_range), def.blade_width, wait, 0.0))
			# its order of leaving: rank + 1 marks at its root, the next to leave the brightest (ART-001)
			game.ground.storm_rank(_lanes[i], rank + 1, rank)
			game.ground.storm_wedge(_lanes[i], wedges[i])
		_anim(&"rain")
		game.fx.ring(e.pos, 3.0, VIOLET, 0.5, 0.15, true)
		game.fx.burst(&"soul", Vector3(e.pos.x, 2.5, e.pos.y))
		cue.emit(&"storm_wave", e.pos, aim, float(_dirs.size()), windup)
		return
	if _due.is_empty():
		if _wave >= def.storm_waves:
			_recover(def.storm_recovery, &"roar")
		return
	var left := 0
	for i in _due.size():
		if _due[i] < 0.0:
			continue
		if _t >= _due[i]:
			if not _due.has(-1.0):
				# the first soul of the wave leaves: he throws them (VX-14; only the pose, nothing is timed on it)
				_pose(&"volley", 0.0)
			_due[i] = -1.0
			_lanes[i] = null
			_fire_soul(_dirs[i], def.storm_damage)
			cue.emit(&"storm_blade", e.pos + _dirs[i] * 0.8, _dirs[i], def.blade_width, 0.0)
		else:
			left += 1
	# the lanes still waiting step up: the next to leave is always drawn the brightest
	var waiting := 0
	for i in _storm_queue():
		game.ground.storm_rank(_lanes[i], -1, waiting)
		waiting += 1
	if left == 0:
		_wave += 1
		_wave_at = _t + def.storm_gap
		_due.clear()
		moment.emit(&"storm_fire")
		_pose(&"roar", 0.0)
		game.fx.shake(2.0)


func _fire_souls(dirs: PackedVector2Array, damage: float) -> void:
	for d in dirs:
		_fire_soul(d, damage)
	game.fx.shake(1.2)


## The storm's lanes still waiting, the next to leave first.
func _storm_queue() -> Array[int]:
	var out: Array[int] = []
	for i in _due.size():
		if _due[i] >= 0.0 and i < _lanes.size() and _lanes[i] != null:
			out.append(i)
	out.sort_custom(func(a: int, b: int) -> bool: return _due[a] < _due[b])
	return out


## One crescent: it flies blade_range meters, or until it crosses the floor's edge by soul_overrun (it comes undone
## there, never flying on over the abyss).
func _fire_soul(d: Vector2, damage: float) -> void:
	var from := e.pos + d * 0.8
	var reach := maxf(_floor.cut(from, d, def.blade_range, -def.soul_overrun), 1.0)
	var s := game.projectiles.fire_soul(from, d, def.blade_speed, damage, def.blade_width, reach, SPECTRAL)
	s.source = _attack
	_shots.append(s)
	var at := e.pos + d * 1.2
	game.fx.chips(Vector3(at.x, Projectiles.SOUL_HEIGHT, at.y), Vector3(d.x, 0.2, d.y), VIOLET, 3, 4.0, 0.12, 0.3, 0.4)
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
	if _t >= beat * def.eruption_sequences - def.eruption_gap:
		_recover(def.eruption_recovery, &"idle")


func _erupt() -> void:
	var n := _rng.randi_range(def.eruption_count.x, maxi(def.eruption_count.x, def.eruption_count.y))
	for at in BossRules.eruptions(game.player.pos, n, def.eruption_radius, _middle, def.eruption_lane, _floor, _rng):
		var z := game.ground.add_warning(at, def.eruption_radius, _windup(def.eruption_delay), def.eruption_damage, SPECTRAL)
		z.eruption = true
		z.source = &"eruptions" if state != State.RITUAL else &"ritual"
	Audio.play(&"eruption")


## The curse: he raises his hand in a thin ring of dark purple while it gathers there, the lane of the bolt shows
## on the floor, a wave of corrupted energy leaves his hand with the bolt, and the bolt follows the paladin a little
## (curse_turn degrees a second for curse_homing seconds). A dodge passes through it. Where it lands: on_cursed.
func _step_curse(dt: float) -> void:
	var windup := _windup(def.curse_windup)
	if _step == 0:
		_step = 1
		_dir = _aim(def.curse_speed)
		e.dir = _dir
		_warn(game.ground.add_line_warning(e.pos, _dir, _lane(_dir, def.curse_speed * def.curse_homing), 1.4, windup, 0.0))
		game.fx.ring(e.pos, 2.4, Color(0.55, 0.15, 0.8), windup, 0.15, true)
		game.fx.burst(&"curse", Vector3(e.pos.x, 2.6, e.pos.y))
		_anim(&"summon")
		Audio.play(&"curse")
		cue.emit(&"curse_gather", e.pos + _dir * HAND.y, _dir, 2.4, windup)
	elif _step == 1:
		_gathering(dt, e.pos + _dir * HAND.y, CURSE_COLOR)
		if _t >= windup:
			_step = 2
			var aim := _aim(def.curse_speed)
			var s := game.projectiles.fire_curse(e.pos + _dir * 1.6, aim, def.curse_speed, def.curse_damage, def.curse_radius,
				def.curse_life, def.curse_turn, def.curse_homing, CURSE_COLOR)
			s.source = &"curse"
			_shots.append(s)
			# the wave leaves his hand along the bolt's way (inside its lane)
			var at := e.pos + aim * 1.6
			game.fx.chips(Vector3(at.x, HAND.x * 0.6, at.y), Vector3(aim.x, 0.1, aim.y), CURSE_COLOR, 8, 6.0, 0.14, 0.35, 0.25)
			game.fx.burst(&"curse", Vector3(at.x, 1.4, at.y), Vector3(aim.x, 0, aim.y))
			_pose(&"volley", 0.0)
			Audio.play(&"curse_release")
			cue.emit(&"curse_release", at, aim, def.curse_speed * def.curse_homing, 0.0)
			_recover(def.curse_recovery, &"volley")


## The curse took hold (Game._on_status_player): a thin ring of it on the floor at the paladin's feet (on the
## stone, never over him; his own look and the HUD are the hero's and the HUD's).
func on_cursed() -> void:
	stats.curses = int(stats.curses) + 1
	var p := game.player.pos
	game.fx.ring(p, 1.4, CURSE_COLOR, 0.45, 0.08, true)
	cue.emit(&"curse_land", p, Vector2.ZERO, 0.0, def.curse_time)
	moment.emit(&"cursed")


## A few of his dead rise around him, one by one (a rune on each spot first), never past the phase's ceiling.
func _step_summon() -> void:
	_anim(&"summon")
	if _step == 0:
		_step = 1
		_call(def.summon_raise, e.pos, def.summon_ring, BossRules.adds_cap(def.adds_cap, phase), def.summon_windup, false)
		Audio.play(&"summon")
	elif _step == 1 and _t >= def.summon_windup + def.rise_stagger * maxi(0, def.summon_raise.size() - 1):
		_recover(0.8, &"summon")


## The paladin keeps away: he crouches with the lane of the charge on the floor (the way shown by his magic
## streaming along it at his feet), charges, leaves a wake that covers that lane only, and lands spent.
func _step_dash_warn(dt: float, toward: Vector2) -> void:
	_anim(&"dash_windup")
	var windup := _windup(def.dash_windup)
	if _step == 0:
		_step = 1
		_dir = toward
		e.dir = _dir
		# the charge stops where his body meets the floor's edge; its lane goes on to the edge (his body's front)
		_dash_len = maxf(_dash_room(_dir), 0.5)
		_warn(game.ground.add_line_warning(e.pos, _dir, _lane(_dir, _dash_len + e.def.radius), def.dash_width, windup, def.dash_damage))
		cue.emit(&"dash_aim", e.pos, _dir, _dash_len, windup)
		Audio.play(&"dash_aim")
	_gather -= dt
	if _gather <= 0.0:
		_gather = GATHER_EVERY * 1.5
		var at := e.pos + _dir * 1.0 + _dir.orthogonal() * _rng.randf_range(-0.6, 0.6) * def.dash_width * 0.5
		game.fx.chips(Vector3(at.x, 0.25, at.y), Vector3(_dir.x, 0.0, _dir.y), VIOLET, 1, 7.0, 0.1, 0.35, 0.08)
	if _t >= windup:
		_from = e.pos
		_go(State.DASH)
		game.fx.boss_dash(_from, _dir, _dash_len, def.dash_width, def.dash_time, def.dash_time + DASH_WAKE, VIOLET, SPECTRAL)
		Audio.play(&"boss_dash")
		cue.emit(&"dash_go", _from, _dir, _dash_len, def.dash_time)


func _step_dash() -> void:
	_anim(&"dash")
	e.pos = _from + _dir * _dash_len * minf(_t / def.dash_time, 1.0)
	if _t >= def.dash_time:
		# the landing, inside the end of the lane
		var end := e.pos - _dir * def.dash_width * 0.5
		game.fx.ring(end, def.dash_width * 0.5, VIOLET, 0.3, 0.12)
		game.fx.burst(&"dust", Vector3(e.pos.x, 0.2, e.pos.y))
		game.fx.shake(2.5)
		game.fx.kick(_dir, 0.8)
		Audio.play(&"dash_land")
		cue.emit(&"dash_land", e.pos, _dir, def.dash_width, 0.0)
		_recover(def.dash_recovery, &"dash")


## Specks of his magic drawn into a point close to him (the hand or the blade) during a wind-up.
func _gathering(dt: float, at: Vector2, color: Color) -> void:
	_gather -= dt
	if _gather > 0.0:
		return
	_gather = GATHER_EVERY
	var from := at + Vector2.from_angle(_rng.randf() * TAU) * 0.9
	var into := Vector3(at.x - from.x, 0.4, at.y - from.y)
	game.fx.chips(Vector3(from.x, HAND.x * 0.8, from.y), into, color, 1, 3.0, 0.1, 0.3, 0.2)


# ---------- recoveries and combinations ----------

## The attack is spent: he stands in its pose for `seconds` (the window to punish him, counted in stats), then
## rests or goes on with the second blow of a combination. played: seconds of its clip already played.
func _recover(seconds: float, anim: StringName, played: float = 0.0) -> void:
	var was := _attack
	_go(State.RECOVER)
	_mark = -played
	_attack = was
	_recover_time = maxf(0.0, seconds)
	_recover_anim = anim
	_punished = false
	stats.windows = int(stats.windows) + 1
	_chain = director.follow_up(was, phase, _rng)


func _step_recover() -> void:
	if _recover_anim == SCYTHE_CLIP:
		_play_on(SCYTHE_CLIP, SCYTHE_LIFT)
	elif _t > _recover_time * 0.6:
		_anim(&"idle")
	else:
		_anim(_recover_anim)
	if _t < _recover_time:
		return
	if _chain != &"" and BossRules.chain_ready(_warnings_live(), 1 if _shots_flying() else 0):
		_cooldown = def.chain_rest
		_go(State.CHASE)
	elif _chain != &"":
		# wait for the first blow to be gone (its shots, its warnings): then the second keeps its whole warning
		return
	else:
		_rest()


## His warnings still on the floor.
func _warnings_live() -> int:
	var n := 0
	for z in game.ground.zones:
		if z.kind == Ground.Kind.WARNING and z.power > 0.0 and z.source != &"" and z.source != &"adds":
			n += 1
	return n


func _warn(z: Ground.Zone) -> Ground.Zone:
	z.source = _attack
	game.ground.sign_boss(z)
	return z


# ---------- his dead ----------

## Calls up to ids.size() of his dead around a point, one by one: a rune on each spot (first after `first` seconds,
## then rise_stagger apart), under the ceiling `cap` standing (the rising count) and the fight's adds_total_cap.
## ritual: raised by the ritual (they go when it ends); counts: they are the ones whose fall breaks the shield.
func _call(ids: Array[StringName], around: Vector2, radius: float, cap: int, first: float, ritual: bool, counts: bool = false) -> int:
	var n := _call_room(ids.size(), cap)
	if n <= 0 or ids.is_empty():
		return 0
	var spots := _ring_spots(around, radius, n)
	var times := BossRules.rise_times(spots.size(), first, def.rise_stagger)
	for i in spots.size():
		# his ritual circle of summoning (Ground.Rune.SUMMON): it fills for times[i], then its low column rises as the
		# dead stands up (_raise; the same moment, the same step count). The zone only draws: _rising times the rise,
		# and ends it if the dead stays down (_end_ritual).
		var z := game.ground.rune_burst(spots[i], RUNE_RADIUS, times[i], Ground.Rune.SUMMON)
		if z != null:
			z.source = &"adds"
		_rising.append({"at": spots[i], "id": ids[i % ids.size()], "t": times[i], "ritual": ritual, "counts": counts, "rune": z})
		cue.emit(&"rune", spots[i], Vector2.ZERO, RUNE_RADIUS, times[i])
	return spots.size()


## How many of `want` may be called now: his ceiling (those rising count), the fight's and the hall's.
func _call_room(want: int, cap: int) -> int:
	var n := BossRules.reinforce_room(want, _standing(_adds), _rising.size(), cap, int(stats.adds_total) + _rising.size(), def.adds_total_cap)
	return mini(n, game.horde.room_for(n + _rising.size()) - _rising.size()) if n > 0 else 0


func _step_rising(dt: float) -> void:
	var i := _rising.size() - 1
	while i >= 0:
		var r: Dictionary = _rising[i]
		r.t = float(r.t) - dt
		if float(r.t) <= 0.0:
			_rising.remove_at(i)
			var add := _raise(r.id, r.at)
			if r.counts:
				_raised.append(add)
		i -= 1


func _raise(id: StringName, at: Vector2) -> Enemy:
	var add := game.horde.spawn(game.horde.def(id), at, true)
	_adds.append(add)
	stats.adds_total += 1
	# no beam here: the summoning circle's own column rises at this moment (Ground._dissolve, SUMMON_*)
	game.fx.burst(&"soul", Vector3(at.x, 0.4, at.y))
	cue.emit(&"rise", at, Vector2.ZERO, RUNE_RADIUS, 0.0)
	Audio.play(&"rise")
	return add


static func _standing(list: Array[Enemy]) -> int:
	var n := 0
	for a in list:
		if a.alive:
			n += 1
	return n


## The ritual's first dead still to rise (they count as standing: the shield cannot break before they are up).
func _rising_ritual() -> int:
	var n := 0
	for r in _rising:
		if r.counts:
			n += 1
	return n


## Of the dead that break the ritual's shield, how many are still standing or rising (0 outside the ritual).
func ritual_left() -> int:
	if state != State.RITUAL:
		return 0
	return _standing(_raised) + _rising_ritual()


## How many dead the ritual began with (those that break the shield; 0 before the first ritual).
func ritual_total() -> int:
	return _ritual_total


## n spots on a ring around a point, never close to the paladin, each with its whole rune on the floor (its middle
## RUNE_RADIUS inside the edge: the dead and its circle never stand over the abyss).
func _ring_spots(around: Vector2, radius: float, n: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	var from := _rng.randf() * TAU
	var p := game.player.pos
	var keep := maxf(RUNE_RADIUS, 0.6)
	for i in n:
		var at := game.arena.resolve(around + Vector2.from_angle(from + TAU * i / maxi(n, 1)) * radius, keep)
		if at.distance_to(p) < def.summon_clear:
			var away := (at - p).normalized() if at.distance_to(p) > 0.1 else Vector2.from_angle(from)
			at = game.arena.resolve(p + away * def.summon_clear, keep)
		out.append(at)
	return out


# ---------- the ritual ----------

func _start_ritual() -> void:
	_go(State.RITUAL)
	_attack = &"ritual"
	e.invulnerable = true
	e.burn_t = 0.0  # a fire laid on him before the ward would glow through it (Combat.hit_enemy no longer feeds it)
	_ritual_t = 0.0
	_ritual_quake = 2.0
	_ritual_more = def.ritual_reinforce_every
	_raised.clear()
	# only these first dead break the shield (BUG-002 of cycle 10): the reinforcements press, they never count
	_ritual_total = _call(def.ritual_raise, e.pos, def.ritual_ring, def.ritual_cap, RITUAL_FIRST_RISE, true, true)
	ritual_changed.emit(ritual_left(), _ritual_total)
	game.fx.ring(e.pos, def.shield_radius * 2.0, SPECTRAL, 0.6, 0.15, true)
	# no pillar of light over him (it hid him, ART-005): the shield raises its own faint curtain around him (BossShield)
	Audio.play(&"shield_up")
	Audio.play(&"summon")
	moment.emit(&"ritual")
	cue.emit(&"shield_up", e.pos, Vector2.ZERO, def.shield_radius, 0.0)


## Behind the shield: his dead rise one by one and fight, the floor erupts every ritual_eruption_every seconds and
## more rise every ritual_reinforce_every (never past ritual_cap standing). Over when its first dead all fall (the
## reinforcements do not count) or the time runs out.
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
		if _call(def.ritual_reinforce, e.pos, def.ritual_ring, def.ritual_cap, def.summon_windup, true, false) > 0:
			Audio.play(&"summon")
	if BossRules.ritual_over(_ritual_t, def.ritual_time, _raised.size(), _standing(_raised), _rising_ritual()):
		_end_ritual()


func _end_ritual() -> void:
	_ritual_done = true
	e.invulnerable = false
	_record_ritual()
	# the dead not yet up stay down, and their runes go
	for i in range(_rising.size() - 1, -1, -1):
		if _rising[i].ritual:
			Ground.end_zone(_rising[i].rune)
			_rising.remove_at(i)
	_shield_power = SHIELD_FLARE
	game.fx.ring(e.pos, def.shield_radius * 2.4, SPECTRAL, 0.5, 0.15, true)
	game.fx.burst(&"soul", Vector3(e.pos.x, 2.0, e.pos.y))
	game.fx.shake(3.0)
	game.hud.show_notice(T.t(&"boss_ritual_end"), 2.0)
	Audio.play(&"shield_down")
	cue.emit(&"shield_break", e.pos, Vector2.ZERO, def.shield_radius, 0.0)
	moment.emit(&"ritual_end")
	_stun(def.ritual_stun)
	ritual_changed.emit(0, _ritual_total)


## The ritual's numbers for RESULT (also when the paladin falls inside it): seconds it lasted, how many of its
## first dead rose.
func _record_ritual() -> void:
	stats.ritual = snappedf(_ritual_t, 0.1)
	stats.ritual_raised = _raised.size()


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
		_shield.position = Vector3(e.pos.x, def.shield_radius * SHIELD_RISE, e.pos.y)
		_shield.scale = Vector3.ONE * (0.6 + 0.4 * minf(_shield_power, 1.0) + 0.15 * maxf(0.0, _shield_power - 1.0))
		(_shield.material_override as ShaderMaterial).set_shader_parameter(&"power", _shield_power)


## The ritual's shield (BossShield: spectral glass, his circle of runes under it, orbiting motes), hidden until the
## ritual; _step_shield drives it by its material's `power` (0..1 growing in, over 1 when it breaks: it shatters).
func _make_shield() -> BossShield:
	return BossShield.create(def.shield_radius)


# ---------- phases, stagger, the fall ----------

## A threshold is crossed: whatever he was doing stops (its warnings and shots go), he roars (a short change of
## pose, his magic rising around him, a violet wave on the floor, the phase's sound and name) and the next phase
## begins on its own pattern (BossDef.phase_openers). No white flash.
func _change_phase(next: int) -> void:
	phase = next
	stats.max_phase = phase
	(stats.phase_at as Array).append(snappedf(_clock, 0.1))
	e.hp_floor = BossRules.hp_floor(phase, def.thresholds) * e.max_hp
	_cancel()
	_go(State.ROAR)
	_opener = director.opener(phase)
	_chain = &""
	game.fx.shake(4.0)
	game.fx.hit_stop(90)
	game.fx.kick_split(1.0)
	game.fx.ring(e.pos, 9.0, VIOLET, 0.7, 0.15, true)
	game.fx.ring(e.pos, 4.5, SPECTRAL, 0.5, 0.15, true)
	# no light column here: Fx.beam mixes toward white at its core (a white flash); rings and souls carry the change
	for k in 3:
		var at := e.pos + Vector2.from_angle(TAU * k / 3.0 + _clock) * 1.2
		game.fx.burst(&"soul", Vector3(at.x, 1.5 + k * 0.6, at.y))
	game.hud.show_notice(T.t("boss_phase_%d" % phase), 3.0)
	Audio.play(&"roar")
	Audio.play(&"phase_shift")
	cue.emit(&"phase_shift", e.pos, Vector2.ZERO, float(phase), def.roar_time)
	# the roar throws the paladin back, out of the king's reach
	var away := (game.player.pos - e.pos).normalized()
	game.player.place(game.player.pos + away * def.roar_push)
	if phase >= def.final_light_phase:
		_corrupt()
	phase_changed.emit(phase)
	moment.emit(&"phase")


## The last phase: the portal behind him burns with his fire, unsteady (a slow violet pulse through his spectral
## green), and he is more corrupted (his edge in the corrupted green, burning brighter).
func _corrupt() -> void:
	game.arena.open_door(SPECTRAL)
	game.arena.final_phase(true)
	var mat := _material()
	if mat:
		mat.set_shader_parameter(&"rim_color", CORRUPT)
		mat.set_shader_parameter(&"rim_power", e.def.rim * CrowdRenderer.PAINT_RIM * CORRUPT_RIM)


func _step_final(dt: float) -> void:
	_wisp -= dt
	if _wisp <= 0.0:
		_wisp = FINAL_WISP
		game.fx.burst(&"soul", Vector3(e.pos.x + _rng.randf_range(-0.8, 0.8), _rng.randf_range(0.5, 3.5), e.pos.y + _rng.randf_range(-0.8, 0.8)))
	_pulse -= dt
	if _pulse <= 0.0:
		_pulse = PORTAL_PULSE_EVERY
		var k := 0.5 + 0.5 * sin(TAU * PORTAL_PULSE_HZ * _clock)
		game.arena.open_door(SPECTRAL.lerp(VIOLET, k * k))


## His look (one material for every Morvath on screen: there is only him).
func _material() -> ShaderMaterial:
	if game.horde.renderer == null or e == null:
		return null
	return game.horde.renderer.kind(e.def).material as ShaderMaterial


## Everything he set going stops: his warnings on the floor, the shots in the air, the dead not yet risen.
func _cancel() -> void:
	game.projectiles.clear_hostile()
	game.ground.clear_warnings()
	_shots.clear()
	_rising.clear()
	_due.clear()


## His armor broke: he staggers, and stands up armored again.
func break_armor() -> void:
	if state == State.STUNNED or state == State.DYING or state == State.RITUAL:
		return
	_stun(def.stagger_time)


## A blow of the paladin landed on him: a recovery he was punished in, and from stagger_from_phase on, heavy blows
## stagger the king.
func _on_struck(target: Enemy, tags: Array[StringName], _damage: float) -> void:
	if target != e:
		return
	if state == State.RECOVER and not _punished:
		_punished = true
		stats.punished = int(stats.punished) + 1
	if phase < def.stagger_from_phase or state in [State.STUNNED, State.ROAR, State.RITUAL, State.TO_CENTER, State.DYING]:
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
	# his palette, never the yellow light of Elun's boons: souls knocked loose and violet chips
	game.fx.burst(&"soul", Vector3(e.pos.x, 2.5, e.pos.y))
	game.fx.chips(Vector3(e.pos.x, 2.5, e.pos.y), Vector3.UP, VIOLET, 6, 3.0, 0.14, 0.45, 0.35)
	game.fx.word(Vector3(e.pos.x, 5.0, e.pos.y), T.t(&"word_stagger"), SPECTRAL)
	Audio.play(&"stagger")


## The paladin lost life to something of this fight (Game._on_hit_player): counted by its source.
func record_hurt(source: StringName, amount: float) -> void:
	var id := source if source != &"" else &"adds"
	var hurt: Dictionary = stats.hurt_by
	var hits: Dictionary = stats.hits_by
	hurt[id] = int(hurt.get(id, 0)) + roundi(amount)
	hits[id] = int(hits.get(id, 0)) + 1


## The paladin fell: the phase he fell in, and how long each phase took.
func record_death() -> void:
	stats.died_phase = phase
	stats.phase_time = BossRules.phase_times(stats.phase_at, _clock)
	if state == State.RITUAL:
		_record_ritual()


## He falls: nothing of his outlives him (shots, warnings, summons, the shield, the curse on the paladin), and the
## ending begins (_step_dying).
func _on_killed(dead: Enemy) -> void:
	if dead != e:
		if state == State.RITUAL and _raised.has(dead):
			ritual_changed.emit(ritual_left(), _ritual_total)
		return
	state = State.DYING
	_t = 0.0
	_step = 0
	center = e.pos
	e.invulnerable = false
	# no flash, no fire or frost glowing on him as he falls (BUG-004)
	e.flash_t = 0.0
	e.burn_t = 0.0
	e.frozen_t = 0.0
	var look := _material()
	if look:
		_dim_from = [look.get_shader_parameter(&"tint"), float(look.get_shader_parameter(&"desaturate")), float(look.get_shader_parameter(&"crest"))]
	stats.time = snappedf(_clock, 0.1)
	stats.phase_time = BossRules.phase_times(stats.phase_at, _clock)
	_cancel()
	game.ground.clear()
	game.horde.clear_crowd.call_deferred()
	_adds.clear()
	_raised.clear()
	game.player.curse.clear()
	game.fx.hit_stop(120)
	game.fx.slow_mo(0.3, 0.35, 0.5, 1.05, VICTORY_BLUR)
	game.fx.shake(5.0)
	game.fx.kick_split(1.0)
	game.fx.ring(center, 3.0, VIOLET, 0.4, 0.15, true)
	Audio.play(&"boss_down")
	Audio.music(&"")
	cue.emit(&"victory_blow", center, Vector2.ZERO, 0.0, VICTORY_TIME)
	moment.emit(&"victory")


## The ending, VICTORY_TIME long: his magic comes undone (his glow fades, his spectral wisps fall away), the
## corrupted power streams back to the altar and its portal (VICTORY_STREAM), the portal takes it and calms to its
## own green, Emeth shines emerald in the paladin's hand, the hall's ritual breaks. What seals him is not said here
## (Daniel's question): only that his power is contained and drawn back.
func _step_dying(dt: float) -> void:
	var before := _t
	_t += dt
	var crossed := func(at: float) -> bool: return before < at and _t >= at
	var portal := game.arena.door_pos
	var fade := clampf((_t - VICTORY_FADE.x) / (VICTORY_FADE.y - VICTORY_FADE.x), 0.0, 1.0)
	var dim := 1.0 - pow(1.0 - clampf(_t / VICTORY_DIM_TIME, 0.0, 1.0), 3.0)
	var mat := _material()
	if mat:
		mat.set_shader_parameter(&"paint_glow", lerpf(CrowdRenderer.PAINT_GLOW * e.def.shine, 0.0, dim))
		mat.set_shader_parameter(&"rim_power", lerpf(e.def.rim * CrowdRenderer.PAINT_RIM, 0.0, dim))
		if not _dim_from.is_empty():
			var tint: Color = _dim_from[0]
			var dark := Color(tint.r * VICTORY_DIM, tint.g * VICTORY_DIM, tint.b * VICTORY_DIM, tint.a)
			mat.set_shader_parameter(&"tint", tint.lerp(dark, dim))
			mat.set_shader_parameter(&"desaturate", lerpf(_dim_from[1], lerpf(_dim_from[1], 1.0, VICTORY_GREY), dim))
			# the pale light on his crown and shoulders (crowd.gdshader's crest) goes out with the rest
			mat.set_shader_parameter(&"crest", lerpf(_dim_from[2], 0.0, dim))
	if _t < VICTORY_FADE.y and int(_t * 8.0) != int(before * 8.0):
		# his spectral wisps fall away from where he stood, fewer as it goes
		if _rng.randf() > fade:
			game.fx.burst(&"soul", Vector3(center.x + _rng.randf_range(-1.0, 1.0), _rng.randf_range(0.6, 3.0), center.y + _rng.randf_range(-1.0, 1.0)))
	if crossed.call(0.25):
		cue.emit(&"victory_fade", center, Vector2.ZERO, 0.0, VICTORY_FADE.y)
	# the stream: its head runs from him to the portal, specks of violet and corrupted green along it
	if _t >= VICTORY_STREAM.x and _t <= VICTORY_STREAM.y:
		var s := (_t - VICTORY_STREAM.x) / (VICTORY_STREAM.y - VICTORY_STREAM.x)
		var head := center.lerp(portal, 1.0 - pow(1.0 - s, 2.0))
		var lift := 1.2 + sin(s * PI) * 2.5
		var way := (portal - center).normalized()
		if int(_t * 30.0) != int(before * 30.0):
			game.fx.chips(Vector3(head.x, lift, head.y), Vector3(way.x, 0.15, way.y), VIOLET if int(_t * 30.0) % 2 == 0 else CORRUPT, 2, 3.0, 0.14, 0.45, 0.35)
	if crossed.call(VICTORY_STREAM.x):
		Audio.play(&"victory_draw")
	if crossed.call(VICTORY_CALM - VICTORY_SEAL):
		# the portal takes his colour back to its own green over the sealing (it owns the portal's light from here)
		game.arena.seal_portal(VICTORY_SEAL, center)
	if crossed.call(VICTORY_PORTAL):
		game.fx.ring(portal, 3.0, VIOLET, 0.6, 0.12, true)
		game.fx.burst(&"soul", Vector3(portal.x, 1.5, portal.y))
		cue.emit(&"victory_absorb", portal, Vector2.ZERO, 0.0, VICTORY_CALM - VICTORY_PORTAL)
	if crossed.call(VICTORY_EMETH):
		game.fx.blade_glow(1.1)
		Audio.play(&"victory_release")
		cue.emit(&"emeth_glow", game.player.pos, game.player.facing, 0.0, 1.1)
	if crossed.call(VICTORY_RITUAL):
		game.fx.ring(_middle, 6.0, OLD_GOLD, 0.8, 0.12, true)
		cue.emit(&"ritual_broken", _middle, Vector2.ZERO, 6.0, 0.8)
	if _t >= VICTORY_TIME:
		# anything that slipped in while he fell goes too
		_cancel()
		if is_instance_valid(_shield):
			_shield.queue_free()
		_shield = null
		state = State.ENTER
		moment.emit(&"fallen")
		cue.emit(&"victory_done", center, Vector2.ZERO, 0.0, 0.0)
		game.boss = null
		RenderingServer.global_shader_parameter_set(&"boss_pos", Arena.NO_BOSS)
		defeated.emit()


# ---------- small helpers ----------

func _go(next: State) -> void:
	state = next
	_held = false
	_t = 0.0
	_step = 0
	_mark = 0.0
	_due.clear()
	_wave = 0
	_wave_at = 0.0
	_gather = 0.0
	e.memo = 0


## Back to walking; the next attack comes after the phase's rest (plus `extra`).
func _rest(extra: float = 0.0) -> void:
	_cooldown = BossDef.by_phase(def.rest, phase, 1.0) + extra
	_attack = &""
	_go(State.CHASE)


## A wind-up of this phase (longer while the paladin is cursed, by as much as he is slower: BossRules.cursed_windup).
func _windup(seconds: float) -> float:
	return BossRules.cursed_windup(seconds * BossDef.by_phase(def.windup_scale, phase, 1.0), game.player.curse.speed_scale())


func _anim(anim: StringName) -> void:
	if e.anim != anim:
		e.anim = anim
		e.anim_t = 0.0


## Holds a clip at a share of its length (the crowd plays a boss's clips at its walking pace: Horde.clip_rate).
func _pose(anim: StringName, share: float) -> void:
	e.anim = anim
	e.anim_t = share * game.horde.renderer.model_of(e.def).duration(anim) / game.horde.clip_rate(e) if game.horde.renderer else 0.0


## Plays a clip on from a share of it at its own pace (the time since _mark).
func _play_on(anim: StringName, from_share: float) -> void:
	if game.horde.renderer == null:
		return
	var length := game.horde.renderer.model_of(e.def).duration(anim)
	e.anim = anim
	e.anim_t = (from_share * length + (_t - _mark)) / game.horde.clip_rate(e)
