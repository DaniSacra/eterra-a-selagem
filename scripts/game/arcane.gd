class_name Arcane
extends Node3D
## The Maga's kit in play (redesign 2026-11-24, 04_PLANO C; GP-5 docs/design/heroes/maga_v1_2026-11-26.md; HeroDef.arcane): Centelha
## (fire bolt), Estilhaço (ice bolt through the crowd), Geada (cold area), Arco Voltaico (volt chain) and the Passo. The Combustão and the
## Suspensão Arcana are out of her tree (no node) and their code waits here for a Gift.
## The states (Queimadura, Frio, Eletrizado) and their reactions are ElementBook (pure, tested); this node applies what the
## book answers in the room. Her bolts go through Combat.on_shot_hit (shot_landed), her spells through the combo tree's
## effects (cast), the Convergência through Ultimates (apply_element). A reaction never applies a state, so none chains.

const IVORY := Color(0.95, 0.88, 0.7)
## How far ahead of her a spell falls when she has no mouse and nothing is near, as a share of the kit's range.
const AHEAD_SHARE := 0.6
## The half angle (degrees) of the cone in which a stick or the robot finds the nearest enemy.
const CONE := 65.0
const SHOT_TAGS: Array[StringName] = [&"cast", &"arcane"]
const ARC_TAGS: Array[StringName] = [&"omega", &"light", &"arcane", &"volt"]
## Where an element was applied from (GP-5 4.1): a blow of hers, an area's tick (Geada, embers, Confluência), the Propagação, the Convergência.
const DIRECT := &"direct"
const AREA := &"area"
const SPREAD := &"spread"
const ULT := &"ult"
## The embers Manifestação keeps alive at once (the oldest goes), and how often Confluência looks (s).
const EMBER_MAX := 3
## Hit stop of a Choque Térmico, ms (maga_v2 7).
const THERMAL_STOP_MS := 50.0
const CONFLUENCE_STEP := 0.5
const FROST_TAGS: Array[StringName] = [&"cast", &"arcane", &"ice"]
## Queimadura damage is dealt in steps of at least this much (not one number a frame).
const BURN_STEP := 2.0
## What Fissão Térmica reaches around the target (m), and the metres the Chão Ardente burns (radius), and how often it sets fire.
const SPLASH_RADIUS := 2.0
const EMBER_STEP := 0.5
const EMBER_SECONDS := 3.0
## The dome's rim (the share of the radius from which Galael's shove acts), its speed at push_pct 1 and the Lumael heal's cap in enemies.
const DOME_RIM := 0.7
const DOME_PUSH := 4.0
const DOME_HEAL_CAP := 6
## The embers the Passo lays at both ends (Rastro and its kin): radius, seconds, unused.
const STEP_TRAIL := Vector3(1.4, Combat.TRAIL_TIME, 0.0)
## Seconds of immunity to a new freeze after one (so the Geada does not hold a body frozen for good).
const THAW := 1.0

class Dome:
	var life := 0.0
	var radius := 2.6
	## The move's tags (the Blessings of the E act on whoever comes in: touched is who they already did).
	var tags: Array[StringName] = []
	var touched: Dictionary = {}
	var node: MeshInstance3D
	var span := 1.0
	var held: Array[Projectiles.Shot] = []

## A standing area on the floor: the Geada and the Chão Ardente.
class Patch:
	var at := Vector2.ZERO
	var radius := 2.5
	var life := 0.0
	var tick := 0.0
	var node: MeshInstance3D
	## The conjuration it belongs to (_cj).
	var conj := 0

var game: Game
var kit: ArcaneKit
var book: ElementBook
var dome: Dome
var frost: Patch
var _embers: Array[Patch] = []
var pips: StatePips
## How many reaction names the screen takes (UX-08): the first three of each, six words a second.
var words := WordBudget.new()
## What the kit did in this run (RESULT arcane).
var tally := {"sparks": 0, "combusts": 0, "shards": 0, "frosts": 0, "arcs": 0, "domes": 0, "held": 0, "freezes": 0,
	"thermal": 0, "overload": 0, "crystal": 0, "burn_damage": 0.0, "reactions": 0}
