class_name ArrivalScene
extends Node3D
## The Guerreiro's arrival (SW-O1, docs/design/onboarding_sw_o.md; ArrivalTimeline is its clock): black, a star, a comet of
## the light of Elun falling slantwise onto the birth spot (PT-25-7: a head and a tail of soft quads, no beam) and landing in
## a flash, a ring of light over the floor, a ring of dust and a little shake; the seal's ring of runes (ritual_rune.gdshader, the steady
## circle) opening from the middle, Emeth's crystals (crystal_spike.gdshader) rising round it, sparks (SpectralMotes,
## GATHER) running from them to the spot, and the Guerreiro forming in its light from the floor up (arrival_form.gdshader on
## his own materials, for 0.4 s). Then the light goes out, the crystals stay as scenery, the room's light comes up and
## he walks; a line shows at the foot of the screen (the HUD's ArrivalCaption). Only what the game already has: no
## light, no particle system, one shader (the hero's), the rest drawn by materials the hall already warms.
##
## Use (the descent's first arrival, Rooms):
##   var scene := ArrivalScene.new()
##   game.add_child(scene)
##   scene.play(game, ArrivalScene.birth_spot(game.arena))
##   await scene.finished        # the hero may move (second 4.0); a press after 1.0 s skips to there (skip())
## While it runs the hero is parked on `at`, unseen and unhurtable, and the HUD is hidden (the cover is above it). The
## crystals stay in the node: free it with the room. Dev: --arrival plays it at the start of the first room;
## --arrival-hold=SECONDS freezes its clock there (for captures of one moment).

signal finished

