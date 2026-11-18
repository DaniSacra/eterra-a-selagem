extends RefCounted
## A sound log replayed through the game's buses (E6, C15-01): tools/mix_probe.gd --log prints its numbers,
## tests/test_mix.gd holds them. The log is what the game writes with --sound-log=file (Audio.log_event and the sound
## names Audio.play let through): [ms, "sfx", name, pitch], [ms, "music", id, level], [ms, "level", n],
## [ms, "boss", phase], [ms, "sting", id], [ms, "stop"], [ms, "air", loop]. The music and the air are replayed by
## MusicMix on the log's clock (crossfades, layers, stings, Morvath's warning duck), each sound with its pitch and its
## trim (Audio.GAIN_DB), at most Audio.VOICES at once (the oldest cut), at the save's default volumes and the buses'
## trims (Audio.BUSES). before: the mix as it was before E6 (no trims, no air, no duck).

const RATE := 44100.0
const BLOCK := 441  # 10 ms: the music's and the air's gains are stepped at this rate


## Returns {"mix": PackedVector2Array (before the Master's limiter), "sounds": count, "seconds": length, "g_sfx": the
## effects' gain}. sounds and music_node: the Audio and Music autoloads (read at run time: a tool is compiled first).
static func render(events: Array, sounds: Node, music_node: Node, before: bool = false, parts: Array = ["music", "air", "sfx"]) -> Dictionary:
	var mc: Dictionary = music_node.get_script().get_script_constant_map()
	var ac: Dictionary = sounds.get_script().get_script_constant_map()
	var opts: Dictionary = SaveData.defaults().options
	var master_db := linear_to_db(opts.master)
	var buses: Dictionary = ac.BUSES
	var trim := func(bus: StringName) -> float: return 0.0 if before else float(buses[bus].trim)
	var music_db: float = mc.MUSIC_DB + linear_to_db(opts.music) + master_db + trim.call(&"Music")
	var air_db: float = Ambience.AMBIENCE_DB + linear_to_db(opts.sfx) + master_db + trim.call(&"Ambience")
	var sfx_db: float = linear_to_db(opts.sfx) + master_db + trim.call(&"SFX")
	var warn_cues: Dictionary = ac.WARN_CUES
	var seconds := float(events.back()[0]) / 1000.0 + 3.0
	var n := int(seconds * RATE)
	var mix := PackedVector2Array()
	mix.resize(n)
	# the music and the air: MusicMix stepped on the log's clock, each deck's layers decoded once and read at its age
	var music := MusicMix.new(music_node.call(&"catalog"))
	var air := MusicMix.new(Ambience.catalog())
	var decoded := {}
	var born := {}
	var next_event := 0
	for b in n / BLOCK:
		var now_ms := b * BLOCK * 1000 / int(RATE)
		while next_event < events.size() and int(events[next_event][0]) <= now_ms:
			var e: Array = events[next_event]
			next_event += 1
			match String(e[1]):
				"music":
					# T5: the log keeps the place; the piece is the one chosen there (Music.piece_for)
					music.play(music_node.call(&"piece_for", StringName(e[2])), int(e[3]))
				"level":
					music.set_level(int(e[2]))
				"boss":
					var boss_piece: StringName = music_node.call(&"piece_for", &"morvath")
					if music.current_id() != boss_piece:
						music.play(boss_piece, int(e[2]))
					else:
						music.set_level(int(e[2]))
				"sting":
					music.sting(StringName(e[2]))
				"stop":
					music.stop()
				"air":
					if before:
						continue
					if String(e[2]) == "" or not air.catalog.has(StringName(e[2])):
						air.stop()
					else:
						air.play(StringName(e[2]))
				"sfx":
					if not before and warn_cues.has(StringName(e[2])):
						music.warn(warn_cues[StringName(e[2])])
						air.warn(warn_cues[StringName(e[2])])
		music.step(BLOCK / RATE)
		air.step(BLOCK / RATE)
		for m: MusicMix in [music, air]:
			m.take_changes()
			var decks: Array[MusicMix.Deck] = []
			decks.append_array(m.decks)
			decks.append_array(m.stings)
			for d in decks:
				if not born.has(d):
					born[d] = b * BLOCK
				for layer in d.layers():
					var key := "%s/%d" % [d.id, layer]
					if not decoded.has(key):
						var st: AudioStream = Ambience.stream_of(d.id) if m == air else music_node.call(&"stream_of", d.id, layer, d.layers())
						decoded[key] = decode(st, -1.0) if st != null else PackedVector2Array()
					var src: PackedVector2Array = decoded[key]
					if src.is_empty():
						continue
					var g := db_to_linear(air_db if m == air else music_db) * m.heard(d, layer) * (1.0 if parts.has("air" if m == air else "music") else 0.0)
					if g < 0.0001:
						continue
					var age: int = b * BLOCK - int(born[d])
					for k in BLOCK:
						var at := age + k
						if at >= src.size():
							if not d.loop:
								break
							at %= src.size()
						mix[b * BLOCK + k] += src[at] * g
	# the sounds: each with its pitch, at most VOICES at once (the oldest cut where the new one starts)
	var g_sfx := db_to_linear(sfx_db) if parts.has("sfx") else 0.0
	var voices: Array = []  # [start, end, index into cuts]
	var plays: Array = []  # [start sample, stream samples, cut length]
	for e: Array in events:
		if String(e[1]) != "sfx" or StringName(e[2]) in ac.UI_SOUNDS:
			continue
		var at := int(float(e[0]) / 1000.0 * RATE)
		var pitch: float = e[3] if e.size() > 3 else 1.0
		var x := _pitched(decode(sounds.call(&"stream", StringName(e[2])), -1.0), pitch)
		if not before:
			x = _gain(x, db_to_linear(float(ac.GAIN_DB.get(StringName(e[2]), 0.0))))
		voices = voices.filter(func(v: Array) -> bool: return v[1] > at)
		if voices.size() >= int(ac.VOICES):
			var oldest: Array = voices.pop_front()
			plays[oldest[2]][2] = at - int(oldest[0])
		plays.append([at, x, x.size()])
		voices.append([at, at + x.size(), plays.size() - 1])
	for p: Array in plays:
		var x: PackedVector2Array = p[1]
		var at: int = p[0]
		for i in mini(int(p[2]), n - at):
			mix[at + i] += x[i] * g_sfx
	return {"mix": mix, "sounds": plays.size(), "seconds": seconds, "g_sfx": g_sfx}


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


## A sound at a pitch (linear interpolation: higher is shorter, as AudioStreamPlayer.pitch_scale plays it).
static func _pitched(x: PackedVector2Array, pitch: float) -> PackedVector2Array:
	if absf(pitch - 1.0) < 0.001 or x.size() < 2:
		return x
	var out := PackedVector2Array()
	out.resize(int((x.size() - 1) / pitch))
	for i in out.size():
		var f := i * pitch
		var k := int(f)
		out[i] = x[k].lerp(x[mini(k + 1, x.size() - 1)], f - k)
	return out


static func _gain(x: PackedVector2Array, g: float) -> PackedVector2Array:
	if g != 1.0:
		for i in x.size():
			x[i] *= g
	return x
