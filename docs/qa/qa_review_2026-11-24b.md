# QA review 2026-11-24b (build 1342184)
Headless only, no GPU, no full suite. Smokes: warrior s7, s9; maga s8 (600 s); boss start; shop start. No SCRIPT ERROR/WARNING/ERROR in any; stuck=0 in all. step_ms_avg 0.23-0.43, peak 7-16 ms.

## Confirmed
- P2 (dev only) `--hero-hp=N` is overridden: game.gd ~1162 (boon refresh) sets `player.max_hp = hero.max_hp + hp_bonus + life_bonus` and heals, and `_apply_talents` (~1998) does the same. After the first Dom the dev value is gone. Repro: `tools/smoke.sh 60 --seed=5 --hero-hp=1` -> final hp 4, mode PLAY. This explains the VICTORY screen in the GPU capture (the bot survived with normal life). Not a player bug; fix by keeping a dev override (e.g. add Dev hero-hp as base in both places) or document that --hero-hp must be used with --boons=0/--autopick off.

## Hypothesis (not investigated)
- P2 `tools/smoke.sh 120 --start=shop --seed=5` ends `mode OVER hp 0` (bot died in 120 s starting at the shop). Could be the bot leaving the shop into a fight with starting life, or shop start skipping the heal; check whether it is expected. Suspect: scripts/game/game.gd start=shop path.
- P2 warrior s7 died in room 10 (of 14), s9/maga s8 reached the guardian alive: consistent with earlier report (warrior harder), nothing new.
- Maga `--stress=300` run was still running when this report was written (not measured here).
