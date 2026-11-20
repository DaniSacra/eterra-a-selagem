class_name Skills
extends Node3D
## Runs the skills of the gifts the paladin holds: each one fires on its own every few seconds (orbits never stop).

const STRIKE_RANGE := 13.0
const STRIKE_DELAY := 0.28
const METEOR_DELAY := 0.45
## A column of a gift that falls on a boss or a guardian is drawn this much fainter (ART-004 of cycle 10: the
## column's white core covered Morvath; his shape must read through it).
const BEAM_OVER_BOSS := 0.2
## Art review P4 (2026-11-16): a column standing in front of him covered him too (the frost gift's 16 m column, the
## camera 30 degrees up: a column hides the floor behind it out to its height / tan(pitch)), and its white core went
## past the glow even faint. Over him its light also stops at this (beam.gdshader's cap: under the glow threshold;
## since cycle C12c every column stops there, Fx.BEAM_CORE_CAP).
const BEAM_CORE_CAP := Fx.BEAM_CORE_CAP
const ORBIT_SPEED := 2.6
const ORBIT_TICK := 0.3
## Q-T5-6: the fire orbs read as embers by the paladin, not as two blown-out orange globes: the core under the
## screen's ceiling (ScreenTone: 1.0 a channel is already near white after exposure and the filmic curve), a small dim
## halo (ORB_HALO_SIZE m, it was 1.6 m at 2.4) and a dim trail (they were 3.0, 2.4 and 2.6, over the glow threshold).
const ORB_CORE := Color(0.95, 0.4, 0.1)
const ORB_HALO := Color(0.42, 0.14, 0.03)
const ORB_HALO_SIZE := 0.9
const ORB_TRAIL := Color(0.6, 0.22, 0.05)

class Pending:
	var at := Vector2.ZERO
	var delay := 0.0
	var radius := 1.0
	var damage := 0.0
	var tags: Array[StringName] = []
	var status: StringName
	var power := 0.0
	var color := Color.WHITE
	var big := false

var game: Game
var _timers: Dictionary = {}  # boon id -> seconds left
var _pending: Array[Pending] = []
var _orbs: Array[MeshInstance3D] = []
var _orbit_angle := 0.0
var _orbit_tick := 0.0
var _found: Array[Enemy] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dev.seed_rng(_rng, 4)


## Seconds until a gift's skill fires again, and its full cooldown (for the HUD).
func timer(b: Boon) -> Vector2:
	var lv := game.boons.level(b.id)
	return Vector2(_timers.get(b.id, 0.0), b.skill.get_cooldown(lv) if b.skill else 0.0)


func step(dt: float) -> void:
	var orbit: Boon = null
	for b in game.boons.owned():
		if b.skill == null:
			continue
		if b.skill.kind == SkillDef.Kind.ORBIT:
			orbit = b
			continue
		var left: float = _timers.get(b.id, 1.0) - dt
		if left <= 0.0 and game.player.alive():
			if _cast(b):
				left = b.skill.get_cooldown(game.boons.level(b.id))
			else:
				left = 0.25
		_timers[b.id] = left
	_step_orbit(orbit, dt)
	_step_pending(dt)


## A skill's damage at a level, its first level's times the rarity the gift was taken at (C13-05).
func _damage(b: Boon, lv: int) -> float:
	return b.skill.damage_at(lv, game.boons.rarity_mult(b.id))


