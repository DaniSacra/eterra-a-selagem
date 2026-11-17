class_name PsalmPlay
extends RefCounted
## The Psalms taken at play (E4, docs/design/e4_psalms.md): the fight's events go to the rules (Psalms, pure) and what
## they answer is done here with the systems the game already has: the circle of light (Ground BIND), the special's
## wave (Combat.throw_wave), the dodge, the spin, the floor's areas (Ground SHELTER and STONE) and the shots
## (Projectiles.shelter). Game makes one and steps it; with no Psalm taken nothing changes.

## The tags of a Psalm's own hits (DealtBy reads them as psalm).
const TAGS: Array[StringName] = [&"psalm"]

var game: Game
var rules: Psalms
## The drawn shelters, the oldest first (as Psalms.shelters).
var _shelter_zones: Array[Ground.Zone] = []
var _dodging := false
var _found: Array[Enemy] = []


func _init(g: Game, held: Psalms) -> void:
	game = g
	rules = held
	game.player.struck.connect(_on_struck)
	game.player.cast_released.connect(_on_cast)
	game.horde.killed.connect(_on_killed)
	game.projectiles.shelter = rules.bars


func step(dt: float) -> void:
	rules.step(dt)
	while _shelter_zones.size() > rules.shelters.size():
		_shelter_zones.pop_front()
	# the Abrigo: the shelter rises where the dodge ends (he fights from it)
	var dodging := game.player.state == Player.State.DODGE
	if _dodging and not dodging:
		var p := rules.holding(PsalmDef.Effect.SHELTER)
		if p != null and game.player.alive():
			_shelter(p)
	_dodging = dodging


## A room ends (its floor's areas went with it).
func clear() -> void:
	rules.clear()
	_shelter_zones.clear()


func _shelter(p: PsalmDef) -> void:
	var at := game.player.pos
	for k in rules.shelter(at, p):
		if not _shelter_zones.is_empty():
			Ground.end_zone(_shelter_zones.pop_front())
	var z := game.ground.add_zone(Ground.Kind.SHELTER, at, p.radius, p.duration, 0.0, TAGS)
	_shelter_zones.append(z)
	game.fx.ring(at, p.radius, p.color, 0.3)


## The circle of light is let go (Combat.cast made it first): the Sentinela has it walk with him and strike whoever
## comes in.
func _on_cast(_at: Vector2, _omega: bool) -> void:
	var p := rules.holding(PsalmDef.Effect.SENTINEL)
	if p == null:
		return
	for i in range(game.ground.zones.size() - 1, -1, -1):
		var z := game.ground.zones[i]
		if z.kind == Ground.Kind.BIND:
			z.follow = true
			z.strike = p.damage
			z.source = &"psalm"
			return


## A move strikes (Player.struck, after Combat.strike): the Pastor's flock leaves with the special's wave, the
## Rocha's stone comes with the spin.
func _on_struck(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	var flock := rules.holding(PsalmDef.Effect.FLOCK)
	if flock != null and node.effect == ComboNode.Effect.WAVE and node.has_tag(&"heavy") and rules.lights > 0:
		var tags: Array[StringName] = node.tags.duplicate()
		tags.append_array(TAGS)
		var color := game.combat.color_of(node.tags)
		for d in Psalms.fan(dir, rules.release(), flock.spread):
			game.combat.throw_wave(node, origin, d, color, tags).counted = true
	var stone := rules.holding(PsalmDef.Effect.STONE)
	if stone != null and node.has_tag(&"spin") and rules.plant(stone):
		_stone(stone, origin)


## The Rocha's stone: a blow all around (stunning the common ones), then it stays, slowing whoever stands in it.
func _stone(p: PsalmDef, at: Vector2) -> void:
	var combat := game.combat
	game.fx.ring(at, p.radius, p.color, 0.35, 0.15, true)
	game.fx.burst(&"dust", Vector3(at.x, 0.2, at.y))
	game.fx.shake(1.2)
	Audio.play(CombatSounds.EVENTS[&"hit_heavy"])
	game.horde.in_circle(at, p.radius, _found)
	combat.source = &"psalm"
	for e: Enemy in _found.duplicate():
		var away := (e.pos - at).normalized() if e.pos.distance_to(at) > 0.01 else Vector2.RIGHT
		var died := combat.hit_enemy(e, p.damage, TAGS, away, 8.0, false)
		# a common body (no armor left, not a guardian nor Morvath: stun_time 0) stands stunned
		if not died and not e.invulnerable and e.armor <= 0.0 and e.def.stun_time > 0.0:
			game.horde.flinch(e, p.stun)
	combat.source = &""
	game.ground.add_zone(Ground.Kind.STONE, at, p.radius, p.duration, 0.0, TAGS)


## Someone fell: the Pastor gathers a light (its mote flies to him).
func _on_killed(e: Enemy) -> void:
	var p := rules.holding(PsalmDef.Effect.FLOCK)
	if p == null:
		return
	var before := rules.lights
	rules.gather(p)
	if rules.lights > before:
		var to := game.player.pos - e.pos
		game.fx.chips(Vector3(e.pos.x, 1.0, e.pos.y), Vector3(to.x, 0.6, to.y).normalized(), p.color, 4, 6.0, 0.1, 0.4, 0.6)
