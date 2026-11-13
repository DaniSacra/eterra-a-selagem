class_name Player
extends Node2D
## The paladin who leads the four. Simple state machine; movement is manual (no physics body).
## Attacks come from the combo tree (data) through a ComboRunner.

enum State { MOVE, ATTACK, CHARGE, DODGE, HURT, DEAD }

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
const CHARGE_WALK := 0.35
const COMBO_TREE := "res://data/combos/paladin.tres"

signal dodged(dir: Vector2)
signal died
signal struck(node: ComboNode, origin: Vector2, dir: Vector2)
signal move_shown(node: ComboNode)
signal shield_broke
signal was_hurt

var arena: Arena
var fx: Fx
var combo: ComboRunner
var state := State.MOVE
var hp := MAX_HP
var max_hp := MAX_HP
var aim := Vector2.RIGHT
var dodge_max := BASE_DODGES
var dodge_charges := BASE_DODGES
var recharge_time := DODGE_RECHARGE
var invuln := 0.0
## Vigília gift: seconds the shield takes to come back (0 = no shield).
var shield_cooldown := 0.0
var shield_ready := false
var _shield_t := 0.0
var _state_t := 0.0
var _recharge_t := 0.0
var _dodge_dir := Vector2.RIGHT
var _attack_dir := Vector2.RIGHT
var _lunge_speed := 0.0
var _charged := false
var _sprite: AnimatedSprite2D
var _light: PointLight2D


func _ready() -> void:
	_sprite = Art.animated(&"paladin")
	add_child(_sprite)
	_sprite.play(&"idle")
	_light = Arena.make_light(Color(1.0, 0.93, 0.75), 84.0, 0.5)
	_light.position = Vector2(0, -8)
	add_child(_light)
	combo = ComboRunner.new(load(COMBO_TREE))
	combo.move_started.connect(_on_move_started)
	combo.move_hit.connect(_on_move_hit)
	combo.move_ended.connect(_on_move_ended)


func step(dt: float, aim_dir: Vector2) -> void:
	aim = aim_dir
	invuln = maxf(0.0, invuln - dt)
	_state_t += dt
	_recharge(dt)
	_step_shield(dt)
	if state != State.DEAD:
		_read_attacks()
		combo.step(dt)
	match state:
		State.MOVE:
			_step_move(dt)
		State.ATTACK:
			_step_attack(dt)
		State.CHARGE:
			_step_charge(dt)
		State.DODGE:
			_step_dodge(dt)
		State.HURT:
			if _state_t >= HURT_TIME:
				_enter(State.MOVE)
	_sprite.visible = invuln <= 0.0 or state == State.DODGE or fmod(invuln, 0.12) > 0.05
	_light.energy = 0.5 + (0.25 if state == State.CHARGE and _charged else 0.0)


func _read_attacks() -> void:
	if state == State.HURT:
		return
	if Controls.pressed(&"light_attack"):
		combo.press(ComboNode.In.LIGHT)
	if Controls.pressed(&"heavy_attack"):
		if state == State.MOVE and combo.charge_available():
			_enter(State.CHARGE)
			_charged = false
		elif state != State.CHARGE:
			combo.press(ComboNode.In.HEAVY)
	if state == State.CHARGE and not Controls.held(&"heavy_attack"):
		_enter(State.MOVE)
		combo.press(ComboNode.In.CHARGE if _charged else ComboNode.In.HEAVY)
		combo.step(0.0)


func _step_move(dt: float) -> void:
	var move := Controls.move()
	if Controls.pressed(&"dodge") and try_dodge(move):
		return
	_walk(move, dt)
	_face(aim.x)
	_play(&"run" if move.length() > 0.1 else &"idle")


func _step_attack(dt: float) -> void:
	if Controls.pressed(&"dodge") and combo.can_cancel() and try_dodge(Controls.move()):
		return
	if combo.phase == ComboRunner.Phase.WINDUP:
		position = arena.resolve(position + _attack_dir * _lunge_speed * dt, RADIUS)


