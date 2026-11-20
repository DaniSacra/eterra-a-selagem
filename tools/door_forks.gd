extends SceneTree
## Rejogabilidade, Fatia 2 (RJ-2, RJ-3; sistemas.md 3.6): measures the doors of many descents' graphs, no game run.
## For every room with two or more doors that lead to rooms with a reward: the share whose doors show rewards of
## different groups (RunMap.group_of: power now, body, home), of three groups, and of the same reward twice; how many
## doors of each reward a way meets (the floor of chances before Morvath: a Blessing, Prata, Memória, an Encanto, a
## Psalm); Encantos on the worst and best way; the doors that show one angel or a meeting of two.
## ~/tools/godot/godot --headless --path . -s tools/door_forks.gd -- [--seeds=1000]
## (The shorter descents, --short and --medium, are checked by tests/test_descent.gd: Rooms needs the autoloads.)

## Rooms.MAP_SALT (Rooms needs the autoloads a -s script has not).
const MAP_SALT := 7411


func _initialize() -> void:
	var seeds := 1000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--seeds="):
			seeds = int(a.trim_prefix("--seeds="))
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var forks := 0
	var mixed := 0
	var three := 0
	var twin := 0
	var on_way := {}
	var ways := 0
	var enchant_most := 0
	var meetings := 0
	var boons := 0
	var no_boon_way := 0
	for s in seeds:
		var map := RunMap.new(stage, hash([s, MAP_SALT]))
		for r in map.nodes:
			var shown: Array[int] = []
			for n in r.next:
				var x := map.at(n)
				if x.reward != RunMap.Reward.NONE and x.kind == RunMap.Kind.COMBAT:
					shown.append(x.reward)
			if shown.size() < 2:
				continue
			forks += 1
			var groups := {}
			var rewards := {}
			for w in shown:
				groups[RunMap.group_of(w)] = true
				if rewards.has(w):
					twin += 1
				rewards[w] = true
			if groups.size() >= 2:
				mixed += 1
			if groups.size() >= 3:
				three += 1
		for r in map.nodes:
			if r.kind == RunMap.Kind.COMBAT and r.reward == RunMap.Reward.BOON and r.depth > 1:
				boons += 1
				if r.meeting:
					meetings += 1
		# every way from the hall to Morvath: what it meets
		var all: Array = []
		_ways(map, map.first().id, [], all)
		for w: Array in all:
			ways += 1
			var seen := {}
			var enchants := 0
			for id: int in w:
				var x := map.at(id)
				seen[x.reward] = int(seen.get(x.reward, 0)) + 1
				if x.reward == RunMap.Reward.ENCHANT:
					enchants += 1
			enchant_most = maxi(enchant_most, enchants)
			for k: int in seen:
				on_way[k] = int(on_way.get(k, 0)) + 1
			if int(seen.get(RunMap.Reward.BOON, 0)) < 3:
				no_boon_way += 1
	print("FORKS seeds=%d rooms with 2+ reward doors=%d different groups=%.1f%% three groups=%.1f%% same reward twice=%d" % [
		seeds, forks, 100.0 * mixed / maxi(forks, 1), 100.0 * three / maxi(forks, 1), twin])
	var line := "WAYS %d:" % ways
	for k: int in on_way:
		line += " %s %.0f%%" % [(RunMap.Reward.keys()[k] as String).to_lower(), 100.0 * on_way[k] / ways]
	print(line)
	print("ENCHANTS most on a way=%d; ways with fewer than 3 Blessing doors=%.1f%%" % [enchant_most, 100.0 * no_boon_way / maxi(ways, 1)])
	print("ANGELS Blessing rooms=%d meetings of two=%.1f%%" % [boons, 100.0 * meetings / maxi(boons, 1)])
	quit()


func _ways(map: RunMap, id: int, so_far: Array, out: Array) -> void:
	var here := so_far.duplicate()
	here.append(id)
	var r := map.at(id)
	if r.next.is_empty():
		out.append(here)
		return
	for n in r.next:
		_ways(map, n, here, out)
