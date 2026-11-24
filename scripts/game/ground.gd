class_name Ground
extends Node3D
## Areas on the floor. WARNING: an enemy attack announced before it lands (hurts the paladin when it fills).
## The others hurt enemies standing in them every TICK: EMBER (fire), MARK (light), HOLY (consecrated, slows),
## STEAM (blinds), BIND (the paladin's circle of light: holds the enemies inside). Two of the Psalms' (E4): SHELTER (the
## Abrigo's shelter: harms nobody, Psalms.bars undoes the shots) and STONE (the Rocha's stone: slows who stands in it).
## Positions are (x, z) in meters.

signal hit_player(amount: float, from: Vector2)
## A floor that strikes on its own (E5, the runes: add_hazard) struck: RuneFloor hurts the enemies standing in it.
signal hazard_landed(z: Zone)
## Any warning that lands, on the frame its blow does (AT-Q1: what breaks the breakables, BreakFloor).
signal zone_landed(z: Zone)

enum Kind { WARNING, EMBER, MARK, HOLY, STEAM, BIND, SHELTER, STONE }
## The same order as GroundLook.Shape (which draws them).
enum Shape { CIRCLE, LINE, ARC }

const TICK := 0.25
## Seconds the landing ring of a blow with another right after it lives (Zone.land_quick; 0.3 the others).
const LAND_QUICK := 0.1
## The source of the floor's own warnings (the runes, E5): "Derrotado por: Runas Instáveis" (DefeatCause).
const HAZARD_SOURCE := &"runes"
## The source of the slabs that strike when stepped on (RP-06, PlateFloor): "Derrotado por: Laje Rachada".
const PLATE_SOURCE := &"plates"
## RP-11: the bands that strike in turn (the chain of the Ponte dos Condenados, BandFloor).
const CHAIN_SOURCE := &"chain"
## RP-08: the rift that breathes (BandFloor, no damage).
const BREATH_SOURCE := &"breath"
## RP-09: a column toppling (ColumnFloor; it never hurts the paladin).
const FALL_SOURCE := &"column"
## RP-10: the roots that strike in the Jardim (PlateFloor with strips): "Derrotado por: Raiz Morta".
const ROOT_SOURCE := &"roots"
## RP-16: the arrow slit a slab arms (PlateFloor with HazardDef.aims): "Derrotado por: Seteira".
const SLIT_SOURCE := &"slit"
## SR-P1: the blades of the wall trap (BandFloor with HazardDef.band_source &"trap").
const TRAP_SOURCE := &"trap"
## A1 (rooms_progression.md): RP-14 the crystal's discharge (RuneFloor), RP-20 the stones of the vault (DropFloor),
## RP-12 the oil urn's blast and its running flame (UrnFloor).
const CRYSTAL_SOURCE := &"crystal"
const ROCKS_SOURCE := &"rocks"
const URN_SOURCE := &"urn"
const OIL_SOURCE := &"oil"
## AT-H2 the skeleton in the Cripta B's niche, AT-H3 the hostile plant of the Jardim B (PlateFloor strips).
const NICHE_SOURCE := &"niche"
const PLANT_SOURCE := &"plant"
## SR-P2 the slab that gives (PlateFloor, plate_source &"sag"), SR-P3 the spiked pit grate (BandFloor, band_source &"spikes").
const SAG_SOURCE := &"sag"
const SPIKES_SOURCE := &"spikes"
## 2026-11-23 the spike plate of the Knight's hall (PlateFloor, plate_source &"spikeplate"; the grate's piece).
const SPIKE_PLATE_SOURCE := &"spikeplate"
## Sources of the room's own warnings that count against its two at once (combat_cadence.md 9.2 R9); a column toppling
## (the paladin's, hurting only them) and the rift's breath (no harm) do not.
const ROOM_SOURCES: Array[StringName] = [HAZARD_SOURCE, PLATE_SOURCE, CHAIN_SOURCE, ROOT_SOURCE, SLIT_SOURCE, TRAP_SOURCE,
	CRYSTAL_SOURCE, ROCKS_SOURCE, URN_SOURCE, OIL_SOURCE, NICHE_SOURCE, PLANT_SOURCE, SAG_SOURCE, SPIKES_SOURCE,
	SPIKE_PLATE_SOURCE]
