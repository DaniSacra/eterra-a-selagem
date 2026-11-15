class_name TitleBackdrop
extends Control
## The backdrop of the title screen: the approved painting (docs/art/title_screen_spec.md) contained on the screen,
## never cropped, with a blurred copy filling the bands on screens that are not 16:9, and its air on top: drifting
## mist, the portal's halo and motes, embers. The painting itself never moves. Everything is placed in pixels of the
## painting (`to_local_point`), so the menu, a sibling added after this, can sit exactly over the painted buttons.

## Emitted on ready and whenever the painting moves or changes size on the screen.
signal layout_changed

const ART_SIZE := Vector2(1672, 941)

const ART: Texture2D = preload("res://assets/ui/title/title_bg.png")
const FILL: Texture2D = preload("res://assets/ui/title/title_fill.png")
const ART_SHADER: Shader = preload("res://assets/shaders/title_art.gdshader")
const MIST_SHADER: Shader = preload("res://assets/shaders/title_mist.gdshader")

## Under everything, and what the fill fades from.
const CLEAR := Color("0b0d1c")
## The blurred copy on the bands is this bright.
const FILL_BRIGHTNESS := 0.45
## Units over which an edge of the painting that meets a band melts into the fill.
const SEAM := 24.0
## A band thinner than this (rounding) is no band.
const BAND_MIN := 0.5
## Submenus darken the backdrop to this.
const DIM_LEVEL := 0.45
const DIM_TIME := 0.2
## The air starts as if it had been drifting for a while (no empty first seconds, and the same frame every capture).
const PREWARM := 20.0
const FIXED_SEED := 20261115
const NOISE_SIZE := 256
const NOISE_FREQUENCY := 0.012
const NOISE_OCTAVES := 4

# --- Motes (section 4.2 and 4.3), in pixels of the painting and seconds ---
## Soft dot: the quad is this many times the size the spec gives for the bright core.
const DOT_SPREAD := 2.6
const DOT_PIXELS := 32
## Share of the dot's radius that is solid before it falls off.
const DOT_CORE := 0.22
## Embers over the army: born along the bottom, right of the heroes.
const EMBERS := 24
const EMBER_X := Vector2(900, 1672)
const EMBER_SPEED := Vector2(25, 60)
const EMBER_LIFE := Vector2(4.0, 7.0)
const EMBER_SIZE := Vector2(1.5, 3.0)
const EMBER_SWAY := 12.0
const EMBER_ALPHA := 0.8
const EMBER_HOT := Color("ffb347")
const EMBER_COLD := Color("ff6a1a")
## Three embers on each scenery torch.
const TORCHES: Array[Vector2] = [Vector2(1352, 400), Vector2(1636, 400), Vector2(1563, 495), Vector2(1354, 558)]
const TORCH_EMBERS := 3
const TORCH_LIFE := Vector2(1.0, 1.8)
const TORCH_SPEED := 30.0
const TORCH_SIZE := Vector2(1.5, 2.5)
const TORCH_JITTER := 4.0
## Motes rising inside the portal.
const PORTAL_MOTES := 28
const PORTAL_RECT := Rect2(1470, 300, 90, 140)
const PORTAL_SPEED := Vector2(20, 40)
const PORTAL_LIFE := Vector2(1.6, 2.4)
const PORTAL_SIZE := Vector2(2.0, 5.0)
const PORTAL_DRIFT := 6.0
const PORTAL_ALPHA := 0.85
const PORTAL_YOUNG := Color("7dffa0")
const PORTAL_OLD := Color("2bd65a")
## Violet sparks circling the mage's orb.
const ORB_SPARKS := 10
const ORB_CENTER := Vector2(756, 205)
const ORB_RADIUS := Vector2(28, 70)
const ORB_LIFE := Vector2(2.0, 3.5)
const ORB_SIZE := Vector2(1.5, 3.0)
const ORB_TURN := 0.5
const ORB_ALPHA := 0.7
const ORB_COLOR := Color("c58cff")
## Pale green sparks leaving the blade of the Emeth (the blade and the hand themselves never change).
const BLADE_SPARKS := 8
const BLADE_FROM := Vector2(300, 730)
const BLADE_TO := Vector2(600, 890)
const BLADE_SPEED := Vector2(8, 16)
const BLADE_LIFE := Vector2(2.0, 3.5)
const BLADE_SIZE := Vector2(1.5, 3.0)
const BLADE_JITTER := 10.0
const BLADE_ALPHA := 0.6
const BLADE_COLOR := Color("9dffb8")
## No mote is drawn over the logo (with its margin) or the Explorer's face: it fades out over MOTE_CLEAR px before them.
const MOTE_FREE: Array[Rect2] = [Rect2(880, 20, 552, 348), Rect2(430, 300, 170, 185)]
const MOTE_CLEAR := 14.0
## Random numbers a mote rolls for each life (where it is born, how fast, how big...).
const DICE := 6
## Share of a mote's life it takes to appear.
const MOTE_FADE_IN := 0.12

