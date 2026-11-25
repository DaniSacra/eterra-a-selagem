class_name RewardGem
extends RefCounted
## What a reward looks like where it waits (QW-106 of cycle C18; ART-01.2 and ART-01.3 of cycle AP-1): a disc of old
## gold, lit by the room, with the reward's own symbol on both faces (reward_gem.gdshader: the painted medallion where
## one exists, assets/ui/events, or DoorGlyph's mark struck in relief on the enamel of its family), swaying slowly to
## the camera, a soft halo of its family's colour behind it under the glow (reward_halo.gdshader).
## Where it is taken (a won room's reward, an item of the shop, the Provação's and the altar's spots) it rests on a
## reliquary (AP-1, ART-01.3): a low chest of the hall's stone behind the spot one steps on, a thread of old gold under
## its cap, a cloth of dark petrol with the lion in old gold hanging over its front (Q-22), the disc held up by a stem
## and a cradle of old gold; in front of it a worn step of stone, where the touch is (Rooms.TOUCH round the spot, which
## did not move). Over a door's mouth it is a sign seen from afar and floats (ART-01.5 will hang it from the arch).
## One material per kind of reward and one for each part of the reliquary (cached), no light of its own: the room's
## lights shade it and it glows a little by itself.

## The disc: radius and thickness (m), the height of its middle over the floor, the halo's size (diameter). AP-1: about
## 90 px across at 1080 lines in the game's camera (it was 1.2 m, about 70 px). Its top stays under the sign's foot
## (Rooms.MARK_SIGN_Y 2.7, where the sign's text grows up from).
const RADIUS := 1.0
const THICK := 0.1
const HEIGHT := 1.56
const HALO := 3.4
## The gold of the disc, the rim, the stem and the reliquary's thread (old gold, art_direction.md 2.2, the disc's row;
## never bright yellow).
const GOLD := Color(0.66, 0.5, 0.26)
## The enamel of each family (art_direction.md 6.3, AP-1): hue (degrees), saturation, value, never past ENAMEL_MAX
## (saturation, value); any two at least 40 degrees of hue or 0.2 of value apart. Gold has none: its face is the coin.
const ENAMEL_MAX := Vector2(0.5, 0.45)
const ENAMEL_BLESSING := Vector3(186.0, 0.5, 0.22)
const ENAMEL_POM := Vector3(352.0, 0.5, 0.2)
const ENAMEL_HEART := Vector3(345.0, 0.42, 0.42)
const ENAMEL_MAGICK := Vector3(232.0, 0.45, 0.4)
const ENAMEL_WATER := Vector3(196.0, 0.2, 0.45)
const ENAMEL_TRIAL := Vector3(282.0, 0.3, 0.42)
const ENAMEL_ALTAR := Vector3(30.0, 0.4, 0.42)
const ENAMEL_ROOM := Vector3(220.0, 0.08, 0.26)
## Fatia 2: the Encanto's green (the card's ENCHANT_EDGE, darker than the Emeth's crystal) and the Psalm's lilac (the
## door glyph's PSALM_LIGHT, kept 25 degrees off the Trial's).
const ENAMEL_ENCHANT := Vector3(148.0, 0.45, 0.3)
const ENAMEL_PSALM := Vector3(255.0, 0.32, 0.42)
## The two materials brought home (Rejogabilidade, Fatia 1, sistemas.md 3.4): neither is enamel. Prata Antiga's face is
## the coin of gold's made in old silver (SILVER, cool and greyed, never white; its rim and halo the same), struck with an
## ingot; Fragmento de Memória's is a leaf of parchment (PARCHMENT, under ENAMEL_MAX's value) with a torn page written
## in ink (INK, never metal). Their halos: the silver's own, a pale parchment's.
const SILVER := Color(0.6, 0.62, 0.64)
const PARCHMENT := Color(0.5, 0.43, 0.32)
const INK := Color(0.12, 0.09, 0.07)
## The struck mark's metal: gold on the enamel, ivory on the Blessing's petrol (art_direction.md 6.3).
const IVORY := Color(0.86, 0.82, 0.72)
## The halo's light: the most it lays at its middle and its brightest channel (under 1, the glow's threshold); its
## colour is the family's hue at this saturation.
const HALO_ALPHA := 0.32
const HALO_PEAK := 0.5
const HALO_SATURATION := 0.45
## How far behind the disc the halo stands, along the view (in disc radii: past the sway and the lean).
const HALO_BACK := 1.2
## It faces the camera and sways slowly round it (a full sway in TURN seconds, SWAY radians each way), leaning back
## LEAN of the camera's pitch so its face is seen whole: spun round, the medallions were edges half the time.
const TURN := 5.0
const SWAY := 0.35
const LEAN := 0.5

