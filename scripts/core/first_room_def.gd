class_name FirstRoomDef
extends Resource
## One room of the guided first descent (SW-O4, docs/design/onboarding_sw_o.md): what it is, where it stands in the
## line, how its fight is written by hand and what it gives. Data only; written by `_first` in tools/make_data.gd.
## Rooms with the same `layer` are the doors' alternatives of that step (each leads to every room of the next layer, as
## RunMap draws it); a layer of one room has one way on.

@export var id: StringName = &""
## The step of the descent (0 the Antessala; the last the chamber of Morvath: its depth in the HUD's "Sala N de 8").
@export var layer := 0
@export var kind := RunMap.Kind.COMBAT
## The arena (RoomLayout.id) and how it is dressed (RoomLayout.variant); the boss and the shop have their own.
@export var layout_id: StringName = &""
@export var variant := 0
## The fight written by hand: one list of enemy ids (EnemyDef.id) per wave. A guardian's room holds only him.
@export var waves: Array[PackedStringArray] = []
## What the room gives when won, and for a Blessing the angel whose cards come (&"": drawn as ever).
@export var reward := RunMap.Reward.NONE
@export var angel: StringName = &""
## The guardian who waits there (EnemyDef.id), and the share of his life (1.0: as he is).
@export var guardian: StringName = &""
@export var hp_scale := 1.0
## Whether the arena's hazards run in this room, and the share of the descent they run at (EncounterGen.progress: -1 by
## the depth); a room that teaches a hazard sets both.
@export var hazards := false
@export var hazard_progress := -1.0
## Enemies standing at once at most while its waves come in.
@export var cap := 4
## The tip (a data/text_pt.tres key; the HUD's) shown in the room, and the objective forced on walking in (&"": the rule's).
@export var tip: StringName = &""
@export var objective: StringName = &""


## The enemies the room brings, once each (the fight's `kinds`).
func kinds() -> Array[StringName]:
	var out: Array[StringName] = []
	for w in waves:
		for id_ in w:
			if not out.has(StringName(id_)):
				out.append(StringName(id_))
	return out
