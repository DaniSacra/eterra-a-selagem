class_name RunMap
extends RefCounted
## The way down through one region (DV-1, the Descida de Valmor, MAP-01): a graph of rooms in layers drawn from the
## run's seed when the descent begins, on dice of its own. Layer 1 is the catacomb hall (the opening fight, always a
## Blessing); layers 2 to StageDef.rooms - 1 hold 2 to 4 rooms each; one whole layer is the guardian's (the Knight and
## the Elder side by side when it has two rooms); layer StageDef.rooms is the shop and the next one Morvath. Every way
## through has the same length. Each room links to 1 to 3 rooms of the next layer (never more than its arena's doors,
## no two links crossing), every room is reached and leads on. Fountain, altar and the Provação's "?" are rooms of the
## graph; the rewards are drawn off the deck here, so what a door's sign and the map promise is what the room gives.
## The rules of the arenas hold on every way (never the same arena twice in a row, none more than arena_max_uses
## times, the guardian at home): the graph is drawn, checked and drawn again when it breaks one (failures counts).
## Hades II has no map (its doors show the reward): this is ours, over its rooms and numbers. Pure logic.
##
## API (what the map screen and the HUD read; nothing else is needed):
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
enum Reward { NONE, BOON, POM, HEART, MAGICK, GOLD, HEAL, POM_SLICE, SILVER, MEMORY }

const REWARD_KEY: Array[StringName] = [&"", &"reward_boon", &"reward_pom", &"reward_heart", &"reward_magick", &"reward_gold", &"reward_heal", &"reward_pom_slice", &"reward_silver", &"reward_memory"]
## The rewards that are materials brought home (Rooms gives them to the run's MaterialPurse).
const MATERIAL_REWARDS: Array[Reward] = [Reward.SILVER, Reward.MEMORY]
const KIND_KEY: Array[StringName] = [&"room_combat", &"room_miniboss", &"room_fountain", &"room_shop", &"room_boss", &"room_trial", &"room_altar"]

## The most doors a room has (every arena has 3, the hall too: CatacombHall._doors).
const MAX_DOORS := 3
## A high-difficulty arena (RoomLayout.difficulty 2) is never drawn before this share of the descent.
const HARD_FROM := 0.4
## Tries to draw a graph that keeps every rule before the last one is kept as it is (never seen in 1000 seeds).
const MAX_TRIES := 60


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
			"guardian_id": String(guardian)}

	## The room in plain values (RunMap.view).
	func view() -> Dictionary:
		return {"id": id, "depth": depth, "slot": slot, "kind": kind, "reward": reward, "guardian": String(guardian),
			"hidden": hidden, "arena": String(arena), "next": next.duplicate()}

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
## The guardian's layer.
var miniboss_depth := 0
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
	changed.emit()


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


## The doors about to open: a pomegranate behind one when nothing can grow (can_pom false) turns into a Blessing
## before its sign shows (Q-25 a; expected never). Returns how many turned.
func settle(doors_: Array[Room], can_pom: bool) -> int:
	var n := 0
	if can_pom:
		return 0
	for r in doors_:
		if r.reward == Reward.POM:
			r.reward = Reward.BOON
			n += 1
	if n > 0:
		pom_turned += n
		changed.emit()
	return n


## The Provação's slab appeared in r: its "?" turns into the room it is.
func reveal(r: Room) -> void:
	if r != null and r.hidden:
		r.hidden = false
		changed.emit()


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
	var last := stage.rooms + 1
	miniboss_depth = _rng.randi_range(stage.miniboss_depth_min, stage.miniboss_depth_max)
	var fountains := _event_depths(stage.fountain_depth_min, stage.fountain_depth_max, stage.fountain_chance, true, [])
	if not fountains.is_empty() and _rng.randf() < stage.fountain_more_chance:
		# a second fountain at the last of its depths (another branch of the same layer when the first is there too),
		# kept only where no way passes both (_one_fountain): a late fountain for who passed the first one healthy, as
		# the line of rooms before the map offered it again until its last depth
		fountains.append_array(_event_depths(stage.fountain_depth_min, stage.fountain_depth_max, 0.0, true, []))
	var altar: Array[int] = []
	if stage.altar_layout != null:
		altar = _event_depths(stage.altar_depth_min, stage.altar_depth_max, stage.altar_chance, false, fountains)
	for d in range(1, last + 1):
		var ids := PackedInt32Array()
		var width := _width(d, layers[d - 1].size() if d > 1 else 1)
		var guardians: Array[StringName] = stage.minibosses.duplicate()
		_shuffle(guardians)
		for s in width:
			var r := Room.new(Kind.COMBAT, Reward.NONE, d, -1)
			if d == last:
				r.kind = Kind.BOSS
			elif d == stage.rooms:
				r.kind = Kind.SHOP
			elif d == miniboss_depth:
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
	for d in range(1, last):
		_link(layers[d], layers[d + 1])
	_one_fountain()
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
		if d != miniboss_depth and not not_in.has(d):
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


## How many rooms a layer holds: 1 for the hall, the shop and Morvath; 1 or 2 for the guardian's; 2 to 4 for the
## others (StageDef.map_widths), never more than the layer before can link to.
func _width(d: int, before: int) -> int:
	if d == 1 or d >= stage.rooms:
		return 1
	if d == miniboss_depth:
		return 2 if stage.minibosses.size() >= 2 and _rng.randf() < stage.guardian_pair_chance else 1
	var w := 2 + (_rng.rand_weighted(stage.map_widths) if not stage.map_widths.is_empty() else 0)
	return clampi(w, 1, before * MAX_DOORS)


