class_name Feel
extends Resource
## Everything that sets how the game feels in the hands: movement, the roll, camera, hit stop, shake, the
## paladin's outline and the two layers of the sword arc. Lives in data/feel.tres (written by tools/make_data.gd).
## In debug builds the F1 panel (scripts/ui/feel_panel.gd) edits it live and can save user://feel_override.tres,
## which then wins over data/feel.tres on that machine (never in --nosave runs, so tests and smoke runs stay clean).
## Every number needs a range hint: the panel builds its sliders from them.

const PATH := "res://data/feel.tres"
const OVERRIDE := "user://feel_override.tres"

@export_group("Movement")
@export_range(2.0, 14.0, 0.1) var speed := 6.8
@export_range(8.0, 40.0, 0.5) var dodge_speed := 24.0
@export_range(0.05, 0.5, 0.01) var dodge_time := 0.2
@export_range(0.0, 0.8, 0.01) var dodge_iframes := 0.2
## C1e, the close dodge: a blow that would land this many seconds into the roll, at most one reward every close_cooldown s;
## the reward is a slow motion at close_fraction of the speed for close_slow real seconds.
@export_range(0.05, 0.3, 0.01) var close_window := 0.15
@export_range(0.0, 3.0, 0.1) var close_cooldown := 2.0
@export_range(0.1, 1.0, 0.05) var close_fraction := 0.4
@export_range(0.05, 0.6, 0.01) var close_slow := 0.25
## PT-1: seconds before a blow lands that the "!" over the enemy lights (the moment to dodge; the floor shows no line for it).
@export_range(0.1, 0.8, 0.01) var bang_lead := 0.35
## Holding the dodge button after the roll runs this many times the walking speed.
@export_range(1.0, 3.0, 0.05) var sprint_scale := 1.5
## How much of the walking speed a swing keeps, by kind of move (a ComboNode can set its own move_scale).
@export_range(0.0, 1.0, 0.01) var move_scale_light := 0.6
@export_range(0.0, 1.0, 0.01) var move_scale_heavy := 0.35
@export_range(0.0, 1.0, 0.01) var move_scale_finisher := 0.15

@export_group("Camera")
## Meters from the point the camera looks at.
@export_range(8.0, 70.0, 0.5) var cam_distance := 44.0
## Meters from the point the camera looks at with the near camera of the options (the save's "camera" "near"; CamRig.near).
@export_range(8.0, 70.0, 0.5) var cam_distance_near := 30.0
## Degrees above the floor.
@export_range(15.0, 85.0, 0.5) var cam_pitch := 50.0
@export_range(15.0, 70.0, 0.5) var cam_fov := 32.0
## Turn of the camera around the floor's up axis, degrees: 0 looks straight north; positive stands it to the
## south-east looking north-west (the diamond view of the catacomb hall). Movement turns with it (screen up = away).
@export_range(-90.0, 90.0, 0.5) var cam_yaw := 0.0
## Meters the camera leads towards where the paladin faces.
@export_range(0.0, 6.0, 0.1) var cam_lead := 2.2
## How fast the camera catches up (higher is stiffer).
@export_range(1.0, 20.0, 0.5) var cam_smooth := 6.0

@export_group("Impact")
## Multiplies the hit stop of every move in the combo data.
@export_range(0.0, 3.0, 0.05) var hit_stop_scale := 0.4
## Multiplies the glint of every finisher (the hold with a star of light before it lands; 0 = off).
@export_range(0.0, 3.0, 0.05) var glint_scale := 1.0
@export_range(0.0, 3.0, 0.05) var shake_scale := 1.0
## The jolt of the camera along a blow.
@export_range(0.0, 3.0, 0.05) var kick_scale := 1.0
## Seconds of the flat black and white frame on an Omega that lands or the blow that ends a boss's phase (0 = off).
@export_range(0.0, 0.15, 0.005) var impact_frame := 0.05
## The fewest seconds between two impact frames (Combat).
@export_range(0.0, 30.0, 0.5) var impact_frame_every := 10.0

