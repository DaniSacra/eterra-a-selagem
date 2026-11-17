extends GutTest
## The music (E4-06, C15-03): the files are there, small, in time with each other and never silent for 2 s; the
## mix rules (MusicMix) never leave 2 s of silence with the music on; the music sits under the blows and its own
## peak stays well under -1 dBTP before the Master's limiter (Audio.limit_master).

const RATE := 44100.0
## "Silence": a stretch this quiet (RMS, dBFS) for SILENCE_S seconds.
const QUIET_DB := -50.0
const SILENCE_S := 2.0


func after_each() -> void:
	Music.mix = MusicMix.new(Music.catalog())


## The samples of a stream, at most `seconds` long (its own length when -1).
static func decode(s: AudioStream, seconds: float = -1.0) -> PackedVector2Array:
	var total := int((s.get_length() if seconds < 0.0 else seconds) * RATE)
	var pb := s.instantiate_playback()
	pb.start(0.0)
	var out := PackedVector2Array()
	while out.size() < total:
		var chunk := pb.mix_audio(1.0, 4096)
		if chunk.is_empty():
			break
		out.append_array(chunk)
	out.resize(mini(out.size(), total))
	return out


## Seconds of the longest run of blocks quieter than QUIET_DB.
static func longest_quiet(x: PackedVector2Array, block_s: float = 0.25) -> float:
	var block := int(block_s * RATE)
	var run := 0.0
	var worst := 0.0
	var i := 0
	while i + block <= x.size():
		var sq := 0.0
		for k in block:
			var v := x[i + k]
			sq += v.x * v.x + v.y * v.y
		var quiet := linear_to_db(sqrt(sq / (2.0 * block)) + 1e-9) < QUIET_DB
		run = run + block_s if quiet else 0.0
		worst = maxf(worst, run)
		i += block
	return worst


## The loudest RMS over windows of `window_s`, in dBFS.
static func loudest_rms(x: PackedVector2Array, window_s: float) -> float:
	var w := maxi(int(window_s * RATE), 1)
	var best := 0.0
	var i := 0
	while i < x.size():
		var sq := 0.0
		var n := mini(w, x.size() - i)
		for k in n:
			var v := x[i + k]
			sq += v.x * v.x + v.y * v.y
		best = maxf(best, sq / (2.0 * n))
		i += w
	return linear_to_db(sqrt(best) + 1e-12)


## The true peak, estimated: every sample, and 4 times between samples (cubic) where the signal is near its top.
static func true_peak(x: PackedVector2Array) -> float:
	var top := 0.0
	for v in x:
		top = maxf(top, maxf(absf(v.x), absf(v.y)))
	var peak := top
	for i in range(1, x.size() - 2):
		for ch in 2:
			var b: float = x[i][ch]
			if absf(b) < top * 0.7:
				continue
			var a: float = x[i - 1][ch]
			var c: float = x[i + 1][ch]
			var d: float = x[i + 2][ch]
			for q: float in [0.25, 0.5, 0.75]:
				var v := b + 0.5 * q * (c - a + q * (2.0 * a - 5.0 * b + 4.0 * c - d + q * (3.0 * (b - c) + d - a)))
				peak = maxf(peak, absf(v))
	return linear_to_db(peak)


func _sum(layers: Array) -> PackedVector2Array:
	var out: PackedVector2Array = layers[0].duplicate()
	for k in range(1, layers.size()):
		var y: PackedVector2Array = layers[k]
		for i in mini(out.size(), y.size()):
			out[i] += y[i]
	return out


func _scaled(x: PackedVector2Array, db: float) -> PackedVector2Array:
	var g := db_to_linear(db)
	var out := x.duplicate()
	for i in out.size():
		out[i] *= g
	return out


