class_name SkyCamera
extends RefCounted
## The camera of the constellation map (SW-M1): a world point `center` seen at the screen point `anchor`, magnified by
## `zoom`. Choosing a figure closes on it (`close_on`), going back opens to the whole sky (`open_out`); both only set the
## target, `step(dt)` slides the camera there (exponential, so it eases out and never overshoots). Pure arithmetic.
##   var cam := SkyCamera.new(Vector2(640, 360), Vector2(640, 360))
##   cam.close_on(figure_centre, Vector2(480, 395)); cam.step(delta); cam.to_screen(world_point)

const ZOOM_OUT := 1.0
const ZOOM_IN := 2.4
const ZOOM_MIN := 0.8
const ZOOM_MAX := 3.4
## How fast the camera closes the gap (1 / s): about 0,5 s to settle.
const RATE := 7.0

var center: Vector2
var anchor: Vector2
var zoom := ZOOM_OUT
var target_center: Vector2
var target_anchor: Vector2
var target_zoom := ZOOM_OUT
var _home_center: Vector2
var _home_anchor: Vector2


func _init(p_center: Vector2 = Vector2.ZERO, p_anchor: Vector2 = Vector2.ZERO) -> void:
	_home_center = p_center
	_home_anchor = p_anchor
	center = p_center
	anchor = p_anchor
	target_center = p_center
	target_anchor = p_anchor


## Aims at a figure: its centre at the screen point `at`, at `z` times.
func close_on(world: Vector2, at: Vector2, z: float = ZOOM_IN) -> void:
	target_center = world
	target_anchor = at
	target_zoom = clampf(z, ZOOM_MIN, ZOOM_MAX)


## Aims at the whole sky again.
func open_out() -> void:
	target_center = _home_center
	target_anchor = _home_anchor
	target_zoom = ZOOM_OUT


## The mouse wheel: one notch closer (+1) or farther (-1) on the same centre, never past the limits.
func wheel(dir: int) -> void:
	target_zoom = clampf(target_zoom * pow(1.25, dir), ZOOM_MIN, ZOOM_MAX)


func step(delta: float) -> void:
	var k := 1.0 - exp(-RATE * delta)
	center = center.lerp(target_center, k)
	anchor = anchor.lerp(target_anchor, k)
	zoom = lerpf(zoom, target_zoom, k)


## Jumps to the target (the screen opens already there; tests).
func snap() -> void:
	center = target_center
	anchor = target_anchor
	zoom = target_zoom


func settled() -> bool:
	return absf(zoom - target_zoom) < 0.005 and center.distance_to(target_center) < 0.3 and anchor.distance_to(target_anchor) < 0.3


## True once the camera is aimed at a figure (past the whole-sky view).
func closed_in() -> bool:
	return target_zoom > ZOOM_OUT + 0.05


## 0 (the whole sky) to 1 (closed on a figure): how far the camera is between the two, for fading what changes with it.
func progress() -> float:
	return clampf((zoom - ZOOM_OUT) / (ZOOM_IN - ZOOM_OUT), 0.0, 1.0)


func to_screen(world: Vector2) -> Vector2:
	return (world - center) * zoom + anchor


func to_world(screen: Vector2) -> Vector2:
	return (screen - anchor) / zoom + center
