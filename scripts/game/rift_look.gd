class_name RiftLook
extends ArenaRoom
## The look of the Salão das Fendas (the hall of the rifts): a big hall with a rift of abyss across 60% of its floor, two
## bridges and a way round its end, broken edges, the violet abyss below (docs/art/cycle12_arenas_spec.md).
## The grey, playable version: ArenaRoom draws the floor, the holes, the obstacles of the layout and the doors. This
## script is the environment artist's: its pieces, stone and light go in dress(). What blocks never comes from here:
## it is an ArenaObstacle in the layout (_stage in tools/make_data.gd), drawn by piece().


func dress() -> void:
	pass
