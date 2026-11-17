extends GutTest
## E1c, bug 2 (Daniel: "se eu ficar apertando direto o E dá um barulho estranho parece pacman e não de espada"): the
## blade's air is recorded swishes drawn at random, never closer than VoiceGate's gap, at most two at once, and only
## for a move that really starts (the blow's impact is another sound, only on a real hit).

const F := 1.0 / 60.0
const BLADE: Array[StringName] = [&"blade", &"blade_spin", &"thrust", &"dart"]


func after_each() -> void:
	Audio.listen(false)
	Controls.virtual = null
	Controls.clear_presses()
	Engine.time_scale = 1.0


func test_the_blade_family_never_starts_twice_within_its_gap() -> void:
	var g := VoiceGate.new()
	assert_true(g.admit(&"blade", 1000))
	assert_false(g.admit(&"blade", 1030), "the same swing a frame or two later is one sound")
	assert_false(g.admit(&"thrust", 1060), "the family shares the gap")
	assert_true(g.admit(&"blade_spin", 1070), "70 ms later the next swing sounds")
	assert_true(g.admit(&"hit", 1071), "other sounds are not held by the blade's gap")
	assert_eq(VoiceGate.gap_ms(&"blade"), 70)


func test_at_most_two_blade_voices_the_newest_takes_the_oldest() -> void:
	var fam: Array[StringName] = [&"blade", &"hit", &"blade", &"", &""]
	var starts := PackedInt64Array([100, 120, 200, 0, 0])
	var playing: Array[bool] = [true, true, true, false, false]
	assert_eq(VoiceGate.pick(&"thrust", fam, starts, playing, 3), 0, "over the cap: the oldest swish is cut")
	playing[0] = false
	assert_eq(VoiceGate.pick(&"blade", fam, starts, playing, 2), 3, "under the cap: the round robin, never over a swish still sounding")
	assert_eq(VoiceGate.pick(&"hit", fam, starts, [true, true, true, true, true] as Array[bool], 2), 2, "no cap for the rest")


func test_every_blade_sound_has_recorded_swishes_to_draw_from() -> void:
	for s in BLADE:
		var n := 0
		while ResourceLoader.exists("res://audio/%s_%d.ogg" % [s, n]):
			n += 1
		assert_gte(n, 3, "%s: at least 3 swishes to draw from" % s)
		assert_true(Audio.stream(s) is AudioStreamRandomizer, "%s plays one of them at random" % s)
		var r := Audio.stream(s) as AudioStreamRandomizer
		assert_between(r.random_pitch, 1.01, 1.2, "a little pitch play")


func test_mashing_the_attack_sounds_only_the_moves_that_start() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var pad := Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.invuln = 99.0
	var started := [0]
	p.runner.move_started.connect(func(_n: ComboNode) -> void: started[0] += 1)
	var ms := [0]
	Audio.listen(true, func() -> int: return ms[0])
	# E pressed on every other frame for 4 seconds (far faster than any move can follow)
	for i in 240:
		if i % 2 == 0:
			pad.press(&"light_attack")
		else:
			pad.release(&"light_attack")
		game._step(F)
		pad.end_frame()
		Controls.flush()
		ms[0] += 16
	var swishes: Array = Audio.heard.filter(func(h: Array) -> bool: return VoiceGate.family(h[0]) == &"blade")
	assert_gt(started[0], 3, "the combo plays")
	assert_lte(swishes.size(), started[0], "no swish without a move that started (presses dropped by the buffer are silent)")
	assert_gte(swishes.size(), started[0] - 1, "and every move is heard (one may fall inside the 70 ms gap)")
	for i in range(1, swishes.size()):
		assert_gte(int(swishes[i][1]) - int(swishes[i - 1][1]), VoiceGate.gap_ms(&"blade"), "never two swishes within the gap")
	var hits: Array = Audio.heard.filter(func(h: Array) -> bool: return h[0] == &"hit" or h[0] == &"hit_heavy")
	assert_eq(hits.size(), 0, "nothing struck in an empty room: no impact sound")
