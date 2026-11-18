class_name RewardGem
extends RefCounted
## What a reward looks like where it waits (QW-106 of cycle C18; ART P0-1, ENV P1-1): over each door, on each item of
## the shop, by the Provação's block and the altar's slab. A disc of old gold, lit by the room, with the reward's own
## symbol on both faces (reward_gem.gdshader: the painted medallion where one exists, assets/ui/events, or DoorGlyph's
## mark struck in relief on enamel of the reward's colour), turning slowly over a low pedestal of the hall's stone,
## a soft halo of its colour behind it under the glow (reward_halo.gdshader). Before: unlit boxes, prisms and spheres of
## pure colour (Rooms.gem_mesh), a material and an omni light each. Now one material per kind of reward (cached), and
## no light of its own: the room's lights shade it and it glows a little by itself.

## The disc: radius and thickness (m), the height of its middle over the floor, the halo's size (diameter).
const RADIUS := 0.6
const THICK := 0.09
const HEIGHT := 1.5
const HALO := 2.4
## The pedestal: a low dais of stone one steps onto (the shop buys by stepping; under the knee, so it never reads as a
## barrier) and its cap (width, height); a narrow one read as a stray tile from the fight's camera.
const PEDESTAL := Vector2(1.0, 0.16)
const PEDESTAL_CAP := Vector2(1.16, 0.06)
## The gold of the disc and the rim (old gold, the cards' frame, never bright yellow).
const GOLD := Color(0.66, 0.5, 0.26)
## The enamel under a struck mark: the reward's colour at this value (dark enough for the gold to stand on it).
const ENAMEL_VALUE := 0.42
## The halo's light: the most it lays at its middle and its brightest channel (under 1, the glow's threshold).
const HALO_ALPHA := 0.4
const HALO_PEAK := 0.55
## It faces the camera and sways slowly round it (a full sway in TURN seconds, SWAY radians each way), leaning back
## LEAN of the camera's pitch so its face is seen whole: spun round, the medallions were edges half the time.
const TURN := 5.0
const SWAY := 0.5
const LEAN := 0.5

const SHADER := preload("res://assets/shaders/reward_gem.gdshader")
const HALO_SHADER := preload("res://assets/shaders/reward_halo.gdshader")

## The shader's marks (reward_gem.gdshader `mark`).
enum Mark { NONE, BLESSING, COIN, HEART, GEM, DROP, CHEVRON_1, CHEVRON_2, CHEVRON_3 }

static var _faces := {}
static var _halos := {}
static var _rim_mat: StandardMaterial3D
static var _face_mesh: QuadMesh
static var _rim_mesh: CylinderMesh
static var _halo_mesh: QuadMesh
static var _mason: Masonry


## Builds the reward's medallion under `parent` (standing at its origin) and returns the node that turns.
## reward: what it gives (RunMap.Reward), or NONE with the room's kind (RunMap.Kind) for a door or an event's spot;
## color: its colour (Rooms._reward_color / _kind_color).
static func make(parent: Node3D, reward: RunMap.Reward, kind: RunMap.Kind, color: Color) -> Node3D:
	_ready()
	var key := "%d|%d" % [reward, kind if reward == RunMap.Reward.NONE else -1]
	# the pedestal: drum and cap, the hall's stone
	var drum := MeshInstance3D.new()
	drum.mesh = _mason.bevel_mesh(Vector3(PEDESTAL.x, PEDESTAL.y, PEDESTAL.x), Masonry.CHAMFER)
	drum.material_override = _mason.stone(0.0)
	drum.position.y = PEDESTAL.y * 0.5
	parent.add_child(drum)
	var cap := MeshInstance3D.new()
	cap.mesh = _mason.bevel_mesh(Vector3(PEDESTAL_CAP.x, PEDESTAL_CAP.y, PEDESTAL_CAP.x), Masonry.CHAMFER * 0.5)
	cap.material_override = _mason.stone(0.0)
	cap.position.y = PEDESTAL.y + PEDESTAL_CAP.y * 0.5
	parent.add_child(cap)
	# the halo behind, facing the camera (it does not turn)
	var halo := MeshInstance3D.new()
	halo.mesh = _halo_mesh
	halo.material_override = _halo(key, color)
	halo.position.y = HEIGHT
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.sorting_offset = -1.0
	parent.add_child(halo)
	# the disc: rim and two faces, swaying (each its own way, by where it stands)
	var spin := Sway.new()
	spin.position.y = HEIGHT
	spin.phase = fposmod(parent.global_position.x * 0.37 + parent.global_position.z * 0.61, 1.0) * TURN if parent.is_inside_tree() else 0.0
	parent.add_child(spin)
	var rim := MeshInstance3D.new()
	rim.mesh = _rim_mesh
	rim.material_override = _rim_mat
	rim.rotation.x = PI * 0.5
	spin.add_child(rim)
	var face_mat := _face(key, reward, kind, color)
	for side in 2:
		var face := MeshInstance3D.new()
		face.mesh = _face_mesh
		face.material_override = face_mat
		face.position.z = (THICK * 0.5 + 0.002) * (1.0 if side == 0 else -1.0)
		face.rotation.y = 0.0 if side == 0 else PI
		spin.add_child(face)
	return spin


