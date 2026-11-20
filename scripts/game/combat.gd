class_name Combat
extends RefCounted
## Resolves what the paladin's moves and gifts do to the enemies: who is hit, how hard, which effects apply.

signal combo_changed(count: int)
signal enemy_struck(e: Enemy, tags: Array[StringName], damage: float)
## Every swing of the combo, after its hits (struck: how many it reached); captures freeze on it (--shot-on).
signal swung(node: ComboNode, struck: int)
## A blow of the paladin's landed on hits enemies (wards not counted): a move of the combo tree (node), or the first
## enemy a wave of a move struck (node null; its shot is counted once, Projectiles.Shot.counted). The passive and the
## Gifts read it (HeroGifts).
signal landed(node: ComboNode, tags: Array[StringName], hits: int)

const COMBO_KEEP := 3.0
## Extra hit slow when a blow kills (Hades II: 0.04 s).
const KILL_HOLD_MS := 40.0
## Slow motion in a fight is rare, as in Hades II (there only the last kill of a room and a boss's death slow the
## world; a blow only gets a few hundredths of a second of hit slow): a blow that fells SLOW_MO_KILLS at once or
## lands on SLOW_MO_CROWD, at most once every SLOW_MO_COOLDOWN seconds. Speed, seconds held, seconds back.
const SLOW_MO_KILLS := 3
const SLOW_MO_CROWD := 7
const SLOW_MO_COOLDOWN := 6.0
const SLOW_MO_FRACTION := 0.2
const SLOW_MO_HOLD := 0.12
const SLOW_MO_OUT := 0.25
const HIT_SLOW_COOLDOWN := 0.3
## The jolt of the camera along a blow that lands (Fx.kick, times Fx.KICK_METERS): a common blow on the scale of
## Hades II's 0.05 m shake (GF-10, at most 0.1 m), bigger only on a finisher and on an Omega (decision D-43).
const KICK_COMMON := 0.25
const KICK_FINISHER := 0.9
const KICK_OMEGA := 1.6
## The gamepad's buzz on a blow that lands (Fx.buzz): weak motor, strong motor, seconds; common, finisher, Omega.
const RUMBLE_COMMON := Vector3(0.25, 0.0, 0.06)
const RUMBLE_FINISHER := Vector3(0.4, 0.45, 0.12)
const RUMBLE_OMEGA := Vector3(0.6, 0.8, 0.18)
const MARK_TAGS: Array[StringName] = [&"mark", &"cross"]
const EMBER_TAGS: Array[StringName] = [&"ember", &"chama"]
const HOLY_TAGS: Array[StringName] = [&"skill", &"vigilia"]
## The circle of light (cast): what gifts see (its size, how long it holds and the burst of the held version are the
## hero's: HeroDef.cast_radius, cast_time, cast_burst).
const CAST_TAGS: Array[StringName] = [&"cast"]
const CAST_COLOR := Color(1.0, 0.95, 0.8)
const SHATTER_SPLASH := 0.4
## Degrees of the narrow arc drawn for a thrust.
const LINE_ARC := 22.0
## Cuts drawn per swing (the rest of the crowd hit only flashes).
const MAX_STARS := 8
## The cut a blow leaves on each one it lands on (Fx.gash): meters long (a common blow draws from the first to the
## second, a finisher the second, a heavy blow GASH_HEAVY with a second streak across), radians it may lean out of
## the floor plane, seconds it lasts, and the chips that fly off it.
const GASH := Vector2(0.9, 1.4)
const GASH_HEAVY := 1.8
const GASH_LEAN := 0.5
const GASH_TIME := Vector2(0.16, 0.18)
const GASH_CHIPS := Vector2i(4, 6)
## The chips of a blow landing (C12d, VX-10): stone grey slivers (Fx.chips lights them by Fx.MOTE_GLOW), their
## speed in m/s, size in meters and life in seconds at most: gone well before 8 frames of the movie (30 fps).
const CHIP_COLOR := Color(0.42, 0.4, 0.37)
const CHIP_SPEED := 6.0
const CHIP_SIZE := 0.08
const CHIP_LIFE := 0.22
## The special (the Seta de Luz dart) lands as a small star of two crossed cuts, this size (Fx.impact), with chips
## of old gold: a puncture, never the streak of a sword cut. Its held version lands as a streak this long (STAB)
## along its flight, crossed (cycle 8: attack, special and Omega told apart at a glance).
const SPECIAL_STAR := 0.7
const STAB := 1.2
## A finisher that lands adds one thin ring, once per blow: meters it grows to, seconds it lasts.
const FINISHER_RING := 1.5
const FINISHER_RING_TIME := 0.2
## Motes of magic shed from the tip of each swing, the way the blade turns (one in four is old gold).
const SWING_MOTES := Vector2i(4, 8)
## The colour split of the screen, only on a finisher that lands (Fx.kick_split).
const FINISHER_SPLIT := 0.5
const SHATTER_RADIUS := 2.2
## Where a finisher's glint shows when there is no blade to follow: meters in front of the paladin, height.
const GLINT_AHEAD := 0.6
const GLINT_HEIGHT := 1.8
## Seconds the arc of a blow stays bright: a common one, a heavy one, a finisher.
const SLASH_TIME := 0.12
const HEAVY_SLASH_TIME := 0.16
const FINISHER_SLASH_TIME := 0.3
## Blows on a ward (an invulnerable enemy): this many sparks, this far out from its centre (in its radii), this colour.
const WARD_SPARK_COUNT := 3
const WARD_SPARK_REACH := 1.6
const WARD_SPARK := Color(0.3, 0.95, 0.75)
## The impact frame (a flat black and white frame of the whole screen, Fx.impact_frame) is kept for the two biggest
## moments only (decision D-08 of cycle 10): an Omega that lands, and the blow that brings a boss down to his next
## phase (or down for good). At most one every Feel.impact_frame_every seconds, and never with the "impact_frames"
## option off (Fx.impact_frames).
const OMEGA_TAG := &"omega"
const BURN_TIME := 3.0
## The families' colours (vfx_pass_spec.md 4, Lote 1): the Chama in amber 30 to 38 on the screen (it was 4 to 25, the
## danger's red), the Geada as it was, the Luz pale gold 42 to 48, the Vigília sage 80 to 95 (it was the Luz's gold;
## AngelSeal.TINT of Shomael), far from the Emeth's emerald 125 to 145.
const FIRE := Color(1.0, 0.6, 0.16)
const FROST := Color(0.5, 0.82, 1.0)
## Elun's gold: only blows that come from gifts.
const LIGHT := Color(1.0, 0.92, 0.7)
const VIGIL := Color(0.66, 0.78, 0.46)
## The paladin's own sword, Emeth: the green of its blade.
const EMETH := Color(0.3, 1.0, 0.45)
## Damage numbers of the sword's common blows: pale, so the emerald ones (finishers, held blows) stand out.
const NUMBER_PALE := UiKit.PALE
## Tags that mark a blow as coming from a gift (skills carry "skill" and their family's tag).
const GIFT_TAGS: Array[StringName] = [&"skill", &"luz", &"vigilia", &"duo"]

