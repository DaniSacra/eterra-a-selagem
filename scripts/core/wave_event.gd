class_name WaveEvent
extends Resource
## Something that happens once at a fixed time: an elite walks in, the light fountain springs, the crypt opens.

enum Kind { ELITE, FOUNTAIN, BOSS }

@export var time := 300.0
@export var kind: Kind = Kind.ELITE
@export var enemy: StringName
