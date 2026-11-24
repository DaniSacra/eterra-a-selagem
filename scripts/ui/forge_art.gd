class_name ForgeArt
extends RefCounted
## The painted pieces of the Forja by file name (docs/art/forge_spec.md 7, docs/art/requests/Pedido-ChatGPT-Forja.txt):
## the final art goes to these paths and is picked up as it appears, no code to change (as DonsArt); until then the
## bench is drawn in code. Wired now: bg (the whole ground), cloth (the cloth, 1160 x 130 at (60, 200)), emeth_flat (the
## Emeth lying, 1000 x 160), pick_whole and pick_head (the Picareta, 620 x 220). The other files of the pack (gems, rings,
## chip, plate, marks, icons, sparks, steam) are listed in FILES for the day each one is wired.
##   var tex := ForgeArt.texture("bg.png")      # null until the file exists

const DIR := "res://assets/ui/forge/"
const FILES: Array[String] = ["bg.png", "cloth.png", "emeth_flat.png", "gem_amber.png", "gem_blue.png", "gem_ivory.png",
	"ring_iron.png", "ring_gold.png", "pick_whole.png", "pick_head.png", "chip.png", "plate.png", "mark_on.png",
	"mark_off.png", "icons.png", "sparks.png", "steam.png"]


static func texture(file: String) -> Texture2D:
	var path := DIR + file
	return load(path) as Texture2D if ResourceLoader.exists(path) else null
