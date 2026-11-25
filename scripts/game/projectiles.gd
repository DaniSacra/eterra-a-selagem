class_name Projectiles
extends Node3D
## Everything that flies: enemy bolts and Morvath's dark orbs (hurt the paladin), the Onda de Luz and the blades of
## the light gifts (hurt enemies, pass through them). Positions are (x, z) on the floor; they fly at a fixed height.

signal hit_player(amount: float, from: Vector2)
## A hostile shot was fired or died on stone (RoomTally.SHOT_*), by its shooter (shooter()), on piece (blocked_by).
signal shot_logged(by: String, what: String, piece: String)
## A friendly shot touched an enemy: the game decides the damage and the gifts that apply.
signal shot_hit(e: Enemy, shot: Shot)
## A hostile shot with a status (Shot.status, the boss's curse) struck the paladin while he could be hurt.
signal status_player(status: StringName)
## A wave of the paladin undid a curse of the boss at `at` (BossDef.curse_cut).
signal curse_cut_at(at: Vector2)
## Set by the boss fight: the paladin's waves undo his curse.
var curse_cut := false

## SPARK: the paladin's Seta de Luz (the special), drawn as the Guerreiro's blade wave (W-1, D-69): a short thin
## crescent of the Emeth's emerald flying flat. WAVE: its held version, the same wave as wide as it hits. SOUL: a boss's
## spectral crescent, wide across its flight, that goes on after it strikes (each one hurts the paladin once). CURSE: a
## boss's bolt that follows the paladin a little and curses him.
enum Kind { BOLT, ORB, WAVE, BLADE, SPARK, SOUL, CURSE }

## Meters a crescent (SOUL) reaches along its flight, before and behind its middle line.
const SOUL_DEPTH := 0.45
## Height of the crescents over the floor (they read on the floor, like the warnings they follow).
const SOUL_HEIGHT := 0.55
## Height of a shot that creeps along the floor (Shot.low).
const LOW_HEIGHT := 0.3

## The special's wave (emeth_wave.gdshader; W-1, decision D-69): only its look, the hit stays the circle of Shot.radius
## (the special 0.7 m, its held version 4.125 m) flying at SPARK_SPEED (the held one 22 m/s).
const WAVE_SHADER := preload("res://assets/shaders/emeth_wave.gdshader")
## The special: meters across from point to point (a little over its hit, 1.4 m), its bow ahead of the points, the
## band's thickness and the wake behind it at its longest.
const WAVE_SPAN := 1.6
const WAVE_BOW := 0.38
const WAVE_THICK := 0.2
const WAVE_WAKE := 0.9
## The held one: as wide as it hits (2 x Shot.radius), its bow, band and wake in proportion but thicker.
const OMEGA_BOW := 0.24
const OMEGA_THICK := 0.4
const OMEGA_WAKE := 1.4
## Brightest channel the wave writes (linear, under Game.GLOW_THRESHOLD 1.3) and its gold thread's share of it.
const WAVE_PEAK := 1.0
const WAVE_PATH_TIME := 0.4
const WAVE_PATH_REACH := 9.0
const WAVE_PATH_WIDTH := Vector2(Fx.WAVE_BAND_MIN, 2.4)
## How far the leading edge goes toward white (emeth_wave.gdshader edge_pale; vfx_pass_spec.md V-06: 0.5, it was 0.35).
const WAVE_EDGE_PALE := 0.5
const WAVE_GOLD := Color(0.95, 0.72, 0.3)
const WAVE_GOLD_LIGHT := 0.85
## Seconds the wave fades over at the end of its flight (the special flies 0.18 s, the held one 0.5 s).
const WAVE_FADE := Vector2(0.04, 0.12)
## The body's share of the peak and the dark ink behind it (emeth_wave.gdshader's body_light, ink).
## V-06: 0.75 (it was 0.55: ten metres out the wave's core read at 92 of the screen and nearly vanished).
const WAVE_BODY_LIGHT := 0.75
const WAVE_INK := 0.3
## A Gift's wave (bolden): its band (meters; the held special's is OMEGA_THICK), body, ink and fade (seconds).
const GIFT_THICK := 0.62
const GIFT_BODY_LIGHT := 0.78
const GIFT_INK := 0.5
const GIFT_FADE := 0.06
const HEIGHT := 1.1
## Enemy shots (bolts, orbs, the curse): their ball and halo (cycle 10, BUG-006), and the halo's radius as a share of
## the ball's (at most 1.5: a crowd of sorcerers never fills the air with light).
const ORB_SHADER := preload("res://assets/shaders/enemy_orb.gdshader")
const HALO_SHADER := preload("res://assets/shaders/enemy_orb_halo.gdshader")
const HALO := 1.5
## The special flies at the speed of Hades II's special (ProjectileStaffBall, 5000 units: 62.5 m/s; GF-07).
const SPARK_SPEED := 5000.0 / 80.0
const LOOK := {
	Kind.BOLT: [Color(3.0, 0.5, 0.3), 0.18, 0.6], Kind.ORB: [Color(1.6, 0.4, 2.8), 0.45, 0.45],
	Kind.WAVE: [Color(3.0, 2.4, 1.2), 0.0, 0.0], Kind.BLADE: [Color(2.8, 2.4, 1.4), 0.0, 0.0],
	Kind.SPARK: [Color(0.3, 1.0, 0.45), 0.0, 0.0], Kind.SOUL: [Boss.SOUL_VIOLET, 0.0, 0.0],
	Kind.CURSE: [Color(1.0, 0.22, 1.5), 0.42, 0.42],
}

