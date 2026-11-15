class_name EnemyDef
extends Resource
## One kind of enemy. A new enemy with an existing behaviour and an already baked model is a new .tres in
## data/enemies, no code. Distances in meters, speeds in meters per second.

## CHASE: walks up and swings. ARCHER: keeps away and shoots a bolt. RUNNER: marks a line and lunges along it.
## CASTER: conjures a circle under the paladin (speed 0: it never moves). KNIGHT: charges along a long line, and
## slams the ground (close_*) when the paladin is near. PRIEST: raises skeletons and conjures circles.
## PULSE: runs in and bursts all around itself. CONE: stops and blasts a wide cone ahead.
enum Behavior { CHASE, ARCHER, RUNNER, CASTER, KNIGHT, PRIEST, BOSS, PULSE, CONE }

@export var id: StringName
@export var name_key: StringName
@export_group("Look")
## Baked model in assets/baked (tools/bake.gd).
@export var model: StringName = &"skeleton"
## Its own palette over the baked model's (tools/make_palettes.gd): the elites wear the gilded one. Empty: the model's.
@export var palette: Texture2D
@export var size := 1.0
@export var tint := Color.WHITE
## Glow around the edges (elites and the boss stand out from the crowd).
@export var rim_color := Color(0.4, 0.55, 1.0)
@export var rim := 0.0
## Colour of its magic (bolts, the burst where its blows land, the fan of its volley). Alpha 0: the default look.
@export var magic_color := Color(0, 0, 0, 0)
@export_group("Body")
@export var behavior: Behavior = Behavior.CHASE
@export var hp := 20.0
@export var speed := 2.5
## Damage when it touches the paladin.
@export var damage := 6.0
@export var radius := 0.45
@export var xp := 1
## The risen dead take more damage from the Luz gifts.
@export var undead := true
## Heavy enemies cannot be launched or pushed far, and freeze for less time.
@export var heavy := false
@export var elite := false
## A yellow bar over the life bar: blows wear it down first and do not push or stun while it holds.
## When it breaks the enemy staggers for armor_stagger seconds. 0 = no armor.
@export var armor := 0.0
@export var armor_stagger := 1.5

@export_group("Attack")
## Damage of its special attack (bolt, lunge, circle, charge).
@export var attack_damage := 10.0
@export var attack_range := 0.0
@export var attack_cooldown := 2.5
## Warning time before the attack lands. Every attack is announced.
@export var attack_windup := 0.6
## RUNNER and KNIGHT: speed of the lunge or charge (m/s) and how long it lasts.
@export var lunge_speed := 14.0
@export var lunge_time := 0.45
## PULSE: radius of the burst. CONE: opening in degrees.
@export var attack_width := 0.0
## KNIGHT: a slam on whoever stands close (0 damage = none).
@export var close_damage := 0.0
@export var close_range := 3.0
@export var close_windup := 0.65

@export_group("Encounters")
## Weight of this enemy in the room generator (Hades II "DifficultyRating"): a room of difficulty 100 holds
## enemies whose ratings add up to about 100.
@export var rating := 0.0
## The armored version that can stand in for it in a room (empty: none).
@export var elite_version: StringName
