class_name BoonState
extends RefCounted
## The gifts the paladin holds in this run, the numbers they add up to, and the draw of the next three cards.
## The draw follows Hades II (E3): a card is a Blessing not held yet for a free action (or one that acts on its own),
## an Elo now and then once one can be formed (Boon.ELO_CHANCE), or, now and then, a trade for an action already
## taken (Boon.TRADE_CHANCE: the new one comes one rarity higher, at the level of the one it replaces). A Blessing
## already held is never drawn again: it grows by the pomegranate (grow_cards).


## One card of a draw: what the choice screen shows and what taking it does.
class Card:
	var boon: Boon
	## Its rarity (always common for an Elo, which has none: Boon.has_rarity).
	var rarity := Boon.Rarity.COMMON
	## The Blessing it replaces (another on the same action), or null.
	var replaces: Boon
	## A trade (E3-01): it replaces replaces one rarity higher and keeps its level.
	var trade := false
	## The level it has once taken.
	var level := 1
	## A pomegranate's card: one more level for a Blessing held (its rarity kept).
	var grow := false
	## A Psalm's card (E4, Psalms.fill): boon is null, the card offers this Psalm (no rarity, no level).
	var psalm: PsalmDef

	func _init(b: Boon = null, r: Boon.Rarity = Boon.Rarity.COMMON, lv: int = 1) -> void:
		boon = b
		rarity = r
		level = lv

var catalog: Array[Boon] = []
var levels: Dictionary = {}
## Rarity of each owned gift (Boon.Rarity); a gift keeps the best rarity it was taken at.
var rarities: Dictionary = {}
## The hero's Gifts equipped for this descent (TalentDef): their mods add up with the Blessings' in stat (at level 1,
## never scaled by rarity), so every blow reads Gift and Blessing in the same sum.
var talents: Array[TalentDef] = []
## Numbers won outside the Blessings (E5: a Provação's blessing, Trials.blessing_mods), fixed, added to stat.
var granted: Array[BoonMod] = []
var _cache: Dictionary = {}


func _init(boons: Array[Boon] = []) -> void:
	catalog = boons


static func load_catalog(dir: String = "res://data/boons/") -> Array[Boon]:
	var out: Array[Boon] = []
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	return out


func level(id: StringName) -> int:
	return levels.get(id, 0)


func rarity(id: StringName) -> Boon.Rarity:
	return rarities.get(id, Boon.Rarity.COMMON)


func rarity_mult(id: StringName) -> float:
	return Boon.RARITY_MULT[rarity(id)]


## The owned gift riding on an action (null when the action is free or for Slot.NONE).
func in_slot(slot: Boon.Slot) -> Boon:
	if slot == Boon.Slot.NONE:
		return null
	for b in owned():
		if b.slot == slot:
			return b
	return null


## The owned gift that taking b would throw away (another gift on the same action), or null.
func replaced_by(b: Boon) -> Boon:
	var current := in_slot(b.slot)
	return current if current != null and current != b else null


## Draws the rarity of a card in sequence (C13-03, Hades II): it starts common and tries each rarity in turn with its
## chance (chances: rare, epic, legendary); the last that passes is the card's.
static func roll_rarity(rng: RandomNumberGenerator, chances: Array[float] = Boon.RARITY_CHANCE) -> Boon.Rarity:
	var r := Boon.Rarity.COMMON
	for i in mini(chances.size(), Boon.Rarity.LEGENDARY):
		if rng.randf() < chances[i]:
			r = (i + 1) as Boon.Rarity
	return r


## What a sequence of chances gives, rarity by rarity (common first): the share of cards of each in the long run.
static func rarity_odds(chances: Array[float]) -> PackedFloat32Array:
	var out := PackedFloat32Array([1.0, 0.0, 0.0, 0.0])
	for i in mini(chances.size(), Boon.Rarity.LEGENDARY):
		var c := clampf(chances[i], 0.0, 1.0)
		for j in i + 1:
			out[i + 1] += out[j] * c
			out[j] *= 1.0 - c
	return out


