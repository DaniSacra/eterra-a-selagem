class_name ComboNode
extends Resource
## One move of the combo tree. Combos are data: a new combo is a new node in data/combos, never new code.

## CHARGE: heavy held (an Omega special; the Warrior has none since 2026-11-21). CHARGE_LIGHT: light held (the Omega
## attack). SHOUT: the Brado de Guerra's button (Q). RUSH: the Investida's button (E). Both are moves of their own that
## any state may start (docs/design/heroes/guerreiro.md).
enum In { LIGHT, HEAVY, CHARGE, CHARGE_LIGHT, SHOUT, RUSH }
enum Shape { ARC, CIRCLE, LINE }
## BLAST, CONTAIN, DOME: the Maga's Explosão Rúnica, Círculo de Contenção and Suspensão Arcana (Arcane, maga.md 2).
enum Effect { NONE, LAUNCH, GROUND_MARK, WAVE, SHOUT, BLAST, CONTAIN, DOME }

@export var id: StringName
## The input that leads here from the previous node: E (light), D (heavy) or a released charge.
@export var input: In = In.LIGHT
## Text key of the move's name, shown when it lands and in the Golpes screen. Empty for a plain link of a chain.
@export var title: StringName
## Animation of the paladin's model, how fast it plays and where it starts (seconds into the clip).
@export var anim: StringName
@export var anim_speed := 1.0
@export var anim_from := 0.0
## The clip that brings the blade back to the guard when the move's own clip ends and he stands (E1c: the return is
## seen, never a cut to the guard). Walking cuts it. Empty: the move's clip already ends in the guard.
@export var recover_anim: StringName
## Which way the blade crosses in the animation, so the cut of light follows the arm: 0 alternates, 1 from the
## paladin's right to his left, 2 from his left to his right (tools/bake_hero.gd measures it).
@export_range(0, 2) var sweep := 0
## What gifts (dons) look at to modify this move: light, heavy, spin, wave, finisher...
@export var tags: Array[StringName] = []

@export_group("Hit")
@export var damage := 10.0
@export var shape: Shape = Shape.ARC
## How far the hit reaches from the paladin, in meters.
@export var reach := 3.0
## Arc: opening in degrees. Line: thickness in meters. Circle: unused.
@export var width := 140.0
## Push given to what it hits, in meters per second.
@export var knockback := 8.0
## Meters the paladin is carried forward during the windup. Only the dash attack (dash_cut, out of a dodge) has
## one: every other blow is struck standing still (E1c, Daniel: "tem que atacar parado").
@export var lunge := 0.0
## Line moves: also strike behind the paladin (the same length backwards).
@export var both_ways := false
## Share of walking speed kept while this move plays. Below 0: the default of data/feel.tres for its kind
## (light, heavy, finisher).
@export_range(-1.0, 1.0, 0.01) var move_scale := -1.0

@export_group("Timing")
## A blow has three phases (E1c, Daniel; numbers of Hades II's staff, docs/design/hades2_feel_study.md): the windup
## (the anticipation, plus the glint of a finisher; walking input ignored), the frame it lands, and the recovery (the
## blade coming back, the rest of the clip, then its last pose held). The paladin stands still from the press until
## move_hold after the blow; only the dodge cuts it. The combo slows as it goes: cut1 quick, cut2 a little slower, the
## spin the slowest and heaviest.
@export var windup := 0.07
## Seconds the move holds at the top of its swing, with a star of light on the blade, before it lands
## (the anticipation beat of a finisher). Scaled live by Feel.glint_scale.
@export var glint := 0.0
## Seconds after the blow lands before another blow may start (Hades II's attack lock: 8, 13, 18 frames for the
## staff's three); a press before that waits for it. The next blow of the combo starts here (the cadence).
@export var recovery := 0.17
## Seconds after the blow lands that his legs stay held (Hades II's SwingNDisableMoveHold: 11, 19, 30 frames; the
## special's 0.71 s), whatever the phase; only the dodge cuts it. Walking then cuts the rest of the clip. Below 0:
## until the recovery ends.
@export var move_hold := -1.0
## Seconds after the move ends in which the next input still continues the combo.
@export var chain_window := 0.35
## The hit stop when it lands, as in Hades II (HitStop, GF-01): the world keeps its full speed for hit_stop_ms after
## the blow (the wait, ScreenPreWait), then runs at hit_slow_scale of its speed for hit_slow_ms (Combat adds
## KILL_HOLD_MS when the blow kills), then comes back. Real milliseconds.
@export var hit_stop_ms := 40.0
@export var hit_slow_ms := 10.0
@export_range(0.0, 1.0, 0.01) var hit_slow_scale := 0.06
## Seconds after this move lands before it may start again (the special's 0.7 s of Hades II; 0 = none).
@export var cooldown := 0.0
## Played when the move starts (the blade leaving, before it lands: GF-11). Audio.SOUNDS or an audio/ file.
@export var sound: StringName = &"blade"
## C17, QW-103 (CF-03): seconds after the move starts (at its own pace: Ímpeto plays it sooner) when `sound` plays,
## so the swish peaks on the blade's frame (the spin's played 0.27 to 0.33 s before its blade); 0: as it starts. A
## move cut before then plays nothing.
@export var sound_at := 0.0
## Played as the move starts when `sound` waits (sound_at > 0): a short gathering, never the blade (&"": none).
@export var sound_press: StringName = &""
## CF-10: a second sound under the blade on the frame the blow lands (the body: a step, an effort), drawn from these,
## never the same twice running when there are more (Player._body_layer). Empty: none.
@export var layers: Array[StringName] = []
## Magia this move spends (the held Omega moves). A press without enough Magia plays the plain move instead.
@export var magick_cost := 0.0
## Held moves (CHARGE, CHARGE_LIGHT): seconds the button must be held. The move fires by itself when the charge
## fills; letting go earlier cancels it.
@export var charge_time := 0.45
@export var shake := 1.0

