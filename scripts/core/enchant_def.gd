class_name EnchantDef
extends Resource
## One Encanto of the Emeth (Rejogabilidade, Fatia 2; sistemas.md 1.7, auditoria.md 3.1; Hades II's Daedalus hammer):
## a change of a blow for one descent, taken at a door of Encanto (RunMap.Reward.ENCHANT) or bought in the shop, at
## most StageDef.enchant_max a descent, three to choose among those learned at the Forja (the Fatia 2's three come
## learned). Its numbers are stats summed in BoonState.stat (BoonState.enchants) with the tags of the blows they touch,
## so the fight reads them as any Blessing's (Combat, GiftState). Data in data/enchants/, written by _enchants in
## tools/make_data.gd.

@export var id: StringName
## Text keys: its name and what it does.
@export var name_key: StringName
@export var desc_key: StringName
## The action it changes (Boon.Slot; for the screen's mark).
@export var slot := Boon.Slot.ATTACK
## Its numbers (BoonMod: stat, tag, base; level 1, never scaled).
@export var mods: Array[BoonMod] = []
## Learned from the start (the Fatia 2's three); the others once inscribed at the Forja (heroes.<id>.forge.inscribed,
## Fatia 3).
@export var learned := true
## Gifts (talent ids) and Encantos it never comes with (auditoria.md 3.1: Lâmina Tríplice is the Corte Crescente's
## substitute, Retorno do Corte none of the dash's chains).
@export var excludes: Array[StringName] = []
