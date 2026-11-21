class_name CamFrame
extends RefCounted
## Framing rules of the game's camera (pure): where a point of the room lands on the screen, how far the point the
## camera looks at stays from the room's ends, and the safe frame the paladin never leaves.

## The paladin never stands closer than this share of the screen to any of its edges (QA of cycle 5, M3: on the west
## landing he was at 11% of the width, and at 5% in its far corner).
const SAFE := 0.18
## The point of the paladin kept inside the safe frame: his chest (meters over the floor).
const HERO_HEIGHT := 1.25
## The distance the room's margins (Game.CAM_MARGIN, CAM_SOUTH) were measured at: a closer camera sees less floor,
## so it may travel closer to the room's ends by the same share.
const MARGIN_DISTANCE := 60.0


## A margin measured at MARGIN_DISTANCE, for a camera at this distance.
static func margin(at_reference: float, distance: float) -> float:
	return at_reference * distance / MARGIN_DISTANCE


## Where a point `height` meters over the floor at `at` shows on the screen (0..1, x to the right, y down), for a
## camera looking at the floor point `target` (Feel.cam_offset_of). fov is the vertical one, in degrees.
static func screen_of(at: Vector2, height: float, target: Vector2, distance: float, pitch_deg: float, yaw_deg: float, fov_deg: float, aspect: float) -> Vector2:
	var p := deg_to_rad(pitch_deg)
	var d := at - target
	var side := d.dot(Feel.screen_to_floor(Vector2.RIGHT, yaw_deg))
	var ahead := d.dot(Feel.screen_to_floor(Vector2.UP, yaw_deg))
	var depth := distance + ahead * cos(p) - height * sin(p)
	var reach := maxf(depth, 0.001) * tan(deg_to_rad(fov_deg) * 0.5)
	return Vector2(0.5 + side / (reach * aspect) * 0.5, 0.5 - (ahead * sin(p) + height * cos(p)) / reach * 0.5)


## The point the camera looks at, moved as little as needed for the paladin (at `hero`) to stay `safe` of the screen
## away from every edge. The room's margins give way to it: on the landing outside the room's rectangle the camera
## follows him past them.
static func keep(target: Vector2, hero: Vector2, distance: float, pitch_deg: float, yaw_deg: float, fov_deg: float, aspect: float, safe: float = SAFE, height: float = HERO_HEIGHT) -> Vector2:
	var p := deg_to_rad(pitch_deg)
	var right := Feel.screen_to_floor(Vector2.RIGHT, yaw_deg)
	var forward := Feel.screen_to_floor(Vector2.UP, yaw_deg)
	var d := hero - target
	# half the safe frame, as the tangent of the angle from the middle of the screen
	var m := (1.0 - 2.0 * safe) * tan(deg_to_rad(fov_deg) * 0.5)
	var base := distance - height * sin(p)
	var rise := height * cos(p)
	# up and down the screen: how far ahead of the target (and behind it) he may stand
	var ahead := d.dot(forward)
	var top := sin(p) - m * cos(p)
	if top > 0.001:
		ahead = minf(ahead, (m * base - rise) / top)
	ahead = maxf(ahead, -(m * base + rise) / (sin(p) + m * cos(p)))
	# across the screen: the frame is wider the farther from the camera he stands
	var half := m * aspect * maxf(base + ahead * cos(p), 0.001)
	return hero - forward * ahead - right * clampf(d.dot(right), -half, half)


## The point a fixed camera looks at (a boss chamber, cycle C11): `target`, moved toward `want` and as much as the
## paladin's safe frame needs (keep), but never more than `reach` meters from `target`. follow false: only `want`
## (a scene of its own, the paladin may leave the frame).
## slack (the near camera, see slack()): beyond `reach`, how far more it may go across and up the screen.
## safe: the paladin's safe frame (the hub's arrival look keeps him nearer the edge, HubPlan.ARRIVAL_SAFE).
static func hold(target: Vector2, want: Vector2, reach: float, hero: Vector2, distance: float, pitch_deg: float, yaw_deg: float, fov_deg: float, aspect: float, follow := true, slack := Vector2.ZERO, safe := SAFE) -> Vector2:
	var at := widen(target + (want - target).limit_length(reach), want, slack, yaw_deg)
	if follow:
		at = keep(at, hero, distance, pitch_deg, yaw_deg, fov_deg, aspect, safe)
	return widen(target + (at - target).limit_length(reach), at, slack, yaw_deg)


## The near camera of the options (CamRig.near): how much farther (meters, across the screen and up it) the point
## it looks at may go past a fixed frame made for the camera at `far` (a room's cam_bounds, a fixed point's
## cam_reach), so that what the near one sees at its farthest is what the far one saw: half the floor seen in the
## middle of the screen, at `far` less at `distance`. Zero when the camera is not nearer.
static func slack(distance: float, far: float, pitch_deg: float, fov_deg: float, aspect: float) -> Vector2:
	var closer := maxf(far - distance, 0.0) * tan(deg_to_rad(fov_deg) * 0.5)
	return Vector2(closer * aspect, closer / maxf(sin(deg_to_rad(pitch_deg)), 0.1))


## `base` moved toward `want` by at most `slack` across the screen (x) and up it (y), for a camera turned `yaw_deg`.
static func widen(base: Vector2, want: Vector2, slack: Vector2, yaw_deg: float) -> Vector2:
	if slack == Vector2.ZERO:
		return base
	var right := Feel.screen_to_floor(Vector2.RIGHT, yaw_deg)
	var forward := Feel.screen_to_floor(Vector2.UP, yaw_deg)
	var d := want - base
	return base + right * clampf(d.dot(right), -slack.x, slack.x) + forward * clampf(d.dot(forward), -slack.y, slack.y)


## The point the camera looks at never moves faster than this (m/s; GP-06 of cycle C12c): the safe frame (keep,
## hold) followed a dash (28 m/s) or a push rigidly, 0.6 m in one frame at 60 FPS. The paladin's dash outruns it by
## at most about 0.8 m for its 0.2 s (2% of the screen's width at the game's distance).
const MAX_SPEED := 24.0


## The point the camera looks at this frame: `from` (the last) toward `want`, at most MAX_SPEED for delta seconds.
static func follow(from: Vector2, want: Vector2, delta: float) -> Vector2:
	return from.move_toward(want, MAX_SPEED * maxf(delta, 0.0))


## Dev (--trace-cam, GP-06 of cycle C12c): the largest jump of the point the camera looks at from one frame to the
## next, and where it happened. cut() starts over (a new room: the camera is placed anew).
class JumpTrace:
	extends RefCounted
	## The point of the frame before (INF: none yet).
	var last := Vector2.INF
	## The largest jump since the last cut (meters), what was given with it, and the frames measured.
	var worst := 0.0
	var worst_at := {}
	var frames := 0

	## The point of this frame; info says where (time, hero, room). Returns the jump from the frame before.
	func add(at: Vector2, info: Dictionary) -> float:
		var jump := at.distance_to(last) if last.is_finite() else 0.0
		last = at
		frames += 1
		if jump > worst:
			worst = jump
			worst_at = info.duplicate()
			worst_at["target"] = at
		return jump

	## Starts over; returns what was measured until now ({worst, at, frames}).
	func cut() -> Dictionary:
		var out := {"worst": worst, "at": worst_at, "frames": frames}
		last = Vector2.INF
		worst = 0.0
		worst_at = {}
		frames = 0
		return out
