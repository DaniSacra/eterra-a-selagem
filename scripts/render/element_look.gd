class_name ElementLook
extends RefCounted
## The three element colors of the elemental Maga (AD-01 / TA-09). Light colors (may pass 1, below the glow threshold
## 1.3). Each is told apart from the hazard red, the hero teal, the Supremo ring and the old hazard amber by the
## minimum distance asserted in tests/test_element_look.gd. No violet (Morvath, curse) and no emerald (Emeth).

const FIRE := Color(1.0, 0.42, 0.0)
const COLD := Color(0.35, 0.88, 1.0)
const VOLT := Color(1.0, 0.97, 0.78)

## Smallest RGB distance each element keeps from every reserved color.
const MIN_DISTANCE := 0.25


static func all() -> Array[Color]:
	return [FIRE, COLD, VOLT]
