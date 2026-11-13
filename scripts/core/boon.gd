class_name Boon
extends Resource
## A gift (dom) sent by one of the companion paladins. A gift changes the moves of the combo tree (mods), acts on its
## own every few seconds (skill), or both.

enum Family { CHAMA, GEADA, LUZ, VIGILIA, DUO }

const FAMILY_COLOR: Array[Color] = [Color(1.0, 0.45, 0.12), Color(0.45, 0.8, 1.0), Color(1.0, 0.85, 0.4), Color(0.45, 0.95, 0.6), Color(0.85, 0.5, 1.0)]
## Tag carried by the hits of a family's skills, so other gifts can change them.
const FAMILY_TAG: Array[StringName] = [&"chama", &"geada", &"luz", &"vigilia", &"duo"]
const FAMILY_KEY: Array[StringName] = [&"family_chama", &"family_geada", &"family_luz", &"family_vigilia", &"family_duo"]

@export var id: StringName
@export var family: Family = Family.LUZ
## Which glyph the card and the HUD draw (see scripts/ui/boon_icon.gd).
@export var icon := 0
@export var max_level := 3
## A combination: offered only when every gift listed here is owned.
@export var requires: Array[StringName] = []
@export var mods: Array[BoonMod] = []
@export var skill: SkillDef


func color() -> Color:
	return FAMILY_COLOR[family]


func family_tag() -> StringName:
	return FAMILY_TAG[family]


func is_duo() -> bool:
	return not requires.is_empty()
