# Backlog de A Selagem

- **Data**: 2026-11-18 (fim do ciclo). **Autor**: game-director (oitava revisão, reescrita; substitui a de 2026-11-16/17).
  **Commit lido**: `dd1f5ba` (HEAD de `arpg-3d`), com `git log --since=2026-11-17` (43 commits: T5, T5b, sala de música,
  pacote de arte 1A, 1B, 2 e 4, Créditos fora do jogo, auditoria e C1 de assets, corredor no chão).
- **Pedido do Daniel**: "passa todos os agentes para gerar backlog para o diretor do jogo, vamos refinar mais ainda o
  jogo"; meta: "uma mecânica perfeita e gostosa de jogar como no Hades 2", arte no molde do Ember & Blade, identidade de
  Eterra.
- **Fontes lidas**: os 7 relatórios de `docs/reports/2026-11-18/` (`combat_feel.md`, `gameplay.md`, `art.md`,
  `environment.md`, `ui.md`, `qa.md`, `assets.md`, com as capturas), a auditoria de arte em montagem
  `docs/gallery/audit_2026-11-18/AUDITORIA.md` (seções de Morvath, identidade e inimigos ainda vazias), `docs/qa/t5b_boss_fight.md`,
  `docs/qa/asset_report.md`, o backlog anterior e o `CLAUDE.md`. Capturas abertas por mim: `art/shop.jpg`, `art/boss3.jpg`,
  `ui/shop_720_shop.jpg`.
- **Rodado pelos agentes nesta rodada** (não por mim): `tools/check.gd` ok; `tools/test.sh` **992/992** em 4 rodadas;
  `title_flow_check` ok; sonda de game feel **40/40**; 24 descidas do robô (reação 0,25) sem erro e sem ninguém preso.
- **Atualização de 2026-11-18 (game-director, commit lido `2057516`)**: pedido do PO "Descida de Valmor" (mapa ramificado
  gerado por semente no começo da descida, consultado no Livro de Ahk com `M`). Entram as entregas MAP-01 a MAP-09, o
  ciclo **DV-1** (seção 3), as perguntas Q-25 a Q-27 (seção 4) e a ordem nova (seção 5). O PO escreveu "Akh"; a grafia
  do cânone é **Ahk**. Lidos para isto: `run_map.gd`, `rooms.gd`, `stage_def.gd`, `trials.gd`, `door_glyph.gd`, `hud.gd`,
  `controls.gd`, `test_descent.gd`, o `_stage` do `make_data.gd`, `comparativo.md` e o `art_polish_backlog.md`. Nada
  rodado (só planejamento).

## Estado do jogo em 5 linhas

1. **A mão está no molde do Hades II e estável**: sonda 40/40, 992 testes, nenhum P0 em nenhum dos 7 relatórios; robô vence
   7 de 8 com Maestria 1, chega a Morvath aos 200 a 320 s com 5 a 8 Bênçãos.
2. **O T5 e o T5b se sustentam**: aviso enche no quadro do dano em 160 golpes medidos, ninguém pula mais (feiticeiro,
   besteiro e corredor com pés no chão), Morvath sem estalos de giro.
3. **O que tira o "gostoso" agora é justiça e variedade, não a mão**: orbes do feiticeiro são 33% dos golpes que o PO levou,
   o corredor bate com 0,7 s de aviso (Hades 1,5), a fase 1 de Morvath é a foice em laço, elites só ganham armadura, e uma
   regra está quebrada (Provação tardia nunca paga a Bênção).
4. **Arte**: linguagem própria e coerente (ardósia, ouro velho, Emeth, leão; cartas, menus 1B e Livro de Ahk na mesma
   língua), mas toda sala vencida mostra recompensas em cubos e prismas chapados (P0 de arte) e o cenário satura três
   cores ao mesmo tempo onde o Ember & Blade só satura o efeito.
5. **Steam**: falta o mínimo de robustez (save atômico, pausa ao perder o foco, menus testados por controle) e a licença do
   Meshy, que só o Daniel responde. Nada de C16 até ele pedir.

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (neste ciclo), P2
(próximo), P3 (depois). Origem: CF = `combat_feel.md`, GP = `gameplay.md`, ART = `art.md`, ENV = `environment.md`, UI =
`ui.md`, QA = `qa.md`, AS = `assets.md`, AUD = `AUDITORIA.md`, T5b = `t5b_boss_fight.md`. Responsáveis:
`gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`, `combat-feel-director`,
`technical-artist`; "Daniel" quando a decisão é dele. O que é opinião minha está dito.

---

## 0. Feito em 17 e 18/11 (fechado com evidência)

| Entrega | Commits | O que entrou | Evidência |
|---|---|---|---|
| **T5** (correções do teste do PO) | `c81d00c`, `37faec0`, `6338417`, `0c1207e`, `c7df16d`, `da41133`, `2374577`, `496b1d4`, `579fe89`, `8778f8b`, QA `fe07159` | ultimate carrega por dano causado e sofrido, primeira aberta sem escolha, HUD diz o que falta; preparação dos inimigos em três tempos com dano do corpo; esqueleto sem tremor e com trote; música gravada e efeitos em camadas; Provação e Altar se explicam na tela; investida atrás do escudo; fuga dos atiradores estável | `docs/design/t5_ultimate.md`, `docs/qa/t5_enemy_motion.md`, `docs/design/t5_audio.md`, `docs/gallery/t5/`, `docs/qa/latest_report.md` |
| **Sala de música** | `5337385` | música original de volta como padrão; tela Músicas para ouvir e escolher por lugar (título, masmorra, Morvath) | `tests/test_music_room.gd`, `docs/gallery/t5/ui/music_room_*.jpg` |
| **T5b** ("esqueletos pulando" na luta de Morvath) | diagnóstico `b79459e`, correção `5aeee46` | feiticeiro e besteiro trotam no chão (0% no ar, era 25 a 32%), erguer termina na guarda, mistura de clipe sem degraus, Morvath gira até 12 graus por quadro (era 137), invocado espera 0,6 s antes do primeiro golpe | `docs/qa/t5b_boss_fight.md` seção 6, `docs/gallery/t5b/` |
| **Corredor no chão** ("esqueleto cor de ferrugem tremendo") | `40d6618` | `Jog_Fwd` com pés travados (171 passos/min, 3,2 cm), balanço pela passada (`Horde.stride_lean`), saíram `SWAY_HZ` e `UNEVEN_STEP` | `t5b_boss_fight.md` seção 7, `docs/gallery/t5b/runner/`; aprovado pelo art-director (ART, "a corrida nova") |
| **Pacote de arte 1A** (cartas, HUD, eventos) | `2001359` | 7 medalhões pintados, selos do altar e da Provação, "Sai/Entra" na troca, marcas de recompensa nas placas, anel da ultimate pronta, "Escolha uma bênção" | `docs/gallery/artpack/stage1a/` |
| **Pacote de arte 1B** (menus) | `9d583d0` | pausa, Suas Bênçãos, vitória, derrota, Configurações em abas e Como Jogar numa língua de página só | `docs/gallery/artpack/stage1b/after/` |
| **Livro de Ahk** (etapa 2) | `4fab502` | Abertura, O Guerreiro (retrato pintado), árvore de Dons com glifo por efeito e caminhos acesos, Compêndio como índice do livro | `docs/gallery/artpack/stage2/after/`, `tests/test_book.gd` |
| **Etapa 4** (salas) | `4e63298` | raízes e musgo do Jardim e lábios das Fendas no chão andável, postes das portas, moeda de ouro na porta, meias-luas de Morvath em violeta frio, selo que se aquieta sob os ataques | `docs/gallery/artpack/stage4/` |
| **C17, frente de gameplay** | `e401151`, `881ce58`, `5a535fe`, `90a728d`, `e7e933a`, `3eded80`, `5a0dde9`, `0c13d4e`, `707894e`, `1957bb3`, `af5be1c`, `a6dd2fd` | BUG-101 a BUG-104, BUG-110, QW-101 a QW-105, QW-107, QW-112, DT-102 e a Q-09 (b) (Lâminas das Almas de perto com passo atrás: fase 1 de 91% foice para 62%, nunca mais de 2 iguais em 3 sementes) | `docs/gallery/c17/`, `CLAUDE.md` seção C17; 1012 testes, sonda 40/40; régua de 24 descidas (reação 0,25, `--ultimate=cleave`): 23 de 24 vitórias (base 14 de 16 nas sementes 1 a 16, agora 16 de 16) |
| **Créditos fora do jogo** (pedido do PO) | `099a486` | sem tela de Créditos; toda atribuição em `CREDITOS.txt` ao lado do exe | `CREDITOS.txt` |
| **Assets: auditoria e C1** | `d458633`, `28fd0a9`, `010ef90` | agente `technical-artist`; inventário; fontes de assado fora do pacote, paleta única do KayKit, BC7/BC5/BC4: exe de 219,7 para 197,2 MB, texturas 3D de 161 para 10 MB de VRAM | `docs/qa/asset_report.md`, `docs/art/asset_inventory.md` |

Saíram deste backlog por estarem feitos (prova nos commits citados no backlog anterior e no `CLAUDE.md`): E1a a E1c, E2 a
E6, C12c a C12d, C13 inteiro, C15-01 a C15-05, BUG-017, B-c, B-2, DT-001, DT-003 (iGPU medida na E6), DT-012 a DT-016,
VX-04 a VX-07, VX-13, VX-14, QW-014, QW-018 e o roteiro do T3.

---

## 1. Bugs e quickwins (primeiro)

Ordenados por prioridade. Duplicados entre relatórios foram juntados (coluna Origem).

### 1.1 Bugs

