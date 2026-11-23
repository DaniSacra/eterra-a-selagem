class_name Skills
extends Node3D
## Runs the skills of the gifts the paladin holds. An AUTO skill fires on its own every few seconds (orbits never stop);
## any other (SkillDef.Trigger, BO-2) waits for its button: trigger() when the hero's move lands, at most once a `gap`.

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
## screen's ceiling (ScreenTone: 1.0 a channel is already near white after exposure and the filmic curve). Since the VFX
## pass (5.3) no halo and no particle trail: an ember drawn out with smoke behind it.
const ORB_CORE := Color(0.95, 0.4, 0.1)
## vfx_pass_spec.md 5.3 (the families' forms in what acts on its own): how long each family's floor mark stays (Fx.
## family_mark: Chama's tongues 0.4 s over a charred ring of 1.5 s, Geada's plates 0.8 s, Luz 0.5 s, Vigília 0.4 s); the
## Luz strike falls as a thin ray (STRIKE_RAY m of radius, never a reward's column); the others as streaks falling from
## FALL_HEIGHT m that land with the blow. The fire orb is an ember drawn out along its way (ORB_EMBER, length and radius)
## trailing smoke every ORB_SMOKE_EVERY s.
const MARK_TIME: Array[float] = [1.5, 0.8, 0.5, 0.4]
const STRIKE_RAY := 0.08
const FALL_HEIGHT := 7.0
const FALL_STREAKS := 3
const ORB_EMBER := Vector2(0.62, 0.13)
const ORB_SMOKE_EVERY := 0.08

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
var _gaps: Dictionary = {}  # boon id -> seconds before its button may set it off again
## The orbit a button set off, and how long it turns yet (an AUTO orbit never stops and is _step_orbit's alone).
var _orbit_boon: Boon
var _orbit_left := 0.0
var _pending: Array[Pending] = []
var _orbs: Array[MeshInstance3D] = []
var _orbit_angle := 0.0
var _orbit_tick := 0.0
var _orb_smoke := 0.0
var _found: Array[Enemy] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	Dev.seed_rng(_rng, 4)


## Seconds until a gift's skill fires again, and its full cooldown (for the HUD): the wait for the timer of an AUTO
## skill, the gap of a skill a button sets off.
func timer(b: Boon) -> Vector2:
	var lv := game.boons.level(b.id)
	if b.skill == null:
		return Vector2.ZERO
	if not b.skill.alone():
		return Vector2(_gaps.get(b.id, 0.0), b.skill.get_gap(lv))
	return Vector2(_timers.get(b.id, 0.0), b.skill.get_cooldown(lv))


func step(dt: float) -> void:
	var orbit: Boon = null
	for id: StringName in _gaps.keys():
		_gaps[id] = maxf(0.0, float(_gaps[id]) - dt)
	for b in game.boons.owned():
		if b.skill == null or not b.skill.alone():
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
	# a button's orbit turns while its time lasts (and while it is still held), else the AUTO one
	_orbit_left = maxf(0.0, _orbit_left - dt)
	if _orbit_boon != null and (_orbit_left <= 0.0 or game.boons.level(_orbit_boon.id) <= 0):
		_orbit_boon = null
	_step_orbit(_orbit_boon if _orbit_boon != null else orbit, dt)
	_step_pending(dt)


## The trigger a move of the combo tree sets off, from its tags (the hero's buttons: the Investida is the dash blow, the
## special the heavy one, the Brado the shout, the Omega its tag, the attack's last blow the finisher); -1 for a
## blow that is no button's end (the first cuts of the combo).
static func trigger_of(node: ComboNode) -> int:
	if node.has_tag(&"omega"):
		return SkillDef.Trigger.OMEGA
	if node.has_tag(&"dash"):
		return SkillDef.Trigger.RUSH
	if node.has_tag(&"shout"):
		return SkillDef.Trigger.SHOUT
	if node.has_tag(&"heavy"):
		return SkillDef.Trigger.SPECIAL
	if node.has_tag(&"finisher"):
		return SkillDef.Trigger.FINISHER
	return -1


