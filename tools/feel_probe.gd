extends Node
## Game feel probe (measurement only, changes nothing in the game): plays scripted inputs through Controls.VirtualPad
## (and the real Input path where the hit stop matters) on the real game scene, one step per frame at 60 Hz, and
## prints what happened on which frame. docs/design/game_feel_measures.md reads its output.
## Run by tools/feel_probe_run.gd (about 5 s):
## ~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain
## Only some scenarios: PROBE=_s_dodge_cancel,_s_buffer before the command. Only the verdicts: | grep '^FEEL'.
##
## C12d acceptance (GF-14): every target below prints one line "FEEL ok <id> ..." or "FEEL falha <id> ...", with the
## target and the measured value; the run ends with "FEEL_SUMMARY n/m ok" and the ids that failed. Frame 0 is the
## frame the press is read. Targets come from docs/design/game_feel_measures.md and docs/backlog.md section 1a
## (GF-01 to GF-10, D-44 as Daniel decided it); the table with the reasons is docs/gallery/c12d/PROBE.md.
##   GF-02a dodge_in_windup     dodge tapped on any frame of a blow (cut1, bolt) starts on that frame, never LOST
##   GF-02b cut_blow_no_damage  a blow whose windup the dodge cut never lands after the dodge starts
##   GF-02c dodge_cuts_spin     dodge tapped every frame from f1 of the spin (cut3) starts on f1
##   GF-03a attack_in_dodge     attack tapped on f1..f13 of a dodge (dodge f0) becomes dash_cut on f13 or f14; later at once
##   GF-03b attack_at_dodge_end attack tapped on f11..f15 starts by max(tap, 14), never LOST
##   GF-03c attack_while_hurt   one attack (f3) or special (f5) tap while hurt (hurt f0) starts on f11 (10..12)
##   GF-04a buffer_cut1         second tap on any frame 1..36 of cut1: cut2 starts at max(tap, end of cut1)
##   GF-04b buffer_spin         tap on any frame 1..39 of the spin: the next cut1 starts at max(tap, end of the spin)
##   GF-06  pad_in_hit_stop     dodge tapped on f6 of a hit: the virtual pad starts it on the same frame as the keyboard
##   GF-01a hit_stop_shape_cut1 cut1 on a dummy: 0 frames with the world stopped (game time not moving), it keeps moving
##                              1+ frames after the hit (25 ms wait), then 1 to 3 frames at 6% or less (rate 0.1), then
##                              full speed within 2 frames (20 ms)
##   GF-01b no_freeze_combo     the 3-blow combo mashed on a dummy: 0 stopped frames
##   GF-01c hit_stop_shape_spin the spin on a dummy: as GF-01a with 3+ frames of wait (70 ms)
##   GF-01d hit_stop_shape_kill cut1 that kills: as GF-01a with 2 to 4 slow frames (10 + 40 ms)
##   GF-05  slow_mo_visible     3 kills with the spin: at most 3 stopped frames, then 5 or more moving frames at 0.15..0.25
##   GF-07a bolt_attack_lock    special then attack every frame: cut1 starts on f25 (24..26; 18 after the dart at f7)
##   GF-07b bolt_recharge       special then special every frame: the second bolt starts on f48 (47..49; 0.7 s)
##   GF-07c bolt_speed          the dart flies at 62.5 m/s (61.5..63.5)
##   GF-07d bolt_holds_legs     D-44 (3): after the special no walking on f1..f48 (0.71 s after the dart), walking by f53
##   GF-07e dodge_cuts_bolt     D-44 (3): a dodge tapped on f20 of the special starts on f20
##   GF-08  omega_when_full     holding attack: the lance lands on f48 (47..49; the charge is 0.8 s)
##   GF-09a turn_facing         facing within 5 degrees of the new direction by f1
##   GF-09b turn_body           drawn body within 5 degrees of its final yaw by f7 (8 frames, 1340 degrees/s)
##   GF-09c plant_on_press      no walking on the frame a blow or the special is pressed (walked 0:0.00)
##   GF-09d dodge_safety_19     the dodge protects 19 frames from the press (19..20)
##   GF-10a kick_cut1           camera kick of cut1 at most 0.1 m
##   GF-10b shake_cut1          camera shake of cut1 at most 0.1 m
##   GF-10c flash_cut1          enemy flash of cut1 0.05 s (0.03..0.055)
##   D-44a  dodge_frame_0       a dodge from rest starts on the press frame (ours, kept by D-44 (1))
##   D-44b  cast_no_safety      no protection after the circle is released (D-44 (2))
##   D-44c  cast_attack_lock    attack tapped every frame from the release starts 8 frames or more after it (D-44 (2))
##   ALL    no_lost_press       no line of the run says LOST
## Not in the probe: GF-11 (sound, a GUT test of Audio and a video), GF-12 (enemy flinch, C12f; the ENEMY scenario
## only prints), GF-13 (latency on the GPU), the omega special table of GF-09 (a document).

