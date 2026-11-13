extends Node
## First scene: applies saved options, then opens the game (the title screen arrives in milestone 6).


func _ready() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/game.tscn")