| ID | P | Título | Evidência | Impacto | Esforço | Responsável | Origem | Pronto quando |
|---|---|---|---|---|---|---|---|---|
| **BUG-101** | **P1 (alto)** | **Provação tomada tarde nunca vira Bênção**: paga vida, carrega a maldição até Morvath e a carta prometeu "VOCÊ RECEBE DEPOIS DE N LUTAS" | 4 de 9 Provações do robô terminaram com `trial.left` 1 a 3 (sementes 4, 11, 12, 13 do GP; semente 4 do QA: `trial_ferida` por 4, sobrava 1 luta); `trial_depth_max` 7 (`make_data.gd:589`), encontros 3 a 5 (`make_data.gd:1205`), Morvath não conta (`Rooms._fight_won`) | regra quebrada que custa vida e mente na carta | P | `gameplay-engineer` (regra), decisão de desenho na pergunta Q-08 | GP P1-1, QA P1-1 | `test_trial.gd`: para toda profundidade 2 a 7 e 500 mapas, encontros oferecidos <= lutas que restam antes de Morvath; laje não aparece se não cabem 3; 24 descidas do robô sem `trial.left > 0` no fim **Feito no C17** (`e401151`): laje só onde cabe a maldição mais curta, cartas limitadas às lutas que restam (`RunMap.fights_left`); 500 mapas no `test_trial.gd`; 24 descidas sem `trial.left > 0` em quem chegou a Morvath (a base tinha 1 em 16). |
| **BUG-102** | **P1 (alto)** | **Save pode se perder inteiro**: `Save.write` trunca no lugar; JSON quebrado vira o padrão e a próxima gravação o torna definitivo | `scripts/save.gd:46-50`, `core/save_data.gd:59-62`; o notebook do Daniel já desligou sem bateria no QA do T5 | perder Maestria, Dons, Compêndio e Juramentos sem aviso: o pior relato possível na Steam | P | `gameplay-engineer` | GP P1-2 | grava em `.tmp` e renomeia; `.bak` antes; leitura cai no `.bak`; nunca grava por cima de arquivo ilegível; teste GUT com `save.json` truncado **Feito no C17** (`881ce58`): `SaveFile`: `.tmp`, `.bak`, `.broken`; `test_save_file.gd` com save truncado. |
| **BUG-103** | P1 (confirmar) | Placas da loja aparecem na Câmara do Selo com Morvath de pé | `ui/shop_720_shop.jpg` ("Sala 11 de 11", barra de Morvath, 5 placas); mas `art/shop.jpg` com `--start=shop` mostra a loja certa no salão ("Sala 10 de 11"). Hipótese minha: artefato do `ui_lab --shop` com o robô andando | se acontecer numa partida real é P0 | P | `gameplay-engineer` | UI-P1-07 | uma descida do robô passando da loja a Morvath sem nenhuma placa da loja na câmara (captura ou contagem de nós `DoorSign`); se for só o laboratório, `ui_lab --shop` corrigido e comentado **Feito no C17** (`5a535fe`): artefato do `ui_lab --shop` com `--bot`; partida real sem placa na câmara (`test_economy.gd`). |
| **BUG-104** | P1 | Morvath desliza parado: lógica andando a 5 a 6 m/s com o desenho em `idle` | `boss_probe --probe-log` s5: 77 trechos, 158 quadros, piores 1,04 e 1,10 m em 12 quadros (f599, f5124) | o chefe "patina" quando o herói esquiva por dentro dele | P | `gameplay-engineer` | CF-07 | `boss_probe` s1 a s5: 0 trechos de 3 quadros ou mais em `idle` com o corpo acima de 1 m/s **Feito no C17** (`90a728d`): `boss_probe` s1 a s5: 85 trechos para 0 (`tools/boss_slide.py`). |
| **BUG-105** | P1 | ~~Fileira de Bênçãos do HUD sem limite: 16 ícones chegam a x 1916 de 1920~~ FEITO no C17 (ui-ux-designer): "+N" depois de 96% da largura, `test_c17_ui.gd`. | `Hud._update_passives`; `ui/menu_1080_pause_many.jpg`, `menu_720_pause_many.jpg` | sai da tela em partida boa | P | `ui-ux-designer` | UI-P1-04 | com `--boons=25`, nada passa de 96% da largura a 720 e 1080, "+N" no fim |
| **BUG-106** | P1 | ~~Como Jogar ensina a ultimate errado ("escolhido antes da descida", "carrega com a Magia gasta")~~ FEITO no C17: ultimate de hoje e passo "Provação e Altar". | `howto_ultimate_desc` no `text_pt.tres`; regra da T5 em `t5_ultimate.md` | o jogador aprende a regra velha | P | `ui-ux-designer` | UI-P1-02 | cada frase do Como Jogar conferida com a regra atual; linha nova para Provação e Altar |
| BUG-107 | P2 | ~~Saudação "Bênção nova"/"Elo formado" por cima da pausa e atrás do título da escolha; e sobre inimigos no topo da arena~~ FEITO no C17: saudações esperam paradas com tela aberta, fileira some na pausa, véu na luta. | `ui/menu_1080_pause_many.jpg`, `elo_720_card.jpg`, `psalm_720_psalm_banner.jpg`; ART P2-4 | ruído sobre telas e luta | P | `ui-ux-designer` | UI-P2-01, UI-P2-02, ART P2-4, AUD (pausa) | com escolha ou pausa aberta nenhuma saudação visível (mostra depois, como o "Salmo descoberto"); fileira do HUD escondida na pausa; na luta, véu atrás ou acima de 12% da altura |
| BUG-108 | P2 | Vazamento no fim da suíte (28 ObjectDB, 19 recursos) vem só do `test_boss_body.gd` `test_the_whole_fight` | `tests_verbose.txt` do QA; não acontece no jogo | esconde um vazamento real futuro | P | `gameplay-engineer` | QA P2-1, UI (verificação), DT-005 antigo | `tools/test.sh` termina sem as duas linhas |
| BUG-109 | P2 | Testes que dependem do relógio de parede (número de asserções muda entre rodadas); `test_descent` instável (Q-T5-5) | QA P2-2: 239 232, 236 970, 238 520 asserções com os mesmos testes | "falhou depois do merge" sem reprodução | P | `gameplay-engineer` | QA P2-2, GP P2-10 | número de asserções igual em 3 rodadas; `wait_frames` trocado (`test_e5_ui.gd:108`); avisos `Float/Int` do `test_boss_exits.gd` resolvidos |
| BUG-110 | P2 | Exe parado aos 2,2 s na 1ª sala com o robô (registro de gente) sem causa no código | GP seção 2 (pausa descartada; hipótese: quadros raros por saída padrão bloqueada, janela fora de vista ou GPU disputada) | qualquer travamento de gente fica sem diagnóstico | P | `gameplay-engineer` (vigia), `qa-performance` (rodar o exe) | GP seção 2 | `--watchdog`: linha `WATCH` a cada 5 s reais (`frames`, `fps`, `mode`, `Fx.rate`, `time_scale`, `time`) no console e no registro; exe rodado 10 min com saída em arquivo **Feito no C17** (`af5be1c`): `--watchdog`, linha `WATCH` e `watch` no registro (`test_watchdog.gd`); falta o exe de 10 min do QA. |
| BUG-111 | P2 | ~~Divisa de fora da tela desenha sobre a legenda "Maestria 2" do 5º losango~~ FEITO no C17: divisa gira pelo meio, `EDGE_INSET` 128. | `ui/trial_720_trial_seal.jpg`; `EDGE_INSET` 116 | sobreposição no HUD | P | `ui-ux-designer` | UI-P2-10 | captura com divisa embaixo e legenda separadas |
| BUG-112 | P2 | ~~Nome do golpe ("Giro da Alvorada") fica no canto depois que o contador some~~ FEITO no C17: o nome some com o contador. | `ui/shop_720_shop.jpg`, `menu_720_defeat.jpg` | texto órfão | P | `ui-ux-designer` | UI-P2-09 | os dois somem juntos |
| BUG-113 | P2 | ~~Números com ",5" para o jogador ("22,5 de vida máxima")~~ FEITO no C17: `BoonMod.WHOLE`, `UiKit.whole`. | `ui/trial_720_trial.jpg`; AUD (Provação) | inconsistente com o HUD inteiro | P | `ui-ux-designer` | UI-P2-06, AUD | teste: números exibidos arredondados onde o HUD mostra inteiro |

### 1.2 Quickwins (grande ganho em poucas horas)

Combate primeiro (pela regra do ciclo), depois leitura e arte, depois texto.

