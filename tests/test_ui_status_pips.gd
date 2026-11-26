extends GutTest
## UI-S1: the statuses shown as pips over an enemy's bar. UI-S2: a card from another angel's family says so.


func test_status_pips_follow_the_enemy_state() -> void:
	var e := Enemy.new()
	assert_eq(Horde.status_pips(e).size(), 0)
	e.burn_t = 1.0
	e.weak_t = 1.0
	e.mark_t = 1.0
	assert_eq(Array(Horde.status_pips(e)), [0, 2, 3])
	e.slow_t = 0.5
	assert_eq(Array(Horde.status_pips(e)), [0, 1, 2, 3])


func test_frost_pip_shows_for_frozen_and_cold_slow() -> void:
	var e := Enemy.new()
	e.frozen_t = 1.0
	assert_eq(Array(Horde.status_pips(e)), [1])
	e.frozen_t = 0.0
	e.cold_slow = 0.2
	assert_eq(Array(Horde.status_pips(e)), [1])


func test_guest_card_caption_names_the_other_family() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	var b: Boon = st.catalog[0]
	var card := BoonCard.new()
	card.listed = true
	card.guest_of_family = true
	add_child_autofree(card)
	card.setup(b, Boon.Rarity.COMMON, 0, [] as Array[Boon], null, "x")
	assert_string_contains(_all_text(card), "De outro anjo")


func _all_text(n: Node) -> String:
	var s := ""
	if n is Label:
		s += (n as Label).text
	elif n is RichTextLabel:
		s += (n as RichTextLabel).text
	for c in n.get_children():
		s += " " + _all_text(c)
	return s
