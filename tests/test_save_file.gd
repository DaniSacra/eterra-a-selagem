extends GutTest
## C17, BUG-102: the save is written through a temporary file and a copy; a file cut short (a power cut) or garbage
## falls back to the copy, is moved aside and never written over.

const DIR := "user://test_save_file/"
var path := DIR + "save.json"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	for f in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR + f)


func after_all() -> void:
	for f in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR + f)
	DirAccess.remove_absolute(DIR)


func _put(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _save(xp: int) -> String:
	var d := SaveData.defaults()
	d.heroes.warrior.mastery_xp = xp
	return JSON.stringify(d, "  ")


func test_no_file_is_a_new_player() -> void:
	var got := SaveFile.read(path)
	assert_null(got.data)
	assert_eq(got.from, "none")


func test_write_goes_through_tmp_and_keeps_a_copy() -> void:
	assert_true(SaveFile.write(path, _save(100)))
	assert_false(FileAccess.file_exists(path + SaveFile.TMP), "the temporary file took the file's place")
	assert_false(FileAccess.file_exists(path + SaveFile.BAK), "no copy before the first good file")
	assert_true(SaveFile.write(path, _save(200)))
	assert_eq(int(SaveFile.read(path).data.heroes.warrior.mastery_xp), 200)
	assert_eq(int(SaveFile.parse(path + SaveFile.BAK).heroes.warrior.mastery_xp), 100, "the last good file is the copy")


func test_a_truncated_save_loads_the_copy_and_is_never_written_over() -> void:
	SaveFile.write(path, _save(300))
	SaveFile.write(path, _save(400))
	var whole := FileAccess.get_file_as_string(path)
	_put(path, whole.substr(0, whole.length() / 2))  # the power went out halfway
	var got := SaveFile.read(path)
	assert_eq(got.from, "bak")
	assert_eq(int(SaveData.merged(got.data).heroes.warrior.mastery_xp), 300, "the Mastery of the copy, not the defaults")
	assert_true(FileAccess.file_exists(path + SaveFile.BROKEN), "the damaged file is kept aside")
	assert_eq(FileAccess.get_file_as_string(path + SaveFile.BROKEN), whole.substr(0, whole.length() / 2))
	# the next write puts the recovered save back and keeps the broken one untouched
	assert_true(SaveFile.write(path, JSON.stringify(SaveData.merged(got.data))))
	assert_eq(int(SaveFile.read(path).data.heroes.warrior.mastery_xp), 300)
	assert_eq(FileAccess.get_file_as_string(path + SaveFile.BROKEN), whole.substr(0, whole.length() / 2))


func test_an_empty_file_with_no_copy_is_set_aside() -> void:
	_put(path, "")
	var got := SaveFile.read(path)
	assert_null(got.data)
	assert_true(FileAccess.file_exists(path + SaveFile.BROKEN))
	_put(path, "{garbage")
	SaveFile.read(path)
	assert_true(FileAccess.file_exists(path + SaveFile.BROKEN + "1"), "an older broken file is never written over")


func test_a_cut_short_temporary_file_never_replaces_the_save() -> void:
	SaveFile.write(path, _save(500))
	assert_false(SaveFile.write(path, "{\"version\": 4, \"heroes\""), "a text that does not read back is refused")
	assert_eq(int(SaveFile.read(path).data.heroes.warrior.mastery_xp), 500)
	assert_false(FileAccess.file_exists(path + SaveFile.TMP))
