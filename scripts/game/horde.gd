class_name Horde
extends Node3D
## All enemies in one loop: no physics bodies, a spatial hash keeps them apart, CrowdRenderer draws them from baked
## poses. Every enemy attack is announced (a swing windup, a warning on the floor) before it can hurt.

signal killed(e: Enemy)
## A blow of the paladin landed on the boss (not a burn's tick): by which button (`dealing`), for his Postura (C1d).
signal boss_blow(e: Enemy, source: StringName)
signal hit_player(amount: float, from: Vector2)
## An enemy's armor (yellow bar) just broke.
signal armor_broken(e: Enemy)
## C1b: a Quebra (Poise) by the button `source` (DealtBy source). C1c: it feeds the Magia and the Brado (KitFeed).
signal poise_broken(e: Enemy, source: StringName)

const CELL := 1.5
## Share of the overlap of two bodies each pushes the other out by in a frame (both ways: half of it closed a frame).
const SEPARATE := 0.25
const KNOCKBACK_DECAY := 7.0
## Seconds a blow's flash lasts on the body: short and dry, 2 to 4 frames with its first one seen (GF-10; Hades II
## 0.03 s; it was 0.14 and read soft).
const FLASH_TIME := 0.05
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
## Only drawn (EnemyDef.windup_shake): it trembles this fast while it winds up. The unsteady runner's sway
## (EnemyDef.sway) follows its stride, stride_lean (T5b, Corredor: it rocked 9 times a second, a tremble, and an uneven
## stride played its locked walk from 0 to 2.4 times its pace, the feet skating).
const SHAKE_HZ := 14.0
const DEATH_SHOW := 1.5
const DISSOLVE_FROM := 0.85
const MAX_DYING := 90
const DEFS_DIR := "res://data/enemies/"
const MODS_DIR := "res://data/mods/"
## Share of an attack clip at which the blow lands (the windup is stretched to end there).
const IMPACT_SHARE := 0.55
const MELEE_COOLDOWN := 1.3
## Skeletons the elder priest raises around itself in one cast (fewer when the fight is full: room_for).
const PRIEST_RAISES := 3
## Enemy.memo of a knight raising its dead (1: its close slam, 2: it charges next).
const KNIGHT_CALLS := 3
const KNIGHT_GUARD := 4
## The knight winds up to hurl its shield (EnemyDef.throw_*).
const KNIGHT_THROW := 5
## A charge follows him only from here on: closer, there would be no time to leave its line (docs/qa/c1_cadencia.md).
const CHARGE_FOLLOW_FROM := 5.0
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
## T5-10: never along the field closer than WAY_NEAR (it alternated, by a wall, between walking out and in), and once
## straight it keeps so until WAY_FAR.
const WAY_EVERY := 0.12
const WAY_NEAR := 2.5
const WAY_FAR := 3.0
## A shooter only winds up with a clear line of fire (Arena.clear_shot, a shot this round) and with its body inside
## this share of the screen (never shooting from off it: VIEW_EDGE to 1 - VIEW_EDGE), else it walks until it is.
const LINE_OF_FIRE := 0.3
const VIEW_EDGE := 0.05
## An enemy that wants to come closer and has not moved STUCK_MOVE meters in STUCK_TIME seconds is stuck (RESULT
## stuck; it should never happen).
const STUCK_TIME := 3.0
const STUCK_MOVE := 0.5
## E1c (AUDIT.md P1): the drawing follows the body. Its real speed is smoothed over VEL_SMOOTH seconds; under
## WALK_FROM m/s it stands (idle), from WALK_START it walks (between, it keeps what it showed: no flicker), at the pace
## of that real speed. When where it walks is more than FACE_SPLIT degrees from where it looks, the body turns to
## where it walks, at TURN_RATE degrees a second (Hades II's 1200 for every enemy); it looks at its aim again in its
## wind-up. A stunned body does not turn (Hades: DisableRotate).
const VEL_SMOOTH := 0.1
const WALK_FROM := 0.3
const WALK_START := 0.4
const TURN_RATE := 1200.0
## T5-10 (docs/design/combat_cadence.md 6.4): with hysteresis. The body turns to where it walks once that is more than
## FACE_SPLIT degrees from its aim, and back to its aim under FACE_BACK; a figure with its own sideways steps
## (walk_side) only turns when faster than FACE_SPEED (slower it steps sideways facing him). It changes between
## standing and walking only after STAND_AFTER (to stand) or WALK_AFTER seconds across the threshold.
const FACE_SPLIT := 70.0
const FACE_BACK := 45.0
const FACE_SPEED := 1.2
## T5-10 (the combat-feel review 7.1, seed 4): a speed that crossed FACE_SPEED for three frames snapped the body round
## and back. It turns back to its aim only under FACE_SPEED_BACK, and either change waits FACE_AFTER seconds.
const FACE_SPEED_BACK := 0.9
const FACE_AFTER := 0.1
## T5-20: a way to run from the paladin (flee_dir) is kept at least FLEE_HOLD seconds while it stays open (the
## crossbowman swapped straight away and 35 degrees off frame by frame by a wall, its body 20 degrees each way).
const FLEE_HOLD := 0.4
## Running away it keeps going FLEE_SLACK meters past where it would start to run (it stopped and went on at that
## line, its body turning to him and away again); its body faces where it moves while it runs and RUN_FACE seconds
## after (until it is down to WALK_FROM), never the raw direction of one frame.
const FLEE_SLACK := 0.75
const RUN_FACE := 0.3
const STAND_AFTER := 0.15
const WALK_AFTER := 0.1
## Its own sideways steps under SIDE_STEP_BELOW m/s, from SIDE_FROM degrees off its facing, backwards from BACK_FROM;
## played at the pace of meters a second / SIDE_STEP_GROUND at its size.
const SIDE_STEP_BELOW := 1.2
const SIDE_FROM := 50.0
const BACK_FROM := 130.0
const SIDE_STEP_GROUND := 2.6
## E1c (AUDIT.md P5): seconds a body whose wind-up was cut waits, once its stun is over, before another (and its sound).
const REARM := 0.5
## How fast an attack clip plays from where the blow is loosed (and on into the recovery).
const ATTACK_PLAY := 1.4
## T5-12: seconds at least between the end of a recovery and the next wind-up.
const AFTER_RECOVER := 0.25
## C17, QW-105 (CF-08): up to this many seconds more, drawn for each recovery, so two bodies (or one body twice) never
## strike on the same beat (a soldier struck every 215 frames exactly, 15 times in a row).
const AFTER_RECOVER_JITTER := 0.5
## C17, QW-105 (CF-08, CF-11): after this many close slams in a row the knight (and the brute) backs off two steps
## (KNIGHT_BACK_OFF seconds) and charges from there; it walks again toward the paladin only once he is
## MELEE_WALK_BAND m past where it stopped (it changed between walking and standing 0.88 times a second).
const KNIGHT_SLAMS := 3
const KNIGHT_BACK_OFF := 0.6
const MELEE_WALK_BAND := 0.8
## T5-10: degrees a second it turns back to the paladin at the end of its recovery.
const RECOVER_TURN := 360.0
## T5b P1-5 (docs/qa/t5b_boss_fight.md): seconds a body that has just risen waits before its first wind-up (its cooldown
## ran down while it rose: 40% of the summoned soldiers armed 0.02 to 0.45 s after standing, "born and already coming").
const ARRIVE := 0.6
## T5b P1-2: a risen body fades from its rise into what it does over RISE_FADE (its last pose and the walk differ), and
## for its first RISEN_TIME seconds turns at RISEN_TURN degrees a second at most (8 a frame; it swung 60 degrees in 3).
const RISE_FADE := 0.25
const RISEN_TIME := 0.3
const RISEN_TURN := 480.0

var list: Array[Enemy] = []
## The damage dealt to enemies by where it came from (DT-016; RESULT dealt_by), and where the damage being dealt now
## comes from (Combat sets it around a hit; &"" counts as other).
var dealt := DealtBy.new()
var dealing: StringName = &""
## Fatia 2, the Refinar Peso: a blow's flinch lasts this many times its own (Combat sets it while it deals a blow).
var stun_scale := 1.0
## The blow being dealt is an Omega (Combat sets it while it deals one): strong for the StunRule though not `big`.
var strong := false
## The blow being dealt is the special (tag heavy) or an Omega: only drawn (combate_c1_leitura 7), armor gives it more sparks.
var heavy_blow := false
## How fast the enemies walk, times their own (E5: a Provação's curse, set by Rooms on entering a fight; 1: as is).
var speed_scale := 1.0
var dying: Array[Enemy] = []
var arena: Arena
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var renderer: CrowdRenderer
## The lights of the wind-ups and of the armor (never red: the warnings on the floor are Ground's).
var tells: EnemyFx
var hp_scale := 1.0
## GR-26: the enemy the HUD shows a bar for at the top of the screen (a guardian), which keeps no bar over its head.
var top_bar_for: Enemy = null

## Every enemy's life times this, elites, guardians and Morvath too (E6: the Juramento Mortos Resistentes).
var vow_hp := 1.0
## Summons never raise anyone past this many standing (EncounterGen.Fight.ceiling, set by Rooms for each fight;
## 0: no ceiling, the endless hall --horde).
var alive_cap := 0
var damage_scale := 1.0
## Fraqueza: the share of its damage a weakened enemy loses (Combat sets it from the Veu Blessings when it weakens one).
var weak_cut := 0.25
var target := Vector2.ZERO
## C1d: how much more the boss takes while his Postura is broken or he is exposed (BossDef.posture_vuln; Boss sets it).
var boss_vuln := 0.4
var target_alive := true
## C1e (the Armadilheiro): where the paladin's last dodge ended and the seconds since (Game sets them each step).
var dodge_end := Vector2.ZERO
var dodge_age := 99.0
## The paladin cannot be hurt now (a dodge, invulnerable frames): Game sets it each step; a plate's spikes wait for him to step off.
var target_safe := false
## The Armadilheiro's plates lying now, from the X to the dormant plate (TrapRules.Plate); C1eMarks draws them.
var plates_laid: Array[TrapRules.Plate] = []
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
## Where a floor point shows on the far camera's screen (0 to 1; Game sets it; unset: everywhere is seen): the
## shooters' rule (_can_fire), the same whatever camera the options chose (LR-02).
var view := Callable()
## Where a floor point shows on the screen of the camera in use (unset: the far one, view): the run's log (screen_flag)
## and the shooters winding up off it (off_screen_windups, the HUD's edge marks).
var seen := Callable()
## Enemies that got stuck this run, by kind (RESULT stuck; Bot.stats).
var stuck_by := {}
## Blows that stunned someone, and attacks those blows cut, this run (GF-12; RESULT flinches, interrupts).
var flinches := 0
## C1b (Poise): breaks this run by the button that broke it (DealtBy source; RESULT breaks).
var breaks: Dictionary = {}
var interrupts := 0
## DT-102 (RESULT windups): by kind, the wind-ups started, those that reached their blow (or shot) and those cut (by a
## stun, the armour breaking or death): id -> [started, struck, cut].
var windups := {}
## Cadence (RESULT idle): for each guardian (knight, priest_elder) the gaps between a recovery's end and the next wind-up
## and the share of the fight spent walking without attacking (IdleStats; stun, shield away and guard break not counted).
var idle := {}
const IDLE_TRACKED: Array[StringName] = [&"knight", &"priest_elder"]
var _cutting := false
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
var _mods: Dictionary = {}
var _frame := 0
var _rng := RandomNumberGenerator.new()
## How many were ever spawned: each takes a number of its own for what is only drawn (Enemy.look).
var _born := 0
## C5: trincas born so far (Enemy.group_id) and the clock their triangles turn by.
var _groups := 0
var _clock := 0.0

## What an enemy's blow is worth now: the director's scale, less the Fraqueza while it lasts.
func _out(e: Enemy) -> float:
	return DamageCalc.weakened(damage_scale, weak_cut, e.weak_t > 0.0)


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


## C1e: a modifier of data/mods by id.
func mod(id: StringName) -> ModDef:
	if not _mods.has(id):
		_mods[id] = load(MODS_DIR + id + ".tres")
	return _mods[id]


func spawn(d: EnemyDef, at: Vector2, rising: bool = true, with_mod: ModDef = null) -> Enemy:
	def(d.id)
	var e := Enemy.new()
	e.def = d
	e.mod = with_mod
	e.pos = at
	var scaled := not d.elite and d.behavior != EnemyDef.Behavior.BOSS
	e.max_hp = d.hp * (hp_scale if scaled else 1.0) * vow_hp
	e.hp = e.max_hp
	e.max_armor = d.armor
	e.armor = d.armor
	e.poise = d.poise
	e.cooldown = d.attack_cooldown * _rng.randf_range(0.4, 1.0)
	e.call_cd = d.raise_first
	e.rows = d.raise_every  # (CV-2: its first act is the call)
	e.guard_cd = d.guard_up_every * 0.5
	e.move_cd = AttackList.start_clocks(d.moves)
	e.charge_n = d.charges
	e.volley_cd = d.volley_every * 0.5
	e.side = 1.0 if _rng.randf() < 0.5 else -1.0
	e.dir = (target - at).normalized() if target.distance_to(at) > 0.1 else Vector2.DOWN
	_born += 1
	e.look = fposmod(_born * 0.618034, 1.0)
	if rising:
		e.state = Enemy.State.RISE
		e.anim = &"rise"
	list.append(e)
	if with_mod != null and with_mod.escort_count > 0:
		e.raised.append_array(_raise_dead(e, room_for(with_mod.escort_count), with_mod.escort_kind))
	return e


## C5, the Trinca: the figures of one head of a wave (EnemyDef.group of them) rise round `at`, kept together by a
## group id; they are returned.
func spawn_group(d: EnemyDef, at: Vector2, rising: bool = true) -> Array[Enemy]:
	_groups += 1
	var out: Array[Enemy] = []
	for k in d.group:
		var e := spawn(d, arena.resolve(TrioRules.birth_pos(at, k, d.group, GROUP_SPREAD), d.radius), rising)
		e.group_id = _groups
		e.group_k = k
		out.append(e)
	return out


func count() -> int:
	return list.size()


## How many of `want` summoned enemies may still rise under alive_cap (fewer, or none).
func room_for(want: int) -> int:
	return want if alive_cap <= 0 else EncounterGen.room_for(list.size(), alive_cap, want)


