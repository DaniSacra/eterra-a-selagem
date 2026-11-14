class_name ComboRunner
extends RefCounted
## Walks the combo tree as inputs arrive. Pure logic: no nodes, no clock of its own.
## press() records an input, step() advances time and emits what happened.

enum Phase { IDLE, WINDUP, RECOVERY, WINDOW }

signal move_started(node: ComboNode)
## The windup is over and the move holds its glint for time seconds before it lands.
signal move_glint(node: ComboNode, time: float)
signal move_hit(node: ComboNode)
signal move_ended(node: ComboNode)
signal combo_dropped

const NO_INPUT := -1

var tree: ComboTree
var phase := Phase.IDLE
var node: ComboNode
## While locked (during the dodge roll) inputs are buffered but nothing starts.
var locked := false
## Multiplies every move's glint (Feel.glint_scale, set by the paladin).
var glint_scale := 1.0
var _t := 0.0
var _buffered := NO_INPUT
var _buffer_age := 0.0
var _dodge_left := 0.0
## Glint still to announce in this windup (the windup timer counts windup + glint).
var _hold := 0.0


func _init(combo_tree: ComboTree) -> void:
	tree = combo_tree


func press(input: ComboNode.In) -> void:
	_buffered = input
	_buffer_age = 0.0


func is_attacking() -> bool:
	return phase == Phase.WINDUP or phase == Phase.RECOVERY


## Share of walking speed the paladin keeps right now: the move's own while the blade swings (Ember & Blade and
## Hades II plant the feet: a swing moves only by its lunge), all of it once the blow has landed, when walking
## cuts the follow-through short and runs (the chain still holds for the next press).
func move_scale(feel: Feel) -> float:
	return node.move_scale_with(feel) if phase == Phase.WINDUP and node != null else 1.0


## True while the blade swings (until the blow lands): the paladin stands planted and plays the swing.
func is_swinging() -> bool:
	return phase == Phase.WINDUP


## The end of any move can be cancelled by a dodge; the windup cannot.
func can_cancel() -> bool:
	return phase != Phase.WINDUP


## The held move a press of this charge input would start right now (null when there is none).
func charge_move(charge: ComboNode.In = ComboNode.In.CHARGE) -> ComboNode:
	return null if is_attacking() else ComboTree.find(_options(), charge)


## True when the moves available right now include this held move (so the press should start charging).
func charge_available(charge: ComboNode.In = ComboNode.In.CHARGE) -> bool:
	return charge_move(charge) != null


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
			if _hold > 0.0 and _t <= _hold:
				move_glint.emit(node, _hold)
				_hold = 0.0
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
	_hold = found.glint * glint_scale
	_t = found.windup + _hold
	move_started.emit(found)
	return true


func _expire_buffer() -> void:
	if _buffered != NO_INPUT and _buffer_age > tree.buffer_time:
		_buffered = NO_INPUT
