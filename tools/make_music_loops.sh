#!/bin/bash
# T5: the recorded music (Kevin MacLeod, incompetech.com, CC BY 4.0; credits in audio/LICENSES.md and credits_*)
# cut into seamless loops for the Music autoload. The sources are not in the project: download them first into a
# folder of their own (untrusted data) and pass it:
#   tools/make_music_loops.sh <folder with the .mp3s>
# Sources (https://incompetech.com/music/royalty-free/mp3-royaltyfree/<title>.mp3):
#   "Tempting Secrets"  -> audio/music/title.ogg       (title screen; plays the opening hit once, loops from LOOP_FROM)
#   "Oppressive Gloom"  -> audio/music/catacombs_1.ogg (rooms, the walk)
#   "The Descent"       -> audio/music/catacombs_2.ogg (rooms, the fight)
#   "Clash Defiant"     -> audio/music/morvath_1..4.ogg (Morvath, one section of the same piece per phase)
#   "Thatched Villagers"-> audio/music/thatched_villagers.ogg (the Santuario, 44 bars of 93.75 bpm)
#   "Heroic Age"        -> audio/music/heroic_age.ogg  (the rooms, walk and fight alike, 48 bars of 130 bpm)
#   "Ossuary 5 - Rest"  -> audio/music/room_won.ogg    (the transition: 16 s of it, faded in and out, over the room won)
# A loop of a piece with a tempo is a whole number of bars (bpm from incompetech's catalog, 4/4), so the music after
# the cut is the music before it; the seam is an equal-power crossfade of XFADE bars of the next bars into the head.
# Every file is brought to a set loudness (LUFS, ffmpeg ebur128) so the E6 mix (tests/test_mix.gd) keeps its levels.
set -euo pipefail
SRC="${1:?folder with the downloaded mp3s}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/audio/music"
WORK="${TMPDIR:-/tmp}/eterra_music_loops"
mkdir -p "$WORK"
Q=0  # vorbis quality (about 64 kbps; MUS-1, Q-20 a: was 3, down for the 18 MB of music with the new pieces)

# loop <source> <start s> <length s> <crossfade s> <wav out>: the seam fades the bars after the loop into its head
loop() {
	local a b
	a=$(echo "$2 + $4" | bc -l); b=$(echo "$2 + $3 + $4" | bc -l)
	ffmpeg -v error -y -i "$1" -filter_complex \
		"[0]atrim=start=$a:end=$b,asetpts=PTS-STARTPTS[a];[0]atrim=start=$2:end=$a,asetpts=PTS-STARTPTS[b];[a][b]acrossfade=d=$4:c1=qsin:c2=qsin[o]" \
		-map "[o]" -ar 44100 -c:a pcm_s16le "$5"
}

# lufs <wav>: its integrated loudness
lufs() {
	ffmpeg -nostats -i "$1" -af ebur128 -f null - 2>&1 | awk '/^ +I:/{v=$2} END{print v}'
}

# encode <wav> <target LUFS> <ogg out>
encode() {
	local now gain
	now=$(lufs "$1"); gain=$(echo "$2 - ($now)" | bc -l)
	ffmpeg -v error -y -i "$1" -af "volume=${gain}dB" -c:a libvorbis -q:a $Q "$3"
	echo "$(basename "$3"): $(printf '%.1f' "$now") LUFS + $(printf '%.1f' "$gain") dB"
}

