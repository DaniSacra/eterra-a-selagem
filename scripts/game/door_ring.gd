class_name DoorRing
extends MeshInstance3D
## The ring of energy round a door's medallion (Daniel 2026-11-23): a band of the room's own colour that pulses slowly
## (door_ring.gdshader) and burns stronger while the hero stands by the door (DoorTip sets `target`). The painted
## medallion is untouched; the ring is a quad facing the camera behind it, one material per door.
## RewardGem.make builds it over a door's mouth; find the doors' rings with DoorRing.GROUP.

const GROUP := &"door_ring"
const SHADER := preload("res://assets/shaders/door_ring.gdshader")
## Quad size against the disc's radius (the band sits at 0.74 of the quad: a little outside the disc).
const SPAN := 3.0
## How fast `near` follows `target` (per second).
const EASE := 7.0

var door := -1
## 0 (far) to 1 (the hero is by it); `near` follows it.
var target := 0.0
var near := 0.0
var _mat: ShaderMaterial


static func make(door_index: int, color: Color, scale_to: float) -> DoorRing:
	var r := DoorRing.new()
	r.name = "DoorRing"
	r.door = door_index
	var q := QuadMesh.new()
	q.size = Vector2.ONE * SPAN * RewardGem.RADIUS * scale_to
	r.mesh = q
	r._mat = ShaderMaterial.new()
	r._mat.shader = SHADER
	r._mat.set_shader_parameter(&"color", Color(color.r, color.g, color.b))
	r.material_override = r._mat
	r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	r.sorting_offset = -0.5
	r.add_to_group(GROUP)
	return r


func _process(delta: float) -> void:
	if is_equal_approx(near, target):
		return
	near = move_toward(near, target, EASE * delta)
	_mat.set_shader_parameter(&"near", near)
