# T5, áudio: música com identidade e efeitos de fantasia medieval

Relatos do PO: (A) "a música da partida não deve ser igual à música da tela inicial"; (B) "os efeitos sonoros
parecem de fliperama".

## Avaliação honesta da síntese

A música da E4 (`tools/make_music.gd`) é bem escrita (modos, camadas, laço sem emenda), mas a síntese do projeto
(tabelas de onda, coro por formantes, Karplus-Strong) não chega a soar orquestral: cordas, metais e coro sintetizados
assim soam como órgão eletrônico e caixinha de música, e o título tocava a mesma faixa das salas. Os efeitos eram
quase todos receitas de onda quadrada, triângulo e serra com ruído (`scripts/audio.gd`, `SOUNDS`): é exatamente o
timbre de fliperama do relato. A troca foi por gravações livres (CC0 e CC BY), nada pago, nada com direitos incertos.

## A) Música

Três identidades, de Kevin MacLeod (incompetech.com, CC BY 4.0; peças orquestrais gravadas com bibliotecas de
amostras reais):

| Momento | Peça | Por quê | Arquivo |
|---|---|---|---|
| Título | "Tempting Secrets" (cordas, flauta, coro; Dark, Epic, Uplifting, Somber) | abre com um golpe de orquestra, depois um bordão de cordas com uma flauta antiga por cima e o coro no último terço: "uma grande história prestes a ser contada", sem intensidade | `music/title.ogg`, 172 s, a abertura toca uma vez e o laço volta aos 16 s (`loop_offset`) |
| Salas, caminhada | "Oppressive Gloom" (cordas, clarone, percussão; 58 BPM, "quase uma marcha fúnebre") | cordas graves, percussão discreta, mistério e tensão de catacumba | `music/catacombs_1.ogg`, laço de 40 compassos (2 min 46 s) |
| Salas, luta | "The Descent" (trompas, trombones, tuba, violinos, percussão; 103 BPM) | fantasia sombria que empurra sem melodia dominante, não cansa em laço | `music/catacombs_2.ogg`, laço de 70 compassos (2 min 43 s) |
| Morvath | "Clash Defiant" (contrabaixos e violoncelos em spiccato, trompa de guerra, metais, percussão, coro; 170 BPM) | percussão marcante, cordas dramáticas, coro discreto, um motivo só por toda a luta | `music/morvath_1..4.ogg`, uma seção de 48 compassos por fase, cada fase 1 LU mais alta (-22, -21, -20, -19 LUFS) |

Temas dos Salmos e a vitória continuam os sintetizados da E4 (curtos, sobre o leito; ver "Escuta humana").

### Como toca

- `Music.TRACKS` ganhou `title` (`Music.play(&"title")` no `boot.gd`; antes o título tocava as salas) e a opção
  `solo` (`MusicMix.Deck.solo`): nas salas e em Morvath o nível n ouve só a camada n. As outras camadas seguem rodando
  mudas no mesmo tempo, então caminhada para luta e fase para fase são crossfade de 2 s (`LAYER_FADE`) sem reiniciar a
  peça. Entrar na primeira sala é crossfade do título para as salas (1,5 s entra, 2,5 s sai); a morte volta à
  caminhada; a vitória entrega à caminhada como antes.
- Laços sem emenda (`tools/make_music_loops.sh`): o laço tem um número inteiro de compassos (BPM do catálogo do
  incompetech, 4/4), então o que vem depois do corte é a continuação do que veio antes; a emenda é um crossfade de
  potência igual (1 a 2 compassos) dos compassos seguintes sobre a cabeça do laço. As seções de Morvath começam na
  grade de compassos a partir de 0, para a troca de fase cair no mesmo pulso.
- Loudness: cada arquivo nivelado em LUFS integrado (título -22, caminhada -21, luta -20, Morvath -22 a -19), na faixa
  da música da E4; os barramentos, o ducking dos avisos de Morvath (`Audio.WARN_CUES`, `MusicMix.WARN_DUCK`) e o
  limitador ficaram iguais.