## The cover's layer (above the HUD's 5), the star's size (px) and how it pulses.
const LAYER := 50
const STAR_CORE := 3.5
const STAR_HALO := 40.0
const STAR_PULSE_HZ := 0.6
const STAR_IVORY := Color(1.0, 0.94, 0.82)
const STAR_EMERALD := Color(0.3, 1.0, 0.55)
## Where the star is in the screen (its middle) until the comet takes its place.
const STAR_HOME := Vector2(0.5, 0.5)
## The room's light at its darkest, as the world's brightness adjustment (1 is as it is).
const DIM_BRIGHTNESS := 0.7
## The light of Elun is gold and warm.
const BEAM_TINT := Color(1.0, 0.78, 0.34)
## PT-25-7, the comet: it comes from COMET_UP m over the spot and COMET_SIDE m to the screen's left (along the camera's
## right), falls with its speed growing (the path share is progress to this power) and ends at COMET_END m. Its head is a
## soft quad (m, light) and its tail TAIL_COUNT quads along the path, TAIL_STEP of the fall apart, thinner and fainter.
const COMET_UP := 8.0
const COMET_SIDE := 7.0
const COMET_END := 0.9
const COMET_EASE := 1.4
const HEAD_SIZE := 1.0
const HEAD_LIGHT := 0.9
## Art review 2026-11-26 (8): the head is a small white-hot core (m, light) inside a faint gold halo (HEAD_SIZE, HEAD_LIGHT),
## never one even disc; loose sparks leave the tail: how many, how far behind the head (fall share), how far they drift
## to the side and down (m), their size (m) and light.
const CORE_SIZE := 0.3
const CORE_LIGHT := 1.5
const SPARKS := 8
const SPARK_BACK := Vector2(0.05, 0.4)
const SPARK_DRIFT := 0.55
const SPARK_SIZE := 0.12
const SPARK_LIGHT := 0.8
const TAIL_COUNT := 14
const TAIL_STEP := 0.045
const TAIL_SIZE := 1.1
const TAIL_LIGHT := 0.75
## The landing: the screen's flash (alpha at most), the floor ring's radius (m) and height, the light that stays round
## the hero (size m, light, its breathing), the shake (Fx.shake amount) and the ring of dust (count, life s, speed, size m).
const FLASH_ALPHA := 0.5
const SHOCK_RADIUS := 3.4
const SHOCK_Y := 0.09
const POOL_SIZE := 3.0
const POOL_LIGHT := 0.4
const POOL_Y_AT := 0.25
const SHAKE := 1.2
const DUST_COUNT := 44
const DUST_LIFE := 1.1
const DUST_SPEED := 4.5
const DUST_SIZE := 0.16
const DUST_GAIN := 0.75
## The seal: radius (m) of the ring of runes, its colour (old gold), strength and the share it opens from.
const RING_RADIUS := 2.2
const RING_COLOR := Color(0.72, 0.55, 0.25)
const RING_GLOW := Color(0.85, 0.72, 0.45)
const RING_STRENGTH := 0.9
const RING_FROM := 0.3
const RING_Y := 0.07
## The crystals: how many, how far from the middle (m), their height range (m), radius (m), lean (rad), the colour and
## the share of the screen's ceiling they reach (like the hero's Judgement Cut).
const CRYSTALS := 5
const CRYSTAL_RING := 2.5
const CRYSTAL_TALL := Vector2(1.2, 2.0)
const CRYSTAL_THICK := 0.42
const CRYSTAL_LEAN := 0.14
const CRYSTAL_TURN := 0.31
const CRYSTAL_SCREEN := 215
## The sparks: per crystal, size (m), light, height they end at (m), how much they spread round the crystal (m).
const MOTES_EACH := 6
const MOTES_SIZE := 0.16
const MOTES_LIGHT := 1.2
const MOTES_END := 1.3
const MOTES_SPREAD := 0.25
## The crystals' own light: a brighter peak, paler edges and a lit deep face, so they are not flat green.
## Art review 2026-11-26 (9): the crystals took the flat emerald; they are the light of Elun, amber and gold, upright.
const CRYSTAL_COLOR := Color(1.0, 0.7, 0.28)
const CRYSTAL_GAIN := 1.2
const CRYSTAL_DEEP := 0.28
const CRYSTAL_EDGE := 1.0
## Sweep 2026-11-25 (item 2): the crystals' own glow, so they are not one flat green: a soft halo round each (size in m,
## colour share) and one green light over the ring's floor (energy, reach in m, height in m), all following the glow.
const CRYSTAL_HALO := 1.7
const CRYSTAL_HALO_ALPHA := 0.16
const CRYSTAL_LIGHT := Vector3(0.9, 4.5, 1.2)
## The birth spot's clearance (m): no stone, balustrade or floor edge nearer than this (the crystals stand at
## CRYSTAL_RING and are as thick as CRYSTAL_THICK), and how far along the way to the room's middle it is looked for (m).
const CLEAR_RADIUS := 3.2
const CLEAR_STEP := 0.5
const MOTES_COLOR := Color(1.0, 0.78, 0.38)
## The hero's forming: a little above his height so the band leaves the head; the painting's light share of the shader.
const FORM_OVER := 0.3
const FORM_CAP_SHARE := 0.9
## The seconds the caption stays when the scene was skipped (ArrivalCaption.SKIPPED); 0 asks for its full time.
const SKIPPED_SECONDS := 2.5
const CAPTION_KEY := &"arrival_line"

const FORM_SHADER := preload("res://assets/shaders/arrival_form.gdshader")
const RUNE_SHADER := preload("res://assets/shaders/ritual_rune.gdshader")
const SPIKE_SHADER := preload("res://assets/shaders/crystal_spike.gdshader")
const IMPACT_SHADER := preload("res://assets/shaders/arrival_impact.gdshader")

## The star over the black: a core and a soft emerald halo, drawn by hand (a few circles, one canvas item).
class Star extends Control:
	var glow := 0.0
	var at := Vector2.ZERO
	var clock := 0.0

	func _draw() -> void:
		if glow <= 0.0:
			return
		var pulse := 0.85 + 0.15 * sin(clock * TAU * STAR_PULSE_HZ)
		for i in 7:
			var k := float(i) / 6.0
			var halo := STAR_EMERALD
			halo.a = glow * pulse * 0.07 * (1.0 - k)
			draw_circle(at, lerpf(STAR_HALO, STAR_CORE * 2.0, k), halo)
		var core := STAR_IVORY
		core.a = glow * pulse
		draw_circle(at, STAR_CORE, core)