class Shot:
	var kind := Kind.BOLT
	## How many smoke puffs its trail has left (Projectiles._trail).
	var trail := 0
	var pos := Vector2.ZERO
	var vel := Vector2.ZERO
	var damage := 0.0
	var radius := 0.4
	var life := 3.0
	var knockback := 0.0
	var color := Color.WHITE
	var tags: Array[StringName] = []
	var status: StringName = &""
	var status_power := 0.0
	## Enemies already hit (piercing shots hit each one once).
	var seen: Dictionary = {}
	var node: Node3D
	## Meters flown (only for the look: the wave's wake grows as it leaves the blade).
	var flown := 0.0
	## A crescent (SOUL): half its width across the flight.
	var half_width := 0.0
	## Seconds it still turns after the paladin, and how fast (radians a second).
	var homing := 0.0
	var turn := 0.0
	## How fast that turning fades (radians a second, each second): the vines stop following after a while.
	var turn_decay := 0.0
	## It creeps along the floor (an enemy's vine) instead of flying at chest height.
	var low := false
	## Which attack fired it (a boss's attack id; the hurt_by count of the fight).
	var source: StringName = &""
	## Which kind of enemy fired it (EnemyDef.id, Horde.acting; &"": none, as the boss's own): "Derrotado por".
	var by: StringName = &""
	## Seconds it has flown (the crescent's look: its first flare, its fade at the end).
	var age := 0.0
	## Seconds its shooter's warning showed before it left (the aim held; the run's log, warn_s).
	var warned := 0.0
	## Its shooter was off the screen as it fired (1), on it (0), unknown (-1) (Horde.screen_flag).
	var offscreen := -1
	## The paladin's wave already counted as its blow landing (Combat.landed: once a shot; a Gift's wave from a blow
	## that counted itself).
	var counted := false
	## The hit stop its contact gives (ms of wait, 0: none; Combat.shot_stop_ms) and whether it already did.
	var stop_ms := 0.0
	var stopped := false
	## The paladin's wave goes through stone (Onda Atravessante, the stat wave_through).
	var through := false
	## The paladin's shot ends at the first enemy it touches (the Maga's: the others pass through).
	var stops := false
	## Held in the air (the Suspensão Arcana): it neither flies nor hurts until Arcane lets it go.
	var frozen := false
	## A Gift's wave drawn bolder (bolden): its own fade at the end.
	var bold := false
	## C1e, lote B (the Lançador's axe, ThrowRules): seconds into its flight when it turns and flies back along the same line (0: it does
	## not), where it left from, whether the line of its way back is shown yet.
	var back_at := 0.0
	var origin := Vector2.ZERO
	var back_warned := false

## How far a shot is from the stone when it dies on it (meters; its ball is about this round).
const SHOT_EDGE := 0.15
## A shot flying this far past the room's floor is gone.
const SHOT_MARGIN := 12.0

