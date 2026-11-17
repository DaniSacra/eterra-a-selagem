extends SceneTree
## The rooms' air (E6, C15-04): one quiet loop per arena, made here by our own synthesis (filtered noise, drones,
## drips, embers, creaks, chains, whispers), so the licence is the project's (D-12b). Nothing recorded.
##   ~/tools/godot/godot --headless --path . -s tools/make_ambience.gd [-- hall crypt ...] [--work=dir]
## Needs ffmpeg with libvorbis on the PATH. Writes audio/ambience/amb_<id>.ogg (Ambience.BY_ARENA maps the arenas to
## them; Music plays them on the Ambience bus). Deterministic. Every loop is seamless: every tone has a whole number
## of cycles in the loop, events wrap round its end, filters and the reverb are warmed on the loop's own tail.
## Each loop is scaled to the same RMS (RMS_DB) with its peak under PEAK_DB, times its recipe's level.

const RATE := 44100
const SECONDS := 24.0
const OUT := "res://audio/ambience/"
const RMS_DB := -28.0
const PEAK_DB := -8.0
const OGG_QUALITY := "2"
## Loop id -> relative level in dB (the busier airs a little lower).
const RECIPES := {
	&"hall": 0.0, &"crypt": 0.0, &"rift": -1.0, &"garden": 0.0, &"sanctuary": -1.0,
	&"bridge": -1.0, &"runes": -1.0, &"trial": 0.0, &"altar": 0.0, &"seal": -1.0,
}

var _n := 0
var _l := PackedFloat32Array()
var _r := PackedFloat32Array()
var _s := PackedFloat32Array()
var _rng := RandomNumberGenerator.new()
var _work := ""


func _init() -> void:
	var asked: Array[StringName] = []
	_work = OS.get_environment("HOME") + "/tools/e6/ambience"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--work="):
			_work = a.substr(7)
		else:
			asked.append(StringName(a))
	if asked.is_empty():
		for id: StringName in RECIPES:
			asked.append(id)
	DirAccess.make_dir_recursive_absolute(_work)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var seed_ := 61
	for id in asked:
		var t := Time.get_ticks_msec()
		_begin(seed_ + RECIPES.keys().find(id) * 101)
		var wet: float = call("_" + String(id))
		_finish(wet)
		_publish(StringName("amb_" + String(id)), RECIPES.get(id, 0.0))
		print("%s: %.1f s to render" % [id, (Time.get_ticks_msec() - t) / 1000.0])
	quit()


# ---------------------------------------------------------------- the airs (each returns its reverb's wet)

## The Salão das Catacumbas: a cold, wide air, the braziers' embers, a few far drips.
func _hall() -> float:
	_noise_bed(0.5, 180.0, 0.9, 120.0, 0.35, 12.0, 0.2)
	_noise_bed(0.12, 1400.0, 1.2, 600.0, 0.5, 8.0, 0.3)
	_crackle(5.0, 0.35, -0.5, 0.2)
	_crackle(3.0, 0.3, 0.5, 0.2)
	_drips(5, 0.25, 1400.0, 2200.0)
	_drone(55.0, 0.05, 0.25, 0.0, 0.1)
	return 0.35


## Cripta dos Esquecidos: close and still, drips that echo, a low hum of the stone.
func _crypt() -> float:
	_noise_bed(0.28, 140.0, 0.8, 70.0, 0.25, 8.0, 0.2)
	_drone(49.0, 0.07, 0.2, 0.0, 0.1)
	_drone(98.0, 0.025, 0.35, 0.2, 0.2)
	_drips(11, 0.35, 1500.0, 2600.0)
	return 0.55


## Salão das Fendas: the deep wind out of the rift, its rumble, a cold violet shimmer far up.
func _rift() -> float:
	_noise_bed(0.75, 320.0, 2.5, 220.0, 0.6, 6.0, 0.3)
	_noise_bed(0.5, 60.0, 0.9, 25.0, 0.3, 12.0, 0.1)
	_drone(1318.5, 0.008, 0.4, -0.4, 0.6)
	_drone(1760.0, 0.006, 0.3, 0.4, 0.6)
	return 0.45


