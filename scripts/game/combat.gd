class_name Combat
extends RefCounted
## Resolves what the paladin's moves and gifts do to the enemies: who is hit, how hard, which effects apply.

signal combo_changed(count: int)
signal enemy_struck(e: Enemy, tags: Array[StringName], damage: float)
## Every swing of the combo, after its hits (struck: how many it reached); captures freeze on it (--shot-on).
signal swung(node: ComboNode, struck: int)

const COMBO_KEEP := 3.0
## Extra hit slow when a blow kills (Hades II: 0.04 s).
const KILL_HOLD_MS := 40.0
## Slow motion in a fight is rare, as in Hades II (there only the last kill of a room and a boss's death slow the
## world; a blow only gets a few hundredths of a second of hit slow): a blow that fells SLOW_MO_KILLS at once or
## lands on SLOW_MO_CROWD, at most once every SLOW_MO_COOLDOWN seconds. Speed, seconds held, seconds back.
const SLOW_MO_KILLS := 3
const SLOW_MO_CROWD := 7
const SLOW_MO_COOLDOWN := 6.0
const SLOW_MO_FRACTION := 0.2
const SLOW_MO_HOLD := 0.12
const SLOW_MO_OUT := 0.25
const HIT_SLOW_COOLDOWN := 0.3
const MARK_TAGS: Array[StringName] = [&"mark", &"cross"]
const EMBER_TAGS: Array[StringName] = [&"ember", &"chama"]
const HOLY_TAGS: Array[StringName] = [&"skill", &"vigilia"]
## The circle of light (cast): what gifts see, its size, how long it holds, and the burst of the held version.
const CAST_TAGS: Array[StringName] = [&"cast"]
const CAST_RADIUS := 5.4
const CAST_TIME := 3.0
const CAST_BURST := 150.0
const CAST_COLOR := Color(1.0, 0.95, 0.8)
const SHATTER_SPLASH := 0.4
## Degrees of the narrow arc drawn for a thrust.
const LINE_ARC := 22.0
## Cuts drawn per swing (the rest of the crowd hit only flashes).
const MAX_STARS := 8
## The cut a blow leaves on each one it lands on (Fx.gash): meters long (a common blow draws from the first to the
## second, a finisher the second, a heavy blow GASH_HEAVY with a second streak across), radians it may lean out of
## the floor plane, seconds it lasts, and the chips that fly off it.
const GASH := Vector2(0.9, 1.4)
const GASH_HEAVY := 1.8
const GASH_LEAN := 0.5
const GASH_TIME := Vector2(0.16, 0.18)
const GASH_CHIPS := Vector2i(4, 6)
## The special lands as a thrust: a streak this long along its flight.
const STAB := 1.2
## A finisher that lands adds one thin ring, once per blow: meters it grows to, seconds it lasts.
const FINISHER_RING := 1.5
const FINISHER_RING_TIME := 0.2
## Motes of magic shed from the tip of each swing, the way the blade turns (one in four is old gold).
const SWING_MOTES := Vector2i(4, 8)
## The colour split of the screen, only on a finisher that lands (Fx.kick_split).
const FINISHER_SPLIT := 0.5
const SHATTER_RADIUS := 2.2
## Where a finisher's glint shows when there is no blade to follow: meters in front of the paladin, height.
const GLINT_AHEAD := 0.6
const GLINT_HEIGHT := 1.8
## Seconds the arc of a blow stays bright: a common one, a heavy one, a finisher.
const SLASH_TIME := 0.12
const HEAVY_SLASH_TIME := 0.16
const FINISHER_SLASH_TIME := 0.3
## A finisher flashes the impact frame when it strikes at least this many enemies (or an elite, or the boss).
const IMPACT_FRAME_CROWD := 6
const BURN_TIME := 3.0
const FIRE := Color(1.0, 0.45, 0.12)
const FROST := Color(0.5, 0.82, 1.0)
## Elun's gold: only blows that come from gifts.
const LIGHT := Color(1.0, 0.82, 0.38)
## The paladin's own sword, Emeth: the green of its blade.
const EMETH := Color(0.3, 1.0, 0.45)
## Damage numbers of the sword's common blows: pale, so the emerald ones (finishers, held blows) stand out.
const NUMBER_PALE := UiKit.PALE
## Tags that mark a blow as coming from a gift (skills carry "skill" and their family's tag).
const GIFT_TAGS: Array[StringName] = [&"skill", &"luz", &"vigilia", &"duo"]

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
var _behind: Array[Enemy] = []
var _slow_cd := 0.0
var _cine_cd := 0.0
## Only for what is drawn (how long a cut is, how many chips): never the game's own draw.
var _look := RandomNumberGenerator.new()


func _init() -> void:
	Dev.seed_rng(_look, 7)


