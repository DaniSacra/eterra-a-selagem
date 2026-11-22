class_name PlateFloor
extends RefCounted
## The slabs that strike when stepped on in a fight (RP-06, H-2; docs/design/rooms_progression.md): runs a PlateHazard
## with the paladin and the enemies standing, lays each armed slab on the floor as an undrawn warning
## (Ground.add_hazard with PLATE_SOURCE: as it lands it strikes the paladin, as any warning, and every enemy standing on
## it, hazard_landed, here) and draws every slab itself (GroundLook.plate: the cracked frame at rest, the amber reaching
## in as it arms). A slab with a push (RP-13, the edge that crumbles) throws whoever it struck toward the firm floor.
## Counts what it dealt and the seconds the paladin stood on a slab for the room's numbers. Rooms makes one when the
## room's HazardDef is PLATES; the drawing hangs from the arena and goes with it.

const NUMBER_COLOR := RuneFloor.NUMBER_COLOR
## How high over the floor the slabs are drawn (under every warning: Ground lays them from 0.06).
const Y := 0.05

var hazard: PlateHazard
var game: Game
## The warning of each armed slab (null: none).
var zones: Array[Ground.Zone] = []
var nodes: Array[MeshInstance3D] = []
## SW-G7: the room's piece of each slab (the environment artist's HazardPiece: the joint, the chevrons, the ember fissure;
## null for a strip or a room without the piece) and the slit a slab arms (RP-16), with the last state each was given.
var pieces: Array[HazardPiece] = []
var slits: Array[HazardPiece] = []
var _shown: Array[Vector3] = []
## Life it took from the enemies, enemies it felled, and the seconds the paladin stood on a slab.
var enemy_damage := 0.0
var kills := 0
## RP-16: what the slits dealt to the enemies (inside enemy_damage) and how many enemies they struck.
var slit_damage := 0.0
var slit_struck := 0
var hero_on := 0.0
## AT-H2: the paladin's pull in course (the way, the metres left, the seconds left), how many pulls, and the blows that
## only sparked on the niche's skeleton or the plant (AT-H3).
var _pull_dir := Vector2.ZERO
var _pull_left := 0.0
var _pull_time := 0.0
var pulled := 0
var sparked := 0
var _bodies := PackedVector2Array()
## AT-H2: the seconds a pull takes (combat_cadence.md 9.3: 0.1 to 0.15 s, never one frame).
const PULL_TIME := 0.12
## The step the pull is measured in against the other warnings and stone.
const PULL_STEP := 0.05


## awake: whether the descent reached HazardDef.from_progress (else the slabs lie drawn and never strike).
func _init(g: Game, def: HazardDef, awake := true, progress := 0.0) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = PlateHazard.new(def, doors, awake, progress)
	zones.resize(hazard.count())
	for i in hazard.count():
		var n := GroundLook.new_node()
		g.arena.add_child(n)
		GroundLook.plate_band(n, hazard.from[i], hazard.dirs[i], hazard.lengths[i], hazard.widths[i], Y)
		nodes.append(n)
		var piece: HazardPiece = null
		var slit: HazardPiece = null
		if g.arena.look != null:
			piece = g.arena.look.hazard_piece(def.plate_source, i)
			if def.aims_away(i):
				slit = g.arena.look.slit_at(Vector2(def.aims[i].x, def.aims[i].y))
		pieces.append(piece)
		slits.append(slit)
		n.visible = piece == null
		_shown.append(Vector3(-1, -1, -1))
	g.ground.hazard_landed.connect(_on_landed)
	_show_pieces(true)
	if not def.sparks.is_empty():
		g.combat.reached.connect(_on_reached)


func step(dt: float) -> void:
	var p := game.player.pos if game.player.alive() else Vector2.INF
	if hazard.plate_at(p) >= 0:
		hero_on += dt
	_bodies.clear()
	for e in game.horde.list:
		if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS:
			_bodies.append(e.pos)
	var mine := 0
	for ph in hazard.phase:
		if ph == PlateHazard.Phase.ARM:
			mine += 1
	var did := hazard.step(dt, p, _bodies, maxi(0, game.ground.room_live() - mine))
	var def := hazard.def
	for i: int in did.armed:
		if def.aims_away(i):
			# RP-16: the slab arms its slit; the band from the slit's mouth warns in the amber, drawn, and strikes
			var a := def.aims[i]
			var from := Vector2(a.x, a.y)
			var to := Vector2(a.z, a.w)
			zones[i] = game.ground.add_band(from, to - from, from.distance_to(to), def.aim_width, def.warn,
				def.hero_damage_of(i), def.enemy_damage, true, Ground.SLIT_SOURCE)
		else:
			zones[i] = game.ground.add_band(hazard.from[i], hazard.dirs[i], hazard.lengths[i], hazard.widths[i], def.warn,
				def.hero_damage_of(i), def.enemy_damage, false, def.plate_source)
		Audio.play(CombatSounds.EVENTS[StringName(_cue() + "_arm")])
		if def.dwell > 0.0:
			_dust(i)
	for i: int in did.fired:
		Audio.play(CombatSounds.EVENTS[&"slit_fire" if def.aims_away(i) else StringName(_cue() + "_fire")])
	for i in nodes.size():
		if is_instance_valid(nodes[i]):
			var st := hazard.state(i)
			GroundLook.set_plate(nodes[i], st)
			# SW-G7: with the room's piece the slab at rest is the piece; the drawn frame only shows the amber warming up
			nodes[i].visible = pieces[i] == null or st.x > 0.0 or st.y > 0.0
	_show_pieces()
	_step_pull(dt)