func find(id: StringName) -> Boon:
	for b in catalog:
		if b.id == id:
			return b
	return null


## The two gifts an Elo is forged from, one of each of its lists (Boon.requires_sets) in order: the one held, or the
## first of the list when none is. Empty for any other gift; a list with nothing in the catalog is skipped.
func sources(b: Boon) -> Array[Boon]:
	var out: Array[Boon] = []
	if b == null:
		return out
	for list in b.requires_sets:
		var pick: Boon = null
		for id in list:
			var s := find(StringName(id))
			if s == null:
				continue
			if pick == null:
				pick = s
			if level(s.id) > 0:
				pick = s
				break
		if pick != null:
			out.append(pick)
	return out


## True when one gift of each of the Elo's lists is held (always true for a gift that is no Elo).
func forged(b: Boon) -> bool:
	for list in b.requires_sets:
		var found := false
		for id in list:
			if level(StringName(id)) > 0:
				found = true
				break
		if not found:
			return false
	return true


## The owned Elos that are not in seen (ids), so a screen can greet each one once.
func new_elos(seen: Dictionary) -> Array[Boon]:
	var out: Array[Boon] = []
	for b in owned():
		if b.is_duo() and not seen.has(b.id):
			out.append(b)
	return out


func owned() -> Array[Boon]:
	var out: Array[Boon] = []
	for b in catalog:
		if level(b.id) > 0:
			out.append(b)
	return out


func can_offer(b: Boon) -> bool:
	return b.can_grow(level(b.id)) and forged(b)


## Raises a gift by one level (or to at_level when it is higher: a trade keeps the replaced one's level), at least at
## the rarity given (an Elo is always common: it has none); a gift on an action replaces the one there.
## Returns the new level (0 when it could not be taken).
func take(b: Boon, at: Boon.Rarity = Boon.Rarity.COMMON, at_level: int = 0) -> int:
	if not can_offer(b):
		return 0
	var old := replaced_by(b)
	if old != null:
		levels.erase(old.id)
		rarities.erase(old.id)
	var lv := maxi(level(b.id) + 1, at_level)
	if b.max_level > 0:
		lv = mini(lv, b.max_level)
	levels[b.id] = lv
	rarities[b.id] = maxi(rarity(b.id), at) if b.has_rarity() else Boon.Rarity.COMMON
	_cache.clear()
	return levels[b.id]


## Takes a card of a draw (its rarity, its level).
func take_card(c: Card) -> int:
	return take(c.boon, c.rarity, c.level)


## Equips the hero's Gifts for the descent (Talents.check decides which are valid).
func equip_talents(defs: Array[TalentDef]) -> void:
	talents = defs
	_cache.clear()


## Adds numbers won outside the Blessings (E5, the Provação): they count in stat from now on.
func grant(mods: Array[BoonMod]) -> void:
	granted.append_array(mods)
	_cache.clear()


## Sum of a stat over every owned gift and equipped Gift. With tags, only modifiers that are untagged or match one of
## them count.
func stat(stat_name: StringName, tags: Array[StringName] = []) -> float:
	var use_cache := tags.is_empty()
	if use_cache and _cache.has(stat_name):
		return _cache[stat_name]
	var total := 0.0
	for m in granted:
		if m.stat == stat_name and (m.tag == &"" or tags.has(m.tag)):
			total += m.value(1)
	for t in talents:
		for m in t.mods:
			if m.stat == stat_name and (m.tag == &"" or tags.has(m.tag)):
				total += m.value(1)
	for b in catalog:
		var lv := level(b.id)
		if lv <= 0:
			continue
		for m in b.mods:
			if m.stat == stat_name and (m.tag == &"" or tags.has(m.tag)):
				total += m.at(lv, rarity_mult(b.id))
	if use_cache:
		_cache[stat_name] = total
	return total


