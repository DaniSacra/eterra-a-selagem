class_name HeroDef
extends Resource
## A playable hero (DT-013): the numbers of the kit, the combo tree, the passive, the ultimates, the Gifts and the
## Mastery curve. The next hero is another HeroDef, never an if. The Warrior (docs/design/warrior_spec.md) is the
## only one: data/heroes/warrior.tres, written by _hero in tools/make_data.gd with the numbers of Hades II the paladin
## already had. The model keeps its technical name (hero_explorer).

const WARRIOR := "res://data/heroes/warrior.tres"

const MAGA := "res://data/heroes/maga.tres"

static var _warrior: HeroDef
static var _maga: HeroDef

@export var id: StringName = &"warrior"
@export var name_key: StringName
## The drawn body (HeroBody) and the combo tree (ComboTree).
@export var model: StringName = &"hero_explorer"
@export_file("*.tres") var combos := ""

@export_group("Body")
## Life, the stagger of a blow taken and the safety after it (Hades II: 30 life, 1.3 s; C1b: 0.7 s; the body's radius is
## Player.RADIUS).
@export var max_hp := 30.0
@export var hurt_time := 0.18
@export var hurt_invuln := 0.7
## Dodge charges and the seconds one takes to come back (the roll's speed, length and safety are Feel's).
@export var dodge_charges := 1
@export var dodge_recharge := 0.8

@export_group("Magia")
## Full at the start of every room; spent by the held Omegas (the attack's and the special's costs are in the combo).
@export var magick_max := 50.0

## C19-4 (Q-12, Hades II): walking while an Omega charges, times his speed. The attack's: 0.03 and the body turns at
## most charge_turn_light degrees a second (Swing5SelfSlowCharge 0.03, RotationMultiplier 1e-8); the special's: 0.6
## (an inference: the staff's special has no speed of its own while its Omega charges, the plain one's
## WeaponStaffBoltInstantStop is 0.6). The circle's is cast_slow.
@export var charge_move_light := 0.03
@export var charge_turn_light := 0.0
@export var charge_move_heavy := 0.6

@export_group("Circle of light")
## The circle is part of this hero's kit (the Warrior's is not since 2026-11-21: the Paladin's later). Without it the
## circle's button reads nothing and Psalms that need it are never offered.
@export var circle := true
## Seconds to draw it (walking slowed to cast_slow), the cooldown, the seconds no blow may start after it is let go;
## held cast_omega_time with cast_omega_cost of Magia it bursts. Radius, seconds on the floor, the burst's damage.
@export var cast_charge := 0.25
@export var cast_slow := 0.6
@export var cast_cooldown := 0.2
@export var cast_attack_lock := 8.0 / 60.0
@export var cast_omega_time := 0.6
@export var cast_omega_cost := 20.0
@export var cast_radius := 5.4
@export var cast_time := 3.0
@export var cast_burst := 150.0

@export_group("Passive")
## The centre of the tree (D-56, P-A): a finisher that lands on at least one enemy gives back this much Magia, once a
## blow, never past the maximum (GiftState.passive_magick; the Gift stat finisher_magick adds to it). A finisher here
## is a move with one of passive_tags (the spin, the Corte Veloz, the Omegas) and none of passive_never (the
## ultimate's blows never count).
@export var magick_on_finisher := 2.0
## C1c (docs/design/kit_c1c.md 1): the buttons feed each other. Magia for each Quebra the paladin causes (not the Brado's, not
## the ultimate's); the Brado's recharge loses cd_refund_hit s for each attack hit and cd_refund_break s for each Quebra, never
## below cd_floor s in all; gains of Magia by hit or Quebra are capped at gain_cap per gain_window s, and one wave refunds
## at most wave_refund_cap. See KitFeed.
@export var magick_on_break := 0.0
@export var cd_refund_hit := 0.0
@export var cd_refund_break := 0.0
@export var cd_floor := 0.0
@export var gain_cap := 3.0
@export var gain_window := 1.0
@export var wave_refund_cap := 8.0
@export var passive_tags: Array[StringName] = [&"finisher", &"dash", &"omega"]
@export var passive_never: Array[StringName] = [&"ultimate"]

@export_group("Arcane kit")
## The Maga's kit (null: not this hero's): see ArcaneKit and Arcane.
@export var arcane: ArcaneKit

@export_group("Progression")
@export var ultimates: Array[UltDef] = []
## The weapon the hero fights with (UltDef.weapon): the ultimate it plays is the one of that weapon.
@export var weapon: StringName = &""
@export_dir var talents_dir := ""
@export var mastery: MasteryCurve


## The Warrior, loaded once.
static func warrior() -> HeroDef:
	if _warrior == null:
		_warrior = load(WARRIOR)
	return _warrior


## The Maga (docs/design/heroes/maga.md), loaded once; played with --hero=maga until the selector of M1b.
static func maga() -> HeroDef:
	if _maga == null:
		_maga = load(MAGA)
	return _maga


func ultimate(ult_id: StringName) -> UltDef:
	for u in ultimates:
		if u.id == ult_id:
			return u
	return null


## The ultimate a descent plays at this Mastery level (T5): the one chosen when it is unlocked, else the first one the
## level unlocks (a player who reached Mastery 2 and never opened the hero screen still has one), else null.
func ult_for(chosen: StringName, level: int) -> UltDef:
	var u := ultimate(chosen)
	if u != null and u.mastery_level <= level:
		return u
	var first: UltDef = null
	for o in ultimates:
		if o.mastery_level <= level and (first == null or o.mastery_level < first.mastery_level):
			first = o
	return first


## The fixed ultimate of the hero's weapon (redesign A.3; reserve ones never), or null below its Mastery level.
func ult_for_weapon(level: int) -> UltDef:
	for u in ultimates:
		if u.weapon == weapon and not u.reserve and weapon != &"":
			return u if u.mastery_level <= level else null
	return null


## The lowest Mastery level that unlocks an ultimate (0: the hero has none).
func first_ult_level() -> int:
	var low := 0
	for u in ultimates:
		if low == 0 or u.mastery_level < low:
			low = u.mastery_level
	return low


func talents() -> Talents:
	return Talents.new(Talents.load_catalog(talents_dir))