## The reliquary (ART-01.3): its body (width, height to the cap's top, depth), its middle this far behind the spot
## (away from the camera; the spot itself is the step), its plinth (height, overhang) and its cap (thickness, overhang).
## Its top is under 1 m: it hides no one and reads as a chest, not a wall (art_polish_backlog ART-01.3).
const RELIQUARY := Vector3(1.5, 0.5, 0.86)
const RELIQUARY_BACK := 0.8
const RELIQUARY_PLINTH := Vector2(0.12, 0.08)
const RELIQUARY_CAP := Vector2(0.09, 0.07)
## The thread of old gold round the body just under the cap (height, how far it stands out).
const THREAD := Vector2(0.035, 0.012)
## The step one stands on in front (width, rise, depth), its middle this far ahead of the spot: the floor's spot
## where the touch is reads as a place to stand. Low (under the ankle) so the feet stay on it.
const STEP := Vector3(1.7, 0.08, 1.1)
const STEP_AHEAD := 0.05
## The stem from the cap to the cradle (radius) and the cradle under the disc (its tube's radius, the arc it spans,
## degrees each side of the bottom).
const STEM := 0.04
const CRADLE_TUBE := 0.035
const CRADLE_SPAN := 62.0
## The cloth over the cap and down the front (width, how far it lies on the cap, its hang at the sides and at the
## point), its petrol (Q-22: dark petrol, the lion in old gold) and the lion's size (share of the cloth's width).
const CLOTH := Vector4(0.8, 0.5, 0.26, 0.4)
const CLOTH_COLOR := Color(0.07, 0.17, 0.19)
const CLOTH_LION := 0.5
## The reliquary's stone a little darker than the floor's (the room's lights fall on its cap first).
const RELIQUARY_TINT := Color(0.78, 0.78, 0.8)
## The reliquary in the stylized look (room redesign lot A review, item 4: it stood raw and pale, luma 121 against the
## slabs' 69): painted as the hall's stone (CatacombHall.STYLE, the one material for every room's rewards), darker.
const STY_RELIQUARY_TINT := Color(0.62, 0.63, 0.66)

const SHADER := preload("res://assets/shaders/reward_gem.gdshader")
const HALO_SHADER := preload("res://assets/shaders/reward_halo.gdshader")
const CLOTH_SHADER := preload("res://assets/shaders/reliquary_cloth.gdshader")

## The shader's marks (reward_gem.gdshader `mark`).
enum Mark { NONE, BLESSING, COIN, HEART, GEM, DROP, CHEVRON_1, CHEVRON_2, CHEVRON_3, INGOT, LEAF, ENCHANT, PSALM }
## How it stands: on a reliquary, floating (a door's sign), or by where it is (AUTO: floating over a door's mouth,
## Arena.door_label, else on a reliquary).
enum Stand { AUTO, RELIQUARY, FLOAT }

static var _faces := {}
static var _halos := {}
static var _rim_mat: StandardMaterial3D
static var _silver_rim_mat: StandardMaterial3D
static var _cloth_mat: ShaderMaterial
static var _face_mesh: QuadMesh
static var _rim_mesh: CylinderMesh
static var _halo_mesh: QuadMesh
static var _stem_mesh: CylinderMesh
static var _cradle_mesh: ArrayMesh
static var _cloth_mesh: ArrayMesh
static var _thread_mesh: ArrayMesh
static var _mason: Masonry


