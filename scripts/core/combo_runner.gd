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
## The sequence of the attack is over or lost for good (the window ran out, a blow taken, the dodge past its keeping):
## Cadência and Apogeu start over. combo_dropped is kept as it was.
signal chain_lost

const NO_INPUT := -1

var tree: ComboTree
var phase := Phase.IDLE
var node: ComboNode
## While locked (during the dodge roll, while hurt) inputs are buffered but nothing starts, and the buffer does not
## age (GF-03: a press in the roll or the stagger comes out when it ends).
var locked := false
## Multiplies every move's glint (Feel.glint_scale, set by the paladin).
var glint_scale := 1.0
## How fast every blow plays (windup, glint, attack lock and leg hold; Ímpeto, GiftState.attack_speed): 1 = its own
## timings.
var speed := 1.0
## The move whose followers the chain window offers instead of the last move's (chain_from: Passo Encadeado,
## Golpe sem Fim); null: the last move's own.
var _chain_from: ComboNode
var _t := 0.0
var _buffered := NO_INPUT
var _buffer_age := 0.0
var _dodge_left := 0.0
## Disciplina (dodge_window_add): the seconds a dodge keeps the sequence it cut, set by HeroGifts (0: the dodge drops it).
var dodge_keep := 0.0
## The blow the kept sequence goes on after, and the seconds it is still kept.
var _kept: ComboNode
var _kept_left := 0.0
## The blow that landed just before the one under way (it is the kept one when the dodge cuts a windup).
var _prev: ComboNode
## Glint still to announce in this windup (the windup timer counts windup + glint).
var _hold := 0.0
## Seconds more nothing may start (hold_for: the 8 frames after the circle of light, D-44); presses wait as when locked.
var _held := 0.0
## Seconds the legs stay held after the last blow landed (ComboNode.move_hold).
var _legs := 0.0
## The blow landed on this step (Stage.STRIKE).
var _struck := false
## SW-C1: seconds (at the blow's own pace) since the move under way was pressed; the cancel windows of the move
## (ComboNode.cancel_*_from) are read against it.
var _since := 0.0
## Seconds left before a move may start again, by id (ComboNode.cooldown).
var _cooldowns: Dictionary[StringName, float] = {}
## The share of a move's cooldown taken off when it is armed (0 to 0.5; GiftState.cooldown_cut, set by HeroGifts).
var cooldown_cut := 0.0
## C1c: how long each running cooldown has run and how long it was armed for (cooldown_refund keeps a floor).
var _cd_age: Dictionary[StringName, float] = {}
var _cd_total: Dictionary[StringName, float] = {}


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


## SW-C1 (SWORN: the masks of cancel): the dodge may cut a move from ComboNode.cancel_dodge_from seconds after its press
## (0 for every blow of the Warrior, the spin included: a cut windup never lands, a cut recovery is simply over; Hades II
## cuts the charge, GF-02). The special, the Brado and the Investida cut from cancel_special_from (step), the next light from
## cancel_light_from (step).
func can_cancel() -> bool:
	return not is_attacking() or node == null or _since >= node.cancel_dodge_from


## The chain of the move under way goes on as if `from` had been played (Passo Encadeado: the Corte Veloz counts as
## cut1; Golpe sem Fim: the spin starts the combo over at cut2): its window offers from's followers.
func chain_from(from: ComboNode) -> void:
	if node != null and from != null:
		_chain_from = from


## The first move of the attack's chain (the one the light button starts standing still).
func opener() -> ComboNode:
	return ComboTree.find(tree.neutral, ComboNode.In.LIGHT)


## Nothing may start for this many seconds (presses wait for it, unaged).
func hold_for(seconds: float) -> void:
	_held = maxf(_held, seconds)


## C1c: takes `seconds` off a running cooldown, but never so that the move waits less than `floor_total` seconds in all
## (or less than the cooldown it was armed with, when that is shorter). Nothing when the move is ready. Returns the seconds taken.
func cooldown_refund(id: StringName, seconds: float, floor_total: float) -> float:
	if not _cooldowns.has(id) or seconds <= 0.0:
		return 0.0
	var min_left := maxf(0.0, minf(floor_total, _cd_total.get(id, 0.0)) - _cd_age.get(id, 0.0))
	var left: float = _cooldowns[id]
	var taken := clampf(left - min_left, 0.0, seconds)
	_cooldowns[id] = left - taken
	return taken


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
	# Disciplina: the sequence waits dodge_keep seconds for the next blow, from the last one that landed
	var kept: ComboNode = null
	if dodge_keep > 0.0 and node != null:
		kept = node if phase == Phase.RECOVERY or phase == Phase.WINDOW else _prev
	elif _kept != null and _kept_left > 0.0:
		kept = _kept  # a second dodge keeps it too
	if node != null and kept == null:
		chain_lost.emit()
	_kept = kept
	_kept_left = dodge_keep if kept != null else 0.0
	phase = Phase.IDLE
	node = null
	_chain_from = null
	_legs = 0.0
	locked = true
	_buffered = NO_INPUT
	_dodge_left = tree.dodge_window


