class_name BakedModel
extends Resource
## A character baked into still poses that a MultiMesh draws hundreds of times. Written by tools/bake.gd from the
## glTF models, read by CrowdRenderer.
##
## E1a (VX-04): the poses are a vertex animation. One mesh (the figure's triangles and texture coordinates) and, for
## every pose of every clip, where each of its vertices stands and which way it faces, in two images: `positions`
## (half floats, RGBA) and `normals` (octahedral, RG8). The texel of vertex v in pose p (the pose's row over all the
## clips: first[anim] + its frame) is p * vertices + v, laid in rows of WIDTH. crowd_pose.gdshaderinc reads two poses
## and blends them by the instance's colour (CrowdRenderer.add_kind), so a figure moves between its poses, never
## jumps (until E1a it showed int(t * fps) of one mesh per pose: 4 to 10 poses a clip, a stop motion beside the hero).

## Texels per row of the pose images (2048: the largest texture every target takes, Android's GLES3 included).
const WIDTH := 2048

## The figure's triangles and texture coordinates (and, as plain vertices, its first idle pose: what a lab or a test
## that only wants the shape reads).
@export var mesh: Mesh
## Every pose's vertex positions (Image.FORMAT_RGBAH) and normals (Image.FORMAT_RG8, octahedral), see above.
@export var positions: Image
@export var normals: Image
## Vertices of the mesh (each pose has this many texels).
@export var vertices := 0
## Animation name -> its poses, and the row of its first pose in the images.
@export var frames: Dictionary = {}
@export var first: Dictionary = {}
## Animation name -> poses per second (a loop shows its frames poses over frames / fps seconds; a one-shot plays the
## same seconds, its first pose at 0 and its last at the end).
@export var fps: Dictionary = {}
## Animation name -> true when the animation loops.
@export var loops: Dictionary = {}
## Animation name -> meters a second the floor runs under the planted foot when the clip plays at its own pace and
## size 1 (E1a-2, VX-05: measured on the baked walk, tools/bake.gd). Horde.walk_rate plays the walk at the enemy's
## speed over this, so the foot on the floor stays where it is put.
@export var ground_speed: Dictionary = {}
@export var albedo: Texture2D
## True when the albedo is a painted texture of its own (the Meshy figures): what glows and what is metal is read
## from its colours (crowd.gdshader). False: a KayKit palette, whose glowing cells are fixed.
@export var painted := false
## Cells of the texture that glow by themselves: every texel from this UV on (the last four cells of a KayKit
## palette's bottom row: eyes, embers, gems; on a painted figure, the same cells of the palette strip under it).
@export var glow_from := Vector2(0.5, 0.75)
## Height of the model standing, in meters (for life bars and hit effects).
@export var height := 2.0

var _pos_tex: ImageTexture
var _normal_tex: ImageTexture


func frame_count(anim: StringName) -> int:
	return int(frames.get(anim, 0))


func duration(anim: StringName) -> float:
	return frame_count(anim) / maxf(float(fps.get(anim, 10.0)), 0.001)


## Poses a second of the blend: a loop goes round its n poses in n / fps seconds; a one-shot crosses its n - 1 gaps in
## the same n / fps seconds (its last pose is reached when the clip ends).
func pose_rate(anim: StringName) -> float:
	var n := frame_count(anim)
	var f := float(fps.get(anim, 10.0))
	return f if loops.get(anim, false) or n <= 1 else f * (n - 1) / n


## What is shown t seconds into an animation: Vector3(pose, next pose, share of the next), the poses counted within
## the clip (CrowdRenderer.add_kind does the same arithmetic inline).
func blend_at(anim: StringName, t: float) -> Vector3:
	return blend(frame_count(anim), pose_rate(anim), loops.get(anim, false), t)


## The pose shown t seconds in, the one the blend starts from (what the crowd showed whole before E1a; the QA's strips
## count repeated poses with it).
func frame_at(anim: StringName, t: float) -> int:
	return int(blend_at(anim, t).x)


