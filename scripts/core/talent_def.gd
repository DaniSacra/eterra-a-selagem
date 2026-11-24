class_name TalentDef
extends Resource
## A Gift (Dom) of a hero: permanent, unlocked by Mastery, equipped before the descent with Devotion
## (docs/design/warrior_spec.md 4). The tree: a centre (the passive, always on) and four branches in a diamond, each with
## an entry, a middle and an apex; bridges between neighbouring branches; sustain Gifts off the branches. What a Gift
## needs comes from where it sits (Talents.missing): only Gifts that are equipped count. Data in data/talents/<hero>/,
## written by _talents in tools/make_data.gd.

## The six branches of 3 x 4 Gifts a hero (redesign 2026-11-24, 04_PLANO A.1): COMBO, IMPETO and DOMINIO for the Warrior;
## ELEMENTALISMO, CONJURACAO and FEITICARIA for the Maga. Each is an entry, two middles and an apex; what a Gift needs is
## `needs`. The number is never saved (only the ids of Gifts are).
enum Branch { COMBO, IMPETO, DOMINIO, ELEMENTALISMO, CONJURACAO, FEITICARIA }
enum Tier { ENTRY, MIDDLE, APEX }

@export var id: StringName
## Text keys (data/text_pt.tres): the name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
@export var branch: Branch = Branch.COMBO
@export var tier: Tier = Tier.ENTRY
## Devotion it takes to equip (1 to 5).
@export_range(0, 5) var cost := 1
## The Mastery level that reveals it (Rejogabilidade, Fatia 1: the Mastery reveals, the Memória opens, the Devotion
## equips; sistemas.md 1.4).
@export_range(1, 20) var unlock_level := 1
## Fragments of Memória it takes to open, once (0: open from the start, as Quarto Corte at Mastery 1, so the first
## descent is no poorer than before). The others cost their Devotion (1 to 5).
@export_range(0, 9) var memory_cost := 0
## The action it changes (Boon.Slot): one Gift per action; NONE when it only reinforces (any number of them).
@export var slot: Boon.Slot = Boon.Slot.NONE
## The Gift that must be equipped for this one to go on (empty: an entry, it needs only the centre).
@export var needs: StringName = &""
## The Gift's numbers, summed with the Blessings in BoonState.stat (level 1, no rarity). Plain stats the fight already
## read (reach_pct, magick_max, max_hp) and the stats of the Gifts' rules (GiftState: fury_*, dash_back_on_kill,
## blow_wave*, hungry_time, omega_discount, spin_loop_hits, dash_chain, fury_full_pct, armor_pct, shout_ward, cooldown_pct, wave_through, finisher_magick,
## ult_charge_pct, room_heal, rise_share, rise_boss_share); a tag limits a number to the moves carrying it.
@export var mods: Array[BoonMod] = []
## A Gift that changes the attack's chain: the combo tree the hero plays instead of HeroDef.combos (Quarto Corte).
## Same tags on every move, so the Blessings keep counting.
@export_file("*.tres") var combos := ""
