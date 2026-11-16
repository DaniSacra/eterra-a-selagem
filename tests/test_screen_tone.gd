extends GutTest
## GP-01 and B-1 of cycle C12c, on the screen, not on the parameter: what a column of light and a door's gem reach on
## the screen once the game's tone (exposure 1.25, filmic, contrast 1.05, saturation 1.3) has turned them into pixels.
## ScreenTone models that; MEASURED is what the GPU gave for known colours (tools/tone_probe.gd, RTX 5060, Forward+,
## 2026-11-16), so the model the caps rest on is itself checked.

## Unshaded colour (as a material's colour) -> the pixel the GPU drew (tools/tone_probe.gd).
const MEASURED := [
	[Color(0.2, 0.2, 0.2), Color8(69, 69, 69)],
	[Color(0.4, 0.4, 0.4), Color8(148, 148, 148)],
	[Color(0.6, 0.6, 0.6), Color8(209, 209, 209)],
	[Color(0.7, 0.7, 0.7), Color8(231, 231, 231)],
	[Color(0.8, 0.8, 0.8), Color8(249, 249, 249)],
	[Color(0.9, 0.9, 0.9), Color8(255, 255, 255)],
	[Color(1.0, 0.45, 0.4), Color8(255, 157, 134)],
	[Color(0.55, 0.8, 1.0), Color8(183, 251, 255)],
	[Color(1.0, 0.85, 0.3), Color8(255, 255, 79)],
	[Color(0.8, 0.35, 0.3), Color8(255, 120, 94)],
	[Color(0.4, 0.6, 0.8), Color8(132, 211, 255)],
	[Color(0.7, 0.6, 0.2), Color8(249, 221, 39)],
	[Color(0.6, 0.25, 0.2), Color8(235, 80, 53)],
	[Color(0.3, 0.9, 0.5), Color8(88, 255, 181)],
]
## How far the model may be from the GPU (the glow's bloom adds a little on top).
const SLACK := 5


func test_the_model_matches_what_the_gpu_drew() -> void:
	for pair: Array in MEASURED:
		var want: Color = pair[1]
		var got := ScreenTone.of(pair[0])
		for ch in 3:
			assert_almost_eq(got[ch] * 255.0, want[ch] * 255.0, float(SLACK), "%s channel %d" % [pair[0], ch])


func test_the_model_uses_the_games_tone() -> void:
	assert_eq(ScreenTone.EXPOSURE, Game.EXPOSURE)
	assert_eq(ScreenTone.EXPOSURE, Game.COMPAT_EXPOSURE, "the browser's exposure too")
	assert_eq(ScreenTone.CONTRAST, Game.ADJUST_CONTRAST)
	assert_eq(ScreenTone.SATURATION, Game.ADJUST_SATURATION)
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var env: Environment = null
	for c in game.get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	assert_not_null(env)
	assert_eq(env.tonemap_mode, Environment.TONE_MAPPER_FILMIC)
	assert_almost_eq(env.tonemap_white, ScreenTone.WHITE, 0.0001)
	assert_almost_eq(env.tonemap_exposure, ScreenTone.EXPOSURE, 0.0001)
	assert_almost_eq(env.adjustment_saturation, ScreenTone.SATURATION, 0.0001)


## What made them white: 1.0 in a material is white on the screen, and the old gem colours bit 255.
func test_a_cap_of_one_was_white_on_the_screen() -> void:
	assert_eq(ScreenTone.peak8(Color.WHITE), 255)
	assert_eq(ScreenTone.peak8(Color(1.0, 0.45, 0.38)), 255, "a channel at 1.0 is 255 whatever the hue")
	assert_gt(ScreenTone.peak8(Color(0.8, 0.35, 0.3)), 250, "saturation pushes the strongest channel up")