var game: Game
var at := Vector2.ZERO
## The scene's own seconds (real time: the world's slow motion does not slow it) and whether it has skipped.
var clock := 0.0
var skipped := false
var _hold := -1.0
var _playing := false
var _gave_control := false
var _captioned := false
var _landed := false
var _head: MeshInstance3D
var _core: MeshInstance3D
var _sparks: Array[MeshInstance3D] = []
var _tail: Array[MeshInstance3D] = []
var _comet_from := Vector3.ZERO
var _shock: MeshInstance3D
var _shock_mat: ShaderMaterial
var _pool: MeshInstance3D
var _flash: ColorRect
var _cover: ColorRect
var _star: Star
var _layer: CanvasLayer
var _ring: MeshInstance3D
var _ring_mat: ShaderMaterial
var _crystals: Array[MeshInstance3D] = []
var _crystal_mats: Array[ShaderMaterial] = []
var _crystal_base: Array[Transform3D] = []
var _crystal_peak := 1.0
var _dust: CPUParticles3D
var _halos: Array[MeshInstance3D] = []
var _crystal_light: OmniLight3D
var _motes: Array[SpectralMotes] = []
var _forms: Array[Dictionary] = []
var _hidden: Array[MeshInstance3D] = []
var _forming := false
var _env: Environment
var _env_brightness := 1.0
var _ui_was_visible := true


## Dev: --arrival plays it over the first room (Game calls this once the room is up; null when not asked).
static func dev(g: Game) -> ArrivalScene:
	if not Dev.has("arrival"):
		return null
	var s := ArrivalScene.new()
	g.add_child(s)
	s.play(g, birth_spot(g.arena))
	return s


## Where the scene is set in this arena: the room's way in (Arena.start) when it is clear all round, else the first
## clear point from it toward the middle of the room (the Salão's way in is a narrow landing by the balustrades and the
## stairs, no place for a ring of crystals). Both the hero and the dressing use it.
static func birth_spot(arena: Arena) -> Vector2:
	var from := arena.start
	var steps := int(from.length() / CLEAR_STEP)
	for i in steps + 1:
		var p := from.lerp(Vector2.ZERO, float(i) / maxf(float(steps), 1.0))
		if is_clear(arena, p):
			return p
	return from


## Whether a ring and crystals fit at `p`: the room's own floor (its edge, balustrades and walls, not the walkable
## strips added for a way in) CLEAR_RADIUS round, and no pillar or block within CRYSTAL_RING of it.
static func is_clear(arena: Arena, p: Vector2) -> bool:
	if arena.shape().clamp(p, CLEAR_RADIUS).distance_to(p) > 0.01:
		return false
	for c in arena.pillars:
		if p.distance_to(Vector2(c.x, c.y)) < c.z + CRYSTAL_RING:
			return false
	for bx in arena.boxes:
		if p.distance_to(p.clamp(bx.position, bx.end)) < CRYSTAL_RING:
			return false
	return true


