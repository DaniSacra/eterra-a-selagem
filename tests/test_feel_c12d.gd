extends GutTest
## C12d "Game feel I: the hand" (docs/backlog.md GF-01 to GF-11, decisions D-43 and D-44): one test per rule of the
## input and the hit stop. The frame-by-frame acceptance is tools/feel_probe.gd (docs/gallery/c12d/PROBE.md); these
## pin the rules themselves.

const F := 1.0 / 60.0
const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY

var game: Game
var pad: Controls.VirtualPad
var started: Array[StringName] = []
var hits: Array[StringName] = []


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()
	Engine.time_scale = 1.0


# ---------- the hit stop (GF-01) ----------

## Speeds of the world frame by frame at 60 Hz for a hit stop.
func _rates(wait: float, slow: float, frames := 12) -> Array[float]:
	var h := HitStop.new()
	h.start(wait, slow)
	var out: Array[float] = []
	for i in frames:
		out.append(h.advance(F))
	return out


func test_hit_stop_waits_then_slows_then_comes_back_never_a_freeze() -> void:
	var r := _rates(0.025, 0.01)
	assert_eq(r[0], 1.0, "the world keeps its speed through the 25 ms wait")
	assert_almost_eq(r[1], HitStop.FRACTION, 0.001, "then drops to 6%")
	assert_gt(r[2], HitStop.FRACTION, "and comes back over 20 ms")
	assert_eq(r[3], 1.0, "full speed again")
	for x in r:
		assert_gt(x, 0.0, "never a freeze")


func test_the_spin_waits_longer_and_a_kill_slows_longer() -> void:
	var spin := _rates(0.07, 0.01)
	assert_eq(spin.slice(0, 4), [1.0, 1.0, 1.0, 1.0] as Array[float], "70 ms of wait: 4 frames at full speed")
	assert_almost_eq(spin[4], HitStop.FRACTION, 0.001)
	var kill := _rates(0.025, 0.05)
	var slow := kill.filter(func(x: float) -> bool: return x <= 0.1).size()
	assert_between(slow, 2, 4, "10 + 40 ms of slow with a kill")


func test_a_slow_shorter_than_a_frame_is_still_seen() -> void:
	# at 30 frames a second, a 10 ms slow sits inside one frame: that frame is the slow one
	var h := HitStop.new()
	h.start(0.025, 0.01)
	var seen := false
	for i in 4:
		var r := h.advance(1.0 / 30.0)
		seen = seen or r <= HitStop.FRACTION
	assert_true(seen)
	assert_false(h.active(), "and it ends")


func test_a_shorter_hit_stop_never_cuts_a_longer_one() -> void:
	var h := HitStop.new()
	h.start(0.07, 0.05)
	var left := h.left()
	h.start(0.0, 0.01)
	assert_eq(h.left(), left)


## Fx counts the hit stop and the slow motion in real time, and a slow motion asked for during a hit stop waits for
## it (GF-05: the two together read as a freeze).
func test_fx_slow_motion_waits_for_the_hit_stop_and_counts_real_time() -> void:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.slow_motion = true
	fx.blow_stop(70.0, 50.0)
	fx.slow_mo(0.2, 0.12, 0.25)
	var rates: Array[float] = []
	for i in 40:
		fx.tick(F * Engine.time_scale)
		rates.append(fx.rate)
		assert_almost_eq(fx.real_dt, F, 0.0001, "frame %d counts real time" % i)
	assert_eq(rates[0], 1.0, "the wait first, at full speed")
	var stop_end := rates.find(rates.filter(func(x: float) -> bool: return x <= 0.1).back())
	var at_fifth := rates.slice(stop_end + 1).filter(func(x: float) -> bool: return x >= 0.15 and x <= 0.25).size()
	assert_gte(at_fifth, 5, "then the slow motion is seen")
	assert_gt(rates.min(), 0.0, "never stopped")


# ---------- the combo runner (GF-04, GF-07, D-44) ----------

func _runner() -> ComboRunner:
	var r := ComboRunner.new(load("res://data/combos/paladin.tres"))
	started.clear()
	hits.clear()
	r.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	r.move_hit.connect(func(n: ComboNode) -> void: hits.append(n.id))
	return r


