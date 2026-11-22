class_name RunMap
extends RefCounted
## The way down through one region (DV-1, the Descida de Valmor, MAP-01): a graph of rooms in layers drawn from the
## run's seed when the descent begins, on dice of its own. Layer 1 is the catacomb hall (the opening fight, always a
## Blessing); layers 2 to StageDef.rooms - 1 hold DOORS rooms each; one whole layer is the first guardian's (the Knight
## and the Elder side by side) and a later one, of a single room, the second guardian's: the one he did not choose
## (Daniel, 2026-11-22: both, and only then Morvath); layer StageDef.rooms is the shop and the next one Morvath. Every
## way through has the same length. DM-1 (Daniel, 2026-11-22): always two doors a room, each room leading to both of the
## next layer; only the second guardian, the shop and Morvath stand behind one. Nobody sees this graph (the map's screen
## is gone): the doors' signs are all there is. Fountain (one always the layer before each guardian's, GP-2), altar and the Provação's "?" are rooms of the
## graph; the rewards are drawn off the deck here, so what a door's sign promises is what the room gives.
## The rules of the arenas hold on every way (never the same arena twice in a row, none more than arena_max_uses
## times, the guardian at home): the graph is drawn, checked and drawn again when it breaks one (failures counts).
## Pure logic.
##
## API (what the rooms, the signs and the HUD read):
##   nodes: Array[Room], index = Room.id. Room: id, depth (its layer, 1 = the hall, last_depth() = Morvath), slot (its
##     place in the layer, left to right), kind (Kind), reward (Reward), guardian (the enemy id of a guardian's room,
##     &"" otherwise), hidden (shows "?" now: the Provação's slab is there and has not appeared), trial (the slab is
##     there, shown or not), arena (RoomLayout.id; &"altar" for the altar, &"seal_chamber" for Morvath), next (ids of
##     the rooms it links to, by slot; its doors, door i = next[i]).
##   layer(depth) -> Array[Room]; last_depth() -> int; at(id) -> Room.
##   path: Array[int] (ids walked, the hall first); here: Room (the room he stands in; null before the first);
##   doors() -> Array[Room] (the rooms behind the doors of here, door i = doors()[i]).
##   walked(room) -> bool; reaches(room, kind) -> bool (a room of that kind is still ahead of it).
##   view() -> Dictionary (all of it in plain values: seed, layers of {id, depth, slot, kind, reward, guardian, hidden,
##     arena, next}, path, here, doors).
##   signal changed: emitted when he enters a room, when a "?" is revealed and when a door's reward changes.

signal changed

## E5: TRIAL is the Provação's chamber (no door leads there: its slab, Rooms; the depth stays, it is no room of the
## graph), ALTAR the Altar Esquecido (a room of the graph, no fight).
enum Kind { COMBAT, MINIBOSS, FOUNTAIN, SHOP, BOSS, TRIAL, ALTAR }
## What a room gives when it is cleared (or what the shop sells).
## BOON: a gift (three to choose). POM: one more level for a gift already owned. HEART: more life.
## MAGICK: more Magia. GOLD: gold for the shop. HEAL: life back (shop only). POM_SLICE: one level more for a gift
## drawn among those held, no choice (shop only; Hades II's pom slice). Rejogabilidade, Fatia 1 (sistemas.md 3.1):
## SILVER, Prata Antiga for the Forja, and MEMORY, Fragmentos de Memória to open the Gifts; both go home (MaterialPurse),
## the doors that trade power now for power in the next descents.
## Fatia 2 (sistemas.md 1.7): ENCHANT, a door (or the shop's item) of an Encanto, one of three learned at the Forja
## (Enchants), at most StageDef.enchant_max on a way; PSALM, a door whose Blessings hold a Psalm card. The deck's Psalm
## card lies on the map as a Blessing that may become one (Room.psalm): settle shows it as a Psalm's door only when a
## Psalm can come then, so the map never promises one that does not come (it promised and turned it before).
enum Reward { NONE, BOON, POM, HEART, MAGICK, GOLD, HEAL, POM_SLICE, SILVER, MEMORY, ENCHANT, PSALM }
## RJ-2, the groups of the rewards: power for this descent (a Blessing, a pomegranate, an Encanto, a Psalm), the body
## and the purse (life, Magia, gold, healing) and home (the materials). Two doors of a room show two groups when the
## deck has them (_draw_rewards): the choice is between kinds of things, not between two of a kind.
enum Group { NONE, POWER, BODY, HOME }

