extends GutTest
## The music (E4-06, C15-03): the files are there, small, in time with each other and never silent for 2 s; the
## mix rules (MusicMix) never leave 2 s of silence with the music on; the music sits under the blows and its own
## peak stays well under -1 dBTP before the Master's limiter (Audio.limit_master).

const RATE := 44100.0
## "Silence": a stretch this quiet (RMS, dBFS) for SILENCE_S seconds.
const QUIET_DB := -50.0
const SILENCE_S := 2.0


var _options: Dictionary


## T5 (Músicas): the tests hear the default pieces, whatever this machine's save chose; put back afterwards.
func before_each() -> void:
	_options = (Save.data.options as Dictionary).duplicate()
	for place in MusicCatalog.PLACES:
		Save.data.options[MusicCatalog.OPTION[place]] = String(MusicCatalog.DEFAULT[place])
	Music.mix = MusicMix.new(Music.catalog())


func after_each() -> void:
	Save.data.options = _options
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
	# T5: the recorded rooms' pieces are long loops (40 and 70 bars, about 2 min 45 s), the title's whole piece,
	# Morvath's four sections of 48 bars; ours (E4, back in Músicas) 96 s for the rooms and 64 s for Morvath
	var bounds := {&"classic_catacombs": Vector2(60, 200), &"classic_morvath": Vector2(45, 120), &"tempting_secrets": Vector2(60, 200),
		&"gloom_descent": Vector2(60, 200), &"clash_defiant": Vector2(45, 120), &"victory": Vector2(6, 15),
		# MUS-1: the fight music, 60 to 100 s in whole bars
		&"thatched_villagers": Vector2(100, 130), &"achaidh_cheide": Vector2(100, 130), &"heroic_age": Vector2(80, 100), &"blade_march": Vector2(60, 100), &"deep_drums": Vector2(60, 100), &"iron_pulse": Vector2(60, 100), &"morvath_battle": Vector2(60, 100)}
	for id: StringName in MusicCatalog.PIECES.keys().filter(MusicCatalog.is_real):
		assert_true(cat.has(id), "piece %s" % id)
		var spec := MusicCatalog.spec(id)
		if spec.get("sting", false):
			if cat.has(id):
				assert_between(float(cat[id].length), 10.0, 20.0, "%s length" % id)
			continue
		var first := -1.0
		for i in int(spec.layers):
			var s := Music.stream_of(id, i)
			assert_not_null(s, Music.file_of(id, i))
			if s == null:
				continue
			assert_eq((s as AudioStreamOggVorbis).loop, bool(spec.loop), "%s loops: %s" % [id, spec.loop])
			if first < 0.0:
				first = s.get_length()
			# a solo track (T5) hears one layer at a time: each piece loops on its own bars, the walk and the fight
			# need not be the same length; layers that sound together must
			if not spec.get("solo", false):
				assert_almost_eq(s.get_length(), first, 0.005, "%s layer %d in time with layer 1" % [id, i + 1])
		var b: Vector2 = bounds[id]
		assert_between(first, b.x, b.y, "%s length" % id)
	var total := 0
	for f in DirAccess.get_files_at(Music.DIR):
		if f.ends_with(".ogg"):
			total += FileAccess.get_file_as_bytes(Music.DIR + f).size()
	# T5 (Músicas): our own rooms' and Morvath's music came back next to the recorded pieces (5.5 MB more)
	assert_lt(total, 20 * 1024 * 1024, "the music stays small in the package")


