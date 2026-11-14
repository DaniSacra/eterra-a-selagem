class_name Player
extends Node3D
## The paladin. Moves on the floor plane (pos is (x, z) in meters), rolls out of danger, and fights with the combo
## tree: the ComboRunner decides which move comes next, this node plays it (animation, lunge) and reports when it lands.

signal struck(node: ComboNode, origin: Vector2, dir: Vector2)
signal move_shown(node: ComboNode)
signal was_hurt(amount: float)
signal died
signal dodged(dir: Vector2)
signal shield_broke

enum State { MOVE, DODGE, HURT, DEAD, REST }

const MODEL := "res://assets/models/characters/Knight.glb"
const HIDDEN_PARTS: Array[String] = ["1H_Sword_Offhand", "Rectangle_Shield", "Round_Shield", "Spike_Shield", "2H_Sword"]
const COMBOS := "res://data/combos/paladin.tres"
const RADIUS := 0.5
const MAX_HP := 100.0
const HURT_TIME := 0.18
const HURT_INVULN := 0.8
const TURN := 18.0
## Soft lock: a swing without a clear aim turns to the closest enemy in front, within this distance.
const ASSIST_RANGE := 6.0
const LOOPS: Array[StringName] = [&"Idle", &"Running_A"]
const FLASH := preload("res://assets/shaders/flash.gdshader")
const XRAY := preload("res://assets/shaders/xray.gdshader")
const OUTLINE := Color(1.0, 0.78, 0.35)

var arena: Arena
var horde: Horde
var fx: Fx
var pos := Vector2.ZERO
var facing := Vector2.DOWN
var state := State.MOVE
var hp := MAX_HP
var max_hp := MAX_HP
var dodge_max := 2
var dodge_charges := 2
var speed_bonus := 0.0
var damage_reduction := 0.0
var shield_cooldown := 0.0
var shield_ready := false
var runner: ComboRunner
var tree: ComboTree
var invuln := 0.0
var charging := false
var charge_t := 0.0
var _state_t := 0.0
var _dodge_dir := Vector2.DOWN
var _dodge_recharge := 0.0
var _lunge := Vector2.ZERO
var _push := Vector2.ZERO
var _shield_t := 0.0
var _flash := 0.0
var _model: Node3D
var _anim: AnimationPlayer
var _overlay: ShaderMaterial
var _xray: ShaderMaterial
var _current_anim := &""
var _light: OmniLight3D


func _ready() -> void:
	tree = load(COMBOS)
	runner = ComboRunner.new(tree)
	runner.move_started.connect(_on_move_started)
	runner.move_hit.connect(func(node: ComboNode) -> void: struck.emit(node, pos, facing))
	_model = (load(MODEL) as PackedScene).instantiate()
	add_child(_model)
	_overlay = ShaderMaterial.new()
	_overlay.shader = FLASH
	_xray = ShaderMaterial.new()
	_xray.shader = XRAY
	_xray.render_priority = 2
	_overlay.next_pass = _xray
	dodge_max = Feel.live().dodge_charges
	dodge_charges = dodge_max
	_prepare(_model)
	_anim = PoseBaker.find_player(_model)
	PoseBaker.find_skeleton(_model).add_child(Slender.new())
	_anim.playback_default_blend_time = 0.08
	for a in LOOPS:
		_anim.get_animation(a).loop_mode = Animation.LOOP_LINEAR
	_play(&"Idle")
	_light = OmniLight3D.new()
	_light.position = Vector3(0, 3.2, 0.6)
	_light.light_color = Color(1.0, 0.78, 0.5)
	_light.light_energy = 1.7
	_light.omni_range = 12.0
	_light.omni_attenuation = 1.2
	_light.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(_light)


func _prepare(n: Node) -> void:
	for c in n.get_children():
		if c is MeshInstance3D:
			if HIDDEN_PARTS.has(String(c.name)):
				(c as MeshInstance3D).visible = false
			else:
				(c as MeshInstance3D).material_overlay = _overlay
		_prepare(c)


