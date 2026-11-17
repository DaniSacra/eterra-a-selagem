#!/bin/bash
# T5: the recorded sound effects that replace the synthesised recipes of scripts/audio.gd (the PO: "parecem de
# fliperama"). Every file is built here from CC0 and CC-BY recordings, layered offline (movement of the weapon,
# contact, impact, magic: one file per moment, so nothing stacks at run time) and leveled to a set peak. Origins,
# authors and licences in audio/LICENSES.md and docs/design/t5_audio.md; the CC-BY ones are in the game's credits.
#   tools/make_sfx.sh <folder with the packs unpacked>
# The folder holds, each unpacked from its OpenGameArt zip (untrusted data; nothing in it is run):
#   R = x_80-CC0-RPG-SFX_0           "80 CC0 RPG SFX", rubberduck, CC0 (https://opengameart.org/content/80-cc0-rpg-sfx)
#   B = x_sfx_breaking_and_falling   "75 CC0 breaking/falling/hit sfx", rubberduck, CC0
#                                    (https://opengameart.org/content/75-cc0-breaking-falling-hit-sfx)
#   H = x_100-CC0-SFX_0              "100 CC0 SFX", rubberduck, CC0 (https://opengameart.org/content/100-cc0-sfx)
#   K = x_RPGsounds_Kenney/OGG       "RPG Audio", Kenney, CC0 (https://opengameart.org/content/50-rpg-sound-effects)
#   L = x_Fantasy_Sound_Library/Fantasy Sound Library/Wav
#                                    "Fantasy Sound Effects Library", Little Robot Sound Factory, CC BY 3.0
#                                    (https://opengameart.org/content/fantasy-sound-effects-library)
#   O = the project's own CC0 files as they were before T5 (qubodup's swishes, Kenney's Impact Sounds), read from git
# A spec is "source|gain dB|rate|delay s|filters|start s|length s": rate 0.7 plays it 0.7 times as fast (lower and
# longer), filters an ffmpeg chain or "-", start and length cut the source ("-" for all of it).
set -euo pipefail
SRC="${1:?folder with the unpacked packs}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/audio"
WORK="${TMPDIR:-/tmp}/eterra_sfx"
mkdir -p "$WORK/orig"
R="$SRC/x_80-CC0-RPG-SFX_0"
B="$SRC/x_sfx_breaking_and_falling"
H="$SRC/x_100-CC0-SFX_0"
K="$SRC/x_RPGsounds_Kenney/OGG"
L="$SRC/x_Fantasy_Sound_Library/Fantasy Sound Library/Wav"
O="$WORK/orig"
# the files of before T5 (commit 5dfe97f), so a second run builds from the same sources
for f in hit_0 hit_1 hit_2 hit_3 hit_4 hit_heavy_0 hit_heavy_1 hit_heavy_2 hit_heavy_3 hit_heavy_4 blade_0 blade_1 blade_2 \
		blade_3 blade_4 blade_spin_0 blade_spin_1 blade_spin_2 thrust_0 thrust_1 thrust_2 dart_0 dart_1 dart_2 bone_0 bone_1 \
		bone_2 bone_3 bone_4; do
	git -C "$ROOT" show "5dfe97f:audio/$f.ogg" > "$O/$f.ogg"
done