- Tamanho: a música toda 11 MB (teto do teste 15 MB).

### Revisão do PO: escolher a música (Músicas)

Relato depois de ouvir: "Não gostei das músicas. Não tem como colocar no menu um lugar onde eu possa ouvir as músicas
que já temos e depois eu escolho as que eu gosto? A música de antigamente eu gostava, só não gostei da música da fase."

- **As antigas voltaram e são o padrão.** Os arquivos da E4 (commit `5dfe97f`) estão de novo no pacote com nome próprio:
  `music/classic_catacombs_1.ogg`, `_2.ogg` ("Catacumbas (original)", caminhada e luta somadas) e
  `music/classic_morvath_1.ogg` a `_4.ogg` ("Morvath (original)", uma camada a mais por fase). Título, masmorra e
  Morvath tocam as antigas por padrão; o título toca a caminhada da Catacumbas, como antes do T5, e a primeira sala
  segue a mesma peça (a luta entra por cima, sem recomeçar). `tools/make_music.gd -- catacombs morvath` regrava esses
  nomes, não mais os do MacLeod.
- **As do MacLeod ficam para escolher**: "Tempting Secrets" (só título), "Oppressive Gloom e The Descent" (masmorra, ou
  título com a caminhada) e "Clash Defiant" (Morvath). Crédito mantido (`credits_music`), pois estão no pacote.
- **Catálogo como dado**: `MusicCatalog` (`scripts/core/music_catalog.gd`), uma linha por peça com nome do jogador
  (`music_<id>` no `text_pt.tres`), arquivos, camadas, `solo` ou somadas, laço e lugares onde serve. Masmorra pede 2
  camadas (caminhada e luta), Morvath 4 (fases); vitória e temas dos Salmos só para ouvir. Peça nova: uma linha e os
  arquivos.
- **Escolha no save**: opções `music_title`, `music_dungeon`, `music_morvath`; valor inválido, ausente ou que não serve
  ali cai no padrão (`MusicCatalog.resolve`). `Music.play(&"title"|&"catacombs"|&"morvath")` e `Music.boss_phase`
  tocam a peça escolhida (`Music.piece_for`); crossfades, camadas por nível ou fase, ducking dos avisos e barramentos
  iguais. O registro de som guarda o lugar e o `tools/mix_replay.gd` resolve igual.
- **Tela Músicas** (`MusicRoomScreen`, botão nas Configurações, também na pausa): "Onde toca" com "< peça >" para
  Título, Masmorra e Morvath (grava na hora) e a lista de todas as peças com Ouvir/Parar, Caminhada ou Luta, Fase 1 a 4
  ou "Todas as fases" (20 s cada). Ao sair, a música do jogo volta onde estava, já com a escolha nova (no título, a
  música do título escolhida). Teclado, mouse e controle; cabe em 1280 x 720 (621 px de altura) e 1920 x 1080.
  Capturas: `docs/gallery/t5/ui/music_room_720.jpg`, `music_room_1080.jpg`, `music_room_options_720.jpg`.
- **Loudness** (ffmpeg `ebur128`): antigas -21,7 LUFS na caminhada e -20,1 com a luta (novas -21,1 e -20,1); Morvath
  original -27,9 / -23,1 / -20,7 / -19,3 nas fases 1 a 4 (novas -22 a -19; a fase 1 original é só o ostinato, mais
  baixa de propósito desde a E4). Nenhum ganho extra. A luta gravada (`tests/test_mix.gd`) dá -16,6 LUFS com a original
  e -16,3 com "Clash Defiant", -1,4 dBTP depois do limitador, limitador em 2 e 3 de 953 janelas: dentro das metas.
