class_name EnemySystem
extends Node
## All enemies in one loop: pooled sprites, no physics bodies, a spatial hash for keeping them apart.

signal killed(e: Enemy)
signal hit_player(amount: float, from: Vector2)

const CELL := 12.0
const KNOCKBACK_DECAY := 9.0
const CONTACT_COOLDOWN := 0.9
const FLASH_TIME := 0.09
const BURN_TICK := 0.5
const DEFS_DIR := "res://data/enemies/"

var list: Array[Enemy] = []
var world: Node2D
var arena: Arena
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var hp_scale := 1.0
var damage_scale := 1.0
var target := Vector2.ZERO
var target_alive := true
var _hash := SpatialHash.new(CELL)
var _pool: Array[Sprite2D] = []
var _anims: Dictionary = {}
var _defs: Dictionary = {}
var _frame := 0
var _rng := RandomNumberGenerator.new()


func def(id: StringName) -> EnemyDef:
	if not _defs.has(id):
		_defs[id] = load(DEFS_DIR + id + ".tres")
	return _defs[id]


func spawn(d: EnemyDef, at: Vector2, rising: bool = false) -> Enemy:
	var e := Enemy.new()
	e.def = d
	e.pos = at
	e.max_hp = d.hp * (hp_scale if not d.elite and d.behavior != EnemyDef.Behavior.BOSS else 1.0)
	e.hp = e.max_hp
	e.cooldown = d.attack_cooldown * _rng.randf_range(0.4, 1.0)
	e.side = 1.0 if _rng.randf() < 0.5 else -1.0
	e.sprite = _pool.pop_back() if not _pool.is_empty() else Sprite2D.new()
	Art.setup(e.sprite, d.sprite)
	e.sprite.position = at
	e.sprite.visible = true
	if e.sprite.get_parent() == null:
		world.add_child(e.sprite)
	if rising and _anim(d.sprite, &"rise").size() > 0:
		e.state = Enemy.State.RISE
		e.anim = &"rise"
	list.append(e)
	return e


func count() -> int:
	return list.size()


func step(dt: float) -> void:
	_frame += 1
	_hash.clear()
	for e in list:
		_hash.insert(e.pos, e)
	var i := 0
	for e in list:
		i += 1
		_timers(e, dt)
		if e.alive and not e.helpless():
			_behave(e, dt)
		if (i + _frame) % 2 == 0:
			_separate(e)
		if e.push.length_squared() > 1.0:
			e.pos += e.push * dt
			e.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * dt)
		# nobody stands inside the paladin
		var off := e.pos - target
		var min_d := e.def.radius + Player.RADIUS - 1.0
		if e.state != Enemy.State.ATTACK and off.length_squared() < min_d * min_d and off.length_squared() > 0.0001:
			e.pos = target + off.normalized() * min_d
		e.pos = arena.resolve(e.pos, e.def.radius)
		_show(e, dt)
	_sweep()


func _timers(e: Enemy, dt: float) -> void:
	e.state_t += dt
	e.cooldown -= dt
	e.contact_cd -= dt
	e.flash_t -= dt
	e.stun_t = maxf(0.0, e.stun_t - dt)
	e.air_t = maxf(0.0, e.air_t - dt)
	e.blind_t = maxf(0.0, e.blind_t - dt)
	if e.frozen_t > 0.0:
		e.frozen_t = maxf(0.0, e.frozen_t - dt)
	if e.burn_t > 0.0:
		e.burn_t -= dt
		e.burn_tick -= dt
		if e.burn_tick <= 0.0:
			e.burn_tick = BURN_TICK
			damage(e, e.burn_dps * BURN_TICK, Vector2.ZERO, 0.0, &"perigo", false)
	if e.state == Enemy.State.RISE and e.state_t > 0.4:
		_set_state(e, Enemy.State.WALK, &"walk")


func _behave(e: Enemy, dt: float) -> void:
	var to := target - e.pos
	var dist := to.length()
	var toward := to / dist if dist > 0.01 else Vector2.RIGHT
	if e.blind_t > 0.0:
		# blinded by steam: stumbles sideways, attacks nothing
		e.pos += toward.rotated(e.side * 1.4) * e.def.speed * 0.5 * dt
		return
	match e.def.behavior:
		EnemyDef.Behavior.CHASE:
			e.dir = toward
			e.pos += toward * e.def.speed * dt
			_contact(e, dist, e.def.damage)
		EnemyDef.Behavior.ARCHER:
			_behave_ranged(e, dt, toward, dist, false)
		EnemyDef.Behavior.CASTER:
			_behave_ranged(e, dt, toward, dist, true)
		EnemyDef.Behavior.WOLF:
			_behave_wolf(e, dt, toward, dist)
		EnemyDef.Behavior.KNIGHT:
			_behave_knight(e, dt, toward, dist)
		EnemyDef.Behavior.PRIEST:
			_behave_priest(e, dt, toward, dist)