func _cast(b: Boon) -> bool:
	var lv := game.boons.level(b.id)
	var s := b.skill
	var tags: Array[StringName] = [&"skill", b.family_tag(), b.id]  # its id third: DealtBy.source
	var color := b.color()
	var p := game.player.pos
	match s.kind:
		SkillDef.Kind.STRIKES:
			var targets := _targets_near(p, STRIKE_RANGE, s.get_count(lv))
			if targets.is_empty():
				return false
			for i in targets.size():
				var at: Vector2 = targets[i]
				_queue(at, STRIKE_DELAY + i * 0.07, s.get_radius(lv), _damage(b, lv), tags, s.status, s.get_status_power(lv), color)
				# what falls: a ball of fire or a pillar of light, seen coming down before it lands
				_beam(at, color, 0.35, 10.0, STRIKE_DELAY + i * 0.07 + 0.12)
			Audio.play(&"rain")
		SkillDef.Kind.NOVA:
			var r := s.get_radius(lv)
			game.fx.ring(p, r, color, 0.45)
			game.fx.slash(p, game.player.facing, r, 359.0, color, 0.3)
			for k in 10:
				var a := TAU * k / 10.0
				game.fx.burst(&"frost" if b.family == Boon.Family.GEADA else &"light", Vector3(p.x + cos(a) * r * 0.7, 0.4, p.y + sin(a) * r * 0.7))
			game.horde.in_circle(p, r, _found)
			for e in _found.duplicate():
				game.combat.skill_hit(e, _damage(b, lv), tags, (e.pos - p).normalized(), 6.0, s.status, s.get_status_power(lv))
			game.fx.shake(1.2)
			Audio.play(&"shield")
		SkillDef.Kind.FAN:
			var aim := game.player.facing
			var n := s.get_count(lv)
			for d in BossRules.fan(aim, n, deg_to_rad(18.0 * minf(n, 7)) if n > 1 else 0.0):
				var shot := game.projectiles.fire_wave(Projectiles.Kind.BLADE, p + d * 0.6, d, _damage(b, lv), s.get_radius(lv), 1.6, color, tags)
				shot.status = s.status
				shot.status_power = s.get_status_power(lv)
			Audio.play(&"swing")
		SkillDef.Kind.METEOR:
			var found: Variant = _densest(p, 16.0, s.get_radius(lv))
			if found == null:
				return false
			var at: Vector2 = found
			_queue(at, METEOR_DELAY, s.get_radius(lv), _damage(b, lv), tags, s.status, s.get_status_power(lv), color, true)
			_beam(at, color, 1.6, 16.0, METEOR_DELAY + 0.2)
			game.fx.ring(at, s.get_radius(lv), color, METEOR_DELAY)
			Audio.play(&"rain")
		SkillDef.Kind.CONSECRATE:
			game.ground.add_zone(Ground.Kind.HOLY, p, s.get_radius(lv), s.get_status_power(lv), _damage(b, lv), tags)
			game.fx.ring(p, s.get_radius(lv), color, 0.5)
			game.fx.burst(&"light", Vector3(p.x, 0.3, p.y))
			Audio.play(&"heal")
	return true


## The column of light (or fire, or frost) of a gift falling at a point; faint where it would stand over the boss
## or the paladin (Game.column).
func _beam(at: Vector2, color: Color, radius: float, height: float, time: float) -> void:
	game.column(at, color, radius, height, time)


## True when a column of this radius at this point stands over the boss (or guardian) shown, if any: on him, or, with
## its height and the camera's yaw and pitch, in front of him on the screen (he stands in the strip of floor the
## column hides, behind its foot as the camera sees it).
static func over_boss(boss: Enemy, at: Vector2, radius: float, height := 0.0, yaw_deg := 0.0, pitch_deg := 30.0) -> bool:
	if boss == null or not boss.alive:
		return false
	return covers(boss.pos, boss.def.radius, at, radius, height, yaw_deg, pitch_deg)


## True when a column of this radius and height at `at` covers a body of body_radius standing at `body`: on it, or in
## front of it on the screen (the body stands in the strip of floor the column hides, behind its foot as the camera
## at yaw and pitch sees it). Height 0: only on it.
static func covers(body: Vector2, body_radius: float, at: Vector2, radius: float, height := 0.0, yaw_deg := 0.0, pitch_deg := 30.0) -> bool:
	var reach := body_radius + radius
	if at.distance_to(body) < reach:
		return true
	if height <= 0.0:
		return false
	# away from the camera along the floor (the camera sits at +(sin yaw, cos yaw) from what it looks at)
	var away := -Vector2(sin(deg_to_rad(yaw_deg)), cos(deg_to_rad(yaw_deg)))
	var v := body - at
	var along := v.dot(away)
	return along > 0.0 and along < height / tan(deg_to_rad(maxf(pitch_deg, 5.0))) and absf(v.cross(away)) < reach


func _queue(at: Vector2, delay: float, radius: float, damage: float, tags: Array[StringName], status: StringName, power: float, color: Color, big: bool = false) -> void:
	var q := Pending.new()
	q.at = at
	q.delay = delay
	q.radius = radius
	q.damage = damage
	q.tags = tags
	q.status = status
	q.power = power
	q.color = color
	q.big = big
	_pending.append(q)


func _step_pending(dt: float) -> void:
	var i := _pending.size() - 1
	while i >= 0:
		var q := _pending[i]
		q.delay -= dt
		if q.delay <= 0.0:
			_land(q)
			_pending.remove_at(i)
		i -= 1