const REWARD_KEY: Array[StringName] = [&"", &"reward_boon", &"reward_pom", &"reward_heart", &"reward_magick", &"reward_gold", &"reward_heal", &"reward_pom_slice", &"reward_silver", &"reward_memory", &"reward_enchant", &"reward_psalm"]
## The rewards that are materials brought home (Rooms gives them to the run's MaterialPurse).
const MATERIAL_REWARDS: Array[Reward] = [Reward.SILVER, Reward.MEMORY]
const GROUP_OF := {Reward.BOON: Group.POWER, Reward.POM: Group.POWER, Reward.ENCHANT: Group.POWER,
	Reward.PSALM: Group.POWER, Reward.POM_SLICE: Group.POWER, Reward.HEART: Group.BODY, Reward.MAGICK: Group.BODY,
	Reward.GOLD: Group.BODY, Reward.HEAL: Group.BODY, Reward.SILVER: Group.HOME, Reward.MEMORY: Group.HOME}
const KIND_KEY: Array[StringName] = [&"room_combat", &"room_miniboss", &"room_fountain", &"room_shop", &"room_boss", &"room_trial", &"room_altar"]

## The doors of every room (DM-1; every arena has 3, the hall too: CatacombHall._doors), but the one before the shop's
## and the shop's own.
const DOORS := 2
## A high-difficulty arena (RoomLayout.difficulty 2) is never drawn before this share of the descent.
const HARD_FROM := 0.4
## Tries to draw a graph that keeps every rule before the last one is kept as it is (never seen in 1000 seeds).
const MAX_TRIES := 60
## The angels' deck is drawn on dice of their own (the map's seed salted with this).
const ANGEL_SALT := 3307


class Room:
	var kind := Kind.COMBAT
	var reward := Reward.NONE
	var depth := 1
	## Index of its arena in StageDef.layouts (the boss and the shop have their own), and how it is dressed
	## (RoomLayout.variant).
	var layout := 0
	var variant := 0
	## E5, the doors that show the way: its fight drawn before its door opens (Rooms.prepare; null: none, or not yet).
	var fight: EncounterGen.Fight
	## DV-1, its place in the graph: id (index in RunMap.nodes; -1: no room of the graph, the Provação's chamber or a
	## test's), slot in its layer, the rooms it links to (ids), its arena's id, the guardian who waits there, the
	## Provação's slab ("?" while hidden) and the seed of its own fight (the same fight whatever the way to it).
	var id := -1
	var slot := 0
	var next: Array[int] = []
	var arena: StringName = &""
	var guardian: StringName = &""
	var trial := false
	var hidden := false
	var fight_seed := 0
	## Fatia 2 (sistemas.md 1.6): a Blessing's room where two angels meet him (the rarer card, StageDef.angel_deck),
	## and, for the others, the one angel its door shows (drawn by Rooms when the door opens, among those with a card
	## for the hand: Rooms.door_angel; &"" until then, and for a meeting).
	var meeting := false
	var angel: StringName = &""
	## The deck's Psalm card fell here: a Blessing's room, never a meeting, that settle shows as a Psalm's door when
	## one can come as its door opens.
	var psalm := false
	## Ofícios (Roteiro A, RunMap.mark_finds): the find waiting in this room once won (&"": none) and whether a vein of
	## Pedra Funda stands in it.
	var find: StringName = &""
	var vein := false

	## What the door's sign may tell (E5-D8; docs/art/e5_spec.md 7.1): kind and reward (their enums), hard (a fight
	## with an elite), guardian, tier (StageDef.Tier of its fight, -1: no fight), elites (ids), depth; since DV-1 the
	## node (id), hidden ("?") and guardian_id (who waits there).
	func sign() -> Dictionary:
		var elites: Array[String] = []
		var tier := -1
		if fight != null:
			tier = fight.tier
			for e in fight.kinds:
				if String(e).ends_with("_elite"):
					elites.append(String(e))
		return {"kind": kind, "reward": reward, "depth": depth, "tier": tier, "guardian": kind == Kind.MINIBOSS,
			"hard": kind == Kind.COMBAT and not elites.is_empty(), "elites": elites, "node": id, "hidden": hidden,
			"guardian_id": String(guardian), "meeting": meeting and reward == Reward.BOON, "angel": String(angel)}

	## The room in plain values (RunMap.view).
	func view() -> Dictionary:
		return {"id": id, "depth": depth, "slot": slot, "kind": kind, "reward": reward, "guardian": String(guardian),
			"hidden": hidden, "arena": String(arena), "next": next.duplicate(), "meeting": meeting and reward == Reward.BOON,
			"angel": String(angel), "find": String(find), "vein": vein}

	func _init(k: Kind, r: Reward, d: int, l: int = 0, v: int = 0) -> void:
		kind = k
		reward = r
		depth = d
		layout = l
		variant = v