var game: Game
## FEEL verdicts of this run: [ok, id, text].
var results: Array = []
var lost_lines := 0
## Game seconds the last frame of run() moved, times 60 (1.0 = full speed, 0 = stopped).
var last_rate := 1.0
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
		if OS.get_environment("PROBE") == "":
			meta("ALL", "no_lost_press", "0 lines with LOST", "%d" % lost_lines, lost_lines == 0)
		_summary()
		print("PROBE DONE")
		# exit code 1 when a target failed, so a script can use the probe as a gate
		get_tree().quit(0 if results.all(func(r: Array) -> bool: return r[0]) else 1)
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
	if s.contains("LOST"):
		lost_lines += 1
	print(s)


## One C12d target: prints "FEEL ok|falha <id> <name> | alvo: ... | medido: ...".
func meta(id: String, name: String, target: String, value: String, ok: bool) -> void:
	var line := "FEEL %s %s %s | alvo: %s | medido: %s" % ["ok" if ok else "falha", id, name, target, value]
	results.append([ok, id, name, target, value])
	print(line)


func _summary() -> void:
	var n := results.filter(func(r: Array) -> bool: return r[0]).size()
	print("FEEL_SUMMARY %d/%d ok" % [n, results.size()])
	for r in results:
		if not r[0]:
			print("FEEL_FAIL %s %s (medido: %s)" % [r[1], r[2], r[4]])


## How a hit stop played after a hit on frame h, from the game-time rate of each frame (rates[i], 1 = full speed):
## stopped frames, first slow frame (rate 0.1 or less), slow frames, first full-speed frame after the slow.
static func stop_shape(rates: Array, h: int, span := 20) -> Dictionary:
	var d := {frozen = 0, first_slow = -1, slow = 0, back = -1}
	for i in range(h + 1, mini(h + 1 + span, rates.size())):
		var r: float = rates[i]
		if r <= 0.0001:
			d.frozen += 1
		if r <= 0.1:
			d.slow += 1
			if d.first_slow < 0:
				d.first_slow = i
		elif d.first_slow >= 0 and d.back < 0 and r >= 0.9:
			d.back = i
	return d


## The GF-01 shape check: world moves during the wait (at least min_wait frames), slow frames in [lo, hi], back to
## full speed within 2 frames of the slow ending.
func check_shape(id: String, name: String, rates: Array, h: int, min_wait: int, lo: int, hi: int) -> void:
	var s := stop_shape(rates, h)
	var wait: int = (s.first_slow - h - 1) if s.first_slow >= 0 else -1
	var ok: bool = s.frozen == 0 and s.first_slow >= 0 and wait >= min_wait and s.slow >= lo and s.slow <= hi \
		and s.back >= 0 and s.back - (s.first_slow + s.slow) <= 2
	var rs: PackedStringArray = []
	for i in range(h, mini(h + 10, rates.size())):
		rs.append("%.2f" % float(rates[i]))
	meta(id, name, "0 parados, mundo anda %d+ quadros, %d a %d quadros a 6%%, volta em 2" % [min_wait, lo, hi],
		"parados %d, espera %d, lentos %d, volta f%d (ritmo desde o acerto f%d: %s)" % [s.frozen, wait, s.slow, s.back, h, " ".join(rs)], ok)


