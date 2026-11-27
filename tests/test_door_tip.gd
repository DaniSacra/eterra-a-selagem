extends GutTest
## PT-10: what the box beside a door says (DoorTip.describe), the seal ids and the ring's easing.

func _room(kind: RunMap.Kind, reward: RunMap.Reward) -> RunMap.Room:
	return RunMap.Room.new(kind, reward, 1, -1)


func test_plain_reward_has_title_and_no_modifier() -> void:
	var d := DoorTip.describe(_room(RunMap.Kind.COMBAT, RunMap.Reward.BOON))
	assert_true(String(d.title).begins_with("Recompensa"))
	assert_true((d.mods as Array).is_empty())


func test_guardian_door_names_the_guardian_modifier() -> void:
	var d := DoorTip.describe(_room(RunMap.Kind.MINIBOSS, RunMap.Reward.BOON))
	assert_eq(d.mods[0].id, &"guardian")


func test_angel_door_carries_its_family() -> void:
	var r := _room(RunMap.Kind.COMBAT, RunMap.Reward.BOON)
	r.angel = &"seraphiel"
	var d := DoorTip.describe(r, 0, Boon.Family.LUZ)
	var ids: Array = []
	for m: Dictionary in d.mods:
		ids.append(m.id)
	assert_has(ids, &"angel")


func test_meeting_says_two_angels() -> void:
	var r := _room(RunMap.Kind.COMBAT, RunMap.Reward.BOON)
	r.meeting = true
	var d := DoorTip.describe(r)
	assert_eq(d.mods[0].family, Boon.Family.DUO)


func test_ring_eases_toward_target() -> void:
	var ring := DoorRing.make(0, Color.WHITE, 1.0)
	add_child_autofree(ring)
	ring.target = 1.0
	ring._process(0.05)
	assert_gt(ring.near, 0.0)
	assert_lt(ring.near, 1.0)
	ring._process(1.0)
	assert_eq(ring.near, 1.0)


## Daniel 2026-11-23: the box showed 4 m from the door while F only worked at it. It follows the interact's own test.
func test_the_box_shows_only_where_the_key_enters() -> void:
	var a := Arena.new()
	autofree(a)
	a.exits = [Vector2(-8.5, -34.0), Vector2(8.5, -34.0)] as Array[Vector2]
	var at_door := Vector2(8.5, -33.0)
	var four_m_off := Vector2(8.5, -29.0)
	assert_eq(DoorTip.door_at(a, at_door, 2), a.exit_at(at_door), "at the door")
	assert_eq(DoorTip.door_at(a, at_door, 2), 1)
	assert_eq(DoorTip.door_at(a, four_m_off, 2), a.exit_at(four_m_off), "same answer as the key's test")
	assert_eq(DoorTip.door_at(a, four_m_off, 2), -1, "close but not at it: no box")
	assert_eq(DoorTip.door_at(a, at_door, 1), -1, "a door that is not open")


## U-1: nothing before the doors open and nothing farther than TIP_RANGE from the door.
func test_the_tip_needs_open_doors_and_the_hero_close() -> void:
	assert_false(DoorTip.tip_allowed(false, 1.0), "doors still shut (before door_open)")
	assert_true(DoorTip.tip_allowed(true, DoorTip.TIP_RANGE - 0.1))
	assert_false(DoorTip.tip_allowed(true, DoorTip.TIP_RANGE + 0.1), "too far")


## BG-2: the Provação's box does not repeat the sign's word and has no badge on the medallion.
func test_the_trial_door_box_says_what_it_gives() -> void:
	var d := DoorTip.describe(_room(RunMap.Kind.TRIAL, RunMap.Reward.NONE))
	assert_ne(d.title, T.t(&"room_trial"))
	assert_eq(d.title, T.t(&"trial_slab_offer"))


## GP-2: the Abertura's dots read the boss's meters and the window.
func test_opening_dots_read_the_meters() -> void:
	var st := CelState.new()
	st.meter_c = 3
	st.meter_i = 99
	var r := OpeningDots.read(st, CelRules.METER_COLD, CelRules.METER_IMPACT)
	assert_eq(r.cold, 3)
	assert_eq(r.impact, CelRules.METER_IMPACT, "never past the meter")
	assert_eq(OpeningDots.read(null, 8, 10).cold, 0)
	var dots := OpeningDots.new()
	add_child_autofree(dots)
	assert_false(dots.shown(), "nothing permanent")
	dots.show_state(st, 8, 10)
	assert_true(dots.shown())