const POOL := 48
## C1e, the Armadilheiro's plates (Zone.tags): the zone's own fill is hidden; C1eMarks draws the X and Ground the dust where one lands.
const PLATE_TAG := &"trap_plate"
## A runner's death burst (combate_c1_leitura 4): the ring of its landing in the grey of coals, 8 bone chips.
const EMBER_COLOR := Color(0.62, 0.34, 0.16)
const EMBER_BONE := Color(0.86, 0.82, 0.72)
const EMBER_CHIPS := 8
## Past this many of its circles at once the new ones fill to EMBER_FILL of their light (the rim stays whole).
const EMBER_STACK := 3
const EMBER_FILL := 0.6
## Strength of the drawing of each kind of area: warnings bright enough to read on the dark floor, the paladin's
## circle of light (big, 3 s) a fine rim around a veil so the fight inside still reads, the rest in between.
const WARNING_STRENGTH := GroundLook.WARNING_STRENGTH
## The circle of light is read by its rim and the marks inside it (this strength); its fill is only a veil
## (BIND_VEIL of this strength: the floor inside stays within a few steps of brightness of the floor outside).
const BIND_STRENGTH := 0.55
const BIND_VEIL := 0.009
const BIND_MARKS := 7.0
const AREA_STRENGTH := 0.8
## Meters of the bright rim around a warning (its size is always the attack's).
const RIM_METERS := GroundLook.RIM_METERS
## The ring where an enemy's blow lands, when its caster has no colour of its own.
const LAND_COLOR := Color(1.0, 0.3, 0.2)
## The red of danger in an eruption's circle (art review P5): the warnings' strength less the circle's own violet veil
## and rim that add to it (at GroundLook.WARNING_STRENGTH its middle clipped to a hot pink).
const RUNE_DANGER := 0.75
## The column of an eruption: its width (share of the circle), height (m) and seconds.
const ERUPTION_WIDTH := 0.55
const ERUPTION_HEIGHT := 5.0
const ERUPTION_TIME := 0.55
## Morvath's ritual circles (cycle 9, ritual_rune.gdshader): what the circle is for. An ERUPTION hurts whoever stands
## in it when it lands, a SUMMON is where one of his dead rises (no harm). His eruptions (Zone.eruption) are drawn so
## on their own; rune_burst draws any of them.
enum Rune { NONE = -1, ERUPTION, SUMMON }
const RUNE_SHADER := preload("res://assets/shaders/ritual_rune.gdshader")
const COLUMN_SHADER := preload("res://assets/shaders/spectral_column.gdshader")
## How strongly a ritual circle is drawn and the width of its rim (m): its edge is the edge of the harm, exactly.
const RUNE_STRENGTH := 1.0
const RUNE_RIM := 0.11
## Seconds a circle takes to dissolve once it has landed.
const RUNE_AFTER := 0.7
## The column of a summon: its width (share of the circle), height (m) and seconds (a summon's is lower and thinner
## than an eruption's, ERUPTION_*: something rises, nothing strikes).
const SUMMON_WIDTH := 0.4
const SUMMON_HEIGHT := 3.0
const SUMMON_TIME := 0.8
## The column's mesh: an open cylinder of radius 1 and height 1 (scaled to each column), narrower at the top.
const COLUMN_TOP := 0.7
const COLUMN_SIDES := 20
const COLORS := {
	Kind.WARNING: GroundLook.WARNING_COLOR, Kind.EMBER: Color(1.0, 0.42, 0.1), Kind.MARK: Color(1.0, 0.82, 0.35),
	Kind.HOLY: Color(1.0, 0.85, 0.45), Kind.STEAM: Color(0.75, 0.85, 0.95), Kind.BIND: Color(1.0, 0.95, 0.8),
	# the Psalms' (E4): ivory over old gold and old gold, inside the palette (never bright yellow nor white)
	Kind.SHELTER: Color(0.95, 0.86, 0.62), Kind.STONE: Color(0.78, 0.62, 0.34),
}