## The burst of a reaction lives this long (CF-07: 0.25 s at most) and, but for the Sobrecarga's, rings this wide.
const REACT_TIME := 0.25
const REACT_RING := 1.4
var _react_sound_t := -99.0
var _burn_acc: Dictionary = {}
## GP-5: a conjuration is one cast (a bolt in flight, the Arco, a Geada, an ember): id -> {spread: elements already spread, recip: the
## Reciprocidade paid, area: its one reaction of charge taken, charged: Supremo charge it gave, free: the Transcendência's free cast}.
var _cj: Dictionary = {}
var _serial := 0
var _conj := 0
## What the reactions gave the Convergência (Ultimates feeds it), the reactions counted toward the Transcendência and whether it is ready.
var react_charge := 0.0
var _react_count := 0
var _transcend := false
var _free_next := false
## Enemy -> book time of the last Confluência shock.
var _confl: Dictionary = {}
var _confl_t := 0.0
var _shards_used := 0
var _shard_t := 0.0
var _found: Array[Enemy] = []
var _near: Array[Enemy] = []


func setup(g: Game) -> void:
	game = g
	kit = g.hero.arcane
	book = kit.make_book()
	pips = StatePips.new()
	add_child(pips)
	g.player.dodged.connect(_on_dodged)


## A new room (or the run's end): the states, the Geada, the embers and the Suspensão go.
func clear() -> void:
	book.clear_all()
	_burn_acc.clear()
	_end_frost()
	for p in _embers:
		p.node.queue_free()
	_embers.clear()
	_end_dome()
	_shards_used = 0
	_shard_t = 0.0
	_cj.clear()
	_confl.clear()
	_react_count = 0
	_transcend = false
	_free_next = false


## A Gift's or a Blessing's number for this hero now (BoonState.stat; the tags limit it to the moves that carry them).
func _stat(stat_name: StringName, tags: Array[StringName] = []) -> float:
	return game.boons.stat(stat_name, tags)


## The book with the Gifts' numbers on top of the kit's.
func _configure() -> void:
	book.burn_dps = kit.burn_dps * (1.0 + _stat(&"burn_dps_pct"))
	book.cold_freeze_at = maxi(1, kit.cold_freeze_at + int(_stat(&"cold_freeze_at")))
	book.react_pct = _stat(&"react_pct")
	# Afinidade: the states last longer (the damage a second does not change)
	var longer := 1.0 + _stat(&"element_time_pct")
	book.burn_time = (kit.burn_time + _stat(&"burn_time_add")) * longer
	book.cold_time = kit.cold_time * longer
	book.volt_time = kit.volt_time * longer
	book.trinity = _stat(&"trinity") > 0.0
	book.residue_time = _stat(&"trinity_time") if _stat(&"trinity_time") > 0.0 else 3.0


func step(dt: float) -> void:
	_configure()
	for k in book.keys():
		if not (k as Enemy).alive:
			book.clear(k)
			_burn_acc.erase(k)
	var burns := book.tick(dt)
	for e: Enemy in burns:
		if e.alive:
			_burn_hurt(e, float(burns[e]))
	_step_frost(dt)
	_step_embers(dt)
	_step_confluence(dt)
	_step_dome(dt)
	_step_shard(dt)
	pips.update(game.horde.list, book)


## Queimadura: the damage is gathered and dealt in BURN_STEP pieces (no Magia, no Apogeu, no combo: Horde.dealing "elemental").
func _burn_hurt(e: Enemy, dmg: float) -> void:
	var acc: float = float(_burn_acc.get(e, 0.0)) + dmg
	if acc < BURN_STEP:
		_burn_acc[e] = acc
		return
	_burn_acc.erase(e)
	_elemental_hit(e, acc, ElementLook.FIRE)
	tally.burn_damage += acc


