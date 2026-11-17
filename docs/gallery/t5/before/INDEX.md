# T5, antes: todas as salas e telas (commit 5dfe97f, branch arpg-3d)

Capturas reais do jogo em 2026-11-17, na placa de vídeo (RTX 5060, Godot 4.7.2 para Windows, Vulkan, Forward+, a
renderização do desktop), 1920 x 1080, com `--nosave` (sem save: Maestria 1, Compêndio vazio, salvo onde dito). As
lutas são jogadas pelo robô (`--bot`, semente 5 salvo onde dito); as Bênçãos pegas pelo robô são as primeiras
oferecidas (`--autopick`). Nada aqui é imagem gerada por IA, exceto o que o próprio jogo mostra: o fundo da tela de
título e o retrato do herói no HUD são artes do jogo feitas com IA (declarado em `docs/steam-ia.md`), e os modelos do
herói, dos inimigos e da Emeth vieram do Meshy. Arquivos em JPG de qualidade alta (convertidos do PNG capturado).

Versão do código: todas as 66 são do commit 5dfe97f. Durante a sessão outro agente ressincronizou o espelho comum da
GPU com outro código (a correção da ultimate do T5); as 9 capturas feitas depois disso (23b, 23c, 26, 32, 32b, 42, 43,
46, 51b) foram refeitas num espelho só do 5dfe97f (`git archive 5dfe97f`, em `C:\Users\danie\tools\eterra-gpu-t5base`),
e a sala 10 refeita nele saiu idêntica à do lote principal (conferência de que o lote principal era o 5dfe97f).

Comando base de cada captura de jogo: `tools/gpu.sh shot <saida> <opções> --shot-at=N` (o mesmo que o gpu.sh roda, sem
ressincronizar o espelho a cada vez). Telas de cartas, Compêndio, loja e eventos: `tools/ui_lab.gd` (opções na linha).

## Telas fora da partida
| Arquivo | O que mostra | Opções |
|---|---|---|
| 01_titulo.jpg | Tela de título (arte de fundo pintada, botões reais do jogo) | `--title` |
| 02_tela_guerreiro_inicio.jpg | Tela "O Guerreiro" num save novo: Maestria 1, árvore de Dons trancada, ultimates trancadas | `--title --screen=hero` |
| 03_tela_guerreiro_maestria20_dons.jpg | Tela "O Guerreiro" com Maestria 20 (2470 XP), Dons equipados (losangos cheios na cor do ramo), Passo Encadeado em foco e a Voragem escolhida | `--screen=hero --hero-xp=2470 --hero-equip=... --hero-ult=vortex` |
| 04_como_jogar.jpg | Como Jogar: teclas de teclado e controle lidas do mapa, botões Compêndio e Créditos | `--screen=howto` |
| 05_creditos.jpg | Créditos (aberto pelo Como Jogar). Saiu em 1280 x 720 | script de captura temporário (abre a tela pelo próprio jogo; apagado depois) |
| 06_configuracoes.jpg | Configurações (volume, janela, qualidade gráfica, Conforto, teclas) | `--screen=options` |
| 07_juramentos.jpg | Juramentos (abertos depois da 1ª vitória), todos desligados | `--screen=juramentos --wins=1` |
| 08a_compendio_dons.jpg | Compêndio, aba Dons (Maestria 4: 7 Dons conhecidos, o resto "???") | `--screen=codex --hero-xp=600` |
| 08b_compendio_bencaos.jpg | Compêndio, aba Bênçãos, com dados de exemplo (11 de 26 encontradas) | `ui_lab --codex=boons` |
| 08c_compendio_elos.jpg | Compêndio, aba Elos (2 de 6 formados, receitas) | `ui_lab --codex=elos` |
| 08d_compendio_salmos.jpg | Compêndio, aba Salmos (2 descobertos, 2 com pista) | `ui_lab --codex=psalms` |
| 08e_compendio_inimigos.jpg | Compêndio, aba Inimigos (derrotados e elites) | `ui_lab --codex=enemies` |
| 08f_compendio_morvath.jpg | Compêndio, aba Morvath (fases alcançadas) | `ui_lab --codex=morvath` |
| 08g_compendio_arenas.jpg | Compêndio, aba Arenas (4 de 8 visitadas) | `ui_lab --codex=arenas` |
| 08h_compendio_golpes.jpg | Compêndio, aba Golpes, sem save (golpes ainda "???") | `--screen=moves` |