class Zone:
	var kind := Kind.WARNING
	var shape := Shape.CIRCLE
	var pos := Vector2.ZERO
	var dir := Vector2.DOWN
	## Circle and arc: radius. Line: length.
	var radius := 1.0
	## Line: width. Arc: opening in degrees.
	var width := 1.0
	var life := 1.0
	var total := 1.0
	var power := 0.0
	var tick := 0.0
	var color := Color.WHITE
	var tags: Array[StringName] = []
	## Colour of the ring where a warning lands (alpha 0: LAND_COLOR).
	var land_color := Color(0, 0, 0, 0)
	## A blow with another right after it on the same spot (the elite runner's first burst, C19): its landing is only a
	## thin ring for LAND_QUICK s, so the next warning's rim reads under it (P2-C19a).
	var land_quick := false
	## Damage dealt to everything inside when the zone runs out (the held circle of light). 0 = none.
	var burst := 0.0
	## A warning that lands as a column of spectral fire (a boss's eruption) instead of a burst of shadow.
	var eruption := false
	## Drawn as one of Morvath's ritual circles (Rune), or NONE. A SUMMON hurts nothing: one of his dead rises there
	## when it runs out (Boss._call times the rise by it).
	var rune := Rune.NONE
	## Called off (clear_warnings, end_zone): it vanishes without landing (no column).
	var cancelled := false
	## Which attack it belongs to (Boss: the attack's id; "adds" for his dead): the hurt_by count of the fight.
	var source: StringName = &""
	## Which kind of enemy laid it (EnemyDef.id, Horde.acting; &"": none, as the boss's own): "Derrotado por".
	var by: StringName = &""
	## Whoever laid it was off the screen (1), on it (0), unknown (-1: the boss's own; Game reads his place).
	var offscreen := -1
	## It walks with the paladin (the Sentinela's circle of light, E4): its middle is his at every step.
	var follow := false
	## A BIND that strikes each enemy as it comes in, once (the Sentinela): the blow's damage (0: none) and who was
	## struck already.
	var strike := 0.0
	var struck := {}
	## A warning of the floor itself (E5, the runes): what it deals to each enemy inside when it lands (0: not one).
	var hazard := 0.0
	## A warning of the floor itself (add_hazard): its landing is told (hazard_landed) even when it deals nothing (the
	## rift that breathes, RP-08, only pushes).
	var floor_own := false
	var node: MeshInstance3D
	var mat: ShaderMaterial
	## The runner's death burst (combate_c1_leitura 4): it lands in embers and bone, in its own grey of coals.
	var ember := false
	## Drawn as an aim (add_aim_warning), and the lock of a thread that follows the paladin (track_line, lock_line):
	## seconds since it locked (-1: not yet) and whether it clicked.
	var aim := false
	var tracks := false
	var lock_t := -1.0
	var lock_left := 0.0
	var clicked := false
	## PT-1: counts and lands as any warning but is not drawn (a melee blow or a shot: the "!" tells it, not the floor).
	var silent := false

var zones: Array[Zone] = []
var player: Player
## Called with (enemy, zone) for every enemy inside a damaging area at each tick.
var on_zone_hit: Callable
## Called with (zone) when a zone with a burst runs out.
var on_zone_burst: Callable
var horde: Horde
var fx: Fx
## The source of the warning that hurt the paladin last (Zone.source), read by the game as hit_player is emitted.
var last_source: StringName = &""
## Which kind of enemy laid it (Zone.by).
var last_by: StringName = &""
## That warning's seconds on the floor and Zone.offscreen, for the run's log (GP-02).
var last_warn := -1.0
var last_offscreen := -1
## The seconds the last warning of each source (Zone.source) showed, kept as it ends: a boss's crescents follow
## the lanes he marks first (warned_for).
var _warned := {}
var _pool: Array[MeshInstance3D] = []
var _found: Array[Enemy] = []
var _rune_pool: Array[MeshInstance3D] = []
var _column_pool: Array[MeshInstance3D] = []
var _column_mesh: CylinderMesh
## Ritual circles dissolving after they landed, with their columns: [circle, column, seconds, column's seconds].
var _after: Array[Array] = []


## One of Morvath's ritual circles (cycle 9): it marks exactly the area of radius `radius` at `at` and fills for
## warn_time (a faint rune whose light grows, a short pulse just before), then a column of spectral fire rises out of
## it and it dissolves. ERUPTION hurts the paladin standing in it (damage), SUMMON marks where one of his dead rises.
## warn_time <= 0: no warning, only the column and the circle dissolving (one risen at once). Returns the warning.
func rune_burst(at: Vector2, radius: float, warn_time: float, kind: Rune, damage := 0.0) -> Zone:
	if warn_time <= 0.0:
		_dissolve(_rune_node(at, radius, kind), at, radius, kind)
		return null
	var z := add_warning(at, radius, warn_time, damage, Boss.SPECTRAL)
	z.eruption = kind == Rune.ERUPTION
	_as_rune(z, kind)
	return z


## The seconds the last warning of this source showed on the floor (0: none yet).
func warned_for(source: StringName) -> float:
	return float(_warned.get(source, 0.0))


## How many ritual circles are still dissolving (tests).
func dissolving() -> int:
	return _after.size()


## burst: the colour of the magic where the blow lands (the caster's EnemyDef.magic_color); alpha 0: the default.
func add_warning(at: Vector2, radius: float, time: float, damage: float, burst := Color(0, 0, 0, 0)) -> Zone:
	var z := _add(Kind.WARNING, Shape.CIRCLE, at, Vector2.DOWN, radius, 0.0, time, damage)
	z.land_color = burst
	return z


