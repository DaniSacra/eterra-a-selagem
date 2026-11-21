# Backlog de A Selagem

## Estado e ordem de 2026-11-20 (sessão principal com o Daniel, commit lido `22d9025`)

Substitui a "Ordem de execução de 2026-11-19 noite" (mantida abaixo como histórico). Regra que vale: dentro de um lote
as frentes rodam em paralelo só com arquivos distintos; integração, commit e push só pela sessão principal; Meshy zero.

### Respostas do Daniel (2026-11-20)

| # | Pergunta | Resposta |
|---|---|---|
| 1 | Último exe | Jogou, "está indo bem". Gerar exe novo com tudo de hoje ao fechar o lote abaixo |
| 2 | Próxima entrega | **Fechar o que está aberto** antes de abrir coisa nova (Lote A abaixo) |
| 3 | Equilíbrio | **Rodar o balance agora** (Lote B). Direção: o jogo precisa ficar **mais difícil, principalmente sem os upgrades** (Maestria baixa, sem Forja, sem Dons) |
| 4 | Câmera | Perto fica o padrão (LR-01 confirmado) |
| 5 | Estilo | O estilizado de hoje fica o padrão (RS-F2 confirmado); DT-RS2 (opção no menu) segue no Lote A |
| 6 | Dano dos perigos no herói | "Tem que ser mais difícil": **sobe de 7 para 10** (o número do Hades) em Runas, Lajes, Corrente, Raiz e Seteira; o balance-designer confere junto do item 3 |
| 7 | Nomes provisórios dos perigos | Ficam (Laje Rachada, Corrente da Ponte, Raiz Morta, Seteira) |
| 8 | H-5 cristal que descarrega (RP-14) | **Fazer** |
| 9 | H-6 chão que cede | Não fazer; revisitar depois |
| 10 | H-7 água rasa | Não por agora |
| 11 | Fonte e Loja | Seguem no Salão vestido (P-10 fechada por ora; RP-15 sai da fila) |
| 12 | OF-05 farming das portas | Recomendado: Prata desde a profundidade 4, Memória depois da camada do guardião (Q-OF3 a) |
| 13 | Ofícios, Roteiro A | Recomendado: Roteiro A depois do Lote A, o B só depois de A jogado (Q-OF1 a) |
| 14 | Coleta | Recomendado: híbrida mínima, só a Pedra Funda num veio físico, no máximo 2 por descida (Q-OF2 a) |

Não respondidas (15 a 35 da lista de 2026-11-20): **15 a 21** (resto dos Ofícios: só a Pedra Funda, Vendedor abre pela
encomenda e faz Obras, nenhum NPC novo, Forjador e Vendedor só função, sem manuscritos, voz neutra no Livro, Q-OF5 e
Q-OF11 a Q-OF15) seguem a recomendação, como combinado. **22 a 33** (nomes dos paladinos, título de Morvath, nome do
hub, romã e loja, anjos e Encantos, Abertura do Livro e Ahk, "Ultimate", licença do Meshy, créditos, lote do Meshy,
arte do Daniel, pontas do medalhão) ficam **abertas** e nada muda até ele responder; Meshy continua zero. **34** (pacote
D-52, D-53, D-55, D-62, D-63, D-11, D-23) e **35** (ENV-HB6: hub fica com luz por estação, bordas não vão a um terço)
seguem a recomendação.

### Feito desde a ordem de 2026-11-19 noite (marcar, não repetir)

| Item | Commit |
|---|---|
| Fatia 1 da rejogabilidade (materiais, Forja Temperar I e II, Dons com Memória, quatro anjos, save 6/7, registro 5) e as telas | `490188c` |
| HUB-D (NPCs, `frame_yaw`, Emeth por posto, selos dos anjos, P0 da planta), LR-01 (Câmera Perto padrão), LR-02 | `490188c`, `4fa27ff`, `7ff9565` |
| Lote 1 (1A a 1E), revisões de `d2ff05d` (arte, salas, interface, QA) e correções | `c3011c0` a `4efa876`, `490188c`, `7ff9565`, `df4afe5` |
| Lote 2A, C19 inteiro (elites de dois golpes, Ceifa Dupla, Ômega no número do Hades, botão de usar, fios de mira), cadência aprovada | `485045d`, `8dc0fea`, `a61349c` |
| Lote 2B em parte: GF-15, VX-17, B-b, T5-17 a T5-19, T5b P2-2, corredor elite com assado próprio, Q-T5-6, Q-T5-7, golpe sofrido sem silhueta | `7f1f203`, `485045d` |
| Lote 2C (QW-116, DT-104, DT-107, assados em dia) | `4fa27ff`, `490188c` |
| Escolha de save (três espaços), benchmark de interface com o Hades II (lotes 1 a 3 da UI, fileira do HUD padrão) | `b903eee`, `485045d`, `9d89a34`, `8144a79` |
| Fatia 2 (Encantos, grupos de portas, anjo na porta, porta de Salmo, Temperar III, Refinar, Esmeralda, Bênçãos novas) e a interface dela; DV-2 MAP-09 (loja de rota) | `485045d`, `8144a79`, `7f1f203` |
| Ciclo visual 2026-11-20 (Salão petróleo, oito biomas pela matriz de matiz, luz por estação no hub, ENV-HB4, HB5, HB7, EdgeKit, linha de tinta) | `485045d`, `2662d2c`, `52fcbb1`, `7f1f203`, `99f9f63`, `9271e95` |
| Passe de VFX, lotes 1 e 2 (luz da recompensa ligada, paleta das famílias, marcas das famílias, onda, círculo, inimigos, almas, ultimates) | `a649036`, `7f1f203`, `8144a79` |
| Lote 4 (perigos): RP-06, RP-07, RP-08, RP-09, RP-10, RP-11, RP-13 (só Santuário B), RP-16, RP-17; LR-03; RP-21 e LR-04/LR-06 provados e devolvidos | `490188c`, `7f1f203`, `8144a79`, `b57067d` a `22d9025` |
| BUG-108, BUG-109 | `485045d`, `7f1f203` |
| Estudo dos Ofícios (só planejamento) | `0a182f0`, `9b22888` |

### Lote A, fechar o que está aberto (agora)

| Frente | Dono | Itens | Aceite |
|---|---|---|---|
| A1 Perigos que faltam | `room-designer` (números e lugares) e `gameplay-engineer` (código), `combat-feel-director` aprova o aviso | **dano no herói 7 para 10** em todo perigo (resposta 6); **RP-14 (H-5) cristal que descarrega** nas Runas B (resposta 8); RP-12 urna de óleo; RP-18 colunata; RP-19 saídas no fundo; RP-20 pedras que caem da abóbada (Santuário B, Fendas B) | regra comum (aviso 1,0 s ou mais, fere inimigos, nunca a 6 m da entrada nem nos 3 s do começo, saída livre testada), "Derrotado por" próprio, 8 sementes do robô sem `stuck`. Fora: H-6 (resposta 9), H-7 (10), RP-15 e SW-N1 a SW-N4 (11) |
| A2 Peças dos perigos | `art-director` (spec SW-G7), `environment-artist` | gramática do perigo (SW-G7) e as peças de verdade no lugar dos placeholders: laje rachada, corrente, raiz que racha, coluna que tomba (fissura, tambores, toco), seteira com a divisa, cristal; `chain_weight` refeito se ainda pendente | AC-RS (clássico igual, F7 exato, colisão e faixa iguais, `fit_probe` sem subir, iGPU 720 Baixa até 0,5 ms) |
| A3 Cenário Sworn P2 | `environment-artist` (depois do A2) | SW-G4, SW-G5, SW-G6, SW-H1 a SW-H3, SW-C2 (só fêmures), SW-C3, SW-F2, SW-F3, SW-J2, SW-J3, SW-S2, SW-S3, SW-P1 a SW-P3, SW-R1, SW-T1, SW-A-1, RS-C7, F-6, J-5 | ordem 5.2 do `sworn_reference_ideas.md`; AC-RS |
| A4 Lote 3 técnico | `gameplay-engineer` | DT-106 (`RunReport`, `RunAward` fora do `game.gd`); DT-RS1 (`Environment` com um dono só, com o `technical-artist`); chave `look` no save para o DT-RS2 | mesma semente, mesmo `RESULT` (`smoke 600` e `--start=boss --boons=25`); ida e volta de todas as salas nos dois perfis |
| A5 Interface pendente | `ui-ux-designer` | DT-RS2 "Estilo visual" em Vídeo; MAP-07 (luz da porta no mapa) e MAP-08 (transições); entrada de Morvath no HUD (AP-2); resto do DT-103; QW-115, QW-117, ART-02.6; P2 da revisão d2ff05d que sobraram (P2-3 a P2-5, P2-8, P2-10, P2-12) | capturas a 720 e 1080; `title_flow_check` e `map_flow_check` verdes |
| A6 AP-2 "Combate que se lê" | `technical-artist`, `environment-artist` | ART-05.2 a 05.5, 05.8, 09.1; V-08 (silhuetas da esquiva, fio do Retorno); capturas das famílias de Bênção e do surgir da elite na sala; P2-C19a (2º anel do corredor elite) | vermelho saturado abaixo de 1,5% na fase 3; herói achado atrás de Morvath; sonda 41/41 |
| A7 Sensação que sobrou do 2B | `gameplay-engineer`, `technical-artist` | CF-09 (golpe 1 e corte da esquiva a 1,5x), CF-10 (segunda camada de som no golpe), tira de lado do besteiro | sonda sem regressão |
| A8 QA do lote | `qa-performance` | HUB-E, BUG-110 (exe 10 min com `--watchdog`), RS-F1, DT-RS3, MAP-05 vídeo; exe novo do lote (Windows e Linux, copiado para as duas pastas do Daniel) | relatório em `docs/qa/latest_report.md`, sem P0 |

### Lote B, equilíbrio "mais difícil sem upgrades" (em paralelo com o Lote A: só medida e números)

`balance-designer` remede com tudo que existe hoje (Fatia 1 e 2, perigos, Encantos, loja de rota): 48 a 72 sementes,
Maestria 1, 5, 10, 15, 20, réguas 0,25 e 0,45, com e sem Forja. **Meta nova do Daniel**: a primeira descida, sem
Maestria, Forja nem Dons, bem mais difícil que hoje (o robô 0,25 vence cerca de 47 de 72 com tudo; a Maestria 1 sem
Forja precisa cair bastante), e a curva com os upgrades continua a crescer. Revisa B-1 a B-5 (dano dos inimigos,
Maestria da ultimate, sustento, primeiras salas, Ancião e Cavaleiro), o dano 10 dos perigos (resposta 6) e a OF-05
(resposta 12, que tira Prata e Memória das primeiras salas). Proibido vida inflada. O `gameplay-engineer` aplica os
números depois do A1 (mesmos arquivos). Aceite: metas do `balance.md` reescritas com o pedido do Daniel e medidas.

### Lote C, Ofícios Roteiro A (depois do Lote A e do B)

OF-05 primeiro (pode ir com o Lote B, é número de porta). Depois o Roteiro A de `docs/design/oficios/18_roadmap.md`
com as respostas 12 a 21: a Primeira Picareta revista, Pedra Funda como o único contável novo, veio físico depois da
luta (no máximo 2 por descida), Vendedor abre pela encomenda e a 1ª Obra, sem NPC novo, sem manuscrito, voz neutra no
capítulo Ofícios. Histórias OF-01 a OF-30 em `17_backlog.md` (só as do Roteiro A). O Roteiro B só depois do Daniel jogar o A.

### Depois (sem mudança): Fatia 3 (Lote 5A), AP-4 (5B), C20 técnico (5C), DT-111 (5D)

### Abertas, só o Daniel (nada muda até ele responder)

Nomes dos paladinos (D-02, D-04), título de Morvath (D-01), nome do hub (D-H4), romã e loja (D-41), nomes finais dos
anjos e Encantos, Abertura do Livro e Ahk (Q-03, Q-05, Q-23), "Ultimate" (Q-16), licença do Meshy (Q-01, trava a
Steam), créditos (Q-17), lote do Meshy (Q-18, recomendação: nada até o exe novo), arte dele (Q-04, Q-07, Q-24, figuras
dos anjos, P-1), pontas do medalhão do Salão (S-Q6). **Só jogando**: se os perigos ficaram justos com 10 de dano, se a
porta de Prata compete com a Bênção, se escolher o anjo é decisão.

---

## Ordem de execução de 2026-11-19 noite (histórico; substituída pela de 2026-11-20 acima; game-director, commit lido `d2ff05d`)

Pedido do Daniel: seguir com **todo** o backlog aberto sem parar para perguntar; ele volta à noite para testar um exe.
Regra dos lotes: dentro de um lote as frentes rodam em paralelo porque não dividem arquivo; um lote começa por agente,
assim que o agente sai do lote anterior. Toda frente fecha com `tools/test.sh` verde, `tools/check.gd` sem erro, sonda
40/40 quando tocar combate, e o aceite escrito no item de origem (o ID leva à tabela). Integração, commit e push só pela
sessão principal. Meshy zero.

**Exe desta noite**: o que estiver integrado quando a Fatia 1, o HUB-D e o Lote 1 fecharem, com o HUB-E (QA do hub) e
o RS-F1 rodados antes. O que passar disso entra no exe seguinte.

### Feito desde 2026-11-18 (marcar, não repetir)

