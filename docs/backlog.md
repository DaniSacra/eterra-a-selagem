# Backlog de A Selagem

- **Data**: 2026-11-16 (fim da tarde). **Autor**: game-director (quinta revisão, a revisão executiva pedida pelo Daniel).
  **Commit lido**: `87ba686` (HEAD de `arpg-3d`); desde a revisão anterior (`95c29c6`): `7e7495e` (backlog), `87ba686`
  (correções F-1 a F-6 e G-1 nas Fendas).
- **Planejamento completo** (diagnóstico, hipóteses A a F, roadmap, aceite, testes, evidências, decisões, próxima
  execução): `docs/design/roadmap_plan.md`. Pedido do Daniel: `docs/design/roadmap_brief_2026-11-16.md`.
- **Fontes lidas**: as da revisão anterior, mais `work/fix_rift_vA_antes_depois_cenario.jpg` (olhado), o registro humano
  (`runs_antes_ciclo12.jsonl`, 3 partidas; `runs.jsonl`, 1 partida sem mouse, pouco representativa pelo Daniel) e o vídeo
  `C:\Users\danie\Videos\ASelagem\partida_ASelagem.mp4` (robô 0,25, derrota na fase 4 aos 3:50; quadros e som medidos
  com `ffmpeg`).
- **Rodado por mim**: `tools/test.sh` no `87ba686`: **462 de 462** (104113 asserções). Nada do jogo foi mudado.
- **Decidido hoje pelo Daniel (D-39)**: "vale copiar do Hades, nomes nossos": mecânicas e números do Hades II, fielmente;
  nomes, personagens, UI e arte de Eterra. O C13 segue isso.

## Estado do jogo em 5 linhas

1. A Fase 1 joga do título à selagem em 7 salas (D-27): salão, três lutas sorteadas entre Cripta, Fendas e Jardim (duas
   variantes cada), fonte, guardião, loja e Morvath em 4 fases na Câmara do Selo. 462 de 462 testes.
2. As Fendas foram corrigidas (`87ba686`): agora leem como rasgo com pontes (olhado no antes e depois); falta a
   reconferência do `art-director` (ART-R1). Cripta e Jardim aprovados.
3. O dado mais forte que temos: **chega-se a Morvath com 3 dons** (3 de 3 partidas de gente e o vídeo do robô) e a loja
   não vende nada (37 de ouro, item mais barato 60). Morvath foi feito para 5 a 8 dons: isso é o C13.
4. No vídeo: coluna de recompensa amarela com miolo branco sobre o herói, coluna ciano que esconde Morvath na entrada,
   gemas das portas acima do glow; 20% de silêncio e pico de 0,04 dBFS sem limitador. Isso é o C12c.
