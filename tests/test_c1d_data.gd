extends GutTest
## C1d lote 1: the guardians' and the king's new data load, default off, and the F8 rule stays.

func test_enemy_def_fields_default_off() -> void:
	var d := EnemyDef.new()
	assert_eq(d.guard_up_time, 0.0)
	assert_eq(d.ward_open, 0.0)
	assert_eq(d.wall_stun, 0.0)
	assert_gte(d.guard_up_windup, 0.6, "a new warning is 0.6 s or more")


func test_boss_def_posture_fields() -> void:
	var b := BossDef.new()
	assert_eq(b.posture, 0.0)
	assert_gt(b.posture_stun, 0.0)
	assert_gt(b.posture_vuln, 0.0)
	assert_gt(b.posture_mult, 0.0)


func test_generated_data_carries_them() -> void:
	var k := load("res://data/enemies/knight.tres") as EnemyDef
	assert_not_null(k)
	var m := load("res://data/bosses/morvath.tres") as BossDef
	assert_not_null(m)
	assert_gte(m.posture, 0.0)


func test_f8_common_blow_still_does_not_stun() -> void:
	assert_eq(StunRule.DEFAULT, StunRule.Mode.NONE)
	var rule := StunRule.live
	StunRule.live = StunRule.DEFAULT
	assert_false(StunRule.stuns(false))
	assert_false(StunRule.stuns(true))
	StunRule.live = rule