## Salas (luta com o robô)
| Arquivo | O que mostra | Opções |
|---|---|---|
| 10_sala_salao_catacumbas_abertura.jpg | Salão das Catacumbas, sala 1 (abertura), luta com esqueletos | `--bot --autopick --shot-at=9` |
| 11_sala_cripta_A.jpg | Cripta dos Esquecidos, variante A, luta | `--arena=crypt --variant=0` |
| 12_sala_cripta_B.jpg | Cripta dos Esquecidos, variante B (ossuário divisor), luta | `--arena=crypt --variant=1` |
| 13_sala_fendas_A.jpg | Salão das Fendas, variante A, luta | `--arena=rift --variant=0 --shot-at=7` |
| 13x_quadro_impacto_fendas_A.jpg | Salão das Fendas A no exato quadro de impacto preto e branco de um Ômega (efeito do jogo, 1 quadro) | `--arena=rift --variant=0 --shot-at=9` |
| 14_sala_fendas_B.jpg | Salão das Fendas, variante B (ponte de cima caída), luta | `--arena=rift --variant=1` |
| 15_sala_jardim_A.jpg | Jardim das Raízes Mortas, variante A, luta | `--arena=garden --variant=0` |
| 16_sala_jardim_B.jpg | Jardim das Raízes Mortas, variante B, luta | `--arena=garden --variant=1` |
| 17_sala_santuario_A.jpg | Santuário Desmoronado, variante A, luta comum (sem guardião) | `--arena=sanctuary --variant=0` |
| 18_sala_santuario_B.jpg | Santuário Desmoronado, variante B (buraco para a cripta), luta comum, aviso de linha do besteiro | `--arena=sanctuary --variant=1` |
| 19_sala_ponte_A.jpg | Ponte dos Condenados, variante A, luta (Ômega da lança no quadro) | `--arena=bridge --variant=0` |
| 20_sala_ponte_B.jpg | Ponte dos Condenados, variante B (ponte longa), luta, avisos no chão | `--arena=bridge --variant=1` |
| 21_sala_runas_A.jpg | Câmara das Runas Instáveis, variante A, entre dois disparos (runas apagadas) | `--arena=runes --variant=0 --shot-at=9` |
| 21b_sala_runas_A_preparo.jpg | Câmara das Runas A com as runas acesas no aviso (âmbar) | `--shot-at=3.8` |
| 21c_sala_runas_A_golpe.jpg | Câmara das Runas A no disparo das runas (lajes claras) | `--shot-at=4.3` |
| 22_sala_runas_B.jpg | Câmara das Runas Instáveis, variante B (pedra quieta no meio), runas apagadas | `--arena=runes --variant=1` |
| 22b_sala_runas_B_preparo.jpg | Câmara das Runas B com runas acesas no aviso | `--shot-at=3.8` |
| 23_sala_guardiao.jpg | Guardião: Sacerdote dos Mortos no Santuário Desmoronado A, barra do guardião no topo | `--start=miniboss --boons=5 --seed=5` |
| 23b_sala_guardiao_semente6.jpg | Guardião: Sacerdote dos Mortos no Santuário Desmoronado B | `--start=miniboss --boons=5 --seed=6` |
| 23c_sala_guardiao_semente7.jpg | Guardião: Cavaleiro esqueleto no Santuário Desmoronado B | `--start=miniboss --boons=5 --seed=7` |
| 24_sala_fonte.jpg | Fonte (no salão), com as duas portas abertas e placas "Ouro, Difícil" e "Bênção, Difícil" | `--start=fountain --shot-at=4` |
| 25_sala_loja.jpg | Loja (no salão) com as placas dos itens, sem ouro ("faltam N"), e a porta para a Câmara do Selo | `--start=shop --boons=3` |
| 26_sala_provacao.jpg | Câmara da Provação: bloco com a rachadura em X, placa "Provação, escolha uma carta" | `--start=trial --shot-at=2.5` (sem robô) |
| 27_sala_altar.jpg | Altar Esquecido com a placa e as três portas (glifos: chama, divisa de "Difícil") | `--start=altar --shot-at=3` |

## Morvath, Câmara do Selo
| Arquivo | O que mostra | Opções |
|---|---|---|
| 30_morvath_fase1_foice.jpg | Fase 1 "O Despertar": Foice Sepulcral acertando o meio círculo | `--start=boss --boons=25 --shot-on=boss:scythe_strike` |
| 31_morvath_fase2_ritual.jpg | Fase 2 "O Ritual dos Mortos": escudo de vidro espectral, mortos erguidos, "Derrube os mortos" e os losangos do ritual na barra | `--boss-hp=0.67 --shot-on=boss:ritual --shot-after=2.5` |
| 32b_morvath_fase3_luta.jpg | Fase 3 "A Maldição dos Condenados", luta | `--boss-hp=0.30 --boons=5 --shot-at=8` |
| 32_morvath_fase3_maldicao.jpg | Fase 3: a maldição acaba de pegar no herói | `--boss-hp=0.3 --boss-only=curse --shot-on=boss:cursed --shot-after=0.6` (sem robô) |
| 33_morvath_fase4_tempestade.jpg | Fase 4 "O Último Suspiro": Tempestade das Seis Almas, portal espectral | `--boss-hp=0.16 --shot-on=boss:storm_fire` |
| 34_morvath_vitoria_selagem.jpg | Vitória: Morvath caído, a selagem do portal e a frase da vitória | `--boss-hp=0.02 --shot-on=boss:victory --shot-after=1.6` |