## Fatia 2, the Encantos: degrees between the waves of Lâmina Tríplice's fan; the tag of Eco da Verdade's echo (never
## echoed again).
const WAVE_FAN := 14.0
const ECHO_TAG := &"echo"

## Retorno do Corte: seconds left of the window after a Corte Veloz and how much farther the next blow reaches.
var _return_t := 0.0
var _return_reach := 0.0
## Eco da Verdade: the blows to echo ({node, origin, dir, t, share}).
var _echoes: Array[Dictionary] = []
var horde: Horde
var fx: Fx
var ground: Ground
var projectiles: Projectiles
var boons: BoonState
var hero: HeroDef = HeroDef.warrior()
## The rules of the Gifts in this run (HeroGifts sets it; null in the bare tests: no Gift).
var gifts: GiftState
## The tags of the blow being dealt and which blow it is (a swing, or a shot's instance id), while Horde.damage runs:
## a kill (Horde.killed) reads what felled it. Empty outside a blow (a burn's tick, a shield's burst).
var kill_tags: Array[StringName] = []
## Where the next hits come from for the damage ledger (DealtBy), when the tags do not say it (the held circle's
## burst); &"": read from the tags.
var source: StringName = &""
var kill_blow := 0
var combo := 0
var best_combo := 0
var damage_dealt := 0.0
var _combo_t := 0.0
var _hits: Array[Enemy] = []
## The materials one blow struck (C15-02: the loudest one sounds over the hit).
var _mats: Array[StringName] = []
var _near: Array[Enemy] = []
var _swing := 0
var _behind: Array[Enemy] = []
var _slow_cd := 0.0
var _cine_cd := 0.0
## Seconds before another impact frame may flash.
var _frame_cd := 0.0
## Only for what is drawn (how long a cut is, how many chips): never the game's own draw.
var _look := RandomNumberGenerator.new()


func _init() -> void:
	Dev.seed_rng(_look, 7)


func step(dt: float) -> void:
	_return_t = maxf(0.0, _return_t - dt)
	_step_echoes(dt)
	_slow_cd = maxf(0.0, _slow_cd - dt)
	_cine_cd = maxf(0.0, _cine_cd - dt)
	_frame_cd = maxf(0.0, _frame_cd - dt)
	if combo > 0:
		_combo_t -= dt
		if _combo_t <= 0.0:
			drop_combo()


func drop_combo() -> void:
	if combo != 0:
		combo = 0
		combo_changed.emit(0)


## Eco da Verdade (Fatia 2; auditoria.md 3.1, "Emeth" is "truth"): a blow with echo_pct strikes again from where it was,
## echo_delay later, for that share of its damage, in its shape; the echo is no blow of the combo (no Magia, no fury,
## no wave, never echoed again) and is drawn as the blow, paler.
func _step_echoes(dt: float) -> void:
	var i := _echoes.size() - 1
	while i >= 0:
		var x: Dictionary = _echoes[i]
		x.t = float(x.t) - dt
		if float(x.t) <= 0.0:
			_echoes.remove_at(i)
			_echo(x.node, x.origin, x.dir, float(x.share))
		i -= 1