func _contact(e: Enemy, dist: float, amount: float) -> void:
	if target_alive and e.contact_cd <= 0.0 and dist < e.def.radius + Player.RADIUS + 1.0:
		e.contact_cd = CONTACT_COOLDOWN
		hit_player.emit(amount * damage_scale, e.pos)


## Keeps its distance; when ready, warns and then shoots an arrow or conjures a circle under the paladin.
func _behave_ranged(e: Enemy, dt: float, toward: Vector2, dist: float, caster: bool) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		if not caster:
			e.dir = toward
		if e.state_t >= d.attack_windup:
			if caster:
				ground.add_warning(target, 20.0, 1.0, d.attack_damage * damage_scale)
			else:
				projectiles.fire(Projectiles.Kind.ARROW, e.pos + Vector2(0, -8), e.dir, 100.0, d.attack_damage * damage_scale)
			e.cooldown = d.attack_cooldown
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	if dist > d.attack_range:
		e.pos += toward * d.speed * dt
	elif dist < d.attack_range * 0.5:
		e.pos -= toward * d.speed * 0.7 * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * d.speed * 0.4 * dt
	_contact(e, dist, d.damage)
	if e.cooldown <= 0.0 and dist < d.attack_range + 16.0 and target_alive:
		_set_state(e, Enemy.State.WINDUP, &"attack")


## Runs in, circles, crouches (the warning) and lunges.
func _behave_wolf(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack")
				e.push = e.dir * 250.0
		Enemy.State.ATTACK:
			_contact(e, dist, d.attack_damage)
			if e.state_t >= 0.32:
				e.cooldown = d.attack_cooldown
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range:
				e.pos += toward * d.speed * dt
			elif e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"windup")
			else:
				e.pos += (toward.rotated(e.side * PI * 0.5) + toward * (0.3 if dist > d.attack_range * 0.6 else -0.5)).normalized() * d.speed * 0.8 * dt
			_contact(e, dist, d.damage)


## Elite: walks the paladin down, then announces a line and charges along it.
func _behave_knight(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t < d.attack_windup * 0.7:
				e.dir = toward
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack")
		Enemy.State.ATTACK:
			e.pos += e.dir * 250.0 * dt
			_contact(e, dist, d.attack_damage)
			if _frame % 3 == 0:
				fx.burst(&"dust", e.pos, -e.dir)
			if e.state_t >= 0.6:
				e.cooldown = d.attack_cooldown
				e.stun_t = 0.7
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			e.pos += toward * d.speed * dt
			_contact(e, dist, d.damage)
			if e.cooldown <= 0.0 and dist < d.attack_range and dist > 30.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"windup")