## A runner's death burst: add_warning that lands in embers (EMBER_COLOR, fire, bone chips); drawn lighter when more than
## EMBER_STACK of them stand at once.
func add_ember_warning(at: Vector2, radius: float, time: float, damage: float) -> Zone:
	var z := add_warning(at, radius, time, damage, EMBER_COLOR)
	z.ember = true
	var live := 0
	for o in zones:
		live += int(o.ember and o.life > 0.0)
	if live > EMBER_STACK:
		GroundLook.put(z.mat, &"fill_max", GroundLook.FILL_MAX * EMBER_FILL)
	return z


## A blow dealt by a body, not by a warning landing (T5-08: Morvath's charge): counted as his attack `source`, with the
## seconds its warning showed, for the log and "Derrotado por".
func strike(amount: float, from: Vector2, source: StringName, warn_s: float, offscreen := -1) -> void:
	last_source = source
	last_by = &""
	last_warn = warn_s
	last_offscreen = offscreen
	hit_player.emit(amount, from)


func add_line_warning(from: Vector2, dir: Vector2, length: float, width: float, time: float, damage: float) -> Zone:
	return _add(Kind.WARNING, Shape.LINE, from, dir, length, width, time, damage)


## A line warning drawn as an aim (C17, QW-107: the crossbow's aim, the soldier's pounce): a thread with a bright tip,
## its band filling only over the end of the wind-up (GroundLook.aim). It warns and lands as any line warning.
func add_aim_warning(from: Vector2, dir: Vector2, length: float, width: float, time: float, damage: float) -> Zone:
	var z := add_line_warning(from, dir, length, width, time, damage)
	GroundLook.aim(z.node.material_override as ShaderMaterial)
	z.aim = true
	return z


## A line (or aim) warning that follows the paladin until lock_line: drawn as a thread meanwhile (combate_c1_leitura 6).
func track_line(z: Zone) -> void:
	if z == null or z.shape != Shape.LINE:
		return
	z.tracks = true
	GroundLook.tracking(z.mat, z.aim)


## The thread locks: it pulses once ("travou"), and the aim's band starts to fill. Called each frame it is locked; it
## only counts the first (a zone never tracked, or already locked, is left alone). Drawing and sound only.
func lock_line(z: Zone) -> void:
	if z == null or not z.tracks or z.lock_t >= 0.0:
		return
	z.lock_t = 0.0
	z.lock_left = z.life / maxf(z.total, 0.01)
	GroundLook.lock_pulse(z.mat, z.aim, 0.0, z.lock_left)


## A band of the floor that strikes on its own (E5, the runes; ArenaHazard): the rectangle `r` warms up for `time`
## seconds in amber (GroundLook.Style.HAZARD, drawn under the enemies' warnings) and strikes everyone in it as it ends:
## hero_damage to the paladin (as any warning), enemy_damage to each enemy (hazard_landed). drawn false: it strikes the
## same but shows nothing (the Runes' own floor, RunesLook, draws the tiles warming up: nothing drawn twice). source:
## what names it (HAZARD_SOURCE the runes, PLATE_SOURCE the slabs of RP-06).
func add_hazard(r: Rect2, time: float, hero_damage: float, enemy_damage: float, drawn := true, source := HAZARD_SOURCE) -> Zone:
	return add_band(Vector2(r.position.x, r.get_center().y), Vector2.RIGHT, r.size.x, r.size.y, time, hero_damage,
		enemy_damage, drawn, source)


## add_hazard over any band of the floor: `width` across, `length` along `dir` from `from` (RP-10, a root's strip).
func add_band(from: Vector2, dir: Vector2, length: float, width: float, time: float, hero_damage: float, enemy_damage: float,
		drawn := true, source := HAZARD_SOURCE) -> Zone:
	var z := _add(Kind.WARNING, Shape.LINE, from, dir, length, width, time, hero_damage)
	z.hazard = enemy_damage
	z.floor_own = true
	z.source = source
	z.by = &""
	z.offscreen = 0
	GroundLook.hazard(z.node, from, z.dir, length, width, z.node.position.y)
	z.node.visible = drawn
	return z


## add_hazard round a point (RP-12, the oil urn's ring): the circle of `radius` whole from the first frame, the amber
## filling; as it lands it strikes the paladin hero_damage (as any warning) and every enemy in it (hazard_landed).
func add_round(at: Vector2, radius: float, time: float, hero_damage: float, enemy_damage: float, source: StringName) -> Zone:
	var z := _add(Kind.WARNING, Shape.CIRCLE, at, Vector2.DOWN, radius, 0.0, time, hero_damage)
	z.hazard = enemy_damage
	z.floor_own = true
	z.source = source
	z.by = &""
	z.offscreen = 0
	GroundLook.hazard_round(z.node, at, radius, z.node.position.y)
	return z


