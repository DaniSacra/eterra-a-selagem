class_name EnemyDef
extends Resource
## One kind of enemy. A new enemy with an existing behaviour and an already baked model is a new .tres in
## data/enemies, no code. Distances in meters, speeds in meters per second.

enum Behavior { CHASE, ARCHER, RUNNER, CASTER, KNIGHT, PRIEST, BOSS }

@export var id: StringName
@export var name_key: StringName
@export_group("Look")
## Baked model in assets/baked (tools/bake.gd).
@export var model: StringName = &"minion"
@export var size := 1.0
@export var tint := Color.WHITE
## Glow around the edges (elites and the boss stand out from the crowd).
@export var rim_color := Color(0.4, 0.55, 1.0)
@export var rim := 0.0
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

@export_group("Attack")
## Damage of its special attack (bolt, lunge, circle, charge).
@export var attack_damage := 10.0
@export var attack_range := 0.0
@export var attack_cooldown := 2.5
## Warning time before the attack lands. Every attack is announced.
@export var attack_windup := 0.6