func _land(q: Pending) -> void:
	var fire := q.tags.has(&"chama")
	var frost := q.tags.has(&"geada")
	game.fx.ring(q.at, q.radius * 1.15, q.color, 0.35 if not q.big else 0.6)
	game.fx.burst(&"fire" if fire else &"frost" if frost else &"light", Vector3(q.at.x, 0.4, q.at.y))
	if q.big:
		game.fx.burst(&"frost" if frost else &"light", Vector3(q.at.x, 1.0, q.at.y))
		game.fx.shake(2.5)
		game.fx.kick_split(0.6)
		game.fx.hit_stop(50)
	game.horde.in_circle(q.at, q.radius, _found)
	for e in _found.duplicate():
		game.combat.skill_hit(e, q.damage, q.tags, (e.pos - q.at).normalized(), 5.0 if not q.big else 10.0, q.status, q.power)
	if fire and q.big == false:
		game.ground.add_zone(Ground.Kind.EMBER, q.at, q.radius * 0.6, 1.6, q.power, q.tags)


## Orbs of fire turning around the paladin: they burn what they touch every ORBIT_TICK.
func _step_orbit(b: Boon, dt: float) -> void:
	var n := 0
	var lv := 0
	if b != null:
		lv = game.boons.level(b.id)
		n = b.skill.get_count(lv)
	while _orbs.size() < n:
		var mi := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.32
		sphere.height = 0.64
		mi.mesh = sphere
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = ORB_CORE
		mi.material_override = m
		var glow := MeshInstance3D.new()
		glow.mesh = Fx.quad(ORB_HALO_SIZE, ORB_HALO)
		(glow.mesh as QuadMesh).material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mi.add_child(glow)
		var trail := CPUParticles3D.new()
		trail.amount = 14
		trail.lifetime = 0.35
		trail.mesh = Fx.quad(0.4, ORB_TRAIL)
		trail.color_ramp = Fx.fade_ramp(Color.WHITE)
		trail.gravity = Vector3(0, 1.5, 0)
		trail.initial_velocity_max = 0.3
		trail.local_coords = false
		mi.add_child(trail)
		add_child(mi)
		_orbs.append(mi)
	while _orbs.size() > n:
		_orbs.pop_back().queue_free()
	if n == 0:
		return
	var s := b.skill
	var r := s.get_radius(lv)
	_orbit_angle += dt * ORBIT_SPEED
	var p := game.player.pos
	for i in n:
		var a := _orbit_angle + TAU * i / n
		_orbs[i].position = Vector3(p.x + cos(a) * r, 1.0, p.y + sin(a) * r)
	_orbit_tick -= dt
	if _orbit_tick > 0.0:
		return
	_orbit_tick = ORBIT_TICK
	var tags: Array[StringName] = [&"skill", b.family_tag(), b.id]  # its id third: DealtBy.source
	for orb in _orbs:
		var at := Vector2(orb.position.x, orb.position.z)
		game.horde.in_circle(at, 0.8, _found)
		for e in _found.duplicate():
			game.combat.skill_hit(e, _damage(b, lv), tags, (e.pos - p).normalized(), 4.0, s.status, s.get_status_power(lv))


## Up to n enemies near a point, nearest first, each a different one.
func _targets_near(p: Vector2, max_dist: float, n: int) -> Array[Vector2]:
	var cand: Array[Enemy] = []
	game.horde.in_circle(p, max_dist, cand)
	cand.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.pos.distance_squared_to(p) < b.pos.distance_squared_to(p))
	var out: Array[Vector2] = []
	# mix the nearest with a few random ones so the strikes spread over the crowd
	for e in cand:
		if out.size() >= n:
			break
		if out.size() < n / 2 or _rng.randf() < 0.5:
			out.append(e.pos)
	for e in cand:
		if out.size() >= n:
			break
		if not out.has(e.pos):
			out.append(e.pos)
	return out


## Where the crowd is thickest around the paladin (null when nobody is near).
func _densest(p: Vector2, max_dist: float, radius: float) -> Variant:
	var cand: Array[Enemy] = []
	game.horde.in_circle(p, max_dist, cand)
	if cand.is_empty():
		return null
	var best: Vector2 = cand[0].pos
	var best_n := -1
	for k in mini(12, cand.size()):
		var c: Enemy = cand[_rng.randi() % cand.size()]
		game.horde.in_circle(c.pos, radius, _found)
		if _found.size() > best_n:
			best_n = _found.size()
			best = c.pos
	return best