func step(dt: float) -> void:
	_slow_cd = maxf(0.0, _slow_cd - dt)
	_cine_cd = maxf(0.0, _cine_cd - dt)
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
	var shape := swing_shape(node, boons.stat(&"reach_pct", tags))
	var reach: float = shape.hit_reach
	var color := color_of(tags)
	var heavy := node.has_tag(&"heavy")
	var finisher := node.has_tag(&"finisher")
	match node.shape:
		ComboNode.Shape.ARC:
			horde.in_arc(origin, dir, reach, shape.hit_width, _hits)
		ComboNode.Shape.CIRCLE:
			horde.in_circle(origin, reach, _hits)
			if not finisher:
				# (a finisher's crescent is the ring flying out: one circle, not rings inside rings)
				fx.ring(origin, reach, color, 0.35, 0.15, true)
		ComboNode.Shape.LINE:
			horde.in_line(origin, dir, reach, node.width, _hits)
			if node.both_ways:
				horde.in_line(origin, -dir, reach, node.width, _behind)
				for e in _behind:
					if not _hits.has(e):
						_hits.append(e)
	var flip := node.sweep_flip(_swing % 2 == 0)
	if node.damage <= 0.0:
		_hits.clear()
	else:
		_draw_swing(node, shape, origin, dir, color, heavy, finisher, flip)
	var struck: Array[Enemy] = _hits.duplicate()
	var stars := 0
	var kills := 0
	for e: Enemy in struck:
		var away := (e.pos - origin).normalized() if node.shape == ComboNode.Shape.CIRCLE else dir if (e.pos - origin).dot(dir) >= 0.0 else -dir
		if stars < MAX_STARS:
			stars += 1
			_draw_hit(e, cut_axis(node.shape, origin, e.pos, away, flip), away, color, heavy, finisher)
		var died := hit_enemy(e, node.damage, tags, away, node.knockback, true, finisher)
		if heavy:
			e.flash_power = 1.0  # a strong blow: pure white for a frame or two
		if died:
			kills += 1
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
		# Hades II holds the hit slow a little longer when the blow kills
		_hit_slow(node.hit_stop_ms + (KILL_HOLD_MS if kills > 0 else 0.0))
		if _cine_cd <= 0.0 and wants_slow_mo(struck.size(), kills):
			_cine_cd = SLOW_MO_COOLDOWN
			fx.slow_mo(SLOW_MO_FRACTION, SLOW_MO_HOLD, SLOW_MO_OUT, 1.05, 0.45)
		fx.shake(node.shake * (1.0 + minf(struck.size(), 10) * 0.05))
		fx.kick(dir, 1.6 if heavy else 0.9)
		if finisher:
			fx.kick_split(FINISHER_SPLIT)
			fx.ring(struck[0].pos, FINISHER_RING, color, FINISHER_RING_TIME, 1.0 + struck[0].y, true)
			if big_strike(struck):
				fx.impact_frame()
		Audio.play(&"hit_heavy" if heavy else &"hit")
	match node.effect:
		ComboNode.Effect.GROUND_MARK:
			ground.add_zone(Ground.Kind.MARK, origin + dir * reach * 0.55, node.effect_radius, node.effect_time, node.effect_power, MARK_TAGS)
		ComboNode.Effect.WAVE:
			var size := 1.0 + boons.stat(&"wave_size_pct", tags)
			var width := node.effect_size if node.effect_size > 0.0 else 3.2
			var look := Projectiles.Kind.SPARK if node.wave_bolt else Projectiles.Kind.WAVE
			projectiles.fire_wave(look, origin + dir * 0.8, dir, node.effect_power, node.effect_radius * size, width * size, color, tags)
		ComboNode.Effect.STUN:
			fx.burst(&"light", Vector3(origin.x, 0.4, origin.y))
	swung.emit(node, struck.size())


