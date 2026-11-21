class_name MapSample
extends RefCounted
## A fixed descent in DescentMap's shape, for captures and tests before the run's own graph (MAP-01) is wired: 11
## depths, two or three rooms in most, the guardian's depth with the Cavaleiro and the Ancião side by side, a fountain,
## the altar, two hidden rooms (the Provação's "?"), the shop and Morvath. Three moments of one descent: at the start
## (in the hall), in the middle (before the guardians) and before the doors past the fountain (one of them hidden).
## Dev only: --title --screen=map [--map-at=start|middle|doors], tools/ui_lab.gd --map, tests.

const C := RunMap.Kind.COMBAT
const B := RunMap.Reward.BOON


static func layers() -> Array:
	return [
		[_n(0, C, B, ["hall"], [1, 2])],
		[_n(1, C, B, ["crypt"], [3, 4]), _n(2, C, RunMap.Reward.GOLD, ["garden"], [4, 5])],
		[_n(3, C, RunMap.Reward.POM, ["rift"], [6]), _n(4, RunMap.Kind.ALTAR, RunMap.Reward.NONE, ["altar"], [6, 7]),
			_n(5, C, RunMap.Reward.HEART, ["bridge", "hard"], [7])],
		[_n(6, C, RunMap.Reward.MAGICK, ["runes"], [8]), _n(7, C, B, ["crypt"], [8, 9])],
		[_n(8, RunMap.Kind.MINIBOSS, B, ["sanctuary", "knight"], [10, 11]),
			_n(9, RunMap.Kind.MINIBOSS, B, ["garden", "priest_elder"], [11, 12])],
		[_n(10, C, B, ["rift"], [13]), _n(11, RunMap.Kind.FOUNTAIN, RunMap.Reward.NONE, ["hall"], [13, 14]),
			_n(12, C, RunMap.Reward.GOLD, ["runes", "hard", "vein"], [14])],
		[_n(13, C, RunMap.Reward.POM, ["bridge", "hidden"], [15, 16]), _n(14, C, B, ["sanctuary", "find"], [16])],
		[_n(15, C, RunMap.Reward.HEART, ["crypt", "hard"], [17]), _n(16, C, B, ["garden", "hidden"], [17, 18])],
		[_n(17, C, RunMap.Reward.MAGICK, ["rift"], [19]), _n(18, C, RunMap.Reward.POM, ["bridge"], [19])],
		[_n(19, RunMap.Kind.SHOP, RunMap.Reward.NONE, ["hall"], [20])],
		[_n(20, RunMap.Kind.BOSS, RunMap.Reward.NONE, ["seal_chamber"], [])],
	]


## The descent at a moment: "start" (in the hall), "middle" (four rooms in, the two guardians behind the doors),
## "doors" (at the fountain, a hidden room behind one door).
static func at(moment: String = "doors") -> Dictionary:
	var path: Array = [0]
	match moment:
		"middle":
			path = [0, 2, 5, 7]
		"doors":
			path = [0, 2, 5, 7, 9, 11]
	return {"layers": layers(), "path": path, "current": path[-1]}


## A node: tags are the arena's id first, then "hard", "hidden", a guardian's id, "find" (the pick's head waits in it)
## or "vein".
static func _n(id: int, kind: RunMap.Kind, reward: RunMap.Reward, tags: Array, next: Array) -> Dictionary:
	var guardian := ""
	for t: String in tags:
		if t == "knight" or t == "priest_elder":
			guardian = t
	return {"id": id, "kind": kind, "reward": reward, "arena": tags[0], "hard": tags.has("hard"),
		"hidden": tags.has("hidden"), "guardian": guardian, "next": next,
		"find": "pick_head" if tags.has("find") else "", "vein": tags.has("vein")}