| ID | P | Título | Evidência | Impacto | Esforço | Responsável | Origem | Pronto quando |
|---|---|---|---|---|---|---|---|---|
| **QW-101** | **P1** | **Orbe do feiticeiro que pega cedo ou não pega**: curva só nos primeiros 0,8 s do voo (depois reto) ou `shot_turn` 40 para 20 | PO: feiticeiro 22 de 67 golpes (33%), aviso mediano 2,2 a 2,6 s, 19 de 22 com a esquiva pronta, 2 mortes; robô 60% dos golpes nas salas; o 40 é nosso (o arquivo do Hades não diz) | o golpe mais "injusto" do jogo para gente | P | `gameplay-engineer` | CF-01 | GUT: herói correndo de lado a 6,75 m/s depois de 1,2 s de voo nunca é atingido; robô s1 a s4: feiticeiro abaixo de 35% dos golpes nas salas; próxima sessão do PO: abaixo de 20% **Feito no C17** (`e7e933a, a6dd2fd`): curva só no primeiro 0,8 s e a 20 graus/s; GUT de passo de lado; robô 24 sementes: feiticeiro 33% dos golpes nas salas (base 50%). |
| **QW-102** | **P1** | **Corredor com aviso legível**: `attack_windup` 0,7 para 1,0 s (0,3 s de segurar com tremor) | PO: 9 golpes (13%) com 0,70 a 0,82 s de aviso; Radiator do Hades 1,5 s | o menor aviso do jogo | P | `gameplay-engineer` (dado) | CF-02 | `enemy_motion_probe`: aviso x dano 0 a 1 quadro mantido; nenhum golpe com aviso abaixo de 0,9 s fora o golpe curto do Escudo. Opinião minha: se o PO ainda apanhar, ir ao 1,5 do Hades pela D-39 **Feito no C17** (`e7e933a`): aviso 1,0 s; `test_the_runner_warns_a_full_second`. |
| **QW-103** | P1 | **Sopro do giro e da lança no quadro da lâmina** (campo `sound_at` no `ComboNode`; no aperto do giro, só um som curto de carga) | `blade_spin_*.ogg` pico 30 a 90 ms depois do aperto, giro acerta aos 0,36 s: sopro 0,27 a 0,33 s adiantado (`player.gd:730`) | o golpe mais forte soa antes de acontecer | P | `gameplay-engineer` | CF-03 | `Audio.listen`: pico do sopro do giro e da lança a no máximo 2 quadros do acerto; golpes 1 e 2 iguais; sonda 40/40 **Feito no C17** (`3eded80`): sopro do giro aos 0,30 s, lança 0,035, estocada 0,115; `test_warrior_strike.gd`; sonda 40/40. |
| **QW-104** | P1 | **(ART-09.7) Corpo do inimigo acende no "vai bater"**: rampa mais clara e morna nos últimos 30% do preparo, abaixo do `flash_cap` | `crowd.gdshader:158` só acende orbe e lâmina; Hades clareia o corpo até 0,95 no último 0,5 s | ler o perigo pelo corpo, sem olhar o chão | P | `gameplay-engineer` (`crowd.gdshader`, `Horde.render`), `art-director` (números) | CF-06 | captura GPU 1080 de esqueleto, Escudo e feiticeiro no segurar aprovada pelo art-director; nenhum canal acima de 1,0; teste em `test_enemy_windup.gd` **Feito no C17** (`5a0dde9`): `docs/gallery/c17/qw104_*`; falta a aprovação do art-director. |
| QW-105 | P1 | Espera sorteada entre golpes (0 a 0,4 s somados ao `AFTER_RECOVER` por inimigo) e Cavaleiro que investe também de perto; histerese do Cavaleiro | esqueleto bate a cada 215 quadros exatos 15 vezes; Cavaleiro 9 golpes curtos idênticos e troca andar/parado 0,88 vez/s | metrônomo previsível | P | `gameplay-engineer` | CF-08, CF-11 | `--play` s1 e s2: desvio padrão do intervalo de 0,1 s ou mais; Cavaleiro investe 1 vez a cada 4 golpes ou menos; troca andar/parado abaixo de 0,5/s **Feito no C17** (`0c13d4e`): desvio padrão 0 para 0,11 s; Cavaleiro 3 investidas em 9 golpes; andar/parado 0,88 para 0,39/s; `test_no_metronome`. |
| **QW-106** | **P1** | **Feito no C18 (environment-artist, `RewardGem`; aguarda revisão do art-director). Art polish: ART-01.1; o que falta (leitura sem placa, relicário) é ART-01.2 e ART-01.3.** **Recompensas de verdade**: trocar os primitivos chapados (`Rooms.gem_mesh`, `SHADING_MODE_UNSHADED`) por disco de ouro velho com o medalhão pintado que já existe (`assets/ui/boons`, `assets/ui/events`), sombreado, girando devagar sobre pedestal baixo, halo abaixo do glow; um material por tipo e luz só na porta escolhida | `art/shop.jpg` (olhei: cubos amarelo, vermelho, verde, azul), `art/altar.jpg`, `art/trial.jpg`, `env/fwd_shop.jpg`; uma omni e um material por gema | a peça mais "protótipo" do jogo, em toda sala vencida | P a M | `environment-artist` (peça e material, em arquivo próprio `reward_gem.gd` para não brigar com o BUG-101 no `rooms.gd`), `ui-ux-designer` (medalhão por recompensa) | ART P0-1, ENV P1-1, AUD P0 | nenhuma `BoxMesh`/`PrismMesh`/`SphereMesh` sem luz em loja, altar, Provação e fim de luta; cada recompensa reconhecida pelo símbolo a 720 sem ler a placa; maior canal na tela até 226; no máximo uma omni de recompensa acesa |
| QW-107 | P1 | (ART-09.7) Mira do besteiro e bote do esqueleto em degradê: fio até 10 px a 1080, ponta clara, corpo até alfa 0,45 enchendo só nos últimos 30% | `art/bridge.jpg`, `art/runes.jpg`, `videos/v2_combo.mp4` 0:05 a 0:09 da AUD: faixa vermelha opaca de ponta a ponta | a coisa mais forte da tela é um aviso | P | `gameplay-engineer` (`GroundLook`), `combat-feel-director` aprova | ART P1-6, AUD (avisos) | largura até 10 px; nenhum trecho com alfa acima de 0,6 fora da ponta; aviso x dano 0 a 1 quadro mantido **Feito no C17** (`af5be1c`): fio de 6 px a 0,5, ponta clara, faixa até 0,22 nos últimos 30%; `docs/gallery/c17/qw107_*`; falta o combat-feel-director. |
| QW-108 | P1 | **Feito no C18 (environment-artist; ART-03.4).** Lajes das Runas no tom dos avisos (preenchimento até 0,25 até os últimos 30%), pilares sem listra acesa em repouso e sem chuvisco âmbar no pontilhado | `art/runes.jpg`, `env/fwd_runes_0.jpg` | "piso de discoteca" que esconde a mira | P | `environment-artist` (`rune_floor.gdshader`, `rune_pillar`) | ART P1-3, ENV P2-1, AUD | captura em preparo: âmbar saturado abaixo de 12% da tela; mira legível por cima; nenhum ponto âmbar isolado em volta do herói atrás do pilar |
| **QW-109** | **P1** | ~~Um nome só para o especial: "Onda de Luz" (D-69); `move_bolt` vira `move_wave` no `make_data.gd`, `howto_heavy_attack_desc` reescrito~~ FEITO no C17 no texto (`move_bolt` diz "Onda de Luz"); falta só o título do nó no `make_data.gd` (`move_wave`), da sessão principal. | HUD e Compêndio "Seta de Luz", Como Jogar "seta de luz", Livro "onda de luz"; `move_wave` existe sem uso | o golpe característico com três nomes, visto em toda luta | P | `ui-ux-designer` (texto), sessão principal regera `combos` | UI-P1-01, AUD (especial) | teste de texto: nenhum "seta" no texto do jogador; captura do HUD com "Onda de Luz". Nome final na Q-06 |
| QW-110 | P1 | ~~Vocabulário único das ações: Ataque, Especial, Círculo, Esquiva, Ultimate; símbolo do HUD no lugar de E/D; "Descer de novo" nos dois finais~~ FEITO no C17: Controles, cartas, Como Jogar, Compêndio com os símbolos do HUD, "Descer de novo" nos dois finais. | "Leve (E)"/"Pesado (D)" nos Controles (o D colide com a tecla D), "Golpes leves/pesados" nas cartas, "E E E" no Compêndio, "Avanço" x "Esquiva", "Tentar de novo" x "Descer de novo" | confusão em toda tela de texto | P | `ui-ux-designer` | UI-P1-03, UI-P2-04, UI-P2-05 | teste que procura "Leve", "Pesado", "(E)", "(D)" nas chaves do jogador; nomes na Q-16 |
| QW-111 | P2 | **(ART-09.6) Feito no C18 só no desenho (environment-artist, `look_scale` 1,25 e `wake_light` no shader; o combat-feel-director mede).** Onda do especial mais legível: +25% de comprimento visual e rastro mais claro, mesmo acerto | `audit/3_gameplay/12_especial_onda_da_lamina_1080.jpg`: a meia-lua de 1,6 m mal aparece a 1080; E1c-2 já pedia | o golpe do herói não se lê | P | `environment-artist` (`emeth_wave.gdshader`, `Projectiles.WAVE_*`), `combat-feel-director` mede | AUD (especial) | `test_special_wave.gd` com os mesmos números de jogo; captura 1080 aprovada pelo art-director |
| QW-112 | P2 | Robô medindo o jogo que se joga: fonte só abaixo de 80% da vida e régua sempre com `--ultimate=cleave` | robô escolhe a fonte com vida cheia (`Rooms.bot_door` rank -1); Maestria 1 sem ultimate em todas as métricas | métricas da E6 distorcidas | P | `gameplay-engineer` | GP P2-7, P2-8 | 24 sementes: `ult.uses > 0` em todas; fonte só abaixo de 80% (`events`) **Feito no C17** (`707894e, a6dd2fd`): fonte só abaixo de 80% (e bebe abaixo disso); 24 sementes com `--ultimate=cleave`: `ult.uses > 0` em 24. |
| QW-113 | P2 | ~~Juramentos e Músicas no painel 1B (sem o logotipo fantasma atrás)~~ FEITO no C17: `UiKit.page`. | `ui/juramentos_720.jpg`, `menu_720_music.jpg`; AUD | fecha o pacote de menus | P | `ui-ux-designer` | UI-P1-05, AUD | capturas 720 e 1080 com o painel das Configurações; `title_flow_check` ok |
| QW-114 | P2 | ~~Texto legível a 720 no Livro e no Compêndio (corpo mínimo 14 px, descrição inteira no foco), legenda da ultimate e tecla acima de 12 px~~ FEITO no C17: lista do Compêndio rola, sem reticências, mínimo 14 px; legenda e tecla 14 px. | `ui/book_720_hero.jpg` (12 px cinza), `book_720_codex_0.jpg` (corte com "...") | leitura em tela pequena (Steam Deck) | P | `ui-ux-designer` | UI-P1-06, UI-P2-11 | nenhuma reticência de corte; menor corpo 14 px a 720 |
| QW-115 | P2 | (ART-10.2, P1 no art polish) Acabamento da vitória e dos números: véu atrás da legenda da selagem, halo do selo em degradê (sem disco amarelo), ouro sobe ao lado do número e menor | `art/victory.jpg`, `stage1b/after/1080_victory_seal.jpg`, `art/jogo.jpg` ("60" sobre "+1 ouro") | o momento de maior emoção e ruído sobre o grupo | P | `ui-ux-designer` | ART P2-2, P2-3, P2-6, AUD (vitória) | capturas aprovadas pelo art-director |
| QW-116 | P2 | (ART-09.3) Feiticeiro: cajado 15 graus para trás junto ao ombro e `lift` 0,5 para 0,3; reassar Morvath (dois commits atrás do `bake.gd`) | `t5b/boss/mage_trot_side_24f.jpg`; AS P2-1 | trote ainda rígido; assado atrasado | P | `gameplay-engineer` (`tools/bake.gd`), `technical-artist` (Morvath) | ART (feiticeiro), AS P2-1 | tira de lado aprovada pelo art-director; `pose_drift` de Morvath até 0,45 m; `test_boss_body.gd` verde |
| QW-117 | P2 | (ART-06.3) Glifos pequenos sem leitura de cruz (Corte do Juízo no losango R, escudo da Vigília, ícone "†" azul) | `ui/ult_720.jpg`, `menu_720_pause_many.jpg` | regra "nunca cruz" | P | `art-director` (desenho), `ui-ux-designer` | UI-P2-08 | revisão a 720 e 1080 sem cruz |
| QW-118 | P2 | ~~Uma regra de maiúsculas (nomes de Bênção em Title Case, "Bênção" sempre maiúscula)~~ FEITO no C17: Title Case nos nomes, Bênção e Magia maiúsculas. | "Escolha uma bênção" x "Fortalecer bênção" x "Magia ampla" | polimento | P | `ui-ux-designer` | UI-P2-03 | teste dos nomes |