| Item | Commit |
|---|---|
| RS-0.1 a RS-0.3, RS-A1 a RS-A9, RS-B1 a RS-B5, RS-C1 a RS-C6 (lotes), RS-D1 a RS-D5, RS-E1 e RS-E2, correções da revisão do Lote A | `d153434`, `081a82d`, `b0ebc78`, `ecc6c3d`, `f3ef650`, `b2a7e20` |
| RS-F2 (exe abre no estilizado, F7 volta ao clássico) | `b7dfa15` |
| RS-0.5 (`frame_stats.py --hue`) | `2f0ad73` |
| Ouro das elites no estilizado (bug do PO) | `a1beec9`, `0c17740` |
| P0 da exportação (baralho vazio, loja vazia no exe) | `ed5a980` |
| LC-1 a LC-5 e LC-1b, LC-3b; LC-6 (pacote de revisão `4354550`) | `ae67a7d`, `4354550`, `0ac8909`, `21f2305`, `a0d9bb9` |
| RS-C1 do ciclo LC (Criptas A e B com peça dominante, pano com o leão) | `47d06a7` |
| RP-01 a RP-05 (zonas, entrada das Runas, peso das Runas, Ponte A, Fendas A) | `6762dbc` |
| Runas: som ao armar e no golpe; leitura no Compatibility (P1 da cadência) | `c79802f`, `c6d6aab` |
| Sworn P1: SW-G1, SW-G2 (com SW-J1 e SW-S1), SW-G3, SW-C1, SW-F1, SW-K1 | `41f8b91`, `bbe3872`, `e950142` |
| Câmera Perto (opção Longe/Perto) | `29039f1` |
| Hub HUB-B1, HUB-B2 (50 x 33 m), HUB-B3 e a interface do HUB-C, placa sob o herói | `2a2fbf8`, `8f85051`, `6d4defb`, `d2ff05d` |
| RJ-0 e RJ-1 (auditoria e `sistemas.md`), aprovação do Daniel (Q-RJ1 a Q-RJ11) | `5b27581`, `ecfd9ee` |
| Auditoria de equilíbrio (propostas B-1 a B-5) | `6c09fdf`, `1492ecd` |
| QW-109 (título do nó `move_wave`) | `1957bb3` |
| AP-3 "Masmorras com alma": absorvido pelo RS (lotes A a E); sobra só o que o RS-F1 apontar | |

**Em execução agora (não repetir)**: Fatia 1 da rejogabilidade (`gameplay-engineer`: `MaterialPurse`, Prata e Memória,
portas novas, Forja Temperar I e II, Dons com Memória, encontro de dois anjos, save 6, registro 5); HUB-D NPCs,
`frame_yaw` da cantaria e Emeth (`technical-artist`); HUB-D cenário e correções (`environment-artist`); relatórios de QA,
arte, salas e interface. Arquivos que nenhum lote abaixo toca até eles fecharem: `run_map.gd`, `rooms.gd`, `stage_def.gd`,
`make_data.gd`, `save_data.gd`, `boon_state.gd`, `game.gd`, `hub*.gd`, `hub_look.gd`, `emeth.gdshader`,
`masonry*.gdshader`, `catacomb_floor*`, `paint.gdshaderinc`. Os achados dos relatórios em curso entram como bugs no
lote do dono do arquivo, na frente do resto.

### Lote 1 (já, com os agentes livres; nada nos arquivos acima)

Prioridade dentro do lote para `ui-ux-designer`, `environment-artist`, `technical-artist` e `art-director`: **as partes
deles na Fatia 1** (`sistemas.md` 3.4: página da Forja, passo "Abrir" na árvore, tela do encontro, marcas das portas,
medalhão em prata e pergaminho, Emeth por posto de Temperar, selos vetoriais dos anjos, revisão), assim que os dados
existirem. O resto do lote preenche a espera.

| Frente | Dono | Itens | Aceite | Arquivos |
|---|---|---|---|---|
| 1A Interface | `ui-ux-designer` | DT-103 resto (volta por controle e por clique, remapear no controle); QW-115 (vitória: véu, halo em degradê, ouro ao lado do número); QW-117 (glifos sem cruz, com o desenho do art-director); ART-02.6 (barras de vida dos comuns 15% mais escuras); UI-P2-13, UI-P2-14, UI-P2-15 | os de cada item; `title_flow_check` e `map_flow_check` verdes; capturas 720 e 1080 | `options_screen.gd`, `end_screen.gd`, `seal_emblem.gd`, `boon_icon.gd`, `action_slot.gd`, `life_bar.gdshader`, `howto_screen.gd`, `tools/*_flow_check.gd`, `text_pt.tres` (só chaves novas). Não tocar `boon_choice.gd`, `boon_card.gd`, `hero_screen.gd`, `talent_*` (Fatia 1) |
| 1B QA e medida | `qa-performance` (depois do relatório em curso) | HUB-E (GUT, saves antigos, controle, F7, Compatibility, desempenho, vídeo das cinco estações); BUG-110 (exe 10 min com `--watchdog`); RS-0.4 (Provação, Altar e Câmara estilizadas na galeria); RS-0.6 (`docs/qa/rs_baseline.md`); RS-0.7 (LEIAME); DT-RS3 (primeira entrada de cada bioma na iGPU, nenhum quadro acima de 50 ms); DT-110 (modo medir); MAP-05 (vídeo e capturas do mapa); RS-F1 (smoke 900 estilizado sem erro de shader, 18 vistas em `docs/gallery/redesign/final/`) | os de cada item; GPU no máximo 2 capturas por vez (`GPU_SLOTS`) | `docs/qa/`, `docs/gallery/`, `tools/` de medida |
| 1C Sensação | `combat-feel-director` | aprovações pendentes: QW-104, QW-107, QW-111, RP-03 (dano novo das Runas); parecer do LC-P1 (preparo mais longo de algum atirador, só tempo, sem Meshy); critérios de cadência do C19 escritos antes do Lote 2 | parecer em `combat_cadence.md` com P0/P1/P2 | só documentos | **Feito (combat-feel-director, `c3011c0`, `combat_cadence.md` seção 8):** QW-104, QW-107, QW-111 e RP-03 aprovados; LC-P1 não recomendado; critérios C19-1 a C19-5 em 8.2 |
| 1D Direção de arte | `art-director` | revisão do `art_direction.md` (DT-109); desenho dos glifos do QW-117; spec SW-G7 (gramática do perigo, pedida pelo RP-06); spec do MAP-06 (página do mapa) e do AP-4; revisão de QW-104 e QW-106; fecho do RS-F1 em `visual_review.md` | documentos e pareceres com capturas | só documentos |
| 1E Salas | `room-designer` | números pelo Hades II e lugares de RP-06 (H-2), RP-07, RP-11 (H-3) e RP-16, para o gameplay não esperar; plantas de SW-N1 a SW-N4 em papel | números escritos em `rooms_progression.md` com a regra comum (aviso 1,0 s ou mais, fere inimigos, nunca a 6 m da entrada nem nos 3 s do começo, saída livre) | só documentos |

### Lote 2 (depois da Fatia 1 e do HUB-D)

| Frente | Dono | Itens | Aceite | Arquivos |
|---|---|---|---|---|
| 2A **C19 "Variedade do combate e da descida"** (caminho crítico, em série) | `gameplay-engineer` | Q-11 elites com golpe próprio (esqueleto elite dois golpes a 0,2 s, corredor elite explosão dupla, como dado); Q-09 (a) segundo golpe de perto de Morvath; Q-12 Ômega carregando no número do Hades; Q-13 botão de usar para loja, recompensa e porta (reusar a ação `interact` do hub); Q-14 (a) linha da mira no orbe e no leque do Ancião, (b) regra para a trepadeira; Q-15 renda do ouro e chances de Elo e Salmo (por cima do baralho da Fatia 1); Ancião e tempestade conferidos pelo `warn_s`; LC-P1 se o 1C pedir; BUG-108; BUG-109 resto (`wait_frames` do `test_e5_ui.gd:108`, avisos do `test_boss_exits.gd`, testes de tempo real) | aceite do C19 na seção 3 (fase 1 de Morvath nenhum ataque acima de 50% e nunca 3 iguais; elites com aviso nos dois golpes; ouro mediano na loja 150 a 220; Elo em 35% e Salmo em 15% das descidas em 72 sementes; encostar não compra; todo tiro com `warn_s` 0,4 ou mais); suíte sem as linhas de vazamento e com asserções iguais em 3 rodadas | `make_data.gd`, `horde.gd`, `boss.gd`, `rooms.gd`, `player.gd`, `combo_runner.gd`, `projectiles.gd`, `ground*.gd`, testes **Cadência aprovada** (combat-feel-director, `combat_cadence.md` 8.3, `8dc0fea`): sonda 41/41, avisos de -1 a +1 f em 270 golpes de elite (o -1 é sobra de 0,003 s), 2º golpe do esqueleto a 0,2 s com fio desde a preparação, Ceifa Dupla 0,85 / 0,85 s de leitura e 2,2 s de janela, clipes dentro de 0,45 m, fase 1 perto 43 a 50% sem 3 iguais. Ancião 45 para 126 é equilíbrio (robô começa o Ômega a 3% com tiro preparando), não cadência: regra no `Bot` e releitura do balance-designer. Ressalvas: P2-C19a (2º anel do corredor elite tapado pela 1ª explosão, 0,33 s de leitura dos 0,5), P2 vídeo da Ceifa não está a 0,25x; P1 antiga fora do C19: corredor elite tremendo encostado no herói (histerese `MELEE_WALK_BAND` no `_behave_pulse`). |
| 2B Sensação herdada (junto do C19, em série com ele) | `gameplay-engineer` e `technical-artist` (assado) | GF-15 (arranque e parada animados), VX-17 (pose final do finalizador), CF-09 (golpe 1 e corte da esquiva a 1,5x), CF-10 (segunda camada de som no golpe), T5-17 a T5-19 (preparo de Morvath para maldição e erupções, recuo da besta), T5b P2-2 (erguer do esqueleto parado), corredor elite a 259 passos/min, tira de lado do besteiro, Q-T5-6, Q-T5-7, B-b | sonda 40/40 mais as metas novas; `boss_probe` e `enemy_motion_probe` sem regressão | `player.gd` (gameplay), `tools/bake.gd`, `tools/bake_hero.gd` (technical-artist) |
| 2C Assets e assado | `technical-artist` | QW-116 (cajado do feiticeiro e Morvath reassado, incluindo o clipe novo da Q-09 a); DT-104 (teste de assado velho, tetos); DT-107 (Q-19 aprovada: saem `hero_sombra/` e `paladin_1/`, arquivos fora do PCK, figuras até 4 100 triângulos); DT-108; DT-101 na parte que não pede a Q-01 (CC BY e IA no `CREDITOS.txt`, `asset_credits.md`, `steam-ia.md`) | os de cada item; `pose_drift` de Morvath até 0,45 m | `tools/bake.gd`, `assets/baked/`, `docs/art/asset_*`, `CREDITOS.txt`, `docs/steam-ia.md` |
| 2D Cenário Sworn P2 | `environment-artist` | SW-G4, SW-G5 (portão que abre; o sinal já existe onde se chama `ArenaRoom.breath`), SW-G6, SW-H1 a SW-H3, SW-C2 (só fêmures, crânio é Meshy), SW-C3, SW-F2, SW-F3, SW-J2, SW-J3, SW-S2, SW-S3, SW-P1 a SW-P3, SW-R1, SW-T1, SW-A-1; RS-C7 (fantasma da Ponte A abaixo de 2 m²); F-6 e J-5 herdados | ordem 5.2 do `sworn_reference_ideas.md`; AC-RS da seção 8.1 (clássico igual, F7 exato, `fit_probe` sem subir, robô sem `stuck`, iGPU 720 Baixa até 0,5 ms) | `*_look.gd`, `catacomb_hall.gd`, `arena_room.gd`, `arena_kit.gd`, `tomb_kit.gd`, `masonry.gd` |
| 2E Estilo no menu | `ui-ux-designer` (tela), `gameplay-engineer` (chave `look` no save, na versão da Fatia 1) | DT-RS2: "Estilo visual" em Configurações > Vídeo; F7 sai do exe ou vira tecla documentada | trocar no menu dá o mesmo quadro que o F7; save antigo abre no estilizado | `options_screen.gd`, `save_data.gd` (uma linha, pelo gameplay) |

### Lote 3 (depois do C19)

| Frente | Dono | Itens | Aceite | Arquivos |
|---|---|---|---|---|
| 3A DT-106 (antes de crescer mais) | `gameplay-engineer` | `RunReport` e `RunAward` fora do `game.gd` | mesma semente, mesmo `RESULT` (`smoke 600` e `--start=boss --boons=25`, semente 5) | `game.gd`, arquivos novos |
| 3B **Fatia 2 "a escolha do caminho"** | `gameplay-engineer` (dados e regras), `ui-ux-designer` (telas), `combat-feel-director` (Encantos), `balance-designer` (medida) | Esmeralda; 1ª ferramenta do Forjador no 1º guardião (abre o Refinar); Temperar III; Encantos 1 a 3 sobre a Lapidação (RJ-7) com carta ENCANTO e loja; porta com um anjo à mostra e o encontro de dois como carta rara; porta de Salmo; bifurcações contrastantes (RJ-2, RJ-3); porta Difícil com Prata a mais; 2 a 3 Bênçãos novas por família | aceite do `sistemas.md` 3.6 (bifurcações contrastantes medidas, cada Encanto escolhido 20 a 45%, nenhum anjo abaixo de 3 ofertas válidas em 95% dos encontros) | dono por arquivo como na Fatia 1 |
| 3C **AP-2 "Combate que se lê"** (paralelo ao 3B: shaders, não lógica) | `technical-artist` (`crowd.gdshader`, raio-x), `environment-artist` (`ritual_rune.gdshader`, `boss_shield.gdshader`, foice), `ui-ux-designer` (entrada de Morvath no HUD) | ART-05.2, 05.3, 05.4, 05.5, 05.8, 09.1 (elites medidas em luta) | vermelho saturado abaixo de 1,5% no quadro da fase 3; herói achado atrás de Morvath; sonda 40/40; clássico e Compatibility conferidos | shaders citados, `xray*.gdshader`, `hud.gd` |
| 3D DV-2 "Descida de Valmor II" | `gameplay-engineer` (MAP-09, depois do 3B porque o baralho muda), `ui-ux-designer` (MAP-07 no mapa, MAP-08 transições), `environment-artist` (luz da porta do MAP-07) | MAP-07, MAP-08, MAP-09 (Q-26 b) | os da seção 3 (72 sementes com a loja de rota) | `map_screen.gd`, `map_graph.gd`, `arena_room.gd` (luz da porta), `run_map.gd` e `_stage` |
| 3E DT-RS1 | `technical-artist` com o `environment-artist` | `Environment` com um dono só (`RoomMood`) | ida e volta de todas as salas nos dois perfis, fase 4 e câmara iguais | `room_mood.gd`, `world_air.gd`, `arena_room.gd`, `boss_chamber.gd`, `visual_profile.gd` (combinar com o 2D) |