- **Testes**: `tests/test_music_room.gd` (catálogo, arquivos, padrão, escolha inválida, `Music` resolve, ouvir e
  voltar, tela pelo teclado, cabe em 720); `tests/test_music.gd` e `test_mix.gd` passam por todas as peças escolhíveis
  (teto do pacote de música 15 para 18 MB: 16,6 MB com as antigas de volta).

### MUS-1: música de luta (2026-11-18)

Pedido do PO: "eu não gosto das músicas, queria que você criasse mais duas ou três músicas para as fases do jogo. Por
se tratar de um jogo de hack slash, acho que tem que ser músicas mais animadas, dinâmicas. As que foram criadas são um
pouco depressivas."

Quatro peças novas, compostas nota por nota e sintetizadas em `tools/make_music.gd` (licença nossa; nenhuma melodia de
outro jogo; o espírito da energia do Hades II, não as notas dele). Todas com percussão que empurra (bumbo, caixa, toms,
taiko, palmas, chimbal, prato e viradas de tom no fim das frases), um riff, melodia com uma segunda voz (`_counter`),
progressões que sobem e o pico em maior (bVI, bVII, I: a luz de Elun), e a volta ao começo pela dominante, sem emenda.

| Peça | id | Caráter | Tom | BPM | Duração | Camadas |
|---|---|---|---|---|---|---|
| Marcha das Lâminas | `blade_march` | orquestral e épica: spiccato em 3+3+2, violinos com contracanto das violas, baixo subindo sol, lá, si bemol... sol; na luta bumbo, caixa, toms, metais com a melodia e acordes, coro no pico | ré menor, pico em ré maior | 144 | 40 compassos, 66,7 s | caminhada, luta |
| Tambores do Fundo | `deep_drums` | folk e tribal: bordão, dedilhado de cordas, rabeca num reel com ornamentos e flauta respondendo; na luta toms de guerra em 3+3+2, taiko, palmas, trompa em quintas, coro em golpes curtos | mi dórico, pico em mi maior | 150 | 40 compassos, 64 s | caminhada, luta |
| Pulso de Ferro | `iron_pulse` | pulsante e sombrio-heroico: baixo em semicolcheias com acento 3+3+2, arpejo alto, motivo grave das violas, coro subindo; na luta bumbo a cada tempo, caixa, prato aberto, acordes de metais e spiccato em oitavas | lá menor harmônico, pico em lá maior | 138 | 36 compassos, 62,6 s | caminhada, luta |
| Morvath, a Batalha | `morvath_battle` | 1 cordas graves em semicolcheias com bumbo e taiko; 2 coro do ritual e sino grave; 3 trêmulo agudo, caixa, toms e harpa caindo; 4 o tema do herói nos metais subindo a dó maior, pratos e coro agudo | dó menor harmônico, pico em dó maior | 150 | 40 compassos, 64 s | uma por fase |

- **Padrão**: Marcha das Lâminas no título (a caminhada) e nas salas, Morvath, a Batalha em Morvath
  (`MusicCatalog.DEFAULT`); as originais e as do MacLeod continuam na tela Músicas. Escolhi a Marcha por ser a mais
  próxima do pedido (orquestral, épica, tema forte); só o ouvido do PO decide de verdade.
- **Loudness por meta, não por pico** (`_publish_levelled`): o ganho de cada camada é achado para a soma bater a meta
  (`Loudness`, BS.1770), depois um limitador com antecipação de 3 ms segura a soma abaixo do teto de amostra
  (`ROOMS_CEILING` -2 dBFS; Morvath `MORVATH_CEILING` -5,2 para as 4 juntas ficarem 1,5 dB abaixo do limitador no ganho
  do jogo). Medido no .ogg (ffmpeg `ebur128`):

