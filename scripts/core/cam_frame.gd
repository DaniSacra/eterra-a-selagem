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