## SW-G7: tells each slab's piece (and the slit it arms) its state when it changes, and while it rests (the seconds of
## its rest left let the slab rise back). first: every piece, at rest or asleep.
func _show_pieces(first := false) -> void:
	for i in pieces.size():
		var st := hazard.state(i) if not first else Vector3.ZERO
		var spent := hazard.left[i] if hazard.phase[i] == PlateHazard.Phase.REST else 0.0
		if not first and st == _shown[i] and spent <= 0.0:
			continue
		_shown[i] = st
		for piece: HazardPiece in [pieces[i], slits[i]]:
			if piece != null and is_instance_valid(piece):
				piece.set_state(st, not hazard.awake, spent)


## AT-H2: the paladin pulled toward the niche a little each frame; his dodge (or his fall) cuts it off.
func _step_pull(dt: float) -> void:
	if _pull_left <= 0.0:
		return
	var pl := game.player
	if not pl.alive() or pl.state == Player.State.DODGE:
		_pull_left = 0.0
		return
	var k := minf(1.0, dt / maxf(_pull_time, dt))
	var d := _pull_left * k
	pl.pos = game.arena.sweep(pl.pos, pl.pos + _pull_dir * d, Player.RADIUS)
	_pull_left -= d
	_pull_time -= dt
	if _pull_time <= 0.0:
		_pull_left = 0.0


## How far from p the paladin may be pulled along `dir` (up to `most`): never into another warning on the floor
## (`own` is the one that pulls) nor into stone (R10).
func pull_reach(p: Vector2, dir: Vector2, most: float, own: Ground.Zone) -> float:
	var ok := 0.0
	var t := PULL_STEP
	while t <= most + 0.001:
		var q := p + dir * t
		if game.arena.sweep(p, q, Player.RADIUS).distance_to(q) > 0.01:
			break
		var inside := false
		for z in game.ground.zones:
			if z != own and z.kind == Ground.Kind.WARNING and z.life > 0.0 and Ground.inside(z, q, Player.RADIUS):
				inside = true
				break
		if inside:
			break
		ok = t
		t += PULL_STEP
	return ok


## AT-H2, AT-H3: a blow of the paladin on the skeleton or the plant only sparks (and the leaves shrink: the strip's
## drawing flashes its ember, placeholder).
func _on_reached(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> void:
	var def := hazard.def
	for i in def.sparks.size():
		var at := def.sparks[i]
		if ColumnFall.touches(shape, origin, dir, reach, width, at, def.spark_radius):
			sparked += 1
			game.fx.burst(&"spark", Vector3(at.x, 0.8, at.y))


## The fight is over (or the room left): what is warming up goes away without striking; the slabs stay drawn at rest.
func stop() -> void:
	for i in zones.size():
		if zones[i] != null:
			Ground.end_zone(zones[i])
			zones[i] = null
	hazard.stop()
	_pull_left = 0.0
	for i in nodes.size():
		if is_instance_valid(nodes[i]):
			GroundLook.set_plate(nodes[i], Vector3.ZERO)
			nodes[i].visible = pieces[i] == null
	for i in pieces.size():
		_shown[i] = Vector3(-1, -1, -1)
	_show_pieces(true)
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)
	if game.combat.reached.is_connected(_on_reached):
		game.combat.reached.disconnect(_on_reached)


## The room's numbers (RoomTally.hazard): {kind, strikes, armed by him and by them, seconds he stood on one}.
func tally() -> Dictionary:
	var out := {"kind": String(hazard.def.plate_source), "armed_by_hero": hazard.armed_by_hero, "armed_by_enemy": hazard.armed_by_enemy,
		"hero_on_s": snappedf(hero_on, 0.1)}
	if not hazard.def.aims.is_empty():
		out["slit_damage"] = snappedf(slit_damage, 0.1)
		out["slit_struck"] = slit_struck
	if hazard.def.pull > 0.0:
		out["pulled"] = pulled
	if not hazard.def.sparks.is_empty():
		out["sparked"] = sparked
	return out


