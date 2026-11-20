extends GutTest
## DT-104: the assets' budgets checked on every run (technical-artist, docs/qa/asset_report.md). Fails when a baked
## figure is staler than its entry in tools/bake.gd (the "bake_stamp" each .res keeps, stamp() in tools/bake.gd), when the
## baked figures pass 70 MB, when the music in the package passes 18 MB, or a figure passes its triangle ceiling.

const BAKE := "res://tools/bake.gd"
const BAKED := "res://assets/baked/"
const BAKED_CEILING := 70 * 1024 * 1024
const MUSIC := "res://audio/music/"
const MUSIC_CEILING := 18 * 1024 * 1024
## DT-107: every figure of the crowd at most this many triangles (body after MeshSlim, about 3 870, plus the KayKit
## pieces it holds, whole); the hub's people have their own (hub_spec_art.md 3.8). The 4 100 of the backlog holds for
## the unarmed and Morvath's 4 281 nearly: the staff (1 519) keeps the sorcerer at 5 530 and the elder at 5 557, and
## the simpler levels of the pieces (tools/bake.gd "lod") were tried and left out (the staff's head and the shield's
## rim go, and the wind-up measures of test_enemy_windup, means over every vertex, move with the pieces' count). A
## figure that grows past this must say why.
const FIGURE_TRIANGLES := 5600
const NPC_TRIANGLES := 12000
## Entries baked but not drawn by the game (none since the statue left, DT-107).
const UNUSED: Array[String] = []


func _entries() -> Dictionary:
	var consts := (load(BAKE) as GDScript).get_script_constant_map()
	var out := {}
	for group: String in ["MODELS", "NPCS"]:
		var d: Dictionary = consts[group]
		for id: String in d:
			out[id] = {"spec": d[id], "npc": group == "NPCS"}
	return out


func _stamp(spec: Dictionary) -> int:
	return (load(BAKE) as GDScript).call(&"stamp", spec)


func test_every_baked_figure_is_as_new_as_its_entry() -> void:
	var stale: Array[String] = []
	for id: String in _entries():
		if UNUSED.has(id):
			continue
		var path := BAKED + id + ".res"
		assert_true(ResourceLoader.exists(path), "%s is baked" % id)
		if not ResourceLoader.exists(path):
			continue
		var m: BakedModel = load(path)
		var want := _stamp(_entries()[id].spec)
		if int(m.get_meta(&"bake_stamp", -1)) != want:
			stale.append(id)
	assert_eq(stale, [] as Array[String],
		"bake again what changed: ~/tools/godot/godot --headless --path . -s tools/bake.gd -- %s" % " ".join(stale))


func test_the_baked_figures_stay_under_seventy_megabytes() -> void:
	var total := 0
	for f in DirAccess.get_files_at(BAKED):
		if f.ends_with(".res"):
			total += FileAccess.get_file_as_bytes(BAKED + f).size()
	assert_lt(total, BAKED_CEILING, "baked figures %.2f MB" % (total / 1048576.0))


func test_the_music_in_the_package_stays_under_eighteen_megabytes() -> void:
	# what the package carries is the imported stream of each .ogg (path in its .import)
	var total := 0
	for f in DirAccess.get_files_at(MUSIC):
		if not f.ends_with(".ogg.import"):
			continue
		var cfg := ConfigFile.new()
		cfg.load(MUSIC + f)
		var imported := String(cfg.get_value("remap", "path", ""))
		var bytes := FileAccess.get_file_as_bytes(imported) if imported != "" else PackedByteArray()
		if bytes.is_empty():
			bytes = FileAccess.get_file_as_bytes(MUSIC + f.trim_suffix(".import"))
		total += bytes.size()
	assert_gt(total, 0, "the music is there")
	assert_lt(total, MUSIC_CEILING, "music in the package %.2f MB" % (total / 1048576.0))


func test_every_figure_keeps_its_triangle_ceiling() -> void:
	var over: Array[String] = []
	var entries := _entries()
	for id: String in entries:
		if UNUSED.has(id) or not ResourceLoader.exists(BAKED + id + ".res"):
			continue
		var m: BakedModel = load(BAKED + id + ".res")
		var n := 0
		for s in m.mesh.get_surface_count():
			n += (m.mesh.surface_get_arrays(s)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		var ceiling := NPC_TRIANGLES if entries[id].npc else FIGURE_TRIANGLES
		if n > ceiling:
			over.append("%s %d" % [id, n])
	assert_eq(over, [] as Array[String], "figures over their ceiling")