func test_every_track_is_there_in_time_and_small() -> void:
	var cat := Music.catalog()
	var bounds := {&"catacombs": Vector2(60, 120), &"morvath": Vector2(45, 120), &"victory": Vector2(6, 15)}
	for id: StringName in Music.TRACKS:
		assert_true(cat.has(id), "track %s" % id)
		var spec: Dictionary = Music.TRACKS[id]
		var first := -1.0
		for i in int(spec.layers):
			var s := Music.stream_of(id, i, spec.layers)
			assert_not_null(s, Music.file_of(id, i, spec.layers))
			if s == null:
				continue
			assert_eq((s as AudioStreamOggVorbis).loop, bool(spec.loop), "%s loops: %s" % [id, spec.loop])
			if first < 0.0:
				first = s.get_length()
			assert_almost_eq(s.get_length(), first, 0.005, "%s layer %d in time with layer 1" % [id, i + 1])
		var b: Vector2 = bounds[id]
		assert_between(first, b.x, b.y, "%s length" % id)
	for id in Music.STINGS:
		assert_true(cat.has(id), "sting %s" % id)
		if cat.has(id):
			assert_between(float(cat[id].length), 10.0, 20.0, "%s length" % id)
	var total := 0
	for f in DirAccess.get_files_at(Music.DIR):
		if f.ends_with(".ogg"):
			total += FileAccess.get_file_as_bytes(Music.DIR + f).size()
	assert_lt(total, 15 * 1024 * 1024, "the music stays small in the package")


func test_no_track_has_two_seconds_of_silence() -> void:
	# the layer always heard under each track (the walk, Morvath's first phase), the stings and the victory up to
	# the moment it hands over (MusicMix.HANDOVER)
	var cat := Music.catalog()
	for id: StringName in [&"catacombs", &"morvath"]:
		var x := decode(Music.stream_of(id, 0, Music.TRACKS[id].layers))
		assert_lt(longest_quiet(x), SILENCE_S, "%s: quiet stretch" % id)
	var victory := decode(Music.stream_of(&"victory", 0, 1), float(cat[&"victory"].length) - MusicMix.HANDOVER)
	assert_lt(longest_quiet(victory), SILENCE_S, "victory: quiet stretch")
	for id in Music.STINGS:
		var x := decode(Music.stream_of(id, 0, 1), float(cat[id].length) - 3.0)
		assert_lt(longest_quiet(x), SILENCE_S, "%s: quiet stretch" % id)


## A whole descent on the mix's clock: title, rooms with fights won, a sting, Morvath's four phases, the victory and
## the end screen; then a death in the fight. The music is never gone for 2 s.
func test_a_run_never_leaves_two_seconds_of_silence() -> void:
	var mix := MusicMix.new(Music.catalog())
	var plan: Array = [
		["play", &"catacombs", 1, 8.0], ["play", &"catacombs", 2, 25.0], ["level", 1, 6.0],
		["play", &"catacombs", 2, 20.0], ["sting", &"psalm_sentinel", 0, 3.0], ["level", 1, 30.0],
		["play", &"morvath", 1, 30.0], ["level", 2, 25.0], ["level", 3, 25.0], ["level", 4, 70.0],
		["play", &"victory", 1, 60.0],
		["play", &"morvath", 3, 10.0], ["play", &"catacombs", 1, 20.0],
	]
	var quiet := 0.0
	var worst := 0.0
	for step: Array in plan:
		match step[0]:
			"play":
				assert_not_null(mix.play(step[1], step[2]), "plays %s" % step[1])
			"level":
				mix.set_level(step[1])
			"sting":
				assert_not_null(mix.sting(step[1]))
		var t := 0.0
		while t < float(step.back()):
			mix.step(0.05)
			mix.take_changes()
			t += 0.05
			quiet = quiet + 0.05 if mix.audible() < 0.1 else 0.0
			worst = maxf(worst, quiet)
	assert_lt(worst, SILENCE_S, "the longest stretch with no music")
	assert_eq(mix.current_id(), &"catacombs")


