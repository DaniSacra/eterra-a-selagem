extends GutTest
## O-2 of the C11 QA: in the victory the crack over the lion closes for good, and well before the calm.


func _victory_at(t: float) -> Dictionary:
	var look := SealLook.new()
	look.set_phase(4)
	look.enter(SealLook.State.FINAL)
	look.step(5.0)
	look.enter(SealLook.State.VICTORY)
	var left := t
	while left > 0.0:
		look.step(minf(left, 1.0 / 60.0))
		left -= 1.0 / 60.0
	return look.values()


func test_the_crack_is_open_as_the_victory_begins() -> void:
	var v := _victory_at(0.1)
	assert_lt(float(v[&"crack_heal"]), 0.01)


func test_the_crack_is_shut_before_the_calm_and_stays_shut() -> void:
	# shut with room to spare: even a quarter of a second of slow motion on the seal's clock leaves it closed by then
	var v := _victory_at(SealLook.VICTORY_CALM - 0.25)
	assert_almost_eq(float(v[&"crack_heal"]), 1.0, 0.001, "closed before the calm")
	for t in [SealLook.VICTORY_CALM, SealLook.VICTORY_TIME, SealLook.VICTORY_TIME + 2.0]:
		v = _victory_at(t)
		assert_almost_eq(float(v[&"crack_heal"]), 1.0, 0.001, "still closed at %.1f s" % t)
		assert_lte(float(v[&"veins"]), 0.0, "no vein left at %.1f s" % t)
		assert_almost_eq(float(v[&"violet"]), 0.0, 0.001, "no violet left at %.1f s" % t)