var stage: StageDef
## The seed the graph was drawn from (RESULT map.seed).
var map_seed := 0
var nodes: Array[Room] = []
## The ids of each layer (index = depth; 0 is empty).
var layers: Array[PackedInt32Array] = []
## The ids walked so far (the hall first), and the room he stands in (null before the first).
var path: Array[int] = []
var here: Room
## The depth he stands at (the Provação's chamber keeps the depth of its slab's room).
var depth := 0
## The first guardian's layer and the second's (0: there is no second, the shorter descents).
var miniboss_depth := 0
var miniboss2_depth := 0
## Graphs drawn and thrown away because one broke a rule (the tests count them).
var failures := 0
## Pomegranates turned into Blessings because nothing could grow when their door opened (expected never; measured).
var pom_turned := 0
## The doors' rewards come off this deck (C13-02).
var deck: RewardDeck
## Dev (--arena): the opening room is this arena (-1: drawn as any).
var forced_layout := -1
## The fewest fights a curse of the Provação lasts (Trials.shortest_curse): the "?" only goes where they fit.
var min_curse := 3
var _rng := RandomNumberGenerator.new()
## While drawing: the parents of each id, the most times each arena was fought along any way up to it (arena index:
## count), the arenas of the fight right before it (the altar passes them on), and the fewest fights after it.
var _parents: Array[PackedInt32Array] = []
var _uses: Array[Dictionary] = []
var _before: Array[PackedInt32Array] = []
var _fights_min := PackedInt32Array()
## Fatia 2: the most Encantos on a way up to each room (index = id), and the angels' deck with its own dice.
var _enchants := PackedInt32Array()
var _angel_deck: RewardDeck
var _angel_rng := RandomNumberGenerator.new()


func _init(stage_def: StageDef, seed_value: int, forced := -1, shortest_curse := 3) -> void:
	stage = stage_def
	map_seed = seed_value
	forced_layout = forced
	min_curse = shortest_curse
	_rng.seed = seed_value
	for attempt in MAX_TRIES:
		if _build():
			return
		failures += 1
	push_warning("RunMap: no graph kept every rule in %d tries (seed %d)" % [MAX_TRIES, seed_value])


# ---------- reading ----------

func at(id: int) -> Room:
	return nodes[id] if id >= 0 and id < nodes.size() else null


func layer(d: int) -> Array[Room]:
	var out: Array[Room] = []
	if d > 0 and d < layers.size():
		for id in layers[d]:
			out.append(nodes[id])
	return out


## Morvath's depth (StageDef.rooms + 1).
func last_depth() -> int:
	return layers.size() - 1


## The opening room: the hall's fight, always a Blessing.
func first() -> Room:
	return nodes[layers[1][0]]


## The rooms behind the doors of the room he stands in (door i = doors()[i]).
func doors() -> Array[Room]:
	return doors_of(here)


func doors_of(r: Room) -> Array[Room]:
	var out: Array[Room] = []
	if r != null:
		for id in r.next:
			out.append(nodes[id])
	return out


func walked(r: Room) -> bool:
	return r != null and path.has(r.id)


## True when a room of this kind lies somewhere after r (not r itself).
func reaches(r: Room, kind: Kind) -> bool:
	var seen := {}
	var todo: Array[int] = r.next.duplicate()
	while not todo.is_empty():
		var id: int = todo.pop_back()
		if seen.has(id):
			continue
		seen[id] = true
		if nodes[id].kind == kind:
			return true
		todo.append_array(nodes[id].next)
	return false


## The whole graph in plain values, for a screen.
func view() -> Dictionary:
	var out_layers: Array = []
	for d in range(1, layers.size()):
		out_layers.append(layer(d).map(func(r: Room) -> Dictionary: return r.view()))
	return {"seed": map_seed, "layers": out_layers, "path": path.duplicate(), "here": here.id if here != null else -1,
		"doors": here.next.duplicate() if here != null else []}


