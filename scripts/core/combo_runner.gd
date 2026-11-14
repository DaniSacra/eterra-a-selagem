class_name ComboRunner
extends RefCounted
## Walks the combo tree as inputs arrive. Pure logic: no nodes, no clock of its own.
## press() records an input, step() advances time and emits what happened.

enum Phase { IDLE, WINDUP, RECOVERY, WINDOW }

signal move_started(node: ComboNode)
signal move_hit(node: ComboNode)
signal move_ended(node: ComboNode)
signal combo_dropped

const NO_INPUT := -1

var tree: ComboTree
var phase := Phase.IDLE
var node: ComboNode
## While locked (during the dodge roll) inputs are buffered but nothing starts.
var locked := false
var _t := 0.0
var _buffered := NO_INPUT
var _buffer_age := 0.0
var _dodge_left := 0.0


func _init(combo_tree: ComboTree) -> void:
	tree = combo_tree


func press(input: ComboNode.In) -> void:
	_buffered = input
	_buffer_age = 0.0


func is_attacking() -> bool:
	return phase == Phase.WINDUP or phase == Phase.RECOVERY


## Share of walking speed the paladin keeps right now: all of it between moves, the move's own while swinging.
func move_scale(feel: Feel) -> float:
	return node.move_scale_with(feel) if is_attacking() and node != null else 1.0


## The end of any move can be cancelled by a dodge; the windup cannot.
func can_cancel() -> bool:
	return phase != Phase.WINDUP


## True when the moves available right now include a charged one (so a heavy press should start charging).
func charge_available() -> bool:
	return not is_attacking() and ComboTree.find(_options(), ComboNode.In.CHARGE) != null


## Called when a dodge starts: drops the current chain and opens the dodge chains.
func on_dodge() -> void:
	phase = Phase.IDLE
	node = null
	locked = true
	_dodge_left = tree.dodge_window


func on_dodge_end() -> void:
	locked = false
	_dodge_left = tree.dodge_window


## Drops everything (the paladin was hurt).
func reset() -> void:
	var had_chain := node != null
	phase = Phase.IDLE
	node = null
	locked = false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	if had_chain:
		combo_dropped.emit()


func step(dt: float) -> void:
	if _buffered != NO_INPUT:
		_buffer_age += dt
	if locked:
		_expire_buffer()
		return
	match phase:
		Phase.IDLE:
			if not _try_start():
				_dodge_left = maxf(0.0, _dodge_left - dt)
				_expire_buffer()
		Phase.WINDUP:
			_expire_buffer()
			_t -= dt
			if _t <= 0.0:
				phase = Phase.RECOVERY
				_t += node.recovery
				move_hit.emit(node)
		Phase.RECOVERY:
			_expire_buffer()
			_t -= dt
			if _t <= 0.0:
				phase = Phase.WINDOW
				_t = node.chain_window
				move_ended.emit(node)
				_try_start()
		Phase.WINDOW:
			if _try_start():
				return
			_t -= dt
			_expire_buffer()
			if _t <= 0.0:
				phase = Phase.IDLE
				node = null
				combo_dropped.emit()


func _options() -> Array[ComboNode]:
	if phase == Phase.WINDOW and node != null:
		return node.next
	return tree.dodge if _dodge_left > 0.0 else tree.neutral


func _try_start() -> bool:
	if _buffered == NO_INPUT:
		return false
	var input := _buffered as ComboNode.In
	var found := ComboTree.find(_options(), input)
	if found == null and phase == Phase.WINDOW:
		# an input that does not continue this chain starts a new one
		found = ComboTree.find(tree.neutral, input)
	if found == null and _dodge_left > 0.0:
		found = ComboTree.find(tree.neutral, input)
	if found == null:
		return false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	node = found
	phase = Phase.WINDUP
	_t = found.windup
	move_started.emit(found)
	return true


func _expire_buffer() -> void:
	if _buffered != NO_INPUT and _buffer_age > tree.buffer_time:
		_buffered = NO_INPUT
