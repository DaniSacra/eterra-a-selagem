extends SceneTree
## The game's music (E4-06, C15-03): composed here, note by note, and rendered by our own synthesis, so the licence
## is the project's (D-12b). Nothing sampled, nothing taken from another game.
##   ~/tools/godot/godot --headless --path . -s tools/make_music.gd [-- psalms victory] [--work=dir]
## T5: the title, the rooms and Morvath are recorded music now (Kevin MacLeod, CC BY 4.0, tools/make_music_loops.sh);
## the old synthesised catacombs and morvath are still here, rendered only when asked by name, as the pieces
## "Catacumbas (original)" and "Morvath (original)" (audio/music/classic_catacombs_*.ogg, classic_morvath_*.ogg; the
## player picks them in the Músicas screen, MusicCatalog; the default from the PO's T5 review to MUS-1).
## MUS-1 (the PO, 2026-11-18: "músicas mais animadas, dinâmicas"): the fight music, also rendered only by name and the
## default since (MusicCatalog.DEFAULT): blade_march, deep_drums, iron_pulse (walk and fight) and morvath_battle (a
## layer per phase), levelled by loudness (_publish_levelled). Each takes 1.5 to 3 min; run them in parallel.
## Needs ffmpeg with libvorbis on the PATH. The .wav of each layer stays in the work folder (default
## ~/tools/e4/music); only the .ogg goes in audio/music/ (Music, scripts/music.gd, plays them). Deterministic.
##
## What is in it (D minor, the light of Elun answering in major):
## - catacombs (80 BPM, 32 bars, 96 s loop): layer 1 the walk (drone, a choir, a harp, a bell and a flute singing a
##   modal tune), layer 2 the fight over it (frame drums, low strings in 3+3+2, brass swells).
## - morvath (120 BPM, 32 bars, 64 s loop), one layer per phase added on top: 1 ostinato and taiko, 2 the ritual's
##   chant and a low bell, 3 the curse's tremolo strings and harp, 4 the last breath's brass theme and full drums.
## - psalm_sentinel, psalm_shelter, psalm_shepherd, psalm_rock: 12 to 16 s, major, each with its own colour.
## - victory: the minor turning to major (bVI, bVII, I), about 11 s.
## - blade_march (144 BPM, 40 bars, 66.7 s; D minor to D major), deep_drums (150 BPM, 40 bars, 64 s; E dorian to E
##   major), iron_pulse (138 BPM, 36 bars, 62.6 s; A harmonic minor to A major), morvath_battle (150 BPM, 40 bars,
##   64 s; C harmonic minor to C major): see each function.

const RATE := 44100
const OUT := "res://audio/music/"
const TAB := 2048
const MASK := TAB - 1
## The loudest sum of a track's layers before the game's own music gain (Music.MUSIC_DB): -4.4 dBFS.
const PEAK := 0.6
const OGG_QUALITY := "3"
## MUS-1: the music must fit 18 MB in the package (the imported .oggvorbisstr, about 6% over the .ogg) with the new
## pieces (tests/test_music.gd checks the .ogg under 18 MiB): ours of before, the Psalms and the victory go at
## quality 1 (about 65 kbps, encoded from their .wav), the new ones at 2 (about 85 kbps).
const QUALITY := {&"classic_catacombs": "1", &"classic_morvath": "1", &"blade_march": "2", &"deep_drums": "2",
	&"iron_pulse": "2", &"morvath_battle": "2", &"psalm_sentinel": "1", &"psalm_shelter": "1", &"psalm_shepherd": "1", &"psalm_rock": "1",
	&"victory": "1"}
## MUS-1: the new pieces are levelled by loudness like the recorded ones (docs/design/t5_audio.md): the walk and the
## walk with the fight (LUFS), Morvath phase by phase; the ceiling in dBFS on the samples (the true peak lands a little
## over it). Morvath's four layers together, at the game's music gain (about +1 dB), must stay 1.5 dB under the
## Master's limiter (test_music.gd, test_music_sits_under_the_blows), hence its lower ceiling.
const ROOMS_LUFS := [-21.8, -20.0]
const ROOMS_CEILING := -2.0
const MORVATH_LUFS := [-22.6, -21.4, -20.4, -19.4]
const MORVATH_CEILING := -5.2

var _l := PackedFloat32Array()
var _r := PackedFloat32Array()
var _s := PackedFloat32Array()
var _n := 0
var _loop := true
var _bpm := 80.0
var _rng := RandomNumberGenerator.new()
var _tables: Dictionary = {}
var _sin := PackedFloat32Array()
var _work := ""


func _init() -> void:
	var asked: Array[String] = []
	_work = OS.get_environment("HOME") + "/tools/e4/music"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--work="):
			_work = a.substr(7)
		else:
			asked.append(a)
	if asked.is_empty():
		asked = ["psalms", "victory"]
	DirAccess.make_dir_recursive_absolute(_work)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_sin.resize(TAB)
	for i in TAB:
		_sin[i] = sin(TAU * i / TAB)
	for piece in asked:
		var t := Time.get_ticks_msec()
		match piece:
			"catacombs":
				_publish(&"classic_catacombs", _catacombs())
			"morvath":
				_publish(&"classic_morvath", _morvath())
			"psalms":
				for id: StringName in [&"psalm_sentinel", &"psalm_shelter", &"psalm_shepherd", &"psalm_rock"]:
					_publish(id, [call("_" + String(id))])
			"victory":
				_publish(&"victory", [_victory()])
			"blade_march":
				_publish_levelled(&"blade_march", _blade_march(), ROOMS_LUFS, ROOMS_CEILING)
			"deep_drums":
				_publish_levelled(&"deep_drums", _deep_drums(), ROOMS_LUFS, ROOMS_CEILING)
			"iron_pulse":
				_publish_levelled(&"iron_pulse", _iron_pulse(), ROOMS_LUFS, ROOMS_CEILING)
			"morvath_battle":
				_publish_levelled(&"morvath_battle", _morvath_battle(), MORVATH_LUFS, MORVATH_CEILING)
		print("%s: %.1f s to render" % [piece, (Time.get_ticks_msec() - t) / 1000.0])
	quit()


# ---------------------------------------------------------------- the pieces

const DM := [62, 65, 69]
const BB := [62, 65, 70]
const CM := [60, 64, 67]
const GM := [62, 67, 70]
const FM := [60, 65, 69]
const AM := [61, 64, 69]
const EB := [63, 67, 70]


