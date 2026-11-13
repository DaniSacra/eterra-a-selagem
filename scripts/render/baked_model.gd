class_name BakedModel
extends Resource
## A character baked into still poses: for each animation, a list of meshes (one per frame) that a MultiMesh can draw
## hundreds of times. Written by tools/bake.gd from the glTF models, read by CrowdRenderer.

## Animation name -> Array of Mesh, one per frame.
@export var anims: Dictionary = {}
## Animation name -> frames per second of the baked frames.
@export var fps: Dictionary = {}
## Animation name -> true when the animation loops.
@export var loops: Dictionary = {}
@export var albedo: Texture2D
## Height of the model standing, in meters (for life bars and hit effects).
@export var height := 2.0


func frame_count(anim: StringName) -> int:
	return (anims.get(anim, []) as Array).size()


## Frame to show after t seconds of an animation.
func frame_at(anim: StringName, t: float) -> int:
	var n := frame_count(anim)
	if n == 0:
		return 0
	var i := int(t * float(fps.get(anim, 10.0)))
	return i % n if loops.get(anim, false) else mini(i, n - 1)


func duration(anim: StringName) -> float:
	return frame_count(anim) / maxf(float(fps.get(anim, 10.0)), 0.001)