static func blend(n: int, rate: float, looped: bool, t: float) -> Vector3:
	if n <= 0:
		return Vector3.ZERO
	var p := t * rate
	if looped:
		p = fposmod(p, float(n))
		var a := mini(int(p), n - 1)
		return Vector3(a, (a + 1) % n, p - a)
	p = clampf(p, 0.0, float(n - 1))
	var a := mini(int(p), n - 1)
	return Vector3(a, mini(a + 1, n - 1), p - a)


## The pose images as textures for the shader (made once, when first drawn).
func pose_textures() -> Array[Texture2D]:
	if _pos_tex == null and positions != null:
		_pos_tex = ImageTexture.create_from_image(positions)
		_normal_tex = ImageTexture.create_from_image(normals)
	return [_pos_tex, _normal_tex]


## Where vertex v stands in pose `frame` of an animation (read from the image, for tests and measures).
func position(anim: StringName, frame: int, v: int) -> Vector3:
	var i := (int(first.get(anim, 0)) + frame) * vertices + v
	var c := positions.get_pixel(i % WIDTH, i / WIDTH)
	return Vector3(c.r, c.g, c.b)


## Every vertex of one pose (see position()).
func pose(anim: StringName, frame: int) -> PackedVector3Array:
	var out := PackedVector3Array()
	out.resize(vertices)
	for v in vertices:
		out[v] = position(anim, frame, v)
	return out


func normal(anim: StringName, frame: int, v: int) -> Vector3:
	var i := (int(first.get(anim, 0)) + frame) * vertices + v
	var c := normals.get_pixel(i % WIDTH, i / WIDTH)
	return oct_decode(Vector2(c.r, c.g))


## A unit vector as two numbers in 0..1 (octahedral), and back (crowd_pose.gdshaderinc decodes the same way).
static func oct_encode(n: Vector3) -> Vector2:
	n /= absf(n.x) + absf(n.y) + absf(n.z)
	var p := Vector2(n.x, n.z)
	if n.y < 0.0:
		p = Vector2((1.0 - absf(p.y)) * signf(p.x if p.x != 0.0 else 1.0), (1.0 - absf(p.x)) * signf(p.y if p.y != 0.0 else 1.0))
	return p * 0.5 + Vector2(0.5, 0.5)


static func oct_decode(e: Vector2) -> Vector3:
	var p := e * 2.0 - Vector2.ONE
	var n := Vector3(p.x, 1.0 - absf(p.x) - absf(p.y), p.y)
	var t := maxf(-n.y, 0.0)
	n.x += -t if n.x >= 0.0 else t
	n.z += -t if n.z >= 0.0 else t
	return n.normalized()


## Packs the baked poses: clips is animation name -> Array of poses, each [PackedVector3Array positions,
## PackedVector3Array normals], all with the same vertices as `shape` (the mesh drawn). Fills mesh, the images,
## frames and first (fps and loops are the caller's).
func pack(shape: Mesh, clips: Dictionary) -> void:
	mesh = shape
	vertices = (clips.values()[0][0][0] as PackedVector3Array).size()
	var total := 0
	for anim: String in clips:
		first[anim] = total
		frames[anim] = (clips[anim] as Array).size()
		total += frames[anim]
	var rows := ceili(float(total * vertices) / WIDTH)
	var floats := PackedFloat32Array()
	floats.resize(rows * WIDTH * 4)
	var octs := PackedByteArray()
	octs.resize(rows * WIDTH * 2)
	for anim: String in clips:
		var k: int = first[anim]
		for p: Array in clips[anim]:
			var pv: PackedVector3Array = p[0]
			var pn: PackedVector3Array = p[1]
			assert(pv.size() == vertices, "every pose has the same vertices")
			var o := k * vertices
			for v in vertices:
				var at := pv[v]
				floats[(o + v) * 4] = at.x
				floats[(o + v) * 4 + 1] = at.y
				floats[(o + v) * 4 + 2] = at.z
				var e := oct_encode(pn[v])
				octs[(o + v) * 2] = clampi(roundi(e.x * 255.0), 0, 255)
				octs[(o + v) * 2 + 1] = clampi(roundi(e.y * 255.0), 0, 255)
			k += 1
	positions = Image.create_from_data(WIDTH, rows, false, Image.FORMAT_RGBAF, floats.to_byte_array())
	positions.convert(Image.FORMAT_RGBAH)
	normals = Image.create_from_data(WIDTH, rows, false, Image.FORMAT_RG8, octs)