func _echo(node: ComboNode, origin: Vector2, dir: Vector2, share: float) -> void:
	var tags: Array[StringName] = [ECHO_TAG]
	for t in node.tags:
		if t != OMEGA_TAG and t != &"finisher":
			tags.append(t)
	var shape := swing_shape(node, boons.stat(&"reach_pct", tags))
	_hits.clear()
	match node.shape:
		ComboNode.Shape.CIRCLE:
			horde.in_circle(origin, shape.hit_reach, _hits)
		ComboNode.Shape.LINE:
			horde.in_line(origin, dir, shape.hit_reach, node.width, _hits)
		_:
			horde.in_arc(origin, dir, shape.hit_reach, shape.hit_width, _hits)
	var color := color_of(tags).lerp(Color(1, 1, 1), 0.35)
	_draw_swing(node, shape, origin, dir, color, false, false, node.sweep_flip(_swing % 2 == 0))
	for e: Enemy in _hits.duplicate():
		var away := (e.pos - origin).normalized() if node.shape == ComboNode.Shape.CIRCLE else dir
		hit_enemy(e, node.damage * share, tags, away, node.knockback * 0.5, false)


## A move of the combo tree lands.
func strike(node: ComboNode, origin: Vector2, dir: Vector2) -> void:
	_swing += 1
	kill_blow = _swing
	var tags := node.tags
	var fury_stun := gifts.fury_stun(tags) if gifts else 0.0
	var hits := 0
	# Retorno do Corte (Fatia 2): the blow right after a Corte Veloz reaches farther and wider
	var back := 0.0
	if _return_t > 0.0 and not node.has_tag(&"dash"):
		back = _return_reach
		_return_t = 0.0
	var shape := swing_shape(node, boons.stat(&"reach_pct", tags) + back, back)
	var reach: float = shape.hit_reach
	var color := color_of(tags)
	var heavy := node.has_tag(&"heavy")
	var finisher := node.has_tag(&"finisher")
	match node.shape:
		ComboNode.Shape.ARC:
			horde.in_arc(origin, dir, reach, shape.hit_width, _hits)
		ComboNode.Shape.CIRCLE:
			horde.in_circle(origin, reach, _hits)
			if not finisher:
				# (a finisher's crescent is the ring flying out: one circle, not rings inside rings)
				fx.ring(origin, reach, color, 0.35, 0.15, true)
		ComboNode.Shape.LINE:
			horde.in_line(origin, dir, reach, node.width, _hits)
			if node.both_ways:
				horde.in_line(origin, -dir, reach, node.width, _behind)
				for e in _behind:
					if not _hits.has(e):
						_hits.append(e)
	var flip := node.sweep_flip(_swing % 2 == 0)
	if node.damage <= 0.0:
		_hits.clear()
	else:
		_draw_swing(node, shape, origin, dir, color, heavy, finisher, flip)
	var struck: Array[Enemy] = _hits.duplicate()
	var stars := 0
	var kills := 0
	_mats.clear()
	for e: Enemy in struck:
		var away := (e.pos - origin).normalized() if node.shape == ComboNode.Shape.CIRCLE else dir if (e.pos - origin).dot(dir) >= 0.0 else -dir
		if e.invulnerable:
			hit_enemy(e, node.damage, tags, away, node.knockback, true, finisher)  # only a spark on his ward
			continue
		if stars < MAX_STARS:
			stars += 1
			_draw_hit(e, cut_axis(node.shape, origin, e.pos, away, flip), away, color, heavy or node.has_tag(&"omega"), finisher)
		var died := hit_enemy(e, node.damage, tags, away, node.knockback, true, finisher)
		hits += 1
		_mats.append(CombatSounds.material_of(e))
		if heavy:
			e.flash_power = 1.0  # a strong blow: its first frame goes toward ivory (crowd.gdshader)
		if died:
			kills += 1
			continue
		if fury_stun > 0.0 and e.def.stun_heavy_time > 0.0:
			# Fúria Plena: with every charge of Ímpeto a finisher stuns longer, those with armor too (never a guardian
			# nor Morvath: their stun time is 0)
			horde.flinch(e, e.def.stun_heavy_time + fury_stun)
		match node.effect:
			ComboNode.Effect.LAUNCH:
				if not e.def.heavy:
					e.air_t = node.effect_time
					e.air_total = node.effect_time
			ComboNode.Effect.STUN:
				if e.def.behavior != EnemyDef.Behavior.BOSS:
					e.stun_t = maxf(e.stun_t, node.effect_time * (0.5 if e.def.heavy else 1.0))
	# (the blade's own sound plays when the move starts, ComboNode.sound: GF-11)
	if not struck.is_empty():
		# Hades II holds the hit slow a little longer when the blow kills
		_hit_slow(node, KILL_HOLD_MS if kills > 0 else 0.0)
		if _cine_cd <= 0.0 and wants_slow_mo(struck.size(), kills):
			_cine_cd = SLOW_MO_COOLDOWN
			# (Fx starts it once the hit stop is over: GF-05)
			fx.slow_mo(SLOW_MO_FRACTION, SLOW_MO_HOLD, SLOW_MO_OUT, 1.05, 0.45)
		fx.shake(node.shake * (1.0 + minf(struck.size(), 10) * 0.05))
		var omega := node.has_tag(OMEGA_TAG)
		fx.kick(dir, kick_of(node))
		var buzz := RUMBLE_OMEGA if omega else RUMBLE_FINISHER if finisher else RUMBLE_COMMON
		fx.buzz(buzz.x, buzz.y, buzz.z)
		if finisher:
			fx.kick_split(FINISHER_SPLIT)
			fx.ring(struck[0].pos, FINISHER_RING, color, FINISHER_RING_TIME, 1.0 + struck[0].y, true)
		Audio.play(CombatSounds.EVENTS[&"hit_heavy" if heavy else &"hit"])
		_play_material(CombatSounds.loudest(_mats))
	match node.effect:
		ComboNode.Effect.GROUND_MARK:
			ground.add_zone(Ground.Kind.MARK, origin + dir * reach * 0.55, node.effect_radius, node.effect_time, node.effect_power, MARK_TAGS)
		ComboNode.Effect.WAVE:
			throw_wave(node, origin, dir, color, tags)
		ComboNode.Effect.STUN:
			fx.burst(&"light", Vector3(origin.x, 0.4, origin.y))
	if gifts:
		_gift_wave(node, origin, dir, color)
	var window := boons.stat(&"return_time", tags)
	if window > 0.0:
		_return_t = window
		_return_reach = boons.stat(&"return_reach", tags)
	var echo := boons.stat(&"echo_pct", tags)
	if echo > 0.0 and not tags.has(ECHO_TAG):
		_echoes.append({"node": node, "origin": origin, "dir": dir, "t": boons.stat(&"echo_delay", tags), "share": echo})
	kill_blow = 0
	swung.emit(node, struck.size())
	if hits > 0:
		landed.emit(node, tags, hits)


