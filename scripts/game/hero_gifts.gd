class_name HeroGifts
extends RefCounted
## The hero's passive and Gifts at play (E2-07, E2-09; docs/design/warrior_spec.md 3.1 and 4): the fight's events go
## to the rules (GiftState, pure) and what they answer is done here: Magia back, the dodge back, the chain going on,
## the glint held, the fury's speed and embers, the heal of a room won. Game makes one, equips it with the Gifts of
## the descent and steps it. The passive is the centre of the tree: always on, Gift or not.

var game: Game
var state: GiftState


func _init(g: Game) -> void:
	game = g
	equip()
	game.combat.landed.connect(_on_landed)
	game.combat.swung.connect(_on_swung)
	game.horde.killed.connect(_on_killed)


## (Re)reads the Gifts equipped (BoonState.talents): a fresh state for the descent and the combo tree of a Gift that
## changes the attack (TalentDef.combos; none: the hero's own).
func equip() -> void:
	state = GiftState.new(game.hero, game.boons)
	state.passive = not Dev.has("no-passive")
	game.combat.gifts = state
	game.player.gifts = state
	var tree := game.hero.combos
	for t in game.boons.talents:
		if t.combos != "":
			tree = t.combos
	if game.player.tree.resource_path != tree:
		game.player.use_tree(tree)


func step(dt: float) -> void:
	state.step(dt)
	var p := game.player
	p.runner.speed = state.attack_speed()
	p.omega_discount = state.omega_discount()
	p.show_fury(state.fury)


## A blow landed (Combat.landed): the passive's Magia, Lâmina Faminta's window (the finisher's glint held on the tip
## as long).
func _on_landed(node: ComboNode, tags: Array[StringName], hits: int) -> void:
	var p := game.player
	var magick := state.passive_magick(tags, hits)
	if magick > 0.0:
		p.magick.gain(magick)
	if state.on_landed(tags, hits) and node != null:
		game.combat.glint(node, p.pos, p.facing, state.hungry_left, p.blade_tip)


## Every blow of the combo, landing or not (Combat.swung; struck: how many it reached): the chain of Passo Encadeado
## (the Corte Veloz, landing or not) and Golpe sem Fim (the spin on 3 or more).
func _on_swung(node: ComboNode, struck: int) -> void:
	if state.chains_on(node.tags, struck):
		game.player.runner.chain_from(game.player.runner.opener())


var _dash_back_blow := 0


## Someone fell (Horde.killed; Combat.kill_tags says what felled it, empty for a burn): Ímpeto's charges, the dodge
## back once a blow (Avanço Feroz, Investida).
func _on_killed(_e: Enemy) -> void:
	var tags := game.combat.kill_tags
	state.on_kill(tags)
	var blow := game.combat.kill_blow
	if state.dash_back(tags) and (blow == 0 or blow != _dash_back_blow):
		_dash_back_blow = blow
		game.player.give_dodge_back()


## A room was won (Respiro).
func room_won() -> void:
	game.player.heal(state.room_heal())