## Captures (--shot) get the same air every time; a lab sets it before adding the backdrop to the tree.
var deterministic := Dev.has("shot")
## Mist, halo and motes. Off leaves the bare painting (to measure their cost, or for a weak machine).
var atmosphere := true:
	set(on):
		atmosphere = on
		if _mist != null:
			_mist.visible = on
			_motes.visible = on

var _rect := Rect2(Vector2.ZERO, ART_SIZE)
var _fill: TextureRect
var _art: TextureRect
var _mist: ColorRect
var _motes: Control
var _shade: ColorRect
var _dot: Texture2D
var _fade: Tween
var _seed := FIXED_SEED
# per mote: how long each of its lives lasts, its offset on the clock, the life it is living and that life's numbers
var _life := PackedFloat32Array()
var _born := PackedFloat32Array()
var _lives := PackedInt32Array()
var _dice := PackedFloat32Array()
var _time := PREWARM


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not deterministic:
		_seed = randi()
		_time += randf() * PREWARM

	_fill = TextureRect.new()
	_fill.texture = FILL
	_fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fill.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_fill.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_fill.modulate = Color(FILL_BRIGHTNESS, FILL_BRIGHTNESS, FILL_BRIGHTNESS)
	_add_layer(_fill)

	_art = TextureRect.new()
	_art.texture = ART
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_SCALE
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_art.material = ShaderMaterial.new()
	(_art.material as ShaderMaterial).shader = ART_SHADER
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art)

	_mist = ColorRect.new()
	_mist.material = ShaderMaterial.new()
	(_mist.material as ShaderMaterial).shader = MIST_SHADER
	(_mist.material as ShaderMaterial).set_shader_parameter(&"noise", _noise())
	_add_layer(_mist)

	_dot = _soft_dot()
	_motes = Control.new()
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_motes.material = add
	_motes.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_motes.draw.connect(_draw_motes)
	_add_layer(_motes)

	_shade = ColorRect.new()
	_shade.color = Color(0, 0, 0, 0)
	_add_layer(_shade)

	atmosphere = atmosphere
	resized.connect(_layout)
	_layout()


func _process(delta: float) -> void:
	if not atmosphere:
		return
	_time += delta
	(_mist.material as ShaderMaterial).set_shader_parameter(&"time", _time)
	_motes.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), CLEAR)


## Where the painting sits, in this Control's coordinates: contained (never cropped) and centred.
func art_rect() -> Rect2:
	return _rect


## Units of this Control per pixel of the painting.
func art_scale() -> float:
	return minf(size.x / ART_SIZE.x, size.y / ART_SIZE.y)


## A point of the painting (pixels, origin at its top left) in this Control's coordinates.
func to_local_point(p_img: Vector2) -> Vector2:
	return _rect.position + p_img * _rect.size / ART_SIZE


