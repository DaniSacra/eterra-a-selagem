class_name TalentDef
extends Resource
## A Gift (Dom) of a hero: permanent, unlocked by Mastery, equipped before the descent with Devotion
## (docs/design/warrior_spec.md 4). The tree: a centre (the passive, always on) and four branches in a diamond, each with
## an entry, a middle and an apex; bridges between neighbouring branches; sustain Gifts off the branches. What a Gift
## needs comes from where it sits (Talents.missing): only Gifts that are equipped count. Data in data/talents/<hero>/,
## written by _talents in tools/make_data.gd.

## The four families (game design, not canon) and the two places off them.
enum Branch { COMBO, FURIA, EMETH, MAGIA, BRIDGE, SUSTAIN }
enum Tier { ENTRY, MIDDLE, APEX, BRIDGE, SUSTAIN }

## Neighbours in the diamond (the order of the art bible): Combo and Furia, Furia and Magia, Magia and Emeth, Emeth and
## Combo.
const NEIGHBOURS := {
	Branch.COMBO: [Branch.FURIA, Branch.EMETH],
	Branch.FURIA: [Branch.COMBO, Branch.MAGIA],
	Branch.MAGIA: [Branch.FURIA, Branch.EMETH],
	Branch.EMETH: [Branch.MAGIA, Branch.COMBO],
}

@export var id: StringName
## Text keys (data/text_pt.tres): the name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
@export var branch: Branch = Branch.COMBO
@export var tier: Tier = Tier.ENTRY
## Devotion it takes to equip (1 to 5).
@export_range(0, 5) var cost := 1
## The Mastery level that unlocks it.
@export_range(1, 20) var unlock_level := 1
## The action it changes (Boon.Slot): one Gift per action; NONE when it only reinforces (any number of them).
@export var slot: Boon.Slot = Boon.Slot.NONE
## An apex: the neighbouring branch one more Gift must come from.
@export var partner: Branch = Branch.COMBO
## A bridge: the two branches whose entries it needs.
@export var joins: Array[Branch] = []
## The Gift's numbers, summed with the Blessings in BoonState.stat (level 1, no rarity). Plain stats the fight already
## read (reach_pct, magick_max, max_hp) and the stats of the Gifts' rules (GiftState: fury_*, dash_back_on_kill,
## blow_wave*, hungry_time, omega_discount, spin_loop_hits, dash_chain, fury_stun, wave_through, finisher_magick,
## ult_charge_pct, room_heal, rise_share); a tag limits a number to the moves carrying it.
@export var mods: Array[BoonMod] = []
## A Gift that changes the attack's chain: the combo tree the hero plays instead of HeroDef.combos (Quarto Corte).
## Same tags on every move, so the Blessings keep counting.
@export_file("*.tres") var combos := ""


static func neighbours(a: Branch, b: Branch) -> bool:
	return NEIGHBOURS.has(a) and (NEIGHBOURS[a] as Array).has(b)