## MUS-1: a loop of ours (all its layers summed, as the fight hears them) meets itself: the jump from its last
## sample to its first is no larger than the jumps inside it, and its last and first quarter second are about as loud
## (no fade out, no gap, no restart heard).
func test_our_layered_loops_meet_themselves() -> void:
	for id: StringName in MusicCatalog.PIECES.keys().filter(MusicCatalog.is_real):
		var spec := MusicCatalog.spec(id)
		if not spec.get("loop", false) or spec.get("solo", false) or int(spec.layers) < 2:
			continue
		var layers := []
		for i in int(spec.layers):
			layers.append(decode(Music.stream_of(id, i)))
		var x := _sum(layers)
		var n := x.size()
		var step := 0.0
		for i in range(1, n):
			step = maxf(step, maxf(absf(x[i].x - x[i - 1].x), absf(x[i].y - x[i - 1].y)))
		var seam := maxf(absf(x[0].x - x[n - 1].x), absf(x[0].y - x[n - 1].y))
		assert_lt(seam, step, "%s: the seam (%.4f) is no jump (largest inside %.4f)" % [id, seam, step])
		var q := int(0.25 * RATE)
		var head := loudest_rms(x.slice(0, q), 0.25)
		var tail := loudest_rms(x.slice(n - q), 0.25)
		assert_lt(absf(head - tail), 6.0, "%s: as loud before the seam as after (%.1f, %.1f dBFS)" % [id, tail, head])


func test_no_track_has_two_seconds_of_silence() -> void:
	# every layer that may be heard alone (each section of a solo piece; ours only the first, the walk and Morvath's
	# first phase, the others play over it), the stings and the victory up to the moment it hands over
	var cat := Music.catalog()
	for id: StringName in MusicCatalog.PIECES.keys().filter(MusicCatalog.is_real):
		var spec := MusicCatalog.spec(id)
		if not spec.get("loop", false):
			continue
		for i in (int(spec.layers) if spec.get("solo", false) else 1):
			var x := decode(Music.stream_of(id, i))
			assert_lt(longest_quiet(x), SILENCE_S, "%s layer %d: quiet stretch" % [id, i + 1])
	var victory := decode(Music.stream_of(&"victory", 0), float(cat[&"victory"].length) - MusicMix.HANDOVER)
	assert_lt(longest_quiet(victory), SILENCE_S, "victory: quiet stretch")
	for id: StringName in MusicCatalog.PIECES.keys().filter(MusicCatalog.is_real):
		if MusicCatalog.spec(id).get("sting", false):
			var x := decode(Music.stream_of(id, 0), float(cat[id].length) - 3.0)
			assert_lt(longest_quiet(x), SILENCE_S, "%s: quiet stretch" % id)


## The pieces chosen for the rooms and Morvath (Músicas, T5), in Save.data only.
func _choose(dungeon: StringName, boss: StringName) -> void:
	Save.data.options.music_dungeon = String(dungeon)
	Save.data.options.music_morvath = String(boss)


## A whole descent on the mix's clock: title, rooms with fights won, a sting, Morvath's four phases, the victory and
## the end screen; then a death in the fight. The music is never gone for 2 s, with our pieces (the default, layers
## added) and with the recorded ones (one section at a time).
func test_a_run_never_leaves_two_seconds_of_silence() -> void:
	for pair: Array in [[&"blade_march", &"morvath_battle"], [&"deep_drums", &"classic_morvath"], [&"iron_pulse", &"morvath_battle"],
			[&"classic_catacombs", &"classic_morvath"], [&"gloom_descent", &"clash_defiant"]]:
		_choose(pair[0], pair[1])
		var rooms := Music.piece_for(&"catacombs")
		var boss := Music.piece_for(&"morvath")
		assert_eq([rooms, boss], pair, "the choice is played")
		var mix := MusicMix.new(Music.catalog())
		var plan: Array = [
			["play", &"title", 1, 8.0], ["play", rooms, 1, 8.0], ["play", rooms, 2, 25.0], ["level", 1, 6.0],
			["play", rooms, 2, 20.0], ["sting", &"psalm_sentinel", 0, 3.0], ["level", 1, 30.0],
			["play", boss, 1, 30.0], ["level", 2, 25.0], ["level", 3, 25.0], ["level", 4, 70.0],
			["play", &"victory", 1, 60.0],
			["play", boss, 3, 10.0], ["play", rooms, 1, 20.0],
		]
		var quiet := 0.0
		var worst := 0.0
		for step: Array in plan:
			match step[0]:
				"play":
					var piece: StringName = Music.piece_for(step[1])
					assert_not_null(mix.play(piece, step[2]), "plays %s" % piece)
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
		assert_lt(worst, SILENCE_S, "%s: the longest stretch with no music" % rooms)
		assert_eq(mix.current_id(), rooms)


