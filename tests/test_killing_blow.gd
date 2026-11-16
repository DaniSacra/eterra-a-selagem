extends GutTest
## BUG-014 (cycle C12a2): the blow that kills the paladin is the one named, in the run's log, on the end screen and in
## Morvath's numbers. Before, a killing blow emitted Player.died inside Player.hurt and the run was logged with the
## blow before it (a Knight's, after the Knight had fallen rooms ago). Each case: a Knight's blow first, then the
## killing blow of one of Morvath's attacks (from the source that deals it: a warning on the floor or a shot) or of
## one of his dead.

var game: Game
var logged: Dictionary


func _fight() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	logged = {}
	game.run_logged.connect(func(outcome: String, entry: Dictionary) -> void:
		logged = entry
		logged["outcome"] = outcome)
	# a Knight's blow (the crowd's own swing), that he lives through
	game.horde.last_by = &"knight"
	game.player.invuln = 0.0
	game.horde.hit_player.emit(4.0, game.player.pos + Vector2.RIGHT)
	assert_eq(game.last_hurt.get("enemy"), &"knight", "the Knight's blow is the last for now")
	game.player.invuln = 0.0
	game.player.hp = 3.0


## The killing blow from `source` (Ground or Projectiles), as its step emits it: last_source and last_by first.
func _kill(source: Node, attack: StringName, by: StringName) -> void:
	source.set(&"last_source", attack)
	source.set(&"last_by", by)
	source.hit_player.emit(9.0, game.player.pos + Vector2.LEFT)


func test_each_of_his_attacks_is_named_when_it_kills() -> void:
	var cases := {&"scythe": game_ground, &"eruptions": game_ground, &"dash": game_ground,
		&"blades": game_shots, &"storm": game_shots, &"curse": game_shots}
	for attack: StringName in cases:
		_fight()
		var hurt_before := int(game.boss.stats.hurt_by.get(attack, 0))
		_kill(cases[attack].call(), attack, &"morvath")
		assert_false(game.player.alive(), "%s: he fell" % attack)
		assert_eq(game.last_hurt.get("attack"), attack, "%s: the killing blow is kept" % attack)
		assert_eq(game.defeated_by(), StringName("killer_" + String(attack)), "%s: the screen names it" % attack)
		assert_eq(logged.get("outcome"), "death", "%s: the run is logged as a death" % attack)
		assert_eq(logged.get("defeated_by"), "killer_" + String(attack), "%s: the log names it" % attack)
		assert_eq(logged.last_hurt.attack, String(attack), "%s: and keeps it as the last blow" % attack)
		assert_eq(int(game.boss.stats.hurt_by.get(attack, 0)), hurt_before + 3, "%s: his numbers count the 3 it took" % attack)
		var rooms: Array = logged.get("rooms", [])
		assert_false(rooms.is_empty(), "%s: the rooms are in the log" % attack)
		assert_eq(int(rooms[-1].hurt_by.get(String(attack), 0)), 3, "%s: the room counts the killing blow" % attack)
		assert_eq(int(rooms[-1].hurt_by.get("knight", 0)), 4, "%s: and the Knight's" % attack)


func game_ground() -> Node:
	return game.ground


func game_shots() -> Node:
	return game.projectiles


func test_one_of_his_dead_is_named_by_its_kind() -> void:
	_fight()
	# a skeleton he raised, its own swing
	game.horde.last_by = &"skeleton"
	game.horde.hit_player.emit(9.0, game.player.pos + Vector2.LEFT)
	assert_false(game.player.alive())
	assert_eq(game.last_hurt.get("enemy"), &"skeleton")
	assert_eq(game.defeated_by(), game.horde.def(&"skeleton").name_key, "the screen names the skeleton")
	assert_eq(logged.get("defeated_by"), String(game.horde.def(&"skeleton").name_key))
	assert_gt(int(game.boss.stats.hurt_by.get(&"adds", 0)), 0, "his numbers count it for his dead")


func test_the_end_screen_names_the_killing_blow() -> void:
	_fight()
	_kill(game.ground, &"scythe", &"morvath")
	await wait_seconds(2.0)
	var label := game.ui.find_child("defeated_by", true, false) as Label
	assert_not_null(label, "the end screen opened")
	if label:
		assert_string_contains(label.text, T.t(&"killer_scythe"), "it says the scythe, not the Knight")
