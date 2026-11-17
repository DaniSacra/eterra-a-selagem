class_name HazardDef
extends Resource
## The floor of an arena that strikes on its own (E5, the Câmara das Runas Instáveis; docs/art/e5_spec.md 3.4): a grid
## of square tiles, patterns of them that warm up (warn), strike everyone standing on them (fire) and rest. Numbers
## only; ArenaHazard runs it, RuneFloor puts it on the floor. Written by _stage in tools/make_data.gd
## (RoomLayout.hazard, ArenaVariant.hazard).

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