## HUD, cartas e eventos dentro da partida
| Arquivo | O que mostra | Opções |
|---|---|---|
| 40_hud_ultimate_carregada.jpg | HUD em combate com a ultimate (Corte do Juízo) cheia no 5º losango (tecla R) | `--ultimate=cleave --ult-full --shot-at=7` |
| 41_ultimate_corte_do_juizo.jpg | A ultimate Corte do Juízo acertando (faixa esmeralda) | `--shot-on=ult --shot-after=0.15` |
| 42_maldicao_no_heroi.jpg | Maldição de Morvath no herói (runas, névoa violeta, selo no HUD, especial travado) | `--boss-hp=0.3 --boss-only=curse --shot-on=boss:cursed --shot-after=1.5` (sem robô) |
| 43_sala2_nome_da_arena.jpg | Entrada na sala 2 (Salão das Fendas): o nome da arena aparece no alto | `--bot --autopick --shot-at=30` |
| 44_pausa.jpg | Menu de pausa sobre a luta | script de captura temporário (abre a tela pelo próprio jogo; apagado depois) |
| 45_bencao_raridades.jpg | Escolha de Bênção: três cartas Comum, Rara e Épica | `ui_lab --card-only --rarity=0,1,2` |
| 46_bencao_troca_lendaria.jpg | Escolha de Bênção com uma troca que sobe para Lendária ("Sobe uma raridade") | `ui_lab --card-only --rarity=3,0,1 --upgrade=1,0,0` |
| 47_elo_cartas.jpg | Escolha de Bênção com Elos: Vapor e Aurora Gelada (corrente com as duas origens) | `ui_lab` |
| 47b_saudacao_bencao_nova.jpg | Depois de tomar o Elo: saudação "Bênção nova: Brasas" no alto (em fila antes do "Elo formado") | `ui_lab` |
| 47c_pausa_painel_bencaos.jpg | Pausa, painel "Suas Bênçãos" com raridade, nível e o Elo Vapor | `ui_lab` |
| 48_carta_salmo.jpg | Carta de Salmo (Salmo da Sentinela, "Salmo descoberto") entre duas Bênçãos | `ui_lab --psalm-card=sentinela` |
| 48b_aviso_salmo_descoberto.jpg | Aviso "Salmo descoberto: Salmo da Sentinela" sobre a luta | `ui_lab --psalm-card=sentinela` |
| 49_tela_provacao.jpg | Tela da Provação: três cartas (Bênção em cima, maldição embaixo) | `ui_lab --start=trial --trial` |
| 49b_provacao_selo_hud.jpg | Depois da escolha: selo da maldição "Mais mortos" no HUD, portas abertas | `ui_lab --trial` |
| 49c_provacao_vencida.jpg | "Provação vencida" com a Bênção ganha (Magia Ampla) | `ui_lab --trial` |
| 50_tela_vitoria.jpg | Tela de vitória ("Morvath foi selado"), Bênçãos levadas, números e Maestria | `--boss-hp=0.02 --shot-on=end` |
| 51_tela_derrota.jpg | Tela de derrota: "Derrotado por: Esqueleto besteiro", "Sala 3 de 11, Salão das Fendas" | `--arena=crypt --shot-on=end` |
| 51b_tela_derrota_morvath.jpg | Tela de derrota na luta contra Morvath | `--start=boss --hero-hp=4 --shot-on=end` |
| 52_tela_altar.jpg | Tela do Altar Esquecido: as duas trocas (uma apagada com o porquê) e "Seguir em frente" | `ui_lab --start=altar --altar --gold=100` |
| 53_loja_placas.jpg | Loja com as placas dos 5 itens em 3 grupos, com 110 de ouro ("faltam N" nos caros) | `ui_lab --start=shop --shop --gold=110` |
| 54_laje_provacao_portas.jpg | Laje da Provação na sala da fonte ("Custa 12 de vida") e porta com placa "Ouro, Difícil" | `ui_lab --start=fountain --slab --hero-hp=30` |

## O que não foi capturado, e por quê
- "Elo formado" (a saudação do Elo): sem save, a primeira saudação na fila é "Bênção nova" (Brasas, nunca vista no
  Compêndio), e a do Elo só vem depois; a captura do `ui_lab` pega a primeira (`47b`). O Elo aparece nas cartas (`47`) e
  no painel da pausa (`47c`).
- Portas com placas no fim de uma sala de luta: o robô sai pela porta logo que ela abre, então as portas aparecem nas
  salas sem luta: fonte (`24`), altar (`27`, glifo de chama e divisas de "Difícil"), loja (`25`, três divisas para a
  Câmara do Selo) e a laje da Provação (`54`).
- Créditos saíram em 1280 x 720 (a tela de título aplica o tamanho de janela do save padrão quando aberta por script);
  as outras 65 imagens estão em 1920 x 1080.
- A tela de título, a do Guerreiro e o Compêndio sem save mostram o estado de um jogador novo; as abas Bênçãos a Arenas
  usam dados de exemplo do `tools/ui_lab.gd` (algumas coisas encontradas, outras "???").
- Toque (celular) e o navegador (Compatibility) não foram capturados: o pedido era o jogo de PC na placa de vídeo.
