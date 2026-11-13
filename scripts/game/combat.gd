class_name Combat
extends RefCounted
## Resolves what the paladin's moves do to the enemies: who is hit, how hard, which effects and gifts apply.

signal combo_changed(count: int)
signal enemy_struck(e: Enemy, tags: Array[StringName], damage: float)

const COMBO_KEEP := 3.0
const SWING_UP := Vector2(0, -8)
const MARK_TAGS: Array[StringName] = [&"mark", &"cross"]
const EMBER_TAGS: Array[StringName] = [&"ember"]
const SHATTER_SPLASH := 0.4
const BURN_TIME := 3.0

var enemies: EnemySystem
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
var _wave_tags: Array[StringName] = []


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
	var family := family_of(tags)
	match node.shape:
		ComboNode.Shape.ARC:
			enemies.in_arc(origin, dir, reach, node.width, _hits)
			fx.slash(origin + SWING_UP, dir, reach, node.width, family, 0.16, _swing % 2 == 0)
		ComboNode.Shape.CIRCLE:
			enemies.in_circle(origin, reach, _hits)
			fx.ring(origin + SWING_UP * 0.5, reach, family)
		ComboNode.Shape.LINE:
			enemies.in_line(origin, dir, reach, node.width, _hits)
			fx.streak(origin + SWING_UP, dir, reach, node.width, family)
	var struck := _hits.duplicate()
	for e: Enemy in struck:
		var away := (e.pos - origin).normalized() if node.shape == ComboNode.Shape.CIRCLE else dir
		var died := hit_enemy(e, node.damage, tags, away, node.knockback)
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
		fx.hit_stop(node.hit_stop_ms)
		fx.shake(node.shake)
		Audio.play(&"hit_heavy" if node.has_tag(&"heavy") else &"hit")
	match node.effect:
		ComboNode.Effect.GROUND_MARK:
			ground.add_zone(Ground.Kind.MARK, origin + dir * reach * 0.55, node.effect_radius, node.effect_time, node.effect_power, family)
		ComboNode.Effect.WAVE:
			var size := 1.0 + boons.stat(&"wave_size_pct", tags)
			_wave_tags = tags
			projectiles.fire_wave(origin + SWING_UP, dir, node.effect_power, node.effect_radius * size, 15.0 * size, family)
	var whirl := boons.stat(&"whirl_dps", tags)
	if whirl > 0.0:
		ground.add_zone(Ground.Kind.EMBER, origin, reach, 3.0, whirl, &"perigo")


func on_wave_hit(e: Enemy, shot: Projectiles.Shot) -> void:
	hit_enemy(e, shot.damage, _wave_tags, shot.vel.normalized(), shot.knockback)


func on_zone_hit(e: Enemy, z: Ground.Zone) -> void:
	match z.kind:
		Ground.Kind.MARK:
			hit_enemy(e, z.power * Ground.TICK, MARK_TAGS, Vector2.ZERO, 0.0, false)
		Ground.Kind.EMBER:
			hit_enemy(e, z.power * Ground.TICK, EMBER_TAGS, Vector2.ZERO, 0.0, false)
			_burn(e, z.power)
		Ground.Kind.STEAM:
			if not e.def.heavy:
				e.blind_t = 1.0


## One enemy takes one hit, with every gift applied. Returns true when it died.
func hit_enemy(e: Enemy, base: float, tags: Array[StringName], away: Vector2, knockback: float, counts: bool = true) -> bool:
	var frozen := e.frozen_t > 0.0
	var shatter := boons.stat(&"shatter_pct") if frozen and counts else 0.0
	var dmg := DamageCalc.hit(base, boons.stat(&"damage_pct", tags), combo, e.air_t > 0.0, frozen and shatter > 0.0, shatter, e.def.undead, boons.stat(&"undead_mult"))
	var family := family_of(tags)
	var died := enemies.damage(e, dmg, away, knockback, family)
	damage_dealt += dmg
	enemy_struck.emit(e, tags, dmg)
	if counts:
		combo += 1
		best_combo = maxi(best_combo, combo)
		_combo_t = COMBO_KEEP
		combo_changed.emit(combo)
		fx.burst(&"spark", e.pos + SWING_UP, away)
	if shatter > 0.0:
		e.frozen_t = 0.0
		fx.burst(&"frost", e.pos + SWING_UP)
		enemies.in_circle(e.pos, 18.0, _near)
		for other in _near:
			if other != e:
				enemies.damage(other, maxf(1.0, roundf(dmg * SHATTER_SPLASH)), (other.pos - e.pos).normalized(), 30.0, &"noite")
	if died:
		return true
	var burn := boons.stat(&"burn_dps", tags)
	if burn > 0.0:
		_burn(e, burn)
	var ember := boons.stat(&"ember_dps", tags)
	if ember > 0.0 and counts:
		ground.add_zone(Ground.Kind.EMBER, e.pos, 9.0, 2.5, ember, &"perigo")
	var freeze := boons.stat(&"freeze_time", tags)
	if freeze > 0.0 and shatter <= 0.0 and e.def.behavior != EnemyDef.Behavior.BOSS:
		if e.burn_t > 0.0:
			_steam(e)
		e.frozen_t = freeze * (0.4 if e.def.heavy else 1.0)
		fx.burst(&"frost", e.pos + SWING_UP)
	return false


func _burn(e: Enemy, dps: float) -> void:
	if e.frozen_t > 0.0:
		_steam(e)
	e.burn_t = BURN_TIME
	e.burn_dps = maxf(e.burn_dps, dps)


## Flame meeting frost: a cloud of steam that blinds whoever stands in it.
func _steam(e: Enemy) -> void:
	var time := boons.stat(&"steam_time")
	if time > 0.0:
		ground.add_zone(Ground.Kind.STEAM, e.pos, 26.0, time, 0.0, &"neve")


## The colour a move shows: the family of the gift that changes it, gold when none does.
func family_of(tags: Array[StringName]) -> StringName:
	if tags.has(&"ember") or boons.stat(&"ember_dps", tags) > 0.0 or boons.stat(&"burn_dps", tags) > 0.0 or boons.stat(&"whirl_dps", tags) > 0.0:
		return &"perigo"
	if boons.stat(&"freeze_time", tags) > 0.0:
		return &"noite"
	return &"luz"
