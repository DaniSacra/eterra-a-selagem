class_name HeroDef
extends Resource
## A playable hero (DT-013): the numbers of the kit, the combo tree, the passive, the ultimates, the Gifts and the
## Mastery curve. The next hero is another HeroDef, never an if. The Warrior (docs/design/warrior_spec.md) is the
## only one: data/heroes/warrior.tres, written by _hero in tools/make_data.gd with the numbers of Hades II the paladin
## already had. The model keeps its technical name (hero_explorer).

const WARRIOR := "res://data/heroes/warrior.tres"

static var _warrior: HeroDef

@export var id: StringName = &"warrior"
@export var name_key: StringName
## The drawn body (HeroBody) and the combo tree (ComboTree).
@export var model: StringName = &"hero_explorer"
@export_file("*.tres") var combos := ""

@export_group("Body")
## Life, the stagger of a blow taken and the safety after it (Hades II: 30 life, 1.3 s; the body's radius is
## Player.RADIUS).
@export var max_hp := 30.0
@export var hurt_time := 0.18
@export var hurt_invuln := 1.3
## A blow's lunge toward the enemy ahead stops when he stands this share of the blow's reach from its edge
## (Player._gap_ahead; the Warrior's identity, warrior_spec 2 and 10.1: the lunge visibly carries him to the enemy).
@export var lunge_standoff := 0.3
## Dodge charges and the seconds one takes to come back (the roll's speed, length and safety are Feel's).
@export var dodge_charges := 1
@export var dodge_recharge := 0.74

@export_group("Magia")
## Full at the start of every room; spent by the held Omegas (the attack's and the special's costs are in the combo).
@export var magick_max := 50.0

@export_group("Circle of light")
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
## The centre of the tree (D-56): a finisher that lands gives back this much Magia, once a blow (no behaviour yet).
@export var magick_on_finisher := 2.0

@export_group("Progression")
@export var ultimates: Array[UltDef] = []
@export_dir var talents_dir := ""
@export var mastery: MasteryCurve


## The Warrior, loaded once.
static func warrior() -> HeroDef:
	if _warrior == null:
		_warrior = load(WARRIOR)
	return _warrior


func ultimate(ult_id: StringName) -> UltDef:
	for u in ultimates:
		if u.id == ult_id:
			return u
	return null


func talents() -> Talents:
	return Talents.new(Talents.load_catalog(talents_dir))
