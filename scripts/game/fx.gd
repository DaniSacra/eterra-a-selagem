class_name Fx
extends Node3D
## Everything that only shows: particle bursts, sword arcs, thrusts, cuts, motes, shockwaves, pillars of light, damage numbers,
## camera shake, hit stop and the full screen colour split. Pooled; nothing here changes the game.

const SLASH := preload("res://assets/shaders/slash.gdshader")
## Morvath's scythe and the wake of his dash and of his crescents (cycle 9): each drawn only over what it hurts.
const BOSS_SCYTHE := preload("res://assets/shaders/boss_scythe.gdshader")
const WAKE := preload("res://assets/shaders/boss_wake.gdshader")
const BOSS_POOL := 3
## The scythe's sector starts this share of its reach out from his middle (his own body covers the rest).
const BOSS_SCYTHE_INNER := 0.1
const INK := preload("res://assets/shaders/slash_ink.gdshader")
const RING := preload("res://assets/shaders/ring.gdshader")
const SMOKE_RING := preload("res://assets/shaders/smoke_ring.gdshader")
## The snap where a blow lands (V-05): its shader, pool, life (3 frames), growth and size (metres, half a quad).
const CONTACT := preload("res://assets/shaders/contact.gdshader")
const CONTACT_POOL := 12
## V-09: the crystal spikes of the Judgement Cut (crystal_spike.gdshader): how many at once, how long one lives, the
## share of it spent growing and the share from which it breaks (into SPIKE_CHIPS chips), its base radius (m).
const SPIKE := preload("res://assets/shaders/crystal_spike.gdshader")
const SPIKE_POOL := 14
const SPIKE_TIME := 0.42
const SPIKE_GROW := 0.08
const SPIKE_BREAK := 0.17
const SPIKE_RADIUS := 0.24
const SPIKE_CHIPS := 4
const SPIKE_SCREEN := 215
## VFX pass P1-1 and P1-2: the screen value the snap's heart and the gash's core stop at (ScreenTone.linear_peak),
## with room under the rule's 226 for the bloom and what lies under them.
const CONTACT_SCREEN := 210
const GASH_SCREEN := 210
const CONTACT_TIME := 0.08
## CF2-07: the small light every blow leaves on the one struck (blow 1, 2, 3), its reach and time, and the 4 slivers.
const CONTACT_LIGHT: Array[float] = [1.0, 1.4, 1.8]
const CONTACT_LIGHT_RANGE := 3.0
const CONTACT_LIGHT_TIME := 0.08
const CONTACT_SPARKS := 4
const CONTACT_SPARK_LIFE := 0.15
const CONTACT_GROW := 1.4
const CONTACT_SPIKES := Vector2(0.4, 0.9)
const CONTACT_SPIKES_HEAVY := Vector2(0.6, 1.4)
## An enemy's blow landing (smoke_ring): how many may show at once, the screen's ceiling of its rim (V-12: 205) and the
## dirty embers and smoke it leaves.
const SMOKE_RING_POOL := 12
## vfx_pass_spec.md 5.3, the forms of the families: the floor marks (family_mark.gdshader) and their screen peaks
## (section 4: Chama, Geada and Luz up to 210, Vigília 195), the tongues a Chama cut leaves, the ray of Luz.
const FAMILY_MARK := preload("res://assets/shaders/family_mark.gdshader")
const MARK_POOL := 12
const MARK_SCREEN: Array[int] = [210, 210, 210, 195, 210]
const MARK_FORM := {Boon.Family.CHAMA: 0, Boon.Family.GEADA: 1, Boon.Family.LUZ: 2, Boon.Family.VIGILIA: 3}
const FAMILY_SLASH_TONGUES := Vector2i(3, 5)
const LUZ_RAY := Vector3(0.06, 5.0, 0.15)
const VIGIL_HIT := Vector3(1.8, 0.3, 30.0)
const SMOKE_RING_SCREEN := 205
const SMOKE_RING_EMBERS := 7
const BEAM := preload("res://assets/shaders/beam.gdshader")
const IMPACT := preload("res://assets/shaders/impact.gdshader")
const IMPACT_POOL := 40
const THRUST := preload("res://assets/shaders/emeth_thrust.gdshader")
const THRUST_POOL := 4
## V-04: seconds the thrust's light takes to reach its point and to leave it, and the crystal spikes of the Omega.
const THRUST_IN := 0.06
const THRUST_OUT := 0.15
const THRUST_SPIKES := 5
## Motes: the specks of magic a swing sheds and the chips of a blow landing, all in one MultiMesh.
const MOTE_POOL := 192
const MOTE_GRAVITY := 5.0
const MOTE_DRAG := 3.5
## The light of a pillar (beam.gdshader's intensity) when nothing asks for less.
const BEAM_INTENSITY := 2.5
## How bright a pillar may get, as a share of the light that keeps its colour at ScreenTone.SAFE on the screen
## (cycle C12c, GP-01): every column of the game (reward, fountain, a gift taken, a gift falling, an elite rising, an
## eruption) keeps its colour and stays under 235 on the screen, never white over the floor, the paladin or Morvath.
## BEAM_NO_CAP only when asked for by name.
const BEAM_CORE_CAP := 1.0
const BEAM_NO_CAP := 1000.0
## Old gold, lit: one mote in MOTE_GOLD_EVERY (the veins of the blade).
const OLD_GOLD := Color(0.95, 0.72, 0.3)
const MOTE_GOLD_EVERY := 4
## How bright a mote is (times its colour): small, so it may pass the glow threshold.
const MOTE_GLOW := 2.2
## The specks as slivers (chip.gdshader, C12d VX-10): width as a share of their size, length as the seconds of
## their flight they streak (at least MOTE_LONG.x, at most MOTE_LONG.y times their width).
const MOTE_WIDTH := 0.5
const MOTE_STREAK := 0.03
const MOTE_LONG := Vector2(2, 4)
const CHIP := preload("res://assets/shaders/chip.gdshader")
## The blade's pulse on a swing: seconds it takes to fall back (EmethSword.PULSE_GLOW at its top).
const BLADE_PULSE := 0.15
const GLINT := preload("res://assets/shaders/glint.gdshader")
const CRESCENT := preload("res://assets/shaders/crescent.gdshader")
const GLINT_POOL := 4
## Meters across the quad of a finisher's glint (its long streak reaches the edges).
const GLINT_SIZE := 13.0
## Seconds the glint takes to burst and fade after its hold.
const GLINT_BURST := 0.16
const CRESCENT_POOL := 8
## N2 (identidade_c1v 2.3): a finisher's second crescent, a thin line of old gold only, this much bigger and late (a
## slower head: the sweep share it takes) so the third blow reads apart from the first in a still frame.
const CRESCENT_ECHO_SIZE := 1.2
const CRESCENT_ECHO_SWEEP := 1.35
## A finisher's crescent flies out to this many times the reach of the blow while it fades.
const CRESCENT_GROW := 1.7
## Seconds it lasts (the light edge goes in the first half, the ink lingers).
const CRESCENT_TIME := 0.34
## Where its band starts, as a share of the reach (lower is a broader sweep): a thin blade of a wave, under a
## meter across when it has flown out.
const CRESCENT_INNER := 0.5
## The longest reach it is drawn with: the wave of a long thrust stays a crescent at the paladin, not across the room.
const CRESCENT_MAX_REACH := 5.5
## Share of the ink opacity (Feel.ink_opacity) its dark body keeps: lighter than a blow, so the white edge leads.
const CRESCENT_INK := 0.28
## V-02: the degrees the spin's ribbon sweeps, and a finisher's at least and at most.
const CRESCENT_SPIN := 300.0
const CRESCENT_ARC := Vector2(140.0, 200.0)
## SR-G4: the half-moon is white and gold: its colour goes this far toward gold, its head and tail are this many times the
## band wide, its edge goes this far toward white and the body is this light (crescent.gdshader's body_light).
const CRESCENT_GOLD := 0.6
const CRESCENT_HEAD := 0.75
const CRESCENT_TAIL := 0.2
const CRESCENT_PALE := 0.8
const CRESCENT_BODY := 0.65
## N4 (art review 2026-11-24): the spin's ribbon is the Emeth's green (not the gold blend), added to the floor, under this
## screen peak (the paladin stays the lightest thing), its ends fading over CRESCENT_SPIN_TIPS of the swing.
const CRESCENT_SPIN_GREEN := Color(0.3, 0.85, 0.55)
const CRESCENT_SPIN_PEAK := 0.5
const CRESCENT_SPIN_TIPS := 0.12
const KICK_METERS := 0.35
const GOLD := Color(1.0, 0.82, 0.38)
## 2026-11-24 strength pass: a short point light on a strong blow (Forward+ only; Compatibility keeps no light, it would
## recompile every material). At most LIGHT_POOL at once, the oldest is taken; energy and range in the call.
const LIGHT_POOL := 3
const LIGHT_TIME := 0.14
const LIGHT_WARM := Color(1.0, 0.78, 0.45)
## The pieces of stone and bone dust a shock throws (grey brown, under the glow), its rings, in meters per radius.
const STONE := Color(0.5, 0.45, 0.38)
const SHOCK_CHIPS := Vector2i(7, 14)
const SHOCK_OUTER := 1.45
## AD2-05: the lit rings (the shock's and the Brado's): width of the line in m, its light, how far it goes toward ivory.
const RING_BRIGHT_M := 0.14
const RING_BRIGHT_LIGHT := 2.4
const RING_BRIGHT_IVORY := 0.75
## 2026-11-24: the cut on a struck enemy is this much longer and lingers this much more.
const GASH_BOOST := 1.3
const GASH_LIFE := 1.25
const SLASH_POOL := 18
## Where the ink of a sword arc starts, as a share of its reach (lower is a fatter crescent of ink). C12d (VX-01): the
## mesh runs from near the paladin; the shaders draw only up to the blade's edge (BLADE_REACH), so the band no longer
## sets where the cut shows.
const INK_INNER := 0.05
## Where the mesh of the light of a cut starts, as a share of the reach (slash.gdshader draws a fine edge at
## BLADE_REACH and a soft core just inside it, nothing past the tip).
const SLASH_INNER := 0.05
## Meters from the paladin to the Emeth's tip in a swing, on the floor: where the edge of every cut of his is drawn
## (reach_m and blade_m in slash.gdshader and slash_ink.gdshader). Measured on the model in the swing frames of cut1
## to cut3 (the tip, EmethSword.TIP, from 2.3 m as it drops through to 2.85 m level with the waist; C12d).
const BLADE_REACH := 2.6
## Seconds of its sweep a cut already shows on the frame of the blow (one frame at 60): it starts with the blade,
## never a frame behind it (VX-01).
const SLASH_LEAD := 1.0 / 60.0
## The arc lives at least this long whatever the swing's own time (0.12 s was under 4 frames at 30 fps: a capture a frame
## every 0.1 s never caught the cut; the head still sweeps in Feel.slash_sweep_time, the rest is the tail fading).
const SLASH_MIN_LIFE := 0.34
## The ribbon's tail behind the head of the swing: at most this share of the arc, and at most this many degrees
## (a spin all around keeps a blade of light, not a full disc).
const SLASH_TAIL := 0.8
const SLASH_TAIL_DEGREES := 170.0
## SR-G4: how far the plain cut's colour goes toward gold, and its core's depth and light (slash.gdshader core_depth, core_light).
const SLASH_GOLD := 0.3
const SLASH_CORE := Vector2(0.82, 0.62)
## 2026-11-24 (strength pass): the cut's light is this much brighter than Feel.slash_intensity (the shader's own cap keeps it under the screen's 226).
const SLASH_BOOST := 1.35
## AD2-02 (art review 2026-11-25): the paladin's own arc in the stylized look (a blade given; the volleys and bosses keep the
## shader's defaults): the core's light (it was style_core_light 0.216) and depth (0.6), the veil of its ink (0.72), and a
## fine edge past the cap on the wire only (style_wire_glow, nothing past 1.3 in a channel).
const SLASH_STYLE_CORE_LIGHT := 0.35
const SLASH_STYLE_CORE_DEPTH := 0.75
const SLASH_STYLE_VEIL := 1.0
const SLASH_STYLE_WIRE := 1.5
const RING_POOL := 16
## How a ring of the pool ages: it opens and fades on its own (a burst), the caller moves it (a wave), or it fades where it is.
const RING_OPEN := 0
const RING_HELD := 1
const RING_FADE := 2
const BEAM_POOL := 24
const NUMBER_POOL := 32
## Damage numbers and floating words: font sizes in pixels at 720 lines (small and white, as in the references)
## and the dark outline around them.
const NUMBER_SIZE := 22
const NUMBER_BIG := 30
## GR-27: damage over time keeps this share of a direct number's height at least, a colour of this value and edge.
const TICK_SHARE := 0.7
const TICK_VALUE := 0.75
const TICK_MIN_SAT := 0.3
const TICK_OUTLINE := 3
const TICK_FALLBACK := Color(0.3, 1.0, 0.45)
const WORD_SIZE := 21
## Gold picked up (gold): its size, its pale old gold, and how far apart two drops still join one word.
const GOLD_SIZE := 14
const GOLD_WORD := Color(0.84, 0.72, 0.47)
const GOLD_JOIN := 6.0
## The gold rises beside the blow's number, not over it (QW-115, "60" under "+1 ouro"): metres to the right on the
## screen of where it fell.
const GOLD_SIDE := 1.1
const NUMBER_OUTLINE := 5
## Meters across the crossed cuts of Fx.impact (times the size asked for).
const IMPACT_SIZE := 1.0
## A damage number starts this far above the point asked for (the top of the enemy's head): clear of the life bar
## that sits there (CrowdRenderer.BAR_ABOVE), a quarter of a meter above it.
const NUMBER_LIFT := 1.0
## Which numbers show is NumberTally's: one per target that counts up while the hits keep coming, at most
## NUMBER_CROWD within NUMBER_CROWD_RADIUS meters and NumberTally.MAX_SHOWN on screen; finishers never hidden.
const NUMBER_CROWD := NumberTally.CROWD
const NUMBER_CROWD_RADIUS := NumberTally.CROWD_RADIUS
## What may start in one frame (FxBudget): chips and motes, cuts on the struck, particle bursts. Past it, nothing
## more is drawn that frame (a swing through a pack piled cuts, chips and numbers on the paladin).
const BUDGET_MOTES := 40
const BUDGET_GASHES := 8
const BUDGET_BURSTS := 6
## Particle bursts are drawn this much smaller than their BURSTS size, with this share of their specks.
const BURST_SCALE := 0.7
const BURST_AMOUNT := 0.7
const SHAKE_METERS := 0.12

