class_name GapFloor
extends Node3D
## PT-25-9: the stream or rift that only a dash crosses, drawn on the floor (placeholder: the environment artist's piece
## replaces it): a dark water strip with a pale foam line on each bank and a slow ripple, one per rectangle of
## Arena.gaps. Display only; the rule is GapRule (Player.step keeps walkers out). It hangs from the arena and goes with it.

const Y := 0.04
## The water of the stream as SL-01's (shallow_water.gdshader, its ripples, glint and ragged banks), darker because this
## one is deep: no one wades it. Its damp bank (HallLife's wet decal) BANK times as wide around it.
const WATER := preload("res://assets/shaders/shallow_water.gdshader")
const DEEP := Color(0.02, 0.05, 0.08)
const SHALLOW := Color(0.07, 0.13, 0.17)
const BANK := 1.45
const BANK_Y := 0.03

var _water: Array[ShaderMaterial] = []


func _init(gaps: Array[Rect2] = []) -> void:
	name = "GapFloor"
	for r in gaps:
		_add(r)


## One rectangle: the strip runs along its long side (the shader's banks are across UV.y).
func _add(r: Rect2) -> void:
	var tall := r.size.y > r.size.x
	var length := maxf(r.size.x, r.size.y)
	var width := minf(r.size.x, r.size.y)
	var mat := ShaderMaterial.new()
	mat.shader = WATER
	mat.set_shader_parameter(&"deep", DEEP)
	mat.set_shader_parameter(&"shallow", SHALLOW)
	var damp := HallLife.decal(HallLife.WATER_DAMP, 0.5)
	for part: Array in [[damp, width * BANK, BANK_Y], [mat, width, Y]]:
		var mi := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(length, part[1])
		mi.mesh = plane
		mi.position = Vector3(r.get_center().x, part[2], r.get_center().y)
		if tall:
			mi.rotation.y = PI * 0.5
		mi.material_override = part[0]
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
	_water.append(mat)