## The room's own warnings on the floor now, counted by `group` (a pattern of the runes lays several rectangles: one
## warning): sources in ROOM_SOURCES, still warming up.
func room_live(groups: Dictionary = {}) -> int:
	var n := 0
	for z in zones:
		if z.kind == Kind.WARNING and z.floor_own and z.life > 0.0 and ROOM_SOURCES.has(z.source):
			if z.source == HAZARD_SOURCE or z.source == CRYSTAL_SOURCE or z.source == OIL_SOURCE:
				groups[z.source] = true
			else:
				n += 1
	return n + groups.size()


## The room's own warnings on the floor now as rectangles round them (DropHazard keeps its stones off them; R9).
func room_rects() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for z in zones:
		if z.kind == Kind.WARNING and z.floor_own and z.life > 0.0 and ROOM_SOURCES.has(z.source):
			out.append(bounds(z))
	return out


## The rectangle round a zone.
static func bounds(z: Zone) -> Rect2:
	if z.shape != Shape.LINE:
		return Rect2(z.pos - Vector2.ONE * z.radius, Vector2.ONE * z.radius * 2.0)
	var side := Vector2(-z.dir.y, z.dir.x) * z.width * 0.5
	var end := z.pos + z.dir * z.radius
	var r := Rect2(z.pos + side, Vector2.ZERO)
	for q in [z.pos - side, end + side, end - side]:
		r = r.expand(q)
	return r


## A band of the floor something falls on (RP-09, a column toppling): `width` across, `length` along `dir` from `from`,
## shown `time` in the hazards' amber; as it lands it deals `enemy_damage` to every enemy in it (hazard_landed) and
## nothing to the paladin (as the falling tree of the Hades II).
func add_fall(from: Vector2, dir: Vector2, length: float, width: float, time: float, enemy_damage: float, source: StringName) -> Zone:
	var z := _add(Kind.WARNING, Shape.LINE, from, dir, length, width, time, 0.0)
	z.hazard = enemy_damage
	z.floor_own = true
	z.source = source
	z.by = &""
	z.offscreen = 0
	GroundLook.hazard(z.node, from, z.dir, length, width, z.node.position.y)
	return z


## PT-1: the zone keeps its place, its time and its damage but shows nothing (the bot and the "!" still read it).
static func mute(z: Zone) -> Zone:
	if z != null:
		z.silent = true
		if z.node != null:
			z.node.visible = false
	return z


func add_arc_warning(at: Vector2, dir: Vector2, radius: float, degrees: float, time: float, damage: float) -> Zone:
	return _add(Kind.WARNING, Shape.ARC, at, dir, radius, degrees, time, damage)


## Ends one zone now (as clear_warnings does for all of them): it is released on the next step without landing (a
## ritual circle goes without its column).
## Turns a line warning on the floor to start at `from` and run along `dir` (C19-1: a soldier elite's second blade
## follows the paladin through its wind-up, then keeps where he stood); its length, width and time stay.
static func point_line(z: Zone, from: Vector2, dir: Vector2) -> void:
	if z == null or z.shape != Shape.LINE or dir.length_squared() < 0.0001:
		return
	z.pos = from
	z.dir = dir.normalized()
	if z.node != null:
		var mid := from + z.dir * z.radius * 0.5
		z.node.rotation = Vector3(0, atan2(z.dir.x, z.dir.y), 0)
		z.node.position = Vector3(mid.x, z.node.position.y, mid.y)


## Turns a line or a half circle warning to start at `from` and face `dir` (Morvath's blows following the paladin
## through their wind-up); its size and time stay.
static func point_zone(z: Zone, from: Vector2, dir: Vector2) -> void:
	if z == null or dir.length_squared() < 0.0001:
		return
	if z.shape == Shape.LINE:
		point_line(z, from, dir)
		return
	if z.shape != Shape.ARC:
		return
	z.pos = from
	z.dir = dir.normalized()
	if z.node != null:
		z.node.rotation = Vector3(0, atan2(-z.dir.x, -z.dir.y), 0)
		z.node.position = Vector3(from.x, z.node.position.y, from.y)


static func end_zone(z: Zone) -> void:
	if z != null:
		z.life = -1.0
		z.power = 0.0
		z.cancelled = true


