class_name SceneGo
extends RefCounted
## The three scenes of the game and the one way between them (HUB-B1): the title (boot), the hub and the run. Every
## move from one to another goes through to(), so a test can catch where the flow goes without leaving its own scene
## (catch: called with the path instead of changing scene).
##   SceneGo.to(get_tree(), SceneGo.HUB)

const TITLE := "res://scenes/boot.tscn"
const HUB := "res://scenes/hub.tscn"
const GAME := "res://scenes/game.tscn"

## Set by tests: gets the path instead of the scene changing (null: the scene changes).
static var catch: Callable


static func to(tree: SceneTree, path: String) -> void:
	if catch.is_valid():
		catch.call(path)
		return
	tree.change_scene_to_file(path)
