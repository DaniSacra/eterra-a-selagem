class_name Synth
extends RefCounted
## Tiny synthesiser: sounds are recipes turned into 16-bit samples. Placeholder until recorded audio exists.

const RATE := 22050

enum Wave { SINE, SQUARE, SAW, NOISE, TRIANGLE }


## One voice: a wave sweeping from f0 to f1 with an attack and an exponential decay. Returns samples in -1..1.
static func tone(wave: Wave, f0: float, f1: float, seconds: float, volume: float = 0.5, attack: float = 0.005, curve: float = 4.0, rate: int = RATE) -> PackedFloat32Array:
	var n := int(seconds * rate)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	var noise := 0.0
	var seed_value := 12345
	for i in n:
		var k := float(i) / n
		var freq := lerpf(f0, f1, k)
		phase = fmod(phase + freq / rate, 1.0)
		var v := 0.0
		match wave:
			Wave.SINE:
				v = sin(phase * TAU)
			Wave.SQUARE:
				v = 1.0 if phase < 0.5 else -1.0
			Wave.SAW:
				v = phase * 2.0 - 1.0
			Wave.TRIANGLE:
				v = absf(phase * 4.0 - 2.0) - 1.0
			Wave.NOISE:
				# sample and hold: the "frequency" is how often the noise changes
				if phase < freq / rate:
					seed_value = (seed_value * 1103515245 + 12345) & 0x7fffffff
					noise = float(seed_value) / 0x3fffffff - 1.0
				v = noise
		var env := minf(float(i) / maxf(attack * rate, 1.0), 1.0) * exp(-curve * k)
		out[i] = v * env * volume
	return out


## Adds b into a starting at an offset (seconds), growing a when needed.
static func mix(a: PackedFloat32Array, b: PackedFloat32Array, at: float = 0.0, rate: int = RATE) -> PackedFloat32Array:
	var start := int(at * rate)
	if a.size() < start + b.size():
		a.resize(start + b.size())
	for i in b.size():
		a[start + i] += b[i]
	return a


static func to_stream(samples: PackedFloat32Array, loop: bool = false, rate: int = RATE) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo = false
	s.data = bytes
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_end = samples.size()
	return s


static func note(semitones_from_a2: int) -> float:
	return 110.0 * pow(2.0, semitones_from_a2 / 12.0)
