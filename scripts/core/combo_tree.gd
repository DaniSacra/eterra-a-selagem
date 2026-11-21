class_name ComboTree
extends Resource
## The whole move list: chains that start standing still and chains that start out of a dodge.

@export var neutral: Array[ComboNode] = []
@export var dodge: Array[ComboNode] = []
## An input pressed this long before it can be used is still honoured.
@export var buffer_time := 0.15
## Holding heavy for this long turns the release into a CHARGE input.
@export var charge_time := 0.45
## How long after a dodge ends the dodge chains can still start.
@export var dodge_window := 0.3


static func find(options: Array[ComboNode], input: ComboNode.In) -> ComboNode:
	for node in options:
		if node.input == input:
			return node
	return null


## Every named move with the inputs that lead to it: [{ node, path: [In...], from_dodge }].
func named_moves() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	_collect(neutral, [], false, out)
	_collect(dodge, [], true, out)
	return out


func _collect(options: Array[ComboNode], path: Array, from_dodge: bool, out: Array[Dictionary]) -> void:
	for node in options:
		var here := path.duplicate()
		here.append(node.input)
		if node.title != &"":
			out.append({"node": node, "path": here, "from_dodge": from_dodge})
		_collect(node.following(), here, from_dodge, out)


## Every node of the tree, each once.
func all_nodes() -> Array[ComboNode]:
	var out: Array[ComboNode] = []
	var stack: Array[ComboNode] = []
	stack.append_array(neutral)
	stack.append_array(dodge)
	while not stack.is_empty():
		var node: ComboNode = stack.pop_back()
		out.append(node)
		stack.append_array(node.next)
	return out


## "E E D" style notation of a path, for the Golpes screen.
static func notation(path: Array, from_dodge: bool, words: Dictionary) -> String:
	var parts := PackedStringArray()
	if from_dodge:
		parts.append(words.dodge + " +")
	for input: ComboNode.In in path:
		match input:
			ComboNode.In.CHARGE:
				parts.append(words.charge)
			ComboNode.In.CHARGE_LIGHT:
				parts.append(words.get("charge_light", "E+"))
			ComboNode.In.SHOUT:
				parts.append(words.get("shout", "Brado"))
			ComboNode.In.RUSH:
				parts.append(words.get("rush", "Investida"))
			ComboNode.In.LIGHT:
				parts.append("E")
			_:
				parts.append("D")
	return " ".join(parts)