| Peça | caminhada | com a luta | pico (dBTP) |
|---|---|---|---|
| Marcha das Lâminas | -21,9 | -20,1 | -9,1 / -3,9 |
| Tambores do Fundo | -21,9 | -20,0 | -8,7 / -4,5 |
| Pulso de Ferro | -22,0 | -20,1 | -6,4 / -3,3 |
| Catacumbas (original), referência | -21,7 | -20,1 | -10,7 / -4,8 |

  Morvath, a Batalha: -22,6 / -21,4 / -20,5 / -19,4 LUFS nas fases 1 a 4, -6,4 a -4,9 dBTP (a original: -27,9 / -23,1 /
  -20,7 / -19,3). Nas salas a camada de luta sozinha fica uns 2,7 LU abaixo da caminhada (na original 3,5).
- **Na luta gravada** (o robô com reação 0,25, `--sound-log`, refeita pelos barramentos e o limitador por
  `tools/mix_probe.gd --log=... --music-dungeon=id`/`--music-morvath=id`, opção nova que só troca a escolha na memória):
  salas -16,9 (Marcha), -16,9 (Tambores), -16,8 (Pulso) contra -17,0 da original, Morvath -16,2; -1,0 a -1,45 dBTP
  depois do limitador, limitador em 8 a 14 de 1588 janelas (salas) e 4 de 826 (Morvath). `test_mix.gd` com Morvath, a
  Batalha: -16,4 LUFS, -1,45 dBTP, 2 de 953 janelas. Música sob os golpes (`test_music.gd`): pico -3,4 dBTP, 0,4 s mais
  alto -16,3 contra -9,6 dos golpes.
- **Pacote** (teto 18 MB): a música toda passava (16,57 MB no disco mais 6,7 das novas; no pacote o .oggvorbisstr
  importado pesa uns 6% a mais que o .ogg). Q-20 (a): as peças do MacLeod reencodadas em qualidade Vorbis 0 (mesmas
  amostras e laços, loudness igual a 0,1 LU; 10,2 para 5,6 MB), as originais e os temas dos Salmos e da vitória
  codificados de novo do .wav (idêntico ao de antes, conferido byte a byte) em qualidade 1 (5,5 para 3,8 e 0,86 para
  0,58) e as novas em 2 (6,7) (`QUALITY` no script; o `tools/make_music_loops.sh` passou a 0). Total no disco 16,69 MB
  (15,9 MiB; o teste pede menos de 18 MiB), no pacote 17,73 MB (os `.oggvorbisstr` importados). Se faltar espaço de
  novo: tirar "Tempting Secrets" (1,1 MB, só título).
- **Tela Músicas**: 14 peças não cabiam em 720 linhas; linhas da lista com 30 px e botões de margem fina
  (`MusicRoomScreen.ROW`, `_compact`, só a lista).
- **Testes**: `test_music_room.gd` (padrão novo, as antigas na lista, passo do título), `test_music.gd` (duração das
  novas de 60 a 100 s, descida inteira sem 2 s de silêncio com cada peça nova, laço que se encontra: o salto da última
  amostra para a primeira não passa do maior salto de dentro e o último e o primeiro quarto de segundo têm volume
  parecido, `test_our_layered_loops_meet_themselves`), `test_mix.gd` (a luta de Morvath com a peça nova).