## Starts the scene on `spot` (x, z in meters, the birth spot): black at once, the hero parked and unseen. from_clock: where in its
## clock it begins (Prologue.SHORT_FROM: the short arrival of the passage from the Antessala to the Sala 00, with no star and no
## black first); with_caption: the line of the first arrival at the foot of the screen (a new save's, once).
func play(g: Game, spot: Vector2, from_clock := 0.0, with_caption := true) -> void:
	game = g
	at = spot
	clock = from_clock
	_captioned = not with_caption
	_hold = Dev.num("arrival-hold", -1.0) if Dev.has("arrival-hold") else -1.0
	_playing = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.layer = LAYER
	add_child(_layer)
	_cover = ColorRect.new()
	_cover.color = Color.BLACK
	_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_cover)
	_star = Star.new()
	_star.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_star)
	_flash = ColorRect.new()
	_flash.color = Color(BEAM_TINT.lerp(Color.WHITE, 0.45), 0.0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_flash)
	if g.ui != null:
		_ui_was_visible = g.ui.visible
		g.ui.visible = false
	if g.air != null and g.air.env != null:
		_env = g.air.env.environment
		_env_brightness = _env.adjustment_brightness
	g.player.visible = false
	# the camera looks at the birth spot the whole scene, free of the room's margins and of where the hero is drawn
	g.cam.lean = spot
	g.cam.lean_free = true
	g.cam.snap()
	_build_ring()
	_build_crystals()
	_build_comet()
	_hold_hero()
	_apply(ArrivalTimeline.state_at(from_clock))


## A press after SKIP_FROM: the scene goes to its second 4.0 (the hero formed, the light going out, control given) and
## the line shows short. Before SKIP_FROM, or once he can walk, it does nothing.
func skip() -> void:
	if not _playing or _gave_control:
		return
	var to := ArrivalTimeline.skip_to(clock)
	if to == clock:
		return
	clock = to
	skipped = true


## Whether the hero may move (second 4.0 reached).
func has_control() -> bool:
	return _gave_control


func _input(event: InputEvent) -> void:
	if not _playing or _gave_control or event.is_echo():
		return
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and event.is_pressed():
		skip()


func _process(delta: float) -> void:
	if not _playing:
		return
	if _hold >= 0.0:
		clock = _hold
	else:
		clock += delta / maxf(Engine.time_scale, 0.001)
	_apply(ArrivalTimeline.state_at(clock))


func _exit_tree() -> void:
	_restore()


# ---------- the dressing ----------

func _apply(s: Dictionary) -> void:
	if not _gave_control:
		_hold_hero()
	_cover.color.a = s[&"black"]
	_dress_star(s)
	_dim(s[&"dim"])
	_dress_comet(s)
	_dress_landing(s)
	_dress_ring(s[&"ring"])
	_dress_crystals(s[&"crystals"], s[&"crystal_glow"])
	for m in _motes:
		m.visible = s[&"motes_on"]
		m.set_param(&"travel", s[&"motes"])
	_dress_hero(s)
	if s[&"control"] and not _gave_control:
		_give_control()
	if s[&"caption"] and _gave_control and not _captioned:
		_caption(0.0)
	if s[&"done"]:
		_end()


func _dress_star(s: Dictionary) -> void:
	_star.clock = clock
	_star.glow = s[&"star"]
	_star.at = get_viewport().get_visible_rect().size * STAR_HOME
	_star.queue_redraw()


## The room's light share (ArrivalTimeline.DIM to 1) as the world's brightness; the room's own mood is left alone.
func _dim(share: float) -> void:
	if _env == null:
		return
	var k := inverse_lerp(ArrivalTimeline.DIM, 1.0, share)
	_env.adjustment_brightness = lerpf(DIM_BRIGHTNESS * _env_brightness, _env_brightness, k)


## The comet's own path: p is the fall (0 to 1), the head sits at the path's share p^COMET_EASE.
func _comet_at(p: float) -> Vector3:
	var end := Vector3(at.x, COMET_END, at.y)
	return _comet_from.lerp(end, pow(clampf(p, 0.0, 1.0), COMET_EASE))


