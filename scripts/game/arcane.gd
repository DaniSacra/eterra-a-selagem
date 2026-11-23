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

class Circle:
	var at := Vector2.ZERO
	var life := 0.0
	var pull_left := 0.0
	var refunded := 0.0
	var pulled: Array[Enemy] = []
	var sigils: Array[MeshInstance3D] = []

class Dome:
	var life := 0.0
	var node: MeshInstance3D
	var held: Array[Projectiles.Shot] = []

var game: Game
var kit: ArcaneKit
var seals: SealBook
var resonance: Resonance
var circle: Circle
var dome: Dome
## What the kit did in this run (RESULT arcane).
var tally := {"seals": 0, "blasts": 0, "amplified": 0, "detonated": 0, "circles": 0, "domes": 0, "held": 0, "storm_seals": 0}
var _glyphs: Dictionary = {}
var _boss_gap := 0.0
var _turn := 0.0
var _found: Array[Enemy] = []
var _unlit: StandardMaterial3D


func setup(g: Game) -> void:
	game = g
	kit = g.hero.arcane
	seals = SealBook.new(kit.seal_time, kit.seal_cap)
	resonance = Resonance.new(kit.resonance_max)


## A new room (or the run's end): the Selos, the Círculo and the Suspensão go (the Ressonância stays: it zeroes with the descent).
func clear() -> void:
	seals.clear()
	for e in _glyphs.keys():
		_drop_glyph(e)
	_end_circle()
	_end_dome()


func step(dt: float) -> void:
	var p := game.player
	p.free_special = resonance.full()
	_boss_gap = maxf(0.0, _boss_gap - dt)
	_turn += dt * GLYPH_SPIN
	for e: Enemy in seals.keys():
		if not e.alive:
			seals.forget(e)
	seals.step(dt, func(e: Enemy) -> bool: return _in_circle(e.pos) or _in_dome(e.pos))
	_step_glyphs()
	_step_circle(dt)
	_step_dome(dt)


# ---------- the Selo ----------

## A shot of hers touched an enemy (Combat.on_shot_hit): the Magia of the hit, and the Selo when the shot is the one that lays it.
func shot_landed(e: Enemy, shot: Projectiles.Shot) -> void:
	game.player.magick.gain(game.hero_gifts.feed.take(kit.shot_magick))
	if not e.alive or e.invulnerable:
		return
	if kit.seals_on(shot.tags, _in_circle(e.pos)) and lay(e):
		game.player.magick.gain(kit.seal_lay_magick)
		game.fx.burst(&"light", Vector3(e.pos.x, 1.4, e.pos.y))


## Lays a Selo on an enemy (the third shot, the Tempestade). True when it is a new one.
func lay(e: Enemy) -> bool:
	if not e.alive or e.invulnerable:
		return false
	var fresh := seals.lay(e)
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
			_suspend()


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
	var radius := kit.blast_size(amplified) * (1.0 + game.boons.stat(&"cast_size_pct", node.tags))
	game.horde.in_circle(at, radius, _found)
	var hits := 0
	var detonated := 0
	var combat := game.combat
	for e: Enemy in _found.duplicate():
		if e.invulnerable:
			continue
		var sealed := seals.has(e)
		var bonus := sealed
		if sealed and e.def.behavior == EnemyDef.Behavior.BOSS:
			bonus = _boss_gap <= 0.0
			if bonus:
				_boss_gap = kit.boss_seal_gap
		var away := (e.pos - at).normalized() if e.pos.distance_to(at) > 0.01 else Vector2.RIGHT
		seals.take(e)
		combat.hit_enemy(e, kit.blast_hit(bonus, amplified), node.tags, away, kit.blast_knockback, false, true)
		hits += 1
		if sealed:
			detonated += 1
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
		game.player.magick.gain(kit.seal_magick * mini(detonated, kit.seal_magick_cap))
		if not amplified:
			resonance.add(kit.resonance_per_seal * detonated)
		_refund_circle(detonated)
	if hits > 0:
		combat.landed.emit(null, node.tags, hits)  # the finisher of the passive


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
	c.life = kit.circle_time
	c.pull_left = kit.circle_pull_time
	var size := kit.circle_radius * (1.0 + game.boons.stat(&"cast_size_pct"))
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


func _in_circle(p: Vector2) -> bool:
	return circle != null and p.distance_to(circle.at) <= kit.circle_radius * (1.0 + game.boons.stat(&"cast_size_pct")) + 0.4


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
				var to := e.pos + kit.pull_step(e.pos, c.at, step_dt)
				e.pos = game.arena.sweep(e.pos, to, e.def.radius) if game.arena else to
	game.horde.in_circle(c.at, kit.circle_radius * (1.0 + game.boons.stat(&"cast_size_pct")), _found)
	for e: Enemy in _found:
		if e.def.behavior != EnemyDef.Behavior.BOSS:
			e.slow_t = maxf(e.slow_t, kit.circle_slow)


func _end_circle() -> void:
	if circle == null:
		return
	for s in circle.sigils:
		s.queue_free()
	circle = null


func _suspend() -> void:
	_end_dome()
	var d := Dome.new()
	d.life = kit.dome_time
	d.node = MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = kit.dome_radius
	ball.height = kit.dome_radius * 2.0
	ball.radial_segments = 16
	ball.rings = 8
	d.node.mesh = ball
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = Color(IVORY.r, IVORY.g, IVORY.b, 0.1)
	d.node.material_override = m
	d.node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(d.node)
	dome = d
	tally.domes += 1
	game.fx.ring(game.player.pos, kit.dome_radius, IVORY, 0.35, 0.15, true)
	Audio.play(CombatSounds.EVENTS[&"circle"])


func _in_dome(p: Vector2) -> bool:
	return dome != null and p.distance_to(game.player.pos) <= kit.dome_radius + 0.4


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
	for s in game.projectiles.shots:
		if Projectiles.hostile(s) and not s.frozen and s.life > 0.0 and s.pos.distance_to(at) <= kit.dome_radius + s.radius:
			s.frozen = true
			d.held.append(s)
			tally.held += 1
			game.fx.burst(&"spark", Vector3(s.pos.x, Projectiles.HEIGHT, s.pos.y))
	game.horde.in_circle(at, kit.dome_radius, _found)
	for e: Enemy in _found:
		if e.def.behavior != EnemyDef.Behavior.BOSS:
			e.slow_t = maxf(e.slow_t, kit.dome_slow)


## The dome falls: what it held goes out with it.
func _end_dome() -> void:
	if dome == null:
		return
	for s in dome.held:
		s.life = 0.0
		s.frozen = false
	dome.node.queue_free()
	dome = null


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