## The wave of a move with Effect.WAVE (the special and its Omega; the Pastor's flock throws more of them, E4): its
## look, reach and width grown by the Blessings (wave_size_pct), through the crowd with Onda Atravessante.
func throw_wave(node: ComboNode, origin: Vector2, dir: Vector2, color: Color, tags: Array[StringName]) -> Projectiles.Shot:
	var size := 1.0 + boons.stat(&"wave_size_pct", tags)
	var width := node.effect_size if node.effect_size > 0.0 else 3.2
	var look := Projectiles.Kind.SPARK if node.wave_bolt else Projectiles.Kind.WAVE
	var shot := projectiles.fire_wave(look, origin + dir * 0.8, dir, node.effect_power, node.effect_radius * size, width * size, color, tags)
	shot.through = boons.stat(&"wave_through", tags) > 0.0
	return shot


## The wave a Gift has a move throw, landing or not (Corte Crescente on the spin, Onda Carregada on the special's
## Omega, Fio do Passo on the Corte Veloz; GiftState.wave): the special's emerald blade wave (emeth_wave.gdshader,
## under the glow), the slower wide one past 1.6 m across. Its tags are the move's (the Blessings count on it) as a
## wave, never an Omega again (no second impact frame); its first hit is not another landing of the blow (counted).
func _gift_wave(node: ComboNode, origin: Vector2, dir: Vector2, color: Color) -> void:
	var w := gifts.wave(node.tags)
	if float(w.damage) <= 0.0:
		return
	var tags: Array[StringName] = []
	for t in node.tags:
		if t != OMEGA_TAG:
			tags.append(t)
	if not tags.has(&"wave"):
		tags.append(&"wave")
	var size := 1.0 + boons.stat(&"wave_size_pct", tags)
	var width := float(w.width) * size
	var look := Projectiles.Kind.SPARK if width <= Projectiles.WAVE_SPAN + 0.01 else Projectiles.Kind.WAVE
	# Lâmina Tríplice (Fatia 2): blow_wave_fan more of them in a fan (the Pastor's spread)
	var ways: Array[Vector2] = [dir]
	ways.append_array(Psalms.fan(dir, int(boons.stat(&"blow_wave_fan", tags)), WAVE_FAN))
	for way in ways:
		var shot := projectiles.fire_wave(look, origin + way * 0.8, way, float(w.damage), float(w.reach) * size, width, color, tags)
		projectiles.bolden(shot)
		shot.counted = true
		shot.through = boons.stat(&"wave_through", tags) > 0.0


