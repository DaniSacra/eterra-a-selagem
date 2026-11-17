class_name TalentTree
extends Control
## The Warrior's Gift tree as a diamond (docs/design/warrior_spec.md 4.1, art piece 3): the passive in the centre and
## the four branches on the axes in the art bible's order (Combo up, Fúria right, Magia down, Emeth left), each with
## its entry, middle and apex going out; the bridges on the diagonals between neighbours; the sustain Gifts in a row of
## their own in the lower left corner (they hang on the centre alone). Lines join what a Gift needs; a line lights in
## old gold when both its ends are on. The nodes are TalentNode buttons placed by hand inside this control; focus moves
## between them by direction (Godot's own search), so keys and the gamepad's pad walk the diamond.

signal picked(def: TalentDef)
signal focused(def: TalentDef)

## Half the diamond across and down, in pixels at 720 lines, and how far out each tier sits (share of the half).
const HALF := Vector2(290, 222)
const TIER_AT := {TalentDef.Tier.ENTRY: 0.34, TalentDef.Tier.MIDDLE: 0.64, TalentDef.Tier.APEX: 0.92}
const BRIDGE_AT := 0.5
const AXIS := {
	TalentDef.Branch.COMBO: Vector2(0, -1), TalentDef.Branch.FURIA: Vector2(1, 0),
	TalentDef.Branch.MAGIA: Vector2(0, 1), TalentDef.Branch.EMETH: Vector2(-1, 0),
}
## The sustain row (centre of its first node and the step) and its label, from the diamond's centre.
const SUSTAIN_AT := Vector2(-258, 204)
const SUSTAIN_STEP := 58.0
const LABEL_SIZE := 17
const CENTRE_SIDE := 58.0
## The room around the diamond for the branch names.
const MARGIN := Vector2(40, 18)

var loadout: HeroLoadout
var nodes: Array[TalentNode] = []
var centre: TalentNode


func setup(p_loadout: HeroLoadout) -> TalentTree:
	loadout = p_loadout
	custom_minimum_size = (HALF + MARGIN) * 2.0
	centre = TalentNode.new().setup(null, CENTRE_SIDE)
	add_child(centre)
	centre.focus_entered.connect(func() -> void: focused.emit(null))
	var sustain := 0
	for t in loadout.book.catalog:
		var n := TalentNode.new().setup(t)
		nodes.append(n)
		add_child(n)
		n.set_meta(&"at", spot(t, sustain))
		if t.tier == TalentDef.Tier.SUSTAIN:
			sustain += 1
		n.pressed.connect(func() -> void: picked.emit(t))
		n.focus_entered.connect(func() -> void: focused.emit(t))
	refresh()
	resized.connect(_place)
	_place()
	return self


## Where a Gift sits, from the diamond's centre (k: its place in the sustain row).
static func spot(t: TalentDef, k: int = 0) -> Vector2:
	match t.tier:
		TalentDef.Tier.BRIDGE:
			var d: Vector2 = AXIS[t.joins[0]] + AXIS[t.joins[1]]
			return d * HALF * BRIDGE_AT
		TalentDef.Tier.SUSTAIN:
			return SUSTAIN_AT + Vector2(SUSTAIN_STEP * k, 0)
	return (AXIS[t.branch] as Vector2) * HALF * float(TIER_AT[t.tier])


func node(id: StringName) -> TalentNode:
	for n in nodes:
		if n.def.id == id:
			return n
	return null


## Every node takes its state again (after a Gift goes on or off).
func refresh() -> void:
	for n in nodes:
		n.state = loadout.state(n.def)
	queue_redraw()


func _mid() -> Vector2:
	return size * 0.5


func _place() -> void:
	var m := _mid()
	centre.position = m - centre.size * 0.5
	for n in nodes:
		n.position = m + (n.get_meta(&"at") as Vector2) - n.size * 0.5
	queue_redraw()


func _on(t: TalentDef) -> bool:
	return t == null or loadout.is_equipped(t.id)


func _draw() -> void:
	var m := _mid()
	for t in loadout.book.catalog:
		match t.tier:
			TalentDef.Tier.ENTRY:
				_link(m, null, t)
			TalentDef.Tier.MIDDLE:
				_link(m, loadout.of(t.branch, TalentDef.Tier.ENTRY), t)
			TalentDef.Tier.APEX:
				_link(m, loadout.of(t.branch, TalentDef.Tier.MIDDLE), t)
			TalentDef.Tier.BRIDGE:
				for b: TalentDef.Branch in t.joins:
					_link(m, loadout.of(b, TalentDef.Tier.ENTRY), t)
	# the branch names past each apex, in the branch's colour
	for b: TalentDef.Branch in AXIS:
		var axis: Vector2 = AXIS[b]
		var text := T.t(HeroLoadout.BRANCH_KEY[b])
		var font := UiKit.TITLE_FONT
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE).x
		var apex := m + axis * HALF * float(TIER_AT[TalentDef.Tier.APEX])
		var at := apex + Vector2(34.0, 6.0) if axis.x == 0.0 else apex + Vector2(-w * 0.5, 50.0)
		var col := TalentNode.BRANCH_COLOR[b].lightened(0.15)
		UiKit.draw_shadow(self, font, at, text, LABEL_SIZE)
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, col)
	var label := T.t(HeroLoadout.BRANCH_KEY[TalentDef.Branch.SUSTAIN])
	var lat := m + SUSTAIN_AT + Vector2(-22.0, -34.0)
	UiKit.draw_shadow(self, UiKit.TITLE_FONT, lat, label, LABEL_SIZE - 2)
	draw_string(UiKit.TITLE_FONT, lat, label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE - 2, TalentNode.BRANCH_COLOR[TalentDef.Branch.SUSTAIN].lightened(0.1))


## The line from what a Gift needs (null: the centre) to it.
func _link(m: Vector2, from: TalentDef, to: TalentDef) -> void:
	var a := m if from == null else m + spot(from)
	var b := m + spot(to)
	var lit := _on(from) and _on(to)
	var locked := to.unlock_level > loadout.level()
	var col := TalentNode.LOCK_LINE if locked else Color(UiKit.OLD_GOLD, 0.55)
	if lit:
		col = UiKit.OLD_GOLD.lightened(0.4)
	draw_line(a, b, col, 3.0 if lit else 1.6, true)
