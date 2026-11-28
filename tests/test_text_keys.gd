extends GutTest
## F11: the text table and the code agree. Every literal T.t("key") is in data/text_pt.tres; every key of the table is
## used somewhere (its name in a script, tool or data file, or under a dynamic prefix / format pattern some code builds);
## no em or en dash in anything the player reads.

const TABLE := "res://data/text_pt.tres"
const DIRS: Array[String] = ["res://scripts", "res://tools", "res://data"]

var _keys: Array = []
var _code := ""


func before_all() -> void:
	_keys = (load(TABLE) as TextTable).entries.keys()
	for d in DIRS:
		_code += _read_dir(d)


func _read_dir(dir: String) -> String:
	var out := ""
	for f in DirAccess.get_files_at(dir):
		if (f.ends_with(".gd") or f.ends_with(".tres")) and f != "text_pt.tres":
			out += FileAccess.get_file_as_string(dir + "/" + f) + "\n"
	for sub in DirAccess.get_directories_at(dir):
		out += _read_dir(dir + "/" + sub)
	return out


func _matches(pattern: String, text: String) -> Array[String]:
	var rx := RegEx.create_from_string(pattern)
	var out: Array[String] = []
	for m in rx.search_all(text):
		out.append(m.get_string(1))
	return out


func test_every_literal_key_exists() -> void:
	var missing: Array[String] = []
	for k in _matches('T\\.t\\(\\s*&?"([A-Za-z0-9_]+)"', _code):
		if k != "key" and not k.ends_with("_") and not _keys.has(StringName(k)) and not _keys.has(k):
			missing.append(k)
	assert_eq(missing, [], "T.t literal keys missing from the table")


func test_no_key_is_orphan() -> void:
	var words := {}
	for w in _matches('"([A-Za-z0-9_]+)"', _code):
		words[w] = true
	var prefixes: Array[String] = []
	for p in _matches('"([A-Za-z0-9_]+_)"\\s*\\+', _code):
		prefixes.append(p)
	var patterns: Array[RegEx] = []
	for f in _matches('"([A-Za-z0-9_]*%[sd][A-Za-z0-9_%sd]*)"', _code):
		var src := RegEx.create_from_string("%[sd]").sub(f, ".+", true)
		patterns.append(RegEx.create_from_string("^" + src + "$"))
	var orphans: Array[String] = []
	for key in _keys:
		var k := String(key)
		if words.has(k) or prefixes.any(func(p: String) -> bool: return k.begins_with(p)):
			continue
		if patterns.any(func(rx: RegEx) -> bool: return rx.search(k) != null):
			continue
		orphans.append(k)
	assert_eq(orphans, [], "keys of the table no code reads")


func test_no_dash_in_player_text() -> void:
	var bad: Array[String] = []
	var table := load(TABLE) as TextTable
	for key in table.entries:
		var v := String(table.entries[key])
		if v.contains("—") or v.contains("–"):
			bad.append(String(key))
	assert_eq(bad, [], "em or en dash in the table")


func test_how_to_rows_have_text_and_cover_every_player_action() -> void:
	var table := load(TABLE) as TextTable
	var covered: Array[StringName] = []
	for row in HowToScreen.ROWS:
		assert_true(table.entries.has("howto_" + row.id), "name of %s" % row.id)
		assert_true(table.entries.has("howto_%s_desc" % row.id), "description of %s" % row.id)
		for a: StringName in row.actions:
			covered.append(a)
	for step in HowToScreen.STEPS:
		assert_true(table.entries.has("howto_step_" + step) and table.entries.has("howto_step_%s_desc" % step), "step " + step)
	var left: Array[StringName] = []
	for a: StringName in Controls.DEFAULT_KEYS:
		if not covered.has(a) and not HowToScreen.HIDDEN.has(a):
			left.append(a)
	assert_eq(left, [], "player actions the How-to does not list")