var shots: Array[Shot] = []
## Shots that died on cover (RESULT shots_blocked).
var blocked := 0
## The source of the shot that hurt the paladin last (Shot.source), read by the game as hit_player is emitted.
var last_source: StringName = &""
## Which kind of enemy fired it (Shot.by).
var last_by: StringName = &""
## That shot's warning in seconds (its shooter's aim and its flight) and Shot.offscreen, for the run's log.
var last_warn := -1.0
var last_offscreen := -1
## DT-102 (RESULT shot_flight): by shooter (shooter_of), the seconds each shot that reached the paladin flew:
## id -> [hits, total seconds, longest].
var flights := {}
var horde: Horde
var player: Player
var fx: Fx
## The Abrigo's shelters (E4, Psalms.bars): called with (where, radius), true where an enemy shot is undone (never a
## boss's crescent, which the stone does not stop either). Unset: none.
var shelter: Callable
var _pools: Dictionary = {}
var _orb_mats: Dictionary = {}
var _found: Array[Enemy] = []


## color: the shooter's magic (EnemyDef.magic_color) for bolts and orbs; alpha 0 keeps the kind's own look.
func fire(kind: Kind, from: Vector2, dir: Vector2, speed: float, damage: float, radius: float = 0.4, life: float = 3.0, color := Color(0, 0, 0, 0)) -> Shot:
	var s := Shot.new()
	s.kind = kind
	s.pos = from
	s.vel = dir.normalized() * speed
	s.damage = damage
	s.radius = radius
	s.life = life
	s.by = horde.acting if horde else &""
	if hostile(s):
		s.offscreen = horde.screen_flag(from) if horde else -1
		shot_logged.emit(shooter(s), RoomTally.SHOT_FIRED, "")
	s.node = _take(kind)
	s.node.visible = true
	s.trail = 0
	if kind == Kind.BOLT or kind == Kind.ORB or kind == Kind.CURSE:
		_tint(s.node, color if color.a > 0.0 else (LOOK[kind] as Array)[0])
	_place(s)
	shots.append(s)
	return s


## A friendly crescent (the Onda de Luz, the light blades) that flies distance meters through the crowd.
func fire_wave(kind: Kind, from: Vector2, dir: Vector2, damage: float, distance: float, size: float, color: Color, tags: Array[StringName]) -> Shot:
	var speed: float = SPARK_SPEED if kind == Kind.SPARK else 22.0 if kind == Kind.WAVE else 19.0
	var s := fire(kind, from, dir, speed, damage, size * 0.5, distance / speed)
	s.color = color
	s.tags = tags
	s.knockback = 10.0
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	mat.set_shader_parameter(&"color", color)
	if kind == Kind.BLADE:
		s.node.scale = Vector3.ONE * size
		return s
	_light_path(from, dir, distance, size, color)
	# the blade wave, flat, its bow along the flight (emeth_wave.gdshader)
	var omega := kind == Kind.WAVE
	mat.set_shader_parameter(&"span_m", s.radius * 2.0 if omega else WAVE_SPAN)
	mat.set_shader_parameter(&"bow_m", s.radius * 2.0 * OMEGA_BOW if omega else WAVE_BOW)
	mat.set_shader_parameter(&"thick_m", OMEGA_THICK if omega else WAVE_THICK)
	mat.set_shader_parameter(&"wake_m", OMEGA_WAKE if omega else WAVE_WAKE)
	mat.set_shader_parameter(&"flown", 0.0)
	mat.set_shader_parameter(&"fade", 1.0)
	mat.set_shader_parameter(&"peak", wave_peak(color))
	mat.set_shader_parameter(&"body_light", WAVE_BODY_LIGHT)
	mat.set_shader_parameter(&"ink", WAVE_INK)
	return s


## The wave flies at 22 to 62 m/s (under two frames at 30 fps), so what it draws as it goes is gone before a capture
## or a slow eye catches it: it leaves its path lit for WAVE_PATH_TIME s, a broad beam along the flight (Fx.thrust),
## the way the sword's arc stays. Only the look.
func _light_path(from: Vector2, dir: Vector2, distance: float, size: float, color: Color) -> void:
	if fx == null:
		return
	fx.thrust(from, dir.normalized(), minf(distance, WAVE_PATH_REACH), clampf(size, WAVE_PATH_WIDTH.x, WAVE_PATH_WIDTH.y), color, WAVE_PATH_TIME, HEIGHT, false, true)


## A Gift's wide wave (Corte Crescente on the spin, Onda Carregada, Fio do Passo; Combat._gift_wave) drawn bolder: it
## flies 6 m in under 0.3 s right under the spin's big crescent, and at the special's held look it hardly read at
## 1080 (E2 capture). A thicker band, a fuller body, more ink behind and a shorter fade, so it is whole most of its
## flight; the same peak (under the glow and ScreenTone.SAFE), the same hit. Only the look.
func bolden(s: Shot) -> void:
	if s.kind != Kind.WAVE:
		return
	s.bold = true
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	mat.set_shader_parameter(&"thick_m", GIFT_THICK)
	mat.set_shader_parameter(&"body_light", GIFT_BODY_LIGHT)
	mat.set_shader_parameter(&"ink", GIFT_INK)


