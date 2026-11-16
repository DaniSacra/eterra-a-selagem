extends SceneTree
## Plays a normal run and, a few seconds in, offers the three illustrated gifts (Vapor, Aurora Gelada, Redemoinho de
## Fogo) so they can be seen and chosen by hand; the run then goes on. For review only; nothing here ships.
##   tools/gpu.sh run --rendering-driver vulkan -s tools/boon_card_view.gd -- --nosave [--offer=a,b,c] [--held=x,y]

const GAME := "res://scenes/game.tscn"
## Both sources of each Elo, so the Elos can be offered.
const HELD: Array[StringName] = [&"brasas", &"toque_geada", &"onda_maior"]
const OFFER: Array[StringName] = [&"vapor", &"aurora", &"redemoinho"]
const START := 3.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node = (load(GAME) as PackedScene).instantiate()
	root.add_child(game)
	await create_timer(START).timeout
	var boons: Variant = game.get(&"boons")
	for id in _ids("held", HELD):
		game.call(&"_take", boons.call(&"find", id))
	var offers: Array = boons.call(&"offers", RandomNumberGenerator.new(), 1)
	offers.clear()
	for id in _ids("offer", OFFER):
		offers.append(boons.call(&"find", id))
	game.call(&"_open_choice", offers)


func _ids(key: String, fallback: Array[StringName]) -> Array[StringName]:
	var raw: String = Dev.arg(key, "")
	if raw == "":
		return fallback
	var out: Array[StringName] = []
	for s in raw.split(",", false):
		out.append(StringName(s))
	return out
