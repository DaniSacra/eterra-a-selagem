class_name Palette
extends Resource
## The closed master palette of Eterra, copied from src/palette.js of the RPG.
## Families run light to dark. A new colour enters here first, with a reason.

const PATH := "res://data/palette.tres"

@export var families: Dictionary = {}

static var _main: Palette


static func main() -> Palette:
	if _main == null:
		_main = load(PATH) as Palette
	return _main


## Colour of a family by tone index (0 = lightest).
static func c(family: StringName, tone: int) -> Color:
	var tones: PackedStringArray = main().families[family]
	return Color.html(tones[clampi(tone, 0, tones.size() - 1)])


func has_hex(hex: String) -> bool:
	var needle := hex.to_lower()
	for tones: PackedStringArray in families.values():
		if tones.has(needle):
			return true
	return false


func tones(family: StringName) -> PackedStringArray:
	return families[family]