---

## 2. Dívidas que vão atrapalhar logo

| ID | P | Título | Evidência | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|---|
| DT-101 | P1 | **Licença e créditos incompletos**: plano do Meshy não registrado (CC BY 4.0 no gratuito exige crédito); `asset_credits.md` só cita "Kenney Impact Sounds"; `CREDITOS.txt` sem os medalhões dos eventos nem o retrato do Livro; `steam-ia.md` sem ambiência nem `title_fill.png` | AS P1-3, P2-8 | P (depois da Q-01) | `technical-artist` | cada modelo do Meshy com plano e licença escritos; todo CC BY nos dois arquivos de crédito; toda arte de IA no `steam-ia.md`; grep cruzado pacote x créditos sem sobra |
| DT-102 | P1 | **Robô não mede inimigos de perto** (0 golpes de perto em 4 descidas contra 19 do PO); balanço de inimigos só com gente | CF-12; antigo DT-002 | P (instrumentação) | `gameplay-engineer`, `qa-performance` | `RESULT` e registro com preparações começadas, que chegaram ao golpe e cortadas por tipo; tempo de voo do tiro que acertou; `omega_charges_started` e `cancelled` (CF-13) **Feito no C17** (`af5be1c, a6dd2fd`): `windups`, `shot_flight`, `omega_charges_started`/`cancelled` no `RESULT`. |
| DT-103 | P2 | Menus sem teste por controle e mouse; abas só pelo foco (sem LB/RB); remapear só no teclado. EM PARTE no C17: LB/RB trocam abas e capítulos, `title_flow_check` com eventos do controle; falta a volta inteira por controle e por clique e remapear no controle. | UI-P2-12 | M | `ui-ux-designer` | `title_flow_check` com uma volta por `InputEventJoypadButton` (A, B, cruz, LB/RB) e uma por clique |
| DT-104 | P2 | Auditoria de assets no fluxo: teste GUT que falha com assado mais velho que o `bake.gd`, assados acima de 70 MB, música acima de 18 MB no PCK, figura acima do teto de triângulos | AS #4 (caso de Morvath, música a 0,78 MB do teto) | P | `technical-artist` | falha no estado de hoje, passa depois do QW-116; menos de 2 s |
| DT-105 | P2 | `fit_probe` sem `Arena.walk` nem salas de evento (39 m² de "beira falsa" no salão por medida errada) | ENV P2-7 | P | `environment-artist` | mede salão, Provação, Altar e Câmara; entra como teste de regressão com os limites de hoje |
| DT-106 | P2 | Arquivos grandes: `game.gd` 1741 linhas, `horde.gd` 1504, `boss.gd` 1431, `rooms.gd` 1146 | GP P2-9 | M | `gameplay-engineer` | `RunReport` (RESULT e registro) e `RunAward` (Maestria e Compêndio do fim) fora do `game.gd`, mesma semente com o mesmo `RESULT` |
| DT-107 | P2 | Pacote e repositório: `.gutconfig.json` e `lion.svg` no PCK, `.uid` órfão, KayKit sem uso (8 de 26 em `dungeon/`, 40 de 43 em `dungeon_r/`, 18 duplicadas), armas `held` acima do orçamento (feiticeiro 5 530 triângulos), `hero_sombra/` e `paladin_1/` (60 MB) guardados | AS P2-2, P2-5, P2-9 | P a M | `technical-artist` (remoção das pastas pede a Q-19) | `pck_sizes.py --files` sem os arquivos de fora; toda figura até 4 100 triângulos; capturas iguais |
| DT-108 | P2 | Documentos desatualizados: pacote web "61 MB" (é 88 MB de pck + 39,5 de wasm), música "16,6 MB" (17,2 no PCK), saldo do Meshy "6" no `meshy_asset_plan.md` (546), linha do corredor no inventário | QA P2-3, AS | P | sessão principal, `technical-artist` | números corrigidos no `CLAUDE.md` e nos documentos |
| DT-109 | P2 | (ART-02.2) **Primeira versão escrita em 2026-11-18 pelo game-director, a revisar pelo art-director.** Não existia `docs/art/art_direction.md` (paleta com valores e regras de leitura); o guia é só o `docs/arte/estetica.md` | AUD resumo 6 | P | `art-director` | documento com paleta numérica (incluindo o teto de saturação do cenário do C18) e regras de leitura |
| DT-110 | P2 | Fila da GPU entre agentes suja as medidas de FPS (até 8 `gpu.sh` esperando; partidas sem tela na mesma CPU) | QA #8, CF (vídeo não gravado) | P | `qa-performance` | modo "medir" que espera CPU calma ou horário reservado; documentado no `agent_workflow.md` |
| DT-111 | P3 | Mundo em câmera lenta abaixo de 20 qps (teto de 0,05 s por passo); estresse de 300 preso na CPU (13 ms no Windows) | GP P2-11, QA #7 | P | `gameplay-engineer` | documentado; subdividir o passo só se a máquina fraca pedir |

**Herdados ainda abertos** (sem mudança de dono): GF-15 (arranque e parada animados), VX-17 (pose final do finalizador),
CF-09 (golpe 1 a 2,75x e corte da esquiva a 3,67x, meta 1,5x), CF-10 (segunda camada de som no golpe), T5-17 a T5-19
(preparação de Morvath para maldição e erupções, recuo da besta), Q-T5-6 (globos laranja na vitória com 25 Bênçãos),
Q-T5-7 (`--shot-on` antes de `--shot-at`), T5b P2-2 (erguer do esqueleto ainda anda 0,23 m), corredor elite a 259
passos/min, besteiro sem tira de lado nova, B-b (esquiva com vsync um quadro composto depois), F-6 e J-5 das Fendas e do
Jardim, UI-P2-13 (espaço morto no Como Jogar e nas cartas; Abertura repete o Como Jogar), UI-P2-14 (Voragem sem estado no
Livro), UI-P2-15 (`ui_lab --trial` vazio com `--bot`; `howto_lab` sem a aba Controles).

---

## 3. Próximos ciclos

Regra de entrega: cada ciclo vira um exe para o Daniel testar de uma vez; nada de pedir teste a cada ajuste. Nenhum ciclo
começa a C16 Steam (o Daniel não pediu).

### C17 "Justiça e peso" (2 a 3 dias, o próximo)

- **Objetivo**: nenhum golpe que o jogador sente como injusto e todo golpe do herói soando e acendendo no tempo certo.
- **Por que agora**: os dados de gente (12 partidas do PO, `hurt_ctx`) apontam três fontes que somam 46% dos golpes levados
  (orbe, corredor) e uma regra quebrada; tudo é dado ou uma função, e muda a sensação mais que qualquer conteúdo novo.
- **Itens**: BUG-101, BUG-102, BUG-103, BUG-104, QW-101, QW-102, QW-103, QW-104, QW-105, QW-107, QW-112, BUG-110
  (vigia), DT-102 (instrumentação); em paralelo a frente de texto e HUD: QW-109, QW-110, BUG-105, BUG-106, BUG-107,
  BUG-111, BUG-112, BUG-113.
- **Aceite**: os de cada item; sonda 40/40; 992+ testes; 8 descidas do robô 0,25 com `--ultimate=cleave` sem queda de
  vitórias acima de 1 de 8 (o aviso maior do corredor e o orbe facilitam: anotar); feiticeiro abaixo de 35% dos golpes
  do robô nas salas; nenhuma Provação aberta no fim de 24 descidas; save truncado recuperado por teste.
- **Evidências**: `docs/gallery/c17/` com antes e depois (corpo acendendo, mira em degradê, HUD com 25 Bênçãos, Como Jogar);
  vídeo 60 qps do giro com som (pendência do CF); saída da sonda e das descidas no `docs/qa/latest_report.md`.
- **Responsáveis e paralelismo sem conflito de arquivo**:
  - `gameplay-engineer` (uma frente, em série): `make_data.gd` (feiticeiro, corredor, `sound_at`), `projectiles.gd`,
    `player.gd`, `horde.gd`, `crowd.gdshader`, `ground_look.gd`, `trials.gd`, `rooms.gd` (Provação, robô), `save.gd`,
    `save_data.gd`, `boss.gd`, `game.gd` (vigia).
  - `ui-ux-designer` (paralelo): `text_pt.tres`, `hud.gd`, `elo_banner.gd`, `action_slot.gd`, telas. O título do nó
    `move_wave` vai no `make_data.gd`: entregar a linha para a sessão principal aplicar junto com o lote do gameplay.
  - `combat-feel-director`: mede antes e depois (sonda, `enemy_motion_probe`, `boss_probe`) e pode reprovar.
  - `qa-performance`: integra, exe, relatório.
- **Riscos**: o aviso maior e o orbe mais fraco deixam as salas fáceis (medir com gente antes de compensar com vida, que
  é proibido); o corpo acendendo pode passar do glow com elites douradas (o art-director fixa o teto).

### T6, teste do PO depois do C17

