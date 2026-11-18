class_name DescentMap
extends RefCounted
## What the descent's map shows (DV-1, MAP-03; the graph itself is RunMap's, MAP-01): the rooms by depth, their links,
## the way walked, the room the paladin stands in and the doors open from it. Pure: built from a plain dictionary, so
## the map screen (MapScreen) reads the same shape from the run (RunMap.view(), when it has one), from the test graphs
## (MapSample) and from the tests.
##
## The dictionary (every key but "layers" optional):
##   "layers":  Array of layers, the first is depth 1 (the hall), the last Morvath's; each layer an Array of nodes:
##     {"id": int (unique in the map), "kind": RunMap.Kind, "reward": RunMap.Reward, "guardian": enemy id
##      (&"knight", &"priest_elder"; "" when none), "hidden": bool (the Provação's room before its slab shows: only
##      "?" on the map), "arena": RoomLayout.id ("" when unknown), "next": Array of ids in the next layer,
##      "hard": bool (a fight with an elite)}
##   "path":    Array of ids walked, in order, the current room last
##   "current": id of the room the paladin stands in (default: the last of "path", else the first node)
##   "doors":   Array of ids behind the doors open now (default: the current room's "next")

## How a room reads on the map: walked, the one stood in, behind an open door, still reachable, or left behind (a
## branch not taken: no way to it any more).
enum State { DONE, CURRENT, DOOR, AHEAD, BEHIND }


class Room:
	var id := 0
	## 1 for the hall.
	var depth := 1
	## Its place in its layer, from the left.
	var index := 0
	var kind := RunMap.Kind.COMBAT
	var reward := RunMap.Reward.NONE
	var guardian: StringName = &""
	var hidden := false
	var arena: StringName = &""
	var hard := false
	var next: Array[int] = []


var layers: Array = []
var rooms: Dictionary = {}
var path: Array[int] = []
var current := -1
var doors: Array[int] = []
var _ahead: Dictionary = {}


static func from_dict(d: Dictionary) -> DescentMap:
	var m := DescentMap.new()
	var depth := 0
	for layer: Array in d.get("layers", []):
		depth += 1
		var row: Array[Room] = []
		for n: Dictionary in layer:
			var r := Room.new()
			r.id = int(n.get("id", 0))
			r.depth = depth
			r.index = row.size()
			r.kind = int(n.get("kind", RunMap.Kind.COMBAT)) as RunMap.Kind
			r.reward = int(n.get("reward", RunMap.Reward.NONE)) as RunMap.Reward
			r.guardian = StringName(str(n.get("guardian", "")))
			r.hidden = bool(n.get("hidden", false))
			r.arena = StringName(str(n.get("arena", "")))
			r.hard = bool(n.get("hard", false))
			for id: Variant in n.get("next", []):
				r.next.append(int(id))
			row.append(r)
			m.rooms[r.id] = r
		m.layers.append(row)
	for id: Variant in d.get("path", []):
		m.path.append(int(id))
	m.current = int(d.get("current", m.path[-1] if not m.path.is_empty() else (m.first_id())))
	if d.has("doors"):
		for id: Variant in d.doors:
			m.doors.append(int(id))
	elif m.rooms.has(m.current):
		m.doors = (m.rooms[m.current] as Room).next.duplicate()
	if m.path.is_empty() and m.rooms.has(m.current):
		m.path.append(m.current)
	m._ahead = m._reach()
	return m


## The map of the run in progress: RunMap.view() once the descent is a graph (MAP-01), else the line of rooms of today
## read from the run (the past rooms, the room stood in, the doors, the guardian's depth, the shop and Morvath).
static func from_game(game: Node) -> DescentMap:
	var rooms_: Variant = game.get(&"rooms") if game != null else null
	if rooms_ == null:
		return DescentMap.new()
	var run_map: Variant = (rooms_ as Object).get(&"map")
	if run_map != null and (run_map as Object).has_method(&"view"):
		return from_dict((run_map as Object).call(&"view"))
	return from_dict(line_of(rooms_ as Object))