func test_a_new_track_crossfades_and_the_victory_hands_over() -> void:
	for pair: Array in [[&"blade_march", &"morvath_battle"], [&"deep_drums", &"classic_morvath"], [&"iron_pulse", &"morvath_battle"],
			[&"classic_catacombs", &"classic_morvath"], [&"gloom_descent", &"clash_defiant"]]:
		_choose(pair[0], pair[1])
		var mix := MusicMix.new(Music.catalog())
		mix.play(pair[0], 2)
		for i in 60:
			mix.step(0.05)
		mix.play(pair[1], 1)
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
		assert_eq(mix.current_id(), pair[0], "the victory hands over to the chosen rooms' walk")
		assert_eq(mix.level(), 1)
		assert_between(t, float(mix.catalog[&"victory"].length) - MusicMix.HANDOVER - 0.1, float(mix.catalog[&"victory"].length))


## Our pieces (the default): the title is the rooms' walk, and the first room goes on with the same piece (the
## fight comes in over the walk, as before T5); Morvath adds a layer a phase.
func test_the_default_title_is_the_walk_and_the_rooms_go_on() -> void:
	Music.play(&"title")
	assert_eq(Music.current(), &"blade_march", "the title hears our rooms' music")
	assert_eq(Music.mix.level(), 1, "the walk")
	var d := Music.mix.current()
	Music.play(&"catacombs", Music.FIGHT)
	assert_eq(Music.mix.current(), d, "the first room does not restart the piece")
	assert_eq(Array(d.targets), [1.0, 1.0], "the fight over the walk")
	Music.boss_phase(3)
	assert_eq(Music.current(), &"morvath_battle")
	assert_eq(Array(Music.mix.current().targets), [1.0, 1.0, 1.0, 0.0], "phase 3 over the first two")


## T5: the recorded pieces hear one layer at a time, crossfaded, never restarted; the title's own piece.
func test_the_title_and_the_solo_tracks() -> void:
	Save.data.options.music_title = "tempting_secrets"
	_choose(&"gloom_descent", &"clash_defiant")
	var mix := MusicMix.new(Music.catalog())
	mix.play(Music.piece_for(&"title"))
	for i in 40:
		mix.step(0.05)
	assert_eq(mix.current_id(), &"tempting_secrets")
	var title := mix.current()
	mix.play(Music.piece_for(&"catacombs"), Music.FIGHT)
	assert_eq(mix.current_id(), &"gloom_descent", "the first room crossfades from the title")
	assert_gt(title.fade, 0.0, "the title still fading out")
	var d := mix.current()
	assert_eq(Array(d.targets), [0.0, 1.0], "the fight alone")
	for i in 60:
		mix.step(0.05)
	var t := d.time
	mix.set_level(Music.WALK)
	assert_eq(Array(d.targets), [1.0, 0.0], "the walk alone")
	mix.step(1.0)
	assert_gt(d.gains[0], 0.0)
	assert_gt(d.gains[1], 0.0, "a crossfade, not a cut")
	assert_almost_eq(d.time, t + 1.0, 0.001, "the same deck goes on: nothing restarts")
	mix.play(Music.piece_for(&"morvath"), 3)
	assert_eq(Array(mix.current().targets), [0.0, 0.0, 1.0, 0.0], "phase 3 hears its own section")
	assert_eq(mix.level(), 3)
	var s := Music.stream_of(&"tempting_secrets", 0) as AudioStreamOggVorbis
	assert_true(s.loop)
	assert_almost_eq(s.loop_offset, float(MusicCatalog.spec(&"tempting_secrets").loop_from), 0.001, "the opening hit plays once")


