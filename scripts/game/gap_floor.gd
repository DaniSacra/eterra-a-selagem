class_name GapFloor
extends Node3D
## PT-25-9: the stream or rift that only a dash crosses, drawn on the floor (placeholder: the environment artist's piece
## replaces it): a dark water strip with a pale foam line on each bank and a slow ripple, one per rectangle of
## Arena.gaps. Display only; the rule is GapRule (Player.step keeps walkers out). It hangs from the arena and goes with it.

## SL-01b: the same canal as the Salao's river (Canal: damp, kerbs on both banks, water with its rim shadow and reflection),
## the water darker because this one is deep: no one wades it. The kerb is continuous: it is crossed by dashing.
const SHEEN_AT := Vector2(-2.0, 0.0)

var _water: Array[ShaderMaterial] = []


func _init(gaps: Array[Rect2] = []) -> void:
	name = "GapFloor"
	for r in gaps:
		_add(r)


## One rectangle: the canal runs along its long side, as wide as the short one.
func _add(r: Rect2) -> void:
	var tall := r.size.y > r.size.x
	var length := maxf(r.size.x, r.size.y)
	var width := minf(r.size.x, r.size.y)
	var c := r.get_center()
	var half := Vector2(0.0, length * 0.5) if tall else Vector2(length * 0.5, 0.0)
	var line := PackedVector2Array()
	var widths := PackedFloat32Array()
	for k in 9:
		line.append(c - half + half * 2.0 * (float(k) / 8.0))
		widths.append(width)
	var mat := Canal.water(SHEEN_AT, true, ArenaRoom.compat())
	# art review 2026-11-26 (4): a broken foam line on each bank on top of the stone kerb and the dark deep water
	mat.set_shader_parameter(&"foam", 0.75)
	Canal.dress(self, line, widths, mat)
	_water.append(mat)
