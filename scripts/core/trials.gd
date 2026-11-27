class_name Trials
extends RefCounted
## The Provação of a run (E5; Hades II's Chaos, docs/design/hades2_sistemas.md section 7, theme without an owner,
## E5-D6): a cracked slab may appear in a room just won (StageDef.trial_chance, within its depths, never again for
## trial_cooldown rooms); stepping on it costs ceil(trial_cost_base + trial_cost_per_depth x depth) life (only with more
## life than that) and leads to the trial's chamber, where a card is taken: a blessing (BLESSING TrialDef, its rarity
## drawn as Hades II's Chaos: rare 40%, epic 10%) and a curse (CURSE TrialDef) carried for 3 to 5 fights, which then
## turns into the blessing for the rest of the run. Blessings taken twice add up. Pure: Rooms runs it, the UI reads
## the cards (Card.view) and active / left for the seal.

const DIR := "res://data/trials/"

## One card of the trial: what is won, at what rarity, and what is carried until then, for how many fights.
class Card:
	var blessing: TrialDef
	var rarity := 0
	var curse: TrialDef
	var encounters := 3

	## What a screen (the split card, docs/art/e5_spec.md 5.3) or the log needs, in plain values: blessing and curse
	## ids, their text keys, their numbers (the blessing's at its rarity), the rarity and the fights.
	func view() -> Dictionary:
		return {"blessing": String(blessing.id), "blessing_name": String(blessing.name_key),
			"blessing_desc": String(blessing.desc_key), "blessing_value": blessing.value(rarity), "rarity": rarity,
			"curse": String(curse.id), "curse_name": String(curse.name_key), "curse_desc": String(curse.desc_key),
			"curse_value": curse.value(0), "encounters": encounters}


var catalog: Array[TrialDef] = []
## The curse carried now (null: none) and the fights it still lasts.
var active: Card = null
var left := 0
## The blessings won so far (in the order they turned).
var won: Array[Card] = []
## Depth of the last room that showed the slab (cooldown).
var last_shown := -1000


func _init(defs: Array[TrialDef] = []) -> void:
	catalog = defs


## A hero that spends no Magia never draws a card that only adds to it (Magia Ampla): it leaves the catalog.
func drop_magick() -> void:
	var keep: Array[TrialDef] = []
	for d in catalog:
		if d.stat(&"magick_max") <= 0.0:
			keep.append(d)
	catalog = keep


