extends SceneTree
## PM-4: how many fountains a path of the descent may hold (300 maps): the most and the least over all paths.
func _init() -> void:
	var st: StageDef = load("res://data/stages/catacombs.tres")
	var hist := {}
	var minh := {}
	var depthcount := {}
	for s in 300:
		var m := RunMap.new(st, s + 1)
		var mx := {}
		var mn := {}
		for d in range(m.layers.size() - 1, 0, -1):
			for id in m.layers[d]:
				var r: RunMap.Room = m.nodes[id]
				var f := 1 if r.kind == RunMap.Kind.FOUNTAIN else 0
				var bx := 0
				var bn := 0
				if not r.next.is_empty():
					bx = -1
					bn = 999
					for n in r.next:
						bx = maxi(bx, mx[n])
						bn = mini(bn, mn[n])
				mx[id] = bx + f
				mn[id] = bn + f
		var a: int = 0
		var b: int = 999
		for id in m.layers[1]:
			a = maxi(a, mx[id])
			b = mini(b, mn[id])
		hist[a] = hist.get(a, 0) + 1
		minh[b] = minh.get(b, 0) + 1
	print("MAX per path: ", hist, "  MIN per path: ", minh)
	quit()
