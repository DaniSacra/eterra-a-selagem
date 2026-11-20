extends SceneTree
## Captures of the Livro de Ahk for UI review (art pack stage 2): over the real title, the book on each chapter
## (Abertura, O Guerreiro, Dons with a Gift focused and its prerequisites lit, a Gift blocked by a rule, a locked one,
## an ultimate) and the Compendium on its chapters, over sample save data (some found, some not).
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/book_lab.gd -- --nosave --lab-out=C:/x/book
## Writes <lab-out>_<name>.png. Calls the screens' own methods; nothing here ships and nothing is saved.

const BOOT := "res://scenes/boot.tscn"
## Mastery 11 with 50 XP into it, Combo's entry and middle and Fúria's entry on (the "before" captures' hand).
const XP := 900
const EQUIPPED: Array = ["quarto_corte", "passo_encadeado", "impeto"]
## Revealed but not opened with Memória (Rejogabilidade, Fatia 1): the gifts_sealed_* captures.
const SEALED: Array = ["lamina_faminta", "investida"]

var _out := ""


func _initialize() -> void:
	create_timer(90.0).timeout.connect(quit)
	_run.call_deferred()


func _run() -> void:
	_out = Dev.arg("lab-out", "book")
	var want := root.size
	var boot: Node = (load(BOOT) as PackedScene).instantiate()
	root.add_child(boot)
	await process_frame
	root.size = want
	await create_timer(1.4).timeout
	var data := _sample()
	var hero: Control = (load("res://scripts/ui/hero_screen.gd") as GDScript).new()
	boot.call(&"_open", hero, 1, [data, 1])
	await create_timer(0.6).timeout
	await _shot("hero")
	hero.call(&"_show", 0)
	await create_timer(0.3).timeout
	await _shot("opening")
	hero.call(&"_open_chapter", 2)
	var tree: Node = hero.get(&"tree")
	for id: String in ["golpe_sem_fim", "furia_plena", "onda_atravessante"]:
		(tree.call(&"node", StringName(id)) as Control).grab_focus()
		await create_timer(0.3).timeout
		await _shot("gifts_" + id)
	# Abrir with Memória: the sealed Gift in focus, the question after one press, and one it cannot pay
	(tree.call(&"node", &"lamina_faminta") as Control).grab_focus()
	await create_timer(0.3).timeout
	await _shot("gifts_sealed")
	hero.call(&"_pick", hero.get(&"loadout").get(&"book").call(&"find", &"lamina_faminta"))
	await create_timer(0.3).timeout
	await _shot("gifts_sealed_ask")
	(tree.call(&"node", &"investida") as Control).grab_focus()
	hero.call(&"_pick", hero.get(&"loadout").get(&"book").call(&"find", &"investida"))
	await create_timer(0.3).timeout
	await _shot("gifts_sealed_short")
	var ults: Array = hero.get(&"ults")
	(ults[1] as Control).grab_focus()
	await create_timer(0.3).timeout
	await _shot("gifts_ult")
	boot.call(&"_close_sub")
	await create_timer(0.3).timeout
	for t: int in [0, 1, 2, 3, 4, 5, 6, 7]:
		var codex: Control = (load("res://scripts/ui/codex_screen.gd") as GDScript).new()
		boot.call(&"_open", codex, 2, [t, data])
		await create_timer(0.4).timeout
		await _shot("codex_%d" % t)
		boot.call(&"_close_sub")
		await process_frame


## A save with some of everything found (the ui_lab's Compendium sample) and the Warrior's hand.
func _sample() -> Dictionary:
	var data: Dictionary = (load("res://scripts/core/save_data.gd") as GDScript).call(&"defaults")
	var block: Dictionary = (load("res://scripts/core/save_data.gd") as GDScript).call(&"hero", data, "warrior")
	block.mastery_xp = XP
	block.equipped = EQUIPPED.duplicate()
	# what this Mastery revealed is opened (the version 6 migration), but for SEALED: Abrir with Memória to show
	(load("res://scripts/core/save_data.gd") as GDScript).call(&"open_revealed", block)
	for id: String in SEALED:
		block.opened.erase(id)
	data.materials = {"silver": 23, "memory": 2}
	var seen := {"brasas": 6, "toque_geada": 4, "onda_maior": 3, "escudo": 2, "passos": 1, "golpe_brasa": 5,
		"estilhaco": 2, "consolo": 1, "lamina_ardente": 1, "circulo_radiante": 2, "passo_geada": 1}
	for id: String in seen:
		data.codex.boons[id] = {"seen": seen[id]}
	data.codex.elos["vapor"] = {"formed": 2}
	data.codex.elos["aurora"] = {"formed": 1}
	data.codex.psalms["sentinela"] = {"seen": 2, "taken": 1}
	data.codex.psalms["pastor"] = {"seen": 1}
	data.codex.enemies = {"skeleton": {"defeated": 64, "elite": 5}, "runner": {"defeated": 31, "elite": 2},
		"mage": {"defeated": 18}, "archer": {"defeated": 12}, "guard": {"defeated": 7}, "knight": {"defeated": 1},
		"morvath": {"met": 3, "phase": 3}}
	data.codex.arenas = {"hall": {"entered": 9}, "crypt": {"entered": 3}, "garden": {"entered": 2}, "seal_chamber": {"entered": 3}}
	data.moves = ["cut1", "cut2", "cut3", "dash_cut"]
	return data


func _shot(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "%s_%s.png" % [_out, tag]
	root.get_texture().get_image().save_png(path)
	print("LAB saved ", path)