## One hit of an element's own (a reaction, a burn tick): through Horde.damage, as source "elemental".
func _elemental_hit(e: Enemy, amount: float, color: Color) -> void:
	if not e.alive or e.invulnerable:
		return
	var horde := game.horde
	horde.dealing = &"elemental"
	horde.damage(e, maxf(1.0, roundf(amount)), Vector2.ZERO, 0.0, color, true, false, false)
	horde.dealing = &""


# ---------- the elements ----------

## The record of a conjuration (a cast: a bolt, the Arco, a Geada, an ember), made when first asked for.
func _cj_of(id: int) -> Dictionary:
	if not _cj.has(id):
		_cj[id] = {"spread": {}, "recip": false, "area": false, "charged": 0.0, "free": false}
		if _cj.size() > 64:
			for old in _cj.keys().slice(0, 32):
				_cj.erase(old)
	return _cj[id]


## A new conjuration (the Arco, a Geada, a patch of embers); `_conj` is the one the elements applied next belong to.
func _new_conj() -> int:
	_serial += 1
	_conj = _serial
	var cj := _cj_of(_serial)
	cj["free"] = _free_next  # the Transcendência's free cast: its reactions do not count for the next one
	_free_next = false
	return _serial


## Puts an element on an enemy (a bolt, the Geada, the Arco, the Convergência) and plays what comes of it: the reaction (one
## at most, and it applies no state; with Trindade the two a residue's third element makes), the Frio's slow and the freeze at the
## third hit. `source`: DIRECT (a blow of hers), AREA (a tick of the Geada, an ember, the Confluência), SPREAD, ULT (GP-5 4.1: only a
## direct blow's element spreads and only direct and spread reactions lay embers). True when it took.
func apply_element(e: Enemy, element: StringName, source: StringName = DIRECT) -> bool:
	if not e.alive or e.invulnerable:
		return false
	var resists := e.def.behavior == EnemyDef.Behavior.BOSS or e.armor > 0.0
	var had := book.has_element(e, element)
	var reactions := book.apply(e, element, resists, source)
	if element == ElementBook.ICE:
		_chill(e, resists)
	if source == DIRECT and not had:
		_spread(e, element)
	for r in reactions:
		_react(r, source)
	return true


## Propagação: the element a blow of hers put on `e` goes to the nearest enemy without it within `spread_range`, once for each element of a
## conjuration; what it spreads does not spread again.
func _spread(e: Enemy, element: StringName) -> void:
	var reach := _stat(&"spread_range")
	if reach <= 0.0:
		return
	var cj := _cj_of(_conj)
	if cj["spread"].has(element):
		return
	var best: Enemy = null
	game.horde.in_circle(e.pos, reach, _near)
	for n: Enemy in _near:
		if n != e and n.alive and not n.invulnerable and not book.has_element(n, element) \
				and (best == null or n.pos.distance_squared_to(e.pos) < best.pos.distance_squared_to(e.pos)):
			best = n
	if best == null:
		return
	cj["spread"][element] = true
	apply_element(best, element, SPREAD)


## Frio: slowed (the Gifts lengthen it) and, at the third hit, frozen if it is a common body (a boss never; thaw_t spaces freezes).
func _chill(e: Enemy, resists: bool) -> void:
	if e.def.behavior != EnemyDef.Behavior.BOSS:
		e.slow_t = maxf(e.slow_t, kit.shard_slow_time * (1.0 + _stat(&"slow_pct") / maxf(kit.slow_pct, 0.01)))
	if book.cold_full(e) and not resists and e.thaw_t <= 0.0 and e.frozen_t <= 0.0:
		var time := kit.freeze_time * (0.4 if e.def.heavy else 1.0)
		e.frozen_t = time
		e.thaw_t = time + THAW
		tally.freezes += 1
		game.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))


