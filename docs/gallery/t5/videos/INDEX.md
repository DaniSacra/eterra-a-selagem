# T5, vídeos antes e depois na placa de vídeo

Gravados em 2026-11-17 pelo `qa-performance` na RTX 5060 (Godot 4.7.2 para Windows, Vulkan, Forward+), pelo Movie
Maker da Godot a **120 quadros por segundo com o tempo fixo** (`--fixed-fps 120 --write-movie`), 1280 x 720, `--nosave`.
Nenhum quadro é imagem gerada por IA. Antes = `5dfe97f` (espelho `C:\Users\danie\tools\eterra-gpu-t5base`, conferido
arquivo por arquivo contra `git archive 5dfe97f`); depois = `620a21e` (espelho `C:\Users\danie\tools\eterra-gpu`
sincronizado às 21:55, scripts, dados, cenas e assados conferidos por conteúdo, mais a correção do `game.gd` que só mexe na
tela de fim, commitada como `579fe89`). Os de depois foram gravados primeiro no `24c298e` e regravados no `620a21e`
(correções de pose do art-director); só os do `620a21e` ficaram. Mesmos argumentos nos dois.

- `NN_nome_antes.mp4` e `NN_nome_depois.mp4`: velocidade normal, 60 qps, com o som do jogo, 960 x 540.
- `NN_nome_antes_lento.mp4` e `NN_nome_depois_lento.mp4`: **0,25x** (cada quadro gravado a 120 qps mostrado a 30 qps,
  sem quadro inventado), sem som, 4 s do jogo viram 16 s; alguns recortados em volta do herói e ampliados.
- Os mestres a 120 qps (H.264 quase sem perda) ficaram fora do git em `/home/dani/tools/t5qa/vid/master/`.
- Gravador: `/home/dani/tools/t5qa/mov.sh` (o `tools/movie.sh` sem ressincronizar o espelho); cortes: `/home/dani/tools/t5qa/cut.sh`.

| # | O que mostra | Opções do jogo (depois de `--`) | Trecho lento |
|---|---|---|---|
| 01 | Esqueletos da primeira sala andando até o herói parado (o "tremor" do relato) | `--play --seed=1 --hero-hp=9999` | 2,0 a 6,0 s, quadro inteiro |
| 02 | Guardião Sacerdote dos Mortos: os esqueletos invocados correndo até o herói (a "gazela") | `--start=miniboss --seed=5 --hero-hp=9999` | 10,0 a 14,0 s, quadro inteiro |
| 03 | Esqueletos (3) preparando e dando o golpe no herói parado | `--start=shop --stress=3 --stress-ids=skeleton` | 0,5 a 4,5 s, recorte 640 x 360 no herói |
| 04 | Escudo (2): preparação e golpe curto colados no herói (no depois eles não investem, perto demais; ver 04b) | `--start=shop --stress=2 --stress-ids=guard` | 0,5 a 5,5 s, recorte no herói |
| 04b | Escudo (1) vindo de longe: preparação da investida, a corrida atrás do escudo e o contato | `--start=shop --stress=1 --stress-ids=guard --seed=3` | 1,5 a 5,0 s, recorte no herói |
| 05 | Besteiro (3): mira, tiro e fuga | `--start=shop --stress=3 --stress-ids=archer` | 1,0 a 5,0 s, quadro inteiro |
| 06 | Feiticeiro (3): preparação e rajada | `--start=shop --stress=3 --stress-ids=mage` | 1,0 a 5,0 s, quadro inteiro |
| 07 | Morvath, Foice Sepulcral (só ela) | `--start=boss --boss-only=scythe --hero-hp=9999` | 3,5 a 7,5 s, recorte no herói |
| 08 | Morvath, Investida (robô fugindo para ela aparecer) | `--start=boss --boss-only=dash --bot --bot-kite=0.9 --hero-hp=9999` | 3,5 a 7,5 s, quadro inteiro |
| 09 | Morvath, Lâminas das Almas | `--start=boss --boss-only=blades --hero-hp=9999` | 3,3 a 7,3 s, recorte no herói |
| 10 | Ultimate Corte do Juízo usada pelo robô na primeira sala | `--bot --autopick --seed=5 --ultimate=cleave --ult-full --hero-hp=9999` | 4,5 a 8,5 s, quadro inteiro |
| 11 | Ultimate Voragem usada pelo robô na primeira sala | `--bot --autopick --seed=5 --ultimate=vortex --ult-full --hero-hp=9999` | 5,5 a 9,5 s, quadro inteiro |

O que foi conferido quadro a quadro (tiras em `/home/dani/tools/t5qa/vid/strip*.jpg`, fora do git):
- 03 depois: o esqueleto ergue a lâmina com o brilho durante o aviso vermelho e desce no golpe.
- 07 depois: Morvath ergue a lâmina por cima da cabeça durante o meio círculo vermelho e desce no acerto.
- 08 depois: Morvath se abaixa durante a faixa e cruza a faixa com o corpo e o rastro.
- 02 depois: os invocados vêm num trote curvado.
- 10 antes e depois: a faixa esmeralda do Corte do Juízo aparece no trecho lento.

O que **não** foi julgado aqui (olho humano, `art-director` e `combat-feel-director`): se o tremor do andar sumiu a 60 qps
reais, se o trote dos invocados deixou de lembrar gazela, a qualidade das poses e o peso dos golpes. O som vai junto nos
vídeos normais, mas ninguém ouviu (WSL sem saída de som).