## Jardim das Raízes Mortas: dry gusts in dead roots, a creak now and then.
func _garden() -> float:
	_noise_bed(0.45, 900.0, 0.7, 500.0, 0.7, 8.0, 0.2)
	_noise_bed(0.25, 220.0, 0.8, 100.0, 0.4, 12.0, 0.15)
	for k in 5:
		_creak(_rng.randf_range(0.0, SECONDS), _rng.randf_range(0.5, 1.1), _rng.randf_range(18.0, 34.0),
			_rng.randf_range(500.0, 900.0), 0.22, _rng.randf_range(-0.7, 0.7))
	return 0.3


## Santuário: a still, warm air with a choir far away (a soft fifth breathing).
func _sanctuary() -> float:
	_noise_bed(0.22, 260.0, 0.8, 120.0, 0.3, 12.0, 0.2)
	for m: Array in [[146.83, 0.03], [220.0, 0.022], [293.66, 0.018], [440.0, 0.008]]:
		_drone(m[0], m[1], 0.12, _rng.randf_range(-0.5, 0.5), 0.8, 12.0)
	_whisper(4.0, 6.0, 0.08, -0.3, [520.0, 900.0])
	_whisper(15.0, 6.0, 0.07, 0.3, [480.0, 1100.0])
	return 0.7


## A Ponte: open wind across the abyss, chains swinging and clinking.
func _bridge() -> float:
	_noise_bed(0.8, 450.0, 2.0, 300.0, 0.7, 6.0, 0.2)
	_noise_bed(0.55, 90.0, 0.8, 40.0, 0.3, 8.0, 0.1)
	for k in 9:
		_clink(_rng.randf_range(0.0, SECONDS), _rng.randf_range(700.0, 1300.0), 0.12, _rng.randf_range(-0.8, 0.8))
	return 0.4


## Salão das Runas: the runes' hum, beating slowly, and a fizz of their light.
func _runes() -> float:
	_noise_bed(0.22, 200.0, 0.8, 80.0, 0.25, 12.0, 0.2)
	_drone(110.0, 0.04, 0.5, -0.2, 0.4, 6.0)
	_drone(165.0, 0.03, 0.33, 0.2, 0.4, 8.0)
	_drone(220.0, 0.018, 0.75, 0.0, 0.5, 4.0)
	_crackle(7.0, 0.12, 0.0, 0.5)
	return 0.5


## Provação: a tense low pulse under a held fifth.
func _trial() -> float:
	_noise_bed(0.22, 160.0, 0.8, 60.0, 0.25, 12.0, 0.2)
	_drone(73.4, 0.05, 0.15, -0.2, 0.2)
	_drone(110.0, 0.035, 0.2, 0.2, 0.2)
	var t := 0.0
	while t < SECONDS:
		_thump(t, 0.35)
		_thump(t + 0.32, 0.22)
		t += 2.0
	return 0.4


## O Altar: candles' soft crackle and a warm low hum.
func _altar() -> float:
	_noise_bed(0.22, 220.0, 0.8, 90.0, 0.25, 12.0, 0.2)
	_drone(110.0, 0.05, 0.2, 0.0, 0.4, 8.0)
	_drone(164.81, 0.02, 0.25, 0.3, 0.5, 8.0)
	_crackle(6.0, 0.18, -0.3, 0.3)
	_crackle(4.0, 0.15, 0.4, 0.3)
	return 0.5


