class_name RelicFloor
extends Node3D
## SR-P5, "a relic in the stone" (docs/design/sworn_ref_backlog.md; our version, the theme to confirm with the Daniel,
## no lore): a worn stone at a room's RoomLayout.relic_spots, shown once the fight is won. He uses it with interact
## standing at it, once: it gives gold or Prata Antiga (Rooms decides) and goes dark. PLACEHOLDER for the
## environment-artist's piece: a low stone with a pale ring on top that glows while it is there. Never collides.

var at := Vector2.ZERO
var spent := false
## What it gives: &"gold" or &"silver".
var gives := &"gold"
var _glow: StandardMaterial3D


static func make(parent: Node, spot: Vector2, what: StringName) -> RelicFloor:
	var r := RelicFloor.new()
	r.at = spot
	r.gives = what
	r.position = Vector3(spot.x, 0.0, spot.y)
	parent.add_child(r)
	return r


func _ready() -> void:
	var stone := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.45
	cyl.bottom_radius = 0.6
	cyl.height = 0.7
	cyl.radial_segments = 8
	stone.mesh = cyl
	stone.position.y = 0.35
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.22, 0.21, 0.2)
	m.roughness = 0.95
	stone.material_override = m
	add_child(stone)
	var ring := MeshInstance3D.new()
	var tor := TorusMesh.new()
	tor.inner_radius = 0.26
	tor.outer_radius = 0.34
	ring.mesh = tor
	ring.position.y = 0.72
	_glow = StandardMaterial3D.new()
	_glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = _glow
	add_child(ring)
	_show()


func spend() -> void:
	spent = true
	if is_inside_tree():
		_show()


func _show() -> void:
	var c := Color(0.95, 0.85, 0.6) if gives == &"gold" else Color(0.78, 0.82, 0.92)
	_glow.albedo_color = Color(0.12, 0.12, 0.12) if spent else c
