class_name GiftState
extends RefCounted
## The rules of the hero's passive and Gifts in a run (docs/design/warrior_spec.md 3.1 and 4), pure: no nodes, no
## clock of its own. Every number is a stat (BoonState.stat: the Gifts' mods, which a Blessing could also carry), so
## a Gift with numbers that exist needs no code. HeroGifts (scripts/game/hero_gifts.gd) feeds it the fight's events and
## does what it answers. With no Gift equipped every answer is the game of before (no fury, full cost, no wave).
##
## - Passive (P-A): a finisher (HeroDef.passive_tags, never passive_never) that lands gives back
##   HeroDef.magick_on_finisher + finisher_magick of Magia, once a blow.
## - Cadência (redesign 2026-11-24): cadence_pct more speed of every attack blow for each blow of the sequence already
##   landed (chain_n; the opener, a lost sequence and a blow taken start it over).
## - Corte Crescente, Onda Carregada, Fio do Passo: blow_wave (damage), blow_wave_m, blow_wave_w (Combat throws it; the
##   Encantos use them).
## - Ainda de Pé: once a descent, a fall leaves him standing with rise_share of his life (rise_boss_share in Morvath's
##   room, E6: none today).
## - Fatia 2 (Encantos, Refinar): blow_wave_fan more waves in a fan (Lâmina Tríplice); echo_pct of a blow again after
##   echo_delay (Eco da Verdade, Combat); return_reach after a blow with return_time (Retorno do Corte, Combat);
##   blow_speed (Pressa) and poise_pct (Peso, Onda Pesada, Combat).
## - Respiro: room_heal of life a room won. ult_charge_pct (the ultimate reads it), finisher_magick.
## The Dons of the redesign are read where they act: dodge_window_add (ComboRunner), attack_magick_pct (KitFeed), charge_time_pct
## and omega_cost_pct (Player), final_pct and apogee_pct and stun_pct (Combat), dash_pierce and dash_stun (Combat, Player).

## The most of a move's cooldown the Dons and Blessings may take off (Fôlego de Guerra).
const COOLDOWN_CUT_MAX := 0.5

## The Blessings and Gifts of the run (their stat sums every number; held here, a Callable would not keep it alive).
var boons: BoonState
var hero: HeroDef
## Blows of the attack's sequence that have landed so far (Cadência).
var chain_n := 0
## The Brado's buff (2026-11-21): seconds left, the extra speed of every blow and the share of damage taken it takes off.
var rally_left := 0.0
var rally_speed := 0.0
var rally_guard := 0.0
## Falls Ainda de Pé still stands him up from this descent.
var rises := 0
## Morvath's room has begun (Game._start_boss): a fall there rises only with rise_boss_share (E6, docs/design/
## e6_balance.md: with the rise there the Mastery 20 robot never lost, 72 of 72).
var boss_room := false
## The passive is on (always in play; --no-passive turns it off to compare runs with the game of before).
var passive := true


func _init(hero_def: HeroDef, held: BoonState) -> void:
	hero = hero_def
	boons = held
	rises = 1 if value(&"rise_share") > 0.0 else 0


func value(name: StringName, tags: Array[StringName] = []) -> float:
	return boons.stat(name, tags) if boons != null else 0.0


func step(dt: float) -> void:
	rally_left = maxf(0.0, rally_left - dt)


# ---------- the passive ----------

## True when a blow with these tags is one of the passive's finishers (the ultimate's never).
func is_finisher(tags: Array[StringName]) -> bool:
	for t in hero.passive_never:
		if tags.has(t):
			return false
	for t in hero.passive_tags:
		if tags.has(t):
			return true
	return false


## Magia a blow with these tags gives back when it lands on hits enemies (0 when it is no finisher or hit nothing).
func passive_magick(tags: Array[StringName], hits: int) -> float:
	if not passive or hits <= 0 or not is_finisher(tags):
		return 0.0
	return hero.magick_on_finisher + value(&"finisher_magick")


# ---------- the Brado ----------

## The Brado de Guerra was cried (2026-11-21): for `seconds` every blow plays `speed` faster and `guard` of the damage
## taken is taken off (the Fúria and its charge are gone, redesign B.5).
func rally(seconds: float, speed: float, guard: float) -> void:
	rally_left = seconds
	rally_speed = speed
	rally_guard = guard


## Blows the Brado's buff still takes whole (ComboNode.buff_ward).
var ward := 0


## A blow falls on the Brado's buff: true when it took it.
func take_ward() -> bool:
	if rally_left <= 0.0 or ward <= 0:
		return false
	ward -= 1
	return true


## The Brado's buff is on.
func rallied() -> bool:
	return rally_left > 0.0


## Share of the damage taken that the Brado's buff takes off (0 outside it).
func guard() -> float:
	return rally_guard if rally_left > 0.0 else 0.0


## How fast every blow plays (ComboRunner.speed): 1 with no charge. tags: the blow playing now (the Refinar Pressa,
## blow_speed with the attack's tag, Fatia 2, plays the attack's blows faster).
func attack_speed(tags: Array[StringName] = []) -> float:
	var fast := value(&"blow_speed", tags) if not tags.is_empty() else 0.0
	return 1.0 + fast + cadence(tags) + (rally_speed if rally_left > 0.0 else 0.0)


## Cadência never speeds a blow past this (3 blows of Cadência: CF-03, the 1 < 2 < 3 of the sequence stays readable).
const CADENCE_CAP := 0.24


## Cadência: cadence_pct for each blow of the sequence that landed, for the attack's blows only (the Brado, the special, the
## Golpe Carregado and the Investida do not play faster for it).
func cadence(tags: Array[StringName]) -> float:
	if chain_n <= 0 or tags.is_empty() or DealtBy.source(tags) != &"attack":
		return 0.0
	return minf(value(&"cadence_pct") * chain_n, CADENCE_CAP)


## A blow of the attack's sequence landed (true: it counted). The opener of the sequence starts the count over (chain_start).
func chain_hit(tags: Array[StringName]) -> bool:
	if tags.is_empty() or DealtBy.source(tags) != &"attack":
		return false
	chain_n += 1
	return true


## The sequence began again, or was lost (the window ran out, a blow taken, a dodge past its keeping).
func chain_reset() -> void:
	chain_n = 0


## The share of its cooldown a move with these tags gets back (Fôlego de Guerra: cooldown_pct is negative, never past
## COOLDOWN_CUT_MAX).
func cooldown_cut(tags: Array[StringName]) -> float:
	return clampf(-value(&"cooldown_pct", tags), 0.0, COOLDOWN_CUT_MAX)


# ---------- waves ----------

## The wave a blow with these tags throws: {damage, reach, width}; damage 0 when it throws none.
func wave(tags: Array[StringName]) -> Dictionary:
	return {"damage": value(&"blow_wave", tags), "reach": value(&"blow_wave_m", tags), "width": value(&"blow_wave_w", tags)}


# ---------- Ainda de Pé, Respiro ----------

## He falls: true (and one rise spent) when Ainda de Pé stands him up; the life he gets back is rise_life.
func rise() -> bool:
	if rises <= 0 or _rise_share() <= 0.0:
		return false
	rises -= 1
	return true


func rise_life(max_hp: float) -> float:
	return maxf(1.0, roundf(max_hp * _rise_share()))


## The share of life a rise gives here: rise_share on the descent, rise_boss_share in Morvath's room (0: no rise).
func _rise_share() -> float:
	return value(&"rise_boss_share") if boss_room else value(&"rise_share")


func room_heal() -> float:
	return value(&"room_heal")
