class_name ComboNode
extends Resource
## One move of the combo tree. Combos are data: a new combo is a new node in data/combos, never new code.

## CHARGE: heavy held (the Omega special). CHARGE_LIGHT: light held (the Omega attack).
enum In { LIGHT, HEAVY, CHARGE, CHARGE_LIGHT }
enum Shape { ARC, CIRCLE, LINE }
enum Effect { NONE, LAUNCH, GROUND_MARK, WAVE, STUN }

@export var id: StringName
## The input that leads here from the previous node: E (light), D (heavy) or a released charge.
@export var input: In = In.LIGHT
## Text key of the move's name, shown when it lands and in the Golpes screen. Empty for a plain link of a chain.
@export var title: StringName
## Animation of the paladin's model, how fast it plays and where it starts (seconds into the clip).
@export var anim: StringName
@export var anim_speed := 1.0
@export var anim_from := 0.0
## Which way the blade crosses in the animation, so the cut of light follows the arm: 0 alternates, 1 from the
## paladin's right to his left, 2 from his left to his right (tools/bake_hero.gd measures it).
@export_range(0, 2) var sweep := 0
## What gifts (dons) look at to modify this move: light, heavy, spin, wave, finisher...
@export var tags: Array[StringName] = []

@export_group("Hit")
@export var damage := 10.0
@export var shape: Shape = Shape.ARC
## How far the hit reaches from the paladin, in meters.
@export var reach := 3.0
## Arc: opening in degrees. Line: thickness in meters. Circle: unused.
@export var width := 140.0
## Push given to what it hits, in meters per second.
@export var knockback := 8.0
## Meters the paladin steps forward during the windup.
@export var lunge := 0.0
## How much farther a lunge may stretch to reach the enemy ahead: each blow carries the paladin to the next one,
## as in Ember & Blade (and stops short of an enemy already within reach, so he does not run through it).
const LUNGE_MAGNET := 2.5
## Line moves: also strike behind the paladin (the same length backwards).
@export var both_ways := false
## Share of walking speed kept while this move plays. Below 0: the default of data/feel.tres for its kind
## (light, heavy, finisher).
@export_range(-1.0, 1.0, 0.01) var move_scale := -1.0

@export_group("Timing")
@export var windup := 0.07
## Seconds the move holds at the top of its swing, with a star of light on the blade, before it lands
## (the anticipation beat of a finisher). Scaled live by Feel.glint_scale.
@export var glint := 0.0
@export var recovery := 0.17
## Seconds after the move ends in which the next input still continues the combo.
@export var chain_window := 0.35
## The hit stop when it lands, as in Hades II (HitStop, GF-01): the world keeps its full speed for hit_stop_ms after
## the blow (the wait, ScreenPreWait), then runs at hit_slow_scale of its speed for hit_slow_ms (Combat adds
## KILL_HOLD_MS when the blow kills), then comes back. Real milliseconds.
@export var hit_stop_ms := 40.0
@export var hit_slow_ms := 10.0
@export_range(0.0, 1.0, 0.01) var hit_slow_scale := 0.06
## Seconds after this move lands before it may start again (the special's 0.7 s of Hades II; 0 = none).
@export var cooldown := 0.0
## Seconds after this move lands in which the paladin's legs stay planted (the special's 0.71 s of Hades II); only
## the dodge cuts it.
@export var root_time := 0.0
## Played when the move starts (the blade leaving, before it lands: GF-11). Audio.SOUNDS or an audio/ file.
@export var sound: StringName = &"blade"
## Magia this move spends (the held Omega moves). A press without enough Magia plays the plain move instead.
@export var magick_cost := 0.0
## Held moves (CHARGE, CHARGE_LIGHT): seconds the button must be held. The move fires by itself when the charge
## fills; letting go earlier cancels it.
@export var charge_time := 0.45
@export var shake := 1.0

@export_group("Effect")
@export var effect: Effect = Effect.NONE
## LAUNCH: unused. GROUND_MARK: damage per second. WAVE: damage of the wave (a move with damage 0 strikes only
## with its wave, like the special's bolt). STUN: unused.
@export var effect_power := 0.0
## LAUNCH: air time. GROUND_MARK: how long the mark lasts. WAVE: unused. STUN: stun time.
@export var effect_time := 0.0
## GROUND_MARK: radius. WAVE: distance travelled.
@export var effect_radius := 0.0
## WAVE: width of the wave in meters (0 = the default 3.2).
@export var effect_size := 0.0
## WAVE: fly as a bolt of light (a bright streak with a trail) instead of a crescent.
@export var wave_bolt := false

@export_group("Tree")
## The moves that may follow this one (ComboNode each; read them typed with following()). Kept as Resource: a typed
## array of its own class in its own script holds the script in a cycle, which leaked it at every exit.
@export var next: Array[Resource] = []


## The moves that may follow this one, typed.
func following() -> Array[ComboNode]:
	var out: Array[ComboNode] = []
	out.assign(next)
	return out


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func duration(glint_scale: float = 1.0) -> float:
	return windup + glint * glint_scale + recovery


## The share of walking speed this move keeps, with Feel's default for its kind when it sets none.
func move_scale_with(feel: Feel) -> float:
	return move_scale if move_scale >= 0.0 else feel.move_scale_for(tags)


## The slash effect's flip for this move (Fx.slash sweeps from the right to the left unless flipped).
## alternate: the flip to use when the move does not say.
func sweep_flip(alternate: bool) -> bool:
	return alternate if sweep == 0 else sweep == 2


## Meters to step for this blow. gap: how far the enemy ahead stands beyond striking distance (INF: nobody ahead).
func lunge_toward(gap: float) -> float:
	if lunge <= 0.0:
		return 0.0
	if gap == INF:
		return lunge
	return clampf(gap, 0.15, lunge + LUNGE_MAGNET)
