class_name Ending
extends Node2D
## The sealing scene (written in milestone 5).


func play(_game: Game) -> void:
	await get_tree().create_timer(0.5).timeout
