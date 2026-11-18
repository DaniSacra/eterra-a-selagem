extends SceneTree
## The game's music (E4-06, C15-03): composed here, note by note, and rendered by our own synthesis, so the licence
## is the project's (D-12b). Nothing sampled, nothing taken from another game.
##   ~/tools/godot/godot --headless --path . -s tools/make_music.gd [-- psalms victory] [--work=dir]
## T5: the title, the rooms and Morvath are recorded music now (Kevin MacLeod, CC BY 4.0, tools/make_music_loops.sh);
## the old synthesised catacombs and morvath are still here, rendered only when asked by name, as the pieces
## "Catacumbas (original)" and "Morvath (original)" (audio/music/classic_catacombs_*.ogg, classic_morvath_*.ogg; the
## player picks them in the Músicas screen, MusicCatalog; they are the default everywhere since the PO's T5 review).
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

const RATE := 44100
const OUT := "res://audio/music/"
const TAB := 2048
const MASK := TAB - 1
## The loudest sum of a track's layers before the game's own music gain (Music.MUSIC_DB): -4.4 dBFS.
const PEAK := 0.6
const OGG_QUALITY := "3"

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


## A plucked string (Karplus-Strong), about 3 s.
func _harp(beat: float, m: float, amp: float, pan: float, send: float) -> void:
	var f := _hz(m)
	var p := maxi(int(round(RATE / f)), 2)
	var line := PackedFloat32Array()
	line.resize(p)
	var lp := 0.0
	for i in p:
		lp += 0.6 * (_rng.randf_range(-1.0, 1.0) - lp)
		line[i] = lp
	var mean := 0.0
	for i in p:
		mean += line[i] / p
	for i in p:
		line[i] -= mean
	var dec := pow(0.001, float(p) / (2.6 * RATE))
	var total := int(3.0 * RATE)
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
	var gain := PEAK / maxf(peak, 0.0001)
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
		var code := OS.execute("ffmpeg", ["-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", OGG_QUALITY, ogg], out, true)
		var size := FileAccess.get_file_as_bytes(ogg).size()
		print("%s: %.2f s, peak %.1f dBFS, rms %.1f dBFS, %d KB%s" % [name, float(n) / RATE, linear_to_db(lpk),
			linear_to_db(sqrt(sq / (2.0 * n))), size / 1024, "" if code == 0 else " (ffmpeg failed: %s)" % str(out)])
