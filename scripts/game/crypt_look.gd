class_name CryptLook
extends ArenaRoom
## The look of the Cripta dos Esquecidos (the crypt of the forgotten): a small compartmented crypt, sarcophagi and columns that
## stop shots, niches with hooded statues, candles (docs/design/cycle12_arenas_plan.md, docs/art/cycle12_arenas_spec.md).
## The grey, playable version: ArenaRoom draws the floor, the holes, the obstacles of the layout and the doors. This
## script is the environment artist's: its pieces, stone and light go in dress(). What blocks never comes from here:
## it is an ArenaObstacle in the layout (_stage in tools/make_data.gd), drawn by piece().


func dress() -> void:
	pass