func step(dt: float) -> void:
	_frame += 1
	_clock += dt
	_dt = dt
	rehash()
	if arena != null and arena.flow != null and not list.is_empty():
		# the shared way to the paladin, made again as he moves (at most 4 times a second, spread over frames)
		arena.flow.aim(target, dt)
	for e in list:
		var reach := e.def.radius + Player.RADIUS
		e.was_in_target = depth_in_target(e) if e.pos.distance_squared_to(target) < reach * reach else 0.0
		e.last_pos = e.pos
	for e in list:
		_timers(e, dt)
		e.facing_him = false
		if e.alive and e.def.id in IDLE_TRACKED and target_alive:
			_tally_idle(e, dt)
		if e.alive and not e.helpless():
			acting = e.def.id
			acting_pos = e.pos
			_behave(e, dt)
			acting = &""
			acting_pos = Vector2.INF
			_watch_stuck(e, dt)
		# every frame at half the push (T5-10: every other frame, bodies pressed together shook 3 cm a frame)
		_separate(e)
		e.pushed = Vector2.ZERO
		if e.push.length_squared() > 0.01:
			e.pushed = e.push * dt
			e.pos += e.pushed
			e.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * dt)
	# after everyone moved and was kept apart (so the crowd's shoving cannot leave anyone inside him): nobody walks
	# into the paladin, nor is pressed into him by the others (a lunge in flight goes through him)
	for e in list:
		var reach := e.def.radius + Player.RADIUS
		# (E1c, AUDIT.md P8: a soldier's lunge stops at his edge too; a charge goes through)
		var through := e.state == Enemy.State.ATTACK and e.def.behavior != EnemyDef.Behavior.RUNNER
		if not through and e.pos.distance_squared_to(target) < reach * reach:
			keep_off_target(e, e.was_in_target, dt)
		# swept from where it stood: a push or a lunge stops at the abyss's edge, never across a hole (D-28)
		e.pos = arena.sweep(e.last_pos, e.pos, e.def.radius)
		e.y = e.height()
		_drawn_motion(e, dt)
	_step_shields(dt)
	_step_plates(dt)
	_step_waves(dt)
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
	e.cooldown -= dt * _pace(e)
	e.call_cd -= dt
	e.haste_t = maxf(0.0, e.haste_t - dt)
	if e.mod != null and e.mod.regen_hp > 0.0 and e.alive and e.state != Enemy.State.DOWN and e.state != Enemy.State.RISE:
		e.calm_t += dt
		if e.calm_t >= e.mod.regen_after:
			e.calm_t = 0.0
			if e.hp < e.max_hp:
				e.hp = SupportRules.mended(e.hp, e.max_hp, e.mod.regen_hp)
				fx.burst(&"dust", Vector3(e.pos.x, 0.9 + e.y, e.pos.y), Vector3.UP)
	e.flash_t -= dt
	e.hurt_t -= dt
	if e.recoil_t >= 0.0:
		e.recoil_t += dt
	e.stun_t = maxf(0.0, e.stun_t - dt)
	if e.def.poise > 0.0:
		_poise_timers(e, dt)
	e.air_t = maxf(0.0, e.air_t - dt)
	e.blind_t = maxf(0.0, e.blind_t - dt)
	e.slow_t = maxf(0.0, e.slow_t - dt)
	e.weak_t = maxf(0.0, e.weak_t - dt)
	e.mark_t = maxf(0.0, e.mark_t - dt)
	e.shove_t = maxf(0.0, e.shove_t - dt)
	e.open_t = maxf(0.0, e.open_t - dt)
	e.guard_cd -= dt
	e.volley_cd -= dt
	e.away_t = maxf(0.0, e.away_t - dt)
	for k in e.move_cd.size():
		e.move_cd[k] -= dt
	if e.guard_t > 0.0:
		e.guard_t = maxf(0.0, e.guard_t - dt)
		if e.guard_t <= 0.0:
			e.guard_cd = e.def.guard_up_every  # (K3: the next guard counts from this one's fall)
	e.block_t = maxf(0.0, e.block_t - dt)
	e.edge_t = maxf(0.0, e.edge_t - dt)
	e.crack_t = maxf(0.0, e.crack_t - dt)
	e.thaw_t = maxf(0.0, e.thaw_t - dt)
	if e.def.ward_count > 0 and e.alive and not e.helpless():
		_step_ward(e, dt)
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
			dealing = &"burn"
			damage(e, e.burn_dps * BURN_TICK, Vector2.ZERO, 0.0, Color(1.0, 0.5, 0.2), true, false, false)
			dealing = &""
	e.risen_t = maxf(0.0, e.risen_t - dt)
	if _holds_bar(e.def) and e.helpless() and e.alive:
		interrupt(e)  # (C5: a frozen Varredor's bar goes with its sweep; the bar's own life is kept up by its steps; C1e: the Canalizador's beam too)
	if e.state == Enemy.State.DOWN:
		_step_down(e)
	if e.state == Enemy.State.RISE and e.state_t > 0.9:
		_set_state(e, Enemy.State.WALK, &"walk")
		e.cooldown = maxf(e.cooldown, ARRIVE)
		e.risen_t = RISEN_TIME
	if e.rearm and not e.helpless():
		# its cut wind-up waits REARM from the end of the stun (the cooldown gates every wind-up)
		e.rearm = false
		e.cooldown = maxf(e.cooldown, REARM)


## Only drawn (E1c, AUDIT.md P1): its real speed on the floor (smoothed, pushes left out) and the way its body faces.
func _drawn_motion(e: Enemy, dt: float) -> void:
	if dt <= 0.0:
		return
	var moved := (e.pos - e.last_pos - e.pushed) / dt
	e.vel = e.vel.lerp(moved, 1.0 - exp(-dt / VEL_SMOOTH))
	if e.def.behavior == EnemyDef.Behavior.BOSS:
		return  # Boss turns his body itself (Boss._turn_body)
	if e.frozen_t > 0.0 or e.stun_t > 0.0 or e.air_t > 0.0:
		return
	var speed := e.vel.length()
	var steps := renderer != null and renderer.kind(e.def).model.frame_count(&"strafe_l") > 0
	var wants := e.face_walk
	if e.state != Enemy.State.WALK or e.facing_him or speed < (WALK_FROM if not steps else FACE_SPEED_BACK if e.face_walk else FACE_SPEED):
		wants = false
	else:
		var split := absf(rad_to_deg(e.dir.angle_to(e.vel)))
		if split > FACE_SPLIT:
			wants = true
		elif split < FACE_BACK:
			wants = false
	e.face_t = e.face_t + dt if wants != e.face_walk else 0.0
	if e.face_t >= FACE_AFTER or (not wants and e.state != Enemy.State.WALK):
		e.face_walk = wants
		e.face_t = 0.0
	# running on its own (T5-20) the body faces where it moves, smoothed; slowed down a moment (a stun's end, a step
	# held) it keeps its facing until it runs again or run_t is over
	var running := e.run_t > 0.0 and e.state == Enemy.State.WALK
	var want := e.vel / speed if e.face_walk or (running and speed >= WALK_FROM) else e.face if running else e.dir
	e.face = turned(e.face if e.face != Vector2.ZERO else e.dir, want, deg_to_rad(RISEN_TURN if e.risen_t > 0.0 else TURN_RATE) * dt)


## `from` turned toward `to` by at most `step` radians (both unit vectors).
static func turned(from: Vector2, to: Vector2, step: float) -> Vector2:
	if to == Vector2.ZERO:
		return from
	var a := from.angle_to(to)
	return to if absf(a) <= step else from.rotated(signf(a) * step)


## Ends its attack: the recovery window when it has one (EnemyDef.recover_time), else it walks at once. The clip of the
## blow goes on (Horde.render holds its end).
func _end_attack(e: Enemy, recover_anim: StringName = &"") -> void:
	e.recover_anim = recover_anim
	if e.def.recover_time > 0.0:
		_set_state(e, Enemy.State.RECOVER, e.anim, false)
	else:
		_set_state(e, Enemy.State.WALK, &"walk")


## How fast a walking enemy's clips play (its pace; a boss posing a clip divides by it: Boss._pose).
func clip_rate(e: Enemy) -> float:
	return clampf(_speed(e) / 2.3, 0.6, 1.6)


## How fast its walk plays (E1a-2, VX-05): as fast as the floor runs under the planted foot of the baked walk at its
## size (CrowdRenderer.Kind.ground), so the foot on the floor stays put; the old pace for a figure not measured or
## one that does not move.
static func walk_rate(speed: float, ground: float, size: float) -> float:
	if ground <= 0.0 or speed <= 0.0:
		return clampf(speed / 2.3, 0.6, 1.6)
	return speed / (ground * maxf(size, 0.01))


## The unsteady runner's trunk tipped to its side (radians) at `t` seconds into its walk loop of `loop` seconds: `sway`
## degrees, once to each side a loop (a loop is two steps), so it rocks onto each foot as it lands and never faster.
static func stride_lean(sway: float, t: float, loop: float) -> float:
	if loop <= 0.0:
		return 0.0
	return deg_to_rad(sway) * sin(TAU * t / loop)


func _speed(e: Enemy) -> float:
	return e.def.speed * speed_scale * (0.45 if e.slow_t > 0.0 else 1.0) * (1.0 + e.haste_pace if e.haste_t > 0.0 else 1.0)


## C1e: how much faster than its own its attacks come back (a Gritador's shout, a Furioso): SupportRules.pace.
func _pace(e: Enemy) -> float:
	if e.haste_t <= 0.0 and e.mod == null:
		return 1.0
	return SupportRules.pace(e.haste_t > 0.0, e.haste_pace, e.mod.attack_pace if e.mod != null else 0.0)


func _behave(e: Enemy, dt: float) -> void:
	if e.state == Enemy.State.RECOVER:
		# standing still at the end of its blow (the punish window); then it walks. T5-10: in its last RECOVER_FADE it
		# turns to the paladin at RECOVER_TURN (it snapped to him 20 degrees a frame the frame it walked again)
		var back := target - e.pos
		if e.state_t >= e.def.recover_time - RECOVER_FADE and back.length() > 0.01:
			e.dir = turned(e.dir, back.normalized(), deg_to_rad(RECOVER_TURN) * dt)
		if e.state_t >= e.def.recover_time:
			_set_state(e, Enemy.State.WALK, &"walk")
			# T5-12: a moment in its guard or walking before the next wind-up, never the frame after its recovery
			if e.def.gap_max > 0.0:
				# a guardian's random rest (AttackGap), the shorter the less toughness it has left
				var d := e.def
				e.cooldown = AttackGap.pick(d.gap_min, d.gap_max, d.gap_min0, d.gap_max0, toughness(e), _rng)
			elif e.def.behavior != EnemyDef.Behavior.SWEEP:  # (the Varredor's rest is exactly recover_time)
				e.cooldown = maxf(e.cooldown, AFTER_RECOVER + _rng.randf_range(0.0, AFTER_RECOVER_JITTER))
		return
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
		EnemyDef.Behavior.SWEEP:
			_behave_sweep(e, dt, toward, dist)
		EnemyDef.Behavior.SUPPORT:
			_behave_support(e, dt, toward, dist)
		EnemyDef.Behavior.LEAP:
			_behave_leap(e, dt, toward, dist)
		EnemyDef.Behavior.BEAM:
			_behave_beam(e, dt, toward, dist)


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
					hit_player.emit(e.def.damage * _out(e), e.pos)
		Enemy.State.ATTACK:
			if e.state_t >= 0.35:
				e.cooldown = MELEE_COOLDOWN * _rng.randf_range(0.8, 1.2)
				_end_attack(e)
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
		if not e.fan.is_empty():
			_point_fan(e)
		if e.state_t >= d.attack_windup:
			if caster:
				e.warning = ground.add_warning(target, 2.3, 1.1, d.attack_damage * _out(e), d.magic_color)
			e.fan.clear()  # (its threads fill on the frame the first shot leaves, then go)
			e.memo = 0
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		var ticks := 0 if caster else maxi(1, d.shot_ticks)
		if d.shot_relock > 0.0 and e.memo > 0 and e.memo < ticks and e.state_t < e.memo * d.shot_interval - d.shot_relock:
			# CB-4: the next bolt's line follows him, then locks
			e.aim = toward
			e.dir = toward
			Ground.point_line(e.warning2 as Ground.Zone, e.pos, toward)
		elif d.shot_relock > 0.0 and e.memo > 0 and e.memo < ticks:
			ground.lock_line(e.warning2 as Ground.Zone)
		while e.memo < ticks and e.state_t >= e.memo * d.shot_interval:
			if e.memo > 0 and not d.shot_line:
				e.aim = toward
			shoot(e, e.aim)
			if d.shot_relock > 0.0 and e.memo + 1 < ticks:
				e.warning2 = _mark(e, ground.add_aim_warning(e.pos, toward, arena.shot_reach(e.pos, toward, d.attack_range * RANGED_REACH, Projectiles.SHOT_EDGE),
					0.5, d.shot_interval, 0.0))
				ground.track_line(e.warning2 as Ground.Zone)
			if d.recoil > 0.0:
				e.push = -e.aim * d.recoil * pow(RANGED_RECOIL_FADE, e.memo)
			e.memo += 1
		if e.state_t >= maxi(0, ticks - 1) * d.shot_interval + 0.4:
			e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
			if d.retreat_far > 0.0:
				e.retreat_t = _rng.randf_range(d.retreat_time.x, d.retreat_time.y)
			# T5-13: the staff brought down (its exit clip) in its recovery
			_end_attack(e, &"exit")
		return
	e.dir = toward
	# it ran from him a moment ago: the distances it keeps grow FLEE_SLACK (it stopped and went on at the line)
	var fled := e.flee_hold > 0.0
	e.flee_hold -= dt
	e.run_t -= dt
	var sp := _speed(e)
	if sp <= 0.0:
		pass
	elif e.retreat_t > 0.0:
		# after its attack it gets away from him (Hades: RetreatAfterAttack), then comes back to its reach
		e.retreat_t -= dt
		if dist < d.retreat_far + (FLEE_SLACK if fled else 0.0):
			var away := _flee(e, -toward)
			e.pos += away * sp * dt
			if away != Vector2.ZERO:
				e.dir = away
				e.run_t = RUN_FACE
		return
	var near := dist < d.attack_range * d.keep_away + (FLEE_SLACK if fled else 0.0)
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
			e.run_t = RUN_FACE
	elif dist > d.attack_range or (e.cooldown <= 0.0 and not _can_fire(e)):
		# out of reach, or ready with no line of fire or off the screen: it walks the way to him until it has one
		e.pos += _walk * sp * dt
		e.dir = _walk
		e.run_t = RUN_FACE
	elif near:
		var away := _flee(e, -toward)
		cornered = away == Vector2.ZERO
		e.pos += away * sp * dt
		if not cornered:
			e.dir = away
			e.run_t = RUN_FACE
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
			e.warning = _mark(e, ground.add_aim_warning(e.pos, toward, arena.shot_reach(e.pos, toward, _line_reach(d), Projectiles.SHOT_EDGE), 0.5,
				d.attack_windup, 0.0))
		elif d.shot_orb and not d.shot_low and not caster:
			# C19-5 (Q-14 a): the mage's orbs leave along a thread too, from the start of its wind-up to the first orb,
			# turning with its aim until it locks (the burst keeps one thread; the orb turns a little in its first 0.8 s)
			_aim_fan(e, toward)


## PT-1: at most one sound of a "!" lighting every this many seconds of the picture (a horde lights many at once).
const BANG_SOUND_GAP := 0.12
var _bang_cd := 0.0


## PT-1: a warning its maker lays on the floor, unless its blow is no area (EnemyDef.ground_warning): then the zone stays
## (time, damage, what the bot reads) but is not drawn, and strike_in feeds the "!" over its head.
func _mark(e: Enemy, z: Ground.Zone) -> Ground.Zone:
	return z if e.def.ground_warning else Ground.mute(z)


## PT-1: seconds until the blow of `e` lands, from its muted zones (the soonest still on; -1: none, or an area blow that
## the floor tells itself). The "!" lights when it is under Feel.bang_lead.
func strike_in(e: Enemy) -> float:
	var best := -1.0
	var zs: Array = [e.warning, e.warning2]
	zs.append_array(e.fan)
	for o in zs:
		var z := o as Ground.Zone
		if z != null and z.silent and not z.cancelled and z.life > 0.0 and (best < 0.0 or z.life < best):
			best = z.life
	return best


## How many of this kind (the common one and its elite count together) are winding up or shooting now.
func attackers(d: EnemyDef) -> int:
	var n := 0
	for o in list:
		if o.alive and o.def.name_key == d.name_key and (o.state == Enemy.State.WINDUP or o.state == Enemy.State.ATTACK):
			n += 1
	return n


## Another of this kind began its wind-up less than windup_gap ago.
func _just_began(d: EnemyDef) -> bool:
	for o in list:
		if d.windup_gap > 0.0 and o.alive and o.def.name_key == d.name_key and o.state == Enemy.State.WINDUP and o.state_t < d.windup_gap:
			return true
	return false


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
	if d.shot_return:
		reach = ThrowRules.out_range(reach, arena.shot_reach(e.pos, dir, reach, Projectiles.SHOT_EDGE))
	var life := ThrowRules.life(reach, d.shot_speed) if d.shot_return else reach / maxf(0.1, d.shot_speed)
	Audio.play(CombatSounds.shot(d))
	for i in n:
		var turn := 0.0 if n == 1 else deg_to_rad(d.shot_spread) * (float(i) / float(n - 1) - 0.5)
		var aim := dir.rotated(turn)
		var s := projectiles.fire(Projectiles.Kind.ORB if d.shot_orb else Projectiles.Kind.BOLT, e.pos + aim * (d.radius + 0.2), aim,
			d.shot_speed, d.attack_damage * _out(e), 0.45 if d.shot_orb else 0.4, life, d.magic_color)
		# its warning so far: the aim it held (a shot of a burst, the time since the burst began too)
		s.warned = e.state_t + (d.attack_windup if e.state == Enemy.State.ATTACK else 0.0)
		if d.shot_return:
			s.back_at = ThrowRules.turn_age(reach, d.shot_speed)
			s.origin = s.pos
		if d.shot_turn > 0.0:
			s.turn = deg_to_rad(d.shot_turn)
			s.turn_decay = deg_to_rad(d.shot_turn_decay)
			s.homing = d.shot_homing if d.shot_homing > 0.0 else life
		if d.shot_low:
			s.low = true
			s.node.scale = LOW_SHOT_SCALE


