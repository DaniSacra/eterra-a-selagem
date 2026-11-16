extends Node
## Game feel probe (measurement only, changes nothing in the game): plays scripted inputs through Controls.VirtualPad
## (and the real Input path where the hit stop matters) on the real game scene, one step per frame at 60 Hz, and
## prints what happened on which frame. docs/design/game_feel_measures.md reads its output.
## Run by tools/feel_probe_run.gd:
## ~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain

var game: Game
var pad := Controls.VirtualPad.new()
var frame := 0
var log_lines: PackedStringArray = []
var events: Array = []
## Scenario runner: a coroutine-like list of [name, callable]; each scenario drives frames through _await_frames.
var _queue: Array[Callable] = []
var _busy := false
var _wait := 0
var _on_frame: Callable = Callable()


func _ready() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(game)
	_queue = [_s_move, _s_turn, _s_attack_air, _s_attack_hit, _s_combo_mash, _s_combo_on_hit, _s_buffer, _s_dodge,
		_s_dodge_cancel, _s_attack_in_dodge, _s_walk_cancel, _s_special, _s_omegas, _s_cast, _s_hitstop_buffer,
		_s_enemy_interrupt, _s_kill, _s_hurt, _s_extra]
	var only := OS.get_environment("PROBE")
	if only != "":
		_queue = _queue.filter(func(c: Callable) -> bool: return only.split(",").has(c.get_method()))


func _process(_delta: float) -> void:
	frame += 1
	if _on_frame.is_valid():
		_on_frame.call()
	if frame == 30:
		Controls.virtual = pad
		_next.call_deferred()


func _next() -> void:
	if _queue.is_empty():
		print("PROBE DONE")
		get_tree().quit()
		return
	var s: Callable = _queue.pop_front()
	await s.call()
	_next()


# ---------- helpers ----------

## Waits until the start of frame n frames from now (the game has stepped n times with the pad set before).
func step(n: int = 1) -> void:
	for i in n:
		await get_tree().process_frame


func reset_hero(at := Vector2(0, 4)) -> void:
	var p := game.player
	pad.held.clear()
	pad.tapped.clear()
	pad.released.clear()
	pad.move = Vector2.ZERO
	pad.aim = Vector2.RIGHT
	p.runner.reset()
	p.state = Player.State.MOVE
	p.pos = at
	p.facing = Vector2.RIGHT
	p.invuln = 0.0
	p.dodge_charges = p.dodge_max
	p.set(&"_dodge_recharge", 0.0)
	p.charging = false
	p.sprinting = false
	p.hp = p.max_hp
	p.magick.gain(p.magick.max_value)
	p.cast_active = false
	p.cast_cooldown = 0.0
	game.fx.stop_left = 0.0
	game.fx.end_slow()
	for e in game.horde.list.duplicate():
		e.alive = false
		e.state = Enemy.State.DEAD
	game.horde.list.clear()
	game.horde.dying.clear()
	game.ground.clear()
	game.combat.set(&"_slow_cd", 0.0)
	game.combat.set(&"_cine_cd", 0.0)
	await step(20)


