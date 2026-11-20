class_name HubNpc
extends Node3D
## One of the hub's two people (HUB-D; docs/design/hub_spec_art.md 3.8; no Meshy): a KayKit adventurer baked by
## tools/bake.gd (`-- npcs`: assets/baked/npc_vendor.res, npc_smith.res; Slender, a palette of the game's own tones
## inside the file) and drawn as the crowd is, by a CrowdRenderer of its own with one figure: the same painted body,
## the stylized look's shell and three light bands by the global art_style (F7 flips it live), the soft shadow at the
## feet. Standing in his idle, now and then a gesture: the Vendedor arranges his wares every VENDOR_REST seconds; the
## Forjador strikes the anvil in bouts of SMITH_BLOWS blows, SMITH_BLOW seconds apart, then breathes for SMITH_REST,
## and each blow throws a few small sparks where the hammer's head lands (under the glow threshold).
## The node stands where he stands and faces its own +z (face() turns it toward a point of the floor).
##   var smith := HubNpc.make(HubNpc.Who.SMITH)
##   parent.add_child(smith)
##   smith.position = Vector3(x, 0, z)
##   smith.face(anvil_xz)
## Only drawing: no collision (the hub's layout has the footprint, HubPlan), nothing read by the game.

enum Who { VENDOR, SMITH }

## The baked model of each (assets/baked/<id>.res).
const MODEL := {Who.VENDOR: &"npc_vendor", Who.SMITH: &"npc_smith"}
## How wide his soft shadow is (the crowd's: radius x 2.6).
const RADIUS := 0.42
## T-1 (art review of the hub, re-review): people of the place, not the dead: in the stylized look their body takes more
## of the key and of the scene's light than the crowd's (crowd.gdshader style_light 0.2, style_scene 0.1, which keeps
## the dead below the floor) and a warmer rim, still below the hero. Classic look untouched (only style_* uniforms).
const STYLE_LIGHT := 0.35
const STYLE_SCENE := 0.2
const STYLE_RIM := 0.32
## Seconds between the Vendedor's gestures (a random span).
const VENDOR_REST := Vector2(6.0, 9.0)
## The Forjador's bouts: how many blows, how far apart (the gesture restarts on this beat), how long he rests after.
const SMITH_BLOWS := Vector2i(3, 5)
const SMITH_BLOW := 1.2
const SMITH_REST := Vector2(4.0, 7.0)
## Seconds a change of clip blends over (the crowd's CLIP_FADE is 0.1; a calm figure, slower).
const FADE := 0.25
## The sparks of a blow: how many, their colour (no channel past 1.0: under the glow threshold, WorldAir 1.3), size
## in meters, how long they live, how fast they leave.
const SPARKS := 10
const SPARK_COLOR := Color(1.0, 0.64, 0.3)
const SPARK_SIZE := Vector2(0.025, 0.045)
const SPARK_LIFE := 0.4
const SPARK_SPEED := Vector2(1.6, 3.2)

var who := Who.VENDOR
## Seconds into the gesture when the hammer lands (the lowest the head goes in the swing; 0 without a hammer).
var impact := 0.0

var _renderer: CrowdRenderer
var _def: EnemyDef
var _kind: CrowdRenderer.Kind
var _model: BakedModel
var _rng := RandomNumberGenerator.new()
var _clip := &"idle"
var _t := 0.0
var _wait := 0.0
var _blows := 0
var _row := -1
var _from := -1
var _fade := 1.0
var _sparked := false
var _sparks: CPUParticles3D


static func make(w: Who, seed_ := 0) -> HubNpc:
	var n := HubNpc.new()
	n.who = w
	n.name = "Vendor" if w == Who.VENDOR else "Smith"
	n._rng.seed = seed_ if seed_ != 0 else (311 if w == Who.VENDOR else 523)
	return n


func _ready() -> void:
	_renderer = CrowdRenderer.new()
	_renderer.name = "Figure"
	add_child(_renderer)
	_def = EnemyDef.new()
	_def.id = MODEL[who]
	_def.model = MODEL[who]
	_def.size = 1.0
	_def.radius = RADIUS
	_def.tint = Color.WHITE
	# his own colours, as painted (the crowd's grey wash is for the bone of the dead)
	_def.vivid = CrowdRenderer.CROWD_GREY
	_renderer.register(_def)
	_kind = _renderer.kind(_def)
	var body := _kind.material as ShaderMaterial
	body.set_shader_parameter(&"style_light", STYLE_LIGHT)
	body.set_shader_parameter(&"style_scene", STYLE_SCENE)
	body.set_shader_parameter(&"style_rim", STYLE_RIM)
	_model = _kind.model
	if _model.has_point("hammer"):
		impact = landing(_model)
		_sparks = _spark_burst()
		add_child(_sparks)
	_t = _rng.randf() * _model.duration(&"idle")
	_rest()
	_draw()