## Runs n frames calling f(i) before each one (i = 0 on the frame the first input is read); f returns nothing.
## After each frame `probe(i)` records the state that frame left.
func run(n: int, f: Callable, probe: Callable) -> void:
	for i in n:
		f.call(i)
		var t0 := game.time
		await get_tree().process_frame
		last_rate = (game.time - t0) * 60.0
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
	var facing: Array[float] = []
	var body: Array[float] = []
	await run(10, func(_i: int) -> void: pad.move = Vector2.RIGHT, func(_i: int, _s: bool) -> void: pass)
	await run(24, func(_i: int) -> void: pad.move = Vector2.LEFT,
		func(i: int, _s: bool) -> void:
			var model := p.get(&"_model") as Node3D
			facing.append(p.facing.angle())
			body.append(model.rotation.y)
			if i < 12:
				out("f%d facing=%.0f deg model=%.0f deg" % [i, rad_to_deg(p.facing.angle()), rad_to_deg(atan2(sin(model.rotation.y), cos(model.rotation.y)))]))
	var near := func(list: Array[float]) -> int:
		for i in list.size():
			if absf(rad_to_deg(angle_difference(list[i], list[-1]))) <= 5.0:
				return i
		return -1
	var f: int = near.call(facing)
	var b: int = near.call(body)
	meta("GF-09a", "turn_facing", "direcao a 5 graus da nova ate f1", "f%d" % f, f >= 0 and f <= 1)
	meta("GF-09b", "turn_body", "corpo a 5 graus do final ate f7 (8 quadros)", "f%d" % b, b >= 0 and b <= 7)


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
	var rates: Array = []
	var peak := {kick = 0.0, shake = 0.0, flash = 0.0}
	await run(30, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"light_attack"),
		func(i: int, stepped: bool) -> void:
			rates.append(last_rate)
			var kick: Vector3 = game.fx.get(&"_kick")
			peak.kick = maxf(peak.kick, kick.length())
			peak.shake = maxf(peak.shake, float(game.fx.get(&"_shake")))
			if e.flash_t > 0.0:
				peak.flash += 1.0
			out("f%d stepped=%s stop_left=%.0fms flash_t=%.2f hurt_t=%.2f push=%.2f moved=%.2f kick=%.3fm shake=%.3fm e.state=%s phase=%s" % [i, stepped,
				game.fx.stop_left * 1000.0, e.flash_t, e.hurt_t, e.push.length(), e.pos.distance_to(p0), kick.length(), float(game.fx.get(&"_shake")),
				Enemy.State.keys()[e.state], phase_name()]))
	_unwatch.call()
	out("events " + str(seen))
	var h := _first(seen, "hit", "cut1")
	check_shape("GF-01a", "hit_stop_shape_cut1", rates, h, 1, 1, 3)
	meta("GF-10a", "kick_cut1", "tranco do golpe 1 ate 0,10 m", "%.3f m" % peak.kick, peak.kick <= 0.1)
	meta("GF-10b", "shake_cut1", "tremor do golpe 1 ate 0,10 m", "%.3f m" % peak.shake, peak.shake <= 0.1)
	meta("GF-10c", "flash_cut1", "clarao do inimigo 0,05 s (2 a 4 quadros)", "%d quadros (%.2f s)" % [int(peak.flash), peak.flash / 60.0],
		peak.flash >= 2.0 and peak.flash <= 4.0)


## Frame of the first event of this kind and move, or -1.
func _first(seen: Array, kind: String, id: String) -> int:
	for x in seen:
		if x[0] == kind and x[1] == id:
			return x[2]
	return -1


