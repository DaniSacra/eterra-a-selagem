class_name HazardDef
extends Resource
## The floor of an arena that strikes on its own. Two kinds (RP-06, docs/design/rooms_progression.md):
## GRID (E5, the Câmara das Runas Instáveis; docs/art/e5_spec.md 3.4): a grid of square tiles, patterns of them that
## warm up (warn), strike everyone standing on them (fire) and rest; ArenaHazard runs it, RuneFloor puts it on the floor.
## PLATES (RP-06, H-2, the "laje de pisar"): fixed slabs, marked at rest, that anyone stepping on arms (the paladin or
## an enemy, as the steam trap of the Hades II): warn seconds lighting from the edge to the middle, a strike of fire
## seconds on whoever stands on it, rearm seconds before it may arm again; PlateHazard runs it, PlateFloor puts it on
## the floor. LINE (RP-11, H-3, "a corrente que varre"): bands across the floor that strike in turn on their own clock,
## one at a time (the chain of the Ponte dos Condenados swinging across a bridge): every `cycle` seconds the next band
## warms up warn seconds and strikes fire seconds, pushing whoever it struck along band_push (RP-08, the rift that
## breathes: the same with no damage, it only pushes away from the brink and cuts a wind-up); BandHazard runs it,
## BandFloor puts it on the floor. Numbers only, written by _stage in tools/make_data.gd (RoomLayout.hazard,
## ArenaVariant.hazard).

## DROPS (RP-20): stones falling from a torn vault; DropHazard runs it, DropFloor. URNS (RP-12): oil urns the paladin's
## blow lights, the blast and the oil running down a channel; UrnHazard runs it, UrnFloor. A GRID may carry crystals
## (RP-14) the paladin charges, that discharge along a column of tiles (ArenaHazard.discharge, RuneFloor).
enum Kind { GRID, PLATES, LINE, DROPS, URNS }
@export var kind := Kind.GRID

## The grid: the north-west corner of tile (0, 0), the side of a tile (m), how many columns (west to east) and rows
## (north to south).
@export var origin := Vector2(-15, -12)
@export var tile := 3.0
@export var cols := 10
@export var rows := 8
## Seconds a pattern warms up before it strikes (as the enemies' warnings, 0.8 to 1.2), seconds it strikes (the blow
## is its first frame), seconds of rest before the next pattern, and seconds of calm when the fight begins.
@export var warn := 1.2
@export var fire := 0.25
@export var rest := 2.4
@export var start_delay := 3.0
## The most of the tiles that may be lit at once, and the most for the dense patterns (checker, comb), only with at
## most dense_standing enemies standing.
@export var max_share := 0.35
@export var dense_share := 0.5
@export var dense_standing := 3
## The patterns it draws from (ArenaHazard.PATTERNS: sweep, comb, cut, checker, frame, islands).
@export var patterns: Array[StringName] = []
## At most this many 2 x 2 blocks in the islands.
@export var islands := 4
## Floor that never lights (the quiet stone of variant B).
@export var quiet: Array[Rect2] = []
## Life lost by the paladin and by an enemy standing on a tile that strikes (it hurts everyone: E5-D3).
@export var hero_damage := 4.0
@export var enemy_damage := 35.0

## PLATES: the slabs (each a rectangle of the floor, 3 x 3 m), the seconds a struck slab rests before it may arm again,
## and the share of the descent (EncounterGen.progress) from which they arm at all: before it they lie on the floor
## drawn at rest and never strike (the frame teaches without hurting).
@export var plates: Array[Rect2] = []
@export var rearm := 5.0
@export var from_progress := 0.0
## PLATES, RP-13 (the edge that crumbles): per slab, life lost by the paladin instead of hero_damage (0 or missing:
## hero_damage) and a push given on the strike to everyone on it, in meters along the floor (zero: none), toward the
## firm floor; nobody falls (D-28), the push is swept as any body pushed.
@export var plate_hero_damage: PackedFloat32Array = PackedFloat32Array()
@export var plate_push: PackedVector2Array = PackedVector2Array()
## PLATES, RP-10 (H-1, the roots that strike in the Jardim): bands along a root, each a segment (a.x, a.y, b.x, b.y)
## strip_width across (the root's metre and one more each side), slabs as any other (numbered after the rectangles, in
## this order). dwell: the seconds someone must stay on a slab before it arms (0, the slabs: at once; the roots wake to
## who lingers). push_out: on the strike everyone on it is thrown this far away from its middle line (the root shrugs
## them off; swept, nobody falls), on top of plate_push. plate_source: what names it (Ground's source: "Derrotado por"
## killer_<name>, the run's numbers, the sounds CombatSounds.EVENTS "<name>_arm" and "<name>_fire").
@export var strips: PackedVector4Array = PackedVector4Array()
@export var strip_width := 3.0
@export var dwell := 0.0
## PLATES: the seconds an enemy must stay on a slab before it arms (negative: dwell). The roots wake sooner to an enemy,
## who only walks over them (RP-10, second pass).
@export var enemy_dwell := -1.0
@export var push_out := 0.0
@export var plate_source: StringName = &"plates"
## PLATES, RP-16 (the arrow slit tied to a slab): per slab, the band its slit fires along instead of striking the slab
## itself, a segment (a.x, a.y, b.x, b.y) from the slit's mouth to where the bolts stop, aim_width across (Vector4.ZERO or
## missing: the slab strikes as always). Stepping on the slab arms the slit; the band warns and strikes as a slab would.
@export var aims: PackedVector4Array = PackedVector4Array()
@export var aim_width := 1.0