## Its way from the paladin (flee_dir) held FLEE_HOLD seconds while it stays open (T5-20).
func _flee(e: Enemy, away: Vector2) -> Vector2:
	if e.flee_hold > 0.0:
		var kept := away.rotated(e.flee_turn)
		if _open_way(e.pos, kept, e.def.radius):
			return kept
	var dir := flee_dir(e.pos, away, e.def.radius, e.side)
	if dir != Vector2.ZERO:
		e.flee_turn = away.angle_to(dir)
		e.flee_hold = FLEE_HOLD
	return dir


## Where a ranged enemy runs to get away from the paladin: straight away, else turned along the wall (its own side
## first), never off the floor. ZERO: cornered, nowhere to go.
func flee_dir(from: Vector2, away: Vector2, radius: float, side: float) -> Vector2:
	for deg: float in [0.0, 35.0, -35.0, 70.0, -70.0, 105.0, -105.0]:
		var dir := away.rotated(deg_to_rad(deg) * (side if side != 0.0 else 1.0))
		if _open_way(from, dir, radius):
			return dir
	return Vector2.ZERO


## Floor and no stone RANGED_LOOK meters that way.
func _open_way(from: Vector2, dir: Vector2, radius: float) -> bool:
	return arena.inside(from + dir * RANGED_LOOK, radius + 0.3) and arena.free_at(from + dir * RANGED_LOOK, radius)


## Runs in, stops, raises its blade (the line on the floor) and pounces along it: its body covers the lunge it
## announced, the blade high, and the blade comes down as it arrives (T5-09: the damage from where its body is then,
## never from the warning). Waiting its turn it keeps to a ring round the paladin (T5-10).
func _behave_runner(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if d.aim_lock > 0.0 and e.state_t < d.attack_windup - d.aim_lock:
				# CB-4: it follows him until the last moment
				e.aim = toward
				e.dir = toward
				Ground.point_line(e.warning as Ground.Zone, e.pos, toward)
				if e.warning2 != null:
					e.lands_at = e.pos + toward * e.travel
			elif d.aim_lock > 0.0:
				ground.lock_line(e.warning as Ground.Zone)  # (only a thread that tracked pulses: once)
			if e.warning2 != null:
				# C19-1: its second blade follows him through the wind-up and keeps where he stood at its end
				var to2 := target - e.lands_at
				if to2.length_squared() > 0.01:
					e.aim2 = to2.normalized()
				Ground.point_line(e.warning2 as Ground.Zone, e.lands_at, e.aim2)
			if e.state_t >= d.attack_windup - TICK_SLACK:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			var go := minf(e.travel, d.lunge_speed * dt)
			e.pos += e.aim * go
			e.travel -= go
			if e.blows < d.strikes and e.state_t >= blow_at(e, e.blows) - TICK_SLACK:
				if e.blows == 1:
					# (C19-1) the second blade, at once from where the body landed, to where he stood
					e.aim = e.aim2
					e.dir = e.aim2
					e.travel = 0.0
					e.warning2 = null
				e.blows += 1
				e.landed = true
				_blade_lands(e)
			if e.state_t >= maxf(d.lunge_time, blow_at(e, d.strikes - 1) + STRIKE_BITE):
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.8, 1.3)
				_end_attack(e)
		_:
			e.dir = toward
			if dist > d.attack_range or not e.straight:
				e.pos += (_slot_way(e, dist) if d.group > 1 else _walk) * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive and (d.max_attackers <= 0 or attackers(d) < d.max_attackers) and not _just_began(d):
				e.aim = toward
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"windup")
				# the pounce it will make: up to his edge (it stops there), at most its lunge; the blade lands as it arrives
				e.travel = clampf(dist - d.radius - Player.RADIUS, 0.0, d.lunge_speed * d.lunge_time)
				e.strike_t = maxf(d.strike_at, e.travel / maxf(d.lunge_speed, 0.1))
				e.landed = false
				e.blows = 0
				e.warning = _mark(e, ground.add_aim_warning(e.pos, toward, e.travel + blade_reach(d), 1.3, d.attack_windup + e.strike_t + dt, 0.0))
				if d.aim_lock > 0.0:
					ground.track_line(e.warning as Ground.Zone)
				if d.strikes > 1:
					# C19-1 (Hades' Guard elite): the second blade's thread shows from the wind-up on (0.2 s after the
					# first is too short to read a warning born then), from where the body lands
					e.lands_at = e.pos + toward * e.travel
					e.aim2 = toward
					e.warning2 = _mark(e, ground.add_aim_warning(e.lands_at, toward, blade_reach(d), 1.3, d.attack_windup + blow_at(e, 1) + dt, 0.0))
			elif d.group > 1:
				_hold_slot(e, dt, toward)
			else:
				_wait_ring(e, dt, toward, dist)


## Seconds a runner's spin goes on after its last burst before its recovery (0.4 s attack, the burst at 0.1).
const PULSE_AFTER := 0.3


## Seconds into its attack at which its blow `k` lands (0 the first; C19-1, C19-2: EnemyDef.strike_gap apart).
static func blow_at(e: Enemy, k: int) -> float:
	return e.strike_t + maxi(k, 0) * e.def.strike_gap


## T5-09: a warning made in the crowd's step already loses that frame in the floor's step (Game: horde, then ground),
## so the crowd's own warnings get one frame more (+ dt); and its timers end a hair early (TICK_SLACK) so sixtieths
## that add up a little short never cost a frame. The warning is full on the frame the blow lands.
const TICK_SLACK := 0.0001
## Seconds a soldier's blade stays down where it bit before its recovery (T5-09).
const STRIKE_BITE := 0.1
## T5-10: a soldier waiting its turn (or its cooldown) keeps to a ring round the paladin, RING_SHARE of its reach, and
## only walks to it when more than RING_SLACK off it; sideways at RING_STRAFE of its speed, to the same side for at
## least RING_SIDE seconds, facing him.
const RING_SHARE := 0.75
const RING_SLACK := 0.5
const RING_STRAFE := 0.3
const RING_SIDE := 1.2
## Once off its ring it walks back to it (at RING_STEP of its speed) until RING_SETTLED meters from it.
const RING_STEP := 0.6
const RING_SETTLED := 0.1
## The fastest it moves while it waits (m/s; under FACE_SPEED and SIDE_STEP_BELOW).
const RING_SPEED := 1.0


## How far a soldier's blade reaches from its middle when it lands (its body and EnemyDef.strike_reach at its size).
static func blade_reach(d: EnemyDef) -> float:
	return d.radius + d.strike_reach * d.size


## The soldier's blade comes down (T5-09): it hurts the paladin if he is within its reach (and the arc ahead) from
## where its body is now.
func _blade_lands(e: Enemy) -> void:
	if not target_alive:
		return
	var to := target - e.pos
	var len := to.length()
	if len > blade_reach(e.def) + Player.RADIUS * 0.6:
		return
	if len > e.def.radius + Player.RADIUS and absf(e.aim.angle_to(to)) > deg_to_rad(e.def.strike_degrees) * 0.5:
		return
	last_by = e.def.id
	last_warn = e.def.attack_windup + e.state_t
	last_offscreen = screen_flag(e.pos)
	hit_player.emit(e.def.attack_damage * _out(e), e.pos)


## T5-10: waiting near the paladin (its turn not come, or its cooldown): on a ring round him, never in and out.
func _wait_ring(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var ring := e.def.attack_range * RING_SHARE
	var off := dist - ring
	if absf(off) > RING_SLACK:
		e.to_ring = true
	elif absf(off) < RING_SETTLED:
		e.to_ring = false
	var move := toward * signf(off) * RING_STEP if e.to_ring else Vector2.ZERO
	e.side_t += dt
	if e.side_t >= RING_SIDE and _rng.randf() < dt * 0.5:
		e.side = -e.side
		e.side_t = 0.0
	move += toward.rotated(e.side * PI * 0.5) * RING_STRAFE
	# (QW-105: with the drawn wait after a recovery it walks back out to its ring from his edge; the crowd's shoving
	# took it past FACE_SPEED and it turned its back to him, 20 degrees a frame)
	e.facing_him = true
	# never faster than RING_SPEED: under FACE_SPEED it steps sideways and back facing him (it turned its back to walk
	# out to the ring at 2.5 m/s and turned round again, 20 degrees a frame)
	e.pos += move.limit_length(1.0) * minf(_speed(e), RING_SPEED) * dt


## Elite: walks the paladin down, then braces behind its shield (a long line on the floor) and charges along it. The
## charge hurts with its body (T5-08): the first frame its edge, swept from where it was to where it is, touches him,
## once a charge; the line is only drawn and fills until the frame it would reach him where he stood.
func _behave_knight(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.memo == KNIGHT_GUARD:
				# K3: the shield goes up (a ring, a glint, a sound), then it holds it guard_up_time s
				if e.state_t >= d.guard_up_windup:
					e.memo = 0
					e.guard_t = d.guard_up_time
					e.cooldown = maxf(e.cooldown, 0.4)
					e.recover_anim = &""
					_set_state(e, Enemy.State.WALK, &"walk")
					fx.ring(e.pos, d.radius + 0.8, EnemyFx.STEEL, 0.3, 0.15, true)
					Audio.play(CombatSounds.EVENTS[&"ward"])
				return
			if e.memo == KNIGHT_CALLS:
				if e.state_t >= d.attack_windup:
					e.rows = 0
					e.raised.append_array(_raise_dead(e, _calls(e)))
					_set_state(e, Enemy.State.ATTACK, &"summon", false)
				return
			if e.memo == KNIGHT_THROW:
				e.dir = toward
				if e.state_t >= d.throw_windup:
					_loose_shield(e)
				return
			if e.memo != 1 and d.aim_lock > 0.0 and e.state_t < d.attack_windup - d.aim_lock:
				_follow_charge(e, toward, dist)
			elif e.memo != 1 and d.aim_lock > 0.0:
				ground.lock_line(e.warning as Ground.Zone)
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack" if e.memo == 1 else &"charge", false)
				fx.shake(1.5)
		Enemy.State.ATTACK:
			if e.memo == KNIGHT_THROW:
				# the shield is in the air: it stands empty-handed a moment (the throw's own flight and landing are _step_shields)
				if e.state_t >= THROW_HOLD:
					e.memo = 0
					e.cooldown = maxf(e.cooldown, d.attack_cooldown * 0.6)
					_end_attack(e)
				return
			if e.memo == 1 or e.memo == KNIGHT_CALLS:
				# the close slam: stands still while it lands
				if e.state_t >= 0.5:
					e.memo = 0
					e.cooldown = d.guard_up_hit_every if e.guard_t > 0.0 else d.attack_cooldown * 0.6
					_end_attack(e)
				return
			var from := e.pos
			e.pos += e.aim * d.lunge_speed * dt
			if d.wall_stun > 0.0 and _wall_hit(e):
				_wall_stun(e)
				return
			if not e.landed and target_alive and BodyBlock.swept_touch(from, e.pos, target, d.radius + Player.RADIUS):
				e.landed = true
				last_by = d.id
				last_warn = d.attack_windup + e.state_t
				last_offscreen = screen_flag(e.pos)
				hit_player.emit(d.attack_damage * _out(e), from)
			if _frame % 3 == 0:
				fx.burst(&"dust", Vector3(e.pos.x, 0.2, e.pos.y), Vector3(-e.aim.x, 0, -e.aim.y))
			if e.state_t >= d.lunge_time:
				if e.warning != null:
					Ground.end_zone(e.warning as Ground.Zone)
					e.warning = null
				e.charges += 1
				if e.charges < e.charge_n and target_alive:
					# GP-12 (Daniel, 2026-11-22): the guardian turns and charges again
					_brace(e, toward, dist, d.recharge_windup)
					return
				# it stands at the end of its charge, spent (T5-12: its shield lowered, recover_anim)
				e.charges = 0
				e.rows += 1
				e.cooldown = d.attack_cooldown
				_end_attack(e, &"recover")
		_:
			if e.retreat_t > 0.0:
				# backing off two steps, facing him, to charge from there (QW-105)
				e.retreat_t -= dt
				e.facing_him = true
				e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0))
				e.pos -= toward * _speed(e) * dt
				return
			var guarded := e.guard_t > 0.0
			_behave_melee_walk(e, dt, toward, dist)
			if d.guard_up_time > 0.0 and not guarded and e.guard_cd <= 0.0 and target_alive and e.open_t <= 0.0 and e.away_t <= 0.0 \
					and e.armor > d.armor * d.guard_up_armor:
				e.memo = KNIGHT_GUARD
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"brace")
				return
			if guarded:
				# K3: shield up, it walks slow and swings now and then, never charging nor calling
				if e.cooldown <= 0.0 and dist < d.guard_up_hit_range and target_alive:
					e.memo = 1
					e.dir = toward
					_set_state(e, Enemy.State.WINDUP, &"attack")
					e.warning = _mark(e, ground.add_arc_warning(e.pos, toward, d.guard_up_hit_range + 0.8, 120.0, d.guard_up_hit_windup, d.guard_up_hit_damage * _out(e)))
					e.state_t = d.attack_windup - d.guard_up_hit_windup
					e.cooldown = d.guard_up_hit_every
				return
			if d.raise_count > 0 and e.rows >= d.raise_every and e.cooldown <= 0.0 and target_alive and _calls(e) > 0:
				# CV-2 (Daniel, 2026-11-22): it stands still, sword and shield up, and its dead rise
				e.memo = KNIGHT_CALLS
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"summon")
				return
			if _knight_move(e, toward, dist):
				return
			var backed := e.slams >= KNIGHT_SLAMS
			if backed and e.cooldown <= 0.0 and dist < d.close_range and target_alive and d.lunge_time > 0.0:
				e.slams = 0
				e.retreat_t = KNIGHT_BACK_OFF
				e.memo = 2  # charge next, from wherever the steps back leave it
				return
			if d.close_damage > 0.0 and e.cooldown <= 0.0 and dist < d.close_range and target_alive and (e.memo != 2 or not e.straight):
				e.slams += 1
				e.memo = 1
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"attack")
				e.warning = _mark(e, ground.add_arc_warning(e.pos, toward, d.close_range + 0.8, 120.0, d.close_windup, d.close_damage * _out(e)))
				e.state_t = d.attack_windup - d.close_windup
				return
			if e.cooldown <= 0.0 and dist < d.attack_range and (dist > d.close_range or e.memo == 2) and target_alive and e.straight \
					and e.away_t <= 0.0:
				e.charges = 0
				e.charge_n = _charges_open(e)
				_brace(e, toward, dist, d.attack_windup)


## How much of its whole toughness (life and armor together, what its two bars show) it still has.
static func toughness(e: Enemy) -> float:
	return (e.hp + e.armor) / maxf(e.max_hp + e.max_armor, 0.001)


## The knight's priority list (AttackList): the first move open now is begun. True when one was.
func _knight_move(e: Enemy, toward: Vector2, dist: float) -> bool:
	var d := e.def
	if d.moves.is_empty() or e.cooldown > 0.0 or not target_alive or not e.straight or e.away_t > 0.0 or e.open_t > 0.0 or e.memo == 2:
		return false
	var i := AttackList.pick(d.moves, e.move_cd, toughness(e), dist)
	if i < 0:
		return false
	var m := d.moves[i]
	e.move_cd[i] = m.cooldown
	e.move_i = i
	match m.id:
		&"throw":
			e.memo = KNIGHT_THROW
			e.dir = toward
			e.guard_t = 0.0
			_set_state(e, Enemy.State.WINDUP, &"attack")  # (not &"summon": that clip is the call of the dead)
		&"charge":
			e.charges = 0
			e.charge_n = m.count
			_brace(e, toward, dist, d.attack_windup)
	return true


## How many charges in a row the list gives it now, by how much toughness is left (the old `charges` when it has no list).
func _charges_open(e: Enemy) -> int:
	var share := toughness(e)
	var best := e.def.charges
	for m in e.def.moves:
		if m.id == &"charge" and share <= m.from_life:
			best = m.count
			break
	return best


## True while the shield is away (thrown and not yet back): it stands without it, its armor takes every blow whole.
func shield_away(e: Enemy) -> bool:
	return e.away_t > 0.0


## The shield leaves its hand: it flies up and comes down on the paladin's spot, which the floor marks (C1eMarks).
func _loose_shield(e: Enemy) -> void:
	var s := Shield.new()
	s.owner = e
	s.from = e.pos
	s.land = arena.resolve(target, 0.6)
	s.total = e.def.throw_flight
	# where he stands now, a red circle until it lands (Daniel, 2026-11-23: no following; the wave still comes after)
	s.mark = ground.add_warning(s.land, e.def.throw_half, s.total, 0.0)
	shields.append(s)
	e.away_t = 99.0
	_set_state(e, Enemy.State.ATTACK, &"attack", false)
	fx.shake(1.0)


