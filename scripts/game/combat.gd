class_name Combat
extends RefCounted
## Resolves what the paladin's moves and gifts do to the enemies: who is hit, how hard, which effects apply.

signal combo_changed(count: int)
signal enemy_struck(e: Enemy, tags: Array[StringName], damage: float)

const COMBO_KEEP := 3.0
const MARK_TAGS: Array[StringName] = [&"mark", &"cross"]
const EMBER_TAGS: Array[StringName] = [&"ember", &"chama"]
const HOLY_TAGS: Array[StringName] = [&"skill", &"vigilia"]
const SHATTER_SPLASH := 0.4
## Stars drawn per swing (the rest of the crowd hit only flashes).
const MAX_STARS := 8
const SHATTER_RADIUS := 2.2
const BURN_TIME := 3.0
const FIRE := Color(1.0, 0.45, 0.12)
const FROST := Color(0.5, 0.82, 1.0)
const LIGHT := Color(1.0, 0.82, 0.38)

var horde: Horde
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var boons: BoonState
var combo := 0
var best_combo := 0
var damage_dealt := 0.0
var _combo_t := 0.0
var _hits: Array[Enemy] = []
var _near: Array[Enemy] = []
var _swing := 0


func step(dt: float) -> void:
	if combo > 0:
		_combo_t -= dt
		if _combo_t <= 0.0:
			drop_combo()


func drop_combo() -> void:
	if combo != 0:
		combo = 0
		combo_changed.emit(0)


