class_name BookTurn
extends Control
## The page turn of the Livro de Ahk (docs/art/book_spec.md 5). The pure part decides where to go (the chapters loop;
## a ribbon far away is one turn per chapter of distance). The node does the gesture: a snapshot of the leaf that goes
## folds in towards the spine (it lifts and stands on its edge), then the snapshot of the page that arrives opens out
## from the spine over the old one, in `secs`; the leaf darkens as it stands. The new content is already laid out
## underneath (the screen swaps it first, the turn only covers the swap). Without a screen to read from (headless) or in
## a browser (Compatibility) `can_animate` is false and the callers swap at once.

const SHADE := 0.55
const LIFT := 0.03

var _tween: Tween
var _layers: Array[Control] = []
## True while a leaf is in the air (the screen swaps the next turn at once).
var busy := false


## The chapter `step` pages away, looping (Ofícios to Abertura).
static func next(current: int, step: int, count: int) -> int:
	return posmod(current + step, count) if count > 0 else 0


## The chapters a turn passes through from `from` to `to`, one per chapter of distance, ending on `to`.
static func route(from: int, to: int) -> Array[int]:
	var out: Array[int] = []
	var dir := signi(to - from)
	var c := from
	while c != to:
		c += dir
		out.append(c)
	return out


static func can_animate() -> bool:
	return DisplayServer.get_name() != "headless" and not OS.has_feature("web")


## Turns the book: `swap` puts the new chapter in (the callers' own), `forward` is a turn to the right.
func flip(book: BookSpread, forward: bool, swap: Callable, secs: float) -> void:
	busy = true
	var old := _grab(book)
	if old.is_empty():
		swap.call()
		busy = false
		return
	# the old pages stay on show while the swap lays out, then hide for one frame drawn off screen: the new ones
	var under_l := _layer(book.left, old[0])
	var under_r := _layer(book.right, old[1])
	swap.call()
	await get_tree().process_frame
	await get_tree().process_frame
	if not busy:
		return
	under_l.visible = false
	under_r.visible = false
	RenderingServer.force_draw(false)
	var fresh := _grab(book)
	under_l.visible = true
	under_r.visible = true
	if fresh.is_empty():
		_clear()
		return
	var out_page := book.right if forward else book.left
	var in_page := book.left if forward else book.right
	var out_tex: Texture2D = old[1] if forward else old[0]
	var in_tex: Texture2D = fresh[0] if forward else fresh[1]
	# the page the leaf lifts from is the leaf itself: only the other old page stays under it
	(under_r if forward else under_l).visible = false
	var out_leaf := _layer(out_page, out_tex)
	var in_leaf := _layer(in_page, in_tex)
	in_leaf.visible = false
	# the leaf stands on the spine: the right page's left side going out, the left page's right side coming in
	var out_edge := 0.0 if forward else 1.0
	out_leaf.pivot_offset = Vector2(out_leaf.size.x * out_edge, out_leaf.size.y * 0.5)
	in_leaf.pivot_offset = Vector2(in_leaf.size.x * (1.0 - out_edge), in_leaf.size.y * 0.5)
	_tween = create_tween()
	_tween.tween_method(_step.bind(out_leaf, in_leaf), 0.0, 1.0, secs)
	await _tween.finished
	_clear()


## t 0..1: the first half the leaf going out folds to the spine, the second half the arriving one opens.
func _step(t: float, out_leaf: Control, in_leaf: Control) -> void:
	if not is_instance_valid(out_leaf) or not is_instance_valid(in_leaf):
		return
	var first := t < 0.5
	out_leaf.visible = first
	in_leaf.visible = not first
	var u := t * 2.0 if first else (t - 0.5) * 2.0
	var width := 1.0 - sin(u * PI * 0.5) if first else sin(u * PI * 0.5)
	var leaf := out_leaf if first else in_leaf
	leaf.scale = Vector2(maxf(width, 0.01), 1.0 + LIFT * sin(u * PI))
	var dark := lerpf(1.0, SHADE, 1.0 - width)
	leaf.modulate = Color(dark, dark, dark)


func _layer(page: Control, tex: Texture2D) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	r.global_position = page.global_position
	r.size = page.size
	_layers.append(r)
	return r


## The pages as they are on screen now, [left, right], in the viewport's pixels (empty: nothing to read).
func _grab(book: BookSpread) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	var img := get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return out
	for page: Control in [book.left, book.right]:
		var xf := get_viewport().get_final_transform() * page.get_global_transform_with_canvas()
		var r := Rect2i(xf * Rect2(Vector2.ZERO, page.size)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		if r.size.x < 2 or r.size.y < 2:
			return [] as Array[Texture2D]
		out.append(ImageTexture.create_from_image(img.get_region(r)))
	return out


## Ends the turn where it is (the next one asked for while it flies).
func finish() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_clear()


func _clear() -> void:
	for l in _layers:
		if is_instance_valid(l):
			l.queue_free()
	_layers.clear()
	busy = false
