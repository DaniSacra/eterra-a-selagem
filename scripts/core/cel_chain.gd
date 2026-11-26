class_name CelChain
extends RefCounted
## Blessings V2 (IMPLEMENTACAO_V2.md 2.2): the lineage of a reaction. Every secondary effect is born of an event with the action
## it came from, what it is (`last`: direct, tick, combust, shatter, discharge...) and how deep it is. A reaction may only follow
## what CelRules.EDGES allows and never past CelRules.CHAIN_DEPTH, so nothing feeds on itself (an echo of an echo, a copy of a
## copy, a discharge of a discharge). Pure: nothing here touches a node.

var action := 0
var last: StringName = &"direct"
var depth := 0


func _init(action_ := 0, last_: StringName = &"direct", depth_ := 0) -> void:
	action = action_
	last = last_
	depth = depth_


## True when a reaction of this kind may follow this event.
func may(kind: StringName) -> bool:
	return CelRules.may_chain(last, kind, depth)


## The event of a reaction that follows this one, or null when it may not (a reaction that cannot simply does not happen).
func enter(kind: StringName) -> CelChain:
	if not may(kind):
		return null
	return CelChain.new(action, kind, depth + 1)
