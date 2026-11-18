# Pacote de direção de arte, etapa 1A: recompensas, HUD, Altar e Provação

Pranchas de referência (só locais, feitas por IA): `docs/art/ref/direcao_2026-11-17/pranchas/01-cartas.png`,
`02-atlas-icones.png`, `03-eventos.png`. Texto e números das telas vêm sempre do jogo (`data/text_pt.tres` e dados).

Capturas reais da Godot 4.7.2 (`tools/ui_lab.gd` e a partida com `--shot`), renderizador Compatibility em OpenGL na
placa de vídeo (d3d12 do WSL), porque a GPU do Forward+ estava em uso por outro agente: o fundo 3D sai um pouco
diferente do jogo no PC, a interface é a mesma. Antes = HEAD `fe07159`; depois = esta entrega. Cada caso em
1280 x 720 e 1920 x 1080. Comando de cada caso no fim.

| Caso | Antes | Depois | O que mudou |
|---|---|---|---|
| Bênçãos comum, rara e épica (Brasas, Toque da Geada, Maré de Luz) | `bless_720_before.jpg`, `bless_1080_before.jpg` | `bless_720_after.jpg`, `bless_1080_after.jpg` | título "Escolha uma bênção"; medalhões pintados das três; símbolo do HUD ao lado da ação |
| Elos (Vapor, Aurora Gelada, Chama Viva) e foco | `elo_720_before.jpg`, `elo_focus_720_before.jpg`, `elo_1080_before.jpg` | `elo_720_after.jpg`, `elo_focus_720_after.jpg`, `elo_1080_after.jpg` | origens com os glifos novos (Brasas com as três brasas); corrente só no Elo |
| Salmo da Sentinela entre duas Bênçãos | `psalm_720_before.jpg`, `psalm_1080_before.jpg` | `psalm_720_after.jpg`, `psalm_1080_after.jpg` | "Transforma: Círculo" com o símbolo do círculo do HUD; arco e "Aberto por" como antes |
| Troca lendária (Golpe em Brasa épica sai, Golpe de Geada lendária entra) | `trade_720_before.jpg`, `trade_1080_before.jpg` | `trade_720_after.jpg`, `trade_1080_after.jpg` | "Sai" e "Entra", nessa ordem, cada um com glifo, nome e raridade na cor dela |
| Texto longo e substituição (Flagelo lendária, Estilhaço, Especial firme substitui) | `long_720_before.jpg`, `long_1080_before.jpg` | `long_720_after.jpg`, `long_1080_after.jpg` | cabe no cartão; aviso de substituição como antes |
| Altar sem ouro | `altar_720_before.jpg`, `altar_1080_before.jpg` | `altar_720_after.jpg`, `altar_1080_after.jpg` | medalhões pintados (romã, velas, passagem); marca da recompensa no que se entrega e recebe; "Sem custo"; velas apagadas com "Faltam 75 de ouro". No antes, sem Bênção na mão, a romã também estava apagada; no depois a captura segura Brasas para mostrar a romã disponível |
| Provação | `trial_720_before.jpg`, `trial_1080_before.jpg` | `trial_720_after.jpg`, `trial_1080_after.jpg` | medalhão da Bênção sozinho no topo; selo rachado pintado no bloco da maldição |
| Selo da Provação no HUD e virada | `trial_seal_720_before.jpg`, `trial_won_720_before.jpg` | `trial_seal_720_after.jpg`, `trial_won_720_after.jpg` | sem mudança (já era da T5) |
| HUD com a ultimate pronta | `ult_720_before.jpg`, `ult_1080_before.jpg` | `ult_720_after.jpg`, `ult_1080_after.jpg`, `ult_1080_after_zoom.jpg` | anel fechado de luz esmeralda em volta do losango (antes só um pulso pálido que se repetia) |
| Porta com recompensa (Ouro, Difícil) | `door_720_before.jpg`, `door_1080_before.jpg` | `door_720_after.jpg`, `door_1080_after.jpg`, `door_1080_after_zoom.jpg` | moeda ao lado de "Ouro"; a divisa de "Difícil" desce para a linha dele |
| Loja (marcas das recompensas) | (sem antes) | `shop_720_after.jpg`, `shop_1080_after.jpg` | Bênção, cura, coração, gema da Magia e romã ao lado de cada nome, as mesmas das portas e do altar |
| Horda (`--stress=300`) | `stress_720_before.jpg`, `stress_1080_before.jpg` | `stress_720_after.jpg`, `stress_1080_after.jpg` | leitura do HUD com a multidão (nada novo cobre o herói) |

Comandos (scratch `cap.sh`, local): `ui_lab.gd -- --card-only --held= --offer=brasas,toque_geada,onda_maior --rarity=0,1,2`;
`--card-only --offer=vapor,aurora,chama_viva --focus-move`; `--psalm-card=sentinela`; `--card-only --trade
--held=golpe_brasa --held-rarity=2 --offer=golpe_geada,brasas,escudo`; `--card-only --held=toque_geada
--offer=flagelo,estilhaco,pesado_firme --rarity=3,0,1`; `--start=altar --altar --gold=0 --held=brasas`;
`--start=trial --trial`; `--start=shop --shop --gold=110`; partida: `--autopick --ultimate=cleave --ult-full
--shot-at=6`, `--start=fountain --shot-at=4`, `--bot --autopick --stress=300 --shot-at=9`, todos com `--seed=5 --nosave`.
