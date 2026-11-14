class_name Horde
extends Node3D
## All enemies in one loop: no physics bodies, a spatial hash keeps them apart, CrowdRenderer draws them from baked
## poses. Every enemy attack is announced (a swing windup, a warning on the floor) before it can hurt.

signal killed(e: Enemy)
signal hit_player(amount: float, from: Vector2)
## An enemy's armor (yellow bar) just broke.
signal armor_broken(e: Enemy)

const CELL := 1.5
const KNOCKBACK_DECAY := 7.0
const FLASH_TIME := 0.14
## Flash of an ordinary blow (a strong one flashes at 1, so its first frame or two are pure white: crowd.gdshader).
const WEAK_FLASH := 0.45
## Numbers of blows that land on armor.
const ARMOR_COLOR := Color(1.0, 0.82, 0.3)
## A killing blow throws light bodies: base speed away, upward speed, gravity.
const THROW := 7.0
const THROW_UP := 6.0
const GRAVITY := 24.0
const BURN_TICK := 0.5
const HURT_TIME := 0.3
const DEATH_SHOW := 1.5
const DISSOLVE_FROM := 0.85
const MAX_DYING := 90
const DEFS_DIR := "res://data/enemies/"
## Share of an attack clip at which the blow lands (the windup is stretched to end there).
const IMPACT_SHARE := 0.55
const MELEE_COOLDOWN := 1.3

var list: Array[Enemy] = []
var dying: Array[Enemy] = []
var arena: Arena
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var renderer: CrowdRenderer
var hp_scale := 1.0
var damage_scale := 1.0
var target := Vector2.ZERO
var target_alive := true
var _hash := SpatialHash.new(CELL)
var _defs: Dictionary = {}
var _frame := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dev.seed_rng(_rng, 5)
	renderer = CrowdRenderer.new()
	renderer.layers = Arena.CROWD_LAYER
	add_child(renderer)


func def(id: StringName) -> EnemyDef:
	if not _defs.has(id):
		var d: EnemyDef = load(DEFS_DIR + id + ".tres")
		_defs[id] = d
		renderer.register(d)
	return _defs[id]


func spawn(d: EnemyDef, at: Vector2, rising: bool = true) -> Enemy:
	def(d.id)
	var e := Enemy.new()
	e.def = d
	e.pos = at
	var scaled := not d.elite and d.behavior != EnemyDef.Behavior.BOSS
	e.max_hp = d.hp * (hp_scale if scaled else 1.0)
	e.hp = e.max_hp
	e.max_armor = d.armor
	e.armor = d.armor
	e.cooldown = d.attack_cooldown * _rng.randf_range(0.4, 1.0)
	e.side = 1.0 if _rng.randf() < 0.5 else -1.0
	e.dir = (target - at).normalized() if target.distance_to(at) > 0.1 else Vector2.DOWN
	if rising:
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
		if e.push.length_squared() > 0.01:
			e.pos += e.push * dt
			e.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * dt)
		# nobody stands inside the paladin
		var off := e.pos - target
		var min_d := e.def.radius + Player.RADIUS
		var len_sq := off.length_squared()
		if e.state != Enemy.State.ATTACK and len_sq < min_d * min_d and len_sq > 0.0001:
			e.pos = target + off / sqrt(len_sq) * min_d
		e.pos = arena.resolve(e.pos, e.def.radius)
		e.y = e.height()
	_sweep()
	for d in dying:
		d.dead_t += dt
		if d.push.length_squared() > 0.01:
			d.pos = arena.resolve(d.pos + d.push * dt, d.def.radius)
			d.push *= maxf(0.0, 1.0 - KNOCKBACK_DECAY * 0.6 * dt)
		if d.vy != 0.0 or d.y > 0.0:
			d.y += d.vy * dt
			d.vy -= GRAVITY * dt
			if d.y <= 0.0:
				d.y = 0.0
				d.vy = -d.vy * 0.3 if d.vy < -4.0 else 0.0


