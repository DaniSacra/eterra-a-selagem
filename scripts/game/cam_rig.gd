class_name CamRig
extends RefCounted
## The game camera, shared by the run (Game) and the hub (HUB-01, HUB-B1): it follows the paladin a little ahead of
## where he walks (Feel.cam_lead), inside the room's margins (Game.CAM_MARGIN, CAM_SOUTH) but never with him nearer
## than CamFrame.SAFE to an edge of the screen (CamFrame.keep), never faster than CamFrame.MAX_SPEED (CamFrame.follow);
## a room with a fixed point (RoomLayout.cam_target and cam_reach: the Seal Chamber, the hub) holds on it and moves only
## for his safe frame (CamFrame.hold). It was Game's _follow, _place_camera, cam_look_at, chamber_look_at and
## _cam_offset; the numbers did not change.
## The options' near camera (the save's "camera" "near", --cam=near; Daniel, 2026-11-19): Feel.cam_distance_near (37 m,
## Hades II's 0.85) for Feel.cam_distance (54); the rooms' margins scale with it (CamFrame.margin), and a fixed frame made
## for the far camera (cam_bounds, cam_target with cam_reach) widens by what the far one saw more (CamFrame.slack): the
## near camera follows him there, it never holds on a point that leaves him or the fight out. Far: as before.
##   var rig := CamRig.new(camera, arena, player)
##   rig.snap()                          # a new room: framed on him at once
##   rig.follow(delta, shake, zoom)      # every frame

## How much closer the camera gets at the end of an Omega's charge (Hades II: 8% over the charge).
const OMEGA_ZOOM := 0.08
## How far the fixed showcase camera (--showcase) stands from the hall's middle, to frame all of it like the reference.
const SHOWCASE_DISTANCE := 60.0

var camera: Camera3D
var arena: Arena
var player: Player
## A scene of its own (the fall of Morvath; null: none): the camera looks at it, wherever the paladin stands.
var focus: Variant = null
## A floor point the camera eases toward instead of its own (INF: none): the hub's station in focus (HubPlan.frame_for,
## HUB-D). Unlike focus, the paladin's safe frame and the room's reach still hold.
var lean := Vector2.INF
## The point the camera follows (eased) and the floor point it looked at last frame (INF: place it anew).
var target := Vector3.ZERO
var at := Vector2.INF
## Called with the point looked at every frame it is placed (Game's --trace-cam; null: none).
var on_placed: Callable
var _charge_zoom := 0.0
## Where the paladin stood last frame and how fast he walks, smoothed (the camera leads by it).
var _last := Vector2.ZERO
var _vel := Vector2.ZERO


func _init(cam: Camera3D, room: Arena, hero: Player) -> void:
	camera = cam
	arena = room
	player = hero
	camera.fov = Dev.num("cam-fov", Feel.live().cam_fov)
	camera.far = 160.0
	target = Vector3(player.pos.x, 0, player.pos.y)


## The near camera of the options: --cam=near|far, else the save's "camera" (read every frame: it changes live).
static func near() -> bool:
	if Dev.has("cam"):
		return Dev.arg("cam") == "near"
	return String(Save.option("camera")) == "near"


## Meters from the point the camera looks at: --cam-dist, else the near or the far one of Feel.
static func distance() -> float:
	if Dev.has("cam-dist"):
		return Dev.num("cam-dist", 0.0)
	return Feel.live().cam_distance_near if near() else Feel.live().cam_distance


## The near camera's room past a fixed frame made for the far one (CamFrame.slack; zero with the far camera).
func slack(distance: float, _fov: float, as_far := false) -> Vector2:
	if as_far or not near():
		return Vector2.ZERO
	var fov := Dev.num("cam-fov", Feel.live().cam_fov)
	var view := camera.get_viewport().get_visible_rect().size
	return CamFrame.slack(distance, Feel.live().cam_distance, Dev.num("cam-pitch", Feel.live().cam_pitch), fov, view.x / maxf(view.y, 1.0))


## Whether the camera keeps to the room's fixed point (cam_target): only the far one (the near one follows him).
func holds() -> bool:
	return arena.cam_reach > 0.0 and not near()


## The camera's turn around the up axis, degrees (--cam-yaw overrides it).
static func yaw() -> float:
	return Dev.num("cam-yaw", Feel.live().cam_yaw)


## A new room: the camera starts framed on the paladin where he walks in, not flying over from where it looked in
## the room before (GP-06: that flight, behind the fade in, moved its target up to 2.9 m a frame).
func snap() -> void:
	var p := arena.cam_target if holds() else player.pos
	target = Vector3(p.x, 0, p.y)
	_last = player.pos
	_vel = Vector2.ZERO
	at = Vector2.INF