### Lote 4 (perigos de sala; `gameplay-engineer` em série, `room-designer` fixa números antes, `combat-feel-director` aprova o aviso, `environment-artist` faz a peça com a SW-G7)

Um comportamento por entrega, nesta ordem: **RP-06 (H-2, laje de pisar)** → RP-07 (variante e intensidade pela
profundidade) → **RP-11 (H-3, corrente e raio que varrem)** → RP-16 (seteira ligada à laje) → RP-08 (H-4, fenda que
respira) → RP-09 (coluna que tomba) → RP-10 (H-1, raiz que golpeia) → RP-14 (H-5, cristal) → RP-12 (urna de óleo) →
RP-13 (borda que desmorona, no lugar do H-6: o H-6 com chão que some fica de fora, custo técnico alto, recomendação
"não") → H-7 (água rasa, só se o Jardim B pedir) → RP-17 (mureta), RP-18 (colunata), RP-19 (saídas no fundo) → salas
novas SW-N1 a SW-N4 com RP-15 (Fonte e Loja em câmaras próprias, P-10). Aceite de cada um no `rooms_progression.md`;
`test_boss_exits` no molde para a saída livre; "Derrotado por" com chave própria; 8 sementes do robô por sala sem
`stuck`. Opção para ganhar tempo (opinião minha): um segundo `gameplay-engineer` em worktree só para os perigos
(`arena_hazard.gd`, arquivos novos de perigo e só as funções da sala no `make_data.gd`), com a sessão principal juntando.

### Lote 5 (depois do Lote 3)

| Frente | Dono | Itens | Aceite |
|---|---|---|---|
| 5A **Fatia 3 "o fim de jogo"** | `gameplay-engineer`, `ui-ux-designer`, `balance-designer` | ferramentas 2 e 3 (Despertar, Inscrever), Encantos 4 a 6 (RJ-8), Discernimento I e II (RJ-10), Obras e troca no Vendedor, Esmeralda por recorde de Peso, aba Anjos no Compêndio, RJ-11 (Memória como as Cinzas) se não estiver coberta pela Fatia 1 | diferença Maestria 1 para 20 entre 40 e 60 pontos (`sistemas.md` 3.6) |
| 5B **AP-4 "Livro, coleção e título"** sem o que pede arte do Daniel | `ui-ux-designer`, `art-director`, `technical-artist` (esboço em traço dos inimigos pelo modelo assado, sem IA) | ART-06.2, 06.3, 07.1 a 07.5, 10.2 a 10.4, 01.5; MAP-06; motivos pintados vetoriais dos 19 Dons (ART P1-10); moldura de couro e abas como fitas | cada tela aprovada a 720 e 1080 pelo art-director |
| 5C **C20 técnico** | `gameplay-engineer` (pausa ao perder o foco e ao desconectar o controle, GP P2-3; nunca no robô nem `--smoke`), `ui-ux-designer` (o que sobrar do DT-103) | itens do C20 na seção 3 menos a arte | `title_flow_check` com controle; foco perdido em PLAY abre a pausa |
| 5D DT-111 | `gameplay-engineer` | documentar; subdividir o passo só se a máquina fraca pedir | nota no `CLAUDE.md` |

### Lote 6 (por último, decisão do Daniel: mecânicas primeiro)

**Equilíbrio B-1 a B-5** (`docs/design/balance.md`): o `balance-designer` remede com Forja, materiais, encontros,
Encantos e perigos já no jogo (48 sementes, Maestria 1, 5, 10, 15, 20, réguas 0,25 e 0,45) e reescreve os números; o
`gameplay-engineer` aplica (B-1 dano dos inimigos, B-2 Maestria da ultimate, B-3 sustento na escada, B-4 primeiras salas,
B-5 Ancião e Cavaleiro). Proibido vida inflada. Aceite: metas do `balance.md` com os sistemas novos somados.

### Fora da fila: dependem do Daniel (nomes, lore, Meshy, arte dele)

- **Meshy** (nenhum crédito): LC-P2 (besta e cajado novos), Q-18 (estátua, armas, gancho, repintura das elites), SW-A1 a
  SW-A4 (crânios, portão, arco, bacia com o leão), crânios do SW-C2.
- **Licença e créditos**: Q-01 (plano do Meshy; fecha o DT-101), Q-17 (nome nos créditos).
- **Nomes**: `PALADIN_1` a `PALADIN_4` (D-02, D-04), título de Morvath (D-01), romã e loja em Eterra (D-41), nome do hub
  (`hub_name` "Santuário", D-H4), Vendedor e Forjador e quem vende (L-11), as ferramentas do Forjador (RJ-9), nomes finais
  dos Encantos e dos anjos (Sarael, Nivael, Lumael, Shomael aprovados como proposta; ficam em chaves próprias).
- **Lore e texto**: Abertura narrativa do Livro (Q-05, proposta a partir do cânone para ele aprovar), Ahk narrador e a
  cena dele (Q-03, Q-23), texto da porta selada e do véu (D-23).
- **Arte que só ele traz**: título com a maga nova e sem cruzes (Q-07, ART-08), retrato do Guerreiro com a Emeth certa
  (Q-04), medalhões das 25 Bênçãos e 6 Elos (Q-24), retratos ou figuras dos anjos, os 18 conceitos em 1920 x 1080 (P-1),
  pontas do medalhão do Salão (S-Q6).
- **Números que ele segura**: passo do dano das Runas de 7 para 10 no herói (parecer da cadência de 2026-11-19).
- **Só jogando**: tudo o que a seção 4 lista em "O que só o Daniel jogando responde", mais se a porta de Prata compete
  com a Bênção, se escolher o anjo é decisão e se a Câmera Perto fica como padrão.

---

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

- **Atualização de 2026-11-18 (game-director, commit lido `b279433`)**: diretriz do PO "Eterra Stylized Art" (só
  planejamento). Entram o plano `docs/art/stylized_poc_plan.md`, a seção 7, a ordem nova na seção 5 e a regra do Meshy
  (nenhum crédito sem o "pode" do PO e sempre com estimativa antes; a Q-18 antiga foi substituída). Nada rodado.

- **Atualização de 2026-11-18, noite (game-director, commit lido `deea6e5`)**: diretriz do PO de redesenho artístico das
  18 vistas (`docs/art/po_directive_room_redesign_2026-11-18.md`); o Daniel foi dormir e pediu que tudo fosse feito pela
  decisão do Game Director, para ele testar de manhã. Entram a **seção 8 "Redesenho das salas (RS)"** (bugs e quickwins
  que as medidas revelaram, itens RS-A a RS-E por lote, RS-F de fechamento, perigos H-1 a H-7 aguardando o PO, perguntas
  pendentes com a decisão provisória), a seção 0 com DV-1, MUS-1, AP-1 e STY e a ordem nova na seção 5. Lidos: a
  diretriz, `docs/design/room_redesign_level_review.md`, `docs/art/room_redesign_matrix.md`, as specs dos lotes A a E,
  `docs/art/room_redesign_decisions.md`, `docs/gallery/rooms_2026-11-18/LEIAME.md`, `arena_room.gd`, `arena_kit.gd`,
  `catacomb_hall.gd`, `visual_profile.gd`, `game.gd` (F7). Rodado por mim: `tools/fit_probe.gd -- --arena=hall` com
  `--look=classic` e `--look=stylized` (honra o perfil, ver RS-0.4). Nada implementado.

## Estado do jogo em 5 linhas (noite de 18/11)

1. **Combate e descida estáveis e completos para a primeira região**: C17, DV-1 (grafo da descida e mapa no Livro), MUS-1
   e AP-1 feitos; nenhum P0 aberto de gameplay.
2. **O perfil estilizado (STY-01 a STY-10) está pronto só no Salão**: figuras, Emeth, cortes e avisos pintados em todo
   lugar, mas a pedra e o ar das arenas continuam os do clássico (RS-0.1, RS-0.2): as 18 vistas medem matiz 223 a 259,
   uma sala só em cor.
3. **O redesenho das salas começou** (Lote A com o environment-artist): cada bioma com paleta, fundo e marcos próprios,
   só no estilizado, clássico intacto, nada novo no chão andável, Meshy zero.
4. **O que falta medir é gente**: dificuldade de Morvath para humano, se o estilizado agrada jogando e se o F7 serve de
   comparação; o robô mede ritmo e regressão, não beleza.
5. **Steam continua fora** (pedido do Daniel); Q-01 (licença do Meshy) e Q-17 seguem abertas.

## Estado do jogo em 5 linhas (manhã de 18/11, histórico)

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
| **DV-1 "Descida de Valmor I"** | `286c9a7`, `859a2b3`, `c831399`, mapa `3ab128a`, `6d8a1ce`, `615e5ab`, `2c34e38` | MAP-01 a MAP-05: grafo da descida pela semente, portas = ligações, robô lendo o mapa, mapa no Livro de Ahk com M | `docs/gallery/dv1/`, `docs/qa/dv1_metrics.md`, `tests/test_descent.gd` |
| **MUS-1** (música de luta) | `9ba1a09`, `470937c`, `ee1fac7` | quatro peças compostas pelo projeto, novas como padrão, save 5 | `docs/gallery/mus1/`, `tests/test_music.gd` |
| **AP-1 "Nada de protótipo"** | `4231da7`, `b279433` | esmalte e relicário das recompensas, estela da Provação, câmaras assentadas, fonte de pedra, portal fundo, braseiros, janelas da Câmara | `docs/gallery/ap1/` |
| **STY-01 a STY-10** (prova estilizada) | `3e63692` a `1e0ea78` | `VisualProfile` reversível (F7, `--look`), Salão pintado, figuras, Emeth, cortes e avisos pintados, poças de fogo, correções das revisões STY-09 | `docs/art/stylized_review.md`, `tests/test_visual_profile.gd`, `tests/test_stylized_figures.gd` |
| **Galeria das 18 vistas e agente room-designer** | `af5fd02`, `ca9b8da`, `4fe9bd9`, `deea6e5` | capturas clássico e estilizado de todas as salas; estudo de level design, matriz e specs do redesenho | `docs/gallery/rooms_2026-11-18/`, seção 8 |

Saíram deste backlog por estarem feitos (prova nos commits citados no backlog anterior e no `CLAUDE.md`): E1a a E1c, E2 a
E6, C12c a C12d, C13 inteiro, C15-01 a C15-05, BUG-017, B-c, B-2, DT-001, DT-003 (iGPU medida na E6), DT-012 a DT-016,
VX-04 a VX-07, VX-13, VX-14, QW-014, QW-018 e o roteiro do T3.

---

## 1. Bugs e quickwins (primeiro)