## Seconds the knight stands after loosing the shield before it walks again.
const THROW_HOLD := 0.45
## Set while a wave a dodge crosses is hurting him (the shield wave): any moment of the roll counts as a close dodge (Game reads it).
var last_wide := false
## The shield wave's colour: hot, thin and bright, a moving wave and not a mark of the floor.
const WAVE_COLOR := Color(1.0, 0.72, 0.42)
## Where the wave starts from the landing (meters).
const WAVE_START := 1.2


## A shield in the air: it lands on the spot taken as it left the hand, marked by `mark` (a red circle on the floor).
class Shield extends RefCounted:
	var owner: Enemy
	var mark: Ground.Zone
	var from := Vector2.ZERO
	var land := Vector2.ZERO
	var t := 0.0
	var total := 1.0


## A shield wave spreading from where it landed.
class Wave extends RefCounted:
	var owner: Enemy
	var center := Vector2.ZERO
	var t := 0.0
	var hit := false
	var ring: Dictionary


var shields: Array[Shield] = []
var waves: Array[Wave] = []


func _step_shields(dt: float) -> void:
	var i := shields.size() - 1
	while i >= 0:
		var s := shields[i]
		s.t += dt
		if not s.owner.alive:
			Ground.end_zone(s.mark)
			shields.remove_at(i)
		else:
			if s.t >= s.total:
				Ground.end_zone(s.mark)
				_land_shield(s)
				shields.remove_at(i)
		i -= 1


func _land_shield(s: Shield) -> void:
	var e := s.owner
	var d := e.def
	e.away_t = d.throw_open
	e.shield_lies = s.land
	fx.burst(&"dust", Vector3(s.land.x, 0.2, s.land.y), Vector3.UP)
	fx.shake(2.2)
	Audio.play(&"enemy_burst")
	var w := Wave.new()
	w.owner = e
	w.center = s.land
	if target_alive and LeapRules.in_area(s.land, target, d.throw_half, Player.RADIUS * 0.6):
		last_by = d.id
		last_warn = d.throw_flight
		last_offscreen = screen_flag(s.land)
		hit_player.emit(d.throw_damage * _out(e), s.land)
		w.hit = true  # (it took the landing: the wave does not hurt him again)
	w.ring = fx.wave_ring(s.land, WAVE_COLOR)
	waves.append(w)


func _step_waves(dt: float) -> void:
	var i := waves.size() - 1
	while i >= 0:
		var w := waves[i]
		var d := w.owner.def
		w.t += dt
		var r := ShockRing.radius_at(w.t, WAVE_START, d.ring_speed, d.ring_delay)
		if not w.owner.alive or ShockRing.spent(r, d.ring_reach):
			fx.wave_end(w.ring)
			waves.remove_at(i)
		else:
			fx.wave_ring_set(w.ring, r, d.ring_thick)
			if w.t - dt < d.ring_delay and w.t >= d.ring_delay:
				Audio.play(&"wave_omega")
				fx.shake(1.2)
			if not w.hit and target_alive and ShockRing.touches(w.center, r, d.ring_thick, target, Player.RADIUS * 0.6):
				w.hit = true
				last_by = d.id
				last_warn = d.ring_delay + d.throw_flight
				last_offscreen = screen_flag(w.center)
				last_wide = true
				hit_player.emit(d.ring_damage * _out(w.owner), w.center + (target - w.center).normalized() * r)
				last_wide = false
		i -= 1


## K1: the charge ended against the arena's wall (the floor pushed it back).
func _wall_hit(e: Enemy) -> bool:
	return arena.resolve(e.pos, e.def.radius).distance_to(e.pos) > 0.05


## K1: it stands against the wall, stunned and turned away for wall_stun seconds (its own collision, not a blow: F8 does not
## touch it), the rest of the row of charges cut and the line gone.
func _wall_stun(e: Enemy) -> void:
	var d := e.def
	e.pos = arena.resolve(e.pos, d.radius)
	if e.warning != null:
		Ground.end_zone(e.warning as Ground.Zone)
		e.warning = null
	e.charges = 0
	e.rows += 1
	e.cooldown = d.attack_cooldown
	e.guard_t = 0.0
	e.stun_t = maxf(e.stun_t, d.wall_stun)
	e.stun_len = d.wall_stun
	e.broken_t = 0.0
	_end_attack(e, &"recover")
	fx.shake(2.5)
	fx.burst(&"dust", Vector3(e.pos.x, 0.4, e.pos.y), Vector3(-e.aim.x, 0, -e.aim.y))
	fx.word(Vector3(e.pos.x, 2.0 + 2.0 * d.size, e.pos.y), T.t(&"word_wall"), Combat.LIGHT)
	Audio.play(CombatSounds.EVENTS[&"stagger"])


## K2: the Brado took a blow from `from`; the guardian that slammed there stands open ward_open seconds (the slam is cut at its
## end: it is a stun by the Brado, not by a common blow).
func ward_taken(from: Vector2) -> void:
	for e in list:
		if e.alive and e.def.ward_open > 0.0 and e.memo == 1 and e.pos.distance_to(from) < 1.0:
			e.stun_t = maxf(e.stun_t, e.def.ward_open)
			e.stun_len = e.def.ward_open
			e.guard_t = 0.0
			e.hurt_t = HURT_TIME
			fx.ring(e.pos, e.def.radius + 1.2, EnemyFx.STEEL, 0.3, 0.15, true)
			fx.word(Vector3(e.pos.x, 2.0 + 2.0 * e.def.size, e.pos.y), T.t(&"word_open"), Combat.LIGHT)
			Audio.play(CombatSounds.EVENTS[&"stagger"])
			break


## It braces behind its shield to charge along a line, `windup` seconds from now.
func _brace(e: Enemy, toward: Vector2, dist: float, windup: float) -> void:
	var d := e.def
	e.slams = 0
	e.memo = 0
	e.aim = toward
	e.dir = toward
	e.landed = false
	_set_state(e, Enemy.State.WINDUP, &"brace")
	e.state_t = d.attack_windup - windup
	# filled when its body would reach his where he stands now (or at the end of the charge)
	e.warning = _mark(e, ground.add_line_warning(e.pos, toward, d.lunge_speed * d.lunge_time + d.radius, 2.4, windup + _charge_reach(d, dist), 0.0))
	if d.aim_lock > 0.0 and dist >= CHARGE_FOLLOW_FROM:
		ground.track_line(e.warning as Ground.Zone)  # (closer than that it never follows: no thread, no pulse)


## Seconds of its charge until its body reaches his, `dist` away (at most the whole charge).
static func _charge_reach(d: EnemyDef, dist: float) -> float:
	return clampf((dist - d.radius - Player.RADIUS) / maxf(d.lunge_speed, 0.1), 0.0, d.lunge_time)


## CV-1: its body and its line turn with the paladin, and the line still fills on the frame it would reach him.
func _follow_charge(e: Enemy, toward: Vector2, dist: float) -> void:
	if dist < CHARGE_FOLLOW_FROM:
		return
	e.aim = toward
	e.dir = toward
	var z := e.warning as Ground.Zone
	if z == null:
		return
	Ground.point_line(z, e.pos, toward)
	var life := e.def.attack_windup - e.state_t + _charge_reach(e.def, dist)
	z.total += life - z.life
	z.life = life


## How many skeletons the knight may raise now.
func _calls(e: Enemy) -> int:
	var standing := 0
	for r in e.raised:
		standing += int(r.alive)
	return room_for(mini(e.def.raise_count, e.def.raise_max - standing)) if standing < e.def.raise_max else 0


## Skeletons rise round `e`, n of them; they are returned.
func _raise_dead(e: Enemy, n: int, kind: StringName = &"", at_edge := false) -> Array[Enemy]:
	var out: Array[Enemy] = []
	var skeleton := def(kind if kind != &"" else e.def.raise_kind)
	var edge: Array[Vector2] = []
	if at_edge:
		edge = edge_spots(n)
	for k in n:
		var at: Vector2 = edge[k] if at_edge else raise_spot(e.pos, k)
		out.append(spawn(skeleton, at, true))
		fx.burst(&"shadow", Vector3(at.x, 0.3, at.y))
	if n > 0:
		Audio.play(&"summon")
	return out


## Between charges the knight still swings at whoever is close.
func _behave_melee_walk(e: Enemy, dt: float, _toward: Vector2, dist: float) -> void:
	e.dir = e.dir.slerp(_walk, minf(1.0, dt * 6.0))
	var stop := e.def.radius + Player.RADIUS + 0.5
	e.closing = dist > (stop if e.closing else stop + MELEE_WALK_BAND)
	if e.closing:
		e.pos += _walk * _speed(e) * (e.def.guard_up_walk if e.guard_t > 0.0 else 1.0) * dt


## n places on the floor's edge, the farthest from the paladin (and from each other): a ring just inside the walls is tried
## every 22.5 degrees, stone and columns pushed out by the arena, then the best n by distance from him.
func edge_spots(n: int) -> Array[Vector2]:
	var box := arena.bounds()
	var center := box.get_center()
	var radius := maxf(minf(box.size.x, box.size.y) * 0.5 - 2.5, 3.0)
	var cands: Array[Vector2] = []
	for i in 16:
		cands.append(arena.resolve(center + Vector2.from_angle(TAU * i / 16.0) * radius, 0.6))
	var out: Array[Vector2] = []
	for k in n:
		var best := Vector2.INF
		var score := -1.0
		for c in cands:
			var near := c.distance_to(target)
			for o in out:
				near = minf(near, c.distance_to(o) * 1.5)
			if near > score:
				score = near
				best = c
		out.append(best if best != Vector2.INF else center)
	return out


## Where the k-th skeleton an elder raises from `from` stands: on a ring of 3.5 m, on the floor and out of stone.
func raise_spot(from: Vector2, k: int) -> Vector2:
	return arena.resolve(from + Vector2.from_angle(TAU * k / PRIEST_RAISES) * 3.5, 0.5)


## C5, the Trinca: meters between the figures of a group as it rises, the ring of the triangle round the paladin (a
## share of the blow's reach), and how fast a figure moves to its place while it waits its turn (a share of its speed).
const GROUP_SPREAD := 1.1
const SLOT_RING := 0.85
const SLOT_STEP := 0.7
## Seconds into its dying a figure lying in a mound is shown at when the last of its trinca falls (it fades at once).
const DOWN_DEAD_AT := 0.9


## How many of e's group (not e) stand: alive and not lying in a mound.
func _standing_of(e: Enemy) -> int:
	var n := 0
	for o in list:
		if o != e and o.group_id == e.group_id and o.alive and o.state != Enemy.State.DOWN:
			n += 1
	return n


## Its place in the triangle round the paladin (TrioRules), ring meters out.
func _slot_of(e: Enemy) -> Vector2:
	var d := e.def
	return TrioRules.slot_pos(target, _clock, e.group_k, d.group, fposmod(float(e.group_id) * 0.618034, 1.0), d.attack_range * SLOT_RING)


## Toward the paladin from afar, toward its place in the triangle once near.
func _slot_way(e: Enemy, dist: float) -> Vector2:
	if dist > e.def.attack_range * 3.0 or not e.straight:
		return _walk
	var to := _slot_of(e) - e.pos
	return to.normalized() if to.length() > 0.2 else Vector2.ZERO


## Waiting its turn (one blow at a time for the whole trinca): it keeps its place in the triangle, facing him.
func _hold_slot(e: Enemy, dt: float, toward: Vector2) -> void:
	e.facing_him = true
	var to := _slot_of(e) - e.pos
	if to.length() > 0.25:
		e.pos += to.normalized() * minf(_speed(e) * SLOT_STEP, to.length() / maxf(dt, 0.001)) * dt


## A figure of a trinca falls: it lies in a mound, hurt by nothing, and cuts its blow short.
func _lie_down(e: Enemy) -> void:
	if e.warning != null:
		Ground.end_zone(e.warning as Ground.Zone)
		e.warning = null
	e.hp = 0.0
	e.invulnerable = true
	e.push = Vector2.ZERO
	e.vy = 0.0
	e.stun_t = 0.0
	e.frozen_t = 0.0
	e.burn_t = 0.0
	e.slow_t = 0.0
	e.rearm = false
	_cutting = true
	_set_state(e, Enemy.State.DOWN, &"death")
	_cutting = false
	Audio.play(CombatSounds.kill(e.def))
	fx.burst(&"bone", Vector3(e.pos.x, 0.6, e.pos.y))


## A mound waits its time and rises if another figure still stands; none left standing (the clear of the crowd, a
## kill that left it behind): it is done.
func _step_down(e: Enemy) -> void:
	if e.echoed and e.mod != null:
		if SupportRules.echo_rises(e.state_t, e.mod.echo_time):
			e.invulnerable = false
			e.hp = SupportRules.echo_hp(e.max_hp, e.mod.echo_share)
			e.mod = null  # (once: the ring goes with it)
			_set_state(e, Enemy.State.RISE, &"rise")
			fx.burst(&"dust", Vector3(e.pos.x, 0.3, e.pos.y))
		return
	var others := _standing_of(e)
	if TrioRules.may_rise(e.state_t, e.def.rise_time, others):
		e.invulnerable = false
		e.hp = e.max_hp
		_set_state(e, Enemy.State.RISE, &"rise")
		fx.burst(&"dust", Vector3(e.pos.x, 0.3, e.pos.y))
	elif others == 0 and e.state_t > 0.1:
		_finish_mound(e)


## The last of a trinca fell: the mounds that lie round it are done with it (all three on the floor: it is over).
func _end_group(e: Enemy) -> void:
	if e.group_id == 0:
		return
	for o in list.duplicate():
		if o != e and o.group_id == e.group_id and o.alive and o.state == Enemy.State.DOWN:
			_finish_mound(o)


func _finish_mound(o: Enemy) -> void:
	o.invulnerable = false
	o.alive = false
	o.state = Enemy.State.DEAD
	o.anim = &"death"
	o.dead_t = DOWN_DEAD_AT
	killed.emit(o)


## C1e, the Detonante: four short lances in a cross where it fell, warned (the arms' own warning is the mark), then they hurt.
func _cross_burst(e: Enemy) -> void:
	var by := acting
	acting = e.def.id
	for dir in SupportRules.cross(e.mod.burst_arms):
		ground.add_line_warning(e.pos, dir, e.mod.burst_reach, e.mod.burst_width, e.mod.burst_time, e.mod.burst_damage * _out(e))
	acting = by


## C1e (inimigos_c1e.md 4 and 5): the Gritador and the Coveiro. It never strikes: it keeps attack_range m from the paladin, runs from
## him when closer than retreat_far (flee_speed), and when its cooldown is up stands still attack_windup s (the wind-up) and calls.
## The Gritador shouts (the others in reach go faster and heal once), the Coveiro raises raise_count dead where its wind-up marked them.
## How far its aim line on the floor goes: the range of an axe that comes back, else 1.5 of its reach.
func _line_reach(d: EnemyDef) -> float:
	return d.shot_range if d.shot_return and d.shot_range > 0.0 else d.attack_range * RANGED_REACH


## The Saltador (C1e, lote B): 4 to 7 m off it keeps to its ring; ready, it marks the square it will land on (corners in L closing over
## its wind-up, C1eMarks; the spot follows the paladin and holds the last aim_lock s), leaves the floor (nothing touches it in the air)
## and lands there leap_time s later, hurting whoever stands in the square; then it rests recover_time s, low. Never a disc.
func _behave_leap(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			e.dir = toward
			if e.state_t >= d.attack_windup - TICK_SLACK:
				e.leap_from = e.pos
				e.invulnerable = true
				e.dir = (e.lands_at - e.pos).normalized() if e.lands_at.distance_to(e.pos) > 0.1 else toward
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			e.pos = LeapRules.pos_at(e.leap_from, e.lands_at, e.state_t, d.leap_time)
			e.leap_y = LeapRules.height_at(e.state_t, d.leap_time)
			if e.state_t >= d.leap_time - TICK_SLACK:
				e.pos = arena.resolve(e.lands_at, d.radius)
				e.leap_y = 0.0
				e.invulnerable = false
				Ground.end_zone(e.warning as Ground.Zone)
				e.warning = null
				fx.burst(&"dust", Vector3(e.pos.x, 0.2, e.pos.y), Vector3.UP)
				Audio.play(&"enemy_charge")
				if target_alive and LeapRules.in_area(e.lands_at, target, d.leap_half, Player.RADIUS * 0.6):
					last_by = d.id
					last_warn = d.attack_windup + d.leap_time
					last_offscreen = screen_flag(e.pos)
					hit_player.emit(d.attack_damage * _out(e), e.pos)
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.9, 1.2)
				_end_attack(e)
		_:
			e.dir = toward
			var sp := _speed(e)
			if dist > d.attack_range:
				e.pos += _walk * sp * dt
			elif dist < d.attack_range * LEAP_KEEP:
				var away := _flee(e, -toward)
				e.pos += away * sp * dt
				if away != Vector2.ZERO:
					e.dir = away
			else:
				e.pos += toward.rotated(e.side * PI * 0.5) * sp * 0.35 * dt
			if e.cooldown <= 0.0 and target_alive and dist <= d.attack_range + 0.5 and arena.inside(e.pos, 1.0) \
					and (d.max_attackers <= 0 or attackers(d) < d.max_attackers) and not _just_began(d):
				# the spot is taken now and kept (Daniel, 2026-11-23): a red circle for the wind-up and the flight
				e.lands_at = arena.resolve(target, d.radius)
				_set_state(e, Enemy.State.WINDUP, &"windup")
				e.warning = ground.add_warning(e.lands_at, d.leap_half, d.attack_windup + d.leap_time, 0.0)