func _step_charge(dt: float) -> void:
	var move := Controls.move()
	if Controls.pressed(&"dodge") and try_dodge(move):
		return
	_walk(move, dt, CHARGE_WALK)
	_face(aim.x)
	_play(&"charge")
	if not _charged and _state_t >= combo.tree.charge_time:
		_charged = true
		fx.burst(&"light", position + Vector2(0, -10))
		fx.ring(position + Vector2(0, -4), 14.0, &"luz", 0.2)
		Audio.play(&"charged")


func _walk(move: Vector2, dt: float, factor: float = 1.0) -> void:
	position = arena.resolve(position + move * SPEED * factor * dt, RADIUS)


func try_dodge(move: Vector2) -> bool:
	if dodge_charges <= 0:
		return false
	dodge_charges -= 1
	_dodge_dir = move.normalized() if move.length() > 0.1 else aim
	invuln = maxf(invuln, DODGE_INVULN)
	combo.on_dodge()
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
		combo.on_dodge_end()
		_enter(State.MOVE)


func _on_move_started(node: ComboNode) -> void:
	_enter(State.ATTACK)
	_attack_dir = aim
	_lunge_speed = node.lunge / maxf(node.windup, 0.01)
	_face(aim.x)
	var a := Art.anim(&"paladin", node.anim)
	_sprite.speed_scale = (a.frames.size() / float(a.fps)) / node.duration()
	_sprite.play(node.anim)
	_sprite.frame = 0
	if node.title != &"":
		move_shown.emit(node)


func _on_move_hit(node: ComboNode) -> void:
	struck.emit(node, position, _attack_dir)


func _on_move_ended(_node: ComboNode) -> void:
	if state == State.ATTACK:
		_enter(State.MOVE)


func _recharge(dt: float) -> void:
	if dodge_charges >= dodge_max:
		_recharge_t = 0.0
		return
	_recharge_t += dt
	if _recharge_t >= recharge_time:
		_recharge_t = 0.0
		dodge_charges += 1


func _step_shield(dt: float) -> void:
	if shield_cooldown <= 0.0 or shield_ready:
		return
	_shield_t += dt
	if _shield_t >= shield_cooldown:
		shield_ready = true
		fx.burst(&"guard", position + Vector2(0, -8))


## Fraction of the next dodge charge already recovered (for the HUD).
func recharge_ratio() -> float:
	return _recharge_t / recharge_time


## Damage from an enemy. Returns true when it landed (not dodged, not invulnerable, not shielded).
func hurt(amount: float, from: Vector2) -> bool:
	if invuln > 0.0 or state == State.DEAD:
		return false
	if shield_ready:
		shield_ready = false
		_shield_t = 0.0
		invuln = 0.5
		fx.burst(&"guard", position + Vector2(0, -8))
		fx.ring(position + Vector2(0, -6), 16.0, &"vida", 0.25)
		Audio.play(&"shield")
		shield_broke.emit()
		return false
	hp = maxf(0.0, hp - amount)
	invuln = HURT_INVULN
	combo.reset()
	fx.shake(3.0)
	fx.hit_stop(60)
	Audio.play(&"hurt")
	was_hurt.emit()
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


## Stands still, sword lowered (the final scene).
func rest() -> void:
	if state != State.DEAD:
		_enter(State.MOVE)
		_sprite.visible = true
		_play(&"idle")


func alive() -> bool:
	return state != State.DEAD


func _enter(next: State) -> void:
	state = next
	_state_t = 0.0


func _face(x: float) -> void:
	if absf(x) > 0.05:
		_sprite.flip_h = x < 0.0


func _play(anim: StringName) -> void:
	_sprite.speed_scale = 1.0
	if _sprite.animation != anim:
		_sprite.play(anim)