func _s_combo_mash() -> void:
	for with_dummy in [false, true]:
		out("== COMBO mash (a tap every other frame) %s" % ("on a dummy" if with_dummy else "in the air"))
		await reset_hero()
		if with_dummy:
			dummy(game.player.pos + Vector2(2.0, 0))
			await step(2)
		var seen := _combo_watch()
		var frozen := [0]
		var rates: Array = []
		await run(110, func(i: int) -> void:
			_cur = i
			if i % 2 == 0 and i < 80:
				tap(&"light_attack"),
			func(_i: int, stepped: bool) -> void:
				rates.append(last_rate)
				if not stepped:
					frozen[0] += 1)
		_unwatch.call()
		out("events " + str(seen) + " frozen_frames=%d" % frozen[0])
		if with_dummy:
			meta("GF-01b", "no_freeze_combo", "0 quadros parados no combo de 3 sobre um alvo", "%d" % frozen[0], frozen[0] == 0)
			check_shape("GF-01c", "hit_stop_shape_spin", rates, _first(seen, "hit", "cut3"), 3, 1, 3)


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
	var bad: PackedStringArray = []
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
		var want: int = maxi(d, e1[0][2] if e1 else 12)
		if not c2 or c2[0][2] < want or c2[0][2] > want + 1:
			bad.append("d%d:%s" % [d, ("f%d" % c2[0][2]) if c2 else "LOST"])
	meta("GF-04a", "buffer_cut1", "2o aperto em qualquer quadro 1 a 36 do golpe 1: golpe 2 em max(aperto, fim do golpe 1)",
		"todos" if bad.is_empty() else "fora: " + " ".join(bad), bad.is_empty())
	bad.clear()
	out("== BUFFER: tap during cut3's windup and recovery (air), from the cut2 hit")
	for d in [1, 3, 6, 10, 15, 20, 26, 30, 31, 32, 34, 36, 39, 40]:
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
		var c3 := _first(seen, "start", "cut3")
		var e3 := -1
		var next := -1
		for x in seen:
			if x[0] == "end" and x[1] == "cut3" and e3 < 0:
				e3 = x[2]
			if x[0] == "start" and x[1] == "cut1" and c3 >= 0 and x[2] > c3 and next < 0:
				next = x[2]
		var want := maxi(e3, c3 + d)
		if c3 < 0 or e3 < 0 or next < want or next > want + 1:
			bad.append("d%d:%s" % [d, ("f%d" % next) if next >= 0 else "LOST"])
	meta("GF-04b", "buffer_spin", "aperto em qualquer quadro 1 a 39 do giro: golpe 1 em max(aperto, fim do giro)",
		"todos" if bad.is_empty() else "fora: " + " ".join(bad), bad.is_empty())


func _s_dodge() -> void:
	out("== DODGE right from rest: state, safety, distance, when the next one is allowed")
	await reset_hero(Vector2(-8, 4))
	var p := game.player
	var x0 := p.pos.x
	var dodged := [0]
	var inv := [0, true]
	p.dodged.connect(func(_d: Vector2) -> void: dodged[0] += 1)
	await run(70, func(i: int) -> void:
		pad.move = Vector2.RIGHT if i < 30 else Vector2.ZERO
		if i >= 1:
			tap(&"dodge"),
		func(i: int, _s: bool) -> void:
			# protected frames counted from the press (f1) until the first unprotected one
			if i >= 1 and inv[1]:
				if p.invulnerable():
					inv[0] += 1
				else:
					inv[1] = false
			if i < 24 or i % 5 == 0:
				out("f%d state=%s inv=%s x=%.2f charges=%d dodges=%d" % [i, Player.State.keys()[p.state], p.invulnerable(), p.pos.x - x0, p.dodge_charges, dodged[0]]))
	meta("GF-09d", "dodge_safety_19", "protecao de 19 a 20 quadros desde o aperto", "%d" % inv[0], inv[0] >= 19 and inv[0] <= 20)
	out("== DODGE alone (no move held): distance")
	await reset_hero(Vector2(-8, 4))
	x0 = game.player.pos.x
	var at := [-1]
	game.player.dodged.connect(func(_d: Vector2) -> void:
		if at[0] < 0:
			at[0] = _cur, CONNECT_ONE_SHOT)
	await run(30, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"dodge"),
		func(_i: int, _s: bool) -> void: pass)
	out("dodge distance standing (facing right): %.2f m" % (game.player.pos.x - x0))
	meta("D-44a", "dodge_frame_0", "esquiva parada sai no quadro do aperto (f0)", "f%d" % at[0], at[0] == 0)


func _s_dodge_cancel() -> void:
	out("== DODGE pressed d frames after an attack tap (air): frame it starts or LOST")
	var late: PackedStringArray = []
	var landed: PackedStringArray = []
	for move_id in [&"light_attack", &"heavy_attack"]:
		for d in [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 14, 20, 30, 40]:
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
			var tag := "%s:d%d" % ["cut1" if move_id == &"light_attack" else "bolt", d]
			if at[0] < d or at[0] > d + 1:
				late.append("%s=%s" % [tag, ("f%d" % at[0]) if at[0] >= 0 else "LOST"])
			elif hit and hit[0][2] > at[0]:
				landed.append("%s=acerto f%d" % [tag, hit[0][2]])
	meta("GF-02a", "dodge_in_windup", "esquiva apertada em qualquer quadro do golpe 1 ou da seta sai no quadro (ou no seguinte)",
		"todos" if late.is_empty() else "fora: " + " ".join(late), late.is_empty())
	meta("GF-02b", "cut_blow_no_damage", "golpe cortado pela esquiva nao acerta depois que ela sai",
		"nenhum" if landed.is_empty() else " ".join(landed), landed.is_empty())