## LINE: the bands (rectangles of the floor, struck one at a time in this order, round and round), the push of each
## (meters along the floor, never off it: nobody falls, D-28), and the seconds from one band's warning to the next's.
@export var bands: Array[Rect2] = []
@export var band_push: PackedVector2Array = PackedVector2Array()
@export var cycle := 6.0
## LINE: what names it (Ground's source: "Derrotado por", the room's hurt_by and the hazard's kind in the run's numbers;
## its sounds are CombatSounds.EVENTS "<name>_arm" and "<name>_fire"): &"chain" the bridge's chain (RP-11), &"breath"
## the rift that breathes (RP-08, no damage, only the push).
@export var band_source: StringName = &"chain"
## LINE: the next band is the one with the most enemies standing in it (ties and none: in turn), instead of strictly
## in turn: the rift breathes where the fight is (RP-08).
@export var band_busy := false
## LINE, SR-P1 (the wall trap, band_source &"trap"): per band, the way its blades fly (a vector, unit or not; zero or
## missing: none), from the block in the wall at the band's far end to where they stop. The block (a `trap_block`
## obstacle of the layout) stands behind the band's start and the chevrons cut in it point this way. A trap is a LINE
## whose bands are the lines of the blades: band_busy picks the line with most enemies standing in it (the paladin
## draws the pack into it), from_progress keeps it asleep (the block stands, the blades do not fly) early in the descent.
@export var band_dir: PackedVector2Array = PackedVector2Array()


## SR-P2, SR-P3 and the traps: the hazard bites harder deep in the descent. From `late_from` of the descent
## (EncounterGen.progress) a LINE's cycle is cycle_late and a PLATES' rest is rearm_late (0: unchanged). Warn and fire
## never change (the warning is the same fair one at every depth); only how soon it comes again.
@export var late_from := 0.7
@export var cycle_late := 0.0
@export var rearm_late := 0.0
## LINE, SR-P3 (the pit grate, band_source &"spikes"): bands are the grates, 2.4 m squares; the spikes rise as it warns
## and stay up for `fire`. The same as the trap in what it asks of the data (band_busy, from_progress).
## PLATES, SR-P2 (the slab that gives, plate_source &"sag"): dwell/enemy_dwell as the roots; whoever stays on it when
## it falls is hurt, then the floor is back after `rearm`. Nothing else is needed: a hazard named by its source.


## The cycle of a LINE at this share of the descent.
func cycle_at(progress: float) -> float:
	return cycle_late if cycle_late > 0.0 and progress >= late_from else cycle


## The rest of a PLATES slab at this share of the descent.
func rearm_at(progress: float) -> float:
	return rearm_late if rearm_late > 0.0 and progress >= late_from else rearm


## A second hazard of the same room, started beside this one (Santuário B: the slabs and the stones of the vault; the
## Fendas B: the breath and the stones; the Cripta A: the slabs and the oil urns). Rooms counts both against the room's
## two warnings at once (combat_cadence.md 9.2 R9).
@export var also: HazardDef

## PLATES, AT-H2 (the niche's skeleton): whoever a strip struck is pulled this far toward the strip's start (the
## niche), never held (Q-AT3 a): the paladin over PlateFloor.PULL_TIME, the pull cut short at the edge of any other
## warning on the floor or of stone (combat_cadence.md 9.2 R10), and cut off by his dodge. 0: no pull.
@export var pull := 0.0
## PLATES, AT-H2 and AT-H3: what a blow of the paladin only sparks on (the skeleton in its niche, the hostile plant):
## never hurt, never a target of the aim assist (no enemy), no number, no combo, no hit stop.
@export var sparks: PackedVector2Array = PackedVector2Array()
@export var spark_radius := 0.6

