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
## True when the albedo is a painted texture of its own (the Meshy figures): what glows and what is metal is read
## from its colours (crowd.gdshader). False: a KayKit palette, whose glowing cells are fixed.
@export var painted := false
## Cells of the texture that glow by themselves: every texel from this UV on (the last four cells of a KayKit
## palette's bottom row: eyes, embers, gems; on a painted figure, the same cells of the palette strip under it).
@export var glow_from := Vector2(0.5, 0.75)
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
