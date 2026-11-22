class_name AccountNode
extends Resource
## One improvement of the account's tree, "O Preparo" (Daniel 2026-11-21; docs/design/benchmark_sworn.md
## section 8, recommendation 1): bought once in the Santuário with a material, kept for every hero and every descent after.
## Its numbers sum into BoonState.stat as the Forja's do (stats: max_hp, damage_pct, room_heal_pct, fountain_heal, gold_pct,
## rarity_bonus, revive), so most need no fight code. Data in data/account/, written by _account in tools/make_data.gd.

@export var id: StringName
## The branch it stands on (vida, cura, ouro, bencao, forca): the screen groups by it.
@export var branch: StringName
## The node that must be bought first (empty: open from the start).
@export var requires: StringName = &""
## Text keys: its name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
@export var material: StringName = &"silver"
@export var cost := 0
@export var mods: Array[BoonMod] = []
