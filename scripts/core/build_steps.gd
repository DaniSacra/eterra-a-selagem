class_name BuildSteps
extends RefCounted
## A room's build as a list of steps (QA P1-1): on a screen the steps get a black frame each (Arena.build_async), so
## no frame of a new room waits on the whole build; without, they run at once. A step may give back an Array of more
## steps (a merge in slices, Masonry.merge_steps): they run right after it, before the rest.


## Runs the steps and the ones they give back, in order, at once.
static func run(steps: Array) -> void:
	var queue := steps.duplicate()
	var k := 0
	while k < queue.size():
		var more: Variant = (queue[k] as Callable).call()
		k += 1
		if is_more(more):
			var rest := queue.slice(k)
			queue.resize(k)
			queue.append_array(more)
			queue.append_array(rest)


## True when what a step gave back is more steps.
static func is_more(v: Variant) -> bool:
	return v is Array and not (v as Array).is_empty() and (v as Array)[0] is Callable