func dummy(at: Vector2, hp := 9999.0, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = hp
	e.max_hp = hp
	e.cooldown = 999.0
	return e


## One frame of the pad: taps this frame (pressed and released at once unless held), then a game step.
func tap(action: StringName) -> void:
	pad.press(action)


func frame_end() -> void:
	# like the bot: every frame the taps of the frame before are gone
	pad.end_frame()
	for a in pad.held.keys():
		if not _holding.has(a):
			pad.release(a)
	pad.released.clear()


var _holding: Dictionary = {}


func hold(action: StringName) -> void:
	_holding[action] = true
	pad.press(action)


func let_go(action: StringName) -> void:
	_holding.erase(action)
	pad.release(action)


func out(s: String) -> void:
	print(s)


## Runs n frames calling f(i) before each one (i = 0 on the frame the first input is read); f returns nothing.
## After each frame `probe(i)` records the state that frame left.
func run(n: int, f: Callable, probe: Callable) -> void:
	for i in n:
		f.call(i)
		var t0 := game.time
		await get_tree().process_frame
		probe.call(i, game.time != t0)
		frame_end()


func phase_name() -> String:
	return ComboRunner.Phase.keys()[game.player.runner.phase]


func node_id() -> String:
	return String(game.player.runner.node.id) if game.player.runner.node else "-"


# ---------- scenarios ----------

func _s_move() -> void:
	out("== MOVE (walk right from rest 30 frames, then let go)")
	await reset_hero()
	var p := game.player
	var last := [p.pos]
	await run(45, func(i: int) -> void:
		pad.move = Vector2.RIGHT if i < 30 else Vector2.ZERO,
		func(i: int, stepped: bool) -> void:
			var v: float = (p.pos - last[0]).length() * 60.0
			if i < 4 or (i >= 28 and i < 36):
				out("f%d stepped=%s speed=%.2f m/s anim=%s x=%.3f" % [i, stepped, v, p.get(&"_current_anim"), p.pos.x])
			last[0] = p.pos)
	out("== SPRINT (hold dodge while moving, 50 frames)")
	await reset_hero(Vector2(-8, 4))
	last = [p.pos]
	await run(50, func(i: int) -> void:
		pad.move = Vector2.RIGHT
		if i == 0:
			hold(&"dodge"),
		func(i: int, _s: bool) -> void:
			var v: float = (p.pos - last[0]).length() * 60.0
			if i < 18 or i % 10 == 0:
				out("f%d state=%s speed=%.2f sprint=%s inv=%s" % [i, Player.State.keys()[p.state], v, p.sprinting, p.invulnerable()])
			last[0] = p.pos)
	let_go(&"dodge")
	await step(2)
	out("== SPRINT let go: speed by frame")
	await reset_hero(Vector2(-8, 4))
	last = [p.pos]
	await run(40, func(i: int) -> void:
		pad.move = Vector2.RIGHT
		if i == 0:
			hold(&"dodge")
		if i == 30:
			let_go(&"dodge"),
		func(i: int, _s: bool) -> void:
			var v: float = (p.pos - last[0]).length() * 60.0
			if i >= 28 and i < 34:
				out("f%d speed=%.2f sprint=%s" % [i, v, p.sprinting])
			last[0] = p.pos)


func _s_turn() -> void:
	out("== TURN (walk right, then left: facing and model yaw by frame)")
	await reset_hero()
	var p := game.player
	await run(10, func(_i: int) -> void: pad.move = Vector2.RIGHT, func(_i: int, _s: bool) -> void: pass)
	await run(12, func(_i: int) -> void: pad.move = Vector2.LEFT,
		func(i: int, _s: bool) -> void:
			var model := p.get(&"_model") as Node3D
			out("f%d facing=%.0f deg model=%.0f deg" % [i, rad_to_deg(p.facing.angle()), rad_to_deg(atan2(sin(model.rotation.y), cos(model.rotation.y)))]))


func _combo_watch() -> Array:
	var seen: Array = []
	var r := game.player.runner
	var c1 := func(n: ComboNode) -> void: seen.append(["start", String(n.id), _cur])
	var c2 := func(n: ComboNode) -> void: seen.append(["hit", String(n.id), _cur])
	var c3 := func(n: ComboNode) -> void: seen.append(["end", String(n.id), _cur])
	var c4 := func() -> void: seen.append(["drop", "", _cur])
	var c5 := func(n: ComboNode, t: float) -> void: seen.append(["glint", String(n.id) + " %.2fs" % t, _cur])
	r.move_started.connect(c1)
	r.move_hit.connect(c2)
	r.move_ended.connect(c3)
	r.combo_dropped.connect(c4)
	r.move_glint.connect(c5)
	_unwatch = func() -> void:
		r.move_started.disconnect(c1)
		r.move_hit.disconnect(c2)
		r.move_ended.disconnect(c3)
		r.combo_dropped.disconnect(c4)
		r.move_glint.disconnect(c5)
	return seen


var _cur := 0
var _unwatch: Callable


func _s_attack_air() -> void:
	out("== ATTACK 1 tap, nobody near (frames from the press)")
	await reset_hero()
	var seen := _combo_watch()
	await run(50, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"light_attack"),
		func(_i: int, _s: bool) -> void: pass)
	_unwatch.call()
	out("events " + str(seen))