## A reaction happened: what it does in the room (_play), then what it feeds (GP-5): the Convergência's charge and the Transcendência's
## count (an effective one, 7), the Reciprocidade's Magia (once a conjuration) and Manifestação's embers. The Convergência's own reactions
## (ULT) feed nothing and none of them lays embers (4.1).
func _react(r: Reaction, source: StringName) -> void:
	_play(r)
	if source == ULT:
		return
	var cj := _cj_of(_conj)
	var back := kit.reaction_magick + _stat(&"reaction_magick")  # (Ressonância and the Reciprocidade)
	if back > 0.0 and not cj["recip"]:
		cj["recip"] = true
		game.player.magick.gain(back)  # (not a hit: no KitFeed cap, no Supremo charge: the charge reads the Magia spent)
	if game.ults.vortex == null and _counts(cj, source):
		react_charge += kit.react_charge
		_count_reaction(cj)
	if (source == DIRECT or source == SPREAD) and r.kind != Reaction.Kind.CRYSTAL and _stat(&"ember_floor") > 0.0:
		_lay_embers((r.target as Enemy).pos)


## Whether a reaction of this conjuration counts for the Supremo and the Transcendência: a direct or spread one up to the cap of a cast,
## an area's once for the cast.
func _counts(cj: Dictionary, source: StringName) -> bool:
	if source == AREA:
		if cj["area"]:
			return false
		cj["area"] = true
		return true
	if float(cj["charged"]) + kit.react_charge > kit.react_charge_cap:
		return false
	cj["charged"] = float(cj["charged"]) + kit.react_charge
	return true


## Transcendência: `transcend_at` effective reactions make the next held spell free (and quick); the free cast's own reactions do not count.
func _count_reaction(cj: Dictionary) -> void:
	var need := int(_stat(&"transcend_at"))
	if need <= 0 or _transcend or cj["free"]:
		return
	_react_count += 1
	if _react_count >= need:
		_react_count = 0
		_transcend = true


## The next held spell (the Arco, the Geada) is free and takes only the hold's threshold to charge.
func transcend_ready() -> bool:
	return _transcend


## The held spell strikes: the benefit is spent (never on a cancel) and that spell's reactions do not count for the next.
func take_transcend() -> void:
	_transcend = false
	_free_next = true


## Reactions counted toward the Transcendência so far (0 to transcend_at - 1) and how many it asks (0: no Dom), for the HUD.
func transcend_progress() -> int:
	return _react_count


func transcend_need() -> int:
	return int(_stat(&"transcend_at"))


## What a reaction does in the room: its damage, its freeze or Quebra, the ring, the burst, the sound and the word.
func _play(r: Reaction) -> void:
	var e := r.target as Enemy
	tally.reactions += 1
	var at := Vector3(e.pos.x, 1.0 + e.y, e.pos.y)
	var fx := game.fx
	var color: Color
	var burst: StringName
	var sound: StringName
	match r.kind:
		Reaction.Kind.THERMAL:
			tally.thermal += 1
			_elemental_hit(e, r.damage, ElementLook.COLD)
			color = ElementLook.REACT_THERMAL
			burst = &"fire"
			sound = &"react_thermal"
		Reaction.Kind.OVERLOAD:
			tally.overload += 1
			_elemental_hit(e, r.damage, ElementLook.VOLT)
			_around(e, r.damage, r.radius, 1.0, 0.0)
			color = ElementLook.REACT_OVERLOAD
			burst = &"spark"
			sound = &"react_overload"
		_:
			tally.crystal += 1
			if r.freeze > 0.0 and e.thaw_t <= 0.0 and e.frozen_t <= 0.0:
				e.frozen_t = r.freeze * (0.4 if e.def.heavy else 1.0)
				e.thaw_t = r.freeze + THAW
			elif r.poise > 0.0:
				# Quebra instead of a freeze (the boss's Postura, a common's poise); Catalisador makes it hit harder (same weight, more of it)
				var horde := game.horde
				horde.poise_extra = _stat(&"react_pct") * Poise.share(&"crystal", Feel.live().poise_weights)
				horde.crack(e, &"crystal")
				horde.poise_extra = 0.0
			color = ElementLook.REACT_CRYSTAL
			burst = &"frost"
			sound = &"react_crystal"
	# one burst a reaction (CF-07): one ring and one puff, in the reaction's color; the sound once a react_gap however many pop
	fx.ring(e.pos, r.radius if r.kind == Reaction.Kind.OVERLOAD else REACT_RING, color, REACT_TIME, 0.15, true)
	fx.burst(burst, at)
	if book.now - _react_sound_t >= kit.react_gap:
		_react_sound_t = book.now
		Audio.play(CombatSounds.EVENTS[sound])
		if r.kind == Reaction.Kind.THERMAL:
			fx.blow_stop(THERMAL_STOP_MS * Feel.live().hit_stop_scale)  # (V2: the Choque Térmico stops the world a beat)
	var word_key := &"word_react_thermal" if r.kind == Reaction.Kind.THERMAL else &"word_react_overload" if r.kind == Reaction.Kind.OVERLOAD else &"word_react_crystal"
	if words.admit(book.now):
		fx.word(at + Vector3(0.0, 0.8, 0.0), T.t(word_key) if words.named(word_key) else "", color)
	var splash := _stat(&"react_splash")  # Fissão Térmica: the same damage, a share of it, 2 m around (no state, no chain)
	if splash > 0.0 and r.kind != Reaction.Kind.CRYSTAL:
		_around(e, r.damage * splash, SPLASH_RADIUS, 1.0, r.radius)