func _build_comet() -> void:
	var right := Vector3.RIGHT
	if game.camera != null:
		right = game.camera.global_transform.basis.x
		right.y = 0.0
		right = right.normalized() if right.length() > 0.01 else Vector3.RIGHT
	_comet_from = Vector3(at.x, COMET_END + COMET_UP, at.y) - right * COMET_SIDE
	_head = _glow_quad(HEAD_SIZE)
	_core = _glow_quad(CORE_SIZE)
	for i in SPARKS:
		_sparks.append(_glow_quad(SPARK_SIZE))
	for i in TAIL_COUNT:
		var k := float(i + 1) / float(TAIL_COUNT)
		_tail.append(_glow_quad(lerpf(TAIL_SIZE, TAIL_SIZE * 0.25, k)))
	_pool = _glow_quad(POOL_SIZE)
	_pool.position = Vector3(at.x, POOL_Y_AT, at.y)
	_shock = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * SHOCK_RADIUS * 2.0
	_shock.mesh = plane
	_shock_mat = ShaderMaterial.new()
	_shock_mat.shader = IMPACT_SHADER
	_shock_mat.set_shader_parameter(&"color", BEAM_TINT)
	_shock.material_override = _shock_mat
	_shock.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_shock.position = Vector3(at.x, SHOCK_Y, at.y)
	_shock.visible = false
	add_child(_shock)