## What a swing shows whether it lands or not: the ribbon of the arc (a thin beam for a thrust), the motes off its
## tip, the pulse of the blade and, for a finisher, the crescent flying out.
func _draw_swing(node: ComboNode, shape: Dictionary, origin: Vector2, dir: Vector2, color: Color, heavy: bool, finisher: bool, flip: bool) -> void:
	var spin := node.shape == ComboNode.Shape.CIRCLE
	var time := FINISHER_SLASH_TIME if finisher else HEAVY_SLASH_TIME if heavy else SLASH_TIME
	var reach: float = shape.draw_reach
	var motes := _look.randi_range(SWING_MOTES.x, SWING_MOTES.y)
	fx.blade_pulse()
	if node.shape == ComboNode.Shape.LINE:
		# a thrust: straight, as wide as it reaches, never the arc of a cut
		for way: Vector2 in ([dir, -dir] if node.both_ways else [dir]):
			fx.thrust(origin, way, reach, node.width, color, time)
			var tip := origin + way * reach * 0.9
			fx.chips(Vector3(tip.x, 0.9, tip.y), Vector3(way.x, 0.2, way.y), color, motes, 4.0, 0.12, 0.4, 0.5, Fx.MOTE_GOLD_EVERY)
	else:
		# a turn all around: a clean sweep of light (a dark ring that size reads as a hole in the floor)
		fx.slash(origin, dir, reach, shape.draw_width, color, time, flip, 0.9, not spin)
		# the motes leave the end of the arc the way the blade was turning
		var turn := -1.0 if flip else 1.0
		var end := dir.angle() - turn * deg_to_rad(minf(shape.draw_width, 300.0)) * 0.5
		var tip := origin + Vector2.from_angle(end) * reach * 0.92
		var onward := Vector2.from_angle(end - turn * PI * 0.5)
		fx.chips(Vector3(tip.x, 0.9, tip.y), Vector3(onward.x, 0.25, onward.y), color, motes, 5.0, 0.12, 0.4, 0.5, Fx.MOTE_GOLD_EVERY)
	if finisher:
		# the sweep of the blade flying out past the blow (all the way around for a spin)
		fx.crescent(origin, dir, reach, 360.0 if spin else maxf(shape.draw_width, 120.0), color)


## What one enemy shows when a blow lands on it: the cut along the way the blade was moving and the chips flying
## away from the paladin. Only called from the loop of those really hit.
func _draw_hit(e: Enemy, axis: Vector2, away: Vector2, color: Color, heavy: bool, finisher: bool) -> void:
	var at := Vector3(e.pos.x, 1.0 + e.y, e.pos.y) - Vector3(away.x, 0, away.y) * 0.3
	var lean := tan(_look.randf_range(-GASH_LEAN, GASH_LEAN))
	var length := GASH_HEAVY if heavy else GASH.y if finisher else _look.randf_range(GASH.x, GASH.y)
	fx.gash(at, Vector3(axis.x, lean, axis.y), color, length, heavy, GASH_TIME.y if heavy or finisher else GASH_TIME.x)
	fx.chips(at, Vector3(away.x, 0.35, away.y), color, _look.randi_range(GASH_CHIPS.x, GASH_CHIPS.y), 7.0, 0.1, 0.35, 0.7)


## The way the blade was moving where it met an enemy, on the floor plane: along the thrust for a line, across the
## line from the paladin for an arc or a spin (so two enemies on opposite sides of the arc are cut at different
## angles). flip: the arc's sweep (Fx.slash).
static func cut_axis(shape: ComboNode.Shape, origin: Vector2, at: Vector2, away: Vector2, flip: bool) -> Vector2:
	if shape == ComboNode.Shape.LINE:
		return away
	var out := at - origin
	if out.length_squared() < 0.0001:
		out = away
	out = out.normalized()
	return Vector2(-out.y, out.x) if flip else Vector2(out.y, -out.x)


## The brief slow on a hit (Hades II slows the world for a few hundredths of a second instead of freezing it; at
## these lengths a freeze reads the same). One slow at most every HIT_SLOW_COOLDOWN seconds.
func _hit_slow(ms: float) -> void:
	if _slow_cd > 0.0 or ms <= 0.0:
		return
	_slow_cd = HIT_SLOW_COOLDOWN
	fx.hit_stop(ms * Feel.live().hit_stop_scale)


## A finisher holds at the top of its swing: the blade gathers light (Fx.glint) and bursts when it lands.
## tip: the point of the sword to follow (none: a point in front of the paladin).
func glint(node: ComboNode, origin: Vector2, dir: Vector2, time: float, tip: Node3D = null) -> void:
	var at := origin + dir * GLINT_AHEAD
	fx.glint(Vector3(at.x, GLINT_HEIGHT, at.y), color_of(node.tags), time, tip)


## A finisher earns the impact frame when it strikes a crowd, an elite or the boss.
## A blow big enough for slow motion: it fells several at once or lands on a crowd.
static func wants_slow_mo(struck: int, kills: int) -> bool:
	return kills >= SLOW_MO_KILLS or struck >= SLOW_MO_CROWD


static func big_strike(struck: Array[Enemy]) -> bool:
	if struck.size() >= IMPACT_FRAME_CROWD:
		return true
	for e in struck:
		if e.def.elite or e.def.behavior == EnemyDef.Behavior.BOSS:
			return true
	return false


## The paladin lets go of the circle of light at a point. omega: the held version, which bursts when it ends.
func cast(at: Vector2, omega: bool) -> void:
	var radius := CAST_RADIUS * (1.0 + boons.stat(&"cast_size_pct"))
	var z := ground.add_zone(Ground.Kind.BIND, at, radius, CAST_TIME, boons.stat(&"cast_dps", CAST_TAGS), CAST_TAGS)
	if omega:
		z.burst = CAST_BURST * (1.0 + boons.stat(&"damage_pct", CAST_TAGS))
	fx.ring(at, radius, CAST_COLOR, 0.3)
	fx.burst(&"light", Vector3(at.x, 0.4, at.y))
	Audio.play(&"charged" if omega else &"swing")


