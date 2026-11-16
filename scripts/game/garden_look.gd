class_name GardenLook
extends ArenaRoom
## The look of the Jardim das Raízes Mortas (the garden of the dead roots): a wide hall round a petrified tree of stone (its
## trunk stops bodies and shots, its crown must open round the paladin), low roots, spectral crystals for show only
## (decision D-30; docs/art/cycle12_arenas_spec.md).
## The grey, playable version: ArenaRoom draws the floor, the holes, the obstacles of the layout and the doors. This
## script is the environment artist's: its pieces, stone and light go in dress(). What blocks never comes from here:
## it is an ArenaObstacle in the layout (_stage in tools/make_data.gd), drawn by piece().


func dress() -> void:
	pass