## Damage to the enemies within `radius` of `e` (not `e`, not those within `skip` m of it: they took it already).
func _around(e: Enemy, amount: float, radius: float, _share: float, skip: float) -> void:
	game.horde.in_circle(e.pos, radius, _near)
	for n: Enemy in _near.duplicate():
		if n != e and n.alive and n.pos.distance_to(e.pos) > skip:
			_elemental_hit(n, amount, ElementLook.VOLT)


# ---------- the bolts (Combat.on_shot_hit) ----------

## A bolt of hers touched an enemy: the Magia of the hit and the element of the bolt (Centelha: fire at the third hit in 4 s;
## Combustão: fire on all in the burst; Estilhaço: ice).
func shot_landed(e: Enemy, shot: Projectiles.Shot) -> void:
	var tags := shot.tags
	var spark := tags.has(&"fire") and not tags.has(&"omega")
	var gain := (kit.shot_magick if spark else 0.0)
	if spark or tags.has(&"ice"):
		gain += _stat(&"shot_magick_add")
	if gain > 0.0:
		game.player.magick.gain(game.hero_gifts.feed.take(gain))
	if not e.alive or e.invulnerable:
		return
	_conj = shot.get_instance_id()  # (one bolt is one conjuration: what it spreads, repays and charges is counted once)
	if spark:
		tally.sparks += 1
		if book.count_hit(e, kit.spark_hits, kit.spark_window):
			apply_element(e, ElementBook.FIRE)
	elif tags.has(&"fire"):
		_combust(e, shot)
	elif tags.has(&"ice"):
		tally.shards += 1
		apply_element(e, ElementBook.ICE)


## The share more her bolts and areas hit with inside the dome (Campo Elementar): 1 outside it.
func shot_mult(shot: Projectiles.Shot) -> float:
	return 1.0 + (_stat(&"dome_shot_pct") if _in_dome(shot.pos) else 0.0)


## The Combustão bursts on the first enemy: the same damage to all within combust_radius, Queimadura on every one, and the Chão
## Ardente's floor when the Gift is on.
func _combust(first: Enemy, shot: Projectiles.Shot) -> void:
	tally.combusts += 1
	var mult := shot_mult(shot)
	var at := first.pos
	apply_element(first, ElementBook.FIRE)
	game.horde.in_circle(at, kit.combust_radius, _found)
	for n: Enemy in _found.duplicate():
		if n == first or not n.alive or n.invulnerable:
			continue
		var away := (n.pos - at).normalized() if n.pos.distance_to(at) > 0.01 else Vector2.RIGHT
		if not game.combat.hit_enemy(n, shot.damage * mult, shot.tags, away, kit.combust_knockback, false, true):
			apply_element(n, ElementBook.FIRE)
	var fx := game.fx
	fx.ring(at, kit.combust_radius, ElementLook.FIRE, 0.35, 0.15, true)
	fx.burst(&"fire", Vector3(at.x, 0.6, at.y))
	fx.shake(1.6)
	Audio.play(CombatSounds.EVENTS[&"circle_burst"])
	if _stat(&"ember_floor") > 0.0:
		_lay_embers(at)


