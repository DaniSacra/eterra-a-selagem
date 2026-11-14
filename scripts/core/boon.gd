class_name Boon
extends Resource
## A gift (dom) sent by one of the companion paladins. A gift changes the moves of the combo tree (mods), acts on its
## own every few seconds (skill), or both.

enum Family { CHAMA, GEADA, LUZ, VIGILIA, DUO }
## The action a gift rides on. One gift per action: taking another for the same action replaces it.
## NONE: a gift that acts on its own or helps always (any number of them).
enum Slot { NONE, ATTACK, SPECIAL, CAST, DASH }
## How strong the gift comes: rarer cards multiply its numbers (the ones marked by_rarity).
enum Rarity { COMMON, RARE, EPIC, HEROIC }

const RARITY_MULT: Array[float] = [1.0, 1.5, 2.0, 2.5]
## Chance weights of each rarity when a card is drawn (Hades II: rare 10%, epic 5%, the rest common).
const RARITY_WEIGHT: Array[float] = [85.0, 10.0, 5.0, 0.0]
## The gift a guardian leaves is never common (Hades II: rare 90, epic 7, legendary 5).
const RARITY_WEIGHT_GUARDIAN: Array[float] = [0.0, 90.0, 7.0, 5.0]
const RARITY_COLOR: Array[Color] = [Color(0.92, 0.92, 0.92), Color(0.35, 0.6, 1.0), Color(0.75, 0.4, 1.0), Color(1.0, 0.3, 0.25)]
const RARITY_KEY: Array[StringName] = [&"rarity_common", &"rarity_rare", &"rarity_epic", &"rarity_heroic"]
## The tag of the moves each action's gifts change (Slot order).
const SLOT_TAG: Array[StringName] = [&"", &"light", &"heavy", &"cast", &"dash"]
const SLOT_KEY: Array[StringName] = [&"", &"slot_attack", &"slot_special", &"slot_cast", &"slot_dash"]

const FAMILY_COLOR: Array[Color] = [Color(1.0, 0.45, 0.12), Color(0.45, 0.8, 1.0), Color(1.0, 0.85, 0.4), Color(0.45, 0.95, 0.6), Color(0.85, 0.5, 1.0)]
## Tag carried by the hits of a family's skills, so other gifts can change them.
const FAMILY_TAG: Array[StringName] = [&"chama", &"geada", &"luz", &"vigilia", &"duo"]
const FAMILY_KEY: Array[StringName] = [&"family_chama", &"family_geada", &"family_luz", &"family_vigilia", &"family_duo"]

@export var id: StringName
@export var family: Family = Family.LUZ
## Which glyph the card and the HUD draw (see scripts/ui/boon_icon.gd).
@export var icon := 0
@export var max_level := 3
@export var slot: Slot = Slot.NONE
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