## kind -> [colour, amount, speed, gravity, size, lifetime, spread (degrees), form]. vfx_pass_spec.md 5.6: no round
## soft dot any more (they read as soap bubbles round the paladin): `chip` bursts are slivers in the motes' MultiMesh
## (chip.gdshader, stretched along their flight), `wisp` bursts are smoke wisps with a torn edge (wisp.gdshader), and
## every colour stays under 1 per channel (under the glow; the shaders cap them under the screen's 226). gravity:
## upward acceleration (m/s2, negative falls). fire also leaves FIRE_SMOKE dark wisps.
const BURSTS := {
	&"spark": [Color(0.95, 0.9, 0.78), 8, 9.0, -6.0, 0.16, 0.16, 50.0, &"chip"],
	&"bone": [Color(0.6, 0.56, 0.48), 12, 6.5, -16.0, 0.26, 0.7, 75.0, &"chip"],
	&"fire": [Color(0.95, 0.57, 0.15), 10, 4.0, 3.0, 0.3, 0.5, 80.0, &"chip"],
	&"frost": [Color(0.48, 0.78, 0.95), 8, 6.0, -8.0, 0.24, 0.35, 80.0, &"chip"],
	# the paladin's light (a gift taken, an Omega charged, the circle): ivory slivers rising, under the glow, never a
	# saturated yellow over him (ART-009 of cycle 10); drawn behind him from the camera (hero_burst)
	&"light": [Color(0.9, 0.84, 0.7), 10, 4.0, 2.0, 0.26, 0.7, 90.0, &"chip"],
	# an enemy rising: dark smoke with a faint carmine edge (never the paladin's light)
	&"shadow": [Color(0.2, 0.08, 0.09), 8, 3.0, 1.5, 0.6, 0.8, 90.0, &"wisp"],
	&"dust": [Color(0.42, 0.4, 0.38), 6, 2.5, 0.5, 0.6, 0.6, 70.0, &"wisp"],
	# healing: ivory-rose slivers rising (the heart, hue 345), never the Emeth's green
	&"heal": [Color(0.95, 0.71, 0.77), 10, 2.5, 2.5, 0.26, 0.8, 90.0, &"chip"],
	# a boss's souls and necromancy: a cold, pale smoke that rises slowly (never Emeth's crystal green; C18 ART P1-4:
	# small, hue pulled to the blue, under the glow)
	&"soul": [Color(0.45, 0.88, 0.9), 10, 2.2, 2.2, 0.3, 0.9, 80.0, &"wisp"],
	# a curse: dark purple wisps
	&"curse": [Color(0.55, 0.15, 0.8), 10, 1.6, 1.2, 0.4, 0.7, 90.0, &"wisp"],
}
## A fire burst's dark smoke at its end: so many wisps, their colour.
const FIRE_SMOKE := 2
const SMOKE := Color(0.12, 0.1, 0.09)
## V-16: dark violet wisps the scythe's reach sheds (so many along the arc).
const SCYTHE_WISPS := 7
const SCYTHE_SMOKE := Color(0.16, 0.07, 0.24)
## The dodge's trail (V-08, AP-2; dodge_ghost.gdshader): a silhouette of the paladin left every GHOST_EVERY s of the
## dodge, at most GHOST_MAX a dodge, each fading over GHOST_TIME s; the first on the dodge's first frame. Only the look.
const DODGE_GHOST := preload("res://assets/shaders/dodge_ghost.gdshader")
const GHOST_EVERY := 0.05
const GHOST_MAX := 4
const GHOST_TIME := 0.12
## How much a wisp's colour covers what is behind it (premultiplied alpha), by how bright it is: dark smoke covers,
## pale souls mostly add.
const WISP_COVER := 0.75
const WISP_POOL := 96
const WISP := preload("res://assets/shaders/wisp.gdshader")
## The motes' light at most (linear, before the exposure): the screen's ScreenTone.SAFE for white (chip.gdshader).
const MOTE_CAP_SCREEN := 226
## The shapes of a sliver (chip.gdshader, vfx_pass_spec.md 5.3).
const SHAPE_LENS := 0
const SHAPE_BARB := 1
const SHAPE_TONGUE := 2

var camera: Camera3D
## Where damage numbers are drawn (a Control over the 3D view).
var overlay: Control
## The hit stop playing (HitStop, GF-01: the world slows, never freezes). stop_left: real seconds left of it (setting
## it to 0 ends it).
var hits := HitStop.new()
var stop_left: float:
	get:
		return hits.left()
	set(value):
		if value <= 0.0:
			hits.clear()
## The speed of the world this frame (tick: slow motion times hit stop; 1 = full speed) and the real seconds the
## frame took. Game steps the world by real_dt * rate.
var rate := 1.0
var real_dt := 0.0
## The "rumble" option: false, the gamepad never vibrates (Game.apply_options reads it from the save).
var rumble := true
## Strength of the colour split on screen (0..1), read by the screen pass.
var split := 0.0
## Seconds left of the impact frame (the screen in flat black and white), read by the screen pass.
var frame_left := 0.0
var shake_scale := 1.0
## The "impact_frames" option (SaveData): false, no impact frame ever.
var impact_frames := true
## The "slow_motion" option: false, no slow motion (nor its zoom and radial blur); the world keeps its speed.
var slow_motion := true
## The "color_split" option: false, the screen never splits its colours.
var color_split := true
## When >= 0, sword arcs hold at this point of their life (the --lab still).
var freeze_t := -1.0
## The moment of slow motion now playing (Hades II slows the whole world on the last kill of a fight and on the
## biggest blows): how much the camera closes in (1 = not at all) and the radial blur and bloom of the screen pass (0..1).
var zoom := 1.0
var radial := 0.0
var _slow_on := false
var _slow_fraction := 1.0
var _slow_in := 0.05
var _slow_hold := 0.0
var _slow_out := 0.3
var _slow_zoom := 1.0
var _slow_blur := 0.0
var _slow_t := 0.0
## A slow motion asked for during a hit stop waits for it to end (GF-05: else the two together read as a freeze).
var _slow_wait := false
var _shake := 0.0
var _slashes: Array[Dictionary] = []
var _inks: Array[Dictionary] = []
var _impacts: Array[Dictionary] = []
var _thrusts: Array[Dictionary] = []
var _motes: MultiMesh
var _mote_n := 0
var _mote_pos := PackedVector3Array()
var _mote_vel := PackedVector3Array()
var _mote_life := PackedFloat32Array()
var _mote_time := PackedFloat32Array()
var _mote_size := PackedFloat32Array()
var _mote_color := PackedColorArray()
var _mote_grav := PackedFloat32Array()
## 1 where the mote came from a burst (showing(&"motes") counts only the swing's and the hits' own).
var _mote_burst := PackedByteArray()
## The sliver's shape (chip.gdshader): SHAPE_LENS, SHAPE_BARB, SHAPE_TONGUE.
var _mote_shape := PackedByteArray()
var _wisps: MultiMesh
var _wisp_n := 0
var _wisp_pos := PackedVector3Array()
var _wisp_vel := PackedVector3Array()
var _wisp_life := PackedFloat32Array()
var _wisp_time := PackedFloat32Array()
var _wisp_size := PackedFloat32Array()
var _wisp_color := PackedColorArray()
var _wisp_rise := PackedFloat32Array()
## The motes' MultiMesh buffer (12 floats of transform, 4 of colour each), sent in one call a frame.
var _mote_buf := PackedFloat32Array()
var _blade: ShaderMaterial
var _blade_looked := false
var _pulse := 0.0
var _glints: Array[Dictionary] = []
var _crescents: Array[Dictionary] = []
var _kick := Vector3.ZERO
var _rings: Array[Dictionary] = []
## Rings waiting their turn (ring_later).
var _later_rings: Array[Dictionary] = []
var _smoke_rings: Array[Dictionary] = []
var _contacts: Array[Dictionary] = []
var _spikes: Array[Dictionary] = []
var _marks: Array[Dictionary] = []
var _beams: Array[Dictionary] = []
var _lights: Array[Dictionary] = []
## The last pillar raised (beam): where, its intensity and cap (tests of GP-01).
var last_beam := {}
## One label per entry of the tally.
var _labels: Array[Label] = []
var _tally := NumberTally.new(NUMBER_POOL)
## The gold word showing (its entry in the tally, -1: none) and the sum it says.
var _gold_at := -1
var _gold_sum := 0
## The paladin's head in the world (Player sets it each frame): no number stands within NumberTally.HERO_CLEAR of it.
var hero_head := Vector3.INF
var budget := FxBudget.new({&"motes": BUDGET_MOTES, &"gashes": BUDGET_GASHES, &"bursts": BUDGET_BURSTS, &"contacts": BUDGET_GASHES, &"marks": BUDGET_GASHES})
var _font: Font
var _arc_meshes: Dictionary = {}
var _boss_scythes: Array[Dictionary] = []
var _boss_wakes: Array[Dictionary] = []
## Seconds the blade's light is held up (the ending: Emeth answers).
var _blade_hold := 0.0
static var _strip_mesh: ArrayMesh
var _rng := RandomNumberGenerator.new()


static func quad(size: float, color: Color) -> QuadMesh:
	var q := QuadMesh.new()
	q.size = Vector2(size, size)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.vertex_color_use_as_albedo = true
	m.albedo_color = color
	m.albedo_texture = soft_dot()
	m.disable_receive_shadows = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = m
	return q


static var _dot: GradientTexture2D

## A round soft dot, white in the middle.
static func soft_dot() -> GradientTexture2D:
	if _dot == null:
		_dot = GradientTexture2D.new()
		_dot.fill = GradientTexture2D.FILL_RADIAL
		_dot.fill_from = Vector2(0.5, 0.5)
		_dot.fill_to = Vector2(0.5, 0.0)
		_dot.width = 64
		_dot.height = 64
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.75))
		_dot.gradient = g
	return _dot


static func fade_ramp(c: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, c)
	g.set_color(1, Color(c.r, c.g, c.b, 0.0))
	return g


