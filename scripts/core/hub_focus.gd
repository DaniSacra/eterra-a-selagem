class_name HubFocus
extends RefCounted
## Which station of the hub is in focus (HUB-B1, docs/design/hub_spec_art.md 2.4): one comes into focus when the
## hero walks within HubPlan.FOCUS_IN of its use point and leaves it past FOCUS_OUT (no flicker on the line); with two
## in reach the nearer wins, and the one in focus only gives way to another FOCUS_SWITCH meters nearer.
##   var focus := HubFocus.new(points)      # {id: use point (x, z)}
##   if focus.step(hero.pos): sign_for(focus.current)

## The station in focus (&"": none).
var current: StringName = &""
var points: Dictionary = {}
var enter := HubPlan.FOCUS_IN
var leave := HubPlan.FOCUS_OUT
var switch := HubPlan.FOCUS_SWITCH


func _init(use_points: Dictionary) -> void:
	points = use_points


## Looks again from where the hero stands; true when the station in focus changed.
func step(at: Vector2) -> bool:
	var best: StringName = &""
	var best_d := INF
	for id: StringName in points:
		var d := at.distance_to(points[id])
		if d <= enter and d < best_d:
			best = id
			best_d = d
	var was := current
	if current != &"":
		var held := at.distance_to(points[current])
		if held > leave:
			current = best
		elif best != &"" and best != current and best_d < held - switch:
			current = best
	else:
		current = best
	return current != was
