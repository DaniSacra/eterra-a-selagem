class_name Boon
extends Resource
## A gift (dom) sent by one of the companion paladins. A gift changes the moves of the combo tree (mods), acts on its
## own every few seconds (skill), or both.

## VEU, MARE and MARCA come after DUO so the old indexes keep their place (AN-2: the angels Velael, Galael and Qeshael).
enum Family { CHAMA, GEADA, LUZ, VIGILIA, DUO, VEU, MARE, MARCA }
## The action a gift rides on. One gift per action: taking another for the same action replaces it.
## NONE: a gift that acts on its own or helps always (any number of them). BO-2: one Slot a button, six in all; DASH is
## the dodge (Space), RUSH the Investida (E), ULT the ultimate (Shift: only in the draw once the ultimate is open).
## RUSH and ULT come last so the indexes of the others keep their place (TalentDef, PsalmDef and EnchantDef share this).
enum Slot { NONE, ATTACK, SPECIAL, CAST, DASH, RUSH, ULT }
## How strong the gift comes: rarer cards multiply its first level (BoonMod.base, a skill's first damage). The four
## rarities of decision D-52: common, rare, epic and legendary, the legendary only by a trade (E3-01; Hades II's heroic;
## Hades II's legendary is our Psalm). An Elo has no rarity (BUG-017).
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