func add_zone(kind: Kind, at: Vector2, radius: float, time: float, power: float, tags: Array[StringName] = []) -> Zone:
	var z := _add(kind, Shape.CIRCLE, at, Vector2.DOWN, radius, 0.0, time, power)
	z.tags = tags
	return z


## Morvath's warning (ART-001): drawn with his signature from now on (a ritual circle keeps its own look).
func sign_boss(z: Zone) -> void:
	if z == null or z.node == null or z.kind != Kind.WARNING or z.rune != Rune.NONE or z.eruption:
		return
	GroundLook.signed_warning(z.node, z.shape, z.pos, z.dir, z.radius, z.width, z.node.position.y)
	GroundLook.put(z.mat, &"progress", 1.0 - z.life / maxf(z.total, 0.001))


## A storm lane's place in its order of leaving (GroundLook.order): marks at its root (1 to 6; < 0 keeps them) and
## rank 0 for the next to leave.
func storm_rank(z: Zone, marks: int, rank: int) -> void:
	if z != null and z.node != null and z.rune == Rune.NONE:
		GroundLook.order(z.node, marks, rank)


## A storm lane's wedge round its root (GroundLook.storm_wedge, from GroundLook.storm_wedges): the lanes never add up.
func storm_wedge(z: Zone, wedge: Vector2) -> void:
	if z != null and z.node != null and z.rune == Rune.NONE:
		GroundLook.storm_wedge(z.node, wedge)


func clear_warnings() -> void:
	for z in zones:
		if z.kind == Kind.WARNING:
			end_zone(z)


func clear() -> void:
	for z in zones:
		_release(z)
	zones.clear()
	for a in _after:
		_end_after(a)
	_after.clear()


static func inside(z: Zone, p: Vector2, margin: float = 0.0) -> bool:
	var d := p - z.pos
	match z.shape:
		Shape.LINE:
			var along := d.dot(z.dir)
			return along >= -margin and along <= z.radius + margin and absf(d.cross(z.dir)) <= z.width * 0.5 + margin
		Shape.ARC:
			return d.length() <= z.radius + margin and (d.length() < 0.6 or absf(z.dir.angle_to(d)) <= deg_to_rad(z.width) * 0.5)
	return d.length() <= z.radius + margin


func step(dt: float) -> void:
	_step_after(dt)
	var i := zones.size() - 1
	while i >= 0:
		# a landing blow can end the run and clear every zone
		if i >= zones.size():
			i = zones.size() - 1
			continue
		var z := zones[i]
		z.life -= dt
		if z.follow and player != null:
			z.pos = player.pos
			if z.node != null:
				z.node.position = Vector3(z.pos.x, z.node.position.y, z.pos.y)
		if z.kind == Kind.WARNING:
			# his eruptions are marked as such after they are made: drawn as his ritual circles from their first step
			if z.eruption and z.rune == Rune.NONE:
				_as_rune(z, Rune.ERUPTION)
			if z.life <= 0.0:
				if z.source != &"":
					_warned[z.source] = z.total
				# the circle and its column live on a moment after the blow (only drawn: the zone itself is gone)
				if z.rune != Rune.NONE and not z.cancelled:
					_dissolve(z.node, z.pos, z.radius, z.rune)
					z.node = null
				if z.power > 0.0 or z.floor_own:  # (a floor's own warning lands even dealing nothing: RP-08 only pushes)
					_land(z)
				if zones.has(z):
					_release(z)
					zones.erase(z)
			else:
				GroundLook.put(z.mat, &"progress", 1.0 - z.life / z.total)
				if z.lock_t >= 0.0:
					z.lock_t += dt
					if z.lock_t <= GroundLook.LOCK_RISE + GroundLook.LOCK_FALL + dt:
						GroundLook.lock_pulse(z.mat, z.aim, z.lock_t, z.lock_left)
					if not z.clicked and not z.silent and z.lock_t >= GroundLook.LOCK_CLICK_AT:
						z.clicked = true
						Audio.play(&"lock_click")
		else:
			z.tick -= dt
			if z.tick <= 0.0:
				z.tick = TICK
				horde.in_circle(z.pos, z.radius, _found)
				for e in _found.duplicate():
					on_zone_hit.call(e, z)
			GroundLook.put(z.mat, &"fade", clampf(z.life / 0.4, 0.0, 1.0) * clampf((z.total - z.life) / 0.2, 0.0, 1.0))
			if z.life <= 0.0 and zones.has(z):
				_release(z)
				zones.erase(z)
				if z.burst > 0.0 and on_zone_burst.is_valid():
					on_zone_burst.call(z)
		i -= 1


