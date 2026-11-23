class_name HeroGifts
extends RefCounted
## The hero's passive and Gifts at play (E2-07, E2-09; docs/design/warrior_spec.md 3.1 and 4): the fight's events go
## to the rules (GiftState, pure) and what they answer is done here: Magia back, the dodge back, the chain going on,
## the glint held, the fury's speed and embers, the heal of a room won. Game makes one, equips it with the Gifts of
## the descent and steps it. The passive is the centre of the tree: always on, Gift or not.

var game: Game
var state: GiftState
## C1c: the buttons feed each other (Magia by hit and Quebra, the Brado's recharge).
var feed: KitFeed


func _init(g: Game) -> void:
	game = g
	feed = KitFeed.new(game.hero)
	equip()
	game.combat.landed.connect(_on_landed)
	game.combat.swung.connect(_on_swung)
	game.horde.killed.connect(_on_killed)
	game.horde.poise_broken.connect(_on_broke)


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
	feed.step(dt)
	var p := game.player
	var tags: Array[StringName] = []
	if p.runner.node != null:
		tags = p.runner.node.tags
	p.runner.speed = state.attack_speed(tags)
	p.runner.cooldown_cut = state.cooldown_cut(tags)
	p.omega_discount = state.omega_discount()
	p.show_fury(state.fury)


## A blow landed (Combat.landed): the passive's Magia, Lâmina Faminta's window (the finisher's glint held on the tip
## as long).
func _on_landed(node: ComboNode, tags: Array[StringName], hits: int) -> void:
	var p := game.player
	var magick := state.passive_magick(tags, hits)
	var attack := node != null and DealtBy.source(tags) == &"attack"
	if attack:
		magick += feed.hit_magick(node.magick_per_hit)  # C1c: once a swing, not for each enemy
		feed.tally.refund_s += p.refund_shout(game.hero.cd_refund_hit)
	elif node != null and node.magick_per_hit > 0.0:
		magick += node.magick_per_hit * hits  # the Investida: Magia for each one it reaches
	if magick > 0.0:
		p.magick.gain(magick)
	if state.on_landed(tags, hits) and node != null:
		game.combat.glint(node, p.pos, p.facing, state.hungry_left, p.blade_tip)


## Every blow of the combo, landing or not (Combat.swung; struck: how many it reached): the chain of Passo Encadeado
## (the Corte Veloz, landing or not) and Golpe sem Fim (the spin on 3 or more).
func _on_swung(node: ComboNode, struck: int) -> void:
	if node.has_tag(&"wave"):
		feed.wave_thrown()
	elif node.has_tag(&"shout"):
		feed.tally.shouts += 1
	if state.chains_on(node.tags, struck):
		game.player.runner.chain_from(game.player.runner.opener())


## A Quebra (Horde.poise_broken): Magia, and the Brado back sooner (C1c).
func _on_broke(_e: Enemy, source: StringName) -> void:
	game.player.magick.gain(feed.break_magick(source))
	feed.tally.refund_s += game.player.refund_shout(feed.break_refund(source))


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