func _s_attack_hit() -> void:
	out("== ATTACK 1 tap on a dummy 2 m ahead: hit stop, flash, push, kick, shake")
	await reset_hero()
	var e := dummy(game.player.pos + Vector2(2.0, 0))
	await step(2)
	var seen := _combo_watch()
	var p0 := e.pos
	await run(30, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"light_attack"),
		func(i: int, stepped: bool) -> void:
			var kick: Vector3 = game.fx.get(&"_kick")
			out("f%d stepped=%s stop_left=%.0fms flash_t=%.2f hurt_t=%.2f push=%.2f moved=%.2f kick=%.3fm shake=%.3fm e.state=%s phase=%s" % [i, stepped,
				game.fx.stop_left * 1000.0, e.flash_t, e.hurt_t, e.push.length(), e.pos.distance_to(p0), kick.length(), float(game.fx.get(&"_shake")),
				Enemy.State.keys()[e.state], phase_name()]))
	_unwatch.call()
	out("events " + str(seen))


func _s_combo_mash() -> void:
	for with_dummy in [false, true]:
		out("== COMBO mash (a tap every other frame) %s" % ("on a dummy" if with_dummy else "in the air"))
		await reset_hero()
		if with_dummy:
			dummy(game.player.pos + Vector2(2.0, 0))
			await step(2)
		var seen := _combo_watch()
		var frozen := [0]
		await run(110, func(i: int) -> void:
			_cur = i
			if i % 2 == 0 and i < 80:
				tap(&"light_attack"),
			func(_i: int, stepped: bool) -> void:
				if not stepped:
					frozen[0] += 1)
		_unwatch.call()
		out("events " + str(seen) + " frozen_frames=%d" % frozen[0])


func _s_combo_on_hit() -> void:
	out("== COMBO one tap per blow, pressed 3 frames after the blow lands (dummy)")
	await reset_hero()
	dummy(game.player.pos + Vector2(2.0, 0))
	await step(2)
	var seen := _combo_watch()
	var hits := [0]
	game.player.runner.move_hit.connect(func(_n: ComboNode) -> void: hits[0] += 1, CONNECT_ONE_SHOT)
	var want := [0]
	await run(110, func(i: int) -> void:
		_cur = i
		if i == 0 or want[0] == i:
			tap(&"light_attack"),
		func(i: int, _s: bool) -> void:
			if not seen.is_empty() and seen[-1][0] == "hit" and seen[-1][2] == i:
				want[0] = i + 3)
	_unwatch.call()
	out("events " + str(seen))


func _s_buffer() -> void:
	out("== BUFFER: second tap d frames after the first (air): when does cut2 start")
	for d in [1, 2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 30, 36]:
		await reset_hero()
		var seen := _combo_watch()
		await run(60, func(i: int) -> void:
			_cur = i
			if i == 0 or i == d:
				tap(&"light_attack"),
			func(_i: int, _s: bool) -> void: pass)
		_unwatch.call()
		var c2 := seen.filter(func(x: Array) -> bool: return x[0] == "start" and x[1] == "cut2")
		var h1 := seen.filter(func(x: Array) -> bool: return x[0] == "hit" and x[1] == "cut1")
		var e1 := seen.filter(func(x: Array) -> bool: return x[0] == "end" and x[1] == "cut1")
		out("d=%d cut1 hit f%s end f%s -> cut2 starts %s" % [d, h1[0][2] if h1 else "-", e1[0][2] if e1 else "-", ("f%d" % c2[0][2]) if c2 else "LOST"])
	out("== BUFFER: tap during cut3's windup and recovery (air), from the cut2 hit")
	for d in [26, 30, 31, 32, 34, 36, 40]:
		await reset_hero()
		var seen := _combo_watch()
		var at := [-1]
		await run(140, func(i: int) -> void:
			_cur = i
			if i == 0 or i == 10 or i == 24 or (at[0] >= 0 and i == at[0] + d):
				tap(&"light_attack"),
			func(i: int, _s: bool) -> void:
				if at[0] < 0 and seen.any(func(x: Array) -> bool: return x[0] == "start" and x[1] == "cut3"):
					at[0] = i)
		_unwatch.call()
		var starts := seen.filter(func(x: Array) -> bool: return x[0] == "start")
		out("tap %d frames after cut3 starts: %s" % [d, str(starts.map(func(x: Array) -> String: return "%s@f%d" % [x[1], x[2]]))])


