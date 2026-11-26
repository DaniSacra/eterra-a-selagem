extends GutTest
## SW-O2 and its neighbours (lote 3A3): the objective line (Objective.pick, enabled, the words with the real keys), the
## guided descent's tips (FirstTips), the question pages (AskPage), skipping the first descent (FirstTips.mark_skipped,
## the save choice's question) and the hidden fifth diamond's gate. No stub is needed: every call of another lote
## (FirstDescent.active, Milestones.ult_open) is behind a file-exists guard and the tests use the fallbacks.

var _pad := false


func before_each() -> void:
	_pad = Controls.using_pad


func after_each() -> void:
	Controls.using_pad = _pad


# ---------- Objective.pick: one case per key ----------

func test_one_case_per_key() -> void:
	var cases := {
		&"obj_explore": {"kind": &"ante"},
		&"obj_dodge": {"kind": &"ante", "near_plates": true},
		&"obj_break": {"kind": &"ante", "near_breakable": true},
		&"obj_find_way": {"kind": &"ante", "crossed_plates": true},
		&"obj_win": {"kind": &"combat", "fighting": true},
		&"obj_take": {"kind": &"combat", "reward_waiting": true},
		&"obj_bless": {"kind": &"combat", "screen": &"boon"},
		&"obj_door": {"kind": &"combat", "doors_open": 2, "first_choice": true},
		&"obj_guardian": {"kind": &"miniboss", "fighting": true},
		&"obj_shop": {"kind": &"shop", "doors_open": 1},
		&"obj_morvath": {"kind": &"boss", "fighting": true},
		&"obj_hub_tree": {"place": &"hub", "hub_new_station": true},
		&"obj_hub_portal": {"place": &"hub"},
		&"lesson_attack": {"kind": &"ante", "lesson": &"lesson_attack"},
		&"lesson_special": {"kind": &"ante", "lesson": &"lesson_special"},
		&"lesson_dodge": {"kind": &"ante", "lesson": &"lesson_dodge"},
		&"lesson_shout": {"kind": &"ante", "lesson": &"lesson_shout"},
		&"lesson_rush": {"kind": &"ante", "lesson": &"lesson_rush"},
	}
	assert_eq(cases.size(), Objective.KEYS.size(), "every key has a case")
	for key: StringName in cases:
		assert_eq(Objective.pick(cases[key]), key, "%s" % key)


func test_find_way_after_a_won_room_with_open_doors() -> void:
	assert_eq(Objective.pick({"kind": &"combat", "doors_open": 1}), &"obj_find_way")
	assert_eq(Objective.pick({"kind": &"combat", "doors_open": 2}), &"obj_find_way", "two doors but not the first choice")
	assert_eq(Objective.pick({"kind": &"combat"}), &"", "nothing to say")


func test_the_anteroom_goes_slabs_then_vase_then_way() -> void:
	assert_eq(Objective.pick({"kind": &"ante", "near_plates": true, "near_breakable": true}), &"obj_dodge")
	assert_eq(Objective.pick({"kind": &"ante", "near_breakable": true, "broke_one": true}), &"obj_explore", "vase already broken")
	assert_eq(Objective.pick({"kind": &"ante", "near_plates": true, "crossed_plates": true}), &"obj_find_way", "slabs behind")


# ---------- precedence ----------

func test_an_open_screen_hides_the_line() -> void:
	assert_eq(Objective.pick({"kind": &"combat", "fighting": true, "screen": &"other"}), &"")
	assert_eq(Objective.pick({"kind": &"boss", "screen": &"other"}), &"")
	assert_eq(Objective.pick({"place": &"hub", "screen": &"other"}), &"")


func test_the_fight_beats_exploring_and_the_reward_beats_the_doors() -> void:
	assert_eq(Objective.pick({"kind": &"ante", "fighting": true}), &"obj_win")
	assert_eq(Objective.pick({"kind": &"combat", "reward_waiting": true, "doors_open": 2, "first_choice": true}), &"obj_take")
	assert_eq(Objective.pick({"kind": &"combat", "fighting": true, "reward_waiting": true}), &"obj_win")


func test_the_guardian_and_morvath_name_their_rooms() -> void:
	assert_eq(Objective.pick({"kind": &"miniboss"}), &"obj_guardian", "before the fight starts")
	assert_eq(Objective.pick({"kind": &"miniboss", "reward_waiting": true}), &"obj_take", "won")
	assert_eq(Objective.pick({"kind": &"boss"}), &"obj_morvath")


func test_the_hub_says_portal_when_nothing_new_waits() -> void:
	assert_eq(Objective.pick({"place": &"hub", "hub_new_station": false}), &"obj_hub_portal")


# ---------- enabled ----------

func test_enabled_in_the_tutorial_and_the_next_descents() -> void:
	assert_true(Objective.enabled({"runs": 0}, true), "the tutorial")
	assert_true(Objective.enabled({"runs": 99, "options": {"objective": false}}, true), "the tutorial ignores the option")
	assert_true(Objective.enabled({"runs": 1}, false))
	assert_true(Objective.enabled({"runs": 3, "options": {"objective": true}}, false))
	assert_false(Objective.enabled({"runs": 4}, false), "off from the fourth")
	assert_false(Objective.enabled({"runs": 1, "options": {"objective": false}}, false), "the option off")
	assert_true(Objective.enabled({"runs": 1, "options": {}}, false), "a save without the key reads it on")


# ---------- the words ----------

