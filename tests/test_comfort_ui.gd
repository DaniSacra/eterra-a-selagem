extends GutTest
## Cycle 10, interface: the comfort options (QW-002), the edge tint of a blow taken (BUG-007), the ritual's count on
## the boss's bar (QW-005), "Derrotado por" on the defeat (QW-003) and no new best without a save (BUG-008).

var _saving := true
var _options := {}


func before_each() -> void:
	# nothing a test changes reaches the player's save
	_saving = Save.enabled
	Save.enabled = false
	_options = Save.data.options.duplicate(true)


func after_each() -> void:
	Save.data.options = _options
	Save.enabled = _saving
	Engine.time_scale = 1.0


# ---------- the edge tint of a blow taken (BUG-007) ----------

func test_a_cursed_blow_tints_violet_weakly_and_briefly_with_no_split() -> void:
	var feel := Feel.live()
	var t := HurtTint.new()
	var split := t.hit(25.0, true, feel)
	assert_eq(split, 0.0, "no colour split under the curse")
	assert_eq(t.red, 0.0, "no red under the curse")
	assert_almost_eq(t.violet, feel.curse_tint, 0.001)
	assert_lte(feel.curse_tint, 0.2, "alpha 0.2 at most")
	assert_lte(feel.curse_tint_time, 0.2, "0.2 s at most")
	t.step(feel.curse_tint_time + 0.001, feel)
	assert_eq(t.violet, 0.0, "gone after its time")


func test_a_plain_blow_tints_the_edges_red_shortly_small_ones_less() -> void:
	var feel := Feel.live()
	var t := HurtTint.new()
	assert_eq(t.hit(feel.hurt_tint_heavy - 1.0, false, feel), 0.0, "a small blow splits nothing")
	var small := t.red
	assert_gt(small, 0.0)
	t.step(1.0, feel)
	assert_eq(t.red, 0.0)
	assert_gt(t.hit(feel.hurt_tint_heavy, false, feel), 0.0, "a heavy blow splits a little")
	assert_gt(t.red, small)
	assert_lte(t.red, 0.45, "discreet: never the old 0.75")
	assert_lte(feel.hurt_split, 0.5)
	t.step(feel.hurt_tint_time + 0.001, feel)
	assert_eq(t.red, 0.0, "short")


# ---------- the comfort options (QW-002) ----------

func test_comfort_options_are_on_by_default_and_kept_from_older_saves() -> void:
	for key: String in OptionsScreen.COMFORT:
		assert_true(SaveData.defaults().options[key], "%s on by default" % key)
		assert_true(SaveData.merged({"options": {"master": 0.5}}).options[key], "%s on for an older save" % key)
		assert_false(SaveData.merged({"options": {key: false}}).options[key], "%s kept off" % key)
		assert_ne(T.t("opt_" + key), "opt_" + key, "%s has a text" % key)


func test_slow_motion_off_keeps_the_world_at_full_speed() -> void:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.slow_motion = false
	fx.slow_mo(0.3, 1.0, 0.5, 1.1, 0.8)
	fx.tick(0.1)
	assert_eq(Engine.time_scale, 1.0)
	assert_eq(fx.radial, 0.0, "no radial blur")
	assert_eq(fx.zoom, 1.0, "no zoom")
	fx.slow_motion = true
	fx.slow_mo(0.3, 1.0, 0.5, 1.1, 0.8)
	fx.tick(0.1)
	assert_lt(Engine.time_scale, 1.0, "on, it slows")
	fx.end_slow()


func test_colour_split_off_never_splits() -> void:
	var fx := Fx.new()
	add_child_autofree(fx)
	fx.color_split = false
	fx.kick_split(1.0)
	assert_eq(fx.split, 0.0)
	fx.color_split = true
	fx.kick_split(1.0)
	assert_eq(fx.split, 1.0)


func test_each_comfort_switch_is_a_button_that_flips_its_option() -> void:
	var screen := OptionsScreen.new()
	add_child_autofree(screen)
	screen.open()
	await wait_process_frames(2)
	for key: String in OptionsScreen.COMFORT:
		var before: bool = Save.option(key)
		var b := screen.find_child("opt_" + key, true, false) as Button
		assert_not_null(b, "%s has its row" % key)
		assert_eq(b.focus_mode, Control.FOCUS_ALL, "%s takes keyboard and gamepad focus" % key)
		b.pressed.emit()
		await wait_process_frames(2)
		assert_eq(Save.option(key), not before, "%s flipped" % key)
		var again := screen.find_child("opt_" + key, true, false) as Button
		assert_true(again.has_focus(), "%s keeps the focus after the rebuild" % key)


func test_the_run_reads_the_comfort_options() -> void:
	var game := Game.new()
	game.fx = Fx.new()
	autofree(game)
	autofree(game.fx)
	for key: String in OptionsScreen.COMFORT:
		Save.data.options[key] = false
	game.apply_options()
	assert_eq(game.fx.shake_scale, 0.0)
	assert_false(game.fx.impact_frames)
	assert_false(game.fx.slow_motion)
	assert_false(game.fx.color_split)


# ---------- the ritual's count (QW-005) ----------

func test_ritual_seals_count_down_and_the_fallen_one_flashes() -> void:
	var b := HudBar.new().setup(Color.PURPLE, Vector2(480, 12), 11, true)
	add_child_autofree(b)
	b.show_ritual(4, 4)
	assert_eq(b.ritual_left, 4)
	assert_almost_eq(b.seal_at(0).x + b.seal_at(3).x, 480.0, 0.01, "centred on the bar")
	b.show_ritual(2, 4)
	assert_eq(b.ritual_left, 2)
	assert_gt(b._seal_flash, 0.0, "the one that fell flashes")
	assert_eq(b._seal_flash_at, 2)
	b._process(HudBar.SEAL_FLASH)
	assert_eq(b._seal_flash, 0.0)
	b.show_ritual(9, 4)
	assert_eq(b.ritual_left, 4, "never more than the total")
	b.show_ritual(0, 0)
	assert_eq(b.ritual_total, 0, "hidden outside the ritual")
	assert_ne(T.t(&"ritual_hint"), "ritual_hint")


# ---------- the end screen (QW-003, BUG-008) ----------

func test_defeat_names_what_struck_the_last_blow() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 200.0, "level": 1, "kills": 30, "best_combo": 9, "boons": 4, "defeated_by": &"killer_storm"}, false)
	var by := end.find_child("defeated_by", true, false) as Label
	assert_not_null(by)
	assert_eq(by.text, T.t(&"defeated_by", {"name": T.t(&"killer_storm")}))
	assert_true(by.text.contains(T.t(&"killer_storm")))
	assert_false(by.text.contains("—") or by.text.contains("–"), "no dash")


func test_defeat_without_a_cause_shows_no_line() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 200.0, "level": 1, "kills": 30, "best_combo": 9, "boons": 4}, false)
	assert_null(end.find_child("defeated_by", true, false))


func test_no_new_best_without_a_save() -> void:
	for victory: bool in [true, false]:
		var end := EndScreen.new()
		add_child_autofree(end)
		end.open(victory, {"time": 100.0, "level": 1, "kills": 30, "best_combo": 9, "boons": 4}, true)
		assert_null(end.find_child("new_best", true, false), "victory %s: no record with --nosave" % victory)
	Save.enabled = true
	var won := EndScreen.new()
	add_child_autofree(won)
	won.open(true, {"time": 100.0, "level": 1, "kills": 30, "best_combo": 9, "boons": 4}, true)
	assert_not_null(won.find_child("new_best", true, false), "with a save it shows")
	Save.enabled = false