func _s_dodge() -> void:
	out("== DODGE right from rest: state, safety, distance, when the next one is allowed")
	await reset_hero(Vector2(-8, 4))
	var p := game.player
	var x0 := p.pos.x
	var dodged := [0]
	p.dodged.connect(func(_d: Vector2) -> void: dodged[0] += 1)
	await run(70, func(i: int) -> void:
		pad.move = Vector2.RIGHT if i < 30 else Vector2.ZERO
		if i >= 1:
			tap(&"dodge"),
		func(i: int, _s: bool) -> void:
			if i < 24 or i % 5 == 0:
				out("f%d state=%s inv=%s x=%.2f charges=%d dodges=%d" % [i, Player.State.keys()[p.state], p.invulnerable(), p.pos.x - x0, p.dodge_charges, dodged[0]]))
	out("== DODGE alone (no move held): distance")
	await reset_hero(Vector2(-8, 4))
	x0 = game.player.pos.x
	await run(30, func(i: int) -> void:
		if i == 0:
			tap(&"dodge"),
		func(_i: int, _s: bool) -> void: pass)
	out("dodge distance standing (facing right): %.2f m" % (game.player.pos.x - x0))


func _s_dodge_cancel() -> void:
	out("== DODGE pressed d frames after an attack tap (air): frame it starts or LOST")
	for move_id in [&"light_attack", &"heavy_attack"]:
		for d in [0, 1, 2, 3, 4, 5, 6, 8, 10, 14, 20, 30, 40]:
			await reset_hero()
			var p := game.player
			var at := [-1]
			var cb := func(_d: Vector2) -> void: at[0] = _cur
			p.dodged.connect(cb)
			var seen := _combo_watch()
			await run(60, func(i: int) -> void:
				_cur = i
				if i == 0:
					tap(move_id)
				if i == d:
					tap(&"dodge"),
				func(_i: int, _s: bool) -> void: pass)
			_unwatch.call()
			p.dodged.disconnect(cb)
			var hit := seen.filter(func(x: Array) -> bool: return x[0] == "hit")
			out("%s then dodge at f%d: blow lands %s, dodge %s" % [move_id, d, ("f%d" % hit[0][2]) if hit else "NEVER (cut)", ("f%d" % at[0]) if at[0] >= 0 else "LOST"])


func _s_attack_in_dodge() -> void:
	out("== ATTACK tapped d frames after a dodge tap: what starts and when")
	for d in [1, 3, 5, 8, 11, 12, 13, 16, 20, 30, 35, 40]:
		await reset_hero(Vector2(-8, 4))
		var seen := _combo_watch()
		await run(60, func(i: int) -> void:
			_cur = i
			pad.move = Vector2.RIGHT if i < 2 else Vector2.ZERO
			if i == 0:
				tap(&"dodge")
			if i == d:
				tap(&"light_attack"),
			func(_i: int, _s: bool) -> void: pass)
		_unwatch.call()
		var st := seen.filter(func(x: Array) -> bool: return x[0] == "start")
		out("attack at f%d: %s" % [d, ("%s@f%d" % [st[0][1], st[0][2]]) if st else "LOST"])


func _s_walk_cancel() -> void:
	out("== WALK during an attack (move held down-screen from the tap): meters walked each frame")
	for id in [&"cut1", &"cut3", &"bolt"]:
		await reset_hero()
		var p := game.player
		var last := [p.pos]
		var steps: PackedStringArray = []
		var seen := _combo_watch()
		var taps: Array = [0] if id != &"cut3" else [0, 12, 32]
		await run(80, func(i: int) -> void:
			_cur = i
			pad.move = Vector2.DOWN if (id != &"cut3" or i >= 32) else Vector2.ZERO
			if taps.has(i):
				tap(&"light_attack" if id != &"bolt" else &"heavy_attack"),
			func(i: int, _s: bool) -> void:
				var d: float = (p.pos - last[0]).dot(Vector2.DOWN)
				if i <= 60:
					steps.append("%d:%.2f" % [i, d])
				last[0] = p.pos)
		_unwatch.call()
		out("%s events %s" % [id, str(seen)])
		out("  walked " + " ".join(steps))


func _s_special() -> void:
	out("== SPECIAL tap: the bolt leaves, and when an attack or a second special may start (tapped every frame)")
	for follow in [&"light_attack", &"heavy_attack"]:
		await reset_hero()
		var seen := _combo_watch()
		await run(80, func(i: int) -> void:
			_cur = i
			if i == 0 or i >= 2:
				tap(&"heavy_attack" if i == 0 else follow),
			func(_i: int, _s: bool) -> void: pass)
		_unwatch.call()
		out("special then %s every frame: %s" % [follow, str(seen.slice(0, 6))])