## Up to n different gifts to choose from (the gifts of draw, common rarity rules).
func offers(rng: RandomNumberGenerator, n: int = 3) -> Array[Boon]:
	var out: Array[Boon] = []
	for c in draw(rng, n):
		out.append(c.boon)
	return out


## Up to n cards, each a different gift (see the class's comment). chances: the rarity draw (roll_rarity); elo_chance
## and trade_chance per card. When no fresh gift is left, a card falls back to a plain replacement (no rarity up), then
## to an Elo that can be formed.
func draw(rng: RandomNumberGenerator, n: int = 3, chances: Array[float] = Boon.RARITY_CHANCE,
		elo_chance: float = Boon.ELO_CHANCE, trade_chance: float = Boon.TRADE_CHANCE) -> Array[Card]:
	var fresh: Array[Boon] = []
	var trades: Array[Boon] = []
	var elos: Array[Boon] = []
	for b in catalog:
		if level(b.id) > 0 or not can_offer(b):
			continue
		if b.is_duo():
			elos.append(b)
		elif replaced_by(b) != null:
			trades.append(b)
		else:
			fresh.append(b)
	var out: Array[Card] = []
	while out.size() < n:
		var c: Card = null
		if not elos.is_empty() and rng.randf() < elo_chance:
			c = Card.new(elos.pop_at(rng.randi() % elos.size()))
		elif not trades.is_empty() and rng.randf() < trade_chance:
			c = trade_card(trades.pop_at(rng.randi() % trades.size()), rng, chances)
		elif not fresh.is_empty():
			c = Card.new(fresh.pop_at(rng.randi() % fresh.size()), roll_rarity(rng, chances))
		elif not trades.is_empty():
			var b: Boon = trades.pop_at(rng.randi() % trades.size())
			c = Card.new(b, roll_rarity(rng, chances))
			c.replaces = replaced_by(b)
		elif not elos.is_empty():
			c = Card.new(elos.pop_at(rng.randi() % elos.size()))
		else:
			break
		out.append(c)
	return out


## A trade for b (E3-01): it replaces the Blessing on its action one rarity higher than that one (never past
## legendary; the card's own draw if that is higher) and keeps its level.
func trade_card(b: Boon, rng: RandomNumberGenerator, chances: Array[float] = Boon.RARITY_CHANCE) -> Card:
	var old := replaced_by(b)
	var c := Card.new(b, roll_rarity(rng, chances))
	if old == null:
		return c
	c.replaces = old
	c.trade = true
	c.rarity = maxi(c.rarity, mini(rarity(old.id) + 1, Boon.Rarity.LEGENDARY)) as Boon.Rarity
	c.level = maxi(1, level(old.id))
	return c


## True when some owned gift can still grow (a door may then promise one more level).
func can_grow() -> bool:
	for b in owned():
		if can_offer(b):
			return true
	return false


## Up to n owned gifts that can still grow, to choose which one gets the extra level.
func grow_offers(rng: RandomNumberGenerator, n: int = 3) -> Array[Boon]:
	var pool: Array[Boon] = []
	for b in owned():
		if can_offer(b):
			pool.append(b)
	var out: Array[Boon] = []
	while out.size() < n and not pool.is_empty():
		out.append(pool.pop_at(rng.randi() % pool.size()))
	return out


## Common cards for these gifts, each at one level more (laboratories and tests that pick what is offered).
func cards_for(gifts: Array) -> Array[Card]:
	var out: Array[Card] = []
	for b: Boon in gifts:
		var c := Card.new(b, rarity(b.id), level(b.id) + 1)
		c.replaces = replaced_by(b)
		out.append(c)
	return out


## grow_offers as cards: each at one level more, its rarity kept.
func grow_cards(rng: RandomNumberGenerator, n: int = 3) -> Array[Card]:
	var out: Array[Card] = []
	for b in grow_offers(rng, n):
		var c := Card.new(b, rarity(b.id), level(b.id) + 1)
		c.grow = true
		out.append(c)
	return out
