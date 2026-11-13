class_name Boon
extends Resource
## A gift (dom) sent by one of the companion paladins. Gifts change the moves of the combo tree; they never attack alone.

enum Family { CHAMA, GEADA, LUZ, VIGILIA, DUO }

const FAMILY_COLOR: Array[StringName] = [&"perigo", &"noite", &"luz", &"vida", &"misterio"]
const FAMILY_KEY: Array[StringName] = [&"family_chama", &"family_geada", &"family_luz", &"family_vigilia", &"family_duo"]

@export var id: StringName
@export var family: Family = Family.LUZ
## Frame of the "icons" sprite.
@export var icon := 0
@export var max_level := 3
## A combination: offered only when every gift listed here is owned.
@export var requires: Array[StringName] = []
@export var mods: Array[BoonMod] = []


func color_family() -> StringName:
	return FAMILY_COLOR[family]


func is_duo() -> bool:
	return not requires.is_empty()