## What a swing shows whether it lands or not: the ribbon of the arc (a thin beam for a thrust), the motes off its
## tip, the pulse of the blade and, for a finisher, the crescent flying out.
func _draw_swing(node: ComboNode, shape: Dictionary, origin: Vector2, dir: Vector2, color: Color, heavy: bool, finisher: bool, flip: bool) -> void:
	var spin := node.shape == ComboNode.Shape.CIRCLE
	var time := FINISHER_SLASH_TIME if finisher else HEAVY_SLASH_TIME if heavy else SLASH_TIME
	var reach: float = shape.draw_reach
	var motes := _look.randi_range(SWING_MOTES.x, SWING_MOTES.y)
	fx.blade_pulse()
	if node.shape == ComboNode.Shape.LINE:
		# a thrust: straight, as wide as it reaches, never the arc of a cut
		for way: Vector2 in ([dir, -dir] if node.both_ways else [dir]):
			fx.thrust(origin, way, reach, node.width, color, time, 0.9, node.has_tag(&"omega"))
			var tip := origin + way * reach * 0.9
			fx.chips(Vector3(tip.x, 0.9, tip.y), Vector3(way.x, 0.2, way.y), color, motes, 4.0, 0.12, 0.4, 0.5, Fx.MOTE_GOLD_EVERY)
	else:
		# a turn all around: a clean sweep of light (a dark ring that size reads as a hole in the floor)
		fx.slash(origin, dir, reach, shape.draw_width, color, time, flip, 0.9, not spin)
		# the motes leave the end of the arc the way the blade was turning
		var turn := -1.0 if flip else 1.0
		var end := dir.angle() - turn * deg_to_rad(minf(shape.draw_width, 300.0)) * 0.5
		var tip := origin + Vector2.from_angle(end) * reach * 0.92
		var onward := Vector2.from_angle(end - turn * PI * 0.5)
		fx.chips(Vector3(tip.x, 0.9, tip.y), Vector3(onward.x, 0.25, onward.y), color, motes, 5.0, 0.12, 0.4, 0.5, Fx.MOTE_GOLD_EVERY)
	if finisher:
		# the sweep of the blade flying out past the blow (all the way around for a spin)
		fx.crescent(origin, dir, reach, 360.0 if spin else maxf(shape.draw_width, 120.0), color)


## What one enemy shows when a blow lands on it: the cut along the way the blade was moving and the chips flying
## away from the paladin. Only called from the loop of those really hit. heavy: a heavy or held blow (a second streak
## across the cut).
func _draw_hit(e: Enemy, axis: Vector2, away: Vector2, color: Color, heavy: bool, finisher: bool) -> void:
	var at := Vector3(e.pos.x, 1.0 + e.y, e.pos.y) - Vector3(away.x, 0, away.y) * 0.3
	var lean := tan(_look.randf_range(-GASH_LEAN, GASH_LEAN))
	var length := GASH_HEAVY if heavy else GASH.y if finisher else _look.randf_range(GASH.x, GASH.y)
	fx.gash(at, Vector3(axis.x, lean, axis.y), color, length, heavy, GASH_TIME.y if heavy or finisher else GASH_TIME.x)
	# the snap at the contact (vfx_pass_spec.md V-05)
	fx.contact(at, Vector3(axis.x, 0.0, axis.y), color, heavy or finisher)
	fx.chips(at, Vector3(away.x, 0.35, away.y), CHIP_COLOR, _look.randi_range(GASH_CHIPS.x, GASH_CHIPS.y), CHIP_SPEED, CHIP_SIZE, CHIP_LIFE, 0.7)


## The way the blade was moving where it met an enemy, on the floor plane: along the thrust for a line, across the
## line from the paladin for an arc or a spin (so two enemies on opposite sides of the arc are cut at different
## angles). flip: the arc's sweep (Fx.slash).
static func cut_axis(shape: ComboNode.Shape, origin: Vector2, at: Vector2, away: Vector2, flip: bool) -> Vector2:
	if shape == ComboNode.Shape.LINE:
		return away
	var out := at - origin
	if out.length_squared() < 0.0001:
		out = away
	out = out.normalized()
	return Vector2(-out.y, out.x) if flip else Vector2(out.y, -out.x)


## The hit stop of a blow as Hades II plays it (GF-01): the world keeps its speed for the move's wait
## (ComboNode.hit_stop_ms), then slows to hit_slow_scale for hit_slow_ms (and extra_ms more when it kills), then comes
## back (HitStop). Never a freeze. One at most every HIT_SLOW_COOLDOWN seconds, as there.
func _hit_slow(node: ComboNode, extra_ms: float = 0.0) -> void:
	if _slow_cd > 0.0 or node.hit_slow_ms <= 0.0:
		return
	_slow_cd = HIT_SLOW_COOLDOWN
	var k := Feel.live().hit_stop_scale
	fx.blow_stop(node.hit_stop_ms * k, (node.hit_slow_ms + extra_ms) * k, node.hit_slow_scale)