# ---------- the spells (ComboNode.Effect FROST, ARC, DOME) ----------

func cast(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	match node.effect:
		ComboNode.Effect.FROST:
			_frost(origin, dir)
		ComboNode.Effect.ARC:
			_arc(node, origin, dir)
		ComboNode.Effect.DOME:
			_suspend(node)


## Where a spell falls: the mouse on the floor; without it (stick, robot) the nearest enemy in the cone, else ahead of her.
func cursor(origin: Vector2, dir: Vector2, reach: float) -> Vector2:
	if Controls.aims_with_mouse():
		var m := game.aim_floor()
		if m != Vector2.INF:
			return m
	var near := game.horde.nearest_ahead(origin, dir, reach, deg_to_rad(CONE))
	return near.pos if near != null else origin + dir * reach * AHEAD_SHARE


## The Geada: an area at the cursor (up to frost_range), Frio on all inside every frost_step, frost_dps a second.
func _frost(origin: Vector2, dir: Vector2) -> void:
	_end_frost()
	var p := Patch.new()
	p.at = game.arena.resolve(ArcaneKit.spot(origin, cursor(origin, dir, kit.frost_range), kit.frost_range), 0.5) if game.arena else origin
	# Expansão and Permanência: only the Geada and the embers are longer and wider (D-15)
	p.radius = (kit.frost_radius + _stat(&"geada_radius_add")) * (1.0 + _stat(&"area_size_pct"))
	p.life = (kit.frost_time + _stat(&"geada_time_add")) * (1.0 + _stat(&"area_time_pct"))
	p.tick = 0.0
	p.conj = _new_conj()
	p.node = _disc(p.radius, ElementLook.COLD, 0.28)
	p.node.position = Vector3(p.at.x, 0.05, p.at.y)
	frost = p
	tally.frosts += 1
	game.fx.ring(p.at, p.radius, ElementLook.COLD, 0.4, 0.15, true)
	game.fx.burst(&"frost", Vector3(p.at.x, 0.4, p.at.y))
	Audio.play(CombatSounds.EVENTS[&"circle"])


func _step_frost(dt: float) -> void:
	var p := frost
	if p == null:
		return
	p.life -= dt
	if p.life <= 0.0:
		_end_frost()
		return
	p.tick -= dt
	if p.tick > 0.0:
		return
	p.tick += kit.frost_step
	game.horde.in_circle(p.at, p.radius, _found)
	for e: Enemy in _found.duplicate():
		if not e.alive or e.invulnerable:
			continue
		var dealt := kit.frost_dps * kit.frost_step * (1.0 + (_stat(&"dome_shot_pct") if _in_dome(p.at) else 0.0))
		if not game.combat.hit_enemy(e, dealt, FROST_TAGS, Vector2.ZERO, 0.0, false):
			_conj = p.conj
			apply_element(e, ElementBook.ICE, AREA)


func _end_frost() -> void:
	if frost != null:
		frost.node.queue_free()
		frost = null


## The Arco Voltaico: the nearest enemy to her, then the nearest to it not yet hit, up to arc_targets (the Gifts add); Eletrizado on each.
func _arc(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	var count := kit.arc_targets + int(_stat(&"arc_targets"))
	var hit: Array[Enemy] = []
	var from := origin
	var reach := kit.arc_range
	var mult := 1.0 + (_stat(&"dome_shot_pct") if _in_dome(origin) else 0.0)
	var fx := game.fx
	_new_conj()
	for _i in count:
		var best: Enemy = null
		game.horde.in_circle(from, reach, _near)
		for n: Enemy in _near:
			if n.alive and not n.invulnerable and not hit.has(n) and (best == null or n.pos.distance_squared_to(from) < best.pos.distance_squared_to(from)):
				best = n
		if best == null:
			break
		var at := Vector3(best.pos.x, 1.0 + best.y, best.pos.y)
		fx.burst(&"spark", at)
		fx.ring(best.pos, 0.8, ElementLook.VOLT, 0.2, 0.1, true)
		fx.arc_leap(from, best.pos)
		hit.append(best)
		var away := (best.pos - from).normalized() if best.pos.distance_to(from) > 0.01 else dir
		if not game.combat.hit_enemy(best, kit.arc_damage * mult, node.tags, away, 0.0, false):
			apply_element(best, ElementBook.VOLT)
		from = best.pos
		reach = kit.arc_jump
	tally.arcs += 1
	if not hit.is_empty():
		fx.shake(1.0)
		Audio.play(CombatSounds.EVENTS[&"circle"])


## A bolt of hers was thrown (Combat.strike, effect WAVE). Estilhaço Gêmeo: a second charge. The first cast gives its recharge
## back at once; the next one runs it; a charge comes back every recharge (_step_shard).
func thrown(node: ComboNode) -> void:
	if not node.has_tag(&"ice"):
		return
	var charges := 1 + int(_stat(&"shard_charges"))
	_shards_used += 1
	if _shards_used < charges:
		game.player.runner.cooldown_refund(node.id, 99.0, 0.0)


func _step_shard(dt: float) -> void:
	if _shards_used <= 0:
		return
	var node := ComboTree.find(game.player.tree.neutral, ComboNode.In.HEAVY)
	if node == null or game.player.runner.cooldown_left(node.id) > 0.0:
		return
	_shard_t += dt
	if _shard_t >= node.cooldown * (1.0 - clampf(-_stat(&"cooldown_pct", node.tags), 0.0, 0.5)):
		_shard_t = 0.0
		_shards_used -= 1


## Chão Ardente: the floor burns EMBER_SECONDS; Queimadura on whoever stands in it every EMBER_STEP (it does not renew itself).
func _lay_embers(at: Vector2) -> void:
	var p := Patch.new()
	p.at = at
	p.radius = kit.ember_radius * (1.0 + _stat(&"area_size_pct"))
	p.life = EMBER_SECONDS * (1.0 + _stat(&"area_time_pct"))
	p.node = _disc(p.radius, ElementLook.FIRE, 0.3)
	p.node.position = Vector3(at.x, 0.05, at.y)
	var keep := _conj  # (a patch is a conjuration of its own; the one that laid it goes on)
	p.conj = _new_conj()
	_conj = keep
	_embers.append(p)
	while _embers.size() > EMBER_MAX:
		var old: Patch = _embers.pop_front()
		old.node.queue_free()


func _step_embers(dt: float) -> void:
	for p in _embers.duplicate():
		p.life -= dt
		if p.life <= 0.0:
			_embers.erase(p)
			p.node.queue_free()
			continue
		p.tick -= dt
		if p.tick <= 0.0:
			p.tick += EMBER_STEP
			game.horde.in_circle(p.at, p.radius, _found)
			for e: Enemy in _found.duplicate():
				if e.alive:
					_conj = p.conj
					apply_element(e, ElementBook.FIRE, AREA)


## Confluência: whoever stands in the Geada and in an ember at once is shocked by a Choque Térmico every `confluence_gap` seconds, with
## no state needed and none consumed (no residue, ember nor spread: it is an area's).
func _step_confluence(dt: float) -> void:
	var gap := _stat(&"confluence_gap")
	if gap <= 0.0 or _stat(&"confluence") <= 0.0 or frost == null or _embers.is_empty():
		return
	_confl_t += dt
	if _confl_t < CONFLUENCE_STEP:
		return
	_confl_t -= CONFLUENCE_STEP
	game.horde.in_circle(frost.at, frost.radius, _found)
	for e: Enemy in _found.duplicate():
		if not e.alive or e.invulnerable or book.now - float(_confl.get(e, -1000.0)) < gap - 0.0001:
			continue
		for p in _embers:
			if e.pos.distance_to(p.at) <= p.radius + e.def.radius:
				_confl[e] = book.now
				var r := Reaction.make(Reaction.Kind.THERMAL, e)
				r.damage = kit.thermal * (1.0 + _stat(&"react_pct"))
				_play(r)
				break


func _suspend(node: ComboNode) -> void:
	_end_dome()
	var d := Dome.new()
	d.tags = node.tags
	d.life = kit.dome_time + _stat(&"dome_time")  # Suspensão Ampla
	d.radius = kit.dome_radius * (1.0 + _stat(&"dome_size_pct"))
	d.node = _dome_node(d.radius, 0.1)
	dome = d
	tally.domes += 1
	if _stat(&"dome_shield", d.tags) > 0.0 and not game.player.shield_ready:
		game.player.shield_ready = true  # (Shomael: the dome opens with the shield ready)
		game.fx.burst(&"heal", Vector3(game.player.pos.x, 1.2, game.player.pos.y))
	game.fx.ring(game.player.pos, d.radius, ElementLook.VOLT, 0.35, 0.15, true)
	Audio.play(CombatSounds.EVENTS[&"circle"])


## The dome ends by its time (Lumael): she is healed for each enemy it held, up to DOME_HEAL_CAP.
func _dome_heals(d: Dome) -> void:
	var per := _stat(&"dome_heal", d.tags)
	if per <= 0.0:
		return
	var n := 0
	for e: Enemy in d.touched.keys():
		if e.alive:
			n += 1
	if n > 0:
		game.player.heal(per * mini(n, DOME_HEAL_CAP))
		game.fx.burst(&"heal", Vector3(game.player.pos.x, 1.2, game.player.pos.y))


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
		_dome_heals(d)
		_end_dome()
		return
	var at := game.player.pos
	d.node.position = Vector3(at.x, 1.1, at.y)
	_hold_shots(d, at)
	game.horde.in_circle(at, d.radius, _found)
	var push := _stat(&"push_pct", d.tags)  # (Galael: the rim shoves outward)
	for e: Enemy in _found:
		if e.def.behavior != EnemyDef.Behavior.BOSS:
			e.slow_t = maxf(e.slow_t, kit.dome_slow)
			if push > 0.0 and e.pos.distance_to(at) >= d.radius * DOME_RIM:
				var out := (e.pos - at).normalized()
				e.pos = game.arena.sweep(e.pos, e.pos + out * DOME_PUSH * push * dt, e.def.radius) if game.arena else e.pos + out * DOME_PUSH * push * dt
		if not d.touched.has(e):
			d.touched[e] = true
			game.combat.touch(e, d.tags)  # (burn, frost, weakness, mark of the Blessings of the E, once to each that comes in)


## Enemy shots that reach the dome stop in the air.
func _hold_shots(d: Dome, at: Vector2) -> void:
	for s in game.projectiles.shots:
		if Projectiles.hostile(s) and not s.frozen and s.life > 0.0 and s.pos.distance_to(at) <= d.radius + s.radius:
			s.frozen = true
			d.held.append(s)
			tally.held += 1
			game.fx.burst(&"spark", Vector3(s.pos.x, Projectiles.HEIGHT, s.pos.y))


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



# ---------- the Passo ----------

## Rastro: embers where she left and where she came out (a Blessing's, stat dodge_ember_dps).
func _on_dodged(_dir: Vector2) -> void:
	_lay_embers(game.player.last_blink_from)  # (V2: the Passo leaves an ember where she left; EMBER_MAX caps them)
	var trail := _stat(&"dodge_ember_dps")
	if trail > 0.0:
		game.ground.add_zone(Ground.Kind.EMBER, game.player.last_blink_from, STEP_TRAIL.x, STEP_TRAIL.y, trail, Combat.EMBER_CEL_TAGS)
		game.ground.add_zone(Ground.Kind.EMBER, game.player.pos, STEP_TRAIL.x, STEP_TRAIL.y, trail, Combat.EMBER_CEL_TAGS)


## A flat disc on the floor (the Geada's and the embers' area): unlit, translucent.
func _disc(radius: float, color: Color, alpha: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.02
	disc.radial_segments = 24
	disc.rings = 1
	mi.mesh = disc
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func stats() -> Dictionary:
	var out := tally.duplicate()
	out.burn_damage = roundi(float(tally.burn_damage))
	return out
