class_name Discern
extends RefCounted
## Discernimento (Rejogabilidade, Fatia 3; sistemas.md 1.3 and 2: the Hades I's Fated Persuasion, BENCAOS_MAPA.md),
## bought with Memória in the Livro de Ahk, in order: I, once a descent the three cards of a Blessing's choice are drawn
## again (Game.reroll_choice); II, the angel of each Blessing's room one layer further is shown on the map
## (Rooms._preview_angels). Never a perfect build: a fresh draw, no choosing. Kept in heroes.<id>.discern. Working
## names; costs a starting point for the balance-designer.
##
## API for the UI (the Book's page): Discern.level(data), Discern.cost(n) (n from 1), Discern.problem(data, n),
## Discern.buy(data) -> bool (the next one; the caller writes the save), text keys discern_<n> and discern_<n>_desc.

enum Problem { OK, OWNED, NEEDS, SHORT, UNKNOWN }

const COSTS: Array[int] = [8, 12]


static func level(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> int:
	return clampi(int(SaveData.hero(data, hero_id).get("discern", 0)), 0, COSTS.size())


static func cost(n: int) -> int:
	return COSTS[n - 1] if n >= 1 and n <= COSTS.size() else 0


static func problem(data: Dictionary, n: int, hero_id := SaveData.FIRST_HERO) -> Problem:
	if n < 1 or n > COSTS.size():
		return Problem.UNKNOWN
	var have := level(data, hero_id)
	if n <= have:
		return Problem.OWNED
	if n > have + 1:
		return Problem.NEEDS
	return Problem.OK if MaterialPurse.can_pay(data, MaterialPurse.MEMORY, cost(n)) else Problem.SHORT


## Buys the next one: spends its Memória and keeps it. False when it cannot (nothing changes).
static func buy(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> bool:
	var n := level(data, hero_id) + 1
	if problem(data, n, hero_id) != Problem.OK or not MaterialPurse.spend(data, MaterialPurse.MEMORY, cost(n)):
		return false
	SaveData.hero(data, hero_id)["discern"] = n
	return true


## The rerolls a descent carries (Discernimento I).
static func rerolls(n: int) -> int:
	return 1 if n >= 1 else 0