func setup(cam: Camera3D, over: Control) -> void:
	Dev.seed_rng(_rng, 6)
	camera = cam
	overlay = over
	_font = load("res://assets/fonts/AlegreyaSans-Bold.ttf")
	for i in SLASH_POOL:
		_inks.append(_effect_node(INK, null))
		_slashes.append(_effect_node(SLASH, null))
	for e in _inks:
		(e.mat as ShaderMaterial).render_priority = -1
	for e in _slashes:
		(e.mat as ShaderMaterial).render_priority = 1
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	for i in IMPACT_POOL:
		var e := _effect_node(IMPACT, q)
		(e.node as MeshInstance3D).sorting_offset = 10.0
		(e.node as MeshInstance3D).extra_cull_margin = 3.0
		_impacts.append(e)
	var strip := PlaneMesh.new()
	strip.size = Vector2.ONE
	for i in THRUST_POOL:
		var e := _effect_node(THRUST, strip)
		(e.mat as ShaderMaterial).render_priority = 1
		_thrusts.append(e)
	_build_motes()
	_build_wisps()
	var gq := QuadMesh.new()
	gq.size = Vector2.ONE
	for i in GLINT_POOL:
		var e := _effect_node(GLINT, gq)
		(e.node as MeshInstance3D).sorting_offset = 12.0
		_glints.append(e)
	for i in CRESCENT_POOL:
		var e := _effect_node(CRESCENT, null)
		(e.mat as ShaderMaterial).render_priority = 2
		_crescents.append(e)
	for i in BOSS_POOL:
		var e := _effect_node(BOSS_SCYTHE, null)
		(e.mat as ShaderMaterial).render_priority = 1
		_boss_scythes.append(e)
		var w := _effect_node(WAKE, strip())
		(w.mat as ShaderMaterial).render_priority = 1
		_boss_wakes.append(w)
	for i in RING_POOL:
		var plane := PlaneMesh.new()
		plane.size = Vector2(2, 2)
		_rings.append(_effect_node(RING, plane))
	var cq := QuadMesh.new()
	cq.size = Vector2(2, 2)
	for i in CONTACT_POOL:
		var e := _effect_node(CONTACT, cq)
		(e.node as MeshInstance3D).sorting_offset = 11.0
		(e.node as MeshInstance3D).extra_cull_margin = 2.0
		_contacts.append(e)
	var prism := CylinderMesh.new()
	prism.top_radius = 0.0
	prism.bottom_radius = 1.0
	prism.height = 1.0
	prism.radial_segments = 4
	prism.rings = 1
	prism.cap_top = false
	for i in SPIKE_POOL:
		var e := _effect_node(SPIKE, prism)
		e.delay = 0.0
		e.lean = Basis()
		e.foot = Vector3.ZERO
		e.tall = 1.0
		e.broke = false
		_spikes.append(e)
	for i in MARK_POOL:
		var plane := PlaneMesh.new()
		plane.size = Vector2(2, 2)
		var e := _effect_node(FAMILY_MARK, plane)
		(e.mat as ShaderMaterial).render_priority = -1
		_marks.append(e)
	for i in SMOKE_RING_POOL:
		var plane := PlaneMesh.new()
		plane.size = Vector2(2, 2)
		var e := _effect_node(SMOKE_RING, plane)
		(e.mat as ShaderMaterial).render_priority = -1
		_smoke_rings.append(e)
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.7
	cyl.bottom_radius = 1.0
	cyl.height = 1.0
	cyl.radial_segments = 16
	cyl.cap_top = false
	cyl.cap_bottom = false
	for i in BEAM_POOL:
		_beams.append(_effect_node(BEAM, cyl))
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		for i in LIGHT_POOL:
			var l := OmniLight3D.new()
			l.shadow_enabled = false
			l.visible = false
			l.light_energy = 0.0
			l.omni_range = 5.0
			add_child(l)
			_lights.append({"node": l, "mat": null, "life": 1.0, "time": LIGHT_TIME, "energy": 0.0})
	for i in NUMBER_POOL:
		var l := Label.new()
		l.add_theme_font_override(&"font", _font)
		l.add_theme_constant_override(&"outline_size", NUMBER_OUTLINE)
		l.add_theme_color_override(&"font_outline_color", Color(0.05, 0.02, 0.06, 0.9))
		l.visible = false
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		overlay.add_child(l)
		_labels.append(l)


func _build_motes() -> void:
	_motes = MultiMesh.new()
	_motes.transform_format = MultiMesh.TRANSFORM_3D
	_motes.use_colors = true
	# a sliver stretched along its flight (chip.gdshader turns it to the camera round its axis), never a round dot
	var sliver := QuadMesh.new()
	sliver.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = CHIP
	sliver.material = mat
	_motes.mesh = sliver
	_motes.instance_count = MOTE_POOL
	_motes.visible_instance_count = 0
	_mote_pos.resize(MOTE_POOL)
	_mote_vel.resize(MOTE_POOL)
	_mote_life.resize(MOTE_POOL)
	_mote_time.resize(MOTE_POOL)
	_mote_size.resize(MOTE_POOL)
	_mote_color.resize(MOTE_POOL)
	_mote_grav.resize(MOTE_POOL)
	_mote_burst.resize(MOTE_POOL)
	_mote_shape.resize(MOTE_POOL)
	mat.set_shader_parameter(&"cap", ScreenTone.linear_peak(Color.WHITE, MOTE_CAP_SCREEN))
	_mote_buf.resize(MOTE_POOL * 16)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = _motes
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# the motes fly anywhere in the room: never culled by the box of the first ones
	mmi.custom_aabb = AABB(Vector3(-60, -5, -60), Vector3(120, 30, 120))
	add_child(mmi)


func _build_wisps() -> void:
	_wisps = MultiMesh.new()
	_wisps.transform_format = MultiMesh.TRANSFORM_3D
	_wisps.use_colors = true
	_wisps.use_custom_data = true
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = WISP
	mat.set_shader_parameter(&"cap", ScreenTone.linear_peak(Color.WHITE, MOTE_CAP_SCREEN))
	q.material = mat
	_wisps.mesh = q
	_wisps.instance_count = WISP_POOL
	_wisps.visible_instance_count = 0
	for arr in [_wisp_pos, _wisp_vel, _wisp_life, _wisp_time, _wisp_size, _wisp_color, _wisp_rise]:
		arr.resize(WISP_POOL)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = _wisps
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.custom_aabb = AABB(Vector3(-60, -5, -60), Vector3(120, 30, 120))
	add_child(mmi)


func _effect_node(shader: Shader, mesh: Mesh) -> Dictionary:
	var mi := MeshInstance3D.new()
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mi.material_override = mat
	mi.mesh = mesh
	mi.visible = false
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return {"node": mi, "mat": mat, "life": 1.0, "time": 1.0, "grow": 0.0, "size": 1.0, "follow": null}


# ---------- what the game calls ----------

func burst(kind: StringName, pos: Vector3, dir: Vector3 = Vector3.ZERO) -> void:
	if not BURSTS.has(kind) or not budget.allows(&"bursts"):
		return
	var spec: Array = BURSTS[kind]
	if kind in CLEAR_OF_HERO:
		pos = clear_of_hero(pos)
	var up := (dir + Vector3.UP * 0.6).normalized() if dir != Vector3.ZERO else Vector3.UP
	var count := maxi(3, roundi(int(spec[1]) * BURST_AMOUNT))
	var spread := deg_to_rad(float(spec[6]))
	var size: float = spec[4] * BURST_SCALE
	if spec[7] == &"wisp":
		wisps(pos, up, spec[0], count, spec[2], size, spec[5], spread, spec[3])
		return
	var shape := SHAPE_TONGUE if kind == &"fire" else SHAPE_BARB if kind == &"frost" else SHAPE_LENS
	_spray(pos, up, spec[0], count, spec[2], size, spec[5], spread, -float(spec[3]), true, 0, shape)
	if kind == &"fire":
		wisps(pos + Vector3.UP * 0.3, Vector3.UP, SMOKE, FIRE_SMOKE, 0.8, 0.5, 0.8, 0.5, 1.0)
	elif kind == &"bone":
		# V-14: a dead one goes up as ash: one dark grey wisp rising about 1 m in 0.6 s
		wisps(pos, Vector3.UP, DEATH_ASH, 1, 1.4, 0.55, 0.6, 0.2, 0.6)
		# N2: the bone dust curls up short and settles (a pale wisp, wide, slow, never above the floor's light + 25)
		# AD2-06: it was born at the floor and read as a white blob there; now from the body (at least chest height: the
		# call from the death sits at 0.6) and falling a little, never a solid drop (wisp.gdshader's alpha is its own)
		wisps(Vector3(pos.x, maxf(pos.y, BONE_DUST_AT), pos.z), Vector3.UP, BONE_DUST, 3, 1.0, 0.5, 1.5, 1.9, -0.25)


## Smoke wisps (vfx_pass_spec.md 5.6, wisp.gdshader): soft torn cards that rise (rise m/s2 up), widen and come apart,
## from pos along dir within spread radians. color: their light (dark for smoke, pale for souls), size in meters.
func wisps(pos: Vector3, dir: Vector3, color: Color, count: int, speed: float = 2.0, size: float = 0.5, life: float = 0.7, spread: float = 1.2, rise: float = 1.0) -> void:
	var forward := dir.normalized() if dir.length_squared() > 0.0001 else Vector3.UP
	var side := forward.cross(Vector3.FORWARD if absf(forward.z) < 0.9 else Vector3.RIGHT).normalized()
	var up := side.cross(forward)
	for i in count:
		if _wisp_n >= WISP_POOL:
			return
		var k := _wisp_n
		_wisp_n += 1
		var a := _rng.randf_range(-spread, spread)
		var b := _rng.randf_range(-spread, spread)
		_wisp_pos[k] = pos
		_wisp_vel[k] = (forward + side * tan(clampf(a, -1.3, 1.3)) * 0.6 + up * tan(clampf(b, -1.3, 1.3)) * 0.6).normalized() * speed * _rng.randf_range(0.3, 1.0)
		_wisp_life[k] = 0.0
		_wisp_time[k] = life * _rng.randf_range(0.7, 1.0)
		_wisp_size[k] = size * _rng.randf_range(0.7, 1.0)
		_wisp_color[k] = color
		_wisp_rise[k] = rise


## C18 (ART P1-4): Morvath's spectral bursts never start nearer the paladin than this (on the floor): a soul landing
## on him bursts at that distance, on its own side, so the green family of the necromancy never covers his.
const CLEAR_OF_HERO: Array[StringName] = [&"soul"]
const HERO_CLEAR_M := 1.5


## pos moved out on the floor to HERO_CLEAR_M from the paladin (hero_head) when nearer (away from the camera when
## it is right on him).
func clear_of_hero(pos: Vector3) -> Vector3:
	if not hero_head.is_finite():
		return pos
	var off := Vector2(pos.x - hero_head.x, pos.z - hero_head.z)
	if off.length() >= HERO_CLEAR_M:
		return pos
	if off.length_squared() < 0.0001:
		var back := behind(Vector3(hero_head.x, 0.0, hero_head.z), 1.0)
		off = Vector2(back.x, back.z) if back != Vector3.ZERO else Vector2(0.0, -1.0)
	off = off.normalized() * HERO_CLEAR_M
	return Vector3(hero_head.x + off.x, pos.y, hero_head.z + off.y)


## Meters behind the paladin (away from the camera, on the floor) where his own bursts are centred (hero_burst).
const HERO_BURST_BACK := 0.8
const NUMBER_POP := 1.3
const NUMBER_POP_TIME := 0.08
## V-14: the grey of the wisp a dead one leaves (value 0.25).
const DEATH_ASH := Color(0.25, 0.24, 0.23)
const BONE_DUST := Color(0.34, 0.32, 0.28)
## Where the bone dust of a death is born (m): the chest.
const BONE_DUST_AT := 1.0
## N2: the Quebra's word is smaller than its ring (identidade_c1v 2.3).
const POISE_WORD_SIZE := 15
## P1-4: the most his light slivers rise over where they start (m; the burst starts at 0.4 m, his shoulder is near 2.1)
## and how fast they fall (m/s2).
const HERO_LIGHT_TOP := 0.9
const HERO_SHOULDER := 1.9
const HERO_LIGHT_FALL := 6.0


## A burst at the paladin, centred a little behind him from the camera: the specks never cover his body.
func hero_burst(kind: StringName, pos: Vector3) -> void:
	if kind == &"light":
		# VFX pass P1-4: his light never goes past his shoulder on the screen: slivers thrown out low round him and
		# falling (top of the arc about HERO_LIGHT_TOP m over where they start), behind him from the camera
		if not budget.allows(&"bursts"):
			return
		var spec: Array = BURSTS[kind]
		var count := maxi(3, roundi(int(spec[1]) * BURST_AMOUNT))
		var at := pos + behind(pos, HERO_BURST_BACK)
		var speed := sqrt(2.0 * HERO_LIGHT_FALL * clampf(HERO_SHOULDER - at.y, 0.15, HERO_LIGHT_TOP))
		_spray(at, Vector3.UP, spec[0], count, speed, float(spec[4]) * BURST_SCALE, 0.5, deg_to_rad(70.0), HERO_LIGHT_FALL, true)
		return
	burst(kind, pos + behind(pos, HERO_BURST_BACK))


## The offset of `meters` on the floor away from the camera, at pos (zero without a camera).
func behind(pos: Vector3, meters: float) -> Vector3:
	if camera == null:
		return Vector3.ZERO
	var back := pos - camera.global_position
	back.y = 0.0
	return back.normalized() * meters if back.length_squared() > 0.0001 else Vector3.ZERO


