class_name ForgeRank
extends Resource
## One rank of the Forja da Emeth (Rejogabilidade, Fatia 1; docs/design/rejogabilidade/sistemas.md 1.5): bought once
## in the hub with a material, kept for every descent after, its numbers summed with the Blessings and the Gifts in
## BoonState.stat (level 1, never scaled by rarity), so it needs no fight code. Data in data/forge/emeth/, written by
## _forge in tools/make_data.gd. The Fatia 1 has the track temper (Temperar I and II); Refinar and Despertar come later.

## Fatia 2: the track refine (Refinar) holds choices, not steps: each bought once (rank 1), one on each action (slot:
## &"attack", &"special"; free to change in the hub), opened by a tool (tool: the Forjador's tool it needs).
@export var slot: StringName = &""
@export var tool: StringName = &""
## The track it belongs to and its place on it (1, 2...): the save keeps the highest rank bought of each track
## (heroes.<id>.forge.temper).
@export var id: StringName
@export var track: StringName = &"temper"
@export var rank := 1
## Text keys: its name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
## What it costs (MaterialPurse ids) and how much.
@export var material: StringName = &"silver"
@export var cost := 0
## The numbers it adds (BoonMod: damage_pct with a tag, as the Blessings).
@export var mods: Array[BoonMod] = []