func on_dodge_end() -> void:
	locked = false
	_dodge_left = tree.dodge_window
	if _kept != null:
		_kept_left = dodge_keep  # (the keeping counts from the end of the roll)


## Drops everything (the paladin was hurt). clear_cooldowns: also the moves' own cooldowns (a blow taken keeps them).
func reset(clear_cooldowns: bool = true) -> void:
	var had_chain := node != null
	if clear_cooldowns:
		_cooldowns.clear()
	phase = Phase.IDLE
	node = null
	_chain_from = null
	locked = false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	_held = 0.0
	_legs = 0.0
	var had_kept := _kept != null
	_kept = null
	_kept_left = 0.0
	_prev = null
	if had_chain:
		combo_dropped.emit()
	if had_chain or had_kept:
		chain_lost.emit()


## The buffer counts only while a press could be used (GF-04: Hades II's trigger lock): a press during a swing, the
## roll, the stagger or a hold waits for it whole, then gets tree.buffer_time to find a move.
func step(dt: float) -> void:
	for id: StringName in _cooldowns.keys():
		_cooldowns[id] -= dt
		_cd_age[id] = _cd_age.get(id, 0.0) + dt
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)
	_struck = false
	if locked:
		return
	_legs = maxf(0.0, _legs - dt * speed)
	# (checked before it counts down, with room for the sum of frames: a hold of 8 frames starts on the 8th after it)
	var held := _held > 0.0001
	_held = maxf(0.0, _held - dt)
	if phase == Phase.WINDUP or phase == Phase.RECOVERY:
		_since += dt * speed
		if not held and _cancel_into():
			return
	match phase:
		Phase.IDLE:
			if not held and not _try_start():
				_dodge_left = maxf(0.0, _dodge_left - dt)
				_age(dt)
				if _kept != null and not locked:
					_kept_left -= dt
					if _kept_left <= 0.0:
						_kept = null
						chain_lost.emit()
		Phase.WINDUP:
			_t -= dt * speed
			if _hold > 0.0 and _t <= _hold:
				move_glint.emit(node, _hold / speed)
				_hold = 0.0
			if _t <= 0.0:
				phase = Phase.RECOVERY
				_t += node.recovery
				if node.cooldown > 0.0:
					_cooldowns[node.id] = node.cooldown * (1.0 - clampf(cooldown_cut, 0.0, 0.5))
					_cd_total[node.id] = _cooldowns[node.id]
					_cd_age[node.id] = 0.0
				_legs = node.legs_held()
				_struck = true
				move_hit.emit(node)
		Phase.RECOVERY:
			_t -= dt * speed
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
				_chain_from = null
				combo_dropped.emit()
				chain_lost.emit()


func _options() -> Array[ComboNode]:
	if phase == Phase.WINDOW and node != null:
		return _chain_from.following() if _chain_from != null else node.following()
	if _kept != null and phase == Phase.IDLE:
		return _kept.following()
	return tree.dodge if _dodge_left > 0.0 else tree.neutral


## SW-C1: the press waiting cuts the move under way when its window has opened: the special, the Brado or the Investida
## (cancel_special_from, a windup or a recovery), the next light of the chain (cancel_light_from, a recovery). A windup
## cut this way never lands (as with the dodge). True when the new move started.
func _cancel_into() -> bool:
	if _buffered == NO_INPUT or node == null:
		return false
	var recovering := phase == Phase.RECOVERY
	if _buffered == ComboNode.In.LIGHT:
		if not recovering or node.cancel_light_from < 0.0 or _since < node.cancel_light_from:
			return false
	elif _buffered == ComboNode.In.HEAVY or _buffered == ComboNode.In.SHOUT or _buffered == ComboNode.In.RUSH:
		var move := ComboTree.find(tree.neutral, _buffered as ComboNode.In)
		if _since < node.cancel_special_from or move == null or move == node or _cooldowns.has(move.id):
			return false
	else:
		return false
	if recovering:
		phase = Phase.WINDOW
		_t = node.chain_window
		move_ended.emit(node)
	else:
		phase = Phase.IDLE
		node = null
		_chain_from = null
		_hold = 0.0
		chain_lost.emit()
	return _try_start()


func _try_start() -> bool:
	if _buffered == NO_INPUT:
		return false
	var input := _buffered as ComboNode.In
	var found := ComboTree.find(_options(), input)
	if found == null and phase == Phase.WINDOW:
		# an input that does not continue this chain starts a new one
		found = ComboTree.find(tree.neutral, input)
	if found == null and (_dodge_left > 0.0 or _kept != null):
		found = ComboTree.find(tree.neutral, input)
	if found == null or _cooldowns.has(found.id):
		return false
	_buffered = NO_INPUT
	_dodge_left = 0.0
	# the blow this one follows (the one a dodge in its windup keeps the sequence after)
	var before: ComboNode = node if phase == Phase.WINDOW else _kept
	_prev = before if before != null and (before.following() as Array).has(found) else null
	_kept = null
	_kept_left = 0.0
	node = found
	_chain_from = null
	_since = 0.0
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