## Today's descent (one room per depth) in the map's shape: every room links to every room of the next depth.
static func line_of(rooms_: Object) -> Dictionary:
	var stage: StageDef = rooms_.get(&"stage")
	var run_map: RunMap = rooms_.get(&"map")
	var here: RunMap.Room = rooms_.get(&"room")
	var at: int = rooms_.call(&"depth")
	var total := stage.rooms + 1
	var layers: Array = []
	var path: Array = []
	var next_id := 0
	var doors: Array = []
	for d in range(1, total + 1):
		var layer: Array = []
		if d == at + 1 and not (rooms_.get(&"next_rooms") as Array).is_empty():
			var i := 0
			for r: RunMap.Room in rooms_.get(&"next_rooms"):
				var info: Dictionary = rooms_.call(&"door_info", i)
				layer.append({"id": next_id, "kind": r.kind, "reward": r.reward, "hard": info.get("hard", false),
					"arena": info.get("arena", ""), "guardian": _guardian_of(r)})
				doors.append(next_id)
				next_id += 1
				i += 1
		else:
			var node := {"id": next_id, "kind": RunMap.Kind.COMBAT, "reward": RunMap.Reward.NONE}
			if d == at and here != null:
				node.kind = here.kind
				node.reward = here.reward
				node.guardian = _guardian_of(here)
			elif d == total:
				node.kind = RunMap.Kind.BOSS
			elif d == stage.rooms:
				node.kind = RunMap.Kind.SHOP
			elif d == run_map.miniboss_depth and d > at:
				node.kind = RunMap.Kind.MINIBOSS
			layer.append(node)
			if d <= at:
				path.append(next_id)
			next_id += 1
		layers.append(layer)
	# every room of a depth links to every room of the next one
	for i in layers.size() - 1:
		var ids: Array = (layers[i + 1] as Array).map(func(n: Dictionary) -> int: return n.id)
		for n: Dictionary in layers[i]:
			n.next = ids
	return {"layers": layers, "path": path, "current": path[-1] if not path.is_empty() else 0, "doors": doors}


static func _guardian_of(r: RunMap.Room) -> StringName:
	if r.kind != RunMap.Kind.MINIBOSS or r.fight == null or r.fight.kinds.is_empty():
		return &""
	return r.fight.kinds[0]


func first_id() -> int:
	return (layers[0][0] as Room).id if not layers.is_empty() and not (layers[0] as Array).is_empty() else -1


func room(id: int) -> Room:
	return rooms.get(id) as Room


func depths() -> int:
	return layers.size()


func state(id: int) -> State:
	if id == current:
		return State.CURRENT
	if path.has(id):
		return State.DONE
	if doors.has(id):
		return State.DOOR
	if _ahead.has(id):
		return State.AHEAD
	return State.BEHIND


## Every room still reachable from the current one (not counting it).
func _reach() -> Dictionary:
	var seen := {}
	var queue: Array[int] = []
	if rooms.has(current):
		queue.append_array((rooms[current] as Room).next)
	while not queue.is_empty():
		var id: int = queue.pop_back()
		if seen.has(id) or not rooms.has(id):
			continue
		seen[id] = true
		queue.append_array((rooms[id] as Room).next)
	return seen


## The link from a to b is walked (both on the path, one after the other).
func walked(a: int, b: int) -> bool:
	var i := path.find(a)
	return i >= 0 and i + 1 < path.size() and path[i + 1] == b


## The mark inside a room's disc: "?" while hidden; the kind's own mark for the rooms without a reward (fountain,
## shop, altar, the Provação, Morvath); else the reward's.
func mark(id: int) -> DoorGlyph.Kind:
	var r := room(id)
	if r == null:
		return DoorGlyph.Kind.NONE
	if r.hidden:
		return DoorGlyph.Kind.UNKNOWN
	match r.kind:
		RunMap.Kind.FOUNTAIN, RunMap.Kind.SHOP, RunMap.Kind.ALTAR, RunMap.Kind.TRIAL, RunMap.Kind.BOSS:
			return DoorGlyph.of({"kind": r.kind})
	return DoorGlyph.of_reward(r.reward)