## How hard the camera jolts when this move lands (times Fx.KICK_METERS): KICK_COMMON, KICK_FINISHER or KICK_OMEGA.
static func kick_of(node: ComboNode) -> float:
	if node.has_tag(OMEGA_TAG):
		return KICK_OMEGA
	return KICK_FINISHER if node.has_tag(&"finisher") else KICK_COMMON


## A finisher holds at the top of its swing: the blade gathers light (Fx.glint) and bursts when it lands.
## tip: the point of the sword to follow (none: a point in front of the paladin).
func glint(node: ComboNode, origin: Vector2, dir: Vector2, time: float, tip: Node3D = null) -> void:
	var at := origin + dir * GLINT_AHEAD
	fx.glint(Vector3(at.x, GLINT_HEIGHT, at.y), color_of(node.tags), time, tip)


## A blow big enough for slow motion: it fells several at once or lands on a crowd.
static func wants_slow_mo(struck: int, kills: int) -> bool:
	return kills >= SLOW_MO_KILLS or struck >= SLOW_MO_CROWD


## A hit earns the impact frame when it is an Omega that lands or the blow that ends a boss's phase (phase_broken),
## and the last frame is at least Feel.impact_frame_every seconds old (cooldown_left: what is left of it).
static func wants_impact_frame(omega: bool, phase_broken: bool, cooldown_left: float) -> bool:
	return (omega or phase_broken) and cooldown_left <= 0.0


## True when this hit takes a boss down to the floor of his phase (Enemy.hp_floor: the next phase begins) or kills
## him. hp_before: his life before the hit.
static func breaks_phase(e: Enemy, hp_before: float) -> bool:
	if e.def.behavior != EnemyDef.Behavior.BOSS or hp_before <= e.hp_floor:
		return false
	return e.hp <= e.hp_floor or not e.alive


## Flashes the impact frame if this hit earns it (wants_impact_frame) and starts its cooldown.
func _impact_frame(omega: bool, phase_broken: bool) -> void:
	if not wants_impact_frame(omega, phase_broken, _frame_cd):
		return
	if fx.impact_frame():
		_frame_cd = Feel.live().impact_frame_every


## The paladin lets go of the circle of light at a point. omega: the held version, which bursts when it ends.
func cast(at: Vector2, omega: bool) -> void:
	var radius := hero.cast_radius * (1.0 + boons.stat(&"cast_size_pct"))
	var z := ground.add_zone(Ground.Kind.BIND, at, radius, hero.cast_time, boons.stat(&"cast_dps", CAST_TAGS), CAST_TAGS)
	if omega:
		z.burst = hero.cast_burst * (1.0 + boons.stat(&"damage_pct", CAST_TAGS))
	fx.ring(at, radius, CAST_COLOR, 0.3)
	fx.hero_burst(&"light", Vector3(at.x, 0.4, at.y))
	Audio.play(CombatSounds.EVENTS[&"circle_omega" if omega else &"circle"])


## The held circle of light runs out: everything inside takes the burst.
func cast_burst(z: Ground.Zone) -> void:
	horde.in_circle(z.pos, z.radius, _hits)
	fx.ring(z.pos, z.radius * 1.1, CAST_COLOR, 0.3)
	fx.chips(Vector3(z.pos.x, 0.6, z.pos.y), Vector3.UP, CAST_COLOR, 12, 7.0, 0.12, 0.4, 1.3)
	fx.shake(2.0)
	_mats.clear()
	source = &"cast_omega"
	for e: Enemy in _hits.duplicate():
		var away := (e.pos - z.pos).normalized() if e.pos.distance_to(z.pos) > 0.01 else Vector2.RIGHT
		hit_enemy(e, z.burst, z.tags, away, 10.0, true, true)
		if not e.invulnerable:
			_mats.append(CombatSounds.material_of(e))
			_impact_frame(true, false)  # the held circle's burst is an Omega
	source = &""
	Audio.play(CombatSounds.EVENTS[&"circle_burst"])
	_play_material(CombatSounds.loudest(_mats))


## A friendly projectile (wave or light blade) touched an enemy.
func on_shot_hit(e: Enemy, shot: Projectiles.Shot) -> void:
	var along := shot.vel.normalized()
	if shot.kind != Projectiles.Kind.BLADE and shot.seen.size() <= MAX_STARS:
		var at := Vector3(e.pos.x, 1.0 + e.y, e.pos.y)
		if shot.kind == Projectiles.Kind.SPARK:
			# the dart: a puncture star, chips with the gold of the blade's veins
			fx.impact(at, shot.color, SPECIAL_STAR, GASH_TIME.y)
			fx.chips(at, Vector3(along.x, 0.3, along.y), shot.color, GASH_CHIPS.x, 7.0, 0.1, 0.35, 0.6, 2)
		else:
			# the held special: a crossed streak along its flight
			fx.gash(at, Vector3(along.x, 0.0, along.y), shot.color, STAB, true, GASH_TIME.y)
			fx.chips(at, Vector3(along.x, 0.3, along.y), shot.color, GASH_CHIPS.x, 7.0, 0.1, 0.35, 0.6)
	kill_blow = -shot.get_instance_id()
	hit_enemy(e, shot.damage, shot.tags, along, shot.knockback, false)
	kill_blow = 0
	if not e.invulnerable:
		Audio.play(CombatSounds.EVENTS[&"dart_hit"])
		_play_material(CombatSounds.material_of(e))
		if not shot.counted:
			# the special's wave lands with its first enemy (the passive counts its Omega once)
			shot.counted = true
			landed.emit(null, shot.tags, 1)
	_apply_status(e, shot.status, shot.status_power)