# mk <name> <length s> <peak dBFS> <spec>...: audio/<name>.ogg, mono, the sources mixed, cut to the length with a
# short fade, then brought to the peak
mk() {
	local name="$1" len="$2" peak="$3"
	shift 3
	local args=() chain="" i=0 mixin=""
	for spec in "$@"; do
		IFS='|' read -r file gain rate delay filt start dur <<< "$spec"
		args+=(-i "$file")
		local f="[$i]aformat=channel_layouts=mono,aresample=44100"
		[ "${start:--}" != "-" ] && f+=",atrim=start=$start"
		[ "${dur:--}" != "-" ] && f+=",atrim=duration=$dur,afade=t=out:st=$(printf "%.3f" "$(echo "$dur - 0.04" | bc -l)"):d=0.04"
		f+=",asetpts=PTS-STARTPTS"
		[ "$rate" != "1" ] && f+=",asetrate=44100*$rate,aresample=44100"
		[ "${filt:--}" != "-" ] && f+=",$filt"
		f+=",volume=${gain}dB"
		[ "$delay" != "0" ] && f+=",adelay=$(echo "$delay * 1000" | bc -l | cut -d. -f1):all=1"
		chain+="$f[s$i];"
		mixin+="[s$i]"
		i=$((i + 1))
	done
	chain+="${mixin}amix=inputs=$i:normalize=0:duration=longest,highpass=f=35,atrim=end=$len,afade=t=out:st=$(printf "%.3f" "$(echo "$len - 0.06" | bc -l)"):d=0.06[o]"
	ffmpeg -v error -y "${args[@]}" -filter_complex "$chain" -map "[o]" -c:a pcm_s16le "$WORK/$name.wav"
	local now
	now=$(ffmpeg -nostats -i "$WORK/$name.wav" -af volumedetect -f null - 2>&1 | awk '/max_volume/{print $5}')
	ffmpeg -v error -y -i "$WORK/$name.wav" -af "volume=$(echo "$peak - ($now)" | bc -l)dB" -c:a libvorbis -q:a 5 "$OUT/$name.ogg"
	echo "$name"
}

# ------------------------------------------------------------------ the Guerreiro
# cut1 is O's swishes as before (blade_*), light; cut2 the same air lower and with the body behind it
mk blade_heavy_0 0.42 -9 "$O/blade_1.ogg|0|0.85|0|-" "$K/cloth1.ogg|-9|1|0|lowpass=f=3000"
mk blade_heavy_1 0.42 -9 "$O/blade_2.ogg|0|0.85|0|-" "$K/cloth2.ogg|-6|1|0|lowpass=f=3000"
mk blade_heavy_2 0.42 -9 "$O/blade_4.ogg|0|0.82|0|-" "$K/cloth3.ogg|-6|1|0|lowpass=f=3000"
# the special (D): the blade's air with the Emeth's green energy on it, a low push under
for n in 0 1 2; do
	mk dart_$n 0.62 -6 "$O/dart_$n.ogg|0|0.9|0|-" "$R/spell_02.ogg|-5|0.75|0.02|lowpass=f=5000" \
		"$L/Spell_02.wav|-12|1.$((n * 3))|0|lowpass=f=900|0|0.55"
done
# the Omega special: the spin's air, a wide surge of magic and a deep push
for n in 0 1 2; do
	mk wave_omega_$n 0.95 -4 "$O/blade_spin_$n.ogg|0|0.8|0|-" "$R/spell_01.ogg|-3|0.8|0.03|lowpass=f=6000" \
		"$L/Spell_04.wav|-8|1|0|lowpass=f=1200|0|0.9"
done
# contact: the original thud of the blow with the edge going in (a slice) on top
for n in 0 1 2 3 4; do
	s=$([ $((n % 2)) -eq 0 ] && echo knifeSlice || echo knifeSlice2)
	mk hit_$n 0.45 -2.5 "$O/hit_$n.ogg|0|1|0|-" "$K/$s.ogg|-11|0.9|0|lowpass=f=6000|0|0.3"
done
# a heavy blow (finisher, Omega): the thud, a low body impact and the slice
heavy=(bfh1_hit_02 bfh1_hit_07 bfh1_hit_06 bfh1_hit_08 bfh1_hit_07)
for n in 0 1 2 3 4; do
	mk hit_heavy_$n 0.7 -1 "$O/hit_heavy_$n.ogg|0|1|0|-" "$B/${heavy[$n]}.ogg|-5|0.85|0|lowpass=f=3000" \
		"$K/knifeSlice2.ogg|-12|0.8|0|lowpass=f=5000|0|0.3"