## The graph for the RESULT and the run's log: seed, nodes ([depth, kind, reward, arena] by id; kind and reward as
## words), edges ([from, to]), the way walked and how many tries the drawing took.
func summary() -> Dictionary:
	var ns: Array = []
	var edges: Array = []
	for r in nodes:
		var w := [r.depth, (Kind.keys()[r.kind] as String).to_lower(), (Reward.keys()[r.reward] as String).to_lower(), String(r.arena)]
		if r.guardian != &"":
			w.append(String(r.guardian))
		if r.trial:
			w.append("trial")
		if r.find != &"":
			w.append("find")
		ns.append(w)
		for n in r.next:
			edges.append([r.id, n])
	return {"seed": map_seed, "nodes": ns, "edges": edges, "path": path.duplicate(), "failures": failures,
		"pom_turned": pom_turned}


# ---------- walking ----------

## The paladin goes through a door into this room. A room of no graph (a test's, a dev's) stands in for the first
## room of its depth and takes its doors; the Provação's chamber keeps the room of its slab as where he stands.
func enter(room: Room) -> void:
	depth = room.depth
	if room.kind == Kind.TRIAL:
		changed.emit()
		return
	if room.id < 0 and room.depth > 0 and room.depth < layers.size():
		room.next = nodes[layers[room.depth][0]].next.duplicate()
	here = room
	if room.id >= 0:
		path.append(room.id)
	if room.kind == Kind.MINIBOSS and room.depth == miniboss_depth and miniboss2_depth > 0:
		_leave_other(room.guardian)
	changed.emit()


## The first guardian was chosen: the second one's room holds the other.
func _leave_other(met: StringName) -> void:
	for r in layer(miniboss2_depth):
		for id in stage.minibosses:
			if id != met:
				r.guardian = id
				break


## True for the layer of a guardian, the first or the second.
func guardian_at(d: int) -> bool:
	return d > 0 and (d == miniboss_depth or d == miniboss2_depth)


## The fights still sure to come before the boss after room r (C17, BUG-101; DV-1: on the worst way): the fewest
## fights (common and guardian) on any way from r to the shop. A Provação carried from here never lasts more.
func fights_left(r: Room = null) -> int:
	var from := r if r != null else here
	if from == null:
		return 0
	var low := 1 << 20
	for id in from.next:
		low = mini(low, (1 if _is_fight(nodes[id]) else 0) + _fights_min[id])
	return 0 if low == 1 << 20 else low


## The Provação's chamber, entered from a room of this depth by its slab: the depth stays (E5).
func trial(at_depth: int) -> Room:
	return Room.new(Kind.TRIAL, Reward.NONE, at_depth, -1)


## The doors about to open: a pomegranate behind one when nothing can grow (can_pom false), a Psalm's door when no Psalm
## can come (can_psalm false) and an Encanto's when none is left to offer (can_enchant false) turn into a Blessing
## (one angel shown, Rooms) before its sign shows (Q-25 a; Fatia 2); the Blessing where the deck's Psalm card fell
## (Room.psalm) shows as a Psalm's door when one can come. Returns how many changed.
func settle(doors_: Array[Room], can_pom: bool, can_psalm := false, can_enchant := true) -> int:
	var n := 0
	for r in doors_:
		var turn := (r.reward == Reward.POM and not can_pom) or (r.reward == Reward.PSALM and not can_psalm) \
				or (r.reward == Reward.ENCHANT and not can_enchant)
		if r.psalm and r.reward == Reward.BOON and can_psalm:
			# the Blessing where the deck's Psalm card fell shows as a Psalm's door: one can come now
			r.reward = Reward.PSALM
			n += 1
			continue
		if turn:
			if r.reward == Reward.POM:
				pom_turned += 1
			r.reward = Reward.BOON
			n += 1
	if n > 0:
		changed.emit()
	return n


## Ofícios, Roteiro A: the veins (every fight room past the guardian's layer held in one of vein_arenas) and, when
## `head` is not &"", the room the find waits in (a fight room, no Provação's, between depth_min and depth_max), on dice
## of their own (the map's seed and FIND_SALT) after the graph is drawn: the map and the run stay as they were.
## Returns whether the find's room was marked.
const FIND_SALT := 5303


