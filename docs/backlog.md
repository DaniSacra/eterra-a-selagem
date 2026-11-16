# Backlog de A Selagem

- **Data**: 2026-11-16 (noite). **Autor**: game-director (sexta revisão: a Game Feel Review pedida pela diretriz do Daniel).
  **Commit lido**: `71cb8cc` (HEAD de `arpg-3d`); desde a revisão anterior (`87ba686`): `fffd677` (roteiro), `4d281bc`
  (ART-R1), `c5798a8` (QA-01), `beb6c27` (C12c), `f07549f` (revisão visual), `74af372` (medidas de game feel), `71cb8cc`
  (QA-02 e vídeos de game feel).
- **Diretriz de prioridade máxima**: `docs/design/game_feel_directive.md` (game feel e excelência visual antes de
  conteúdo). **Revisão oficial**: `docs/design/game_feel_review.md` (por área, com evidência e tipo de cada problema).
  Planejamento e ordem dos ciclos: `docs/design/roadmap_plan.md` (seção 0, nova).
- **Fontes lidas**: `game_feel_measures.md` (A a L), `visual_review.md` (V-*), `docs/gallery/game_feel/VIDEOS.md` e os
  vídeos (quadros tirados com `ffmpeg` e olhados), `docs/qa/latest_report.md` (QA-02), `docs/gallery/cycle12c/AFTER.md`.
- **Rodado por mim**: `tools/feel_probe_run.gd` no `71cb8cc` (a saída bate com as medidas). Nada do jogo foi mudado.
- **Decidido pelo Daniel**: D-39 (mecânicas e números do Hades II fielmente, nomes e arte de Eterra) continua valendo.

## Estado do jogo em 5 linhas

1. A Fase 1 joga do título à selagem em 7 salas; o C12c (`beb6c27`) passou em 7 dos 9 itens de aceite (QA-02): 0 preso em
   96 lutas e 8 descidas, câmera 0,4 m, som -2,94 dBFS, registro v2, 495 testes, nenhum número de combate mudado.
2. Abertos do C12c: **A-1** colunas da recompensa e da fonte ainda 255 na tela (em correção), **M-1** cantos da Cripta
   abaixo de 45, B-1 a B-3 baixos.
3. A Game Feel Review diz: o combate responde no quadro mas **some aperto** (esquiva na preparação, ataque na esquiva,
   buffer curto) e **gruda** (hit stop copiado como congelamento); os inimigos não reagem ao golpe.
4. No visual: fita do corte opaca longe da lâmina, brilho do finalizador sobre o herói, avisos vermelhos empilhados,
   multidão animada aos saltos, armas do KayKit. O cenário e as silhuetas estão no caminho.