## Elite: stays back, raises skeletons around itself and conjures circles.
func _behave_priest(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		if e.state_t >= d.attack_windup:
			e.memo += 1
			if e.memo % 2 == 1:
				var skeleton := def(&"skeleton")
				for k in 7:
					var at := e.pos + Vector2.from_angle(TAU * k / 7.0) * 34.0
					spawn(skeleton, arena.resolve(at, 5.0), true)
					fx.burst(&"shadow", at)
			else:
				for k in 3:
					ground.add_warning(target + Vector2.from_angle(TAU * k / 3.0 + e.state_t) * (0.0 if k == 0 else 30.0), 20.0, 0.9 + k * 0.25, d.attack_damage * damage_scale)
			e.cooldown = d.attack_cooldown
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	if dist > d.attack_range:
		e.pos += toward * d.speed * dt
	elif dist < d.attack_range * 0.6:
		e.pos -= toward * d.speed * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * d.speed * 0.5 * dt
	_contact(e, dist, d.damage)
	if e.cooldown <= 0.0 and target_alive:
		_set_state(e, Enemy.State.WINDUP, &"attack")


func _set_state(e: Enemy, state: Enemy.State, anim: StringName) -> void:
	e.state = state
	e.state_t = 0.0
	if e.anim != anim:
		e.anim = anim
		e.anim_t = 0.0


func _separate(e: Enemy) -> void:
	var cx := int(floor(e.pos.x / CELL - 0.5))
	var cy := int(floor(e.pos.y / CELL - 0.5))
	for oy in 2:
		for ox in 2:
			for other: Enemy in _hash.at_cell(cx + ox, cy + oy):
				if other == e:
					continue
				var d := e.pos - other.pos
				var min_d := e.def.radius + other.def.radius
				var len_sq := d.length_squared()
				if len_sq < min_d * min_d and len_sq > 0.0001:
					var len := sqrt(len_sq)
					var shove := d / len * (min_d - len) * 0.5
					if not e.def.heavy or other.def.heavy:
						e.pos += shove
					if not other.def.heavy or e.def.heavy:
						other.pos -= shove


func _show(e: Enemy, dt: float) -> void:
	var s := e.sprite
	s.position = e.pos
	s.offset.y = -Art.origin(e.def.sprite).y - e.height()
	if absf(e.dir.x) > 0.1:
		s.flip_h = e.dir.x < 0.0
	if e.frozen_t <= 0.0 and e.stun_t <= 0.0:
		e.anim_t += dt
	var a: Dictionary = _anim(e.def.sprite, e.anim)
	var frames: Array = a.frames
	var idx := int(e.anim_t * a.fps)
	s.frame = int(frames[idx % frames.size()] if a.loop else frames[mini(idx, frames.size() - 1)])
	var want: StringName = Art.FLASH if e.flash_t > 0.0 else Art.FROZEN if e.frozen_t > 0.0 else e.variant
	var tex := Art.tex(e.def.sprite, want)
	if s.texture != tex:
		s.texture = tex


func _anim(sprite: StringName, anim: StringName) -> Dictionary:
	var key := String(sprite) + "/" + String(anim)
	if not _anims.has(key):
		var a: Dictionary = Art.def(sprite).anims.get(anim, {})
		if a.is_empty():
			a = Art.def(sprite).anims.get("walk", {"frames": [0], "fps": 1, "loop": true}) if anim != &"rise" else {}
		_anims[key] = a
	return _anims[key]


## Damage to an enemy. Returns true when it died.
func damage(e: Enemy, amount: float, from_dir: Vector2, knockback: float, family: StringName = &"luz", show_number: bool = true) -> bool:
	if not e.alive or e.invulnerable:
		return false
	e.hp -= amount
	e.flash_t = FLASH_TIME
	if knockback > 0.0:
		e.push = from_dir * knockback * (0.25 if e.def.heavy else 1.0) * 6.0
	if show_number:
		fx.number(e.pos + Vector2(0, -16 - e.height()), amount, family)
	if e.hp <= 0.0:
		e.alive = false
		fx.burst(&"bone" if e.def.undead else &"dust", e.pos + Vector2(0, -8))
		killed.emit(e)
		return true
	return false


func _sweep() -> void:
	var i := list.size() - 1
	while i >= 0:
		var e := list[i]
		if not e.alive:
			e.sprite.visible = false
			_pool.append(e.sprite)
			e.sprite = null
			list[i] = list[list.size() - 1]
			list.pop_back()
		i -= 1


## Removes the common crowd (the crypt doors opened): no experience, no drops. Elites and bosses stay.
func clear_crowd() -> void:
	for e in list:
		if not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
			e.alive = false
			fx.burst(&"bone", e.pos + Vector2(0, -8))
	_sweep()


# ---------- hit queries (only on the frames a move lands, so a plain loop is enough) ----------

func in_circle(center: Vector2, radius: float, out: Array[Enemy]) -> void:
	out.clear()
	for e in list:
		var r := radius + e.def.radius
		if e.alive and e.pos.distance_squared_to(center) <= r * r:
			out.append(e)


func in_arc(center: Vector2, dir: Vector2, reach: float, degrees: float, out: Array[Enemy]) -> void:
	out.clear()
	var half := deg_to_rad(degrees) * 0.5
	for e in list:
		if not e.alive:
			continue
		var d := e.pos - center
		var r := reach + e.def.radius
		var len_sq := d.length_squared()
		if len_sq > r * r:
			continue
		# anything hugging the paladin is hit whatever the angle
		if len_sq < 64.0 or absf(dir.angle_to(d)) <= half + e.def.radius / maxf(sqrt(len_sq), 1.0):
			out.append(e)


func in_line(from: Vector2, dir: Vector2, length: float, width: float, out: Array[Enemy]) -> void:
	out.clear()
	for e in list:
		if not e.alive:
			continue
		var d := e.pos - from
		var along := d.dot(dir)
		if along < -e.def.radius or along > length + e.def.radius:
			continue
		if absf(d.cross(dir)) <= width * 0.5 + e.def.radius:
			out.append(e)