done
# the dodge: cloth and a low rush of air
mk dodge_0 0.4 -10 "$K/cloth1.ogg|0|1.1|0|-" "$O/blade_0.ogg|-6|0.65|0|lowpass=f=2500"
mk dodge_1 0.4 -10 "$K/cloth2.ogg|0|1.1|0|-" "$O/blade_3.ogg|-6|0.65|0|lowpass=f=2500"
mk dodge_2 0.4 -10 "$K/cloth3.ogg|0|1.1|0|-" "$O/blade_1.ogg|-6|0.65|0|lowpass=f=2500"
# struck: a blow on the body, leather and a rattle of mail
mk hurt_0 0.5 -4 "$B/bfh1_hit_08.ogg|0|0.9|0|-" "$K/dropLeather.ogg|-6|0.9|0|-" "$R/metal_01.ogg|-16|1|0|lowpass=f=5000"
mk hurt_1 0.5 -4 "$B/bfh1_hit_06.ogg|0|0.9|0|-" "$K/dropLeather.ogg|-6|1|0|-" "$R/metal_03.ogg|-18|1|0|lowpass=f=5000"
mk hurt_2 0.5 -4 "$B/bfh1_hit_03.ogg|0|0.8|0|-" "$K/cloth1.ogg|-6|1|0|-" "$R/metal_02.ogg|-18|1|0|lowpass=f=5000"
# the Omega charging (a held breath of the Emeth) and ready (a low bell)
mk charge_up 0.7 -12 "$L/Spell_00.wav|0|0.8|0|lowpass=f=5000,afade=t=in:d=0.3|0|0.8"
mk charged 0.9 -10 "$H/bell_01.ogg|0|0.5|0|lowpass=f=3500" "$R/spell_01.ogg|-10|0.9|0|lowpass=f=5000"
# the circle of light, its held version and its burst
mk circle 0.6 -9 "$L/Spell_01.wav|0|0.85|0|lowpass=f=5500|0|0.7"
mk circle_omega 0.9 -8 "$L/Spell_00.wav|0|0.9|0|lowpass=f=5500|0|1.0" "$R/spell_01.ogg|-6|0.8|0.05|lowpass=f=5000"
mk circle_burst 0.75 -4 "$B/bfh1_rock_breaking_02.ogg|0|0.9|0|-" "$R/spell_02.ogg|-6|0.7|0|lowpass=f=5000" \
	"$L/Spell_04.wav|-8|1|0|lowpass=f=1000|0|0.7"
# the ultimate: the gesture gathering, the cleave splitting the floor, the Voragem turning and imploding
mk ult_gesture 0.45 -8 "$R/spell_01.ogg|0|0.7|0|lowpass=f=5000,afade=t=in:d=0.15" "$K/cloth4.ogg|0|0.9|0|-"
mk ult_cleave 1.1 -2 "$B/bfh1_rock_breaking_01.ogg|0|0.85|0|-" "$L/Spell_02.wav|-5|1|0|lowpass=f=1500|0|1.0" \
	"$O/blade_spin_0.ogg|-3|0.7|0|-"
mk vortex 1.1 -8 "$L/Spell_03.wav|0|0.9|0|lowpass=f=4000,afade=t=in:d=0.3|0|1.2" "$O/blade_spin_1.ogg|-4|0.5|0.1|lowpass=f=2500"
mk ult_implode 0.9 -3 "$L/Spell_04.wav|0|1.1|0|lowpass=f=2500|0|0.9" "$B/bfh1_rock_falling_01.ogg|-4|0.9|0.05|-"