func _s_attack_in_dodge() -> void:
	out("== ATTACK tapped d frames after a dodge tap: what starts and when")
	var bad: PackedStringArray = []
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
		var good := false
		if st:
			var f: int = st[0][2]
			good = (st[0][1] == "dash_cut" and f >= 13 and f <= 14) if d <= 13 else (f >= d and f <= d + 1)
		if not good:
			bad.append("d%d:%s" % [d, ("%s@f%d" % [st[0][1], st[0][2]]) if st else "LOST"])
	meta("GF-03a", "attack_in_dodge", "ataque nos quadros 1 a 13 da esquiva vira dash_cut no 13 ou 14; depois, na hora",
		"todos" if bad.is_empty() else "fora: " + " ".join(bad), bad.is_empty())


func _s_walk_cancel() -> void:
	out("== WALK during an attack (move held down-screen from the tap): meters walked each frame")
	var walked := {}
	for id in [&"cut1", &"cut3", &"bolt"]:
		await reset_hero()
		var p := game.player
		var last := [p.pos]
		var steps: PackedStringArray = []
		var dist: Array[float] = []
		walked[id] = dist
		var seen := _combo_watch()
		var taps: Array = [0] if id != &"cut3" else [0, 12, 32]
		await run(80, func(i: int) -> void:
			_cur = i
			pad.move = Vector2.DOWN if (id != &"cut3" or i >= 32) else Vector2.ZERO
			if taps.has(i):
				tap(&"light_attack" if id != &"bolt" else &"heavy_attack"),
			func(i: int, _s: bool) -> void:
				var d: float = (p.pos - last[0]).dot(Vector2.DOWN)
				dist.append(d)
				if i <= 60:
					steps.append("%d:%.2f" % [i, d])
				last[0] = p.pos)
		_unwatch.call()
		out("%s events %s" % [id, str(seen)])
		out("  walked " + " ".join(steps))
	var cut1: Array[float] = walked[&"cut1"]
	var bolt: Array[float] = walked[&"bolt"]
	meta("GF-09c", "plant_on_press", "0,00 m andados no quadro do aperto (golpe 1 e seta)", "golpe 1 %.2f, seta %.2f" % [cut1[0], bolt[0]],
		cut1[0] < 0.005 and bolt[0] < 0.005)
	var moved_in_hold := -1
	for i in range(1, 49):
		if bolt[i] > 0.005 and moved_in_hold < 0:
			moved_in_hold = i
	var walks_again := -1
	for i in range(49, 54):
		if bolt[i] > 0.005 and walks_again < 0:
			walks_again = i
	meta("GF-07d", "bolt_holds_legs", "D-44: parado de f1 a f48 depois da seta (0,71 s depois do dardo), anda de novo ate f53",
		"%s, anda de novo %s" % [("anda em f%d" % moved_in_hold) if moved_in_hold >= 0 else "parado", ("f%d" % walks_again) if walks_again >= 0 else "depois de f53"],
		moved_in_hold < 0 and walks_again >= 0)


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
		var bolt0 := _first(seen, "start", "bolt")
		var nxt := -1
		for x in seen:
			if x[0] == "start" and x[2] > bolt0 and nxt < 0:
				nxt = x[2]
		if follow == &"light_attack":
			meta("GF-07a", "bolt_attack_lock", "golpe 1 sai em f25 (24 a 26) com o ataque apertado todo quadro", ("f%d" % nxt) if nxt >= 0 else "nunca",
				nxt >= 24 and nxt <= 26)
		else:
			meta("GF-07b", "bolt_recharge", "2a seta sai em f48 (47 a 49) com o especial apertado todo quadro", ("f%d" % nxt) if nxt >= 0 else "nunca",
				nxt >= 47 and nxt <= 49)
	out("== SPECIAL: dart speed, and a dodge on f20 (move held)")
	await reset_hero()
	var speed := [0.0]
	var at := [-1]
	var cb := func(_d: Vector2) -> void:
		if at[0] < 0:
			at[0] = _cur
	game.player.dodged.connect(cb)
	await run(30, func(i: int) -> void:
		_cur = i
		pad.move = Vector2.DOWN
		if i == 0:
			tap(&"heavy_attack")
		if i == 20:
			tap(&"dodge"),
		func(_i: int, _s: bool) -> void:
			for shot in game.projectiles.shots:
				if shot.kind == Projectiles.Kind.SPARK:
					speed[0] = maxf(speed[0], shot.vel.length()))
	game.player.dodged.disconnect(cb)
	out("dart %.1f m/s, dodge on f20 starts %s" % [speed[0], ("f%d" % at[0]) if at[0] >= 0 else "LOST"])
	meta("GF-07c", "bolt_speed", "dardo a 62,5 m/s (61,5 a 63,5)", "%.1f m/s" % speed[0], absf(speed[0] - 62.5) <= 1.0)
	meta("GF-07e", "dodge_cuts_bolt", "D-44: esquiva apertada em f20 da seta sai em f20", ("f%d" % at[0]) if at[0] >= 0 else "LOST", at[0] == 20)


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
	var lance := _first(seen, "hit", "lance")
	meta("GF-08", "omega_when_full", "lanca acerta em f48 (47 a 49; carga de 0,8 s)", ("f%d" % lance) if lance >= 0 else "nunca", lance >= 47 and lance <= 49)
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
	var safe: PackedStringArray = []
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
				if at[0] >= 0 and p.invulnerable():
					safe.append("%s f%d" % ["omega" if held else "toque", i])
				if i < 3 or i == 14 or i == 15 or i == 16 or i == 36 or i == 37:
					out("f%d speed=%.2f inv=%s" % [i, (p.pos - last[0]).length() * 60.0, p.invulnerable()])
				last[0] = p.pos)
		p.cast_released.disconnect(cb)
		out("circle released at f%d omega=%s" % [at[0], at[1]])
	meta("D-44b", "cast_no_safety", "D-44: nenhum quadro protegido depois de soltar o circulo",
		"nenhum" if safe.is_empty() else "%d quadros (%s ... %s)" % [safe.size(), safe[0], safe[-1]], safe.is_empty())
	out("== CAST tap, then attack tapped every frame from the release")
	await reset_hero()
	await step(200)
	var seen := _combo_watch()
	var rel := [-1]
	var cb2 := func(_a: Vector2, _o: bool) -> void: rel[0] = _cur
	game.player.cast_released.connect(cb2)
	await run(50, func(i: int) -> void:
		_cur = i
		if i == 0:
			hold(&"cast")
		if i == 1:
			let_go(&"cast")
		if rel[0] >= 0:
			tap(&"light_attack"),
		func(_i: int, _s: bool) -> void: pass)
	game.player.cast_released.disconnect(cb2)
	_unwatch.call()
	var first := -1
	for x in seen:
		if x[0] == "start" and first < 0:
			first = x[2]
	out("circle released at f%d, first blow %s" % [rel[0], ("f%d" % first) if first >= 0 else "never"])
	meta("D-44c", "cast_attack_lock", "D-44: golpe so 8 quadros ou mais depois de soltar o circulo",
		("%d quadros depois" % (first - rel[0])) if first >= 0 and rel[0] >= 0 else "sem golpe", rel[0] >= 0 and first - rel[0] >= 8)


