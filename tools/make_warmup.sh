#!/bin/bash
# Builds the warm-up set (assets/warmup/warmup_set.res, P1-1 / DT-RS3) from scratch: every arena and variant, the
# event rooms, Morvath's phases, the hub, the title, the elites, the gift families, the ultimates and the psalms, in
# both looks and both renderers, each run headless adding what it saw (tools/make_warmup.gd). About 10 minutes.
# Run it again after adding a shader or a look (tests/test_warmup.gd fails when a shader file is missing from the set).
#   tools/make_warmup.sh
cd "$(dirname "$0")/.." || exit 1
G=${GODOT:-$HOME/tools/godot/godot}
RUNS=(
	"--title"
	"--hub"
	"--bot --start=ante" "--bot --start=sala00" "--bot --painted" "--bot --start=ante --painted" "--bot --start=sala00 --painted"
	"--bot --arena=hall"
	"--bot --start=shop" "--bot --start=fountain" "--bot --start=trial" "--bot --start=altar" "--bot --start=miniboss"
	"--bot --start=boss" "--bot --start=boss --boss-hp=0.66" "--bot --start=boss --boss-hp=0.3" "--bot --start=boss --boss-hp=0.14"
	"--bot --stress=10 --stress-ids=skeleton_elite,runner_elite,mage_elite,archer_elite,guard_elite,priest_elite,knight,priest_elder"
	"--bot --stress=10 --stress-ids=skeleton,runner,mage,archer,guard,priest"
	"--bot --stress=8 --stress-ids=skeleton,guard,skeleton"  # (the painted sword cards and contact sparks, painted_fx.gdshader)
	"--bot --hero=maga --stress=6"  # (the Maga's own spell cards, maga_spell.gdshader)
	"--bot --stress=10 --stress-ids=trinca,varredor,gritador,coveiro,saltador,lancador,canalizador,armadilheiro,skeleton_big,runner_big,skeleton_raised"
	"--bot --stress=6 --boon-ids=golpe_peste,pesado_peste,circulo_peste,passo_peste,epidemia_celestial"
	"--bot --stress=6 --boon-ids=golpe_trovao,pesado_trovao,circulo_trovao,passo_trovao,descarga"
	"--bot --stress=6 --boon-ids=golpe_brasa,pesado_brasa,circulo_brasa,passo_brasa"
	"--bot --stress=6 --boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada"
	"--bot --stress=6 --boon-ids=golpe_radiante,pesado_radiante,circulo_radiante,passo_radiante"
	"--bot --stress=6 --boon-ids=golpe_firme,pesado_firme,circulo_firme,vigia_firme"
	"--bot --stress=6 --ultimate=cleave --ult-full" "--bot --stress=6 --ultimate=vortex --ult-full"
	"--bot --stress=6 --psalm=sentinela,pastor" "--bot --stress=6 --psalm=abrigo,rocha"
)
for arena in crypt rift garden sanctuary bridge runes; do
	for v in 0 1; do RUNS+=("--bot --arena=$arena --variant=$v"); done
done
first=--fresh
for method in forward_plus gl_compatibility; do
	for look in classic stylized; do
		for run in "${RUNS[@]}"; do
			# shellcheck disable=SC2086
			timeout 300 "$G" --headless --path . --rendering-method $method --fixed-fps 30 -s tools/make_warmup.gd -- \
				--nosave --fast=3 --seed=5 --look=$look --harvest-at=300 $run $first 2>&1 | grep -E "^WARMUP|SCRIPT ERROR"
			first=""
		done
	done
done