- **Para ouvir** (`docs/gallery/mus1/`, cópia em `C:\Users\danie\Downloads\ASelagem-musicas\`): `<id>_walk_then_fight.mp3`
  (60 s do .ogg do jogo: caminhada até 26 s e a luta entrando em 2 s; Morvath com uma fase a cada 15 s,
  `morvath_battle_phases_1_to_4.mp3`), `<id>_with_the_fight.mp3` (60 s da luta gravada pelo robô com a peça, já no
  volume do jogo, depois do limitador). As peças sozinhas ficam uns 3 dB abaixo das gravações com a luta, como no jogo.
- **Ninguém ouviu**: o artista técnico mediu loudness, pico, espectro e laço, mas não tem ouvido. O PO e o
  `combat-feel-director` precisam ouvir antes de fechar.
- **Save antigo**: todo save desde o T5 grava a escolha padrão (`classic_catacombs`), então quem já tem save continua
  ouvindo a original até escolher na tela Músicas. Falta decidir uma migração de save (fora dos arquivos do artista
  técnico).

## B) Efeitos

Todo nome de som do jogo (81 em `Audio.SOUNDS`) tem arquivo gravado agora; as receitas só tocam se um arquivo
faltar. Os arquivos são montados por `tools/make_sfx.sh` (fonte da verdade, uma linha por arquivo com as camadas):
cada momento é um arquivo só com as camadas já mixadas (movimento da arma, contato, impacto, magia), nada empilhado em
tempo de jogo; tom e filtro ajustados (nada agudo: passa-baixas de 3 a 7 kHz nos metais, vidros e magias), pico
nivelado por categoria. Variações: `nome_0.ogg`, `nome_1.ogg`... sorteados com 12% de tom (`AudioStreamRandomizer`).

### O que mudou por momento

Guerreiro:
- Golpe 1 (`blade`, cut1): o sopro leve de antes (qubodup).
- Golpe 2 (`blade_heavy`, novo, cut2): o mesmo ar mais grave (0,85) com o corpo (pano) atrás; mais forte que o 1.
- Golpe 3 (`blade_spin`, finalizador): o giro de antes; o peso vem no contato (`hit_heavy`).
- Contato (`hit`, só com acerto): a pancada do Kenney com o fio entrando (corte de faca do Kenney, -11 dB, sem agudos).
- Contato forte (`hit_heavy`, finalizador e Ômega): pancada, impacto grave de corpo (rubberduck) e o corte.
- Especial (D, `dart`): o ar da lâmina, a magia (rubberduck `spell_02` grave) e um empurrão grave (LRSF `Spell_02`
  filtrado): a onda esmeralda com energia.
- Ômega do especial (`wave_omega`, novo): o ar do giro, surto de magia (`spell_01`) e o estrondo grave (`Spell_04`).
- Ômega carregando (`charge_up`) e pronto (`charged`, sino grave meia oitava abaixo com brilho de magia), esquiva
  (pano e ar grave), ferido (`hurt`: pancada no corpo, couro, malha), círculo de luz, círculo Ômega e explosão (pedra
  que estoura com magia e grave), ultimate (gesto, Corte do Juízo com pedra rachando e estrondo, Voragem girando e
  implodindo).

Inimigos:
- Material do golpe: osso (madeira seca quebrando, aguda cortada), escudo (madeira batida), armadura (metal batido),
  espectral (vidro grave e magia). Quedas: esqueleto desmontando (`bone`), metal caindo (`kill_metal`), espectral.
- Preparações por papel: lâmina sacada (`tell_blade`), brasas (`tell_ember`), orbe crescendo (`tell_orb`), besta
  armando (trinco e clique, `tell_bolt`), escudo firmado (couro e madeira, `tell_shield`), zumbido de ritual
  (`tell_ritual`). Golpes: ar mais grave que o do herói (`enemy_swing`), investida com passos (`enemy_charge`),
  explosão de fogo e pedra (`enemy_burst`). Tiros: orbe, trepadeira (gosma e rangido), virote (estalo de madeira e ar).
- Corte da preparação (`interrupt`: tinido curto e pano), quebra de armadura (metal caindo e quebra), elite chegando
  (rugido e metal) e caindo.

Morvath: foice erguida (o giro ao contrário, subindo, e um zumbido grave: o aviso se ouve), foice (ar grave e
corrente), foice no chão (pedra quebrando e pancada grave), Lâminas, meias-luas das almas, investida (rosnado no
preparo, `dash_aim`; pancada e pedra na chegada), erupção (pedra caindo e estrondo), maldição (magia ao contrário),
escudo do ritual (sobe magia, quebra vidro), invocação e mortos se erguendo (pedra e osso), rugido (criatura grave e
dragão), troca de fase (gongo grave e rugido), queda, selagem (gongo e sino graves), vitória.

Interface: `ui_move` um toque de madeira curto e baixo, `ui_ok` um trinco de metal com madeira; Bênção, nível, cura,
fonte e orbe com gema, sino grave e magia, sem bipes.

### Código e dados

- `scripts/audio.gd`: receitas `blade_heavy` e `wave_omega` (reserva), cabeçalho; `VoiceGate.FAMILY` põe as duas na
  família da lâmina (no máximo 2 vozes, 70 ms).
- `tools/make_data.gd` (parte `combos`): cut2 toca `blade_heavy`, o Ômega do especial `wave_omega`
  (`data/combos/paladin*.tres` regerados).
- `bone_3.ogg` e `bone_4.ogg` (Kenney) saíram: a queda do esqueleto tem 3 variações novas.

## Mixagem medida

`tools/mix_probe.gd -- --log=tests/fixtures/sound_log_boss.json --why` (a luta de Morvath gravada):
-16,4 LUFS (meta -18 a -14), -1,44 dBTP depois do limitador, limitador em 3 a 5 de 953 janelas (meta abaixo de 2%; com
os primeiros níveis estava em 23, por isso os golpes, o rugido, a troca de fase, as almas e o material espectral
ficaram 1,5 a 2 dB mais baixos). Música de Morvath sozinha: -6,6 dBTP, a parte mais alta 6 dB abaixo dos golpes
(`tests/test_music.gd`).

## Testes atualizados (com justificativa)

- `tests/test_music.gd`: as faixas solo não precisam ter as camadas do mesmo tamanho (cada peça laça nos próprios
  compassos; nunca tocam juntas); limites de duração do título e das salas até 200 s ("laço longo"); silêncio
  conferido em cada camada solo e no título; "a música fica sob os golpes" mede a camada mais alta de Morvath, não a
  soma das quatro (que nunca tocam juntas). Teste novo `test_the_title_and_the_solo_tracks` (título, crossfade para as
  salas, caminhada e luta sem reiniciar, fase 3 sozinha, `loop_offset` do título).

## Escuta humana (o que precisa do Daniel)

Nada disso foi ouvido: as escolhas vieram das descrições, instrumentos e medidas (loudness por trecho, energia acima
de 4 kHz e abaixo de 300 Hz). Ouvir:
1. As quatro peças nos seus lugares e as emendas dos laços (título aos 2 min 52 s, caminhada aos 2 min 46 s, luta aos
   2 min 43 s, cada fase de Morvath aos 68 s), e se "Clash Defiant" tem a ameaça que Morvath pede (a peça é
   contida de propósito; a fase 4 é a seção mais forte). Alternativa já baixada e medida: "Stoneworld Battle"
   (cresce mais, sem coro).
2. Os temas dos Salmos e a vitória, sintetizados, ao lado da orquestra gravada: talvez destoem.
3. Os efeitos do Guerreiro em sequência (1, 2, 3, especial, Ômegas), a foice erguida e o rosnado da investida como
   avisos, as quedas, a interface. Ajustar no `tools/make_sfx.sh` (pico, tom, filtro, outra fonte) e rodar de novo.
4. Se o escudo do ritual quebrando (vidro) ainda brilha demais.

## Arquivos e origens

Pacotes baixados (cada um numa pasta própria, tratados como dados): ver `audio/LICENSES.md` (autor, link, licença).
Reconstruir: baixar os .mp3 e os .zip, descompactar e rodar `tools/make_music_loops.sh <pasta>` e
`tools/make_sfx.sh <pasta>`. Créditos no jogo: `credits_music`, `credits_music_own`, `credits_sfx`, `credits_blade`,
`credits_rpg_sfx`, `credits_fantasy`, `credits_synth`.
