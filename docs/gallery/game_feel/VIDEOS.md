# Vídeos de game feel (diretriz do Daniel de 2026-11-16, seção Testes)

Autor: `qa-performance`, 2026-11-16, commit `beb6c27`. Gravados pelo Movie Maker da Godot 4.7.2 de Windows na placa do
Daniel (RTX 5060, Vulkan, Forward+), **1920 x 1080, câmera do jogo, 30 quadros por segundo, com o som que o jogo mistura**
(os `0_25x` sem som). Nada editado além de cortar o começo e o fim e converter (`ffmpeg -c:v libx264 -preset slow -crf 28
-c:a aac -b:a 160k`). Nenhum quadro gerado ou retocado.

Como foi gravado:
- `tools/movie.sh <saída.avi> <quadros> [opções do jogo]` (`MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-qa`): Movie Maker a
  1080 (ver o cabeçalho do script: o Movie Maker usa o tamanho da janela do projeto, então o script põe um `override.cfg`
  só no espelho).
- (a) a (d) e (g) têm **um roteiro de entrada fixo**, não o robô: `PRE="-s res://tools/feel_driver.gd"` e `--feel=<nome>`
  (`tools/feel_driver.gd`, roteiros em `SCRIPTS`; `tools/feel_driver_bot.gd` aperta os botões num controle virtual, como o
  robô, com as direções da tela giradas pela câmera como o teclado). "fight" anda até o inimigo mais perto e toca a
  sequência (L ataque, d esquiva) sem a esquiva automática do robô, para o golpe e a reação ficarem claros.
- (e) e (f) são o robô de verdade (`--feel=bot` só repassa ao robô do jogo), com reação humana `--bot-reaction=0.25`.
- Os grupos de (b) a (e) vêm do `--stress=N --stress-ids=...` (nascem de 4 a 20 m do herói, sem o teto de inimigos das
  salas) na sala da loja (`--start=shop`), que é o Salão das Catacumbas vazio. O herói tem vida alta (`--hero-hp`), por isso
  a barra mostra 999 ou 200: só para não morrer no meio da tomada.
- (g) foi gravado a 120 quadros por segundo do relógio do jogo e tocado a 30 (`setpts=4*PTS`): cada quadro do vídeo é um
  quadro do jogo, sem quadros inventados.