**Noite de 18/11: os mais urgentes estão na seção 8.2** (RS-0.1 `paint_look` só no Salão e RS-0.2 `_dress_air()` por
cima do ar estilizado, os dois altos; RS-0.3 F7 sem refazer o ar; RS-0.4 a RS-0.7 ferramentas e linha de base). As
tabelas abaixo são da manhã; o que nelas não tem "Feito" segue valendo depois do RS.

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
| BUG-109 | P2 | Testes que dependem do relógio de parede (número de asserções muda entre rodadas); `test_descent` instável (Q-T5-5) | QA P2-2: 239 232, 236 970, 238 520 asserções com os mesmos testes | "falhou depois do merge" sem reprodução | P | `gameplay-engineer` | QA P2-2, GP P2-10 | número de asserções igual em 3 rodadas; `wait_frames` trocado (`test_e5_ui.gd:108`); avisos `Float/Int` do `test_boss_exits.gd` resolvidos **Em parte no DV-1**: todo jogo de teste usa `--seed=1` (`tests/hooks/pre_run.gd`), `test_descent` reescrito e estável (26 188 asserções em rodadas seguidas); a suíte ainda varia (209 275 e 209 968) por testes de tempo real (ex.: `test_arenas` "field and 8 bodies"); `wait_frames` do `test_e5_ui.gd:108` e avisos do `test_boss_exits.gd` não feitos. |
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
| **QW-104** | P1 | **(ART-09.7) Corpo do inimigo acende no "vai bater"**: rampa mais clara e morna nos últimos 30% do preparo, abaixo do `flash_cap` | `crowd.gdshader:158` só acende orbe e lâmina; Hades clareia o corpo até 0,95 no último 0,5 s | ler o perigo pelo corpo, sem olhar o chão | P | `gameplay-engineer` (`crowd.gdshader`, `Horde.render`), `art-director` (números) | CF-06 | captura GPU 1080 de esqueleto, Escudo e feiticeiro no segurar aprovada pelo art-director; nenhum canal acima de 1,0; teste em `test_enemy_windup.gd` **Feito no C17** (`5a0dde9`): `docs/gallery/c17/qw104_*`; falta a aprovação do art-director. **Cadência aprovada** (combat-feel-director, `combat_cadence.md` 8.1: corpo no máximo no quadro do golpe, 0 f em 50 botes; P2: rampa de 0,24 a 0,35 s contra 0,5 s do Hades, `tell_time` próprio no C19). |
| QW-105 | P1 | Espera sorteada entre golpes (0 a 0,4 s somados ao `AFTER_RECOVER` por inimigo) e Cavaleiro que investe também de perto; histerese do Cavaleiro | esqueleto bate a cada 215 quadros exatos 15 vezes; Cavaleiro 9 golpes curtos idênticos e troca andar/parado 0,88 vez/s | metrônomo previsível | P | `gameplay-engineer` | CF-08, CF-11 | `--play` s1 e s2: desvio padrão do intervalo de 0,1 s ou mais; Cavaleiro investe 1 vez a cada 4 golpes ou menos; troca andar/parado abaixo de 0,5/s **Feito no C17** (`0c13d4e`): desvio padrão 0 para 0,11 s; Cavaleiro 3 investidas em 9 golpes; andar/parado 0,88 para 0,39/s; `test_no_metronome`. |
| **QW-106** | **P1** | **Feito no C18 (environment-artist, `RewardGem`; aguarda revisão do art-director). Art polish: ART-01.1; o que falta (leitura sem placa, relicário) é ART-01.2 e ART-01.3.** **Recompensas de verdade**: trocar os primitivos chapados (`Rooms.gem_mesh`, `SHADING_MODE_UNSHADED`) por disco de ouro velho com o medalhão pintado que já existe (`assets/ui/boons`, `assets/ui/events`), sombreado, girando devagar sobre pedestal baixo, halo abaixo do glow; um material por tipo e luz só na porta escolhida | `art/shop.jpg` (olhei: cubos amarelo, vermelho, verde, azul), `art/altar.jpg`, `art/trial.jpg`, `env/fwd_shop.jpg`; uma omni e um material por gema | a peça mais "protótipo" do jogo, em toda sala vencida | P a M | `environment-artist` (peça e material, em arquivo próprio `reward_gem.gd` para não brigar com o BUG-101 no `rooms.gd`), `ui-ux-designer` (medalhão por recompensa) | ART P0-1, ENV P1-1, AUD P0 | nenhuma `BoxMesh`/`PrismMesh`/`SphereMesh` sem luz em loja, altar, Provação e fim de luta; cada recompensa reconhecida pelo símbolo a 720 sem ler a placa; maior canal na tela até 226; no máximo uma omni de recompensa acesa |
| QW-107 | P1 | (ART-09.7) Mira do besteiro e bote do esqueleto em degradê: fio até 10 px a 1080, ponta clara, corpo até alfa 0,45 enchendo só nos últimos 30% | `art/bridge.jpg`, `art/runes.jpg`, `videos/v2_combo.mp4` 0:05 a 0:09 da AUD: faixa vermelha opaca de ponta a ponta | a coisa mais forte da tela é um aviso | P | `gameplay-engineer` (`GroundLook`), `combat-feel-director` aprova | ART P1-6, AUD (avisos) | largura até 10 px; nenhum trecho com alfa acima de 0,6 fora da ponta; aviso x dano 0 a 1 quadro mantido **Feito no C17** (`af5be1c`): fio de 6 px a 0,5, ponta clara, faixa até 0,22 nos últimos 30%; `docs/gallery/c17/qw107_*`; **aprovado** pelo combat-feel-director (`combat_cadence.md` 8.1: fio de 7 a 9 px medido a 1080 na GPU, faixa 0,22, aviso x dano 0 f em 50 botes, `warn_s` do besteiro 1,15 s ou mais). |
| QW-108 | P1 | **Feito no C18 (environment-artist; ART-03.4).** Lajes das Runas no tom dos avisos (preenchimento até 0,25 até os últimos 30%), pilares sem listra acesa em repouso e sem chuvisco âmbar no pontilhado | `art/runes.jpg`, `env/fwd_runes_0.jpg` | "piso de discoteca" que esconde a mira | P | `environment-artist` (`rune_floor.gdshader`, `rune_pillar`) | ART P1-3, ENV P2-1, AUD | captura em preparo: âmbar saturado abaixo de 12% da tela; mira legível por cima; nenhum ponto âmbar isolado em volta do herói atrás do pilar |
| **QW-109** | **P1** | ~~Um nome só para o especial: "Onda de Luz" (D-69); `move_bolt` vira `move_wave` no `make_data.gd`, `howto_heavy_attack_desc` reescrito~~ FEITO no C17 no texto (`move_bolt` diz "Onda de Luz"); falta só o título do nó no `make_data.gd` (`move_wave`), da sessão principal. | HUD e Compêndio "Seta de Luz", Como Jogar "seta de luz", Livro "onda de luz"; `move_wave` existe sem uso | o golpe característico com três nomes, visto em toda luta | P | `ui-ux-designer` (texto), sessão principal regera `combos` | UI-P1-01, AUD (especial) | teste de texto: nenhum "seta" no texto do jogador; captura do HUD com "Onda de Luz". Nome final na Q-06 |
| QW-110 | P1 | ~~Vocabulário único das ações: Ataque, Especial, Círculo, Esquiva, Ultimate; símbolo do HUD no lugar de E/D; "Descer de novo" nos dois finais~~ FEITO no C17: Controles, cartas, Como Jogar, Compêndio com os símbolos do HUD, "Descer de novo" nos dois finais. | "Leve (E)"/"Pesado (D)" nos Controles (o D colide com a tecla D), "Golpes leves/pesados" nas cartas, "E E E" no Compêndio, "Avanço" x "Esquiva", "Tentar de novo" x "Descer de novo" | confusão em toda tela de texto | P | `ui-ux-designer` | UI-P1-03, UI-P2-04, UI-P2-05 | teste que procura "Leve", "Pesado", "(E)", "(D)" nas chaves do jogador; nomes na Q-16 |
| QW-111 | P2 | **(ART-09.6) Feito no C18 só no desenho (environment-artist, `look_scale` 1,25 e `wake_light` no shader; o combat-feel-director mede).** Onda do especial mais legível: +25% de comprimento visual e rastro mais claro, mesmo acerto | `audit/3_gameplay/12_especial_onda_da_lamina_1080.jpg`: a meia-lua de 1,6 m mal aparece a 1080; E1c-2 já pedia | o golpe do herói não se lê | P | `environment-artist` (`emeth_wave.gdshader`, `Projectiles.WAVE_*`), `combat-feel-director` mede | AUD (especial) | `test_special_wave.gd` com os mesmos números de jogo; captura 1080 aprovada pelo art-director **Cadência aprovada** (combat-feel-director, `combat_cadence.md` 8.1: acerto igual, 5/5; a ponta desenhada a 1,0 m fica dentro do acerto real de 1,2 a 1,45 m pelos corpos); falta só o art-director. |
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
| **MAP-01** | **P1** | **Grafo da descida por semente** (`RunMap` com nós, arestas, recompensas, arenas, guardiões, fonte, altar e "?" gerados no começo; `fights_left` no pior caminho) | `run_map.gd` `options()` sorteia sala a sala; `test_descent.gd` supõe uma linha | base de toda a Descida de Valmor; muda a decisão entre quase todas as lutas | M | `gameplay-engineer` | BUG-109 junto (o `test_descent` instável é reescrito aqui) | DV-1 | GUT em 1000 sementes: toda rota tem 11 salas, começa no salão, passa por exatamente um guardião, pela loja na 10 e termina em Morvath; todo nó alcançável e com saída; até 3 arestas por nó e nunca mais que as saídas da arena; regras de arena em toda rota; fonte no máximo uma por rota; altar no máximo um; mesma semente, mesmo grafo; 100 sementes dão pelo menos 95 grafos diferentes (estrutura e conteúdo); em toda semente, ao menos uma sala com duas portas cujos conjuntos de salas alcançáveis são diferentes; Cavaleiro e Ancião como alternativas em pelo menos 30% das sementes; `--short`, `--medium`, `--arena`, `--start=` e Juramentos seguem funcionando; `test_trial.gd`: 500 grafos, nenhuma carta pede mais encontros que o pior caminho **Feito no DV-1**: `RunMap` em grafo por semente; 1000 sementes com toda rota de 11 salas, guardião, loja e Morvath; 100 sementes dão 100 grafos diferentes; `test_descent.gd`, `test_trial.gd` (500 grafos). |
| **MAP-02** | **P1** | **Portas da arena = arestas do grafo** (o `Rooms` lê as portas do nó atual; placa, `door_info`, `DoorGlyph`, luta e recompensa vêm do nó; registro com o caminho) | `rooms.gd` `_enter`, `_prepare`, `door_info`, `door_text`, `_roll_slab`, `bot_door` | o que a placa e o mapa prometem é o que a sala dá | M | `gameplay-engineer` | MAP-01 | DV-1 | GUT: em 200 descidas do robô, para toda porta atravessada a recompensa dada, o tipo de sala, a dificuldade e o guardião são os da placa e os do nó; a romã nunca chega sem Bênção que possa subir; a mesma semente e o mesmo nó dão a mesma luta por caminhos diferentes; Maestria por sala igual à de hoje; `RESULT` e registro com `map` (semente, nós, arestas) e `rooms[].node`, `events` de porta com o nó escolhido e os oferecidos (`RunLog.VERSION` 4, linhas antigas lidas por `normalized`); `test_descent`, `test_e5_wiring`, `test_economy`, `test_trial` verdes **Feito no DV-1**: portas = ligações do nó (`Rooms._enter`, `door_info`, `_prepare` com `fight_seed`); `RunLog.VERSION` 4 com `map` e `rooms[].node`; 200 descidas e 72 do robô sem promessa quebrada. |
| **MAP-03** | **P1** | **Mapa consultável (página funcional do Livro)**: ação `map` (`M`, Back no controle), botão "Mapa [M]" no HUD, entrada na pausa, caminho, sala atual, próximas portas, ramos deixados, marcas do `DoorGlyph` e "?" (`DoorGlyph.Kind.UNKNOWN` novo), legenda | `controls.gd` `ACTIONS` sem mapa; `hud.gd` `_room` no alto à esquerda; `door_glyph.gd` sem "?" | o jogador planeja a rota | M | `ui-ux-designer` (tela, HUD, texto), `gameplay-engineer` (ação `map`, pausa pelo `Game.open_screen`) | MAP-01 (lê o grafo; pode começar com um grafo fixo de teste) | DV-1 | abrir e fechar 20 vezes não muda o mapa; aberto, o relógio da partida não anda e nenhum inimigo age; ao fechar nenhum golpe escapa (`test_input_leak.gd` estendido); fluxo inteiro por teclado, controle e mouse num `tools/map_flow_check.gd`; legível a 720 e 1080 (marcas de pelo menos 18 px a 720, texto 14 px); o botão do HUD não cobre nada a 720; tecla real no botão; texto só no `text_pt.tres`, sem travessão; `M` e Back remapeáveis nas Configurações **Feito no DV-1 (ui-ux-designer, interface)**: `MapScreen`, `MapGraph`, `DescentMap` (lê o `RunMap.view()` do grafo real), `MapSample`, `DoorGlyph.Kind.UNKNOWN`, ação `map` (M, Back; remapeável no teclado), botão no HUD, Mapa na pausa, linha no Como Jogar; `test_map_screen.gd`, `test_input_leak.gd` estendido, `tools/map_flow_check.gd`; capturas em `docs/gallery/dv1/ui/`. |
| **MAP-04** | P1 | **Robô e régua no grafo**: `bot_door` com o mesmo gosto de hoje e um passo à frente (com menos de 80% da vida prefere a porta que deixa a fonte ao alcance); régua da E6 refeita | `Rooms.bot_door` olha só a porta; `docs/qa/e6_metrics.md` medido na linha única | as métricas de balanceamento deixam de valer quando o mapa muda | P a M | `gameplay-engineer` (robô), `qa-performance` (régua) | MAP-02 | DV-1 | 24 descidas (reação 0,25, `--ultimate=cleave`): nenhum erro, ninguém preso, vitórias a no máximo 2 de 24 da base do C17 (23 de 24); 72 sementes Maestria 1 e 20 com a diferença ainda até 25 pontos; Bênçãos ao chegar a Morvath e ouro na loja anotados no `docs/qa/latest_report.md` **Feito no DV-1**: `bot_door` lê o mapa inteiro (`bot_way`); régua em `docs/qa/dv1_metrics.md`: 56 de 72 contra 58 da base, Bênçãos em Morvath mediana 6, ouro na loja 85. |
| **MAP-05** | P1 | **Prova do aceite do PO** (vídeo e capturas) | pedido do PO | o PO vê a mudança sem precisar achar o caso | P | `qa-performance` | MAP-01 a MAP-03 | DV-1 | em `docs/gallery/dv1/`: vídeo na GPU de uma descida em que a sala mostra duas portas com consequências diferentes (o mapa aberto antes mostra o que cada uma alcança), o herói escolhe pela arena e `M` mostra o caminho feito; capturas do mapa de duas sementes com salas e ligações diferentes, todas as rotas chegando a Morvath; o `comparativo.md` e o `CLAUDE.md` atualizados **Parte de lógica no DV-1**: `test_map05_the_door_walked_through_is_the_way_on_the_map` (porta escolhida pela arena vira o caminho do mapa; outra semente, outro grafo); capturas e vídeo com o mapa da UI ficam para a sessão principal. |
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

### MUS-1 "Música de luta" (pedido do PO de 2026-11-18; em paralelo, arquivos próprios)

- **Pedido**: "eu não gosto das músicas... criasse mais duas ou três músicas para as fases do jogo, por se tratar de um jogo
  de hack slash acho que tem que ser músicas mais animadas, dinâmicas. As que foram criadas são um pouco depressivas."
- **Itens**: MUS-01 duas ou três peças novas para a masmorra (caminhada e luta, laço sem emenda, 130 a 160 BPM,
  percussão que empurra, tom de aventura e não de terror), compostas e sintetizadas pelo projeto em `tools/make_music.gd`
  (licença nossa, nada de pacote pago); MUS-02 uma peça nova de Morvath nas 4 fases no mesmo espírito, se couber;
  MUS-03 entram no `MusicCatalog` (escolha na tela Músicas) e a melhor da masmorra vira o padrão (`DEFAULT`); as antigas
  ficam para escolher.
- **Responsável**: `technical-artist` (síntese, loudness, laços, pacote); `combat-feel-director` ouve contra a luta.
- **Aceite**: loudness igual às de hoje (cerca de -21 LUFS caminhada, -20 com a luta) e pico abaixo de -1 dBTP; laço sem
  emenda e sem silêncio de 2 s (`test_music.gd`, `test_mix.gd`); teto da música no pacote (18 MB) respeitado ou peça
  antiga reencodada (Q-20); gravação de 60 s de cada peça com a luta (`--sound-log` e `mix_probe --wav`) para o PO ouvir.