# ---------- the walk's stride (E1a-2, VX-05) ----------

## A foot bears the figure when its lowest vertex is this close to the lowest any foot goes in the loop (a jog's
## flight: neither does).
const CONTACT := 0.06
## Animation name -> per foot (left, right), per pose, the vertices of its sole (tools/bake.gd takes the walk's from
## the skin of the feet): what the stride is measured on.
@export var feet: Dictionary = {}


## How the foot that bears the figure moves on the floor from each pose of a loop to the next (soles: per foot, per
## pose, the same vertices of its sole, see feet): per foot, per pair of poses, the (x, z) step of its lowest vertex
## (the point it stands on: a foot rolling from heel to toe stands still on it), or NAN when the other foot bears the
## figure or neither does. The figure faces +z.
static func floor_moves(soles: Array) -> Array:
	var out := []
	if soles.is_empty():
		return out
	var n := (soles[0] as Array).size()
	var floor_y := INF
	for track: Array in soles:
		for p: PackedVector3Array in track:
			for at in p:
				floor_y = minf(floor_y, at.y)
	# per pose: which foot bears the figure, and on which vertex
	var bearer: Array[int] = []
	var point: Array[int] = []
	for i in n:
		var best := -1
		var best_v := -1
		var best_y := floor_y + CONTACT
		for f in soles.size():
			var p: PackedVector3Array = soles[f][i]
			for v in p.size():
				if p[v].y < best_y:
					best_y = p[v].y
					best = f
					best_v = v
		bearer.append(best)
		point.append(best_v)
	for f in soles.size():
		var moves: Array[Vector2] = []
		for i in n:
			if bearer[i] != f:
				moves.append(Vector2(NAN, NAN))
				continue
			var a: Vector3 = (soles[f][i] as PackedVector3Array)[point[i]]
			var b: Vector3 = (soles[f][(i + 1) % n] as PackedVector3Array)[point[i]]
			moves.append(Vector2(b.x - a.x, b.z - a.z))
		out.append(moves)
	return out


## Meters a second the floor runs back under the planted foot when the loop plays at its own pace (dt: seconds from
## one pose to the next): the speed at which the foot on the floor strays least from where it was put (a search
## around the mean speed of the feet on the floor).
static func ground_of(poses: Array, dt: float) -> float:
	var back := 0.0
	var k := 0
	for moves: Array in floor_moves(poses):
		for m: Vector2 in moves:
			if not is_nan(m.x):
				back -= m.y
				k += 1
	if k == 0:
		return 0.0
	var mean := back / (k * dt)
	var best := mean
	var least := INF
	for step in 201:
		var g := mean * lerpf(0.6, 1.4, step / 200.0)
		var s := slide_per_step(poses, dt, g)
		if s < least:
			least = s
			best = g
	return best


## Meters the planted foot strays on the floor from where it was put, at most, in a step (the worst of the loop's
## steps), when the figure goes forward `ground` meters a second while the loop plays at its own pace.
static func slide_per_step(poses: Array, dt: float, ground: float) -> float:
	var worst := 0.0
	for moves: Array in floor_moves(poses):
		var n := moves.size()
		# a step starts where the foot comes down (on the floor now, in the air the pair before)
		for start in n:
			if is_nan((moves[start] as Vector2).x) or not is_nan((moves[(start + n - 1) % n] as Vector2).x):
				continue
			var at := Vector2.ZERO
			for j in n:
				var m: Vector2 = moves[(start + j) % n]
				if is_nan(m.x):
					break
				at += m + Vector2(0.0, ground * dt)
				worst = maxf(worst, at.length())
	return worst