5. Próximo: **C12d "Game feel I"** (a mão do jogador: resposta, impacto e leitura) e depois o teste do Daniel; conteúdo
   novo (C13 longo, C14 arenas) espera o acabamento, pela regra da diretriz.

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (neste ciclo), P2
(próximo), P3 (depois). **Estado**: aberto, em andamento, proposta (espera o Daniel), aprovado, feito. Responsáveis:
`gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito (fechado com evidência)

### C12c "Qualidade da experiência" (`beb6c27`, medido no QA-02 `71cb8cc`)

| ID | Item | Estado | Prova |
|---|---|---|---|
| GP-01 | Colunas e gemas abaixo do glow; Morvath entra sem coluna | **em parte**: entrada de Morvath passa (corpo 45 aos 0,5 s, sem coluna); gemas com cor de volta mas canal dominante 255; colunas da recompensa e da fonte **255 na tela** (A-1, em correção) | `cycle12c/AFTER.md` GP-01; `after/coluna_recompensa_criptaA.jpg`, `coluna_fonte.jpg`, `morvath_entrada_0_5s.jpg` |
| GP-02 | Registro v2 (`source`, `boons_at_boss`, `shop`, `fountain_used`, `hurt_ctx` com `warn_s`, `dash_ready`, `offscreen`; por sala `variant`, ouro, dons, esquivas, golpes, tiros, `blocked_by`) | feito | QA-02 item 6; `after/descida_run.jsonl` |
| GP-03, GP-04 | `resolve` acha o lugar livre mais perto; cercado nos corredores mais estreitos, 16 de 16 esquivas saem | feito | `beb6c27`; testes |
| GP-05 | Limitador -1 dB no `Master` | feito | pico -2,94 dBFS na descida com som (QA-02 item 5) |
| GP-06 | `--trace-cam`; alvo da câmera a no máximo 24 m/s | feito | maior salto 0,400 m em 46 salas (antes 2,9 m) |
| (QA-01) | Aviso no chão não fere depois da sala vencida | feito | `after/sem_dano_apos_sala_vencida.jpg` |
| UI-01, UI-02 | `DoorSign` (18 px a 1080, contraste 12:1); derrota com sala, arena e dons | feito | `work/ui_after_doors_1080.jpg`, `ui_after_end_1080.jpg`, `tests/test_end_screen_run.gd` |
| ENV-01 | Chão da Cripta na luta 45 a 60 | **em parte**: mediana 30 para 43,5, 4 de 8 recortes no alvo; oeste e norte 19 a 34 (M-1) | `after/crypt_vA_c_recortes.jpg`, `crypt_vB_c_recortes.jpg` |
| ENV-02 | Fraturas da árvore até 200 | feito (máximo 198) | `AFTER.md` ENV-02 |
| ENV-03 | Jardim no Compatibility (sem sombra da lua) | feito pelo `environment-artist`, não remedido pelo QA | `work/env_garden_compat_antes_depois.jpg` |
| ART-R1 | Fendas reconferidas (F-1 a F-3, F-5, F-6, G-1 passam; F-4 dois pontos abaixo) | feito; D-38 sem objeto | `4d281bc` |
| QA-01, QA-02 | Linha de base e medidas depois, vídeo de descida com som a 1080 (DT-004), 11 vídeos de game feel | feito | `c5798a8`, `71cb8cc`; `docs/gallery/cycle12c/`, `docs/gallery/game_feel/` |
| GF-R | Game Feel Review: medidas (`74af372`), revisão visual (`f07549f`), vídeos (`71cb8cc`), revisão oficial | feito | `docs/design/game_feel_review.md` |

Aceite do C12c (roadmap D): itens 1, 2, 4, 5, 6, 7, 8, 9 passam; **3 não passa** (colunas, A-1) e o 3b passa em parte
(M-1). O C12c fecha quando o A-1 entrar com captura na GPU; o M-1 pode fechar por aceite do `art-director` (cantos
escuros de propósito, aceite só no terço central) ou por correção.

### C12b "Fecho das Fendas" (2026-11-16)

| ID | Item | Commit | Prova |
|---|---|---|---|
| F-1 a F-5 | Paredes da fenda escuras com bruma violeta abaixo (`rift_haze.gdshader`), bordas quebradas com pedras caídas, pontes com lajes próprias, meio-fio, parapeito vazado, pilares de canto e pegões, lua como luz principal | `87ba686` | `work/fix_rift_vA_antes_depois_cenario.jpg` (olhado: a fenda lê como rasgo com pontes); medidas de aceite a reconferir pelo `art-director` (ART-R1) |
| F-6 | Inscrições fracas entre a fenda e o buraco | `87ba686` | idem |
| G-1b | Ar do Compatibility nas Fendas | `87ba686` | `work/fix_rift_vA_compat_vs_forward.jpg` |
| D-39 | O Daniel confirmou: mecânicas e números do Hades II fielmente, nomes, personagens, UI e arte de Eterra | conversa de 2026-11-16 | `docs/design/roadmap_plan.md` |

### C12a2 "Medir certo" e C12 "Arenas I" (2026-11-16)

| ID | Item | Commit | Prova |
|---|---|---|---|
| BUG-014 | "Derrotado por" e `boss.hurt_by` com o golpe que matou (`Player.was_hurt` antes de `died`) | `f25ae5f` | `tests/test_killing_blow.gd` |
| QW-011 | `RESULT` e `runs.jsonl` com `rooms` (`depth`, `layout`, `hp_in`, `hurt_by`, `time`, `contact`), `hp_at_boss`, `arena`, `stuck`, `stuck_by`, `shots_blocked` | `f25ae5f` | `core/room_tally.gd`; `METRICAS.md` seção 1 |
| QW-013 | Vida ao entrar no chefe na métrica do robô | `fd72101` | `METRICAS.md` seção 2: `hp_at_boss` 12 a 53, mediana 24, 8 descidas |
| DT-008 | Momento do pico do passo: `--trace-steps`; os picos de 5 a 12 ms caem num sistema diferente a cada vez, fora de custo próprio (interrupção da máquina) | `f25ae5f` | `METRICAS.md` seção 3; o que sobrou virou QA B-1 |
| BUG-015 | Tiros param em pedra acima de 1,25 m, com faísca; ramo rasteiro do sacerdote para em tudo que barra corpo | `f25ae5f` (C12-F4) | testes em `test_arenas.gd`; 1,1 a 1,3 tiros barrados por luta na Cripta |
| BUG-016 | Nascimento por zonas com caminho; limite dos tiros pela sala real | `f25ae5f` (C12-F5) | `test_arenas.gd`; 0 preso em 192 lutas |
| C12-F1 a F9 | `RoomLayout` estendido, `FloorShape.POLY` com buracos, `Arena.sweep`, `NavGrid` e `FlowField`, linha de tiro, nascimento e saídas, `cam_bounds`, robô com caminho, escolha da arena sem repetir, `--arena`, `--variant`, `tools/arena_lab.gd` | `f25ae5f` | 455 testes no commit; QA seções 2 e 3 |
| C12-A0 | Salão das Catacumbas como arena (abertura, fonte, loja; `--arena=hall`) | `f25ae5f` | `METRICAS.md` seção 5 (5,09 ms) |
| C12-A1 | Cripta dos Esquecidos, 2 variantes | `e2297ee`, `95c29c6` | `cycle12_maps/crypt/`; aprovada na `ART_REVIEW.md` |
| C12-A2 | Salão das Fendas, 2 variantes | `e2297ee` | `cycle12_maps/rift/`; arte corrigida no `87ba686` (C12b acima) |
| C12-A3 | Jardim das Raízes Mortas com a árvore petrificada (D-30) | `91cc656`, `95c29c6` | `cycle12_maps/garden/`, `work/garden_grid_a`; aprovado |
| D-27 | Descida de teste de 7 salas (`--short` volta à de 5) | `f25ae5f` | `test_descent.gd` |
| D-28 | Golpe empurra até a borda, ninguém cai | `f25ae5f` | `Arena.sweep`; 0 corpo fora do chão |
| D-33 | Nome da arena por 2 s ao entrar (`Hud.show_place`, chaves `arena_*`) | `f25ae5f` | `vX_b_explorador.jpg` |
| D-34 | Estandartes com o leão no salão e nas arenas (a câmara segue com a espada) | `501f3d8` (spec), `e2297ee` | `ArenaKit.Emblem.LION`, `banner_lion.gdshader` |
| C-1 a C-4 | Tampa do túmulo no valor da pedra sob facho 1,6; capitéis e aduelas; degraus no valor da cantaria; lápides | `95c29c6` | `work/fix_crypt_antes`/`_depois` |
| J-1 a J-4 | Cristais esmeralda corrompido escuro; casca torcida com grão, líquen e fraturas, tronco 1,16 a 1,22 do chão; raízes com dois lombos e pontas abertas; capim | `95c29c6` | `work/fix_garden_arvore_antes_depois` (olhado: os cristais deixaram de competir com a Emeth) |
| G-1 (Cripta e Jardim) | Compensação do Compatibility por sala (`COMPAT_*`) | `95c29c6` | `work/fix_crypt_compat`, `fix_garden_compat`; **as Fendas ficaram de fora** (G-1b abaixo) |
| DT-004 (parte) | Vídeo de travessia por arena (20 s, 1280 x 720, sem som) | `fd72101`, `95c29c6` | `cycle12_maps/*/travessia.mp4`; o vídeo da luta com som segue aberto |

### Antes (histórico)
- C12a da madrugada (BOSS-001 a 003, QW-006 a 008, BUG-010 a 012, DT-007, D-24), atiradores do Hades II (`da35721`,
  `c666f4a`), teste T1 do Daniel: ver `752ceee:docs/backlog.md`.
- C10 e C11 (BUG-001 a 009, QW-001 a 005, ART-001, ART-003 a 009, Câmara do Selo): `fa30024:docs/backlog.md`.

---

## 1. Bugs

Nenhum crítico. Os altos são do combate: aperto que some é regra quebrada (D-39) e fere a direção ("o jogador vence por
habilidade e esquiva"). Os itens completos estão na seção 1a (GF, VX).

### Alto

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| A-1 | Colunas de luz da recompensa e da fonte 255 na tela (miolo 93 a 100% acima de 235) | QA-02 A-1; `after/coluna_recompensa_criptaA.jpg`, `coluna_fonte.jpg` | P | `gameplay-engineer` (valor do `art-director`) | **em correção** | recorte da coluna (915, 120, 90 x 330) com maior canal até 235 na captura da GPU; herói dentro dela legível |
| GF-02 | Esquiva apertada na preparação de um golpe some (golpe 1 quadros 1 a 4, seta 1 a 6, giro 1 a 22) | `game_feel_measures.md` problema 2; sonda `_s_dodge_cancel` | P | `gameplay-engineer` | aberto | `_s_dodge_cancel` sem nenhum `LOST` |
| GF-03 | Ataque apertado durante a esquiva (quadros 1 a 13), no último quadro dela e durante o golpe sofrido some | problemas 3 e 4; `_s_attack_in_dodge`, `_s_extra`, `_s_hurt` | P | `gameplay-engineer` | aberto | aperto nos quadros 1 a 13 vira golpe da esquiva no 13 ou 14; nada `LOST` |
| GF-01 | Hit stop é congelamento total (cópia errada do `ScreenPreWait` do Hades) | problema 1; `_s_kill` (3 quadros parados no abate do golpe 1), `_s_combo_on_hit` (`frozen_frames=6`) | M | `gameplay-engineer` | aberto | ver GF-01 na seção 1a |
| VX-11 | `PALADIN_4`, `PALADIN_2` e `PALADIN_3` aparecem para o jogador na carta de dom ("Luz, dom de PALADIN_4") | V-U1, `carta_dom_720.jpg`; `data/text_pt.tres` linhas 29 a 31 | P | `ui-ux-designer` | aberto | nenhuma chave `PALADIN_` visível em nenhuma tela (teste que monta a carta de cada família e procura "PALADIN") |

### Médio

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| GF-05 | Câmera lenta de 3 abates vira 0,28 s de tela congelada | problema 5; `_s_kill` (17 quadros `stepped=false` a 0,2) | P | `gameplay-engineer` | aberto | no máximo 3 quadros parados, depois a lentidão a 0,2 visível (`stepped=true`) |
| GF-06 | Controle virtual (robô, toque futuro) perde apertos no hit stop | problema 9; `_s_hitstop_buffer` (`pad ... LOST`) | P | `gameplay-engineer` | aberto | `pad` igual ao `keyboard` |
| M-1 | Cantos oeste e norte da Cripta com chão 19 a 34 na luta | QA-02 M-1; `after/crypt_vA_c_recortes.jpg` | P | `environment-artist` ou aceite do `art-director` | aberto | recortes do QA com 45 ou mais, ou aceite escrito só para o terço central |
| QA M-1 (antigo) | Referência `04` em tamanho cheio no histórico do git | backlog anterior | P | Daniel (D-37) | aberto | D-37 tomada |

### Baixo

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| B-1 (QA-02) | Gemas das portas com o canal dominante em 255; Dom e Ouro da fonte quase brancas (239, 238) | `after/gemas_portas_criptaA.jpg`, `coluna_fonte.jpg` | P | `gameplay-engineer` (`Rooms.gem_color`) | aberto | maior canal até 235 se o `art-director` mantiver o aceite; senão aceite escrito |
| B-2 (QA-02) | O robô nunca usa a fonte (`fountain_used: false` em 8 de 8): `Bot.step` volta antes do trecho da fonte com a sala vazia | QA-02 B-2; `bot.gd` perto da linha 189 | P | `gameplay-engineer` | aberto | `fountain_used: true` em pelo menos 6 de 8 descidas em que ele entra com menos de 60% |
| B-3 (QA-02) | Limitador no teto em 67 janelas de 0,1 s | QA-02 B-3 | P | `gameplay-engineer` | aberto, vai para a mixagem do C15 | pico e LUFS do C15 |
| B-1 (antigo) | Pico do passo acima de 2 ms em poucos quadros | backlog anterior | P | `gameplay-engineer` | aberto | p99 do passo abaixo de 2 ms |
| BUG-013 | Comando da investida na spec da câmara | backlog anterior | P | `art-director` | aberto | spec com `--bot-kite=1` |

---

## 1a. Game Feel e Excelência Visual (GF, VX)

Origem: `docs/design/game_feel_review.md` (área e evidência de cada item), `game_feel_measures.md` (propostas A a L),
`visual_review.md` (V-*). Campos: ID, ciclo, prioridade, descrição, problema, valor para o jogador, aceite, dependências,
responsável, estado, evidência. "Sonda" = `~/tools/godot/godot --headless --path . --fixed-fps 60 -s
tools/feel_probe_run.gd -- --nosave --start=fountain` (`PROBE=_s_x` roda um cenário). Tipo: **cópia** (errada ou que
faltou do Hades II, corrige sem perguntar), **bug**, **arte** (direção já aprovada), **Daniel** (decisão aberta).

### Game feel (GF)

| ID | Ciclo | P | Descrição | Problema | Valor para o jogador | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|---|
| GF-14 | C12d | P0 | Sonda com metas: a `feel_probe` imprime uma linha `FEEL <meta> ok/falha` por meta deste ciclo e um `FEEL_SUMMARY n/m` | hoje a sonda imprime quadros, não diz se passou | aceite do ciclo verificável por qualquer agente | rodada no HEAD antes das mudanças mostra as falhas esperadas (GF-01 a GF-08); a mesma rodada no fim mostra todas ok | nenhuma (roda primeiro) | `qa-performance` | aberto | `tools/feel_probe.gd` |
| GF-02 | C12d | P0 | Esquiva corta a preparação (`ComboRunner.can_cancel` também no WINDUP) e o aperto da esquiva entra no buffer | aperto some (cópia: o Hades corta a carga) | "apertei e esquivou", sempre | `_s_dodge_cancel`: nenhum `LOST`; golpe cortado não dá dano; teste GUT | nenhuma | `gameplay-engineer` | aberto | medidas tabela 3 e 5, problema 2 |
| GF-03 | C12d | P0 | Ler ataque e especial durante a esquiva e o golpe sofrido; soltar o golpe da esquiva no fim dela; aperto no último quadro vale | ataque some nos quadros 1 a 13 (cópia: `DashAttackQueue`) | ataque e esquiva encadeiam como no Hades | `_s_attack_in_dodge` e `_s_extra`: aperto nos quadros 1 a 13 vira golpe da esquiva no 13 ou 14; `_s_hurt`: aperto guardado sai no 11 | nenhuma | `gameplay-engineer` | aberto | problema 3, tabela 4 |
| GF-04 | C12d | P0 | Buffer contado do momento em que o golpe pode sair (trava de gatilho), não do aperto | apertos nos quadros 1 a 3 do golpe 1 e nos 32 primeiros do giro somem | combo sem aperto perdido | `_s_buffer`: o 2º aperto vale em qualquer quadro do golpe 1 e do giro; `tests/test_combo.gd` estendido | nenhuma | `gameplay-engineer` | aberto | tabela 4 |
| GF-01 | C12d | P0 | Hit stop no molde do Hades: por golpe a espera (25, 65, 70, 50 ms), a fração (6%) e a lentidão (10 ms; +40 com abate), volta em 20 ms; em tempo real, por `Engine.time_scale`; dados no `ComboNode` gerados pelo `make_data.gd` | congelamento inteiro a partir do quadro seguinte | o golpe morde sem grudar; o clarão e o empurrão aparecem | `_s_attack_hit`, `_s_combo_on_hit`, `_s_kill`: 0 quadros `stepped=false` por hit stop; 1 a 3 quadros a 6% depois da espera; teste GUT da agenda | nenhuma | `gameplay-engineer` | aberto | problema 1, tabela 7 |
| GF-05 | C12d | P0 | `Fx.tick` desconta o hit stop em tempo real; a câmera lenta de vários abates só começa quando o hit stop acaba | 0,28 s de tela congelada | a câmera lenta se vê | `_s_kill` (3 abates): no máximo 3 quadros parados, depois `time_scale` 0,2 com `stepped=true` | GF-01 | `gameplay-engineer` | aberto | problema 5 |
| GF-06 | C12d | P1 | `VirtualPad` guarda os toques até o jogo andar (como o `_latched` do teclado) | o robô e o toque perdem apertos | métricas do robô sem esse viés; toque futuro | `_s_hitstop_buffer`: `pad` sai como `keyboard` | nenhuma | `gameplay-engineer` | aberto | problema 9 |
| GF-07 | C12d | P1 | Seta: trava de ataque 18 quadros após o disparo, recarga própria 0,7 s, dardo 62,5 m/s (a parada das pernas de 0,71 s espera a D-44) | trava 35 quadros, dardo a 30 m/s | especial deixa de travar o combo | `_s_special`: golpe no quadro 25, especial no 48 | D-44 só para a parada | `gameplay-engineer` | aberto | problema 7, tabela 5 |
| GF-08 | C12d | P1 | Ômega do ataque acerta ao encher (brilho dentro da carga) | acerta 0,14 s depois | o Ômega sai quando a barra enche | `_s_omegas`: acerto no quadro 48 | nenhuma | `gameplay-engineer` | aberto | problema 10 |
| GF-09 | C12d | P2 | Pequenos fiéis: direção instantânea e corpo a 1340 graus/s; botões lidos antes de andar (planta no quadro do aperto); proteção da esquiva 19 quadros desde o aperto; Ômega do especial conferido contra `ProjectileStaffBallCharged` | divergências sem razão escrita | virada e golpe mais limpos | `_s_turn`: direção a 180 no quadro 1, corpo em até 8 quadros; `_s_walk_cancel`: `walked 0:0.00`; `_s_dodge`: `inv` até o quadro 18; tabela do Ômega do especial no `game_feel_measures.md` preenchida | nenhuma | `gameplay-engineer` | aberto | problemas 13, tabela 10 |
| GF-10 | C12d | P1 | Impacto seco: tranco e tremor dos golpes comuns na escala do Hades (0,05 a 0,1 m); clarão do inimigo 0,05 s com o 1º quadro visível; o que fica maior nos finalizadores e no Ômega o `art-director` fixa pelo vídeo | tranco 6 a 11 vezes o do Hades; clarão 0,14 s | golpe legível, avisos não tremem | sonda `_s_attack_hit`: `kick` até 0,1 m no golpe 1, `flash_t` 0,05; vídeo (c) antes e depois aprovado pelo `art-director` | GF-01 | `gameplay-engineer`, `art-director` | aberto | problemas 8 e 12 |
| GF-11 | C12d | P1 | Som de lâmina no disparo de cada golpe (não só se erra), som de carga no giro e nos Ômegas; vibração por golpe no controle (`Input.start_joy_vibration`), com opção no Conforto | 0,37 s mudos no giro; sem vibração | o golpe se ouve antes de acertar | teste do `Audio`: todo `ComboNode` tem som de disparo; vídeo (b) com som mostra o som no quadro do disparo; opção de vibração salva | nenhuma | `gameplay-engineer` (sons provisórios CC0 ou síntese), `ui-ux-designer` (opção) | aberto | problema 11 |
| GF-13 | C12d | P1 | Latência de ponta a ponta na placa (vsync ligado e desligado): aperto marcado e quadros até o primeiro pixel mudar | só a lógica foi medida | saber se o vsync atrasa | número em ms por ação (andar, golpe, esquiva) no relatório do QA | nenhuma | `qa-performance` | aberto | medidas, "Como foi medido" |
| GF-12 | C12f | P1 | Reação ao golpe dos comuns sem armadura no molde do Hades: atordoamento curto, para de andar, interrompe a preparação, por inimigo (`EnemyDef`, imune no próprio ataque como no Hades) | o golpe não muda o comportamento de ninguém | acertar faz diferença; leitura de controle da luta | teste GUT: esqueleto acertado na preparação não ataca; robô 0,25 em 8 descidas antes e depois | **D-42** | `gameplay-engineer` | proposta | tabela 8, problema 6 |
| GF-15 | C12e | P2 | Arranque e parada animados (clipes curtos só no desenho) | sem peso visual ao arrancar e parar | corpo com peso sem atraso | sonda `_s_move` igual (velocidade cheia no quadro 0); vídeo (a) antes e depois | nenhuma | `gameplay-engineer` (`tools/bake_hero.gd`) | aberto | tabela 2 |

### Excelência visual (VX)

| ID | Ciclo | P | Descrição | Problema | Valor para o jogador | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|---|
| VX-01 | C12d | P0 | Fita do corte comum presa à lâmina: corpo em tinta escura translúcida (alfa até 0,6), borda de ataque fina marfim-menta, verde pálido (saturação até 0,45); começa na ponta da Emeth no quadro do golpe e varre com ela 2 a 3 quadros | folha verde opaca a 2 ou 3 m da lâmina | o corte lê como luz da espada | `--shot-on=hit --shot-after=0.033`: menos de 15% dos pixels da fita com saturação acima de 0,6; ponta a menos de 0,5 m da ponta da Emeth; vídeo (g) antes e depois | nenhuma | `environment-artist` (`slash.gdshader`, `slash_ink.gdshader`), `gameplay-engineer` (o encaixe na lâmina em `fx.gd`/`combat.gd`) | aberto | V-E1; `g_combo_finalizador_0_25x.mp4` 4,5 a 6,5 s |
| VX-02 | C12d | P0 | Brilho do finalizador fora do corpo: anel até 0,6 da altura do herói, centro na ponta da espada, cruz com miolo transparente | o anel cobre o herói 5 a 6 quadros | herói sempre legível | no quadro do brilho, nenhum pixel do anel com alfa acima de 0,5 sobre a caixa do corpo do herói | nenhuma | `environment-artist` (`glint.gdshader`), `gameplay-engineer` (`Fx.GLINT_SIZE` e a posição) | aberto | V-E2; `g_acertos_reacao_0_25x.mp4` 7,4 a 8,4 s |
| VX-03 | C12d | P0 | Avisos em linha e retângulo: preenchimento até 0,35 que sobe só nos últimos 30% do preparo; sobreposição pelo máximo, não pela soma; borda e divisa como estão; tempo, área e assinatura de Morvath iguais | massa vermelha sob o herói em grupo | escolher a saída dentro de três avisos | três avisos sobrepostos não passam do alfa de um cheio; anel do herói visível dentro deles; `test_storm_wedge.gd` e testes de aviso passando | nenhuma | `environment-artist` (`ground.gdshader`, `ground_look.gd`) | aberto | V-L1; `d_especial_circulo_omegas.mp4` 0:01 a 0:02 e 0:10 a 0:15 |
| VX-08 | C12d | P1 | Morvath e guardiões mantêm a cor queimando: borda de fogo até 0,25, brasas pela metade | manto violeta vira laranja | o chefe sempre lê como ele | no meio da fase 3 queimando, mediana do manto com matiz 260 a 300 | nenhuma | `environment-artist` (`crowd.gdshader`, só o ramo da queimadura) | aberto | V-M2; `f1_morvath_despertar.mp4` por volta de 0:07 |
| VX-09 | C12d | P1 | Aro do círculo de luz com alfa até 0,45, metade da espessura, traços finos | lê como marca de interface por cima dos corpos | zona clara sem cobrir os inimigos | esqueleto em pé sobre o aro com os pés legíveis na captura | nenhuma | `environment-artist` (`ground.gdshader` estilo CIRCLE) | aberto | V-M1 |
| VX-10 | C12d | P2 | Lascas alongadas na direção do corte (2:1 a 4:1), marfim a cinza, vida até 0,25 s | pontos brancos redondos 10 ou mais quadros no ar | impacto sem sujeira | nenhuma lasca visível 8 quadros depois do golpe | nenhuma | `environment-artist` (`impact.gdshader`), `gameplay-engineer` (vida das lascas em `fx.gd`) | aberto | V-E3 |
| VX-11 | C12d | P0 | Sem marcador `PALADIN_n` para o jogador: a linha "dom de X" some até o Daniel dar os nomes (sem inventar nome) | bug visível na carta | texto limpo | teste que monta cada carta e não acha "PALADIN" | nenhuma | `ui-ux-designer` | aberto | V-U1 |
| VX-12 | C12d | P2 | Contador de golpes até 48 px a 1080, nome do golpe com alfa 0,7 | compete com a luta | olho na luta | captura a 1080 medida | nenhuma | `ui-ux-designer` | aberto | V-U3 |
| VX-04 | C12e | P0 | Multidão e Morvath sem saltos: mais poses (andar 20 a 24, ataque 14 a 16, golpe sofrido 8, parado 12, morte 16) e mistura entre a pose atual e a seguinte no vértice; medir memória e quadro | 10 poses por ciclo sem mistura, stop motion ao lado do herói | inimigos vivos | vídeo a 30 qps: nenhum inimigo andando repete a pose em 2 quadros seguidos; pacote dos assados medido; quadro sem piora acima de 0,3 ms | nenhuma | `environment-artist` (`tools/bake.gd`), `gameplay-engineer` (`crowd_renderer.gd`, `crowd.gdshader`), `qa-performance` | aberto | V-A1; `crowd_renderer.gd:242` |
| VX-05 | C12e | P1 | Passo do andar medido por clipe no assado e guardado no `BakedModel` | `clip_rate` genérico, pé deslizando | pés no chão | pé de apoio desliza menos de 5 cm por passo no `enemy_lab` | VX-04 | `environment-artist`, `gameplay-engineer` | aberto | V-A2 |
| VX-06 | C12e | P1 | Recuo visível: golpe sofrido com 8 poses e deslocamento de 0,15 a 0,3 m que se vê em 3 quadros | recuo invisível | o golpe se vê no corpo | `--shot-on=hit` + 6 quadros: o alvo se desloca e volta | VX-04; GF-12 se a D-42 aprovar | `gameplay-engineer` | aberto | V-A3 |
| VX-07 | C12e | P1 | Armas do KayKit, paliativo no assado: ferro escuro e osso sem listras, cutelo até 0,6 do tronco, gancho de Morvath em ouro velho (matiz 35 a 45, saturação até 0,5) | outro estilo colado em figuras pintadas | inimigos coerentes | `enemy_lab`: nenhuma arma em faixas de duas cores; gancho medido | nenhuma (o final é D-46) | `environment-artist` (`tools/bake.gd` `held`) | aberto | V-P1 |
| VX-13 | C12e | P2 | Metade dos grupos de velas da borda leste e sul do salão apagados | quente por toda a borda | quente como acento | fração de pixels quentes saturados na vitrine pela metade, chão acima de 45 | nenhuma | `environment-artist` | aberto | V-C1 |
| VX-17 | C12e | P2 | Pose final do finalizador como carga (o corpo recua 5 a 10 cm, o brilho cresce desde o começo) | lê como parada | antecipação clara | `g_combo` antes e depois aprovado pelo `art-director` | VX-02, GF-01 | `gameplay-engineer` | aberto | V-A4 |
| VX-14 | C12f | P1 | Clipes de Morvath mais pesados (UAL CC0: golpe de duas mãos para a foice, lançamento para a tempestade) | ataques são golpes genéricos | o chefe tem presença | vídeo por fase antes e depois aprovado pelo `art-director`; `test_boss*.gd` com os mesmos tempos de aviso | VX-04 | `gameplay-engineer` (`tools/bake.gd` bloco de Morvath, tempos) | aberto | V-A5 |
| VX-15 | depois | P3 | Peças próprias de cenário (velas, balaustradas, sarcófagos), ícones de dom por família, retrato do medalhão a partir do Explorador | KayKit ao lado de pintura; ícones genéricos; retrato de outro estilo | identidade | spec do `art-director` por família | D-46 (Meshy), arte 2D | `art-director`, `environment-artist`, `ui-ux-designer` | proposta | V-C2, V-M3, V-U2 |
| VX-16 | depois | P3 | Gema do cajado do mago até 235 | estoura branco | | `enemy_lab` | nenhuma | `environment-artist` | aberto | V-P2 |

## 1b. Itens priorizados do C12c em diante (formato completo)

Campos: ID, ciclo, prioridade (P0 a P3), descrição, problema, valor para o jogador, aceite, dependências, responsável,
estado, evidência. Planejamento e justificativas em `docs/design/roadmap_plan.md`. Nada do C12c muda número de combate.

### C12c "Qualidade da experiência"

Fechado na seção 0 (estado de cada item com a prova do QA-02). Abertos que ficaram: A-1 (em correção), M-1, B-1 a B-3
(seção 1). As hipóteses A, B, D e F seguem pedindo teste humano; o registro v2 (GP-02) já as mede.

### C13 "Progressão e rejogabilidade" (depois do C12f e do teste T4; números do Hades II pela D-39)

| ID | P | Descrição | Problema | Valor | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|
| C13-01 | P1 | Descida de 10 salas e Morvath na 11 por padrão; a de 7 e a de 5 por opção; arenas sem repetir seguidas, nenhuma mais de 3 vezes | 3 dons em Morvath | partida de 10 a 13 min com curva | robô 0,25 chega com 5 a 8 dons em 6 de 8; `test_descent.gd` | teste final do C12c | `gameplay-engineer` | aberto | DT-001; `runs_antes_ciclo12.jsonl` |
| C13-02 | P1 | Baralho de recompensas do Hades II no lugar dos pesos | variedade sem repetir | portas mais interessantes | teste do baralho (sem reposição, reabastece) | C13-01 | `gameplay-engineer` | aberto | `hades2_sistemas.md` "achado" |
| C13-03 | P1 | Raridade em sequência; guardião sem heroica | `RARITY_WEIGHT_GUARDIAN` diferente do Hades | fidelidade (D-39) | teste com 10 mil sorteios dentro de 1 ponto das chances | | `gameplay-engineer` | aberto | idem |
| C13-04 | P1 | Ouro por inimigo (70%, teto 10 a 15 + 0,5 por profundidade), recompensa 100, loja em 3 grupos, cura 50 | loja inútil (37 de ouro, mínimo 60) | a loja vira escolha | robô compra na loja em 6 de 8 | C13-01 | `gameplay-engineer`, `ui-ux-designer` (loja) | aberto | vídeo 2:02; `_stage` `shop_prices` |
| C13-05 | P1 | Romã com ganho fixo por nível (`base`, `per_level`), 32 dons migrados | | dons que crescem | testes por dom | | `gameplay-engineer` | aberto | `hades2_sistemas.md` seção 1 |
| C13-06 | P2 | Elo com 12% por carta | | | teste de sorteio | C13-02 | `gameplay-engineer` | aberto | seção 3 |
| C13-07 | P2 | Bônus de sequência de golpes fora (D-10) | não existe no Hades II | fidelidade | `DamageCalc.combo_bonus` desligado e testado | D-10 | `gameplay-engineer` | proposta | comparativo, Dons |
| C13-08 | P1 | Métricas do C13: dons e ouro por sala no registro, 8 descidas longas | | | `METRICAS.md` do ciclo | GP-02 | `qa-performance` | aberto | |

### C15 "Som e polimento" e C14 "Arenas II" (ordem pela D-47; os sons de ação do C15-02 sobem para o GF-11 e o C12f)

| ID | Ciclo | P | Descrição | Aceite | Responsável | Estado |
|---|---|---|---|---|---|---|
| C15-01 | C15 | P2 | Mixagem por barramentos, ducking nos avisos de Morvath | pico até -1 dBTP; integrado -18 a -14 LUFS | `gameplay-engineer` | aberto |
| C15-02 | C15 | P2 | Som em toda ação, aviso e ataque de Morvath | teste que acusa evento sem som | `gameplay-engineer`, `art-director` | aberto |
| C15-03 | C15 | P2 | Música de combate e de Morvath por fase (CC0, CC-BY ou síntese, D-12b) | nenhum silêncio de 2 s com música ligada | `art-director`, Daniel (fonte) | aberto |
| C15-04 | C15 | P2 | Ambiência por arena | idem | `environment-artist` | aberto |
| C15-05 | C15 | P2 | `audio/LICENSES.md` e créditos | toda fonte listada | `ui-ux-designer` | aberto |
| C14-A4 a A6 | C14 | P2 | Santuário, Ponte, Runas (D-29), cada uma com uma decisão de combate própria | testes do C12 e decisão medida | `environment-artist`, `gameplay-engineer`, `art-director` | aberto |

---

## 2. Quickwins

Os quickwins de sensação desta revisão são do C12d (cabem em horas cada): GF-02, GF-03, GF-04, GF-06 (P), VX-02, VX-11.
Abaixo, os de processo.

| ID | Título | Evidência | Impacto | Esforço | Responsável | Prioridade | Pronto quando |
|---|---|---|---|---|---|---|---|
| QW-014 | Versão de teste do Daniel: **sai depois do C12d** (T3), não do C12c (recomendação, D-45) | regra de entrega MVP; o C12d muda a mão e invalidaria um teste da mão antiga | um teste só, da mão nova | P | sessão principal | P0, depois do QA do C12d | `ASelagem.exe` do commit do C12d em `Downloads\ASelagem-3D` e `ASelagem-teste`; `runs.jsonl` antigo guardado com outro nome |
| QW-015 | Ler o T3 por roteiro fixo (registro v2) | GP-02 grava `hurt_ctx`, esquivas, golpes por sala | separar "injusto" de "não reagiu" | P | `qa-performance` | P0 depois do T3 | tabela por sala do T3 ao lado da do robô 0,25 |
| QW-012 | Teste humano dos atiradores | `c666f4a` nunca jogado por gente | balanceamento deles | P | Daniel | dentro do T3 | 3 partidas no registro |
| QW-016 | Galeria de game feel antes e depois | `docs/gallery/game_feel/` é o "antes" | comparação externa da diretriz | P | `qa-performance` | P0 no QA do C12d | `docs/gallery/game_feel/after_c12d/` com os mesmos comandos do `VIDEOS.md` e a saída da sonda |

---

## 3. Dívidas

### DT-001 A descida ainda é de teste
- **Evidência**: 7 salas (D-27), Morvath aos 95 a 120 s com 3 a 4 dons pelo robô; Morvath tem 6050 de vida pensados para 6 a
  8 dons. **Responsável**: `gameplay-engineer` no C13. **Pronto quando**: descida inteira (10 salas e Morvath na 11) com
  as arenas distribuídas; `--short` e a de 7 continuam por opção.

### DT-002 O robô não mede dificuldade
- Melhorou: agora anda pelo campo de fluxo e não fica preso (F7). Continua vencendo com reação 0 e sem usar cobertura de
  propósito; métrica de robô é simulação, não diversão. **Responsável**: `qa-performance`. Fica até o T2 dar números de gente.

### DT-003 Desempenho em máquina fraca nunca medido
- O Compatibility foi medido **na RTX 5060** (3,2 a 5,4 ms); placa fraca e iGPU, nunca. Para a Steam é obrigatório antes do
  C16. **Responsável**: `qa-performance`. **Pronto quando**: salão, Fendas e Jardim medidos a 1280 x 720 numa iGPU (a placa
  integrada do próprio notebook do Daniel, se ele permitir forçar) ou registrado por que não dá.

### DT-004 Vídeo da luta com som (feito)
- Feito no QA-02 (`71cb8cc`): `docs/gallery/cycle12c/after/descida_com_som.mp4` (7 salas e Morvath, 1080, com som) e os
  vídeos de game feel `f1` a `f4`. `tools/movie.sh` grava a 1080.

### DT-010 A sonda de game feel não é teste
- **Evidência**: `tools/feel_probe.gd` mede, mas nada falha quando um aperto volta a sumir. **Responsável**:
  `qa-performance` (GF-14) e depois `gameplay-engineer` (um teste GUT por regra de entrada, ver GF-02 a GF-04). **Pronto
  quando**: as regras de entrada do C12d têm teste GUT que quebra se voltarem.

### DT-011 Vídeos de game feel com roteiro fixo e vida alta
- **Evidência**: `VIDEOS.md`, limitações: roteiro com mira automática, herói com 200 ou 999 de vida, fase 4 curta. Não
  mostram pressão real. **Responsável**: `qa-performance`. **Pronto quando**: o QA do C12d regrava (a) a (g) com os
  mesmos comandos (antes e depois comparáveis) e acrescenta a fase 4 inteira com `--bot-kite`.

### DT-005 "Resources still in use at exit"
- Igual. **Pronto quando**: `tools/test.sh` e `tools/smoke.sh` sem a linha.

### DT-006 Vídeo dirigido do bloqueio de corpo
- O roteiro à mão do QA (`METRICAS.md` seção 4) cobriu a mecânica em números; falta o vídeo. Baixa prioridade.

### DT-009 Medidas de câmera da F6 nunca em número (feito: GP-06, 0,400 m)
- **Evidência**: QA, limitações: o salto do alvo entre quadros (meta abaixo de 0,5 m a 60 FPS) só foi visto nos vídeos.
- **Responsável**: `qa-performance`. **Esforço**: P. **Pronto quando**: `--trace-cam` ou sonda que imprime o maior salto
  do alvo numa travessia de cada arena.

---

## 4. Arenas: pendências que ficaram e o que vem

### Correções da revisão de arte que ficaram (depois de F-1 a F-5)

| # | Arena | Pendência | Prioridade depois da D-36 | Responsável |
|---|---|---|---|---|
| F-6 | Fendas | Inscrições de ouro entre a fenda e o buraco não aparecem | P3 (fidelidade) | `environment-artist` |
| G-1b | Fendas | Compatibility (ver quickwins) | P2 | `environment-artist` |
| G-2 | Fendas, Jardim | Marcos da vitrine não medidos contra a spec 6.1 | P3 (fidelidade) | `qa-performance` |
| G-3 | todas | Peças procedurais provisórias (sarcófagos, estátuas, árvore) | P3, ART-010 com Meshy se o Daniel autorizar | Daniel |
| J-5 | Jardim | Opinião minha, na `fix_garden_arvore_antes_depois`: as duas fraturas claras dos galhos quebrados saem quase brancas, o ponto mais claro da árvore; conferir que ficam abaixo do glow e no valor do marfim, não do branco | P3 | `environment-artist` |
| Densidade | Cripta, Jardim | A `05` e a `04` são muito mais cheias; aqui o chão da luta é quase vazio | P3 (fidelidade, depois do T2) | `art-director` |

### Arenas das entregas seguintes (sem mudança)

| ID | Arena | Entrega | Decisão |
|---|---|---|---|
| C14-A4 | Santuário Desmoronado (grande, casa do guardião) | 2 | |
| C14-A5 | Ponte dos Condenados (comprida, plataformas e ponte) | 2 | |
| C14-A6 | Câmara das Runas Instáveis (faixas e ladrilhos, nunca círculo) | 2 | D-29 |
| C16-A7 | Biblioteca Sepultada (estantes destrutíveis) | 3 | D-32 depois do T2 |
| C16-A8 | Reservatório das Almas (água rasa) | 3 | D-31 depois do T2 |

---

## 5. T3: teste do Daniel depois do C12d

**Quando**: depois do commit do C12d e do QW-014. **Quanto**: 3 partidas do título ao fim, teclado e mouse ou controle.
Substitui o "teste final do C12c" (o roteiro de 7 perguntas do `roadmap_plan.md` E continua valendo e entra junto).

### Perguntas de game feel (uma linha cada)
1. Alguma vez apertou a esquiva ou o ataque e nada saiu? Onde (no meio do combo, logo depois da esquiva, ao levar golpe)?
2. O golpe pesa? Gruda ou fica fraco? O finalizador (o giro) está no tempo certo?
3. A seta de luz e o Ômega: dá vontade de usar? Algum ficou rígido?
4. No meio de um grupo, os avisos vermelhos deixaram escolher a saída?
5. Os inimigos parecem sentir o golpe? (antes da D-42, a resposta esperada é "não": serve de linha de base)
6. Morvath: alguma coisa da foice ou da tempestade pareceu sem aviso?
7. Qualquer coisa que tenha coberto o herói.

### O que mandar
O `%APPDATA%\EterraASelagem\runs.jsonl` inteiro e as respostas. Se puder, o tempo do vídeo ou um print do que escondeu o
herói.

---

## 6. Próximos ciclos

**Ordem nova (sexta revisão; `roadmap_plan.md` seção 0)**: fechar o C12c (A-1) → **C12d "Game feel I: a mão"** → T3 (teste
do Daniel) → **C12e "Excelência visual I: movimento e coerência"** → **C12f "Game feel II: inimigos, Morvath e som do
combate"** → T4 → C13 "Progressão" → C15 "Som e música" → C14 "Arenas II" → C16 "Steam".
Por quê: a diretriz manda combate primeiro quando ele está rígido e acabamento visual primeiro quando modelos e animações
estão abaixo da direção, e proíbe aumentar conteúdo para esconder falta de qualidade. A revisão achou as duas coisas. O
C13 (descida de 10 salas, economia) é sistema, não só conteúdo, mas alonga a partida sobre uma mão que ainda perde
aperto: vem depois. Os sons de ação, carga e aviso (C15-02) sobem para o GF-11 e o C12f; música, ambiência e mixagem
continuam no C15. A D-40 perde o objeto (o C15 foi partido); a ordem nova é a D-47.

### C12d "Game feel I: a mão do jogador" (próximo; 1 a 2 dias)
- **Objetivo**: nenhum aperto perdido, golpe que morde sem grudar e impacto que se lê, com os números do Hades II.
- **Por que agora**: é o centro da diretriz e do jogo; um teste do Daniel antes disso mediria a mão errada.
- **Pré-requisito**: o A-1 integrado e com captura (mexe em `fx.gd`, `game.gd`, `rooms.gd`); o C12d parte desse commit.
- **Entregas e donos (arquivos distintos; o `environment-artist` em worktree)**:

| Ordem | Agente | Itens | Arquivos donos | Não mexe em |
|---|---|---|---|---|
| 1 (primeiro, horas) | `qa-performance` | GF-14 (metas na sonda e rodada "antes" guardada) | `tools/feel_probe.gd`, `tools/feel_probe_run.gd`, `docs/gallery/game_feel/` | código do jogo |
| 2 | `gameplay-engineer` | na ordem: GF-02, GF-03, GF-04, GF-06 (entrada); GF-01, GF-05 (hit stop); GF-07, GF-08, GF-09; GF-10; GF-11 (sons e vibração); encaixe do VX-01, VX-02 e VX-10 em `fx.gd` com os valores que o `environment-artist` entregar | `scripts/game/player.gd`, `scripts/core/combo_runner.gd`, `combo_tree.gd`, `combo_node.gd`, `feel.gd`, `scripts/controls.gd`, `scripts/game/fx.gd`, `combat.gd`, `game.gd` (relógio e `apply_options`, não `_build_world`), `horde.gd` (só `FLASH_TIME`), `scripts/audio.gd`, `tools/make_data.gd` (`_combos`, `_feel`) e `data/` regerado, `tests/test_feel_c12d.gd` (novo), `tests/test_combo.gd` | shaders, `scripts/ui/`, `text_pt.tres`, ferramentas do QA |
| 2 (paralelo) | `environment-artist` | VX-01, VX-02, VX-03, VX-08, VX-09, VX-10 (shaders e desenho dos avisos) | `assets/shaders/slash.gdshader`, `slash_ink.gdshader`, `glint.gdshader`, `impact.gdshader`, `ground.gdshader`, `crowd.gdshader` (só o ramo da queimadura), `scripts/game/ground_look.gd` | `fx.gd`, `combat.gd` (passa os valores ao `gameplay-engineer`) |
| 2 (paralelo) | `ui-ux-designer` | VX-11 (só texto), VX-12, opção de vibração do GF-11 | `data/text_pt.tres`, `scripts/ui/hud.gd` (contador), `scripts/ui/options_screen.gd`, `scripts/core/save_data.gd` (chave `rumble`), `tests/test_comfort_ui.gd` | regras de combate |
| 3 | `art-director` | valores do GF-10 nos finalizadores; aprovação de VX-01 a VX-03, VX-08 a VX-10 nas capturas; adendo na `visual_review.md` | `docs/design/visual_review.md`, `docs/arte/estetica.md` | código |
| 4 | `qa-performance` | GF-13 (latência na placa), QW-016 (vídeos (a) a (g) regravados com os mesmos comandos, mais a fase 4 inteira com `--bot-kite`), relatório | `docs/qa/latest_report.md`, `docs/gallery/game_feel/after_c12d/` | código |

- **Aceite (medível)**:
  1. Sonda: `FEEL_SUMMARY` com todas as metas ok: `_s_dodge_cancel`, `_s_attack_in_dodge`, `_s_extra` e `_s_hurt` sem
     nenhum `LOST`; `_s_buffer` com o 2º aperto valendo em todo quadro do golpe 1 e do giro; `_s_hitstop_buffer` com o
     `pad` igual ao `keyboard`; `_s_attack_hit`, `_s_combo_on_hit` e `_s_kill` sem quadro `stepped=false` por hit stop e
     com 1 a 3 quadros a `time_scale` até 0,06 depois da espera do golpe; `_s_kill` de 3 abates com no máximo 3 quadros
     parados e depois `time_scale` 0,2 andando; `_s_special` golpe no 25 e especial no 48; `_s_omegas` lança no 48;
     `_s_turn` direção a 180 no quadro 1; `_s_attack_hit` com `kick` até 0,1 m e clarão até 0,05 s nos golpes comuns.
  2. Testes GUT novos para cada regra de entrada e para a agenda do hit stop; `tools/test.sh` inteiro, `check.gd`,
     `title_flow_check.gd`.
  3. Diff do `make_data.gd` só em `_combos` (campos de hit stop, travas e velocidade da seta, Ômega) e `_feel` (tranco,
     tremor); nenhum dano, vida, alcance, aviso inimigo ou número de Morvath mudado.
  4. Robô: `tools/smoke.sh 300 --seed=5` vence; 8 descidas com reação 0,25 com `stuck` 0 e entre 3 e 8 vitórias (antes 5;
     simulação, só para pegar regressão grande).
  5. Visual: aceites de VX-01, VX-02, VX-03, VX-08, VX-09, VX-10 medidos nas capturas da GPU e aprovados pelo
     `art-director`; nenhuma chave `PALADIN_` visível (VX-11).
  6. Vídeos antes (`docs/gallery/game_feel/`) e depois (`after_c12d/`) com os mesmos comandos; quadro a 1080 sem piora
     acima de 0,3 ms por arena; latência de ponta a ponta reportada (GF-13).
- **Evidências**: saída da sonda antes e depois, capturas `--shot-on=hit|swing|omega` e `--frames` na Cripta com
  `--cam-dist=26`, vídeos (a) a (g), relatório do QA.
- **Riscos**: hit stop por `Engine.time_scale` se cruzar com a câmera lenta, os menus e a vitória (testar os três);
  esquiva que corta a preparação deixa o jogo mais fácil (medir no robô e no T3); o Daniel achar o golpe fraco sem o tranco
  grande (D-43 guarda o tranco maior nos finalizadores).
- **Sem o Daniel**: tudo acima. **Com o Daniel**: a parada das pernas da seta (D-44; até ele responder, fica como está), a
  proteção do círculo (D-44), o atordoamento dos comuns (D-42, vai para o C12f).

### T3 (seção 5), depois do C12d

### C12e "Excelência visual I: movimento e coerência" (2 a 3 dias)
- **Objetivo**: inimigos e Morvath que se movem tão bem quanto o herói e armas no estilo dos modelos.
- **Por que agora**: o maior déficit visual depois da mão (V-A1 alta: stop motion ao lado do herói); sem créditos.
- **Entregas**: VX-04, VX-05, VX-06 (sem o atordoamento se a D-42 não vier), VX-07, VX-13, VX-17, GF-15, M-1, B-1 (gemas).
- **Aceite**: os de cada item; pacote dos assados medido (hoje cerca de 44 MB) e com teto escrito; quadro sem piora acima
  de 0,3 ms; vídeos (b), (c), (e), (f1) antes e depois aprovados pelo `art-director`.
- **Responsáveis**: `environment-artist` (`tools/bake.gd`), `gameplay-engineer` (`crowd_renderer.gd`, `crowd.gdshader`,
  `bake_hero.gd`), `qa-performance`, `art-director`. **Riscos**: memória e tempo de assado; mistura de pose no vértice no
  Compatibility.

### C12f "Game feel II: inimigos, Morvath e som do combate" (2 dias)
- **Objetivo**: o golpe mudar o comportamento dos inimigos e o combate se ouvir.
- **Entregas**: GF-12 (se a D-42 aprovar), VX-06 completo, VX-14 (clipes de Morvath), C15-02 subido (som por ação, aviso e
  inimigo, impacto por material), B-2 (robô usa a fonte), correção do que o GF-13 e o T3 apontarem.
- **Aceite**: teste GUT do atordoamento por inimigo; 8 descidas antes e depois; teste que acusa evento de combate sem som;
  vídeos por fase de Morvath aprovados. **Riscos**: dificuldade cai com o atordoamento; medir antes de mexer em vida.

### T4, depois do C12f: o Daniel diz se o combate está aprovado para a Fase 1 (critério 1 da definição, `roadmap_plan.md` 0).

### C13, C15, C14, C16
- Como na seção 1b e no `roadmap_plan.md` (B e D). O C13 só começa depois do T4.

### Itens de arte que seguem abertos

| ID | Título | Esforço | Responsável | Quando |
|---|---|---|---|---|
| ART-002 | Música (o som de combate subiu para o C12f) | G | `art-director`, Daniel (fonte) | C15 |
| ART-010 | Peças definitivas (estátuas, sarcófagos, porta, foice de Morvath, árvore) | M | `art-director`, `environment-artist`; Daniel autoriza créditos | depois do C12f (D-46) |
| ART-011 | Gancho amarelo de Morvath e ouro das elites por repintura | P | Daniel | paliativo no VX-07; repintura com D-46 |
| QW-009, QW-010 | Coroa da fachada; medir a `02` contra a planta | P | `art-director` | quando sobrar |

---

## 7. Decisões do Daniel

### Novas, tomadas por ele hoje (2026-11-16)

| ID | Decisão | Onde |
|---|---|---|
| D-34 | Estandartes com o leão no salão e nas arenas; a Câmara do Selo segue com a espada | `501f3d8`, `e2297ee` |
| D-35 | Estátuas encapuzadas de mãos vazias; nenhuma porta verde (nem braseiros pedidos na imagem) nas arenas | `501f3d8` |
| D-36 | "Não precisa de fidelidade nesta entrega, o importante é ter as arenas salas diferentes, depois eu testo": fidelidade às imagens conceituais fica para depois, talvez com Meshy que ele autorize | registrado no `CLAUDE.md` (`95c29c6`) |

### Decidida pelo Daniel nesta tarde

| ID | Decisão | Onde |
|---|---|---|
| D-39 | "Vale copiar do Hades, nomes nossos": mecânicas e números do Hades II fielmente; nomes, personagens, UI e arte de Eterra. Resolve o conflito com a frase "não copiar mecanicamente" do pedido de hoje | `roadmap_plan.md`; C13 planejado com isso |

### Abertas da Game Feel Review (novas)

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-42 | Os inimigos comuns sem armadura atordoam ao levar golpe, como no Hades II (param de andar, a preparação é interrompida; elites imunes até a armadura quebrar; alguns imunes só durante o próprio ataque)? Muda muito a dificuldade | (a) copiar o Hades por inimigo; (b) só parar de andar no recuo, sem interromper o ataque; (c) como está | **(a)**, pela D-39 e porque hoje acertar não muda nada; entra no C12f, medido no robô e no T4 antes de mexer em vida **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-43 | O que fica nosso no impacto (apresentação, não dificuldade): câmera lenta rara por vários abates (o Hades só tem no último abate e no chefe), tranco de câmera maior só nos finalizadores e no Ômega, clarão morno em vez do vermelho do Hades | (a) manter os três, corrigidos (GF-05, GF-10); (b) tirar e ficar só com o Hades | **(a)**: é a sensação do Ember & Blade, rara e corrigida; o `art-director` fixa os valores pelo vídeo **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-44 | Três diferenças que mexem na dificuldade: (1) esquiva sai no quadro 0 (o Hades espera 3 quadros protegido); (2) o círculo dá 0,2 s de proteção e deixa atacar na hora (o Hades não protege e trava 8 quadros); (3) depois da seta o herói anda na hora (o Hades segura as pernas 0,71 s, só a esquiva corta) | para cada uma: copiar o Hades ou manter | **(1) manter** (só ganha resposta); **(2) copiar** (é erro de cópia que facilita); **(3) copiar**, porque o especial é o golpe de maior dano por aperto, mas contraria o "mais dinâmico" do 1º teste: até a resposta, fica como está **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-45 | Quando o Daniel testa | (a) a versão do C12c agora; (b) depois do C12d (1 a 2 dias), um teste só | **(b)**: o C12d muda a mão (esquiva, buffer, hit stop); um teste antes mediria a mão que vamos trocar **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-46 | Créditos do Meshy (546) para armas próprias dos inimigos e de Morvath (hoje do KayKit) | (a) nada agora, paliativo no assado (VX-07); (b) autorizar um lote depois do C12e, com orçamento do `art-director` por peça antes de gastar | **(b)** depois do paliativo: as armas são o que mais destoa nos modelos, e o custo por peça precisa ser orçado (não sei o preço de geração; a repintura é 10 créditos) **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-47 | Nova ordem dos ciclos (seção 6): C12d, T3, C12e, C12f, T4, C13, C15, C14, C16 | (a) a nova; (b) a anterior (C13 logo depois do teste) | **(a)**: é a regra da sua diretriz; o C13 alonga a partida sobre uma mão que ainda perde aperto **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |

### Abertas de antes

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-41 | Nomes de Eterra para romã, raridades e loja no C13 | os nomes provisórios do `hades2_sistemas.md` ou os seus | mandar só os que quiser trocar |
| D-12b | Licença do som e da música (C12f e C15) | (a) só CC0 e síntese; (b) CC0 e CC-BY com créditos | **(b)** **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-37 | A referência `04` (feita por IA) em tamanho cheio está no histórico do git e no GitHub (`91cc656`) | (a) deixar; (b) reescrever o histórico (só com ordem expressa); (c) deixar e só proibir de novo | **(a) com (c)** se o repositório for privado; **(b)** numa única vez se for ficar público |
| D-31, D-32 | Água que desacelera; destrutíveis que abrem passagem | decidir depois do T4 | como antes |

Fechadas sem objeto: **D-38** (o ART-R1 aprovou as Fendas, `4d281bc`); **D-40** (o C15 foi partido: sons do combate no
C12f, música no C15; a ordem é a D-47).

### Tomadas pela sessão na noite de 2026-11-16 (a confirmar; o Daniel ainda não respondeu)

| ID | Decisão tomada | Onde está | Recomendação |
|---|---|---|---|
| D-08 | Quadro P&B só em Ômega acertado e quebra de fase, 1 a cada 10 s, com opção | `dcf6632`, `196f33c` | Confirmar |
| D-14 | Na luta, a porta selada no lugar do portal vermelho | `482eb6f` | Confirmar |
| D-16 | Selo com o leão de pé (patas de trás) | `482eb6f` | Confirmar |
| D-17 | Espada erguida no lugar da cruz | `482eb6f`, `00dd13b` | Confirmar |
| D-18 | Raio de 12,5 m | `boss_arena.md` | Confirmar |
| D-20 | Morvath vai ao centro nas fases 3 e 4 | `6b16045` | Confirmar |
| D-21, D-22 | "A Câmara do Selo"; tela de fim sem nível | `6801e87` | Confirmar |
| C12a | O miolo do selo escurece com as faixas da tempestade | `b7f5f4d` | Confirmar no T3 |

D-15 (salas comuns no salão) e D-06 (descida curta) foram superadas pelas arenas e pela D-27.

### Decididas pelo Daniel antes (arenas)
D-25 (3 arenas), D-26 (salão como arena), D-27 (7 salas), D-28 (para na borda), D-29 (runas em faixas), D-30 (árvore
petrificada), D-33 (nome por 2 s): todas seguiram a recomendação e estão entregues, menos D-29 (C14).

### Abertas de antes

| ID | Pergunta | Recomendação |
|---|---|---|
| D-23 | O que é a porta selada e o véu de runas | Pendente na história; sem texto até o cânone ter |
| D-11 | Meta de dificuldade da primeira vitória | Até 3 tentativas para quem jogou Hades, com a descida inteira |
| D-09 | Magia na luta do chefe | Decidir no C13 com o registro |
| D-10 | Bônus de sequência (não existe no Hades II) | Tirar no C13 (C13-07), coerente com a D-39 **Decidido pelo Daniel em 2026-11-16: segue a recomendação.** |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" ou "o Lich-Rei do Sul" (cânone) |
| D-02, D-04 | Quem sela Morvath; nomes dos paladinos (os marcadores `PALADIN_n` apareciam na carta de dom; o VX-11 esconde a linha até os nomes existirem) | Seguir o cânone de 12/11; nomes depois |
| D-05 | Créditos do Meshy (546) | Nada até você pedir; fidelidade das arenas é candidata (D-36) |
| D-07, D-12, D-13 | Entre partidas; origem do som; executável para testadores | Como antes |
| D-03 | Imagens da Hécate | Desistir |