func _timers(e: Enemy, dt: float) -> void:
	e.state_t += dt
	e.cooldown -= dt
	e.flash_t -= dt
	e.hurt_t -= dt
	e.stun_t = maxf(0.0, e.stun_t - dt)
	e.air_t = maxf(0.0, e.air_t - dt)
	e.blind_t = maxf(0.0, e.blind_t - dt)
	e.slow_t = maxf(0.0, e.slow_t - dt)
	if e.frozen_t > 0.0:
		e.frozen_t = maxf(0.0, e.frozen_t - dt)
	else:
		e.anim_t += dt
	if e.burn_t > 0.0:
		e.burn_t -= dt
		e.burn_tick -= dt
		if e.burn_tick <= 0.0:
			e.burn_tick = BURN_TICK
			damage(e, e.burn_dps * BURN_TICK, Vector2.ZERO, 0.0, Color(1.0, 0.5, 0.2), true, false)
	if e.state == Enemy.State.RISE and e.state_t > 0.9:
		_set_state(e, Enemy.State.WALK, &"walk")


func _speed(e: Enemy) -> float:
	return e.def.speed * (0.45 if e.slow_t > 0.0 else 1.0)


func _behave(e: Enemy, dt: float) -> void:
	var to := target - e.pos
	var dist := to.length()
	var toward := to / dist if dist > 0.01 else Vector2.DOWN
	if e.blind_t > 0.0:
		# blinded by steam: stumbles sideways, attacks nothing
		e.pos += toward.rotated(e.side * 1.4) * _speed(e) * 0.5 * dt
		return
	match e.def.behavior:
		EnemyDef.Behavior.CHASE:
			_behave_melee(e, dt, toward, dist)
		EnemyDef.Behavior.ARCHER:
			_behave_ranged(e, dt, toward, dist, false)
		EnemyDef.Behavior.CASTER:
			_behave_ranged(e, dt, toward, dist, true)
		EnemyDef.Behavior.RUNNER:
			_behave_runner(e, dt, toward, dist)
		EnemyDef.Behavior.KNIGHT:
			_behave_knight(e, dt, toward, dist)
		EnemyDef.Behavior.PRIEST:
			_behave_priest(e, dt, toward, dist)
		EnemyDef.Behavior.PULSE:
			_behave_pulse(e, dt, toward, dist)
		EnemyDef.Behavior.CONE:
			_behave_cone(e, dt, toward, dist)


## Walks up, raises the blade (the warning) and swings. Only the swing hurts, and only if the paladin is still close.
func _behave_melee(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var reach := e.def.radius + Player.RADIUS + 0.7 * e.def.size
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= _windup(e):
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				if target_alive and dist < reach + 0.5:
					hit_player.emit(e.def.damage * damage_scale, e.pos)
		Enemy.State.ATTACK:
			if e.state_t >= 0.35:
				e.cooldown = MELEE_COOLDOWN * _rng.randf_range(0.8, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = e.dir.slerp(toward, minf(1.0, dt * 8.0))
			if dist > reach * 0.8:
				e.pos += toward * _speed(e) * dt
			if dist < reach and e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"attack")


func _windup(e: Enemy) -> float:
	return e.def.attack_windup if e.def.behavior != EnemyDef.Behavior.CHASE else 0.5


## Keeps its distance; when ready, aims (the warning) and shoots a bolt, or conjures a circle under the paladin.
func _behave_ranged(e: Enemy, dt: float, toward: Vector2, dist: float, caster: bool) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		e.dir = toward
		if e.state_t >= d.attack_windup:
			if caster:
				ground.add_warning(target, 2.3, 1.1, d.attack_damage * damage_scale)
			else:
				projectiles.fire(Projectiles.Kind.BOLT, e.pos + toward * 0.6, toward, 13.0, d.attack_damage * damage_scale)
			e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		if e.state_t >= 0.4:
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	var sp := _speed(e)
	if dist > d.attack_range:
		e.pos += toward * sp * dt
	elif dist < d.attack_range * 0.5:
		e.pos -= toward * sp * 0.8 * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * sp * 0.35 * dt
	if e.cooldown <= 0.0 and dist < d.attack_range + 2.0 and target_alive and arena.inside(e.pos, 1.0):
		_set_state(e, Enemy.State.WINDUP, &"cast" if caster else &"aim")


## Runs in, stops, marks a line on the floor and lunges along it.
func _behave_runner(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			e.pos += e.aim * d.lunge_speed * dt
			if e.state_t >= d.lunge_time:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.8, 1.3)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range:
				e.pos += toward * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive:
				e.aim = toward
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"windup")
				ground.add_line_warning(e.pos, toward, d.lunge_speed * d.lunge_time + d.radius + 1.0, 1.3, d.attack_windup + d.lunge_time * 0.5, d.attack_damage * damage_scale)
			else:
				var circle := (toward.rotated(e.side * PI * 0.5) + toward * (0.3 if dist > d.attack_range * 0.6 else -0.5)).normalized()
				e.pos += circle * _speed(e) * 0.8 * dt