## A sword arc on the floor plane at waist height: from origin towards dir, reach meters, width degrees.
## ink: lay the dark half-moon under the cut. blade: meters from origin where its edge is drawn (the Emeth's tip;
## 0: the outer edge of the arc, for a cut that is not the paladin's). The head sweeps the arc in
## Feel.slash_sweep_time and is already SLASH_LEAD into it on the frame it starts.
func slash(origin: Vector2, dir: Vector2, reach: float, width_deg: float, color: Color, time: float = 0.2, flip: bool = false, height: float = 0.9, ink_under: bool = true, blade: float = BLADE_REACH) -> void:
	time = maxf(time, SLASH_MIN_LIFE)
	var tilt := _rng.randf_range(-0.08, 0.08)
	var s: Dictionary = _take(_slashes)
	var ink: Dictionary = _take(_inks)
	_place_arc(s, _arc(reach, width_deg, SLASH_INNER), origin, dir, height, tilt)
	_place_arc(ink, _arc(reach, width_deg, INK_INNER), origin, dir, height - 0.05, tilt)
	s.time = time
	var feel := Feel.live()
	ink.time = time * feel.ink_life
	var sweep := clampf(feel.slash_sweep_time / time, 0.1, 0.7)
	s.life = minf(SLASH_LEAD / time, sweep)
	ink.life = s.life / feel.ink_life
	for e: Dictionary in [s, ink]:
		var mat: ShaderMaterial = e.mat
		mat.set_shader_parameter(&"flip", flip)
		mat.set_shader_parameter(&"t", e.life)
		mat.set_shader_parameter(&"reach_m", reach)
		mat.set_shader_parameter(&"blade_m", blade)
	(s.mat as ShaderMaterial).set_shader_parameter(&"band_from", SLASH_INNER)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"band_from", INK_INNER)
	var family := family_of(color)
	# SR-G4: the plain cut (the Emeth's, no family) is white and gold, its core deeper and brighter
	var lit := color.lerp(GOLD, SLASH_GOLD) if family < 0 else color
	(s.mat as ShaderMaterial).set_shader_parameter(&"color", lit)
	(s.mat as ShaderMaterial).set_shader_parameter(&"style_peak", ScreenTone.linear_peak(lit.lerp(Color.WHITE, 0.3)))
	if family < 0:
		(s.mat as ShaderMaterial).set_shader_parameter(&"core_depth", SLASH_CORE.x)
		(s.mat as ShaderMaterial).set_shader_parameter(&"core_light", SLASH_CORE.y)
	(s.mat as ShaderMaterial).set_shader_parameter(&"family", family)
	var own := blade > 0.0
	(s.mat as ShaderMaterial).set_shader_parameter(&"style_core_light", SLASH_STYLE_CORE_LIGHT if own else 0.216)
	(s.mat as ShaderMaterial).set_shader_parameter(&"style_core_depth", SLASH_STYLE_CORE_DEPTH if own else 0.6)
	(s.mat as ShaderMaterial).set_shader_parameter(&"style_wire_glow", SLASH_STYLE_WIRE if own else 0.0)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"style_veil", SLASH_STYLE_VEIL if own else 0.72)
	if family == Boon.Family.CHAMA:
		# the tail's tongues rise off it (vfx_pass_spec.md 5.3): 3 to 5 tongue slivers along the back of the arc
		var n := budget.take(&"motes", _rng.randi_range(FAMILY_SLASH_TONGUES.x, FAMILY_SLASH_TONGUES.y))
		var mid := dir.normalized() if dir.length_squared() > 0.0001 else Vector2(0, 1)
		for k in n:
			var a := deg_to_rad(width_deg) * (_rng.randf_range(-0.5, 0.5))
			var way := mid.rotated(a)
			var at := Vector3(origin.x + way.x * reach * 0.8, height, origin.y + way.y * reach * 0.8)
			_spray(at, Vector3.UP, color * 0.95, 1, 1.8, 0.3, 0.4, 0.3, -3.0, false, 0, SHAPE_TONGUE)
	(s.mat as ShaderMaterial).set_shader_parameter(&"sweep", sweep)
	(s.mat as ShaderMaterial).set_shader_parameter(&"intensity", feel.slash_intensity * SLASH_BOOST)
	(s.mat as ShaderMaterial).set_shader_parameter(&"tail", minf(SLASH_TAIL, SLASH_TAIL_DEGREES / maxf(width_deg, 1.0)))
	(ink.mat as ShaderMaterial).set_shader_parameter(&"sweep", sweep / feel.ink_life)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"opacity", feel.ink_opacity if ink_under else 0.0)


func _place_arc(e: Dictionary, mesh: Mesh, origin: Vector2, dir: Vector2, height: float, tilt: float) -> void:
	var mi: MeshInstance3D = e.node
	mi.mesh = mesh
	mi.position = Vector3(origin.x, height, origin.y)
	mi.rotation = Vector3(tilt, atan2(dir.x, dir.y), 0.0)


## The cut a blow leaves on whoever it lands on: a short streak of length meters along axis (the way the blade was
## moving there), a pale core in the blow's colour. cross: a second, thinner streak across it (a heavy blow).
func gash(pos: Vector3, axis: Vector3, color: Color, length: float = 1.2, cross: bool = false, time: float = 0.15) -> void:
	if not budget.allows(&"gashes"):
		return
	length *= GASH_BOOST
	time *= GASH_LIFE
	var e: Dictionary = _take(_impacts)
	(e.node as Node3D).position = pos
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"axis", axis.normalized() if axis.length_squared() > 0.0001 else Vector3.RIGHT)
	mat.set_shader_parameter(&"size", length)
	mat.set_shader_parameter(&"cross_cut", 1.0 if cross else 0.0)
	mat.set_shader_parameter(&"life", 0.0)
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(color.lerp(Color.WHITE, 0.35), GASH_SCREEN))
	e.time = time


## The snap where a blow of the paladin lands (vfx_pass_spec.md V-05): a star of 5 to 7 uneven spikes at pos, half of
## them toward dir (the way the blade went), a small ivory heart, the tips in color; 3 frames growing 1.0 to 1.25, under
## the screen's 226. heavy: longer spikes (0.4 to 0.9 m). As many a frame as the gashes (BUDGET_GASHES, own count: on
## the gashes' own count a crowd showed half its cuts).
func contact(pos: Vector3, dir: Vector3, color: Color, heavy: bool = false, level: int = 0) -> void:
	if not budget.allows(&"contacts"):
		return
	var e: Dictionary = _take(_contacts)
	var mi: MeshInstance3D = e.node
	mi.position = pos
	var spikes := CONTACT_SPIKES_HEAVY if heavy else CONTACT_SPIKES
	e.size = spikes.y * CONTACT_GROW
	mi.scale = Vector3.ONE * e.size
	e.time = CONTACT_TIME
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"life", 0.0)
	mat.set_shader_parameter(&"seed", _rng.randf())
	# review: 6 or 7 (with 5 and the fan's spikes on one line it could read as a 4-point star)
	mat.set_shader_parameter(&"count", float(_rng.randi_range(6, 7)))
	mat.set_shader_parameter(&"half_m", e.size)
	mat.set_shader_parameter(&"spike_min_m", spikes.x)
	mat.set_shader_parameter(&"spike_max_m", spikes.y)
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(Color(1.0, 0.97, 0.9), CONTACT_SCREEN))
	if heavy:
		hit_light(pos, color, 1.8, 4.0)
	else:
		# CF2-07: every blow lights the one it lands on a little (blow 1, 2, 3: 1.0, 1.4, 1.8) and throws 4 white slivers
		hit_light(pos, color, CONTACT_LIGHT[clampi(level, 0, 2)], CONTACT_LIGHT_RANGE, CONTACT_LIGHT_TIME)
	var sparks := budget.take(&"motes", CONTACT_SPARKS)
	if sparks > 0:
		_spray(pos, Vector3.UP * 0.4, Color(1.0, 0.97, 0.9) * 0.9, sparks, 5.0, 0.1, CONTACT_SPARK_LIFE, 1.2, MOTE_GRAVITY, false)
	var aim := Vector2(1, 0)
	if camera != null and dir.length_squared() > 0.0001:
		var b := camera.global_transform.basis
		aim = Vector2(dir.dot(b.x), dir.dot(b.y))
		aim = aim.normalized() if aim.length_squared() > 0.0001 else Vector2(1, 0)
	mat.set_shader_parameter(&"aim", aim)


## A burst where something breaks (armor): two crossed cuts, upright. size 1 is IMPACT_SIZE meters across.
func impact(pos: Vector3, color: Color, size: float = 1.0, time: float = -1.0) -> void:
	gash(pos, Vector3(_rng.randf_range(-0.4, 0.4), 1.0, 0.0), color, IMPACT_SIZE * size, true, time if time > 0.0 else 0.18)


## A thrust: a thin beam from origin along dir, reach meters long and width meters across at its widest (what the
## blow reaches), tapering to a point. omega: the held thrust (a broader, paler thread with the gold veins of Emeth).
func thrust(origin: Vector2, dir: Vector2, reach: float, width: float, color: Color, time: float = 0.2, height: float = 0.9, omega: bool = false) -> void:
	var e: Dictionary = _take(_thrusts)
	var mi: MeshInstance3D = e.node
	var mid := origin + dir * reach * 0.5
	mi.position = Vector3(mid.x, height, mid.y)
	mi.rotation = Vector3(0.0, atan2(dir.x, dir.y), 0.0)
	mi.scale = Vector3(width, 1.0, reach)
	e.time = time
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"intensity", Feel.live().slash_intensity)
	mat.set_shader_parameter(&"omega", 1.0 if omega else 0.0)
	# V-04: the light runs in to the point in THRUST_IN s and leaves over THRUST_OUT s
	mat.set_shader_parameter(&"sweep", clampf(THRUST_IN / time, 0.05, 0.9))
	mat.set_shader_parameter(&"leave", clampf(THRUST_OUT / time, 0.1, 0.95))
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(color.lerp(Color.WHITE, 0.45)))
	if omega:
		# crystal spikes from the point to the sides (V-04): long slivers, flying out a moment
		var tip := Vector3(origin.x + dir.x * reach, height, origin.y + dir.y * reach)
		var fwd := Vector3(dir.x, 0.0, dir.y)
		for k in THRUST_SPIKES:
			var side := fwd.cross(Vector3.UP) * (1.0 if k % 2 == 0 else -1.0)
			var out := (side * _rng.randf_range(0.6, 1.0) + fwd * _rng.randf_range(0.2, 0.7)).normalized()
			_spray(tip, out, color.lerp(Color.WHITE, 0.3) * 0.9, 1, 9.0, 0.16, 0.18, 0.15, 0.0, true)


## Small specks flying from pos along dir (meters per second at most; a third of that at least) within spread
## radians of it: the magic a swing sheds, the chips of a blow landing. size in meters, life in
## seconds, both at most. gold_every: one in so many is old gold instead of color (0: none).
func chips(pos: Vector3, dir: Vector3, color: Color, count: int, speed: float = 6.0, size: float = 0.1, life: float = 0.35, spread: float = 0.6, gold_every: int = 0) -> void:
	var lit := Color(color.r * MOTE_GLOW, color.g * MOTE_GLOW, color.b * MOTE_GLOW)
	_spray(pos, dir, lit, budget.take(&"motes", count), speed, size, life, spread, MOTE_GRAVITY, false, gold_every)


## count slivers from pos along dir (spread radians round it), falling at gravity m/s2; burst: from Fx.burst (not
## counted by showing(&"motes"), not in the motes' budget).
func _spray(pos: Vector3, dir: Vector3, color: Color, count: int, speed: float, size: float, life: float, spread: float, gravity: float, from_burst: bool, gold_every: int = 0, shape: int = SHAPE_LENS) -> void:
	var forward := dir.normalized() if dir.length_squared() > 0.0001 else Vector3.UP
	var side := forward.cross(Vector3.UP)
	side = side.normalized() if side.length_squared() > 0.0001 else Vector3.RIGHT
	var up := side.cross(forward)
	for i in count:
		if _mote_n >= MOTE_POOL:
			return
		var k := _mote_n
		_mote_n += 1
		var a := _rng.randf_range(-spread, spread)
		var b := _rng.randf_range(-spread, spread) * 0.6
		_mote_pos[k] = pos
		_mote_vel[k] = (forward + side * tan(clampf(a, -1.3, 1.3)) + up * tan(clampf(b, -1.3, 1.3))).normalized() * speed * _rng.randf_range(0.35, 1.0)
		_mote_life[k] = 0.0
		_mote_time[k] = life * _rng.randf_range(0.6, 1.0)
		_mote_size[k] = size * _rng.randf_range(0.75, 1.0)
		_mote_color[k] = OLD_GOLD if gold_every > 0 and i % gold_every == gold_every - 1 else color
		_mote_grav[k] = gravity
		_mote_burst[k] = 1 if from_burst else 0
		_mote_shape[k] = shape


## The blade answers a swing: its light rises for an instant (never a light on the room).
func blade_pulse() -> void:
	_pulse = 1.0


## How many effects of a kind are on screen now (tests: nothing shows without a real hit).
func showing(kind: StringName) -> int:
	match kind:
		&"motes":
			var own := 0
			for i in _mote_n:
				own += 1 - _mote_burst[i]
			return own
		&"wisps":
			return _wisp_n
		&"numbers":
			var shown := 0
			for l in _labels:
				if l.visible:
					shown += 1
			return shown
	var pools := {&"gashes": _impacts, &"slashes": _slashes, &"thrusts": _thrusts, &"crescents": _crescents, &"rings": _rings, &"smoke_rings": _smoke_rings, &"contacts": _contacts, &"marks": _marks, &"glints": _glints,
		&"boss_scythes": _boss_scythes, &"boss_wakes": _boss_wakes}
	var count := 0
	for e: Dictionary in pools.get(kind, []):
		if (e.node as Node3D).visible:
			count += 1
	return count