func _on_landed(z: Ground.Zone) -> void:
	var i := zones.find(z)
	if i < 0:
		return
	zones[i] = null
	var before := game.horde.list.filter(func(e: Enemy) -> bool: return e.alive and e.def.behavior != EnemyDef.Behavior.BOSS and Ground.inside(z, e.pos)).size()
	var def := hazard.def
	var pull := Vector2.ZERO
	if def.pull > 0.0:
		pull = -hazard.dirs[i]
		# the paladin's pull is his own (over PULL_TIME, cut short at other warnings); the enemies' is the push
		var p := game.player.pos
		if game.player.alive() and Ground.inside(z, p, Player.RADIUS * 0.6):
			_pull_dir = pull
			_pull_left = pull_reach(p, pull, def.pull, z)
			_pull_time = PULL_TIME
			pulled += 1
	var dealt := strike(game, z, def.push_of(i), z.source, false, false, def.push_out, pull * def.pull)
	enemy_damage += dealt.x
	kills += int(dealt.y)
	if hazard.def.aims_away(i):
		slit_damage += dealt.x
		slit_struck += before


## The sounds' name: "plate" the slabs, else the source's (RP-10: "roots").
func _cue() -> String:
	return "plate" if hazard.def.plate_source == Ground.PLATE_SOURCE else String(hazard.def.plate_source)


## A root waking (RP-10): dust along it as it cracks, placeholder until the environment artist's root.
func _dust(i: int) -> void:
	for k in 3:
		var at := hazard.from[i] + hazard.dirs[i] * hazard.lengths[i] * (k + 0.5) / 3.0
		game.fx.burst(&"dust", Vector3(at.x, 0.3, at.y))


## A floor warning `z` of the room's own hazard landed: deals its damage to every enemy (not the boss) inside it and
## pushes everyone it struck by `push` (swept: nobody goes through stone nor falls); the paladin's damage is the
## Ground's own. cut: a push that deals nothing cuts the wind-up or attack of whoever it moved (the rift that breathes,
## RP-08: the flood trap of the Hades II; never a charge that cannot be cut, nor a guardian). Returns (life taken,
## enemies felled, enemies pushed). Shared by the slabs and the bands (BandFloor).
## bodies: whoever's body touches it is struck (a column falling: RP-09), not only who stands in it. out: everyone it
## struck is also thrown this far away from its middle line (RP-10, a root shrugging them off).
## enemy_pull: a shove for the enemies only (AT-H2, the niche pulls them; the paladin's pull is PlateFloor's own).
static func strike(game: Game, z: Ground.Zone, push: Vector2, source: StringName, cut := false, bodies := false, out := 0.0,
		enemy_pull := Vector2.ZERO) -> Vector3:
	var dealt := 0.0
	var felled := 0
	var pushed := 0
	var h := game.horde
	h.dealing = source
	for e in h.list.duplicate():
		if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or not Ground.inside(z, e.pos, e.def.radius if bodies else 0.0):
			continue
		var before: float = e.hp
		if z.hazard > 0.0 and h.damage(e, z.hazard, Vector2.ZERO, 0.0, NUMBER_COLOR):
			felled += 1
		dealt += maxf(0.0, before - e.hp)
		var shove := push + away(z, e.pos) * out + enemy_pull
		if shove != Vector2.ZERO and e.alive:
			e.pos = game.arena.sweep(e.pos, e.pos + shove, e.def.radius)
			pushed += 1
			var charging: bool = e.state == Enemy.State.ATTACK and e.def.stun_immune_attacking
			if cut and e.def.stun_time > 0.0 and not charging:
				h.interrupt(e)
	h.dealing = &""
	if (push != Vector2.ZERO or out > 0.0) and game.player.alive() and Ground.inside(z, game.player.pos, Player.RADIUS * 0.6):
		var p := game.player.pos
		game.player.pos = game.arena.sweep(p, p + push + away(z, p) * out, Player.RADIUS)
	return Vector3(dealt, felled, pushed)


## The way from a line zone's middle line out to p, across it (unit; zero for other shapes).
static func away(z: Ground.Zone, p: Vector2) -> Vector2:
	if z.shape != Ground.Shape.LINE:
		return Vector2.ZERO
	var d := p - z.pos
	var across := d - z.dir * d.dot(z.dir)
	if across.length_squared() < 0.0001:
		return Vector2(-z.dir.y, z.dir.x)
	return across.normalized()