## Elite: walks the paladin down, then marks a long line and charges along it.
func _behave_knight(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
				fx.shake(1.5)
		Enemy.State.ATTACK:
			if e.memo == 1:
				# the close slam: stands still while it lands
				if e.state_t >= 0.5:
					e.memo = 0
					e.cooldown = d.attack_cooldown * 0.6
					_set_state(e, Enemy.State.WALK, &"walk")
				return
			e.pos += e.aim * d.lunge_speed * dt
			if _frame % 3 == 0:
				fx.burst(&"dust", Vector3(e.pos.x, 0.2, e.pos.y), Vector3(-e.aim.x, 0, -e.aim.y))
			if e.state_t >= d.lunge_time:
				e.cooldown = d.attack_cooldown
				e.stun_t = 0.8
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			_behave_melee_walk(e, dt, toward, dist)
			if d.close_damage > 0.0 and e.cooldown <= 0.0 and dist < d.close_range and target_alive:
				e.memo = 1
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"attack")
				ground.add_arc_warning(e.pos, toward, d.close_range + 0.8, 120.0, d.close_windup, d.close_damage * damage_scale)
				e.state_t = d.attack_windup - d.close_windup
				return
			if e.cooldown <= 0.0 and dist < d.attack_range and dist > d.close_range and target_alive:
				e.aim = toward
				e.dir = toward
				_set_state(e, Enemy.State.WINDUP, &"idle")
				ground.add_line_warning(e.pos, toward, d.lunge_speed * d.lunge_time + d.radius, 2.4, d.attack_windup, d.attack_damage * damage_scale)


## Between charges the knight still swings at whoever is close.
func _behave_melee_walk(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0))
	if dist > e.def.radius + Player.RADIUS + 0.5:
		e.pos += toward * _speed(e) * dt


