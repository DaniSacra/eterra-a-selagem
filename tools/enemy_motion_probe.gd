extends SceneTree
## T5 (docs/design/combat_cadence.md 6.1): plays the real game and logs every enemy each world step: state, timers,
## the clip and pose drawn (decoded from drawn_row), place, real speed, the yaw drawn, its warning on the floor; plus
## sounds heard and blows on the paladin (HIT). From the combat-feel-director's probe of the T5 diagnosis
## (docs/gallery/t5/motion/before/data/t5_probe.gd.txt). Read with tools/enemy_motion_probe.py.
## ~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/enemy_motion_probe.gd -- --play --seed=2
##   --hero-hp=9999 --probe-secs=40 --probe-out=out.csv [--probe-ids=skeleton]

var game: Node = null
var horde: Object = null
var last_frame := -1
var secs := 40.0
var out: FileAccess
var ids := PackedStringArray()
var t0 := -1
var heard_n := 0
var uid := {}
var rows := {}  # model -> Array of [first, anim, n]


func _initialize() -> void:
	var path := "probe.csv"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probe-secs="):
			secs = float(a.trim_prefix("--probe-secs="))
		elif a.begins_with("--probe-out="):
			path = a.trim_prefix("--probe-out=")
		elif a.begins_with("--probe-ids="):
			ids = a.trim_prefix("--probe-ids=").split(",")
	out = FileAccess.open(path, FileAccess.WRITE)
	out.store_line("f,id,uid,state,state_t,anim,drawn,pose,fade,x,z,vx,vz,speed,yaw,dist,cd,stun,hurt,warn_life,warn_total,walking,straight,blow_t,radius,reach,windup,hold")
	change_scene_to_file("res://scenes/boot.tscn")


func _decode(model: BakedModel, row: int) -> String:
	if row < 0:
		return "-"
	if not rows.has(model):
		var list := []
		for anim: StringName in model.first:
			list.append([int(model.first[anim]), anim, model.frame_count(anim)])
		rows[model] = list
	for r: Array in rows[model]:
		if row >= r[0] and row < r[0] + r[2]:
			return "%s:%d" % [r[1], row - r[0]]
	return "?%d" % row


func _process(_d: float) -> bool:
	if game == null:
		for n in root.find_children("*", "Node", true, false):
			if "horde" in n and n.get(&"horde") != null and n.has_method(&"result"):
				game = n
				horde = n.get(&"horde")
				# every blow on the paladin, with what dealt it: the crowd's body (horde), a warning landing or a
				# body's strike (ground), a shot (shots); x, z where it came from and the paladin's place
				for src: Object in [horde, n.get(&"ground"), n.get(&"projectiles")]:
					var channel: String = "horde" if src == horde else ("ground" if src == n.get(&"ground") else "shots")
					src.hit_player.connect(func(amount: float, from: Vector2) -> void:
						var hero: Vector2 = horde.get(&"target")
						out.store_line("%d,HIT,%.1f,%.2f,%.2f,%s,%s,%.2f,%.2f" % [last_frame + 1, amount, from.x, from.y, channel,
							String(src.get(&"last_by")), hero.x, hero.y]))
				root.get_node("Audio").listen(true, func() -> int: return Engine.get_process_frames())
				break
		return false
	if not is_instance_valid(horde):
		out.close()
		return true
	var f: int = horde.get(&"_frame")
	if f == last_frame:
		return false
	last_frame = f
	if t0 < 0:
		t0 = Engine.get_process_frames()
	var target: Vector2 = horde.get(&"target")
	var renderer: Object = horde.get(&"renderer")
	for e: Object in horde.get(&"list"):
		var d: EnemyDef = e.def
		if not ids.is_empty() and not String(d.id) in ids:
			continue
		if not uid.has(e):
			uid[e] = uid.size()
		var model: BakedModel = renderer.kind(d).model
		var w: Object = e.warning
		var wl := -1.0
		var wt := -1.0
		if w != null and not w.cancelled and w.life > 0.0:
			wl = w.life
			wt = w.total
		var v: Vector2 = e.vel
		out.store_line("%d,%s,%d,%d,%.3f,%s,%s,%s,%.2f,%.3f,%.3f,%.2f,%.2f,%.2f,%.1f,%.2f,%.2f,%.2f,%.2f,%.3f,%.3f,%d,%d,%.3f,%.2f,%.2f,%.2f,%.2f" % [f, d.id, uid[e], e.state, e.state_t, e.anim,
			e.drawn_anim, _decode(model, e.drawn_row), e.fade_t, e.pos.x, e.pos.y, v.x, v.y, v.length(), rad_to_deg(e.yaw()),
			e.pos.distance_to(target), e.cooldown, e.stun_t, e.hurt_t, wl, wt, int(e.walking), int(e.straight), e.blow_t, d.radius, d.radius + d.strike_reach * d.size, d.attack_windup, d.windup_hold])
	var boss: Object = game.get(&"boss")
	if boss != null and is_instance_valid(boss):
		var zs := ""
		for z: Object in game.get(&"ground").zones:
			if int(z.kind) == 0 and not z.cancelled:
				zs += "%s:%.2f/%.2f;" % [z.source, z.life, z.total]
		out.store_line("%d,BOSS,%d,%s,%d,%.3f,%d,%s" % [f, boss.state, boss.get(&"_attack"), boss.get(&"_step"), boss.get(&"_t"), boss.phase, zs])
	var heard: Array = root.get_node("Audio").heard
	while heard_n < heard.size():
		var h: Array = heard[heard_n]
		out.store_line("%d,SND,%s,%d" % [f, h[0], h[1]])
		heard_n += 1
	if Engine.get_process_frames() - t0 > secs * 60:
		out.close()
		quit()
		return true
	return false
