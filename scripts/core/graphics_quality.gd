class_name GraphicsQuality
extends RefCounted
## "Qualidade gráfica" (E6, DT-003): Alta, Média, Baixa, the save's option "quality" (0, 1, 2; Alta by default, the
## look the art was made for). Each level is a row of settings: the 3D resolution scale, MSAA, the screen effects
## of the Forward+ (fog in the air, contact shadows, reflections on the wet floor; the browser's renderer has none of
## them anyway) and the shadow maps. The glow stays on at every level: the fires, the portal and the Emeth are read
## by it. App.apply_options puts the viewport's part, Game.apply_options the environment's. `--quality=alta|media|
## baixa` (or 0, 1, 2) overrides the save for one run (measurements, tools/gpu.sh). Numbers in docs/qa/e6_audio_perf.md.

const HIGH := 0
const MEDIUM := 1
const LOW := 2
const NAMES: Array[String] = ["alta", "media", "baixa"]
## The text of each level (data/text_pt.tres).
const TEXT: Array[StringName] = [&"opt_quality_high", &"opt_quality_medium", &"opt_quality_low"]
const LEVELS := [
	{"scale": 1.0, "msaa": Viewport.MSAA_2X, "volumetric_fog": true, "ssao": true, "ssr": true,
		"shadow_atlas": 4096, "sun_shadow": 4096, "soft_shadows": RenderingServer.SHADOW_QUALITY_SOFT_LOW},
	{"scale": 0.85, "msaa": Viewport.MSAA_2X, "volumetric_fog": false, "ssao": true, "ssr": false,
		"shadow_atlas": 2048, "sun_shadow": 2048, "soft_shadows": RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW},
	{"scale": 0.5, "msaa": Viewport.MSAA_DISABLED, "volumetric_fog": false, "ssao": false, "ssr": false,
		"shadow_atlas": 1024, "sun_shadow": 1024, "soft_shadows": RenderingServer.SHADOW_QUALITY_HARD},
]


static func clamp_level(level: int) -> int:
	return clampi(level, HIGH, LOW)


## The level in use: --quality on the command line, else the save's.
static func current(saved: int) -> int:
	if Dev.has("quality"):
		var a := Dev.arg("quality").to_lower()
		var i := NAMES.find(a.replace("é", "e"))
		return clamp_level(i if i >= 0 else int(a))
	return clamp_level(saved)


## A level's row; for measuring, `--gfx-<key>=value` overrides one setting (e.g. --gfx-shadow_atlas=0, --gfx-scale=0.5).
static func settings(level: int) -> Dictionary:
	var s: Dictionary = LEVELS[clamp_level(level)]
	for key: String in s:
		if Dev.has("gfx-" + key):
			s = s.duplicate()
			s[key] = (Dev.arg("gfx-" + key) == "1") if s[key] is bool else type_convert(float(Dev.arg("gfx-" + key)), typeof(s[key]))
	return s


## The viewport's part: resolution scale (FSR 1 on the Forward+ under 1.0, bilinear on the browser's renderer),
## MSAA, the shadow maps.
static func apply_viewport(vp: Viewport, level: int) -> void:
	var s := settings(level)
	var forward := RenderingServer.get_current_rendering_method() != "gl_compatibility"
	vp.scaling_3d_scale = s.scale
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if forward and s.scale < 1.0 else Viewport.SCALING_3D_MODE_BILINEAR
	vp.msaa_3d = s.msaa
	vp.positional_shadow_atlas_size = s.shadow_atlas
	RenderingServer.directional_shadow_atlas_set_size(s.sun_shadow, true)
	RenderingServer.directional_soft_shadow_filter_set_quality(s.soft_shadows)
	RenderingServer.positional_soft_shadow_filter_set_quality(s.soft_shadows)


## The environment's part (only where the renderer has them: fog in the air and reflections are Forward+ only).
static func apply_environment(e: Environment, level: int) -> void:
	if e == null:
		return
	var s := settings(level)
	var forward := RenderingServer.get_current_rendering_method() != "gl_compatibility"
	e.volumetric_fog_enabled = forward and s.volumetric_fog
	e.ssao_enabled = s.ssao
	e.ssr_enabled = forward and s.ssr