## A warning fills: the blow lands. A burst shows where, and the paladin is hit if still inside.
func _land(z: Zone) -> void:
	var center := z.pos + (z.dir * z.radius * 0.5 if z.shape == Shape.LINE else Vector2.ZERO)
	if z.shape == Shape.CIRCLE and fx != null and not z.floor_own:
		var color := z.land_color if z.land_color.a > 0.0 else LAND_COLOR
		# a ritual circle has its own column (_dissolve); the others a ring and a burst of shadow
		if z.rune == Rune.NONE:
			# an enemy's blow lands in smoke (vfx_pass_spec.md V-12), Morvath's eruptions keep their own ring
			if z.eruption:
				fx.ring(z.pos, z.radius * 1.1, color, 0.3)
			elif z.land_quick:
				fx.smoke_ring(z.pos, z.radius * 1.1, color, LAND_QUICK, true)
			else:
				fx.smoke_ring(z.pos, z.radius * 1.1, color, 0.5)
		fx.burst(&"soul" if z.eruption else &"shadow", Vector3(z.pos.x, 0.3, z.pos.y))
		if z.ember:
			fx.burst(&"fire", Vector3(z.pos.x, 0.3, z.pos.y))
			fx.chips(Vector3(z.pos.x, 0.6, z.pos.y), Vector3.UP, EMBER_BONE, EMBER_CHIPS, 5.0, 0.09, 0.45, 1.2)
		if z.eruption and z.rune == Rune.NONE:
			fx.beam(z.pos, color, z.radius * ERUPTION_WIDTH, ERUPTION_HEIGHT, ERUPTION_TIME)
	if z.tags.has(PLATE_TAG) and fx != null:
		fx.burst(&"dust", Vector3(center.x, 0.2, center.y), Vector3.UP)
		Audio.play(&"enemy_charge")
	if player and player.alive() and z.power > 0.0 and inside(z, player.pos, Player.RADIUS * 0.6):
		last_source = z.source
		last_by = z.by
		last_warn = z.total
		last_offscreen = z.offscreen
		hit_player.emit(z.power, center)
	if z.hazard > 0.0 or z.floor_own:
		hazard_landed.emit(z)
	zone_landed.emit(z)


## A plate's spikes hurt the paladin who stepped on them (Horde): the same hit as a landing zone, from the Armadilheiro.
func plate_strike(power: float, center: Vector2, by: StringName, warn: float) -> void:
	last_source = &""
	last_by = by
	last_warn = warn
	last_offscreen = horde.screen_flag(horde.acting_pos) if horde else -1
	hit_player.emit(power, center)


func _add(kind: Kind, shape: Shape, at: Vector2, dir: Vector2, radius: float, width: float, time: float, power: float) -> Zone:
	var z := Zone.new()
	z.kind = kind
	z.shape = shape
	z.pos = at
	z.dir = dir.normalized() if dir.length_squared() > 0.0001 else Vector2.DOWN
	z.radius = radius
	z.width = width
	z.life = time
	z.total = time
	z.power = power
	z.color = COLORS[kind]
	z.by = horde.acting if horde else &""
	z.offscreen = horde.screen_flag(horde.acting_pos) if horde else -1
	z.node = _pool.pop_back() if not _pool.is_empty() else _new_node()
	z.mat = z.node.material_override
	z.node.visible = true
	# the Psalms' areas (E4) are drawn as the circle of light (a fine rim and a veil): a full area that size would cover him
	var circle := kind == Kind.BIND or kind == Kind.SHELTER or kind == Kind.STONE
	var style := GroundLook.Style.WARNING if kind == Kind.WARNING else GroundLook.Style.CIRCLE if circle else GroundLook.Style.AREA
	GroundLook.dress(z.node, style, shape, z.color, WARNING_STRENGTH if kind == Kind.WARNING else BIND_STRENGTH if circle else AREA_STRENGTH,
		RIM_METERS, at, z.dir, radius, width, 0.06 + zones.size() * 0.0005)
	z.mat.set_shader_parameter(&"circle_veil", BIND_VEIL)
	z.mat.set_shader_parameter(&"circle_marks", BIND_MARKS)
	zones.append(z)
	return z


func _new_node() -> MeshInstance3D:
	var mi := GroundLook.new_node()
	add_child(mi)
	return mi


func _release(z: Zone) -> void:
	if z.node == null:
		return
	z.node.visible = false
	(_rune_pool if z.rune != Rune.NONE else _pool).append(z.node)
	z.node = null


# ---------- Morvath's ritual circles (only drawn) ----------

