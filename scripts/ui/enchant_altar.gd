class_name EnchantAltar
extends Control
## PT-10: the Emeth planted in a block of stone and lit, at the left of the Encanto's choice, the ichthys glowing on the
## stone's face. Drawn (no model, no viewport): the blade point down into the stone, a slight lean, emerald glow and
## three tongues of light that flicker. It fills the space it is given (anchor it to the left).
##   add_child(EnchantAltar.new())

const STONE := Color(0.2, 0.18, 0.2)
const STONE_LIT := Color(0.34, 0.3, 0.29)
const GLOW := Color(0.45, 0.85, 0.6)
const BLADE := Color(0.88, 0.93, 0.9)
const GOLD := Color(0.86, 0.7, 0.34)
const LEAN := deg_to_rad(7.0)

var _t := 0.0


func _init() -> void:
	name = "altar"
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _glow(i: int) -> float:
	return 0.8 + 0.2 * sin(_t * (2.3 + i * 0.7) + i * 1.9)


func _draw() -> void:
	var u := minf(size.y * 0.0115, size.x / 46.0)
	if u <= 0.0:
		return
	var plant := Vector2(size.x * 0.5, size.y * 0.68)
	var f := _glow(0)
	# the glow behind the blade
	for k in 7:
		var t := float(k) / 7.0
		draw_circle(plant + Vector2(0, -22.0 * u), u * (34.0 - t * 22.0), Color(GLOW, 0.035 * f * (0.5 + t)))
	# the blade, pommel up, the point in the stone (leaning a little)
	draw_set_transform(plant, LEAN, Vector2.ONE)
	var edge := Color(GLOW, 0.9 * f)
	var blade := PackedVector2Array([Vector2(-3.6, 8), Vector2(-3.6, -28), Vector2(3.6, -28), Vector2(3.6, 8)])
	_poly(blade, u, edge.darkened(0.2), 1.5)
	_poly(blade, u, BLADE)
	draw_line(Vector2(0, -26) * u, Vector2(0, 2) * u, Color(GLOW, 0.8 * f), u * 1.1, true)
	var guard := PackedVector2Array([Vector2(-14, -27), Vector2(-9, -31), Vector2(9, -31), Vector2(14, -27), Vector2(10, -27.5),
		Vector2(0, -28.5), Vector2(-10, -27.5)])
	_poly(guard, u, GOLD.darkened(0.55), 1.2)
	_poly(guard, u, GOLD)
	draw_line(Vector2(0, -31) * u, Vector2(0, -41) * u, Color(0.62, 0.22, 0.2), u * 3.4, true)
	var pommel := PackedVector2Array([Vector2(0, -48), Vector2(3.4, -44), Vector2(0, -40.5), Vector2(-3.4, -44)])
	_poly(pommel, u, GOLD.darkened(0.55), 1.2)
	_poly(pommel, u, GOLD.lightened(0.15))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# the stone: a block, its lit top, its face
	var w := u * 40.0
	var top := plant.y - u * 0.6
	var block := PackedVector2Array([Vector2(plant.x - w * 0.5, top + u * 3.0), Vector2(plant.x - w * 0.42, top - u * 1.2),
		Vector2(plant.x + w * 0.42, top - u * 1.2), Vector2(plant.x + w * 0.5, top + u * 3.0), Vector2(plant.x + w * 0.5, top + u * 24.0),
		Vector2(plant.x - w * 0.5, top + u * 24.0)])
	draw_colored_polygon(block, STONE)
	draw_colored_polygon(PackedVector2Array([block[0], block[1], block[2], block[3], Vector2(plant.x + w * 0.5, top + u * 6.0),
		Vector2(plant.x - w * 0.5, top + u * 6.0)]), STONE_LIT.darkened(0.1))
	draw_polyline(block + PackedVector2Array([block[0]]), Color(GOLD, 0.45), 1.5, true)
	# the tongues of light where the blade enters
	for i in 3:
		var g := _glow(i + 1)
		var x := plant.x + (i - 1) * u * 5.0
		var h := u * (9.0 + i % 2 * 5.0) * g
		draw_colored_polygon(PackedVector2Array([Vector2(x - u * 2.4, top), Vector2(x - u * 0.6, top - h * 0.6), Vector2(x + u * 0.4, top - h),
			Vector2(x + u * 2.2, top - h * 0.5), Vector2(x + u * 2.6, top)]), Color(GLOW.lightened(0.25), 0.7))
	# the ichthys glowing on the face
	var face := Vector2(plant.x, top + u * 15.0)
	Ichthys.draw(self, face, u * 15.0, Color(GLOW, 0.22 * f), u * 4.5)
	Ichthys.draw(self, face, u * 15.0, Color(GLOW.lightened(0.3), 0.95 * f), maxf(2.0, u * 1.3))


func _poly(pts: PackedVector2Array, u: float, color: Color, grow := 0.0) -> void:
	var scaled := PackedVector2Array()
	var c := Vector2.ZERO
	for p in pts:
		c += p
	c /= pts.size()
	for p in pts:
		scaled.append((p + (p - c).normalized() * grow) * u)
	draw_colored_polygon(scaled, color)