func _glow_quad(size: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = Fx.quad(size, Color(0, 0, 0, 1))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visible = false
	add_child(mi)
	return mi


func _tone(mi: MeshInstance3D, light: float) -> void:
	(mi.mesh.material as StandardMaterial3D).albedo_color = Color(BEAM_TINT * light, 1.0)


## The comet falling (second 1.6 to 2.4): the head and its tail along the slant; gone the frame it lands.
func _dress_comet(s: Dictionary) -> void:
	var p: float = s[&"comet"]
	var on := p > 0.0 and p < 1.0
	_head.visible = on
	if on:
		_head.position = _comet_at(p)
		var fade := minf(p * 6.0, 1.0)
		_tone(_head, HEAD_LIGHT * fade)
		_core.position = _head.position
		(_core.mesh.material as StandardMaterial3D).albedo_color = Color(Color(1.0, 0.96, 0.82) * (CORE_LIGHT * fade), 1.0)
	_core.visible = on
	_dress_sparks(p, on)
	for i in _tail.size():
		var q := p - float(i + 1) * TAIL_STEP
		var mi := _tail[i]
		mi.visible = on and q > 0.0
		if mi.visible:
			mi.position = _comet_at(q)
			_tone(mi, TAIL_LIGHT * (1.0 - float(i) / float(_tail.size())))


## The sparks loosed from the tail: each one stays on the path a fixed way behind the head and drifts off to the side and
## down by a fixed amount, fading as it goes (the same on every play).
func _dress_sparks(p: float, on: bool) -> void:
	for i in _sparks.size():
		var mi := _sparks[i]
		var k := float(i) / float(_sparks.size())
		var q := p - lerpf(SPARK_BACK.x, SPARK_BACK.y, fmod(k * 3.7 + 0.13, 1.0))
		mi.visible = on and q > 0.0
		if not mi.visible:
			continue
		var along := (p - q) / SPARK_BACK.y
		var side := Vector3(sin(float(i) * 2.4), -absf(cos(float(i) * 1.7)) - 0.3, cos(float(i) * 2.4)) * SPARK_DRIFT * along
		mi.position = _comet_at(q) + side
		_tone(mi, SPARK_LIGHT * (1.0 - along))


## The landing: the flash, the ring over the floor, the dust, the shake (once), then the light round the hero until he walks.
func _dress_landing(s: Dictionary) -> void:
	if s[&"impact"] and not _landed:
		_landed = true
		Audio.play(&"seal")
		if game.fx != null and clock < ArrivalTimeline.T_IMPACT + 0.5:
			game.fx.shake(SHAKE)
		_burst_dust()
	var flash: float = s[&"flash"]
	_flash.color.a = FLASH_ALPHA * flash * flash
	var shock: float = s[&"shock"]
	_shock.visible = s[&"impact"] and shock < 1.0
	_shock_mat.set_shader_parameter(&"t", shock)
	var beam: float = s[&"beam"]
	_pool.visible = beam > 0.0
	if _pool.visible:
		var breath := 0.9 + 0.1 * sin(clock * TAU * 0.8)
		_tone(_pool, POOL_LIGHT * beam * breath * minf(shock * 3.0, 1.0))


func _burst_dust() -> void:
	_dust = CPUParticles3D.new()
	_dust.amount = DUST_COUNT
	_dust.lifetime = DUST_LIFE
	_dust.one_shot = true
	_dust.explosiveness = 1.0
	_dust.mesh = Fx.quad(DUST_SIZE, Color(BEAM_TINT * DUST_GAIN, 1.0))
	_dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	_dust.emission_ring_axis = Vector3.UP
	_dust.emission_ring_height = 0.05
	_dust.emission_ring_radius = 0.5
	_dust.emission_ring_inner_radius = 0.3
	_dust.direction = Vector3.UP
	_dust.spread = 25.0
	_dust.gravity = Vector3(0, -2.0, 0)
	_dust.initial_velocity_min = DUST_SPEED * 0.3
	_dust.initial_velocity_max = DUST_SPEED * 0.6
	_dust.radial_accel_min = DUST_SPEED
	_dust.radial_accel_max = DUST_SPEED * 1.4
	_dust.damping_min = 2.5
	_dust.damping_max = 4.0
	var fade := Gradient.new()
	fade.set_color(0, Color.WHITE)
	fade.set_color(1, Color.BLACK)
	_dust.color_ramp = fade
	_dust.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_dust.position = Vector3(at.x, 0.12, at.y)
	add_child(_dust)
	_dust.emitting = true


func _build_ring() -> void:
	_ring = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE
	_ring.mesh = plane
	_ring_mat = ShaderMaterial.new()
	_ring_mat.shader = RUNE_SHADER
	_ring_mat.set_shader_parameter(&"kind", 2)
	_ring_mat.set_shader_parameter(&"color", RING_COLOR)
	_ring_mat.set_shader_parameter(&"spirit", RING_GLOW)
	_ring_mat.set_shader_parameter(&"rim_m", 0.07)
	_ring_mat.set_shader_parameter(&"seed", 0.37)
	_ring.material_override = _ring_mat
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position = Vector3(at.x, RING_Y, at.y)
	_ring.visible = false
	add_child(_ring)


## The seal opens from the middle out: the circle grows from RING_FROM of its size and its light comes with it.
func _dress_ring(open: float) -> void:
	_ring.visible = open > 0.0
	if not _ring.visible:
		return
	var r := RING_RADIUS * lerpf(RING_FROM, 1.0, open)
	_ring.scale = Vector3(r * 2.0, 1.0, r * 2.0)
	_ring_mat.set_shader_parameter(&"size_m", r)
	_ring_mat.set_shader_parameter(&"strength", RING_STRENGTH * open)


func _build_crystals() -> void:
	var prism := CylinderMesh.new()
	prism.top_radius = 0.0
	prism.bottom_radius = 1.0
	prism.height = 1.0
	prism.radial_segments = 4
	prism.rings = 1
	prism.cap_top = false
	_crystal_peak = ScreenTone.linear_peak(CRYSTAL_COLOR.lerp(Color.WHITE, 0.25), CRYSTAL_SCREEN)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in CRYSTALS:
		var a := TAU * (float(i) + 0.5) / CRYSTALS + CRYSTAL_TURN
		var out := Vector3(cos(a), 0.0, sin(a))
		var tall := lerpf(CRYSTAL_TALL.x, CRYSTAL_TALL.y, rng.randf())
		var lean := Basis(Vector3.UP.cross(out).normalized(), CRYSTAL_LEAN * (0.5 + rng.randf()))
		var foot := Vector3(at.x, 0.0, at.y) + out * CRYSTAL_RING
		var mi := MeshInstance3D.new()
		mi.mesh = prism
		var mat := ShaderMaterial.new()
		mat.shader = SPIKE_SHADER
		mat.set_shader_parameter(&"color", CRYSTAL_COLOR)
		mat.set_shader_parameter(&"shatter", 0.99)  # (never breaks: life stays 0)
		mat.set_shader_parameter(&"life", 0.0)
		mat.set_shader_parameter(&"deep", CRYSTAL_DEEP)
		mat.set_shader_parameter(&"edge_pale", CRYSTAL_EDGE)
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.visible = false
		add_child(mi)
		_crystals.append(mi)
		_crystal_mats.append(mat)
		# the full-grown transform; _dress_crystals scales its height from the foot
		_crystal_base.append(Transform3D(lean * Basis.from_scale(Vector3(CRYSTAL_THICK, tall, CRYSTAL_THICK)),
			foot + lean.y * tall * 0.5))
		var halo := MeshInstance3D.new()
		halo.mesh = Fx.quad(CRYSTAL_HALO, Color(0, 0, 0, 0))
		halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		halo.visible = false
		add_child(halo)
		_halos.append(halo)
		var m := SpectralMotes.make(SpectralMotes.Mode.GATHER, MOTES_EACH, MOTES_COLOR, MOTES_SIZE, MOTES_LIGHT, 40 + i)
		m.set_param(&"from", foot + Vector3(0, tall * 0.5, 0))
		m.set_param(&"from_spread", MOTES_SPREAD)
		m.set_param(&"to", Vector3(at.x, MOTES_END, at.y))
		m.set_param(&"travel", 0.0)
		m.visible = false
		add_child(m)
		_motes.append(m)


func _dress_crystals(rise: float, glow: float) -> void:
	if _crystal_light == null:
		_crystal_light = OmniLight3D.new()
		_crystal_light.light_color = CRYSTAL_COLOR
		_crystal_light.omni_range = CRYSTAL_LIGHT.y
		_crystal_light.light_specular = 0.0
		_crystal_light.shadow_enabled = false
		_crystal_light.light_cull_mask = ~Arena.CROWD_LAYER
		_crystal_light.position = Vector3(at.x, CRYSTAL_LIGHT.z, at.y)
		add_child(_crystal_light)
	_crystal_light.light_energy = CRYSTAL_LIGHT.x * glow * clampf(rise, 0.0, 1.0)
	for i in _crystals.size():
		var mi := _crystals[i]
		mi.visible = rise > 0.0
		if not mi.visible:
			continue
		var base := _crystal_base[i]
		var k := maxf(rise, 0.001)
		# grown from its foot: the height scales, the middle follows
		var up := base.basis.y.normalized()
		var tall := base.basis.y.length() * k
		var b := base.basis
		b.y = up * tall
		var foot := base.origin - up * base.basis.y.length() * 0.5
		mi.transform = Transform3D(b, foot + up * tall * 0.5)
		_crystal_mats[i].set_shader_parameter(&"peak", _crystal_peak * CRYSTAL_GAIN * glow)
		var halo := _halos[i]
		halo.visible = glow > 0.0
		halo.position = foot + up * tall * 0.6
		(halo.mesh.material as StandardMaterial3D).albedo_color = Color(CRYSTAL_COLOR * (CRYSTAL_HALO_ALPHA * glow), 1.0)


# ---------- the hero ----------

## Parked on the spot, unseen and unhurtable until he may walk.
func _hold_hero() -> void:
	game.player.place(at)
	game.player.position = Vector3(game.player.pos.x, 0.0, game.player.pos.y)  # (the body is drawn only when stepped)
	game.player.invuln = maxf(game.player.invuln, 1.0)


## His body forms from the floor up (arrival_form.gdshader on each painted mesh; the rest of him, the blade, joins when it
## is done), then his own materials come back.
func _dress_hero(s: Dictionary) -> void:
	var player := game.player
	var forming: bool = s[&"hero_visible"] and not s[&"control"]
	if forming and not _forming:
		_begin_form()
	if forming:
		var cut: float = s[&"hero_form"] * (HeroBody.HEIGHT + FORM_OVER)
		for f in _forms:
			var m: ShaderMaterial = f.mat
			m.set_shader_parameter(&"cut", cut)
			m.set_shader_parameter(&"flash", s[&"hero_flash"])
	if _forming and not forming:
		_end_form()
	player.visible = s[&"hero_visible"]


func _begin_form() -> void:
	_forming = true
	var model: Node = game.player.get(&"_model")
	if model == null:
		return
	var cap := ScreenTone.linear_peak(Color(1, 0.94, 0.82)) * FORM_CAP_SHARE
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var own: Material = mi.material_override
		var tex: Texture2D = null
		var tint := Color.WHITE
		if own is ShaderMaterial and HeroBody.fills(own):
			tex = (own as ShaderMaterial).get_shader_parameter(&"albedo")
			var t: Variant = (own as ShaderMaterial).get_shader_parameter(&"tint")
			tint = t if t is Color else Color.WHITE
		elif own is StandardMaterial3D and HeroBody.fills(own):
			tex = (own as StandardMaterial3D).albedo_texture
			tint = (own as StandardMaterial3D).albedo_color
		if tex == null:
			# the blade and the like: unseen until he is formed
			_hidden.append(mi)
			mi.visible = false
			continue
		var m := ShaderMaterial.new()
		m.shader = FORM_SHADER
		m.set_shader_parameter(&"albedo", tex)
		m.set_shader_parameter(&"tint", tint)
		m.set_shader_parameter(&"cut", 0.0)
		m.set_shader_parameter(&"cap", cap)
		_forms.append({&"mesh": mi, &"own": own, &"overlay": mi.material_overlay, &"mat": m})
		mi.material_override = m
		mi.material_overlay = null


func _end_form() -> void:
	_forming = false
	for f in _forms:
		var mi: MeshInstance3D = f.mesh
		if is_instance_valid(mi):
			mi.material_override = f.own
			mi.material_overlay = f.overlay
	_forms.clear()
	for mi in _hidden:
		if is_instance_valid(mi):
			mi.visible = true
	_hidden.clear()


func _give_control() -> void:
	_gave_control = true
	_release_camera()
	game.player.visible = true
	if game.ui != null:
		game.ui.visible = _ui_was_visible
	if skipped and not _captioned:
		_caption(SKIPPED_SECONDS)
	finished.emit()


func _release_camera() -> void:
	if game != null and is_instance_valid(game) and game.cam != null and game.cam.lean_free:
		game.cam.lean = Vector2.INF
		game.cam.lean_free = false


func _caption(seconds: float) -> void:
	_captioned = true
	var caption: Variant = game.hud.get(&"arrival_caption") if game.hud != null else null
	if caption != null and caption.has_method(&"show_line"):
		caption.show_line(CAPTION_KEY, seconds)


## The scene is over: its covers go, the crystals stay as the Antessala's scenery (their glow low).
func _end() -> void:
	_playing = false
	_restore()
	for m in _motes:
		m.queue_free()
	_motes.clear()
	_ring.queue_free()
	for n: Node in [_head, _core, _pool, _shock, _dust]:
		if n != null:
			n.queue_free()
	for mi in _tail:
		mi.queue_free()
	_tail.clear()
	for mi in _sparks:
		mi.queue_free()
	_sparks.clear()
	if _layer != null:
		_layer.queue_free()
		_layer = null
	set_process(false)


## Everything the scene borrowed goes back as it was (also when the room is left in the middle of it).
func _restore() -> void:
	_release_camera()
	if _env != null:
		_env.adjustment_brightness = _env_brightness
		_env = null
	if _forming:
		_end_form()
	if game != null and is_instance_valid(game) and game.player != null and is_instance_valid(game.player):
		game.player.visible = true
		if game.ui != null and not _gave_control:
			game.ui.visible = _ui_was_visible
