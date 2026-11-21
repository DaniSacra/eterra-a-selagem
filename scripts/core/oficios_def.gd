class_name OficiosDef
extends Resource
## Ofícios, Roteiro A, "A Primeira Picareta" (docs/design/oficios/15_prototipo.md; Q-OF1 to Q-OF4 and Q-OF6 a): the
## numbers of the journey, one resource (data/oficios/oficios.tres, part `oficios` of tools/make_data.gd). A vein of
## Pedra Funda seen without the pick is noted; the Forjador then asks for the pick's head, found in a room marked on
## the map (or given by the guardian after pity_runs descents that passed it without the room); restored for
## restore_cost, the pick opens the veins; the first stone opens the Vendedor's order, whose delivery makes the first
## Obra. Names are working names (Q-OF5).

const SILVER := &"silver"
const MEMORY := &"memory"
const EMERALD := &"emerald"

## The tool, its broken head (a find) and the craft item it opens.
@export var tool := &"pick"
@export var head := &"pick_head"
@export var stone := &"pedra_funda"
## What restoring the pick costs (Prata 20, Q-OF11 a) and how many Pedra Funda the save holds at most (Q-OF4 a).
@export var restore_cost := {SILVER: 20}
@export var stone_cap := 10
## The veins: the arenas they stand in (RoomLayout.gather_spots), past the guardian's layer only, at most veins_max
## extracted a descent; one press, then vein_hold seconds standing at it (walking off stops it), vein_stones each.
@export var vein_arenas: Array[StringName] = [&"rift", &"runes"]
@export var veins_max := 2
@export var vein_hold := 1.0
@export var vein_stones := 1
## The room marked for the head: a fight room between these depths; pity: the guardian won gives it after this many
## descents that passed the guardian with the room marked and not taken.
@export var find_depth_min := 4
@export var find_depth_max := 8
@export var pity_runs := 2
## The Vendedor's order (OF-13): what it asks for (items and materials), opened by the first Pedra Funda ever held;
## the Obra its delivery makes (OF-14, the angels' preview on the map).
@export var order := &"vendor_stone"
@export var order_wants := {&"pedra_funda": 2, SILVER: 30}
@export var order_gives := &"angel_preview"


static func live() -> OficiosDef:
	return load("res://data/oficios/oficios.tres")
