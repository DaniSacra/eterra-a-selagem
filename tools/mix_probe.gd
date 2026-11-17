extends SceneTree
## The whole mix, measured offline (C15-03): Morvath's music at phase 4 (all four layers, the loudest music) at the
## game's gains, with the loudest blows and Morvath's beats all landing together every BLOW_EVERY seconds after
## MUSIC_ALONE, summed as the buses do with the save's default volumes. Prints the music's own level, the sum's true
## peak before the Master's limiter, and after a model of it (a hard limiter at Audio.LIMIT_DB with lookahead and
## Audio.LIMIT_RELEASE). The real limiter is Godot's AudioEffectHardLimiter; the Movie Maker records the real thing on
## the GPU (tools/movie.sh), the headless one cannot.
##   ~/tools/godot/godot --headless --path . -s tools/mix_probe.gd [-- --every=0.25 --seconds=8]

const RATE := 44100.0
const MUSIC_ALONE := 3.0
const BLOWS: Array[StringName] = [&"hit_heavy", &"mat_armor", &"blade", &"scythe_land", &"roar", &"ult_cleave"]


## The autoloads (Music, Audio, Save) are read at run time: this script is compiled before they exist.
func _process(_delta: float) -> bool:
	_measure()
	return true


func _measure() -> void:
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
	for i in 4:
		_add(mix, _decode(music_node.stream_of(&"morvath", i, 4), seconds), 0, music_db)
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
