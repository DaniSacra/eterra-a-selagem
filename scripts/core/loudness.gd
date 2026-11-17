class_name Loudness
extends RefCounted
## Loudness of a stereo mix, offline (E6, C15-01; tools/mix_probe.gd, tests/test_mix.gd): integrated loudness in
## LUFS by ITU-R BS.1770-4 / EBU R128 (K-weighting, 400 ms blocks every 100 ms, absolute gate -70 LUFS, relative
## gate -10 LU), the true peak in dBTP (4 times oversampled by a windowed sinc, BS.1770 annex 2), and a model of the
## Master's hard limiter (Audio.limit_master) that tells how often it works.

const RATE := 44100.0


## The two K-weighting biquads (high shelf, then high pass) for a sample rate, as [b0, b1, b2, a1, a2] each.
static func k_filters(rate: float = RATE) -> Array:
	var k := tan(PI * 1681.974450955533 / rate)
	var q := 0.7071752369554196
	var vh := pow(10.0, 3.999843853973347 / 20.0)
	var vb := pow(vh, 0.4996667741545416)
	var a0 := 1.0 + k / q + k * k
	var shelf := [(vh + vb * k / q + k * k) / a0, 2.0 * (k * k - vh) / a0, (vh - vb * k / q + k * k) / a0,
		2.0 * (k * k - 1.0) / a0, (1.0 - k / q + k * k) / a0]
	k = tan(PI * 38.13547087602444 / rate)
	q = 0.5003270373238773
	a0 = 1.0 + k / q + k * k
	var high := [1.0, -2.0, 1.0, 2.0 * (k * k - 1.0) / a0, (1.0 - k / q + k * k) / a0]
	return [shelf, high]


## The mean square of the K-weighted signal summed over both channels, per 100 ms (BS.1770 builds its 400 ms blocks
## from four of these).
static func k_power(x: PackedVector2Array, rate: float = RATE) -> PackedFloat32Array:
	var f := k_filters(rate)
	var s: Array = f[0]
	var h: Array = f[1]
	var hop := int(rate * 0.1)
	var out := PackedFloat32Array()
	out.resize(x.size() / hop)
	for ch in 2:
		var x1 := 0.0
		var x2 := 0.0
		var y1 := 0.0
		var y2 := 0.0
		var z1 := 0.0
		var z2 := 0.0
		var w1 := 0.0
		var w2 := 0.0
		var acc := 0.0
		for i in out.size() * hop:
			var v: float = x[i][ch]
			var y: float = s[0] * v + s[1] * x1 + s[2] * x2 - s[3] * y1 - s[4] * y2
			x2 = x1
			x1 = v
			y2 = y1
			y1 = y
			var w: float = y - 2.0 * z1 + z2 - h[3] * w1 - h[4] * w2
			z2 = z1
			z1 = y
			w2 = w1
			w1 = w
			acc += w * w
			if (i + 1) % hop == 0:
				out[i / hop] += acc / hop
				acc = 0.0
	return out


## Integrated loudness, LUFS (-70 or lower for silence).
static func integrated(x: PackedVector2Array, rate: float = RATE) -> float:
	return integrated_of(k_power(x, rate))


static func integrated_of(power: PackedFloat32Array) -> float:
	var blocks := PackedFloat32Array()
	for i in range(3, power.size()):
		blocks.append((power[i] + power[i - 1] + power[i - 2] + power[i - 3]) * 0.25)
	var gated := _gate(blocks, db_to_power(-70.0))
	if gated.is_empty():
		return -70.0
	var rel := _mean(gated) * db_to_power(-10.0)
	var final := _gate(gated, rel)
	return lufs(_mean(final)) if not final.is_empty() else -70.0


## The loudest short-term loudness (3 s), LUFS.
static func short_term_max(power: PackedFloat32Array) -> float:
	var best := 0.0
	for i in range(29, power.size()):
		var sum := 0.0
		for k in 30:
			sum += power[i - k]
		best = maxf(best, sum / 30.0)
	return lufs(best)


static func lufs(mean_square: float) -> float:
	return -0.691 + 10.0 * log(maxf(mean_square, 1e-12)) / log(10.0)


static func db_to_power(l: float) -> float:
	return pow(10.0, (l + 0.691) / 10.0)


static func _gate(blocks: PackedFloat32Array, floor_: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for b in blocks:
		if b > floor_:
			out.append(b)
	return out


static func _mean(a: PackedFloat32Array) -> float:
	var sum := 0.0
	for v in a:
		sum += v
	return sum / maxf(a.size(), 1.0)


## The true peak in dBTP: the sample peak, and 4 times between samples by a 48-tap windowed sinc where the signal is
## within 6 dB of its top (the rest cannot exceed it by that much).
static func true_peak(x: PackedVector2Array) -> float:
	var top := 0.0
	for v in x:
		top = maxf(top, maxf(absf(v.x), absf(v.y)))
	var taps := _sinc_taps()
	var peak := top
	for i in range(6, x.size() - 6):
		for ch in 2:
			if absf(x[i][ch]) < top * 0.5:
				continue
			for p in 3:
				var y := 0.0
				for k in 12:
					y += x[i - 5 + k][ch] * taps[p][k]
				peak = maxf(peak, absf(y))
	return linear_to_db(peak + 1e-12)


## The three in-between phases (1/4, 2/4, 3/4 of the way from sample i to i + 1): 12 taps each over i - 5 .. i + 6.
static func _sinc_taps() -> Array:
	var out := []
	for p in 3:
		var frac := (p + 1) * 0.25
		var t := []
		var sum := 0.0
		for k in 12:
			var d := float(k - 5) - frac
			var w := 0.5 + 0.5 * cos(PI * d / 6.5)
			var v := w * (1.0 if absf(d) < 1e-6 else sin(PI * d) / (PI * d))
			t.append(v)
			sum += v
		for k in 12:
			t[k] = t[k] / sum
		out.append(t)
	return out


## A model of the Master's hard limiter (both channels together): the gain is at most ceiling over the peak of the
## next 5 ms and comes back at its release. Returns [the limited signal, the gain reduction in dB per 100 ms window
## (its deepest)].
static func limit(x: PackedVector2Array, ceiling_db: float, release: float, rate: float = RATE) -> Array:
	var ceiling := db_to_linear(ceiling_db)
	var look := int(0.005 * rate)
	var blocks := PackedFloat32Array()
	blocks.resize(x.size() / look + 2)
	blocks.fill(0.0)
	for i in x.size():
		var b := i / look
		blocks[b] = maxf(blocks[b], maxf(absf(x[i].x), absf(x[i].y)))
	var out := x.duplicate()
	var hop := int(rate * 0.1)
	var reduction := PackedFloat32Array()
	reduction.resize(x.size() / hop + 1)
	reduction.fill(0.0)
	var gain := 1.0
	var back := 1.0 / (release * rate)
	for i in x.size():
		var b := i / look
		var need := minf(1.0, ceiling / maxf(maxf(blocks[b], blocks[b + 1]), 1e-9))
		gain = need if need < gain else minf(need, gain + back)
		out[i] = x[i] * gain
		reduction[i / hop] = maxf(reduction[i / hop], -linear_to_db(gain))
	return [out, reduction]


## How many 100 ms windows the limiter takes more than `db` off.
static func windows_over(reduction: PackedFloat32Array, db: float) -> int:
	var n := 0
	for r in reduction:
		if r > db:
			n += 1
	return n