## The tag on the Canalizador's beam on the floor (the robot steps out of it: Bot._danger) and how much of its fill the floor keeps.
const BEAM_TAG := &"beam"
const BEAM_FILL := 0.12


## Whether its line on the floor is held lit by it alone (the Varredor's bar, the Canalizador's beam): it ends with it.
func _holds_bar(d: EnemyDef) -> bool:
	return d.behavior == EnemyDef.Behavior.SWEEP or d.behavior == EnemyDef.Behavior.BEAM


## The Canalizador (C1e, lote C): planted, within attack_range of the paladin it shows a thread on him for attack_windup s (it follows him,
## locked the last aim_lock s), then holds a beam of shot_ticks pulses shot_interval s apart that turns after him at shot_turn degrees a
## second; each pulse hurts whoever stands in it (never within sweep_clear m of its root). A cut (the Quebra) ends it; it rests after.
func _behave_beam(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t < d.attack_windup - d.aim_lock:
				e.aim = toward
				Ground.point_line(e.warning as Ground.Zone, e.pos, e.aim)
			else:
				ground.lock_line(e.warning as Ground.Zone)
			e.dir = e.aim
			if e.state_t >= d.attack_windup - TICK_SLACK:
				Ground.end_zone(e.warning as Ground.Zone)
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				e.blows = 0
				var beam := _mark(e, ground.add_line_warning(e.pos, e.aim, d.attack_range, d.attack_width, 1.0, 0.0))
				beam.life = BEAM_FILL
				GroundLook.beam(beam.mat, d.attack_width * 0.5)
				beam.tags.append(BEAM_TAG)
				e.warning = beam
		Enemy.State.ATTACK:
			e.aim = BeamRules.turned(e.aim, toward, d.shot_turn, dt)
			e.dir = e.aim
			var beam := e.warning as Ground.Zone
			if beam != null:
				beam.life = BEAM_FILL
				Ground.point_line(beam, e.pos, e.aim)
			var reach := arena.shot_reach(e.pos, e.aim, d.attack_range, 0.1)
			while BeamRules.pulse_due(e.state_t, d.shot_interval, e.blows, d.shot_ticks):
				if e.blows > 0:
					Audio.play(&"shot_orb")  # (the first one's sound came with the attack)
				e.blows += 1
				if target_alive and BeamRules.hits(e.pos, e.aim, target, reach, d.attack_width, d.sweep_clear, Player.RADIUS * 0.6):
					last_by = d.id
					last_warn = d.attack_windup
					last_offscreen = screen_flag(e.pos)
					hit_player.emit(d.attack_damage * _out(e), e.pos)
			if e.state_t >= BeamRules.hold_time(d.shot_ticks, d.shot_interval) - TICK_SLACK:
				Ground.end_zone(beam)
				e.warning = null
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.9, 1.1)
				_end_attack(e)
		_:
			e.dir = toward
			if e.cooldown <= 0.0 and target_alive and dist <= d.attack_range and arena.inside(e.pos, 1.0) and not _just_began(d):
				e.aim = toward
				_set_state(e, Enemy.State.WINDUP, &"cast")
				e.warning = _mark(e, ground.add_aim_warning(e.pos, e.aim, d.attack_range, d.attack_width, d.attack_windup + dt, 0.0))
				ground.track_line(e.warning as Ground.Zone)


## The share of its jumping range the Saltador keeps from the paladin (4 of 7 m).
const LEAP_KEEP := 0.57