# ------------------------------------------------------------------ what a blow lands on, and the falls
mk mat_bone_0 0.35 -10 "$B/bfh1_wood_breaking_01.ogg|0|1.1|0|lowpass=f=4500"
mk mat_bone_1 0.35 -10 "$B/bfh1_wood_breaking_03.ogg|0|1.1|0|lowpass=f=4500"
mk mat_bone_2 0.35 -10 "$B/bfh1_wood_breaking_04.ogg|0|1.15|0|lowpass=f=4500"
mk mat_shield_0 0.35 -8 "$B/bfh1_wood_hit_01.ogg|0|0.9|0|-"
mk mat_shield_1 0.35 -8 "$B/bfh1_wood_hit_02.ogg|0|0.9|0|-"
mk mat_shield_2 0.35 -8 "$B/bfh1_wood_hit_03.ogg|0|0.9|0|-"
mk mat_armor_0 0.5 -9 "$B/bfh1_metal_hit_02.ogg|0|1|0|lowpass=f=7000"
mk mat_armor_1 0.5 -9 "$B/bfh1_metal_hit_03.ogg|0|1|0|lowpass=f=7000"
mk mat_armor_2 0.5 -9 "$B/bfh1_metal_hit_04.ogg|0|1|0|lowpass=f=7000"
mk mat_spectral_0 0.5 -12 "$B/bfh1_glass_hit_01.ogg|0|0.6|0|lowpass=f=4000" "$R/spell_02.ogg|-6|0.6|0|lowpass=f=3000"
mk mat_spectral_1 0.5 -12 "$B/bfh1_glass_hit_02.ogg|0|0.55|0|lowpass=f=4000" "$R/spell_02.ogg|-6|0.55|0|lowpass=f=3000"
mk ward 0.4 -12 "$B/bfh1_glass_hit_02.ogg|0|0.8|0|lowpass=f=4000"
mk interrupt 0.35 -9 "$B/bfh1_metal_hit_05.ogg|0|1.1|0|-" "$K/cloth2.ogg|-4|1|0|-"
mk armor_break 0.8 -5 "$B/bfh1_metal_falling_02.ogg|0|1|0|lowpass=f=7000" "$B/bfh1_breaking_02.ogg|-3|0.9|0|-"
mk kill_metal_0 0.9 -6 "$B/bfh1_metal_falling_01.ogg|0|1|0|lowpass=f=5000" "$B/bfh1_falling_05.ogg|-4|0.9|0.05|-"
mk kill_metal_1 0.9 -6 "$B/bfh1_metal_falling_04.ogg|0|0.9|0|lowpass=f=5000" "$B/bfh1_falling_06.ogg|-4|0.9|0.05|-"
mk kill_spectral 0.9 -8 "$R/spell_02.ogg|0|0.5|0|lowpass=f=3000" "$B/bfh1_glass_falling_02.ogg|-8|0.7|0|lowpass=f=4000"
# a skeleton's fall: the bones giving way and clattering down
mk bone_0 0.7 -4 "$B/bfh1_falling_01.ogg|0|1.05|0|lowpass=f=5000" "$B/bfh1_wood_breaking_02.ogg|-4|1.1|0|lowpass=f=4500"
mk bone_1 0.7 -4 "$B/bfh1_falling_04.ogg|0|1.1|0|lowpass=f=5000" "$B/bfh1_wood_breaking_01.ogg|-4|1.1|0|lowpass=f=4500"
mk bone_2 0.7 -4 "$B/bfh1_falling_05.ogg|0|1.1|0|lowpass=f=5000" "$B/bfh1_wood_breaking_04.ogg|-4|1.1|0|lowpass=f=4500"

