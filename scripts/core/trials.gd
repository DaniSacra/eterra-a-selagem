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


## True when he may pay: more life than the cost (Hades II: whoever has the cost or less cannot enter).
static func can_pay(stage: StageDef, depth: int, hp: float) -> bool:
	return hp > cost(stage, depth)


## True when the slab may appear in a room of this depth just won (before the dice): within the stage's depths, none
## carried now, and the last one at least trial_cooldown rooms ago.
func may_show(stage: StageDef, depth: int) -> bool:
	return depth >= stage.trial_depth_min and depth <= stage.trial_depth_max and active == null \
		and depth - last_shown >= stage.trial_cooldown and not catalog.is_empty()


## Rolls the slab for a room of this depth just won; true when it shows (and the cooldown starts).
func roll(stage: StageDef, depth: int, rng: RandomNumberGenerator) -> bool:
	if not may_show(stage, depth) or rng.randf() >= stage.trial_chance:
		return false
	last_shown = depth
	return true


## Up to n cards, each with a different blessing and a different curse (fewer when the catalog is short).
func offers(rng: RandomNumberGenerator, n: int, chances: Array[float]) -> Array[Card]:
	var blessings := _of(TrialDef.Kind.BLESSING)
	var curses := _of(TrialDef.Kind.CURSE)
	var out: Array[Card] = []
	for i in mini(n, mini(blessings.size(), curses.size())):
		var c := Card.new()
		c.blessing = _take_weighted(blessings, rng)
		c.curse = _take_weighted(curses, rng)
		c.rarity = BoonState.roll_rarity(rng, chances)
		c.encounters = rng.randi_range(c.curse.encounters.x, c.curse.encounters.y)
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