func _behave_support(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		e.dir = toward
		if e.state_t >= d.attack_windup:
			_call(e)
			e.cooldown = d.attack_cooldown * _rng.randf_range(0.9, 1.1)
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		if e.state_t >= 0.4:
			_end_attack(e)
		return
	e.dir = toward
	var sp := _speed(e)
	if dist < d.retreat_far:
		var away := _flee(e, -toward)
		if away != Vector2.ZERO:
			e.pos += away * sp * (d.flee_speed / d.speed if d.flee_speed > 0.0 and d.speed > 0.0 else 1.0) * dt
			e.dir = away
	elif dist > d.attack_range:
		e.pos += _walk * sp * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * sp * 0.35 * dt
	if e.cooldown <= 0.0 and target_alive and dist >= d.retreat_far and _calls_now(e):
		_set_state(e, Enemy.State.WINDUP, &"cast")


## Whether a call has anything to do now (the marks of the dead are set here; a shout needs someone within its reach).
func _calls_now(e: Enemy) -> bool:
	var d := e.def
	if d.shout_radius > 0.0:
		for o in list:
			if _shouted_at(e, o):
				return true
		return false
	if d.plate_damage > 0.0:
		return _plates().size() < d.plate_max
	if d.raise_count > 0:
		var standing := 0
		for r in e.raised:
			standing += int(r.alive)
		var n := room_for(mini(d.raise_count, d.raise_max - standing))
		if n <= 0:
			return false
		e.spots.clear()
		for at in SupportRules.spots(e.pos, target, n, RAISE_RING, RAISE_SPREAD, d.raise_far):
			var spot := arena.resolve(at, 0.5)
			if spot.distance_to(target) >= d.raise_far:
				e.spots.append(spot)
		return not e.spots.is_empty()
	return false


## Distance from the Coveiro at which its dead rise and the angle between them.
const RAISE_RING := 2.6
const RAISE_SPREAD := 80.0


func _shouted_at(e: Enemy, o: Enemy) -> bool:
	return o != e and o.alive and o.def.behavior != EnemyDef.Behavior.BOSS and o.state != Enemy.State.RISE and o.state != Enemy.State.DOWN \
		and SupportRules.in_reach(e.pos, o.pos, e.def.shout_radius)


## The call lands (its wind-up ran its course; a cut one never gets here).
func _call(e: Enemy) -> void:
	var d := e.def
	if d.shout_radius > 0.0:
		for o in list:
			if _shouted_at(e, o):
				o.haste_t = d.shout_time
				o.haste_pace = d.shout_pace
				o.hp = SupportRules.healed(o.hp, o.max_hp, d.shout_heal)
		fx.ring(e.pos, d.shout_radius, d.magic_color, 0.45, 0.15, true)
		Audio.play(&"summon")
	if d.plate_damage > 0.0:
		_lay_plate(e)
	if d.raise_count > 0:
		var standing := 0
		for r in e.raised:
			standing += int(r.alive)
		var kind := def(d.raise_kind)
		var n := room_for(mini(e.spots.size(), d.raise_max - standing))
		for k in n:
			e.raised.append(spawn(kind, e.spots[k], true))
			fx.burst(&"shadow", Vector3(e.spots[k].x, 0.3, e.spots[k].y))
		if n > 0:
			Audio.play(&"summon")
		e.spots.clear()


## The centres of the plates lying now (from the X to the dormant plate, until they are gone).
func _plates() -> Array[Vector2]:
	var out: Array[Vector2] = []
	for p in plates_laid:
		out.append(p.at)
	return out


## C1e, the Armadilheiro: a plate where the paladin stands, or where his last dodge ended (under plate_window s ago). Its warning is the X
## of C1eMarks for plate_time s (the zone's own red fill is hidden); then it hurts whoever stands on it, the dodge's protection excepted;
## the spikes stand plate_spikes s more and hurt who steps on them and was not hurt at the landing; the dormant plate lies on (a memory of
## the dodge, and one of the plate_max) until plate_life s after it was laid.
func _lay_plate(e: Enemy) -> void:
	var d := e.def
	var at := arena.resolve(TrapRules.spot(target, dodge_end, dodge_age, d.plate_window), d.plate_half)
	var laid := _plates()
	if not TrapRules.may_lay(at, laid, d.plate_max, d.plate_half * 1.6):
		return
	var z := ground.add_line_warning(at - Vector2(d.plate_half, 0.0), Vector2.RIGHT, d.plate_half * 2.0, d.plate_half * 2.0, d.plate_time,
		d.plate_damage * _out(e))
	z.tags.append(Ground.PLATE_TAG)
	z.node.visible = false
	var p := TrapRules.Plate.new()
	p.at = at
	p.half = d.plate_half
	p.warn = d.plate_time
	p.spikes = d.plate_spikes
	p.life = d.plate_life
	p.damage = d.plate_damage * _out(e)
	p.by = e.def.id
	plates_laid.append(p)
	Audio.play(&"summon")


## The plates age; at the landing the zone has hurt (or missed) whoever stood there, and while the spikes stand one who steps on them is hurt once.
func _step_plates(dt: float) -> void:
	var i := plates_laid.size() - 1
	while i >= 0:
		var p := plates_laid[i]
		p.age += dt
		match p.phase():
			TrapRules.Phase.GONE:
				plates_laid.remove_at(i)
			TrapRules.Phase.SPIKES:
				if not p.landed:
					p.landed = true
					p.struck = target_alive and p.covers(target, Player.RADIUS * 0.6)
				elif not p.struck and target_alive and p.covers(target, Player.RADIUS * 0.6) and not target_safe:
					p.struck = true
					ground.plate_strike(p.damage, p.at, p.by, p.warn)
		i -= 1


## Elite: stays back, raises skeletons around itself and shoots a fan of orbs.
func _behave_priest(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP and e.volley == 2:
		# A2: its three orbs aimed on the floor, held for the last FAN_LOCK s
		if e.state_t < d.volley_windup - FAN_LOCK:
			e.aim = toward
			_point_fan(e)
		if e.state_t >= d.volley_windup:
			_volley(e, e.aim)
			_end_fan(e)
			e.volley = 0
			e.volley_cd = d.volley_every
			e.cooldown = maxf(e.cooldown, d.volley_recover)
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.WINDUP:
		if not e.fan.is_empty():
			# C19-5: its fan's threads follow him until it shoots (they and the orbs leave along the same aim)
			# GP-1 (2026-11-22): held for the last FAN_LOCK, as Morvath's (Boss.FOLLOW_LOCK), so it can be stepped out of
			if e.state_t < d.attack_windup - FAN_LOCK:
				e.aim = toward
				_point_fan(e)
		if e.state_t >= d.attack_windup:
			e.memo += 1
			# every other cast raises skeletons, as many as the fight has room for (none: it conjures circles)
			var raised := 0
			if e.rows == 1:
				# the Elder's call (raise_cd_max > 0): ranged dead at the floor's edge, away from the paladin
				e.rows = 0
				e.raised.append_array(_raise_dead(e, _calls(e), &"", true))
				raised = 1
			elif d.raise_cd_max <= 0.0:
				raised = room_for(PRIEST_RAISES) if e.memo % 2 == 1 else 0
				if raised > 0:
					_raise_dead(e, raised)
			if raised <= 0:
				# the circles on the floor are Morvath's alone (Daniel, 2026-11-16): a fan of orbs
				shoot(e, e.aim if not e.fan.is_empty() else toward)
			if raised > 0:
				_end_fan(e)
			elif d.volley_count > 0 and e.volley_cd <= 0.0 and target_alive:
				e.volley = 1  # A2: after the fan it backs away and looses its volley
				e.volley_t = 0.0
			e.fan.clear()
			e.cooldown = d.attack_cooldown
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		if e.state_t >= 0.5:
			_end_attack(e)
		return
	e.dir = toward
	if e.volley == 1:
		_volley_back(e, dt, toward)
		return
	if dist > d.attack_range or not _can_fire(e):
		e.pos += _walk * _speed(e) * dt
	elif dist < d.attack_range * 0.6:
		e.pos -= toward * _speed(e) * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt
	if e.cooldown <= 0.0 and target_alive and _can_fire(e):
		# T5-03: raising the dead is its own gesture (the priest's ritual), the fan of orbs the staff's
		var raises := (e.memo + 1) % 2 == 1 and room_for(PRIEST_RAISES) > 0
		if d.raise_cd_max > 0.0:
			raises = e.call_cd <= 0.0 and _calls(e) > 0
			e.rows = 1 if raises else 0
			if raises:
				e.call_cd = _rng.randf_range(d.raise_cd_min, d.raise_cd_max)
		_set_state(e, Enemy.State.WINDUP, &"summon" if raises else &"cast")
		if not raises:
			_aim_fan(e, toward)


## C19-5 (Q-14 a, combat_cadence.md 8.2): the threads of a fan of shots winding up, in the crossbow's grammar
## (Ground.add_aim_warning): one per shot, up to FAN_THREADS (the elder's five: with only its edges and its middle,
## stepping off a thread put him on an orb with none, and the robot's hits by the elder went 45 to 99 in 24 seeds),
## born together with the wind-up and full on the frame it shoots, each as long as its shot flies before stone.
const FAN_THREADS := 5
## Seconds before the fan leaves in which its aim no longer follows him.
const FAN_LOCK := 0.35
const AIM_THREAD_WIDTH := 0.7
## The tag on those threads (Ground.Zone.tags): the robot dodges their shots, not the threads (Bot._danger).
const FAN_TAG := &"aim_fan"


func _aim_fan(e: Enemy, toward: Vector2, count: int = -1, spread: float = -1.0, windup: float = -1.0) -> void:
	_end_fan(e)
	var d := e.def
	e.fan_spread = spread
	var n := mini(FAN_THREADS, maxi(1, d.shot_count if count < 0 else count))
	for i in n:
		var z := _mark(e, ground.add_aim_warning(e.pos, toward, 1.0, AIM_THREAD_WIDTH, (d.attack_windup if windup < 0.0 else windup) + _dt, 0.0))
		z.tags.append(FAN_TAG)
		e.fan.append(z)
	e.aim = toward
	_point_fan(e)


## A2: the elder backs volley_back meters from him over volley_back_time s (stopping at a wall, a stone or the end of the
## time), then raises its staff: the threads of its three orbs are born with the wind-up.
func _volley_back(e: Enemy, dt: float, toward: Vector2) -> void:
	var d := e.def
	e.volley_t += dt
	var away := _flee(e, -toward)
	var blocked := away == Vector2.ZERO
	if not blocked:
		e.pos += away * (d.volley_back / maxf(d.volley_back_time, 0.1)) * dt
	if blocked or e.volley_t >= d.volley_back_time:
		e.volley = 2
		_set_state(e, Enemy.State.WINDUP, &"cast")
		e.aim = toward
		_aim_fan(e, toward, d.volley_count, d.volley_spread, d.volley_windup)


## A2: the slow orbs that turn after him.
func _volley(e: Enemy, dir: Vector2) -> void:
	var d := e.def
	var n := maxi(1, d.volley_count)
	Audio.play(CombatSounds.shot(d))
	for i in n:
		var turn := 0.0 if n == 1 else deg_to_rad(d.volley_spread) * (float(i) / float(n - 1) - 0.5)
		var aim := dir.rotated(turn)
		var s := projectiles.fire(Projectiles.Kind.ORB, e.pos + aim * (d.radius + 0.2), aim, d.volley_speed,
			d.attack_damage * _out(e), 0.45, d.volley_life, d.magic_color)
		s.warned = d.volley_windup
		s.turn = deg_to_rad(d.volley_turn)
		s.homing = d.volley_life


## Turns the fan's threads with e.aim (each the length its shot flies before stone stops it).
func _point_fan(e: Enemy) -> void:
	var d := e.def
	var n := e.fan.size()
	var reach := d.shot_range if d.shot_range > 0.0 else d.attack_range * RANGED_REACH
	for i in n:
		var turn := 0.0 if n == 1 else deg_to_rad(d.shot_spread if e.fan_spread < 0.0 else e.fan_spread) * (float(i) / float(n - 1) - 0.5)
		var dir := e.aim.rotated(turn)
		var z := e.fan[i] as Ground.Zone
		if z == null or z.cancelled or z.node == null or not is_instance_valid(z.node):
			continue  # (the floor was cleared under it: a new room, his fall)
		var from := e.pos + dir * (d.radius + 0.2)
		var length := arena.shot_reach(from, dir, reach, Projectiles.SHOT_EDGE)
		if absf(z.radius - length) > 0.05:
			z.radius = length
			z.node.scale.z = length
			GroundLook.put(z.mat, &"length_m", length)
		Ground.point_line(z, from, dir)


func _end_fan(e: Enemy) -> void:
	for z in e.fan:
		Ground.end_zone(z as Ground.Zone)
	e.fan.clear()


## Runs in close, stops, glows (the warning ring) and bursts all around itself.
func _behave_pulse(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			# C19-2: each burst after the first gets its ring on the frame of the one before, where the body is, full
			# on the frame of its own (strike_gap, at least 0.5 s to read a new ring)
			while e.blows < d.strikes and e.state_t >= blow_at(e, e.blows) - TICK_SLACK:
				if e.blows > 0:
					Audio.play(CombatSounds.strike(d))  # (the first one's sound came with the attack)
				e.blows += 1
				if e.blows < d.strikes:
					e.warning2 = _mark(e, ground.add_warning(e.pos, d.attack_width, d.strike_gap + dt, d.attack_damage * _out(e), d.magic_color))
					(e.warning2 as Ground.Zone).land_quick = e.blows < d.strikes - 1
			if e.state_t >= blow_at(e, d.strikes - 1) + PULSE_AFTER:
				e.warning2 = null
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_end_attack(e)
		_:
			e.dir = toward
			# (C19, combat_cadence.md 8.3 (b): pushed off his body while it waits it walked in again at once, a 12 cm saw
			# at 8 Hz; it walks again only MELEE_WALK_BAND past its reach, as the knight)
			e.closing = dist > (d.attack_range if e.closing else d.attack_range + MELEE_WALK_BAND)
			if e.closing:
				e.pos += _walk * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"windup")
				e.strike_t = d.strike_at
				e.blows = 0
				# it bursts as its arms open, strike_at into its attack (T5-09): the warning fills until then
				e.warning = _mark(e, ground.add_warning(e.pos, d.attack_width, d.attack_windup + d.strike_at + dt, d.attack_damage * _out(e), d.magic_color))
				# (P2-C19a: a burst with another after it leaves only a thin ring for LAND_QUICK s, never over the next)
				(e.warning as Ground.Zone).land_quick = d.strikes > 1
			else:
				e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt


## C5, the Varredor (CB-7): rooted, it lays a bar of floor along a line (SweepRules.start_dir: behind where the paladin
## stands, with a thread ahead of it for the way it will turn), follows him with it until the last aim_lock seconds, then
## swings it round itself, sweep_degrees in sweep_time; within sweep_clear m of it the bar does not hurt. Only the bar's
## own place hurts, where the drawn bar is now (once a sweep), and it rests recover_time after it.
const SWEEP_TRIGGER := 1.5
## The tag on every zone of a sweep (Ground.Zone.tags): the robot keeps to its pocket and steps out of the bar's reach (Bot._danger).
const SWEEP_TAG := &"sweep"
## The drawn bar of a sweep keeps this much of its fill in the floor's step (Ground fills it by its life).
const SWEEP_FILL := 0.12


func _behave_sweep(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t < d.attack_windup - d.aim_lock:
				e.aim = SweepRules.start_dir(toward, e.side)
				_point_sweep_marks(e)
			else:
				ground.lock_line(e.warning as Ground.Zone)
			e.dir = e.aim
			if e.state_t >= d.attack_windup - TICK_SLACK:
				Ground.end_zone(e.warning as Ground.Zone)
				Ground.end_zone(e.warning2 as Ground.Zone)
				e.warning2 = null
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				e.landed = false
				# the bar itself, held lit by keeping its life up (Ground fills a warning as its life runs out)
				var bar := _mark(e, ground.add_line_warning(e.pos, e.aim, d.attack_range, d.attack_width, 1.0, 0.0))
				bar.life = SWEEP_FILL
				GroundLook.put(bar.mat, &"root_clear_m", d.sweep_clear)
				bar.tags.append(SWEEP_TAG)
				e.warning = bar
		Enemy.State.ATTACK:
			var dir := SweepRules.dir_at(e.aim, e.side, d.sweep_degrees, d.sweep_time, e.state_t)
			e.dir = dir
			var bar := e.warning as Ground.Zone
			if bar != null:
				bar.life = SWEEP_FILL
				Ground.point_line(bar, e.pos, dir)
			if not e.landed and target_alive and SweepRules.in_bar(e.pos, dir, target, d.attack_range, d.attack_width, d.sweep_clear, Player.RADIUS * 0.6):
				e.landed = true
				last_by = d.id
				last_warn = d.attack_windup
				last_offscreen = screen_flag(e.pos)
				hit_player.emit(d.attack_damage * _out(e), e.pos)
			if e.state_t >= d.sweep_time - TICK_SLACK:
				Ground.end_zone(bar)
				e.warning = null
				e.cooldown = d.attack_cooldown
				_end_attack(e)
		_:
			e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0)) if e.dir.length_squared() > 0.01 else toward
			if e.cooldown <= 0.0 and target_alive and dist <= d.attack_range + SWEEP_TRIGGER and (d.max_attackers <= 0 or attackers(d) < d.max_attackers):
				e.side = -e.side
				e.aim = SweepRules.start_dir(toward, e.side)
				_set_state(e, Enemy.State.WINDUP, &"windup")
				var time := d.attack_windup + dt
				e.warning = _mark(e, ground.add_line_warning(e.pos, e.aim, d.attack_range, d.attack_width, time, 0.0))
				GroundLook.put((e.warning as Ground.Zone).mat, &"root_clear_m", d.sweep_clear)
				(e.warning as Ground.Zone).tags.append(SWEEP_TAG)
				ground.track_line(e.warning as Ground.Zone)
				e.warning2 = _mark(e, ground.add_aim_warning(e.pos, e.aim, d.attack_range * 0.8, SWEEP_WAY_WIDTH, time, 0.0))
				(e.warning2 as Ground.Zone).tags.append(SWEEP_TAG)
				_point_sweep_marks(e)


## The bar's width of the thread that tells the way the bar will turn (the warning of the bar itself is the bar's width).
const SWEEP_WAY_WIDTH := 0.45


## The wind-up's bar on the line it starts along and the thread SweepRules.WAY_DEGREES ahead of it, the way it turns.
func _point_sweep_marks(e: Enemy) -> void:
	Ground.point_line(e.warning as Ground.Zone, e.pos, e.aim)
	if e.warning2 != null:
		Ground.point_line(e.warning2 as Ground.Zone, e.pos, e.aim.rotated(e.side * deg_to_rad(SweepRules.WAY_DEGREES)))


## Comes to mid range, plants itself and blasts a wide cone ahead.
func _behave_cone(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				if d.magic_color.a > 0.0:
					# the fan of bolts flying out over the cone that was marked
					fx.slash(e.pos, e.aim, d.attack_range + 0.5, d.attack_width, d.magic_color, VOLLEY_TIME, false, 0.9, false, 0.0)
		Enemy.State.ATTACK:
			if e.state_t >= 0.5:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_end_attack(e)
		_:
			e.dir = toward
			if dist > d.attack_range * 0.8:
				e.pos += _walk * _speed(e) * dt
			if dist < d.attack_range and e.cooldown <= 0.0 and target_alive:
				e.aim = toward
				_set_state(e, Enemy.State.WINDUP, &"aim")
				e.warning = _mark(e, ground.add_arc_warning(e.pos, toward, d.attack_range + 0.5, d.attack_width, d.attack_windup, d.attack_damage * _out(e)))


## The way to walk toward the paladin (cycle C12): straight while the floor between is clear (or he is near), else
## along the arena's FlowField round what blocks; kept WAY_EVERY seconds. Enemy.straight says which it is.
func _way(e: Enemy, toward: Vector2, dist: float) -> Vector2:
	if arena == null or arena.flow == null:
		e.straight = true
		return toward
	e.way_t -= _dt
	if e.way_t <= 0.0:
		e.way_t = WAY_EVERY * (0.75 + 0.5 * e.look)
		e.straight = dist < WAY_NEAR or (e.straight and dist < WAY_FAR) or arena.nav.clear_line(e.pos, target)
		if not e.straight:
			e.way = arena.flow.next_step(e.pos)
			if e.way == Vector2.ZERO:
				e.straight = true
	return toward if e.straight else e.way


## A shooter may wind up: a clear line of fire to the paladin and its body on the far camera's screen (VIEW_EDGE).
func _can_fire(e: Enemy) -> bool:
	if not arena.clear_shot(e.pos, target, LINE_OF_FIRE):
		return false
	return on_screen(e.pos)


## True when a body at p shows on the far camera's screen, VIEW_EDGE inside its edges (always, without a view).
func on_screen(p: Vector2) -> bool:
	return _inside(view, p)


## True when a body at p shows on the screen of the camera in use, VIEW_EDGE inside its edges (the far one without seen).
func in_sight(p: Vector2) -> bool:
	return _inside(seen if seen.is_valid() else view, p)


static func _inside(frame: Callable, p: Vector2) -> bool:
	if not frame.is_valid():
		return true
	var s: Vector2 = frame.call(p)
	return s.x >= VIEW_EDGE and s.x <= 1.0 - VIEW_EDGE and s.y >= VIEW_EDGE and s.y <= 1.0 - VIEW_EDGE


## For the run's log: 1 when a body at p is off the screen in use, 0 on it, -1 unknown (no view, or p is Vector2.INF).
func screen_flag(p: Vector2) -> int:
	if not (seen.is_valid() or view.is_valid()) or not p.is_finite():
		return -1
	return 0 if in_sight(p) else 1


## The shooters (ARCHER, and the elder PRIEST: everyone _can_fire lets wind up) winding up now off the screen of the camera in use (the far camera's rule lets them, LR-02):
## for the HUD's edge marks (ui-ux-designer). Each is the Enemy itself (pos, def, state_t of its windup).
func off_screen_windups() -> Array[Enemy]:
	var out: Array[Enemy] = []
	for e in list:
		if e.state == Enemy.State.WINDUP and (e.def.behavior == EnemyDef.Behavior.ARCHER or e.def.behavior == EnemyDef.Behavior.PRIEST) \
				and not in_sight(e.pos):
			out.append(e)
	return out


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
	if e.def.id in IDLE_TRACKED:
		if state == Enemy.State.WALK and e.state != Enemy.State.WALK:
			e.idle_gap = 0.0
		if state == Enemy.State.RECOVER or (state == Enemy.State.WALK and e.state == Enemy.State.ATTACK):
			e.idle_dead = 0.0
		elif state != Enemy.State.WALK and e.idle_gap >= 0.0:
			var st := _idle_stats(e)
			st.add_gap(e.idle_gap)
			if e.idle_dead >= 0.0:
				st.add_dead(e.idle_dead)
			e.idle_gap = -1.0
			e.idle_dead = -1.0
	if state == Enemy.State.WINDUP and e.state != Enemy.State.WINDUP:
		_tally_windup(e, 0)
	elif e.state == Enemy.State.WINDUP and state != Enemy.State.WINDUP:
		_tally_windup(e, 2 if _cutting else 1)
	if state == Enemy.State.WINDUP and e.state != Enemy.State.WINDUP:
		Audio.play(CombatSounds.windup(e.def))  # (C15-02: every wind-up is heard, by what it shows)
	elif state == Enemy.State.ATTACK:
		var loosed := CombatSounds.strike(e.def)
		if loosed != &"":
			Audio.play(loosed)
	e.state = state
	e.state_t = 0.0
	if state == Enemy.State.WINDUP:
		e.drawn_tick = 0
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
					var shove := d / len * (min_d - len) * SEPARATE
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


## The half angle of the front a shield covers (EnemyDef.front_block), in degrees.
const FRONT_DEGREES := 75.0


## Its shield is up at all (the rule's conditions without the angle): it has one, the guard is not open, and it is not
## spent nor helpless. blocks_front and the drawing (the streaks on the floor, the open walk) read this one.
func guard_up(e: Enemy) -> bool:
	if e.def.guard_up_time > 0.0 and e.guard_t <= 0.0:
		return false  # (K3: a guardian's shield is up only by time)
	return e.def.front_block > 0.0 and e.open_t <= 0.0 and e.state != Enemy.State.RECOVER and not e.helpless()


## Its shield stands between it and `from` now: guard not open, not spent nor helpless, and `from` in front of it.
func blocks_front(e: Enemy, from: Vector2) -> bool:
	if not guard_up(e):
		return false
	var to := from - e.pos
	var ahead := e.face if e.face != Vector2.ZERO else e.dir
	return to.length_squared() > 0.0001 and absf(ahead.angle_to(to)) <= deg_to_rad(FRONT_DEGREES)


## `from` is at its back (past 110 degrees of where it faces).
func behind(e: Enemy, from: Vector2) -> bool:
	var to := from - e.pos
	var ahead := e.face if e.face != Vector2.ZERO else e.dir
	return to.length_squared() > 0.0001 and absf(ahead.angle_to(to)) >= deg_to_rad(110.0)


## The special opens its guard (EnemyDef.front_open).
func open_guard(e: Enemy) -> void:
	if e.def.front_block <= 0.0 or (e.def.guard_up_time > 0.0 and e.guard_t <= 0.0):
		return
	if e.open_t <= 0.0:
		tells.armor_break(Vector3(e.pos.x, e.y + 1.2 * e.def.size, e.pos.y), e.def.size * 0.6, EnemyFx.STEEL)
		tells.guard_fling(e)
		fx.word(Vector3(e.pos.x, 2.0 + 1.6 * e.def.size, e.pos.y), T.t(&"word_guard_open"), Combat.LIGHT)
	e.open_t = e.def.front_open


## CB-4: the priest armors the plain enemies nearest to it, and the threads of it rise from them while it stands.
func _step_ward(e: Enemy, dt: float) -> void:
	e.ward_t -= dt
	if e.ward_t > 0.0:
		return
	e.ward_t = e.def.ward_every
	var near: Array[Enemy] = []
	for o in list:
		if o.alive and o != e and o.def.ward_count <= 0 and not o.def.elite and o.def.behavior != EnemyDef.Behavior.BOSS \
				and o.armor <= 0.0 and o.state != Enemy.State.RISE and o.pos.distance_to(e.pos) <= e.def.ward_radius:
			near.append(o)
	near.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.pos.distance_squared_to(e.pos) < b.pos.distance_squared_to(e.pos))
	for o in near.slice(0, e.def.ward_count):
		o.warded_by = e
		o.max_armor = e.def.ward_armor
		o.armor = e.def.ward_armor
		fx.ring(o.pos, o.def.radius + 0.5, EnemyFx.OLD_GOLD, 0.35, 0.15, true)
		var back: Vector2 = e.pos - o.pos
		fx.wisps(Vector3(o.pos.x, 1.0, o.pos.y), Vector3(back.x, 0.6, back.y), e.def.magic_color, 5, 3.0, 0.4, 0.7, 0.15, 0.3)


## Peaks of the body's give when armor took a heavy blow (combate_c1_leitura 7): a common body, a guardian.
const HEAVY_ARMOR_PEAK: Array[float] = [0.06, 0.04]
const CRACK_TIME := 0.18
const CRACK_PITCH: Array[float] = [1.0, 0.92, 0.84]
const CRACK_KICK := 0.15


## The armor crossed 75, 50 or 25% (once each; two at once: the lower): shards from the chest, a white breath, its
## sound; a guardian more shards and a short kick. Only drawn and heard.
func _crack(e: Enemy, chest: Vector3, from_dir: Vector2, level: int) -> void:
	e.crack_t = CRACK_TIME
	tells.armor_crack(chest, -from_dir, e.def.size, e.def.heavy)
	Audio.play(&"mat_armor", CRACK_PITCH[clampi(level - 1, 0, 2)])
	if fx != null and e.def.heavy and from_dir != Vector2.ZERO:
		fx.kick(from_dir.normalized(), CRACK_KICK)


func _unward(e: Enemy) -> void:
	e.warded_by = null
	e.armor = 0.0
	e.max_armor = 0.0


## It fell: the armor it gave goes with it.
func _end_wards(e: Enemy) -> void:
	for o in list:
		if o.warded_by == e:
			var chest := Vector3(o.pos.x, o.y + 1.2 * o.def.size, o.pos.y)
			if o.alive and _palms.has(e):
				# the thread parts from the middle to the ends (drawn: the palm it ran from, last frame's)
				tells.ward_cut((_palms[e] as Array)[o.get_instance_id() % 2], chest)
			tells.armor_break(chest, o.def.size * 0.6)
			_unward(o)


## Damage to an enemy. Returns true when it died.
## `flash` false: no flash of a blow on the body (a burn's tick).
func damage(e: Enemy, amount: float, from_dir: Vector2, knockback: float, color: Color = Fx.GOLD, show_number: bool = true, big: bool = false, flash: bool = true) -> bool:
	if not e.alive or e.invulnerable:
		return false
	if e.broken_t > 0.0 and e.armor <= 0.0:
		amount *= 1.0 + (boss_vuln if e.def.behavior == EnemyDef.Behavior.BOSS else e.def.poise_vuln)  # C1b: a broken poise leaves it open (C1d: so does Morvath's Postura)
	# what it really takes off (armor, or life down to its floor), under where it came from (DT-016)
	dealt.add(dealing, minf(amount, e.armor) if e.armor > 0.0 else clampf(e.hp - e.hp_floor, 0.0, amount))
	if e.state == Enemy.State.RECOVER and flash and from_dir != Vector2.ZERO:
		_tally_windup(e, 3)  # a blow in its window after the attack (on the armor too)
	if e.armor > 0.0:
		# armor takes the blow: no push, no flinch; breaking it staggers (Game listens to armor_broken)
		var level_before := EnemyFx.wear_level(e.armor, e.max_armor)
		e.armor = DamageCalc.against_armor(e.armor, amount)[0]
		e.flash_t = FLASH_TIME
		e.flash_power = WEAK_FLASH
		e.absorbed = true
		var chest := Vector3(e.pos.x, e.y + 1.2 * e.def.size, e.pos.y)
		var heavy_hit := heavy_blow or strong
		if show_number:
			fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, ARMOR_COLOR, big, e.get_instance_id())
			tells.armor_hit(chest, from_dir, EnemyFx.HEAVY_SPARKS if heavy_hit else EnemyFx.ABSORB_SPARKS)
		if heavy_hit and flash and from_dir != Vector2.ZERO:
			# only drawn: the gold edge a moment longer and the body gives a little (never the hit pose)
			e.edge_t = EnemyFx.HEAVY_EDGE
			e.recoil_t = 0.0
			e.recoil_dir = from_dir.normalized()
			e.recoil_peak = HEAVY_ARMOR_PEAK[1 if e.def.heavy else 0]
		var level := EnemyFx.wear_level(e.armor, e.max_armor)
		if e.armor > 0.0 and level > level_before and e.max_armor > 0.0:
			_crack(e, chest, from_dir, level)
		if e.armor <= 0.0:
			tells.armor_break(chest, e.def.size)
			if e.warded_by != null:
				_unward(e)  # (a ward broken staggers no one: the plain enemy under it is no elite)
			else:
				armor_broken.emit(e)
		return false
	e.absorbed = false
	e.hp = maxf(e.hp - amount, e.hp_floor)
	if amount > 0.0:
		e.calm_t = 0.0
	if flash:
		e.flash_t = FLASH_TIME
		e.flash_power = 1.0 if big else WEAK_FLASH
		if e.def.behavior == EnemyDef.Behavior.BOSS:
			e.flash_power = minf(e.flash_power, BOSS_FLASH)
		if from_dir != Vector2.ZERO:
			# only drawn: the body jolts back from the blow and returns (HitRecoil)
			e.recoil_t = 0.0
			e.recoil_dir = from_dir.normalized()
			e.recoil_peak = 0.0
	if e.hp > 0.0 and e.def.poise > 0.0 and flash and from_dir != Vector2.ZERO:
		_wear_poise(e, from_dir)
	if e.hp > 0.0 and e.def.behavior == EnemyDef.Behavior.BOSS and flash and from_dir != Vector2.ZERO:
		boss_blow.emit(e, dealing)
	if (e.state == Enemy.State.WALK or e.state == Enemy.State.RECOVER) and not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
		e.hurt_t = HURT_TIME
	if flash and from_dir != Vector2.ZERO and e.hp > 0.0 and StunRule.stuns(big or strong):
		# a blow, not a burn's tick or a zone's: a common body flinches (GF-12), longer by the blow's stun_scale (the
		# Refinar Peso, Fatia 2: Combat sets it around its damage)
		flinch(e, (e.def.stun_heavy_time if big else e.def.stun_time) * stun_scale)
	if knockback > 0.0:
		e.push = from_dir * knockback * (0.35 if e.def.heavy else 1.0)
	if show_number:
		fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, color, big, e.get_instance_id(),
			from_dir == Vector2.ZERO and knockback <= 0.0)
	if e.hp <= 0.0:
		if e.def.rise_time > 0.0 and e.group_id != 0 and _standing_of(e) > 0:
			_lie_down(e)  # C5: a Trinca's figure falls into a mound while another of them stands
			return false
		if e.mod != null and e.mod.echo_time > 0.0 and not e.echoed:
			e.echoed = true
			_lie_down(e)  # C1e, the Eco: a mound that rises once, alone, with a share of its life
			return false
		if e.state == Enemy.State.WINDUP:
			_tally_windup(e, 2)
		if e.def.death_burst > 0.0:
			# CB-4: what burned in it bursts a moment later
			var by := acting
			acting = e.def.id
			ground.add_ember_warning(e.pos, e.def.attack_width, e.def.death_burst, e.def.attack_damage * _out(e))
			acting = by
		if e.mod != null and e.mod.burst_arms > 0:
			_cross_burst(e)  # C1e, the Detonante
		if e.def.ward_count > 0:
			_end_wards(e)
		# its blows still to come (C19: a second blade or burst, a fan's threads) go with it
		if _holds_bar(e.def) and e.warning != null:
			Ground.end_zone(e.warning as Ground.Zone)  # (C5: the bar of a sweep is held lit by the Varredor alone)
			e.warning = null
		if e.warning2 != null:
			Ground.end_zone(e.warning2 as Ground.Zone)
			e.warning2 = null
		_end_fan(e)
		e.alive = false
		e.state = Enemy.State.DEAD
		if e.def.behavior == EnemyDef.Behavior.BOSS:
			e.flash_t = 0.0  # the blow that fells a boss leaves no flash on him (BUG-004)
		e.dead_t = 0.0
		e.anim = &"death"
		if from_dir != Vector2.ZERO:
			e.dir = -from_dir
			e.face = Vector2.ZERO
			if not e.def.heavy and e.def.behavior != EnemyDef.Behavior.BOSS:
				var power := THROW + knockback * 0.8 + (5.0 if big else 0.0)
				e.push = from_dir * power * _rng.randf_range(0.8, 1.2)
				e.vy = THROW_UP * _rng.randf_range(0.7, 1.2) + (3.0 if big else 0.0)
				e.spin = _rng.randf_range(0.6, 1.0)
		Audio.play(CombatSounds.kill(e.def))
		fx.burst(&"bone" if e.def.undead else &"dust", Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(from_dir.x, 0, from_dir.y))
		if e.def.elite and e.def.gild > 0.0:
			# V-14: an elite (its steel gilded; not the guardians) falls with two slivers of old gold more (its gilded steel), never more gold than that
			fx.chips(Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(from_dir.x, 0.6, from_dir.y), CrowdRenderer.GILD_COLOR, 2,
				5.5, 0.12, 0.6, 1.2)
		killed.emit(e)
		_end_group(e)
		return true
	return false


