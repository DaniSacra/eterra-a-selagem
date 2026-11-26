extends GutTest
## Lote 1: BG-4 (--hub --smoke goes to the Santuário), DT-2 (the Voragem stays in reserve).


func test_hub_with_smoke_routes_to_the_hub() -> void:
	var boot: GDScript = load("res://scripts/boot.gd")
	Dev.put("smoke", "5")
	Dev.put("hub")
	assert_eq(boot.call(&"route"), SceneGo.HUB)
	Dev.drop("hub")
	assert_eq(boot.call(&"route"), SceneGo.GAME)
	Dev.drop("smoke")


func test_a_legacy_vortex_save_plays_the_cleave() -> void:
	var w := HeroDef.warrior()
	assert_eq(w.ult_for_weapon(99).id, &"cleave")
	assert_true(w.ultimate(&"vortex").reserve, "kept for a future weapon, never fixed")
	var d := SaveData.defaults()
	d.heroes.warrior.ultimate = "vortex"
	SaveData.migrate_redesign(d)
	assert_eq(d.heroes.warrior.ultimate, "")
	var again := d.duplicate(true)
	SaveData.migrate_redesign(again)
	assert_eq(again, d, "idempotent")