## Builds the reward's medallion under `parent` (standing at its origin) and returns the node that turns.
## reward: what it gives (RunMap.Reward), or NONE with the room's kind (RunMap.Kind) for a door or an event's spot;
## color: its colour (Rooms._reward_color / _kind_color; the enamel and the halo are the family's own, art_direction 6.3).
static func make(parent: Node3D, reward: RunMap.Reward, kind: RunMap.Kind, color: Color, stand := Stand.AUTO) -> Node3D:
	_ready()
	var key := "%d|%d" % [reward, kind if reward == RunMap.Reward.NONE else -1]
	if stand == Stand.AUTO:
		stand = Stand.FLOAT if at_door(parent) else Stand.RELIQUARY
	# PT-2: on a door the medallion hangs from the arch at the door's own height, a little smaller
	var lift := HEIGHT
	var s := 1.0
	if stand == Stand.FLOAT:
		var di := door_of(parent)
		if di >= 0:
			lift = (parent.get_parent() as Rooms).game.arena.door_anchor(di).y
			s = DOOR_SCALE
	# the reliquary turned to the camera: its body behind the spot, the step on it
	var frame := Node3D.new()
	frame.rotation.y = deg_to_rad(Feel.live().cam_yaw)
	parent.add_child(frame)
	var held := Vector3.ZERO
	if stand == Stand.RELIQUARY:
		held = _reliquary(frame)
	# the halo behind, facing the camera (it does not turn)
	var halo := MeshInstance3D.new()
	halo.mesh = _halo_mesh
	halo.material_override = _halo(key, reward, kind, color)
	# set back along the view past the swaying disc: through it, it veiled the half of the face behind its plane
	var pitch := deg_to_rad(Feel.live().cam_pitch)
	halo.position = held + Vector3(0, lift, 0) - Vector3(0, sin(pitch), cos(pitch)) * RADIUS * HALO_BACK * s
	# (over a door the halo stays inside the spacing of two doors: the Provação's are 4.2 m apart)
	var halo_k := s * (DOOR_HALO if s > 1.0 else 1.0)
	halo.scale = Vector3(halo_k, halo_k, halo_k)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.sorting_offset = -1.0
	frame.add_child(halo)
	# a door's medallion pulses in a ring of its room's colour (DoorRing; DoorTip makes it burn when he is near)
	if stand == Stand.FLOAT and door_of(parent) >= 0:
		var ring := DoorRing.make(door_of(parent), color, s)
		ring.position = held + Vector3(0, lift, 0)
		frame.add_child(ring)
	# the disc: rim and two faces (and the cradle that holds it), swaying (each its own way, by where it stands)
	var spin := Sway.new()
	spin.position = held + Vector3(0, lift, 0)
	spin.scale = Vector3(s, s, s)
	spin.phase = fposmod(parent.global_position.x * 0.37 + parent.global_position.z * 0.61, 1.0) * TURN if parent.is_inside_tree() else 0.0
	frame.add_child(spin)
	var rim := MeshInstance3D.new()
	rim.mesh = _rim_mesh
	rim.material_override = _silver_rim_mat if reward == RunMap.Reward.SILVER else _rim_mat
	rim.rotation.x = PI * 0.5
	# a painted medallion has its own frame: no gold rim of ours (Daniel 2026-11-23)
	rim.visible = painting(reward, kind) == null
	spin.add_child(rim)
	var face_mat := _face(key, reward, kind)
	for side in 2:
		var face := MeshInstance3D.new()
		face.mesh = _face_mesh
		face.material_override = face_mat
		face.position.z = (THICK * 0.5 + 0.002) * (1.0 if side == 0 else -1.0)
		face.rotation.y = 0.0 if side == 0 else PI
		spin.add_child(face)
	if stand == Stand.RELIQUARY or stand == Stand.FLOAT:
		var cradle := MeshInstance3D.new()
		cradle.mesh = _cradle_mesh
		cradle.material_override = _rim_mat
		spin.add_child(cradle)
	if stand == Stand.FLOAT:
		_door_mount(parent, frame, spin)
	return spin


## AP-4 3.1 (ART-01.5): the disc over a door's mouth is held, never loose in the air: a rod of old gold from the top of
## the door's arch (DOOR_ARCH_BACK m out of the room, DOOR_ARCH_TOP high) to the cradle under the disc's foot; where the
## door is stairs with no arch, from the top of a low iron post (DOOR_POST: radius, height) beside the mouth, on its
## cheek off the floor. The rod meets the disc on its turning axis, so the swaying disc stays on it. Nothing collides.
## PT-2: the disc on a door is DOOR_SCALE of its size (the arch's tympanum is 4 m wide).
const DOOR_SCALE := 1.4
## The share of its size a door's halo keeps (HALO * DOOR_SCALE * this stays under the 4.2 m of the closest doors).
const DOOR_HALO := 0.85
const DOOR_ROD := 0.04
const DOOR_ARCH_TOP := 4.9
const DOOR_ARCH_BACK := 0.5
const DOOR_POST := Vector2(0.07, 1.2)
const DOOR_KNOB := 0.09
const DOOR_POST_SIDE := 0.5
const DOOR_IRON := Color(0.13, 0.12, 0.11)
static var _iron_mat: StandardMaterial3D
static var _bronze_mat: StandardMaterial3D


