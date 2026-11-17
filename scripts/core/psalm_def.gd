class_name PsalmDef
extends Resource
## A Psalm (E4, docs/design/e4_psalms.md): a rare find that transforms how one action of the hero works (not a
## number more). Hades II's legendary in rule: offered on a card (Psalms.chance) only when one thing of each of its
## three groups is held (a Blessing, an Elo or an equipped Gift), never grows, one per theme and two per run (Psalms).
## Named by its theme only (D-59 (a)): no number, no verse. Data in data/psalms/, written by _psalms in
## tools/make_data.gd; played by PsalmPlay (scripts/game/psalm_play.gd), its pure rules in Psalms.

## What the Psalm does to its action; a new Psalm with one of these needs no code, only data.
## SENTINEL: the circle of light walks with the hero and strikes each enemy as it comes in (damage, once a circle).
## SHELTER: the dodge leaves a shelter where it ends (radius, duration; at most count) that undoes enemy shots.
## FLOCK: each kill gathers a light (up to count); the special throws one more wave for each, fanned spread degrees.
## STONE: the spin plants a stone of light (radius): damage and a stun of stun s on the common ones, then it stays
## duration s slowing whoever is in it; no other stone while one stands.
enum Effect { SENTINEL, SHELTER, FLOCK, STONE }

## A Gift (TalentDef id) in a group is written with this before its id; anything else is a Blessing or an Elo (Boon id).
const GIFT := "dom:"

@export var id: StringName
## The theme (one per run): two Psalms of one theme never both come in a run.
@export var theme: StringName
## Text keys (data/text_pt.tres): name, what it does, the hint the Codex shows before it is found and the short line
## said when it is taken.
@export var name_key: StringName
@export var desc_key: StringName
@export var hint_key: StringName
@export var line_key: StringName
## The action it transforms (what the card says it changes).
@export var slot: Boon.Slot = Boon.Slot.NONE
## The three groups (one held thing from each, never the same thing for two groups): Boon ids, or GIFT + TalentDef id.
@export var requires: Array[PackedStringArray] = []
@export var effect: Effect = Effect.SENTINEL
## The effect's numbers (what each means: Effect).
@export var damage := 0.0
@export var radius := 0.0
@export var duration := 0.0
@export var stun := 0.0
@export var count := 0
@export var spread := 0.0
## Its light: old gold with an emerald vein (never bright yellow nor white).
@export var color := Color(0.78, 0.62, 0.34)


## The numbers its description reads ({damage} {radius} {duration} {stun} {count} {spread}), as the player reads them
## (a whole number plain, else one decimal with a comma).
func text_args() -> Dictionary:
	return {"damage": number(damage), "radius": number(radius), "duration": number(duration), "stun": number(stun),
		"count": count, "spread": number(spread)}


static func number(v: float) -> String:
	return str(roundi(v)) if is_equal_approx(v, roundf(v)) else ("%.1f" % v).replace(".", ",")


## True when an entry of a group names a Gift.
static func is_gift(entry: String) -> bool:
	return entry.begins_with(GIFT)


## The id an entry names (the Gift's without GIFT).
static func entry_id(entry: String) -> StringName:
	return StringName(entry.trim_prefix(GIFT))
