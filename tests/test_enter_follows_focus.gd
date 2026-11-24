extends GutTest
## UI review 2026-11-24b, B1: the Enter chip says what Enter does now (the Videira's reason, the focused way).


func _vine(silver: int) -> VineScreen:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	var s := VineScreen.new()
	add_child_autofree(s)
	s.open(d)
	return s


func test_the_vine_chip_says_water_only_when_it_can() -> void:
	var s := _vine(30)
	assert_eq(s.bar.item(&"ui_accept").verb.text, T.t(&"bar_water").to_upper())
	var poor := _vine(0)
	assert_true(poor.water_button.disabled)
	assert_eq(poor.bar.item(&"ui_accept").verb.text, poor.water_button.text.to_upper(), "the reason, not Regar")


func test_an_entry_follows_the_focused_button_and_comes_back() -> void:
	var root := Control.new()
	add_child_autofree(root)
	var a := Button.new()
	var b := Button.new()
	root.add_child(a)
	root.add_child(b)
	var bar := ActionBar.attach(root, [ActionBar.entry(&"ui_accept", T.t(&"bar_confirm"))])
	var enter := bar.item(&"ui_accept")
	enter.follow(b, T.t(&"bar_descend"))
	b.grab_focus()
	assert_eq(enter.verb.text, T.t(&"bar_descend").to_upper())
	a.grab_focus()
	assert_eq(enter.verb.text, T.t(&"bar_confirm").to_upper())
