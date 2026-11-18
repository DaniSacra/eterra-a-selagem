extends SceneTree
## The whole mix, measured offline (C15-03): Morvath's music at phase 4 (all four layers, the loudest music) at the
## game's gains, with the loudest blows and Morvath's beats all landing together every BLOW_EVERY seconds after
## MUSIC_ALONE, summed as the buses do with the save's default volumes. Prints the music's own level, the sum's true
## peak before the Master's limiter, and after a model of it (a hard limiter at Audio.LIMIT_DB with lookahead and
## Audio.LIMIT_RELEASE). The real limiter is Godot's AudioEffectHardLimiter; the Movie Maker records the real thing on
## the GPU (tools/movie.sh), the headless one cannot.
##   ~/tools/godot/godot --headless --path . -s tools/mix_probe.gd [-- --every=0.25 --seconds=8]
##
## E6 (C15-01, B-3), a real run: --log=file replays a sound log written by the game (--sound-log=file, on a smoke
## run: tools/smoke.sh 180 --start=boss --boons=25 --seed=5 --sound-log=/tmp/boss.json) through the same buses and
## gains (Audio.BUSES, Music.MUSIC_DB, Ambience.AMBIENCE_DB, the save's default volumes), the music and the air
## replayed by MusicMix on the log's clock (crossfades, layers, stings, Morvath's warning duck), every sound with
## its pitch and at most Audio.VOICES at once (the oldest cut). Prints the integrated loudness (LUFS, BS.1770), the
## loudest 3 s, the true peak before and after the limiter model, and in how many 100 ms windows the limiter works.
##   ... -s tools/mix_probe.gd -- --log=/tmp/boss.json [--wav=/tmp/mix.wav] [--before] [--music-dungeon=id] [--music-morvath=id]
## --before: the mix as it was before E6 (no bus trims, no air, no warning duck), for the comparison.

const RATE := 44100.0
const MUSIC_ALONE := 3.0
const BLOWS: Array[StringName] = [&"hit_heavy", &"mat_armor", &"blade", &"scythe_land", &"roar", &"ult_cleave"]


## The autoloads (Music, Audio, Save) are read at run time: this script is compiled before they exist.
func _process(_delta: float) -> bool:
	_measure()
	return true


func _measure() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--log="):
			_replay(a.substr(6))
			return
	var music_node := root.get_node("Music")
	var sounds := root.get_node("Audio")
	var music_consts: Dictionary = music_node.get_script().get_script_constant_map()
	var audio_consts: Dictionary = sounds.get_script().get_script_constant_map()
	var every := 0.25
	var seconds := 8.0
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--every="):
			every = float(a.substr(8))
		elif a.begins_with("--seconds="):
			seconds = float(a.substr(10))
	var opts: Dictionary = SaveData.defaults().options
	var master_db := linear_to_db(opts.master)
	var music_db: float = music_consts.MUSIC_DB + linear_to_db(opts.music) + master_db
	var sfx_db := linear_to_db(opts.sfx) + master_db
	var n := int(seconds * RATE)
	var mix := PackedVector2Array()
	mix.resize(n)
	# Morvath's chosen piece at phase 4 (T5): ours stacks the four layers, a solo piece plays its 4th section alone
	var boss_piece: StringName = music_node.call(&"piece_for", &"morvath")
	var solo := bool(MusicCatalog.spec(boss_piece).get("solo", false))
	for i in ([3] if solo else [0, 1, 2, 3]):
		_add(mix, _decode(music_node.stream_of(boss_piece, i), seconds), 0, music_db)
	var music_rms := _rms(mix, 0, int(MUSIC_ALONE * RATE))
	var t := MUSIC_ALONE
	while t < seconds:
		for b in BLOWS:
			var s: AudioStream = sounds.call(&"stream", b)
			_add(mix, _decode(s, -1.0), int(t * RATE), sfx_db)
		t += every
	var before := _true_peak(mix)
	var after := _true_peak(_limit(mix, db_to_linear(audio_consts.LIMIT_DB), audio_consts.LIMIT_RELEASE))
	print("music alone: rms %.1f dBFS, true peak %.1f dBTP" % [music_rms, _true_peak(mix.slice(0, int(MUSIC_ALONE * RATE)))])
	print("music + blows every %.2f s: true peak %.1f dBTP before the limiter, %.2f dBTP after (model)" % [every, before, after])


static func _decode(s: AudioStream, seconds: float) -> PackedVector2Array:
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


static func _add(mix: PackedVector2Array, x: PackedVector2Array, at: int, db: float) -> void:
	var g := db_to_linear(db)
	for i in mini(x.size(), mix.size() - at):
		mix[at + i] += x[i] * g


static func _rms(x: PackedVector2Array, from: int, to: int) -> float:
	var sq := 0.0
	for i in range(from, to):
		sq += x[i].x * x[i].x + x[i].y * x[i].y
	return linear_to_db(sqrt(sq / maxf(2.0 * (to - from), 1.0)) + 1e-12)


## A lookahead hard limiter (both channels together): the gain is at most ceiling over the peak of the next 5 ms
## (block maxima: this block and the next) and comes back at its release.
static func _limit(x: PackedVector2Array, ceiling: float, release: float) -> PackedVector2Array:
	var look := int(0.005 * RATE)
	var blocks := PackedFloat32Array()
	blocks.resize(x.size() / look + 2)
	blocks.fill(0.0)
	for i in x.size():
		var b := i / look
		blocks[b] = maxf(blocks[b], maxf(absf(x[i].x), absf(x[i].y)))
	var out := x.duplicate()
	var gain := 1.0
	var back := 1.0 / (release * RATE)
	for i in x.size():
		var b := i / look
		var need := minf(1.0, ceiling / maxf(maxf(blocks[b], blocks[b + 1]), 1e-9))
		gain = need if need < gain else minf(need, gain + back)
		out[i] = x[i] * gain
	return out


