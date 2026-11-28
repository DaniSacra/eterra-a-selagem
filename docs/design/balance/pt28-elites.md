# PT-28-7: elites back to a sane time-to-kill (2026-11-27)

Reason: PT-27b raised the hero's blows to x2.25 (45/45/90) and the elites to x1.8 of the SWORN Major. Daniel, room 12: the
elite skeleton mage "nao morria" (1300 x 1.8 = 2340 life, 52 light blows, and it kites).

Numbers (`tools/make_data.gd`, `_hp_scale`):

| Enemy | Before | Now | Hits of 45 | Ideal time at about 105 dps |
|---|---|---|---|---|
| skeleton_elite, varredor_elite | 2700 | 1500 | 33 | 14 s |
| runner_elite, guard_elite | 2430 | 1350 | 30 | 13 s |
| mage_elite | 2340 | 910 (1300 x 0.7) | 20 | 9 s, 12 to 18 s with the kiting |
| archer_elite | 2250 | 875 (1250 x 0.7) | 19 | 8 s, 12 to 18 s with the kiting |
| priest_elite | 2340 | 910 | 20 | 9 s |
| capitao | 2700 | 1800 (1500 x 1.2) | 40 | 17 s |

Constants: `ELITE_HP_X` 1.0, `ELITE_RANGED_HP_X` 0.7, `CAPTAIN_HP_X` 1.2. Commons, bigger ones (x1.5), guardians (x1.5) and
Morvath (x2.4) untouched. The knob is those three constants; regenerate with `make_data.gd -- enemies`.