## A finisher gathering light on the blade: a thin cross, a long streak and a ring that grow for hold seconds,
## then burst (the blow lands at that instant). follow: a node it stays on (the tip of the sword), else it stays at pos.
func glint(pos: Vector3, color: Color, hold: float, follow: Node3D = null) -> void:
	var e: Dictionary = _take(_glints)
	e.follow = follow
	(e.node as Node3D).position = follow.global_position if follow else pos
	e.time = hold + GLINT_BURST
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"size", GLINT_SIZE)
	mat.set_shader_parameter(&"hold", hold / e.time)
	mat.set_shader_parameter(&"life", 0.0)
	mat.set_shader_parameter(&"streak_angle", _rng.randf_range(0.25, 0.45) * (1.0 if _rng.randf() < 0.5 else -1.0))
	mat.set_shader_parameter(&"seed", _rng.randf())
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(Color(1.0, 0.97, 0.9), CONTACT_SCREEN))


## The wave of a finisher: a thin crescent of ink with a white edge that flies far past the blow and fades.
func crescent(origin: Vector2, dir: Vector2, reach: float, width_deg: float, color: Color, height: float = 0.7) -> void:
	var e: Dictionary = _take(_crescents)
	# V-02: the spin sweeps CRESCENT_SPIN degrees (never a closed ring), a finisher CRESCENT_ARC
	var deg := CRESCENT_SPIN if width_deg >= CRESCENT_SPIN else clampf(width_deg, CRESCENT_ARC.x, CRESCENT_ARC.y)
	var r := minf(reach, CRESCENT_MAX_REACH)
	_place_arc(e, _arc(r, deg, CRESCENT_INNER), origin, dir, height, 0.0)
	(e.node as Node3D).scale = Vector3.ONE
	e.time = CRESCENT_TIME
	var mat: ShaderMaterial = e.mat
	var gold := color.lerp(GOLD, CRESCENT_GOLD) if family_of(color) < 0 else color
	mat.set_shader_parameter(&"color", gold)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"ink_opacity", Feel.live().ink_opacity * CRESCENT_INK)
	mat.set_shader_parameter(&"band_m", r * (1.0 - CRESCENT_INNER))
	mat.set_shader_parameter(&"head_m", r * (1.0 - CRESCENT_INNER) * CRESCENT_HEAD)
	mat.set_shader_parameter(&"tail_m", r * (1.0 - CRESCENT_INNER) * CRESCENT_TAIL)
	mat.set_shader_parameter(&"edge_pale", CRESCENT_PALE)
	mat.set_shader_parameter(&"body_light", CRESCENT_BODY)
	mat.set_shader_parameter(&"sweep", clampf(Feel.live().slash_sweep_time / CRESCENT_TIME, 0.05, 0.5))
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(gold.lerp(Color.WHITE, 0.45)))
	mat.set_shader_parameter(&"additive", 0.0)
	mat.set_shader_parameter(&"tip_fade", 0.0)
	if deg >= CRESCENT_SPIN and family_of(color) < 0:
		mat.set_shader_parameter(&"color", CRESCENT_SPIN_GREEN)
		mat.set_shader_parameter(&"peak", CRESCENT_SPIN_PEAK)
		mat.set_shader_parameter(&"edge_pale", 0.2)
		mat.set_shader_parameter(&"additive", 1.0)
		mat.set_shader_parameter(&"tip_fade", CRESCENT_SPIN_TIPS)
	if deg < CRESCENT_SPIN:
		_crescent_echo(origin, dir, r * CRESCENT_ECHO_SIZE, deg, height, mat)


## The finisher's second crescent: only the gold edge (no body, no ink), bigger and a few frames behind the first.
func _crescent_echo(origin: Vector2, dir: Vector2, reach: float, deg: float, height: float, first: ShaderMaterial) -> void:
	var e: Dictionary = _take(_crescents)
	_place_arc(e, _arc(reach, deg, CRESCENT_INNER), origin, dir, height, 0.0)
	(e.node as Node3D).scale = Vector3.ONE
	e.time = CRESCENT_TIME
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"additive", 0.0)
	mat.set_shader_parameter(&"tip_fade", 0.0)
	mat.set_shader_parameter(&"color", GOLD)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"ink_opacity", 0.0)
	mat.set_shader_parameter(&"body_light", 0.0)
	mat.set_shader_parameter(&"band_m", reach * (1.0 - CRESCENT_INNER))
	mat.set_shader_parameter(&"head_m", reach * (1.0 - CRESCENT_INNER) * CRESCENT_TAIL)
	mat.set_shader_parameter(&"tail_m", reach * (1.0 - CRESCENT_INNER) * CRESCENT_TAIL * 0.5)
	mat.set_shader_parameter(&"edge_pale", 0.35)
	mat.set_shader_parameter(&"sweep", clampf(float(first.get_shader_parameter(&"sweep")) * CRESCENT_ECHO_SWEEP, 0.05, 0.6))
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(GOLD.lerp(Color.WHITE, 0.3)))


## Morvath's Sepulchral Scythe: the blade crosses the half circle from origin along dir (reach m, degrees wide) in
## sweep seconds, its trail and ashes last until `life`. body: the violet of the trail, edge: the blade and the reach.
## Drawn flat on the floor, exactly over the sector the blow hurts.
func boss_scythe(origin: Vector2, dir: Vector2, reach: float, degrees: float, sweep: float, life: float, body: Color, edge: Color) -> void:
	var e: Dictionary = _take(_boss_scythes)
	_place_arc(e, _arc(reach, degrees, BOSS_SCYTHE_INNER), origin, dir, 0.08, 0.0)
	e.time = life
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"sweep", clampf(sweep / maxf(life, 0.01), 0.05, 0.95))
	mat.set_shader_parameter(&"flip", _rng.randf() < 0.5)
	mat.set_shader_parameter(&"body", body)
	mat.set_shader_parameter(&"edge", edge)
	# V-16: the gnawed reach in metres, under the screen's 226, and dark violet wisps leaving the reach
	mat.set_shader_parameter(&"reach_m", reach * deg_to_rad(degrees) / 3.0)
	mat.set_shader_parameter(&"band_m", reach * (1.0 - BOSS_SCYTHE_INNER))
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(body))
	var half := deg_to_rad(degrees) * 0.5
	var facing := atan2(dir.x, dir.y)
	for k in SCYTHE_WISPS:
		var a := facing - half + 2.0 * half * (k + 0.5) / SCYTHE_WISPS
		var out := Vector3(sin(a), 0.0, cos(a))
		wisps(Vector3(origin.x, 0.3, origin.y) + out * reach, out + Vector3.UP * 0.12, SCYTHE_SMOKE, 1, 2.2, 0.6, 0.35, 0.5, 0.3)


## Morvath's dash: its lane (from, dir, length, width in m) revealed as he runs it in `run` seconds, breaking into
## ashes until `life`.
func boss_dash(from: Vector2, dir: Vector2, length: float, width: float, run: float, life: float, body: Color, edge: Color) -> void:
	var e: Dictionary = _take(_boss_wakes)
	var mi: MeshInstance3D = e.node
	mi.position = Vector3(from.x, 0.07, from.y)
	mi.rotation = Vector3(0.0, atan2(dir.x, dir.y), 0.0)
	mi.scale = Vector3(width, 1.0, length)
	e.time = life
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"sweep", clampf(run / maxf(life, 0.01), 0.05, 0.95))
	mat.set_shader_parameter(&"body", body)
	mat.set_shader_parameter(&"edge", edge)


## Emeth's blade holds its light up for `seconds` (the ending), then falls back as after a swing.
func blade_glow(seconds: float) -> void:
	_blade_hold = maxf(_blade_hold, seconds)
	_pulse = 1.0


