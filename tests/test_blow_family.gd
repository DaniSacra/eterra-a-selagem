extends GutTest
## The colour of a blow (Combat.color_of): a Blessing that only adds damage to a blow (Golpe Radiante, Golpe Firme,
## Final Radiante) tints it with its family (BoonState.family_on), as fire and frost already did by their effects.
## The action's Blessing goes before one that acts alone; a blow no Blessing names keeps the Emeth's green.

var _combat: Combat


func before_each() -> void:
	_combat = Combat.new()
	_combat.boons = BoonState.new(BoonState.load_catalog())


func after_each() -> void:
	_combat.free()


func _take(id: StringName) -> void:
	_combat.boons.take(_combat.boons.find(id))


func test_no_blessing_the_emeth() -> void:
	var light: Array[StringName] = [&"light"]
	assert_eq(_combat.boons.family_on(light), -1)
	assert_eq(_combat.color_of(light), Combat.EMETH)


func test_light_and_vigil_tint_the_attack() -> void:
	var light: Array[StringName] = [&"light"]
	var heavy: Array[StringName] = [&"heavy", &"wave"]
	_take(&"golpe_radiante")
	assert_eq(_combat.color_of(light), Combat.LIGHT, "Golpe Radiante: the attack in Elun's gold")
	assert_eq(_combat.color_of(heavy), Combat.EMETH, "the special untouched")
	_take(&"golpe_firme")  # (the same action: it throws Golpe Radiante away)
	assert_eq(_combat.color_of(light), Combat.VIGIL, "Golpe Firme: the attack in sage")


func test_the_action_blessing_goes_first() -> void:
	var finisher: Array[StringName] = [&"light", &"spin", &"finisher"]
	_take(&"final_radiante")
	assert_eq(_combat.boons.family_on(finisher), Boon.Family.LUZ, "acting alone, it names the finisher")
	_take(&"golpe_firme")
	assert_eq(_combat.boons.family_on(finisher), Boon.Family.VIGILIA, "the attack's own Blessing first")