## C1b (Poise): a blow of the paladin wears the poise by its button (Feel.poise_weights, by `dealing`); at 0 it breaks.
func _wear_poise(e: Enemy, from_dir: Vector2) -> void:
	var d := e.def
	if not Poise.takes(d.poise, e.frozen_t, e.stun_t, e.state == Enemy.State.DOWN or e.state == Enemy.State.RISE, e.invulnerable):
		return
	var shr := Poise.share(dealing, Feel.live().poise_weights)
	if shr <= 0.0:
		return
	e.poise = Poise.wear(e.poise, d.poise, shr)
	e.poise_idle = 0.0
	if e.poise > 0.0:
		return
	var key := String(dealing)
	breaks[key] = int(breaks.get(key, 0)) + 1
	interrupt(e)
	e.stun_t = maxf(e.stun_t, d.poise_stun)
	e.stun_len = d.poise_stun
	e.broken_t = d.poise_stun
	e.hurt_t = HURT_TIME
	var chest := Vector3(e.pos.x, e.y + 1.2 * d.size, e.pos.y)
	tells.armor_break(chest, d.size * 0.8, EnemyFx.POISE_BREAK)
	Audio.play(CombatSounds.EVENTS[&"stagger"])
	fx.word(Vector3(e.pos.x, 2.0 + 2.0 * d.size, e.pos.y), T.t(&"word_poise"), Combat.LIGHT)
	poise_broken.emit(e, dealing)


func _poise_timers(e: Enemy, dt: float) -> void:
	if e.broken_t > 0.0:
		e.broken_t = maxf(0.0, e.broken_t - dt)
		if e.broken_t <= 0.0:
			e.poise = e.def.poise  # it recovers: full again
			e.poise_idle = 0.0
		return
	e.poise_idle += dt
	e.poise = Poise.settle(e.poise, e.def.poise, e.poise_idle, e.def.poise_idle)


## GF-12 (D-42, Hades II per enemy): a blow stuns it for `seconds` (EnemyDef.stun_time, stun_heavy_time): it stops
## (helpless), a wind-up or an attack under way is cut (interrupt) and it shows the hit pose. Not while it rises, nor
## while its own attack is loosed when that cannot be cut (EnemyDef.stun_immune_attacking); 0 seconds: never (the
## guardians, Morvath). Armor never gets here: a blow on the bar returns before (damage). True when it took.
func flinch(e: Enemy, seconds: float) -> bool:
	if seconds <= 0.0 or not e.alive or e.state == Enemy.State.RISE:
		return false
	if e.state == Enemy.State.ATTACK and e.def.stun_immune_attacking:
		return false
	interrupt(e)
	if seconds >= e.stun_t:
		e.stun_len = seconds  # its hit pose is stretched over this stun (Horde.render)
	e.stun_t = maxf(e.stun_t, seconds)
	e.hurt_t = HURT_TIME
	flinches += 1
	return true


## Cuts the attack it is winding up or loosing: it never lands, its warning on the floor goes at once (a wind-up
## shows nothing more) and it walks again when it can move. A cut attack that was already loosed counts as spent
## (its cooldown starts); a cut wind-up leaves it ready, to be announced again in full. True when one was cut.
func interrupt(e: Enemy) -> bool:
	if e.state != Enemy.State.WINDUP and e.state != Enemy.State.ATTACK:
		return false
	if e.state == Enemy.State.ATTACK:
		e.cooldown = maxf(e.cooldown, e.def.attack_cooldown)
	else:
		e.rearm = true  # a cut wind-up comes again in full, REARM after the stun (AUDIT.md P5)
	if e.warning != null:
		Ground.end_zone(e.warning as Ground.Zone)
		e.warning = null
	if e.warning2 != null:
		Ground.end_zone(e.warning2 as Ground.Zone)
		e.warning2 = null
	_end_fan(e)
	e.volley = 0
	if e.def.behavior != EnemyDef.Behavior.PRIEST:
		e.memo = 0  # (a knight's slam, a burst's ticks; the elder priest counts its casts there)
	_cutting = true
	_set_state(e, Enemy.State.WALK, &"walk")
	_cutting = false
	interrupts += 1
	Audio.play(CombatSounds.EVENTS[&"interrupt"])
	return true


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


## DT-102: one wind-up of e's kind started (0), reached its blow (1) or was cut (2); C19-1: a blow it took in its
## recovery (3, the window punished).
func _tally_windup(e: Enemy, what: int) -> void:
	var id := String(e.def.id)
	if not windups.has(id):
		windups[id] = [0, 0, 0, 0]
	windups[id][what] += 1


func _idle_stats(e: Enemy) -> IdleStats:
	if not idle.has(e.def.id):
		idle[e.def.id] = IdleStats.new()
	return idle[e.def.id]


## One step of a guardian's cadence count: earned openings (stunned, shield away, armor broken) are left out.
func _tally_idle(e: Enemy, dt: float) -> void:
	var earned := e.stun_t > 0.0 or e.away_t > 0.0 or e.open_t > 0.0 or e.broken_t > 0.0 or e.helpless()
	var walking := e.state == Enemy.State.WALK
	_idle_stats(e).tick(dt, walking, earned, e.state == Enemy.State.RECOVER)
	if earned:
		return
	if e.state == Enemy.State.RECOVER or walking:
		e.idle_dead += dt if e.idle_dead >= 0.0 else 0.0
	if walking and e.idle_gap >= 0.0:
		e.idle_gap += dt


## The guardians' idle gaps and shares for RESULT: {id: {n, mean, p90, max, share, fight}}.
func idle_report() -> Dictionary:
	var out := {}
	for id: StringName in idle:
		out[String(id)] = (idle[id] as IdleStats).report()
	return out


## The wind-ups by kind for RESULT: {id: {started, struck, cut, punished}}.
func windup_report() -> Dictionary:
	var out := {}
	for id: String in windups:
		var w: Array = windups[id]
		out[id] = {"started": w[0], "struck": w[1], "cut": w[2], "punished": w[3]}
	return out


## Removes the common crowd (the crypt doors opened): no experience, no drops. Elites and bosses stay.
func clear_crowd() -> void:
	plates_laid.clear()
	for e in list:
		if not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
			e.alive = false
			e.state = Enemy.State.DEAD
			e.anim = &"death"
			if e.warning != null and _holds_bar(e.def):
				Ground.end_zone(e.warning as Ground.Zone)
				e.warning = null
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


## Seconds a change of clip fades over (E1c): the pose shown last fades into the new clip (CrowdRenderer.add_kind's
## from_row and fade), never cut. A boss's a little longer (his blows are 0.4 to 1.1 s long; bug 3: each change jumped
## his body up to 0.96 m in one frame); every other figure's 0.1 s (AUDIT.md P4). T5b P1-3: his 0.18 s (it was 0.12): from
## the end of the scythe, the rain or his stun into the guard the body crossed 0.13 to 0.16 m a frame, more than the clips
## move on their own (0.03 to 0.04).
const CLIP_FADE := 0.1
## The guard's open and shut clips fade into each other over this (combate_c1_leitura 2); the lit streak of a blow it shut.
const GUARD_FADE := 0.12
## The fuse of a runner falling (its death_burst): swell to this much more, tremble this far (m, from, to).
const FUSE_SWELL := 0.12
const FUSE_SHAKE := Vector2(0.02, 0.06)
## Who a priest armors glows between these flashes (as an absorbed blow's old gold) at WARDED_HZ.
const WARDED_GLOW := Vector2(0.20, 0.34)
const WARDED_HZ := 1.2
## Where each priest's palms are this frame (Enemy -> [left, right]), for the threads.
var _palms := {}
const GUARD_BLOCK_TIME := 0.12
const BOSS_CLIP_FADE := 0.18
## T5-12: a recovery fades into the guard over this long once its clip has played.
const RECOVER_FADE := 0.3
## T5-13: each shot of a burst starts its throw from the pose of the one before over this long.
const SHOT_FADE := 0.04


## T5-01: how far into its wind-up clip a body `t` seconds into a wind-up of `windup` is (0..1): 0 while it settles
## (`settle` seconds), then eased in and out (smoothstep) until the hold (the last `hold` share), 1 through the hold.
static func windup_arm(t: float, windup: float, settle: float, hold: float) -> float:
	var top := windup * (1.0 - hold)
	if top <= settle:
		return 1.0 if t >= top else 0.0
	return smoothstep(settle, top, t)


## T5-10: which steps a walking body takes: &"walk", or its own sideways (strafe_l, strafe_r) or backwards (back)
## steps when slow and turned away from where it walks while facing its aim, if its figure has them.
static func walk_side(e: Enemy, kind: CrowdRenderer.Kind) -> StringName:
	var speed := e.vel.length()
	if speed >= SIDE_STEP_BELOW or speed < 0.01 or kind.model.frame_count(&"strafe_l") == 0:
		return &"walk"
	var f := e.face if e.face != Vector2.ZERO else e.dir
	var a := rad_to_deg(f.angle_to(e.vel))
	if absf(a) >= BACK_FROM:
		return &"back" if kind.model.frame_count(&"back") > 0 else &"walk"
	if absf(a) < SIDE_FROM:
		return &"walk"
	# (x, z) on the floor: a body facing +z has its left at +x, a positive angle from its facing
	return &"strafe_l" if a > 0.0 else &"strafe_r"
