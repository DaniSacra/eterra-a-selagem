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

enum Kind { GRID, PLATES, LINE }
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


## LINE: the push of band i (zero: none).
func band_push_of(i: int) -> Vector2:
	return band_push[i] if i < band_push.size() else Vector2.ZERO


## PLATES: the seconds an enemy must stay on a slab before it arms.
func dwell_of_enemy() -> float:
	return dwell if enemy_dwell < 0.0 else enemy_dwell


## PLATES: the paladin's damage of slab i.
func hero_damage_of(i: int) -> float:
	return plate_hero_damage[i] if i < plate_hero_damage.size() and plate_hero_damage[i] > 0.0 else hero_damage


## PLATES: the push of slab i (zero: none).
func push_of(i: int) -> Vector2:
	return plate_push[i] if i < plate_push.size() else Vector2.ZERO
