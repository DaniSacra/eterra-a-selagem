class_name BandFloor
extends RefCounted
## The bands that strike in turn in a fight (RP-11, H-3: the chain that sweeps the bridges of the Ponte dos Condenados;
## docs/design/rooms_progression.md): runs a BandHazard and lays each band, as it warms up, on the floor as a drawn
## floor warning (Ground.add_hazard with CHAIN_SOURCE: the amber band of the runes, GroundLook.Style.HAZARD, until the
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


func _init(g: Game, def: HazardDef) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = BandHazard.new(def, doors)
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	var def := hazard.def
	if game.player.alive():
		for r in def.bands:
			if r.has_point(game.player.pos):
				hero_in += dt
				break
	var did := hazard.step(dt)
	var armed: int = did.armed
	if armed >= 0:
		zone = game.ground.add_hazard(def.bands[armed], def.warn, def.hero_damage, def.enemy_damage, true,
			Ground.CHAIN_SOURCE)
		zone_band = armed
		Audio.play(CombatSounds.EVENTS[&"chain_arm"])
	if int(did.fired) >= 0:
		Audio.play(CombatSounds.EVENTS[&"chain_fire"])


## The fight is over (or the room left): what is warming up goes away without striking.
func stop() -> void:
	if zone != null:
		Ground.end_zone(zone)
		zone = null
	hazard.stop()
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## The room's numbers (RoomTally.hazard).
func tally() -> Dictionary:
	return {"kind": "chain", "hero_in_s": snappedf(hero_in, 0.1)}


func _on_landed(z: Ground.Zone) -> void:
	if z != zone:
		return
	zone = null
	var dealt := PlateFloor.strike(game, z, hazard.def.band_push_of(zone_band), Ground.CHAIN_SOURCE)
	enemy_damage += dealt.x
	kills += int(dealt.y)
