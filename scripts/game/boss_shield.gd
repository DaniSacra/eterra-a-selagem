class_name BossShield
extends MeshInstance3D
## The shield of Morvath's ritual (cycle 9): the sphere of spectral glass (boss_shield.gdshader), his circle of runes on
## the floor under it (ritual_rune.gdshader, kind 2) and a few motes orbiting it (SpectralMotes). Boss drives it as it
## drove the old sphere: position (its middle Boss.SHIELD_RISE of the radius over the floor), uniform scale and the
## material's `power` (0..1 growing in, over 1 when it breaks); this node follows that power with the rest and plays
## the breaking (the glass falls apart in shards) when the power goes over 1.

const SHADER := preload("res://assets/shaders/boss_shield.gdshader")
## His corrupted emerald (the sphere, the circle and the motes are the same green; Morvath's palette).
const COLOR := Color(0.32, 0.95, 0.62)
const SEGMENTS := 40
const RINGS := 20
## The circle on the floor: its radius (share of the shield's), how strongly it is drawn, its height over the floor.
const CIRCLE := 1.12
const CIRCLE_STRENGTH := 0.9
const CIRCLE_Y := 0.065
## Motes orbiting it: how many, size (m), light, orbit (share of the radius), heights (share of the radius, over and
## under its middle), turns a second.
const MOTES := 12
const MOTE_SIZE := 0.14
const MOTE_LIGHT := 0.9
const MOTE_ORBIT := 1.12
const MOTE_SPAN := Vector2(-0.45, 0.75)
const MOTE_TURNS := 0.07
## Seconds the glass takes to fall apart once the power goes over 1.
const SHATTER_TIME := 0.5

var radius := 3.0
var _circle: MeshInstance3D
var _motes: SpectralMotes
var _shatter := -1.0


## The shield of this radius, hidden until Boss raises its power.
static func create(r: float) -> BossShield:
	var s := BossShield.new()
	s.radius = r
	var sphere := SphereMesh.new()
	sphere.radius = r
	sphere.height = r * 2.0
	sphere.radial_segments = SEGMENTS
	sphere.rings = RINGS
	s.mesh = sphere
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"color", COLOR)
	mat.set_shader_parameter(&"power", 0.0)
	s.material_override = mat
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.visible = false
	s._circle = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(r * CIRCLE * 2.0, r * CIRCLE * 2.0)
	s._circle.mesh = plane
	var cm := ShaderMaterial.new()
	cm.shader = Ground.RUNE_SHADER
	cm.set_shader_parameter(&"kind", 2)
	cm.set_shader_parameter(&"size_m", r * CIRCLE)
	cm.set_shader_parameter(&"rim_m", Ground.RUNE_RIM)
	cm.set_shader_parameter(&"strength", 0.0)
	s._circle.material_override = cm
	s._circle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.add_child(s._circle)
	s._motes = SpectralMotes.make(SpectralMotes.Mode.ORBIT, MOTES, COLOR, MOTE_SIZE, MOTE_LIGHT)
	s._motes.set_param(&"radius", r * MOTE_ORBIT)
	s._motes.set_param(&"span", MOTE_SPAN * r)
	s._motes.set_param(&"turns", MOTE_TURNS)
	s.add_child(s._motes)
	return s


func _process(delta: float) -> void:
	if not visible:
		_shatter = -1.0
		return
	var m := material_override as ShaderMaterial
	var power: float = m.get_shader_parameter(&"power")
	# it breaks: Boss flares the power over 1, then lets it fall; the glass goes in shards in SHATTER_TIME
	if power > 1.0 and _shatter < 0.0:
		_shatter = 0.0
	if _shatter >= 0.0:
		_shatter = minf(1.0, _shatter + delta / SHATTER_TIME)
	var shatter := maxf(_shatter, 0.0)
	m.set_shader_parameter(&"shatter", shatter)
	var held := minf(power, 1.0) * (1.0 - shatter)
	(_circle.material_override as ShaderMaterial).set_shader_parameter(&"strength", CIRCLE_STRENGTH * held)
	_motes.set_param(&"power", held)
	# the circle stays on the floor whatever height and size Boss gives the sphere
	var s := maxf(scale.y, 0.01)
	_circle.position = Vector3(0, (CIRCLE_Y - position.y) / s, 0)
	_circle.scale = Vector3.ONE / s
