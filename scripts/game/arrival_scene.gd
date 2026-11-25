class_name ArrivalScene
extends Node3D
## The Guerreiro's arrival (SW-O1, docs/design/onboarding_sw_o.md; ArrivalTimeline is its clock): black, a star, the
## light of Elun (RewardShaft) coming down on the birth spot, the seal's ring of runes (ritual_rune.gdshader, the steady
## circle) opening from the middle, Emeth's crystals (crystal_spike.gdshader) rising round it, sparks (SpectralMotes,
## GATHER) running from them to the light, and the Guerreiro forming in it from the floor up (arrival_form.gdshader on
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
## Where the star is in the screen before it comes down (its middle), and the height it ends at over the birth spot (m).
const STAR_HOME := Vector2(0.5, 0.5)
const STAR_END_HEIGHT := 1.6
## The room's light at its darkest, as the world's brightness adjustment (1 is as it is).
const DIM_BRIGHTNESS := 0.7
## The beam of the reward is a faint one that falls away round the paladin; here it is his own light, so its body is
## stronger and it keeps most of its strength round him (reward_shaft.gdshader uniforms, only on this node's shaft).
const BEAM_BODY := 0.9
## The light of Elun is gold and warm (RewardShaft's own tint is a pale ivory that reads beige on the floor).
const BEAM_TINT := Color(1.0, 0.78, 0.34)
const BEAM_NEAR_KEEP := 1.0
const BEAM_HERO_KEEP := 0.5
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
const CRYSTAL_GAIN := 1.2
const CRYSTAL_DEEP := 0.55
const CRYSTAL_EDGE := 0.75
## The birth spot's clearance (m): no stone, balustrade or floor edge nearer than this (the crystals stand at
## CRYSTAL_RING and are as thick as CRYSTAL_THICK), and how far along the way to the room's middle it is looked for (m).
const CLEAR_RADIUS := 3.2
const CLEAR_STEP := 0.5
const MOTES_COLOR := Color(0.3, 1.0, 0.55)
## The hero's forming: a little above his height so the band leaves the head; the painting's light share of the shader.
const FORM_OVER := 0.3
const FORM_CAP_SHARE := 0.9
## The seconds the caption stays when the scene was skipped (ArrivalCaption.SKIPPED); 0 asks for its full time.
const SKIPPED_SECONDS := 2.5
const CAPTION_KEY := &"arrival_line"

const FORM_SHADER := preload("res://assets/shaders/arrival_form.gdshader")
const RUNE_SHADER := preload("res://assets/shaders/ritual_rune.gdshader")
const SPIKE_SHADER := preload("res://assets/shaders/crystal_spike.gdshader")

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
var _shaft: RewardShaft
var _taken := false
var _cover: ColorRect
var _star: Star
var _layer: CanvasLayer
var _ring: MeshInstance3D
var _ring_mat: ShaderMaterial
var _crystals: Array[MeshInstance3D] = []
var _crystal_mats: Array[ShaderMaterial] = []
var _crystal_base: Array[Transform3D] = []
var _crystal_peak := 1.0
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


## Starts the scene on `spot` (x, z in meters, the birth spot): black at once, the hero parked and unseen.
func play(g: Game, spot: Vector2) -> void:
	game = g
	at = spot
	clock = 0.0
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
	_hold_hero()
	_apply(ArrivalTimeline.state_at(0.0))


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
	_dress_beam(s)
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
	var home := get_viewport().get_visible_rect().size * STAR_HOME
	var goal := home
	if game.camera != null:
		goal = game.camera.unproject_position(Vector3(at.x, STAR_END_HEIGHT, at.y))
	_star.at = home.lerp(goal, s[&"star_move"])
	_star.queue_redraw()


## The room's light share (ArrivalTimeline.DIM to 1) as the world's brightness; the room's own mood is left alone.
func _dim(share: float) -> void:
	if _env == null:
		return
	var k := inverse_lerp(ArrivalTimeline.DIM, 1.0, share)
	_env.adjustment_brightness = lerpf(DIM_BRIGHTNESS * _env_brightness, _env_brightness, k)


func _dress_beam(s: Dictionary) -> void:
	if s[&"beam_on"] and _shaft == null and not _taken:
		_shaft = RewardShaft.make(self, Vector3(at.x, 0.0, at.y), BEAM_TINT)
		# a skip past the descent: the light is there at once
		_shaft.appear(0.0, clock > ArrivalTimeline.T_OPEN + RewardShaft.DOWN + RewardShaft.LAND)
		_shaft_look()
		Audio.play(&"seal")
	if s[&"beam_off"] and _shaft != null and not _taken:
		_taken = true
		_shaft.take()


func _shaft_look() -> void:
	for m: ShaderMaterial in _shaft.get(&"_mats"):
		if m.shader == RewardShaft.SHAFT_SHADER:
			m.set_shader_parameter(&"body", BEAM_BODY)
			m.set_shader_parameter(&"near_keep", BEAM_NEAR_KEEP)
			m.set_shader_parameter(&"hero_keep", BEAM_HERO_KEEP)


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
	_crystal_peak = ScreenTone.linear_peak(Combat.EMETH.lerp(Color.WHITE, 0.25), CRYSTAL_SCREEN)
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
		mat.set_shader_parameter(&"color", Combat.EMETH)
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
		var m := SpectralMotes.make(SpectralMotes.Mode.GATHER, MOTES_EACH, MOTES_COLOR, MOTES_SIZE, MOTES_LIGHT, 40 + i)
		m.set_param(&"from", foot + Vector3(0, tall * 0.5, 0))
		m.set_param(&"from_spread", MOTES_SPREAD)
		m.set_param(&"to", Vector3(at.x, MOTES_END, at.y))
		m.set_param(&"travel", 0.0)
		m.visible = false
		add_child(m)
		_motes.append(m)


func _dress_crystals(rise: float, glow: float) -> void:
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
	if skipped:
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