## GRID, RP-14 (H-5, the crystal that discharges): where each crystal stands (off the floor, by the north wall), the
## column of tiles (0 west) it discharges along, and how far round it a blow of the paladin reaches it (m). Each blow of
## his that touches a crystal charges it; at crystal_hits it discharges at once: its column's tiles (only those that
## may light: never the quiet stone, the way in nor a door) become the runes' next pattern, warned warn seconds with the
## chevrons running away from the crystal, striking as the runes do (named crystal_source). A pattern of the runes
## warming up then goes dark unstruck (the crystal drains it): never more than one pattern on the floor. Asleep before
## crystal_from of the descent (the crystal takes no charge).
@export var crystals: PackedVector2Array = PackedVector2Array()
@export var crystal_cols: PackedInt32Array = PackedInt32Array()
@export var crystal_hits := 3
@export var crystal_radius := 0.6
@export var crystal_from := 0.0
@export var crystal_source: StringName = &"crystal"

## DROPS, RP-20 (stones from the torn vault): the parts of the floor stones may fall on, the side of a stone's square
## (m), at most drop_count stones at once, one every drop_every seconds after start_delay; drop_aim the share aimed at
## the paladin when he stands in a zone (the others anywhere in one). Each warns warn seconds (the square whole from the
## first frame, the shadow filling) and strikes fire seconds; never over another stone nor over another hazard's warning
## (Rooms gives the room's busy squares), never within 6 m of the way in (the data keeps the zones clear). The rubble
## left is drawn only (it never stops a body: combat_cadence.md 9.3). Asleep before from_progress.
@export var drop_zones: Array[Rect2] = []
@export var drop_size := 2.0
@export var drop_count := 2
@export var drop_every := 4.0
@export var drop_aim := 0.5

## URNS, RP-12 (the oil urn, the Hades II's barrel): where each urn stands (the data puts an obstacle there), the
## blast's radius, and per urn the oil's channel (a.x, a.y, b.x, b.y; Vector4.ZERO: none). A blow of the paladin lights
## an urn: its ring warns warn seconds (combat_cadence.md 9.4: 1.3 s with 10 to him) and blasts (hero_damage,
## enemy_damage); the oil runs down the channel at flow_speed m/s, in stretches of flow_step m, each warned flow_lead
## seconds ahead of the flame (the band whole from its first frame), striking flow_hero / flow_enemy as the flame
## reaches it and burning burn seconds after (whoever walks in is struck once). Once per urn per room. Asleep before
## from_progress (a blow only rings on the bronze).
@export var urns: PackedVector2Array = PackedVector2Array()
@export var urn_radius := 2.5
@export var urn_flows: PackedVector4Array = PackedVector4Array()
@export var flow_width := 1.5
@export var flow_speed := 3.0
@export var flow_step := 2.0
@export var flow_lead := 1.0
@export var flow_hero := 5.0
@export var flow_enemy := 40.0
@export var burn := 2.0
@export var urn_source: StringName = &"urn"


## URNS: the channel of urn i (Vector4.ZERO: none).
func flow_of(i: int) -> Vector4:
	return urn_flows[i] if i < urn_flows.size() else Vector4.ZERO


## LINE: the way the blades of band i fly (zero: none).
func band_dir_of(i: int) -> Vector2:
	return band_dir[i] if i < band_dir.size() else Vector2.ZERO


## LINE: the push of band i (zero: none).
func band_push_of(i: int) -> Vector2:
	return band_push[i] if i < band_push.size() else Vector2.ZERO


## PLATES: the seconds an enemy must stay on a slab before it arms.
func dwell_of_enemy() -> float:
	return dwell if enemy_dwell < 0.0 else enemy_dwell


## PLATES: whether slab i fires a slit (RP-16), and the band it fires along.
func aims_away(i: int) -> bool:
	return i < aims.size() and aims[i] != Vector4.ZERO


## PLATES: the paladin's damage of slab i.
func hero_damage_of(i: int) -> float:
	return plate_hero_damage[i] if i < plate_hero_damage.size() and plate_hero_damage[i] > 0.0 else hero_damage


## PLATES: the push of slab i (zero: none).
func push_of(i: int) -> Vector2:
	return plate_push[i] if i < plate_push.size() else Vector2.ZERO