Exe nas duas pastas. Perguntas (uma linha cada): (1) algum golpe pareceu sem aviso, de quem? (2) os orbes ainda
pegam do nada? (3) o giro soa no tempo do golpe? (4) dá para ver quem vai bater pelo corpo? (5) a Provação pagou a Bênção?
(6) Morvath fase 1 enjoa? (7) onde o herói se perdeu na tela? Mandar o `runs.jsonl` inteiro. As respostas a Q-08, Q-09 e
Q-11 a Q-14 entram no C19.

### C18 "A tela de um jogo acabado" (3 a 4 dias; pode começar junto com o C17, outros arquivos)

- **Objetivo**: cenário num tom só que deixa o efeito saturar, chão com valor para o olho descansar, e nenhuma peça de
  protótipo à vista.
- **Por que agora**: é o que mais separa a primeira impressão do Ember & Blade (p90 de saturação 35 a 51 contra 24 a 25;
  Cripta com luma 37 contra 67 a 75) e nada depende de créditos nem de IA.
- **Itens**: QW-106 (se não coube no C17), QW-108, QW-111; paleta do cenário (bruma do abismo e nuvens da câmara com
  saturação até 0,45, portal como único verde do salão, metade das velas que restam apagadas ou mais frias, ART P1-2, AUD);
  portal do salão com profundidade (AUD); clareiras pálidas no `catacomb_floor.gdshader` e nos chãos das arenas, luz de
  preenchimento das paredes na Cripta e no Santuário (ART P1-2, ENV P1-5); família de verdes separada do herói: erupções
  da fase 3 com miolo vermelho translúcido até 0,35 (não magenta), aro sem ciano, partículas espectrais até 0,12 m e
  nunca a menos de 1,5 m do herói, domo do ritual no matiz 165 longe do petróleo do anel (ART P1-4, P1-11; capturei
  `art/boss3.jpg`: o herói some dentro do disco rosa); capitéis com ábaco e três silhuetas de coluna no Santuário (ART
  P1-5, ENV P1-6); fundo com bruma e ruínas nas câmaras da Provação e do Altar, sem corte de parede (ART P1-8, ENV P2-8);
  leitura do chão: Ponte B (parapeito contorna o patamar, depende da Q-10), Santuário B (`broken_lip` afundado), Runas B
  (pedra quieta clara com moldura) (ENV P1-2 a P1-4); parapeito baixo das pontes abrindo em volta do herói (ENV P2-2);
  entulho e velas do KayKit fora do salão (ENV P2-6); Jardim: cristais escuros com brilho só na aresta e copa por cartões
  procedurais (ART P1-7, depende da Q-21); barras de vida dos comuns 15% mais escuras (ART P2-5).
- **Aceite**: luma média do quadro de luta entre 55 e 70 em toda arena; p90 de saturação do cenário sem efeitos até 32
  no salão e na câmara; nenhuma área violeta acima de 60% de saturação maior que 5% da tela; herói dentro de uma erupção
  com as cores próprias (sem tinta rosa) e nenhuma bolha verde ou ciano na caixa de 300 x 300 px em volta dele; `fit_probe`:
  fantasma da Ponte B cerca de 4 m², beira falsa do Santuário B cerca de 9 m²; nenhuma face de corte nas câmaras de evento;
  nenhuma peça do `dungeon/` na vitrine; quadro na iGPU Baixa sem cair abaixo de 57 qps (Fendas hoje).
- **Estado (environment-artist, 2026-11-18)**: feitos QW-106, QW-108, QW-111 (só desenho), paleta, clareiras, luz de
  preenchimento da Cripta e do Santuário, verdes de Morvath, leitura do chão (Ponte B pela Q-10 a, Santuário B, Runas B),
  parapeito das pontes, capitéis e três silhuetas no Santuário, fundo das câmaras de evento, entulho do KayKit fora do
  salão, cristais e copa do Jardim (Q-21 a). Números e pendências em `docs/gallery/c18/README.md`. Fora deste trabalho:
  barras de vida (ART P2-5, ui-ux-designer) e portal do salão com profundidade (AUD, opcional, não feito).
- **Evidências**: `docs/gallery/c18/` antes e depois de cada arena e fase de Morvath na GPU a 1080 com a tabela de luma e
  saturação do ART; aprovação do `art-director`.
- **Responsáveis e paralelismo**: `environment-artist` (cenário, luz, shaders das salas e dos efeitos de Morvath:
  `*_look.gd`, `catacomb_hall.gd`, `boss_chamber.gd`, `ritual_rune.gdshader`, `boss_shield.gdshader`, `rune_floor.gdshader`,
  `reward_gem.gd` novo); `ui-ux-designer` (barras, `life_bar.gdshader`); `art-director` (spec numérica no DT-109 primeiro,
  revisão); `technical-artist` (DT-104, DT-107). Conflito a evitar: `crowd.gdshader` é do gameplay no C17 (QW-104); as
  partículas espectrais ficam no `BossShield`/`Ground`, não no shader da multidão.
- **Riscos**: escurecer o violeta pode apagar a leitura do abismo como queda; clarear o chão pode baixar o contraste do
  herói (medir na caixa dele, ART melhoria 3); sombras novas na iGPU.

### Descida de Valmor (pedido do PO de 2026-11-18): ciclos DV-1 e DV-2

**A experiência pedida**: nas Catacumbas de Valmor o jogador olha adiante, escolhe uma porta e muda de plano depois de
uma sala difícil (referência: o mapa ramificado de Darkest Dungeon II, escolha uma passagem por vez). O ritmo de combate e
a travessia pelas portas físicas da arena continuam. Exemplo do PO: com pouca vida, uma porta dá Bênção e deixa a Fonte
ao alcance na sala seguinte; a outra leva ao Altar e abre caminho para uma Loja.

**O que o código faz hoje (lido em `2057516`)**:
- `RunMap.options(can_pom)` sorteia as portas **na hora de entrar em cada sala** (`Rooms._enter`), com o dado da partida;
  não existe estrutura do que vem depois da próxima porta. A luta atrás de cada porta é sorteada quando as portas abrem
  (`Rooms._prepare`, mesmo dado), então depende de como se jogou.
- A ordem é fixa por profundidade: guardião numa profundidade sorteada de 4 a 6 (sala única, o guardião sorteado entre
  `knight` e `priest_elder` só no `_prepare`), fonte uma vez de 5 a 8 (forçada na 8), altar 20% de 2 a 8, **loja sempre na
  10** (`next == stage.rooms`, 5 itens, "a última antes do chefe"), Morvath na 11. Duas portas, três com 25%; as arenas têm
  2 a 3 saídas (`ArenaExit`), o que limita o número de portas por nó.
- A romã só entra quando alguma Bênção pode subir (`can_pom`, lido na entrada da sala).
- A Provação é uma laje sorteada numa sala de luta vencida (`Rooms._roll_slab`), que leva à câmara **na mesma
  profundidade** e devolve as portas da sala de antes; o BUG-101 limita a maldição por `RunMap.fights_left`, que hoje
  supõe a linha única de salas.
- Não existe retomar uma descida no meio (o save guarda Maestria, Compêndio e Juramentos, não a partida): "manter o mapa
  ao retomar" hoje é só manter ao abrir e fechar a consulta.
- O Hades II não tem mapa (as portas mostram a recompensa; `comparativo.md` linha "Salas"): isto é uma evolução nossa
  sobre a base do Hades, pedida pelo PO, e entra no `comparativo.md` como diferença.

**Desenho proposto (opinião minha, a confirmar nas Q-25 a Q-27)**:
- **Grafo em camadas gerado no começo da descida** (`RunMap` passa a guardar `nodes` e `edges`; o grafo é a fonte única
  das portas, das placas e do mapa). Profundidade 1 = o salão (um nó); profundidades 2 a 9 com 2 a 4 nós cada; 10 = a loja
  (um nó, todas as rotas passam, Q-26 a); 11 = Morvath. **Toda rota tem o mesmo comprimento** (11 salas), então "Sala N
  de 11" no HUD, a Maestria por sala, o `RESULT` e a régua da E6 continuam valendo.
- Cada nó liga a 1 a 3 nós da camada seguinte (nunca mais que as saídas da arena dele), sem arestas cruzadas no desenho,
  todo nó alcançável e todo nó chegando à loja. Uma **camada de guardião** (profundidade sorteada de 4 a 6, como hoje)
  só com nós de guardião, para toda rota passar por um; com 2 nós nela, um é o Cavaleiro e o outro o Ancião (Q-27 a).
- Fonte em alguns ramos (no máximo uma por rota, ao menos uma rota com ela), altar em no máximo um nó (uma vez por
  descida, como hoje), arenas com as regras de hoje valendo **em toda rota** (nunca a mesma arena em duas salas
  seguidas, nenhuma mais de 3 vezes, Santuário como casa do guardião), conferidas por enumeração das rotas (o grafo tem
  poucas dezenas de nós; gerar e validar, com novas tentativas na mesma semente).
- **Recompensas sorteadas no gerador**, camada por camada, do mesmo baralho (`RewardDeck`), nenhuma porta da mesma sala
  com a mesma recompensa. A romã só a partir da profundidade 3 (a sala 1 sempre dá Bênção e a 2 já a tem para subir); se,
  na hora de abrir as portas, nada puder subir, aquela romã vira Bênção **antes** de a placa aparecer e o mapa se
  atualiza (esperado nunca acontecer; medido). Assim o que a placa e o mapa mostram é o que a sala dá.
- **Dado separado para o mapa** (semente da partida mais um sal) e **luta por nó com semente própria**: o mesmo nó dá a
  mesma luta seja qual for o caminho e o jeito de jogar; a mesma semente dá o mesmo mapa.
- **Provação**: continua laje (o Caos do Hades II é escondido numa sala), mas sorteada no gerador num nó de luta, e o nó
  mostra **"?"** no mapa até a laje aparecer (Q-25 a). O `fights_left` passa a ser o **pior caminho** do grafo a partir do
  nó: o menor número de lutas (comum e guardião) entre ele e a loja em todas as rotas; a laje só vai a um nó onde a
  maldição mais curta cabe nesse pior caminho.
