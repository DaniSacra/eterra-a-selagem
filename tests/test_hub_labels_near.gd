extends GutTest
## Hub station names show only near the hero (fade by distance to the use point) and --no-hud hides them and the purse.


func _hub() -> Hub:
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


func test_alpha_by_distance() -> void:
	assert_eq(HubLabels.name_alpha(0.0), 1.0)
	assert_eq(HubLabels.name_alpha(HubPlan.FOCUS_IN + HubLabels.NAME_FULL), 1.0)
	assert_eq(HubLabels.name_alpha(HubPlan.FOCUS_IN + HubLabels.NAME_REACH), 0.0)
	assert_gt(HubLabels.name_alpha(HubPlan.FOCUS_IN + 2.5), 0.0)
	assert_lt(HubLabels.name_alpha(HubPlan.FOCUS_IN + 2.5), 1.0)
	assert_gt(HubLabels.NAME_FULL, 0.0, "fully shown a little before the focus line")


func test_hidden_far_shown_near() -> void:
	var hub := _hub()
	var labels := hub.find_child("HubLabels", true, false) as HubLabels
	var id := HubPlan.SMITH
	hub.player.pos = Vector2(1000, 1000)
	await wait_process_frames(3)
	assert_false((labels.names[id] as Label).visible, "far: hidden")
	hub.player.pos = HubPlan.use_point(id) + Vector2(3.0, 0.0)
	await wait_process_frames(3)
	assert_true((labels.names[id] as Label).visible, "near: shown")
	assert_gt((labels.names[id] as Label).modulate.a, 0.0)


func test_no_hud_hides_names_and_purse() -> void:
	Dev.put("no-hud")
	var hub := _hub()
	var labels := hub.find_child("HubLabels", true, false) as HubLabels
	hub.player.pos = HubPlan.use_point(HubPlan.SMITH) + Vector2(3.0, 0.0)
	await wait_process_frames(3)
	var none := labels.shown().is_empty()
	var purse := labels.purse.visible
	Dev.drop("no-hud")
	assert_true(none, "no names")
	assert_false(purse, "no counters")
