class_name VendorScale
extends Control
## The Vendedor's balance (docs/art/shop_spec.md B.1 and B.3), drawn in the 1280 x 720 stage: a post on the counter, a beam
## that tilts about its pivot, two chains and two brass plates. The left plate carries what is given, the right what
## comes (any Control, put by show_offer). Preview shows them at 40%; put drops them on the plates and rocks the beam
## twice toward the given side (the heavier); take lifts them back; settle (the deal closed) sends the given out to the
## left and the received down to the purse, and the beam level again. `angle` is the tilt in degrees, positive with the
## left end down. Everything is placeholder drawing until assets/ui/shop/scale_*.png arrives.
##   scale.show_offer(give_control, get_control); scale.put(8.0); scale.settle()

signal settled

const PIVOT := Vector2(640, 200)
const HALF := 190.0
const DROP := 150.0
const PLATE := Vector2(150, 30)
const FOOT_Y := 560.0
const GHOST := 0.4
const ITEM_RISE := 46.0

var angle := 0.0:
	set(v):
		angle = v
		_layout()
		queue_redraw()
var put_on := false
## True while the closed deal is leaving the plates.
var busy := false
var left_item: Control
var right_item: Control
var _slide := Vector2.ZERO:
	set(v):
		_slide = v
		_layout()
var _fall := 0.0:
	set(v):
		_fall = v
		_layout()
var _alpha := 0.0:
	set(v):
		_alpha = v
		_layout()
var _tween: Tween


func _init() -> void:
	name = "scale"
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## What is given and what comes in the plates (null for nothing): previewed at 40% until put.
func show_offer(give: Control, receive: Control) -> void:
	clear()
	left_item = give
	right_item = receive
	for c in [give, receive]:
		if c != null:
			(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(c)
			(c as Control).size = (c as Control).get_combined_minimum_size()
	_alpha = GHOST
	_slide = Vector2.ZERO
	_fall = 0.0
	_layout()


func clear() -> void:
	_kill()
	for c in [left_item, right_item]:
		if c != null and is_instance_valid(c):
			(c as Control).queue_free()
	left_item = null
	right_item = null
	put_on = false
	angle = 0.0


## The first press: the items fall on the plates and the beam rocks toward the given side (deg).
func put(deg: float) -> void:
	_kill()
	put_on = true
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "_alpha", 1.0, 0.1)
	_tween.tween_property(self, "_fall", 0.0, 0.25).from(-ITEM_RISE).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var rock := _tween.chain().set_parallel(false)
	for k: float in [1.35, 0.8, 1.12, 1.0]:
		rock.tween_property(self, "angle", deg * k, 0.15).set_trans(Tween.TRANS_SINE)


## B: the items go back to the counter, the beam level again.
func take() -> void:
	_kill()
	put_on = false
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "_alpha", GHOST, 0.2)
	_tween.tween_property(self, "angle", 0.0, 0.2).set_trans(Tween.TRANS_SINE)


## The deal closed: the given leaves to the left, the received goes down to the purse, then the plates are empty.
func settle() -> void:
	_kill()
	put_on = false
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "_slide", Vector2(-130, 0), 0.25)
	_tween.tween_property(self, "_alpha", 0.0, 0.3)
	_tween.tween_property(self, "_fall", 70.0, 0.3)
	_tween.tween_property(self, "angle", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	busy = true
	_tween.chain().tween_callback(_done)


func _done() -> void:
	busy = false
	clear()
	settled.emit()


func _kill() -> void:
	busy = false
	if _tween != null:
		_tween.kill()
		_tween = null


## The beam's two ends and the centre of each plate for the tilt now.
func ends() -> Array[Vector2]:
	var a := deg_to_rad(angle)
	var left := PIVOT + Vector2(-cos(a), sin(a)) * HALF
	var right := PIVOT + Vector2(cos(a), -sin(a)) * HALF
	return [left, right, left + Vector2(0, DROP), right + Vector2(0, DROP)]


func _layout() -> void:
	var e := ends()
	if left_item != null and is_instance_valid(left_item):
		left_item.position = e[2] - Vector2(left_item.size.x * 0.5, ITEM_RISE) + Vector2(_slide.x, _fall)
		left_item.modulate.a = _alpha
	if right_item != null and is_instance_valid(right_item):
		right_item.position = e[3] - Vector2(right_item.size.x * 0.5, ITEM_RISE) + Vector2(0, _fall)
		right_item.modulate.a = _alpha


func _draw() -> void:
	var e := ends()
	var brass := ShopArt.BRASS
	var dark := brass.darkened(0.45)
	# the post and its foot
	draw_rect(Rect2(PIVOT.x - 7, PIVOT.y, 14, FOOT_Y - PIVOT.y), dark)
	draw_rect(Rect2(PIVOT.x - 4, PIVOT.y, 5, FOOT_Y - PIVOT.y), brass.darkened(0.2))
	draw_colored_polygon(PackedVector2Array([Vector2(PIVOT.x - 54, FOOT_Y), Vector2(PIVOT.x - 20, FOOT_Y - 40),
		Vector2(PIVOT.x + 20, FOOT_Y - 40), Vector2(PIVOT.x + 54, FOOT_Y)]), dark)
	# the beam, its pivot and the finial
	draw_line(e[0], e[1], dark, 10.0, true)
	draw_line(e[0], e[1], brass, 6.0, true)
	draw_circle(PIVOT, 12.0, dark)
	draw_circle(PIVOT, 8.0, brass)
	draw_circle(PIVOT + Vector2(0, -22), 5.0, brass)
	# the chains (three links each way) and the plates
	for i in 2:
		_plate(e[i], e[i + 2], brass, dark)


func _plate(top: Vector2, mid: Vector2, brass: Color, dark: Color) -> void:
	var half := PLATE.x * 0.5
	for side: float in [-1.0, 1.0]:
		var foot := mid + Vector2(side * half * 0.92, 0)
		draw_line(top, foot, dark, 2.5, true)
		for k in 3:
			draw_circle(top.lerp(foot, 0.25 + 0.25 * k), 3.0, brass)
	var pts := PackedVector2Array()
	for i in 17:
		var t := float(i) / 16.0
		pts.append(mid + Vector2(lerpf(-half, half, t), sin(t * PI) * PLATE.y))
	draw_colored_polygon(pts, brass.darkened(0.15))
	draw_polyline(pts, dark, 3.0, true)
	draw_line(mid + Vector2(-half, 0), mid + Vector2(half, 0), brass.lightened(0.15), 4.0, true)