## The light a column may write at its brightest (beam.gdshader: hue kept, scaled to `cap`), for every colour a column
## takes in the game, stays under SCREEN_MAX on the screen and keeps its hue (not white).
func test_every_column_colour_stays_under_235_and_keeps_its_hue() -> void:
	var colors: Array[Color] = [Combat.LIGHT, Color(3, 3, 3), Color(3, 1, 0.3), Color(0.3, 0.6, 3.0)]
	for r in RunMap.Reward.values():
		colors.append(Rooms._reward_color(r))
	for k in RunMap.Kind.values():
		colors.append(Rooms._kind_color(k))
	for c in colors:
		var peak := ScreenTone.linear_peak(c)
		var lin := _linear(c)
		var top := maxf(lin.x, maxf(lin.y, lin.z))
		# the brightest the shader writes, on its own and with its sides whitened (mix toward white, same peak)
		for w in [0.0, 0.25, 1.0]:
			var v := lin / top
			v = v.lerp(Vector3.ONE, float(w) * 0.25)
			v = v / maxf(v.x, maxf(v.y, v.z)) * peak
			var s := ScreenTone.of_linear(v * ScreenTone.EXPOSURE)
			assert_lte(roundi(maxf(s.r, maxf(s.g, s.b)) * 255.0), ScreenTone.SCREEN_MAX, "%s on the screen" % c)
		var s0 := ScreenTone.of_linear(lin / top * peak * ScreenTone.EXPOSURE)
		if c.s > 0.3:
			assert_gt(s0.s, 0.3, "%s keeps its colour on the screen (%s)" % [c, s0])
			assert_almost_eq(s0.h, Color(c.r, c.g, c.b).h, 0.08, "%s keeps its hue" % c)


## Laid over what is behind it (blend_premul_alpha, alpha = light / cap), a column never takes the screen past its
## cap, its two faces over each other, over a floor or a paladin as bright as the cap.
func test_a_column_over_anything_never_sums_past_its_cap() -> void:
	var code := (load("res://assets/shaders/beam.gdshader") as Shader).code
	assert_true(code.contains("blend_premul_alpha"), "laid over, not added")
	assert_false(code.contains("blend_add"))
	assert_true(code.contains("ALPHA = clamp(peak / max(cap"), "it covers in the measure of its light")
	var cap := 0.7
	for light in [0.0, 0.2, 0.5, 0.7, 2.5]:
		for behind in [0.0, 0.3, 0.7]:
			var out := float(behind)
			for face in 2:
				var l := minf(float(light), cap)
				out = l + out * (1.0 - l / cap)
			assert_lte(out, cap + 0.0001, "light %s over %s" % [light, behind])


## Fx.beam hands the shader the cap of its colour; default share 1.0 of it.
func test_fx_beam_hands_the_shader_the_screen_cap_of_its_colour() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var gold := Rooms._reward_color(RunMap.Reward.BOON)
	game.fx.beam(Vector2(3, 3), gold)
	assert_almost_eq(float(game.fx.last_beam.peak), ScreenTone.linear_peak(gold), 0.0001)
	assert_lt(float(game.fx.last_beam.peak), 1.0, "under the old 1.0, which was white")
	var mat: ShaderMaterial = null
	for b: Dictionary in game.fx._beams:
		if (b.node as MeshInstance3D).position.is_equal_approx(Vector3(3, 4.5, 3)):
			mat = b.mat
	assert_not_null(mat, "the column stands there")
	assert_almost_eq(float(mat.get_shader_parameter(&"cap")), ScreenTone.linear_peak(gold), 0.0001)


## B-1: every gem (rewards, door kinds) under SCREEN_MAX on the screen, with its colour.
func test_every_gem_stays_under_235_on_the_screen() -> void:
	var colors: Array[Color] = []
	for r in RunMap.Reward.values():
		colors.append(Rooms._reward_color(r))
	for k in RunMap.Kind.values():
		colors.append(Rooms._kind_color(k))
	for c in colors:
		var g := Rooms.gem_color(c)
		assert_lte(ScreenTone.peak8(g), ScreenTone.SAFE, "gem %s" % c)
		if c.s > 0.3:
			assert_gt(ScreenTone.of(g).s, 0.3, "gem %s keeps its colour" % c)


## The slow motion's lift of the bright parts (screen.gdshader) never takes a pixel past SCREEN_MAX.
func test_the_slow_motions_lift_stays_under_235() -> void:
	var code := (load("res://assets/shaders/screen.gdshader") as Shader).code
	var at := code.find("uniform float lift_ceiling = ")
	assert_gt(at, -1)
	var value := float(code.substr(at + "uniform float lift_ceiling = ".length(), 5).split(";")[0])
	assert_lte(roundi(value * 255.0), ScreenTone.SCREEN_MAX)
	assert_true(code.contains("min(c + c * c * radial * 0.5, max(c, vec3(lift_ceiling)))"))


func _linear(c: Color) -> Vector3:
	return Vector3(_l(c.r), _l(c.g), _l(c.b))


func _l(s: float) -> float:
	return s / 12.92 if s <= 0.04045 else pow((s + 0.055) / 1.055, 2.4)
