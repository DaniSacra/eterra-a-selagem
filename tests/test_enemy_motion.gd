extends GutTest
## E1c (docs/gallery/e1c/enemies/AUDIT.md): the drawing follows the body (never the walk standing still, sideways or
## backwards), the window after a blow stands still, a cut wind-up waits before the next, the soldier's lunge stops at
## the paladin's edge and at most 2 soldiers wind up at once. Hades II's numbers (docs/design/hades2_feel_study.md 4).

const DT := 1.0 / 60.0
## A half turn at Horde.TURN_RATE (0.15 s), and the smoothing of the speed (VEL_SMOOTH) it starts behind.
## T5-10: a turn may take 12 frames (the facing turns once the walk is FACE_SPLIT off its aim and keeps to it until
## FACE_BACK: the body no longer flicks between the two, so a turn begins a beat later).
const TURN_FRAMES := 12

var game: Game


## Every game here plays the same dice (QA E2-12): without --seed each system's generator is randomize()d
## (Dev.seed_rng), so each run drew other cooldowns, sides and attack turns; the walk test then crossed its 5% limit
## now and then (0.0546 once). Seeded as --seed=1 does, from the game's _ready on, whatever ran before.
func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev._args.erase("seed")


func _room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _spawn(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.8), false)
	return e


## One step of the game and one frame of its drawing (the tests step the game by hand: nothing draws on its own).
func _frame() -> void:
	game.player.invuln = 10.0
	game._step(DT)
	game.horde.render(DT)


## AUDIT.md P1: with every common kind on the floor and the paladin walking round, no figure is drawn walking under
## WALK_FROM m/s for longer than Horde.STAND_AFTER (T5-10: it changes to standing only once slow that long), and the walk is drawn with more than FACE_SPLIT degrees between where it goes and where it faces
## only while the body turns to it (at TURN_RATE: a half turn takes 0.15 s).
func test_the_walk_is_drawn_only_where_the_body_walks() -> void:
	_room()
	var ids: Array[StringName] = [&"skeleton", &"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest"]
	for i in ids.size():
		_spawn(ids[i], Vector2.from_angle(TAU * i / ids.size()) * 7.0)
	var walk_frames := 0
	var slow := 0
	var split := 0
	var streak := {}
	var longest := 0
	var beyond := 0
	var slow_run := {}
	var slow_longest := 0
	for f in 900:
		# he walks a slow circle, so they chase, strafe, flee and come back
		game.player.pos = game.arena.resolve(Vector2.from_angle(f * DT * 0.6) * 3.0, Player.RADIUS)
		_frame()
		for e in game.horde.list:
			if e.drawn_anim != &"walk" or e.frozen_t > 0.0:
				streak[e] = 0
				slow_run[e] = 0
				continue
			walk_frames += 1
			var speed := e.vel.length()
			slow_run[e] = int(slow_run.get(e, 0)) + 1 if speed < Horde.WALK_FROM else 0
			slow_longest = maxi(slow_longest, slow_run[e])
			if slow_run[e] > ceili(Horde.STAND_AFTER / DT) + 1:
				slow += 1
			var f2 := Vector2(sin(e.yaw()), cos(e.yaw()))
			if speed > 0.01 and absf(rad_to_deg(f2.angle_to(e.vel))) > Horde.FACE_SPLIT + 1.0:
				split += 1
				streak[e] = int(streak.get(e, 0)) + 1
				longest = maxi(longest, streak[e])
				if streak[e] > TURN_FRAMES:
					beyond += 1
			else:
				streak[e] = 0
	gut.p("walk frames %d, turning sideways %d, longest turn %d frames" % [walk_frames, split, longest])
	assert_gt(walk_frames, 300, "they walked")
	assert_eq(slow, 0, "never the walk under %.1f m/s past the delay (longest %d frames)" % [Horde.WALK_FROM, slow_longest])
	assert_eq(beyond, 0, "sideways or backwards only while the body turns (longest %d frames)" % longest)
	assert_lt(float(split) / walk_frames, 0.05, "and that is rare (%d of %d frames)" % [split, walk_frames])


## The priest never moves: it stands (idle), never walks in place.
func test_the_priest_stands() -> void:
	_room()
	var e := _spawn(&"priest", Vector2(9.0, 0.0))
	for f in 240:
		_frame()
		if e.state == Enemy.State.WALK and e.stun_t <= 0.0:
			assert_ne(e.drawn_anim, &"walk", "frame %d" % f)
			if e.drawn_anim == &"walk":
				return


