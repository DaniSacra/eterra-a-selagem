class_name WorldAir
extends RefCounted
## The air of the world, shared by the run (Game) and the hub (HUB-01, HUB-B1): the WorldEnvironment (sky, ambient,
## tone map, glow, fog, the desktop's volumetric fog, contact shadows and reflections) and the moon, dressed for the
## visual profile (its one owner: RoomMood, DT-RS1). It was inline in Game._build_world; the numbers did not change (Game
## keeps its constants as names of these, read by the tests and the scenery).
##   var air := WorldAir.build(self)   # adds the WorldEnvironment and the moon under self
##   air.env.environment               # the Environment (GraphicsQuality.apply_environment, ArenaRoom's air)

## The browser's renderer (GL Compatibility) lights brighter than the desktop's (Forward+): its exposure and ambient.
const COMPAT_EXPOSURE := 1.25
const COMPAT_AMBIENT := 0.4
## The air of the hall (the reference image): cold teal behind and below, a low teal ambient, no violet in the air
## (the violet comes from the abyss lights). Fog by depth starts past the hall; height fog fills the abyss.
const SKY := Color(0.11, 0.2, 0.24)
const AMBIENT := Color(0.3, 0.4, 0.46)
const AMBIENT_ENERGY := 0.9
const EXPOSURE := 1.25
const FOG := Color(0.11, 0.2, 0.24)
const FOG_BEGIN := 64.0
const FOG_END := 170.0
const FOG_HEIGHT := -3.0
const FOG_HEIGHT_DENSITY := 0.6
const VOLUMETRIC_DENSITY := 0.0
## Glow: only colours over the threshold bloom (blades and slashes go past 2, fire tongues stay under 2), weight of
## each glow level (the widest, 4, kept low so fires and the portal have no big halo).
const GLOW_INTENSITY := 0.45
const GLOW_THRESHOLD := 1.3
const GLOW_LEVELS: Array[float] = [0.0, 1.0, 1.0, 1.0, 0.3, 0.0, 0.0]
## Contact shadows (desktop): corners and the feet of every piece dark, also where light falls.
const SSAO_RADIUS := 1.0
const SSAO_INTENSITY := 3.0
const SSAO_LIGHT_AFFECT := 0.2
## Colour adjustment after the tone map. Contrast over 1 cuts every value under 0.5 - 0.5 / contrast to black (1.12
## crushed the darkest teal to pure black and so to full saturation): kept low, the shadows keep their colour.
const ADJUST_CONTRAST := 1.05
const ADJUST_SATURATION := 1.3

var env: WorldEnvironment
var moon: DirectionalLight3D
## The owner of the air (DT-RS1): every room's air, the look's and Morvath's mood go through it.
var mood: RoomMood


## Builds the world's air under parent (the WorldEnvironment first, then the moon, as the run always had them).
static func build(parent: Node) -> WorldAir:
	var air := WorldAir.new()
	air.env = WorldEnvironment.new()
	var e := Environment.new()
	# the catacomb hall of the reference image (2026-11-14): a cold, dark teal air; the warmth comes only from fire
	# and candles, the green from the portal, the violet from the depths
	e.background_mode = Environment.BG_COLOR
	e.background_color = SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = AMBIENT
	e.ambient_light_energy = AMBIENT_ENERGY
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = EXPOSURE
	e.glow_enabled = true
	e.glow_intensity = GLOW_INTENSITY
	e.glow_strength = 1.0
	e.glow_bloom = 0.03
	e.glow_hdr_threshold = GLOW_THRESHOLD
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	# the fires and the portal keep their shape: the widest level only a little, so no big halo washes the stone
	for i in 7:
		e.set_glow_level(i, GLOW_LEVELS[i])
	# haze only past the hall (by depth from the camera), and a height fog filling the abyss below the floor: the
	# depths turn to teal mist, the hall itself stays clear
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_DEPTH
	e.fog_light_color = FOG
	e.fog_depth_begin = FOG_BEGIN
	e.fog_depth_end = FOG_END
	e.fog_depth_curve = 1.0
	e.fog_height = FOG_HEIGHT
	e.fog_height_density = FOG_HEIGHT_DENSITY
	e.fog_aerial_perspective = 0.2
	# desktop (Forward+) only, ignored by the browser's renderer: a little light in the air around the fires and the
	# portal (no ambient in it: it would lift every black), contact shadows, the wet floor mirroring the light (fog in
	# the air and reflections only switched on there: the browser's renderer warns in the log for each, BUG-011)
	var forward := RenderingServer.get_current_rendering_method() != "gl_compatibility"
	e.volumetric_fog_enabled = forward
	e.volumetric_fog_density = VOLUMETRIC_DENSITY
	e.volumetric_fog_albedo = Color(0.7, 0.72, 0.78)
	e.volumetric_fog_emission = Color.BLACK
	e.volumetric_fog_gi_inject = 0.0
	e.volumetric_fog_length = 90.0
	e.volumetric_fog_ambient_inject = 0.0
	e.ssao_enabled = true
	e.ssao_radius = SSAO_RADIUS
	e.ssao_intensity = SSAO_INTENSITY
	e.ssao_light_affect = SSAO_LIGHT_AFFECT
	e.ssr_enabled = forward
	e.ssr_max_steps = 48
	e.adjustment_enabled = true
	e.adjustment_contrast = ADJUST_CONTRAST
	e.adjustment_saturation = ADJUST_SATURATION
	if not forward:
		# the browser's renderer has no fog in the air nor contact shadows and lights the stone brighter: darker
		# exposure and ambient so it keeps the desktop's mood
		e.tonemap_exposure = COMPAT_EXPOSURE
		e.ambient_light_energy = COMPAT_AMBIENT
	air.env.environment = e
	parent.add_child(air.env)
	air.moon = DirectionalLight3D.new()
	# a cold light from high behind the hall (north-west), rimming the stone and the fighters
	air.moon.rotation_degrees = Vector3(-50, 150, 0)
	air.moon.light_color = Color(0.5, 0.75, 0.85)
	air.moon.light_energy = 0.35
	air.moon.shadow_enabled = true
	air.moon.directional_shadow_max_distance = 90.0
	air.moon.light_volumetric_fog_energy = 0.3
	parent.add_child(air.moon)
	# the one owner of the air (RoomMood, DT-RS1): these numbers are the world's classic air, the stylized proof's
	# its stylized one (VisualProfile.world_values); rooms and moods go over them there, the look in use on top
	air.mood = RoomMood.own(air.env, air.moon)
	VisualProfile.set_look(VisualProfile.current())
	return air


## The options' screen effects (graphics quality) on this air.
func apply_quality() -> void:
	GraphicsQuality.apply_environment(env.environment, GraphicsQuality.current(int(Save.option("quality"))))