| Vídeo | Duração | Comando (depois de `MIRROR=... PRE="-s res://tools/feel_driver.gd" tools/movie.sh <saída.avi> <quadros>`) | O que observar |
|---|---|---|---|
| `a_movimento_esquiva.mp4` | 15,5 s | `480 --bot --start=shop --seed=5 --feel=move` | arranque e parada (há aceleração ou é instantâneo?), virada de 180 graus, esquiva parada e em movimento, duas esquivas seguidas (só 1 carga), corrida segurando a esquiva (6,5 a 8,3 s), trocas rápidas de direção, a câmera adiantando para onde ele anda; som dos passos e da esquiva |
| `b_combo_finalizador.mp4` | 12,5 s | `660 --bot --start=shop --seed=5 --hero-at=2,4 --hero-hp=999 --stress=8 --stress-ids=skeleton_elite,guard,skeleton,skeleton --feel=combo` | o ataque de três golpes do começo ao fim (1,0 s e 2,6 s, já com os inimigos chegando), depois em sequência sobre o grupo: o ritmo entre os golpes (toque a cada 0,25 s, 0,7 s de pausa), o avanço que puxa até o inimigo, a meia-lua do finalizador, o brilho de antecipação, o hit stop, o número somado, a armadura amarela do esqueleto de elite quebrando ("Atordoado") e o Escudo bloqueando |
| `c_acertos_reacao.mp4` | 11 s | `600 --bot --start=shop --seed=5 --hero-at=2,4 --hero-hp=999 --stress=7 --stress-ids=skeleton,runner,guard,skeleton_elite --feel=hits` | acertos de perto: o pisca claro e morno no corpo, a inclinação para trás, o empurrão, o corpo arremessado ao morrer, a câmera lenta do último abate e se cada golpe "pesa" pelo som; os avisos vermelhos de quem ataca o herói no meio do grupo |
| `d_especial_circulo_omegas.mp4` | 17 s | `630 --bot --start=shop --seed=5 --hero-at=2,4 --hero-hp=999 --stress=10 --stress-ids=skeleton,guard,skeleton_elite,skeleton --feel=abilities` | especial (seta, 2,2 e 2,9 s), círculo de luz (4,8 s), Ômega do ataque segurando 1,0 s (7 s; a câmera fecha 8% na carga), Ômega do especial segurando 0,8 s (10 s; a lança), Ômega do círculo segurando 0,9 s (12,4 s; explode no fim), a barra de Magia caindo 20 + 10 + 20; se cada habilidade se distingue das outras pela forma e pelo som |
| `e_grupo_misto.mp4` | 16 s | `750 --bot --start=shop --seed=5 --hero-hp=200 --bot-reaction=0.25 --stress=8 --stress-ids=skeleton,runner,mage,archer,guard,priest --feel=bot` | o robô contra 8 de seis papéis (esqueleto, corredor, feiticeiro, besteiro, Escudo, sacerdote): leitura dos avisos de cada um no meio da luta, tiros de longe, o herói no meio da multidão (raio-x), números, a sala esvaziando; o robô sai pela porta aos 16 s |
| `f1_morvath_despertar.mp4` | 22 s | `660 --bot --start=boss --seed=5 --boons=6 --hero-hp=200 --bot-reaction=0.25 --boss-hp=1.0 --feel=bot` | fase 1: entrada (sem coluna, com o aro), a Foice Sepulcral em meio círculo com o aviso, as Lâminas das Almas, a investida; a reação de Morvath aos golpes (pisca até 0,8, sem branco) |
| `f2_morvath_ritual.mp4` | 22 s | o mesmo com `--boss-hp=0.6` | fase 2: o Ritual dos Mortos (escudo de vidro espectral, 4 mortos, os losangos na barra, "Derrube os mortos"), golpe no escudo só faísca, Erupções Sepulcrais com o miolo vermelho, o escudo se partindo |
| `f3_morvath_maldicao_e_fase4.mp4` | 22 s | o mesmo com `--boss-hp=0.3` | fase 3: a Maldição (projétil, runas na cintura do herói, Emeth com veios violeta, especial travado) e, aos 12 s, a passagem para a fase 4 |
| `f4_morvath_ultimo_suspiro.mp4` | 15 s | `660 --bot --start=boss --seed=5 --boons=0 --hero-hp=200 --bot-reaction=0.25 --boss-hp=0.14 --feel=bot` | fase 4: a Tempestade das Seis Almas (cunhas com a ordem de saída), o portal inquieto, a morte de Morvath, a selagem e a tela de vitória (a partir dos 12 s). Com 14% da vida a fase é curta: o robô a derruba em uns 10 s |
| `g_combo_finalizador_0_25x.mp4` | 25 s (6,25 s de jogo) | `FPS=120 ... 840` com as opções de (b); `ffmpeg -an -vf setpts=4*PTS -r 30 -t 25` | quadro a quadro: antecipação (há pose de preparo antes do corte?), o quadro do impacto (o pisca, o hit stop, a fita do corte sincronizada com a lâmina?), a recuperação (quanto tempo até poder andar), a meia-lua do finalizador e onde ela nasce em relação ao corpo |
| `g_acertos_reacao_0_25x.mp4` | 25 s (6,25 s de jogo) | `FPS=120 ... 960` com as opções de (c); idem | a reação do inimigo quadro a quadro: o pisca (só o 1º quadro de um golpe forte vai ao marfim), a inclinação de 0,1 s, o empurrão, a morte e o arremesso, a câmera lenta e o desfoque do último abate |

## Observações do QA (o que se vê, sem julgar game feel; a avaliação é do Game Director, do `art-director` e do Daniel)

- Em (b) e (c) os inimigos do `--stress` chegam em 1 a 2 s, então o ataque "no ar" do roteiro já pega gente; o primeiro
  combo sem ninguém por perto só aparece limpo em (g) por alguns quadros.
- Em (b) a meia-lua do finalizador aparece a uns 2 m do corpo do herói, na direção do golpe (quadros de 1,1 a 1,3 s do
  `g_combo`): conferir com o `art-director` se é o desenho pretendido.
- Com 8 a 10 inimigos de perto (b, c, d) o chão sob o herói fica coberto de avisos vermelhos sobrepostos; o herói continua
  legível pelo anel e pelo raio-x.
- (f4): com `--boons=0` e 14% da vida Morvath cai em uns 10 s; para ver a fase 4 inteira, gravar de novo com
  `--boss-hp=0.15 --hero-hp=200` e sem dano do herói (não há opção para isso hoje) ou deixar o robô longe (`--bot-kite`).
- Os sons são os provisórios sintetizados e o Kenney Impact (`CLAUDE.md`); música desligada.

## Limitações

- O roteiro de entrada não é gente: os toques têm ritmo fixo e mira automática no inimigo mais perto. Latência entre o
  comando e a ação, e o que se sente no controle, não se medem em vídeo; pedem o teste humano.
- A vida alta do herói tira o risco; a luta com o robô vence rápido demais para mostrar a pressão real.
- Câmera do jogo a 1080 com a escala do Windows (o 3D é desenhado em 2880 x 1620 e reduzido).
