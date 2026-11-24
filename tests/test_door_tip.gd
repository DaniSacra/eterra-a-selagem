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