## From black to the painting, slowing down.
func fade_in(time := 0.9) -> void:
	_shade.color.a = 1.0
	_fade_to(0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## To black; the returned signal fires when it gets there.
func fade_out(time := 0.45) -> Signal:
	_fade_to(1.0, time)
	return _fade.finished


## Darkens the backdrop behind a submenu, or brings it back.
func dim(on: bool) -> void:
	_fade_to(1.0 - DIM_LEVEL if on else 0.0, DIM_TIME)


func _fade_to(alpha: float, time: float) -> PropertyTweener:
	if _fade != null:
		_fade.kill()
	_fade = create_tween()
	return _fade.tween_property(_shade, ^"color:a", alpha, time)


func _add_layer(layer: Control) -> void:
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _layout() -> void:
	# contain: the whole painting always shows; the size is rounded up so no line of the fill shows at 16:9
	var art_size := (ART_SIZE * art_scale()).ceil()
	_rect = Rect2(((size - art_size) * 0.5).floor(), art_size)
	_art.position = _rect.position
	_art.size = _rect.size
	var band := (size - _rect.size) * 0.5
	var seam := Vector2(
		SEAM / _rect.size.x if band.x > BAND_MIN else 0.0,
		SEAM / _rect.size.y if band.y > BAND_MIN else 0.0)
	(_art.material as ShaderMaterial).set_shader_parameter(&"seam", seam)
	_fill.visible = seam != Vector2.ZERO
	var mist := _mist.material as ShaderMaterial
	mist.set_shader_parameter(&"rect_size", size)
	mist.set_shader_parameter(&"art_origin", _rect.position)
	mist.set_shader_parameter(&"art_scale", _rect.size.x / ART_SIZE.x)
	queue_redraw()
	layout_changed.emit()


## Three unrelated tiling noises in the three channels of one texture: the mist reads it, nothing is computed per pixel.
func _noise() -> Texture2D:
	var data := PackedByteArray()
	data.resize(NOISE_SIZE * NOISE_SIZE * 3)
	for channel in 3:
		var n := FastNoiseLite.new()
		n.seed = FIXED_SEED + channel
		n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		n.frequency = NOISE_FREQUENCY
		n.fractal_octaves = NOISE_OCTAVES
		var plane := n.get_seamless_image(NOISE_SIZE, NOISE_SIZE)
		plane.convert(Image.FORMAT_L8)
		var src := plane.get_data()
		for i in src.size():
			data[i * 3 + channel] = src[i]
	return ImageTexture.create_from_image(Image.create_from_data(NOISE_SIZE, NOISE_SIZE, false, Image.FORMAT_RGB8, data))


func _soft_dot() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color.WHITE)
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(DOT_CORE, Color.WHITE)
	g.add_point(0.5, Color(1, 1, 1, 0.4))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = DOT_PIXELS
	t.height = DOT_PIXELS
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t


## A number from 0 to 1 that depends only on the seed and on (mote, the life it is living, which number).
func _rnd(mote: int, life: int, which: int) -> float:
	var n := (_seed + mote * 7919 + life * 104729 + which * 1299721) & 0xffffffff
	n = ((n ^ 61) ^ (n >> 16)) & 0xffffffff
	n = (n * 9) & 0xffffffff
	n = n ^ (n >> 4)
	n = (n * 0x27d4eb2d) & 0xffffffff
	n = n ^ (n >> 15)
	return float(n & 0xffffff) / float(0x1000000)


func _range(r: Vector2, t: float) -> float:
	return lerpf(r.x, r.y, t)