# ------------------------------------------------------------------ the enemies' wind-ups, blows and shots
mk tell_blade_0 0.45 -14 "$K/drawKnife3.ogg|0|0.85|0|lowpass=f=7000"
mk tell_blade_1 0.45 -14 "$K/drawKnife2.ogg|0|0.85|0|lowpass=f=7000"
mk tell_ember 0.45 -14 "$R/spell_fire_03.ogg|0|1|0|lowpass=f=4000,afade=t=in:d=0.1|0|0.45"
mk tell_orb 0.45 -15 "$R/spell_01.ogg|0|0.75|0|lowpass=f=4500,afade=t=in:d=0.2"
mk tell_bolt 0.35 -13 "$K/metalLatch.ogg|0|0.8|0|lowpass=f=4500" "$K/metalClick.ogg|0|0.9|0.12|lowpass=f=4500"
mk tell_shield 0.45 -12 "$K/dropLeather.ogg|0|0.75|0|-" "$B/bfh1_wood_hit_03.ogg|-6|0.8|0.05|-"
mk tell_ritual 0.6 -15 "$L/Spell_03.wav|0|0.8|0|lowpass=f=3000,afade=t=in:d=0.2|0|0.7"
mk enemy_swing_0 0.35 -11 "$O/blade_0.ogg|0|0.75|0|-"
mk enemy_swing_1 0.35 -11 "$O/blade_2.ogg|0|0.75|0|-"
mk enemy_swing_2 0.35 -11 "$O/blade_3.ogg|0|0.72|0|-"
mk enemy_charge 0.45 -9 "$K/footstep03.ogg|0|0.8|0|-" "$K/footstep05.ogg|0|0.8|0.15|-" "$O/blade_spin_2.ogg|-6|0.6|0|lowpass=f=2500"
mk enemy_burst 0.6 -7 "$R/spell_fire_06.ogg|0|0.8|0|lowpass=f=5000" "$B/bfh1_rock_falling_01.ogg|-4|0.9|0|-"
mk shot_orb 0.3 -14 "$R/spell_02.ogg|0|1|0|lowpass=f=3500|0|0.3"
mk shot_vine 0.45 -14 "$R/creature_slime_02.ogg|0|0.7|0|lowpass=f=4000" "$K/creak1.ogg|-6|0.6|0|lowpass=f=4000"
mk bolt 0.3 -12 "$B/bfh1_wood_hit_01.ogg|0|1.5|0|-" "$O/thrust_0.ogg|-2|1.15|0|-"
# the Dons' own effects (Skills): the swing of a strike, the rain of light, a shield
mk swing 0.3 -12 "$O/blade_1.ogg|0|0.95|0|-"
mk rain 0.45 -12 "$R/spell_01.ogg|0|1.1|0|lowpass=f=5000|0|0.45"