## The warning drawn as a ritual circle from now on (its ground quad goes back to the pool).
func _as_rune(z: Zone, kind: Rune) -> void:
	if z.node != null:
		z.node.visible = false
		_pool.append(z.node)
	z.rune = kind
	z.node = _rune_node(z.pos, z.radius, kind)
	z.mat = z.node.material_override
	z.mat.set_shader_parameter(&"progress", 1.0 - z.life / maxf(z.total, 0.001))


## A ritual circle laid over the area: the quad is radius * 2 wide, the shader draws nothing past its edge.
func _rune_node(at: Vector2, radius: float, kind: Rune) -> MeshInstance3D:
	var node: MeshInstance3D = _rune_pool.pop_back() if not _rune_pool.is_empty() else null
	if node == null:
		node = MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(1, 1)
		node.mesh = plane
		var mat := ShaderMaterial.new()
		mat.shader = RUNE_SHADER
		node.material_override = mat
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(node)
	var m := node.material_override as ShaderMaterial
	m.set_shader_parameter(&"kind", kind)
	m.set_shader_parameter(&"progress", 0.0)
	m.set_shader_parameter(&"after", 0.0)
	m.set_shader_parameter(&"size_m", radius)
	m.set_shader_parameter(&"rim_m", RUNE_RIM)
	m.set_shader_parameter(&"strength", RUNE_STRENGTH)
	m.set_shader_parameter(&"seed", _seed(at))
	m.set_shader_parameter(&"danger", GroundLook.WARNING_COLOR)
	m.set_shader_parameter(&"danger_fill", GroundLook.SIGN_FILL)
	m.set_shader_parameter(&"danger_strength", RUNE_DANGER)
	node.scale = Vector3(radius * 2.0, 1.0, radius * 2.0)
	node.rotation = Vector3.ZERO
	node.position = Vector3(at.x, 0.06 + (zones.size() + _after.size()) * 0.0005, at.y)
	node.visible = true
	return node


## The circle has landed: a column rises out of it and the circle dissolves (RUNE_AFTER).
func _dissolve(node: MeshInstance3D, at: Vector2, radius: float, kind: Rune) -> void:
	(node.material_override as ShaderMaterial).set_shader_parameter(&"progress", 1.0)
	var erupt := kind == Rune.ERUPTION
	var col := _column(at, radius * (ERUPTION_WIDTH if erupt else SUMMON_WIDTH), ERUPTION_HEIGHT if erupt else SUMMON_HEIGHT)
	_after.append([node, col, 0.0, ERUPTION_TIME if erupt else SUMMON_TIME])


func _column(at: Vector2, radius: float, height: float) -> MeshInstance3D:
	var col: MeshInstance3D = _column_pool.pop_back() if not _column_pool.is_empty() else null
	if col == null:
		if _column_mesh == null:
			_column_mesh = CylinderMesh.new()
			_column_mesh.top_radius = COLUMN_TOP
			_column_mesh.bottom_radius = 1.0
			_column_mesh.height = 1.0
			_column_mesh.radial_segments = COLUMN_SIDES
			_column_mesh.rings = 3
			_column_mesh.cap_top = false
			_column_mesh.cap_bottom = false
		col = MeshInstance3D.new()
		col.mesh = _column_mesh
		var mat := ShaderMaterial.new()
		mat.shader = COLUMN_SHADER
		col.material_override = mat
		col.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(col)
	var m := col.material_override as ShaderMaterial
	m.set_shader_parameter(&"life", 0.0)
	m.set_shader_parameter(&"seed", _seed(at) * 10.0)
	col.scale = Vector3(radius, height, radius)
	col.position = Vector3(at.x, height * 0.5, at.y)
	col.visible = true
	return col


func _step_after(dt: float) -> void:
	var i := _after.size() - 1
	while i >= 0:
		var a: Array = _after[i]
		var t: float = (a[2] as float) + dt
		a[2] = t
		((a[0] as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter(&"after", clampf(t / RUNE_AFTER, 0.0, 1.0))
		((a[1] as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter(&"life", clampf(t / (a[3] as float), 0.0, 1.0))
		if t >= maxf(RUNE_AFTER, a[3] as float):
			_end_after(a)
			_after.remove_at(i)
		i -= 1


func _end_after(a: Array) -> void:
	(a[0] as MeshInstance3D).visible = false
	_rune_pool.append(a[0])
	(a[1] as MeshInstance3D).visible = false
	_column_pool.append(a[1])


## The same turn of the glyphs for the same spot (no random number: the drawing never touches the run's dice).
static func _seed(at: Vector2) -> float:
	return fposmod(at.x * 0.173 + at.y * 0.311, 1.0)
