class_name BossShield
extends MeshInstance3D
## The shield of Morvath's ritual (cycle 9): the sphere of spectral glass (boss_shield.gdshader), his circle of runes on
## the floor under it (ritual_rune.gdshader, kind 2) and a few motes orbiting it (SpectralMotes). Boss drives it as it
## drove the old sphere: position (its middle Boss.SHIELD_RISE of the radius over the floor), uniform scale and the
## material's `power` (0..1 growing in, over 1 when it breaks); this node follows that power with the rest and plays
## the breaking (the glass falls apart in shards) when the power goes over 1. As it rises, a thin curtain of spectral
## fire climbs around it (cycle 10, ART-005: the old pillar of light over him hid him for most of a second), on the
## shield's own edge and faint at the height of his body.

const SHADER := preload("res://assets/shaders/boss_shield.gdshader")
## His corrupted emerald (the sphere, the circle and the motes are the same green; Morvath's palette). Cycle 10
## (ART-006): colder and darker than the Emeth's living green (hue 165, saturation 0.55, value 0.7), so the two never
## read as one; the same as spectral_column.gdshader and ritual_rune.gdshader.
const COLOR := Color(0.315, 0.7, 0.604)
const SEGMENTS := 40
const RINGS := 20
## The circle on the floor: its radius (share of the shield's), how strongly it is drawn, its height over the floor.
const CIRCLE := 1.12
const CIRCLE_STRENGTH := 0.9
const CIRCLE_Y := 0.065
## Motes orbiting it: how many, size (m), light, orbit (share of the radius), heights (share of the radius, over and
## under its middle), turns a second. Cycle 10 (BUG-005): small green specks, their colour times their light never
## past 1.2 (under the glow threshold plus a little), half of them in the spectral blue of its veins.
const MOTES := 12
const MOTE_SIZE := 0.12
const MOTE_LIGHT := 1.5
const MOTE_BLUE := Color(0.3, 0.55, 0.95)
const MOTE_BLUE_LIGHT := 1.2
const MOTE_ORBIT := 1.12
const MOTE_SPAN := Vector2(-0.45, 0.75)
const MOTE_TURNS := 0.07
## Seconds the glass takes to fall apart once the power goes over 1.
const SHATTER_TIME := 0.5
## The curtain of fire as it rises (spectral_column.gdshader on an open cylinder): its radius (share of the shield's),
## height (m), light (at most 0.4 where it crosses him) and seconds.
const CURTAIN := 1.02
const CURTAIN_HEIGHT := 6.0
const CURTAIN_STRENGTH := 0.4
const CURTAIN_TIME := 0.8
const CURTAIN_SIDES := 32

var radius := 3.0
var _circle: MeshInstance3D
var _motes: Array[SpectralMotes] = []
var _curtain: MeshInstance3D
var _curtain_t := -1.0
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
	for k in 2:
		var m := SpectralMotes.make(SpectralMotes.Mode.ORBIT, MOTES / 2, COLOR if k == 0 else MOTE_BLUE, MOTE_SIZE,
			MOTE_LIGHT if k == 0 else MOTE_BLUE_LIGHT, 9 + k)
		m.set_param(&"radius", r * MOTE_ORBIT)
		m.set_param(&"span", MOTE_SPAN * r)
		m.set_param(&"turns", MOTE_TURNS)
		s.add_child(m)
		s._motes.append(m)
	s._curtain = MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = r * CURTAIN
	tube.bottom_radius = r * CURTAIN
	tube.height = CURTAIN_HEIGHT
	tube.radial_segments = CURTAIN_SIDES
	tube.rings = 3
	tube.cap_top = false
	tube.cap_bottom = false
	s._curtain.mesh = tube
	var fm := ShaderMaterial.new()
	fm.shader = Ground.COLUMN_SHADER
	fm.set_shader_parameter(&"color", COLOR)
	fm.set_shader_parameter(&"height_m", CURTAIN_HEIGHT)
	fm.set_shader_parameter(&"strength", CURTAIN_STRENGTH)
	fm.set_shader_parameter(&"tongues", 9.0)
	s._curtain.material_override = fm
	s._curtain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s._curtain.visible = false
	s.add_child(s._curtain)
	return s


func _process(delta: float) -> void:
	if not visible:
		_shatter = -1.0
		_curtain_t = -1.0
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
	for mo in _motes:
		mo.set_param(&"power", held)
	_step_curtain(delta, power)
	# the circle stays on the floor whatever height and size Boss gives the sphere
	var s := maxf(scale.y, 0.01)
	_circle.position = Vector3(0, (CIRCLE_Y - position.y) / s, 0)
	_circle.scale = Vector3.ONE / s


## The curtain rises once each time the shield grows in from nothing, and stands on the floor at the shield's edge
## whatever size Boss gives the sphere.
func _step_curtain(delta: float, power: float) -> void:
	if _curtain_t < 0.0 and power > 0.0 and power < 1.0 and _shatter < 0.0:
		_curtain_t = 0.0
	_curtain.visible = _curtain_t >= 0.0 and _curtain_t < 1.0
	if not _curtain.visible:
		return
	_curtain_t += delta / CURTAIN_TIME
	(_curtain.material_override as ShaderMaterial).set_shader_parameter(&"life", minf(_curtain_t, 1.0))
	var s := maxf(scale.y, 0.01)
	_curtain.position = Vector3(0, (CURTAIN_HEIGHT * 0.5 - position.y) / s, 0)
	_curtain.scale = Vector3.ONE / s
