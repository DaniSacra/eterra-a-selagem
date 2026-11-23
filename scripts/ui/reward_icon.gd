class_name RewardIcon
extends RefCounted
## PT-2: the one place that gives the picture of a door's medallion. One 512x512 transparent PNG per reward, per kind
## of room that gives none and per angel, at assets/ui/rewards/<id>.png; the painted ones are used when the file exists,
## and when it does not the medallion keeps today's picture (RewardGem.painting, then the mark struck on the enamel).
## Ids: reward ids are the lowercase names of RunMap.Reward, room ids those of RunMap.Kind, angel ids "angel_" and the
## lowercase name of the Boon.Family (chama, geada, luz, vigilia, veu, mare, marca).

const DIR := "res://assets/ui/rewards/"
const REWARD_IDS := {
	RunMap.Reward.BOON: &"boon", RunMap.Reward.POM: &"pom", RunMap.Reward.POM_SLICE: &"pom_slice",
	RunMap.Reward.HEART: &"heart", RunMap.Reward.MAGICK: &"magick", RunMap.Reward.GOLD: &"gold",
	RunMap.Reward.HEAL: &"heal", RunMap.Reward.SILVER: &"silver", RunMap.Reward.MEMORY: &"memory",
	RunMap.Reward.ENCHANT: &"enchant", RunMap.Reward.PSALM: &"psalm",
}
const KIND_IDS := {
	RunMap.Kind.COMBAT: &"combat", RunMap.Kind.MINIBOSS: &"miniboss", RunMap.Kind.FOUNTAIN: &"fountain",
	RunMap.Kind.SHOP: &"shop", RunMap.Kind.BOSS: &"boss", RunMap.Kind.TRIAL: &"trial", RunMap.Kind.ALTAR: &"altar",
}
const ANGELS: Array[StringName] = [&"chama", &"geada", &"luz", &"vigilia", &"veu", &"mare", &"marca"]

static var _cache := {}


## The id of what a door gives: the reward's, or the room kind's when it gives none.
static func id_of(reward: RunMap.Reward, kind: RunMap.Kind) -> StringName:
	if reward != RunMap.Reward.NONE:
		return REWARD_IDS.get(reward, &"")
	return KIND_IDS.get(kind, &"")


## Every id the art is expected to have (the request to the artist lists these).
static func all_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for v: StringName in REWARD_IDS.values():
		out.append(v)
	for v: StringName in KIND_IDS.values():
		out.append(v)
	for a in ANGELS:
		out.append(StringName("angel_" + String(a)))
	return out


static func path(id: StringName) -> String:
	return DIR + String(id) + ".png"


## The painted icon of an id, or null when its file is not there (the caller falls back to today's picture).
static func texture(id: StringName) -> Texture2D:
	if id == &"":
		return null
	var p := path(id)
	if not _cache.has(p):
		_cache[p] = load(p) if ResourceLoader.exists(p) else null
	return _cache[p]


## The painted icon of a reward or room kind, or null.
static func of(reward: RunMap.Reward, kind: RunMap.Kind) -> Texture2D:
	return texture(id_of(reward, kind))


## The painted icon of an angel, by its family's name (see ANGELS), or null.
static func of_angel(family: StringName) -> Texture2D:
	return texture(StringName("angel_" + String(family)))
