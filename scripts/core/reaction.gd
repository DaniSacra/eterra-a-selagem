class_name Reaction
extends RefCounted
## One elemental reaction (Maga v3, 04_PLANO C.2). Pure data; the caller deals the damage and the freeze.
## Reactions never apply elemental states and never trigger other reactions.

enum Kind { THERMAL, OVERLOAD, CRYSTAL }

var kind: int = Kind.THERMAL
var target: Object = null
## Damage on the target (Choque Térmico) or in the area (Sobrecarga: the caller spreads it to the neighbours).
var damage := 0.0
## Area radius in metres (0 = target only).
var radius := 0.0
## Seconds to freeze the target (Cristalização on common enemies).
var freeze := 0.0
## Poise broken instead of a freeze (Cristalização on bosses and armoured).
var poise := 0.0


static func make(k: int, key: Object) -> Reaction:
	var r := Reaction.new()
	r.kind = k
	r.target = key
	return r
