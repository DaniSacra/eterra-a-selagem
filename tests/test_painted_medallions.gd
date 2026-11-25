extends GutTest
## The hand-painted medallions, Rev. 02 (2026-11-23, docs/art/medallions_rev02.md): every door id and every Blessing has
## its painting, imported with mipmaps, and the art changed nothing of the rules (reserved Blessings stay reserved).


func test_every_door_id_has_its_painting() -> void:
	for id in RewardIcon.all_ids():
		assert_not_null(RewardIcon.texture(id), "assets/ui/rewards/%s.png" % id)
	assert_eq(RewardIcon.all_ids().size(), 25)


func test_every_blessing_has_its_painted_medallion() -> void:
	var dir := DirAccess.open("res://data/boons")
	var n := 0
	for f in dir.get_files():
		if not f.ends_with(".tres"):
			continue
		var b: Boon = load("res://data/boons/" + f)
		assert_not_null(BoonArt.medallion(b.id), "assets/ui/boons/%s.png" % b.id)
		n += 1
	assert_eq(n, 81)


func test_the_paintings_import_with_mipmaps() -> void:
	# BoonArt.rect and the door's shader both filter with mipmaps (512 px shown at 32 to 200)
	for folder in ["res://assets/ui/boons/", "res://assets/ui/rewards/"]:
		for f in DirAccess.get_files_at(folder):
			if f.ends_with(".png.import"):
				var cfg := ConfigFile.new()
				cfg.load(folder + f)
				assert_true(cfg.get_value("params", "mipmaps/generate", false), folder + f)


func test_the_art_leaves_the_reserved_blessings_reserved() -> void:
	var b: Boon = load("res://data/boons/00_brasas.tres")
	assert_true(b.reserve, "a painting never makes a reserved Blessing drawable")
