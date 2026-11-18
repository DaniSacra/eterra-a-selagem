# T5, depois: as salas e telas (conteúdo do 579fe89, branch arpg-3d)

Capturas reais do jogo em 2026-11-17 pelo `qa-performance`, na placa de vídeo (RTX 5060, Godot 4.7.2 para Windows,
Vulkan, Forward+), 1920 x 1080, `--nosave`, **mesma numeração e mesmas opções de `../before/INDEX.md`** (o antes é o
`5dfe97f`). Nada aqui é imagem gerada por IA, além do que o próprio jogo mostra (fundo do título e retrato do HUD,
declarados em `docs/steam-ia.md`). JPG convertido do PNG capturado. Cópia em
`C:\Users\danie\Downloads\ASelagem-prints\after\`.

**Versão**: espelho `C:\Users\danie\tools\eterra-gpu` sincronizado com o `620a21e` às 21:55 (scripts, dados, cenas e
assados conferidos por conteúdo) mais a correção do Q-T5-2 em `scripts/game/game.gd`, commitada depois como `579fe89` (a tela de fim
só mostra XP que é gravado): o conteúdo é o do `579fe89`. Por isso a `50` não mostra mais "+220 XP".
Lote: `/home/dani/tools/t5qa/stills.sh` (as opções de cada uma estão lá e no INDEX de antes).

## Mudadas pelo T5 (olhar primeiro)
| Arquivo | O que mostra | Diferença para o antes |
|---|---|---|
| 01_titulo.jpg | Tela de título | igual na imagem (a música nova não aparece em captura) |
| 40a_hud_ultimate_trancada.jpg | Sem `--bot`, Maestria 1: 5º losango com cadeado e "Maestria 2" em cima; esqueletos batendo com o corpo | novo (antes o losango nem aparecia) |
| 40b_hud_ultimate_carregando.jpg | Corte do Juízo carregando aos 12 s (nível de ouro velho parcial no losango) | novo; opções: `--bot --autopick --seed=5 --ultimate=cleave --shot-at=12` |
| 40c_hud_ultimate_pronta.jpg | Carga cheia, sem robô: "Pronta" sobre o losango, que pulsa | novo; `--play --seed=5 --ultimate=cleave --ult-full --hero-hp=9999 --shot-at=1.5` |
| 40_hud_ultimate_carregada.jpg | Mesmo comando do antes (`--ult-full --shot-at=7`): o robô já usou a ultimate (o losango recomeça a carga) | o robô agora solta antes dos 7 s |
| 41_ultimate_corte_do_juizo.jpg | Corte do Juízo acertando | igual |
| 41b_ultimate_voragem.jpg | Voragem 0,6 s depois de solta | novo (`--ultimate=vortex --shot-on=ult --shot-after=0.6`) |
| 26_sala_provacao.jpg | Câmara da Provação com a placa | texto da placa novo |
| 27_sala_altar.jpg | Altar Esquecido com a placa e as portas | texto novo |
| 49_tela_provacao.jpg | Três cartas: medalhão da Bênção com o losango rachado, "Você recebe depois de N lutas", "Você carrega nas próximas N lutas" | telas do T5 (A-T5-5) |
| 49b_provacao_selo_hud.jpg | Selo da maldição no HUD depois da escolha | igual |
| 49c_provacao_vencida.jpg | "Provação vencida" | igual |
| 52_tela_altar.jpg | Altar: "Você entrega / Você recebe", selos (romã, vela, arco aberto), "Seguir em frente" | telas do T5 (A-T5-6) |
| 54_laje_provacao_portas.jpg | Placa da laje: "Pisar custa 12 de vida", "Uma Bênção forte, com uma maldição", "Para recusar, não pise" | texto novo (A-T5-7) |
| 07_juramentos.jpg | Juramentos com "Descer" em foco | antes o foco estava em "Mais Elites" (cursor do Windows sobre a lista; ver o relatório, Q-T5-3) |
| 50_tela_vitoria.jpg | Vitória sem save: sem "+XP" nem barra de Maestria | antes "+220 XP" sem save (Q-T5-2; corrigido no `579fe89`) |

## As outras (mesmas opções do antes)
02, 03, 04, 06, 08a a 08h (telas fora da partida); 10 a 25 (salas, guardião, fonte, loja; 13x é o quadro de impacto
preto e branco, 21b, 21c e 22b as runas acesas); 30 a 34 (Morvath, as quatro fases e a vitória); 43 (nome da sala 2);
45 a 48b (cartas, Elo, Salmo); 51b (derrota diante de Morvath); 53 (loja com 110 de ouro).

Diferenças de opção: `34` com `--shot-at=0.3` (com 2% de vida o robô vence antes dos 2 s padrão e o `--shot-on=boss:victory`
perdia o momento); `50` com `--shot-after=1.5` (a tela ainda entrava).

## Não capturadas
- `05_creditos` e `44_pausa`: no antes vieram de um script temporário apagado; não refeitos.
- `51_tela_derrota` (`--arena=crypt --shot-on=end`): três tentativas, inclusive com `--hero-hp=6` e `--shot-at=0.3`, sem
  a tela de fim em 150 s; a `51b` mostra a tela de derrota.