## A button's move landed (or the dodge began, or the ultimate fell): every owned skill that button sets off goes, if its
## gap is over. A skill with no target (nobody near for a strike) does not spend its gap.
func trigger(which: SkillDef.Trigger) -> void:
	if not game.player.alive():
		return
	for b in game.boons.owned():
		if b.skill == null or b.skill.trigger != which or float(_gaps.get(b.id, 0.0)) > 0.0:
			continue
		var lv := game.boons.level(b.id)
		if b.skill.kind == SkillDef.Kind.ORBIT:
			_orbit_boon = b
			_orbit_left = b.skill.get_duration(lv)
		elif not _cast(b):
			continue
		_gaps[b.id] = b.skill.get_gap(lv)


## A skill's damage at a level, its first level's times the rarity the gift was taken at (C13-05).
func _damage(b: Boon, lv: int) -> float:
	return b.skill.damage_at(lv, game.boons.rarity_mult(b.id))


func _cast(b: Boon) -> bool:
	var lv := game.boons.level(b.id)
	var s := b.skill
	var tags: Array[StringName] = [&"skill", b.family_tag(), b.id]  # its id third: DealtBy.source
	if s.trigger == SkillDef.Trigger.ULT:
		tags.append(&"ultimate")  # the ultimate's frost freezes, as its blow does (Combat.FREEZERS)
	var color := b.color()
	# the Maga's special and Q fall where the spell fell (Arcane.spot_of), the rest at her feet
	var spot := game.arcane.spot_of(s.trigger) if game.arcane != null else Vector2.INF
	var p := game.player.pos if spot == Vector2.INF else spot
	match s.kind:
		SkillDef.Kind.STRIKES:
			var targets := _targets_near(p, STRIKE_RANGE, s.get_count(lv))
			if targets.is_empty():
				return false
			for i in targets.size():
				var at: Vector2 = targets[i]
				_queue(at, STRIKE_DELAY + i * 0.07, s.get_radius(lv), _damage(b, lv), tags, s.status, s.get_status_power(lv), color)
				# what falls, seen coming down before it lands: Luz a thin ray, the others streaks of their colour
				_falling(b.family, at, color, STRIKE_DELAY + i * 0.07, 1)
			Audio.play(&"rain")
		SkillDef.Kind.NOVA:
			var r := s.get_radius(lv)
			if not _mark(b.family, p, r, color):
				game.fx.ring(p, r, color, 0.45)
				game.fx.slash(p, game.player.facing, r, 359.0, color, 0.3)
			game.horde.in_circle(p, r, _found)
			for e in _found.duplicate():
				game.combat.skill_hit(e, _damage(b, lv), tags, (e.pos - p).normalized(), 6.0, s.status, s.get_status_power(lv))
			game.fx.shake(1.2)
			Audio.play(&"shield")
		SkillDef.Kind.FAN:
			var aim := game.player.facing
			var n := s.get_count(lv)
			for d in BossRules.fan(aim, n, deg_to_rad(18.0 * minf(n, 7)) if n > 1 else 0.0):
				# (the blades leave her, as the Warrior's, even when the Explosão fell far away)
				var shot := game.projectiles.fire_wave(Projectiles.Kind.BLADE, game.player.pos + d * 0.6, d, _damage(b, lv), s.get_radius(lv), 1.6, color, tags)
				shot.status = s.status
				shot.status_power = s.get_status_power(lv)
			Audio.play(&"swing")
		SkillDef.Kind.METEOR:
			var found: Variant = _densest(p, 16.0, s.get_radius(lv))
			if found == null:
				return false
			var at: Vector2 = found
			_queue(at, METEOR_DELAY, s.get_radius(lv), _damage(b, lv), tags, s.status, s.get_status_power(lv), color, true)
			_falling(b.family, at, color, METEOR_DELAY, FALL_STREAKS)
			game.fx.ring(at, s.get_radius(lv), color, METEOR_DELAY, 0.15, true)
			Audio.play(&"rain")
		SkillDef.Kind.CONSECRATE:
			var r := s.get_radius(lv)
			# the special's ground lies where its wave goes, in front of him; the others under him
			var at := p + game.player.facing * (r + 1.0) if s.trigger == SkillDef.Trigger.SPECIAL and spot == Vector2.INF else p
			var time := s.get_duration(lv) if s.get_duration(lv) > 0.0 else s.get_status_power(lv)
			if s.status == &"burn":
				# embers on the floor: damage a second to whoever stands there, and burning (Combat.on_zone_hit)
				game.ground.add_zone(Ground.Kind.EMBER, at, r, time, _damage(b, lv), Combat.EMBER_TAGS)
			else:
				game.ground.add_zone(Ground.Kind.HOLY, at, r, time, _damage(b, lv), tags)
			if not _mark(b.family, at, r, color):
				game.fx.ring(at, r, color, 0.5)
			# slow gold dust rising over the hallowed floor
			game.fx.chips(Vector3(at.x, 0.2, at.y), Vector3.UP, Fx.OLD_GOLD * 0.4, 6, 0.6, 0.12, 0.8, 1.2)
			Audio.play(&"heal")
	return true


