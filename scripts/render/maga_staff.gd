class_name MagaStaff
extends RefCounted
## The Maga's Bastão Rúnico de Duas Pontas (maga.md 1; M1c, 2026-11-23): the Meshy model w_maga_staff (text to 3D after
## the pack's art 01: an open gold ring with spikes around an amber orb and a gold point, on a dark shaft with ivory
## wraps). Meshy made the head at one end only, so the staff is two copies of it, butt to butt in her fist: the same
## head at both ends, as the art has it. The staff's space is the sword's (HeroBody places it in the right hand): the
## fist at the origin, the staff along +Y and -Y, each head's point HALF from the fist.

const MODEL := "res://assets/models/meshy/w_maga_staff/w_maga_staff.glb"
## The model's own space (along +Y, 0.95 long, its middle at the origin): the top point and the lower ivory wrap,
## where the fist closes (the butt spike under it goes into the other copy's shaft).
const MODEL_TOP := 0.475
const MODEL_HAND := -0.36
## Fist to each point, in the sword's space (1 = 1.1 m as drawn): the whole staff about her drawn height, a little
## under the art's (there it is longer than she is tall, and the lower head would cut the floor in the idle).
const HALF := 1.2


## The staff: an empty holder at the fist with the two copies under it ("Upper" and "Lower"), painted as the body.
static func make() -> MeshInstance3D:
	var root := MeshInstance3D.new()
	var scene := (load(MODEL) as PackedScene).instantiate()
	var model := scene.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var size := HALF / (MODEL_TOP - MODEL_HAND)
	for half: Array in [[&"Upper", Basis()], [&"Lower", Basis(Vector3.BACK, PI)]]:
		var mi := MeshInstance3D.new()
		mi.name = half[0]
		mi.mesh = model.mesh
		var turn: Basis = half[1]
		mi.transform = Transform3D(turn.scaled(Vector3.ONE * size), turn * Vector3(0, -MODEL_HAND * size, 0))
		root.add_child(mi)
	scene.free()
	HeroBody._fill(root)
	return root