## AUDIT.md P2: after its lunge the soldier stands still for its recover_time (Hades' Guard 2.1 s), then walks.
func test_the_soldier_recovers_standing_still() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(2.6, 0.0))
	e.cooldown = 0.0
	assert_almost_eq(e.def.recover_time, 2.1, 0.001)
	var seen := false
	for f in 240:
		_frame()
		if e.state == Enemy.State.RECOVER:
			seen = true
			break
	assert_true(seen, "it struck and recovers")
	var at := e.pos
	var frames := 0
	while e.state == Enemy.State.RECOVER and frames < 300:
		_frame()
		frames += 1
	assert_almost_eq(frames * DT, e.def.recover_time, 0.05, "as long as its recover_time")
	assert_lt(e.pos.distance_to(at), 0.05, "standing still")
	assert_eq(e.state, Enemy.State.WALK)


## Every kind that recovers has the number of its counterpart in Hades II.
func test_recover_times() -> void:
	var want := {&"skeleton": 2.1, &"skeleton_elite": 1.5, &"runner": 1.35, &"runner_elite": 0.5, &"guard": 1.1, &"archer": 0.6, &"mage": 0.8}
	for id: StringName in want:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		assert_almost_eq(d.recover_time, float(want[id]), 0.001, String(id))


## A blow in the recovery stuns, but the window goes on (nothing to cut).
func test_a_blow_in_the_recovery_cuts_nothing() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(2.6, 0.0))
	e.state = Enemy.State.RECOVER
	e.state_t = 0.2
	var cuts := game.horde.interrupts
	game.horde.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.state, Enemy.State.RECOVER)
	assert_gt(e.stun_t, 0.0)
	assert_eq(game.horde.interrupts, cuts)


## AUDIT.md P5: a cut wind-up comes again only REARM after the stun; the stun is Hades' 0.5 s (1.1 s heavy).
func test_a_cut_wind_up_waits_after_the_stun() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(2.6, 0.0))
	e.cooldown = 0.0
	for f in 240:
		_frame()
		if e.state == Enemy.State.WINDUP and e.state_t > 0.2:
			break
	assert_eq(e.state, Enemy.State.WINDUP)
	game.horde.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_almost_eq(e.stun_t, 0.5, 0.001)
	var free_at := -1.0
	var again_at := -1.0
	for f in 120:
		_frame()
		if free_at < 0.0 and not e.helpless():
			free_at = f * DT
		if e.state == Enemy.State.WINDUP:
			again_at = f * DT
			break
	assert_gt(again_at, 0.0, "it winds up again")
	assert_gte(again_at - free_at, Horde.REARM - DT, "not before REARM after the stun")
	for id: StringName in [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest"]:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		assert_almost_eq(d.stun_time, 0.5, 0.001, String(id))
		assert_almost_eq(d.stun_heavy_time, 1.1, 0.001, String(id))


## AUDIT.md P4: a stunned body shows its hit pose through the whole stun, never the idle in between (heavy too).
func test_the_hit_pose_lasts_the_stun() -> void:
	_room()
	for id: StringName in [&"skeleton", &"guard"]:
		var e := _spawn(id, Vector2(4.0, 0.0))
		game.horde.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false, true)
		var shown: Array = []
		while e.stun_t > DT:
			_frame()
			if shown.is_empty() or shown[-1] != e.drawn_anim:
				shown.append(e.drawn_anim)
		assert_eq(shown, [&"hit"], "%s: only the hit pose while stunned" % id)
		e.alive = false


## AUDIT.md P8: the soldier's lunge stops at the paladin's edge, never through him.
func test_the_lunge_stops_at_his_edge() -> void:
	_room()
	var e := _spawn(&"skeleton", Vector2(2.6, 0.0))
	e.cooldown = 0.0
	var side := (e.pos - game.player.pos).normalized()
	var keep := e.def.radius + Player.RADIUS
	var lunged := false
	for f in 240:
		_frame()
		if e.state == Enemy.State.ATTACK:
			lunged = true
		var off := e.pos - game.player.pos
		assert_gt(off.dot(side), 0.0, "never past him")
		assert_gte(off.length(), keep - 0.02, "never inside him")
		if lunged and e.state == Enemy.State.RECOVER:
			break
	assert_true(lunged)


## AUDIT.md P9: at most 2 soldiers (and their elites) wind up or lunge at once.
func test_at_most_two_soldiers_attack_at_once() -> void:
	_room()
	for i in 5:
		var e := _spawn(&"skeleton" if i < 4 else &"skeleton_elite", Vector2.from_angle(TAU * i / 5.0) * 3.0)
		e.cooldown = 0.0
	var most := 0
	for f in 300:
		_frame()
		most = maxi(most, game.horde.attackers(game.horde.def(&"skeleton")))
	assert_eq(most, 2)