mus2() {
	# the Santuario (MUS-2, 2026-11-25): "Thatched Villagers", 44 bars from the start (bpm found by the envelope's
	# autocorrelation; the loop that meets itself best in the whole piece), 2 bars of crossfade into the head
	BAR=$(echo "4 * 60 / 93.75" | bc -l)
	LEN=$(echo "${HUB_BARS:-44} * $BAR" | bc -l)
	loop "$SRC/Thatched Villagers.mp3" 0 "$LEN" "$(echo "2 * $BAR" | bc -l)" "$WORK/thatched_villagers.wav"
	encode "$WORK/thatched_villagers.wav" -22 "$OUT/thatched_villagers.ogg"

	# the rooms' second piece: "Heroic Age" (130 bpm), 48 bars, played for the walk and the fight alike
	BAR=$(echo "4 * 60 / 130" | bc -l)
	loop "$SRC/Heroic Age.mp3" 0 "$(echo "48 * $BAR" | bc -l)" "$(echo "2 * $BAR" | bc -l)" "$WORK/heroic_age.wav"
	encode "$WORK/heroic_age.wav" -20 "$OUT/heroic_age.ogg"

	# the transition: the steady stretch of "Ossuary 5 - Rest" (64 s to 80 s), 2 s in and 4 s out (it plays once over the
	# room won, the room's music ducked under it, until the next room begins)
	ffmpeg -v error -y -ss 64 -t 16 -i "$SRC/Ossuary 5 - Rest.mp3" -af "afade=t=in:d=2:curve=qsin,afade=t=out:st=12:d=4:curve=qsin" \
		-ar 44100 -c:a pcm_s16le "$WORK/room_won.wav"
	encode "$WORK/room_won.wav" -22 "$OUT/room_won.ogg"
}
# MUS2_ONLY=1 makes just the three pieces of MUS-2 (the folder needs only their mp3s)
[ -n "${MUS2_ONLY:-}" ] && { mus2; exit 0; }

# the title: the opening hit plays once, then the loop from LOOP_FROM to TITLE_END, its last XT seconds fading into
# the seconds before LOOP_FROM (Music.TRACKS.title.loop_from must match)
LOOP_FROM=16
TITLE_END=172
XT=4
ffmpeg -v error -y -i "$SRC/Tempting Secrets.mp3" -filter_complex \
	"[0]atrim=start=0:end=$TITLE_END,asetpts=PTS-STARTPTS[a];[0]atrim=start=$((LOOP_FROM - XT)):end=$LOOP_FROM,asetpts=PTS-STARTPTS[b];[a][b]acrossfade=d=$XT:c1=qsin:c2=qsin[o]" \
	-map "[o]" -ar 44100 -c:a pcm_s16le "$WORK/title.wav"
encode "$WORK/title.wav" -22 "$OUT/title.ogg"

# the rooms: the walk (58 bpm, 40 bars) and the fight (103 bpm, 70 bars), heard one at a time (Music.TRACKS solo)
BAR=$(echo "4 * 60 / 58" | bc -l)
loop "$SRC/Oppressive Gloom.mp3" 0 "$(echo "40 * $BAR" | bc -l)" "$BAR" "$WORK/catacombs_1.wav"
encode "$WORK/catacombs_1.wav" -21 "$OUT/catacombs_1.ogg"
BAR=$(echo "4 * 60 / 103" | bc -l)
loop "$SRC/The Descent.mp3" 0.606 "$(echo "70 * $BAR" | bc -l)" "$(echo "2 * $BAR" | bc -l)" "$WORK/catacombs_2.wav"
encode "$WORK/catacombs_2.wav" -20 "$OUT/catacombs_2.ogg"

# Morvath: four sections of "Clash Defiant" (170 bpm), 48 bars each, starts on the bar grid from 0, a little
# louder each phase: 1 the calmer middle, 2 after the break, 3 the later push, 4 the climax
BAR=$(echo "4 * 60 / 170" | bc -l)
LEN=$(echo "48 * $BAR" | bc -l)
X=$(echo "2 * $BAR" | bc -l)
i=1
for spec in "43:-22" "212:-21" "153:-20" "84:-19"; do
	bars=${spec%%:*}; target=${spec##*:}
	loop "$SRC/Clash Defiant.mp3" "$(echo "$bars * $BAR" | bc -l)" "$LEN" "$X" "$WORK/morvath_$i.wav"
	encode "$WORK/morvath_$i.wav" "$target" "$OUT/morvath_$i.ogg"
	i=$((i + 1))
done

mus2
