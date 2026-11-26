extends GutTest
## Lote U of the 2026-11-25 round: controls lines read from the bindings (U-2), the Warrior's quiet Magia (U-3) and the
## shooter arrows (U-5).


func test_controls_lines_have_no_fixed_names() -> void:
	for pad: bool in [false, true]:
		var line := UiKit.controls_line(pad)
		assert_false(line.contains("{"), "every name filled: " + line)
		assert_false(line.to_lower().contains("ultimate"), line)
		assert_false(line.contains("Ômega"), line)
		assert_false(line.contains("—"), line)
		for a: StringName in [&"light_attack", &"heavy_attack", &"dodge", &"ultimate", &"interact"]:
			assert_string_contains(line, UiKit.bound_name(a, pad), "%s in %s" % [a, "pad" if pad else "keys"])


func test_the_pad_line_follows_a_rebound_button() -> void:
	assert_eq(UiKit.bound_name(&"interact", true), "A", "the default (GP-1: interact on A)")
	assert_eq(UiKit.bound_name(&"ultimate", false), "Shift")


func test_the_thin_magick_wakes_when_it_moves_or_its_button_is_held() -> void:
	assert_false(Hud.magick_wakes(20.0, 20.0, false), "still")
	assert_false(Hud.magick_wakes(-1.0, 20.0, false), "first look")
	assert_true(Hud.magick_wakes(20.0, 21.5, false), "rose")
	assert_true(Hud.magick_wakes(20.0, 8.0, false), "spent")
	assert_true(Hud.magick_wakes(20.0, 20.0, true), "held")


func _enemy(b: EnemyDef.Behavior, state: Enemy.State, t: float) -> Enemy:
	var e := Enemy.new()
	e.def = EnemyDef.new()
	e.def.behavior = b
	e.def.attack_windup = 1.4
	e.state = state
	e.state_t = t
	return e


func test_the_arrow_is_for_a_shooter_a_second_before_its_shot() -> void:
	assert_false(Hud.shooter_warning(_enemy(EnemyDef.Behavior.ARCHER, Enemy.State.WINDUP, 0.1)), "too early")
	assert_true(Hud.shooter_warning(_enemy(EnemyDef.Behavior.ARCHER, Enemy.State.WINDUP, 0.5)), "within 1 s")
	assert_false(Hud.shooter_warning(_enemy(EnemyDef.Behavior.ARCHER, Enemy.State.WALK, 0.5)), "not winding up")
	assert_false(Hud.shooter_warning(_enemy(EnemyDef.Behavior.CHASE, Enemy.State.WINDUP, 0.5)), "a melee enemy")
	var dead := _enemy(EnemyDef.Behavior.PRIEST, Enemy.State.WINDUP, 0.5)
	dead.alive = false
	assert_false(Hud.shooter_warning(dead))