5. Nenhum teste humano do C12 ainda; o registro atual não separa "injusto" de "não reagiu". O C12c acrescenta isso e
   termina numa versão para o teste final do Daniel.

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (neste ciclo), P2
(próximo), P3 (depois). **Estado**: aberto, em andamento, proposta (espera o Daniel), aprovado, feito. Responsáveis:
`gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito (fechado com evidência)

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

Nenhum crítico nem alto aberto. As três altas de arte das Fendas (F-1 a F-3) foram corrigidas no `87ba686` (seção 0) e
esperam só a reconferência do `art-director` (ART-R1). Os clarões vistos no vídeo do robô entraram como GP-01 (seção 1b),
com prioridade P0 porque ferem a regra de leitura da direção.

### Médio

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| F-4 | Chão das Fendas escuro longe das lanternas (25 a 29 na luta) | F-4 | P | `environment-artist` | feito no `87ba686`, a reconferir (ART-R1) | recortes da F-4 com 40 ou mais |
| F-5 | Paredão de cantaria azul iluminada sob as bordas de fora | F-5 | P | `environment-artist` | feito no `87ba686`, a reconferir (ART-R1) | recorte do paredão até 60% do chão |
| QA M-1 | Referência `04` (IA) em tamanho cheio no histórico (`91cc656:docs/gallery/cycle12_maps/work/garden_vs_04.png`), já enviada ao `origin` | QA M-1; `git remote -v` aponta para o GitHub | P | Daniel (D-37) | aberto | decisão D-37 tomada; regra para os agentes: miniatura de 480 px rotulada, nunca a referência inteira em `docs/gallery` |

### Baixo

| ID | Título | Evidência | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|
| B-1 | Pico do passo acima de 2 ms (mediana 2,3 a 2,95; 5 passos de 4,2 a 11,4 em 48 lutas; o salão sem campo de fluxo também passa) | QA B-1, `METRICAS.md` seção 3 | P | `gameplay-engineer` | meta reescrita como percentil (p99 do passo abaixo de 2 ms) e medida; ou um pico explicado no Windows nativo |
| B-2 | `--hero-at` no centro exato de um obstáculo deixa o herói dentro (só a opção de desenvolvimento) | QA B-2, `crypt/vA_g_hero_at_dentro_do_tumulo.jpg` | P | `gameplay-engineer` | `Arena.resolve` empurra para a face mais perto quando o ponto é o centro; teste GUT; e conferir que invocação do Ancião e reforços de Morvath nunca caem dentro de peça |
| B-3 | Teste "cercado" do GUT só olha o chão | QA B-3, `test_no_dead_end_traps_a_cornered_paladin` | P | `gameplay-engineer` | teste com 2 inimigos de cada lado e uma esquiva que sai em pelo menos 12 de 16 direções, nos 4 corredores mais estreitos |
| B-4 | Jardim no Compatibility com p90 de 6,03 ms a 1080p | QA B-4 | P | `qa-performance` (medir de novo depois do `95c29c6`, que diz 5,2 ms), `environment-artist` | p90 até 6 ms no Compatibility na RTX 5060, ou registrado como aceito (o navegador é secundário) |
| BUG-013 | O comando da investida na spec da câmara não dá investida | QA anterior B-1 | P | `art-director` | `boss_chamber_spec.md` seção 9 com `--bot --bot-kite=1` |

---

## 1b. Itens priorizados do C12c em diante (formato completo)

Campos: ID, ciclo, prioridade (P0 a P3), descrição, problema, valor para o jogador, aceite, dependências, responsável,
estado, evidência. Planejamento e justificativas em `docs/design/roadmap_plan.md`. Nada do C12c muda número de combate.

### C12c "Qualidade da experiência" (hoje; termina na versão do teste final do Daniel)

| ID | P | Descrição | Problema | Valor para o jogador | Aceite | Dependências | Responsável | Estado | Evidência |
|---|---|---|---|---|---|---|---|---|---|
| GP-01 | P0 | Colunas de luz e gemas das portas abaixo do glow; entrada de Morvath sem coluna sobre ele | coluna amarela com miolo branco sobre o herói ao vencer a sala; coluna ciano que deixa Morvath em silhueta preta por 1 s; gemas amarelas acima do glow | herói e chefe sempre legíveis; paleta de Eterra | teste GUT: todo `Fx.beam` do jogo com `cap` até 1,0; capturas do QA-02: maior canal da coluna até 235, mediana do recorte de Morvath aos 0,5 s acima de 30 | nenhuma | `gameplay-engineer` | aberto | vídeo 1:20, 1:58, 2:08; `Fx.beam` com `BEAM_INTENSITY` 2,5 sem teto em `rooms.gd:297`, `boss.gd:218`, `game.gd:702`; `rooms.gd:418` (albedo x 2,2); comentário em `boss.gd:979` |
| GP-02 | P0 | Registro que separa injusto de não reagiu: por sala `variant`, `dodges`, `hits`, `hits_by`, `shots` por tipo `{fired, hit, blocked}`, `blocked_by`, `gold_in`, `boons_in`; por partida `source`, `boons_at_boss`, `shop {gold, bought}`, `fountain_used`; por golpe levado `hurt_ctx` (fonte, `warn_s`, `dash_ready`, `offscreen`, até 60) | `RoomTally` só tem dano por fonte, tempo e contato; o teste humano não decide se feiticeiro, Ancião e foice são injustos | as próximas mudanças de número saem de dado de gente, não do robô | `tests/test_cycle12c.gd` cobre cada campo; `tools/smoke.sh 120 --seed=5 --runlog=<arq>` grava a linha com todos e `source: bot`; campos antigos iguais | nenhuma | `gameplay-engineer` | aberto | `core/room_tally.gd`; `boss.hurt_by` do Daniel: foice 36 de 62 (vitória), 12 de 24 (derrota) contra o robô que morre na tempestade |
| GP-03 | P1 | B-2: `Arena.resolve` com o ponto no centro de uma peça empurra para a face mais perto; invocações nunca dentro de peça | `--hero-at` no centro do túmulo deixa o herói dentro | ninguém nasce dentro de pedra | teste GUT por peça de cada arena; 200 invocações do Ancião e 200 reforços de Morvath sorteados, 0 dentro de peça | nenhuma | `gameplay-engineer` | aberto | QA B-2, `crypt/vA_g_hero_at_dentro_do_tumulo.jpg` |
| GP-04 | P1 | B-3: teste "cercado" com inimigos | o teste atual só olha o chão | garante saída em corredor estreito | teste GUT: 2 esqueletos de cada lado nos 4 corredores mais estreitos de cada arena e variante, pelo menos 12 de 16 esquivas saem mais de 2,5 m | nenhuma | `gameplay-engineer` | aberto | QA B-3 |
| GP-05 | P1 | `AudioEffectHardLimiter` no `Master`, teto -1,0 dB | pico de 0,04 dBFS (corte) no vídeo; `audio.gd` sem limitador | sem estalo em lutas cheias | teste GUT do efeito no barramento; pico até -1,0 dBFS no vídeo do QA-02 | nenhuma | `gameplay-engineer` | aberto | `astats` no vídeo (pico aos 12 s); `scripts/audio.gd:84` |
| GP-06 | P1 | DT-009: `--trace-cam` imprime o maior salto do alvo da câmera e onde | salto nunca medido | câmera estável nas salas grandes | opção existe e está no `CLAUDE.md`; QA-02 mede abaixo de 0,5 m por quadro a 60 FPS nas 4 arenas | nenhuma | `gameplay-engineer` | aberto | QA, limitações |
| ENV-01 | P0 | Cripta: chão da luta no alvo sem acender a periferia | chão longe das velas com 40 (alvo 45 a 60); terço do quadro preto no vídeo | inimigos e avisos legíveis em toda a sala (hipótese C) | `crypt/vA_c_combate` e `vB_c_combate` refeitas: recortes de chão longe das velas com mediana 45 a 60; tampa sob o facho até 150; quadro sem piora de mais de 0,3 ms | nenhuma | `environment-artist` | aberto | `ART_REVIEW.md` Medidas; vídeo 1:01 a 1:23 |
| ENV-02 | P2 | J-5: fraturas dos galhos no valor do marfim | as fraturas saem quase brancas (opinião minha) | nada compete com o herói | maior canal das fraturas até 200 no `garden/vA_a_cenario` | nenhuma | `environment-artist` | aberto | `work/fix_garden_arvore_antes_depois` |
| ENV-03 | P2 | B-4: Jardim no Compatibility | p90 de 6,03 ms | navegador e máquina fraca | p90 até 6,0 ms medido pelo QA, ou registrado como aceito | QA-02 mede | `environment-artist` | aberto | QA B-4 |
| UI-01 | P1 | Placas das portas legíveis (`DoorSign`, classe nova em `scripts/ui/door_sign.gd`) | rótulos "Ouro", "Fonte de luz", "Loja" pequenos e brancos sobre a gema | escolher a porta sem procurar | teste GUT da classe; na captura a 1080 do QA-02 maiúsculas de pelo menos 16 px e contraste de pelo menos 4,5:1 | o `gameplay-engineer` troca a chamada em `rooms.gd` `_marker` | `ui-ux-designer` | aberto | vídeo 1:23, 2:02 |
| UI-02 | P1 | Tela de derrota com "Sala N de M", a arena e os dons levados | a derrota mostra tempo, abates, sequência e número de dons, não onde nem com quê | o Daniel e quem testar contam a partida pela tela | teste GUT da `EndScreen` com derrota na sala 3 da Cripta e 2 dons; captura `--shot-on=end` | nenhuma | `ui-ux-designer` | aberto | vídeo 3:50 |
| QA-01 | P0 | Linha de base antes das mudanças: capturas `antes/`, vídeo de descida com som, pico e silêncios | sem antes não há prova do depois | | arquivos em `docs/gallery/cycle12c/antes/` com comando no `CAPTURAS.md` | nenhuma (roda primeiro) | `qa-performance` | aberto | plano, seção F |
| QA-02 | P0 | Medidas do aceite do C12c, relatório, galeria `cycle12c`, DT-004 (descida inteira com som a 1080p) | | | todos os itens da seção D do `roadmap_plan.md` com número | integração dos outros itens | `qa-performance` | aberto | plano, seções D a F |
| ART-R1 | P1 | Reconferir F-1 a F-6 com as medidas da `ART_REVIEW.md` | correções sem reconferência | | adendo na `ART_REVIEW.md` com cada aceite medido; se passar, D-38 fecha | nenhuma | `art-director` | aberto | `87ba686` |

Hipóteses que pedem teste humano (não viram mudança de número no C12c; o GP-02 as mede): A (catacumbas interligadas),
B (árvore e raízes no combate), D (justiça da foice e da fase 4), F (qualidade do som). Roteiro de 7 perguntas no
`roadmap_plan.md`, seção E.

### C13 "Progressão e rejogabilidade" (depois do teste final; números do Hades II pela D-39)

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

### C15 "Som e polimento" e C14 "Arenas II" (ordem pela D-40)

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

| ID | Título | Evidência | Impacto | Esforço | Responsável | Prioridade | Pronto quando |
|---|---|---|---|---|---|---|---|
| QW-014 | Montar a versão do teste final (era "T2"; agora sai depois do C12c, `roadmap_plan.md` H) | regra de entrega MVP; memória "Test build folders" | o Daniel testa tudo de uma vez | P | sessão principal | P0, depois do QA-02 | `ASelagem.exe` exportado do commit das Fendas, copiado para `Downloads\ASelagem-3D` e `ASelagem-teste`; `runs.jsonl` antigo do Daniel guardado com outro nome para não misturar com o T2 |
| QW-015 | Ler o teste final por um roteiro fixo (com os campos do GP-02) | QW-011 e GP-02 gravam o que precisamos | separar "salas difíceis" de "Morvath difícil" e "atirador injusto" de "atirador fácil" | P | `qa-performance` | P0 depois do T2 | tabela por sala do T2 (arena, `hp_in`, dano por fonte, tempo, `contact`) ao lado da mesma tabela do robô 0,25 (`METRICAS.md` seção 1) |
| QW-012 | Teste humano dos atiradores novos | `c666f4a` nunca jogado | decide o balanceamento deles | P | Daniel | P0 (dentro do T2) | 3 partidas no registro e as respostas do roteiro do T2 |
| G-1b | Compatibility das Fendas (vermelho some, azul satura): **feito no `87ba686`**, a reconferir no ART-R1 | `ART_REVIEW.md` G-1, `work/fix_rift_vA_compat_vs_forward.jpg` | navegador; desktop não muda | P | `environment-artist` | feito | recortes do `vA_c` em Forward+ e Compatibility com diferença de até 15 por canal |

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

### DT-004 Vídeo da luta com som
- Travessias feitas (720p, mudas). Falta o vídeo da luta com Morvath no HEAD a 1920 x 1080 com som. **Responsável**:
  `gameplay-engineer`, `qa-performance`. **Esforço**: P.

### DT-005 "Resources still in use at exit"
- Igual. **Pronto quando**: `tools/test.sh` e `tools/smoke.sh` sem a linha.

### DT-006 Vídeo dirigido do bloqueio de corpo
- O roteiro à mão do QA (`METRICAS.md` seção 4) cobriu a mecânica em números; falta o vídeo. Baixa prioridade.

### DT-009 Medidas de câmera da F6 nunca em número
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

## 5. T2: teste do Daniel desta entrega

**Atualização (quinta revisão)**: o T2 virou o teste final do C12c. O roteiro novo, com 7 perguntas ligadas às hipóteses A a F,
está no `roadmap_plan.md`, seção E; as perguntas abaixo continuam valendo como apoio.

**Quando**: depois do commit do C12c e do QW-014. **Quanto**: 3 partidas, do título ao fim (vitória ou morte), no
teclado ou no controle, como ele preferir. Nenhum teste à parte para cada coisa.

### O que observar

1. **As salas parecem lugares diferentes?** Cripta (fechada, colunas e túmulo), Fendas (abismo com pontes), Jardim
   (árvore de pedra). O nome aparece por 2 s ao entrar. Alguma sala pareceu a mesma, ou alguma pareceu injusta?
2. **Ficou preso ou viu inimigo preso?** Em pilar, raiz, borda da fenda, ponte ou porta. Se sim, em que sala e onde.
3. **A fenda e a cobertura mudaram como você luta?** Usou as pontes, se escondeu atrás de coluna ou do tronco? Algum
   inimigo ou tiro pegou você de um lugar que não dava para ver?
4. **Os atiradores são justos?** O mago (rajada de 3 orbes que perseguem e se esconde atrás de coluna), o sacerdote (a
   trepadeira que rasteja pelo chão) e o besteiro (atira e foge): deu para ver o tiro chegando e sair dele? Algum era
   chato de alcançar demais?
5. **O guardião** (Cavaleiro ou Ancião, sala 5): pelo robô o Ancião é quem mais fere na descida. Foi o momento mais
   difícil antes de Morvath?
6. **Com quanta vida você chegou a Morvath** e se a luta pareceu mais curta ou mais longa que a da última vez.
7. **Os golpes e o herói ainda leem** no meio da luta nas salas novas (mais escuras na Cripta, azuis nas Fendas)? Qualquer
   coisa que esconda o herói ou um aviso.

### O que mandar
- O arquivo `%APPDATA%\EterraASelagem\runs.jsonl` inteiro (cada partida já traz `rooms`, com a arena, a vida ao entrar, o
  dano por inimigo, o tempo e o primeiro contato de cada sala, e `hp_at_boss`, `defeated_by`, os dons e o controle).
- As respostas curtas às 7 perguntas (uma linha cada basta) e, se puder, um print de onde ficou preso ou do que escondeu
  o herói.

---

## 6. Próximos ciclos

**Ordem atual (quinta revisão, `roadmap_plan.md` B)**: **C12c "Qualidade da experiência"** (hoje, seção 1b) → teste final
do Daniel → **C13 "Progressão e rejogabilidade"** (D-39: economia e dons do Hades II) → **C15 "Som e polimento"** →
**C14 "Arenas II"** → **C16 "Steam"**. A troca C15 antes do C14 é recomendação minha e espera a D-40; sem resposta vale a
ordem do pedido (C14 antes do C15). O C12c deixou de ser "Leitura do T2" (balanceamento): agora não muda número nenhum e
instrumenta o teste; o balanceamento pelos dados de gente vai para o começo do C13. O texto abaixo é o histórico da
revisão anterior.

Ordem da revisão anterior: C12b (feito no `87ba686`) → T2 → C12c "Leitura do T2" → C13 → C14 → C15 → C16.

### C12b "Fecho das Fendas" (feito no `87ba686`; falta ART-R1)
- **Objetivo**: a fenda ler como abismo com pontes e a versão de teste sair.
- **Por que agora**: é a única arena segurada pela revisão; o resto está pronto para o Daniel.
- **Entregas**: F-1 a F-5, capturas e vídeo das Fendas refeitos, QW-014.
- **Aceite**: os aceites de F-1 a F-5 na `ART_REVIEW.md`; testes todos passando; smoke `300 --seed=5` sem erro; nenhuma
  mudança na forma andável (testes de `test_arenas.gd` iguais).
- **Evidências**: `cycle12_maps/rift/` refeito, antes e depois em `work/`.
- **Responsáveis**: `environment-artist`, `art-director` (confere), sessão principal (versão).
- **Riscos**: a fenda continuar lendo como poços; nesse caso vale a D-38 (sai assim e a ponte única fica para depois).

### T2 (seção 5)

### C12c "Leitura do T2" (horas a 1 dia, só com dados)
- **Objetivo**: as salas e os atiradores ficarem justos para gente, medido pelo registro dele.
- **Por que agora**: o robô diz que o feiticeiro na sala 3 (276 a 288 de dano somado nas Fendas e no Jardim) e o Ancião como
  guardião (279 a 459) fazem a maior parte do dano; só gente diz se isso é injusto ou só difícil.
- **Entregas**: QW-015; ajuste de números em `make_data.gd` só onde o registro e as respostas apontarem (sem mexer em
  mecânica sem nova decisão); correções de preso e de leitura que o Daniel achar; B-2 e B-3.
- **Aceite**: nenhum preso relatado sem correção; para cada mudança de número, a linha do registro que a justifica; robô 0,25
  continua entre 3 e 6 vitórias em 8 na descida de 7.
- **Responsáveis**: `qa-performance` (leitura), `gameplay-engineer` (ajustes). **Riscos**: 3 partidas são pouca amostra:
  mexer só no que for gritante e repetir no teste com três pessoas (D-13).

### C13 "Progressão do Hades"
- **Objetivo**: chegar a Morvath com 5 a 8 dons, com a progressão de dons do Hades II.
- **Entregas**: DT-001 (descida inteira com as arenas espalhadas), baralho de recompensas, romã por nível, loja em 3 grupos,
  ouro por inimigo, D-09 e D-10 decididos com o registro.
- **Aceite**: robô chega com 5 a 8 dons em 8 partidas; partida inteira entre 10 e 13 min; robô 0,25 entre 4 e 7 vitórias
  em 8. **Responsáveis**: `gameplay-engineer`, `ui-ux-designer`, `qa-performance`.

### C14 "Arenas II"
- Santuário, Ponte e Runas (D-29), terceira variante das arenas do C12. Mesmos testes e evidências. Fidelidade às imagens
  conceituais (densidade, F-6, G-2, peças pelo Meshy) entra aqui se o Daniel quiser (D-36).

### C15 "Som" e C16 "Steam"
- Como antes: ART-002 (som de combate e música, D-12), ART-010, ART-011; depois controle com ícones, opções de vídeo, save
  robusto, DT-003 nas metas da Steam, D-07, D-13; Biblioteca e Reservatório se o Daniel quiser antes do lançamento.

### Itens de arte que seguem abertos

| ID | Título | Esforço | Responsável | Quando |
|---|---|---|---|---|
| ART-002 | Som de combate e música | G | `art-director`, Daniel (fonte) | C15 |
| ART-010 | Peças definitivas (estátuas, sarcófagos, porta em relevo, foice de Morvath, árvore) | M | `art-director`, `environment-artist`; Daniel autoriza créditos | C14 ou C15 |
| ART-011 | Gancho amarelo de Morvath e ouro das elites por repintura | P | Daniel | C15 |
| QW-009, QW-010 | Coroa da fachada fora do quadro; medir a `02` contra a planta | P | `art-director` | quando sobrar |

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

### Abertas

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-40 | Ordem depois do C13 | (a) C14 Arenas II e depois C15 Som (pedido); (b) C15 antes do C14 | **(b)**: o som está em todo golpe e hoje 20% da partida é silêncio; a descida longa do C13 mostra se as 4 arenas cansam antes de fazer mais 3. Sem resposta, vale (a) |
| D-41 | Nomes de Eterra para romã, raridades e loja no C13 | os nomes provisórios do `hades2_sistemas.md` ou os seus | mandar só os que quiser trocar |
| D-12b | Licença do som e da música no C15 | (a) só CC0 e síntese; (b) CC0 e CC-BY com créditos | **(b)** |
| D-37 | A referência `04` (feita por IA) em tamanho cheio está no histórico do git e no GitHub (`91cc656`) | (a) deixar como está, já que o repositório é seu e as referências são suas; (b) reescrever o histórico e forçar o envio (só com a sua ordem expressa; quebra as cópias e os outros ramos); (c) deixar e só proibir de novo | **(a) com (c)**, se o repositório for privado: não vale reescrever história por uma imagem sua. Se ele for público, ou for ficar público antes do lançamento, **(b)** numa única vez, com você mandando |
| D-38 | Se depois de F-1 a F-5 a fenda ainda ler como poços (provavelmente sem objeto: no `87ba686` ela lê como rasgo; fecha com o ART-R1) | (a) o T2 sai assim; (b) segurar o T2 e passar a variante A para uma ponte só (o rasgo ganha comprimento; muda a forma andável e os testes) | **(a)**: pela D-36 o que vale agora é a sala ser diferente, e ela já é; a ponte única entra no C14 se você sentir falta |
| D-31, D-32 | Água que desacelera; destrutíveis que abrem passagem | decidir depois do T2 | como antes |

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
| C12a | O miolo do selo escurece com as faixas da tempestade | `b7f5f4d` | Confirmar no T2 |

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
| D-10 | Bônus de sequência (não existe no Hades II) | Tirar no C13 (C13-07), coerente com a D-39 |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" ou "o Lich-Rei do Sul" (cânone) |
| D-02, D-04 | Quem sela Morvath; nomes dos paladinos | Seguir o cânone de 12/11; nomes depois |
| D-05 | Créditos do Meshy (546) | Nada até você pedir; fidelidade das arenas é candidata (D-36) |
| D-07, D-12, D-13 | Entre partidas; origem do som; executável para testadores | Como antes |
| D-03 | Imagens da Hécate | Desistir |