## A move of the combo tree lands.
func strike(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	_swing += 1
	var tags := node.tags
	var reach := node.reach * (1.0 + boons.stat(&"reach_pct", tags))
	var color := color_of(tags)
	var heavy := node.has_tag(&"heavy")
	match node.shape:
		ComboNode.Shape.ARC:
			horde.in_arc(origin, dir, reach, node.width, _hits)
			fx.slash(origin, dir, reach, node.width, color, 0.2 if heavy else 0.16, _swing % 2 == 0)
		ComboNode.Shape.CIRCLE:
			horde.in_circle(origin, reach, _hits)
			fx.slash(origin, dir, reach, 359.0, color, 0.24, _swing % 2 == 0)
			fx.ring(origin, reach * 1.1, color, 0.35)
		ComboNode.Shape.LINE:
			horde.in_line(origin, dir, reach, node.width, _hits)
			fx.slash(origin + dir * reach * 0.15, dir, reach * 0.85, 22.0, color, 0.18)
	var struck := _hits.duplicate()
	var stars := 0
	for e: Enemy in struck:
		var away := (e.pos - origin).normalized() if node.shape == ComboNode.Shape.CIRCLE else dir
		if stars < MAX_STARS:
			stars += 1
			fx.impact(Vector3(e.pos.x, 1.0 + e.y, e.pos.y) - Vector3(away.x, 0, away.y) * 0.3, color, 1.4 if heavy else 1.0)
		var died := hit_enemy(e, node.damage, tags, away, node.knockback, true, node.has_tag(&"finisher"))
		if died:
			continue
		match node.effect:
			ComboNode.Effect.LAUNCH:
				if not e.def.heavy:
					e.air_t = node.effect_time
					e.air_total = node.effect_time
			ComboNode.Effect.STUN:
				if e.def.behavior != EnemyDef.Behavior.BOSS:
					e.stun_t = maxf(e.stun_t, node.effect_time * (0.5 if e.def.heavy else 1.0))
	if struck.is_empty():
		Audio.play(&"swing")
	else:
		fx.hit_stop(node.hit_stop_ms * Feel.live().hit_stop_scale + minf(struck.size(), 8) * 4.0)
		fx.shake(node.shake * (1.0 + minf(struck.size(), 10) * 0.05))
		fx.kick(dir, 1.6 if heavy else 0.9)
		if node.has_tag(&"finisher"):
			fx.kick_split(0.5)
		Audio.play(&"hit_heavy" if heavy else &"hit")
	match node.effect:
		ComboNode.Effect.GROUND_MARK:
			ground.add_zone(Ground.Kind.MARK, origin + dir * reach * 0.55, node.effect_radius, node.effect_time, node.effect_power, MARK_TAGS)
		ComboNode.Effect.WAVE:
			var size := 1.0 + boons.stat(&"wave_size_pct", tags)
			projectiles.fire_wave(Projectiles.Kind.WAVE, origin + dir * 0.8, dir, node.effect_power, node.effect_radius * size, 3.2 * size, color, tags)
		ComboNode.Effect.STUN:
			fx.burst(&"light", Vector3(origin.x, 0.4, origin.y))


## A friendly projectile (wave or light blade) touched an enemy.
func on_shot_hit(e: Enemy, shot: Projectiles.Shot) -> void:
	hit_enemy(e, shot.damage, shot.tags, shot.vel.normalized(), shot.knockback, false)
	_apply_status(e, shot.status, shot.status_power)


func on_zone_hit(e: Enemy, z: Ground.Zone) -> void:
	match z.kind:
		Ground.Kind.MARK:
			hit_enemy(e, z.power * Ground.TICK, MARK_TAGS, Vector2.ZERO, 0.0, false)
		Ground.Kind.EMBER:
			hit_enemy(e, z.power * Ground.TICK, EMBER_TAGS, Vector2.ZERO, 0.0, false)
			_burn(e, z.power)
		Ground.Kind.HOLY:
			hit_enemy(e, z.power * Ground.TICK, HOLY_TAGS, Vector2.ZERO, 0.0, false)
			e.slow_t = maxf(e.slow_t, 0.5)
		Ground.Kind.STEAM:
			if not e.def.heavy:
				e.blind_t = 1.0


## A gift's skill hits an enemy: damage plus the skill's own status (burn, freeze, stun, slow).
func skill_hit(e: Enemy, damage: float, tags: Array[StringName], away: Vector2, knockback: float, status: StringName, power: float) -> bool:
	var died := hit_enemy(e, damage, tags, away, knockback, false)
	if not died:
		_apply_status(e, status, power)
	return died


func _apply_status(e: Enemy, status: StringName, power: float) -> void:
	if power <= 0.0 or not e.alive:
		return
	match status:
		&"burn":
			_burn(e, power)
		&"freeze":
			_freeze(e, power)
		&"stun":
			if e.def.behavior != EnemyDef.Behavior.BOSS:
				e.stun_t = maxf(e.stun_t, power * (0.5 if e.def.heavy else 1.0))
		&"slow":
			e.slow_t = maxf(e.slow_t, power)


## One enemy takes one hit, with every gift applied. counts: it is a blow of the paladin (feeds the combo counter).
## Returns true when it died.
func hit_enemy(e: Enemy, base: float, tags: Array[StringName], away: Vector2, knockback: float, counts: bool = true, big: bool = false) -> bool:
	var frozen := e.frozen_t > 0.0
	var shatter := boons.stat(&"shatter_pct") if frozen and counts else 0.0
	var dmg := DamageCalc.hit(base, boons.stat(&"damage_pct", tags), combo, e.air_t > 0.0, frozen and shatter > 0.0, shatter, e.def.undead, boons.stat(&"undead_mult"))
	var color := color_of(tags)
	var died := horde.damage(e, dmg, away, knockback, color, true, big)
	damage_dealt += dmg
	enemy_struck.emit(e, tags, dmg)
	if counts:
		combo += 1
		best_combo = maxi(best_combo, combo)
		_combo_t = COMBO_KEEP
		combo_changed.emit(combo)
		fx.burst(&"spark", Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(away.x, 0, away.y))
	if shatter > 0.0:
		e.frozen_t = 0.0
		fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
		fx.ring(e.pos, SHATTER_RADIUS, FROST, 0.3)
		horde.in_circle(e.pos, SHATTER_RADIUS, _near)
		for other in _near.duplicate():
			if other != e:
				horde.damage(other, maxf(1.0, roundf(dmg * SHATTER_SPLASH)), (other.pos - e.pos).normalized(), 5.0, FROST)
	if died:
		return true
	var burn := boons.stat(&"burn_dps", tags)
	if burn > 0.0:
		_burn(e, burn)
	var freeze := boons.stat(&"freeze_time", tags)
	if freeze > 0.0 and shatter <= 0.0:
		_freeze(e, freeze)
	return false


func _freeze(e: Enemy, time: float) -> void:
	if e.def.behavior == EnemyDef.Behavior.BOSS:
		return
	if e.burn_t > 0.0:
		_steam(e)
	e.frozen_t = maxf(e.frozen_t, time * (0.4 if e.def.heavy else 1.0))
	fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))


func _burn(e: Enemy, dps: float) -> void:
	if e.frozen_t > 0.0:
		_steam(e)
	e.burn_t = BURN_TIME
	e.burn_dps = maxf(e.burn_dps, dps)


## Flame meeting frost: a cloud of steam that blinds whoever stands in it.
func _steam(e: Enemy) -> void:
	var time := boons.stat(&"steam_time")
	if time > 0.0:
		ground.add_zone(Ground.Kind.STEAM, e.pos, 2.8, time, 0.0)
		fx.burst(&"dust", Vector3(e.pos.x, 0.8, e.pos.y))


## The colour of a blow: the family of the gift that changes it, gold when none does.
func color_of(tags: Array[StringName]) -> Color:
	if tags.has(&"chama") or tags.has(&"ember") or boons.stat(&"burn_dps", tags) > 0.0:
		return FIRE
	if tags.has(&"geada") or boons.stat(&"freeze_time", tags) > 0.0:
		return FROST
	return LIGHT