## A Câmara do Selo: the violet hum under the seal, the abyss wind, souls whispering far off.
func _seal() -> float:
	_noise_bed(0.55, 240.0, 1.6, 140.0, 0.5, 8.0, 0.3)
	_drone(41.2, 0.08, 0.3, 0.0, 0.2, 12.0)
	_drone(61.7, 0.045, 0.45, -0.3, 0.3, 8.0)
	_drone(82.4, 0.03, 0.6, 0.3, 0.3, 6.0)
	for k in 4:
		_whisper(k * 6.0 + _rng.randf_range(0.0, 2.0), 3.5, 0.06, _rng.randf_range(-0.7, 0.7), [_rng.randf_range(500.0, 800.0), _rng.randf_range(1000.0, 1500.0)])
	return 0.6


# ---------------------------------------------------------------- the pieces

func _begin(seed_: int) -> void:
	_rng.seed = seed_
	_n = int(SECONDS * RATE)
	for a: PackedFloat32Array in [_l, _r, _s]:
		a.resize(_n)
		a.fill(0.0)


## A whole number of cycles in the loop, so a tone meets itself at the seam.
func _loop_hz(hz: float) -> float:
	return maxf(roundf(hz * SECONDS), 1.0) / SECONDS


## Filtered noise breathing slowly: a band pass (centre, q) whose centre swings by `sweep` Hz and whose level swings by
## `swell` (0 to 1) over `period` seconds (a whole number of times in the loop); each side its own noise.
func _noise_bed(amp: float, centre: float, q: float, sweep: float, swell: float, period: float, send: float) -> void:
	var w := TAU * _loop_hz(1.0 / period)
	var phase := [_rng.randf() * TAU, _rng.randf() * TAU]
	for ch in 2:
		var noise := PackedFloat32Array()
		noise.resize(_n)
		for i in _n:
			noise[i] = _rng.randf_range(-1.0, 1.0)
		var ic1 := 0.0
		var ic2 := 0.0
		var a1 := 0.0
		var a2 := 0.0
		var a3 := 0.0
		var k := 1.0 / q
		var warm := RATE * 2
		for step in warm + _n:
			var i := (step - warm + _n) % _n
			var t := float(i) / RATE
			if step % 64 == 0:
				var fc := clampf(centre + sweep * sin(w * t + phase[ch]), 30.0, RATE * 0.45)
				var g := tan(PI * fc / RATE)
				a1 = 1.0 / (1.0 + g * (g + k))
				a2 = g * a1
				a3 = g * a2
			var v3 := noise[i] - ic2
			var v1 := a1 * ic1 + a2 * v3
			var v2 := ic2 + a2 * ic1 + a3 * v3
			ic1 = 2.0 * v1 - ic1
			ic2 = 2.0 * v2 - ic2
			if step >= warm:
				var level := amp * (1.0 - swell * 0.5 * (1.0 + sin(w * t * 0.5 * 2.0 + phase[1 - ch])))
				var y := v1 * level
				if ch == 0:
					_l[i] += y
				else:
					_r[i] += y
				_s[i] += y * send * 0.5


## Two sines a beat apart (`beat` Hz), breathing over `period` seconds, at a pan.
func _drone(hz: float, amp: float, beat: float, pan: float, send: float, period: float = 12.0) -> void:
	var f1 := TAU * _loop_hz(hz)
	var f2 := TAU * _loop_hz(hz + beat)
	var w := TAU * _loop_hz(1.0 / period)
	var ph := _rng.randf() * TAU
	var gl := sqrt(0.5 * (1.0 - pan))
	var gr := sqrt(0.5 * (1.0 + pan))
	for i in _n:
		var t := float(i) / RATE
		var y := amp * (0.5 * sin(f1 * t) + 0.5 * sin(f2 * t)) * (0.75 + 0.25 * sin(w * t + ph))
		_l[i] += y * gl
		_r[i] += y * gr
		_s[i] += y * send