## The column of light (or fire, or frost) of a gift falling at a point; faint where it would stand over the boss
## or the paladin (Game.column).
func _beam(at: Vector2, color: Color, radius: float, height: float, time: float) -> void:
	game.column(at, color, radius, height, time)


## The family's floor form (Fx.family_mark) for a gift that acts round a point; false for a family without one (the
## Elo shows its two in its blows), so the caller keeps the plain ring.
func _mark(family: int, at: Vector2, radius: float, color: Color) -> bool:
	if not Fx.MARK_FORM.has(family):
		return false
	game.fx.family_mark(family, at, radius, color, MARK_TIME[family])
	return true


## What a gift drops on a point, seen coming down for `delay` s: Luz a thin ray from above (Game.column at STRIKE_RAY,
## the only column outside the rewards, vfx_pass_spec.md 5.3), the others `streaks` slivers of their colour falling
## from FALL_HEIGHT to land with the blow.
func _falling(family: int, at: Vector2, color: Color, delay: float, streaks: int) -> void:
	if family == Boon.Family.LUZ:
		_beam(at, color, STRIKE_RAY, 6.0, delay + 0.12)
		return
	var speed := FALL_HEIGHT / maxf(delay, 0.05)
	for k in streaks:
		var off := Vector2.from_angle(TAU * k / maxf(streaks, 1)) * 0.35 if k > 0 else Vector2.ZERO
		game.fx.chips(Vector3(at.x + off.x, FALL_HEIGHT, at.y + off.y), Vector3.DOWN, color * 0.4, 1, speed, 0.22, delay, 0.0)


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
	if not _mark(Fx.family_of(q.color), q.at, q.radius * 1.15, q.color):
		game.fx.ring(q.at, q.radius * 1.15, q.color, 0.35 if not q.big else 0.6)
		game.fx.burst(&"fire" if fire else &"frost" if frost else &"light", Vector3(q.at.x, 0.4, q.at.y))
	if q.big:
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
		# an ember drawn out along its way (vfx_pass_spec.md 5.3), its core amber under the glow, no round halo
		var mi := MeshInstance3D.new()
		var ember := CapsuleMesh.new()
		ember.radius = ORB_EMBER.y
		ember.height = ORB_EMBER.x
		ember.radial_segments = 8
		ember.rings = 2
		mi.mesh = ember
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = ORB_CORE * 0.85
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	_orb_smoke -= dt
	var smoke := _orb_smoke <= 0.0
	if smoke:
		_orb_smoke = ORB_SMOKE_EVERY
	for i in n:
		var a := _orbit_angle + TAU * i / n
		var at := Vector3(p.x + cos(a) * r, 1.0, p.y + sin(a) * r)
		_orbs[i].position = at
		# lying along the way it turns (the capsule's axis is its y)
		var way := Vector3(-sin(a), 0.0, cos(a))
		_orbs[i].basis = Basis(way.cross(Vector3.UP).normalized(), way, Vector3.UP).orthonormalized()
		if smoke:
			game.fx.wisps(at - way * 0.4, Vector3.UP, Fx.SMOKE, 1, 0.4, 0.35, 0.45, 0.3, 1.0)
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
