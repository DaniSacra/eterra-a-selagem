class_name Enemy
extends RefCounted
## A light enemy record. No node logic, no physics body: EnemySystem moves all of them in one loop.

enum State { RISE, WALK, WINDUP, ATTACK }

var def: EnemyDef
var pos := Vector2.ZERO
var push := Vector2.ZERO
var dir := Vector2.RIGHT
var hp := 1.0
var max_hp := 1.0
var alive := true
var state := State.WALK
var state_t := 0.0
var cooldown := 0.0
var contact_cd := 0.0
var flash_t := 0.0
var frozen_t := 0.0
var stun_t := 0.0
var air_t := 0.0
var air_total := 1.0
var blind_t := 0.0
var burn_t := 0.0
var burn_dps := 0.0
var burn_tick := 0.0
var anim: StringName = &"walk"
var anim_t := 0.0
var sprite: Sprite2D
var variant: StringName = &""
## Id of the last player swing or wave that hit it, so one swing never hits twice.
var hit_mark := 0
var side := 1.0
## Free for the behaviour (attack counters, phase).
var memo := 0
## Takes no damage (the boss while it enters or changes phase).
var invulnerable := false


func helpless() -> bool:
	return frozen_t > 0.0 or stun_t > 0.0 or air_t > 0.0 or state == State.RISE


func height() -> float:
	if air_t <= 0.0:
		return 0.0
	var k := 1.0 - air_t / air_total
	return sin(k * PI) * 16.0