func _s_omegas() -> void:
	out("== OMEGA attack: hold light from f0")
	await reset_hero()
	var p := game.player
	var seen := _combo_watch()
	await run(90, func(i: int) -> void:
		_cur = i
		if i == 0:
			hold(&"light_attack"),
		func(i: int, _s: bool) -> void:
			if i % 6 == 0:
				out("f%d charging=%s progress=%.2f phase=%s node=%s" % [i, p.charging, p.charge_progress(), phase_name(), node_id()]))
	let_go(&"light_attack")
	_unwatch.call()
	out("events " + str(seen))
	out("== OMEGA special: hold heavy from f0")
	await reset_hero()
	seen = _combo_watch()
	await run(90, func(i: int) -> void:
		_cur = i
		if i == 0:
			hold(&"heavy_attack"),
		func(_i: int, _s: bool) -> void: pass)
	let_go(&"heavy_attack")
	_unwatch.call()
	out("events " + str(seen))


func _s_cast() -> void:
	for held in [false, true]:
		out("== CAST %s" % ("held 50 frames" if held else "tap"))
		await reset_hero()
		await step(200)
		var p := game.player
		var at := [-1, false]
		var cb := func(_a: Vector2, omega: bool) -> void:
			at[0] = _cur
			at[1] = omega
		p.cast_released.connect(cb)
		var last := [p.pos]
		await run(60, func(i: int) -> void:
			_cur = i
			pad.move = Vector2.RIGHT
			if i == 0:
				hold(&"cast")
			if not held and i == 1:
				let_go(&"cast")
			if held and i == 50:
				let_go(&"cast"),
			func(i: int, _s: bool) -> void:
				if i < 3 or i == 14 or i == 15 or i == 16 or i == 36 or i == 37:
					out("f%d speed=%.2f inv=%s" % [i, (p.pos - last[0]).length() * 60.0, p.invulnerable()])
				last[0] = p.pos)
		p.cast_released.disconnect(cb)
		out("circle released at f%d omega=%s" % [at[0], at[1]])


func _s_hitstop_buffer() -> void:
	out("== HIT STOP: a dodge pressed on a frozen frame (keyboard path latches it; the pad as the bot and touch use it)")
	for real in [true, false]:
		await reset_hero()
		dummy(game.player.pos + Vector2(2.0, 0), 15.0)
		await step(2)
		var dodge_at := [-1]
		var cb := func(_d: Vector2) -> void: dodge_at[0] = _cur
		game.player.dodged.connect(cb)
		var frozen: Array[int] = []
		await run(30, func(i: int) -> void:
			_cur = i
			if i == 0:
				tap(&"light_attack")
			if i == 6:
				if real:
					Controls.virtual = null
					Input.action_press(&"dodge")
				else:
					tap(&"dodge")
			if i == 7 and real:
				Input.action_release(&"dodge")
			if i == 14:
				Controls.virtual = pad,
			func(i: int, stepped: bool) -> void:
				if not stepped:
					frozen.append(i))
		Controls.virtual = pad
		game.player.dodged.disconnect(cb)
		out("%s: frozen frames %s, dodge pressed on f6, dodge starts %s" % ["keyboard" if real else "pad", str(frozen),
			("f%d" % dodge_at[0]) if dodge_at[0] >= 0 else "LOST"])


func _s_enemy_interrupt() -> void:
	out("== ENEMY hit during its windup: is the attack cut")
	await reset_hero()
	var p := game.player
	p.invuln = 999.0
	var e := dummy(p.pos + Vector2(2.2, 0))
	e.cooldown = 0.0
	var hit_at := [-1]
	var states: Array = []
	await run(120, func(i: int) -> void:
		_cur = i
		if hit_at[0] < 0 and e.state == Enemy.State.WINDUP and e.state_t > 0.15:
			tap(&"light_attack")
			hit_at[0] = i,
		func(i: int, _s: bool) -> void:
			var s: String = Enemy.State.keys()[e.state]
			if states.is_empty() or states[-1][0] != s:
				states.append([s, i])
			if hit_at[0] >= 0 and i <= hit_at[0] + 12:
				out("f%d e.state=%s state_t=%.2f hurt_t=%.2f anim=%s" % [i, s, e.state_t, e.hurt_t, e.anim]))
	out("tap at f%d; enemy states %s" % [hit_at[0], str(states)])
	p.invuln = 0.0


