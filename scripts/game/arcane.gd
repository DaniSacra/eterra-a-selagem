class_name Arcane
extends Node3D
## The Maga's kit in play (docs/design/heroes/maga.md; HeroDef.arcane): the Selo on the enemies, the Explosão Rúnica
## that detonates it, the Círculo de Contenção, the Suspensão Arcana and the Ressonância. The numbers are ArcaneKit's, the
## rules SealBook and Resonance (pure, tested); this node does what they answer in the room. Her shots go through
## Combat.on_shot_hit (shot_landed), her spells through the combo tree's effects (cast), the Tempestade through
## Ultimates (lay, detonate). Nothing here draws with a new shader: flat unlit pieces in amber and ivory (maga.md 2.4).

const AMBER := Color(1.0, 0.62, 0.18)
const IVORY := Color(0.95, 0.88, 0.7)
const GOLD := Color(0.95, 0.72, 0.3)
## The Selo's glyph: a hexagon over the head, its radius, height over the floor, turn (rad/s).
const GLYPH_RADIUS := 0.24
const GLYPH_HEIGHT := 2.4
const GLYPH_SPIN := 1.4
## The Círculo's six sigils: their size, and the seconds they blink at the end.
const SIGILS := 6
const SIGIL_RADIUS := 0.3
const SIGIL_BLINK := 0.8
## How far ahead of her a spell falls when she has no mouse and nothing is near, as a share of the kit's range.
const AHEAD_SHARE := 0.6
## The half angle (degrees) of the cone in which a stick or the robot finds the Selo to detonate, and the furthest one.
const CONE := 65.0
## What the Círculo's tags are (the Blessings and Gifts that read the Q's size, burn and so on count on them), and the Passo's flash.
const CIRCLE_TAGS: Array[StringName] = [&"shout", &"cast", &"arcane"]
const STEP_TAGS: Array[StringName] = [&"dash", &"arcane", &"blink"]
## Brasa Viva's burn spreads this far from the Selo detonated; the Ruptura's leap and the Passo de Brasa's flash reach this far (m).
const SEAL_BURN_SPREAD := 1.5
const LEAP_RANGE := 4.0
## How long the Selo a leap lays lives (s).
const LEAP_SECONDS := 4.0
const FLASH_RADIUS := 2.2
## The Passo de Brasa's embers where she lands: radius, seconds, damage a second (and the burn it sets).
const STEP_EMBERS := Vector3(1.2, 2.0, 4.0)
const STEP_BURN := 4.0
## The Brasa Gêmea's second blast comes this long after the first (s).
const TWIN_DELAY := 0.5
## The Suspensão Absoluta blinks its last seconds.
const ULTRA_BLINK := 2.0

class Circle:
	var at := Vector2.ZERO
	var life := 0.0
	var pull_left := 0.0
	var refunded := 0.0
	var pulled: Array[Enemy] = []
	var sigils: Array[MeshInstance3D] = []
	## The pull is over: the Gifts that act when it closes have acted (Prisão Sigilada, Selo no Chão, Brasa que Prende, the Blessings).
	var closed := false

class Dome:
	var life := 0.0
	var radius := 2.6
	## The move's tags (the Blessings of the E act on whoever comes in: touched is who they already did).
	var tags: Array[StringName] = []
	var touched: Dictionary = {}
	var node: MeshInstance3D
	var held: Array[Projectiles.Shot] = []

## The Brasa Gêmea's second blast, waiting.
class Twin:
	var left := 0.5
	var at := Vector2.ZERO
	var radius := 3.2
	var share := 0.5
	var amplified := false
	var tags: Array[StringName] = []
	## What the first blast did to each enemy it hit (the second does a share of it).
	var first: Dictionary = {}