## The chevrons beside a room's disc: one for a hard fight, two for the guardian (Morvath's three are his mark).
func badge(id: int) -> DoorGlyph.Kind:
	var r := room(id)
	if r == null or r.hidden:
		return DoorGlyph.Kind.NONE
	if r.kind == RunMap.Kind.MINIBOSS:
		return DoorGlyph.Kind.GUARDIAN
	return DoorGlyph.Kind.HARD if r.kind == RunMap.Kind.COMBAT and r.hard else DoorGlyph.Kind.NONE


## The guardian's short name under his room on the map ("Cavaleiro", "Ancião"), "" for other rooms.
func guardian_short(id: int) -> String:
	var r := room(id)
	if r == null or r.guardian == &"" or r.hidden:
		return ""
	var key := "map_guardian_" + String(r.guardian)
	return T.t(key) if T.table.entries.has(key) else guardian_name(r.guardian)


## A guardian's whole name, as the Compendium writes it.
static func guardian_name(id: StringName) -> String:
	var key := "codex_enemy_" + String(id)
	if T.table.entries.has(key):
		return T.t(key)
	var path_ := "res://data/enemies/%s.tres" % id
	if ResourceLoader.exists(path_):
		var def := load(path_) as EnemyDef
		if def != null:
			return T.t(def.name_key)
	return String(id)


## The room's name in the text of the focused room: "?" while hidden, the guardian's name in his room, else the kind.
func title(id: int) -> String:
	var r := room(id)
	if r == null:
		return ""
	if r.hidden:
		return T.t(&"map_hidden")
	if r.kind == RunMap.Kind.MINIBOSS and r.guardian != &"":
		return T.t(&"map_guardian_title", {"name": guardian_name(r.guardian)})
	return T.t(RunMap.KIND_KEY[r.kind])


## The lines under the title: the room's number, its reward, hard, the arena, and how it stands now.
func lines(id: int) -> PackedStringArray:
	var r := room(id)
	var out: PackedStringArray = []
	if r == null:
		return out
	out.append(T.t(&"hud_room", {"n": r.depth, "of": depths()}))
	if r.hidden:
		out.append(T.t(&"map_hidden_desc"))
	else:
		if r.reward != RunMap.Reward.NONE and r.kind != RunMap.Kind.SHOP:
			out.append(T.t(&"map_reward", {"name": T.t(RunMap.REWARD_KEY[r.reward])}))
		if r.hard and r.kind == RunMap.Kind.COMBAT:
			out.append(T.t(&"map_hard"))
	var arena_key := "arena_" + String(r.arena)
	if r.arena != &"" and T.table.entries.has(arena_key):
		out.append(T.t(&"map_arena", {"name": T.t(arena_key)}))
	out.append(T.t(STATE_KEY[state(id)]))
	return out


const STATE_KEY: Array[StringName] = [&"map_state_done", &"map_state_current", &"map_state_door", &"map_state_ahead",
	&"map_state_behind"]


## Where the focus starts: the first open door, else the room stood in.
func first_focus() -> int:
	if not doors.is_empty():
		return doors[0]
	return current


## The room the focus moves to from `id` by one step: left and right along its depth, up and down to the nearest room
## of the depth above or below (one it links with first). The same id when there is none that way.
func step(id: int, dir: Vector2i) -> int:
	var r := room(id)
	if r == null:
		return first_focus()
	var row: Array = layers[r.depth - 1]
	if dir.x != 0:
		var i := r.index + dir.x
		return (row[i] as Room).id if i >= 0 and i < row.size() else id
	var d := r.depth - 1 + dir.y
	if d < 0 or d >= layers.size():
		return id
	var target: Array = layers[d]
	var where := _share(r)
	var best := id
	var best_cost := INF
	for o: Room in target:
		var linked := r.next.has(o.id) or o.next.has(r.id)
		var cost := absf(_share(o) - where) - (0.5 if linked else 0.0)
		if cost < best_cost:
			best_cost = cost
			best = o.id
	return best


## Where a room stands across its depth, 0 to 1.
func _share(r: Room) -> float:
	var n: int = (layers[r.depth - 1] as Array).size()
	return (r.index + 0.5) / float(n)
