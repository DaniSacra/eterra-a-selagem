class_name VineNode
extends Resource
## One node of A Videira (Daniel 2026-11-23, docs/design/videira_pacote_2026-11-23/; it replaced "O Preparo"): bought once
## at the Santuário with a material, kept for every hero and every descent after. Its numbers sum into BoonState.stat as the
## Forja's do. Stats: max_hp (Vida); traveler (a merchant before each guardian), shop_extra (one more item in the shops),
## shop_care (a healing item always on the shelf) (Provisão); silver_pct, memory_pct, material_pct (Perseverança).
## Data in data/vine/, written by _vine in tools/make_data.gd.

@export var id: StringName
## The branch it stands on (vida, provisao, perseveranca): the screen groups by it.
@export var branch: StringName
## Its place in the branch, 1 to 3 (the order of purchase inside the branch).
@export var step := 1
## The node that must be bought first (empty: the first of its branch).
@export var requires: StringName = &""
## Text keys: its name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
@export var material: StringName = &"silver"
@export var cost := 0
@export var mods: Array[BoonMod] = []
