class_name RunSpoils
extends RefCounted
## What a descent opened (PT-25-6, the end screen's "Liberado nesta descida"): the milestones the save reached during
## the run, told by the Santuário piece each one opens ("A Videira liberada"). Pure; Game snapshots the ids when the run
## starts (Milestones.reached) and again when the end screen opens.
##   RunSpoils.opened(before, after) -> the ids in `after` that were not in `before`, in order
##   RunSpoils.text_key(id)          -> the text key that names the opening ("end_open_<id>")


static func opened(before: Array, after: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in after:
		if not before.has(id):
			out.append(StringName(id))
	return out


static func text_key(id: StringName) -> StringName:
	return StringName("end_open_%s" % id)