## Fixed multipliers (decision D-53 (a); Hades II draws them in a range, 1.3 to 1.5 and so on).
const RARITY_MULT: Array[float] = [1.0, 1.5, 2.0, 2.5]
## Chances of a card, tried in turn from common (C13-03, Hades II's RarityChances): rare, epic, legendary; the last
## that passes is the card's: 77.4 / 14.7 / 5.9 / 2% (SW-B2; the SWORN gives 79.5 / 14 and 6.5 for the top three).
## These are the defaults; a stage carries its own (StageDef.rarity_chance).
const RARITY_CHANCE: Array[float] = [0.16, 0.06, 0.02]
## The guardian's (Hades II's Erebus: rare 90, epic 7; the legendary 3%, decision 10 of 2026-11-22).
const RARITY_CHANCE_GUARDIAN: Array[float] = [0.90, 0.07, 0.03]
## The most a card's chance of being an Elo grows to when one can be formed (C13-06; SW-B2, the SWORN's duo: 0 to 50%).
const ELO_CHANCE := 0.5
## SW-B2: the share of ELO_CHANCE by Blessings held (index = how many; the last one holds after it): none below three,
## then a straight climb to the whole at ten (SWORN: 0 at two Blessings, 50% at ten).
const ELO_RAMP: Array[float] = [0.0, 0.0, 0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
## Chance a card offers to trade the Blessing on an action already held for another, one rarity higher and at the
## same level (E3-01, Hades II's ReplaceChance 0.1).
const TRADE_CHANCE := 0.1
## The colour of each rarity, the same everywhere (cards, the Blessings panel): rare a cold blue, epic violet,
## legendary old gold (HSV saturation 0.52, never bright yellow). The card draws common in its own quiet metal
## (BoonCard.COMMON_EDGE).
const RARITY_COLOR: Array[Color] = [Color(0.92, 0.92, 0.92), Color("6f9be6"), Color("b07ae6"), Color("d4ad66")]
const RARITY_KEY: Array[StringName] = [&"rarity_common", &"rarity_rare", &"rarity_epic", &"rarity_legendary"]
## The tag of the moves each action's gifts change (Slot order).
const SLOT_TAG: Array[StringName] = [&"", &"light", &"heavy", &"cast", &"dash", &"dash", &"ultimate"]
const SLOT_KEY: Array[StringName] = [&"", &"slot_attack", &"slot_special", &"slot_cast", &"slot_dash", &"slot_rush", &"slot_ult"]

## AN-2: Veu a smoke grey warmed by the dusk (hue 30, low saturation), Mare a deep sea blue (hue 220, far from the
## Geada's ice at 200 by its depth), Marca an olive bronze (hue 47, darker than the Luz's pale gold).
## vfx_pass_spec.md 4 (Lote 1): Chama amber, Geada as it was, Luz pale gold, Vigília sage (hue 82; was the emerald's
## green), Elo old gold (was violet, Morvath's). The cards, the HUD and the effects read them (Combat.color_of the same).
const FAMILY_COLOR: Array[Color] = [Color(1.0, 0.6, 0.16), Color(0.45, 0.8, 1.0), Color(1.0, 0.92, 0.7), Color(0.66, 0.78, 0.46), Color(0.78, 0.62, 0.34),
	Color(0.76, 0.7, 0.64), Color(0.3, 0.5, 0.86), Color(0.7, 0.62, 0.3)]
## Tag carried by the hits of a family's skills, so other gifts can change them.
const FAMILY_TAG: Array[StringName] = [&"chama", &"geada", &"luz", &"vigilia", &"duo", &"veu", &"mare", &"marca"]
const FAMILY_KEY: Array[StringName] = [&"family_chama", &"family_geada", &"family_luz", &"family_vigilia", &"family_duo", &"family_veu", &"family_mare", &"family_marca"]

@export var id: StringName
@export var family: Family = Family.LUZ
## Which glyph the card and the HUD draw (see scripts/ui/boon_icon.gd).
@export var icon := 0
## The highest level (0: no ceiling, as in Hades II). An Elo stays at 1: it never grows (BUG-017).
@export var max_level := 3
@export var slot: Slot = Slot.NONE
## BO-2: a Blessing kept out of the draw (never offered, never deleted: the file stays, an old save and the Compêndio
## still know it, and it can come back). The ones that leave their family when it is cut to six a button.
@export var reserve := false
## A move tag the hero must have for this Blessing to do anything ("finisher", "spin"); the draw skips it for a hero
## whose combo tree has no move with it (the Maga has no finisher nor spin, 2026-11-24). Empty: any hero.
@export var needs_tag: StringName = &""
## An Elo (E3-02, Hades II's OneFromEachSet): offered when one gift of each list is owned (a list per family). The
## first of each list is the one the card shows when none is owned.
@export var requires_sets: Array[PackedStringArray] = []
@export var mods: Array[BoonMod] = []
@export var skill: SkillDef
## Blessings V1 (docs/design/bencaos_v1, 2026-11-26): what holding this Blessing gives other Blessings to ask for (a
## capability word: "burn", "cold", "crit", "impact", "weak", "mark", "echo", "cadence"), and what it asks before it may
## come on a card: every entry is a capability, a Blessing id, or "fam:<family tag>" (one Blessing of that angel). Empty:
## nothing. A principal (a slot) asks only a free slot and its action; a complement (no slot) asks these.
@export var grants: PackedStringArray = PackedStringArray()
@export var needs_all: PackedStringArray = PackedStringArray()


func color() -> Color:
	return FAMILY_COLOR[family]


## The button a slot's Blessings belong to (BO-2: one slot a button, so this is the source of what a Blessing changes).
const SLOT_BUTTON: Array[StringName] = [&"", &"light_attack", &"heavy_attack", &"shout", &"dodge", &"rush", &"ultimate"]
## The button of a move tag, for a Blessing whose slot says nothing (an Elo): light, heavy, cast, dash (the Investida).
const TAG_BUTTON := {&"light": &"light_attack", &"heavy": &"heavy_attack", &"cast": &"shout", &"dash": &"rush"}


## BC-2, BO-2: the action (button) whose moves this Blessing changes: its slot's button; a Blessing with no slot (an Elo)
## takes the button of its first tagged modifier; one with none acts alone (&"").
func button() -> StringName:
	if slot != Slot.NONE:
		return SLOT_BUTTON[slot]
	for m in mods:
		if TAG_BUTTON.has(m.tag):
			return TAG_BUTTON[m.tag]
	return &""


## True when nothing sets the Blessing off: no button, and a skill (if any) that fires on its own.
func acts_alone() -> bool:
	return slot == Slot.NONE and (skill == null or skill.alone())


func family_tag() -> StringName:
	return FAMILY_TAG[family]


## V1: a complement takes no slot, can be held beside any principal and never twice (the angel's four extras).
func is_complement() -> bool:
	return slot == Slot.NONE and not is_duo()


func is_duo() -> bool:
	return family == Family.DUO or not requires_sets.is_empty()


## An Elo has no rarity and no level beyond 1 (BUG-017: Hades II's duos never grow and never scale by rarity).
func has_rarity() -> bool:
	return not is_duo()


## True while a level more is still possible at this level.
func can_grow(level: int) -> bool:
	return max_level <= 0 or level < max_level