## A flat strip one meter wide and one long on the floor plane: x across (-0.5 to 0.5), z along (0 to 1); UV.x across,
## UV.y along.
static func strip() -> ArrayMesh:
	if _strip_mesh:
		return _strip_mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p := [Vector3(-0.5, 0, 0), Vector3(0.5, 0, 0), Vector3(-0.5, 0, 1), Vector3(0.5, 0, 1)]
	var uv := [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	for k: int in [0, 2, 1, 1, 2, 3]:
		st.set_uv(uv[k])
		st.add_vertex(p[k])
	_strip_mesh = st.commit()
	return _strip_mesh


## One or two frames of the whole screen in flat black and white: only for the biggest blows (Combat decides which,
## and how often). Off with the "impact_frames" option (impact_frames false), for comfort and sensitivity to light.
## Returns true when it flashed.
func impact_frame() -> bool:
	if not impact_frames or Feel.live().impact_frame <= 0.0:
		return false
	frame_left = maxf(frame_left, Feel.live().impact_frame)
	return true


## The camera jolts along a blow (dir on the floor plane).
func kick(dir: Vector2, amount: float) -> void:
	_kick += Vector3(dir.x, 0, dir.y) * KICK_METERS * amount * shake_scale * Feel.live().kick_scale


## A flat shockwave growing to radius. thin: only a fine line, nothing inside it.
## A short point light where a strong blow lands (energy 1 to 3, range in meters, `time` seconds, fading quadratically).
## Never more than LIGHT_POOL at once; none on Compatibility. Only for looks: nothing reads it.
func hit_light(pos: Vector3, color: Color, energy: float = 2.0, range_m: float = 5.0, time: float = LIGHT_TIME) -> void:
	if _lights.is_empty():
		return
	var e: Dictionary = _take(_lights)
	var l: OmniLight3D = e.node
	l.position = pos
	l.light_color = color.lerp(LIGHT_WARM, 0.35)
	l.omni_range = range_m
	l.light_energy = energy
	e.energy = energy
	e.time = time


## The ground answering a heavy blow (Golpe Carregado, finishers, the Apogeu, the cleave): a thick ring opening on the
## floor, a thin one outside it, pieces of stone and bone dust flung up, a puff of dust and a brief light. power 1 is a
## finisher; 0.6 a held blow; 1.6 an Omega. Drawn only, nothing here moves the game.
func shock(center: Vector2, radius: float, color: Color, power: float = 1.0) -> void:
	ring(center, radius, color, 0.4, 0.12, false, true)
	ring(center, radius * SHOCK_OUTER, color, 0.32, 0.14, true, true)
	var at := Vector3(center.x, 0.25, center.y)
	var n := budget.take(&"motes", roundi(lerpf(SHOCK_CHIPS.x, SHOCK_CHIPS.y, clampf(power / 1.6, 0.0, 1.0))))
	if n > 0:
		_spray(at, Vector3.UP, STONE, n, 6.0 + 2.0 * power, 0.14, 0.55, 1.1, MOTE_GRAVITY * 1.6, false)
	burst(&"dust", at)
	hit_light(at + Vector3.UP * 0.8, color, 1.6 + 1.2 * power, radius * 2.2 + 3.0)


## The Investida's trail: dust kicked up along the line it runs and a few slivers of its colour (the thrust is drawn by `thrust`).
func dash_trail(origin: Vector2, dir: Vector2, reach: float, color: Color) -> void:
	for k in 3:
		var at := origin + dir * reach * (0.2 + 0.3 * k)
		wisps(Vector3(at.x, 0.3, at.y), Vector3.UP, BONE_DUST, 1, 0.8, 0.5, 0.6, 1.0, 0.4)
	var n := budget.take(&"motes", 6)
	if n > 0:
		var mid := origin + dir * reach * 0.5
		_spray(Vector3(mid.x, 0.5, mid.y), Vector3(-dir.x, 0.3, -dir.y), color.lerp(Color.WHITE, 0.3) * 0.9, n, 7.0, 0.12, 0.35, 0.8, 0.0, false)


## A second lit ring at the same radius after `wait` seconds (the Brado's echo: AD2-05).
func ring_later(center: Vector2, radius: float, color: Color, wait: float) -> void:
	_later_rings.append({"center": center, "radius": radius, "color": color, "wait": wait})


func ring(center: Vector2, radius: float, color: Color, time: float = 0.35, height: float = 0.15, thin: bool = false, bright: bool = false) -> void:
	var r: Dictionary = _take(_rings)
	var mi: MeshInstance3D = r.node
	mi.position = Vector3(center.x, height, center.y)
	r.size = radius
	r.grow = 1.0
	r.mode = RING_OPEN
	mi.scale = Vector3.ONE * radius * 0.3
	(r.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	var band := 0.035 if thin else 0.08
	if bright:
		# AD2-05: a line of at least RING_BRIGHT_M wide, light (additive, ivory over its colour), a fill that lifts the floor
		band = maxf(band, RING_BRIGHT_M / maxf(radius, 0.1))
	(r.mat as ShaderMaterial).set_shader_parameter(&"band", band)
	(r.mat as ShaderMaterial).set_shader_parameter(&"fill", 0.0 if thin else 0.3 if bright else 0.18)
	(r.mat as ShaderMaterial).set_shader_parameter(&"intensity", RING_BRIGHT_LIGHT if bright else 1.5)
	(r.mat as ShaderMaterial).set_shader_parameter(&"ivory", RING_BRIGHT_IVORY if bright else 0.4)
	r.time = time


## A wave ring the caller moves (the knight's shield wave): a thin band at `radius` that stays until `wave_end`. The
## round ring is allowed here because it is a moving wave, never a mark on the floor (Daniel, 2026-11-23).
func wave_ring(center: Vector2, color: Color, height: float = 0.16) -> Dictionary:
	var r: Dictionary = _take(_rings)
	var mi: MeshInstance3D = r.node
	mi.position = Vector3(center.x, height, center.y)
	(r.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	(r.mat as ShaderMaterial).set_shader_parameter(&"fill", 0.0)
	r.mode = RING_HELD
	r.size = 1.0
	r.time = 0.3
	wave_ring_set(r, 1.0, 0.8)
	return r


## Sets the held ring's radius and the band's width in meters (the shader's band is a share of the radius).
func wave_ring_set(r: Dictionary, radius: float, thick: float) -> void:
	r.size = radius
	(r.node as Node3D).scale = Vector3.ONE * radius
	(r.mat as ShaderMaterial).set_shader_parameter(&"band", clampf(thick / maxf(radius, 0.1), 0.02, 0.6))
	(r.mat as ShaderMaterial).set_shader_parameter(&"life", 0.0)


## The held ring fades where it is, in `time` seconds.
func wave_end(r: Dictionary, time: float = 0.25) -> void:
	r.mode = RING_FADE
	r.time = time


## Where an enemy's blow lands (vfx_pass_spec.md V-12): a ring of dark smoke with a torn edge opening to `radius`, its
## inner rim in `color` under the screen's 205, a dark middle, dirty embers and smoke rising; nothing lit is filled.
## thin: only a thin ring, gone in `time` (a blow with another right after it).
func smoke_ring(center: Vector2, radius: float, color: Color, time: float = 0.5, thin: bool = false) -> Dictionary:
	var r: Dictionary = _take(_smoke_rings)
	var mi: MeshInstance3D = r.node
	mi.position = Vector3(center.x, 0.12, center.y)
	mi.scale = Vector3.ONE * radius
	r.time = time
	var mat: ShaderMaterial = r.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"cap", ScreenTone.linear_peak(color, SMOKE_RING_SCREEN))
	mat.set_shader_parameter(&"thin", 1.0 if thin else 0.0)
	mat.set_shader_parameter(&"closing", 0.0)
	mat.set_shader_parameter(&"life", 0.0)
	if thin:
		return r
	var ember := Color(color.r, color.g, color.b) / maxf(maxf(color.r, color.g), maxf(color.b, 0.001)) * 0.5
	for k in SMOKE_RING_EMBERS:
		var a := TAU * k / SMOKE_RING_EMBERS + _rng.randf_range(-0.3, 0.3)
		var at := Vector3(center.x + cos(a) * radius * 0.8, 0.2, center.y + sin(a) * radius * 0.8)
		wisps(at, Vector3(cos(a) * 0.4, 1.0, sin(a) * 0.4), ember * 0.6 if k % 2 == 0 else SMOKE, 1, 1.2, 0.45, 0.5, 0.4, 1.2)
	return r


## A spike of emerald crystal breaking out of the floor at `foot` after `delay` s (V-09): `tall` m, leaning `lean` (a
## turn off the upright), grows in SPIKE_GROW s and breaks into chips SPIKE_BREAK s later.
func crystal_spike(foot: Vector3, tall: float, lean: Basis, delay: float, color: Color) -> void:
	var e: Dictionary = _take(_spikes)
	e.delay = delay
	e.lean = lean
	e.foot = foot
	e.tall = tall
	e.broke = false
	e.time = SPIKE_TIME
	var mi: MeshInstance3D = e.node
	mi.visible = delay <= 0.0
	mi.scale = Vector3.ZERO
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"peak", ScreenTone.linear_peak(color.lerp(Color.WHITE, 0.25), SPIKE_SCREEN))
	mat.set_shader_parameter(&"grow", SPIKE_GROW / SPIKE_TIME)
	mat.set_shader_parameter(&"shatter", (SPIKE_GROW + SPIKE_BREAK) / SPIKE_TIME)
	mat.set_shader_parameter(&"life", 0.0)
	if delay > 0.0:
		mi.visible = true
		mi.scale = Vector3.ZERO


func _step_spike(e: Dictionary, delta: float) -> void:
	if e.delay > 0.0:
		e.delay -= delta
		return
	_age(e, delta)
	var mi: MeshInstance3D = e.node
	var grown := clampf(e.life * SPIKE_TIME / SPIKE_GROW, 0.0, 1.0)
	var tall: float = e.tall * (1.0 - pow(1.0 - grown, 3.0))
	var b: Basis = e.lean * Basis.from_scale(Vector3(SPIKE_RADIUS, maxf(tall, 0.001), SPIKE_RADIUS))
	mi.transform = Transform3D(b, e.foot + e.lean.y * tall * 0.5)
	(e.mat as ShaderMaterial).set_shader_parameter(&"life", e.life)
	if not e.broke and e.life * SPIKE_TIME >= SPIKE_GROW + SPIKE_BREAK:
		e.broke = true
		var tip: Vector3 = e.foot + e.lean.y * tall * 0.7
		chips(tip, e.lean.y + Vector3.UP * 0.3, Combat.EMETH * 0.7, SPIKE_CHIPS, 4.0, 0.14, 0.3, 0.9)


## An elite rises (vfx_pass_spec.md V-15): no column; a ring of dark smoke with a dull old gold edge (value 0.5) closes on
## the spot in ELITE_SURGE_TIME, and a breath of wisps rises 1.5 m.
const ELITE_SURGE_TIME := 0.4
const ELITE_SURGE_GOLD := Color(0.5, 0.36, 0.16)


func elite_surge(at: Vector2, radius: float = 1.6) -> void:
	# the ring closes over the shader's open_time (0.33 of its life), so its life is ELITE_SURGE_TIME / 0.33
	var r := smoke_ring(at, radius, ELITE_SURGE_GOLD, ELITE_SURGE_TIME / 0.33, true)
	var mat: ShaderMaterial = r.mat
	mat.set_shader_parameter(&"closing", 1.0)
	mat.set_shader_parameter(&"thin", 0.0)
	for k in 5:
		var a := TAU * k / 5.0 + _rng.randf_range(-0.3, 0.3)
		wisps(Vector3(at.x + cos(a) * radius * 0.5, 0.2, at.y + sin(a) * radius * 0.5), Vector3.UP, SMOKE, 1, 2.0, 0.5, 0.75, 0.25, 0.4)


## The Blessing family a colour belongs to (Combat.FIRE, FROST, LIGHT, VIGIL and Boon.FAMILY_COLOR), -1 for the sword's
## own green or anything else (vfx_pass_spec.md 5.3: the family's form rides on the colour the blow already carries).
static func family_of(color: Color) -> int:
	var known := {Boon.Family.CHAMA: [Combat.FIRE], Boon.Family.GEADA: [Combat.FROST], Boon.Family.LUZ: [Combat.LIGHT], Boon.Family.VIGILIA: [Combat.VIGIL]}
	for f: int in known:
		var list: Array = known[f].duplicate()
		list.append(Boon.FAMILY_COLOR[f])
		for c: Color in list:
			if absf(c.r - color.r) + absf(c.g - color.g) + absf(c.b - color.b) < 0.06:
				return f
	return -1


## The floor form of a family (vfx_pass_spec.md 5.3, family_mark.gdshader) at center, radius meters, for time seconds:
## Chama a ring of tongues over a charred ring, Geada hexagonal frost plates, Luz a thin ring with eight marks drawn
## round from the side toward `dir`, Vigília three segmented arcs opening (only within `arc_deg` of dir when it is less
## than 180). Nothing for the Elo (it shows the two families' own) nor an unknown family.
func family_mark(family: int, center: Vector2, radius: float, color: Color, time: float = 0.5, dir: Vector2 = Vector2.ZERO, arc_deg: float = 180.0) -> void:
	if not MARK_FORM.has(family) or not budget.allows(&"marks"):
		return
	var e: Dictionary = _take(_marks)
	var mi: MeshInstance3D = e.node
	mi.position = Vector3(center.x, 0.1, center.y)
	mi.scale = Vector3.ONE * radius
	mi.rotation = Vector3.ZERO
	var way := dir.normalized() if dir.length_squared() > 0.0001 else Vector2(1, 0)
	# the quad's +x is the world's +x; its UV.y runs along the world's +z
	mi.rotation.y = -atan2(way.y, way.x) if arc_deg < 180.0 else 0.0
	e.time = time
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"form", MARK_FORM[family])
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"cap", ScreenTone.linear_peak(color, MARK_SCREEN[family]))
	mat.set_shader_parameter(&"life", 0.0)
	mat.set_shader_parameter(&"time", time)
	mat.set_shader_parameter(&"radius_m", radius)
	mat.set_shader_parameter(&"seed", _rng.randf())
	mat.set_shader_parameter(&"count", float(clampi(roundi(radius * 4.0), 12, 18)))
	mat.set_shader_parameter(&"tongue", clampf(0.6 / maxf(radius, 0.1), 0.12, 0.5))
	mat.set_shader_parameter(&"arc", deg_to_rad(minf(arc_deg, 180.0)) if arc_deg < 180.0 else PI + 0.1)
	mat.set_shader_parameter(&"start", Vector2(way.x, way.y) if arc_deg >= 180.0 else Vector2(1, 0))
	mat.set_shader_parameter(&"gold", OLD_GOLD * 0.7)
	if family == Boon.Family.CHAMA:
		# the tongues rise off the floor too: slivers shaped like tongues, a little smoke at the end
		var n := clampi(roundi(radius * 4.0), 12, 18)
		for k in budget.take(&"motes", n):
			var a := TAU * k / n + _rng.randf_range(-0.15, 0.15)
			var at := Vector3(center.x + cos(a) * radius * 0.82, 0.15, center.y + sin(a) * radius * 0.82)
			_spray(at, Vector3(cos(a) * 0.25, 1.0, sin(a) * 0.25), color * 0.95, 1, 1.4, 0.34, 0.45, 0.25, -3.0, false, 0, SHAPE_TONGUE)
		for k in 3:
			var a := TAU * k / 3.0 + _rng.randf()
			wisps(Vector3(center.x + cos(a) * radius * 0.7, 0.4, center.y + sin(a) * radius * 0.7), Vector3.UP, SMOKE, 1, 0.8, 0.5, 0.8, 0.5, 1.0)


## The circle of light let go (vfx_pass_spec.md V-07): its rim drawn round from the side toward `from` in 0.12 s (the
## Luz form of family_mark, ivory with its marks and gold thread) and CIRCLE_SLIVERS slivers of light falling 1.5 m onto
## the rim in 0.2 s; no filled ring.
const CIRCLE_SLIVERS := 5
const CIRCLE_SPIKES := 10


func circle_cast(at: Vector2, radius: float, color: Color, from: Vector2 = Vector2.ZERO) -> void:
	family_mark(Boon.Family.LUZ, at, radius, color, 0.35, from)
	var n := budget.take(&"motes", CIRCLE_SLIVERS)
	var turn := _rng.randf() * TAU
	for k in n:
		var a := turn + TAU * k / maxf(n, 1)
		_spray(Vector3(at.x + cos(a) * radius, 1.5, at.y + sin(a) * radius), Vector3.DOWN, color * 0.9, 1, 7.5, 0.2, 0.2, 0.0, 0.0, false)


## The held circle bursts (V-07): crystal spikes from the rim inward in 0.2 s (the Omega's, V-04), no ring.
func circle_burst(at: Vector2, radius: float, color: Color) -> void:
	var n := budget.take(&"motes", CIRCLE_SPIKES)
	for k in n:
		var a := TAU * k / maxf(n, 1) + _rng.randf_range(-0.2, 0.2)
		var rim := Vector3(at.x + cos(a) * radius, 0.4, at.y + sin(a) * radius)
		_spray(rim, Vector3(-cos(a), 0.15, -sin(a)), Combat.EMETH * 0.85, 1, radius / 0.2 * 0.6, 0.3, 0.2, 0.05, 0.0, false)


## A family's mark where its blow lands (vfx_pass_spec.md 5.3, with Fx.contact): Chama three tongues rising, Geada a
## burst of 5 to 7 frost barbs falling, Luz a thin ray from above and a small ring of marks, Vigília three 60 degree arcs
## opening toward dir. Nothing for the sword's own green.
func family_hit(family: int, pos: Vector3, dir: Vector3, color: Color, heavy: bool = false) -> void:
	match family:
		Boon.Family.CHAMA:
			_spray(pos, Vector3.UP, color * 0.95, budget.take(&"motes", 4 if heavy else 3), 1.6, 0.3, 0.45, 0.4, -3.0, false, 0, SHAPE_TONGUE)
		Boon.Family.GEADA:
			var out := (dir + Vector3.UP * 0.8).normalized() if dir.length_squared() > 0.0001 else Vector3.UP
			_spray(pos, out, color * 0.95, budget.take(&"motes", _rng.randi_range(5, 7)), 4.5, 0.2, 0.35, 0.9, 8.0, false, 0, SHAPE_BARB)
		Boon.Family.LUZ:
			if budget.allows(&"marks"):
				beam(Vector2(pos.x, pos.z), color, LUZ_RAY.x, LUZ_RAY.y, LUZ_RAY.z)
			family_mark(family, Vector2(pos.x, pos.z), 0.8 if not heavy else 1.1, color, 0.35, -Vector2(dir.x, dir.z))
		Boon.Family.VIGILIA:
			family_mark(family, Vector2(pos.x, pos.z), VIGIL_HIT.x * (1.2 if heavy else 1.0), color, VIGIL_HIT.y, Vector2(dir.x, dir.z), VIGIL_HIT.z)