static func _door_mount(parent: Node3D, frame: Node3D, spin: Node3D) -> void:
	var rooms := parent.get_parent() as Rooms
	if rooms == null or rooms.game == null or rooms.game.arena == null:
		return
	var a := rooms.game.arena
	var i := door_of(parent)
	if i < 0:
		return
	var inward := a.exit_inward[i] if i < a.exit_inward.size() else Vector2(0, 1)
	var side := Vector2(-inward.y, inward.x)
	var edge := a.exits[i] + inward * ArenaExit.EDGE_FROM_SPOT
	var anchor: Vector3
	if a.look != null and a.look.in_wall(i):
		var c := edge - inward * DOOR_ARCH_BACK
		anchor = Vector3(c.x, DOOR_ARCH_TOP, c.y)
		# the rod hangs straight from the arch's crown to the disc: the crown is over the medallion's own spot
		var m := a.door_anchor(i)
		anchor = Vector3(m.x, DOOR_ARCH_TOP, m.z)
		# SW-C9: a disc that floats over the lintel (its top over the crown) hangs from nothing: no rod
		if m.y + RADIUS * spin.scale.y > DOOR_ARCH_TOP:
			return
	elif a.door_anchor(i).y - RADIUS * spin.scale.y > DOOR_POST.y + 1.0:
		# SW-C9: a disc floating high over stairs hangs from nothing too (a rod from the low post crossed the hero's screen)
		return
	else:
		var half := Arena.STAIRS_HALF_WIDTH
		var base := 0.0
		if a.layout != null and i < a.layout.exits.size() and a.look != null:
			half = absf(a.layout.exits[i].mouth.size.dot(side)) * 0.5
			base = ArenaRoom.EXIT_CHEEK.y
		# on the side nearer the camera's right, so the rod crosses no part of the disc's face
		var right := Vector2(cos(deg_to_rad(Feel.live().cam_yaw)), -sin(deg_to_rad(Feel.live().cam_yaw)))
		var sd := 1.0 if side.dot(right) >= 0.0 else -1.0
		var c := edge - inward * ArenaRoom.DOOR_POST_OUT + side * sd * (half + ArenaRoom.DOOR_POST_OUT + DOOR_POST_SIDE)
		# standing on the stairs' cheek (its top over the floor), a knob of old gold on top where the rod starts
		var post := _rod(frame, _local(frame, parent, Vector3(c.x, base, c.y)), _local(frame, parent, Vector3(c.x, base + DOOR_POST.y, c.y)),
			DOOR_POST.x, _iron())
		post.name = "DoorPost"
		anchor = Vector3(c.x, base + DOOR_POST.y, c.y)
		_rod(frame, _local(frame, parent, anchor - Vector3(0, DOOR_KNOB, 0)), _local(frame, parent, anchor + Vector3(0, DOOR_KNOB, 0)),
			DOOR_KNOB, _bronze())
	# the disc's foot under the cradle, where the sway leaves it (the lean tilts it, the turn keeps it on the axis)
	var foot := spin.position + Basis(Vector3.RIGHT, -deg_to_rad(Feel.live().cam_pitch) * LEAN) * Vector3(0, (-RADIUS - CRADLE_TUBE * 2.0) * spin.scale.y, 0)
	var rod := _rod(frame, _local(frame, parent, anchor), foot, DOOR_ROD, _bronze())
	rod.name = "DoorRod"


## A world point (the room's) in the frame's coordinates (the frame turned under `parent`, which stands in the room).
static func _local(frame: Node3D, parent: Node3D, w: Vector3) -> Vector3:
	return frame.basis.inverse() * (w - parent.position)


