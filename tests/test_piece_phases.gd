extends GutTest
## EA-02: every hazard piece reads in three phases (rest, prepare, strike) from one table in GroundLook.


func test_phases_of_state() -> void:
	assert_eq(GroundLook.phase_of(Vector3.ZERO), GroundLook.Phase.REST)
	assert_eq(GroundLook.phase_of(Vector3(0.4, 0, 0)), GroundLook.Phase.PREPARE)
	assert_eq(GroundLook.phase_of(Vector3(0, 0.5, 0)), GroundLook.Phase.STRIKE)


func test_each_piece_climbs_rest_prepare_strike() -> void:
	for piece: StringName in GroundLook.PIECE_LOOK:
		var rest := GroundLook.piece_light(piece, Vector3.ZERO)
		var prep := GroundLook.piece_light(piece, Vector3(1.0, 0, 0))
		var hit := GroundLook.piece_light(piece, Vector3(0, 0.5, 0))
		assert_gt(prep, rest * GroundLook.PIECE_GAP, "%s prepare over rest by 25%%" % piece)
		assert_gt(prep, rest + 0.1, "%s prepare clearly over rest" % piece)
		assert_gt(hit, prep, "%s strike over prepare" % piece)


func test_prepare_ramps_and_falls_back() -> void:
	for piece: StringName in GroundLook.PIECE_LOOK:
		var early := GroundLook.piece_light(piece, Vector3(0.2, 0, 0))
		var late := GroundLook.piece_light(piece, Vector3(0.9, 0, 0))
		assert_gte(late, early, "%s lights as it arms" % piece)
		var back := GroundLook.piece_light(piece, Vector3(0, 0, 0.5))
		assert_lt(back, GroundLook.piece_light(piece, Vector3(0, 0.5, 0)), "%s cools after the strike" % piece)