func on_zone_hit(e: Enemy, z: Ground.Zone) -> void:
	match z.kind:
		Ground.Kind.MARK:
			hit_enemy(e, z.power * Ground.TICK, MARK_TAGS, Vector2.ZERO, 0.0, false)
		Ground.Kind.EMBER:
			hit_enemy(e, z.power * Ground.TICK, EMBER_TAGS, Vector2.ZERO, 0.0, false)
			_burn(e, z.power)
		Ground.Kind.HOLY:
			hit_enemy(e, z.power * Ground.TICK, z.tags if not z.tags.is_empty() else HOLY_TAGS, Vector2.ZERO, 0.0, false)
			e.slow_t = maxf(e.slow_t, 0.5)
		Ground.Kind.STEAM:
			if not e.def.heavy:
				e.blind_t = 1.0
		Ground.Kind.STONE:
			# the Rocha's stone (E4): whoever stands in it is slowed
			e.slow_t = maxf(e.slow_t, Ground.TICK * 2.0)
		Ground.Kind.BIND:
			if z.strike > 0.0 and not z.struck.has(e):
				# the Sentinela's circle (E4): a blow of light on each one as it comes in, once a circle
				z.struck[e] = true
				source = z.source
				hit_enemy(e, z.strike, z.tags, (e.pos - z.pos).normalized() if e.pos.distance_to(z.pos) > 0.01 else Vector2.RIGHT, 6.0, false)
				source = &""
				fx.burst(&"light", Vector3(e.pos.x, 1.0, e.pos.y))
				if not e.alive:
					return
			# held in place (the boss only slowed), plus whatever the cast gifts add
			if e.def.behavior == EnemyDef.Behavior.BOSS:
				e.slow_t = maxf(e.slow_t, Ground.TICK * 2.0)
			else:
				e.stun_t = maxf(e.stun_t, Ground.TICK + 0.05)
			if z.power > 0.0:
				hit_enemy(e, z.power * Ground.TICK, z.tags, Vector2.ZERO, 0.0, false)
			else:
				var burn := boons.stat(&"burn_dps", z.tags)
				if burn > 0.0:
					_burn(e, burn)
				var freeze := boons.stat(&"freeze_time", z.tags)
				if freeze > 0.0 and e.frozen_t <= 0.0:
					_freeze(e, freeze)


## A gift's skill hits an enemy: damage plus the skill's own status (burn, freeze, stun, slow).
func skill_hit(e: Enemy, damage: float, tags: Array[StringName], away: Vector2, knockback: float, status: StringName, power: float) -> bool:
	var died := hit_enemy(e, damage, tags, away, knockback, false)
	if not died:
		_apply_status(e, status, power)
	return died


func _apply_status(e: Enemy, status: StringName, power: float) -> void:
	if power <= 0.0 or not e.alive or e.invulnerable:
		return
	match status:
		&"burn":
			_burn(e, power)
		&"freeze":
			_freeze(e, power)
		&"stun":
			if e.def.behavior != EnemyDef.Behavior.BOSS:
				e.stun_t = maxf(e.stun_t, power * (0.5 if e.def.heavy else 1.0))
		&"slow":
			e.slow_t = maxf(e.slow_t, power)


## One enemy takes one hit, with every gift applied. counts: it is a blow of the paladin (feeds the combo counter).
## Returns true when it died.
func hit_enemy(e: Enemy, base: float, tags: Array[StringName], away: Vector2, knockback: float, counts: bool = true, big: bool = false) -> bool:
	if e.invulnerable:
		# a ward (Morvath's ritual shield): no flash, no number, no burn or frost, no combo; a few sparks where a blow
		# or a shot struck it (not the ticks of a zone he stands in)
		if counts or knockback > 0.0:
			_ward_spark(e, away)
		return false
	var frozen := e.frozen_t > 0.0
	var shatter := boons.stat(&"shatter_pct") if frozen and counts else 0.0
	var dmg := DamageCalc.hit(base, boons.stat(&"damage_pct", tags), e.air_t > 0.0, frozen and shatter > 0.0, shatter, e.def.undead, boons.stat(&"undead_mult"))
	var hp_before := e.hp
	kill_tags = tags
	horde.dealing = source if source != &"" else DealtBy.source(tags)
	horde.stun_scale = 1.0 + boons.stat(&"stun_pct", tags)
	var died := horde.damage(e, dmg, away, knockback, number_color(tags, big), true, big)
	horde.stun_scale = 1.0
	kill_tags = []
	horde.dealing = &""
	_impact_frame(tags.has(OMEGA_TAG), breaks_phase(e, hp_before))
	damage_dealt += dmg
	enemy_struck.emit(e, tags, dmg)
	if counts:
		combo += 1
		best_combo = maxi(best_combo, combo)
		_combo_t = COMBO_KEEP
		combo_changed.emit(combo)
	if shatter > 0.0:
		e.frozen_t = 0.0
		fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
		fx.ring(e.pos, SHATTER_RADIUS, FROST, 0.3)
		horde.in_circle(e.pos, SHATTER_RADIUS, _near)
		horde.dealing = &"shatter"
		for other in _near.duplicate():
			if other != e:
				horde.damage(other, maxf(1.0, roundf(dmg * SHATTER_SPLASH)), (other.pos - e.pos).normalized(), 5.0, FROST)
		horde.dealing = &""
	if died:
		return true
	var burn := boons.stat(&"burn_dps", tags)
	if burn > 0.0:
		_burn(e, burn)
	var freeze := boons.stat(&"freeze_time", tags)
	if freeze > 0.0 and shatter <= 0.0:
		_freeze(e, freeze)
	return false


