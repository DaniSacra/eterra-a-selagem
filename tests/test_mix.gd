extends GutTest
## E6 (C15-01, C15-04, B-3): the mix by buses, Morvath's warning duck, the rooms' air, the loudness meter, and the
## mix of a real Morvath fight (a sound log of tools/smoke.sh --start=boss --boons=25 --seed=5
## --bot-reaction=0.25, tests/fixtures/sound_log_boss.json) replayed through the buses: integrated -18 to -14 LUFS,
## true peak at most -1 dBTP after the limiter, the limiter only a guard (B-3).

const MixReplay := preload("res://tools/mix_replay.gd")
const RATE := 44100.0


func after_each() -> void:
	Music.mix = MusicMix.new(Music.catalog())
	Music.air = MusicMix.new(Ambience.catalog())


static func sine(hz: float, db: float, seconds: float, phase: float = 0.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(int(seconds * RATE))
	var a := db_to_linear(db)
	for i in out.size():
		var v := a * sin(TAU * hz * i / RATE + phase)
		out[i] = Vector2(v, v)
	return out


# ---------------------------------------------------------------- the meter

func test_a_sine_at_minus_20_reads_minus_20_lufs() -> void:
	# BS.1770: a 1 kHz sine in both channels reads its own level in LUFS (within the K filter's 0.7 dB at 1 kHz)
	var l := Loudness.integrated(sine(997.0, -20.0, 4.0))
	assert_almost_eq(l, -20.0, 0.8, "1 kHz at -20 dBFS: %.2f LUFS" % l)
	var quiet := Loudness.integrated(sine(997.0, -40.0, 4.0))
	assert_almost_eq(l - quiet, 20.0, 0.1, "20 dB quieter reads 20 LU less")
	assert_eq(Loudness.integrated(PackedVector2Array([Vector2.ZERO, Vector2.ZERO])), -70.0, "silence is gated out")


func test_the_true_peak_sees_between_the_samples() -> void:
	# a quarter of the sample rate at 45 degrees: every sample is at 0.707 of the top, the wave itself reaches it
	var x := sine(RATE / 4.0, -6.0, 0.5, PI / 4.0)
	var top := 0.0
	for v in x:
		top = maxf(top, absf(v.x))
	assert_lt(linear_to_db(top), -8.5, "the samples miss the top")
	assert_almost_eq(Loudness.true_peak(x), -6.0, 0.6, "the true peak finds it")


func test_the_limiter_model_holds_the_ceiling_and_counts() -> void:
	var x := sine(220.0, 3.0, 1.0)
	var r: Array = Loudness.limit(x, -1.5, 0.1)
	var out: PackedVector2Array = r[0]
	var top := 0.0
	for v in out:
		top = maxf(top, absf(v.x))
	assert_lte(linear_to_db(top), -1.49, "at most the ceiling")
	assert_eq(Loudness.windows_over(r[1], 3.0), 10, "4.5 dB off in every 0.1 s window")
	var calm: Array = Loudness.limit(sine(220.0, -12.0, 1.0), -1.5, 0.1)
	assert_eq(Loudness.windows_over(calm[1], 0.0), 0, "under the ceiling it does nothing")


# ---------------------------------------------------------------- the buses

func test_every_bus_runs_into_master_and_its_limiter() -> void:
	for bus: StringName in Audio.BUSES:
		var i := AudioServer.get_bus_index(bus)
		assert_gt(i, 0, "bus %s exists" % bus)
		assert_eq(AudioServer.get_bus_send(i), &"Master", "%s sends to Master" % bus)
		assert_true(SaveData.defaults().options.has(Audio.BUSES[bus].option), "%s follows a save option" % bus)
	var master := AudioServer.get_bus_index(&"Master")
	assert_true(AudioServer.get_bus_effect(master, AudioServer.get_bus_effect_count(master) - 1) is AudioEffectHardLimiter)


func test_the_volumes_land_on_the_buses_with_their_trims() -> void:
	Audio.apply_volumes()
	for bus: StringName in Audio.BUSES:
		var v: float = Save.option(Audio.BUSES[bus].option)
		assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)),
			linear_to_db(v) + float(Audio.BUSES[bus].trim), 0.01, bus)


func test_the_trims_only_name_real_sounds_and_only_lower() -> void:
	for s: StringName in Audio.GAIN_DB:
		assert_true(Audio.SOUNDS.has(s), "%s is a sound" % s)
		assert_lte(float(Audio.GAIN_DB[s]), 0.0, "%s is only lowered" % s)
	for s in Audio.UI_SOUNDS:
		assert_true(Audio.SOUNDS.has(s))


# ---------------------------------------------------------------- Morvath's warnings duck the bed

func test_a_warning_ducks_the_music_and_the_air_and_lets_go() -> void:
	var m := MusicMix.new({&"x": {"layers": 1, "length": 10.0}})
	var d := m.play(&"x")
	m.step(MusicMix.FADE_IN + 0.01)
	assert_almost_eq(m.heard(d, 0), 1.0, 0.01)
	m.warn(1.0)
	for i in 10:
		m.step(0.01)
	assert_almost_eq(m.heard(d, 0), MusicMix.WARN_DUCK, 0.01, "down within %.2f s" % MusicMix.WARN_ATTACK)
	for i in 80:
		m.step(0.01)
	assert_almost_eq(m.heard(d, 0), MusicMix.WARN_DUCK, 0.01, "held while the warning lasts")
	for i in 70:
		m.step(0.01)
	assert_almost_eq(m.heard(d, 0), 1.0, 0.01, "back after it")


