class_name EnemyDef
extends Resource
## One kind of enemy. A new enemy with an existing behaviour is a new .tres in data/enemies, no code.

enum Behavior { CHASE, ARCHER, WOLF, CASTER, KNIGHT, PRIEST, BOSS }

@export var id: StringName
@export var name_key: StringName
@export var sprite: StringName
@export var behavior: Behavior = Behavior.CHASE
@export var hp := 20.0
@export var speed := 30.0
## Damage when it touches the paladin.
@export var damage := 8.0
@export var radius := 5.0
@export var xp := 1
## The risen dead take double damage from the Luz gift.
@export var undead := true
## Heavy enemies cannot be launched or pushed far, and freeze for less time.
@export var heavy := false
@export var elite := false

@export_group("Attack")
## Damage of its special attack (arrow, lunge, circle, charge).
@export var attack_damage := 10.0
@export var attack_range := 0.0
@export var attack_cooldown := 2.5
## Warning time before the attack lands. Every attack is announced.
@export var attack_windup := 0.6