@export_group("Effect")
@export var effect: Effect = Effect.NONE
## LAUNCH: unused. GROUND_MARK: damage per second. WAVE: damage of the wave (a move with damage 0 strikes only
## with its wave, like the special's bolt). SHOUT (the Brado de Guerra): the charges of Ímpeto it gives (GiftState.rally).
@export var effect_power := 0.0
## LAUNCH: air time. GROUND_MARK: how long the mark lasts. WAVE: unused. SHOUT: seconds the cry's buff lasts (it
## stuns no one: it pushes); it draws a ring, not the blade's cut.
@export var effect_time := 0.0
## SHOUT: the buff's extra speed of every blow (0.2 = 20%) and the share of damage taken it takes off (0.15 = 15%).
@export var buff_speed := 0.0
@export var buff_guard := 0.0
## Blows the buff takes whole while it lasts (10A-2: the Brado takes one).
@export var buff_ward := 0
## Magia given back for each enemy this move reaches (the Investida's 3).
@export var magick_per_hit := 0.0
## GROUND_MARK: radius. WAVE: distance travelled.
@export var effect_radius := 0.0
## WAVE: width of the wave in meters (0 = the default 3.2).
@export var effect_size := 0.0
## WAVE: fly as a bolt of light (a bright streak with a trail) instead of a crescent.
@export var wave_bolt := false
## WAVE: metres a second (0: the look's own), stops at the first enemy it touches (the Maga's shots), its colour (alpha 0: the tags').
@export var wave_speed := 0.0
@export var wave_stops := false
@export var wave_color := Color(0, 0, 0, 0)

@export_group("Tree")
## The moves that may follow this one (ComboNode each; read them typed with following()). Kept as Resource: a typed
## array of its own class in its own script holds the script in a cycle, which leaked it at every exit.
@export var next: Array[Resource] = []


## The moves that may follow this one, typed.
func following() -> Array[ComboNode]:
	var out: Array[ComboNode] = []
	out.assign(next)
	return out


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func duration(glint_scale: float = 1.0) -> float:
	return windup + glint * glint_scale + recovery


## Seconds from the press to the frame the blow lands (the windup and the glint).
func lead(glint_scale: float = 1.0) -> float:
	return windup + glint * glint_scale


## The slowest and fastest the rest of the clip may play in the recovery (a share of its own speed).
const FOLLOW_MIN := 0.5
const FOLLOW_MAX := 1.0


## How fast (a share of the clip's own speed) the rest of the swing's clip plays after the blow, so the blade comes
## back over the whole leg hold instead of snapping back (E1c: cut1's return played 3.7 times too fast). tail:
## seconds of the clip left after the peak. A long tail plays at its own speed (walking cuts what is left once the
## legs are free); a short one is slowed down to FOLLOW_MIN and its last pose held.
func follow_speed(tail: float) -> float:
	var hold := legs_held()
	if hold <= 0.0:
		return FOLLOW_MAX
	return clampf(tail / hold, FOLLOW_MIN, FOLLOW_MAX)


## Seconds the legs stay held after the blow lands (move_hold, or the recovery when it sets none).
func legs_held() -> float:
	return move_hold if move_hold >= 0.0 else recovery


## The share of walking speed this move keeps, with Feel's default for its kind when it sets none.
func move_scale_with(feel: Feel) -> float:
	return move_scale if move_scale >= 0.0 else feel.move_scale_for(tags)


## The slash effect's flip for this move (Fx.slash sweeps from the right to the left unless flipped).
## alternate: the flip to use when the move does not say.
func sweep_flip(alternate: bool) -> bool:
	return alternate if sweep == 0 else sweep == 2