- **Mapa no Livro de Ahk**: ação nova `map` em `Controls` (tecla `M`, botão Back/View do controle, que está livre;
  remapeável), botão discreto "Mapa [M]" ao lado do "Sala N de 11" no HUD (clicável, mostra a tecla real ou o botão do
  controle) e uma entrada "Mapa" na pausa. Abre como página do livro (`BookSpread`), pausa a luta pelo `Game.open_screen`
  (a câmera lenta corta como nos menus) e, ao fechar, `Controls.clear_presses` (o mesmo cuidado do bug 1 da E1c). A entrada
  no topo, Morvath embaixo; caminho feito em tinta cheia, sala atual marcada, próximas portas em destaque, ramos que
  ficaram para trás apagados; cada nó com a marca do `DoorGlyph` (marca da recompensa e as divisas de dificuldade, gota,
  moeda, vela, selo, "?"), legenda na página da esquerda. A escolha continua sendo atravessar a porta na arena.
- **Q-13 (botão de usar)**: não muda o mapa nem a ação `map`; se vier (a), atravessar a porta passa a pedir o botão, e o
  mapa só ganha a dica "Usar diante da porta". O botão de usar não deve ser o Back do controle.

| ID | P | Título | Evidência | Impacto | Esforço | Responsável | Depende de | Ciclo | Pronto quando |
|---|---|---|---|---|---|---|---|---|---|
| **MAP-01** | **P1** | **Grafo da descida por semente** (`RunMap` com nós, arestas, recompensas, arenas, guardiões, fonte, altar e "?" gerados no começo; `fights_left` no pior caminho) | `run_map.gd` `options()` sorteia sala a sala; `test_descent.gd` supõe uma linha | base de toda a Descida de Valmor; muda a decisão entre quase todas as lutas | M | `gameplay-engineer` | BUG-109 junto (o `test_descent` instável é reescrito aqui) | DV-1 | GUT em 1000 sementes: toda rota tem 11 salas, começa no salão, passa por exatamente um guardião, pela loja na 10 e termina em Morvath; todo nó alcançável e com saída; até 3 arestas por nó e nunca mais que as saídas da arena; regras de arena em toda rota; fonte no máximo uma por rota; altar no máximo um; mesma semente, mesmo grafo; 100 sementes dão pelo menos 95 grafos diferentes (estrutura e conteúdo); em toda semente, ao menos uma sala com duas portas cujos conjuntos de salas alcançáveis são diferentes; Cavaleiro e Ancião como alternativas em pelo menos 30% das sementes; `--short`, `--medium`, `--arena`, `--start=` e Juramentos seguem funcionando; `test_trial.gd`: 500 grafos, nenhuma carta pede mais encontros que o pior caminho |
| **MAP-02** | **P1** | **Portas da arena = arestas do grafo** (o `Rooms` lê as portas do nó atual; placa, `door_info`, `DoorGlyph`, luta e recompensa vêm do nó; registro com o caminho) | `rooms.gd` `_enter`, `_prepare`, `door_info`, `door_text`, `_roll_slab`, `bot_door` | o que a placa e o mapa prometem é o que a sala dá | M | `gameplay-engineer` | MAP-01 | DV-1 | GUT: em 200 descidas do robô, para toda porta atravessada a recompensa dada, o tipo de sala, a dificuldade e o guardião são os da placa e os do nó; a romã nunca chega sem Bênção que possa subir; a mesma semente e o mesmo nó dão a mesma luta por caminhos diferentes; Maestria por sala igual à de hoje; `RESULT` e registro com `map` (semente, nós, arestas) e `rooms[].node`, `events` de porta com o nó escolhido e os oferecidos (`RunLog.VERSION` 4, linhas antigas lidas por `normalized`); `test_descent`, `test_e5_wiring`, `test_economy`, `test_trial` verdes |
| **MAP-03** | **P1** | **Mapa consultável (página funcional do Livro)**: ação `map` (`M`, Back no controle), botão "Mapa [M]" no HUD, entrada na pausa, caminho, sala atual, próximas portas, ramos deixados, marcas do `DoorGlyph` e "?" (`DoorGlyph.Kind.UNKNOWN` novo), legenda | `controls.gd` `ACTIONS` sem mapa; `hud.gd` `_room` no alto à esquerda; `door_glyph.gd` sem "?" | o jogador planeja a rota | M | `ui-ux-designer` (tela, HUD, texto), `gameplay-engineer` (ação `map`, pausa pelo `Game.open_screen`) | MAP-01 (lê o grafo; pode começar com um grafo fixo de teste) | DV-1 | abrir e fechar 20 vezes não muda o mapa; aberto, o relógio da partida não anda e nenhum inimigo age; ao fechar nenhum golpe escapa (`test_input_leak.gd` estendido); fluxo inteiro por teclado, controle e mouse num `tools/map_flow_check.gd`; legível a 720 e 1080 (marcas de pelo menos 18 px a 720, texto 14 px); o botão do HUD não cobre nada a 720; tecla real no botão; texto só no `text_pt.tres`, sem travessão; `M` e Back remapeáveis nas Configurações |
| **MAP-04** | P1 | **Robô e régua no grafo**: `bot_door` com o mesmo gosto de hoje e um passo à frente (com menos de 80% da vida prefere a porta que deixa a fonte ao alcance); régua da E6 refeita | `Rooms.bot_door` olha só a porta; `docs/qa/e6_metrics.md` medido na linha única | as métricas de balanceamento deixam de valer quando o mapa muda | P a M | `gameplay-engineer` (robô), `qa-performance` (régua) | MAP-02 | DV-1 | 24 descidas (reação 0,25, `--ultimate=cleave`): nenhum erro, ninguém preso, vitórias a no máximo 2 de 24 da base do C17 (23 de 24); 72 sementes Maestria 1 e 20 com a diferença ainda até 25 pontos; Bênçãos ao chegar a Morvath e ouro na loja anotados no `docs/qa/latest_report.md` |
| **MAP-05** | P1 | **Prova do aceite do PO** (vídeo e capturas) | pedido do PO | o PO vê a mudança sem precisar achar o caso | P | `qa-performance` | MAP-01 a MAP-03 | DV-1 | em `docs/gallery/dv1/`: vídeo na GPU de uma descida em que a sala mostra duas portas com consequências diferentes (o mapa aberto antes mostra o que cada uma alcança), o herói escolhe pela arena e `M` mostra o caminho feito; capturas do mapa de duas sementes com salas e ligações diferentes, todas as rotas chegando a Morvath; o `comparativo.md` e o `CLAUDE.md` atualizados |
| MAP-06 | P2 | Arte completa da página do mapa (tinta e ouro gravado no papel, nós pintados, vinheta da descida, Morvath no fim como selo) | depende da linguagem do Livro (ART-07) | o mapa fica com a cara do Livro | M | `art-director` (spec), `ui-ux-designer` | MAP-03; Q-23 se Ahk aparecer | AP-4 (junto do Livro) | capturas 720 e 1080 aprovadas pelo art-director; nenhuma marca diferente das placas |
| MAP-07 | P2 | Destaque da porta ao inspecionar um nó (foco num dos próximos nós acende a porta correspondente na arena e uma seta na borda da tela se ela estiver fora) | pedido do PO ("se couber") | liga o mapa à arena sem ler a placa | P a M | `ui-ux-designer`, `environment-artist` (luz da porta, `ArenaRoom`) | MAP-03 | DV-2 | foco em cada próximo nó acende só a porta dele; captura com o mapa aberto e a porta acesa atrás do véu |
| MAP-08 | P3 | Transições: página que vira ao abrir e fechar, caminho se desenhando a tinta ao entrar numa sala nova | pedido do PO (incremento) | acabamento | P | `ui-ux-designer` | MAP-03, MAP-06 | DV-2 | abrir e fechar em até 0,3 s; nada anima com o jogo pausado além da página |
| MAP-09 | P2 | Loja de rota no meio da descida (3 itens, em alguns ramos de 6 a 8), além da loja final | pedido do PO (Loja como escolha de rota) | escolha de rota pela economia | M | `gameplay-engineer` (dado no `_stage`), `ui-ux-designer` (placas) | Q-26 (b), Q-15 e a economia do C19 | DV-2 | 72 sementes: quem passa pela loja de rota chega a ela com ouro para ao menos um item em 2 de 3 descidas; ouro mediano na loja final dentro da meta do C19 |

#### DV-1 "Descida de Valmor I" (3 a 4 dias; em paralelo com o AP-1, arquivos distintos)

- **Objetivo**: a descida é um mapa gerado por semente no começo, as portas da arena são as ligações dele e o jogador
  consulta o caminho com `M` no Livro de Ahk.
- **Por que agora**: muda a decisão do jogador entre quase todas as lutas (o PO pediu como melhoria importante da Fase
  1); não depende das respostas do T6 (não mexe em números do combate); não há bug aberto que quebre o combate (os de
  C17 estão feitos, sobram BUG-108 e BUG-109, P2, e o 109 entra aqui); e precisa vir **antes do C19**, que vai mexer no
  mesmo `rooms.gd` (botão de usar da Q-13 e economia da loja da Q-15): é melhor o C19 construir sobre o grafo do que o
  grafo desfazer o C19. A leitura dos ataques, a animação e a explicação de Altar e Provação, que o PO pediu para pesar,
  foram feitas no T5 e no C17 e esperam o teste de gente (T6) e as aprovações do art-director e do combat-feel-director.
- **Entregas**: MAP-01, MAP-02, MAP-03, MAP-04, MAP-05, mais BUG-109 (e BUG-108 se couber).
- **Aceite central (do PO)**: numa descida, uma sala com duas portas de consequências diferentes para as salas
  seguintes; a escolha feita atravessando a porta na arena; o caminho confirmado no mapa com `M`; outra semente com outra
  combinação de salas e ligações, todas as rotas chegando a Morvath. Mais os aceites de cada item; `tools/test.sh` verde
  com contagem de asserções estável em 3 rodadas; sonda 40/40 (prova de que o combate não mudou).