@export_group("Hold")
## GP-1 (ButtonIntent): seconds a blow button is held before it stops being a tap and becomes the held blow (0.20 s).
@export_range(0.05, 0.6, 0.01) var hold_threshold := 0.2
## A held blow with no Magia for it: false = the Magia bar flashes and nothing strikes; true = the tap's blow comes out at the threshold.
@export var hold_fallback_tap := false

@export_group("Poise")
## C1b (Poise): the share of a common enemy's full poise each button's blow takes, by DealtBy source (Dictionary: no
## slider). A source missing here takes none.
@export var poise_weights: Dictionary = {}

@export_group("Hurt")
## The red at the edges of the screen when the paladin is hurt (screen.gdshader): its strongest alpha, how long it
## fades, the damage from which a blow gets all of it (smaller blows get hurt_tint_small of it) and the colour split
## of those heavy blows (0 = none). It never reaches the middle of the screen.
@export_range(0.0, 1.0, 0.01) var hurt_tint := 0.42
@export_range(0.05, 1.0, 0.01) var hurt_tint_time := 0.22
@export_range(0.0, 60.0, 0.5) var hurt_tint_heavy := 10.0
@export_range(0.0, 1.0, 0.05) var hurt_tint_small := 0.5
@export_range(0.0, 1.0, 0.05) var hurt_split := 0.35
## Under a boss's curse the blow tints the edges in the curse's violet instead (CurseAura.COLOR), never with a split.
@export_range(0.0, 1.0, 0.01) var curse_tint := 0.2
@export_range(0.05, 1.0, 0.01) var curse_tint_time := 0.2

@export_group("Look")
## Gold edge and see-through silhouette on the paladin (0 = off).
@export_range(0.0, 2.0, 0.05) var outline := 1.0

@export_group("Sword arc")
## Bright streaks (slash.gdshader).
@export_range(0.0, 6.0, 0.1) var slash_intensity := 1.7
## Seconds the head of an arc takes to sweep through (C12d: 0.05, three frames with the blade).
@export_range(0.02, 0.4, 0.01) var slash_sweep_time := 0.05
## Dark ink stroke under it (slash_ink.gdshader): opacity, and how much longer than the streaks it lingers.
@export_range(0.0, 1.0, 0.01) var ink_opacity := 0.85
@export_range(1.0, 4.0, 0.05) var ink_life := 2.0

static var _live: Feel


## The values in use (loaded once; the F1 panel edits this same object).
static func live() -> Feel:
	if _live == null:
		_live = load_current()
	return _live


static func load_current() -> Feel:
	if OS.is_debug_build() and not Dev.has("nosave") and ResourceLoader.exists(OVERRIDE):
		var o := ResourceLoader.load(OVERRIDE, "", ResourceLoader.CACHE_MODE_IGNORE) as Feel
		if o != null:
			return o
	var base := load(PATH) as Feel
	return base.duplicate() if base != null else Feel.new()


static func save_override() -> Error:
	return ResourceSaver.save(live(), OVERRIDE)


## Drops the saved override and goes back to data/feel.tres.
static func reset() -> void:
	if FileAccess.file_exists(OVERRIDE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(OVERRIDE))
	_live = null
	_live = load_current()


## Where the camera sits relative to what it looks at.
static func cam_offset_of(distance: float, pitch_deg: float, yaw_deg: float = 0.0) -> Vector3:
	var p := deg_to_rad(pitch_deg)
	return Vector3(0, sin(p) * distance, cos(p) * distance).rotated(Vector3.UP, deg_to_rad(yaw_deg))


## A direction on the screen (x right, y down) as a direction on the floor (x, z), for a camera turned yaw degrees.
static func screen_to_floor(v: Vector2, yaw_deg: float) -> Vector2:
	return v.rotated(-deg_to_rad(yaw_deg))


## Default share of walking speed kept during a swing, by the move's tags.
func move_scale_for(tags: Array[StringName]) -> float:
	if tags.has(&"finisher"):
		return move_scale_finisher
	if tags.has(&"heavy"):
		return move_scale_heavy
	return move_scale_light
