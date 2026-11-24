class_name ForgeInfo
extends RefCounted
## What the Forja's plate says about one choice (docs/art/forge_spec.md 3 and 4), pure: its look (the six states of
## a chip), what the press does, the words of the plate (name, state, what it changes, the line under it) and the
## price with what the save holds. Built from the Forge's own rules (Forge.state and problem) or from the Oficina's
## (Oficios.restore_problem); nothing is bought here. The screen only draws it.
##   var info := ForgeInfo.of(forge, Save.data, rank)     # the Emeth's choices
##   var pick := ForgeInfo.pick(Save.data, OficiosDef.live())

## READY: can be forged now. SHORT: the material is missing. NEEDS: an earlier rank first. STORED: forged and kept
## (Usar is free). ON: on the blade. NO_TOOL: the Forjador's tool is still lost.
enum Look { READY, SHORT, NEEDS, STORED, ON, NO_TOOL }
## What the press does: HAMMER (three strikes spend), USE (a kept choice goes on, free), AWAKEN, SLEEP (the Despertar,
## free), NONE (nothing to do: the plate says why).
enum Action { NONE, HAMMER, USE, AWAKEN, SLEEP }

var rank: ForgeRank
var look := Look.READY
var action := Action.NONE
var id: StringName = &""
var name := ""
## The state's word on the plate.
var state_text := ""
## What it changes (one sentence with numbers) and the small line under it (what it replaces, or why it waits).
var desc := ""
var detail := ""
var material: StringName = MaterialPurse.SILVER
var cost := 0
var have := 0
## No price on the plate (a free change or nothing to buy).
var free := false
## Why nothing can be done (when action is NONE).
var why := ""
## The word under the chip's name (the price shows as a number instead when empty).
var chip_word := ""


static func of(forge: Forge, data: Dictionary, r: ForgeRank) -> ForgeInfo:
	var i := ForgeInfo.new()
	i.rank = r
	i.id = r.id
	i.name = T.t(r.name_key)
	i.desc = T.t(r.desc_key)
	i.material = r.material
	i.cost = r.cost
	i.have = MaterialPurse.amount(data, r.material)
	var mat := MaterialCount.short_of(r.material)
	match forge.problem(data, r):
		Forge.Problem.OWNED:
			i.free = true
			_owned(forge, data, r, i)
		Forge.Problem.NO_TOOL:
			i.look = Look.NO_TOOL
			i.state_text = T.t(&"forge_state_no_tool")
			i.chip_word = i.state_text
			i.detail = T.t(StringName("forge_no_" + String(r.tool))) if r.tool != Forge.TOOL_REFINE else T.t(&"forge_no_tool")
			i.why = i.detail
		Forge.Problem.NEEDS:
			var before := _before(forge, r)
			var prev := T.t(before.name_key) if before != null else ""
			i.look = Look.NEEDS
			i.state_text = T.t(&"forge_state_needs", {"name": prev})
			i.chip_word = T.t(&"forge_after", {"name": prev})
			i.detail = T.t(&"forge_step_needs", {"name": prev})
			i.why = i.detail
		Forge.Problem.SHORT:
			i.look = Look.SHORT
			i.state_text = T.t(&"forge_lack", {"n": r.cost - i.have, "name": mat})
			i.detail = T.t(&"forge_step_short_emerald" if r.material == MaterialPurse.EMERALD else &"forge_step_short")
			i.why = i.detail
		_:
			i.look = Look.READY
			i.action = Action.HAMMER
			i.state_text = T.t(&"forge_state_ready")
			i.detail = _instead(forge, data, r)
	return i