func _s_kill() -> void:
	out("== KILL a skeleton with cut1 (20 dmg on 15 hp): throw, time scale, hit stop")
	await reset_hero()
	var e := dummy(game.player.pos + Vector2(2.0, 0), 15.0)
	await step(2)
	await run(40, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"light_attack"),
		func(i: int, stepped: bool) -> void:
			if i < 14 or i % 8 == 0:
				out("f%d stepped=%s alive=%s push=%.1f vy=%.1f y=%.2f time_scale=%.2f stop=%.0fms" % [i, stepped, e.alive, e.push.length(), e.vy, e.y,
					Engine.time_scale, game.fx.stop_left * 1000.0]))
	out("== KILL 3 at once with cut3 (spin): slow motion")
	await reset_hero()
	var p := game.player
	for k in 3:
		dummy(p.pos + Vector2.from_angle(TAU * k / 3.0) * 1.6, 50.0)
	await step(2)
	await run(70, func(i: int) -> void:
		_cur = i
		if i == 0:
			game.player.runner.press(ComboNode.In.LIGHT)
			game.player.runner.set(&"phase", ComboRunner.Phase.WINDOW)
			game.player.runner.node = game.player.runner.tree.neutral[0].following()[0],
		func(i: int, stepped: bool) -> void:
			if Engine.time_scale < 0.999 or not stepped:
				out("f%d stepped=%s time_scale=%.2f zoom=%.2f" % [i, stepped, Engine.time_scale, game.fx.zoom]))


func _s_hurt() -> void:
	out("== HURT: a blow on the paladin; when can he act again (dodge and attack tapped every frame)")
	for act in [&"dodge", &"light_attack"]:
		await reset_hero()
		var p := game.player
		var seen := _combo_watch()
		var dodge_at := [-1]
		var cb := func(_d: Vector2) -> void: dodge_at[0] = _cur
		p.dodged.connect(cb)
		await run(40, func(i: int) -> void:
			_cur = i
			if i == 0:
				p.hurt(3.0, p.pos + Vector2.LEFT)
			elif i >= 1:
				tap(act),
			func(_i: int, _s: bool) -> void: pass)
		p.dodged.disconnect(cb)
		_unwatch.call()
		var st := seen.filter(func(x: Array) -> bool: return x[0] == "start")
		out("after a hurt at f0, %s every frame: dodge %s, attack %s" % [act, ("f%d" % dodge_at[0]) if dodge_at[0] >= 0 else "-", ("f%d" % st[0][2]) if st else "-"])


func _s_extra() -> void:
	out("== ATTACK right around the end of a dodge (dodge tapped f0)")
	for d in [11, 12, 13, 14, 15]:
		await reset_hero(Vector2(-8, 4))
		var seen := _combo_watch()
		var p := game.player
		var states: PackedStringArray = []
		await run(30, func(i: int) -> void:
			_cur = i
			pad.move = Vector2.RIGHT if i < 2 else Vector2.ZERO
			if i == 0:
				tap(&"dodge")
			if i == d:
				tap(&"light_attack"),
			func(i: int, _s: bool) -> void:
				if i >= 10 and i <= 15:
					states.append("%d:%s" % [i, Player.State.keys()[p.state]]))
		_unwatch.call()
		var st := seen.filter(func(x: Array) -> bool: return x[0] == "start")
		out("attack at f%d: %s  (%s)" % [d, ("%s@f%d" % [st[0][1], st[0][2]]) if st else "LOST", " ".join(states)])
	out("== DODGE tapped every frame from f1 after a cut3 starts (air): first dodge frame")
	await reset_hero()
	var at := [-1]
	var cb := func(_d: Vector2) -> void:
		if at[0] < 0:
			at[0] = _cur
	game.player.dodged.connect(cb)
	var seen := _combo_watch()
	game.player.runner.press(ComboNode.In.LIGHT)
	game.player.runner.phase = ComboRunner.Phase.WINDOW
	game.player.runner.node = game.player.runner.tree.neutral[0].following()[0]
	await run(40, func(i: int) -> void:
		_cur = i
		if i >= 1:
			tap(&"dodge"),
		func(_i: int, _s: bool) -> void: pass)
	game.player.dodged.disconnect(cb)
	_unwatch.call()
	out("cut3 events %s, first dodge f%d" % [str(seen), at[0]])
