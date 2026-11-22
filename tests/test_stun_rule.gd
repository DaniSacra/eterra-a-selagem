extends GutTest
## StunRule (experiment, 2026-11-21): which blows stun a common enemy and cut its attack; F8 steps through the rules.

var game: Game


func before_each() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()


func after_each() -> void:
	StunRule.live = StunRule.Mode.ALL


## A skeleton winding up takes one blow under `mode`: true when its attack goes on.
func _goes_on(mode: StunRule.Mode, big: bool, strong := false) -> bool:
	StunRule.live = mode
	var e := game.horde.spawn(game.horde.def(&"skeleton"), game.arena.resolve(Vector2(3, 0), 0.6), false)
	e.state = Enemy.State.WINDUP
	e.hp = 100.0
	game.horde.strong = strong
	game.horde.damage(e, 5.0, Vector2.RIGHT, 1.0, Color.WHITE, false, big)
	game.horde.strong = false
	assert_lt(e.hp, 100.0, "the blow still hurts")
	assert_gte(e.recoil_t, 0.0, "and still shows")
	var on := e.state == Enemy.State.WINDUP and e.stun_t <= 0.0
	e.alive = false
	return on


func test_each_rule() -> void:
	const M := StunRule.Mode
	assert_false(_goes_on(M.ALL, false), "all: a plain blow cuts")
	assert_true(_goes_on(M.STRONG, false), "strong: a plain blow does not")
	assert_false(_goes_on(M.STRONG, true), "strong: the last blow does")
	assert_false(_goes_on(M.STRONG, false, true), "strong: an Omega does")
	assert_true(_goes_on(M.NONE, true), "none: not even the last blow")
	assert_true(_goes_on(M.NONE, true, true))


func test_the_game_opens_on_none_and_f8_steps_through_all() -> void:
	assert_eq(StunRule.DEFAULT, StunRule.Mode.NONE)
	assert_eq(StunRule.from_id("strong"), StunRule.Mode.STRONG)
	assert_eq(StunRule.from_id("x"), StunRule.DEFAULT)
	StunRule.live = StunRule.Mode.NONE
	var seen := {}
	for k in StunRule.IDS.size():
		StunRule.step()
		seen[StunRule.live] = T.t(StunRule.TEXT[StunRule.live])
	assert_eq(seen.size(), 3)
	assert_eq(StunRule.live, StunRule.Mode.NONE, "and comes back")
	assert_true(InputMap.has_action(&"stun_toggle"))
