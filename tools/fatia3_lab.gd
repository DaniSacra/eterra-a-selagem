extends SceneTree
## Captures of the Fatia 3 screens over the real title: the Forja's Despertar bookmark (one awake, one asleep, the
## Inscrever without its tool), the Vendedor's stall (Obras and trades), the Livro's Ofícios with the Discernimento
## asked, and the Compêndio's Anjos tab, over sample save data. Nothing here ships and nothing is saved.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/fatia3_lab.gd -- --nosave --lab-out=C:/x/f3

const BOOT := "res://scenes/boot.tscn"

var _out := ""


func _initialize() -> void:
	create_timer(90.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	_out = Dev.arg("lab-out", "f3")
	var want := root.size
	var boot: Node = (load(BOOT) as PackedScene).instantiate()
	root.add_child(boot)
	await process_frame
	root.size = want
	await create_timer(1.4).timeout
	var data := _sample()
	var forge: Control = (load("res://scripts/ui/forge_screen.gd") as GDScript).new()
	boot.call(&"_open", forge, 1, [data, 2])
	await create_timer(0.5).timeout
	await _shot("forge_arts")
	var f := Forge.new(Forge.load_catalog())
	forge.call(&"_show", f.track(Forge.INSCRIBE)[0])
	await create_timer(0.3).timeout
	await _shot("forge_inscribe")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	var vendor: Control = (load("res://scripts/ui/vendor_screen.gd") as GDScript).new()
	boot.call(&"_open", vendor, 1, [data])
	await create_timer(0.5).timeout
	await _shot("vendor")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	var hero: Control = (load("res://scripts/ui/hero_screen.gd") as GDScript).new()
	boot.call(&"_open", hero, 1, [data, 3])
	await create_timer(0.5).timeout
	(hero.get(&"discern_buttons") as Array)[0].pressed.emit()
	await create_timer(0.3).timeout
	await _shot("book_discern")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	var codex: Control = (load("res://scripts/ui/codex_screen.gd") as GDScript).new()
	boot.call(&"_open", codex, 1, [7, data])
	await create_timer(0.5).timeout
	await _shot("codex_angels")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	# the Inimigos tab: a defeated one in the Livro's ink (FigureSketch), and one never defeated in silhouette
	var enemies: Control = (load("res://scripts/ui/codex_screen.gd") as GDScript).new()
	boot.call(&"_open", enemies, 1, [4, data])
	await create_timer(0.4).timeout
	(enemies.find_child("list", true, false).find_child("skeleton", true, false) as Control).grab_focus()
	await create_timer(0.8).timeout
	await _shot("codex_enemy_ink")
	(enemies.find_child("list", true, false).find_child("mage", true, false) as Control).grab_focus()
	await create_timer(0.8).timeout
	await _shot("codex_enemy_unknown")
	quit()


func _sample() -> Dictionary:
	var d := SaveData.defaults()
	Forge.add_tool(d, Forge.TOOL_REFINE)
	Forge.add_tool(d, Forge.TOOL_AWAKEN)
	MaterialPurse.give(d, MaterialPurse.SILVER, 64)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 11)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 6)
	var f := Forge.new(Forge.load_catalog())
	f.buy(d, &"awaken_sede")
	f.buy(d, &"awaken_impeto")
	for k in 12:
		SaveData.codex_add(d, "enemies", "skeleton", "defeated")
	var def := OficiosDef.live()
	Oficios.block(d).orders[String(def.order)] = "done"
	for pair: Array in [["sarael", 4, 3, 2], ["shomael", 2, 1, 0]]:
		for k in pair[1]:
			SaveData.codex_add(d, "angels", pair[0], "met")
		for k in pair[2]:
			SaveData.codex_add(d, "angels", pair[0], "chosen")
		for k in pair[3]:
			SaveData.codex_add(d, "angels", pair[0], "blessed")
	return d


func _shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
