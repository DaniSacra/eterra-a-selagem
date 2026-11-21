extends GutTest
## TalentMotif (AP-4 spec 2.2): a motif for each of the 19 Gifts, shapes that triangulate, silhouettes apart, the
## colour of the paper's paint and the glyph under the LOD.


func test_every_gift_has_a_motif_that_draws() -> void:
	for id in TalentGlyph.IDS:
		assert_true(TalentMotif.has(id), "%s has a motif" % id)
		for part: Dictionary in TalentMotif.shapes(id):
			assert_false(Geometry2D.triangulate_polygon(part.p).is_empty(), "%s: every shape triangulates" % id)
	assert_false(TalentMotif.has(&"nope"))


func test_silhouettes_stay_apart() -> void:
	var masks := {}
	for id in TalentGlyph.IDS:
		var m := PackedByteArray()
		m.resize(36 * 36)
		for y in 36:
			for x in 36:
				var p := (Vector2(x + 0.5, y + 0.5) - Vector2(18, 18)) / 16.0
				for part: Dictionary in TalentMotif.shapes(id):
					if Geometry2D.is_point_in_polygon(p, part.p):
						m[y * 36 + x] = 1
						break
		masks[id] = m
	var ids := TalentGlyph.IDS
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var a: PackedByteArray = masks[ids[i]]
			var b: PackedByteArray = masks[ids[j]]
			var both := 0
			var any := 0
			for k in a.size():
				both += a[k] & b[k]
				any += a[k] | b[k]
			assert_lt(float(both) / maxf(1.0, any), 0.8, "%s and %s apart" % [ids[i], ids[j]])


func test_paint_stays_on_the_paper() -> void:
	for key in ["carmine", "rust", "emerald", "blue", "gold", "terra"]:
		var c := TalentMotif.tone(key)
		assert_lte(c.s, 0.6, key)
		assert_lte(maxf(c.r, maxf(c.g, c.b)) * TalentMotif.LIGHT, 1.0, key)
	# emerald only in the Emeth branch and the Coração da Emeth
	for id in TalentGlyph.IDS:
		var branch := TalentMotif.branch_of(id)
		for part: Dictionary in TalentMotif.shapes(id):
			if part.k == "emerald":
				assert_true(branch == TalentDef.Branch.EMETH or id == &"coracao_da_emeth" or id == &"quarto_corte"
					or branch == TalentDef.Branch.BRIDGE, "%s: emerald only where the Emeth is" % id)


func test_under_the_lod_it_draws_the_glyph() -> void:
	var c := Control.new()
	c.size = Vector2(100, 100)
	var got: Array = []
	c.draw.connect(func() -> void:
		got.append(TalentMotif.draw(c, &"impeto", Vector2(20, 20), 10.0))
		got.append(TalentMotif.draw(c, &"impeto", Vector2(60, 60), 30.0, HeroLoadout.State.LOCKED))
		got.append(TalentMotif.draw(c, &"nope", Vector2(40, 40), 30.0)))
	add_child_autofree(c)
	await wait_frames(2)
	assert_eq(got.slice(0, 3), [true, true, false])
