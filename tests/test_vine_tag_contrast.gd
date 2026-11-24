extends GutTest
## AD-08: the tag's name and price keep 4.5:1 against the parchment face, owned or not.


func test_ink_on_face() -> void:
	assert_gte(VineTag.contrast(VineTag.DARK_INK, VineTag.FACE), VineTag.MIN_CONTRAST)
	assert_gte(VineTag.contrast(VineTag.DARK_INK, VineTag.FACE_BACK), VineTag.MIN_CONTRAST)


func test_short_price_rubric_on_face() -> void:
	assert_gte(VineTag.contrast(VineTag.RUBRIC_LIT, VineTag.FACE), VineTag.MIN_CONTRAST)