func test_every_warning_cue_is_a_sound_and_ducks_the_game_music() -> void:
	for cue: StringName in Audio.WARN_CUES:
		assert_true(Audio.SOUNDS.has(cue), "%s is a sound" % cue)
	for cue in [&"scythe_raise", &"dash_aim", &"eruption", &"curse"]:
		assert_true(Audio.WARN_CUES.has(cue), "Morvath's %s ducks the bed" % cue)
	Audio.listen(true, func() -> int: return 0)
	Audio.play(&"scythe_raise")
	Audio.listen(false)
	assert_gt(Music.mix.warn_hold, 0.0, "the music ducks")
	assert_gt(Music.air.warn_hold, 0.0, "the air ducks")


# ---------------------------------------------------------------- the rooms' air

func test_every_arena_has_its_air() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var layouts: Array[RoomLayout] = []
	layouts.append_array(stage.layouts)
	for l: RoomLayout in [stage.boss_layout, stage.shop_layout, stage.trial_layout, stage.altar_layout]:
		if l != null:
			layouts.append(l)
	var ids := {&"hall": true}
	for l in layouts:
		ids[l.id] = true
	for id: StringName in ids:
		assert_ne(Ambience.of(id), &"", "arena %s has an air" % id)
		assert_not_null(Ambience.stream_of(Ambience.of(id)), "and its loop is there")
	for id in [&"crypt", &"rift", &"garden", &"sanctuary", &"bridge", &"runes", &"trial", &"altar", &"hall", &"seal_chamber"]:
		assert_ne(Ambience.of(id), &"", "%s (C15-04)" % id)


func test_the_loops_are_quiet_long_and_seamless() -> void:
	for arena: StringName in Ambience.BY_ARENA:
		var loop: StringName = Ambience.BY_ARENA[arena]
		var x := MixReplay.decode(Ambience.stream_of(loop))
		assert_gt(x.size() / RATE, 15.0, "%s lasts" % loop)
		var sq := 0.0
		var step := 0.0
		var top := 0.0
		for i in x.size():
			sq += x[i].x * x[i].x
			top = maxf(top, absf(x[i].x))
			if i > 0:
				step = maxf(step, absf(x[i].x - x[i - 1].x))
		var rms := linear_to_db(sqrt(sq / x.size()))
		assert_between(rms, -34.0, -24.0, "%s is quiet: %.1f dBFS" % [loop, rms])
		assert_lt(linear_to_db(top), -6.0, "%s never peaks" % loop)
		var seam := absf(x[0].x - x[x.size() - 1].x)
		assert_lt(seam, maxf(step, 0.002) * 1.5, "%s meets itself at the seam (%.4f, largest step %.4f)" % [loop, seam, step])


func test_a_room_change_crossfades_the_air() -> void:
	Music.air = MusicMix.new(Ambience.catalog())
	Music.ambience(&"crypt")
	assert_eq(Music.air.current_id(), Ambience.of(&"crypt"))
	Music.air.step(MusicMix.FADE_IN)
	Music.ambience(&"rift")
	Music.air.step(0.5)
	assert_eq(Music.air.decks.size(), 2, "the old air fades out under the new")
	assert_eq(Music.air.current_id(), Ambience.of(&"rift"))
	Music.air.step(MusicMix.FADE_OUT)
	assert_eq(Music.air.decks.size(), 1, "then it is gone")
	Music.ambience(&"rift")
	assert_eq(Music.air.decks.size(), 1, "the same room keeps its loop")
	Music.ambience(&"")
	Music.air.step(MusicMix.FADE_OUT + 0.1)
	assert_eq(Music.air.decks.size(), 0, "no room, no air")


# ---------------------------------------------------------------- a real fight's mix

func test_morvaths_fight_hits_the_loudness_targets() -> void:
	var events: Array = (JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/sound_log_boss.json")) as Dictionary).events
	var r := MixReplay.render(events, Audio, Music)
	var mix: PackedVector2Array = r.mix
	var lim: Array = Loudness.limit(mix, Audio.LIMIT_DB, Audio.LIMIT_RELEASE)
	var out: PackedVector2Array = lim[0]
	var lufs := Loudness.integrated(out)
	var tp := Loudness.true_peak(out)
	var working := Loudness.windows_over(lim[1], 0.5)
	gut.p("Morvath's fight: %.1f LUFS, %.2f dBTP after the limiter, limiter working in %d of %d windows" % [lufs, tp, working, (lim[1] as PackedFloat32Array).size()])
	assert_between(lufs, -18.0, -14.0, "integrated loudness (C15-01)")
	assert_lte(tp, -1.0, "true peak (C15-01)")
	assert_lt(float(working) / (lim[1] as PackedFloat32Array).size(), 0.02, "the limiter is a guard, not a compressor (B-3)")
	assert_eq(Loudness.windows_over(lim[1], 3.0), 0, "and never digs deep")
