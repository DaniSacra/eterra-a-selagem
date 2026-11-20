class_name Boon
extends Resource
## A gift (dom) sent by one of the companion paladins. A gift changes the moves of the combo tree (mods), acts on its
## own every few seconds (skill), or both.

enum Family { CHAMA, GEADA, LUZ, VIGILIA, DUO }
## The action a gift rides on. One gift per action: taking another for the same action replaces it.
## NONE: a gift that acts on its own or helps always (any number of them).
enum Slot { NONE, ATTACK, SPECIAL, CAST, DASH }
## How strong the gift comes: rarer cards multiply its first level (BoonMod.base, a skill's first damage). The four
## rarities of decision D-52: common, rare, epic and legendary, the legendary only by a trade (E3-01; Hades II's heroic;
## Hades II's legendary is our Psalm). An Elo has no rarity (BUG-017).
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

## Fixed multipliers (decision D-53 (a); Hades II draws them in a range, 1.3 to 1.5 and so on).
const RARITY_MULT: Array[float] = [1.0, 1.5, 2.0, 2.5]
## Chances of a card, tried in turn from common (C13-03, Hades II's RarityChances): rare, epic, legendary; the last
## that passes is the card's. So 85.5% common, 9.5% rare, 5% epic. The legendary never in the draw (only a trade).
## These are the defaults; a stage carries its own (StageDef.rarity_chance).
const RARITY_CHANCE: Array[float] = [0.10, 0.05, 0.0]
## The guardian's (Hades II's Erebus: rare 90, epic 7, legendary 5; that legendary is the Psalm, none yet): 9.3% common.
const RARITY_CHANCE_GUARDIAN: Array[float] = [0.90, 0.07, 0.0]
## Chance a card is an Elo when one can be formed (C13-06, Hades II's duo: 12%).
const ELO_CHANCE := 0.12
## Chance a card offers to trade the Blessing on an action already held for another, one rarity higher and at the
## same level (E3-01, Hades II's ReplaceChance 0.1).
const TRADE_CHANCE := 0.1
## The colour of each rarity, the same everywhere (cards, the Blessings panel): rare a cold blue, epic violet,
## legendary old gold (HSV saturation 0.52, never bright yellow). The card draws common in its own quiet metal
## (BoonCard.COMMON_EDGE).
const RARITY_COLOR: Array[Color] = [Color(0.92, 0.92, 0.92), Color("6f9be6"), Color("b07ae6"), Color("d4ad66")]
const RARITY_KEY: Array[StringName] = [&"rarity_common", &"rarity_rare", &"rarity_epic", &"rarity_legendary"]
## The tag of the moves each action's gifts change (Slot order).
const SLOT_TAG: Array[StringName] = [&"", &"light", &"heavy", &"cast", &"dash"]
const SLOT_KEY: Array[StringName] = [&"", &"slot_attack", &"slot_special", &"slot_cast", &"slot_dash"]

## vfx_pass_spec.md 4 (Lote 1): Chama amber, Geada as it was, Luz pale gold, Vigília sage (hue 82; was the emerald's
## green), Elo old gold (was violet, Morvath's). The cards, the HUD and the effects read them (Combat.color_of the same).
const FAMILY_COLOR: Array[Color] = [Color(1.0, 0.6, 0.16), Color(0.45, 0.8, 1.0), Color(1.0, 0.92, 0.7), Color(0.66, 0.78, 0.46), Color(0.78, 0.62, 0.34)]
## Tag carried by the hits of a family's skills, so other gifts can change them.
const FAMILY_TAG: Array[StringName] = [&"chama", &"geada", &"luz", &"vigilia", &"duo"]
const FAMILY_KEY: Array[StringName] = [&"family_chama", &"family_geada", &"family_luz", &"family_vigilia", &"family_duo"]

@export var id: StringName
@export var family: Family = Family.LUZ
## Which glyph the card and the HUD draw (see scripts/ui/boon_icon.gd).
@export var icon := 0
## The highest level (0: no ceiling, as in Hades II). An Elo stays at 1: it never grows (BUG-017).
@export var max_level := 3
@export var slot: Slot = Slot.NONE
## An Elo (E3-02, Hades II's OneFromEachSet): offered when one gift of each list is owned (a list per family). The
## first of each list is the one the card shows when none is owned.
@export var requires_sets: Array[PackedStringArray] = []
@export var mods: Array[BoonMod] = []
@export var skill: SkillDef


func color() -> Color:
	return FAMILY_COLOR[family]


func family_tag() -> StringName:
	return FAMILY_TAG[family]


func is_duo() -> bool:
	return family == Family.DUO or not requires_sets.is_empty()


## An Elo has no rarity and no level beyond 1 (BUG-017: Hades II's duos never grow and never scale by rarity).
func has_rarity() -> bool:
	return not is_duo()


## True while a level more is still possible at this level.
func can_grow(level: int) -> bool:
	return max_level <= 0 or level < max_level