## `count` drips spread over the loop: a little rising plink and its echo in the reverb.
func _drips(count: int, amp: float, lo: float, hi: float) -> void:
	for k in count:
		var at := int((k + _rng.randf_range(0.1, 0.9)) * SECONDS / count * RATE)
		var f0 := _rng.randf_range(lo, hi)
		var a := amp * _rng.randf_range(0.5, 1.0)
		var pan := _rng.randf_range(-0.8, 0.8)
		var count_ := int(0.09 * RATE)
		var ph := 0.0
		for j in count_:
			var t := float(j) / RATE
			ph += TAU * f0 * (1.0 + 0.7 * minf(t / 0.025, 1.0)) / RATE
			var y := a * sin(ph) * exp(-t / 0.018) * minf(t / 0.001, 1.0)
			_put(at + j, y, pan, 0.9)


## Embers: `rate` clicks a second on average, short noise flicks, a little spread round a pan.
func _crackle(rate: float, amp: float, pan: float, send: float) -> void:
	var count := int(rate * SECONDS)
	for k in count:
		var at := _rng.randi_range(0, _n - 1)
		var a := amp * pow(_rng.randf(), 2.0)
		var count_ := _rng.randi_range(40, 260)
		var p := clampf(pan + _rng.randf_range(-0.3, 0.3), -1.0, 1.0)
		var last := 0.0
		for j in count_:
			var x := _rng.randf_range(-1.0, 1.0)
			var y := (x - last) * a * exp(-float(j) / (count_ * 0.3))
			last = x
			_put(at + j, y * 0.5, p, send)


## A creak of old wood: a pulse train jittering at `rate` Hz through a band at `band` Hz.
func _creak(at_s: float, seconds: float, rate: float, band: float, amp: float, pan: float) -> void:
	var at := int(at_s * RATE)
	var count_ := int(seconds * RATE)
	var ic1 := 0.0
	var ic2 := 0.0
	var g := tan(PI * band / RATE)
	var k := 1.0 / 6.0
	var a1 := 1.0 / (1.0 + g * (g + k))
	var a2 := g * a1
	var a3 := g * a2
	var next := 0.0
	for j in count_:
		var t := float(j) / RATE
		var x := 0.0
		if t >= next:
			x = 1.0
			next = t + 1.0 / (rate * _rng.randf_range(0.8, 1.25))
		var v3 := x - ic2
		var v1 := a1 * ic1 + a2 * v3
		var v2 := ic2 + a2 * ic1 + a3 * v3
		ic1 = 2.0 * v1 - ic1
		ic2 = 2.0 * v2 - ic2
		var env := sin(PI * t / seconds)
		_put(at + j, v1 * amp * env, pan, 0.5)


## A chain link touching another: three inharmonic partials, a short ring.
func _clink(at_s: float, hz: float, amp: float, pan: float) -> void:
	var at := int(at_s * RATE)
	var count_ := int(0.5 * RATE)
	for j in count_:
		var t := float(j) / RATE
		var y := amp * (sin(TAU * hz * t) * exp(-t / 0.08) + 0.6 * sin(TAU * hz * 2.76 * t) * exp(-t / 0.05)
			+ 0.3 * sin(TAU * hz * 5.4 * t) * exp(-t / 0.03))
		_put(at + j, y, pan, 0.7)


## A breath of voices: noise through two formants, swelling in and out over `seconds`.
func _whisper(at_s: float, seconds: float, amp: float, pan: float, formants: Array) -> void:
	var at := int(at_s * RATE)
	var count_ := int(seconds * RATE)
	var st := [[0.0, 0.0], [0.0, 0.0]]
	var co := []
	for f: float in formants:
		var g := tan(PI * f / RATE)
		var k := 1.0 / 8.0
		var a1 := 1.0 / (1.0 + g * (g + k))
		co.append([a1, g * a1, g * g * a1])
	for j in count_:
		var t := float(j) / RATE
		var x := _rng.randf_range(-1.0, 1.0)
		var y := 0.0
		for b in co.size():
			var c: Array = co[b]
			var s: Array = st[b]
			var v3: float = x - s[1]
			var v1: float = c[0] * s[0] + c[1] * v3
			var v2: float = s[1] + c[1] * s[0] + c[2] * v3
			s[0] = 2.0 * v1 - s[0]
			s[1] = 2.0 * v2 - s[1]
			y += v1
		var env := pow(sin(PI * t / seconds), 2.0)
		_put(at + j, y * amp * env, pan, 0.9)


