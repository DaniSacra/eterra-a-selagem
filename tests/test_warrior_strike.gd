extends GutTest
## E1c, the Warrior strikes standing still (Daniel's E1 test: "tem que atacar parado", "tem que ter a animação do
## ataque, o ataque e a animação do retorno", "diferença de tempo entre os 3 ataques", "depois do D trava para andar e
## eu fico patinando"; numbers of Hades II's staff, docs/design/hades2_feel_study.md). The frame-by-frame acceptance
## is tools/feel_probe.gd (E1c-P1 to E1c-P6); these pin the rules.

const F := 1.0 / 60.0
const L := ComboNode.In.LIGHT
const S := ComboRunner.Stage
## The attack clips (the moves' own and their returns).
const STRIKE_CLIPS: Array[StringName] = [&"Slash_A", &"Slash_A_Rec", &"Slash_B", &"Slash_B_Rec", &"Slash_C", &"Sword_Attack", &"Cast"]
## How far the hips may sway from the model's origin on the floor in a strike clip (meters as drawn): tools/bake_hero.gd
## keeps them in place (0.05 m measured in every clip); root motion would carry the body away from the paladin.
const HIP_SWAY := 0.2

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()
	Engine.time_scale = 1.0


func _room() -> Player:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()
	p.magick.gain(p.magick.max_value)
	return p


## One frame of the paladin: taps this frame, then his step; the direction held is pad.move, the aim up.
func _frame(p: Player, taps: Array = [], held: Array = []) -> void:
	for a: StringName in taps + held:
		pad.press(a)
	p.step(F, pad.move, Vector2.UP)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		if not held.has(a):
			pad.release(a)
	pad.released.clear()


func test_the_basic_attack_never_moves_him_with_the_direction_held() -> void:
	var p := _room()
	pad.move = Vector2.RIGHT
	var at := p.pos
	_frame(p, [&"light_attack"])
	var frames := 0
	while p.runner.planted() and frames < 60:
		assert_almost_eq(p.pos.distance_to(at), 0.0, 0.001, "still on frame %d" % frames)
		assert_ne(p.get(&"_current_anim"), &"Run", "never the run while planted")
		_frame(p)
		frames += 1
	assert_gt(frames, 10, "planted from the press through the leg hold")
	_frame(p)
	assert_gt(p.pos.x, at.x, "walks once the legs are free")


func test_the_whole_combo_never_moves_him() -> void:
	var p := _room()
	pad.move = Vector2.RIGHT
	var at := p.pos
	var ids: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: ids.append(n.id))
	_frame(p, [&"light_attack"])
	for i in 50:
		_frame(p, [&"light_attack"] if not ids.has(&"cut3") else [])
		assert_almost_eq(p.pos.distance_to(at), 0.0, 0.001)
	assert_eq(ids, [&"cut1", &"cut2", &"cut3"] as Array[StringName])


func test_after_the_special_and_its_omega_the_legs_come_back() -> void:
	# no stage keeps a lock for ever: 0.71 s after the dart he walks (D-44), and so after the Omega special
	for held in [false, true]:
		var p := _room()
		pad.move = Vector2.RIGHT
		var at := p.pos
		var walked := -1
		for i in 120:
			if held:
				_frame(p, [], [&"heavy_attack"] if i < 45 else [])
			else:
				_frame(p, [&"heavy_attack"] if i == 0 else [])
			if p.pos.x > at.x + 0.01 and walked < 0:
				walked = i
		assert_between(walked, 1, 119, "walks again after the %s" % ("Omega special" if held else "special"))
		assert_eq(p.runner.stage(), S.IDLE, "nothing left held")
		assert_false(p.runner.planted())


func test_the_drawn_body_stays_on_the_logical_position() -> void:
	var p := _room()
	pad.move = Vector2.RIGHT
	var model := p.get(&"_model") as Node3D
	var origin := model.position
	_frame(p, [&"light_attack"])
	for i in 40:
		_frame(p, [&"light_attack"])
		assert_almost_eq(p.position.x, p.pos.x, 0.0001)
		assert_almost_eq(p.position.z, p.pos.y, 0.0001)
		assert_eq(model.position, origin, "the model is never moved off the paladin's node")