- **Evidências**: `docs/gallery/dv1/` (MAP-05), saída dos testes de 1000 sementes, régua do MAP-04 no
  `docs/qa/latest_report.md`.
- **Agentes e arquivos**: `gameplay-engineer` (`run_map.gd`, `rooms.gd`, `trials.gd`, `stage_def.gd` e o `_stage` do
  `make_data.gd` para os números do grafo, `run_log.gd`, `bot.gd`, `controls.gd`, os testes); `ui-ux-designer` (tela nova
  `map_screen.gd`, `hud.gd`, `pause_menu.gd`, `door_glyph.gd`, `text_pt.tres`); `qa-performance` (MAP-05, régua);
  `combat-feel-director` não entra. O AP-1 (`environment-artist`) não toca nesses arquivos.
- **Riscos**: (1) régua da E6 e as métricas do robô deixam de ser comparáveis com as de antes (por isso o MAP-04 no mesmo
  ciclo); (2) grafo pequeno demais para as regras de arena em toda rota (6 arenas, até 3 usos, guardião no Santuário):
  gerar e validar com tentativas e contar falhas no teste; (3) mapa todo à vista tira a surpresa (por isso a Q-25 e o "?");
  (4) pausa pelo mapa no meio de um hit stop ou câmera lenta: usar o mesmo caminho da pausa; (5) `rooms.gd` tem 1100
  linhas (DT-106): o grafo fica no `RunMap`, puro e testado, e o `Rooms` só lê.

#### DV-2 "Descida de Valmor II" (2 a 3 dias, depois do C19)

- **Objetivo**: o mapa e a arena conversam (MAP-07), a loja vira escolha de rota (MAP-09) e o mapa ganha transições
  (MAP-08). A arte completa da página (MAP-06) vai junto com o AP-4, que já cuida do Livro.
- **Por que depois do C19**: a loja de rota depende da economia da Q-15, medida no C19.
- **Aceite**: os dos itens; robô de 72 sementes com a loja de rota.

### C19 "Variedade do combate e da descida" (4 a 5 dias, depois do T6)

- **Nota de 2026-11-18**: vem depois do DV-1 e trabalha sobre o grafo: o botão de usar (Q-13) vale para atravessar a
  porta escolhida no mapa, e a economia da loja (Q-15) é medida na régua refeita pelo MAP-04.

- **Objetivo**: inimigos e Morvath que pedem respostas diferentes, e escolhas da descida (loja, Elo, Salmo) que acontecem
  para quem joga.
- **Por que agora**: depois que a justiça está provada com gente (T6); muda dificuldade e números, então pede as respostas
  do Daniel.
