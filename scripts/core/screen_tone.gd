class_name ScreenTone
## What a colour drawn in the 3D world ends up as on the screen, in the desktop renderer (Forward+): the game's
## exposure, Godot's filmic curve (white 1.0), the sRGB encoding, then the contrast and saturation of Game._build_world
## (GP-01 of cycle C12c: a cap of 1.0 in the material is not 1.0 on the screen; exposure 1.25 and the filmic curve take
## 1.0 to white, and saturation 1.3 pushes a colour's strongest channel past it). Below the glow threshold only (the
## glow adds on top). Checked against the GPU by tools/tone_probe.gd. Pure, no nodes.

## The brightest a light that must keep its colour may reach on the screen (0..255 of the strongest channel).
const SCREEN_MAX := 235
## What the caps aim at: SCREEN_MAX less what the glow's bloom (glow_bloom 0.03) and a neighbour's halo add on top
## (measured on the GPU: up to 3 to 5).
const SAFE := 226
## Defaults: Game.EXPOSURE, Game.ADJUST_CONTRAST, Game.ADJUST_SATURATION (kept in step by tests/test_screen_tone.gd).
const EXPOSURE := 1.25
const CONTRAST := 1.05
const SATURATION := 1.3
const WHITE := 1.0


## The screen colour (0..1 each, clamped) of a colour written by a material. srgb: given as a material's colour
## (albedo_color, a source_color uniform: decoded to linear first); false: already linear (a shader's own math).
static func of(c: Color, srgb: bool = true, exposure: float = EXPOSURE) -> Color:
	var lin := Vector3(c.r, c.g, c.b)
	if srgb:
		lin = Vector3(_to_linear(c.r), _to_linear(c.g), _to_linear(c.b))
	return of_linear(lin * exposure)


## The screen colour of a linear colour already times the exposure.
static func of_linear(v: Vector3) -> Color:
	var w := _filmic(WHITE)
	var s := Vector3(_to_srgb(_filmic(v.x) / w), _to_srgb(_filmic(v.y) / w), _to_srgb(_filmic(v.z) / w))
	s = (s - Vector3.ONE * 0.5) * CONTRAST + Vector3.ONE * 0.5
	var avg := (s.x + s.y + s.z) / 3.0
	s = Vector3.ONE * avg + (s - Vector3.ONE * avg) * SATURATION
	return Color(clampf(s.x, 0, 1), clampf(s.y, 0, 1), clampf(s.z, 0, 1))


## The strongest channel of c on the screen, 0..255.
static func peak8(c: Color, srgb: bool = true) -> int:
	var s := of(c, srgb)
	return roundi(maxf(s.r, maxf(s.g, s.b)) * 255.0)


## c scaled down (hue kept) until its strongest channel on the screen is at most limit (0..255).
static func fit(c: Color, limit: int = SAFE, srgb: bool = true) -> Color:
	if peak8(c, srgb) <= limit:
		return c
	var lo := 0.0
	var hi := 1.0
	for i in 24:
		var k := (lo + hi) * 0.5
		if peak8(Color(c.r * k, c.g * k, c.b * k), srgb) <= limit:
			lo = k
		else:
			hi = k
	return Color(c.r * lo, c.g * lo, c.b * lo, c.a)


## The brightest channel (linear, before the exposure) a light of colour c may have (hue kept) and still reach at most
## limit (0..255) on the screen. c as a material's colour (sRGB, any brightness: only its hue counts).
static func linear_peak(c: Color, limit: int = SAFE) -> float:
	var lin := Vector3(_to_linear(maxf(c.r, 0)), _to_linear(maxf(c.g, 0)), _to_linear(maxf(c.b, 0)))
	var top := maxf(lin.x, maxf(lin.y, lin.z))
	if top <= 0.0:
		return 1.0
	lin /= top
	var lo := 0.0
	var hi := 4.0
	for i in 24:
		var k := (lo + hi) * 0.5
		if _peak8_linear(lin * k * EXPOSURE) <= limit:
			lo = k
		else:
			hi = k
	return lo


static func _peak8_linear(v: Vector3) -> int:
	var s := of_linear(v)
	return roundi(maxf(s.r, maxf(s.g, s.b)) * 255.0)


static func _filmic(x: float) -> float:
	x = maxf(x, 0.0)
	const BIAS := 2.0
	const A := 0.22 * BIAS * BIAS
	const B := 0.30 * BIAS
	const C := 0.10
	const D := 0.20
	const E := 0.01
	const F := 0.30
	return (x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F) - E / F


static func _to_linear(s: float) -> float:
	return s / 12.92 if s <= 0.04045 else pow((s + 0.055) / 1.055, 2.4)


static func _to_srgb(l: float) -> float:
	l = maxf(l, 0.0)
	return l * 12.92 if l <= 0.0031308 else 1.055 * pow(l, 1.0 / 2.4) - 0.055