static func _owned(forge: Forge, data: Dictionary, r: ForgeRank, i: ForgeInfo) -> void:
	i.look = Look.ON
	if r.track == Forge.AWAKEN:
		var on := forge.is_on(data, r)
		i.look = Look.ON if on else Look.STORED
		i.state_text = T.t(&"forge_state_awake" if on else &"forge_state_asleep")
		i.chip_word = T.t(&"forge_awaken_on" if on else &"forge_stored")
		i.action = Action.SLEEP if on else Action.AWAKEN
		i.detail = T.t(&"forge_step_awake" if on else &"forge_step_asleep")
	elif r.track == Forge.REFINE:
		var on := forge.is_on(data, r)
		i.look = Look.ON if on else Look.STORED
		i.state_text = T.t(&"forge_state_on" if on else &"forge_state_off")
		i.chip_word = T.t(&"forge_refine_on" if on else &"forge_stored")
		if on:
			i.why = T.t(&"forge_step_on")
			i.detail = i.why
		else:
			i.action = Action.USE
			i.detail = _instead(forge, data, r, true)
	elif r.track == Forge.INSCRIBE:
		i.state_text = T.t(&"forge_state_inscribed")
		i.chip_word = T.t(&"forge_state_inscribed")
		i.detail = T.t(&"forge_step_inscribed")
		i.why = i.detail
	else:
		i.state_text = T.t(&"forge_state_owned")
		i.chip_word = T.t(&"forge_refine_on")
		i.detail = T.t(&"forge_step_owned")
		i.why = i.detail
		if Forge.temper(data) >= forge.track(Forge.TEMPER).size():
			i.why = T.t(&"forge_done")


## "No lugar de X": what a Refinar or a Despertar takes the place of (empty when it takes none).
static func _instead(forge: Forge, data: Dictionary, r: ForgeRank, kept := false) -> String:
	var now: ForgeRank = null
	if r.track == Forge.REFINE:
		for o in forge.refine_options(r.slot):
			if o != r and forge.is_on(data, o):
				now = o
	elif r.track == Forge.AWAKEN:
		var a := forge.awake(data)
		now = a if a != r else null
	if now == null:
		return T.t(&"forge_step_use_free") if kept else ""
	return T.t(&"forge_instead", {"name": T.t(now.name_key)})


static func _before(forge: Forge, r: ForgeRank) -> ForgeRank:
	var track := forge.track(r.track)
	var i := track.find(r)
	return track[i - 1] if i > 0 else null


## The Oficina's one choice: restoring the Picareta.
static func pick(data: Dictionary, def: OficiosDef) -> ForgeInfo:
	var i := ForgeInfo.new()
	i.id = &"pick"
	i.name = T.t(&"oficio_pick")
	i.desc = T.t(&"forge_pick_desc")
	i.material = MaterialPurse.SILVER
	i.cost = int(def.restore_cost.get(OficiosDef.SILVER, 0))
	i.have = MaterialPurse.amount(data, MaterialPurse.SILVER)
	match Oficios.restore_problem(data, def):
		Oficios.DONE:
			i.look = Look.ON
			i.free = true
			i.state_text = T.t(&"forge_pick_state_restored")
			i.chip_word = T.t(&"forge_pick_state_restored")
			i.detail = T.t(&"forge_pick_step_restored")
			i.why = i.detail
		Oficios.NO_HEAD:
			i.look = Look.NO_TOOL
			i.state_text = T.t(&"forge_pick_state_no_head")
			i.chip_word = i.state_text
			i.detail = T.t(&"oficio_smith_where")
			i.why = i.detail
		Oficios.SHORT:
			i.look = Look.SHORT
			i.state_text = T.t(&"forge_lack", {"n": Oficios.restore_short(data, def), "name": MaterialCount.short_of(MaterialPurse.SILVER)})
			i.detail = T.t(&"forge_step_short")
			i.why = i.detail
		_:
			i.look = Look.READY
			i.action = Action.HAMMER
			i.state_text = T.t(&"forge_pick_state_ready")
	return i


## Whether the press spends (three strikes) rather than changing something free.
func spends() -> bool:
	return action == Action.HAMMER


## The verb of the button.
func verb() -> String:
	match action:
		Action.HAMMER:
			return T.t(&"oficio_restore") if id == &"pick" else T.t(&"forge_hammer")
		Action.USE:
			return T.t(&"forge_refine_use")
		Action.AWAKEN:
			return T.t(&"forge_awaken_use")
		Action.SLEEP:
			return T.t(&"forge_awaken_off")
	return ""