# ------------------------------------------------------------------ Morvath
mk scythe_raise 0.7 -6 "$O/blade_spin_1.ogg|0|0.5|0|areverse,lowpass=f=3000" "$L/Spell_03.wav|-4|0.7|0|lowpass=f=1500,afade=t=in:d=0.3|0|0.8"
mk scythe 0.6 -4 "$O/blade_spin_0.ogg|0|0.55|0|-" "$R/chain_01.ogg|-10|0.6|0.05|lowpass=f=3500"
mk scythe_land 0.8 -3 "$B/bfh1_rock_breaking_01.ogg|0|0.85|0|-" "$B/bfh1_hit_02.ogg|-2|0.8|0|-"
mk boss_slash 0.5 -5 "$O/blade_spin_2.ogg|0|0.65|0|-" "$R/spell_02.ogg|-6|0.5|0|lowpass=f=3000"
mk souls 0.55 -9 "$R/spell_01.ogg|0|0.6|0|lowpass=f=3500" "$O/dart_1.ogg|-3|0.6|0|-"
mk boss_dash 0.5 -5 "$O/blade_spin_0.ogg|0|0.5|0|-" "$K/cloth1.ogg|-3|0.7|0|-"
mk dash_aim 0.9 -5 "$R/creature_monster_03.ogg|0|0.8|0|-"
mk dash_land 0.7 -3 "$B/bfh1_hit_07.ogg|0|0.85|0|-" "$B/bfh1_rock_falling_01.ogg|-3|0.8|0.03|-"
mk eruption 0.9 -4 "$B/bfh1_rock_falling_03.ogg|0|0.6|0|-" "$L/Spell_02.wav|-4|0.9|0|lowpass=f=900|0|0.8"
mk curse 0.7 -7 "$R/spell_02.ogg|0|0.6|0|areverse,lowpass=f=3500" "$L/Spell_03.wav|-6|0.7|0.1|lowpass=f=2000|0|0.6"
mk curse_release 0.5 -6 "$R/spell_fire_05.ogg|0|0.9|0|lowpass=f=5000" "$R/spell_02.ogg|-3|0.7|0|lowpass=f=4000"
mk cursed 0.5 -7 "$R/spell_01.ogg|0|0.6|0|lowpass=f=3500" "$K/cloth3.ogg|-3|0.9|0|-"
mk shield_up 0.8 -8 "$L/Spell_00.wav|0|0.8|0|lowpass=f=4500,afade=t=in:d=0.15|0|0.9"
mk shield_down 0.9 -4 "$B/bfh1_glass_breaking_06.ogg|0|0.8|0|lowpass=f=5000" "$B/bfh1_glass_breaking_01.ogg|-4|0.75|0.05|lowpass=f=4500"
mk summon 0.7 -8 "$L/Spell_03.wav|0|0.75|0|lowpass=f=3000|0|0.8" "$B/bfh1_rock_falling_05.ogg|-6|0.8|0.1|lowpass=f=4000"
mk rise 0.6 -8 "$B/bfh1_rock_falling_09.ogg|0|0.8|0|lowpass=f=4500" "$B/bfh1_wood_breaking_04.ogg|-4|0.9|0.1|lowpass=f=4000"
mk roar 1.3 -3 "$R/creature_roar_03.ogg|0|0.75|0|-" "$L/Dragon_Growl_00.wav|-6|0.9|0|lowpass=f=3000|0|1.3"
mk phase_shift 1.6 -5 "$H/gong_01.ogg|0|0.6|0|lowpass=f=3000" "$R/creature_roar_02.ogg|-8|0.6|0.05|-"
mk victory_draw 1.6 -6 "$L/Spell_03.wav|0|0.8|0|areverse,lowpass=f=3000|0|1.3"
mk victory_release 1.2 -6 "$H/bell_01.ogg|0|0.5|0|lowpass=f=3500" "$L/Spell_01.wav|-6|0.9|0.05|lowpass=f=5000"
mk boss_down 1.4 -3 "$B/bfh1_falling_04.ogg|0|0.7|0|-" "$B/bfh1_metal_falling_01.ogg|-4|0.8|0.1|-" "$R/creature_die_01.ogg|-4|0.6|0|-"
mk seal 1.5 -5 "$H/gong_02.ogg|0|0.75|0|lowpass=f=3000" "$H/bell_02.ogg|-8|0.5|0.1|lowpass=f=3000"
mk sword_rise 0.6 -8 "$K/drawKnife3.ogg|0|0.9|0|lowpass=f=6000" "$R/spell_01.ogg|-6|0.9|0.05|lowpass=f=5000"
# an elite coming in and going down
mk elite 0.9 -5 "$R/creature_roar_01.ogg|0|0.8|0|-" "$B/bfh1_metal_hit_04.ogg|-6|0.8|0|lowpass=f=6000"
mk elite_down 1.1 -3 "$B/bfh1_metal_falling_01.ogg|0|0.9|0|lowpass=f=7000" "$B/bfh1_falling_04.ogg|-3|0.9|0.05|-"
# a door of stone and wood opening
mk door 1.2 -6 "$K/doorOpen_1.ogg|0|0.7|0|lowpass=f=4000" "$B/bfh1_rock_falling_01.ogg|-6|0.6|0.2|-"

# ------------------------------------------------------------------ rewards and the interface
mk orb 0.4 -12 "$R/item_gem_01.ogg|0|0.6|0|lowpass=f=4500"
mk heal 0.7 -10 "$L/Spell_00.wav|0|1|0|lowpass=f=5500|0|0.7"
mk fountain 0.9 -10 "$H/splash_01.ogg|0|0.9|0|-" "$L/Spell_00.wav|-6|1|0.1|lowpass=f=5000|0|0.8"
mk boon 0.6 -10 "$R/item_gem_04.ogg|0|0.7|0|lowpass=f=4500" "$L/Spell_01.wav|-8|0.9|0|lowpass=f=5000|0|0.6"
mk level_up 0.9 -10 "$H/bell_02.ogg|0|0.5|0|lowpass=f=3000" "$L/Spell_01.wav|-6|0.85|0.05|lowpass=f=5000|0|0.8"
mk ui_move 0.15 -20 "$R/item_wood_02.ogg|0|0.9|0|lowpass=f=4000|0|0.15"
mk ui_ok 0.3 -15 "$K/metalLatch.ogg|0|0.85|0|lowpass=f=4500" "$B/bfh1_wood_hit_02.ogg|-6|1.1|0|-"