func test_the_api_levels_phases_and_stings() -> void:
	Music.play(&"catacombs", Music.FIGHT)
	assert_eq(Music.current(), Music.piece_for(&"catacombs"))
	assert_eq(Music.mix.level(), 2)
	Music.set_level(Music.WALK)
	assert_eq(Music.mix.level(), 1)
	Music.boss_phase(1)
	assert_eq(Music.current(), Music.piece_for(&"morvath"))
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


## QA E4: Game.take_psalm calls Music.sting(p.id) with the Psalm's real id (data/psalms: sentinela, abrigo, pastor,
## rocha), not the English names the stings are filed under (psalm_sentinel...): every real Psalm must find its theme.
func test_every_real_psalm_finds_its_sting() -> void:
	var all := Psalms.load_catalog()
	assert_gt(all.size(), 0, "the Psalms are there")
	for p: PsalmDef in all:
		var before := Music.mix.stings.size()
		Music.sting(p.id)
		assert_eq(Music.mix.stings.size(), before + 1, "Psalm %s (Music.sting(&\"%s\")) plays a theme" % [p.id, p.id])


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
## -1 dBTP on its own, and its loudest moment sits at least MUSIC_UNDER_BLOW under the loudest blow. E6 (C15-01): the
## gains are the buses' (Audio.BUSES trims, Audio.GAIN_DB per sound); the music came up 9 dB so the whole mix reaches
## -18 to -14 LUFS with the limiter only a guard (B-3; tests/test_mix.gd): its own true peak, -13 dBTP in E4, is now
## about -3.5, so the rule on it went from 6 dB to 1.5 dB under the limiter's ceiling (docs/qa/e6_audio_perf.md).
const MUSIC_UNDER_BLOW := 6.0


func test_music_sits_under_the_blows() -> void:
	var opts: Dictionary = SaveData.defaults().options
	var music_db := Music.MUSIC_DB + linear_to_db(opts.music) + linear_to_db(opts.master) + float(Audio.BUSES[&"Music"].trim)
	var sfx_db := linear_to_db(opts.sfx) + linear_to_db(opts.master) + float(Audio.BUSES[&"SFX"].trim)
	# T5 (Músicas): every Morvath piece the player may choose. Ours stacks its layers (phase 4 is the four together);
	# a recorded one plays one section per phase, so its loudest is the loudest single layer, not their sum
	var peak := -100.0
	var loud := -100.0
	for id in MusicCatalog.choices(MusicCatalog.MORVATH):
		var layers: Array = []
		for i in MusicCatalog.layers(id):
			layers.append(decode(Music.stream_of(id, i)))
		var heard: Array = layers if MusicCatalog.spec(id).get("solo", false) else [_sum(layers)]
		for x: PackedVector2Array in heard:
			var boss := _scaled(x, music_db)
			peak = maxf(peak, true_peak(boss))
			loud = maxf(loud, loudest_rms(boss, 0.4))
	var blows := -100.0
	for pair: Array in [["hit_0", &"hit"], ["hit_1", &"hit"], ["hit_heavy_0", &"hit_heavy"]]:
		var db := sfx_db + float(Audio.GAIN_DB.get(pair[1], 0.0))
		blows = maxf(blows, loudest_rms(_scaled(decode(load("res://audio/%s.ogg" % pair[0])), db), 0.05))
	gut.p("music: true peak %.1f dBTP, loudest 0.4 s %.1f dBFS; blows %.1f dBFS" % [peak, loud, blows])
	assert_lt(peak, Audio.LIMIT_DB - 1.5, "the music alone never drives the limiter")
	assert_lt(loud + MUSIC_UNDER_BLOW, blows, "the music sits under the blows")