var game: Game
var kit: ArcaneKit
var seals: SealBook
var resonance: Resonance
var circle: Circle
var dome: Dome
## The Suspensão Absoluta (the second ultimate) and its numbers; null when it is not up.
var ultra: Dome
var ultra_def: UltDef
var _twins: Array[Twin] = []
## Where the last Explosão fell (a Blessing's skill of the special falls there; INF: none this room) and where the Círculo stands.
var last_blast := Vector2.INF
## What the kit did in this run (RESULT arcane).
var tally := {"seals": 0, "blasts": 0, "amplified": 0, "detonated": 0, "circles": 0, "domes": 0, "held": 0, "storm_seals": 0, "ultras": 0, "twins": 0, "leaps": 0}
var _glyphs: Dictionary = {}
var _boss_gap := 0.0
var _turn := 0.0
var _found: Array[Enemy] = []
var _near: Array[Enemy] = []
var _unlit: StandardMaterial3D


func setup(g: Game) -> void:
	game = g
	kit = g.hero.arcane
	seals = SealBook.new(kit.seal_time, kit.seal_cap)
	resonance = Resonance.new(kit.resonance_max)
	g.player.dodged.connect(_on_dodged)


## A new room (or the run's end): the Selos, the Círculo and the Suspensão go (the Ressonância stays: it zeroes with the descent).
func clear() -> void:
	seals.clear()
	for e in _glyphs.keys():
		_drop_glyph(e)
	_end_circle()
	_end_dome()
	_end_ultra()
	_twins.clear()
	last_blast = Vector2.INF


## A Gift's or a Blessing's number for this hero now (BoonState.stat; the tags limit it to the moves that carry them).
func _stat(stat_name: StringName, tags: Array[StringName] = []) -> float:
	return game.boons.stat(stat_name, tags)


func step(dt: float) -> void:
	var p := game.player
	p.free_special = resonance.full()
	_boss_gap = maxf(0.0, _boss_gap - dt)
	_turn += dt * GLYPH_SPIN
	for e: Enemy in seals.keys():
		if not e.alive:
			seals.forget(e)
	seals.cap = kit.seal_cap + int(_stat(&"seal_cap"))  # (Selo Duplo)
	p.blast_discount = _ultra_discount() if ultra != null else 0.0
	seals.step(dt, func(e: Enemy) -> bool: return _in_circle(e.pos) or _in_dome(e.pos) or _in_ultra(e.pos))
	_step_glyphs()
	_step_circle(dt)
	_step_dome(dt)
	_step_ultra(dt)
	_step_twins(dt)


# ---------- the Selo ----------

## A shot of hers touched an enemy (Combat.on_shot_hit): the Magia of the hit, and the Selo when the shot is the one that lays it.
func shot_landed(e: Enemy, shot: Projectiles.Shot) -> void:
	game.player.magick.gain(game.hero_gifts.feed.take(kit.shot_magick))
	if not e.alive or e.invulnerable:
		return
	var shift := int(_stat(&"seal_at"))
	var circle_shift := int(_stat(&"circle_seal_at"))
	if kit.lays_seal(ArcaneKit.chain_step(shot.tags), _in_circle(e.pos), shift, circle_shift, _in_ultra(e.pos)) and lay(e):
		game.player.magick.gain(kit.seal_lay_magick)
		game.fx.burst(&"light", Vector3(e.pos.x, 1.4, e.pos.y))


## The share more her shots hit with inside the Suspensão Absoluta (Combat.on_shot_hit): 1 outside it.
func shot_mult(shot: Projectiles.Shot) -> float:
	return 1.0 + (ultra_def.dome_shot_pct if ultra != null and shot.tags.has(&"arcane") and _in_ultra(shot.pos) else 0.0)


## Lays a Selo on an enemy (the third shot, the Tempestade). True when it is a new one. `most` holds the number the enemy may
## hold down for this Selo (the Tempestade lays one); `seconds` is how long it lives (the book's, when it is 0 or less).
func lay(e: Enemy, most: int = -1, seconds: float = -1.0) -> bool:
	if not e.alive or e.invulnerable:
		return false
	var fresh := seals.lay(e, most, seconds)
	if fresh:
		tally.seals += 1
	return fresh