## The brightest channel of the wave's leading edge for a blow of this colour: WAVE_PEAK, lowered so the pale edge
## stays under ScreenTone.SAFE on the screen (the edge at 1.0 went to 255).
static func wave_peak(color: Color) -> float:
	return minf(WAVE_PEAK, ScreenTone.linear_peak(color.lerp(Color.WHITE, WAVE_EDGE_PALE)))


## A boss's spectral crescent: width meters across, flying distance meters (it strikes the paladin once).
func fire_soul(from: Vector2, dir: Vector2, speed: float, damage: float, width: float, distance: float, color: Color) -> Shot:
	var s := fire(Kind.SOUL, from, dir, speed, damage, SOUL_DEPTH, distance / maxf(speed, 0.1))
	s.half_width = width * 0.5
	s.color = color
	s.node.scale = Vector3(width / CRESCENT_SPAN, 1.0, width / CRESCENT_SPAN * 0.85)
	((s.node as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter(&"color", color)
	return s


## A boss's curse: a bolt that turns after the paladin (turn degrees a second for homing seconds) and curses him.
func fire_curse(from: Vector2, dir: Vector2, speed: float, damage: float, radius: float, life: float, turn_deg: float, homing: float, color := Color(0, 0, 0, 0)) -> Shot:
	var s := fire(Kind.CURSE, from, dir, speed, damage, radius, life, color)
	s.status = &"curse"
	s.turn = deg_to_rad(turn_deg)
	s.homing = homing
	return s


## True while a shot that hurts the paladin flies.
func hostile_left() -> bool:
	for s in shots:
		if hostile(s):
			return true
	return false


func clear_hostile() -> void:
	var i := shots.size() - 1
	while i >= 0:
		if hostile(shots[i]):
			_release(shots[i])
			shots.remove_at(i)
		i -= 1


func step(dt: float) -> void:
	var i := shots.size() - 1
	while i >= 0:
		# a hit can end the run and clear the shots
		if i >= shots.size():
			i = shots.size() - 1
			continue
		var s := shots[i]
		if s.frozen:
			i -= 1
			continue
		if s.homing > 0.0 and player.alive():
			s.homing -= dt
			var want := s.vel.angle_to(player.pos - s.pos)
			s.vel = s.vel.rotated(clampf(want, -s.turn * dt, s.turn * dt))
			s.turn = maxf(0.0, s.turn - s.turn_decay * dt)
		if s.back_at > 0.0:
			_returning(s)
		var to := s.pos + s.vel * dt
		var arena := horde.arena if horde else null
		# the room's cover stops every shot but a boss's crescents (cycle C12, BUG-015): it dies on the stone with a spark
		var stop := arena.shot_hit(s.pos, to, SHOT_EDGE, s.low) if arena != null and s.kind != Kind.SOUL and not s.through else -1.0
		var sheltered: bool = stop < 0.0 and shelter.is_valid() and s.kind != Kind.SOUL and hostile(s) and shelter.call(to, s.radius)
		if stop >= 0.0:
			to = s.pos.lerp(to, stop)
		s.pos = to
		s.life -= dt
		s.age += dt
		s.flown += s.vel.length() * dt
		var gone := s.life <= 0.0 or (arena != null and not arena.bounds().grow(SHOT_MARGIN).has_point(s.pos))
		if stop >= 0.0 or sheltered:
			gone = true
			blocked += 1
			# a shot dying on stone rings like a blow on a ward (E1b)
			Audio.play(&"ward")
			if hostile(s):
				var piece := "shelter" if sheltered else String(arena.last_cover.piece) if arena.last_cover else ""
				shot_logged.emit(shooter(s), RoomTally.SHOT_BLOCKED, piece)
			fx.burst(&"spark", Vector3(s.pos.x, LOW_HEIGHT if s.low else HEIGHT, s.pos.y), Vector3(-s.vel.x, 0, -s.vel.y).normalized())
		elif not gone:
			if s.kind == Kind.SOUL:
				if player.alive() and not s.seen.has(player) and touches_soul(s, player.pos, Player.RADIUS):
					s.seen[player] = true
					last_source = s.source
					last_by = s.by
					last_warn = s.warned + s.age
					last_offscreen = s.offscreen
					_flew(s)
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					fx.burst(&"soul", Vector3(player.pos.x, HEIGHT, player.pos.y))
			elif hostile(s):
				if player.alive() and s.pos.distance_to(player.pos) < s.radius + Player.RADIUS and not (s.back_at > 0.0 and s.seen.has(player)):
					var safe := player.invulnerable()
					last_source = s.source
					last_by = s.by
					last_warn = s.warned + s.age
					last_offscreen = s.offscreen
					_flew(s)
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					if s.status != &"" and not safe:
						status_player.emit(s.status)
					fx.burst(&"curse" if s.kind == Kind.CURSE else &"spark", Vector3(s.pos.x, HEIGHT, s.pos.y))
					if s.back_at > 0.0:
						s.seen[player] = true  # (the axe goes on: it hurts again on the way back)
					else:
						gone = true
			else:
				if curse_cut and (s.kind == Kind.WAVE or s.kind == Kind.SPARK):
					_cut_curses(s)
				horde.in_circle(s.pos, s.radius, _found)
				if s.stops:
					# it ends on the nearest enemy it touches, once
					var first: Enemy = null
					for e in _found:
						if not s.seen.has(e) and (first == null or e.pos.distance_squared_to(s.pos) < first.pos.distance_squared_to(s.pos)):
							first = e
					if first != null:
						s.seen[first] = true
						gone = true
						shot_hit.emit(first, s)
				else:
					for e in _found:
						if not s.seen.has(e):
							s.seen[e] = true
							shot_hit.emit(e, s)
		if gone:
			if shots.has(s):
				_release(s)
				shots.erase(s)
		else:
			_place(s)
		i -= 1


## The axe of a Lançador: its line of the way back shows ThrowRules.RETURN_WARN s before it turns, and at the turn it flies back along
## the same line (the paladin can be hurt again).
func _returning(s: Shot) -> void:
	if not s.back_warned and s.age >= ThrowRules.warn_age(s.back_at) and horde != null and horde.ground != null:
		s.back_warned = true
		var way := s.vel.normalized()
		var length := s.pos.distance_to(s.origin) + s.vel.length() * maxf(0.0, s.back_at - s.age)
		horde.ground.add_aim_warning(s.origin, way, length, RETURN_LINE, maxf(0.05, s.back_at - s.age), 0.0)
	if s.age >= s.back_at:
		s.back_at = 0.0
		s.vel = -s.vel
		s.seen.erase(player)
		s.back_warned = true
		Audio.play(&"ward")


## Width of the thin line that shows the axe's way back.
const RETURN_LINE := 0.3


## C1d: a wave of the paladin undoes every curse it touches (its life ends here: it is gone on its own step).
func _cut_curses(w: Shot) -> void:
	for o in shots:
		if o.kind == Kind.CURSE and o.life > 0.0 and o.pos.distance_to(w.pos) < w.radius + o.radius + CUT_SLACK:
			o.life = 0.0
			fx.burst(&"spark", Vector3(o.pos.x, HEIGHT, o.pos.y))
			Audio.play(&"ward")
			curse_cut_at.emit(o.pos)


## Meters more than the two radii within which a wave still touches a curse (it flies 22 m/s: a frame is 0.37 m).
const CUT_SLACK := 0.5


## Who fired a shot, for the run's log: its kind (EnemyDef.id), or "morvath" for the boss's own.
func _flew(s: Shot) -> void:
	var id := shooter(s)
	if not flights.has(id):
		flights[id] = [0, 0.0, 0.0]
	var f: Array = flights[id]
	f[0] += 1
	f[1] += s.age
	f[2] = maxf(f[2], s.age)


## The flights for RESULT: {shooter: {hits, avg, max}} in seconds.
func flight_report() -> Dictionary:
	var out := {}
	for id: String in flights:
		var f: Array = flights[id]
		out[id] = {"hits": f[0], "avg": snappedf(f[1] / maxf(f[0], 1), 0.01), "max": snappedf(f[2], 0.01)}
	return out


static func shooter(s: Shot) -> String:
	return shooter_of(s.by)


## The same, from the kind that fired it (Shot.by; &"": the boss's own).
static func shooter_of(by: StringName) -> String:
	return String(by) if by != &"" else "morvath"


static func hostile(s: Shot) -> bool:
	return s.kind == Kind.BOLT or s.kind == Kind.ORB or s.kind == Kind.SOUL or s.kind == Kind.CURSE


## A crescent (SOUL) touches a body of this radius at p: within its depth along the flight and its width across.
static func touches_soul(s: Shot, p: Vector2, radius: float) -> bool:
	var d := p - s.pos
	var ahead := s.vel.normalized()
	return absf(d.dot(ahead)) <= s.radius + radius and absf(d.cross(ahead)) <= s.half_width + radius * 0.5


## The smoke an enemy shot leaves (vfx_pass_spec.md V-11): a dark puff every TRAIL_STEP metres flown (the bolt's
## thinner and closer, a fiapo of 0.8 m behind it), drifting up and coming apart (Fx.wisps).
const TRAIL_STEP := {Kind.BOLT: 0.45, Kind.ORB: 0.7, Kind.CURSE: 0.7, Kind.SPARK: 0.6, Kind.WAVE: 0.6, Kind.SOUL: 0.5}
## V-06: the paladin's wave leaves crystal slivers in its path instead (one every 0.6 m, held WAKE_CHIP s, its colour
## at this share before the chips' glow), never smoke.
const WAKE_CHIP := 0.15
const WAKE_CHIP_LIGHT := 0.32
const TRAIL_SMOKE := Color(0.08, 0.04, 0.05)


func _trail(s: Shot) -> void:
	if fx == null:
		return
	var step: float = TRAIL_STEP[s.kind]
	var due := int(s.flown / step)
	if due <= s.trail:
		return
	s.trail = due
	if s.kind == Kind.SOUL:
		# three smoke tails streaming back from its tips and middle, waving (V-17)
		var back := Vector3(-s.vel.x, 0.0, -s.vel.y).normalized()
		var side := back.cross(Vector3.UP)
		for k in 3:
			var off := side * float(k - 1) * s.half_width * 0.8 + back * (0.1 if k == 1 else 0.35)
			fx.wisps(s.node.position + off, back + Vector3.UP * 0.15 + side * sin(s.flown * 4.0 + k) * 0.3, SOUL_TAIL, 1, 3.5, 0.45, 0.35, 0.15, 0.2)
		return
	if s.kind == Kind.SPARK or s.kind == Kind.WAVE:
		fx.chips(s.node.position, Vector3(-s.vel.x, 0.0, -s.vel.y).normalized() + Vector3.UP * 0.1, s.color * WAKE_CHIP_LIGHT, 1, 0.8, 0.16, WAKE_CHIP, 0.25)
		return
	var size := 0.32 if s.kind == Kind.BOLT else 0.5
	fx.wisps(s.node.position, Vector3(-s.vel.x, 0.0, -s.vel.y) * 0.05 + Vector3.UP * 0.2, TRAIL_SMOKE, 1, 0.4, size, 0.35, 0.3, 0.6)


func _place(s: Shot) -> void:
	s.node.position = Vector3(s.pos.x, SOUL_HEIGHT if s.kind == Kind.SOUL else (LOW_HEIGHT if s.low else HEIGHT), s.pos.y)
	if s.vel.length_squared() > 0.0:
		s.node.rotation.y = atan2(s.vel.x, s.vel.y)
		if s.kind == Kind.SOUL:
			s.node.rotation.y += deg_to_rad(SOUL_TURN) * s.age
	if s.kind == Kind.SOUL:
		_place_soul(s)
	if TRAIL_STEP.has(s.kind):
		_trail(s)
	if s.kind == Kind.WAVE or s.kind == Kind.SPARK:
		var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
		mat.set_shader_parameter(&"flown", s.flown)
		var fade_time := GIFT_FADE if s.bold else WAVE_FADE.y if s.kind == Kind.WAVE else WAVE_FADE.x
		mat.set_shader_parameter(&"fade", clampf(s.life / fade_time, 0.0, 1.0))


func _take(kind: Kind) -> Node3D:
	var pool: Array = _pools.get(kind, [])
	if not pool.is_empty():
		return pool.pop_back()
	var mi := MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var look: Array = LOOK[kind]
	if kind == Kind.BLADE or kind == Kind.SOUL:
		# a crescent: the ribbon of a sword arc held at the end of its sweep (thick in the middle, thin at the ends)
		mi.mesh = _crescent()
		var mat := ShaderMaterial.new()
		mat.shader = Fx.SLASH
		mat.set_shader_parameter(&"intensity", 2.4)
		mat.set_shader_parameter(&"sweep", 1.0)
		mat.set_shader_parameter(&"t", 1.0)
		mat.set_shader_parameter(&"tail", 0.85)
		if kind == Kind.SOUL:
			# a boss's crescent of spectral fire (soul_crescent.gdshader) and its short trail (boss_wake.gdshader)
			mat.shader = SOUL_SHADER
			mat.set_shader_parameter(&"intensity", SOUL_INTENSITY)
			mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(SOUL_PALE, SOUL_SCREEN))
			mi.add_child(_soul_trail())
		mi.material_override = mat
	elif kind == Kind.WAVE or kind == Kind.SPARK:
		mi.mesh = _wave_plane()
		var mat := ShaderMaterial.new()
		mat.shader = WAVE_SHADER
		mat.set_shader_parameter(&"edge_pale", WAVE_EDGE_PALE)
		mat.set_shader_parameter(&"gold", WAVE_GOLD)
		mat.set_shader_parameter(&"gold_light", WAVE_GOLD_LIGHT)
		mi.material_override = mat
		# the shader sets the plane to its size in meters (up to 8.25 m across)
		mi.extra_cull_margin = 6.0
	else:
		# a ball in the shooter's hue with a small heart and a soft blended halo (enemy_orb*.gdshader): one material
		# per part for every shot, the hue per shot (_tint), nothing over the glow threshold
		var sphere := SphereMesh.new()
		sphere.radius = look[1]
		sphere.height = look[1] * 2.0
		sphere.radial_segments = 10
		sphere.rings = 6
		mi.mesh = sphere
		mi.material_override = _orb_material(ORB_SHADER)
		if kind == Kind.BOLT:
			mi.scale = Vector3(0.6, 0.6, 2.4)
			mi.set_instance_shader_parameter(&"needle", 1.0)
		var glow := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2.ONE * look[1] * 2.0 * HALO
		glow.mesh = q
		glow.material_override = _orb_material(HALO_SHADER)
		glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# the bolt has no smoke round it, only its trail (_trail)
		glow.visible = kind != Kind.BOLT
		mi.add_child(glow)
	add_child(mi)
	return mi


## The colour of a pooled bolt or orb, its core and its halo: the hue of the shooter's magic (its largest channel
## at 1; the magic colours are written over 1 for the crowd's lamps and would draw white).
func _tint(node: Node3D, color: Color) -> void:
	var hue := Vector3(color.r, color.g, color.b) / maxf(maxf(color.r, color.g), maxf(color.b, 0.001))
	(node as GeometryInstance3D).set_instance_shader_parameter(&"hue", hue)
	for c in node.get_children():
		if c is GeometryInstance3D:
			(c as GeometryInstance3D).set_instance_shader_parameter(&"hue", hue)


## The shared material of an enemy shot's ball or halo.
func _orb_material(shader: Shader) -> ShaderMaterial:
	if not _orb_mats.has(shader):
		var m := ShaderMaterial.new()
		m.shader = shader
		_orb_mats[shader] = m
	return _orb_mats[shader]


func _release(s: Shot) -> void:
	s.node.visible = false
	s.node.scale = Vector3(0.6, 0.6, 2.4) if s.kind == Kind.BOLT else Vector3.ONE
	if s.kind == Kind.SPARK:
		# the wave breaks into a few chips of its own colour where it ends
		fx.chips(s.node.position, Vector3(s.vel.x, 0.0, s.vel.y), s.color, 5, 5.0, 0.1, 0.3, 0.9)
	elif s.kind == Kind.SOUL:
		# the crescent comes apart where it is: specks across its width drift on and rise, a wisp of its smoke
		var across := s.vel.normalized().orthogonal()
		for k in 3:
			var at := s.pos + across * s.half_width * (k - 1) * 0.6
			fx.chips(Vector3(at.x, SOUL_HEIGHT, at.y), Vector3(s.vel.x, 2.0, s.vel.y), s.color if k != 1 else Boss.VIOLET, 2, 2.5, 0.12, 0.45, 0.6)
		fx.burst(&"soul", Vector3(s.pos.x, SOUL_HEIGHT, s.pos.y))
	if not _pools.has(s.kind):
		_pools[s.kind] = []
	(_pools[s.kind] as Array).append(s.node)


var _plane: PlaneMesh


## The flat 1 x 1 plane the blade wave is drawn on (shared by every wave).
func _wave_plane() -> PlaneMesh:
	if _plane == null:
		_plane = PlaneMesh.new()
		_plane.size = Vector2.ONE
	return _plane


## Meters across the crescent mesh at scale 1 (its two tips, 70 degrees each side of its middle).
const CRESCENT_SPAN := 1.88
## How bright a boss's crescent is drawn (it must not drown the warnings).
const SOUL_INTENSITY := 1.0
const SOUL_SHADER := preload("res://assets/shaders/soul_crescent.gdshader")
var _crescent_mesh: ArrayMesh

## Meters of trail a crescent leaves behind its middle at most: as far back as its hit reaches a body (SOUL_DEPTH
## plus the paladin's radius), the share of its width the trail takes, and how long it flares as it leaves and fades
## as it ends (s).
const SOUL_TRAIL := SOUL_DEPTH + Player.RADIUS
const SOUL_TRAIL_WIDTH := 0.55
const SOUL_FLARE := 0.12
const SOUL_FADE := 0.22
## V-17: the lilac its core stops at on the screen, and the three smoke tails it leaves (one wisp each from the two tips
## and the middle every SOUL_TAIL_STEP m flown, SOUL_TAIL long in their life) while it turns SOUL_TURN degrees a second.
const SOUL_PALE := Color(0.8, 0.72, 0.95)
const SOUL_SCREEN := 215
const SOUL_TAIL_STEP := 0.5
const SOUL_TAIL := Color(0.09, 0.04, 0.12)
const SOUL_TURN := 15.0


func _soul_trail() -> MeshInstance3D:
	var trail := MeshInstance3D.new()
	trail.mesh = Fx.strip()
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = Fx.WAKE
	mat.set_shader_parameter(&"trail_mode", true)
	mat.set_shader_parameter(&"body", Boss.VIOLET)
	mat.set_shader_parameter(&"edge", Boss.SOUL_VIOLET)
	mat.set_shader_parameter(&"edge_light", 0.35)
	mat.set_shader_parameter(&"body_light", 0.45)
	trail.material_override = mat
	return trail


## The crescent's flare, fade and trail (its scale is the parent's: the trail is put back in meters).
func _place_soul(s: Shot) -> void:
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	var fade := clampf(s.life / SOUL_FADE, 0.0, 1.0)
	mat.set_shader_parameter(&"fade", fade)
	mat.set_shader_parameter(&"flare", maxf(0.0, 1.0 - s.age / SOUL_FLARE))
	var trail: MeshInstance3D = s.node.get_child(0) if s.node.get_child_count() > 0 else null
	if trail == null:
		return
	var sx := maxf(s.node.scale.x, 0.001)
	var sz := maxf(s.node.scale.z, 0.001)
	var length := minf(s.flown, SOUL_TRAIL)
	trail.visible = false  # V-17: the three smoke tails (_trail) took its place
	trail.scale = Vector3(s.half_width * 2.0 * SOUL_TRAIL_WIDTH / sx, 1.0, length / sz)
	trail.position = Vector3(0.0, -0.02, -length / sz)
	(trail.material_override as ShaderMaterial).set_shader_parameter(&"fade", fade)


## A crescent 1 meter across, bulging forward (+Z), with the UVs of a slash.
func _crescent() -> ArrayMesh:
	if _crescent_mesh:
		return _crescent_mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 16
	var half := deg_to_rad(70.0)
	for i in seg:
		var a0 := -half + 2.0 * half * i / seg
		var a1 := -half + 2.0 * half * (i + 1) / seg
		var p := [Vector3(sin(a0) * 0.25, 0, cos(a0) * 0.25 - 0.3), Vector3(sin(a0), 0, cos(a0) - 0.3),
			Vector3(sin(a1) * 0.25, 0, cos(a1) * 0.25 - 0.3), Vector3(sin(a1), 0, cos(a1) - 0.3)]
		var u0 := 1.0 - absf(float(i) / seg - 0.5) * 2.0
		var u1 := 1.0 - absf(float(i + 1) / seg - 0.5) * 2.0
		var uv := [Vector2(0.3 + 0.4 * u0, 0), Vector2(0.3 + 0.4 * u0, 1), Vector2(0.3 + 0.4 * u1, 0), Vector2(0.3 + 0.4 * u1, 1)]
		for k: int in [0, 1, 2, 2, 1, 3]:
			st.set_uv(uv[k])
			st.add_vertex(p[k])
	_crescent_mesh = st.commit()
	return _crescent_mesh