## Every frame: eases the followed point and places the camera. zoom: the slow motion's (Fx.zoom; 1 without).
func follow(delta: float, shake: Vector3, zoom := 1.0) -> void:
	var look: Vector3
	if focus != null:
		look = focus
	elif lean.is_finite():
		look = Vector3(lean.x, 0, lean.y)
		_last = player.pos
	elif holds():
		# a boss chamber: the camera keeps to its point (look_at moves it only for the paladin's safe frame)
		look = Vector3(arena.cam_target.x, 0, arena.cam_target.y)
	else:
		# a little ahead of where the paladin walks (never where he aims: standing still, he stays in the middle)
		var walked := (player.pos - _last) / maxf(delta, 0.001)
		_last = player.pos
		_vel = _vel.lerp(walked, 1.0 - exp(-delta * 5.0))
		var lead := (_vel / maxf(Feel.live().speed, 0.1)).limit_length(1.0) * Feel.live().cam_lead
		look = Vector3(player.pos.x + lead.x, 0, player.pos.y + lead.y)
	target = target.lerp(look, 1.0 - exp(-delta * (2.5 if focus != null else Feel.live().cam_smooth)))
	place(shake, delta, zoom)


func place(shake: Vector3, delta: float, zoom := 1.0) -> void:
	if Dev.has("showcase"):
		# the fixed frame of the whole hall, to set side by side with the reference image
		var c := arena.showcase
		if Dev.has("cam-at"):
			# --cam-at=x,z: the fixed camera looks at this floor point instead (close-ups of the hall)
			var xz := Dev.arg("cam-at").split(",")
			c = Vector3(float(xz[0]), 0.0, float(xz[1]))
		var off := Feel.cam_offset_of(Dev.num("cam-dist", SHOWCASE_DISTANCE), Dev.num("cam-pitch", Feel.live().cam_pitch), yaw())
		camera.fov = Dev.num("cam-fov", Feel.live().cam_fov)
		camera.look_at_from_position(c + off, c, Vector3.UP)
		return
	var off := offset(zoom)
	var p := look_at(Vector2(target.x, target.z), distance(), camera.fov)
	# never faster than CamFrame.MAX_SPEED (GP-06): the safe frame follows a dash or a push without a jump
	if at.is_finite():
		p = CamFrame.follow(at, p, delta)
	at = p
	if on_placed.is_valid():
		on_placed.call(p)
	var t := Vector3(p.x, 0, p.y)
	camera.look_at_from_position(t + off + shake, t + shake * 0.5, Vector3.UP)


## The floor point the camera looks at, for the point it follows: inside the room's margins, unless the paladin
## would stand near an edge of the screen (the landing by the way in lies outside the room's rectangle).
## as_far: where the far camera would look whatever the options say (the shooters' fair frame, LR-02: no slack).
func look_at(want: Vector2, distance: float, fov: float, as_far := false) -> Vector2:
	if arena.cam_reach > 0.0:
		return hold_at(want, distance, fov, as_far)
	var h := arena.half
	var side := maxf(0.0, h.x - CamFrame.margin(Game.CAM_MARGIN.x, distance))
	var p := Vector2(clampf(want.x, -side, side), clampf(want.y,
		minf(0.0, -h.y + CamFrame.margin(Game.CAM_MARGIN.y, distance) - arena.view_north), maxf(0.0, h.y - CamFrame.margin(Game.CAM_SOUTH, distance))))
	if arena.cam_bounds.has_area():
		# an arena's own box for the point the camera looks at (cycle C12; the same spring follows it, no zoom)
		p = want.clamp(arena.cam_bounds.position, arena.cam_bounds.end)
		# the near camera may go past it by what the far one saw more (CamFrame.slack; zero far)
		p = CamFrame.widen(p, want, slack(distance, fov, as_far), yaw())
	if focus != null:
		# a scene of its own (the fall of Morvath): the camera looks at it, wherever the paladin stands
		return p
	var view := camera.get_viewport().get_visible_rect().size
	return CamFrame.keep(p, player.pos, distance, Dev.num("cam-pitch", Feel.live().cam_pitch), yaw(), fov, view.x / maxf(view.y, 1.0))


## The floor point the camera looks at in a room with a fixed point (cycle C11, docs/art/boss_chamber_spec.md section 4;
## the hub): its point (Arena.cam_target), moved only as much as the paladin's safe frame needs (CamFrame.keep, 18% of
## the screen), and never more than Arena.cam_reach meters from it.
func hold_at(want: Vector2, distance: float, fov: float, as_far := false) -> Vector2:
	var view := camera.get_viewport().get_visible_rect().size
	return CamFrame.hold(arena.cam_target, want, arena.cam_reach, player.pos, distance, Dev.num("cam-pitch", Feel.live().cam_pitch), yaw(),
		fov, view.x / maxf(view.y, 1.0), focus == null, slack(distance, fov, as_far))


## Camera offset from feel.tres; --cam-dist, --cam-pitch (degrees above the floor) and --cam-fov override it for tuning.
## zoom: the slow motion's (Fx.zoom); the camera also closes in while an Omega charges (OMEGA_ZOOM over the charge).
func offset(zoom := 1.0) -> Vector3:
	var feel := Feel.live()
	var charge := player.charge_progress() * OMEGA_ZOOM
	_charge_zoom = charge if charge > _charge_zoom else lerpf(_charge_zoom, charge, 1.0 - exp(-camera.get_process_delta_time() / maxf(Engine.time_scale, 0.001) * 6.0))
	camera.fov = Dev.num("cam-fov", feel.cam_fov) / (zoom * (1.0 + _charge_zoom))
	return Feel.cam_offset_of(distance(), Dev.num("cam-pitch", feel.cam_pitch), yaw())