func mark_finds(head: StringName, depth_min: int, depth_max: int, vein_arenas: Array[StringName]) -> bool:
	for r in nodes:
		r.vein = r.kind == Kind.COMBAT and r.depth > miniboss_depth and vein_arenas.has(r.arena)
	if head == &"":
		return false
	var can := nodes.filter(func(r: Room) -> bool:
		return r.kind == Kind.COMBAT and not r.trial and r.depth >= depth_min and r.depth <= depth_max)
	if can.is_empty():
		return false
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([map_seed, FIND_SALT])
	(can[rng.randi() % can.size()] as Room).find = head
	return true


## The Provação's slab appeared in r: its "?" turns into the room it is.
func reveal(r: Room) -> void:
	if r != null and r.hidden:
		r.hidden = false
		changed.emit()


## DV-2 (MAP-09): a shop before the last one (the route shop, fewer items).
func is_route_shop(r: Room) -> bool:
	return r != null and r.kind == Kind.SHOP and r.depth < stage.rooms


## The group of a reward (RJ-2).
static func group_of(r: int) -> Group:
	return GROUP_OF.get(r, Group.NONE)


# ---------- drawing ----------

static func _is_fight(r: Room) -> bool:
	return r.kind == Kind.COMBAT or r.kind == Kind.MINIBOSS


## One graph: the layers and their kinds, the links, the arenas, the rewards, the "?", then the check.
func _build() -> bool:
	nodes.clear()
	layers.clear()
	layers.append(PackedInt32Array())
	_parents.clear()
	_uses.clear()
	_before.clear()
	deck = RewardDeck.new(stage.reward_deck)
	_angel_deck = RewardDeck.new(stage.angel_deck)
	_angel_rng.seed = hash([map_seed, ANGEL_SALT])
	_enchants.clear()
	var last := stage.rooms + 1
	miniboss_depth = _rng.randi_range(stage.miniboss_depth_min, stage.miniboss_depth_max)
	miniboss2_depth = 0
	if stage.miniboss2_depth_min > 0:
		var low := maxi(stage.miniboss2_depth_min, miniboss_depth + stage.miniboss_gap)
		miniboss2_depth = _rng.randi_range(low, maxi(low, stage.miniboss2_depth_max))
	# GP-2: a fountain is always one of the two doors before a guardian's; now and then another past the first
	var fountains: Array[int] = []
	for g: int in [miniboss_depth, miniboss2_depth]:
		if g > 2:
			fountains.append(g - 1)
	if _rng.randf() < stage.fountain_more_chance:
		fountains.append_array(_event_depths(maxi(stage.fountain_depth_min, miniboss_depth + 1), stage.fountain_depth_max, 1.0, true, fountains))
	var altar: Array[int] = []
	if stage.altar_layout != null:
		altar = _event_depths(stage.altar_depth_min, stage.altar_depth_max, stage.altar_chance, false, fountains)
	# DV-2 (MAP-09): a route shop on one branch of a middle layer, never one of the fountain's nor the altar's
	var route: Array[int] = []
	if stage.route_shop_chance > 0.0:
		var busy: Array = fountains.duplicate()
		busy.append_array(altar)
		route = _event_depths(stage.route_shop_depth_min, stage.route_shop_depth_max, stage.route_shop_chance, false, busy)
	for d in range(1, last + 1):
		var ids := PackedInt32Array()
		var width := 1 if d == 1 or d >= stage.rooms or d == miniboss2_depth else DOORS
		var guardians: Array[StringName] = stage.minibosses.duplicate()
		_shuffle(guardians)
		for s in width:
			var r := Room.new(Kind.COMBAT, Reward.NONE, d, -1)
			if d == last:
				r.kind = Kind.BOSS
			elif d == stage.rooms:
				r.kind = Kind.SHOP
			elif guardian_at(d):
				r.kind = Kind.MINIBOSS
				r.reward = Reward.BOON
				r.guardian = guardians[s % guardians.size()] if not guardians.is_empty() else &""
			elif d == 1:
				r.reward = Reward.BOON
			r.id = nodes.size()
			r.slot = s
			r.fight_seed = _rng.randi()
			nodes.append(r)
			ids.append(r.id)
			_parents.append(PackedInt32Array())
			_uses.append({})
			_before.append(PackedInt32Array())
			_enchants.append(0)
		layers.append(ids)
		for k in fountains.count(d):
			# a layer keeps a fight beside its fountains
			var plain := Array(ids).filter(func(id: int) -> bool: return nodes[id].kind == Kind.COMBAT)
			if plain.size() > 1 or (k == 0 and not plain.is_empty()):
				nodes[plain[_rng.randi() % plain.size()]].kind = Kind.FOUNTAIN
		if d in altar and ids.size() > 1:
			var plain := Array(ids).filter(func(id: int) -> bool: return nodes[id].kind == Kind.COMBAT)
			if not plain.is_empty():
				nodes[plain[_rng.randi() % plain.size()]].kind = Kind.ALTAR
		if d in route and ids.size() > 1:
			var plain := Array(ids).filter(func(id: int) -> bool: return nodes[id].kind == Kind.COMBAT)
			if plain.size() > 1:
				nodes[plain[_rng.randi() % plain.size()]].kind = Kind.SHOP
	for d in range(1, last):
		for from in layers[d]:
			for to in layers[d + 1]:
				_join(from, to)
	for d in range(1, last + 1):
		_place_arenas(d)
		_draw_rewards(d)
	_count_fights()
	_place_trials()
	return _keeps_rules()


