extends SceneTree
## Draws the painted-looking textures of the effects in code (no outside pack): torn-edge impact stars, a bone dust
## flipbook and a brush streak strip. Grey values in the red channel (white = light/density). Made by an AI assistant
## writing this script (see docs/steam-ia.md); no source image. Run:
##   godot --headless --path . -s tools/make_fx_textures.gd
## Output: assets/textures/fx/*.png

const OUT := "res://assets/textures/fx/"
const STAR := 256
const PUFF := 128
const PUFF_FRAMES := 8


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_star(OUT + "star4.png", 4, 11)
	_star(OUT + "star6.png", 6, 29)
	_puffs(OUT + "puff_sheet.png")
	_streaks(OUT + "brush_streaks.png")
	print("fx textures done")
	quit()


func _noise(seed_: int, freq: float) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seed_
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = freq
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = 4
	return n


## A star of `rays` uneven rays, long ones and short ones, each thin at the tip, edges torn by noise, a hot core.
func _star(path: String, rays: int, seed_: int) -> void:
	var img := Image.create(STAR, STAR, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var angles: Array[float] = []
	var lens: Array[float] = []
	var widths: Array[float] = []
	for i in rays:
		angles.append((float(i) / rays + rng.randf_range(-0.04, 0.04)) * TAU)
		lens.append(0.95 if i % 2 == 0 else rng.randf_range(0.5, 0.72))
		widths.append(rng.randf_range(0.05, 0.085) * (1.0 if i % 2 == 0 else 0.8))
	var tear := _noise(seed_, 6.0)
	for y in STAR:
		for x in STAR:
			var p := Vector2((x + 0.5) / STAR * 2.0 - 1.0, (y + 0.5) / STAR * 2.0 - 1.0)
			var r := p.length()
			var v := exp(-r * r * 38.0)  # hot core
			v = maxf(v, 0.5 * exp(-r * r * 6.0))  # soft halo
			for i in rays:
				var dir := Vector2.from_angle(angles[i])
				var along := p.dot(dir)
				var across := absf(p.x * dir.y - p.y * dir.x)
				if along > 0.0 and along < lens[i]:
					var k := along / lens[i]
					var w := widths[i] * pow(1.0 - k, 1.1) + 0.004
					var t := tear.get_noise_2d(x, y) * 0.5 * w
					var ray := 1.0 - smoothstep(w * 0.35, w, across + t)
					v = maxf(v, ray * (1.0 - k * 0.55))
			v *= 1.0 - smoothstep(0.88, 1.0, r)
			var c := clampf(v, 0.0, 1.0)
			img.set_pixel(x, y, Color(c, c, c, 1.0))
	img.save_png(path)


## 8 frames of a puff of dust in a 4x2 sheet: it opens, curls, thins and comes apart as the noise eats it.
func _puffs(path: String) -> void:
	var img := Image.create(PUFF * 4, PUFF * 2, false, Image.FORMAT_RGBA8)
	var a := _noise(5, 0.035)
	var b := _noise(77, 0.07)
	for f in PUFF_FRAMES:
		var t := float(f) / float(PUFF_FRAMES - 1)
		var ox := (f % 4) * PUFF
		var oy := (f / 4) * PUFF
		var radius := lerpf(0.38, 0.92, 1.0 - pow(1.0 - t, 2.0))
		for y in PUFF:
			for x in PUFF:
				var p := Vector2((x + 0.5) / PUFF * 2.0 - 1.0, (y + 0.5) / PUFF * 2.0 - 1.0)
				var r := p.length() / radius
				var n := a.get_noise_2d(x + f * 9.0, y - f * 13.0) * 0.6 + b.get_noise_2d(x - f * 5.0, y + f * 7.0) * 0.4
				var body := (1.0 - r) + n * 0.55 - t * 0.5
				var d := smoothstep(0.0, 0.35, body) * (1.0 - t * 0.55)
				d *= 1.0 - smoothstep(0.92, 1.0, p.length())
				var c := clampf(d, 0.0, 1.0)
				img.set_pixel(ox + x, oy + y, Color(c, c, c, 1.0))
	img.save_png(path)


## A wide strip of long dry-brush streaks (stretched along x, tileable on x) to break a ribbon of light into paint.
func _streaks(path: String) -> void:
	var w := 512
	var h := 128
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var n := _noise(3, 1.0)
	n.fractal_octaves = 3
	for y in h:
		for x in w:
			# tile in x by blending two samples a period apart
			var u := float(x) / w
			var s1 := n.get_noise_2d(x * 0.012, y * 0.9)
			var s2 := n.get_noise_2d((x - w) * 0.012, y * 0.9)
			var s := lerpf(s1, s2, u)
			var fine := n.get_noise_2d(x * 0.05 + 40.0, y * 2.4) * 0.35
			var c := clampf(0.55 + s * 1.3 + fine, 0.0, 1.0)
			c = smoothstep(0.18, 0.75, c)
			img.set_pixel(x, y, Color(c, c, c, 1.0))
	img.save_png(path)
