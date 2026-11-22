class_name BandFloor
extends RefCounted
## The bands that strike in turn in a fight (RP-11, H-3: the chain that sweeps the bridges of the Ponte dos Condenados;
## RP-08, H-4: the rift that breathes, the same with no damage; docs/design/rooms_progression.md): runs a BandHazard and lays each band, as it warms up, on the floor as a drawn
## floor warning (Ground.add_hazard named by HazardDef.band_source: the amber band of the runes, GroundLook.Style.HAZARD, until the
## environment-artist's chain swings over it); as it lands it strikes the paladin (as any warning) and every enemy in it,
## and pushes them all along the bridge (PlateFloor.strike). Counts what it dealt and the seconds the paladin stood in a
## band. Rooms makes one when the room's HazardDef is LINE.

var hazard: BandHazard
var game: Game
## The warning of the band warming up (null: none).
var zone: Ground.Zone
var zone_band := -1
var enemy_damage := 0.0
var kills := 0
var hero_in := 0.0
## Enemies it pushed, and wind-ups or attacks its push cut (the rift that breathes).
var pushed := 0
var cut := 0
var _bodies := PackedVector2Array()
var pieces: Array[HazardPiece] = []
var _shown: Array[Vector2] = []


## awake false: the hazard sleeps (a trap early in the descent: HazardDef.from_progress); it strikes nothing and warns nothing.
func _init(g: Game, def: HazardDef, awake := true, progress := 0.0) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = BandHazard.new(def, doors, progress)
	if not awake:
		hazard.stop()
	g.ground.hazard_landed.connect(_on_landed)
	# SW-G7: the room's piece of each band (the Ponte's chain: post, arm, weight), told its state as it changes
	for i in def.bands.size():
		pieces.append(g.arena.look.hazard_piece(def.band_source, i) if g.arena.look != null else null)
		_shown.append(Vector2(-1, -1))
	_show_pieces()


func step(dt: float) -> void:
	var def := hazard.def
	if game.player.alive():
		for r in def.bands:
			if r.has_point(game.player.pos):
				hero_in += dt
				break
	_bodies.clear()
	if def.band_busy:
		for e in game.horde.list:
			if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS:
				_bodies.append(e.pos)
	var did := hazard.step(dt, _bodies)
	var armed: int = did.armed
	if armed >= 0:
		zone = game.ground.add_hazard(def.bands[armed], def.warn, def.hero_damage, def.enemy_damage, true,
			def.band_source)
		zone_band = armed
		Audio.play(CombatSounds.EVENTS[StringName(String(def.band_source) + "_arm")])
	if int(did.fired) >= 0:
		Audio.play(CombatSounds.EVENTS[StringName(String(def.band_source) + "_fire")])
	_show_pieces()


func _show_pieces() -> void:
	for i in pieces.size():
		var st := hazard.state(i)
		if st == _shown[i]:
			continue
		_shown[i] = st
		if pieces[i] != null and is_instance_valid(pieces[i]):
			pieces[i].set_state(Vector3(st.x, st.y, 0.0))


## The fight is over (or the room left): what is warming up goes away without striking.
func stop() -> void:
	if zone != null:
		Ground.end_zone(zone)
		zone = null
	hazard.stop()
	_show_pieces()
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## The room's numbers (RoomTally.hazard).
func tally() -> Dictionary:
	var out := {"kind": String(hazard.def.band_source), "hero_in_s": snappedf(hero_in, 0.1), "pushed": pushed,
		"cut": cut}
	if hazard.def.band_source == Ground.TRAP_SOURCE:
		out["fired"] = hazard.fired  # SR-P1: how often the blades flew (damage and kills: RoomTally)
	return out


func _on_landed(z: Ground.Zone) -> void:
	if z != zone:
		return
	zone = null
	var cuts := game.horde.interrupts
	var dealt := PlateFloor.strike(game, z, hazard.def.band_push_of(zone_band), hazard.def.band_source,
		hazard.def.enemy_damage <= 0.0)
	cut += game.horde.interrupts - cuts
	pushed += int(dealt.z)
	enemy_damage += dealt.x
	kills += int(dealt.y)
