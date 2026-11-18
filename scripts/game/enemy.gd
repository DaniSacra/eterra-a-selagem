class_name Enemy
extends RefCounted
## A light enemy record. No node, no physics body: Horde moves all of them in one loop and CrowdRenderer draws them.
## pos is (x, z) on the floor in meters; y is the height when thrown in the air.

## RECOVER (E1c): the window after its blow, standing still (EnemyDef.recover_time; last so the numbers of the others stay).
enum State { RISE, WALK, WINDUP, ATTACK, DEAD, RECOVER }

var def: EnemyDef
var pos := Vector2.ZERO
var y := 0.0
var push := Vector2.ZERO
## How deep it stood in the paladin's body when the frame began (Horde.keep_off_target lets it only work its way out).
var was_in_target := 0.0
var dir := Vector2.DOWN
var hp := 1.0
var max_hp := 1.0
## Yellow bar over the life bar (EnemyDef.armor): blows wear it down first.
var armor := 0.0
var max_armor := 0.0
var alive := true
var state := State.WALK
var state_t := 0.0
var cooldown := 0.0
var contact_cd := 0.0
var flash_t := 0.0
## How white the last blow flashed it (1: a strong blow, the body goes pure white for a frame or two).
var flash_power := 1.0
## The last blow landed on armor (drawn as a gleam of old gold on the edges, never the white of a wound).
var absorbed := false
## A number of its own from 0 to 1, for what is only drawn (the phase of a sway, where its dust falls): given in
## the order of spawning, never by the simulation's dice.
var look := 0.0
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
## Only drawn (E1a-3): seconds since the last blow that wounded it (-1: none yet) and the way it pushed (HitRecoil).
var recoil_t := -1.0
var recoil_dir := Vector2.ZERO
## Only drawn (E1c, a boss): the clip drawn last frame and its pose row, and the clip change being faded (the row it
## left, the seconds since; Horde.CLIP_FADE).
var drawn_anim: StringName = &""
var drawn_row := -1
var fade_row := -1
var fade_t := 0.0
## Only drawn (E1c, AUDIT.md P1: the drawing follows the body): its real speed on the floor, smoothed over
## Horde.VEL_SMOOTH (pushes left out), the way the body faces (ZERO: dir; it turns toward where it walks when that is
## far from dir, Horde._face), how far into its walk loop it is (seconds of the clip, at the pace of its real speed),
## the seconds into its attack clip it has reached (held on into the recovery) and the stun its hit pose is stretched
## over (Horde.flinch).
var vel := Vector2.ZERO
var face := Vector2.ZERO
var walk_phase := 0.0
var walking := false
var blow_t := 0.0
var stun_len := 0.0
## The push applied this step (left out of vel).
var pushed := Vector2.ZERO
## A wind-up of its was cut: once the stun is over it waits Horde.REARM before another (AUDIT.md P5).
var rearm := false
var anim: StringName = &"walk"
var anim_t := 0.0
## The direction a lunge or charge was aimed at when it was announced.
var aim := Vector2.DOWN
var side := 1.0
## Seconds it has kept to its side while waiting (Horde._wait_ring).
var side_t := 0.0
## Walking back to that ring (off it by more than Horde.RING_SLACK), until it is there.
var to_ring := false
## Only drawn (T5-10): its body turned to where it walks (Horde._drawn_motion), until that is near where it looks.
var face_walk := false
## The warning on the floor of the attack it is winding up or loosing (null: none): a blow that cuts the attack ends
## it (Horde.interrupt, GF-12). A Ground.Zone, kept untyped: Enemy is read by pure scripts (tools/make_data.gd) that
## must not compile the game's nodes.
var warning: RefCounted
## Free for the behaviour (attack counters, phase).
var memo := 0
## T5-08, T5-09 (docs/design/combat_cadence.md 6.3): the blow of its attack under way has landed (once an attack);
## meters of its lunge still to cover (the soldier's pounce, announced with its warning); seconds into its attack at
## which its blow lands (its warning fills until then).
var landed := false
var travel := 0.0
var strike_t := 0.0
## T5-12: the clip its recovery plays (&"": the rest of its blow), then its guard.
var recover_anim: StringName = &""
## Only drawn (T5-10): seconds its real speed has stayed on the other side of the walk's threshold (the drawing
## changes between standing and walking only after Horde.STAND_AFTER, WALK_AFTER), and the seconds of the fade of
## its clip change now (0: Horde.CLIP_FADE).
var switch_t := 0.0
var fade_len := 0.0
## Only drawn (T5-13): the shot of its burst whose throw is drawn (each one starts its own).
var drawn_tick := 0
## Only drawn (T5-15): meters its body trembles from side to side now (a boss's hold; the crowd's is EnemyDef.windup_shake).
var shake := 0.0
## Seconds a ranged enemy still runs from the paladin after its attack (EnemyDef.retreat_time).
var retreat_t := 0.0
## T5-20: the way it runs from the paladin, turned this many radians from straight away (Horde.flee_dir's candidate),
## kept for flee_hold more seconds unless it gets blocked; and, only drawn, for run_t more seconds its body faces where
## it really moves (smoothed, Horde._drawn_motion: it runs on its own), never the raw direction of this frame.
var flee_turn := 0.0
var flee_hold := 0.0
var run_t := 0.0
## Only drawn (T5-10): seconds its body has wanted to change between facing its aim and facing where it walks.
var face_t := 0.0
## Takes no damage (a boss behind its ritual's shield).
var invulnerable := false
## Life it cannot drop under (a boss stops at the threshold of its next phase; 0: none).
var hp_floor := 0.0
## Seconds since death (the death animation and the dissolve play from it).
var dead_t := 0.0
## A killing blow throws the body: upward speed and how hard it tumbles (0 when it just falls).
var vy := 0.0
var spin := 0.0
## Where it stood when this frame's step began (Horde: its move is swept from there, Arena.sweep).
var last_pos := Vector2.ZERO
## The way it walks toward the paladin (Horde._way: straight, or along the arena's FlowField round what blocks), kept
## way_t seconds more; straight: the way is the straight line, read fresh each frame.
var way := Vector2.ZERO
var way_t := 0.0
var straight := true
## Where it stood when it last moved half a meter, and how long ago (Horde: an enemy that wants to come and cannot is
## stuck past Horde.STUCK_TIME; counted once).
var anchor := Vector2.ZERO
var anchor_t := 0.0
var stuck := false


func helpless() -> bool:
	return frozen_t > 0.0 or stun_t > 0.0 or air_t > 0.0 or state == State.RISE


func height() -> float:
	if air_t <= 0.0:
		return 0.0
	var k := 1.0 - air_t / air_total
	return sin(k * PI) * 3.2


## Which way the body is drawn facing (radians round Y): `face`, else `dir`.
func yaw() -> float:
	var f := face if face != Vector2.ZERO else dir
	return atan2(f.x, f.y)
