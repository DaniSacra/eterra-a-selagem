class_name JuramentoDef
extends Resource
## One Juramento (E6, D-63; the vows of Hades II's Oath of the Unseen, docs/design/e6_juramentos.md): a difficulty
## chosen before a descent, in ranks, each rank with its number and its Peso (Hades II's Fear). Only numbers: the word
## (stat) says what it changes, read by Juramentos. data/juramentos/*.tres, written by _juramentos in
## tools/make_data.gd.

## How its number reads on screen: MORE "20%" (a fraction more), LEFT "75%" (what is left of the normal, 1 + value),
## COUNT "2" (a plain count).
enum Shown { MORE, LEFT, COUNT }

@export var id: StringName
## Its name and the line saying what it does ({v} is the number of the rank chosen) in data/text_pt.tres.
@export var name_key: StringName
@export var desc_key: StringName
## What it changes (Juramentos.STATS): enemy_hp_pct, enemy_damage_pct, enemy_speed_pct, enemy_count_pct, elite_pct,
## heal_pct, price_pct, boon_denial, boss_rival.
@export var stat: StringName
## The number of each rank (rank 1 is values[0]); rank 0 is off.
@export var values := PackedFloat32Array()
## The Peso each rank adds (rank r weighs the sum of the first r).
@export var weights := PackedInt32Array()
@export var shown := Shown.MORE
## Its place on the screen.
@export var order := 0


func max_rank() -> int:
	return mini(values.size(), weights.size())


## Its number at this rank (0 when off).
func value(rank: int) -> float:
	return values[clampi(rank, 1, max_rank()) - 1] if rank > 0 and max_rank() > 0 else 0.0


## The Peso of this rank (every rank up to it).
func weight(rank: int) -> int:
	var total := 0
	for i in clampi(rank, 0, max_rank()):
		total += weights[i]
	return total


## Its number at this rank as the screen shows it.
func shown_value(rank: int) -> String:
	var v := value(rank)
	match shown:
		Shown.LEFT:
			return "%d%%" % roundi((1.0 + v) * 100.0)
		Shown.COUNT:
			return str(roundi(v))
	return "%d%%" % roundi(absf(v) * 100.0)
