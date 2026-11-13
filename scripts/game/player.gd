class_name Player
extends Node2D
## The paladin who leads the four. Simple state machine; movement is manual (no physics body).

enum State { MOVE, DODGE, HURT, DEAD }

const SPEED := 74.0
const RADIUS := 5.0
const DODGE_SPEED := 235.0
const DODGE_TIME := 0.2
const DODGE_INVULN := 0.26
const DODGE_RECHARGE := 1.5
const BASE_DODGES := 2
const MAX_HP := 100.0
const HURT_TIME := 0.22
const HURT_INVULN := 0.7

signal dodged(dir: Vector2)
signal died

var arena: Arena
var fx: Fx
var state := State.MOVE
var hp := MAX_HP
var max_hp := MAX_HP
var aim := Vector2.RIGHT
var dodge_max := BASE_DODGES
var dodge_charges := BASE_DODGES
var invuln := 0.0
var _state_t := 0.0
var _recharge_t := 0.0
var _dodge_dir := Vector2.RIGHT
var _sprite: AnimatedSprite2D
var _light: PointLight2D


func _ready() -> void:
	_sprite = Art.animated(&"paladin")
	add_child(_sprite)
	_sprite.play(&"idle")
	_light = Arena.make_light(Color(1.0, 0.93, 0.75), 84.0, 0.5)
	_light.position = Vector2(0, -8)
	add_child(_light)


func step(dt: float, aim_dir: Vector2) -> void:
	aim = aim_dir
	invuln = maxf(0.0, invuln - dt)
	_state_t += dt
	_recharge(dt)
	match state:
		State.MOVE:
			_step_move(dt)
		State.DODGE:
			_step_dodge(dt)
		State.HURT:
			if _state_t >= HURT_TIME:
				_enter(State.MOVE)
	_sprite.visible = invuln <= 0.0 or state == State.DODGE or fmod(invuln, 0.12) > 0.05


func _step_move(dt: float) -> void:
	var move := Controls.move()
	if Controls.pressed(&"dodge") and try_dodge(move):
		return
	_walk(move, dt)
	_face(aim.x)
	_play(&"run" if move.length() > 0.1 else &"idle")


func _walk(move: Vector2, dt: float, factor: float = 1.0) -> void:
	position = arena.resolve(position + move * SPEED * factor * dt, RADIUS)


func try_dodge(move: Vector2) -> bool:
	if dodge_charges <= 0:
		return false
	dodge_charges -= 1
	_dodge_dir = move.normalized() if move.length() > 0.1 else aim
	invuln = maxf(invuln, DODGE_INVULN)
	_enter(State.DODGE)
	_face(_dodge_dir.x)
	_play(&"dodge")
	fx.burst(&"dust", position, -_dodge_dir)
	Audio.play(&"dodge")
	dodged.emit(_dodge_dir)
	return true


func _step_dodge(dt: float) -> void:
	position = arena.resolve(position + _dodge_dir * DODGE_SPEED * dt, RADIUS)
	if _state_t >= DODGE_TIME:
		fx.burst(&"dust", position, _dodge_dir)
		_enter(State.MOVE)


func _recharge(dt: float) -> void:
	if dodge_charges >= dodge_max:
		_recharge_t = 0.0
		return
	_recharge_t += dt
	if _recharge_t >= DODGE_RECHARGE:
		_recharge_t = 0.0
		dodge_charges += 1


## Fraction of the next dodge charge already recovered (for the HUD).
func recharge_ratio() -> float:
	return _recharge_t / DODGE_RECHARGE


## Damage from an enemy. Returns true when it landed (not dodged, not invulnerable).
func hurt(amount: float, from: Vector2) -> bool:
	if invuln > 0.0 or state == State.DEAD:
		return false
	hp = maxf(0.0, hp - amount)
	invuln = HURT_INVULN
	fx.shake(3.0)
	fx.hit_stop(60)
	Audio.play(&"hurt")
	if hp <= 0.0:
		_enter(State.DEAD)
		_play(&"death")
		died.emit()
		return true
	position = arena.resolve(position + (position - from).normalized() * 4.0, RADIUS)
	_enter(State.HURT)
	_play(&"hurt")
	return true


func heal(amount: float) -> void:
	hp = minf(max_hp, hp + amount)


func _enter(next: State) -> void:
	state = next
	_state_t = 0.0


func _face(x: float) -> void:
	if absf(x) > 0.05:
		_sprite.flip_h = x < 0.0


func _play(anim: StringName, speed: float = 1.0) -> void:
	_sprite.speed_scale = speed
	if _sprite.animation != anim:
		_sprite.play(anim)
