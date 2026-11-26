class_name VineSky
extends Control
## The Videira's figures on the night sky (SW-M1, replaces VinePlant), drawn by code on the 1280 x 720 stage: for each branch
## a cloud of its light, the faint strokes that finish the figure, the line of light from its root through the stars it has
## grown, and each node as a star by state (grown: lit star; can grow: pulsing ring; short: dim ring; locked: a dark point).
## Drawing only: it knows each node's state (set_states), the one in focus and the camera (SkyCamera), never the rules.
## `reveal` (0 to 1) lights the figures in on opening; `bloom_id` flashes a node just bought.

const RING_DIM := Color("8a8fa8")
const RUBRIC := Color("d9644f")
const FOCUS := Color(1.0, 0.96, 0.8)

var vine: Vine
var cam: SkyCamera
var states: Dictionary = {}
var focus_id: StringName = &""
## The branch the camera is closed on (&"": the whole sky).
var branch_in: StringName = &""
var reveal := 1.0
var bloom_id: StringName = &""
var bloom := 1.0
var _t := 0.0


func setup(v: Vine, p_cam: SkyCamera) -> VineSky:
	vine = v
	cam = p_cam
	name = "sky"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = VineLayout.STAGE
	return self


func set_states(s: Dictionary) -> void:
	states = s
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## How visible a branch's figure is: all alike in the whole sky, only the one closed on when the camera is in.
func figure_alpha(branch: StringName) -> float:
	if branch_in == &"" or branch == branch_in:
		return 1.0
	return lerpf(1.0, 0.16, cam.progress())


## The radius of a star on the screen: small in the whole sky, larger closed in.
func star_r() -> float:
	return lerpf(4.5, 9.0, cam.progress())


func _draw() -> void:
	for b in vine.branches():
		_figure(b)


func _figure(b: StringName) -> void:
	var a := figure_alpha(b) * clampf(reveal, 0.0, 1.0)
	var tint := VineLayout.tint(b)
	var nodes := vine.nodes_of(b)
	# the cloud of the figure's light, brighter with every star grown
	var grown := nodes.filter(func(n: VineNode) -> bool: return states.get(n.id) == Vine.State.OWNED).size()
	var glow := 0.05 + 0.1 * grown / maxf(nodes.size(), 1.0)
	var mid := cam.to_screen(VineLayout.center(b))
	for k in 18:
		var f := 1.0 - float(k) / 18.0
		draw_circle(mid, 150.0 * cam.zoom * (0.15 + 0.85 * f), Color(tint, glow * a * 0.22))
	# the strokes that finish the figure
	for stroke in VineLayout.outline(b):
		draw_polyline(_screen(stroke), Color(tint, 0.3 * a), 1.5 + 0.5 * cam.progress(), true)
	# the faint stars that fill the figure (no node, no tag): small dim points
	for p in VineLayout.faint(b):
		var at := cam.to_screen(p)
		draw_circle(at, star_r() * 0.32, Color(tint.lerp(RING_DIM, 0.6), 0.55 * a))
		draw_circle(at, star_r() * 0.14, Color(1, 1, 1, 0.5 * a))
	# the line of light from the root, segment by segment
	var chain := VineLayout.chain(b, nodes.size())
	for i in nodes.size():
		var p := cam.to_screen(chain[i])
		var q := cam.to_screen(chain[i + 1])
		var st: Vine.State = states.get(nodes[i].id, Vine.State.LOCKED)
		var reach := 0.0
		match st:
			Vine.State.OWNED:
				reach = 1.0
			Vine.State.AVAILABLE, Vine.State.SHORT:
				reach = 0.45
			_:
				reach = 0.18
		if st == Vine.State.OWNED:
			draw_line(p, q, Color(tint, 0.16 * a), 9.0, true)
		draw_line(p, q, Color(tint.lightened(0.25 * reach), (0.15 + 0.8 * reach) * a), 1.6 + 1.4 * reach, true)
	# the root, always lit (it is the figure's start, not a node)
	StarGlyph.lit(self, cam.to_screen(VineLayout.root(b)), star_r() * 0.55, tint, 0.8 * a)
	for n in nodes:
		_star(n, tint, a)


func _screen(world: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in world:
		out.append(cam.to_screen(p))
	return out


func _star(n: VineNode, tint: Color, a: float) -> void:
	var c := cam.to_screen(VineLayout.bud(n.branch, n.step))
	var r := star_r()
	var st: Vine.State = states.get(n.id, Vine.State.LOCKED)
	var pulse := 0.5 + 0.5 * sin(_t * 3.0)
	match st:
		Vine.State.OWNED:
			StarGlyph.lit(self, c, r * 0.75, tint, a)
		Vine.State.AVAILABLE:
			StarGlyph.halo(self, c, r * 0.8, Color(tint, 0.25 * a * (0.6 + 0.4 * pulse)), 3.0 + pulse)
			draw_circle(c, r * 0.7, Color(tint.darkened(0.35), a))
			draw_arc(c, r * (1.15 + 0.15 * pulse), 0.0, TAU, 28, Color(tint.lightened(0.3), a), 2.0, true)
			draw_circle(c, r * 0.28, Color(1, 1, 1, a))
		Vine.State.SHORT:
			draw_circle(c, r * 0.7, Color(0.1, 0.09, 0.14, a))
			draw_arc(c, r * 1.05, 0.0, TAU, 28, Color(tint.lerp(RING_DIM, 0.6), 0.9 * a), 1.8, true)
			draw_circle(c, r * 0.25, Color(tint.lerp(RING_DIM, 0.5), 0.9 * a))
		_:
			draw_circle(c, r * 0.6, Color(0.05, 0.05, 0.09, a))
			draw_arc(c, r * 0.6, 0.0, TAU, 20, Color(RING_DIM, 0.55 * a), 1.4, true)
	if bloom_id == n.id and bloom < 1.0:
		draw_arc(c, r * (1.0 + bloom * 6.0), 0.0, TAU, 40, Color(tint.lightened(0.5), (1.0 - bloom) * a), 3.0, true)
		StarGlyph.spikes(self, c, r * (2.0 + 3.0 * (1.0 - bloom)), Color(1, 1, 1, (1.0 - bloom) * a))
	if focus_id == n.id:
		draw_arc(c, r * 1.9, 0.0, TAU, 36, Color(FOCUS, 0.95), 2.5, true)