## Every mote is a pure function of the clock: no state that matters (only a cache of the numbers of the life it is
## living), so they are the same on every run with the same seed and follow the painting when the window changes.
func _draw_motes() -> void:
	var mote := 0
	# the screen's bottom and right edge in pixels of the painting: on the bands the embers are born out there
	var corner := (size - _rect.position) * ART_SIZE / _rect.size
	for i in EMBERS:
		var age := _live(mote, EMBER_LIFE)
		var k := mote * DICE
		var at := Vector2(
			lerpf(EMBER_X.x, maxf(EMBER_X.y, corner.x), _dice[k])
				+ sin(_time * lerpf(0.6, 1.4, _dice[k + 3]) + _dice[k + 4] * TAU) * EMBER_SWAY * _dice[k + 5],
			maxf(ART_SIZE.y, corner.y) - _range(EMBER_SPEED, _dice[k + 1]) * age * _life[mote])
		_mote(at, _range(EMBER_SIZE, _dice[k + 2]), EMBER_HOT.lerp(EMBER_COLD, age), EMBER_ALPHA * (1.0 - age) * _appear(age))
		mote += 1
	for torch in TORCHES:
		for i in TORCH_EMBERS:
			var age := _live(mote, TORCH_LIFE)
			var k := mote * DICE
			var at := torch + Vector2(
				(_dice[k] - 0.5) * 2.0 * TORCH_JITTER + sin(_time * 3.0 + _dice[k + 1] * TAU) * TORCH_JITTER * 0.5,
				-TORCH_SPEED * age * _life[mote])
			_mote(at, _range(TORCH_SIZE, _dice[k + 2]), EMBER_HOT.lerp(EMBER_COLD, age), EMBER_ALPHA * (1.0 - age) * _appear(age))
			mote += 1
	for i in PORTAL_MOTES:
		var age := _live(mote, PORTAL_LIFE)
		var k := mote * DICE
		var at := PORTAL_RECT.position + PORTAL_RECT.size * Vector2(_dice[k], _dice[k + 1]) + Vector2(
			sin(_time * 1.7 + _dice[k + 3] * TAU) * PORTAL_DRIFT,
			-_range(PORTAL_SPEED, _dice[k + 4]) * age * _life[mote])
		_mote(at, _range(PORTAL_SIZE, _dice[k + 2]), PORTAL_YOUNG.lerp(PORTAL_OLD, age),
			PORTAL_ALPHA * _appear(age) * (1.0 - smoothstep(0.55, 1.0, age)))
		mote += 1
	for i in ORB_SPARKS:
		var age := _live(mote, ORB_LIFE)
		var k := mote * DICE
		var turn := _dice[k] * TAU + age * _life[mote] * ORB_TURN * (1.0 if _dice[k + 1] > 0.3 else -1.0)
		var at := ORB_CENTER + Vector2.from_angle(turn) * lerpf(ORB_RADIUS.x, ORB_RADIUS.y, sqrt(_dice[k + 3]) * (0.7 + 0.3 * age))
		_mote(at, _range(ORB_SIZE, _dice[k + 2]), ORB_COLOR, ORB_ALPHA * sin(age * PI))
		mote += 1
	var blade_side := (BLADE_TO - BLADE_FROM).normalized().orthogonal()
	for i in BLADE_SPARKS:
		var age := _live(mote, BLADE_LIFE)
		var k := mote * DICE
		var at := BLADE_FROM.lerp(BLADE_TO, _dice[k]) + blade_side * (_dice[k + 1] - 0.5) * 2.0 * BLADE_JITTER + Vector2(
			sin(_time * 1.3 + _dice[k + 3] * TAU) * 3.0,
			-_range(BLADE_SPEED, _dice[k + 4]) * age * _life[mote])
		_mote(at, _range(BLADE_SIZE, _dice[k + 2]), BLADE_COLOR, BLADE_ALPHA * sin(age * PI))
		mote += 1


## How far mote number `mote` is into the life it is living (0 to 1). Each life rolls DICE new numbers for it, in
## `_dice` from `mote * DICE`; how long its lives last and when they start is its own, for good.
func _live(mote: int, life_range: Vector2) -> float:
	if mote >= _life.size():
		_life.append(_range(life_range, _rnd(mote, 0, DICE)))
		_born.append(_rnd(mote, 0, DICE + 1) * _life[mote])
		_lives.append(-1)
		_dice.resize((mote + 1) * DICE)
	var clock := _time + _born[mote]
	var n := int(clock / _life[mote])
	if n != _lives[mote]:
		_lives[mote] = n
		for d in DICE:
			_dice[mote * DICE + d] = _rnd(mote, n, d)
	return fmod(clock, _life[mote]) / _life[mote]


func _appear(age: float) -> float:
	return minf(age / MOTE_FADE_IN, 1.0)


## One soft dot: place and size in pixels of the painting.
func _mote(at_img: Vector2, size_img: float, color: Color, alpha: float) -> void:
	for free in MOTE_FREE:
		var away := (at_img - at_img.clamp(free.position, free.end)).length()
		alpha *= clampf(away / MOTE_CLEAR - 0.5, 0.0, 1.0)
	if alpha <= 0.0:
		return
	var half := maxf(size_img * _rect.size.x / ART_SIZE.x * DOT_SPREAD, 2.0) * 0.5
	_motes.draw_texture_rect(_dot, Rect2(to_local_point(at_img) - Vector2(half, half), Vector2(half, half) * 2.0), false, Color(color, alpha))