## The layer of a material over a blow's hit (CombatSounds.MATERIAL_SOUND; none for &"").
func _play_material(m: StringName) -> void:
	var sound := CombatSounds.material(m)
	if sound != &"":
		Audio.play(sound)


## A blow on a ward: a few small spectral sparks on its face, toward the striker (FxBudget keeps a flurry cheap).
func _ward_spark(e: Enemy, away: Vector2) -> void:
	Audio.play(CombatSounds.EVENTS[&"ward"])
	var at := e.pos - away * e.def.radius * WARD_SPARK_REACH
	fx.chips(Vector3(at.x, 1.4 + e.y, at.y), Vector3(-away.x, 0.3, -away.y), WARD_SPARK, WARD_SPARK_COUNT, 4.0, 0.07, 0.25, 0.8)


func _freeze(e: Enemy, time: float) -> void:
	if e.def.behavior == EnemyDef.Behavior.BOSS or e.invulnerable:
		return
	if e.burn_t > 0.0:
		_steam(e)
	e.frozen_t = maxf(e.frozen_t, time * (0.4 if e.def.heavy else 1.0))
	fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))


func _burn(e: Enemy, dps: float) -> void:
	if e.invulnerable:
		return  # nothing takes hold through a ward (it would glow through it: crowd.gdshader's burn)
	if e.frozen_t > 0.0:
		_steam(e)
	e.burn_t = BURN_TIME
	e.burn_dps = maxf(e.burn_dps, dps)


## Flame meeting frost: a cloud of steam that blinds whoever stands in it.
func _steam(e: Enemy) -> void:
	var time := boons.stat(&"steam_time")
	if time > 0.0:
		ground.add_zone(Ground.Kind.STEAM, e.pos, 2.8, time, 0.0)
		fx.burst(&"dust", Vector3(e.pos.x, 0.8, e.pos.y))


## The colour of a blow: the family of the gift that changes it; Elun's gold for the other gifts; the green of
## the sword when no gift touches it.
func color_of(tags: Array[StringName]) -> Color:
	if tags.has(&"chama") or tags.has(&"ember") or boons.stat(&"burn_dps", tags) > 0.0:
		return FIRE
	if tags.has(&"geada") or boons.stat(&"freeze_time", tags) > 0.0:
		return FROST
	if tags.has(&"vigilia"):
		return VIGIL
	for t in GIFT_TAGS:
		if tags.has(t):
			return LIGHT
	return EMETH


## The colour of a damage number: the gift's own (fire, frost, Elun's gold); for the sword alone, its emerald only
## on the big blows (finishers and the held ones), pale on the rest.
func number_color(tags: Array[StringName], big: bool) -> Color:
	var color := color_of(tags)
	if color != EMETH:
		return color
	return EMETH if big or tags.has(&"omega") else NUMBER_PALE


## Where a move hits and what is drawn for it. The arc on screen covers exactly what the blow reaches
## (tests/test_combo.gd checks every move of the tree). reach_pct: the gifts' bonus to reach.
static func swing_shape(node: ComboNode, reach_pct: float, width_pct := 0.0) -> Dictionary:
	var reach := node.reach * (1.0 + reach_pct)
	match node.shape:
		ComboNode.Shape.CIRCLE:
			return {"hit_reach": reach, "hit_width": 360.0, "draw_reach": reach, "draw_width": 360.0}
		ComboNode.Shape.LINE:
			# a thrust: a narrow arc whose tip is the end of the line (width is meters across, not degrees)
			var across := node.width * (1.0 + width_pct)
			return {"hit_reach": reach, "hit_width": across, "draw_reach": reach, "draw_width": LINE_ARC * (1.0 + width_pct)}
	var arc := minf(node.width * (1.0 + width_pct), 360.0)
	return {"hit_reach": reach, "hit_width": arc, "draw_reach": reach, "draw_width": arc}