## A pillar of light (or shadow) at a point on the floor. intensity: its light (beam.gdshader's; BEAM_INTENSITY
## is the usual one, less where it must not cover someone).
## cap: how bright its light may get, a share of what keeps its colour at ScreenTone.SAFE on the screen (BEAM_CORE_CAP;
## BEAM_NO_CAP: as bright as it comes). The light covers what is behind it in that measure (beam.gdshader), so nothing
## under a column, nor its two faces, sums past it.
func beam(at: Vector2, color: Color, radius: float = 0.8, height: float = 9.0, time: float = 0.45, intensity: float = BEAM_INTENSITY,
		cap: float = BEAM_CORE_CAP) -> void:
	var b: Dictionary = _take(_beams)
	# the cap is a share of the light that keeps this colour at ScreenTone.SAFE on the screen (GP-01)
	var peak := cap * ScreenTone.linear_peak(color)
	last_beam = {"at": at, "intensity": intensity, "cap": cap, "color": color, "peak": peak}
	var mi: MeshInstance3D = b.node
	mi.position = Vector3(at.x, height * 0.5, at.y)
	mi.scale = Vector3(radius, height, radius)
	b.size = radius
	(b.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	(b.mat as ShaderMaterial).set_shader_parameter(&"intensity", intensity)
	(b.mat as ShaderMaterial).set_shader_parameter(&"cap", peak)
	b.time = time


## A damage number over pos (the top of whoever took it). key: who took it (an instance id; 0 for none): hits that
## follow each other on the same target join its number, which counts up and pops again (NumberTally).
## tick: damage over time (a burn, a floor, a zone): never smaller than TICK_SHARE of a direct number, always in a family
## colour of at least TICK_VALUE (grey becomes the Emeth's green) and with a TICK_OUTLINE px edge (GR-27).
func number(pos: Vector3, amount: float, color: Color, big: bool = false, key: int = 0, tick: bool = false) -> void:
	if tick:
		color = tick_color(color)
	var i := _tally.add(key, pos + Vector3(0, NUMBER_LIFT, 0), amount, color, big, Engine.get_process_frames())
	if i < 0:
		return
	var e := _tally.entries[i]
	if not _tally.merged:
		e.pos += _jitter()
	var size := NUMBER_BIG if e.big else (NumberTally.GROUP_SIZE if e.group else NUMBER_SIZE)
	if tick:
		size = maxi(size, ceili(NUMBER_BIG * TICK_SHARE))
	_show_label(i, str(roundi(e.amount)), e.color, size, TICK_OUTLINE if tick else 0)


## The colour of a damage-over-time number: grey (low saturation) is no family, so it takes the Emeth's green; the value
## never falls under TICK_VALUE.
static func tick_color(c: Color) -> Color:
	if c.s < TICK_MIN_SAT:
		c = TICK_FALLBACK
	return Color.from_hsv(c.h, c.s, maxf(c.v, TICK_VALUE), c.a)


func word(pos: Vector3, text: String, color: Color) -> void:
	var i := _tally.add_word(pos + _jitter(), color)
	_show_label(i, text, color, POISE_WORD_SIZE if text == T.t(&"word_poise") else WORD_SIZE)


## Gold picked up (UI review d2ff05d, P1-3): "+N ouro" in a pale old gold, smaller than a damage number; gold that
## follows within NumberTally.MERGE_TIME and GOLD_JOIN metres joins the "+N" still showing, as the hits on one target
## join one number, so a horde's drops read "+3 ouro", never a pile of "+1 ouro".
func gold(pos: Vector3, amount: int) -> void:
	var text := "+%d %s" % [amount, _gold_word()]
	if _gold_at >= 0:
		var e := _tally.entries[_gold_at]
		if e.shown and e.amount < 0.0 and e.color == GOLD_WORD and e.life <= NumberTally.MERGE_TIME \
				and Vector2(e.pos.x - pos.x, e.pos.z - pos.z).length() <= GOLD_JOIN:
			_gold_sum += amount
			e.life = 0.0
			_show_label(_gold_at, "+%d %s" % [_gold_sum, _gold_word()], GOLD_WORD, GOLD_SIZE)
			return
	_gold_sum = amount
	var side := Feel.screen_to_floor(Vector2.RIGHT, Feel.live().cam_yaw) * GOLD_SIDE
	_gold_at = _tally.add_word(pos + Vector3(side.x, 0.0, side.y) + _jitter() * 0.5, GOLD_WORD)
	_show_label(_gold_at, text, GOLD_WORD, GOLD_SIZE)


## The sum the gold word showing now says (0: none showing; the tests read it).
func gold_shown() -> int:
	if _gold_at < 0:
		return 0
	var e := _tally.entries[_gold_at]
	return _gold_sum if e.shown and e.color == GOLD_WORD else 0


## The hit stop of a blow (Hades II, GF-01): wait_ms at full speed, slow_ms at fraction of the speed, back to full in
## HitStop.BACK. Milliseconds of real time.
func blow_stop(wait_ms: float, slow_ms: float = 10.0, fraction: float = HitStop.FRACTION) -> void:
	hits.start(wait_ms / 1000.0, slow_ms / 1000.0, fraction)


## A heavy moment (a boss's roar, a gift's blast): the world slows to a few percent at once for ms, then comes back
## (never a freeze since GF-01).
func hit_stop(ms: float) -> void:
	blow_stop(0.0, ms)


## The gamepad buzzes (a blow that lands, a hit taken): weak and strong motor (0..1), seconds. Only with a pad in use
## and the "rumble" option on.
func buzz(weak: float, strong: float, seconds: float) -> void:
	# the autoload looked up by its path, not its name: the labs (tools/enemy_lab.gd) run Fx as a script, without autoloads
	var controls := get_node_or_null(^"/root/Controls")
	if not rumble or controls == null or not controls.get(&"using_pad"):
		return
	for pad in Input.get_connected_joypads():
		Input.start_joy_vibration(pad, weak, strong, seconds)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount * SHAKE_METERS * shake_scale * Feel.live().shake_scale)


func kick_split(amount: float) -> void:
	if color_split:
		split = maxf(split, amount)


## Runs every frame with the frame's delta (scaled by Engine.time_scale as Godot gives it). Everything here counts in
## real time (GF-05: a hit stop under slow motion is as short as anywhere else). Sets rate and real_dt, and
## Engine.time_scale for what Godot animates by itself. Returns the camera's shake offset.
func tick(delta: float) -> Vector3:
	real_dt = delta / maxf(Engine.time_scale, 0.0001)
	var hit := hits.advance(real_dt)
	if not hits.active() and _slow_wait:
		_slow_wait = false
		_slow_t = 0.0
	_tick_slow(real_dt)
	rate = _slow_scale() * hit
	# what Godot moves by itself (animations, particles) follows the world one frame later
	Engine.time_scale = maxf(rate, 0.0001)
	delta = real_dt
	_shake = maxf(0.0, _shake - delta * (0.6 + _shake * 6.0))
	split = maxf(0.0, split - delta * 3.0)
	frame_left = maxf(0.0, frame_left - delta)
	_kick *= maxf(0.0, 1.0 - delta * 14.0)
	if _shake <= 0.0:
		return _kick
	return _kick + Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-0.5, 0.5), _rng.randf_range(-1, 1)) * _shake


## Slow motion: the world runs at fraction of its speed (eased in over ease_in seconds, held, eased back over
## ease_out), the camera closes in by zoom and the screen blurs toward its middle. A weaker one never cuts a
## stronger one short. Seconds here are real seconds.
func slow_mo(fraction: float, hold: float, ease_out: float, zoom_to: float = 1.0, blur: float = 0.0, ease_in: float = 0.06) -> void:
	if not slow_motion or (_slow_on and fraction > _slow_fraction):
		return
	_slow_on = true
	_slow_fraction = fraction
	_slow_in = ease_in
	_slow_hold = hold
	_slow_out = ease_out
	_slow_zoom = zoom_to
	_slow_blur = blur
	_slow_t = 0.0
	_slow_wait = hits.active()


## Back to full speed at once (a menu opens, the run ends).
func end_slow() -> void:
	_slow_on = false
	_slow_wait = false
	hits.clear()
	rate = 1.0
	zoom = 1.0
	radial = 0.0
	Engine.time_scale = 1.0


## How deep in the slow motion we are now (0..1), by real time since it began.
static func slow_strength(t: float, ease_in: float, hold: float, ease_out: float) -> float:
	if t < ease_in:
		return t / maxf(ease_in, 0.001)
	if t < ease_in + hold:
		return 1.0
	return clampf(1.0 - (t - ease_in - hold) / maxf(ease_out, 0.001), 0.0, 1.0)


func _tick_slow(dt: float) -> void:
	if not _slow_on or _slow_wait:
		return
	_slow_t += dt
	if _slow_t >= _slow_in + _slow_hold + _slow_out:
		_slow_on = false
		zoom = 1.0
		radial = 0.0
		return
	var k := slow_strength(_slow_t, _slow_in, _slow_hold, _slow_out)
	zoom = lerpf(1.0, _slow_zoom, k)
	radial = _slow_blur * k


## The speed the slow motion leaves the world at now (1 when none plays).
func _slow_scale() -> float:
	if not _slow_on or _slow_wait:
		return 1.0
	return lerpf(1.0, _slow_fraction, slow_strength(_slow_t, _slow_in, _slow_hold, _slow_out))


## Ages the pooled effects (also during hit stop, so the impact frame keeps glowing). A new frame: the budget of
## what may start is whole again.
func animate(delta: float) -> void:
	budget.reset()
	for i in range(_later_rings.size() - 1, -1, -1):
		var w: Dictionary = _later_rings[i]
		w.wait -= delta
		if w.wait <= 0.0:
			_later_rings.remove_at(i)
			ring(w.center, w.radius, w.color, 0.32, 0.14, false, true)
	for list: Array[Dictionary] in [_slashes, _inks]:
		for s in list:
			if s.life < 1.0 or (s.node as Node3D).visible:
				if freeze_t >= 0.0:
					s.life = freeze_t / (Feel.live().ink_life if list == _inks else 1.0)
				else:
					_age(s, delta)
				(s.mat as ShaderMaterial).set_shader_parameter(&"t", s.life)
	for s in _impacts:
		if (s.node as Node3D).visible:
			_age(s, delta)
			(s.mat as ShaderMaterial).set_shader_parameter(&"life", s.life)
	for list: Array[Dictionary] in [_thrusts, _boss_scythes, _boss_wakes]:
		for s in list:
			if (s.node as Node3D).visible:
				_age(s, delta)
				(s.mat as ShaderMaterial).set_shader_parameter(&"t", s.life)
	_animate_motes(delta)
	_animate_wisps(delta)
	_animate_blade(delta)
	_animate_ghosts(delta)
	for g in _glints:
		if (g.node as Node3D).visible:
			if freeze_t >= 0.0:
				g.life = freeze_t
			else:
				_age(g, delta)
			if is_instance_valid(g.follow):
				(g.node as Node3D).position = (g.follow as Node3D).global_position
			(g.mat as ShaderMaterial).set_shader_parameter(&"life", g.life)
	for c in _crescents:
		if (c.node as Node3D).visible:
			if freeze_t >= 0.0:
				c.life = freeze_t
			else:
				_age(c, delta)
			var out: float = 1.0 - pow(1.0 - c.life, 3.0)
			(c.node as Node3D).scale = Vector3.ONE * lerpf(1.0, CRESCENT_GROW, out)
			(c.mat as ShaderMaterial).set_shader_parameter(&"t", c.life)
	for r in _rings:
		if (r.node as Node3D).visible:
			if r.get("mode", RING_OPEN) == RING_HELD:
				continue  # (a wave the caller moves: it keeps its own radius)
			_age(r, delta)
			if r.get("mode", RING_OPEN) == RING_FADE:
				(r.node as Node3D).scale = Vector3.ONE * r.size
				(r.mat as ShaderMaterial).set_shader_parameter(&"life", r.life)
				continue
			var k: float = 1.0 - pow(1.0 - r.life, 3.0)
			(r.node as Node3D).scale = Vector3.ONE * r.size * lerpf(0.3, 1.0, k)
			(r.mat as ShaderMaterial).set_shader_parameter(&"life", r.life)
	for c in _contacts:
		if (c.node as Node3D).visible:
			_age(c, delta)
			var mi: Node3D = c.node
			mi.scale = Vector3.ONE * c.size * lerpf(1.0, CONTACT_GROW, c.life) / CONTACT_GROW
			(c.mat as ShaderMaterial).set_shader_parameter(&"life", c.life)
	for sp in _spikes:
		if (sp.node as Node3D).visible:
			_step_spike(sp, delta)
	for m in _marks:
		if (m.node as Node3D).visible:
			_age(m, delta)
			(m.mat as ShaderMaterial).set_shader_parameter(&"life", m.life)
	for r in _smoke_rings:
		if (r.node as Node3D).visible:
			_age(r, delta)
			(r.mat as ShaderMaterial).set_shader_parameter(&"life", r.life)
	for l in _lights:
		if (l.node as Node3D).visible:
			_age(l, delta)
			(l.node as OmniLight3D).light_energy = l.energy * pow(1.0 - l.life, 2.0)
	for b in _beams:
		if (b.node as Node3D).visible:
			_age(b, delta)
			var mi: Node3D = b.node
			mi.scale.x = b.size * (1.0 - b.life * 0.6)
			mi.scale.z = mi.scale.x
			(b.mat as ShaderMaterial).set_shader_parameter(&"life", b.life)
	if freeze_t >= 0.0:
		for e in _tally.entries:
			e.life = 0.2
	else:
		_tally.age(delta)
	for i in _labels.size():
		var l := _labels[i]
		var e := _tally.entries[i]
		if not e.shown or camera == null:
			l.visible = false
			continue
		if not l.visible:
			continue
		var p: Vector3 = e.pos + Vector3(0, e.life * 1.6, 0)
		if camera.is_position_behind(p):
			l.visible = false
			_tally.hide(i)
			continue
		var sp := camera.unproject_position(p)
		if hero_head.is_finite() and not camera.is_position_behind(hero_head):
			sp = NumberTally.clear_of(sp, camera.unproject_position(hero_head), NumberTally.HERO_CLEAR + l.size.y * 0.5)
		# vfx_pass_spec.md 5.7: in at NUMBER_POP x and down to 1 in NUMBER_POP_TIME (it was 1.48 down over 0.12 s)
		var pop := 1.0 + (NUMBER_POP - 1.0) * maxf(0.0, 1.0 - e.life / NUMBER_POP_TIME)
		l.scale = Vector2.ONE * pop
		l.position = sp - l.size * 0.5 * pop
		l.modulate.a = 1.0 - smoothstep(0.45, NumberTally.LIFE, e.life)