func _shuffle(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := _rng.randi() % (i + 1)
		var t: Variant = a[i]
		a[i] = a[j]
		a[j] = t


## Links two layers with no crossing (DV-1): each room of the upper layer leads to a run of 1 to MAX_DOORS rooms side by
## side below, each run starting where the one before ended (sharing that room) or right after it, the runs covering
## the whole layer below. Every such way of linking is listed and one is drawn, weighted by the doors of each room
## (StageDef.map_doors: 1, 2 or 3 doors), so most rooms show two doors.
func _link(a: PackedInt32Array, b: PackedInt32Array) -> void:
	var ways: Array = []
	var weights := PackedFloat32Array()
	_ways(a.size(), b.size(), [], ways, weights)
	if ways.is_empty():
		return
	var way: Array = ways[_rng.rand_weighted(weights)]
	var lo := 0
	for i in a.size():
		var size: int = way[i][0]
		for k in size:
			_join(a[i], b[lo + k])
		lo += size - 1 + (0 if way[i][1] else 1)


## Every linking of na rooms over nb (each [doors, shares the last one with the next]), with its weight.
func _ways(na: int, nb: int, so_far: Array, ways: Array, weights: PackedFloat32Array) -> void:
	var lo := 0
	for w: Array in so_far:
		lo += int(w[0]) - 1 + (0 if w[1] else 1)
	if so_far.size() == na:
		return
	var last := so_far.size() == na - 1
	for size in range(1, MAX_DOORS + 1):
		var hi := lo + size - 1
		if hi > nb - 1:
			break
		for shares: bool in ([true] if last else [true, false]):
			var w := so_far.duplicate()
			w.append([size, shares])
			if last:
				if hi == nb - 1:
					var weight := 1.0
					for x: Array in w:
						weight *= stage.map_doors[clampi(int(x[0]) - 1, 0, stage.map_doors.size() - 1)] if not stage.map_doors.is_empty() else 1.0
					ways.append(w)
					weights.append(weight)
			else:
				_ways(na, nb, w, ways, weights)


func _join(from: int, to: int) -> void:
	var r := nodes[from]
	if r.next.has(to):
		return
	r.next.append(to)
	r.next.sort_custom(func(x: int, y: int) -> bool: return nodes[x].slot < nodes[y].slot)
	_parents[to].append(from)


## The second fountain goes back to a fight when some way would pass both.
func _one_fountain() -> void:
	var most := PackedInt32Array()
	most.resize(nodes.size())
	for d in range(1, layers.size()):
		for id in layers[d]:
			var m := 0
			for p in _parents[id]:
				m = maxi(m, most[p])
			if nodes[id].kind == Kind.FOUNTAIN and m >= 1:
				nodes[id].kind = Kind.COMBAT
			most[id] = m + (1 if nodes[id].kind == Kind.FOUNTAIN else 0)


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
			r.variant = _rng.randi() % maxi(1, l.variant_count()) if r.kind != Kind.SHOP else 0
			uses[r.layout] = int(uses.get(r.layout, 0)) + 1
			taken.append(r.layout)
		_uses[id] = uses
		_before[id] = before if r.kind == Kind.ALTAR else PackedInt32Array([r.layout])


## The rewards of a layer's fights, off the deck: no two rooms of a layer with the same (so no two doors of a room),
## a pomegranate only from StageDef.pom_from_depth (the hall gives a Blessing, the next room may still not have one
## to grow); a Blessing when the deck has nothing that fits even full.
func _draw_rewards(d: int) -> void:
	var used: Array[int] = []
	for id in layers[d]:
		var r := nodes[id]
		if r.kind != Kind.COMBAT or d == 1:
			continue
		var card := deck.draw(_rng, func(c: int) -> bool:
			return not used.has(c) and (c != Reward.POM or d >= stage.pom_from_depth))
		r.reward = Reward.BOON if card < 0 else card as Reward
		used.append(r.reward)


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


## Every rule of the graph: each room but Morvath leads on (to at most its doors), each but the hall is reached; a
## fight never in the arena of the fight before it, never in an arena its depth may not have, no arena past its uses
## on any way; at most one fountain on a way; some room with two doors that lead on to different rooms. (The rooms
## reached are bits of an int: a region holds fewer than 63 rooms.)
func _keeps_rules() -> bool:
	var reach: Array[int] = []
	reach.resize(nodes.size())
	reach.fill(0)
	var differ := false
	for d in range(layers.size() - 1, 0, -1):
		for id in layers[d]:
			var r := nodes[id]
			if d < layers.size() - 1 and (r.next.is_empty() or r.next.size() > _doors_of(r)):
				return false
			if d > 1 and _parents[id].is_empty():
				return false
			var mask := 1 << id
			for n in r.next:
				mask |= reach[n]
			reach[id] = mask
			for x in r.next.size():
				for y in range(x + 1, r.next.size()):
					# the rooms beyond each door (the door's own room left out: two doors always differ by it)
					if reach[r.next[x]] & ~(1 << r.next[x]) != reach[r.next[y]] & ~(1 << r.next[y]):
						differ = true
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
	return differ


## The doors a room may have: its arena's (the hall's are its own stairs), never past MAX_DOORS.
func _doors_of(r: Room) -> int:
	if r.kind == Kind.ALTAR and stage.altar_layout != null and stage.altar_layout.exits.size() > 0:
		return mini(MAX_DOORS, stage.altar_layout.exits.size())
	if r.layout >= 0 and r.layout < stage.layouts.size() and stage.layouts[r.layout].exits.size() > 0:
		return mini(MAX_DOORS, stage.layouts[r.layout].exits.size())
	return MAX_DOORS


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
## layer before the guardian's leaves his house free.
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
			func(i: int) -> bool: return at_depth != miniboss_depth - 1 or not stage.layouts[i].guardian_home,
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