static func load_catalog(dir: String = DIR) -> Array[TrialDef]:
	var out: Array[TrialDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	return out


## Life the slab asks at this depth (Hades II's GetSecretDoorCost).
static func cost(stage: StageDef, depth: int) -> int:
	return ceili(stage.trial_cost_base + stage.trial_cost_per_depth * depth)


## BL-03: true when he has the share of life the slab asks to be offered at all (trial_min_hp_frac of his maximum).
static func healthy(stage: StageDef, hp: float, max_hp: float) -> bool:
	return hp >= max_hp * stage.trial_min_hp_frac


## True when he may pay: more life than the cost (Hades II: whoever has the cost or less cannot enter).
static func can_pay(stage: StageDef, depth: int, hp: float) -> bool:
	return hp > cost(stage, depth)


## True when the slab may appear in a room of this depth just won (before the dice): within the stage's depths, none
## carried now, the last one at least trial_cooldown rooms ago, and (C17, BUG-101) the shortest curse still fits in
## the fights sure to come before the boss (RunMap.fights_left): a curse that cannot turn is never offered.
func may_show(stage: StageDef, depth: int, fights_left: int = ANY_FIGHTS) -> bool:
	return depth >= stage.trial_depth_min and depth <= stage.trial_depth_max and active == null \
		and depth - last_shown >= stage.trial_cooldown and not catalog.is_empty() \
		and fights_left >= shortest_curse()


## No limit from the fights left (the old callers and the tests of the slab's dice).
const ANY_FIGHTS := 1 << 20


## The fewest fights any curse of the catalog may last (its encounters.x; 0 with no curse).
func shortest_curse() -> int:
	var low := 1 << 20
	for d in _of(TrialDef.Kind.CURSE):
		low = mini(low, d.encounters.x)
	return low if low < (1 << 20) else 0


## Rolls the slab for a room of this depth just won; true when it shows (and the cooldown starts).
func roll(stage: StageDef, depth: int, rng: RandomNumberGenerator, fights_left: int = ANY_FIGHTS) -> bool:
	if not may_show(stage, depth, fights_left) or rng.randf() >= stage.trial_chance:
		return false
	last_shown = depth
	return true


## DV-1: the slab of a room the descent's graph marked with "?" (RunMap.Room.trial; the dice were thrown there):
## true when it shows now (may_show), and the cooldown starts.
func open_at(stage: StageDef, depth: int, fights_left: int = ANY_FIGHTS) -> bool:
	if not may_show(stage, depth, fights_left):
		return false
	last_shown = depth
	return true


## Up to n cards, each with a different blessing and a different curse (fewer when the catalog is short); no curse
## lasts more than the fights left before the boss (C17, BUG-101: the card's promise always comes true).
func offers(rng: RandomNumberGenerator, n: int, chances: Array[float], fights_left: int = ANY_FIGHTS) -> Array[Card]:
	var blessings := _of(TrialDef.Kind.BLESSING)
	var curses := _of(TrialDef.Kind.CURSE)
	var out: Array[Card] = []
	for i in mini(n, mini(blessings.size(), curses.size())):
		var c := Card.new()
		c.blessing = _take_weighted(blessings, rng)
		c.curse = _take_weighted(curses, rng)
		c.rarity = BoonState.roll_rarity(rng, chances)
		c.encounters = mini(rng.randi_range(c.curse.encounters.x, c.curse.encounters.y), maxi(1, fights_left))
		out.append(c)
	return out


## The card taken: its curse is carried from the next fight on.
func take(card: Card) -> void:
	active = card
	left = card.encounters


## A fight was won: one less to carry. Returns the card whose curse turned into its blessing now (null: none).
func fight_won() -> Card:
	if active == null:
		return null
	left -= 1
	if left > 0:
		return null
	var done := active
	won.append(done)
	active = null
	left = 0
	return done


## The sum of a curse's word carried now (0 without one).
func curse(word: StringName) -> float:
	return active.curse.stat(word) if active != null else 0.0


## The blessing of a card as plain modifiers at its rarity (BoonState.grant): the number fixed, no level gains.
static func blessing_mods(card: Card) -> Array[BoonMod]:
	var out: Array[BoonMod] = []
	var mult: float = Boon.RARITY_MULT[clampi(card.rarity, 0, Boon.RARITY_MULT.size() - 1)]
	for m in card.blessing.mods:
		var fixed := BoonMod.new()
		fixed.stat = m.stat
		fixed.tag = m.tag
		fixed.base = m.at(1, mult)
		fixed.by_rarity = false
		out.append(fixed)
	return out


## The robot's rule (E5): it pays when what is left is still at least BOT_KEEP of its most life.
const BOT_KEEP := 0.6


static func bot_accepts(stage: StageDef, depth: int, hp: float, max_hp: float) -> bool:
	return can_pay(stage, depth, hp) and hp - cost(stage, depth) >= max_hp * BOT_KEEP


## What each curse costs the robot's plan (E6, item 6: it took the first card, Pobreza included, and reached the shop
## with no gold): a fight that hurts more costs most, no gold costs most only while the shop is still ahead.
const BOT_CURSE_COST := {&"trial_fragil": 3.0, &"trial_horda": 2.0, &"trial_pressa": 2.0, &"trial_ferida": 1.0,
	&"trial_pobreza": 5.0}
## What a rarity step of the blessing is worth against that.
const BOT_RARITY_WORTH := 1.0


## The card the robot takes (E6): the best blessing rarity for the least harm to its plan (shop_ahead: the shop is
## still to come, so Pobreza hurts). Ties go to the first card.
static func bot_card(cards: Array[Card], shop_ahead: bool) -> int:
	var best := 0
	var best_score := -INF
	for i in cards.size():
		var c := cards[i]
		var harm: float = BOT_CURSE_COST.get(c.curse.id, 2.0)
		if c.curse.id == &"trial_pobreza" and not shop_ahead:
			harm = 0.0
		var score := c.rarity * BOT_RARITY_WORTH - harm
		if score > best_score:
			best_score = score
			best = i
	return best


func _of(kind: TrialDef.Kind) -> Array[TrialDef]:
	var out: Array[TrialDef] = []
	for d in catalog:
		if d.kind == kind:
			out.append(d)
	return out


static func _take_weighted(list: Array[TrialDef], rng: RandomNumberGenerator) -> TrialDef:
	var w := PackedFloat32Array()
	for d in list:
		w.append(maxf(d.weight, 0.001))
	var i := rng.rand_weighted(w)
	var d := list[i]
	list.remove_at(i)
	return d