func _animate_motes(delta: float) -> void:
	if _mote_n == 0:
		if _motes.visible_instance_count != 0:
			_motes.visible_instance_count = 0
		return
	var i := 0
	var drag := maxf(0.0, 1.0 - MOTE_DRAG * delta)
	while i < _mote_n:
		var life := _mote_life[i] + delta / _mote_time[i]
		if life >= 1.0:
			# the last one takes its place
			_mote_n -= 1
			_mote_pos[i] = _mote_pos[_mote_n]
			_mote_vel[i] = _mote_vel[_mote_n]
			_mote_life[i] = _mote_life[_mote_n]
			_mote_time[i] = _mote_time[_mote_n]
			_mote_size[i] = _mote_size[_mote_n]
			_mote_color[i] = _mote_color[_mote_n]
			_mote_grav[i] = _mote_grav[_mote_n]
			_mote_burst[i] = _mote_burst[_mote_n]
			_mote_shape[i] = _mote_shape[_mote_n]
			continue
		_mote_life[i] = life
		var vel := _mote_vel[i] * drag - Vector3(0, _mote_grav[i] * delta, 0)
		_mote_vel[i] = vel
		_mote_pos[i] += vel * delta
		var fade := 1.0 - life * life
		# a sliver where it is (chip.gdshader): the basis's x column is its axis along the flight, as long as the
		# streak, the y column's length its width; its colour fading (what set_instance_transform and
		# set_instance_color would store, written into the buffer: three rows of basis x, y, z and origin)
		var w := _mote_size[i] * MOTE_WIDTH * (0.7 + 0.3 * fade)
		var ax := streak(vel, w)
		var at := _mote_pos[i]
		var c := _mote_color[i] * fade
		var o := i * 16
		var d := _mote_buf
		d[o] = ax.x; d[o + 1] = 0.0; d[o + 2] = 0.0; d[o + 3] = at.x
		d[o + 4] = ax.y; d[o + 5] = w; d[o + 6] = 0.0; d[o + 7] = at.y
		d[o + 8] = ax.z; d[o + 9] = float(_mote_shape[i]); d[o + 10] = w; d[o + 11] = at.z
		d[o + 12] = c.r; d[o + 13] = c.g; d[o + 14] = c.b; d[o + 15] = c.a
		i += 1
	if _mote_n > 0:
		_motes.buffer = _mote_buf
	_motes.visible_instance_count = _mote_n


func _animate_wisps(delta: float) -> void:
	if _wisp_n == 0:
		if _wisps.visible_instance_count != 0:
			_wisps.visible_instance_count = 0
		return
	var drag := maxf(0.0, 1.0 - 2.5 * delta)
	var i := 0
	while i < _wisp_n:
		var life := _wisp_life[i] + delta / _wisp_time[i]
		if life >= 1.0:
			_wisp_n -= 1
			for arr in [_wisp_pos, _wisp_vel, _wisp_life, _wisp_time, _wisp_size, _wisp_color, _wisp_rise]:
				arr[i] = arr[_wisp_n]
			continue
		_wisp_life[i] = life
		_wisp_vel[i] = _wisp_vel[i] * drag + Vector3(0, _wisp_rise[i] * delta, 0)
		_wisp_pos[i] += _wisp_vel[i] * delta
		var w := _wisp_size[i] * (0.7 + 0.6 * life)
		_wisps.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(w, w * 1.6, w)), _wisp_pos[i]))
		var c := _wisp_color[i]
		_wisps.set_instance_color(i, Color(c.r, c.g, c.b, 1.0 - life))
		_wisps.set_instance_custom_data(i, Color(float(i % 17) / 17.0, life, 0, 0))
		i += 1
	_wisps.visible_instance_count = _wisp_n


## The axis of a sliver flying at vel, width w meters across: along the flight, MOTE_STREAK seconds of it long but
## never shorter or longer than MOTE_LONG times its width (still, it lies along x).
static func streak(vel: Vector3, w: float) -> Vector3:
	var along := vel.normalized() if vel.length_squared() > 0.000001 else Vector3.RIGHT
	return along * clampf(vel.length() * MOTE_STREAK, w * MOTE_LONG.x, w * MOTE_LONG.y)


## The pulse of the blade falls back to its still light. The blade is looked for once: the sword EmethSword made
## that lives in this game (the title screen has one of its own).
func _animate_blade(delta: float) -> void:
	_animate_return()
	if _pulse <= 0.0:
		return
	if _blade_hold > 0.0:
		_blade_hold -= delta
	else:
		_pulse = maxf(0.0, _pulse - delta / BLADE_PULSE)
	if _find_blade():
		EmethSword.set_pulse(_blade, _pulse)


var _ghosts: Array[Dictionary] = []
var _ghost_bodies: Array[MeshInstance3D] = []
var _ghost_t := 0.0
var _ghost_n := 0
var _ghost_player: Node = null
# no screen (tests, --smoke): nothing to see, and the headless server keeps no mesh data to bake from
var _ghost_off := DisplayServer.get_name() == "headless"


## V-08: while the paladin dodges, his pose is baked into a pooled mesh (MeshInstance3D.bake_mesh_from_current_skeleton_pose)
## every GHOST_EVERY s and left behind in ink; tests and the lab without a player draw nothing.
func _animate_ghosts(delta: float) -> void:
	for g in _ghosts:
		var gi: MeshInstance3D = g.node
		if gi.visible:
			g.life += delta / GHOST_TIME
			if g.life >= 1.0:
				gi.visible = false
			else:
				(g.mat as ShaderMaterial).set_shader_parameter(&"life", g.life)
	if _ghost_off:
		return
	var p: Variant = get_parent().get(&"player") if get_parent() != null else null
	if p == null or not is_instance_valid(p) or not p is Player:
		return
	var player := p as Player
	if player.state != Player.State.DODGE:
		_ghost_n = 0
		_ghost_t = 0.0
		return
	_ghost_t -= delta
	if _ghost_t > 0.0 or _ghost_n >= GHOST_MAX:
		return
	_ghost_t = GHOST_EVERY
	_ghost_n += 1
	if _ghost_player != player:
		_ghost_player = player
		_ghost_bodies.clear()
		for n in player.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			if mi.skin != null and mi.mesh != null:
				_ghost_bodies.append(mi)
	for body in _ghost_bodies:
		_ghost_of(body)


func _ghost_of(body: MeshInstance3D) -> void:
	var g: Dictionary = {}
	for e in _ghosts:
		if not (e.node as MeshInstance3D).visible:
			g = e
			break
	if g.is_empty():
		if _ghosts.size() >= GHOST_MAX * 2:
			return
		var mat := ShaderMaterial.new()
		mat.shader = DODGE_GHOST
		mat.render_priority = 1
		var gi := MeshInstance3D.new()
		gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gi.material_override = mat
		add_child(gi)
		g = {"node": gi, "mat": mat, "life": 0.0, "mesh": null}
		_ghosts.append(g)
	var node: MeshInstance3D = g.node
	g.mesh = body.bake_mesh_from_current_skeleton_pose(g.mesh)
	node.mesh = g.mesh
	node.global_transform = body.global_transform
	node.visible = true
	g.life = 0.0
	(g.mat as ShaderMaterial).set_shader_parameter(&"life", 0.0)


func _find_blade() -> bool:
	if not _blade_looked:
		_blade_looked = true
		_blade = EmethSword.blade_of(get_parent())
	return _blade != null


## V-08 (AP-2): the Retorno do Corte's window as a thread on the blade (EmethSword.set_return), read from the game's
## Combat each frame (its _return_t counts the window down and is zeroed by the blow that takes it). Only the look.
var _return_window := 0.0
var _return_shown := 0.0
var _return_prev := 0.0


func _animate_return() -> void:
	var combat: Variant = get_parent().get(&"combat") if get_parent() != null else null
	if combat == null or not (combat is Object) or not (combat as Object).get(&"_return_t") is float:
		return
	var left: float = (combat as Object).get(&"_return_t")
	if left > _return_prev or left <= 0.0:
		_return_window = left
	_return_prev = left
	var k := left / _return_window if _return_window > 0.0 else 0.0
	if k == _return_shown:
		return
	_return_shown = k
	if _find_blade():
		EmethSword.set_return(_blade, k)


func _age(e: Dictionary, delta: float) -> void:
	e.life = minf(1.0, e.life + delta / maxf(e.time, 0.01))
	if e.life >= 1.0:
		(e.node as Node3D).visible = false


func _take(pool: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = pool[0]
	for e in pool:
		if not (e.node as Node3D).visible:
			best = e
			break
		if e.life > best.life:
			best = e
	best.life = 0.0
	(best.node as Node3D).visible = true
	return best


## The label of tally entry i shows text; the labels of entries the tally let go are hidden.
func _show_label(i: int, text: String, color: Color, size: int, outline: int = 0) -> void:
	for k in _labels.size():
		if not _tally.entries[k].shown:
			_labels[k].visible = false
	var l := _labels[i]
	l.text = text
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	if outline > 0:
		l.add_theme_constant_override(&"outline_size", outline)
	else:
		l.remove_theme_constant_override(&"outline_size")
	l.visible = true
	l.size = Vector2.ZERO
	l.pivot_offset = l.get_combined_minimum_size() * 0.5
	var at := _tally.entries[i].pos
	if camera and not camera.is_position_behind(at):
		l.position = camera.unproject_position(at) - l.get_combined_minimum_size() * 0.5
	else:
		l.visible = false
		_tally.hide(i)


func _jitter() -> Vector3:
	return Vector3(_rng.randf_range(-0.2, 0.2), 0, _rng.randf_range(-0.1, 0.1))


## Ring sector mesh: UV.x along the swing, UV.y from the inner (inner_frac of reach) to the outer edge. Cached by size.
func _arc(reach: float, width_deg: float, inner_frac: float) -> ArrayMesh:
	var key := Vector3i(roundi(reach * 10.0), roundi(width_deg), roundi(inner_frac * 100.0))
	if _arc_meshes.has(key):
		return _arc_meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := maxi(12, ceili(width_deg / 5.0))
	var half := deg_to_rad(minf(width_deg, 359.0)) * 0.5
	var inner := reach * inner_frac
	for i in seg:
		var a0 := -half + 2.0 * half * i / seg
		var a1 := -half + 2.0 * half * (i + 1) / seg
		var u0 := float(i) / seg
		var u1 := float(i + 1) / seg
		var p := [Vector3(sin(a0) * inner, 0, cos(a0) * inner), Vector3(sin(a0) * reach, 0, cos(a0) * reach),
			Vector3(sin(a1) * inner, 0, cos(a1) * inner), Vector3(sin(a1) * reach, 0, cos(a1) * reach)]
		var uv := [Vector2(u0, 0), Vector2(u0, 1), Vector2(u1, 0), Vector2(u1, 1)]
		for k: int in [0, 1, 2, 2, 1, 3]:
			st.set_uv(uv[k])
			st.add_vertex(p[k])
	var mesh := st.commit()
	_arc_meshes[key] = mesh
	return mesh


## "ouro" from the text table, through the autoload found at run time: naming T here broke every -s lab that draws the
## crowd (a -s script and what it names compile before the autoloads exist).
func _gold_word() -> String:
	var t: Node = get_node_or_null(^"/root/T")
	return t.call(&"t", &"hud_gold_short") if t != null else "ouro"