func alive() -> bool:
	return state != State.DEAD


func invulnerable() -> bool:
	return invuln > 0.0 or state == State.DODGE or state == State.DEAD or state == State.REST


## Every frame of play. move: stick or keys. aim: where the paladin wants to strike (unit vector, or zero).
func step(dt: float, move: Vector2, aim: Vector2) -> void:
	_state_t += dt
	invuln = maxf(0.0, invuln - dt)
	_flash = maxf(0.0, _flash - dt * 6.0)
	if shield_cooldown > 0.0 and not shield_ready:
		_shield_t += dt
		if _shield_t >= shield_cooldown:
			shield_ready = true
			fx.burst(&"heal", Vector3(pos.x, 1.2, pos.y))
	if dodge_charges < dodge_max:
		_dodge_recharge += dt
		if _dodge_recharge >= Feel.live().dodge_recharge:
			_dodge_recharge = 0.0
			dodge_charges += 1
	match state:
		State.DEAD, State.REST:
			_show(dt)
			return
		State.HURT:
			pos += _push * dt
			_push *= maxf(0.0, 1.0 - 10.0 * dt)
			if _state_t >= HURT_TIME:
				state = State.MOVE
		State.DODGE:
			var feel := Feel.live()
			pos += _dodge_dir * feel.dodge_speed * dt * (1.0 - _state_t / feel.dodge_time * 0.5)
			if _state_t >= feel.dodge_time:
				state = State.MOVE
				runner.on_dodge_end()
				invuln = maxf(invuln, feel.dodge_iframes - feel.dodge_time)
		State.MOVE:
			_read_buttons(dt, move, aim)
			if state == State.MOVE:
				var sp := Feel.live().speed * (1.0 + speed_bonus)
				if runner.is_attacking():
					pos += move * sp * Feel.live().move_scale_light * dt + _lunge * dt
				else:
					pos += move * sp * dt
					if move.length() > 0.1:
						facing = facing.slerp(move.normalized(), minf(1.0, dt * TURN)).normalized()
	runner.step(dt)
	_lunge *= maxf(0.0, 1.0 - 9.0 * dt)
	pos = arena.resolve(pos, RADIUS)
	_show(dt, move)


func _read_buttons(dt: float, move: Vector2, aim: Vector2) -> void:
	_aim = aim
	if Controls.pressed(&"dodge") and dodge_charges > 0 and runner.can_cancel():
		_start_dodge(move)
		return
	if Controls.pressed(&"light_attack"):
		runner.press(ComboNode.In.LIGHT)
	if Controls.pressed(&"heavy_attack"):
		if runner.charge_available():
			charging = true
			charge_t = 0.0
		else:
			runner.press(ComboNode.In.HEAVY)
	if charging:
		charge_t += dt
		if charge_t >= tree.charge_time and charge_t - dt < tree.charge_time:
			fx.burst(&"light", Vector3(pos.x, 1.4, pos.y))
			Audio.play(&"charged")
		if not Controls.held(&"heavy_attack"):
			charging = false
			runner.press(ComboNode.In.CHARGE if charge_t >= tree.charge_time else ComboNode.In.HEAVY)


var _aim := Vector2.ZERO


func _start_dodge(move: Vector2) -> void:
	charging = false
	state = State.DODGE
	_state_t = 0.0
	dodge_charges -= 1
	_dodge_dir = move.normalized() if move.length() > 0.2 else facing
	facing = _dodge_dir
	runner.on_dodge()
	_play(&"Dodge_Forward", 1.3)
	fx.burst(&"dust", Vector3(pos.x, 0.2, pos.y), Vector3(-_dodge_dir.x, 0, -_dodge_dir.y))
	Audio.play(&"dodge")
	dodged.emit(_dodge_dir)


