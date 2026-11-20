class_name GiftState
extends RefCounted
## The rules of the hero's passive and Gifts in a run (docs/design/warrior_spec.md 3.1 and 4), pure: no nodes, no
## clock of its own. Every number is a stat (BoonState.stat: the Gifts' mods, which a Blessing could also carry), so
## a Gift with numbers that exist needs no code. HeroGifts (scripts/game/hero_gifts.gd) feeds it the fight's events and
## does what it answers. With no Gift equipped every answer is the game of before (no fury, full cost, no wave).
##
## - Passive (P-A): a finisher (HeroDef.passive_tags, never passive_never) that lands gives back
##   HeroDef.magick_on_finisher + finisher_magick of Magia, once a blow.
## - Ímpeto: fury_per_kill charges a kill (tagged: Sangue Quente adds one for an Omega), up to fury_max, all gone
##   fury_time seconds after the last kill; fury_speed more speed of every blow a charge.
## - Fúria Plena: with fury_max charges a finisher stuns fury_stun seconds longer.
## - Avanço Feroz, Investida: a kill by a blow with dash_back_on_kill gives the dodge's charge back, once a blow.
## - Lâmina Faminta: a blow with hungry_time that lands opens a window that long; an Omega begun in it costs
##   omega_discount less.
## - Golpe sem Fim: a blow with spin_loop_hits that lands on that many starts the combo over at its 2nd blow.
## - Passo Encadeado: a blow with dash_chain counts as the combo's 1st blow.
## - Corte Crescente, Onda Carregada, Fio do Passo: blow_wave (damage), blow_wave_m, blow_wave_w (Combat throws it).
## - Ainda de Pé: once a descent, a fall leaves him standing with rise_share of his life (rise_boss_share in Morvath's
##   room, E6: none today).
## - Fatia 2 (Encantos, Refinar): blow_wave_fan more waves in a fan (Lâmina Tríplice); echo_pct of a blow again after
##   echo_delay (Eco da Verdade, Combat); return_reach after a blow with return_time (Retorno do Corte, Combat);
##   blow_speed (Pressa) and stun_pct (Peso, Combat).
## - Respiro: room_heal of life a room won. Coração da Emeth: ult_charge_pct (the ultimate reads it), finisher_magick.

## The Blessings and Gifts of the run (their stat sums every number; held here, a Callable would not keep it alive).
var boons: BoonState
var hero: HeroDef
## Ímpeto's charges and the seconds before they all fade.
var fury := 0
var fury_left := 0.0
## Seconds left of Lâmina Faminta's window.
var hungry_left := 0.0
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
	hungry_left = maxf(0.0, hungry_left - dt)
	if fury > 0:
		fury_left -= dt
		if fury_left <= 0.0:
			fury = 0
			fury_left = 0.0


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


# ---------- Ímpeto, Fúria Plena ----------

func fury_max() -> int:
	return int(value(&"fury_max"))


## A kill by a blow with these tags (none: a burn, a zone): the charges it gives. Returns how many it gained.
func on_kill(tags: Array[StringName]) -> int:
	var top := fury_max()
	if top <= 0:
		return 0
	var before := fury
	fury = mini(top, fury + int(value(&"fury_per_kill", tags)))
	fury_left = value(&"fury_time")
	return fury - before


## How fast every blow plays (ComboRunner.speed): 1 with no charge. tags: the blow playing now (the Refinar Pressa,
## blow_speed with the attack's tag, Fatia 2, plays the attack's blows faster).
func attack_speed(tags: Array[StringName] = []) -> float:
	var fast := value(&"blow_speed", tags) if not tags.is_empty() else 0.0
	return 1.0 + fast + (fury * value(&"fury_speed") if fury > 0 else 0.0)


## Seconds more a finisher with these tags stuns (Fúria Plena, only with every charge).
func fury_stun(tags: Array[StringName]) -> float:
	if fury <= 0 or fury < fury_max():
		return 0.0
	return value(&"fury_stun", tags)


# ---------- Avanço Feroz, Investida ----------

## True when a kill by a blow with these tags gives the dodge's charge back.
func dash_back(tags: Array[StringName]) -> bool:
	return value(&"dash_back_on_kill", tags) > 0.0


# ---------- Lâmina Faminta ----------

## A blow with these tags landed on hits enemies: opens the window (true when it did).
func on_landed(tags: Array[StringName], hits: int) -> bool:
	var window := value(&"hungry_time", tags)
	if hits <= 0 or window <= 0.0:
		return false
	hungry_left = maxf(hungry_left, window)
	return true


## The share of an Omega's cost taken off when it is begun now (0 outside the window).
func omega_discount() -> float:
	return clampf(value(&"omega_discount"), 0.0, 1.0) if hungry_left > 0.0 else 0.0


# ---------- Golpe sem Fim, Passo Encadeado ----------

## True when the blow just landed (hits enemies) makes the combo go on at its 2nd blow.
func chains_on(tags: Array[StringName], hits: int) -> bool:
	if value(&"dash_chain", tags) > 0.0:
		return true
	var loop := value(&"spin_loop_hits", tags)
	return loop > 0.0 and hits >= int(loop)


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
