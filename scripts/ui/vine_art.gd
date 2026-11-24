class_name VineArt
extends RefCounted
## The painted pieces of the Videira by file name (docs/art/vine_spec.md 6): the final art of the ChatGPT pack goes to these
## paths and is picked up as it appears, no code to change; until then VinePlant and VineTag draw the stand-ins.
##   assets/ui/vine/bg.png          the arch and trellis at night, full stage (1280 x 720)
##   assets/ui/vine/vase.png        the clay vase, centred on VineLayout.VASE (150 x 110)
##   assets/ui/vine/bud_dry.png, bud_closed.png, bud_ready.png   the 44 px buds (locked, short, can grow)
##   assets/ui/vine/cluster.png     the grown root: leaves and amber flowers (64 px)
##   assets/ui/vine/tag.png, tag_back.png   the clay tag (128 x 46) and its blank back
##   assets/ui/vine/panel.png       the dark wood of the reading panel
##   (bark.png, leaf.png, can.png and drops.png are listed in the spec and wait for their own drawing)

const DIR := "res://assets/ui/vine/"


## The picture at that file name, or null while it has not been made.
static func texture(file: String) -> Texture2D:
	var path := DIR + file
	return load(path) if ResourceLoader.exists(path) else null


## A stylebox from the picture (9-slice margin in px) or the stand-in.
static func box(file: String, margin: int, stand_in: StyleBox) -> StyleBox:
	var tex := texture(file)
	if tex == null:
		return stand_in
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.set_texture_margin_all(margin)
	return sb