- **Feito (2026-11-18, technical-artist; falta o PO ouvir)**: MUS-01 "Marcha das Lâminas" (orquestral e épica, ré
  menor a ré maior, 144 BPM, 66,7 s), "Tambores do Fundo" (folk e tribal, mi dórico a mi maior, 150 BPM, 64 s) e "Pulso
  de Ferro" (pulsante, lá menor harmônico a lá maior, 138 BPM, 62,6 s); MUS-02 "Morvath, a Batalha" (dó menor
  harmônico a dó maior, 150 BPM, 64 s, 4 camadas); MUS-03 padrão: Marcha das Lâminas no título e nas salas, Morvath, a
  Batalha em Morvath (`MusicCatalog.DEFAULT`). Caminhada -21,9 a -22,0 LUFS e com a luta -20,0 a -20,1 (ffmpeg
  `ebur128`), pico -3,3 a -4,5 dBTP; Morvath -22,6 / -21,4 / -20,5 / -19,4 LUFS, -4,9 dBTP com as 4. Na luta gravada
  pelo robô: salas -16,8 a -16,9 LUFS, Morvath -16,2 (C15-01: -18 a -14), -1,0 a -1,45 dBTP depois do limitador.
  Música toda 16,69 MB no disco e 17,73 MB no pacote (teto 18): Kevin MacLeod reencodado em qualidade 0 (Q-20 a), as
  originais, os Salmos e a vitória do .wav em qualidade 1, as novas em 2. Tela Músicas com linhas mais baixas (14 peças cabem em 720). Gravações em
  `docs/gallery/mus1/` e `C:\Users\danie\Downloads\ASelagem-musicas\`. **Pendente**: um save que já gravou
  `classic_catacombs` (todo save desde o T5 grava o padrão) continua tocando a antiga; para o PO ouvir as novas sem
  escolher, uma migração de save (versão nova que troca o padrão antigo pelo novo) ou ele escolhe em Configurações, Músicas.

## 4. Perguntas para o Daniel

**Respondidas em 2026-11-18: o Daniel aceitou todas as recomendações** (Q-02 a Q-05, Q-07, Q-11 a Q-16, Q-18 a Q-20,
Q-22 a Q-27 pela recomendação de cada linha; Q-06, Q-08, Q-09 b, Q-10 e Q-21 já feitas). Q-18: ~~a estátua e as armas
dos inimigos no Meshy ficam autorizadas depois do AP-3, até 135 créditos~~ **substituída pela regra do PO de
2026-11-18: nenhum crédito do Meshy sem o "pode" explícito dele, sempre com estimativa antes; estátua, armas e elites
ficam "aguardando estimativa e aprovação do PO"** (estimativas por lote em `docs/art/stylized_poc_plan.md` 1.5). Q-24: os
medalhões dependem de uma prancha nova do Daniel (o AP-4 faz o resto sem ela). Seguem abertas só Q-01 (plano do Meshy,
só da Steam) e Q-17 (nome nos créditos). Ciclos em série com commit e push entre um e outro: DV-1 com AP-1, C19,
AP-2, DV-2, C20, AP-3, AP-4 (MUS-1 em paralelo).

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
| Q-18 | **Aguardando estimativa e aprovação do PO** (a autorização anterior foi substituída em 2026-11-18). Créditos do Meshy (hoje 500): lote proposto pelo technical-artist | estátua encapuzada (15), armas próprias dos inimigos e o gancho de Morvath (cerca de 120), repintura das elites (60); até 195 | autorizar a estátua e as armas depois do C18 (D-46 já disse "lote com orçamento"); as elites esperam a Q-11 |
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

**Revista na noite de 2026-11-18 pela diretriz do redesenho das salas** (seção 8). A prova estilizada (STY-01 a
STY-10), o DV-1, o AP-1 e o MUS-1 estão feitos; o redesenho é a migração sala por sala que o AP-3 previa, então o **AP-3
vira o RS** (os aceites dele continuam dentro do RS: nada de fundo liso, KayKit fora das paredes, luma de luta 55 a 70,
iGPU Baixa a no máximo 3 qps abaixo).

1. **Esta noite, em série, sem parada entre lotes** (pedido do Daniel): RS-0 (bugs e ferramentas: RS-0.1 a RS-0.3 dentro
   do RS-A1; RS-0.4 a RS-0.7 em paralelo pelo `qa-performance` e pelo `technical-artist`, arquivos distintos), depois
   RS-A, RS-B, RS-C, RS-D, RS-E e o fechamento RS-F. Revisões de cada lote não bloqueiam o seguinte; as correções entram
   antes do RS-F.
2. **Manhã de 19/11, o Daniel testa** o exe (estilizado como padrão só se o RS-F passar; F7 volta ao clássico) e
   responde a lista curta da seção 8.6 e os perigos H-1 a H-7.
3. **AP-2 "Combate que se lê"** no perfil que o Daniel escolher (estilizado se ele aprovar o RS; o clássico continua
   intacto e testado).
4. **C19** variedade, **DV-2**, **C20** e **AP-4**, como antes. Perigos de sala aprovados (minha ordem: H-2, depois
   H-3) entram como itens de gameplay depois do C19, com o `room-designer` fixando os números pelo Hades II antes.
5. **Meshy**: só estimativas, nada gasto sem o "pode" do Daniel.

Opinião minha: não abrir o C19 em paralelo esta noite. Ele não cruza arquivos com o RS, mas o teste de manhã é para
julgar as salas; mudar o combate ao mesmo tempo mistura as respostas.

**Revista em 2026-11-18 pela diretriz "Eterra Stylized Art"** (histórico) (seção 7): o Daniel pediu para parar e planejar. Nada
começa sem ele dizer o "pode" para a prova de conceito. A ordem nova:

1. **Daniel responde S-Q1** (a imagem de referência que faltou) e aprova o plano `docs/art/stylized_poc_plan.md`.
2. **Revisão do AP-1 pelo art-director no perfil clássico** (está pendente e vira a linha de base da prova) e o **T6**,
   se ainda não foi jogado.
3. **STY, prova de conceito no Salão das Catacumbas** (5 a 6 dias, STY-01 a STY-09). Pode correr junto com o **C19**
   (só lógica e dados; não toca `crowd.gdshader`, raio-x, `masonry`, chão nem `CatacombHall`) se o Daniel liberar.
4. **Daniel julga a prova** (lado a lado, vídeos, FPS, pareceres).
5. **AP-2 "Combate que se lê"** logo depois, nos dois perfis (é leitura de combate, vale em qualquer estilo; espera a
   prova só porque mexe no `crowd.gdshader` e no raio-x).
6. **DV-2** e **C20** como antes.
7. **AP-3 "Masmorras com alma"** vira a migração sala por sala no estilo aprovado (ou segue clássico se a prova for
   recusada); **AP-4** em paralelo (interface 2D, arquivos distintos).
8. **Meshy**: só estimativas por lote ao Daniel, depois do AP-3 ou quando uma revisão pedir forma esculpida.

A lista abaixo (antes da diretriz) fica como histórico.


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

---

## 7. Eterra Stylized Art (diretriz do PO de 2026-11-18, só planejamento)

**Estado na noite de 2026-11-18**: STY-01 a STY-10 feitos (seção 0); `PaintPass` desligado por padrão; S-Q6 (pontas do
medalhão) segue aberta e foi para a seção 8.6. O AP-3 virou o redesenho das salas (seção 8).

Plano completo em **`docs/art/stylized_poc_plan.md`** (diagnóstico, prova de conceito, riscos, perguntas S-Q1 a S-Q4);
texto do Daniel em `docs/art/po_directive_stylized_2026-11-18.md`. A referência que ele citou não chegou (S-Q1); a
provisória é a prancha `docs/art/ref/direcao_2026-11-18/prancha_relicarios_cripta_livro_morvath.png`.

- **Diagnóstico em uma linha**: cerca de 65% da estética só com shaders, luz e pós, 75 a 80% com geometria procedural;
  Guerreiro, Emeth, os nove inimigos, Morvath, a pedra procedural e o KayKit miúdo ficam; o que falta é forma esculpida
  e textura pintada à mão (estimativas do Meshy, nada autorizado).
- **Prova (STY-01 a STY-09)**: Salão das Catacumbas num perfil `--look=stylized` reversível (`VisualProfile`, global
  `art_style`, `paint.gdshaderinc`, pós `PaintPass` só no Forward+ e só sobre o opaco), câmera, layout, colisão e lógica
  iguais; 5 a 6 dias; `art-director`, `environment-artist`, `technical-artist`, `qa-performance`,
  `combat-feel-director`.
- **Meshy**: regra do PO de 2026-11-18, nenhum crédito sem o "pode" explícito dele e sempre com estimativa antes; a Q-18
  está "aguardando estimativa e aprovação do PO".

**Art polish diante da nova estética (nada descartado)**:

| Ciclo | Antes | Agora | Por quê |
|---|---|---|---|
| AP-1 | feito, aguarda revisão | revisão do art-director no clássico antes da prova | é a linha de base do lado a lado (relicários, portal e braseiros estão no salão) |
| AP-2 Combate que se lê | depois do C19 | **logo depois da prova**, nos dois perfis | leitura de combate vale em qualquer estilo; espera só pelo conflito no `crowd.gdshader` e no raio-x |
| AP-3 Masmorras com alma | depois do C20 | **vira a migração** sala por sala no estilo aprovado; os aceites dele (sem fundo liso, KayKit fora das paredes, luma 55 a 70, iGPU Baixa a 3 qps) continuam | é o ciclo que mais muda com a estética; fazer em clássico agora seria refazer |
| AP-4 Livro, coleção e título | por último | **em paralelo ao AP-3**, sem mudança de escopo | interface 2D já em pintura digital (medalhões, Livro); não depende do 3D |


---

## 8. Redesenho das salas (RS)

Diretriz do PO de 2026-11-18 (`docs/art/po_directive_room_redesign_2026-11-18.md`), estudo do `room-designer`
(`docs/design/room_redesign_level_review.md`), matriz e specs do `art-director` (`docs/art/room_redesign_matrix.md`,
`room_redesign_lot{A,B,C,D,E}_spec.md`) e decisões da noite (`docs/art/room_redesign_decisions.md`, mais L-1 ardósia
azul no Salão, L-11 loja sem personagem, L-12 cristal só como imagem). Os números de cada item são os das specs; aqui
está só o alvo que decide o aceite.

**Regras de todos os itens**: só o perfil STYLIZED muda (tudo novo por `VisualProfile.vary`; peça nova `visible` falso
no clássico); câmera, colisão, `RoomLayout`, portas, nascimentos, avisos, raio-x e combate não mudam; nada novo acima de
0,3 m no chão andável nem acima de 0,9 m a 2 m da borda sul; nenhum círculo no chão fora do Salão e da Câmara; cores
reservadas (Emeth 133, Morvath 157 a 165 e 253 a 270, aviso 4, âmbar 30 só nas Runas, petróleo saturado só no herói);
nada de figura alada, auréola, sol, cruz ou estrela; Meshy zero.

### 8.1 Aceite comum (AC-RS), vale para todo item de sala

1. **Clássico intacto**: capturas clássicas das salas tocadas iguais às de `docs/gallery/rooms_2026-11-18/atual/` (até 2
   por canal fora das chamas); `tools/test.sh -gselect=test_visual_profile` e `-gselect=test_room_style` passam.
2. **F7 dentro da sala** troca e volta exato, ar incluído (`test_room_style.gd`: monta a sala, troca duas vezes, compara
   materiais, luzes, visibilidade, `Environment`, lua e colisão).
3. **Jogo**: `tools/fit_probe.gd -- --arena=<id> --variant=<n> --look=stylized` sem subir fantasma nem peça sem desenho
   mais de 0,1 m² sobre a linha de base (tabela 0.2 do estudo); `tools/test.sh -gselect=test_arenas`; 8 sementes do robô
   por sala e variante tocadas (`tools/smoke.sh 120 --arena=<id> --variant=<n> --seed=1..8 --look=stylized`) com
   `stuck` 0 no `RESULT`; `tools/test.sh` inteiro e `tools/check.gd` sem erro.
4. **Leitura** (pelo `tools/frame_stats.py` com o `--hue` do RS-0.5): quadro de luta luma média 52 a 70, `SATHIGH` até 26;
   caixa de 300 x 300 px do herói com verde e ciano até 2%; aro do aviso 40 ou mais acima da laje; alvos de matiz, sat
   HSV p50 e luma p50 do chão de cada bioma (matriz 0.4).
5. **Desempenho**: no máximo 6 luzes com sombra (`tools/arena_lab.gd` imprime `SHADOWED LIGHTS`); `tools/sty_probe.gd`
   na RTX 1920 x 1080 Alta e na iGPU 1280 x 720 Baixa (`--gpu-index 1 --quality=baixa`) a no máximo 3 qps abaixo da
   linha de base do RS-0.6.
6. **Compatibility**: `DRIVER=opengl3 tools/shot.sh` uma captura por sala, sem erro de shader no log.
7. **Evidência**: antes e depois a 1080 e 720 e uma em luta com aviso (`--shot-at=9`) em `docs/gallery/redesign/<lote>/`,
   na linha de comando da galeria (`RES=1920x1080 tools/gpu.sh shot <saída> --look=stylized --arena=<id> --variant=<n>
   --bot --autopick --seed=5 --shot-at=5`).
8. **Revisão**: `art-director` em `docs/art/visual_review.md`; `combat-feel-director` uma captura de luta por bioma
   (avisos, corte, herói achado em 1 s). Revisão não bloqueia o lote seguinte esta noite; correção entra antes do RS-F.

### 8.2 RS-0: bugs e quickwins que as medidas revelaram (primeiro)

| ID | Gravidade | Título | Evidência | Impacto | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|---|---|
| **RS-0.1** | **alto** | **`paint_look` só no Salão**: a pedra, o chão e o KayKit das arenas nunca passam pelo gêmeo pintado | `ArenaKit.paint_look()` (`scripts/game/arena_kit.gd:378`) só é chamado por `CatacombHall._stylize` (`catacomb_hall.gd:423`); matriz 0.2 item 1: Cripta estilizada igual à clássica por caixa (1 a 2 níveis) | no estilizado toda arena mistura figuras e estandartes pintados com pedra clássica, contra a regra 0.3.6; o "uma sala só em cor" das 18 vistas | P a M | `environment-artist` | fechado pelo RS-A1: `ArenaRoom._stylize()` chama `paint_look(style)` em toda sala; materiais da Cripta no estilizado com `masonry_paint`/`catacomb_floor_paint` (conferido no `test_room_style`) |
| **RS-0.2** | **alto** | **`_dress_air()` grava o ar clássico por cima do estilizado** | `ArenaRoom._dress_air()` (`arena_room.gd:1517`) aplica `air()` sem olhar o perfil, depois do `VisualProfile.dress_world`; lote A 1.4 | em toda arena o estilizado perde a chave de trás da câmera e o ambiente: sem isso nenhum preset de bioma chega à tela | P | `environment-artist` | `_dress_air()` usa `style().air` no estilizado (chaves que faltam caem no `air()`); `test_room_style` confere ambiente e lua da Cripta estilizada iguais ao preset e `leave_air()` devolvendo o ar de antes nos dois perfis |
| **RS-0.3** | médio | **F7 não refaz o ar da sala vestida** | `Game._process` (`game.gd:445-446`) só chama `VisualProfile.toggle()` | o Daniel vai comparar com F7 de manhã: sem isto a troca ao vivo mostra o ar do outro perfil e o juízo dele sai errado | P | `environment-artist` (função na sala); a linha no `game.gd` passa pelo Game Director | `test_room_style`: dentro da Cripta A, B e do Salão, duas trocas deixam `Environment` e lua exatamente nos valores de cada perfil |
| **RS-0.4** | médio | **Ferramentas e `--look`**: suspeita de que `fit_probe`/`arena_lab` não honram o perfil | **conferido em parte**: rodei `fit_probe -- --arena=hall --look=stylized` e as malhas saem com `masonry_paint` e `catacomb_floor_paint` (`VisualProfile.current` lê `Dev.arg("look")`); os números iguais nas arenas vêm do RS-0.1, não da ferramenta. A galeria não tem Provação e Altar estilizados (só laboratório clássico) | sem a vista 14 e 15 estilizadas não há "antes" para o Lote D | P | `qa-performance` | uma captura estilizada de Provação, Altar e Câmara pelo `arena_lab`/`chamber_lab` na RTX em `docs/gallery/rooms_2026-11-18/estilizado/` (14, 15); se o laboratório não pintar, corrigir a ordem de leitura do perfil e registrar |
| **RS-0.5** | médio | **`frame_stats.py` sem matiz** | a matriz mediu o matiz com um script do scratchpad (matriz 0.2); `tools/frame_stats.py` só dá luma, `SATHIGH`, violeta e verde/rosa | todo aceite do RS é matiz e sat HSV p50 por caixa: sem a ferramenta no repositório o aceite não se reproduz | P | `technical-artist` | `--hue` imprime por caixa a média circular ponderada pela saturação HSV, sat HSV p50 e luma p50; reproduz a tabela 0.2 da matriz nas capturas da galeria com até 3 graus e 0,02 de diferença |
| **RS-0.6** | médio | **Linha de base do estilizado por sala** | o aceite pede "3 qps abaixo da base" e "fit_probe sem subir", e a base estilizada não existe por sala | sem base, o desempenho do RS não tem régua | P | `qa-performance` | `docs/qa/rs_baseline.md` com, para as 18 vistas no estilizado e no clássico: qps e ms de GPU na RTX Alta 1080 e na iGPU Baixa 720 (`sty_probe`), luzes com sombra, `fit_probe` (fantasma, peça sem desenho, borda falsa); feito antes de fechar o RS-A |
| **RS-0.7** | baixo | LEIAME da galeria diz que nas arenas o estilo pega "pedra, chão, props" | `docs/gallery/rooms_2026-11-18/LEIAME.md` contra a matriz 0.2 e o RS-0.1 | engana a leitura do Daniel sobre o que o estilizado é hoje | P | `qa-performance` | LEIAME diz que nas arenas só figuras, estandartes, golpes e saturação global mudam |

### 8.3 Lotes (ordem P-13; sem parada entre lotes esta noite)

Esforço em sessões do `environment-artist` (S). Cada lote fecha com um item de QA e revisão.

#### Lote A: biblioteca, Cripta A e B, Salão com Loja e Fonte (5 a 6 S; `docs/art/room_redesign_lotA_spec.md`)

| ID | Objetivo | Aceite medível (além do AC-RS) | Dono | Depende de | Esforço |
|---|---|---|---|---|---|
| **RS-A1** | Biblioteca: gancho `style()` no `ArenaRoom` e `STYLE` no `CatacombHall`, `paint_look(style)`, `ArenaKit.stylize_fires(fire)`, `ArenaRoom._stylize()`, ar estilizado e F7, `backdrop` só no estilizado, teste `tests/test_room_style.gd` | fecha RS-0.1 a RS-0.3; `test_room_style` e `test_visual_profile` passam; poças do Salão iguais ao STY-10 (braseiro leste 100 a 150 de luma, matiz 26 a 34, laje a 1,5 m) | `environment-artist` (+ Game Director: linha do F7 no `game.gd`) | nada | 1 a 1,5 S |
| **RS-A2** | Peças da biblioteca: metal fosco (ouro velho, ferro, bronze), osso com `paint_keep`, urna, efígie amortalhada | ouro na tela matiz 34 a 42, sat até 0,6, nada acima de 200; osso matiz 35 a 45, luma 110 a 150 nos feixes; urna até 0,55 m e raio até 0,14; efígie sem rosto, mão, cruz nem espada | `environment-artist` | RS-A1 | parte do Lote A |
| **RS-A3** | Cripta A em petróleo frio: preset, facho frio, brilho frio da porta norte, bruma além da frente, fundo em camadas, peças A1 a A7 | chão leste matiz 198 a 215, sat 0,10 a 0,20, luma p50 60 a 75; chão oeste 60 a 78 longe das velas; parede norte luma 32 a 48, matiz 200 a 225; fora da sala luma 12 a 30, p90 menos p10 6 ou mais; quadro YAVG 50 a 62, `SATHIGH` 12 a 24; parte quente 2,5 a 7%; 2 luzes com sombra; `fit_probe` A até 0,42 / 0,14 (base 0,32 / 0,04); efígie visível sem cobrir inimigos; nenhum ciano na caixa do herói acima de 2% | `environment-artist` | RS-A1, RS-A2 | 1 S |
| **RS-A4** | Cripta B: figura velada sobre o Ossuário, urnas no muro, luz fria da figura, mesmos números da A | os da RS-A3; `fit_probe` B até 0,41 / 0,14; figura e urnas abrem em pontilhado em volta do herói (`see_through`) | `environment-artist` | RS-A3 | 1 S |
| **RS-A5** | Salão em ardósia azul (L-1): `STYLE` da tabela 3.2, urnas junto aos potes e no plinto das estátuas do portal | chão do meio matiz 215 a 235, sat 0,08 a 0,16, luma 65 a 78; chão norte 55 a 70; abismo 205 a 225, sat 0,30 a 0,50; quadro YAVG 58 a 70, `SATHIGH` 14 a 22; poças iguais ao STY-10; `fit_probe` hall fantasma até 3,14, borda falsa até 39,16 | `environment-artist` | RS-A1 | 0,5 a 1 S |
| **RS-A6** | Loja vestida, sem personagem (L-11): tapetes umbra e ocre, lanternas de ferro, posto de provisões | `DoorSign` com contraste 4,5:1 ou mais nas capturas `--start=shop` a 720 e 1080, "faltam N" igual ao de hoje; nenhuma lanterna cobre placa; parte quente até 10%; nenhum vermelho em pano; nada barra | `environment-artist` (+ Game Director: uma linha `arena.dress_shop(pontos)` no `rooms.gd`) | RS-A5 | 0,5 S |
| **RS-A7** | Fonte vestida, bica de pedra simples (P-11): musgo, flores pálidas, velas na borda | água 40 ou mais de luma acima da laje vizinha; nenhuma luz nova; musgo nunca matiz 120 a 170 com sat acima de 0,3; fonte achada em 1 s na captura `--start=fountain` (juízo do art-director) | `environment-artist` | RS-A5 | 0,5 S |
| **RS-A8** | QA do lote | AC-RS 1 a 7 para Cripta A e B, Salão, Loja e Fonte; 8 sementes do robô na Cripta A e B; galeria `docs/gallery/redesign/lotA/` | `qa-performance` | RS-A3 a RS-A7, RS-0.5, RS-0.6 | 1 S |
| **RS-A9** | Revisões | `art-director` (Cripta e Salão lidos como lugares diferentes, nenhum dos dois umbra; marcos visíveis); `combat-feel-director` (captura de luta com aviso na Cripta e no Salão) | `art-director`, `combat-feel-director` | RS-A8 | P |

Riscos do lote: o `Environment` tem dois donos (ver DT-RS1); apagar a chave e o preenchimento da Cripta pode escurecer
o chão demais (compensar no ambiente, nunca com omni nova); pedra petróleo vizinha do cachecol do herói (separar pela
saturação, pedra até 0,2); o Salão sai da umbra aprovada no STY-09 (reversível só pelo preset, L-1).

#### Lote B: Santuário A e B, Fendas A e B (4 a 5 S; `room_redesign_lotB_spec.md`)

| ID | Objetivo | Aceite medível | Dono | Depende de | Esforço |
|---|---|---|---|---|---|
| **RS-B1** | Santuário em calcário morno: preset, fachos marfim-dourados, facho novo sobre o `boss_spawn` do guardião | chão de luta matiz 30 a 45, sat 0,06 a 0,14, luma 70 a 85; quadro luma 58 a 70; parte quente 6 a 12%; aro do aviso do guardião dentro do facho 40 ou mais acima da laje (`--start=miniboss --arena=sanctuary --shot-at=9`); luzes com sombra 5 (A) e 4 (B) | `environment-artist` | Lote A (biblioteca) | 1 S |
| **RS-B2** | Santuário, peças S1 a S6 (S6 só na B: abóbada rasgada, sem céu de poente) | `fit_probe` A até 1,3 / 0,3 e B até 1,3 / 0,1; borda falsa até 9,3 (A) e 9,6 (B); nada no chão andável | `environment-artist` | RS-B1 | 1 S |
| **RS-B3** | Fendas em ardósia-índigo: preset, bruma a 0,8 da saturação, `DEEP` a 4 se preciso | chão matiz 235 a 255, sat 0,06 a 0,14, luma 50 a 65; sat HSV p50 do quadro 0,25 a 0,40; violeta até 3% (até 5% com orbes em voo) | `environment-artist` | Lote A | 1 S |
| **RS-B4** | Fendas, peças F1 a F5 (F4 a ponte caída como marco da B, P-6; F5 vórtice só distante) | orbe do feiticeiro com maior canal 40 ou mais acima do fundo da fenda atrás dele (`--shot-at=9`); `fit_probe` fantasma até 1,6, borda falsa até 5,2 (A) e 5,1 (B); nenhum fogo verde | `environment-artist` | RS-B3 | 1 S |
| **RS-B5** | QA e revisões do lote | AC-RS nas quatro vistas; 8 sementes por sala e variante; `docs/gallery/redesign/lotB/` | `qa-performance`, `art-director`, `combat-feel-director` | RS-B1 a RS-B4 | 1 S |

#### Lote C: Jardim A e B, Ponte A e B (5 a 6 S; `room_redesign_lotC_spec.md`)

| ID | Objetivo | Aceite medível | Dono | Depende de | Esforço |
|---|---|---|---|---|---|
| **RS-C1** | Biblioteca do lote: musgo pintado (`root_moss_paint`), folha morta, fungo pálido, água escura | musgo nunca matiz 120 a 170 com sat acima de 0,3; folha matiz 15 a 25, sat até 0,45, valor até 0,4; fungo maior canal até 0,6; água matiz 200 a 210, espuma maior canal até 0,9, nada entre 170 e 190 de matiz | `environment-artist` | Lote A | 1,5 S |
| **RS-C2** | Jardim em cinza-musgo: preset, árvore de pedra no cinza-musgo, cristais com aresta até 1,0 | chão matiz 70 a 100, luma 55 a 70, sat 0,08 a 0,18; ciano no quadro até 12% (hoje 32 / 24%); folha ferrugem 2 a 6% só na copa e nas bordas | `environment-artist` | RS-C1 | 1 S |
| **RS-C3** | Jardim, peças J1 a J6 (J5 só na B: lago fora da borda oeste, polígono igual) | aviso perto da parede 40 ou mais acima e folha 100 ou mais de luma abaixo do aviso; `fit_probe` fantasma até 2,0 e peça sem desenho até 1,6; nenhuma água no chão andável | `environment-artist` | RS-C2 | 1 S |
| **RS-C4** | Ponte em cinza-azulado gasto: preset, bruma a 0,85 da saturação | chão das plataformas matiz 205 a 220, luma 55 a 70; ciano 40 a 65% com sat HSV p50 do quadro 0,25 a 0,35; parte quente 3 a 7% | `environment-artist` | RS-C1 | 0,5 S |
| **RS-C5** | Ponte, peças P1 a P6 (braseiros de cabeceira fora do tabuleiro, arcos, correntes, cascatas ao norte; P5 e P6 só na B) | atiradores da plataforma leste com 30 ou mais de luma de diferença do fundo; nenhum decalque dourado no tabuleiro; `fit_probe` A até 4,1, B até 2,8 | `environment-artist` | RS-C4 | 1 S |
| **RS-C6** | QA e revisões do lote | AC-RS nas quatro vistas; `docs/gallery/redesign/lotC/` | `qa-performance`, `art-director`, `combat-feel-director` | RS-C1 a RS-C5 | 1 S |
| **RS-C7** | Fantasma da Ponte A abaixo de 2 m² (meta do estudo) | `fit_probe` Ponte A fantasma abaixo de 2,0 sem mudar o polígono do chão | `room-designer` (diagnóstico) e `environment-artist` | RS-C5 | desejável, não bloqueia o lote |

#### Lote D: Runas A e B, Provação, Altar (5 a 6 S; `room_redesign_lotD_spec.md`)

| ID | Objetivo | Aceite medível | Dono | Depende de | Esforço |
|---|---|---|---|---|---|
| **RS-D1** | Gêmeo pintado do chão de runas (`rune_floor_paint.gdshader`) com o estado das lajes intocado | `test_e5_looks.gd` estendido: `set_tile` muda o mesmo parâmetro nos dois perfis e o F7 com uma laje acesa não apaga nem duplica o estado; `test_hazard.gd` passa; moldura acesa 40 ou mais acima da laje apagada vizinha e matiz da laje acesa 26 a 36 nos dois perfis (`arena_lab -- --arena=runes --state=arm|fire --look=...`) | `environment-artist`; `technical-artist` revisa o shader | Lote A | 1,5 S |
| **RS-D2** | Runas em pedra clara fria e peças R1 a R5 (R5: cristal fora do chão ao norte, só imagem, L-12) | chão matiz 220 a 235, sat 0,03 a 0,10, luma 62 a 75; âmbar em repouso (`--state=after`) 0% fora dos braseiros de parede (até 1%); nada redondo (D-29); nenhuma marca luminosa no chão que não seja estado de laje; `fit_probe` fantasma até 2,7, borda falsa até 0,6; `sty_probe` com as luzes do disparo | `environment-artist` | RS-D1 | 1,5 S |
| **RS-D3** | Provação lilás acinzentada: preset, losangos concêntricos pintados, estandartes desbotados, braseiros apagados, urnas quebradas | quadro matiz 265 a 285, luma p50 45 a 60; vermelho (matiz 345 a 15, sat acima de 0,4) 0%; nenhum círculo; `settle` continua apagando 60% das veias nos dois perfis; `fit_probe` até 1,2 | `environment-artist` | RS-0.4, Lote A | 1 S |
| **RS-D4** | Altar em pedra morna calma: preset, facho ouro velho pálido, oferendas, hera, pétalas | chão matiz 28 a 42, luma p50 45 a 58 antes do `kindle`; parte quente 4 a 10% depois; a luz do `kindle` continua a única com sombra; nada de figura alada, auréola, sol, cruz; `fit_probe` até 3,5 | `environment-artist` | RS-0.4, Lote A | 1 S |
| **RS-D5** | QA e revisões do lote | AC-RS nas quatro vistas; 8 sementes do robô nas Runas A e B; `docs/gallery/redesign/lotD/` | `qa-performance`, `art-director`, `combat-feel-director` | RS-D1 a RS-D4 | 1 S |

#### Lote E: Câmara do Selo, só fundo e atmosfera (1 a 2 S; `room_redesign_lotE_spec.md`)

| ID | Objetivo | Aceite medível | Dono | Depende de | Esforço |
|---|---|---|---|---|---|
| **RS-E1** | Fundo e ar distante: arcos partidos no anel distante, correntes de lado, cacos parados, céu e agulhas um degrau mais lidos; nada dentro do círculo de 12,5 m mais 6 m | quadro matiz 250 a 265, luma p50 37 a 46; fundo p90 menos p10 15 ou mais; violeta até 5% na fase 1 e até 8% na fase 4; `test_chamber_look`, `test_boss_chamber`, `test_seal_victory` passam iguais; correntes nunca na frente de Morvath (captura da fase 1 com ele no selo) | `environment-artist` | Lote A (ar e F7) | 1 a 2 S |
| **RS-E2** | QA e revisão da luta | em cada fase, Morvath e o herói achados em 1 s; aro dos avisos 40 ou mais acima do chão; meias-luas violeta com maior canal 40 ou mais acima do fundo; `sty_probe` na fase 4 (RTX Alta e iGPU Baixa, até 3 qps abaixo); `docs/gallery/redesign/lotE/`; **revisão do `combat-feel-director` obrigatória** (é a luta do chefe) | `qa-performance`, `combat-feel-director`, `art-director` | RS-E1 | 0,5 S |

#### RS-F: fechamento

| ID | Objetivo | Aceite medível | Dono | Depende de |
|---|---|---|---|---|
| **RS-F1** | Volta completa e galeria final | `tools/smoke.sh 900 --seed=5 --look=stylized` sem erro de shader no log; as 18 vistas na linha da galeria em `docs/gallery/redesign/final/`; correções pendentes das revisões A a E feitas; `art-director` fecha em `docs/art/visual_review.md` | `qa-performance`, `art-director` | RS-A a RS-E |
| **RS-F2** | **Feito 2026-11-19** (`VisualProfile.default_look`, só no exe exportado; volta da descida e Câmara no estilizado sem erro). Estilizado como padrão do exe (decisão da noite), F7 volta ao clássico | só se o RS-F1 passar; senão o exe sai clássico e o Daniel vê o estilizado pelo F7. Clássico intacto nas 18 vistas. `CLAUDE.md` e `docs/arte/estetica.md` atualizados | Game Director (`VisualProfile`) | RS-F1 |

### 8.4 Dívidas do redesenho

| ID | Título | Evidência | Impacto | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|---|
| **DT-RS1** | O `Environment` tem quatro donos: `VisualProfile.dress_world`, `ArenaRoom._dress_air`/`leave_air`, `BossChamber.restore_air` e `RoomMood` | risco 1 do lote A; STY-10 já teve um bug assim (ar da câmara lido antes de ela se vestir) | cada sala nova ou troca de perfil pode devolver o ar errado; o `test_room_style` cobre, não resolve | M | `technical-artist` com o `environment-artist` | depois do RS-F: um dono só (proposta minha: `RoomMood` recebe o ar da sala por perfil e é o único que escreve), testes de ida e volta de todas as salas |
| **DT-RS2** | O perfil visual não tem opção no menu nem no save | só F7 e `--look`; F7 não aparece nos Controles | se o Daniel adotar o estilizado, o jogador não acha o clássico; F7 hoje é tecla de desenvolvimento | P | `ui-ux-designer` | depois da decisão do Daniel: linha "Estilo visual" em Configurações > Vídeo, chave no save, ou F7 sai do exe |
| **DT-RS3** | Gêmeos de shader dobram as variantes (`masonry_paint`, `catacomb_floor_paint`, `rune_floor_paint`, `root_moss_paint`) | cada sala nova compila o gêmeo na primeira entrada | **opinião minha, não medido**: engasgo na primeira entrada de cada bioma no estilizado, pior na iGPU e no Compatibility | P para medir | `qa-performance` | `--trace-steps` na primeira entrada de cada sala, nos dois perfis, iGPU Baixa: nenhum quadro acima de 50 ms; se houver, aquecer os materiais no carregamento |

### 8.5 Perigos de sala H-1 a H-7: **aguardam aprovação do PO**

Nenhum entra no redesenho (decisão da noite, regra 0.3.9 da matriz). Regras comuns do estudo: aviso de 1,0 s ou mais,
fere inimigos também, chave "Derrotado por", nunca a menos de 6 m da porta de entrada nem nos 3 primeiros segundos,
sempre uma saída livre (teste no molde do `test_boss_exits.gd`); números no molde das Runas (herói 4, inimigo comum 35)
até o `room-designer` fixar os do Hades II. Donos quando aprovados: `room-designer` (números, lugar, progressão) e
`gameplay-engineer` (código e testes); `combat-feel-director` aprova o aviso.

| ID | Perigo | Sala | Custo de código | Risco principal | Minha recomendação |
|---|---|---|---|---|---|
| **H-1** | Raiz que golpeia | Jardim, salas 4 a 9 | comportamento novo (linha com gatilho de proximidade) | a raiz do centro dispararia sempre: só as de fora | depois do H-2 e do H-3 |
| **H-2** | Laje de pisar | Cripta (cantos) e Santuário (naves laterais), desde a sala 4 | pouco: `ArenaHazard` com padrão "gatilho" | pôr nas rotas de 4 m da Cripta | **o primeiro**, depois do C19 |
| **H-3** | Corrente que varre | Ponte A e B, da metade em diante | comportamento novo (faixa em movimento) | pegar as duas pontes ao mesmo tempo | o segundo |
| **H-4** | Fenda que respira | Fendas, desde a sala 3 | comportamento novo (empurrão em área) | empurrar o herói para dentro de um grupo | só se o H-2 agradar |
| **H-5** | Cristal que se descarrega | Runas B, da metade em diante | pouco: fileira do `ArenaHazard` com gatilho por golpe | o robô precisa aprender a ignorá-lo | junto do H-3 se o Daniel quiser um perigo que o jogador usa |
| **H-6** | Chão que cede | Santuário B e Ponte B, no fim | muito: `NavGrid`, `FlowField`, `Arena.walk` e robô com chão que some | técnico alto | **não** |
| **H-7** | Água rasa | Jardim B (o lago do RS-C3 ficaria fora do chão) | pouco (zona lenta permanente) | lentidão no herói irrita | não por agora |

### 8.6 Perguntas pendentes para o Daniel (decisão provisória tomada esta noite)

| ID | Pergunta | Decisão provisória | Minha recomendação |
|---|---|---|---|
| **P-1** | Gerar os 18 conceitos em 1920 x 1080 na câmera do jogo? | seguimos com os recortes de 548 x 146 só como clima | sim, se for refinar depois do teste; não muda o que foi feito |
| **P-10** | Fonte e Loja como câmaras próprias ou o Salão vestido? | Salão vestido (RS-A6, RS-A7) | o vestido agora; câmaras próprias só se o Salão repetido 2,5 vezes por descida cansar no teste (custo de mapa e de gameplay) |
| **P-11** | Bica de leão na fonte? | bica de pedra simples | simples: as fontes são o sinal do Sopro, o leão é outro sinal (L-4) |
| **L-1** | Salão estilizado: umbra morna (STY S-Q5 a, aprovada no STY-09) ou ardósia azul da diretriz? | ardósia azul (RS-A5) | ardósia azul com poças âmbar; volta à umbra trocando só o preset |
| **S-Q6** | As quatro pontas longas do medalhão do Salão leem como estrela de quatro pontas? | ficam, sem ouro nem brilho, no valor da junta | mudar ou tirar as pontas numa entrega própria depois do RS, com uma imagem sua |
| **L-11** | A Loja tem um mercador? Quem vende? | posto sem ninguém: caixotes, panos, lanternas | sem personagem até o cânone dizer quem vende (pergunta junto da D-41) |
| **L-12** | O cristal da Runas B explica por que a pedra quieta não acende? | só imagem, fora do chão, sem texto | fica imagem; vira mecânica só se o H-5 for aprovado |

Também para o Daniel, de manhã: os perigos H-1 a H-7 (8.5) e se o estilizado vira o padrão (RS-F2).

**O que só o Daniel jogando responde**: se cada bioma se lê como um lugar diferente descendo a masmorra (o robô não
vê), se o estilizado cansa ou ajuda a ler a luta em salas escuras como a Cripta e a Câmara, se o F7 lado a lado basta
para comparar, e se a Loja e a Fonte vestidas pedem câmaras próprias (P-10).

## 9. Ciclo LC, leitura do combate no STYLIZED (parecer da direção artística, 2026-11-19)

Base: `ed5a980` (= `0c17740` mais a correção da loja no exe). Evidências de antes: pacote
`Eterra-Evidencias-Direcao-Artistica-a1beec9.zip` (`03_personagens`, `02_comparativos/06_*`). Aprovado e fechado: ouro
velho nas elites e guardiões (`a1beec9`, galeria `0c17740`); violeta continua de Morvath. Meshy zero. Pergunta da
revisão: durante a luta, dá para perceber quem é elite, quem vai atacar e onde o golpe vai acertar?

| Id | Tarefa | Aceite | Dono | Depende |
|---|---|---|---|---|
| **LC-1** | Preparação do Besteiro: a besta e a pose de mira legíveis na câmera normal (malha, clipe e efeitos existentes) | em velocidade real, com 2 ou mais tipos em quadro, dá para dizer que é o besteiro que mira e por onde o virote passa antes do tiro | `technical-artist` (assado, `EnemyFx`) | |
| **LC-2** | Preparação do Feiticeiro: cajado e orbe como foco | idem, o orbe crescendo no cajado lido de longe e separado do Sacerdote | `technical-artist` | |
| **LC-3** | Preparação do Sacerdote: gesto de conjuração reconhecível pela silhueta, também ao lado do Feiticeiro | idem | `technical-artist` | |
| **LC-4** | Figuras no Compatibility: torso, arma e escudo com volume dentro do contorno (Guerreiro, Escudo, todos) | armas e posturas reconhecíveis no Compatibility estilizado; Forward+ e clássico iguais | `technical-artist` (`crowd.gdshader`, `hero_paint.gdshader`) | |
| **LC-5** | Tempestade das Seis Almas no Compatibility, fase 4 | faixas distintas do piso desde a preparação, do aviso ao impacto, comparadas com o Forward+ na mesma tomada | `technical-artist` (`ground*.gdshader`) | |
| **LC-6** | Entrega: build integrada, clipes antes e depois (câmera normal, HUD, velocidade real), combate com os três atiradores juntos, fase 4 nos dois renderizadores, SHA e o que passou | pacote revisado pelo Game Director | `qa-performance` | LC-1 a LC-5 |
| LC-P1 | (proposta, muda tempo ou mecânica: não neste ciclo) preparo mais longo ou com pausa marcada para algum atirador, se o LC-1 a LC-3 não bastarem | decisão do Daniel e do `combat-feel-director` | `combat-feel-director` | LC-6 | **Não recomendado (2026-11-19, `combat_cadence.md` 8.1):** o problema era quem mira, resolvido no LC-1b e LC-3b; `warn_s` dos atiradores em 8 descidas, mínimo 0,83 s (mago 1,07). Reabrir só se o registro do Daniel mostrar um atirador com mais de 30% dos golpes fora da tela. |
| LC-P2 | (proposta, só com Meshy ou modelo novo) besta maior, cajado do Sacerdote com forma própria | estimativa de créditos antes | `technical-artist` | LC-6 |
| **RS-C1** | Criptas A e B: um elemento funerário dominante por variante, com luz e composição (referências internas: a árvore do Jardim, a travessia da Ponte B) | na câmera do jogo, A e B se distinguem de relance; depois da leitura do combate | `art-director` (spec), `environment-artist` | LC-6 |

**Estado do ciclo LC (2026-11-19, build `4354550`, pacote `Eterra-Revisao-LC-4354550.zip`):** LC-2 passou (orbe lê na
tela inteira); LC-4 passou na medida (herói luma p50 31 para 103, Forward+ 88), falta o olhar do diretor; LC-5 lê no
olho desde a preparação, com o vermelho em carmim mais escuro no Compatibility (matiz 335 contra 348); LC-1 e LC-3
parciais (besta de luz com 30 a 40 px a 1080; o V do Sacerdote lê de frente, não de costas). Aguardando o parecer:
LC-P1 (tempo) e LC-P2 (Meshy) só com decisão dele e do Daniel.

## 10. Rejogabilidade do Guerreiro (pacote do PO de 2026-11-19): **só planejamento, nada começa sem o Daniel**

Base: pacote `Eterra_Pacote_Completo_Mecanicas_Rejogabilidade.zip`, copiado em `docs/design/rejogabilidade/` (diretriz
`PROMPT_CLAUDE_CODE.md`, `DESIGN_MECANICAS.md`, `ECONOMIA_FORJA.md`, `BENCAOS_MAPA.md`, `BACKLOG_VALIDACAO.md`) e
`docs/art/ref/rejogabilidade/` (5 imagens conceituais de IA, só locais como as outras referências; não vão no jogo). O próprio pacote pede
**auditar primeiro, propor e parar para aprovação**. Regra-mãe preservada: Dom define o herói, Bênção define a partida,
Salmo transforma o poder. Só o Guerreiro, só a Emeth, sem bloqueio nem aparo, golpes plantados, Meshy zero.

**Leitura prévia do Game Director (antes da auditoria, para não duplicar):**
- Mapa: o `RunMap` (DV-1) já é grafo com portas que mostram a recompensa por marca (`DoorGlyph.of_reward`), `Kind`
  COMBAT, MINIBOSS, FOUNTAIN, SHOP, BOSS, TRIAL, ALTAR e `Reward` BOON, POM, HEART, MAGICK, GOLD, HEAL, POM_SLICE, com
  regras por camada e semente própria (`MAP_SALT`). As bifurcações do pacote (Bênção contra cura, elite contra loja...)
  são em boa parte regra de sorteio nova sobre o que existe, não sala nova. Nada de sala "Magia cheia" (ela já enche).
- Encantos: sobrepõem a **Lapidação da Emeth** já estudada (`docs/design/hades2_sistemas.md`, `WeaponUpgrade` com
  `mods` e `node_overrides`, máximo 2 por partida). Um sistema só, não dois.
- Bênçãos: famílias, raridades (D-52, D-53), troca, Elos (E3-02) e Salmos existem. O encontro "2 entidades, depois 3
  Bênçãos" esbarra na **D-51** (quem concede as Bênçãos, pendente) e no cânone: as imagens do pacote mostram anjos com
  auréola e raios e cruzes nos ícones, o que contraria regras do jogo (nunca sol nem cruz; não inventar entidades).
  Identidade mecânica por família (Chama pressão, Geada controle, Luz alcance, Vigília ritmo) pode ser estudada sem
  nomear ninguém.
- Forja e materiais: o Forjador do hub está "a definir" (D-H2: proposta de aspectos da Emeth sem somar dano). O
  `balance-designer` propõe no máximo 5 a 10 pontos de vitória vindos de progresso permanente, e só depois da 5ª
  descida (`docs/design/balance.md`): Temperar, Refinar e Despertar precisam caber nisso.
- Dons: árvore, Maestria e Devoção existem (E2) e o Livro de Ahk também; "Livro dos Dons" é o mesmo. Fragmentos de
  Memória só se não duplicarem a Maestria (o pacote diz o mesmo).
- Ouro de partida já separado; nenhum recurso persistente existe ainda (save versão 5 recebe chaves novas pelo
  `SaveData.defaults()`).

| Id | Entrega (fatia) | Aceite | Dono | Depende |
|---|---|---|---|---|
| **RJ-0** | Auditoria: matriz JÁ EXISTE / PARCIAL / PROPOSTA / CONFLITO / DEPENDE DO CÂNONE para cada ideia, citando arquivos e D-xx; leitura do cânone (`../dungeon-rpg/docs/mundo/canone.md`); sobreposição Encantos x Lapidação, materiais x custos existentes; o que NÃO fazer | documento `docs/design/rejogabilidade/auditoria.md`, nenhuma linha de código | `game-director` (com `balance-designer` na economia) | aprovação do Daniel para começar |
| RJ-1 | Especificação integrada: arquitetura dos sistemas e da economia (fonte, gasto exclusivo, frequência, teto, persistência e uso no fim de jogo de cada material), migração do save, catálogo de 6 Encantos, 4 identidades mecânicas de Bênção sem entidades, wireframes de Dons, Forja, encontro e mapa, simulação de distribuição de recompensas e custo de progressão | aprovação do Daniel item a item | `game-director`, `balance-designer`, `ui-ux-designer` (wireframes) | RJ-0 |
| RJ-2 | Taxonomia de recompensas e bifurcações contrastantes no `RunMap` (sem refazer o grafo) | portas distintas, ícones claros, mesma semente = mesmo mapa; % de bifurcações contrastantes medida | `gameplay-engineer`, `room-designer` | RJ-1 |
| RJ-3 | Distribuição do mapa em muitas sementes | nenhuma rota inviável, piso de oportunidades antes de Morvath, `--short` e `--medium` | `gameplay-engineer`, `balance-designer` | RJ-2 |
| RJ-4 | Encontro em duas etapas (2 fontes, depois até 3 Bênçãos elegíveis) com fallback legível | raridade, troca, Elo e exclusões preservadas; tela e controle | `gameplay-engineer`, `ui-ux-designer` | RJ-1, **D-51** |
| RJ-5 | Materiais e uma melhoria permanente | persistência, save antigo lido, teto | `gameplay-engineer` | RJ-1 |
| RJ-6 | Forja da Emeth no Forjador do hub (Temperar, Refinar, Despertar) | melhoria completa com custo e retorno visível; dentro do teto de equilíbrio | `gameplay-engineer`, `ui-ux-designer`, `environment-artist` (estação) | RJ-5, HUB-D |
| RJ-7 | 3 Encantos de partida (sobre a Lapidação) | exclusões por ação, tags light/heavy/dash/finisher/omega preservadas, cada um muda a sensação | `gameplay-engineer`, `combat-feel-director` (revisão) | RJ-1 |
| RJ-8 | Mais 3 Encantos (6 no total) e equilíbrio | robô em muitas sementes, nenhum domina | `gameplay-engineer`, `balance-designer` | RJ-7 |
| RJ-9 | Uma ferramenta perdida do Forjador (achado único que abre uma função) | missão e desbloqueio funcionam; nome só com o Daniel | `gameplay-engineer` | RJ-6 |
| RJ-10 | Discernimento I (uma rolagem de novo por partida) | sem garantia de montagem perfeita; diversidade por semente medida | `gameplay-engineer` | RJ-4 |
| RJ-11 | Fragmentos de Memória | só se aprovados depois da RJ-0 | | RJ-0 |

**Não fazer (do pacote e do projeto):** outros heróis; mais armas equipáveis; escudo, aparo ou bloqueio; barra nova
de Fúria; baralho de tarô; dezenas de moedas; anjos, títulos de Elun, símbolos sagrados ou Deus como NPC inventados;
reescrever o mapa; cruz e sol nos ícones.

**Para o Daniel decidir antes da RJ-0 começar:** (a) a ordem em relação ao que já está na fila (equilíbrio B-1 a B-5,
HUB-D, salas H-1 a H-7); (b) D-51, quem concede as Bênçãos, antes do RJ-4; (c) se o progresso permanente da Forja
cabe na curva nova (a primeira descida muito difícil) ou se a Forja só muda o jeito da Emeth sem somar força (D-H2).

**Respostas do Daniel (2026-11-19, depois do pacote):**
1. **Ordem: mecânicas primeiro, equilíbrio depois.** As mecânicas da seção 10 entram antes do pacote B-1 a B-5 do
   `docs/design/balance.md`, e precisam conversar entre si: os recursos que alimentam Forja, Encantos e o resto vêm das
   descidas, então a descida tem de dar o que buscar. O equilíbrio de tudo junto vem depois (o `balance-designer`
   remede com os sistemas novos).
2. **As Bênçãos são oferecidas por anjos**, e os anjos e todas as Bênçãos são para inventar, com o Hades II como
   benchmark (os deuses do Olimpo e suas Bênçãos). Isso resolve a D-51 e muda a regra "nunca inventar lore" para os
   anjos: o projeto propõe nomes, aparência, temperamento e família de cada anjo e as Bênçãos de cada um, e o Daniel
   aprova; sempre servos de Yah, nunca deuses, a luz vem de Elun (cânone). A forma visual (auréola, asas) e os símbolos
   (a regra de nunca sol nem cruz) entram na proposta para o Daniel decidir.
3. **A Forja deixa o herói mais forte** (altera a arma): progresso permanente que soma força. A curva nova (primeira
   descida muito difícil) passa a contar com ela no equilíbrio.

**Intenção do PO, nas palavras dele (pedido ao ChatGPT que gerou o pacote, colado em 2026-11-19), e a leitura do Game
Director com o equivalente do Hades II:**
- "No nosso jogo as cartas de tarô são os Dons, só que mais sofisticados, com progressão; o baralho da Mel precisa de
  cinzas, outro recurso além do dinheiro." → os Dons são o nosso Arcana; hoje eles custam só Devoção e abrem pela
  Maestria; a ideia é que equipar ou abrir Dons também peça um recurso trazido das descidas (as Cinzas do Hades; o
  Fragmento de Memória do pacote é o candidato). Entra na RJ-0 e na RJ-11, que deixa de ser opcional.
- "Forja com custos de prata, brasa, ouro... como as Armas Noturnas do Hades 2; lá a gente melhora a Emeth." → a Forja
  é o nosso aprimoramento de arma (aspectos e melhorias das Armas Noturnas, pagas com materiais).
- "Escolher entre dois deuses, como no Sworn; no nosso caso anjos, e depois a Bênção. O RNG pode diminuir no futuro."
  → RJ-4 (encontro em duas etapas) e RJ-10 (Discernimento).
- "O caminho até o chefe não faz sentido escolher: as salas têm recompensas parecidas. Lojas, coisas de forja, vida
  extra, mana extra, ver o anjo da sala, aleatório, ter um Salmo." → RJ-2: recompensas novas nas portas (material de
  Forja, Encanto, Salmo, o anjo da sala à mostra, porta "?" aleatória) e bifurcações que trocam uma coisa por outra.
- "O que poderiam ser os Encantos pensando no Hades 2?" → os Martelos de Dédalo (melhorias da arma só na descida):
  RJ-7 e RJ-8 sobre a Lapidação.
- "Ir atrás das armas do Forjador" → as ferramentas perdidas (RJ-9), achadas nas descidas, abrem funções da Forja
  (a Emeth continua a arma única: nada de arma equipável nova).
- "Mais coisas que não só ouro: materiais para algum tipo de craft." → os materiais da RJ-5, com fonte nas salas,
  elites, guardião e Morvath, e gasto na Forja, nos Dons e no hub (no Hades, os reagentes e os Encantamentos do
  Caldeirão que fazem a Encruzilhada crescer: candidato para o Vendedor e o hub, a propor na RJ-1).
- "Eu gosto desta profundidade, que deixa o jogo muito rejogável." → critério de sucesso da seção 10.

**Aprovação do Daniel (2026-11-19, noite):** seguir todas as recomendações do `docs/design/rejogabilidade/sistemas.md`
(Q-RJ1 a Q-RJ11: Fatia 1 inteira, três moedas sem a Brasa, os quatro anjos Sarael, Nivael, Lumael e Shomael com auréola
fina sem raios, asas fechadas e rosto encoberto, dois anjos em toda sala de Bênção, primeira melhoria da Forja cedo e
pequena, crédito retroativo de Prata, e o resto como recomendado). **Segurado**: a Fatia 1 só começa depois que ele
testar o exe com o Santuário.

## 11. Ofícios e Descobertas do Santuário (pedido do PO de 2026-11-20): **aguardando aprovação do PO**

Estudo só de planejamento em `docs/design/oficios/` (ler primeiro o `README.md`; diagnóstico do gameplay-engineer,
coleta do room-designer, economia do balance-designer, UX do ui-ux-designer, síntese do game-director). Recomendação:
nenhuma camada paralela nem moeda nova; os Ofícios continuam a Rejogabilidade nas estações que existem (Forjador com a
Oficina, Vendedor com encomendas e Obras, Livro com o capítulo Ofícios). Protótipo: **a Primeira Picareta revista**
(veio preso nas Fendas e Runas depois do guardião, cabeça achada numa sala marcada no mapa com piedade, restaurada por
20 de Prata, Pedra Funda como o único contável novo, o Vendedor abre a 1ª Obra). Épicos e histórias **OF-01 a OF-30**
em `docs/design/oficios/17_backlog.md`; roteiros A, B, C em `18_roadmap.md`; 15 perguntas (Q-OF1 a Q-OF15) em
`22_decisoes_pendentes.md`. **OF-05** (porta de Prata desde a profundidade 4 e de Memória depois do guardião) corrige
um farming medido hoje e pode ser aprovada sozinha. Nada começa sem o Daniel.
