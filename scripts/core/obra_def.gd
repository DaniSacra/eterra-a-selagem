class_name ObraDef
extends Resource
## One Obra of the Santuário, made at the Vendedor (Rejogabilidade, Fatia 3; sistemas.md 1.7: the Hades II's Cauldron):
## a one-time cost in the three materials that opens something in every descent after it, as numbers of the stage
## (StageDef property: value, laid over the stage by Vendor.stage_for). Kept with the Ofícios' recipes
## (oficios.recipes). Working names. Data in data/obras/, written by _obras in tools/make_data.gd.

@export var id: StringName
@export var name_key: StringName
@export var desc_key: StringName
## What it costs (material id: count; MaterialPurse ids).
@export var cost: Dictionary = {}
## The StageDef numbers it changes (property name: value).
@export var stage: Dictionary = {}
