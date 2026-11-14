class_name ComboNode
extends Resource
## One move of the combo tree. Combos are data: a new combo is a new node in data/combos, never new code.

enum In { LIGHT, HEAVY, CHARGE }
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
## Share of walking speed kept while this move plays. Below 0: the default of data/feel.tres for its kind
## (light, heavy, finisher).
@export_range(-1.0, 1.0, 0.01) var move_scale := -1.0

@export_group("Timing")
@export var windup := 0.07
@export var recovery := 0.17
## Seconds after the move ends in which the next input still continues the combo.
@export var chain_window := 0.35
@export var hit_stop_ms := 40.0
@export var shake := 1.0

@export_group("Effect")
@export var effect: Effect = Effect.NONE
## LAUNCH: unused. GROUND_MARK: damage per second. WAVE: damage of the wave. STUN: unused.
@export var effect_power := 0.0
## LAUNCH: air time. GROUND_MARK: how long the mark lasts. WAVE: unused. STUN: stun time.
@export var effect_time := 0.0
## GROUND_MARK: radius. WAVE: distance travelled.
@export var effect_radius := 0.0

@export_group("Tree")
@export var next: Array[ComboNode] = []


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func duration() -> float:
	return windup + recovery


## The share of walking speed this move keeps, with Feel's default for its kind when it sets none.
func move_scale_with(feel: Feel) -> float:
	return move_scale if move_scale >= 0.0 else feel.move_scale_for(tags)