func sealed_spots() -> Array[Vector2]:
	var out: Array[Vector2] = []
	for e: Enemy in seals.keys():
		out.append(e.pos)
	return out


# ---------- the spells (ComboNode.Effect BLAST, CONTAIN, DOME) ----------

func cast(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	match node.effect:
		ComboNode.Effect.BLAST:
			_blast(node, origin, dir)
		ComboNode.Effect.CONTAIN:
			_contain(origin, dir)
		ComboNode.Effect.DOME:
			_suspend(node)


## Where a Blessing's skill of this button falls instead of at her feet: the Explosão's spot for the special, the Círculo's for
## the Q (INF: at her feet, as the Warrior's).
func spot_of(trigger: SkillDef.Trigger) -> Vector2:
	if trigger == SkillDef.Trigger.SPECIAL:
		return last_blast
	if trigger == SkillDef.Trigger.SHOUT and circle != null:
		return circle.at
	return Vector2.INF


## Where a spell falls: the mouse on the floor; without it (stick, robot) the Selo within the cone (when `seals_first`), else
## the nearest enemy in the cone, else ahead of her.
func cursor(origin: Vector2, dir: Vector2, seals_first: bool) -> Vector2:
	if Controls.aims_with_mouse():
		var m := game.aim_floor()
		if m != Vector2.INF:
			return m
	var half := deg_to_rad(CONE)
	if seals_first:
		var best: Enemy = null
		for e: Enemy in seals.keys():
			if e.alive and absf(dir.angle_to(e.pos - origin)) < half and e.pos.distance_to(origin) <= kit.blast_range \
					and (best == null or e.pos.distance_squared_to(origin) < best.pos.distance_squared_to(origin)):
				best = e
		if best != null:
			return best.pos
	var near := game.horde.nearest_ahead(origin, dir, kit.blast_range, half)
	return near.pos if near != null else origin + dir * kit.blast_range * AHEAD_SHARE


func _blast(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	var amplified := resonance.take_amplified()
	var at := kit.blast_at(origin, cursor(origin, dir, true), sealed_spots())
	var radius := kit.blast_size(amplified) * (1.0 + _stat(&"cast_size_pct", node.tags) + _stat(&"wave_size_pct", node.tags))
	game.horde.in_circle(at, radius, _found)
	last_blast = at
	var hits := 0
	var detonated := 0  # Selos (Selo Duplo: an enemy may hold two)
	var struck := {}  # enemy -> the base damage it took (the Brasa Gêmea's second blast does a share of it)
	var marked: Array[Enemy] = []  # enemies whose Selo went off
	var burn := _stat(&"seal_burn")
	var combat := game.combat
	for e: Enemy in _found.duplicate():
		if e.invulnerable:
			continue
		var held := seals.count(e)
		var bonus := held
		if held > 0 and e.def.behavior == EnemyDef.Behavior.BOSS:
			bonus = held if _boss_gap <= 0.0 else 0
			if bonus > 0:
				_boss_gap = kit.boss_seal_gap
		var away := (e.pos - at).normalized() if e.pos.distance_to(at) > 0.01 else Vector2.RIGHT
		seals.take(e)
		var damage := kit.blast_hit_n(bonus, amplified)
		struck[e] = damage
		combat.hit_enemy(e, damage, node.tags, away, kit.blast_knockback, false, true)
		hits += 1
		if held > 0:
			detonated += held
			marked.append(e)
			if burn > 0.0:
				_burn_near(e.pos, burn)  # Brasa Viva
	var fx := game.fx
	fx.ring(at, radius, AMBER, 0.35, 0.15, true)
	fx.ring(at, radius * 0.55, IVORY, 0.25)
	fx.burst(&"fire", Vector3(at.x, 0.6, at.y))
	fx.shake(1.6 if not amplified else 2.6)
	Audio.play(CombatSounds.EVENTS[&"circle_burst"])
	tally.blasts += 1
	tally.amplified += int(amplified)
	tally.detonated += detonated
	if detonated > 0:
		game.player.magick.gain((kit.seal_magick + _stat(&"seal_magick")) * mini(detonated, kit.seal_magick_cap))  # Eco Arcano
		if not amplified:
			resonance.add(kit.resonance_per_seal * detonated)
		_refund_circle(detonated)
	if amplified and _stat(&"inferno_dps") > 0.0:
		# Inferno Rúnico: the amplified blast leaves embers where it fell
		game.ground.add_zone(Ground.Kind.EMBER, at, kit.blast_radius, _stat(&"inferno_time"), _stat(&"inferno_dps"))
	if _stat(&"seal_leap") > 0.0:
		for e in marked:
			_leap(e)  # Ruptura
	var twin := _stat(&"twin_blast")
	if twin > 0.0 and detonated >= 3:
		var t := Twin.new()
		t.left = TWIN_DELAY
		t.at = at
		t.radius = radius
		t.share = twin
		t.amplified = amplified
		t.tags = node.tags
		t.first = struck
		_twins.append(t)
	if hits > 0:
		combat.landed.emit(null, node.tags, hits)  # the finisher of the passive


## Brasa Viva: the Selo's burn on the enemy that held it and on those within SEAL_BURN_SPREAD m of it.
func _burn_near(p: Vector2, dps: float) -> void:
	game.horde.in_circle(p, SEAL_BURN_SPREAD, _near)
	for n: Enemy in _near:
		if n.alive:
			game.combat.ignite(n, dps)


## Ruptura: a Selo that went off jumps once to the nearest enemy without one within LEAP_RANGE m (a boss is never chosen) and lives 4 s.
func _leap(from: Enemy) -> void:
	game.horde.in_circle(from.pos, LEAP_RANGE, _near)
	var best: Enemy = null
	for n: Enemy in _near:
		if n == from or not n.alive or n.invulnerable or seals.has(n) or n.def.behavior == EnemyDef.Behavior.BOSS:
			continue
		if best == null or n.pos.distance_squared_to(from.pos) < best.pos.distance_squared_to(from.pos):
			best = n
	if best != null and lay(best, -1, LEAP_SECONDS):
		tally.leaps += 1
		game.fx.burst(&"light", Vector3(best.pos.x, 1.4, best.pos.y))


func _step_twins(dt: float) -> void:
	for t in _twins.duplicate():
		t.left -= dt
		if t.left <= 0.0:
			_twins.erase(t)
			_twin_blast(t)


## The Brasa Gêmea: the same place again, a share of what each enemy took the first time (those that came in since take the share
## of a bare blast). No Magia, no Ressonância, no Selo.
func _twin_blast(t: Twin) -> void:
	game.horde.in_circle(t.at, t.radius, _found)
	for e: Enemy in _found.duplicate():
		if e.invulnerable or not e.alive:
			continue
		var away := (e.pos - t.at).normalized() if e.pos.distance_to(t.at) > 0.01 else Vector2.RIGHT
		var damage: float = t.first.get(e, kit.blast_hit_n(0, t.amplified))
		game.combat.hit_enemy(e, damage * t.share, t.tags, away, kit.blast_knockback * 0.5, false, true)
	game.fx.ring(t.at, t.radius * 0.8, AMBER, 0.3, 0.15, true)
	game.fx.burst(&"fire", Vector3(t.at.x, 0.6, t.at.y))
	Audio.play(CombatSounds.EVENTS[&"circle_burst"])
	tally.twins += 1


## The Q's recharge gets a second back for each Selo detonated (at most circle_refund_cap a cast; never under cd_floor).
func _refund_circle(detonated: int) -> void:
	if circle == null:
		return
	var ask := minf(kit.circle_refund * detonated, kit.circle_refund_cap - circle.refunded)
	circle.refunded += game.player.refund_shout(ask)


func _contain(origin: Vector2, dir: Vector2) -> void:
	_end_circle()
	var c := Circle.new()
	c.at = game.arena.resolve(kit.circle_at(origin, cursor(origin, dir, false)), 0.5) if game.arena else origin
	c.life = kit.circle_time + _stat(&"circle_time")  # Contenção Perfeita
	c.pull_left = kit.circle_pull_time
	var size := _circle_size()
	game.horde.in_circle(c.at, size, _found)
	for e: Enemy in _found:
		if Combat.is_common(e.def):
			c.pulled.append(e)
	for k in SIGILS:
		var a := TAU * k / SIGILS
		var m := _flat(SIGIL_RADIUS, GOLD)
		m.position = Vector3(c.at.x + cos(a) * size * 0.95, 0.08, c.at.y + sin(a) * size * 0.95)
		add_child(m)
		c.sigils.append(m)
	circle = c
	tally.circles += 1
	game.fx.ring(c.at, size, GOLD, 0.4, 0.15, true)
	game.fx.burst(&"light", Vector3(c.at.x, 0.4, c.at.y))
	Audio.play(CombatSounds.EVENTS[&"circle"])


## The Círculo's radius with the Blessings' and the Gifts' size (Círculo Expandido).
func _circle_size() -> float:
	return kit.circle_radius * (1.0 + _stat(&"cast_size_pct", CIRCLE_TAGS))


func _in_circle(p: Vector2) -> bool:
	return circle != null and p.distance_to(circle.at) <= _circle_size() + 0.4


func _step_circle(dt: float) -> void:
	var c := circle
	if c == null:
		return
	c.life -= dt
	if c.life <= 0.0:
		_end_circle()
		return
	var shown := 1.0 if c.life > SIGIL_BLINK or int(c.life * 8.0) % 2 == 0 else 0.0
	for s in c.sigils:
		s.visible = shown > 0.0
		s.rotation.y = _turn
	if c.pull_left > 0.0:
		var step_dt := minf(dt, c.pull_left)
		c.pull_left -= dt
		for e in c.pulled:
			if e.alive:
				var to := e.pos + kit.pull_step(e.pos, c.at, step_dt) * (1.0 + _stat(&"push_pct", CIRCLE_TAGS))  # (Galael: the pull draws further)
				e.pos = game.arena.sweep(e.pos, to, e.def.radius) if game.arena else to
	if c.pull_left <= 0.0 and not c.closed:
		_close_circle(c)
	game.horde.in_circle(c.at, _circle_size(), _found)
	for e: Enemy in _found:
		if e.def.behavior != EnemyDef.Behavior.BOSS:
			e.slow_t = maxf(e.slow_t, kit.circle_slow)


## The pull is over: what the Gifts and the Blessings of the Q do to everyone inside. Brasa que Prende hurts them, Selo no Chão
## marks the commons and the elites, Prisão Sigilada roots the commons, and the statuses of the Q's tags (burn, frost, weakness,
## mark) are put on all, so the Blessings of the Q have something to act on (the Círculo strikes nothing itself).
func _close_circle(c: Circle) -> void:
	c.closed = true
	var burst := _stat(&"circle_burst")
	var root := _stat(&"circle_root")
	var mark := _stat(&"circle_seal") > 0.0
	game.horde.in_circle(c.at, _circle_size(), _found)
	for e: Enemy in _found.duplicate():
		if not e.alive or e.invulnerable:
			continue
		if burst > 0.0 and game.combat.hit_enemy(e, burst, CIRCLE_TAGS, Vector2.ZERO, 0.0, false):
			continue
		game.combat.touch(e, CIRCLE_TAGS)
		if mark and not (e.def.heavy or e.def.behavior == EnemyDef.Behavior.BOSS):
			lay(e)
		if root > 0.0 and Combat.is_common(e.def):
			e.stun_t = maxf(e.stun_t, root)


func _end_circle() -> void:
	if circle == null:
		return
	for s in circle.sigils:
		s.queue_free()
	circle = null


func _suspend(node: ComboNode) -> void:
	_end_dome()
	var d := Dome.new()
	d.tags = node.tags
	d.life = kit.dome_time + _stat(&"dome_time")  # Suspensão Larga
	d.radius = kit.dome_radius * (1.0 + _stat(&"dome_size_pct"))
	d.node = _dome_node(d.radius, 0.1)
	dome = d
	tally.domes += 1
	game.fx.ring(game.player.pos, d.radius, IVORY, 0.35, 0.15, true)
	Audio.play(CombatSounds.EVENTS[&"circle"])


## The dome's ball: a pale ivory skin of this radius and alpha, put in the room.
func _dome_node(radius: float, alpha: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = radius
	ball.height = radius * 2.0
	ball.radial_segments = 16
	ball.rings = 8
	mi.mesh = ball
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = Color(IVORY.r, IVORY.g, IVORY.b, alpha)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _in_dome(p: Vector2) -> bool:
	return dome != null and p.distance_to(game.player.pos) <= dome.radius + 0.4


func _step_dome(dt: float) -> void:
	var d := dome
	if d == null:
		return
	d.life -= dt
	if d.life <= 0.0:
		_end_dome()
		return
	var at := game.player.pos
	d.node.position = Vector3(at.x, 1.1, at.y)
	_hold_shots(d, at, false)
	game.horde.in_circle(at, d.radius, _found)
	for e: Enemy in _found:
		if e.def.behavior != EnemyDef.Behavior.BOSS:
			e.slow_t = maxf(e.slow_t, kit.dome_slow)
		if not d.touched.has(e):
			d.touched[e] = true
			game.combat.touch(e, d.tags)  # (burn, frost, weakness, mark of the Blessings of the E, once to each that comes in)


## Enemy shots that reach the dome stop in the air (`sparing`: not a guardian's nor the boss's, the Suspensão Absoluta's rule).
func _hold_shots(d: Dome, at: Vector2, sparing: bool) -> void:
	for s in game.projectiles.shots:
		if Projectiles.hostile(s) and not s.frozen and s.life > 0.0 and s.pos.distance_to(at) <= d.radius + s.radius:
			if sparing and _spared(s):
				continue
			s.frozen = true
			d.held.append(s)
			tally.held += 1
			game.fx.burst(&"spark", Vector3(s.pos.x, Projectiles.HEIGHT, s.pos.y))


## A shot the Suspensão Absoluta does not hold: Morvath's own (no shooter kind) and a guardian's (a heavy kind).
func _spared(s: Projectiles.Shot) -> bool:
	if s.by == &"":
		return true
	var def := game.horde.def(s.by)
	return def != null and def.heavy


## The dome falls: what it held goes out with it.
func _end_dome() -> void:
	if dome == null:
		return
	_release(dome)
	dome = null


func _release(d: Dome) -> void:
	for s in d.held:
		s.life = 0.0
		s.frozen = false
	d.node.queue_free()


# ---------- the Suspensão Absoluta (the second ultimate) ----------

## Ultimates lets it go: a big dome that walks with her for the ultimate's seconds.
func open_absolute(def: UltDef) -> void:
	_end_ultra()
	var d := Dome.new()
	d.life = def.duration
	d.radius = def.radius
	d.node = _dome_node(d.radius, 0.08)
	ultra = d
	ultra_def = def
	tally.ultras += 1
	game.fx.ring(game.player.pos, d.radius, IVORY, 0.4, 0.15, true)
	game.fx.ring(game.player.pos, d.radius * 0.6, AMBER, 0.3)
	Audio.play(CombatSounds.EVENTS[&"ult_vortex"])


func _in_ultra(p: Vector2) -> bool:
	return ultra != null and p.distance_to(game.player.pos) <= ultra.radius + 0.4


## The share off the Explosão's price inside it: its own price (dome_blast_cost) over the move's.
func _ultra_discount() -> float:
	var node := ComboTree.find(game.player.tree.neutral, ComboNode.In.HEAVY)
	if node == null or node.magick_cost <= 0.0:
		return 0.0
	return clampf(1.0 - ultra_def.dome_blast_cost / node.magick_cost, 0.0, 1.0)


func _step_ultra(dt: float) -> void:
	var d := ultra
	if d == null:
		return
	d.life -= dt
	if d.life <= 0.0:
		_end_ultra()
		return
	var at := game.player.pos
	d.node.position = Vector3(at.x, 1.1, at.y)
	d.node.visible = d.life > ULTRA_BLINK or int(d.life * 6.0) % 2 == 0
	_hold_shots(d, at, true)
	game.horde.in_circle(at, d.radius, _found)
	for e: Enemy in _found:
		e.slow_t = maxf(e.slow_t, kit.dome_slow)  # (Morvath too: only slowed)


func _end_ultra() -> void:
	if ultra == null:
		return
	_release(ultra)
	ultra = null
	ultra_def = null
	game.player.blast_discount = 0.0


# ---------- the Passo ----------

## Passo de Brasa: a flash where she was (it hurts and burns whoever stood there) and embers where she came out.
func _on_dodged(_dir: Vector2) -> void:
	var flash := _stat(&"step_flash")
	if flash <= 0.0:
		return
	var from := game.player.last_blink_from
	game.horde.in_circle(from, FLASH_RADIUS, _found)
	for e: Enemy in _found.duplicate():
		if not e.alive or e.invulnerable:
			continue
		var away := (e.pos - from).normalized() if e.pos.distance_to(from) > 0.01 else Vector2.RIGHT
		if not game.combat.hit_enemy(e, flash, STEP_TAGS, away, 3.0, false):
			game.combat.ignite(e, STEP_BURN)
	game.fx.ring(from, FLASH_RADIUS, AMBER, 0.3, 0.15, true)
	game.fx.burst(&"fire", Vector3(from.x, 0.5, from.y))
	game.ground.add_zone(Ground.Kind.EMBER, game.player.pos, STEP_EMBERS.x, STEP_EMBERS.y, STEP_EMBERS.z)


# ---------- the Tempestade ----------

## The Tempestade's detonation of one enemy: its Selo is consumed (true when it held one).
func detonate(e: Enemy) -> bool:
	return seals.take(e) > 0


# ---------- the Selo drawn ----------

func _flat(radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.02
	disc.radial_segments = 6
	disc.rings = 1
	mi.mesh = disc
	if _unlit == null:
		_unlit = StandardMaterial3D.new()
		_unlit.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var m := _unlit.duplicate() as StandardMaterial3D
	m.albedo_color = color * 0.9
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func _step_glyphs() -> void:
	for e: Enemy in _glyphs.keys():
		if not seals.has(e):
			_drop_glyph(e)
	for e: Enemy in seals.keys():
		if not _glyphs.has(e):
			var g := _flat(GLYPH_RADIUS, IVORY)
			add_child(g)
			_glyphs[e] = g
		var g: MeshInstance3D = _glyphs[e]
		g.position = Vector3(e.pos.x, GLYPH_HEIGHT + e.y, e.pos.y)
		g.rotation = Vector3(deg_to_rad(25.0), _turn, 0.0)


func _drop_glyph(e: Enemy) -> void:
	var g: MeshInstance3D = _glyphs.get(e)
	if g != null:
		g.queue_free()
	_glyphs.erase(e)


func stats() -> Dictionary:
	return tally.duplicate()