## The held circle of light runs out: everything inside takes the burst.
func cast_burst(z: Ground.Zone) -> void:
	horde.in_circle(z.pos, z.radius, _hits)
	fx.ring(z.pos, z.radius * 1.1, CAST_COLOR, 0.3)
	fx.chips(Vector3(z.pos.x, 0.6, z.pos.y), Vector3.UP, CAST_COLOR, 12, 7.0, 0.12, 0.4, 1.3)
	fx.shake(2.0)
	for e: Enemy in _hits.duplicate():
		var away := (e.pos - z.pos).normalized() if e.pos.distance_to(z.pos) > 0.01 else Vector2.RIGHT
		hit_enemy(e, z.burst, z.tags, away, 10.0, true, true)
	Audio.play(&"hit_heavy")


## A friendly projectile (wave or light blade) touched an enemy.
func on_shot_hit(e: Enemy, shot: Projectiles.Shot) -> void:
	var along := shot.vel.normalized()
	if shot.kind != Projectiles.Kind.BLADE and shot.seen.size() <= MAX_STARS:
		# the special lands as a thrust: a streak along its flight
		var at := Vector3(e.pos.x, 1.0 + e.y, e.pos.y)
		fx.gash(at, Vector3(along.x, 0.0, along.y), shot.color, STAB, false, GASH_TIME.y)
		fx.chips(at, Vector3(along.x, 0.3, along.y), shot.color, GASH_CHIPS.x, 7.0, 0.1, 0.35, 0.6)
	hit_enemy(e, shot.damage, shot.tags, along, shot.knockback, false)
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
		Ground.Kind.BIND:
			# held in place (the boss only slowed), plus whatever the cast gifts add
			if e.def.behavior == EnemyDef.Behavior.BOSS:
				e.slow_t = maxf(e.slow_t, Ground.TICK * 2.0)
			else:
				e.stun_t = maxf(e.stun_t, Ground.TICK + 0.05)
			if z.power > 0.0:
				hit_enemy(e, z.power * Ground.TICK, z.tags, Vector2.ZERO, 0.0, false)
			else:
				var burn := boons.stat(&"burn_dps", z.tags)
				if burn > 0.0:
					_burn(e, burn)
				var freeze := boons.stat(&"freeze_time", z.tags)
				if freeze > 0.0 and e.frozen_t <= 0.0:
					_freeze(e, freeze)


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
	var died := horde.damage(e, dmg, away, knockback, number_color(tags, big), true, big)
	damage_dealt += dmg
	enemy_struck.emit(e, tags, dmg)
	if counts:
		combo += 1
		best_combo = maxi(best_combo, combo)
		_combo_t = COMBO_KEEP
		combo_changed.emit(combo)
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


## The colour of a blow: the family of the gift that changes it; Elun's gold for the other gifts; the green of
## the sword when no gift touches it.
func color_of(tags: Array[StringName]) -> Color:
	if tags.has(&"chama") or tags.has(&"ember") or boons.stat(&"burn_dps", tags) > 0.0:
		return FIRE
	if tags.has(&"geada") or boons.stat(&"freeze_time", tags) > 0.0:
		return FROST
	for t in GIFT_TAGS:
		if tags.has(t):
			return LIGHT
	return EMETH


## The colour of a damage number: the gift's own (fire, frost, Elun's gold); for the sword alone, its emerald only
## on the big blows (finishers and the held ones), pale on the rest.
func number_color(tags: Array[StringName], big: bool) -> Color:
	var color := color_of(tags)
	if color != EMETH:
		return color
	return EMETH if big or tags.has(&"omega") else NUMBER_PALE


## Where a move hits and what is drawn for it. The arc on screen covers exactly what the blow reaches
## (tests/test_combo.gd checks every move of the tree). reach_pct: the gifts' bonus to reach.
static func swing_shape(node: ComboNode, reach_pct: float) -> Dictionary:
	var reach := node.reach * (1.0 + reach_pct)
	match node.shape:
		ComboNode.Shape.CIRCLE:
			return {"hit_reach": reach, "hit_width": 360.0, "draw_reach": reach, "draw_width": 360.0}
		ComboNode.Shape.LINE:
			# a thrust: a narrow arc whose tip is the end of the line (width is meters across, not degrees)
			return {"hit_reach": reach, "hit_width": node.width, "draw_reach": reach, "draw_width": LINE_ARC}
	return {"hit_reach": reach, "hit_width": node.width, "draw_reach": reach, "draw_width": node.width}
