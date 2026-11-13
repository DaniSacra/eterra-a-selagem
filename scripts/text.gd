extends Node
## Autoload "T": T.t("key") returns the Portuguese text from data/text_pt.tres.

var table: TextTable = load("res://data/text_pt.tres")


func t(key: StringName, args: Dictionary = {}) -> String:
	return table.text(key, args)