func _s_hitstop_buffer() -> void:
	out("== HIT STOP: a dodge pressed on a frozen frame (keyboard path latches it; the pad as the bot and touch use it)")
	var starts := {}
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
		starts[real] = dodge_at[0]
		out("%s: frozen frames %s, dodge pressed on f6, dodge starts %s" % ["keyboard" if real else "pad", str(frozen),
			("f%d" % dodge_at[0]) if dodge_at[0] >= 0 else "LOST"])

	var fmt := func(f: int) -> String: return ("f%d" % f) if f >= 0 else "LOST"
	meta("GF-06", "pad_in_hit_stop", "esquiva apertada em f6 de um acerto: controle virtual igual ao teclado, nenhum LOST",
		"teclado %s, controle virtual %s" % [fmt.call(starts[true]), fmt.call(starts[false])], starts[true] >= 0 and starts[false] == starts[true])


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
	var seen := _combo_watch()
	var rates: Array = []
	await run(40, func(i: int) -> void:
		_cur = i
		if i == 0:
			tap(&"light_attack"),
		func(i: int, stepped: bool) -> void:
			rates.append(last_rate)
			if i < 14 or i % 8 == 0:
				out("f%d stepped=%s rate=%.2f alive=%s push=%.1f vy=%.1f y=%.2f time_scale=%.2f stop=%.0fms" % [i, stepped, last_rate, e.alive, e.push.length(), e.vy, e.y,
					Engine.time_scale, game.fx.stop_left * 1000.0]))
	_unwatch.call()
	check_shape("GF-01d", "hit_stop_shape_kill", rates, _first(seen, "hit", "cut1"), 1, 2, 4)
	out("== KILL 3 at once with cut3 (spin): slow motion")
	await reset_hero()
	var p := game.player
	for k in 3:
		dummy(p.pos + Vector2.from_angle(TAU * k / 3.0) * 1.6, 50.0)
	await step(2)
	var count := {stopped = 0, slow = 0}
	await run(90, func(i: int) -> void:
		_cur = i
		if i == 0:
			game.player.runner.press(ComboNode.In.LIGHT)
			game.player.runner.set(&"phase", ComboRunner.Phase.WINDOW)
			game.player.runner.node = game.player.runner.tree.neutral[0].following()[0],
		func(i: int, stepped: bool) -> void:
			if not stepped:
				count.stopped += 1
			elif last_rate >= 0.15 and last_rate <= 0.25:
				count.slow += 1
			if Engine.time_scale < 0.999 or not stepped:
				out("f%d stepped=%s rate=%.2f time_scale=%.2f zoom=%.2f" % [i, stepped, last_rate, Engine.time_scale, game.fx.zoom]))
	meta("GF-05", "slow_mo_visible", "3 abates: ate 3 quadros parados, depois 5 ou mais quadros andando a 0,15 a 0,25",
		"parados %d, andando lento %d" % [count.stopped, count.slow], count.stopped <= 3 and count.slow >= 5)


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
	out("== HURT: one tap while hurt (attack on f3, special on f5): is it kept")
	var got: PackedStringArray = []
	var good := true
	for one in [[&"light_attack", 3], [&"heavy_attack", 5]]:
		await reset_hero()
		var p := game.player
		var seen := _combo_watch()
		await run(30, func(i: int) -> void:
			_cur = i
			if i == 0:
				p.hurt(3.0, p.pos + Vector2.LEFT)
			elif i == one[1]:
				tap(one[0]),
			func(_i: int, _s: bool) -> void: pass)
		_unwatch.call()
		var st := seen.filter(func(x: Array) -> bool: return x[0] == "start")
		var txt: String = ("%s@f%d" % [st[0][1], st[0][2]]) if st else "LOST"
		out("after a hurt at f0, %s tapped once on f%d: %s" % [one[0], one[1], txt])
		got.append("%s f%d -> %s" % [one[0], one[1], txt])
		if not st or st[0][2] < 10 or st[0][2] > 12:
			good = false
	meta("GF-03c", "attack_while_hurt", "um toque de ataque (f3) ou especial (f5) ferido sai em f11 (10 a 12)", ", ".join(got), good)


func _s_extra() -> void:
	out("== ATTACK right around the end of a dodge (dodge tapped f0)")
	var bad: PackedStringArray = []
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
		if not st or st[0][2] > maxi(d, 14):
			bad.append("d%d:%s" % [d, ("f%d" % st[0][2]) if st else "LOST"])
	meta("GF-03b", "attack_at_dodge_end", "ataque nos quadros 11 a 15 da esquiva sai ate max(aperto, 14)",
		"todos" if bad.is_empty() else "fora: " + " ".join(bad), bad.is_empty())
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
	meta("GF-02c", "dodge_cuts_spin", "esquiva apertada todo quadro desde f1 do giro sai em f1", "f%d" % at[0], at[0] == 1)
