class_name Enemy
extends RefCounted
## A light enemy record. No node, no physics body: Horde moves all of them in one loop and CrowdRenderer draws them.
## pos is (x, z) on the floor in meters; y is the height when thrown in the air.

enum State { RISE, WALK, WINDUP, ATTACK, DEAD }

var def: EnemyDef
var pos := Vector2.ZERO
var y := 0.0
var push := Vector2.ZERO
var dir := Vector2.DOWN
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
var slow_t := 0.0
var burn_t := 0.0
var burn_dps := 0.0
var burn_tick := 0.0
var hurt_t := 0.0
var anim: StringName = &"walk"
var anim_t := 0.0
## The direction a lunge or charge was aimed at when it was announced.
var aim := Vector2.DOWN
var side := 1.0
## Free for the behaviour (attack counters, phase).
var memo := 0
## Takes no damage (the boss while it enters or changes phase).
var invulnerable := false
## Seconds since death (the death animation and the dissolve play from it).
var dead_t := 0.0


func helpless() -> bool:
	return frozen_t > 0.0 or stun_t > 0.0 or air_t > 0.0 or state == State.RISE


func height() -> float:
	if air_t <= 0.0:
		return 0.0
	var k := 1.0 - air_t / air_total
	return sin(k * PI) * 3.2


func yaw() -> float:
	return atan2(dir.x, dir.y)