## Draws every living and dying enemy. Called every frame, also while the game is paused for hit stop.
## render_dt: the world's seconds since the last call (fades, the walk's pace and the held blow go with the world's time).
func render(render_dt := 1.0 / 60.0) -> void:
	renderer.begin()
	var few := list.size() <= BARS_FOR_ALL
	var crowded := not few
	var now := Time.get_ticks_msec() * 0.001
	if bar_trails.size() > list.size() + 32:
		bar_trails.prune(func(who: Object) -> bool: return (who as Enemy).alive)
	tells.begin()
	_palms.clear()
	var lead := Feel.live().bang_lead
	_bang_cd = maxf(0.0, _bang_cd - render_dt)
	for e in list:
		var d := e.def
		# PT-1: the "!" over a blow the floor does not show, for the last Feel.bang_lead seconds before it lands
		var due := strike_in(e) if e.alive else -1.0
		if due > 0.0 and due <= lead:
			tells.alert(e, lead - due)
			if not e.alerted and _bang_cd <= 0.0:
				_bang_cd = BANG_SOUND_GAP
				Audio.play(&"lock_click")
			e.alerted = true
		elif due < 0.0:
			e.alerted = false
		var kind := renderer.kind(d)
		var anim := e.anim
		var t := e.anim_t
		var at := Vector3(e.pos.x, e.y, e.pos.y)
		var lean := 0.0
		var tell := 0.0
		var boss := d.behavior == EnemyDef.Behavior.BOSS
		var still := e.frozen_t > 0.0
		var fade_len := 0.0
		if e.state == Enemy.State.WALK or e.state == Enemy.State.RECOVER:
			if not boss and e.stun_t > 0.0 and e.stun_len > 0.0 and e.stun_t <= e.stun_len + 0.001:
				# stunned by a blow: the hit pose stretched over the whole stun (AUDIT.md P4; Hades plays its stun
				# animation through it, the heavy one slower), no idle in between
				anim = &"hit"
				t = (1.0 - e.stun_t / e.stun_len) * kind.hit_time
			elif e.hurt_t > 0.0 and (not d.heavy or e.hurt_t > HURT_TIME - HEAVY_HURT):
				anim = &"hit"
				t = HURT_TIME - e.hurt_t
			elif e.stun_t > 0.0 and not boss:
				# (a boss plays his own stunned clip: Boss holds stun_t through it, and this drew him idle, E1c)
				anim = &"idle"
			elif e.state == Enemy.State.RECOVER:
				# T5-12, the window after its blow is alive: its own recovery clip (a shield lowered, a staff brought
				# down) or the rest of its blow at the clip's own pace, then its guard (never the last pose held)
				var own := e.recover_anim != &"" and kind.model.frame_count(e.recover_anim) > 0
				var clip := e.recover_anim if own else anim
				var length := kind.model.duration(clip)
				if own:
					t = e.state_t * maxf(1.0, length / maxf(d.recover_time, 0.01))
				else:
					if not still:
						e.blow_t += render_dt
					t = e.blow_t
				if t < length:
					anim = clip
				else:
					anim = &"idle"
					t = e.state_t
					fade_len = RECOVER_FADE
			elif not boss and anim == &"walk":
				# the drawing follows the body (AUDIT.md P1): standing still it stands, walking at the pace of its real
				# speed; T5-10: it changes between them only once its speed has stayed across for STAND_AFTER or
				# WALK_AFTER (a body that slows for a frame in a turn kept flickering between the two)
				var speed := e.vel.length()
				if not still:
					var want := speed >= (WALK_FROM if e.walking else WALK_START)
					e.switch_t = e.switch_t + render_dt if want != e.walking else 0.0
					if e.switch_t >= (STAND_AFTER if e.walking else WALK_AFTER):
						e.walking = want
						e.switch_t = 0.0
				if e.walking:
					var step := walk_rate(speed, kind.ground, d.size)
					var side := walk_side(e, kind)
					if side != &"walk":
						# slow and sideways or backwards, facing him: its own steps (T5-10), never a run turned aside
						anim = side
						step = speed / (SIDE_STEP_GROUND * maxf(d.size, 0.01))
					if not still:
						e.walk_phase += render_dt * step
					t = e.walk_phase
					if d.sway > 0.0:
						# unsteady: the trunk rocks from side to side, toward the foot it lands on (the place does not change)
						lean = stride_lean(d.sway, t, kind.model.duration(anim))
				else:
					anim = &"idle"
			else:
				t = e.anim_t * (walk_rate(_speed(e), kind.ground, d.size) if anim == &"walk" else clip_rate(e))
		elif e.state == Enemy.State.WINDUP:
			var w := _windup(e)
			tell = clampf(e.state_t / maxf(w, 0.01), 0.0, 1.0)
			var holding := false
			if anim == &"attack":
				# stretch the swing so the blade comes down when the windup ends (the close slam: it reads)
				t = e.state_t / w * kind.attack_time * IMPACT_SHARE
			elif not kind.model.loops.get(anim, true):
				# T5-01: settle, arm, hold. Its wind-up clip runs eased from the end of the settle to the hold, and
				# holds there on its last pose, or on its own loop (anim_hold) when it has one
				var arm := windup_arm(e.state_t, w, d.windup_settle, d.windup_hold)
				holding = e.state_t >= w * (1.0 - d.windup_hold)
				t = arm * kind.model.duration(anim)
				var hold_clip := StringName(String(anim) + "_hold")
				if holding and kind.model.frame_count(hold_clip) > 0:
					anim = hold_clip
					t = e.state_t - w * (1.0 - d.windup_hold)
				fade_len = d.windup_settle
			else:
				t = e.anim_t
				holding = e.state_t >= w * (1.0 - d.windup_hold)
				fade_len = d.windup_settle
			# LC-1 to LC-3: its lights where the drawn pose has the crossbow, the orb or the hands
			tells.tell(e, tell, kind.model, anim, t)
			if d.windup_shake > 0.0 and holding and e.frozen_t <= 0.0:
				# the tremble of "it is about to strike", only in the hold (it shook the whole wind-up)
				var side := Vector2(e.dir.y, -e.dir.x) * d.windup_shake * sin(TAU * SHAKE_HZ * e.state_t)
				at += Vector3(side.x, 0, side.y)
		elif e.state == Enemy.State.ATTACK:
			tells.loosed(e, e.state_t, kind.model, anim, e.state_t)
			if anim == &"attack" and d.shot_ticks > 1 and kind.model.frame_count(&"shot") > 0:
				# T5-13: every shot of a burst its own throw of the hand (the stretch round the release), not one gesture
				var tick := maxi(0, e.memo - 1)
				anim = &"shot"
				t = e.state_t - tick * d.shot_interval
				if e.memo > e.drawn_tick:
					e.drawn_tick = e.memo
					e.drawn_anim = &""
				fade_len = SHOT_FADE
			elif anim == &"attack":
				# from where the wind-up left it: the start of its own attack clip when it has a wind-up clip (the
				# soldier's blade held high while its body pounces, coming down as it lands: strike_t, T5-09), else
				# the share of the swing the wind-up stretched
				if kind.has_windup and d.strikes > 1 and d.behavior == EnemyDef.Behavior.RUNNER:
					# C19-1: the second blade is the blow again from its top, faded in from where the first ended
					var k := 0
					while k + 1 < d.strikes and e.state_t >= blow_at(e, k + 1) - d.strike_at:
						k += 1
					if k != e.drawn_tick:
						e.drawn_tick = k
						e.drawn_anim = &""
					fade_len = d.strike_gap * 0.5
					t = maxf(0.0, e.state_t - (blow_at(e, k) - d.strike_at)) * ATTACK_PLAY
				elif kind.has_windup:
					t = maxf(0.0, e.state_t - (e.strike_t - d.strike_at)) * ATTACK_PLAY
					if d.strikes > 1:
						# C19-2: the runner's spin goes on round and round between its bursts
						t = fposmod(t, maxf(kind.model.duration(&"attack"), 0.01))
				else:
					t = e.state_t * ATTACK_PLAY + kind.attack_time * IMPACT_SHARE
				e.blow_t = t
			else:
				t = e.state_t
				e.blow_t = t
		if e.shake > 0.0 and e.frozen_t <= 0.0:
			var tremble := Vector2(e.dir.y, -e.dir.x) * e.shake * sin(TAU * SHAKE_HZ * e.state_t)
			at += Vector3(tremble.x, 0, tremble.y)
		var k := clampf(e.flash_t / FLASH_TIME, 0.0, 1.0)
		var shown_flash := k * e.flash_power
		var shown_absorbed := e.absorbed
		if e.warded_by != null and e.armor > 0.0 and not (e.absorbed and shown_flash > 0.0):
			# combate_c1_leitura 3: whoever the priest armors glows in old gold, slowly (a blow takes it to the full flash)
			shown_flash = lerpf(WARDED_GLOW.x, WARDED_GLOW.y, 0.5 + 0.5 * sin(TAU * WARDED_HZ * now))
			shown_absorbed = true
		if e.edge_t > 0.0 and e.absorbed:
			# combate_c1_leitura 7: a heavy blow on armor keeps its edge of gold a little longer
			shown_flash = maxf(shown_flash, e.edge_t / EnemyFx.HEAVY_EDGE * e.flash_power)
			shown_absorbed = true
		if e.crack_t > 0.0 and e.armor > 0.0:
			# the crack of the armor (75, 50, 25%): the gold at its full for CRACK_TIME
			shown_flash = 1.0
			shown_absorbed = true
		var state := CrowdRenderer.state(shown_flash, e.frozen_t > 0.0, e.burn_t > 0.0, 0.0, shown_absorbed, tell,
			EnemyFx.wear(e.armor, e.max_armor), d.throw_flight > 0.0 and shield_away(e))
		# a blow flattens and widens the body for an instant, and lifts it a little; less on a heavy body, and not at
		# all when its armor took it
		var give := 0.0 if e.absorbed or e.block_t > 0.0 else k * (HEAVY_SQUASH if d.heavy else 1.0)
		var squash := Vector3(1.0 + 0.25 * give, 1.0 - 0.2 * give, 1.0 + 0.25 * give)
		var back := HitRecoil.offset(e.recoil_t, d.heavy)
		if e.recoil_peak > 0.0:
			back *= e.recoil_peak / (HitRecoil.HEAVY_PEAK if d.heavy else HitRecoil.PEAK)
		at += Vector3(e.recoil_dir.x, 0.0, e.recoil_dir.y) * back
		if e.drawn_anim == &"rise" and anim != &"rise":
			fade_len = RISE_FADE
		if d.front_block > 0.0:
			# combate_c1_leitura 2: the guard drawn as the rule has it (guard_up), open: the shield out and the chest in view
			var open := StringName(String(anim) + "_open")
			if (anim == &"walk" or anim == &"idle") and not guard_up(e) and kind.model.frame_count(open) > 0:
				anim = open
				fade_len = maxf(fade_len, GUARD_FADE)
			if e.alive:
				tells.guard_marks(e, guard_up(e), blocks_front(e, target), clampf(e.block_t / GUARD_BLOCK_TIME, 0.0, 1.0))
		if d.ward_count > 0 and kind.model.has_point("hand_l") and kind.model.frame_count(anim) > 0:
			_palms[e] = [EnemyFx.anchor(e.pos, e.y, e.yaw(), d.size, kind.model.point("hand_l", anim, t)),
				EnemyFx.anchor(e.pos, e.y, e.yaw(), d.size, kind.model.point("hand_r", anim, t))]
		if d.behavior == EnemyDef.Behavior.BOSS and e.alive and kind.model.has_point("head") and kind.model.frame_count(anim) > 0:
			# GR-7: his two eyes where the pose drawn has his head
			tells.eyes(EnemyFx.anchor(e.pos, e.y, e.yaw(), d.size, kind.model.point("head", anim, t)), e.yaw(), d.size,
				e.state == Enemy.State.WINDUP, e.helpless())
		var fade := _fade(e, anim, render_dt, fade_len)
		e.drawn_row = renderer.add_kind(kind, d, anim, t, at + Vector3(0, 0.18 * give, 0), e.yaw(), state, squash, -RECOIL_TILT * give, lean, e.fade_row, fade)
		# the thin life bar over the head (the boss has its own at the top of the screen); with a big crowd only
		# the hurt and the armored show one, thinner and fainter, so the screen stays clear
		if d.behavior != EnemyDef.Behavior.BOSS and e != top_bar_for and e.state != Enemy.State.DOWN and (few or e.hp < e.max_hp or e.armor > 0.0):
			var top := e.y + kind.model.height * d.size
			var life := e.hp / maxf(e.max_hp, 0.001)
			renderer.add_bar(d, Vector3(e.pos.x, top, e.pos.y), life,
				e.armor / maxf(e.max_armor, 0.001) if e.max_armor > 0.0 else 0.0, crowded, bar_trails.shown(e, life, now))
			if d.poise > 0.0 and e.armor <= 0.0 and e.poise < d.poise * CrowdRenderer.POISE_SHOW:
				renderer.add_poise_bar(d, Vector3(e.pos.x, top, e.pos.y), e.poise / d.poise, crowded)
	_draw_ward_threads(now)
	for e in dying:
		var burst := e.def.death_burst
		# combate_c1_leitura 4: what bursts is its own fuse: embers and a fiery edge growing, a tremble, a swell, not sinking
		# nor dissolving until it goes off (the dissolve then starts at the burst, not at DISSOLVE_FROM)
		var fuse := burst > 0.0 and e.dead_t < burst
		var from := burst if burst > 0.0 else DISSOLVE_FROM
		var dissolve := clampf((e.dead_t - from) / (DEATH_SHOW - from), 0.0, 1.0)
		var sink := maxf(0.0, e.dead_t - from) * 1.2
		var tumble := -e.spin * sin(clampf(e.dead_t * 2.2, 0.0, 1.0) * PI) * 1.1
		var fall := _fade(e, &"death", render_dt)
		var swell := Vector3.ONE
		var body := Vector3(e.pos.x, e.y - sink, e.pos.y)
		var look := Color(death_flash(e), 0, 0, dissolve)
		if fuse:
			var share := e.dead_t / burst
			swell = Vector3.ONE * (1.0 + FUSE_SWELL * share)
			var shake := lerpf(FUSE_SHAKE.x, FUSE_SHAKE.y, share) * sin(TAU * SHAKE_HZ * e.dead_t)
			body += Vector3(e.dir.y, 0.0, -e.dir.x) * shake
			look = CrowdRenderer.state(look.r, false, true, 0.0, false, share)
		renderer.add_kind(renderer.kind(e.def), e.def, &"death", e.dead_t * 1.3, body, e.yaw(),
			look, swell, tumble, 0.0, e.fade_row, fall)
	renderer.commit()
	tells.commit()


## How far a figure drawn as `anim` is from the pose it showed before its clip last changed (0..1; 1: all the new
## clip): a change of clip starts a fade from the pose row it showed last (CLIP_FADE, BOSS_CLIP_FADE).
## `seconds`: how long a change starting now fades over (0: CLIP_FADE; T5-01, a wind-up's settle).
func _fade(e: Enemy, anim: StringName, render_dt: float, seconds := 0.0) -> float:
	if anim != e.drawn_anim and e.drawn_row >= 0:
		e.fade_row = e.drawn_row
		e.fade_t = 0.0
		e.fade_len = seconds
	e.drawn_anim = anim
	if e.fade_row < 0:
		return 1.0
	e.fade_t += render_dt
	var length := e.fade_len if e.fade_len > 0.0 else BOSS_CLIP_FADE if e.def.behavior == EnemyDef.Behavior.BOSS else CLIP_FADE
	return clampf(e.fade_t / length, 0.0, 1.0)


## The threads from each priest's palm to what it armors (EnemyFx.ward_thread), at most WARD_THREADS on the screen.
func _draw_ward_threads(now: float) -> void:
	var n := 0
	for e in list:
		if e.warded_by == null or e.armor <= 0.0 or not e.alive or not _palms.has(e.warded_by):
			continue
		if n >= EnemyFx.WARD_THREADS:
			return
		n += 1
		var palms: Array = _palms[e.warded_by]
		var from: Vector3 = palms[e.get_instance_id() % 2]
		var close := target.distance_to(e.warded_by.pos) < EnemyFx.WARD_CLOSE_M
		tells.ward_thread(from, Vector3(e.pos.x, e.y + 1.2 * e.def.size, e.pos.y), close, now, float(e.get_instance_id() % 7) * 0.13)


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
