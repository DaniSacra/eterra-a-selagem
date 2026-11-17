class_name TrialDef
extends Resource
## One half of a card of the Provação (E5; Hades II's Chaos, docs/design/hades2_sistemas.md section 7): a CURSE carried
## for a few fights (encounters), or the BLESSING it turns into for the rest of the run. Numbers only (mods: the same
## BoonMod words the game reads; a curse's own words are read by Rooms: enemy_speed_pct, heal_pct, hurt_pct,
## wave_extra, gold_pct). data/trials/*.tres, written by _trials in tools/make_data.gd.

enum Kind { CURSE, BLESSING }

@export var id: StringName
@export var kind := Kind.BLESSING
## Its name in the text (data/text_pt.tres), and a line saying what it does ({value} is its first number).
@export var name_key: StringName
@export var desc_key: StringName
@export var mods: Array[BoonMod] = []
## A curse lasts this many fights, drawn (Hades II: 3 to 5 encounters).
@export var encounters := Vector2i(3, 5)
## How often it is drawn against the others of its kind.
@export var weight := 1.0


## The number of its first modifier at this rarity (a blessing's grows with it; a curse's never does).
func value(rarity: int = 0) -> float:
	if mods.is_empty():
		return 0.0
	return mods[0].at(1, Boon.RARITY_MULT[clampi(rarity, 0, Boon.RARITY_MULT.size() - 1)])


## The sum of one of its words (the curse's, as Rooms reads them).
func stat(word: StringName) -> float:
	var total := 0.0
	for m in mods:
		if m.stat == word:
			total += m.value(1)
	return total