func _on_move_started(node: ComboNode) -> void:
	var dir := _aim if _aim.length() > 0.1 else facing
	if not Controls.aims_with_mouse():
		var target := horde.nearest(pos, ASSIST_RANGE) if horde else null
		if target and absf(dir.angle_to(target.pos - pos)) < 1.2:
			dir = (target.pos - pos).normalized()
	facing = dir.normalized()
	_lunge = facing * node.lunge / maxf(node.windup + 0.06, 0.05) * 1.6
	_play(node.anim, node.anim_speed, node.anim_from)
	if node.title != &"":
		move_shown.emit(node)


func heal(amount: float) -> void:
	if amount <= 0.0 or not alive():
		return
	hp = minf(max_hp, hp + amount)


## A blow lands on the paladin. Rolls, the shield and the moments after a hit ignore it.
func hurt(amount: float, from: Vector2) -> void:
	if invulnerable() or amount <= 0.0:
		return
	if shield_ready:
		shield_ready = false
		_shield_t = 0.0
		invuln = 0.5
		fx.burst(&"heal", Vector3(pos.x, 1.2, pos.y))
		Audio.play(&"shield")
		shield_broke.emit()
		return
	amount = maxf(1.0, roundf(amount * (1.0 - damage_reduction)))
	hp -= amount
	invuln = HURT_INVULN
	_flash = 1.0
	charging = false
	runner.reset()
	var away := (pos - from).normalized() if pos.distance_to(from) > 0.01 else -facing
	_push = away * 9.0
	fx.number(Vector3(pos.x, 2.4, pos.y), amount, Color(1.0, 0.3, 0.25), true)
	fx.burst(&"spark", Vector3(pos.x, 1.2, pos.y), Vector3(away.x, 0, away.y))
	fx.shake(2.0)
	fx.kick_split(1.0)
	Audio.play(&"hurt")
	was_hurt.emit(amount)
	if hp <= 0.0:
		hp = 0.0
		state = State.DEAD
		_play(&"Death_A", 1.0)
		died.emit()
		return
	state = State.HURT
	_state_t = 0.0
	_play(&"Hit_A", 1.6)


## The fight is over: stand still and look on (the final scene).
func rest() -> void:
	if state == State.DEAD:
		return
	state = State.REST
	runner.reset()
	_play(&"Idle")


## Puts the paladin at a spot (the roar of Morvath throws him back).
func place(at: Vector2) -> void:
	pos = arena.resolve(at, RADIUS)


func _show(dt: float, move: Vector2 = Vector2.ZERO) -> void:
	position = Vector3(pos.x, 0, pos.y)
	var want := atan2(facing.x, facing.y)
	_model.rotation.y = lerp_angle(_model.rotation.y, want, minf(1.0, dt * (30.0 if runner.is_attacking() else TURN)))
	var glow := Color(1.0, 0.8, 0.35, clampf(charge_t / tree.charge_time, 0.0, 1.0) * (0.8 if charging else 0.0))
	if shield_ready and not charging:
		glow = Color(0.4, 1.0, 0.6, 0.35)
	_overlay.set_shader_parameter(&"flash", maxf(_flash, 0.6 if invuln > 0.0 and state != State.DODGE and fmod(invuln, 0.16) < 0.08 else 0.0))
	_overlay.set_shader_parameter(&"glow", glow)
	var edge := Dev.num("outline", Feel.live().outline)
	_overlay.set_shader_parameter(&"outline", Color(OUTLINE, edge))
	_xray.set_shader_parameter(&"color", Color(OUTLINE, edge))
	RenderingServer.global_shader_parameter_set(&"hero_pos", position)
	if state != State.MOVE or runner.is_attacking():
		return
	if move.length() > 0.1:
		_play(&"Running_A", 1.0 + speed_bonus)
	elif _anim.is_playing() and not LOOPS.has(_current_anim):
		return  # let the follow-through of a swing finish
	else:
		_play(&"Idle")


func _play(anim: StringName, speed: float = 1.0, from: float = -1.0) -> void:
	if from >= 0.0:
		_anim.play(anim, 0.05, speed)
		_anim.seek(from, true)
	elif _current_anim != anim or not _anim.is_playing():
		_anim.play(anim, -1, speed)
	_current_anim = anim