## The layers holding an event (the fountain, the altar) between these depths: the first one the dice give, or the
## last one when `forced`; never the guardian's, the shop's nor one in `not_in`.
func _event_depths(from: int, to: int, chance: float, forced: bool, not_in: Array) -> Array[int]:
	var can: Array[int] = []
	var out: Array[int] = []
	for d in range(maxi(2, from), mini(to, stage.rooms - 1) + 1):
		if not guardian_at(d) and not not_in.has(d):
			can.append(d)
	if can.is_empty():
		return out
	if chance >= 1.0:
		out.append(can[_rng.randi() % can.size()])
		return out
	for d in can:
		if _rng.randf() < chance:
			out.append(d)
			return out
	if forced:
		out.append(can[-1])
	return out


func _shuffle(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := _rng.randi() % (i + 1)
		var t: Variant = a[i]
		a[i] = a[j]
		a[j] = t


func _join(from: int, to: int) -> void:
	var r := nodes[from]
	if r.next.has(to):
		return
	r.next.append(to)
	r.next.sort_custom(func(x: int, y: int) -> bool: return nodes[x].slot < nodes[y].slot)
	_parents[to].append(from)


## The arenas of a layer, room by room in a random order: what came before it on every way (the arena of the fight
## before, the most uses of each) decides (_layout); rooms of one layer in different arenas when they can be.
func _place_arenas(d: int) -> void:
	var order: Array = Array(layers[d])
	_shuffle(order)
	var taken: Array[int] = []
	for id: int in order:
		var r := nodes[id]
		var uses := {}
		var before := PackedInt32Array()
		for p in _parents[id]:
			for l: int in _uses[p]:
				uses[l] = maxi(int(uses.get(l, 0)), int(_uses[p][l]))
			if nodes[p].kind == Kind.ALTAR:
				for l in _before[p]:
					if not before.has(l):
						before.append(l)
			elif not before.has(nodes[p].layout):
				before.append(nodes[p].layout)
		match r.kind:
			Kind.BOSS:
				r.layout = -1
				r.arena = stage.boss_layout.id if stage.boss_layout else &""
			Kind.ALTAR:
				r.layout = -1
				r.arena = stage.altar_layout.id if stage.altar_layout else &""
			Kind.SHOP:
				r.layout = stage.layouts.find(stage.shop_layout)
			_:
				r.layout = _layout(r.kind, d, before, uses, taken)
		if r.layout >= 0 and r.layout < stage.layouts.size():
			var l := stage.layouts[r.layout]
			r.arena = l.id
			# RP-07: only among the variants whose band holds this depth (one draw either way: no band, the map of before)
			var fit := l.variants_at(EncounterGen.progress(stage, d))
			var roll := _rng.randi()
			if d == miniboss2_depth:
				# the same house dressed another way than behind the doors of the first
				var met := layer(miniboss_depth).map(func(x: Room) -> int: return x.variant if x.layout == r.layout else -1)
				var fresh := Array(fit).filter(func(v: int) -> bool: return not met.has(v))
				if not fresh.is_empty():
					fit = fresh
			r.variant = fit[roll % fit.size()] if r.kind != Kind.SHOP else 0
			if r.kind != Kind.SHOP:
				# (a shop is no fight's arena: the route shop of DV-2 never uses up the hall's)
				uses[r.layout] = int(uses.get(r.layout, 0)) + 1
			taken.append(r.layout)
		_uses[id] = uses
		_before[id] = before if r.kind == Kind.ALTAR else PackedInt32Array([r.layout])


## The rewards of a layer's fights, off the deck: no two rooms of a layer with the same (so no two doors of a room),
## a pomegranate only from StageDef.pom_from_depth (the hall gives a Blessing, the next room may still not have one
## to grow), a Psalm only from psalm_from_depth, an Encanto never past enchant_max on a way and its second only from
## enchant_second_from, Prata only from silver_from_depth and Memória only past the guardian's layer (OF-05); a
## Blessing when the deck has nothing that fits even full. RJ-2: a card of a group the other
## doors of its rooms do not show yet is taken first when the deck has one. A Blessing's room is a meeting of two
## angels when its card off the angels' deck says so (StageDef.angel_deck, dice of their own: the map of before stays).
func _draw_rewards(d: int) -> void:
	var used: Array[int] = []
	for id in layers[d]:
		var r := nodes[id]
		var most := 0
		for p in _parents[id]:
			most = maxi(most, _enchants[p])
		if r.kind != Kind.COMBAT or d == 1:
			_enchants[id] = most
			if r.reward == Reward.BOON:
				r.meeting = true  # the hall's and the guardian's: no door shows them
			continue
		var beside := {}
		for p in _parents[id]:
			for n in nodes[p].next:
				if n != id and nodes[n].reward != Reward.NONE:
					beside[group_of(nodes[n].reward)] = true
		# (the Psalm card shows as a Blessing on the map: one promise with it)
		var card := deck.draw_prefer(_rng, func(c: int) -> bool:
			return not used.has(Reward.BOON if c == Reward.PSALM else c) and _may(c, d, most),
			func(c: int) -> bool: return not beside.has(group_of(c)))
		r.reward = Reward.BOON if card < 0 else card as Reward
		used.append(Reward.BOON if r.reward == Reward.PSALM else r.reward)
		if r.reward == Reward.PSALM:
			# a Blessing that may become a Psalm's door (settle): no meeting, and the angels' dice stay as they were
			r.reward = Reward.BOON
			r.psalm = true
			_enchants[id] = most
			continue
		_enchants[id] = most + (1 if r.reward == Reward.ENCHANT else 0)
		if r.reward == Reward.BOON:
			r.meeting = _angel_deck.draw(_angel_rng, func(_c: int) -> bool: return true) == 1


## Whether a card may lie at depth d behind a room with `most` Encantos already on a way to it.
func _may(c: int, d: int, most: int) -> bool:
	match c:
		Reward.POM:
			return d >= stage.pom_from_depth
		Reward.PSALM:
			return d >= stage.psalm_from_depth
		Reward.SILVER:
			return d >= stage.silver_from_depth
		Reward.MEMORY:
			return not stage.memory_after_guardian or d > miniboss_depth
		Reward.ENCHANT:
			return most < stage.enchant_max and (most == 0 or d >= stage.enchant_second_from)
	return true


## The fewest fights after each room on any way to the shop (fights_left).
func _count_fights() -> void:
	_fights_min.resize(nodes.size())
	_fights_min.fill(0)
	for d in range(layers.size() - 1, 0, -1):
		for id in layers[d]:
			var low := 1 << 20
			for n in nodes[id].next:
				low = mini(low, (1 if _is_fight(nodes[n]) else 0) + _fights_min[n])
			_fights_min[id] = 0 if low == 1 << 20 else low


## The Provação's "?" (Q-25 a): each fight room within its depths with StageDef.trial_chance, only where the shortest
## curse fits on the worst way after it, and never two on one way (once a descent, as its cooldown).
func _place_trials() -> void:
	var below := {}
	for d in range(maxi(2, stage.trial_depth_min), mini(stage.trial_depth_max, stage.rooms - 1) + 1):
		for id in layers[d]:
			var r := nodes[id]
			if r.kind != Kind.COMBAT or below.has(id) or fights_left(r) < min_curse or _rng.randf() >= stage.trial_chance:
				continue
			r.trial = true
			r.hidden = true
			var todo: Array[int] = r.next.duplicate()
			while not todo.is_empty():
				var n: int = todo.pop_back()
				if not below.has(n):
					below[n] = true
					todo.append_array(nodes[n].next)


## Every rule of the graph that the dice may break: a fight never in the arena of the fight before it, never in an arena
## its depth may not have, no arena past its uses on any way.
func _keeps_rules() -> bool:
	for d in range(layers.size() - 1, 0, -1):
		for id in layers[d]:
			var r := nodes[id]
			if r.next.size() > _doors_of(r):
				return false
			for l: int in _uses[id]:
				if int(_uses[id][l]) > stage.arena_max_uses:
					return false
			if _is_fight(r) and d > 1:
				if r.layout < 0 or r.layout >= stage.layouts.size() or not _fits(r.kind, d, r.layout):
					return false
				for p in _parents[id]:
					var prev: PackedInt32Array = _before[p] if nodes[p].kind == Kind.ALTAR else PackedInt32Array([nodes[p].layout])
					if prev.has(r.layout):
						return false
	return true


## The doors a room may have: its arena's (the hall's are its own stairs), never past DOORS.
func _doors_of(r: Room) -> int:
	if r.kind == Kind.ALTAR and stage.altar_layout != null and stage.altar_layout.exits.size() > 0:
		return mini(DOORS, stage.altar_layout.exits.size())
	if r.layout >= 0 and r.layout < stage.layouts.size() and stage.layouts[r.layout].exits.size() > 0:
		return mini(DOORS, stage.layouts[r.layout].exits.size())
	return DOORS


## True when an arena may hold a room of this kind at this depth (its place in the descent, a high one only from
## HARD_FROM, a guardian only where one may stand).
func _fits(kind: Kind, at_depth: int, l: int) -> bool:
	if forced_layout >= 0 and at_depth == 1:
		return true
	var lay := stage.layouts[l]
	if kind == Kind.MINIBOSS and lay.guardian_home:
		return true
	var at := EncounterGen.progress(stage, at_depth)
	if at < lay.depth.x - 0.001 or at > lay.depth.y + 0.001 or (lay.difficulty >= 2 and at < HARD_FROM):
		return false
	return kind != Kind.MINIBOSS or lay.guardian


## The arena of a room (cycle C12; DV-1 on every way to it): one whose place in the descent (RoomLayout.depth) holds
## this depth, that may hold this kind of room (guardian, fountain), never a high one before HARD_FROM, never one of
## the fights right before it (`before`; a fountain may follow its own), never one already used StageDef.arena_max_uses
## times on a way to it (`uses`), the least used first, one no other room of its layer has (`taken`) when it can; the
## layer before a guardian's, and every one up to the second's, leaves his house free.
func _layout(kind: Kind, at_depth: int, before: PackedInt32Array, uses: Dictionary, taken: Array[int]) -> int:
	if stage.layouts.is_empty():
		return 0
	if forced_layout >= 0 and at_depth == 1:
		return forced_layout
	if kind == Kind.MINIBOSS:
		# the guardian's own room, whatever the depth (E5: the Santuário), unless it was just fought in or used up
		for i in stage.layouts.size():
			if stage.layouts[i].guardian_home and not before.has(i) and int(uses.get(i, 0)) < stage.arena_max_uses:
				return i
	var found: Array[int] = []
	for i in stage.layouts.size():
		if kind == Kind.FOUNTAIN:
			if stage.layouts[i].fountain:
				found.append(i)
			continue
		if not before.has(i) and _fits(kind, at_depth, i):
			found.append(i)
	for keep: Callable in [
			func(i: int) -> bool: return int(uses.get(i, 0)) < stage.arena_max_uses,
			func(i: int) -> bool: return not (guardian_at(at_depth + 1) or at_depth < miniboss2_depth) or not stage.layouts[i].guardian_home,
			func(i: int) -> bool: return not taken.has(i)]:
		var fits := found.filter(keep)
		if not fits.is_empty():
			found.assign(fits)
	if found.is_empty():
		# nothing fits (a stage of one room shape): anything but the arenas just left
		for i in stage.layouts.size():
			if not before.has(i) or stage.layouts.size() == 1:
				found.append(i)
	var least := 1 << 30
	for i in found:
		least = mini(least, int(uses.get(i, 0)))
	var pool := found.filter(func(i: int) -> bool: return int(uses.get(i, 0)) == least)
	return pool[_rng.randi() % pool.size()]