## A straight rod from a to b (the frame's coordinates) of the given radius, under `frame`, casting no shadow.
static func _rod(frame: Node3D, a: Vector3, b: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = a.distance_to(b)
	cyl.radial_segments = 8
	cyl.rings = 1
	var mi := MeshInstance3D.new()
	mi.mesh = cyl
	mi.material_override = mat
	var up := (b - a).normalized()
	var x := up.cross(Vector3.FORWARD if absf(up.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT).normalized()
	mi.transform = Transform3D(Basis(x, up, x.cross(up)), (a + b) * 0.5)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(mi)
	return mi


## Art review 2026-11-23 (22): the door's rod and knob in lit bronze, not mirror gold (a metal with nothing to reflect read as
## a black disc where the rod's end faces the camera: an empty setting is bronze, never black).
static func _bronze() -> StandardMaterial3D:
	if _bronze_mat == null:
		_bronze_mat = StandardMaterial3D.new()
		_bronze_mat.albedo_color = GOLD
		_bronze_mat.metallic = 0.0
		_bronze_mat.roughness = 0.55
		_bronze_mat.emission_enabled = true
		_bronze_mat.emission = GOLD * 0.45
	return _bronze_mat


static func _iron() -> StandardMaterial3D:
	if _iron_mat == null:
		_iron_mat = StandardMaterial3D.new()
		_iron_mat.albedo_color = DOOR_IRON
		_iron_mat.metallic = 0.6
		_iron_mat.roughness = 0.6
	return _iron_mat


## True when `parent` stands where a door's sign floats (Arena.door_label of one of the room's exits).
static func at_door(parent: Node3D) -> bool:
	return door_of(parent) >= 0


## The door whose medallion hangs where `parent` stands (Arena.door_anchor), or -1.
static func door_of(parent: Node3D) -> int:
	var rooms := parent.get_parent() as Rooms
	if rooms == null or rooms.game == null or rooms.game.arena == null:
		return -1
	return rooms.game.arena.door_at_anchor(Vector2(parent.position.x, parent.position.z))


## The face's material of one kind of reward (cached: one per kind, never one per instance).
static func face_material(reward: RunMap.Reward, kind: RunMap.Kind, _color := Color.WHITE) -> ShaderMaterial:
	_ready()
	return _face("%d|%d" % [reward, kind if reward == RunMap.Reward.NONE else -1], reward, kind)


## The painted medallion of a reward or a room (assets/ui/events), or null when it has none.
static func painting(reward: RunMap.Reward, kind: RunMap.Kind) -> Texture2D:
	var art := RewardIcon.of(reward, kind)  # PT-2: assets/ui/rewards/<id>.png wins when it exists
	if art != null:
		return art
	match reward:
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return BoonArt.event(&"pomegranate")
		RunMap.Reward.NONE:
			match kind:
				RunMap.Kind.TRIAL:
					return BoonArt.event(&"trial_seal")
				RunMap.Kind.ALTAR:
					return BoonArt.event(&"candles")
	return null


## The mark struck on a reward or a room without a painting (DoorGlyph's).
static func mark_of(reward: RunMap.Reward, kind: RunMap.Kind) -> Mark:
	match reward:
		RunMap.Reward.BOON:
			return Mark.BLESSING
		RunMap.Reward.GOLD:
			return Mark.COIN
		RunMap.Reward.HEART:
			return Mark.HEART
		RunMap.Reward.MAGICK:
			return Mark.GEM
		RunMap.Reward.HEAL:
			return Mark.DROP
		RunMap.Reward.SILVER:
			return Mark.INGOT
		RunMap.Reward.MEMORY:
			return Mark.LEAF
		RunMap.Reward.ENCHANT:
			return Mark.ENCHANT
		RunMap.Reward.PSALM:
			return Mark.PSALM
		RunMap.Reward.NONE:
			match kind:
				RunMap.Kind.SHOP:
					return Mark.COIN
				RunMap.Kind.FOUNTAIN:
					return Mark.DROP
				RunMap.Kind.MINIBOSS:
					return Mark.CHEVRON_2
				RunMap.Kind.BOSS:
					return Mark.CHEVRON_3
				RunMap.Kind.COMBAT:
					return Mark.CHEVRON_1
	return Mark.NONE


## True when the face is the coin itself, all old gold (gold and the shop: art_direction.md 6.3, no enamel).
static func is_gold(reward: RunMap.Reward, kind: RunMap.Kind) -> bool:
	return reward == RunMap.Reward.GOLD or (reward == RunMap.Reward.NONE and kind == RunMap.Kind.SHOP)


## The face's own stuff when it is no enamel (Color(0, 0, 0, 0): enamel): gold's coin, Prata Antiga's silver, the
## Memória's parchment. Its halo takes this colour too.
static func face_stuff(reward: RunMap.Reward, kind: RunMap.Kind) -> Color:
	if is_gold(reward, kind):
		return GOLD
	match reward:
		RunMap.Reward.SILVER:
			return SILVER
		RunMap.Reward.MEMORY:
			return PARCHMENT
	return Color(0, 0, 0, 0)


## The family's enamel (hue in degrees, saturation, value) of a reward or a room (ENAMEL_*).
static func family(reward: RunMap.Reward, kind: RunMap.Kind) -> Vector3:
	match reward:
		RunMap.Reward.BOON:
			return ENAMEL_BLESSING
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return ENAMEL_POM
		RunMap.Reward.HEART:
			return ENAMEL_HEART
		RunMap.Reward.MAGICK:
			return ENAMEL_MAGICK
		RunMap.Reward.HEAL:
			return ENAMEL_WATER
		RunMap.Reward.ENCHANT:
			return ENAMEL_ENCHANT
		RunMap.Reward.PSALM:
			return ENAMEL_PSALM
		RunMap.Reward.NONE:
			match kind:
				RunMap.Kind.FOUNTAIN:
					return ENAMEL_WATER
				RunMap.Kind.TRIAL:
					return ENAMEL_TRIAL
				RunMap.Kind.ALTAR:
					return ENAMEL_ALTAR
	return ENAMEL_ROOM


## The enamel of a reward or a room as a colour (its family, under ENAMEL_MAX).
static func enamel_of(reward: RunMap.Reward, kind: RunMap.Kind) -> Color:
	var f := family(reward, kind)
	return Color.from_hsv(fposmod(f.x, 360.0) / 360.0, minf(f.y, ENAMEL_MAX.x), minf(f.z, ENAMEL_MAX.y))


## The disc's mount: faces the camera, sways round it.
## Keeps a door's medallion (disc and ring) inside the screen: how far to slide it along the camera's right, horizontal
## in the world, so its ring stands at least `margin` px from the left and right edges (the sign's text already clamps
## itself, DoorSign). Zero when it is clear or behind the camera. Pure given the camera.
static func pull_in(cam: Camera3D, anchor: Vector3, screen: Vector2, margin: float) -> Vector3:
	if cam.is_position_behind(anchor):
		return Vector3.ZERO
	var right := cam.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	var c := cam.unproject_position(anchor)
	var reach := RADIUS * DOOR_SCALE * RING_REACH
	var px := c.distance_to(cam.unproject_position(anchor + right * reach))
	if px < 0.5:
		return Vector3.ZERO
	var shift := 0.0
	if c.x + px > screen.x - margin:
		shift = (screen.x - margin) - (c.x + px)
	elif c.x - px < margin:
		shift = margin - (c.x - px)
	return right * (shift / px * reach)


## The ring of a door's medallion over its disc's radius (the ring pulses a little wider than the disc).
const RING_REACH := 1.25


class Sway extends Node3D:
	var phase := 0.0

	func _ready() -> void:
		_pose()

	func _process(delta: float) -> void:
		phase += delta
		_pose()

	func _pose() -> void:
		# the frame it hangs in is already turned to the camera
		rotation = Vector3(-deg_to_rad(Feel.live().cam_pitch) * LEAN, sin(phase * TAU / TURN) * SWAY, 0.0)


static func _ready() -> void:
	if _mason != null:
		return
	_mason = Masonry.new(null)
	_face_mesh = QuadMesh.new()
	_face_mesh.size = Vector2(RADIUS * 2.0, RADIUS * 2.0)
	_rim_mesh = CylinderMesh.new()
	_rim_mesh.top_radius = RADIUS
	_rim_mesh.bottom_radius = RADIUS
	_rim_mesh.height = THICK
	_rim_mesh.radial_segments = 36
	_rim_mesh.rings = 1
	_halo_mesh = QuadMesh.new()
	_halo_mesh.size = Vector2(HALO, HALO)
	_rim_mat = StandardMaterial3D.new()
	_rim_mat.albedo_color = GOLD
	_rim_mat.metallic = 0.85
	_rim_mat.roughness = 0.35
	_rim_mat.emission_enabled = true
	_rim_mat.emission = GOLD * 0.12
	_silver_rim_mat = _rim_mat.duplicate() as StandardMaterial3D
	_silver_rim_mat.albedo_color = SILVER
	_silver_rim_mat.emission = SILVER * 0.12
	_stem_mesh = CylinderMesh.new()
	_stem_mesh.top_radius = STEM
	_stem_mesh.bottom_radius = STEM * 1.6
	_stem_mesh.radial_segments = 10
	_stem_mesh.rings = 1
	_stem_mesh.height = HEIGHT - RADIUS - CRADLE_TUBE - RELIQUARY.y
	_cradle_mesh = _arc_tube(RADIUS + CRADLE_TUBE * 0.6, CRADLE_TUBE, deg_to_rad(CRADLE_SPAN))
	_cloth_mesh = _cloth()
	_thread_mesh = _thread()
	_cloth_mat = ShaderMaterial.new()
	_cloth_mat.shader = CLOTH_SHADER
	_cloth_mat.set_shader_parameter(&"cloth", CLOTH_COLOR)
	_cloth_mat.set_shader_parameter(&"gold", GOLD)
	_cloth_mat.set_shader_parameter(&"lion", ArenaKit.LION_FIELD)
	_cloth_mat.set_shader_parameter(&"lion_v", Vector2(CLOTH.y / (CLOTH.y + CLOTH.w), 1.0))
	_cloth_mat.set_shader_parameter(&"lion_size", CLOTH_LION)


## The reliquary and its step under `frame` (turned to the camera: -z is away from it); returns where the disc's foot
## stands (its middle over the reliquary).
static func _reliquary(frame: Node3D) -> Vector3:
	var stone := _mason.stone(0.0, RELIQUARY_TINT)
	var darker := STY_RELIQUARY_TINT / RELIQUARY_TINT
	VisualProfile.vary(stone, {&"shader": Masonry.PAINT_SHADER,
		&"shader_parameter/stone_a": VisualProfile.classic_of(stone, &"shader_parameter/stone_a", stone.get_shader_parameter(&"stone_a")) * darker,
		&"shader_parameter/stone_b": VisualProfile.classic_of(stone, &"shader_parameter/stone_b", stone.get_shader_parameter(&"stone_b")) * darker,
		&"shader_parameter/paint_stone": CatacombHall.STYLE[&"stone"],
		&"shader_parameter/paint_shadow": CatacombHall.STYLE[&"shadow"]})
	var body_z := -RELIQUARY_BACK
	var step := _stone_box(Vector3(STEP.x, STEP.y, STEP.z), Masonry.CHAMFER * 0.6, stone)
	step.position = Vector3(0, STEP.y * 0.5 - 0.01, STEP_AHEAD)
	frame.add_child(step)
	var plinth_size := Vector3(RELIQUARY.x + RELIQUARY_PLINTH.y * 2.0, RELIQUARY_PLINTH.x, RELIQUARY.z + RELIQUARY_PLINTH.y * 2.0)
	var plinth := _stone_box(plinth_size, Masonry.CHAMFER, stone)
	plinth.position = Vector3(0, RELIQUARY_PLINTH.x * 0.5, body_z)
	frame.add_child(plinth)
	var body_h := RELIQUARY.y - RELIQUARY_PLINTH.x - RELIQUARY_CAP.x
	var body := _stone_box(Vector3(RELIQUARY.x, body_h, RELIQUARY.z), Masonry.CHAMFER, stone)
	body.position = Vector3(0, RELIQUARY_PLINTH.x + body_h * 0.5, body_z)
	frame.add_child(body)
	var cap := _stone_box(Vector3(RELIQUARY.x + RELIQUARY_CAP.y * 2.0, RELIQUARY_CAP.x, RELIQUARY.z + RELIQUARY_CAP.y * 2.0), Masonry.CHAMFER, stone)
	cap.position = Vector3(0, RELIQUARY.y - RELIQUARY_CAP.x * 0.5, body_z)
	frame.add_child(cap)
	var thread := MeshInstance3D.new()
	thread.mesh = _thread_mesh
	thread.material_override = _rim_mat
	thread.position = Vector3(0, RELIQUARY.y - RELIQUARY_CAP.x - THREAD.x * 0.5 - 0.02, body_z)
	thread.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(thread)
	var cloth := MeshInstance3D.new()
	cloth.mesh = _cloth_mesh
	cloth.material_override = _cloth_mat
	cloth.position = Vector3(0, RELIQUARY.y + 0.004, body_z + (RELIQUARY.z * 0.5 + RELIQUARY_CAP.y))
	cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(cloth)
	# the stem up from the back of the cap to the cradle under the disc
	var stem_top := HEIGHT - RADIUS - CRADLE_TUBE
	var stem := MeshInstance3D.new()
	stem.mesh = _stem_mesh
	stem.material_override = _rim_mat
	stem.position = Vector3(0, (RELIQUARY.y + stem_top) * 0.5, body_z)
	frame.add_child(stem)
	return Vector3(0, 0, body_z)


static func _stone_box(size: Vector3, chamfer: float, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = _mason.bevel_mesh(size, chamfer)
	mi.material_override = mat
	return mi


## A tube bent round the disc's foot (in the disc's plane, z = 0): the cradle that holds it, `radius` from its middle,
## `tube` thick, `span` radians each side of straight down.
static func _arc_tube(radius: float, tube: float, span: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 14
	var sides := 6
	var ring := func(t: float) -> Array:
		var a := -PI * 0.5 + lerpf(-span, span, t)
		var c := Vector3(cos(a), sin(a), 0.0) * radius
		var out := Vector3(cos(a), sin(a), 0.0)
		var pts := []
		for k in sides:
			var b := TAU * k / sides
			var n := out * cos(b) + Vector3(0, 0, 1) * sin(b)
			pts.append([c + n * tube, n])
		return pts
	for i in steps:
		var r0: Array = ring.call(float(i) / steps)
		var r1: Array = ring.call(float(i + 1) / steps)
		for k in sides:
			var k1 := (k + 1) % sides
			for v: Array in [r0[k], r1[k], r1[k1], r0[k], r1[k1], r0[k1]]:
				st.set_normal(v[1])
				st.add_vertex(v[0])
	return st.commit()


## The cloth: lying on the cap from its back part to the front edge, then hanging down the front to a point in the
## middle (its origin at the cap's front edge, its top). UV: u across, v along it from the back to the point.
static func _cloth() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols := 10
	var length := CLOTH.y + CLOTH.w
	var at := func(u: float, v: float) -> Vector3:
		var x := (u - 0.5) * CLOTH.x
		var d := v * length
		var hang := lerpf(CLOTH.z, CLOTH.w, 1.0 - absf(u * 2.0 - 1.0))
		if d <= CLOTH.y:
			return Vector3(x, 0.0, -CLOTH.y + d)
		# down the front, the sides shorter than the point
		var down := (d - CLOTH.y) / CLOTH.w * hang
		return Vector3(x, -down, 0.012)
	var rows: Array[float] = [0.0, CLOTH.y / length * 0.5, CLOTH.y / length, CLOTH.y / length + 0.02, 0.6, 0.75, 0.88, 1.0]
	for i in rows.size() - 1:
		for c in cols:
			var u0 := float(c) / cols
			var u1 := float(c + 1) / cols
			var quad: Array = [[u0, rows[i]], [u1, rows[i]], [u1, rows[i + 1]], [u0, rows[i + 1]]]
			for k: int in [0, 1, 2, 0, 2, 3]:
				var uv: Array = quad[k]
				var p: Vector3 = at.call(uv[0], uv[1])
				var n := Vector3.UP if float(uv[1]) <= CLOTH.y / length else Vector3(0, 0, 1)
				st.set_normal(n)
				st.set_uv(Vector2(uv[0], uv[1]))
				st.add_vertex(p)
	return st.commit()


## The thread of old gold round the body under the cap: four thin bars.
static func _thread() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var w := RELIQUARY.x * 0.5 + THREAD.y
	var d := RELIQUARY.z * 0.5 + THREAD.y
	for side: Array in [[Vector3(0, 0, d), Vector3(w, 0, 0), Vector3(0, 0, 1)], [Vector3(0, 0, -d), Vector3(w, 0, 0), Vector3(0, 0, -1)],
			[Vector3(w, 0, 0), Vector3(0, 0, d), Vector3(1, 0, 0)], [Vector3(-w, 0, 0), Vector3(0, 0, d), Vector3(-1, 0, 0)]]:
		var c: Vector3 = side[0]
		var along: Vector3 = side[1]
		var n: Vector3 = side[2]
		var up := Vector3(0, THREAD.x * 0.5, 0)
		var q: Array[Vector3] = [c - along + up, c + along + up, c + along - up, c - along - up]
		for k: int in [0, 1, 2, 0, 2, 3]:
			st.set_normal(n)
			st.add_vertex(q[k])
	st.index()
	return st.commit()


static func _face(key: String, reward: RunMap.Reward, kind: RunMap.Kind) -> ShaderMaterial:
	if _faces.has(key):
		return _faces[key]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	var tex := painting(reward, kind)
	m.set_shader_parameter(&"has_medallion", tex != null)
	if tex:
		m.set_shader_parameter(&"medallion", tex)
	m.set_shader_parameter(&"mark", mark_of(reward, kind))
	m.set_shader_parameter(&"enamel", enamel_of(reward, kind))
	var stuff := face_stuff(reward, kind)
	var memory := reward == RunMap.Reward.MEMORY
	# the face's metal (the rim drawn on it and a coin's field): silver for the Prata, gold for the rest
	m.set_shader_parameter(&"gold", SILVER if reward == RunMap.Reward.SILVER else GOLD)
	m.set_shader_parameter(&"all_gold", stuff.a > 0.0 and not memory)
	m.set_shader_parameter(&"parchment", memory)
	if memory:
		m.set_shader_parameter(&"enamel", PARCHMENT)
	var mk := mark_of(reward, kind)
	m.set_shader_parameter(&"mark_metal", IVORY if mk == Mark.BLESSING else INK if memory else SILVER if reward == RunMap.Reward.SILVER else GOLD)
	_faces[key] = m
	return m


static func _halo(key: String, reward: RunMap.Reward, kind: RunMap.Kind, _color: Color) -> ShaderMaterial:
	if _halos.has(key):
		return _halos[key]
	var stuff := face_stuff(reward, kind)
	var c := stuff if stuff.a > 0.0 else Color.from_hsv(fposmod(family(reward, kind).x, 360.0) / 360.0, HALO_SATURATION, 1.0)
	var m := ShaderMaterial.new()
	m.shader = HALO_SHADER
	m.set_shader_parameter(&"color", Color(c.r, c.g, c.b))
	m.set_shader_parameter(&"alpha", HALO_ALPHA)
	m.set_shader_parameter(&"peak", minf(HALO_PEAK, ScreenTone.linear_peak(c)))
	_halos[key] = m
	return m
