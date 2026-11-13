class_name SkillDef
extends Resource
## What a gift does on its own, every few seconds, without a button (the paladin keeps fighting meanwhile).
## Every number has one value per level of the gift.

enum Kind {
	## Strikes fall on enemies near the paladin (fire, light pillars).
	STRIKES,
	## A ring bursts out around the paladin.
	NOVA,
	## Orbs circle the paladin and burn what they touch. Always on: cooldown is unused.
	ORBIT,
	## Blades fly out in a fan where the paladin aims.
	FAN,
	## One great blow falls where the crowd is thickest.
	METEOR,
	## Holy ground under the paladin for a while.
	CONSECRATE,
}

@export var kind: Kind = Kind.STRIKES
@export var cooldown: PackedFloat32Array = PackedFloat32Array([4.0])
@export var damage: PackedFloat32Array = PackedFloat32Array([20.0])
@export var count: PackedFloat32Array = PackedFloat32Array([1.0])
## Meters (area of a strike, ring, orbit or ground).
@export var radius: PackedFloat32Array = PackedFloat32Array([2.0])
## Seconds the hit freezes, stuns, or the ground lasts; damage per second of a burn. Depends on the kind of status.
@export var status: StringName = &""
@export var status_power: PackedFloat32Array = PackedFloat32Array([0.0])


static func at(values: PackedFloat32Array, level: int) -> float:
	if values.is_empty() or level <= 0:
		return 0.0
	return values[mini(level, values.size()) - 1]


func get_cooldown(level: int) -> float:
	return at(cooldown, level)


func get_damage(level: int) -> float:
	return at(damage, level)


func get_count(level: int) -> int:
	return roundi(at(count, level))


func get_radius(level: int) -> float:
	return at(radius, level)


func get_status_power(level: int) -> float:
	return at(status_power, level)