## The true peak, estimated 4 times between samples (cubic) where the signal is near its top.
static func _true_peak(x: PackedVector2Array) -> float:
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
				peak = maxf(peak, absf(b + 0.5 * q * (c - a + q * (2.0 * a - 5.0 * b + 4.0 * c - d + q * (3.0 * (b - c) + d - a)))))
	return linear_to_db(peak + 1e-12)


# ---------------------------------------------------------------- E6: a real run replayed

const MixReplay := preload("res://tools/mix_replay.gd")


func _replay(path: String) -> void:
	var t0 := Time.get_ticks_msec()
	var before := "--before" in OS.get_cmdline_user_args()
	var wav := ""
	var parts := ["music", "air", "sfx"]
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--wav="):
			wav = a.substr(6)
		elif a.begins_with("--parts="):
			# --parts=music,air: only those (the loudness of each part alone)
			parts = Array(a.substr(8).split(","))
		elif a.begins_with("--music-"):
			# MUS-1: --music-title=id, --music-dungeon=id, --music-morvath=id replay the log with that piece there (the
			# save's option in memory only, never written)
			var kv := a.substr(2).split("=")
			root.get_node("Save").data.options[kv[0].replace("-", "_")] = kv[1]
	var events: Array = (JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary).events
	var music_node := root.get_node("Music")
	var sounds := root.get_node("Audio")
	var r := MixReplay.render(events, sounds, music_node, before, parts)
	var mix: PackedVector2Array = r.mix
	var seconds: float = r.seconds
	var g_sfx: float = r.g_sfx
	var ac: Dictionary = sounds.get_script().get_script_constant_map()
	var power := Loudness.k_power(mix)
	var peak_before := Loudness.true_peak(mix)
	var limited: Array = Loudness.limit(mix, ac.LIMIT_DB, ac.LIMIT_RELEASE)
	var out: PackedVector2Array = limited[0]
	var red: PackedFloat32Array = limited[1]
	var power_out := Loudness.k_power(out)
	print("replay %s%s: %.1f s, %d sounds, %d events" % [path.get_file(), " (before E6)" if before else "", seconds, r.sounds, events.size()])
	print("  integrated %.1f LUFS (after the limiter %.1f), loudest 3 s %.1f LUFS" % [Loudness.integrated_of(power),
		Loudness.integrated_of(power_out), Loudness.short_term_max(power_out)])
	print("  true peak %.2f dBTP before the limiter, %.2f dBTP after (model, ceiling %.1f)" % [peak_before,
		Loudness.true_peak(out), ac.LIMIT_DB])
	print("  limiter working in %d of %d windows of 0.1 s (more than 0.5 dB off), %d more than 3 dB" % [
		Loudness.windows_over(red, 0.5), red.size(), Loudness.windows_over(red, 3.0)])
	if "--why" in OS.get_cmdline_user_args():
		_why(events, red, g_sfx, sounds)
	if wav != "":
		var bytes := PackedByteArray()
		bytes.resize(out.size() * 4)
		for i in out.size():
			bytes.encode_s16(i * 4, clampi(int(round(out[i].x * 32767.0)), -32768, 32767))
			bytes.encode_s16(i * 4 + 2, clampi(int(round(out[i].y * 32767.0)), -32768, 32767))
		var w := AudioStreamWAV.new()
		w.format = AudioStreamWAV.FORMAT_16_BITS
		w.stereo = true
		w.mix_rate = int(RATE)
		w.data = bytes
		w.save_to_wav(wav)
		print("  wrote %s" % wav)
	print("  (%.1f s to measure)" % ((Time.get_ticks_msec() - t0) / 1000.0))




## --why: the windows where the limiter works most, and the sounds that started in the 300 ms before; then each
## sound's own peak at the effects' gain.
func _why(events: Array, red: PackedFloat32Array, g_sfx: float, sounds: Node) -> void:
	var order := range(red.size())
	order.sort_custom(func(a: int, b: int) -> bool: return red[a] > red[b])
	for w: int in order.slice(0, 12):
		if red[w] <= 0.5:
			break
		var names := []
		for e: Array in events:
			var t := float(e[0]) / 1000.0
			if String(e[1]) == "sfx" and t > w * 0.1 - 0.3 and t < w * 0.1 + 0.1:
				names.append(e[2])
		print("  %.1f s: -%.1f dB  %s" % [w * 0.1, red[w], ", ".join(names)])
	var seen := {}
	var peaks := []
	for e: Array in events:
		if String(e[1]) == "sfx" and not seen.has(e[2]):
			seen[e[2]] = true
			var x := _decode(sounds.call(&"stream", StringName(e[2])), -1.0)
			var top := 0.0
			for v in x:
				top = maxf(top, maxf(absf(v.x), absf(v.y)))
			peaks.append([linear_to_db(top * g_sfx) + float(sounds.get_script().get_script_constant_map().GAIN_DB.get(StringName(e[2]), 0.0)), e[2]])
	peaks.sort()
	peaks.reverse()
	print("  loudest sounds alone: " + ", ".join(peaks.slice(0, 14).map(func(p: Array) -> String: return "%s %.1f" % [p[1], p[0]])))