## Elite: stays back, raises skeletons around itself and conjures circles.
func _behave_priest(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	if e.state == Enemy.State.WINDUP:
		if e.state_t >= d.attack_windup:
			e.memo += 1
			if e.memo % 2 == 1:
				var skeleton := def(&"skeleton")
				for k in 3:
					var at := arena.resolve(e.pos + Vector2.from_angle(TAU * k / 3.0) * 3.5, 0.5)
					spawn(skeleton, at, true)
					fx.burst(&"shadow", Vector3(at.x, 0.3, at.y))
				Audio.play(&"summon")
			else:
				for k in 3:
					var at := target + (Vector2.ZERO if k == 0 else Vector2.from_angle(TAU * k / 3.0 + e.state_t) * 3.2)
					ground.add_warning(at, 2.4, 0.9 + k * 0.25, d.attack_damage * damage_scale)
			e.cooldown = d.attack_cooldown
			_set_state(e, Enemy.State.ATTACK, &"attack", false)
		return
	if e.state == Enemy.State.ATTACK:
		if e.state_t >= 0.5:
			_set_state(e, Enemy.State.WALK, &"walk")
		return
	e.dir = toward
	if dist > d.attack_range:
		e.pos += toward * _speed(e) * dt
	elif dist < d.attack_range * 0.6:
		e.pos -= toward * _speed(e) * dt
	else:
		e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt
	if e.cooldown <= 0.0 and target_alive:
		_set_state(e, Enemy.State.WINDUP, &"cast")


## Runs in close, stops, glows (the warning ring) and bursts all around itself.
func _behave_pulse(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			if e.state_t >= 0.4:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range:
				e.pos += toward * _speed(e) * dt
			elif e.cooldown <= 0.0 and target_alive:
				_set_state(e, Enemy.State.WINDUP, &"windup")
				ground.add_warning(e.pos, d.attack_width, d.attack_windup, d.attack_damage * damage_scale)
			else:
				e.pos += toward.rotated(e.side * PI * 0.5) * _speed(e) * 0.5 * dt


## Comes to mid range, plants itself and blasts a wide cone ahead.
func _behave_cone(e: Enemy, dt: float, toward: Vector2, dist: float) -> void:
	var d := e.def
	match e.state:
		Enemy.State.WINDUP:
			if e.state_t >= d.attack_windup:
				_set_state(e, Enemy.State.ATTACK, &"attack", false)
		Enemy.State.ATTACK:
			if e.state_t >= 0.5:
				e.cooldown = d.attack_cooldown * _rng.randf_range(0.85, 1.2)
				_set_state(e, Enemy.State.WALK, &"walk")
		_:
			e.dir = toward
			if dist > d.attack_range * 0.8:
				e.pos += toward * _speed(e) * dt
			if dist < d.attack_range and e.cooldown <= 0.0 and target_alive:
				e.aim = toward
				_set_state(e, Enemy.State.WINDUP, &"aim")
				ground.add_arc_warning(e.pos, toward, d.attack_range + 0.5, d.attack_width, d.attack_windup, d.attack_damage * damage_scale)


func _set_state(e: Enemy, state: Enemy.State, anim: StringName, restart: bool = true) -> void:
	e.state = state
	e.state_t = 0.0
	if e.anim != anim or restart:
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


## Damage to an enemy. Returns true when it died.
func damage(e: Enemy, amount: float, from_dir: Vector2, knockback: float, color: Color = Fx.GOLD, show_number: bool = true, big: bool = false) -> bool:
	if not e.alive or e.invulnerable:
		return false
	if e.armor > 0.0:
		# armor takes the blow: no push, no flinch; breaking it staggers (Game listens to armor_broken)
		e.armor = DamageCalc.against_armor(e.armor, amount)[0]
		e.flash_t = FLASH_TIME
		e.flash_power = WEAK_FLASH
		if show_number:
			fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, ARMOR_COLOR, big)
		if e.armor <= 0.0:
			armor_broken.emit(e)
		return false
	e.hp -= amount
	e.flash_t = FLASH_TIME
	e.flash_power = 1.0 if big else WEAK_FLASH
	if e.state == Enemy.State.WALK and not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
		e.hurt_t = HURT_TIME
	if knockback > 0.0:
		e.push = from_dir * knockback * (0.35 if e.def.heavy else 1.0)
	if show_number:
		fx.number(Vector3(e.pos.x, e.y + 1.9 * e.def.size, e.pos.y), amount, color, big)
	if e.hp <= 0.0:
		e.alive = false
		e.state = Enemy.State.DEAD
		e.dead_t = 0.0
		e.anim = &"death"
		if from_dir != Vector2.ZERO:
			e.dir = -from_dir
			if not e.def.heavy and e.def.behavior != EnemyDef.Behavior.BOSS:
				var power := THROW + knockback * 0.8 + (5.0 if big else 0.0)
				e.push = from_dir * power * _rng.randf_range(0.8, 1.2)
				e.vy = THROW_UP * _rng.randf_range(0.7, 1.2) + (3.0 if big else 0.0)
				e.spin = _rng.randf_range(0.6, 1.0)
		Audio.play(&"bone")
		fx.burst(&"bone" if e.def.undead else &"dust", Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(from_dir.x, 0, from_dir.y))
		killed.emit(e)
		return true
	return false


func _sweep() -> void:
	var i := list.size() - 1
	while i >= 0:
		var e := list[i]
		if not e.alive:
			dying.append(e)
			list[i] = list[list.size() - 1]
			list.pop_back()
		i -= 1
	var j := dying.size() - 1
	while j >= 0:
		if dying[j].dead_t > DEATH_SHOW:
			dying.remove_at(j)
		j -= 1
	while dying.size() > MAX_DYING:
		dying.pop_front()


## Removes the common crowd (the crypt doors opened): no experience, no drops. Elites and bosses stay.
func clear_crowd() -> void:
	for e in list:
		if not e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS:
			e.alive = false
			e.state = Enemy.State.DEAD
			e.anim = &"death"
			fx.burst(&"shadow", Vector3(e.pos.x, 0.6, e.pos.y))
	_sweep()


## Up to this many enemies on the floor, every one shows its life bar (as in Hades II); more, only the hurt.
const BARS_FOR_ALL := 24


## Draws every living and dying enemy. Called every frame, also while the game is paused for hit stop.
func render() -> void:
	renderer.begin()
	var few := list.size() <= BARS_FOR_ALL
	for e in list:
		var anim := e.anim
		var t := e.anim_t
		if e.state == Enemy.State.WALK:
			if e.hurt_t > 0.0:
				anim = &"hit"
				t = HURT_TIME - e.hurt_t
			elif e.stun_t > 0.0:
				anim = &"idle"
			else:
				t = e.anim_t * clampf(_speed(e) / 2.3, 0.6, 1.6)
		elif e.state == Enemy.State.WINDUP and anim == &"attack":
			# stretch the swing so the blade comes down when the windup ends
			var clip := renderer.model_of(e.def).duration(&"attack")
			t = e.state_t / _windup(e) * clip * IMPACT_SHARE
		elif e.state == Enemy.State.ATTACK and anim == &"attack":
			var clip := renderer.model_of(e.def).duration(&"attack")
			t = clip * IMPACT_SHARE + e.state_t * 1.4
		var k := clampf(e.flash_t / FLASH_TIME, 0.0, 1.0)
		var state := Color(k * e.flash_power, 1.0 if e.frozen_t > 0.0 else 0.0, 1.0 if e.burn_t > 0.0 else 0.0, 0.0)
		# a blow flattens and widens the body for an instant, and lifts it a little
		var squash := Vector3(1.0 + 0.25 * k, 1.0 - 0.2 * k, 1.0 + 0.25 * k)
		renderer.add(e.def, anim, t, Vector3(e.pos.x, e.y + 0.18 * k, e.pos.y), e.yaw(), state, squash)
		# the thin life bar over the head (the boss has its own at the top of the screen); with a big crowd only
		# the hurt and the armored show one, so the screen stays clear
		if e.def.behavior != EnemyDef.Behavior.BOSS and (few or e.hp < e.max_hp or e.armor > 0.0):
			var top := e.y + renderer.model_of(e.def).height * e.def.size
			renderer.add_bar(e.def, Vector3(e.pos.x, top, e.pos.y), e.hp / maxf(e.max_hp, 0.001),
				e.armor / maxf(e.max_armor, 0.001) if e.max_armor > 0.0 else 0.0)
	for e in dying:
		var dissolve := clampf((e.dead_t - DISSOLVE_FROM) / (DEATH_SHOW - DISSOLVE_FROM), 0.0, 1.0)
		var sink := maxf(0.0, e.dead_t - DISSOLVE_FROM) * 1.2
		var tumble := -e.spin * sin(clampf(e.dead_t * 2.2, 0.0, 1.0) * PI) * 1.1
		renderer.add(e.def, &"death", e.dead_t * 1.3, Vector3(e.pos.x, e.y - sink, e.pos.y), e.yaw(), Color(maxf(0.0, 1.0 - e.dead_t * 8.0), 0, 0, dissolve), Vector3.ONE, tumble)
	renderer.commit()


# ---------- queries (only on the frames something lands, so a plain loop is enough) ----------

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
		if len_sq < 1.0 or absf(dir.angle_to(d)) <= half + e.def.radius / maxf(sqrt(len_sq), 0.5):
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


## The closest living enemy within a cone (half angle in radians) around dir.
func nearest_ahead(from: Vector2, dir: Vector2, max_dist: float, half_angle: float) -> Enemy:
	var best: Enemy = null
	var best_d := max_dist * max_dist
	for e in list:
		var d := e.pos.distance_squared_to(from)
		if e.alive and d < best_d and absf(dir.angle_to(e.pos - from)) < half_angle:
			best_d = d
			best = e
	return best


func nearest(from: Vector2, max_dist: float = INF) -> Enemy:
	var best: Enemy = null
	var best_d := max_dist * max_dist
	for e in list:
		var d := e.pos.distance_squared_to(from)
		if e.alive and d < best_d:
			best_d = d
			best = e
	return best