- **Itens**: fase 1 de Morvath variada perto (CF-04, Q-09); elites com golpe próprio, esqueleto elite com dois golpes a
  0,2 s e corredor elite com explosão dupla, como dado (`strikes`, `strike_gap`) (CF-05, Q-11); Ômega carregando devagar
  com o número do Hades por ação (GP P2-1, Q-12); botão de usar para loja, recompensa e porta (GP P2-2, Q-13); aviso curto
  no chão para o orbe e o leque do Ancião ou a regra corrigida (GP P2-6, Q-14); economia da loja pela renda do Érebo (GP
  P2-5, Q-15); Elos e Salmos ao alcance (GP P2-4, Q-15); Ancião, 49% do dano antes de Morvath no robô (QA #4), e a
  tempestade, 51% do dano de Morvath (QA #3), conferidos pelo `warn_s` do registro antes de mexer.
- **Aceite**: `boss_cadence` em 3 sementes: na fase 1 nenhum ataque acima de 50% e nunca 3 iguais seguidos; elites com
  aviso cobrindo os dois golpes (aviso x dano 0 a 1 quadro), um elite novo sem código; loja com ouro mediano entre 150 e
  220 e 1/3 das descidas comprando além da cura (24 sementes); 72 sementes Maestria 1: Elo em 35% das descidas e Salmo
  visto em 15%, Maestria 20 até 25 pontos acima; encostar sem apertar não compra nem sai; todo tiro inimigo com `warn_s`
  a partir de 0,4.
- **Responsáveis**: `gameplay-engineer` (regras e dados), `combat-feel-director` (aceite de cadência), `art-director`
  (pose do segundo golpe da elite), `ui-ux-designer` (placa com a tecla de usar, remapear), `qa-performance` (72 sementes).
  Paralelismo: o gameplay é o dono do `make_data.gd`, `horde.gd`, `boss.gd`, `rooms.gd`; a UI trabalha só nas placas
  (`door_sign.gd`) e nas Configurações.
- **Riscos**: elites e Morvath mais variados podem endurecer a região (a D-11 pede primeira vitória em até 3 tentativas
  para quem jogou Hades); botão de usar muda o ritmo de saída das salas.

### C20 "Livro, título e prontidão técnica" (3 a 4 dias; depende de respostas do Daniel)

- **Nota de 2026-11-18**: a parte de arte deste ciclo (título, motivos da árvore, ilustrações do Livro, moldura de couro,
  medalhões) passou para o ciclo AP-4 do backlog de art polish (ART-06, ART-07, ART-08); o C20 fica com o técnico
  (pausa ao perder o foco, DT-103, DT-101, DT-106).

- **Objetivo**: a primeira imagem do jogo e o Livro com a identidade fechada, e a base técnica que a Steam vai exigir,
  sem começar a C16.
- **Itens**: título da prancha 08 com a maga aprovada e a decisão das cruzes (Q-07); etapa 3 do pacote (motivos pintados
  da prancha 09 nos 19 Dons, ART P1-10); ilustrações do Livro (cena de Ahk se aprovada, esboço em traço de cada inimigo
  no Compêndio pelo nosso próprio modelo assado, sem IA; ART P1-9, AUD); moldura de couro da árvore e abas como fitas
  (AUD); medalhões pintados das 25 Bênçãos e 6 Elos que faltam (AS #9, AUD; IA declarada); pausa ao perder o foco e ao
  desconectar o controle (GP P2-3); DT-103 (menus por controle); DT-101 fechado; DT-106.
- **Aceite**: `title_flow_check` passa com a arte nova e com controle; nenhuma cruz se o Daniel decidir pelo leão; cada
  nó da árvore com o motivo do próprio efeito legível a 720; página de cada inimigo descoberto com o desenho; foco perdido
  em PLAY abre a pausa (robô e `--smoke` nunca); `steam-ia.md` e `CREDITOS.txt` em dia.
- **Responsáveis**: `ui-ux-designer` (título, Livro, menus), `art-director` (spec e revisão), `technical-artist` (recortes,
  render em traço, licenças), `gameplay-engineer` (foco e controle).
- **Riscos**: depende de arte de IA do PO; o retrato do Guerreiro diverge da Emeth do modelo (Q-04).

---

## 4. Perguntas para o Daniel

Cada uma com as opções e a minha recomendação. As de número baixo bloqueiam mais.

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| Q-01 | **Meshy: em que plano foram gerados o herói, a Emeth e os nove inimigos (2026-11-15) e qual a licença?** | (a) plano pago: o modelo é seu, basta registrar; (b) gratuito: CC BY 4.0, precisa de crédito ao Meshy no `CREDITOS.txt` e na página da Steam | responder qual; com (b) eu ponho o crédito. **Bloqueia a Steam** (AS P1-3) |
| Q-02 | Livro de Ahk: o nome fica "Livro de Ahk"? | (a) "Livro de Ahk"; (b) "Crônica de Ahk"; (c) outro nome seu | (a): o cânone traz "Ahk, o Escriba" e o nome diz quem narra |
| Q-03 | Ahk narra o jogo ou aparece só como epígrafe? E a cena dele (prancha 04)? | (a) só epígrafe no começo de cada capítulo; (b) narrador com frases curtas nas telas do Livro; (c) também na partida | (b) no Livro, com frases suas ou do cânone; a cena de Ahk em silhueta até você aprovar o visual dele |
| Q-04 | O retrato do Guerreiro no Livro é o definitivo? (a Emeth dele é curta e reta, sem a guarda de chifres nem o punho vermelho) | (a) fica; (b) nova imagem com a Emeth certa (IA, declarada) | (b) quando houver a arte; até lá (a) |
| Q-05 | Textos das páginas do Livro: a Abertura repete o Como Jogar palavra por palavra | (a) Abertura narrativa (cânone, sua revisão) e o Como Jogar ensina; (b) como está | (a), sem inventar lore: eu proponho a partir do cânone e você aprova |
| Q-06 | Nome do especial: "Onda de Luz" (D-69, onda da lâmina)? | (a) Onda de Luz; (b) Onda da Emeth; (c) outro | (a) já existe no texto (`move_wave`); se você quiser outro, é uma linha |
| Q-07 | Arte do título: as cruzes (clérigo, peito dele, estandarte da fortaleza) viram leão? E entra a maga aprovada da prancha 08 (capa marfim, Cometa)? | (a) leão/espada no lugar das cruzes e a maga nova (arte nova de IA); (b) cruz fica só na arte do título; (c) espera o elenco | (a): o jogo inteiro já trocou cruz por leão e espada (D-16, D-17, D-66); a capa da Steam deve dizer o mesmo |
| Q-08 | Regra da Provação tardia (BUG-101) | (a) encontros limitados às lutas que restam e laje só onde cabem 3; (b) a luta de Morvath conta como encontro (a Bênção chega na vitória, inútil); (c) laje só até a profundidade 4 | (a): mantém a decisão de risco e não mente na carta |
| Q-09 | Fase 1 de Morvath vira foice em laço com o herói perto (80% foice) | (a) segundo golpe de perto no par da Hécate (rápido e depois lento com janela longa, clipe novo); (b) Lâminas das Almas a qualquer distância com um passo atrás (dado); (c) como está | (b) já no C17 se couber (só dado) e (a) no C19, junto com as elites. **(b) feita no C17** (`1957bb3`: dado `blade_step*` e o passo atrás no `boss.gd`; foice 91% para 62%, nunca 3 iguais); o aceite de no máximo 50% fica para a (a) no C19 |
| Q-10 | Ponte dos Condenados B: o patamar do meio é para andar? O parapeito hoje o atravessa | (a) sim, o parapeito contorna o patamar; (b) não, o patamar sai da planta | (a): o chão já é andável e os inimigos andam nele |
| Q-11 | Elites com golpe próprio como no Hades II (esqueleto elite com dois golpes, corredor elite com explosão dupla) | (a) copiar (D-39); (b) só armadura e velocidade, como hoje | (a), medido com gente |
| Q-12 | Ômega carregando devagar como no Hades (hoje anda a toda) | (a) número do Hades por ação; (b) meio-termo; (c) como está | (a): a carga ganha risco e peso; a esquiva corta |
| Q-13 | Botão de usar para loja, recompensa e porta (hoje encostar compra e sai) | (a) botão, como no Hades; (b) encostar | (a): evita comprar cura com a vida cheia e sair sem querer desviando de um golpe |
| Q-14 | "Todo ataque tem aviso no chão": o orbe do feiticeiro, o leque do Ancião e a trepadeira não têm (o Hades também não marca o orbe) | (a) linha curta da mira no preparo, como o besteiro; (b) mudar a regra para "todo ataque tem aviso, no chão ou no corpo" | (a) para o orbe e o leque; (b) para a trepadeira, que é lenta |
| Q-15 | Loja e combinações: o robô chega com 60 a 89 de ouro (a Bênção custa 150) e Elo/Salmo quase não aparecem (1 Elo em 12 descidas com Maestria 1) | (a) ajustar a renda e as chances pela régua do Hades e medir 72 sementes; (b) como está | (a): a regra central (Salmo transforma) não chega ao jogador nas primeiras horas |
| Q-16 | Nomes das ações: "Esquiva" ou "Avanço"? "Ultimate" fica em inglês? | Esquiva/Avanço; Ultimate ou um nome em português ("Golpe Supremo", "Juízo") | "Esquiva" (é o mais usado e "Avanço" já é parte de um Dom); "Ultimate" é decisão sua: eu manteria até você escolher um nome próprio |
| Q-17 | Créditos: "Criação e direção: Daniel Sacramento" no `CREDITOS.txt` está como você quer? | (a) assim; (b) outro nome ou estúdio; (c) sem nome | o que você preferir; é o que vai para a Steam |
| Q-18 | Créditos do Meshy (546): lote proposto pelo technical-artist | estátua encapuzada (15), armas próprias dos inimigos e o gancho de Morvath (cerca de 120), repintura das elites (60); até 195 | autorizar a estátua e as armas depois do C18 (D-46 já disse "lote com orçamento"); as elites esperam a Q-11 |
| Q-19 | `hero_sombra/` e `paladin_1/` (60 MB, sem uso) saem do repositório? | (a) sim, o histórico do git guarda; (b) ficam | (a) |
| Q-20 | Música: tirar uma peça que ninguém escolhe ou reencodar para abrir folga (0,78 MB do teto de 18) | (a) reencodar um passo abaixo (sem diferença audível medida); (b) tirar uma peça | (a) |
| Q-21 | Copa da árvore do Jardim (prancha 07) | (a) cartões de folhagem procedurais, sem créditos; (b) modelo do Meshy | (a) |
| Q-25 | **Descida de Valmor: o que o "?" esconde e quanto o mapa mostra** | (a) o mapa mostra o tipo de sala e de recompensa de todos os nós desde o começo; "?" só no nó onde a laje da Provação vai aparecer; (b) como (a), e o "?" também esconde às vezes a Fonte ou o Altar, revelados ao entrar; (c) o mapa mostra recompensas só das próximas portas e do passo seguinte; o resto só o tipo de sala | (a): é o que deixa planejar como no Darkest Dungeon II, a Provação continua com mistério e nada prometido muda (a romã que não pudesse subir vira Bênção antes da placa aparecer, o que na prática não acontece) |
| Q-26 | **Loja: a "última loja antes do chefe" continua?** Hoje ela é sempre a sala 10, com 5 itens | (a) fica fixa na 10, todas as rotas passam por ela, como no Hades II; a escolha de rota fica entre Fonte, Altar, guardião e recompensas; (b) fica a final e entra uma loja de rota menor (3 itens) em alguns ramos de 6 a 8; (c) só lojas de rota, sem a final (quem não passou por uma enfrenta Morvath sem gastar) | (a) no DV-1 e (b) no DV-2, depois de acertar a renda (Q-15): hoje o robô chega à loja com 60 a 89 de ouro e uma loja no meio quase nunca teria o que comprar. (c) eu não recomendo: o ouro perde sentido em metade das rotas |
| Q-27 | **Guardião como escolha de rota** | (a) quando a camada do guardião tem dois nós, um é o Cavaleiro e o outro o Ancião, com o nome no mapa (a placa segue dizendo "Guardião"); (b) um guardião sorteado e escondido, como hoje | (a): são lutas muito diferentes (o Ancião deu 49% do dano antes de Morvath no robô) e escolher contra quem lutar é uma decisão boa de rota |

**Decisões antigas que ainda valem e esperam confirmação** (tomadas pela recomendação e implementadas; o Daniel não
respondeu): D-51 (quem concede as Bênçãos: os três companheiros e o voto do herói, texto quando os nomes existirem),
D-52 e D-53 (quatro raridades, lendária só pela troca, multiplicador fixo), D-55 (nomes das ultimates: hoje Corte do
Juízo e Voragem), D-62 (Compêndio só com texto de jogo), D-63 e E6-D1 (Juramentos; o nome fica perto dos "Juramentados" do
cânone; Ainda de Pé não levanta na sala de Morvath), D-08, D-14, D-16, D-17, D-18, D-20, D-21, D-22 (câmara e quadro P&B).
**Abertas de antes, sem mudança**: D-01 (título de Morvath; hoje "o Rei que Traiu a Luz"), D-02 e D-04 (quem sela
Morvath, nomes dos paladinos), D-09 (Magia na luta do chefe), D-11 (meta da primeira vitória: até 3 tentativas para quem
jogou Hades), D-23 (porta selada e véu de runas, sem texto até o cânone ter), D-31 e D-32 (água e destrutíveis, arenas
futuras), D-37 (referência 04 no histórico do git), D-41 (nomes de Eterra para romã e loja), D-07, D-12, D-13.
**Fechadas**: D-03, D-05 (substituída pela Q-18), D-06, D-15, D-38, D-40, D-48 e D-49 (o herói é "O Guerreiro", D-64;
"guardião" fica na sala), D-10, D-12b, D-39, D-42 a D-47, D-50, D-54, D-56 a D-61, D-64 a D-71.

**O que só o Daniel jogando responde** (o robô não mede): se os orbes e o corredor ficaram justos, se Morvath dura 2 a 4
minutos para gente (robô: 68 a 146 s), se o Ômega é usado (PO: mediana 1 por partida), se a ultimate se sente, se a
música e os efeitos agradam, e se o herói se acha nas fases 2 a 4.

---

## 5. Ordem sugerida

Revista em 2026-11-18 com a Descida de Valmor. A lista anterior (BUG-101 a BUG-104, QW-101 a QW-112, C17 e C18) está
feita (seção 0 e as marcas "Feito" nas tabelas).

1. **T6**: o exe do C17 com o C18 nas duas pastas e o PO joga (já pronto; as respostas destravam o C19 e o AP-2). Junto,
   as aprovações que faltam: QW-104 e QW-106 (art-director), QW-107 e QW-111 (combat-feel-director).
2. **MAP-01** grafo da descida por semente, com **BUG-109** (o `test_descent` instável é reescrito aqui) e BUG-108 se
   couber (`gameplay-engineer`).
3. **AP-1 "Nada de protótipo"** em paralelo com o DV-1 inteiro (`environment-artist`; arquivos distintos).
4. **MAP-02** portas da arena = arestas do grafo, recompensa prometida igual à dada, registro com o caminho.
5. **MAP-03** mapa consultável com `M`, botão no HUD e na pausa (`ui-ux-designer`; pode começar com um grafo fixo de
   teste junto com o item 2).
6. **MAP-04** robô e régua da E6 refeitos no grafo; **MAP-05** prova do aceite do PO; exe do DV-1 com o AP-1 (T7, um
   teste só para as duas entregas).
7. **C19** variedade (Morvath fase 1, elites, Ômega, botão de usar, economia da loja, Elos e Salmos), com as respostas
   do T6 e sobre o grafo.
8. **AP-2 "Combate que se lê"** (depende do T6; ao lado do C19 se os arquivos não se cruzarem, como diz o
   `art_polish_backlog.md`).
9. **DV-2**: MAP-07 destaque da porta, MAP-09 loja de rota (Q-26 b e Q-15), MAP-08 transições.
10. **C20** técnico (pausa ao perder o foco, DT-103, DT-101, DT-106), **AP-3** e **AP-4** (com o MAP-06, arte da página
    do mapa no Livro), conforme as respostas Q-01 a Q-07, Q-22 a Q-24.

---

## 6. Art polish (diretriz do PO de 2026-11-18)

O backlog de arte agora mora em **`docs/art/art_polish_backlog.md`** (diagnóstico, itens ART-01 a ART-10 com o que o C17
e o C18 já resolveram, roadmap AP-1 a AP-4, decisões e o primeiro ciclo), com o guia em valores em
**`docs/art/art_direction.md`** (primeira versão, a revisar pelo art-director). Os itens de arte deste backlog levam o
número ART-xx de lá e não se repetem aqui. Ciclos de arte em série, um por vez, ao lado do C19 quando os arquivos não se
cruzam. Próximo recomendado: **AP-1 "Nada de protótipo"** (recompensas lidas sem placa, relicário, estela da Provação,
câmaras de evento assentadas, portal do salão, braseiros, janelas da Câmara). Perguntas novas para o Daniel: Q-22 (cor
dos estandartes), Q-23 (como Ahk aparece) e Q-24 (de onde vêm os medalhões pintados), na seção D daquele documento; ele
reaproveita Q-03, Q-04, Q-05, Q-07, Q-13 e Q-18 daqui.
