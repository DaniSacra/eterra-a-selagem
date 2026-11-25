class_name Encounters
extends RefCounted
## The meetings with the angels in one descent (Rejogabilidade, Fatia 1; sistemas.md 1.6 and 3.1): every room's
## Blessing and the guardian's come by two angels (Encounter.pair on the room's own dice); the one chosen offers up to
## three Blessings of its family (Encounter.cards on its own dice, with the stage's chances; the Psalm filled as
## before), and the usual choice screen (BoonChoice) shows them. One angel eligible: only it comes; none: the rest card
## (Fôlego). The robot and --autopick choose at once by affinity (Encounter.affinity); a person sees the meeting's
## screen first (EncounterScreen, attached by the Hud; AngelChoice is only the fallback when no screen listens to
## `opened`, as in bare tests). --angels=a,b forces the pair,
## --no-angels plays the draw of before (every family, no meeting).
##
## API for the UI (used by EncounterScreen):
##   game.encounters.angels_now -> Array[AngelDef]: the pair on show (empty when no meeting is open).
##   game.encounters.choose(angel) : takes that angel; its cards open on the choice screen (BoonChoice) right after.
##   game.encounters.cards_of(angel) -> Array[BoonState.Card]: the cards that angel would offer (the same ones choose
##     opens: its own dice), for a screen that previews them or goes back to the pair.
##   game.encounters.meetings -> Array[Dictionary]: one entry a meeting ({room, node, offered, chose, cards, fallback}),
##     the RESULT's angels (fallback "door": the one angel the door showed, Fatia 2).
##   game.encounters.door_angel(room) -> StringName: the angel a Blessing's door shows (Rooms sets RunMap.Room.angel
##     when the doors open; RunMap.Room.meeting: two angels meet him there instead).
##   signal opened(angels: Array[AngelDef]) when a meeting needs a choice (EncounterScreen listens; with no listener
##     the old AngelChoice opens).

signal opened(angels: Array)

var game: Game
var book: Encounter
var meetings: Array[Dictionary] = []
## The meeting open now: its angels, chances and the Psalm's chance.
var angels_now: Array[AngelDef] = []
var _chances: Array[float] = []
var _psalm := -1.0
var _entry: Dictionary = {}


func _init(g: Game) -> void:
	game = g
	book = Encounter.new(Encounter.load_catalog())


## True when the room's Blessings come by the angels (the descent by rooms, a catalog, not --no-angels).
func on() -> bool:
	return game.rooms != null and not book.catalog.is_empty() and not Dev.has("no-angels")


## A room's Blessing (Rooms._give with meeting): draws the pair and goes on to its cards (robot, --autopick, one
## angel) or opens the meeting's screen.
func open(chances: Array[float], psalm_chance: float) -> void:
	_chances = chances
	_psalm = psalm_chance
	var forced: Array = Array(Dev.arg("angels").split(",", false)) if Dev.has("angels") else []
	var room := game.rooms.room
	# Fatia 2: a door that showed one angel brings that one (if it still has a card for the hand: else a pair)
	var shown := book.find(room.angel) if room != null and not room.meeting and room.angel != &"" and forced.is_empty() else null
	if shown != null and Encounter.eligible(game.boons, shown):
		angels_now = [shown] as Array[AngelDef]
	else:
		angels_now = book.pair(game.boons, _dice(), forced)
	_entry = {"room": room.depth if room else 0, "node": room.id if room else -1,
		"offered": angels_now.map(func(a: AngelDef) -> String: return String(a.id)), "chose": "", "cards": [],
		"fallback": "door" if shown != null and angels_now.size() == 1 and angels_now[0] == shown else "" if angels_now.size() >= Encounter.SIZE \
			else ("single" if angels_now.size() == 1 else "none")}
	meetings.append(_entry)
	if angels_now.is_empty():
		game.open_cards([])  # nobody has a card for this hand: the rest card of today
		return
	# BC-4: a lone angel speaks first too, for a person (the robot and --autopick never wait)
	if game.bot != null or Dev.has("autopick"):
		choose(Encounter.affinity(game.boons, angels_now))
		return
	opened.emit(angels_now)
	if opened.get_connections().is_empty():
		var screen := AngelChoice.new()
		game.open_screen(screen)
		screen.open(angels_now)
		screen.chosen.connect(func(a: AngelDef) -> void:
			game.close_screen()
			choose(a))


## Dev (--encounter=a,b): opens a meeting with these angels (ids) at once, for captures.
func dev_open(ids: String) -> void:
	_chances = game.rooms.stage.rarity_chance
	_psalm = 0.0
	angels_now.clear()
	for id in ids.split(",", false):
		var a := book.find(StringName(id))
		if a != null:
			angels_now.append(a)
	_entry = {"room": 0, "node": -1, "offered": [], "chose": "", "cards": [], "fallback": ""}
	meetings.append(_entry)
	if angels_now.is_empty():
		return
	if Dev.has("encounter-pick"):
		# dev, for captures: straight to the first angel's cards (SW-B1)
		choose(angels_now[0])
		return
	opened.emit(angels_now)


## Fatia 2 (sistemas.md 1.6): the one angel a Blessing's door shows (no meeting), drawn when the door opens on dice of
## that room among the angels with a card for the hand; &"" when none has (the room falls back to the pair).
## PT-8: `taken` are the angels the doors beside it already show; it takes another when the pair has one.
func door_angel(r: RunMap.Room, taken: Array[StringName] = []) -> StringName:
	var rng := Encounter.dice(game.run_seed(), r.id, r.depth)
	var two := book.pair(game.boons, rng)
	for a in two:
		if not taken.has(a.id):
			return a.id
	return two[0].id if not two.is_empty() else &""


## Takes an angel of the pair: its cards on the choice screen.
func choose(angel: AngelDef) -> void:
	if angel == null or not angels_now.has(angel):
		return
	var cards := cards_of(angel)
	_entry["chose"] = String(angel.id)
	_entry["cards"] = cards.map(func(c: BoonState.Card) -> String:
		return String(c.psalm.id) if c.psalm != null else String(c.boon.id))
	angels_now = []
	game.choice_angel = angel
	game.open_cards(cards)


## The cards an angel of the meeting open now offers (the same each time it is asked: its own dice).
func cards_of(angel: AngelDef) -> Array[BoonState.Card]:
	var room := game.rooms.room
	var rng := Encounter.cards_dice(game.run_seed(), room.id if room else -1, room.depth if room else 0, angel.id)
	var stage := game.rooms.stage
	var cards := Encounter.cards(game.boons, angel, rng, 3, _chances, stage.elo_now(game.boons.owned().size()), stage.trade_chance)
	game.fill_psalm(cards, _psalm, rng)
	return cards


## Discernimento I: the angel's cards drawn again (another dice of the same room, so a reroll is its own draw).
func reroll_cards(angel: AngelDef) -> Array[BoonState.Card]:
	var room := game.rooms.room
	var rng := Encounter.cards_dice(game.run_seed(), (room.id if room else -1) + 7919, room.depth if room else 0, angel.id)
	var stage := game.rooms.stage
	var cards := Encounter.cards(game.boons, angel, rng, 3, _chances, stage.elo_now(game.boons.owned().size()), stage.trade_chance)
	game.fill_psalm(cards, _psalm, rng)
	return cards


## The dice of the room's pair.
func _dice() -> RandomNumberGenerator:
	var room := game.rooms.room
	return Encounter.dice(game.run_seed(), room.id if room else -1, room.depth if room else 0)
