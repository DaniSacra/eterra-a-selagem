class_name HeroGifts
extends RefCounted
## The hero's passive and Gifts at play (E2-07, E2-09; docs/design/warrior_spec.md 3.1 and 4): the fight's events go
## to the rules (GiftState, pure) and what they answer is done here: Magia back, the dodge back, the chain going on,
## the cadence of the sequence, Apogeu's books, the heal of a room won. Game makes one, equips it with the Gifts of
## the descent and steps it. The passive is the centre of the tree: always on, Gift or not.

var game: Game
var state: GiftState
## C1c: the buttons feed each other (Magia by hit and Quebra, the Brado's recharge).
var feed: KitFeed
const DASH_TAGS: Array[StringName] = [&"dash"]


func _init(g: Game) -> void:
	game = g
	feed = KitFeed.new(game.hero)
	equip()
	game.combat.landed.connect(_on_landed)
	game.combat.swung.connect(_on_swung)
	game.horde.killed.connect(_on_killed)
	game.horde.poise_broken.connect(_on_broke)
	var runner := game.player.runner
	runner.move_started.connect(_on_move_started)
	runner.move_hit.connect(_on_move_hit)
	runner.chain_lost.connect(_on_chain_lost)


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
	p.runner.speed = state.attack_speed(tags) + game.combat.celestial.attack_speed(tags)
	p.runner.cooldown_cut = minf(state.cooldown_cut(tags) + game.combat.celestial.cooldown_cut(tags), 0.5)
	p.omega_cost_pct = state.value(&"omega_cost_pct")
	p.charge_time_pct = state.value(&"charge_time_pct")
	p.dash_pierce = state.value(&"dash_pierce", DASH_TAGS) > 0.0
	p.runner.dodge_keep = state.value(&"dodge_window_add")
	game.combat.apogee.step(dt)


## A blow landed (Combat.landed): the passive's Magia, Lâmina Faminta's window (the finisher's glint held on the tip
## as long).
func _on_landed(node: ComboNode, tags: Array[StringName], hits: int) -> void:
	var p := game.player
	var magick := state.passive_magick(tags, hits)
	var attack := node != null and DealtBy.source(tags) == &"attack"
	if attack:
		# C1c: once a swing, not for each enemy; Determinação: attack_magick_pct more of it
		magick += feed.hit_magick(node.magick_per_hit * (1.0 + state.value(&"attack_magick_pct")))
		feed.tally.refund_s += p.refund_shout(game.hero.cd_refund_hit)
	elif node != null and node.magick_per_hit > 0.0:
		magick += node.magick_per_hit * hits  # the Investida: Magia for each one it reaches
	if magick > 0.0:
		p.magick.gain(magick)


## Every blow of the combo, landing or not (Combat.swung; struck: how many it reached).
func _on_swung(node: ComboNode, _struck: int) -> void:
	if node.has_tag(&"wave"):
		feed.wave_thrown()
	elif node.has_tag(&"shout"):
		feed.tally.shouts += 1


## The sequence starts over at its opener: Cadência and Apogeu's books begin again.
func _on_move_started(node: ComboNode) -> void:
	var opener := game.player.runner.opener()
	if opener != null and node.id == opener.id:
		_on_chain_lost()


## A blow of the sequence landed (the runner's strike, hit or not): Cadência counts it.
func _on_move_hit(node: ComboNode) -> void:
	state.chain_hit(node.tags)


## The sequence is over or was lost (window ran out, a blow taken, a dodge past Disciplina's keeping).
func _on_chain_lost() -> void:
	state.chain_reset()
	game.combat.apogee.clear()


## A Quebra (Horde.poise_broken): Magia, and the Brado back sooner (C1c).
func _on_broke(_e: Enemy, source: StringName) -> void:
	game.player.magick.gain(feed.break_magick(source))
	feed.tally.refund_s += game.player.refund_shout(feed.break_refund(source))


## Someone fell (Horde.killed): Apogeu's books on him are closed.
func _on_killed(e: Enemy) -> void:
	game.combat.apogee.reset(e.get_instance_id())


## A room was won (Respiro).
func room_won() -> void:
	game.player.heal(state.room_heal())