func test_no_strike_clip_carries_root_motion() -> void:
	var body := HeroBody.make()
	var model: Node3D = body[0]
	var anim: AnimationPlayer = body[1]
	add_child_autofree(model)
	var sk := model.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var hips := sk.find_bone(&"Hips")
	assert_gt(hips, -1)
	for clip in STRIKE_CLIPS:
		anim.play(clip)
		var length := anim.current_animation_length
		var worst := 0.0
		var t := 0.0
		while t <= length:
			anim.seek(t, true)
			var at := sk.global_transform * sk.get_bone_global_pose(hips).origin
			worst = maxf(worst, Vector2(at.x, at.z).distance_to(Vector2(model.global_position.x, model.global_position.z)))
			t += 1.0 / 30.0
		assert_lt(worst, HIP_SWAY, "%s keeps the hips over the paladin (%.2f m)" % [clip, worst])


func test_the_three_blows_take_different_times_and_each_has_a_recovery() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var cut1: ComboNode = ComboTree.find(tree.neutral, L)
	var cut2: ComboNode = cut1.following()[0]
	var cut3: ComboNode = cut2.following()[0]
	var spans: Array[float] = []
	for n in [cut1, cut2, cut3]:
		assert_gt(n.recovery, 0.0, "%s has an attack lock" % n.id)
		assert_gt(n.move_hold, n.recovery, "%s holds the legs past it" % n.id)
		spans.append(n.lead() + n.move_hold)
	assert_lt(spans[0], spans[1])
	assert_lt(spans[1], spans[2])
	assert_gte(cut3.lead(), cut1.lead() * 3.0, "the spin's windup reads as a finisher's (Hades II: 3 to 6 times the first)")


func test_the_stages_run_idle_windup_strike_recovery_idle() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var r := ComboRunner.new(tree)
	var seen: Array[int] = [r.stage()]
	r.press(L)
	for i in 60:
		r.step(F)
		if r.stage() != seen[-1]:
			seen.append(r.stage())
	assert_eq(seen, [S.IDLE, S.WINDUP, S.STRIKE, S.RECOVERY, S.IDLE] as Array[int])


func test_mashing_the_attack_starts_no_blow_outside_its_window() -> void:
	# a press every frame for 3 s: every blow starts when the one before ends its attack lock, never earlier
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var r := ComboRunner.new(tree)
	var t := [0.0]
	var starts: Array = []
	var hits: Dictionary = {}
	var last: Array = [null]
	r.move_started.connect(func(n: ComboNode) -> void:
		if last[0] != null:
			var prev: ComboNode = last[0]
			assert_gte(t[0] + 0.0001, float(hits[prev]) + prev.recovery, "%s waited for %s's lock" % [n.id, prev.id])
		starts.append([n.id, t[0]])
		last[0] = n)
	r.move_hit.connect(func(n: ComboNode) -> void: hits[n] = t[0])
	for i in 180:
		r.press(L)
		r.step(F)
		t[0] += F
	var ids := starts.map(func(s: Array) -> StringName: return s[0])
	assert_eq(ids.slice(0, 4), [&"cut1", &"cut2", &"cut3", &"cut1"], "the chain, then a new one")
	var cycle: float = 0.0
	for n: ComboNode in [ComboTree.find(tree.neutral, L), ComboTree.find(tree.neutral, L).following()[0],
			ComboTree.find(tree.neutral, L).following()[0].following()[0]]:
		cycle += n.lead() + n.recovery
	assert_lte(starts.size(), int(ceil(3.0 / cycle * 3.0)) + 1, "no more blows than the cadence allows")


func test_the_return_clip_plays_when_he_stands() -> void:
	var p := _room()
	pad.move = Vector2.ZERO
	_frame(p, [&"light_attack"])
	var anim := p.get(&"_anim") as AnimationPlayer
	var played: Array[StringName] = []
	for i in 90:
		_frame(p)
		anim.advance(F)
		var c: StringName = p.get(&"_current_anim")
		if played.is_empty() or played[-1] != c:
			played.append(c)
	assert_eq(played.slice(0, 2), [&"Slash_A", &"Slash_A_Rec"] as Array[StringName], "the blade comes back, never a cut to the guard")