## Turns him to look at a point of the floor (world x, z).
func face(at: Vector2) -> void:
	var d := at - Vector2(global_position.x, global_position.z)
	if d.length() > 0.01:
		rotation.y = atan2(d.x, d.y)


## A gesture now (the Vendedor arranges his wares; the Forjador starts a bout).
func gesture() -> void:
	_blows = _rng.randi_range(SMITH_BLOWS.x, SMITH_BLOWS.y) if who == Who.SMITH else 1
	_play(&"gesture")


## Seconds into a model's gesture when the hammer's head is lowest: the blow lands (the baked chop ends there).
static func landing(m: BakedModel) -> float:
	var n := m.frame_count(&"gesture")
	var length := m.duration(&"gesture")
	var best := INF
	var at := 0.0
	var steps := maxi(n * 4, 1)
	for i in steps + 1:
		var t := length * i / steps
		var y := m.point("hammer", &"gesture", t).y
		if y < best:
			best = y
			at = t
	return at


## Where the Forjador's hammer head lands, in his own space (facing +z, his right hand at -x): HubLook stands him so
## this point is the anvil's face.
static func strike_point() -> Vector3:
	var m: BakedModel = load("res://assets/baked/%s.res" % MODEL[Who.SMITH])
	return m.point("hammer", &"gesture", landing(m))


## Where the hammer's head is now, in the world (Vector3.ZERO without a hammer).
func hammer_head() -> Vector3:
	if not _model.has_point("hammer"):
		return Vector3.ZERO
	var anim := _clip
	return global_transform * _model.point("hammer", anim, _t)


func _process(delta: float) -> void:
	_t += delta
	_fade = minf(_fade + delta / FADE, 1.0)
	if _clip == &"gesture":
		if _sparks != null and not _sparked and _t >= impact:
			_sparked = true
			_spark()
		var beat := maxf(SMITH_BLOW, _model.duration(&"gesture")) if who == Who.SMITH else _model.duration(&"gesture")
		if _t >= beat:
			_blows -= 1
			if _blows > 0:
				_play(&"gesture")
			else:
				_play(&"idle")
				_rest()
	else:
		_wait -= delta
		if _wait <= 0.0:
			gesture()
	_draw()


func _rest() -> void:
	var span := SMITH_REST if who == Who.SMITH else VENDOR_REST
	_wait = _rng.randf_range(span.x, span.y)


func _play(clip: StringName) -> void:
	_from = _row
	_fade = 0.0 if _row >= 0 else 1.0
	_clip = clip
	_t = 0.0
	_sparked = false


func _draw() -> void:
	_renderer.begin()
	_row = _renderer.add_kind(_kind, _def, _clip, _t, Vector3.ZERO, 0.0, Color(0, 0, 0, 0), Vector3.ONE, 0.0, 0.0,
		_from if _fade < 1.0 else -1, _fade)
	_renderer.commit()


func _spark() -> void:
	_sparks.global_position = hammer_head()
	_sparks.restart()
	_sparks.emitting = true


## A one-shot burst of small amber sparks, unlit, under the glow threshold (no light of its own).
func _spark_burst() -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.name = "Sparks"
	p.one_shot = true
	p.emitting = false
	p.amount = SPARKS
	p.lifetime = SPARK_LIFE
	p.explosiveness = 1.0
	p.local_coords = false
	p.direction = Vector3.UP
	p.spread = 70.0
	p.initial_velocity_min = SPARK_SPEED.x
	p.initial_velocity_max = SPARK_SPEED.y
	p.gravity = Vector3(0, -9.8, 0)
	p.scale_amount_min = SPARK_SIZE.x / SPARK_SIZE.y
	p.scale_amount_max = 1.0
	var fade := Gradient.new()
	fade.set_color(0, SPARK_COLOR)
	fade.set_color(1, Color(SPARK_COLOR.r * 0.6, SPARK_COLOR.g * 0.3, SPARK_COLOR.b * 0.1, 0.0))
	p.color_ramp = fade
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * SPARK_SIZE.y
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.albedo_texture = Fx.soft_dot()
	m.disable_receive_shadows = true
	quad.material = m
	p.mesh = quad
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return p
