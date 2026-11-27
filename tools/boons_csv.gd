extends SceneTree
## DT-3: writes the Blessings table (the numbers in play) from the data, so the CSV never drifts from make_data.gd.
## ~/tools/godot/godot --headless --path . -s tools/boons_csv.gd [-- out.csv]
## Columns: Anjo;Slot;Nome;Efeito;Valor comum (niveis 1/2/3);Pre-requisito;Concede

const OUT := "docs/design/bencaos_v2/BALANCEAMENTO_V2.csv"


func _initialize() -> void:
	var text := _load_text()
	var out := OUT
	for a in OS.get_cmdline_user_args():
		out = a
	var rows: Array[String] = ["﻿Anjo;Slot;Nome;Efeito;Valor comum (niveis 1/2/3);Pre-requisito;Concede"]
	var files := DirAccess.get_files_at("res://data/boons")
	files.sort()
	for f in files:
		if not f.begins_with("v1_") or not f.ends_with(".tres"):
			continue
		var b: Boon = load("res://data/boons/" + f)
		var parts: Array[String] = []
		for m in b.mods:
			parts.append("%s %s" % [m.stat, _levels(m)])
		if b.skill != null:
			parts.append("skill %s dano %s raio %s" % [SkillDef.Kind.keys()[b.skill.kind], _arr(b.skill.damage), _arr(b.skill.radius)])
		var fam: String = str(text.get("family_" + str(Boon.FAMILY_TAG[b.family]), str(b.family))).split("[")[0]
		var slot: String = text.get(str(Boon.SLOT_KEY[b.slot]), "") if b.slot != Boon.Slot.NONE else "Complemento"
		var desc: String = text.get("boon_%s_desc" % b.id, "")
		rows.append(";".join([fam, slot, text.get("boon_%s" % b.id, str(b.id)), _q(desc), _q("; ".join(parts)),
			_q(", ".join(b.needs_all)), _q(", ".join(b.grants))]))
	var fa := FileAccess.open(out, FileAccess.WRITE)
	fa.store_string("\n".join(rows) + "\n")
	fa.close()
	print("CSV ", rows.size() - 1, " rows -> ", out)
	quit()


func _levels(m: BoonMod) -> String:
	return "%s/%s/%s" % [_n(m.at(1)), _n(m.at(2)), _n(m.at(3))]


func _arr(a: PackedFloat32Array) -> String:
	var s: Array[String] = []
	for v in a:
		s.append(_n(v))
	return "/".join(s)


func _n(v: float) -> String:
	return String.num(v, 3).replace(".", ",")


func _q(s: String) -> String:
	return '"%s"' % s.replace('"', '""')


func _load_text() -> Dictionary:
	var d := {}
	var re := RegEx.new()
	re.compile('^"([a-z0-9_]+)": "(.*)",?$')
	for line in FileAccess.get_file_as_string("res://data/text_pt.tres").split("\n"):
		var m := re.search(line)
		if m != null:
			d[m.get_string(1)] = m.get_string(2).replace('\\"', '"')
	return d