## A soft low thump (a heartbeat of the stone).
func _thump(at_s: float, amp: float) -> void:
	var at := int(at_s * RATE)
	var count_ := int(0.4 * RATE)
	var ph := 0.0
	for j in count_:
		var t := float(j) / RATE
		ph += TAU * (58.0 - 18.0 * minf(t / 0.12, 1.0)) / RATE
		_put(at + j, amp * sin(ph) * exp(-t / 0.11) * minf(t / 0.008, 1.0), 0.0, 0.2)


## Adds a sample at i (wrapping round the loop) at a pan, and sends some to the reverb.
func _put(i: int, y: float, pan: float, send: float) -> void:
	var j := i % _n
	_l[j] += y * sqrt(0.5 * (1.0 - pan))
	_r[j] += y * sqrt(0.5 * (1.0 + pan))
	_s[j] += y * send


# ---------------------------------------------------------------- the room and the output

## A Freeverb-like room (the music's, tools/make_music.gd), warmed on the loop's tail so the seam is whole, then a high
## pass at about 28 Hz (two passes round the loop).
func _finish(wet: float) -> void:
	var combs := [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617]
	var aps := [556, 441, 341, 225]
	var lens := PackedInt32Array()
	for ch in 2:
		for c: int in combs:
			lens.append(int((c + 23 * ch) * 1.5))
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
	var feedback := 0.88
	var damp := 0.35
	var warm := int(6.0 * RATE)
	for step in warm + _n:
		var j := step - warm
		var src := j if j >= 0 else _n + j
		var inp := _s[src] * 0.015
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
			if j >= 0:
				if ch == 0:
					_l[j] += acc * wet * 3.0
				else:
					_r[j] += acc * wet * 3.0
	_l = _dc_block(_l)
	_r = _dc_block(_r)


func _dc_block(x: PackedFloat32Array) -> PackedFloat32Array:
	var out := x.duplicate()
	var x1 := 0.0
	var y1 := 0.0
	for pass_i in 2:
		for i in _n:
			var y := x[i] - x1 + 0.996 * y1
			x1 = x[i]
			y1 = y
			out[i] = y
	return out


## Scales the loop to RMS_DB + level (its peak at most PEAK_DB), writes the .wav in the work folder and the .ogg.
func _publish(id: StringName, level: float) -> void:
	var sq := 0.0
	var peak := 0.0
	for i in _n:
		sq += _l[i] * _l[i] + _r[i] * _r[i]
		peak = maxf(peak, maxf(absf(_l[i]), absf(_r[i])))
	var rms := sqrt(sq / (2.0 * _n))
	var gain := minf(db_to_linear(RMS_DB + level) / maxf(rms, 1e-9), db_to_linear(PEAK_DB) / maxf(peak, 1e-9))
	var bytes := PackedByteArray()
	bytes.resize(_n * 4)
	for i in _n:
		bytes.encode_s16(i * 4, clampi(int(round(_l[i] * gain * 32767.0)), -32768, 32767))
		bytes.encode_s16(i * 4 + 2, clampi(int(round(_r[i] * gain * 32767.0)), -32768, 32767))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = true
	wav.mix_rate = RATE
	wav.data = bytes
	var wav_path := "%s/%s.wav" % [_work, id]
	wav.save_to_wav(wav_path)
	var ogg := ProjectSettings.globalize_path(OUT + String(id) + ".ogg")
	var out := []
	var code := OS.execute("ffmpeg", ["-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", OGG_QUALITY, ogg], out, true)
	print("%s: peak %.1f dBFS, rms %.1f dBFS, %d KB%s" % [id, linear_to_db(peak * gain), linear_to_db(rms * gain),
		FileAccess.get_file_as_bytes(ogg).size() / 1024, "" if code == 0 else " (ffmpeg failed: %s)" % str(out)])