## The face's material of one kind of reward (cached: one per kind, never one per instance).
static func face_material(reward: RunMap.Reward, kind: RunMap.Kind, color: Color) -> ShaderMaterial:
	_ready()
	return _face("%d|%d" % [reward, kind if reward == RunMap.Reward.NONE else -1], reward, kind, color)


## The painted medallion of a reward or a room (assets/ui/events), or null when it has none.
static func painting(reward: RunMap.Reward, kind: RunMap.Kind) -> Texture2D:
	match reward:
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return BoonArt.event(&"pomegranate")
		RunMap.Reward.NONE:
			match kind:
				RunMap.Kind.TRIAL:
					return BoonArt.event(&"trial_seal")
				RunMap.Kind.ALTAR:
					return BoonArt.event(&"candles")
	return null


## The mark struck on a reward or a room without a painting (DoorGlyph's).
static func mark_of(reward: RunMap.Reward, kind: RunMap.Kind) -> Mark:
	match reward:
		RunMap.Reward.BOON:
			return Mark.BLESSING
		RunMap.Reward.GOLD:
			return Mark.COIN
		RunMap.Reward.HEART:
			return Mark.HEART
		RunMap.Reward.MAGICK:
			return Mark.GEM
		RunMap.Reward.HEAL:
			return Mark.DROP
		RunMap.Reward.NONE:
			match kind:
				RunMap.Kind.SHOP:
					return Mark.COIN
				RunMap.Kind.FOUNTAIN:
					return Mark.DROP
				RunMap.Kind.MINIBOSS:
					return Mark.CHEVRON_2
				RunMap.Kind.BOSS:
					return Mark.CHEVRON_3
				RunMap.Kind.COMBAT:
					return Mark.CHEVRON_1
	return Mark.NONE


## The enamel under a mark: the colour at ENAMEL_VALUE, hue and saturation kept.
static func enamel(color: Color) -> Color:
	return Color.from_hsv(color.h, minf(color.s, 0.85), ENAMEL_VALUE)


## The disc's mount: faces the camera, sways round it.
class Sway extends Node3D:
	var phase := 0.0

	func _ready() -> void:
		_pose()

	func _process(delta: float) -> void:
		phase += delta
		_pose()

	func _pose() -> void:
		var feel := Feel.live()
		rotation = Vector3(-deg_to_rad(feel.cam_pitch) * LEAN, deg_to_rad(feel.cam_yaw) + sin(phase * TAU / TURN) * SWAY, 0.0)


static func _ready() -> void:
	if _mason != null:
		return
	_mason = Masonry.new(null)
	_face_mesh = QuadMesh.new()
	_face_mesh.size = Vector2(RADIUS * 2.0, RADIUS * 2.0)
	_rim_mesh = CylinderMesh.new()
	_rim_mesh.top_radius = RADIUS
	_rim_mesh.bottom_radius = RADIUS
	_rim_mesh.height = THICK
	_rim_mesh.radial_segments = 32
	_rim_mesh.rings = 1
	_halo_mesh = QuadMesh.new()
	_halo_mesh.size = Vector2(HALO, HALO)
	_rim_mat = StandardMaterial3D.new()
	_rim_mat.albedo_color = GOLD
	_rim_mat.metallic = 0.85
	_rim_mat.roughness = 0.35
	_rim_mat.emission_enabled = true
	_rim_mat.emission = GOLD * 0.12


static func _face(key: String, reward: RunMap.Reward, kind: RunMap.Kind, color: Color) -> ShaderMaterial:
	if _faces.has(key):
		return _faces[key]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	var tex := painting(reward, kind)
	m.set_shader_parameter(&"has_medallion", tex != null)
	if tex:
		m.set_shader_parameter(&"medallion", tex)
	m.set_shader_parameter(&"mark", mark_of(reward, kind))
	m.set_shader_parameter(&"enamel", enamel(color))
	m.set_shader_parameter(&"gold", GOLD)
	_faces[key] = m
	return m


static func _halo(key: String, color: Color) -> ShaderMaterial:
	if _halos.has(key):
		return _halos[key]
	var m := ShaderMaterial.new()
	m.shader = HALO_SHADER
	m.set_shader_parameter(&"color", Color(color.r, color.g, color.b))
	m.set_shader_parameter(&"alpha", HALO_ALPHA)
	m.set_shader_parameter(&"peak", minf(HALO_PEAK, ScreenTone.linear_peak(color)))
	_halos[key] = m
	return m