func test_every_key_has_its_text_without_a_dash() -> void:
	for key in Objective.KEYS:
		var raw := T.t(key)
		assert_ne(raw, String(key), "%s has a text" % key)
		assert_false(raw.contains("—") or raw.contains("–"), "%s has no dash" % key)
	for key: String in ["opt_objective", "opt_objective_tip", "arrival_line", "first_end_1", "first_end_2", "first_done",
			"first_tip_fight", "first_tip_archer", "first_tip_hold", "first_tip_armor", "first_tip_knight", "pause_skip_first",
			"pause_skip_confirm", "pause_skip_yes", "pause_skip_no", "slot_first_ask", "slot_first_line", "slot_first_yes",
			"slot_first_skip", "hub_open_ult", "guide_ult"]:
		assert_true(T.table.entries.has(key), key)
		assert_false(String(T.table.entries[key]).contains("—"), "%s has no dash" % key)


func test_the_keys_in_the_words_are_the_real_bindings() -> void:
	Controls.using_pad = false
	var kb := Objective.text(&"obj_dodge")
	assert_false(kb.contains("{"), "filled in")
	assert_true(kb.contains(UiKit.action_label(&"dodge")))
	assert_true(Objective.text(&"obj_break").contains(UiKit.action_label(&"light_attack")))
	assert_true(Objective.text(&"obj_take").contains(UiKit.action_label(&"interact")))
	Controls.using_pad = true
	var pad := Objective.text(&"obj_dodge")
	assert_false(pad.contains("{"))
	assert_true(pad.contains(UiKit.action_label(&"dodge")))
	assert_ne(Objective.text(&""), "x", "an empty key has no words")
	assert_eq(Objective.text(&""), "")


# ---------- the guided descent's tips ----------

func test_the_fight_tip_does_not_show_in_the_tutorial_but_the_hold_one_does() -> void:
	var data := {"runs": 0}
	var ctx := {"fighting": true, "fight_t": FirstTips.HOLD_AFTER + 1.0, "tutorial": true}
	assert_eq(FirstTips.pick(data, ctx), &"hold")
	ctx.tutorial = false
	assert_eq(FirstTips.pick(data, ctx), &"fight", "a normal first descent still has it")


func test_skipping_marks_first_as_two_and_never_downgrades() -> void:
	var data := {"first": 0}
	FirstTips.mark_skipped(data)
	assert_eq(data.first, 2)
	var done := {"first": 1}
	FirstTips.mark_skipped(done)
	assert_eq(done.first, 1, "a done descent stays done")
	var old := {}
	FirstTips.mark_skipped(old)
	assert_eq(old.first, 2, "a save without the field is pending")


# ---------- the screens ----------

func test_the_line_changes_key_and_hides() -> void:
	var line := ObjectiveLine.new()
	add_child_autofree(line)
	await wait_process_frames(2)
	line.set_key(&"obj_explore")
	assert_eq(line.key, &"obj_explore")
	await wait_seconds(ObjectiveLine.OUT + ObjectiveLine.IN + 0.2)
	assert_eq(line.find_children("*", "RichTextLabel", false, false)[0].text, T.t(&"obj_explore"))
	assert_almost_eq(line.modulate.a, 1.0, 0.05)
	line.set_key(&"")
	assert_eq(line.key, &"")


func test_the_caption_shows_and_clears() -> void:
	var caption := ArrivalCaption.new()
	add_child_autofree(caption)
	await wait_process_frames(2)
	caption.show_line(&"arrival_line", ArrivalCaption.SKIPPED)
	assert_eq(caption.key, &"arrival_line")
	await wait_seconds(ArrivalCaption.IN + 0.1)
	assert_gt((caption.find_children("*", "Label", false, false)[0] as Label).modulate.a, 0.9)
	caption.clear()
	assert_eq(caption.key, &"")


func test_the_question_page_answers_once() -> void:
	var q := AskPage.new().setup("t", "l", "Sim", "Não")
	add_child_autofree(q)
	await wait_process_frames(2)
	watch_signals(q)
	assert_not_null(q.yes)
	q.no.pressed.emit()
	q.yes.pressed.emit()
	assert_signal_emit_count(q, "answered", 1)
	assert_signal_emitted_with_parameters(q, "answered", [false])


func test_the_save_choice_asks_only_for_a_new_save_when_another_has_descents() -> void:
	var dir := "user://test_objective_slots/"
	DirAccess.make_dir_recursive_absolute(dir)
	for n in range(1, SaveSlots.COUNT + 1):
		SaveSlots.erase(n, dir)
	assert_false(SaveSlotScreen.needs_first_ask(1, dir), "no save yet")
	var played := SaveData.defaults()
	played["runs"] = 2
	var f := FileAccess.open(SaveSlots.path(2, dir), FileAccess.WRITE)
	f.store_string(JSON.stringify(played))
	f.close()
	assert_true(SaveSlotScreen.needs_first_ask(1, dir), "a new save beside a played one asks")
	assert_false(SaveSlotScreen.needs_first_ask(2, dir), "an existing save does not")
	for n in range(1, SaveSlots.COUNT + 1):
		SaveSlots.erase(n, dir)
	DirAccess.remove_absolute(dir)


func test_the_fifth_diamond_is_open_without_a_save_or_the_milestones_file() -> void:
	assert_true(Hud.ult_open(), "tests run without a save")


## Sweep 2026-11-25, P1-2: Morvath line goes with the victory: the reward and the doors speak then.
func test_morvath_is_asked_before_the_fight_and_in_it_never_after_the_victory() -> void:
	assert_eq(Objective.pick({"kind": &"boss"}), &"obj_morvath", "before the fight")
	assert_eq(Objective.pick({"kind": &"boss", "fighting": true}), &"obj_morvath", "in it")
	assert_eq(Objective.pick({"kind": &"boss", "reward_waiting": true}), &"obj_take", "the reward waits")
	assert_eq(Objective.pick({"kind": &"boss", "doors_open": 1}), &"obj_find_way", "a door is open")