func test_a_new_track_crossfades_and_the_victory_hands_over() -> void:
	var mix := MusicMix.new(Music.catalog())
	mix.play(&"catacombs", 2)
	for i in 60:
		mix.step(0.05)
	mix.play(&"morvath", 1)
	mix.step(0.5)
	assert_eq(mix.decks.size(), 2, "the rooms' music still fading while Morvath's comes in")
	assert_gt(mix.decks[0].fade, 0.0)
	assert_gt(mix.decks[1].fade, 0.0)
	for i in 100:
		mix.step(0.05)
	assert_eq(mix.decks.size(), 1)
	mix.play(&"victory")
	var t := 0.0
	while mix.current_id() == &"victory" and t < 30.0:
		mix.step(0.05)
		t += 0.05
	assert_eq(mix.current_id(), &"catacombs", "the victory hands over to the walk")
	assert_between(t, float(mix.catalog[&"victory"].length) - MusicMix.HANDOVER - 0.1, float(mix.catalog[&"victory"].length))


func test_the_api_levels_phases_and_stings() -> void:
	Music.play(&"catacombs", Music.FIGHT)
	assert_eq(Music.current(), &"catacombs")
	assert_eq(Music.mix.level(), 2)
	Music.set_level(Music.WALK)
	assert_eq(Music.mix.level(), 1)
	Music.boss_phase(1)
	assert_eq(Music.current(), &"morvath")
	assert_eq(Music.mix.level(), 1)
	var decks := Music.mix.decks.size()
	Music.boss_phase(3)
	assert_eq(Music.mix.level(), 3, "a phase adds layers")
	assert_eq(Music.mix.decks.size(), decks, "the same track goes on")
	Music.sting(&"sentinel")
	assert_eq(Music.mix.stings.size(), 1, "a Psalm's id finds its theme")
	assert_eq(Music.mix.stings[0].id, &"psalm_sentinel")
	for i in 30:
		Music.mix.step(0.05)
	assert_almost_eq(Music.mix.duck, MusicMix.DUCK, 0.01, "the bed goes down under the sting")
	assert_gt(Music.mix.audible(), MusicMix.DUCK - 0.01)


func test_music_runs_into_master_before_the_limiter() -> void:
	var bus := AudioServer.get_bus_index(&"Music")
	assert_gt(bus, 0)
	assert_true(AudioServer.get_bus_send(bus) in [&"Master", &""], "the Music bus sends to Master")
	var master := AudioServer.get_bus_index(&"Master")
	var last := AudioServer.get_bus_effect(master, AudioServer.get_bus_effect_count(master) - 1)
	assert_true(last is AudioEffectHardLimiter, "the limiter is the Master's last effect")
	assert_almost_eq((last as AudioEffectHardLimiter).ceiling_db, Audio.LIMIT_DB, 0.001)
	assert_true(SaveData.defaults().options.has("music"), "the music's volume is a save option")


## The mixing (C15-03): Morvath's full track (four layers, the loudest music) at the game's gain stays far under
## -1 dBTP on its own, and its loudest moment sits at least 6 dB under a blow.
func test_music_sits_under_the_blows() -> void:
	var opts: Dictionary = SaveData.defaults().options
	var music_db := Music.MUSIC_DB + linear_to_db(opts.music) + linear_to_db(opts.master)
	var sfx_db := linear_to_db(opts.sfx) + linear_to_db(opts.master)
	var layers := []
	for i in 4:
		layers.append(decode(Music.stream_of(&"morvath", i, 4)))
	var boss := _scaled(_sum(layers), music_db)
	var peak := true_peak(boss)
	var loud := loudest_rms(boss, 0.4)
	var blows := -100.0
	for name: String in ["hit_0", "hit_1", "hit_heavy_0"]:
		blows = maxf(blows, loudest_rms(_scaled(decode(load("res://audio/%s.ogg" % name)), sfx_db), 0.05))
	gut.p("music: true peak %.1f dBTP, loudest 0.4 s %.1f dBFS; blows %.1f dBFS" % [peak, loud, blows])
	assert_lt(peak, Audio.LIMIT_DB - 6.0, "the music alone never drives the limiter")
	assert_lt(loud + 6.0, blows, "the music sits under the blows")
