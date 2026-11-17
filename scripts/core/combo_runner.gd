class_name ComboRunner
extends RefCounted
## Walks the combo tree as inputs arrive. Pure logic: no nodes, no clock of its own.
## press() records an input, step() advances time and emits what happened.

enum Phase { IDLE, WINDUP, RECOVERY, WINDOW }
## The blow as the player sees it (E1c; docs/design/warrior_spec.md, "Estados do golpe"), read from the phases above,
## never a second state machine: IDLE (free: no move, or the chain window with the legs free), WINDUP (the
## anticipation, glint included), STRIKE (the one step the blow lands), RECOVERY (the attack lock and the leg hold
## after the blow: the clip's return or its held pose). IDLE -> WINDUP -> STRIKE -> RECOVERY -> IDLE; a press in
## RECOVERY waits and starts the next WINDUP when the attack lock ends; the dodge cuts any of them back to IDLE.
enum Stage { IDLE, WINDUP, STRIKE, RECOVERY }

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
## While locked (during the dodge roll, while hurt) inputs are buffered but nothing starts, and the buffer does not
## age (GF-03: a press in the roll or the stagger comes out when it ends).
var locked := false
## Multiplies every move's glint (Feel.glint_scale, set by the paladin).
var glint_scale := 1.0
var _t := 0.0
var _buffered := NO_INPUT
var _buffer_age := 0.0
var _dodge_left := 0.0
## Glint still to announce in this windup (the windup timer counts windup + glint).
var _hold := 0.0
## Seconds more nothing may start (hold_for: the 8 frames after the circle of light, D-44); presses wait as when locked.
var _held := 0.0
## Seconds the legs stay held after the last blow landed (ComboNode.move_hold).
var _legs := 0.0
## The blow landed on this step (Stage.STRIKE).
var _struck := false
## Seconds left before a move may start again, by id (ComboNode.cooldown).
var _cooldowns: Dictionary[StringName, float] = {}


func _init(combo_tree: ComboTree) -> void:
	tree = combo_tree


func press(input: ComboNode.In) -> void:
	_buffered = input
	_buffer_age = 0.0


func is_attacking() -> bool:
	return phase == Phase.WINDUP or phase == Phase.RECOVERY


## Share of walking speed the paladin keeps right now: the move's own while he stands planted (E1c: 0 for every
## blow, struck standing still), all of it once he may walk again (the chain still holds for the next press).
func move_scale(feel: Feel) -> float:
	if not planted():
		return 1.0
	# (the legs may still be held after the chain has ended: no move left to ask)
	return node.move_scale_with(feel) if node != null else 0.0


## True while the blade swings (until the blow lands).
func is_swinging() -> bool:
	return phase == Phase.WINDUP


## True while the paladin stands planted: a move's windup and its leg hold after it lands (ComboNode.move_hold),
## which outlasts its recovery and its chain window. Only the dodge cuts it. He never plays the run while planted.
func planted() -> bool:
	return phase == Phase.WINDUP or _legs > 0.0001


## Seconds his legs stay held (ComboNode.move_hold).
func legs_left() -> float:
	return _legs


## Where the blow stands (Stage).
func stage() -> Stage:
	if phase == Phase.WINDUP:
		return Stage.WINDUP
	if _struck:
		return Stage.STRIKE
	if phase == Phase.RECOVERY or _legs > 0.0001:
		return Stage.RECOVERY
	return Stage.IDLE


## A dodge may cut any move, its windup too (Hades II cuts the charge; GF-02): a blow cut before it lands deals nothing.
func can_cancel() -> bool:
	return true


## Nothing may start for this many seconds (presses wait for it, unaged).
func hold_for(seconds: float) -> void:
	_held = maxf(_held, seconds)


## Seconds left before this move may start again.
func cooldown_left(id: StringName) -> float:
	return _cooldowns.get(id, 0.0)


## The held move a press of this charge input would start right now (null when there is none).
func charge_move(charge: ComboNode.In = ComboNode.In.CHARGE) -> ComboNode:
	return null if is_attacking() else ComboTree.find(_options(), charge)


## True when the moves available right now include this held move (so the press should start charging).
func charge_available(charge: ComboNode.In = ComboNode.In.CHARGE) -> bool:
	return charge_move(charge) != null


## Called when a dodge starts: drops the current chain (a windup it cuts never lands) and opens the dodge chains.
## Presses from before the dodge are dropped; those made during it come out when it ends (the dash attack).
func on_dodge() -> void:
	phase = Phase.IDLE
	node = null
	_legs = 0.0
	locked = true
	_buffered = NO_INPUT
	_dodge_left = tree.dodge_window


func on_dodge_end() -> void:
	locked = false
	_dodge_left = tree.dodge_window


## Drops everything (the paladin was hurt). clear_cooldowns: also the moves' own cooldowns (a blow taken keeps them).
func reset(clear_cooldowns: bool = true) -> void:
	var had_chain := node != null
	if clear_cooldowns:
		_cooldowns.clear()
	phase = Phase.IDLE
	node = null
	locked = false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	_held = 0.0
	_legs = 0.0
	if had_chain:
		combo_dropped.emit()


## The buffer counts only while a press could be used (GF-04: Hades II's trigger lock): a press during a swing, the
## roll, the stagger or a hold waits for it whole, then gets tree.buffer_time to find a move.
func step(dt: float) -> void:
	for id: StringName in _cooldowns.keys():
		_cooldowns[id] -= dt
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)
	_struck = false
	if locked:
		return
	_legs = maxf(0.0, _legs - dt)
	# (checked before it counts down, with room for the sum of frames: a hold of 8 frames starts on the 8th after it)
	var held := _held > 0.0001
	_held = maxf(0.0, _held - dt)
	match phase:
		Phase.IDLE:
			if not held and not _try_start():
				_dodge_left = maxf(0.0, _dodge_left - dt)
				_age(dt)
		Phase.WINDUP:
			_t -= dt
			if _hold > 0.0 and _t <= _hold:
				move_glint.emit(node, _hold)
				_hold = 0.0
			if _t <= 0.0:
				phase = Phase.RECOVERY
				_t += node.recovery
				if node.cooldown > 0.0:
					_cooldowns[node.id] = node.cooldown
				_legs = node.legs_held()
				_struck = true
				move_hit.emit(node)
		Phase.RECOVERY:
			_t -= dt
			if _t <= 0.0:
				phase = Phase.WINDOW
				_t = node.chain_window
				move_ended.emit(node)
				if not held:
					_try_start()
		Phase.WINDOW:
			if not held and _try_start():
				return
			_t -= dt
			if not held:
				_age(dt)
			if _t <= 0.0:
				phase = Phase.IDLE
				node = null
				combo_dropped.emit()


func _options() -> Array[ComboNode]:
	if phase == Phase.WINDOW and node != null:
		return node.following()
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
	if found == null or _cooldowns.has(found.id):
		return false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	node = found
	phase = Phase.WINDUP
	_hold = found.glint * glint_scale
	_t = found.windup + _hold
	move_started.emit(found)
	return true


func _age(dt: float) -> void:
	if _buffered == NO_INPUT:
		return
	_buffer_age += dt
	if _buffer_age > tree.buffer_time:
		_buffered = NO_INPUT
