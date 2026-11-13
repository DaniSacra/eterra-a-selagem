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
@export var anim: StringName
## What gifts (dons) look at to modify this move: light, heavy, spin, wave, finisher...
@export var tags: Array[StringName] = []

@export_group("Hit")
@export var damage := 10.0
@export var shape: Shape = Shape.ARC
## How far the hit reaches from the paladin, in pixels.
@export var reach := 26.0
## Arc: opening in degrees. Line: thickness in pixels. Circle: unused.
@export var width := 100.0
@export var knockback := 40.0
## Pixels the paladin steps forward during the windup.
@export var lunge := 0.0

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