func _run(r: ComboRunner, frames: int) -> void:
	for i in frames:
		r.step(F)


func test_a_press_in_the_roll_waits_unaged_and_comes_out_as_the_first_cut() -> void:
	var r := _runner()
	r.on_dodge()
	r.press(L)
	_run(r, 12)
	assert_true(started.is_empty(), "nothing starts in the roll")
	r.on_dodge_end()
	r.step(F)
	assert_eq(started, [&"cut1"] as Array[StringName], "12 frames later it is still there (no dash attack since 2026-11-21)")


func test_a_dodge_drops_presses_made_before_it() -> void:
	var r := _runner()
	r.press(L)
	r.step(0.0)
	r.press(L)
	r.on_dodge()
	r.on_dodge_end()
	r.step(F)
	assert_eq(started, [&"cut1"] as Array[StringName], "only the blow before the dodge")


func test_hold_for_lets_nothing_start_for_its_frames() -> void:
	var r := _runner()
	r.hold_for(8.0 / 60.0)
	var first := -1
	for i in 20:
		r.press(L)
		r.step(F)
		if not started.is_empty() and first < 0:
			first = i
	assert_eq(first, 8, "the 8 frames of Hades II after the circle")


func test_the_special_has_its_own_cooldown_and_frees_the_attack_first() -> void:
	var r := _runner()
	r.press(H)
	r.step(0.0)
	var attack_at := -1
	for i in 60:
		r.press(L)
		r.step(F)
		if started.size() > 1 and attack_at < 0:
			attack_at = i
	assert_eq(started[1], &"cut1")
	assert_between(attack_at, 23, 26, "the attack 18 frames after the dart (dart on frame 6 or 7)")
	r = _runner()
	r.press(H)
	r.step(0.0)
	var again := -1
	for i in 80:
		r.press(H)
		r.step(F)
		if started.size() > 1 and again < 0:
			again = i
		if again >= 0 and i >= again + 8:
			break
	assert_between(again, 35, 39, "the second dart 0.5 s after the first (0.7 s before 2026-11-21)")
	r.reset(false)
	assert_gt(r.cooldown_left(&"bolt"), 0.0, "a blow taken keeps the cooldown")
	r.reset()
	assert_eq(r.cooldown_left(&"bolt"), 0.0)


# ---------- the paladin in a real room (GF-02, GF-03, GF-07, GF-08, GF-09, D-44) ----------

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
	started.clear()
	hits.clear()
	p.runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	p.runner.move_hit.connect(func(n: ComboNode) -> void: hits.append(n.id))
	return p


## One frame of the paladin: taps this frame, then his step (as the bot drives him).
func _frame(p: Player, taps: Array = [], held: Array = []) -> void:
	for a: StringName in taps:
		pad.press(a)
	for a: StringName in held:
		pad.press(a)
	p.step(F, pad.move, Vector2.RIGHT)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		if not held.has(a):
			pad.release(a)
	pad.released.clear()


func test_a_dodge_in_the_windup_starts_at_once_and_the_blow_never_lands() -> void:
	var p := _room()
	_frame(p, [&"light_attack"])
	_frame(p)
	_frame(p, [&"dodge"])
	assert_eq(p.state, Player.State.DODGE, "the dodge cuts the windup")
	for i in 20:
		_frame(p)
	assert_true(hits.is_empty(), "the cut blow never lands")


func test_an_attack_in_the_roll_or_the_stagger_is_kept() -> void:
	var p := _room()
	_frame(p, [&"dodge"])
	_frame(p, [&"light_attack"])
	var at := -1
	for i in 20:
		_frame(p)
		if not started.is_empty() and at < 0:
			at = i
	assert_eq(started, [&"cut1"] as Array[StringName], "the plain first cut when the roll ends")
	p = _room()
	p.hurt(1.0, p.pos + Vector2.LEFT)
	_frame(p)
	_frame(p, [&"heavy_attack"])
	assert_true(started.is_empty(), "nothing while staggered")
	for i in 12:
		_frame(p)
	assert_eq(started, [&"bolt"] as Array[StringName], "the special comes out when the stagger ends")