func _catacombs() -> Array:
	_bpm = 80.0
	var bars := 32
	var chords := [DM, BB, CM, DM, GM, BB, FM, AM]
	var roots := [38, 46, 48, 38, 43, 46, 41, 45]
	var seconds := bars * 4 * 60.0 / _bpm
	# layer 1, the walk
	_begin(seconds, 11, true)
	for p in 4:
		_voice(p * 32.0, 32.0, 50, 0.035, 0.0, 0.25, _harm_table("drone", [1.0, 0.35, 0.12, 0.05]), {"attack": 5.0, "release": 5.0})
		_voice(p * 32.0, 32.0, 57, 0.02, 0.1, 0.25, _harm_table("drone", [1.0, 0.35, 0.12, 0.05]), {"attack": 6.0, "release": 5.0})
	for bar in bars:
		var p := bar / 8
		var c: Array = chords[bar % 8]
		var vowel := "oo" if p < 2 else "ah"
		for i in c.size():
			_voice(bar * 4.0, 4.0, c[i] - 12 * int(i == 0 and p == 3), 0.05, -0.5 + i * 0.5, 0.6,
				_vowel_table(vowel, c[i]), {"attack": 1.0, "release": 1.6, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
		if p >= 1:
			var arp := [c[0] - 12, c[1] - 12, c[2] - 12, c[0], c[1], c[2], c[1], c[0]]
			var step := 1.0 if p == 1 else 0.5
			var k := 0
			while k * step < 4.0:
				_harp(bar * 4.0 + k * step, arp[(k * int(step * 2.0)) % arp.size()], 0.10 if k % 2 == 0 else 0.07, 0.35, 0.4)
				k += 1
	var tune := _catacomb_tune()
	for e: Array in tune:
		_bell(32.0 + e[0], e[2], 0.11, 0.25, 0.5)
		_flute(96.0 + e[0], e[1], e[2] - 12, 0.08, -0.15, 0.45)
	for e: Array in _catacomb_answer():
		_flute(64.0 + e[0], e[1], e[2], 0.07, 0.2, 0.45)
	var calm := _finish(0.32)
	# layer 2, the fight
	_begin(seconds, 12, true)
	for bar in bars:
		var p := bar / 8
		var r: int = roots[bar % 8]
		var pattern := [0, 0, 12, 0, 0, 12, 7, 12]
		for k in 8:
			var accent := 1.0 if k in [0, 3, 6] else 0.65
			_voice(bar * 4.0 + k * 0.5, 0.42, r + 12 + pattern[k] - 12 * int(r > 44), 0.11 * accent, -0.2, 0.25,
				_saw_table(r, 1.1, 5000.0), {"attack": 0.01, "release": 0.12, "decay": 7.0, "sustain": 0.3, "detune": [-5.0, 5.0]})
		_taiko(bar * 4.0, 1.0, 0.0)
		if p >= 1:
			_taiko(bar * 4.0 + 2.5, 0.65, -0.2)
			_frame(bar * 4.0 + 1.0, 0.55, 0.3)
			_frame(bar * 4.0 + 3.0, 0.7, -0.3)
			_frame(bar * 4.0 + 3.5, 0.45, 0.3)
			for k in 8:
				_shaker(bar * 4.0 + k * 0.5, 0.5 if k % 2 == 1 else 0.3, 0.4)
		if bar % 8 == 7 and p >= 1:
			for k in 8:
				_frame(bar * 4.0 + 2.0 + k * 0.25, 0.25 + k * 0.07, -0.4 + k * 0.1)
		if (bar % 8 == 3 or bar % 8 == 7) and p % 2 == 1:
			var c: Array = chords[bar % 8]
			for m: int in [c[0] - 12, c[2] - 12]:
				_voice(bar * 4.0, 4.0, m, 0.05, 0.15, 0.5, _saw_table(m, 1.7, 3000.0),
					{"attack": 1.4, "release": 1.0, "bright": _saw_table(m, 0.9, 6000.0), "detune": [-6.0, 6.0], "vib": 0.002})
	var fight := _finish(0.25)
	return [calm, fight]


## The walk's tune (8 bars, beats from the phrase's start): [beat, beats, midi].
func _catacomb_tune() -> Array:
	return [[0, 2, 69], [2, 1, 74], [3, 1, 72], [4, 1.5, 74], [5.5, 0.5, 72], [6, 2, 70], [8, 1, 72], [9, 1, 76],
		[10, 1.5, 79], [11.5, 0.5, 77], [12, 1, 76], [13, 3, 74], [16, 1, 70], [17, 1, 74], [18, 2, 79],
		[20, 1.5, 77], [21.5, 0.5, 74], [22, 1, 72], [23, 1, 70], [24, 1, 69], [25, 1, 72], [26, 2, 77],
		[28, 2, 76], [30, 1, 73], [31, 1, 69]]


## Its answer, lower and slower (phrase 3).
func _catacomb_answer() -> Array:
	return [[0, 3, 62], [3, 1, 65], [4, 2, 70], [6, 2, 69], [8, 3, 67], [11, 1, 64], [12, 4, 65],
		[16, 2, 67], [18, 2, 70], [20, 3, 69], [23, 1, 67], [24, 2, 65], [26, 2, 69], [28, 4, 64]]


func _morvath() -> Array:
	_bpm = 120.0
	var bars := 32
	var chords := [DM, DM, BB, AM, DM, GM, EB, AM]
	var roots := [38, 38, 46, 45, 38, 43, 39, 45]
	var seconds := bars * 4 * 60.0 / _bpm
	var layers := []
	# 1 O Despertar: the ostinato, taiko on 1 and 3, a low choir
	_begin(seconds, 21, true)
	for bar in bars:
		var r: int = roots[bar % 8]
		var c: Array = chords[bar % 8]
		var pattern := [0, 0, 12, 0, 12, 0, 7, 12]
		for k in 8:
			var accent := 1.0 if k in [0, 3, 6] else 0.6
			for octave: int in [0, 12]:
				_voice(bar * 4.0 + k * 0.5, 0.4, r + pattern[k] + octave, (0.07 if octave == 0 else 0.06) * accent, -0.15 + octave * 0.02, 0.2,
					_saw_table(r + octave, 1.1, 5000.0), {"attack": 0.008, "release": 0.1, "decay": 8.0, "sustain": 0.3, "detune": [-6.0, 6.0]})
		_taiko(bar * 4.0, 1.0, 0.0)
		_taiko(bar * 4.0 + 2.0, 0.7, 0.1)
		if bar % 8 == 0:
			_boom(bar * 4.0, 0.9)
		for i in c.size():
			_voice(bar * 4.0, 4.0, c[i] - 12, 0.045, -0.4 + i * 0.4, 0.5, _vowel_table("oo", c[i] - 12),
				{"attack": 0.5, "release": 0.8, "detune": [-8.0, 0.0, 7.0], "vib": 0.003})
	layers.append(_finish(0.25))
	# 2 O Ritual dos Mortos: the chant in octaves, frame drums off the beat, a low bell every two bars
	_begin(seconds, 22, true)
	var chant := [[62, 64], [65, 64], [65, 62], [61, 64], [62, 65], [67, 62], [63, 67], [64, 61]]
	for bar in bars:
		var two: Array = chant[bar % 8]
		for h in 2:
			for octave: int in [-12, -24]:
				_voice(bar * 4.0 + h * 2.0, 2.0, two[h] + octave, 0.06 if octave == -12 else 0.045, 0.1, 0.55,
					_vowel_table("ah", two[h] + octave), {"attack": 0.25, "release": 0.4, "detune": [-9.0, 0.0, 8.0], "vib": 0.004})
		for k in 4:
			_frame(bar * 4.0 + k + 0.5, 0.45, 0.35 if k % 2 == 0 else -0.35)
		_frame(bar * 4.0 + 3.75, 0.35, 0.0)
		if bar % 2 == 0:
			_bell(bar * 4.0, 50 if bar % 8 != 6 else 51, 0.13, -0.1, 0.6)
	layers.append(_finish(0.3, 2.4))
	# 3 A Maldição dos Condenados: tremolo strings high, a harp falling, shaker in sixteenths
	_begin(seconds, 23, true)
	for bar in bars:
		var c: Array = chords[bar % 8]
		for m: int in [c[1] + 12, c[2] + 12]:
			_voice(bar * 4.0, 4.0, m, 0.035, 0.4 if m == c[1] + 12 else -0.4, 0.45, _saw_table(m, 1.3, 7000.0),
				{"attack": 0.3, "release": 0.4, "detune": [-6.0, 6.0], "trem": 12.0, "trem_depth": 0.6})
		var fall := [c[2] + 12, c[1] + 12, c[0] + 12, c[2], c[1], c[0], c[2], c[1]]
		for k in 8:
			_harp(bar * 4.0 + k * 0.5, fall[k], 0.075, 0.25 - k * 0.06, 0.4)
		for k in 16:
			_shaker(bar * 4.0 + k * 0.25, 0.45 if k % 4 == 2 else 0.25, -0.3)
	layers.append(_finish(0.3, 3.2))
	# 4 O Último Suspiro: the brass theme over toms in eighths, a high choir, a swell into each phrase
	_begin(seconds, 24, true)
	var theme := [[0, 1, 74], [1, 1, 69], [2, 1, 74], [3, 1, 77], [4, 2, 76], [6, 1, 74], [7, 1, 72],
		[8, 1.5, 74], [9.5, 0.5, 77], [10, 2, 82], [12, 3, 76], [15, 1, 73], [16, 1, 74], [17, 1, 77], [18, 2, 81],
		[20, 1.5, 79], [21.5, 0.5, 77], [22, 2, 74], [24, 1, 75], [25, 1, 79], [26, 2, 82], [28, 2, 81],
		[30, 1, 76], [31, 1, 73]]
	for p in 4:
		for e: Array in theme:
			for octave: int in [0, -12]:
				var m: int = e[2] - 12 + octave
				_voice(p * 32.0 + e[0], e[1] * 0.95, m, 0.07 if octave == 0 else 0.05, 0.05, 0.4, _saw_table(m, 1.8, 3000.0),
					{"attack": 0.05, "release": 0.25, "bright": _saw_table(m, 0.85, 6500.0), "detune": [-5.0, 5.0], "vib": 0.003})
		_swell(p * 32.0 + 28.0, 4.0, 0.05)
	for bar in bars:
		var c: Array = chords[bar % 8]
		for k in 8:
			_frame(bar * 4.0 + k * 0.5, 0.65 if k % 2 == 0 else 0.4, -0.25 if k % 2 == 0 else 0.25, 0.8)
		_taiko(bar * 4.0 + 1.5, 0.6, -0.1)
		_taiko(bar * 4.0 + 3.5, 0.6, 0.1)
		if bar % 8 == 7:
			for k in 8:
				_taiko(bar * 4.0 + 2.0 + k * 0.25, 0.35 + k * 0.06, -0.3 + k * 0.08)
		for i in c.size():
			_voice(bar * 4.0, 4.0, c[i] + 12, 0.025, -0.5 + i * 0.5, 0.6, _vowel_table("ah", c[i] + 12),
				{"attack": 0.4, "release": 0.6, "detune": [-8.0, 0.0, 7.0], "vib": 0.005})
	layers.append(_finish(0.3))
	return layers


## The watch that does not sleep (Sl 121): bells rising to the hills, a horn's fifths, a soft heartbeat, D major.
func _psalm_sentinel() -> Array:
	_bpm = 72.0
	_begin(_secs(14.0) + 4.0, 31, false)
	var chords := [[0, 4, [62, 66, 69]], [4, 2, [62, 67, 71]], [6, 2, [61, 64, 69]], [8, 6, [62, 66, 69, 74]]]
	for e: Array in chords:
		for m: int in e[2]:
			_voice(e[0], e[1], m - 12, 0.05, randf_pan(), 0.6, _vowel_table("ah", m - 12),
				{"attack": 0.9, "release": 2.2, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
	for m: int in [50, 57]:
		_voice(0.0, 8.0, m, 0.06, -0.2, 0.4, _saw_table(m, 1.8, 2500.0), {"attack": 1.5, "release": 1.5, "detune": [-5.0, 5.0], "vib": 0.002})
		_voice(8.0, 6.0, m, 0.06, -0.2, 0.4, _saw_table(m, 1.8, 2500.0), {"attack": 0.6, "release": 2.5, "detune": [-5.0, 5.0], "vib": 0.002})
	for b in 8:
		_taiko(float(b), 0.32 if b % 2 == 0 else 0.22, 0.0)
	for e: Array in [[0, 69], [1, 74], [2, 76], [3, 78], [4, 81], [6, 79], [7, 76], [8, 78], [9, 81], [10, 86]]:
		_bell(e[0], e[1], 0.12, 0.3, 0.55)
	return _finish(0.4)


## Shelter under his wings (Sl 91, the Refúgio): a warm choir, a harp rocking, a flute coming down, F major.
func _psalm_shelter() -> Array:
	_bpm = 66.0
	_begin(_secs(14.0) + 4.0, 32, false)
	for e: Array in [[0, 4, [65, 69, 72]], [4, 2, [65, 70, 74]], [6, 2, [64, 67, 72]], [8, 6, [65, 69, 72, 77]]]:
		for m: int in e[2]:
			_voice(e[0], e[1], m - 12, 0.055, randf_pan(), 0.6, _vowel_table("oo", m - 12),
				{"attack": 1.0, "release": 2.4, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
	var harp := [53, 60, 65, 69, 72, 69, 65, 60]
	for k in 24:
		_harp(k * 0.5, harp[k % 8] + (2 if k >= 8 and k < 12 else 0) - (1 if k >= 12 and k < 16 else 0), 0.08, -0.3, 0.45)
	for e: Array in [[0, 2, 84], [2, 1, 81], [3, 1, 82], [4, 1.5, 84], [5.5, 0.5, 86], [6, 2, 84], [8, 1, 81],
			[9, 1, 79], [10, 4, 77]]:
		_flute(e[0], e[1], e[2] - 12, 0.08, 0.2, 0.5)
	_bell(10.0, 77, 0.06, 0.1, 0.6)
	return _finish(0.42)


## The shepherd (Sl 23): a pastoral drone, a plucked 6/8, a flute by still waters, G major.
func _psalm_shepherd() -> Array:
	_bpm = 150.0  # eighth notes of a 6/8 at 50 the dotted quarter
	_begin(_secs(30.0) + 4.0, 33, false)
	for m: int in [43, 50]:
		_voice(0.0, 30.0, m, 0.06, -0.1, 0.3, _harm_table("drone", [1.0, 0.5, 0.3, 0.15, 0.08]), {"attack": 1.5, "release": 3.0, "vib": 0.002})
	var bars := [[55, 59, 62], [55, 60, 64], [54, 57, 62], [55, 59, 62], [52, 55, 59], [55, 60, 64], [54, 57, 62], [55, 59, 62, 67]]
	for b in 5:
		var c: Array = bars[b]
		for k in 6:
			_harp(b * 6.0 + k, c[[0, 1, 2, 1, 2, 1][k]] + (12 if k == 2 else 0), 0.08 if k % 3 == 0 else 0.055, 0.3, 0.4)
	for e: Array in [[0, 2, 74], [2, 1, 71], [3, 2, 67], [5, 1, 69], [6, 3, 71], [9, 2, 69], [11, 1, 67],
			[12, 2, 64], [14, 1, 62], [15, 2, 67], [17, 1, 69], [18, 2, 71], [20, 1, 74], [21, 2, 76], [23, 1, 74], [24, 6, 79]]:
		_flute(e[0], e[1], e[2], 0.085, -0.1, 0.45)
	for m: int in [67, 71, 74]:
		_voice(24.0, 6.0, m - 12, 0.04, randf_pan(), 0.6, _vowel_table("oo", m - 12), {"attack": 1.0, "release": 2.5, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
	return _finish(0.38)


## The rock and the fortress (Sl 18): firm drums, a low choir, brass in open fifths, C major.
func _psalm_rock() -> Array:
	_bpm = 76.0
	_begin(_secs(16.0) + 4.0, 34, false)
	for b in 12:
		_taiko(float(b), 0.75 if b % 2 == 0 else 0.5, 0.0)
	_boom(0.0, 0.8)
	_boom(8.0, 0.8)
	for e: Array in [[0, 4, [48, 55, 60, 64]], [4, 2, [48, 53, 57, 60]], [6, 2, [43, 50, 55, 59]], [8, 8, [48, 55, 60, 64]]]:
		for m: int in e[2]:
			_voice(e[0], e[1], m, 0.045, randf_pan(), 0.5, _vowel_table("oh", m), {"attack": 0.5, "release": 2.5, "detune": [-8.0, 0.0, 7.0], "vib": 0.003})
	for e: Array in [[0, 2, 60], [2, 1, 62], [3, 1, 64], [4, 2, 65], [6, 1, 64], [7, 1, 62], [8, 2, 64], [10, 2, 67], [12, 4, 72]]:
		for fifth: int in [0, 7]:
			var m: int = e[2] - 12 + fifth
			_voice(e[0], e[1] * 0.95, m, 0.06, 0.1, 0.4, _saw_table(m, 1.7, 3000.0),
				{"attack": 0.06, "release": 0.5 if e[0] < 12 else 2.5, "bright": _saw_table(m, 0.9, 6000.0), "detune": [-5.0, 5.0], "vib": 0.002})
	_bell(12.0, 72, 0.09, 0.0, 0.6)
	return _finish(0.36)


## The victory: Bb, C, then D major, a fanfare, bells on the last chord.
func _victory() -> Array:
	_bpm = 84.0
	_begin(_secs(12.0) + 4.0, 41, false)
	for k in 8:
		_frame(k * 0.25, 0.25 + k * 0.08, -0.3 + k * 0.08)
	_boom(2.0, 1.0)
	_taiko(2.0, 1.0, 0.0)
	_taiko(8.0, 0.9, 0.0)
	_boom(8.0, 0.8)
	for e: Array in [[0, 1, [58, 62, 65]], [1, 1, [60, 64, 67]], [2, 6, [62, 66, 69]], [8, 4, [62, 66, 69, 74]]]:
		for m: int in e[2]:
			_voice(e[0], e[1], m - 12, 0.05, randf_pan(), 0.55, _vowel_table("ah", m - 12),
				{"attack": 0.3, "release": 2.8 if e[0] >= 8 else 0.4, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
	for e: Array in [[2, 1, 62], [3, 0.5, 69], [3.5, 0.5, 74], [4, 2, 78], [6, 1, 76], [7, 1, 73], [8, 4, 74]]:
		for third: int in [0, -12]:
			var m: int = e[2] - 12 + third
			_voice(e[0], e[1] * 0.95, m, 0.07, 0.1, 0.4, _saw_table(m, 1.7, 3000.0),
				{"attack": 0.04, "release": 0.3 if e[0] < 8 else 2.8, "bright": _saw_table(m, 0.85, 6500.0), "detune": [-5.0, 5.0], "vib": 0.003})
	for m: int in [86, 81, 78, 74]:
		_bell(8.0 + (86 - m) * 0.04, m, 0.09, 0.3 - (86 - m) * 0.05, 0.6)
	return _finish(0.4)



# ---------------------------------------------------------------- MUS-1: the fight music (2026-11-18)
# The PO: "músicas mais animadas, dinâmicas" for a hack and slash. Three pieces for the rooms (walk and fight, the
# fight layer over the walk) and one for Morvath (a layer per phase), 138 to 150 BPM, drums that push, a riff, a
# heroic tune with a counter line, progressions that climb and cadences that resolve upwards into major (the light of
# Elun at the peaks). Adventure, not horror. Levelled by loudness (_publish_levelled), not by peak.

const PC := {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7,
	"G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}


## A chord by name ("Dm", "Bb", "F#m", "C/E", "Bdim", "Asus"): bass (36 to 47), root (pitch class), tones (a close
## triad between 57 and 68), third and fifth (semitones over the root).
func _chord(name: String) -> Dictionary:
	var main := name.get_slice("/", 0)
	var over := name.get_slice("/", 1) if name.contains("/") else ""
	var n := 2 if main.length() > 1 and (main[1] == "#" or main[1] == "b") else 1
	var root: int = PC[main.substr(0, n)]
	var q := main.substr(n)
	var third := 3 if q == "m" or q == "dim" else (5 if q == "sus" else 4)
	var fifth := 6 if q == "dim" else 7
	var tones: Array[int] = []
	for iv: int in [0, third, fifth]:
		tones.append(57 + posmod(root + iv - 57, 12))
	tones.sort()
	var b: int = PC[over] if over != "" else root
	return {"bass": 36 + posmod(b - 36, 12), "root": root, "tones": tones, "third": third, "fifth": fifth}


func _chords(names: Array) -> Array:
	var out := []
	for nm: String in names:
		out.append(_chord(nm))
	return out


## The lowest tone of the chord above m.
func _above(c: Dictionary, m: int) -> int:
	var best := m + 12
	for t: int in c.tones:
		for oct: int in [-24, -12, 0, 12, 24]:
			if t + oct > m and t + oct < best:
				best = t + oct
	return best


## The lowest note of pitch class pc at or above m.
func _pc_from(pc: int, m: int) -> int:
	return m + posmod(pc - m, 12)


## An inner line through the chords of bars bar0.. (n bars), each note the chord tone nearest the last (between lo and
## hi), moving every `beats`: the counter voice under a tune.
func _counter(chords: Array, bar0: int, n: int, lo: int, hi: int, beats: float = 2.0) -> Array:
	var out := []
	var prev := (lo + hi) / 2
	var per := int(4.0 / beats)
	for k in n:
		var c: Dictionary = chords[bar0 + k]
		for h in per:
			var best := prev
			var bd := 999
			for t: int in c.tones:
				for oct: int in [-24, -12, 0, 12, 24]:
					var m := t + oct
					if m < lo or m > hi:
						continue
					var d := absi(m - prev) + (4 if m == prev and h > 0 else 0)
					if d < bd:
						bd = d
						best = m
			out.append([k * 4.0 + h * beats, beats, best])
			prev = best
	return out


## A tune: [beat, beats, midi] from a start beat, on an instrument, transposed.
func _line(start: float, notes: Array, kind: String, transpose: int, amp: float, pan: float) -> void:
	for e: Array in notes:
		var b: float = start + float(e[0])
		var d: float = e[1]
		var m: int = int(e[2]) + transpose
		match kind:
			"strings":
				_voice(b, d * 0.97, m, amp, pan, 0.35, _saw_table(m, 1.25, 7000.0),
					{"attack": 0.05, "release": 0.18, "vib": 0.005, "detune": [-8.0, 0.0, 8.0]})
			"viola":
				_voice(b, d * 0.97, m, amp, pan, 0.35, _saw_table(m, 1.4, 5000.0),
					{"attack": 0.12, "release": 0.3, "vib": 0.004, "detune": [-7.0, 7.0]})
			"brass":
				_voice(b, d * 0.95, m, amp, pan, 0.35, _saw_table(m, 1.9, 2500.0),
					{"attack": 0.04, "release": 0.2, "bright": _saw_table(m, 0.95, 5500.0), "detune": [-5.0, 5.0], "vib": 0.003})
			"fiddle":
				if d >= 1.0 and _rng.randf() < 0.35:
					_voice(b - 0.12, 0.1, m + 2, amp * 0.7, pan, 0.3, _saw_table(m + 2, 1.15, 9000.0),
						{"attack": 0.006, "release": 0.03, "detune": [-3.0, 3.0]})
				_voice(b, d * 0.92, m, amp, pan, 0.3, _saw_table(m, 1.15, 9000.0),
					{"attack": 0.015, "release": 0.1, "vib": 0.007, "detune": [-4.0, 4.0]})
			"flute":
				_flute(b, d * 0.95, m, amp, pan, 0.45)
			"choir":
				_voice(b, d, m, amp, pan, 0.55, _vowel_table("ah", m), {"attack": 0.2, "release": 0.5, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})


## Long chord tones (strings, or a choir's vowel) over bars bar0.. for n bars, offset in octaves.
func _pads(chords: Array, bar0: int, n: int, kind: String, octave: int, amp: float) -> void:
	for k in n:
		var c: Dictionary = chords[bar0 + k]
		var i := 0
		for t: int in c.tones:
			var m := t + 12 * octave
			var pan := -0.5 + i * 0.5
			if kind == "strings":
				_voice((bar0 + k) * 4.0, 4.0, m, amp, pan, 0.5, _saw_table(m, 1.5, 4500.0),
					{"attack": 0.4, "release": 0.6, "vib": 0.004, "detune": [-9.0, 0.0, 9.0]})
			else:
				_voice((bar0 + k) * 4.0, 4.0, m, amp, pan, 0.6, _vowel_table(kind, m),
					{"attack": 0.4, "release": 0.7, "detune": [-8.0, 0.0, 7.0], "vib": 0.004})
			i += 1


## A drum pattern of 16 steps a bar ("X" accent, "x" normal, "o" ghost, "." rest) on one of the kit's pieces.
func _hits(bar: int, pat: String, kind: String, vel: float, pan: float = 0.0, arg: float = 0.0) -> void:
	for k in mini(pat.length(), 16):
		var ch := pat[k]
		if ch == ".":
			continue
		var v := vel * (1.0 if ch == "X" else (0.72 if ch == "x" else 0.38))
		v *= _rng.randf_range(0.92, 1.05)
		var b := bar * 4.0 + k * 0.25 + _rng.randf_range(-0.006, 0.006)
		match kind:
			"kick": _kick(b, v)
			"snare": _snare(b, v, pan)
			"hat": _hat(b, v, pan, false)
			"open": _hat(b, v, pan, true)
			"tom": _tom(b, v, pan, arg)
			"taiko": _taiko(b, v, pan)
			"frame": _frame(b, v, pan, arg)
			"clap": _clap(b, v, pan)
			"shaker": _shaker(b, v, pan)


## A tom fill over the last beats of a bar: sixteenths falling from high to low, getting louder.
func _fill(bar: int, from_beat: float, vel: float) -> void:
	var steps := int((4.0 - from_beat) * 4.0)
	for k in steps:
		var x := float(k) / maxf(steps - 1, 1)
		_tom(bar * 4.0 + from_beat + k * 0.25, vel * (0.6 + 0.4 * x), -0.4 + 0.8 * x, lerpf(190.0, 80.0, x))


func _kick(beat: float, vel: float) -> void:
	_drum(beat, vel * 0.42, 0.0, 47.0, 110.0, 32.0, 7.5, 0.35, 70.0, 0.35, 0.6, 0.08)


func _snare(beat: float, vel: float, pan: float) -> void:
	_drum(beat, vel * 0.2, pan, 190.0, 50.0, 40.0, 22.0, 2.2, 17.0, 0.85, 0.4, 0.35)


func _tom(beat: float, vel: float, pan: float, f0: float) -> void:
	var f := f0 if f0 > 0.0 else 110.0
	_drum(beat, vel * 0.3, pan, f, f * 0.7, 22.0, 6.5, 0.45, 40.0, 0.2, 0.8, 0.3)


## A hi-hat: high noise, closed (short) or open (ringing).
func _hat(beat: float, vel: float, pan: float, open: bool) -> void:
	var total := int((0.45 if open else 0.07) * RATE)
	var decay := 9.0 if open else 75.0
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * vel * 0.04
	var gr := sin((pan + 1.0) * PI / 4.0) * vel * 0.04
	var lp := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var n := _rng.randf_range(-1.0, 1.0)
		lp += 0.55 * (n - lp)
		var v := (n - lp) * minf(tt / 0.001, 1.0) * exp(-tt * decay)
		if k > total - 200:
			v *= float(total - k) / 200.0
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * 0.15 * vel * 0.04


## A clap (hands together): three quick bursts and a tail of mid noise.
func _clap(beat: float, vel: float, pan: float) -> void:
	var total := int(0.25 * RATE)
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * vel * 0.09
	var gr := sin((pan + 1.0) * PI / 4.0) * vel * 0.09
	var lp := 0.0
	var lp2 := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var n := _rng.randf_range(-1.0, 1.0)
		lp += 0.45 * (n - lp)
		lp2 += 0.08 * (lp - lp2)
		var e := exp(-fmod(tt, 0.011) * 260.0) if tt < 0.033 else exp(-(tt - 0.033) * 22.0)
		var v := (lp - lp2) * e * minf(tt / 0.0005, 1.0)
		if k > total - 200:
			v *= float(total - k) / 200.0
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * 0.35 * vel * 0.09


## A crash cymbal: wide high noise, ringing out.
func _crash(beat: float, amp: float) -> void:
	var total := int(2.6 * RATE)
	var i0 := int(_secs(beat) * RATE)
	var la := 0.0
	var lb := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var na := _rng.randf_range(-1.0, 1.0)
		var nb := _rng.randf_range(-1.0, 1.0)
		la += 0.6 * (na - la)
		lb += 0.6 * (nb - lb)
		var e := minf(tt / 0.002, 1.0) * exp(-tt * 1.9)
		if k > total - 2000:
			e *= float(total - k) / 2000.0
		var va := (na - la) * e * amp
		var vb := (nb - lb) * e * amp
		_l[j] += va
		_r[j] += vb
		_s[j] += (va + vb) * 0.25


## The bass: a short saw and a sine under it.
func _bass(beat: float, beats: float, m: int, amp: float) -> void:
	_voice(beat, beats, m, amp, 0.0, 0.04, _saw_table(m, 1.0, 1800.0),
		{"attack": 0.004, "release": 0.06, "decay": 5.0, "sustain": 0.5, "detune": [-5.0, 5.0]})
	_voice(beat, beats, m, amp * 0.5, 0.0, 0.0, _harm_table("sine", [1.0]), {"attack": 0.004, "release": 0.06})


## A short bowed note (spiccato strings).
func _spic(beat: float, m: int, amp: float, pan: float) -> void:
	_voice(beat, 0.22, m, amp, pan, 0.25, _saw_table(m, 1.1, 6000.0),
		{"attack": 0.005, "release": 0.07, "decay": 12.0, "sustain": 0.25, "detune": [-6.0, 6.0]})


## A brass stab on the chord: short, bright, accented.
func _stab(beat: float, c: Dictionary, octave: int, amp: float, beats: float = 0.4) -> void:
	var i := 0
	for t: int in c.tones:
		var m := t + 12 * octave
		_voice(beat, beats, m, amp, -0.3 + i * 0.3, 0.35, _saw_table(m, 1.7, 3000.0),
			{"attack": 0.015, "release": 0.12, "bright": _saw_table(m, 0.85, 6500.0), "decay": 4.0, "sustain": 0.6, "detune": [-5.0, 5.0]})
		i += 1


# ---------------------------------------------------------------- MUS-1, the rooms


## "Marcha das Lâminas": orchestral and epic, D minor rising to D major, 144 BPM, 40 bars (66.7 s). Spiccato strings
## in 3+3+2 sixteenths, the tune on violins with a viola counter line, a climbing bass G A Bb C D E F G, the climax in
## D major and the bVI bVII I cadence; the fight adds kick, snare, toms, brass (the tune an octave down and stabs),
## low strings and a choir at the peak.
func _blade_march() -> Array:
	_bpm = 144.0
	var chords := _chords(["Dm", "Dm", "Dm", "Dm",
		"Dm", "Bb", "C", "Dm", "Bb", "C", "Dm", "A",
		"Dm", "Bb", "F", "C", "Gm", "Bb", "C", "A",
		"Gm", "F/A", "Bb", "C", "Dm", "C/E", "F", "G",
		"D", "G", "D", "A", "Bb", "C", "D", "D",
		"Bb", "C", "A", "A"])
	var bars := chords.size()
	var seconds := _secs(bars * 4.0)
	var tune_a := [[0, 1, 62], [1, 0.5, 62], [1.5, 0.5, 65], [2, 2, 69], [4, 1.5, 70], [5.5, 0.5, 69], [6, 1, 67], [7, 1, 65],
		[8, 1, 64], [9, 0.5, 65], [9.5, 0.5, 67], [10, 2, 72], [12, 3, 69], [15, 1, 65],
		[16, 1, 70], [17, 0.5, 70], [17.5, 0.5, 72], [18, 2, 74], [20, 1.5, 76], [21.5, 0.5, 74], [22, 1, 72], [23, 1, 67],
		[24, 1, 69], [25, 1, 72], [26, 1, 74], [27, 1, 77], [28, 3, 76], [31, 1, 73]]
	var tune_a2 := [[0, 1, 62], [1, 0.5, 62], [1.5, 0.5, 65], [2, 2, 69], [4, 1.5, 70], [5.5, 0.5, 69], [6, 1, 67], [7, 1, 65],
		[8, 1, 65], [9, 0.5, 67], [9.5, 0.5, 69], [10, 2, 72], [12, 3, 67], [15, 1, 64],
		[16, 1, 70], [17, 0.5, 70], [17.5, 0.5, 72], [18, 2, 74], [20, 1.5, 77], [21.5, 0.5, 74], [22, 1, 70], [23, 1, 72],
		[24, 1, 72], [25, 1, 76], [26, 1, 79], [27, 1, 76], [28, 3, 76], [31, 1, 73]]
	var tune_c := [[0, 2, 62], [2, 1, 66], [3, 1, 69], [4, 3, 71], [7, 1, 69], [8, 1, 66], [9, 1, 69], [10, 2, 74],
		[12, 3, 73], [15, 1, 69], [16, 1.5, 70], [17.5, 0.5, 72], [18, 2, 74], [20, 1.5, 72], [21.5, 0.5, 74], [22, 2, 76],
		[24, 4, 78], [28, 2, 78], [30, 1, 76], [31, 1, 74]]
	var tune_t := [[0, 2, 70], [2, 2, 72], [4, 2, 72], [6, 2, 76], [8, 4, 73], [12, 2, 76], [14, 1, 73], [15, 1, 69]]
	# the climb: over each bass note its chord in a dotted rising figure, every bar higher than the last
	var climb := []
	var prev := 64
	for k in 8:
		var c: Dictionary = chords[20 + k]
		var x0 := _pc_from(posmod(c.bass, 12), prev + 1)
		var x1 := _above(c, x0)
		climb.append_array([[k * 4.0, 1.5, x0], [k * 4.0 + 1.5, 0.5, x1], [k * 4.0 + 2.0, 2.0, _above(c, x1)]])
		prev = x0
	# layer 1, the walk
	_begin(seconds, 51, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var peak := 1.15 if bar >= 28 and bar < 36 else 1.0
		var r: int = c.bass + 12
		var o := r + 12
		var f: int = r + int(c.fifth)
		var t: int = r + int(c.third) + 12
		var riff := [r, r, o, r, r, o, f, o, r, r, o, r, f, o, t, o]
		for k in 16:
			var acc := 1.0 if k in [0, 3, 6, 8, 11, 14] else 0.55
			_spic(b + k * 0.25, riff[k], 0.05 * acc * peak, -0.3 + 0.15 * (k % 2))
		for k in 8:
			_bass(b + k * 0.5, 0.42, c.bass, 0.075 if k % 2 == 0 else 0.055)
		_hits(bar, "x.o.x.o.x.o.x.oo" if bar >= 4 else "x...x...x...x.o.", "hat", 0.8, 0.35)
		_hits(bar, "....x.......x..." if bar >= 4 else "............x...", "frame", 0.75, 0.0, 0.7)
	_line(16.0, tune_a, "strings", 0, 0.1, 0.1)
	_line(48.0, tune_a2, "strings", 12, 0.09, 0.1)
	_line(48.0, _counter(chords, 12, 8, 60, 72), "viola", 0, 0.05, -0.35)
	_line(80.0, climb, "strings", 0, 0.09, 0.1)
	_pads(chords, 20, 8, "strings", 0, 0.025)
	_line(112.0, tune_c, "strings", 12, 0.1, 0.1)
	_line(112.0, _counter(chords, 28, 8, 62, 74), "viola", 0, 0.05, -0.35)
	_pads(chords, 28, 8, "oo", 0, 0.03)
	_line(144.0, tune_t, "strings", 0, 0.09, 0.1)
	var walk := _finish(0.22)
	# layer 2, the fight
	_begin(seconds, 52, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var sec := 0 if bar < 4 else (1 if bar < 20 else (2 if bar < 28 else (3 if bar < 36 else 4)))
		match sec:
			0:
				_hits(bar, "X.......X.......", "kick", 0.9)
				_hits(bar, "X.......x.......", "taiko", 0.8)
				if bar == 3:
					for k in 16:
						_snare(b + k * 0.25, 0.25 + 0.6 * k / 15.0, 0.0)
			1, 4:
				_hits(bar, "X..x..x.X..x..x.", "kick", 0.9)
				_hits(bar, "....X.......X..o", "snare", 0.85, 0.05)
			2:
				_hits(bar, "X..x..x.X..x..x.", "kick", 0.9)
				_hits(bar, "....X..o....X.oo", "snare", 0.85, 0.05)
				_hits(bar, "X.......X.......", "taiko", 0.6)
			3:
				_hits(bar, "X.x.X.x.X.x.X.xx", "kick", 0.85)
				_hits(bar, "....X..o....X..o", "snare", 0.95, 0.05)
				_hits(bar, "X...X...X...X...", "taiko", 0.55)
		if sec > 0:
			_hits(bar, "..x...x...x...xx", "tom", 0.45, 0.3, 140.0)
		if bar in [11, 19, 27, 35]:
			_fill(bar, 2.0, 0.9)
		if bar in [0, 4, 12, 20, 28, 36]:
			_crash(b, 0.035)
			_boom(b, 0.8)
		if bar in [3, 19, 27]:
			_swell(b, 4.0, 0.04)
		# low strings: the root in octaves, held and bowed again on the half bar
		for h in 2:
			for oc: int in [12, 24]:
				var m: int = c.bass + oc
				_voice(b + h * 2.0, 1.9, m, 0.03, 0.2, 0.3, _saw_table(m, 1.3, 4000.0), {"attack": 0.02, "release": 0.15, "detune": [-6.0, 6.0]})
		if sec == 0 or sec == 4:
			_stab(b, c, 0, 0.04)
			_stab(b + 1.5, c, 0, 0.032)
			_stab(b + 3.0, c, 0, 0.032, 0.3)
	_line(16.0, tune_a, "brass", -12, 0.07, -0.1)
	_line(48.0, tune_a2, "brass", 0, 0.065, -0.1)
	_line(80.0, climb, "brass", -12, 0.07, -0.1)
	_line(112.0, tune_c, "brass", 0, 0.075, -0.1)
	_line(112.0, tune_c, "brass", -12, 0.05, 0.15)
	_pads(chords, 28, 8, "ah", 1, 0.022)
	_line(144.0, tune_t, "brass", -12, 0.06, -0.1)
	var fight := _finish(0.18)
	return [walk, fight]


## "Tambores do Fundo": folk and tribal, E dorian, 150 BPM, 40 bars (64 s). A drone and a plucked riff, frame drums
## in 3+3+2, a fiddle reel with a flute answering; the climb C D E lifts it into E major. The fight adds war toms and a
## taiko, claps, a horn calling in fifths, a chanting choir and low strings driving eighths.
func _deep_drums() -> Array:
	_bpm = 150.0
	var chords := _chords(["Em", "Em", "Em", "D",
		"Em", "D", "Em", "A", "Em", "D", "C", "B",
		"Em", "D", "Em", "A", "Em", "D", "C", "B",
		"C", "D", "Em", "Em", "C", "D", "E", "E",
		"E", "A", "E", "B", "C", "D", "E", "E",
		"C", "D", "B", "B"])
	var bars := chords.size()
	var seconds := _secs(bars * 4.0)
	var reel := [[0, 0.5, 76], [0.5, 0.5, 74], [1, 0.5, 71], [1.5, 0.5, 74], [2, 1, 76], [3, 0.5, 79], [3.5, 0.5, 78],
		[4, 1, 76], [5, 0.5, 74], [5.5, 0.5, 73], [6, 1, 74], [7, 1, 69],
		[8, 0.5, 71], [8.5, 0.5, 74], [9, 0.5, 76], [9.5, 0.5, 79], [10, 1, 81], [11, 0.5, 79], [11.5, 0.5, 76],
		[12, 1.5, 78], [13.5, 0.5, 76], [14, 1, 73], [15, 1, 76],
		[16, 0.5, 79], [16.5, 0.5, 78], [17, 0.5, 76], [17.5, 0.5, 74], [18, 1, 76], [19, 1, 71],
		[20, 0.5, 74], [20.5, 0.5, 76], [21, 0.5, 78], [21.5, 0.5, 81], [22, 1, 78], [23, 1, 74],
		[24, 1, 76], [25, 0.5, 79], [25.5, 0.5, 76], [26, 1, 72], [27, 1, 76],
		[28, 2, 75], [30, 1, 78], [31, 1, 71]]
	var rise := [[0, 1, 72], [1, 1, 76], [2, 2, 79], [4, 1, 74], [5, 1, 78], [6, 2, 81], [8, 1, 76], [9, 1, 79],
		[10, 1, 83], [11, 1, 81], [12, 4, 79], [16, 1, 76], [17, 1, 79], [18, 2, 84], [20, 1, 78], [21, 1, 81],
		[22, 2, 86], [24, 2, 83], [26, 2, 80], [28, 4, 83]]
	var light := [[0, 1.5, 76], [1.5, 0.5, 80], [2, 2, 83], [4, 1.5, 85], [5.5, 0.5, 83], [6, 2, 81], [8, 1, 80],
		[9, 1, 83], [10, 2, 88], [12, 3, 87], [15, 1, 83], [16, 1.5, 84], [17.5, 0.5, 83], [18, 2, 79],
		[20, 1.5, 81], [21.5, 0.5, 83], [22, 2, 86], [24, 4, 88], [28, 2, 88], [30, 1, 83], [31, 1, 80]]
	var turn := [[0, 2, 79], [2, 2, 76], [4, 2, 78], [6, 2, 81], [8, 4, 78], [12, 1, 75], [13, 1, 78], [14, 1, 81], [15, 1, 83]]
	# layer 1, the walk
	_begin(seconds, 61, true)
	for p in 4:
		_voice(p * 40.0, 40.0, 40, 0.02, -0.1, 0.25, _harm_table("drone", [1.0, 0.5, 0.3, 0.15, 0.08]), {"attack": 4.0, "release": 4.0})
		_voice(p * 40.0, 40.0, 47, 0.015, 0.1, 0.25, _harm_table("drone", [1.0, 0.5, 0.3, 0.15, 0.08]), {"attack": 4.0, "release": 4.0})
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var peak := 1.15 if bar >= 28 and bar < 36 else 1.0
		var r: int = c.bass + 12
		var top := _above(c, r + 11)
		var riff := [top, r + 7, top, _above(c, top), top, r + 7, _above(c, _above(c, top)), r + 7]
		for k in 8:
			_harp(b + k * 0.5, riff[k], (0.11 if k in [0, 3, 6] else 0.075) * peak, 0.3, 0.25, 1.1, 0.85)
		for k in 4:
			_bass(b + k, 0.9 if k != 1 else 0.45, c.bass, 0.07)
		_bass(b + 1.5, 0.45, c.bass + 7, 0.05)
		_hits(bar, "X..x..x.X..x..x.", "frame", 0.75, -0.25, 0.4)
		_hits(bar, ".x.x.x.x.x.x.x.x", "shaker", 0.6, 0.4)
	_line(16.0, reel, "fiddle", 0, 0.085, 0.15)
	_line(48.0, reel, "fiddle", 0, 0.085, 0.15)
	_line(48.0, _counter(chords, 12, 8, 64, 76, 2.0), "flute", 0, 0.045, -0.3)
	_line(80.0, rise, "fiddle", 0, 0.085, 0.15)
	_line(80.0, rise, "flute", -12, 0.04, -0.3)
	_line(112.0, light, "fiddle", 0, 0.09, 0.15)
	_line(112.0, _counter(chords, 28, 8, 66, 78, 2.0), "flute", 0, 0.045, -0.3)
	_pads(chords, 28, 8, "oh", 0, 0.025)
	_line(144.0, turn, "fiddle", 0, 0.085, 0.15)
	var walk := _finish(0.25)
	# layer 2, the fight
	_begin(seconds, 62, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var big := bar >= 20 and bar < 36
		_hits(bar, "X..x..x.X..x..x.", "tom", 0.9, -0.2, 95.0)
		_hits(bar, "..x...x...x..xx." if big else "...x.......x....", "tom", 0.6, 0.3, 150.0)
		_hits(bar, "X.......X..x...." if bar >= 4 else "X.......X.......", "taiko", 1.0)
		if bar >= 4:
			_hits(bar, "....X.......X..." if not big else "....X..x....X.x.", "clap", 0.8, 0.1)
			_hits(bar, "xoxoxoxoxoxoxoxo", "shaker", 0.5, -0.4)
		for k in 8:
			var m: int = c.bass + 12 + (12 if k % 4 == 2 else 0)
			_spic(b + k * 0.5, m, 0.05 if k % 2 == 0 else 0.035, -0.2)
		if bar in [4, 12, 20, 28, 36]:
			_boom(b, 0.9)
			_crash(b, 0.025)
		if bar in [11, 19, 27, 35, 39]:
			_fill(bar, 2.0, 0.9)
		# the war horn on the downbeat of every other bar: root and fifth
		if bar % 2 == 0 and bar >= 4:
			for iv: int in [0, 7]:
				var m: int = c.bass + 24 + iv
				_voice(b, 1.6, m, 0.04, 0.2, 0.4, _saw_table(m, 1.9, 2500.0),
					{"attack": 0.06, "release": 0.4, "bright": _saw_table(m, 0.95, 5000.0), "detune": [-6.0, 6.0], "vib": 0.003})
		# the chant: "ah" stabs on the off-beats of the bar's second half
		if bar >= 4:
			for t: int in c.tones:
				for at: float in [2.5, 3.5]:
					_voice(b + at, 0.4, t - 12, 0.03, 0.0, 0.5, _vowel_table("ah", t - 12), {"attack": 0.02, "release": 0.2, "detune": [-8.0, 0.0, 7.0]})
	_line(80.0, rise, "brass", -24, 0.05, -0.1)
	_line(112.0, light, "brass", -24, 0.06, -0.1)
	_pads(chords, 28, 8, "ah", 1, 0.02)
	var fight := _finish(0.2)
	return [walk, fight]


## "Pulso de Ferro": pulsing and dark-heroic, A minor (harmonic, the E major dominant), 138 BPM, 36 bars (62.6 s).
## A sixteenth-note bass that pushes in 3+3+2, a low horn motif, a choir rising over F G Am, the climax in A major
## (bVI bVII I) and a turn that drives back in on E. The fight adds a four on the floor, snare, toms, brass stabs
## and spiccato strings in octaves.
func _iron_pulse() -> Array:
	_bpm = 138.0
	var chords := _chords(["Am", "Am", "F", "E",
		"Am", "F", "G", "E", "Am", "F", "Dm", "E",
		"F", "G", "Am", "Am", "F", "G", "A", "A",
		"A", "D", "A", "E", "F", "G", "A", "A",
		"Am", "F", "G", "E", "Am", "F", "E", "E"])
	var bars := chords.size()
	var seconds := _secs(bars * 4.0)
	var motif := [[0, 1.5, 69], [1.5, 0.5, 72], [2, 1, 76], [3, 1, 74], [4, 2, 72], [6, 1, 69], [7, 1, 72],
		[8, 1.5, 74], [9.5, 0.5, 71], [10, 1, 67], [11, 1, 71], [12, 3, 68], [15, 1, 71],
		[16, 1.5, 69], [17.5, 0.5, 72], [18, 1, 76], [19, 1, 81], [20, 2, 77], [22, 1, 76], [23, 1, 74],
		[24, 1.5, 77], [25.5, 0.5, 76], [26, 1, 74], [27, 1, 72], [28, 2, 71], [30, 1, 68], [31, 1, 64]]
	var rise := [[0, 1, 72], [1, 1, 77], [2, 2, 81], [4, 1, 74], [5, 1, 79], [6, 2, 83], [8, 1, 76], [9, 1, 81],
		[10, 2, 84], [12, 2, 83], [14, 2, 81], [16, 1, 77], [17, 1, 81], [18, 2, 84], [20, 1, 79], [21, 1, 83],
		[22, 2, 86], [24, 2, 85], [26, 2, 88], [28, 4, 85]]
	var light := [[0, 1.5, 64], [1.5, 0.5, 69], [2, 2, 73], [4, 1.5, 74], [5.5, 0.5, 73], [6, 2, 69], [8, 1, 73],
		[9, 1, 76], [10, 2, 81], [12, 3, 80], [15, 1, 76], [16, 1.5, 77], [17.5, 0.5, 76], [18, 2, 72],
		[20, 1.5, 74], [21.5, 0.5, 76], [22, 2, 79], [24, 4, 81], [28, 2, 81], [30, 1, 76], [31, 1, 73]]
	var drive := [[0, 1.5, 69], [1.5, 0.5, 72], [2, 2, 76], [8, 1.5, 74], [9.5, 0.5, 71], [10, 2, 67],
		[16, 1.5, 69], [17.5, 0.5, 72], [18, 2, 77], [24, 2, 76], [26, 2, 71], [28, 4, 68]]
	# layer 1, the walk
	_begin(seconds, 71, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var peak := 1.15 if bar >= 20 and bar < 28 else 1.0
		var r: int = c.bass
		var pulse := [r, r, r + 12, r, r, r + 12, r, r + 12, r, r, r + 12, r, r, r + 12, r + 7, r + 12]
		for k in 16:
			var acc := 1.0 if k in [0, 3, 6, 8, 11, 14] else 0.5
			_bass(b + k * 0.25, 0.2, pulse[k], 0.07 * acc * peak)
		_hits(bar, "x.x.x.x.x.x.x.x." if bar < 4 else "xoxoxoxoxoxoxoxo", "hat", 0.55, 0.3)
		if bar >= 4:
			_hits(bar, "............X...", "snare", 0.4, -0.1)
		# the chord in high, quiet eighths: the pulse's shine
		var arp: Array = [c.tones[0] + 12, c.tones[1] + 12, c.tones[2] + 12, c.tones[1] + 12]
		for k in 8:
			_harp(b + k * 0.5, arp[k % 4], 0.05 * peak, 0.35, 0.3, 1.0, 0.7)
	_line(16.0, motif, "viola", -12, 0.08, -0.1)
	_line(16.0, motif, "strings", 0, 0.05, 0.25)
	_pads(chords, 12, 8, "oh", 0, 0.035)
	_line(48.0, rise, "strings", 0, 0.085, 0.1)
	_line(80.0, light, "strings", 12, 0.09, 0.1)
	_line(80.0, _counter(chords, 20, 8, 60, 72), "viola", 0, 0.05, -0.35)
	_pads(chords, 20, 8, "ah", 0, 0.03)
	_line(112.0, drive, "strings", 0, 0.085, 0.1)
	var walk := _finish(0.2)
	# layer 2, the fight
	_begin(seconds, 72, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var peak := bar >= 20 and bar < 28
		_hits(bar, "X...X...X.x.X..x" if peak else "X...X...X...X..x", "kick", 0.95)
		if bar >= 4:
			_hits(bar, "....X..o....X.oo" if peak else "....X.......X...", "snare", 0.85, 0.05)
			_hits(bar, "..o...o...o...o.", "open", 0.4, -0.3)
		else:
			_hits(bar, "X.......X.......", "taiko", 0.8)
		_hits(bar, "...x..x....x..x." if bar >= 12 else "......x.......x.", "tom", 0.55, 0.35, 120.0)
		var low: int = c.tones[0] - 12
		for k in 8:
			_spic(b + k * 0.5, low + (0 if k % 2 == 0 else 12), 0.03, -0.25)
			_spic(b + k * 0.5, low + 12 + (0 if k % 2 == 0 else 12), 0.025, 0.25)
		if bar % 2 == 0:
			_stab(b, c, 0, 0.045)
		_stab(b + 2.5, c, 0, 0.035, 0.3)
		if bar in [4, 12, 20, 28]:
			_crash(b, 0.035)
			_boom(b, 0.9)
		if bar in [11, 19, 27, 35]:
			_fill(bar, 2.0, 0.85)
		if bar in [3, 19, 27]:
			_swell(b, 4.0, 0.04)
	_line(16.0, motif, "brass", -12, 0.07, -0.1)
	_line(48.0, rise, "brass", -12, 0.06, -0.1)
	_line(80.0, light, "brass", 0, 0.075, -0.1)
	_line(80.0, light, "choir", 0, 0.03, 0.3)
	_line(112.0, drive, "brass", -12, 0.07, -0.1)
	var fight := _finish(0.18)
	return [walk, fight]


# ---------------------------------------------------------------- MUS-1, Morvath


## "Morvath, a Batalha": C minor (harmonic, the G major dominant), 150 BPM, 40 bars (64 s), one layer added per phase.
## 1 O Despertar: low strings in driving sixteenths, kick and taiko, the bass. 2 O Ritual dos Mortos: a choir chanting
## in half notes, frame drums off the beat, a low bell. 3 A Maldição dos Condenados: tremolo strings high, snare,
## toms and hats, a falling harp. 4 O Último Suspiro: the hero's brass theme answering him, rising into C major (the
## light of Elun) and back, with crashes and a high choir.
func _morvath_battle() -> Array:
	_bpm = 150.0
	var chords := _chords(["Cm", "Ab", "Fm", "G", "Cm", "Ab", "Bb", "G",
		"Cm", "Ab", "Fm", "G", "Cm", "Ab", "Bb", "G",
		"Ab", "Bb", "Cm", "Cm", "Ab", "Bb", "C", "C",
		"C", "F", "C", "G", "Ab", "Bb", "C", "C",
		"Cm", "Ab", "Fm", "G", "Ab", "Bb", "G", "G"])
	var bars := chords.size()
	var seconds := _secs(bars * 4.0)
	var layers := []
	# 1, the drive
	_begin(seconds, 81, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var r: int = c.bass + 12
		var f: int = r + int(c.fifth)
		var t: int = r + int(c.third) + 12
		var riff := [r, r, r + 12, r, r, r + 12, f, r + 12, r, r, r + 12, r, f, r + 12, t, r + 12]
		for k in 16:
			var acc := 1.0 if k in [0, 3, 6, 8, 11, 14] else 0.55
			_spic(b + k * 0.25, riff[k], 0.05 * acc, -0.25)
			_spic(b + k * 0.25, riff[k] - 12, 0.035 * acc, 0.25)
		for k in 8:
			_bass(b + k * 0.5, 0.42, c.bass, 0.07 if k % 2 == 0 else 0.05)
		_hits(bar, "X..x..x.X..x..x.", "kick", 0.85)
		_hits(bar, "X.......X.......", "taiko", 0.75)
		if bar % 8 == 0:
			_boom(b, 0.8)
	layers.append(_finish(0.2))
	# 2, the ritual's chant
	_begin(seconds, 82, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var low: int = c.tones[0]
		var hi := _above(c, low)
		for h in 2:
			var m: int = (low if h == 0 else hi) - 12
			for oc: int in [0, -12]:
				_voice(b + h * 2.0, 2.0, m + oc, 0.055 if oc == 0 else 0.04, 0.1, 0.55, _vowel_table("oh", m + oc),
					{"attack": 0.12, "release": 0.35, "detune": [-9.0, 0.0, 8.0], "vib": 0.004})
		_hits(bar, "..x...x...x...xx", "frame", 0.7, 0.3, 0.5)
		if bar % 2 == 0:
			_bell(b, c.bass + 12, 0.11, -0.1, 0.6)
	layers.append(_finish(0.28))
	# 3, the curse: tremolo strings, snare and toms, a falling harp
	_begin(seconds, 83, true)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		var t1: int = c.tones[1] + 12
		var t2: int = c.tones[2] + 12
		for t: int in [t1, t2]:
			_voice(b, 4.0, t, 0.03, 0.4 if t == t1 else -0.4, 0.4, _saw_table(t, 1.3, 7000.0),
				{"attack": 0.2, "release": 0.3, "detune": [-6.0, 6.0], "trem": 15.0, "trem_depth": 0.6})
		_hits(bar, "....X.......X..o", "snare", 0.8, 0.05)
		_hits(bar, "..x...x...x..xx.", "tom", 0.6, -0.3, 130.0)
		_hits(bar, "xoxoxoxoxoxoxoxo", "hat", 0.65, 0.35)
		var fall: Array = [t2, t1, c.tones[0] + 12, c.tones[2], c.tones[1], c.tones[0], c.tones[2], c.tones[1]]
		for k in 8:
			_harp(b + k * 0.5, fall[k], 0.06, 0.25 - k * 0.06, 0.35, 1.4, 0.7)
		if bar % 8 == 7:
			_fill(bar, 2.0, 0.8)
	layers.append(_finish(0.25))
	# 4, the last breath: the brass theme, crashes, a high choir
	_begin(seconds, 84, true)
	var theme := [[0, 1.5, 72], [1.5, 0.5, 67], [2, 2, 72], [4, 1.5, 75], [5.5, 0.5, 72], [6, 2, 68],
		[8, 1, 68], [9, 1, 72], [10, 2, 77], [12, 3, 74], [15, 1, 71],
		[16, 1.5, 72], [17.5, 0.5, 75], [18, 2, 79], [20, 1.5, 80], [21.5, 0.5, 79], [22, 2, 77], [24, 1, 75], [25, 1, 74],
		[26, 2, 72], [28, 3, 71], [31, 1, 74]]
	var climb := [[0, 1, 72], [1, 1, 75], [2, 2, 80], [4, 1, 74], [5, 1, 77], [6, 2, 82], [8, 1, 75], [9, 1, 79],
		[10, 2, 84], [12, 4, 79], [16, 1, 75], [17, 1, 80], [18, 2, 84], [20, 1, 77], [21, 1, 82], [22, 2, 86],
		[24, 2, 84], [26, 2, 88], [28, 4, 84]]
	var light := [[0, 1.5, 72], [1.5, 0.5, 76], [2, 2, 79], [4, 1.5, 81], [5.5, 0.5, 79], [6, 2, 77], [8, 1, 76],
		[9, 1, 79], [10, 2, 84], [12, 3, 83], [15, 1, 79], [16, 1.5, 80], [17.5, 0.5, 79], [18, 2, 75],
		[20, 1.5, 77], [21.5, 0.5, 79], [22, 2, 82], [24, 4, 84], [28, 2, 84], [30, 1, 79], [31, 1, 76]]
	for s: Array in [[0.0, theme], [32.0, theme], [64.0, climb], [96.0, light], [128.0, theme]]:
		_line(s[0], s[1], "brass", -12, 0.075, -0.1)
		_line(s[0], s[1], "strings", 0, 0.045, 0.25)
	for bar in bars:
		var c: Dictionary = chords[bar]
		var b := bar * 4.0
		if bar % 8 == 0:
			_crash(b, 0.035)
		if bar % 8 == 7:
			_swell(b, 4.0, 0.035)
		_hits(bar, "....X.......X...", "clap", 0.5, 0.0)
		_hits(bar, "X...X...X...X...", "kick", 0.55)
		var i := 0
		for t: int in c.tones:
			_voice(b, 4.0, t + 12, 0.02, -0.5 + i * 0.5, 0.6, _vowel_table("ah", t + 12),
				{"attack": 0.3, "release": 0.5, "detune": [-8.0, 0.0, 7.0], "vib": 0.005})
			i += 1
	layers.append(_finish(0.22))
	return layers


# ---------------------------------------------------------------- MUS-1, levelled publishing

## Brings a piece's layers to loudness targets and writes them: targets[k] is the integrated loudness (LUFS, the
## game's Loudness) of the layers 1..k+1 summed (the walk, then the walk and the fight; Morvath phase by phase).
## Every such sum is kept under ceiling dBFS (samples) by a lookahead limiter whose gain applies to all the layers of
## that sum, so the layers stay in time and their sum is the limited sum.
func _publish_levelled(id: StringName, layers: Array, targets: Array, ceiling_db: float) -> void:
	var gains: Array[float] = []
	for k in layers.size():
		gains.append(1.0)
	var out := []
	for k in layers.size():
		out.append([layers[k][0], layers[k][1]])
	for k in layers.size():
		gains[k] = _solve_gain(out, k, float(targets[k]))
		out[k] = [_scaled(layers[k][0], gains[k]), _scaled(layers[k][1], gains[k])]
	for attempt in 3:
		for k in layers.size():
			_limit_prefix(out, k, ceiling_db)
		var worst := 0.0
		var report := []
		var level: Array[float] = []
		for k in layers.size():
			var l := Loudness.integrated(_prefix(out, k))
			level.append(l)
			report.append("%.2f" % l)
			worst = maxf(worst, absf(l - float(targets[k])))
		print("%s attempt %d: LUFS %s (targets %s)" % [id, attempt, ", ".join(report), str(targets)])
		if worst < 0.25 or attempt == 2:
			break
		# the limiter took some loudness away: give it back and limit again, from the raw layers
		for k in layers.size():
			gains[k] *= db_to_linear(clampf(float(targets[k]) - level[k], -1.5, 1.5) * (1.0 if k == 0 else 1.5))
			out[k] = [_scaled(layers[k][0], gains[k]), _scaled(layers[k][1], gains[k])]
	for k in out.size():
		print("%s: layers 1..%d true peak %.2f dBTP" % [id, k + 1, Loudness.true_peak(_prefix(out, k))])
	_write(id, out, 1.0)


func _scaled(x: PackedFloat32Array, g: float) -> PackedFloat32Array:
	var o := x.duplicate()
	for i in o.size():
		o[i] *= g
	return o


## The layers 0..k summed, as the game's sample pairs.
func _prefix(layers: Array, k: int) -> PackedVector2Array:
	var n: int = (layers[0][0] as PackedFloat32Array).size()
	var out := PackedVector2Array()
	out.resize(n)
	for q in k + 1:
		var l: PackedFloat32Array = layers[q][0]
		var r: PackedFloat32Array = layers[q][1]
		for i in n:
			out[i] += Vector2(l[i], r[i])
	return out


## The gain of layer k that brings the sum of 0..k to target LUFS (the layers before it as they are): a secant on dB.
func _solve_gain(layers: Array, k: int, target: float) -> float:
	var base := _prefix(layers, k - 1) if k > 0 else PackedVector2Array()
	var l: PackedFloat32Array = layers[k][0]
	var r: PackedFloat32Array = layers[k][1]
	var n := l.size()
	var f := func(db: float) -> float:
		var g := db_to_linear(db)
		var x := PackedVector2Array()
		x.resize(n)
		for i in n:
			x[i] = Vector2(l[i], r[i]) * g
			if k > 0:
				x[i] += base[i]
		return Loudness.integrated(x) - target
	var a := 0.0
	var fa: float = f.call(a)
	var b := -fa if k == 0 else -fa * 2.0
	var fb: float = f.call(b)
	for it in 6:
		if absf(fb) < 0.05 or absf(fb - fa) < 1e-4:
			break
		var c := b - fb * (b - a) / (fb - fa)
		a = b
		fa = fb
		b = clampf(c, -40.0, 40.0)
		fb = f.call(b)
	return db_to_linear(b)


## A lookahead limiter on the sum of layers 0..k (samples under ceiling dBFS): the gain falls linearly over 3 ms
## before a peak and recovers over about 120 ms, applied to every layer of the sum (a loop wraps round).
func _limit_prefix(layers: Array, k: int, ceiling_db: float) -> void:
	var x := _prefix(layers, k)
	var n := x.size()
	var ceil_lin := db_to_linear(ceiling_db)
	var g := PackedFloat32Array()
	g.resize(n)
	var any := false
	for i in n:
		var a := maxf(absf(x[i].x), absf(x[i].y))
		g[i] = minf(1.0, ceil_lin / maxf(a, 1e-9))
		if g[i] < 1.0:
			any = true
	if not any:
		return
	var att := 1.0 / (0.003 * RATE)
	var rel := 1.0 / (0.12 * RATE)
	for pass_i in 2:
		for i in range(n - 1, -1, -1):
			g[i] = minf(g[i], g[(i + 1) % n] + att)
	var cur := 1.0
	for pass_i in 2:
		for i in n:
			cur = minf(g[i], cur + rel)
			if pass_i == 1:
				g[i] = cur
	for q in k + 1:
		var l: PackedFloat32Array = layers[q][0]
		var r: PackedFloat32Array = layers[q][1]
		for i in n:
			l[i] *= g[i]
			r[i] *= g[i]
		layers[q] = [l, r]


# ---------------------------------------------------------------- the buffer

func _begin(seconds: float, seed: int, loop: bool) -> void:
	_n = int(round(seconds * RATE))
	_loop = loop
	_rng.seed = seed
	for buf: String in ["_l", "_r", "_s"]:
		var b := PackedFloat32Array()
		b.resize(_n)
		b.fill(0.0)
		set(buf, b)


func _secs(beats: float) -> float:
	return beats * 60.0 / _bpm


func randf_pan() -> float:
	return _rng.randf_range(-0.5, 0.5)


## The reverb of the hall over the send (a Freeverb, mono in, stereo out); a loop is warmed on its own end first, so
## the tail of bar 32 rings into bar 1 and the seam is not heard. Returns [left, right].
func _finish(wet: float, gain: float = 1.0) -> Array:
	var combs := [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617]
	var aps := [556, 441, 341, 225]
	var lens := PackedInt32Array()
	for ch in 2:
		for c: int in combs:
			lens.append(int((c + 23 * ch) * 1.35))
		for a: int in aps:
			lens.append(a + 23 * ch)
	var offs := PackedInt32Array()
	var total := 0
	for x in lens:
		offs.append(total)
		total += x
	var buf := PackedFloat32Array()
	buf.resize(total)
	buf.fill(0.0)
	var idx := PackedInt32Array()
	idx.resize(lens.size())
	idx.fill(0)
	var filt := PackedFloat32Array()
	filt.resize(16)
	filt.fill(0.0)
	var feedback := 0.86
	var damp := 0.3
	var warm := int(5.0 * RATE) if _loop else 0
	for step in warm + _n:
		var j := step - warm
		var src := j if j >= 0 else _n + j
		var inp := _s[src] * 0.015
		var out_l := 0.0
		var out_r := 0.0
		for ch in 2:
			var acc := 0.0
			var base := ch * 12
			for c in 8:
				var q := base + c
				var at := offs[q] + idx[q]
				var o := buf[at]
				filt[ch * 8 + c] = o * (1.0 - damp) + filt[ch * 8 + c] * damp
				buf[at] = inp + filt[ch * 8 + c] * feedback
				idx[q] = (idx[q] + 1) % lens[q]
				acc += o
			for a in 4:
				var q := base + 8 + a
				var at := offs[q] + idx[q]
				var bo := buf[at]
				var o := bo - acc
				buf[at] = acc + bo * 0.5
				idx[q] = (idx[q] + 1) % lens[q]
				acc = o
			if ch == 0:
				out_l = acc
			else:
				out_r = acc
		if j >= 0:
			_l[j] += out_l * wet * 3.0
			_r[j] += out_r * wet * 3.0
	return [_dc_block(_l, gain), _dc_block(_r, gain)]


## A high pass at about 28 Hz: no offset and no rumble under the music (a loop runs it twice, the seam warm).
func _dc_block(x: PackedFloat32Array, gain: float) -> PackedFloat32Array:
	var out := x.duplicate()
	var x1 := 0.0
	var y1 := 0.0
	for pass_i in (2 if _loop else 1):
		for i in _n:
			var y := x[i] - x1 + 0.996 * y1
			x1 = x[i]
			y1 = y
			out[i] = y * gain
	return out


## Writes a sample pair at i (wrapping round a loop, dropped past a one-shot's end).
func _at(i: int) -> int:
	if i >= _n:
		return i - _n if _loop else -1
	return i


# ---------------------------------------------------------------- instruments

func _hz(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


## One cycle with the given harmonics' amplitudes, peak 1.
func _harm_table(key: String, amps: Array) -> PackedFloat32Array:
	var k := "%s%s" % [key, str(amps)]
	if _tables.has(k):
		return _tables[k]
	var t := PackedFloat32Array()
	t.resize(TAB)
	var peak := 0.0
	for i in TAB:
		var v := 0.0
		for h in amps.size():
			v += amps[h] * sin(TAU * (h + 1) * i / TAB)
		t[i] = v
		peak = maxf(peak, absf(v))
	for i in TAB:
		t[i] /= peak
	_tables[k] = t
	return t


## A sawtooth-like string or brass for note m: harmonics 1/k^tilt up to top Hz.
func _saw_table(m: int, tilt: float, top: float) -> PackedFloat32Array:
	var f := _hz(m)
	var amps := []
	var h := 1
	while h * f < minf(top, RATE * 0.45) and h <= 60:
		amps.append(1.0 / pow(h, tilt))
		h += 1
	return _harm_table("saw", amps)


## A choir's vowel for note m: the harmonics weighted by the vowel's formants.
func _vowel_table(vowel: String, m: int) -> PackedFloat32Array:
	var formants: Array = {"ah": [[730.0, 1.0, 130.0], [1090.0, 0.55, 150.0], [2440.0, 0.22, 260.0]],
		"oo": [[320.0, 1.0, 110.0], [870.0, 0.3, 150.0], [2240.0, 0.06, 260.0]],
		"oh": [[570.0, 1.0, 120.0], [840.0, 0.6, 140.0], [2410.0, 0.14, 260.0]]}[vowel]
	var f := _hz(m)
	var amps := []
	var h := 1
	while h * f < 6000.0 and h <= 60:
		var w := 0.12
		for fm: Array in formants:
			w += fm[1] * exp(-pow((h * f - fm[0]) / fm[2], 2.0))
		amps.append(w / pow(h, 0.4))
		h += 1
	return _harm_table(vowel, amps)


## A held voice: unison oscillators on a table (detune in cents), attack, optional decay to a sustain, a cosine
## release, vibrato, tremolo, and a second table it brightens towards with the envelope (brass).
func _voice(beat: float, beats: float, m: float, amp: float, pan: float, send: float, table: PackedFloat32Array, o: Dictionary = {}) -> void:
	var attack: float = o.get("attack", 0.02)
	var release: float = o.get("release", 0.3)
	var decay: float = o.get("decay", 0.0)
	var sustain: float = o.get("sustain", 1.0)
	var detune: Array = o.get("detune", [0.0])
	var vib: float = o.get("vib", 0.0)
	var trem: float = o.get("trem", 0.0)
	var trem_depth: float = o.get("trem_depth", 0.0)
	var bright: PackedFloat32Array = o.get("bright", PackedFloat32Array())
	var has_bright := not bright.is_empty()
	var dur := _secs(beats)
	var total := int((dur + release) * RATE)
	var i0 := int(_secs(beat) * RATE)
	var f := _hz(m)
	var nv := detune.size()
	var inc := PackedFloat64Array()
	var ph := PackedFloat64Array()
	for d: float in detune:
		inc.append(f * pow(2.0, d / 1200.0) * TAB / RATE)
		ph.append(_rng.randf() * TAB)
	var vph := _rng.randf() * TAB
	var vinc := _rng.randf_range(4.6, 5.6) * TAB / RATE
	var tph := 0.0
	var tinc := trem * TAB / RATE
	var gl := cos((pan + 1.0) * PI / 4.0) * amp / nv
	var gr := sin((pan + 1.0) * PI / 4.0) * amp / nv
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var e := 1.0
		if tt < attack:
			e = tt / attack
		elif decay > 0.0:
			e = sustain + (1.0 - sustain) * exp(-(tt - attack) * decay)
		if tt > dur:
			e *= 0.5 + 0.5 * cos(PI * minf((tt - dur) / release, 1.0))
		var bend := 1.0
		if vib > 0.0:
			vph += vinc
			bend += vib * minf(tt * 3.0, 1.0) * _sin[int(vph) & MASK]
		var v := 0.0
		var w := 0.0
		for u in nv:
			ph[u] += inc[u] * bend
			if ph[u] >= TAB:
				ph[u] -= TAB
			var p := int(ph[u])
			var fr := ph[u] - p
			var a := table[p]
			v += a + (table[(p + 1) & MASK] - a) * fr
			if has_bright:
				var b := bright[p]
				w += b + (bright[(p + 1) & MASK] - b) * fr
		if has_bright:
			var mixb := e * e * 0.8
			v = v * (1.0 - mixb) + w * mixb
		if trem > 0.0:
			tph += tinc
			v *= 1.0 - trem_depth * (0.5 + 0.5 * _sin[int(tph) & MASK])
		v *= e
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * send * amp / nv
	return


## A flute: a soft table, a delayed vibrato and the breath's noise.
func _flute(beat: float, beats: float, m: float, amp: float, pan: float, send: float) -> void:
	_voice(beat, beats, m, amp, pan, send, _harm_table("flute", [1.0, 0.2, 0.07, 0.03]), {"attack": 0.07, "release": 0.25, "vib": 0.005})
	var dur := _secs(beats)
	var total := int((dur + 0.25) * RATE)
	var i0 := int(_secs(beat) * RATE)
	var lp := 0.0
	var gl := cos((pan + 1.0) * PI / 4.0) * amp * 0.12
	var gr := sin((pan + 1.0) * PI / 4.0) * amp * 0.12
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var e := minf(tt / 0.04, 1.0) * (0.35 + 0.65 * exp(-tt * 6.0))
		if tt > dur:
			e *= maxf(1.0 - (tt - dur) / 0.25, 0.0)
		lp += 0.12 * (_rng.randf_range(-1.0, 1.0) - lp)
		var v := lp * e
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * send * amp * 0.12


## A plucked string (Karplus-Strong), about 3 s (secs; bright, the pluck's noise, 0.6 a harp, higher a bouzouki).
func _harp(beat: float, m: float, amp: float, pan: float, send: float, secs: float = 3.0, bright: float = 0.6) -> void:
	var f := _hz(m)
	var p := maxi(int(round(RATE / f)), 2)
	var line := PackedFloat32Array()
	line.resize(p)
	var lp := 0.0
	for i in p:
		lp += bright * (_rng.randf_range(-1.0, 1.0) - lp)
		line[i] = lp
	var mean := 0.0
	for i in p:
		mean += line[i] / p
	for i in p:
		line[i] -= mean
	var dec := pow(0.001, float(p) / ((secs - 0.4) * RATE))
	var total := int(secs * RATE)
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * amp
	var gr := sin((pan + 1.0) * PI / 4.0) * amp
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var at := k % p
		var o := line[at]
		line[at] = (o + line[(at + 1) % p]) * 0.5 * dec
		var v := o
		if k > total - 2000:
			v *= float(total - k) / 2000.0
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * send * amp


## A bell: inharmonic partials, each with its own decay.
func _bell(beat: float, m: float, amp: float, pan: float, send: float) -> void:
	var f := _hz(m)
	var partials := [[0.5, 0.25, 0.9], [1.0, 1.0, 1.3], [2.0, 0.45, 2.2], [2.76, 0.3, 3.0], [5.4, 0.12, 5.0], [8.93, 0.05, 8.0]]
	var total := int(4.5 * RATE)
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * amp * 0.5
	var gr := sin((pan + 1.0) * PI / 4.0) * amp * 0.5
	var incs := PackedFloat64Array()
	var levels := PackedFloat32Array()
	var decays := PackedFloat32Array()
	for q: Array in partials:
		if q[0] * f < RATE * 0.45:
			incs.append(q[0] * f * TAB / RATE)
			levels.append(q[1])
			decays.append(q[2])
	var ph := PackedFloat64Array()
	ph.resize(incs.size())
	ph.fill(0.0)
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var v := 0.0
		for u in incs.size():
			ph[u] += incs[u]
			if ph[u] >= TAB:
				ph[u] -= TAB
			v += _sin[int(ph[u])] * levels[u] * exp(-tt * decays[u])
		v *= minf(tt / 0.002, 1.0)
		if k > total - 2000:
			v *= float(total - k) / 2000.0
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * send * amp * 0.5


## A drum: a sine falling from f0 + sweep to f0, its decay, and a noise slap (low passed for the taiko).
func _drum(beat: float, vel: float, pan: float, f0: float, sweep: float, fall: float, body_decay: float, slap: float, slap_decay: float, lp_k: float, seconds: float, send: float) -> void:
	var total := int(seconds * RATE)
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * vel
	var gr := sin((pan + 1.0) * PI / 4.0) * vel
	var ph := 0.0
	var lp := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		ph += (f0 + sweep * exp(-tt * fall)) * TAB / RATE
		var v := _sin[int(ph) & MASK] * exp(-tt * body_decay)
		lp += lp_k * (_rng.randf_range(-1.0, 1.0) - lp)
		v += lp * slap * exp(-tt * slap_decay)
		v *= minf(tt / 0.001, 1.0)
		if k > total - 500:
			v *= float(total - k) / 500.0
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * send * vel


func _taiko(beat: float, vel: float, pan: float) -> void:
	_drum(beat, vel * 0.3, pan, 52.0, 70.0, 28.0, 6.0, 1.2, 40.0, 0.12, 1.2, 0.3)


func _frame(beat: float, vel: float, pan: float, bright: float = 0.5) -> void:
	_drum(beat, vel * 0.22, pan, 140.0, 90.0, 45.0, 13.0, 0.5 + bright * 0.4, 60.0, 0.25 + bright * 0.3, 0.5, 0.25)


func _boom(beat: float, vel: float) -> void:
	_drum(beat, vel * 0.3, 0.0, 36.0, 26.0, 6.0, 2.0, 0.3, 20.0, 0.03, 2.6, 0.4)


## A shaker: a short burst of high noise.
func _shaker(beat: float, vel: float, pan: float) -> void:
	var total := int(0.12 * RATE)
	var i0 := int(_secs(beat) * RATE)
	var gl := cos((pan + 1.0) * PI / 4.0) * vel * 0.045
	var gr := sin((pan + 1.0) * PI / 4.0) * vel * 0.045
	var lp := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var n := _rng.randf_range(-1.0, 1.0)
		lp += 0.35 * (n - lp)
		var v := (n - lp) * (tt / 0.006 if tt < 0.006 else exp(-(tt - 0.006) * 45.0))
		_l[j] += v * gl
		_r[j] += v * gr
		_s[j] += v * 0.2 * vel * 0.045


## A cymbal swelling for beats into the next downbeat, then fading.
func _swell(beat: float, beats: float, amp: float) -> void:
	var dur := _secs(beats)
	var total := int((dur + 0.6) * RATE)
	var i0 := int(_secs(beat) * RATE)
	var lp := 0.0
	var lp2 := 0.0
	for k in total:
		var j := _at(i0 + k)
		if j < 0:
			break
		var tt := float(k) / RATE
		var n := _rng.randf_range(-1.0, 1.0)
		lp += 0.5 * (n - lp)
		lp2 += 0.05 * (lp - lp2)
		var e := pow(tt / dur, 2.5) if tt < dur else exp(-(tt - dur) * 8.0)
		var v := (lp - lp2) * e * amp
		_l[j] += v
		_r[j] += v
		_s[j] += v * 0.5


# ---------------------------------------------------------------- output

## Scales a track's layers together (the sum of all at most PEAK), writes each as .wav in the work folder and
## .ogg in audio/music/ (<id>.ogg, or <id>_1.ogg... for layers).
func _publish(id: StringName, layers: Array) -> void:
	var n: int = (layers[0][0] as PackedFloat32Array).size()
	var peak := 0.0
	for i in n:
		var sl := 0.0
		var sr := 0.0
		for layer: Array in layers:
			sl += layer[0][i]
			sr += layer[1][i]
		peak = maxf(peak, maxf(absf(sl), absf(sr)))
	_write(id, layers, PEAK / maxf(peak, 0.0001))


## Writes each layer, times gain, as .wav in the work folder and .ogg in audio/music/.
func _write(id: StringName, layers: Array, gain: float) -> void:
	var n: int = (layers[0][0] as PackedFloat32Array).size()
	for k in layers.size():
		var name := String(id) if layers.size() == 1 else "%s_%d" % [id, k + 1]
		var l: PackedFloat32Array = layers[k][0]
		var r: PackedFloat32Array = layers[k][1]
		var bytes := PackedByteArray()
		bytes.resize(n * 4)
		var sq := 0.0
		var lpk := 0.0
		for i in n:
			var a := l[i] * gain
			var b := r[i] * gain
			sq += a * a + b * b
			lpk = maxf(lpk, maxf(absf(a), absf(b)))
			bytes.encode_s16(i * 4, clampi(int(round(a * 32767.0)), -32768, 32767))
			bytes.encode_s16(i * 4 + 2, clampi(int(round(b * 32767.0)), -32768, 32767))
		var wav := AudioStreamWAV.new()
		wav.format = AudioStreamWAV.FORMAT_16_BITS
		wav.stereo = true
		wav.mix_rate = RATE
		wav.data = bytes
		var wav_path := "%s/%s.wav" % [_work, name]
		wav.save_to_wav(wav_path)
		var ogg := ProjectSettings.globalize_path(OUT + name + ".ogg")
		var out := []
		var code := OS.execute("ffmpeg", ["-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", QUALITY.get(id, OGG_QUALITY), ogg], out, true)
		var size := FileAccess.get_file_as_bytes(ogg).size()
		print("%s: %.2f s, peak %.1f dBFS, rms %.1f dBFS, %d KB%s" % [name, float(n) / RATE, linear_to_db(lpk),
			linear_to_db(sqrt(sq / (2.0 * n))), size / 1024, "" if code == 0 else " (ffmpeg failed: %s)" % str(out)])
