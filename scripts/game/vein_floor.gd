class_name VeinFloor
extends Node3D
## Ofícios, Roteiro A (OF-08, OF-10): a vein of Pedra Funda at a room's RoomLayout.gather_spots, shown once the room is
## won. PLACEHOLDER for the environment-artist's piece (three states: closed without the pick, open, spent; in the
## stone of the Fendas and the Runas, no amber, red, violet nor emerald): a dark stone block with a pale grey thread.
## Never collides (P10). Rooms drives it: use_kind &"vein", one press, then OficiosDef.vein_hold seconds at it.

enum State { CLOSED, OPEN, SPENT }

var at := Vector2.ZERO
var state := State.CLOSED
## Seconds of extraction done (0 until pressed; walking off stops and forgets it).
var progress := -1.0
var _thread: StandardMaterial3D


static func make(parent: Node, spot: Vector2, open: bool) -> VeinFloor:
	var v := VeinFloor.new()
	v.at = spot
	v.state = State.OPEN if open else State.CLOSED
	v.position = Vector3(spot.x, 0.0, spot.y)
	parent.add_child(v)
	return v


func _ready() -> void:
	var rock := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.1, 0.7, 0.8)
	rock.mesh = box
	rock.position.y = 0.35
	rock.rotation.y = 0.5
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.2, 0.21, 0.23)
	m.roughness = 0.95
	rock.material_override = m
	add_child(rock)
	var line := MeshInstance3D.new()
	var bar := BoxMesh.new()
	bar.size = Vector3(0.9, 0.06, 0.82)
	line.mesh = bar
	line.position.y = 0.42
	line.rotation = Vector3(0.0, 0.5, 0.35)
	_thread = StandardMaterial3D.new()
	_thread.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.material_override = _thread
	add_child(line)
	_show()


func set_state(s: State) -> void:
	state = s
	if is_inside_tree():
		_show()


func _show() -> void:
	var grey := {State.CLOSED: 0.42, State.OPEN: 0.78, State.SPENT: 0.18}
	var g: float = grey[state]
	_thread.albedo_color = Color(g, g * 1.01, g * 1.04)
