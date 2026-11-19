extends GutTest
## The exported build must read the data as the editor does (2026-11-19, P0 of the evidence package): with Godot's
## default text-to-binary conversion on export the stage's reward_deck (a PackedInt32Array) came out empty in the
## exe, so every door offered a Blessing and the shop stayed empty. The project keeps the text resources as they are.


func test_text_resources_are_not_converted_on_export() -> void:
	assert_false(bool(ProjectSettings.get_setting("editor/export/convert_text_resources_to_binary", true)),
		"editor/export/convert_text_resources_to_binary must stay false (the exe lost the reward deck)")
