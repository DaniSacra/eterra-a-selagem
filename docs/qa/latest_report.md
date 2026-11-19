# Relatório de QA e desempenho: o exe que o Daniel testou (hub de 50 x 33 m, Santuário, descida, Morvath)

- **Data**: 2026-11-19. **Testado**: `arpg-3d` no **`d2ff05d`** ("Hub sign: goes under the hero..."), numa worktree
  isolada (`/home/dani/games/qa-d2ff05d`, apagada no fim) e o **próprio exe exportado** `build/windows/ASelagem.exe`
  (gerado às 18:14, depois do commit das 18:08), copiado para `C:\Users\danie\tools\qa-exe\` e rodado na RTX com
  `--nosave` (o save do Daniel não foi tocado). O exe do Linux `build/linux/ASelagem.x86_64` deu o mesmo `RESULT` que o
  editor (`--fixed-fps 60 --smoke=30 --seed=5`: só `fps` e `step_ms*` diferem).
- **Pedido do Daniel**: "ainda precisa de muitas melhorias", sem detalhe. Foco deste relatório: layout (o que está fora do
  lugar, cortado, sobreposto, pequeno, ilegível ou vazio).
- **Capturas**: `docs/qa/shots_d2ff05d/` (107 arquivos; JPG das telas inteiras, `crop_*.png` recortes em tamanho real,
  `sheet_*.jpg` folhas 2 x 2 só para ver junto). As do exe estão no estilizado (padrão do exe); `--look=classic` onde dito.
  Telas de laboratório (`m720_*`, `t720_*`, `u_*`) vêm do editor no mesmo commit pelo `tools/gpu.sh` (espelho próprio),
  com `--look=stylized`.

## Veredito

**Jogável e estável, mas não está pronto como "versão para avaliar a qualidade"**: nenhum P0 (nada trava, nenhum erro de
script na importação, 1159/1159 testes, o robô vence em 4 de 4 sementes de 600 s), porém o **Santuário (hub) tem
problemas de enquadramento que o Daniel vê nos primeiros segundos** (P1-1 a P1-4): na chegada duas das cinco estações
estão fora da tela e duas cortadas na borda, o Portal (a estação principal) fica cortado no topo, a Câmera Perto mostra
quase metade da tela de parede escura, e as estações são pequenas demais para a praça de 50 x 33 m. É provável que seja
boa parte do "muitas melhorias". O resto são P2 de legibilidade e de painéis com área vazia.

| Item | Resultado |
|---|---|
| Importação (`--import`) | 0 `SCRIPT ERROR`, 0 `Parse Error`; 4 linhas `ERROR` da fonte AlegreyaSans na 1ª importação de uma cópia limpa (a fonte é lida antes de importada; some na 2ª; benigno) |
| `tools/check.gd` | `CHECK ok`, 0 erros |
| `tools/test.sh` | 110 scripts, **1159/1159**, 0 arriscados (o `test_only_finishers_glint` não ficou arriscado), 2 avisos `Float/Int`, 2 `DEPRECATED` (`wait_frames`), vazamento no fim (29 ObjectDB, 19 recursos, 1 RID de Environment): conhecidos. **1 `SCRIPT ERROR` dentro de teste que passa**, ver P2-12 |
| `tools/title_flow_check.gd` / `map_flow_check.gd` | `FLOW ok` (título, hub, Portal, pausa, voltar ao hub e ao título, RB/LB do controle) / `MAP_FLOW ok` |
| `smoke.sh 300 --seed=5` | **sala 11 (Morvath) aos 272,0 s**, 6 Bênçãos, `max_alive` 8, `step_ms_avg` 0,31 |
| `smoke.sh 120 --start=boss --boons=25 --seed=5` | **vence aos 71,5 s** (fase 4 alcançada), vida 50/50 |
| `smoke.sh 600`, sementes 1, 2, 3, 7 | **4 vitórias**; Morvath aos 269, 267, 332, 219 s; 5 a 7 Bênçãos; `stuck` 0 em todas |
| `smoke.sh 120 --stress=300 --seed=5` | `step_ms_avg` 2,73, pico 21,9 (T5: 3,8 depois / 2,6 antes) |
| Capturas no exe na RTX | 60 (título, hub e as 5 estações, painéis, menu, Perto/Longe, clássico, todas as arenas, loja, Provação, Altar, Morvath fases 1 e 4, vitória, derrota, Configurações, Livro, Compêndio, mapa, Músicas, Compatibility) + 22 do laboratório |

## 1. Achados por gravidade

Dono sugerido entre parênteses. "720" = 1280 x 720, "1080" = 1920 x 1080.

### P0
Nenhum.

### P1 (layout do Santuário; o Daniel vê logo ao entrar)

**P1-1. Chegada ao Santuário: estações fora da tela ou cortadas, praça vazia.** Na chegada (câmera Longe, padrão) só se
vê o Portal e a fonte inteiros: o Vendedor aparece cortado na borda esquerda (só o toldo), a Árvore de Dons cortada na
borda direita, e o **Forjador e o Livro de Ahk nem aparecem**. O meio da tela é piso vazio com o herói pequeno embaixo; nada
diz para onde ir. Nas estações, as peças são minúsculas para a praça: a bigorna tem ~25 px de altura a 720, o atril do
Livro ~30 px, o balcão do Vendedor ~60 px (`hub_vendor_720`, `hub_book_720`).
- Capturas: `hub_arrive_1080.jpg`, `hub_arrive_720.jpg`, `sheet_hub_st.jpg`.
- Reproduzir: `ASelagem.exe -- --hub` (ou Iniciar no título), olhar a tela sem andar.
- Dono: environment-artist (escala das estações, peças que leem de longe) com gameplay-engineer (`HubPlan`: distância
  das estações ao centro, `CAM_TARGET`/`CAM_REACH`); critério do art-director.

**P1-2. Forjador: a estação não aparece quando se está nela.** Parado no ponto de uso do Forjador, a placa aparece mas
o forno (na parede oeste) fica fora da tela à esquerda; só a bigorna pequena se vê, e o herói fica a ~18% da borda.
- Captura: `hub_smith_720.jpg`.
- Reproduzir: `--hub --hero-at=smith` a 1280 x 720.
- Dono: gameplay-engineer (alcance da câmera do hub para o oeste, `CamFrame.hold` com `CAM_REACH` 13 m) ou
  environment-artist (trazer o forno para perto do ponto de uso).

**P1-3. Portal: a estação principal sai cortada no topo da tela.** Com o herói no Portal, o arco verde fica preso na borda
de cima nas duas câmeras: na Longe só a metade de baixo do portal aparece e o herói fica a ~20% do topo; na Perto a
placa "Portal da Descida" é desenhada **por cima do próprio arco do portal** (`hub_near_portal_720`).
- Capturas: `hub_portal_720.jpg`, `hub_portal_1080.jpg`, `hub_near_portal_720.jpg`, `hubuse_portal_720.jpg`.
- Reproduzir: `--hub --hero-at=portal` (e com `--cam=near`).
- Dono: gameplay-engineer (a câmera deveria subir para mostrar o portal: o ponto fixo segura mais do que a margem de
  18% pede no norte) e ui-ux-designer (placa do Portal por cima do arco na Perto).

**P1-4. Câmera Perto no Santuário: quase metade da tela é parede escura.** Na chegada com a câmera Perto, os ~45% de baixo
da tela são o muro de arrimo escuro sob a praça, e a escada de chegada desce para dentro dele (não leva a lugar nenhum).
- Captura: `hub_near_1080.jpg` (quadro de cima à esquerda de `sheet_hub2.jpg`).
- Reproduzir: Configurações > Vídeo > Câmera "Perto", entrar no Santuário (ou `--hub --cam=near`).
- Dono: gameplay-engineer (`CamRig.near` segue o herói sem limite ao sul no hub) e environment-artist (o que fica abaixo
  da praça e a escada de chegada).

### P2

**P2-1. Fios de ouro do piso do Santuário parecem linhas soltas.** Os fios que ligam a fonte às estações são riscos finos
que começam e terminam no meio do piso, longe das estações; leem como linhas de depuração. Também há uma linha reta
cruzando o piso de borda a borda na altura do terraço (oeste do terraço até o Vendedor).
Captura: `hub_arrive_1080.jpg`. Dono: environment-artist (`HubLook`, anel e fios).

**P2-2. Painéis com metade vazia.** Configurações Áudio (3 linhas e "Músicas") e Vídeo (4 linhas) num painel de altura
fixa com ~45% vazio; Como Jogar com faixa vazia acima e abaixo dos quatro passos; cartas de Elo com a metade de baixo vazia.
Capturas: `opt_720.jpg`, `t720_options_tab_video.jpg`, `howto_720.jpg`, `u_card_card.jpg`. Dono: ui-ux-designer.

**P2-3. Textos pequenos a 720.** Legenda "Maestria 2" sobre o 5º losango (~9 px), dica do rodapé da árvore de Dons
("Enter ou clique: equipar ou tirar. Esc: voltar.", ~9 px), legenda do mapa (~10 px) e "M fecha o mapa", "VOCÊ RECEBE
DEPOIS DE 3 LUTAS" nas cartas da Provação, preços da loja em rosa ("150 ouro, faltam 150", ~11 px), "Bênçãos da descida:
20" na pausa. Capturas: `play_hud_720.jpg`, `hubuse_tree_720.jpg`, `map_720.jpg`, `u_trial_trial.jpg`, `crop_shop_c720.png`,
`m720_pause_many.jpg`. Dono: ui-ux-designer.

**P2-4. Loja: a saída para Morvath parece um quinto item.** "A Câmara do Selo" usa disco dourado parecido com os da loja e
fica logo acima da fileira dos 4 itens. Capturas: `shop_720.jpg`, `crop_shop_c.png`. Reproduzir: `--start=shop`. Dono:
ui-ux-designer (placa) / gameplay-engineer (posição da saída em relação a `SHOP_SHIFT`). Obs.: na loja sem Bênçãos
aparecem 4 itens (sem romã), não 5; não conferi a regra.

**P2-5. Barras de vida e números de dano empilhados na multidão.** Na Ponte, quatro esqueletos juntos: barras se
sobrepõem e os números "50 50 20" ficam por cima das barras. Captura: `crop_bridge_r.png` (`bridge_1080.jpg`). Dono:
ui-ux-designer (`NumberTally`, barras).

**P2-6. Herói some sob as zonas de Bênção em Morvath com muitas Bênçãos.** Com 25 Bênçãos (só no teste
`--boons=25`), discos amarelo-claros grandes e um anel branco cobrem o herói na borda oeste. Numa partida normal (5 a 7
Bênçãos) não medi. Capturas: `boss_p4_720.jpg`, `boss_1080.jpg`. Dono: art-director (avaliar com uma partida real).

**P2-7. "Provação vencida" encosta na placa da porta.** A saudação no alto e a placa "Bênção / Guardião" ficam a ~10 px uma
da outra. Captura: `crop_trial_won.png` (`u_trial_trial_won.jpg`). Dono: ui-ux-designer.

**P2-8. Texto do HUD no alto sobre fundo claro.** "Sala 1 de 11 / Mapa [M]" sobre a cascata clara do Jardim: lê, mas com
pouco contraste. Captura: `crop_garden_top.png`. Dono: ui-ux-designer.

**P2-9. Compatibility: água da fonte do Santuário preta.** No OpenGL a água vira um disco preto (no Forward+ é azul e
clara). Capturas: `crop_compat_fount.png` contra `crop_sty_fount.png`; `compat_hub_1080.jpg`. Reproduzir:
`ASelagem.exe --rendering-driver opengl3 -- --hub`. Dono: environment-artist (`dark_water.gdshader` no Compatibility).

**P2-10. Nome do hub igual ao de uma arena.** O hub é "Santuário" e a arena é "Santuário Desmoronado"; o menu do hub diz
"SANTUÁRIO" e a tela de fim "Voltar ao Santuário". Provisório (D-H4), anotado para o Daniel decidir. Capturas:
`hubmenu_720.jpg`, `defeat_720.jpg`. Dono: Game Director.

**P2-11. O Livro aberto no Santuário tem "Descer às catacumbas"**, que desce direto sem a pergunta do Portal
(`hub.gd` 198 a 204). Duas portas de saída no hub, uma com confirmação e outra sem. Captura: `hubuse_book_720.jpg`. Dono:
ui-ux-designer.

**P2-12. `SCRIPT ERROR` dentro de um teste que passa.** `test_room_style.gd` `test_the_chamber_comes_back`:
`Invalid type in function 'restore_air' ... argument 2 (previously freed)` em `BossChamber._exit_tree`
(`boss_chamber.gd:506`): passa `_air_moon` já liberado a um parâmetro tipado. No jogo a cena inteira sai junta e não vi o
erro, mas o mesmo caminho existe. Reproduzir: `tools/test.sh -gselect=test_room_style`. Dono: environment-artist (checar
`is_instance_valid` antes da chamada).

**P2-13. Vendedor e Forjador sem conteúdo** ("A definir", só Voltar): conhecido (HUB-C/HUB-D), registrado porque o Daniel
encontra duas estações vazias de cinco. Captura: `hubuse_vendor_720.jpg`.

## 2. O que está bem (com evidência)
- Título a 720 e 1080 sem corte (`title_*.jpg`, `compat_title_720.jpg`).
- Placas das estações legíveis, com tecla real; com controle a tecla vira o botão A (`hub_book_pad_1080.jpg`).
- Painel do Portal, menu do hub (Continuar, Como Jogar, Compêndio, Configurações, Voltar ao título, Sair), Livro com os
  três lugares selados e o botão Compêndio (`hubuse_*`, `hubmenu_*`).
- Tela de vitória e de derrota com "Voltar ao Santuário" e "Descer de novo" (`boss_win_1080.jpg`, `defeat_*.jpg`); fluxo
  de volta ao hub coberto pelo `title_flow_check` e por `test_hub.gd`.
- Configurações > Vídeo com "Câmera: Longe/Perto" (`t720_options_tab_video.jpg`); Controles com Interagir em E
  (`t720_options_tab_controls.jpg`).
- Todas as arenas no estilizado sem nada fora do lugar nas capturas (Salão, Criptas, Fendas, Jardim A e B, Santuário,
  Ponte A e B, Runas A e B, Provação, Altar, loja, Câmara do Selo): `sheet_d1.jpg` a `sheet_d4.jpg`.
- F7 / clássico: hub, Cripta e Morvath no clássico sem problema de layout (`hub_classic_1080.jpg`, `classic_*`).
- Compatibility: Salão, Morvath e hub abrem e leem (fora a água, P2-9).

## 3. Desempenho (`tools/sty_probe.gd`, estilizado, 6 s medidos depois de 5 a 8 s, `--disable-vsync`)

| Cena | RTX 5060, 1920 x 1080, Alta: quadro / GPU (pior) / chamadas | Intel RaptorLake-S iGPU, 1280 x 720, Baixa: quadro / GPU (pior) |
|---|---|---|
| Santuário, Longe | 2,18 ms / 2,14 (6,66) / 500 | 14,80 ms / 14,50 (19,70) → ~68 qps |
| Santuário, Perto | 1,68 / 1,57 (6,73) / 511 | 11,79 / 11,51 (13,84) → ~85 qps |
| Salão (robô, semente 5) | 2,92 / 2,51 (7,51) / 652 | 17,63 / 17,16 (22,28) → ~57 qps |
| Criptas | 2,48 / 1,99 (6,97) / 591 | 14,24 / 13,79 (16,21) |
| Santuário Desmoronado | 3,07 / 2,61 (7,89) / 742 | 17,14 / 16,75 (18,97) |
| Fendas | 3,42 / 2,09 (7,03) / 638 | 15,36 / 14,98 (16,44) |
| `--stress=300` | **26,67** / 5,02 (13,12) / 805 | 56,75 / 56,12 (56,64) |

Memória de vídeo: 254 MB no hub, até 318 MB nas arenas (RTX); 107 a 174 MB na iGPU. O hub é a cena mais barata das duas
placas. No `--stress=300` da RTX o quadro (26,7 ms) é bem maior que GPU + CPU de desenho (5,0 + 1,4): o tempo vai na
simulação de 300 inimigos ou na outra captura que rodava ao mesmo tempo na mesma placa (dois espaços do `gpu.sh`
ocupados por outros agentes); só modo de teste, sem tetos de inimigos. Não comparei com um commit base (nada mudou
no desempenho neste pedido).

## 4. Limitações
- O exe de Windows é de janela (sem console): o log dele sai vazio, então `SCRIPT ERROR` em tempo de execução só foi
  procurado nas execuções do editor (laboratórios, testes, robô): nenhum, fora o P2-12.
- Capturas com `--bot` escondem o 5º losango (ultimate) de propósito (`hud.gd:475`); conferido sem o robô em
  `play_hud_720.jpg`. `--pad` só existe no hub: o HUD da partida com glifos de controle não foi capturado (coberto pelos
  testes de troca de dispositivo e pelo `title_flow_check` com eventos reais de controle). Nenhum controle físico, nenhum
  teste com gente, sem som ouvido.
- Máquina carregada: outros agentes rodavam dezenas de partidas do robô e capturas na GPU ao mesmo tempo. Os picos de
  `step_ms_peak` de 550 a 1595 ms nas sementes 1 e 3 foram disputa de CPU: a semente 1 sozinha com `--trace-steps` deu
  pico de 10,9 ms (`horde`).
- Capturas a 1920 x 1080 e 1280 x 720 em janela (`--resolution`), não em tela cheia; a GPU é a RTX 5060 do notebook do
  Daniel e a iGPU Intel dele; celular não medido.
- A Provação e o Altar (cartas) e a carta de Bênção vêm do `tools/ui_lab.gd` no editor, não do exe (o exe não abre essas
  telas por opção); o código é o mesmo commit.