func test_the_special_holds_the_legs_without_skating() -> void:
	# D-44 (3) kept; E1c (Daniel: "trava para andar e eu fico patinando"): planted from the press until 0.71 s after
	# the dart with the direction held, in the throw's clip and pose, never the run; then he walks; the dodge cuts it
	var p := _room()
	pad.move = Vector2.DOWN
	var z := p.pos.y
	var bolt := ComboTree.find(p.tree.neutral, ComboNode.In.HEAVY)
	_frame(p, [&"heavy_attack"])
	assert_almost_eq(p.pos.y, z, 0.001, "planted on the press frame (GF-09)")
	var free_at := -1
	for i in 70:
		_frame(p)
		if p.runner.planted():
			assert_ne(p.get(&"_current_anim"), &"Run", "no run while held (no skating)")
			assert_almost_eq(p.pos.y, z, 0.001, "still while held")
		elif free_at < 0 and p.pos.y > z + 0.01:
			free_at = i + 1
	var want := roundi((bolt.windup + bolt.move_hold) * 60.0)
	assert_between(free_at, want - 1, want + 1, "walks again 0.71 s after the dart (frame %d)" % free_at)
	p = _room()
	_frame(p, [&"heavy_attack"])
	for i in 20:
		_frame(p)
	assert_true(p.runner.planted())
	_frame(p, [&"dodge"])
	assert_false(p.runner.planted(), "the dodge cuts it")
	assert_eq(p.state, Player.State.DODGE)


func test_the_omega_lands_when_its_charge_fills() -> void:
	var p := _room()
	var lance := ComboTree.find(p.tree.neutral, ComboNode.In.CHARGE_LIGHT)
	var at := -1
	for i in 70:
		_frame(p, [], [&"light_attack"])
		if hits.has(&"lance") and at < 0:
			at = i
	assert_between(at, int(lance.charge_time * 60.0) - 1, int(lance.charge_time * 60.0) + 1, "it lands as the charge fills (0.8 s)")


func test_turning_faces_at_once_and_the_body_follows_at_1340_degrees() -> void:
	var p := _room()
	pad.move = Vector2.RIGHT
	for i in 10:
		_frame(p)
	pad.move = Vector2.LEFT
	_frame(p)
	assert_almost_eq(p.facing.angle_to(Vector2.LEFT), 0.0, 0.01, "the way he faces turns at once")
	for i in 7:
		_frame(p)
	var model := p.get(&"_model") as Node3D
	assert_almost_eq(absf(angle_difference(model.rotation.y, atan2(-1.0, 0.0))), 0.0, deg_to_rad(5.0), "the body in 8 frames")


# ---------- the virtual pad in a frame the game did not step (GF-06) ----------

func test_the_virtual_pad_keeps_a_tap_until_the_game_steps() -> void:
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	pad.press(&"dodge")
	Controls.latch_virtual()
	pad.end_frame()
	assert_true(Controls.pressed(&"dodge"), "kept through the frame that did not step")
	Controls.flush()
	assert_false(Controls.pressed(&"dodge"), "seen once the game stepped")


# ---------- impact (GF-10) and sound (GF-11) ----------

func test_a_common_blow_jolts_the_camera_on_the_scale_of_hades_ii() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for node in tree.all_nodes():
		var meters := Combat.kick_of(node) * Fx.KICK_METERS
		if node.has_tag(&"finisher") or node.has_tag(&"omega"):
			assert_gt(meters, 0.1, "%s: a finisher or an Omega jolts more (D-43)" % node.id)
		else:
			assert_lte(meters, 0.1, "%s: a common blow at most 0.1 m" % node.id)
	assert_lte(Horde.FLASH_TIME, 0.055, "the flash of a blow is short and dry")


func test_every_move_has_a_sound_when_it_starts() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for node in tree.all_nodes():
		assert_ne(node.sound, &"", "%s has a sound" % node.id)
		assert_true(Audio.SOUNDS.has(node.sound), "%s: its sound exists" % node.id)
	assert_true(Audio.SOUNDS.has(&"charge_up"), "the Omega charge has its sound")
