# Backlog de A Selagem

- **Data**: 2026-11-16 (tarde). **Autor**: game-director (terceira revisão). **Commit lido**: `61f591e` (HEAD de `arpg-3d`);
  mudanças desde a revisão anterior: `75e7ada`, `b7f5f4d` (C12a), `fa30024` (backlog), `da35721` e `c666f4a` (inimigos de
  longe com os números do Hades II), `61f591e` (declaração de IA).
- **Fontes novas**: o pedido do Daniel "Ciclo 12: diversidade de arenas" (`docs/design/cycle12_arenas_brief.md`) e as cinco
  imagens em `docs/art/ref/cycle12_maps/` (olhadas uma a uma); o registro das 3 partidas do Daniel de hoje
  (`%APPDATA%\EterraASelagem\runs.jsonl`); leitura do código de `arena.gd`, `floor_shape.gd`, `room_layout.gd`, `run_map.gd`,
  `rooms.gd`, `horde.gd`, `projectiles.gd`, `player.gd`, `bot.gd`, `game.gd`, `cam_frame.gd`, `make_data.gd`.
- **Rodado por mim**: `tools/test.sh` no `61f591e`: **437 de 437** testes passando. Nada do jogo foi mudado.
- Avaliação completa das arenas, com contas de tamanho, câmera, estrutura de dados e testes:
  [`docs/design/cycle12_arenas_plan.md`](design/cycle12_arenas_plan.md). Relatório executivo anterior:
  [`docs/design/game_director_review.md`](design/game_director_review.md).

## Estado do jogo em 5 linhas

1. A Fase 1 é jogável do título à selagem e **o Daniel jogou** (3 partidas hoje, teclado): 1 vitória (luta de 132 s, terminou
   com 10 de vida), 2 mortes, uma na fase 2 e outra na fase 1 entrando na câmara quase sem vida; chegou a Morvath aos 107 a
   113 s com 3 dons nas três.
2. Do teste saiu a mudança dos atiradores (`da35721`, `c666f4a`): mago em rajada que se esconde atrás de colunas, sacerdote
   com a trepadeira que rasteja, besteiro que foge depois do tiro, círculos no chão só de Morvath. **Ninguém jogou essa
   versão**; pelo robô as salas ficaram bem mais difíceis (1 a 2 vitórias em 4 a 6 partidas, chega a Morvath com pouca vida).
3. Todas as salas comuns ainda são **o mesmo salão** (`StageDef.layouts` tem um só); o Daniel pediu arenas variadas. O
   código tem forma de chão em dado (retângulo ou círculo) mas não tem buraco dentro da sala, busca de caminho, linha de
   tiro nem câmera por sala, e os tiros atravessam pilares.
4. Saúde técnica boa: 437 testes passando, câmara a cerca de 4 ms por quadro a 1080p na RTX 5060; desempenho em máquina
   fraca nunca medido.
5. "Derrotado por" está errado no registro de partidas (causa achada, BUG-014); o som continua sintetizado; a descida
   continua curta (5 salas).

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (neste ciclo), P2
(próximo), P3 (depois). **Estado**: aberto, proposta (espera o Daniel), aprovado, feito. Responsáveis: `gameplay-engineer`,
`environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito (fechado com evidência)

### C12a, madrugada de 2026-11-16

| ID | Item | Commit |
|---|---|---|
| BOSS-001 | Centro da tempestade de 121 para 86 de luminância; o miolo do selo escurece com as faixas no chão (mudança a confirmar pelo Daniel) | `b7f5f4d` |
| BOSS-002 | Velas da frente no pontilhado em volta do herói | `b7f5f4d` |
| BOSS-003 | Estrela da vitória sem estouro | `b7f5f4d` |
| QW-006, QW-007, QW-008 | 13 janelas, fio violeta com vão escuro, tampas e friso dos sarcófagos, espada dos estandartes | `b7f5f4d` |
| BUG-010 | Luta começada depois do ritual sem escudo nem dica (testado) | `75e7ada` |
| BUG-011 | Sem névoa volumétrica nem SSR no Compatibility | `b7f5f4d` |
| BUG-012 | `step_ms_avg` e `step_ms_peak` medidos com inimigos de pé | `75e7ada` |
| DT-007, D-24 | Referências de Morvath e as cinco do ciclo 12 declaradas como IA no `docs/steam-ia.md` | `61f591e` |
| T1 | Teste do Daniel: 3 partidas no `runs.jsonl` | dados de 07:41 a 07:48 |

### Depois do teste do Daniel (2026-11-16, manhã)

| Item | Commit | Prova |
|---|---|---|
| Atiradores ficam longe e atiram; círculos no chão só de Morvath; erupções de 4 m | `da35721` | `tests/test_ranged_enemies.gd`; robô 4 de 6 (era 5 de 6) |
| Mago, sacerdote e besteiro com os números do Hades II (rajada, trepadeira, fuga) | `c666f4a` | 437 testes; robô 1 a 2 vitórias em 4 a 6 |

### C10 e C11 (histórico)
BUG-001 a BUG-009, QW-001 a QW-005, ART-001, ART-003 a ART-009, a Câmara do Selo inteira, QA M-1, M-2, B-6, O-4, ART P1,
P3, P5, P6: ver a revisão anterior no histórico do git (`fa30024:docs/backlog.md`).

---

## 1. Bugs

Nenhum crítico: sem crash nem travamento nas 3 partidas do Daniel (144 FPS, `step_ms_peak` de 12 a 47 ms, ver DT-008).

### Alto

#### BUG-014 "Derrotado por" errado no registro e o último golpe fora das métricas do chefe
- **Prioridade**: P0. **Estado**: aberto. **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Evidência**: 3ª partida do Daniel: `defeated_by: enemy_knight` e `last_hurt.enemy: knight` numa morte **dentro da luta
  com Morvath** (fase 1, 26,9 s), com `boss.hurt_by` **vazio** (nenhum golpe da luta registrado, embora ele tenha morrido
  ali). 1ª partida: `enemy_mage` na fase 2.
- **Causa achada no código**: `Game._on_hit_player` (`scripts/game/game.gd:713`) chama `player.hurt()` e só **depois** grava
  `last_hurt` e `boss.record_hurt`. Quando o golpe mata, `Player.hurt` emite `died` na mesma hora
  (`player.gd`, fim de `hurt`), `_on_player_died` (`game.gd:766`) chama `log_run("death")` antes da volta: o registro leva o
  golpe **anterior** (o Cavaleiro era o guardião da sala 3) e o chefe nunca conta o golpe que matou.
- **A conferir**: a tela abre 1,8 s depois, quando `last_hurt` já foi atualizado, então pelo código ela deveria mostrar o
  golpe certo. O Daniel viu "Cavaleiro" na tela; ou a tela também erra por outro caminho, ou o golpe que matou não tinha
  origem. O teste do pronto responde.
- **Impacto**: o registro é o único dado de gente que temos; a tela de derrota mente para o jogador.
- **Pronto quando**: `last_hurt` e `record_hurt` gravados antes de `player.hurt` poder emitir `died` (ou o `died` adiado);
  teste GUT: depois de um golpe do Cavaleiro, matar o herói com cada ataque de Morvath (foice, lâminas, investida,
  erupção, maldição, tempestade) e com um morto invocado: o registro e a tela dizem o golpe certo e `boss.hurt_by` conta o
  golpe final.

### Médio

#### BUG-015 Os tiros atravessam pilares e obeliscos, e o mago se esconde atrás deles
- **Prioridade**: P1 (entra na fundação do C12). **Estado**: aberto. **Esforço**: P. **Responsável**: `gameplay-engineer`.
- **Evidência**: `scripts/game/projectiles.gd` não consulta o cenário (nenhuma referência a `arena`, `pillars` ou `boxes`);
  `Horde.cover_spot` (`c666f4a`) leva o mago para trás do pilar mais perto entre ataques.
- **Impacto**: a cobertura não cobre, nem para ele nem para o herói; contradiz a regra do pedido "cada objeto se comporta
  como parece". Opinião: mudar isso **facilita** as salas (o herói também se esconde); por isso medir junto com o teste dos
  atiradores (QW-011).
- **Pronto quando**: tiro inimigo e do herói morrem com faísca ao tocar pilar, obelisco, estátua ou caixa marcada como
  sólida; teste GUT; a câmara de Morvath não muda (não tem obstáculo).

#### BUG-016 Nascimento e limites que só valem para uma sala retangular centrada
- **Prioridade**: P1 (fundação do C12). **Estado**: aberto, latente (não aparece no salão de hoje). **Esforço**: P.
  **Responsável**: `gameplay-engineer`.
- **Evidência**: `Rooms._spawn_point` (`rooms.gd:207`) sorteia no retângulo `arena.half` e só chama `resolve`; os tiros somem
  fora de `Arena.HALF * 2` em volta da origem (`projectiles.gd:197`).
- **Impacto**: com buraco ou ilha, inimigo nasce onde não se chega; numa sala comprida, tiro some no meio dela.
- **Pronto quando**: nascimento só em zonas da sala com caminho até o herói; limite dos tiros pela caixa da sala real.

### Baixo

| ID | Título | Evidência | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|
| BUG-013 | O comando da investida na especificação nunca dá investida na câmara | QA B-1, `CAPTURAS.md` | P | `art-director` | `boss_chamber_spec.md` seção 9 com `--bot --bot-kite=1` |

---

## 2. Quickwins

| ID | Título | Evidência | Impacto | Esforço | Responsável | Prioridade | Pronto quando |
|---|---|---|---|---|---|---|---|
| QW-011 | Registro de partidas com dano levado por tipo de inimigo e por sala, e vida ao entrar em cada sala | o `runs.jsonl` de hoje só tem `hurt_by` dentro da luta do chefe; não dá para saber qual atirador feriu nas salas, nem com quanta vida ele chegou na câmara (morreu em 26,9 s) | mede os atiradores novos com gente, que é o que decide o balanceamento deles | P | `gameplay-engineer` | P0 | `runs.jsonl` com `rooms: [{depth, layout, hp_in, hurt_by: {mage: n, ...}, time}]`; teste do `RunLog` |
| QW-012 | Teste humano dos atiradores novos (dentro da próxima entrega, sem pedido à parte) | `c666f4a` nunca jogado; robô caiu para 1 a 2 vitórias em 4 a 6 | saber se as salas ficaram justas antes de mexer nelas de novo | P | Daniel; `qa-performance` lê o registro | P1 | 3 partidas no registro com QW-011; pergunta no roteiro: "viu o tiro do mago chegando?", "a trepadeira dá para fugir?" |
| QW-013 | Vida ao entrar na câmara visível na métrica do robô | o robô e o Daniel chegam com pouca vida (2 de 3 partidas morreram na câmara) | separar "Morvath difícil" de "salas difíceis" | P | `qa-performance` | P1 | `METRICAS` com a mediana de vida ao entrar no chefe, robô 0,25, 8 partidas |

---

## 3. Dívidas

### DT-001 A descida curta continua o padrão e distorce o balanceamento
- **Evidência**: `tools/make_data.gd` (`st.rooms = 4`); o Daniel chega a Morvath com 3 dons em 107 a 113 s.
- **Impacto**: Morvath tem 6050 de vida para 6 a 8 dons; com 3, qualquer ajuste sai torto. Com arenas novas, numa descida de
  5 salas só 2 são de luta comum: quase não se veria a variedade.
- **Esforço**: P. **Responsável**: `gameplay-engineer`; decisão do Daniel (D-06, D-27).
- **Pronto quando**: descida de teste com o número de salas que o Daniel escolher; `--short` mantém a de 5.

### DT-002 O robô não mede dificuldade
- Igual à revisão anterior: o robô vence demais com reação 0 e não sabe usar cobertura. Com arenas, ele precisa de caminho
  (C12-F7) ou toda métrica de sala nova fica errada. **Responsável**: `qa-performance`, `gameplay-engineer`.

### DT-003 Desempenho em máquina fraca nunca medido
- Igual; pesa mais com salas grandes (mais peças e luzes). Medir no C12 pelo menos o Compatibility a 1280 x 720 no salão,
  na cripta e na fenda. **Responsável**: `qa-performance`.

### DT-004 Vídeos da luta em 720p, mudos e de antes das correções
- **Evidência**: QA B-2; os vídeos são do `6bab080`. **Esforço**: P. **Responsável**: `gameplay-engineer` (gravar a 1080),
  `qa-performance`. **Pronto quando**: vídeo da luta no HEAD a 1920 x 1080 com som. Fazer junto com os vídeos de travessia
  do C12.

### DT-005 "Resources still in use at exit" continua
- **Esforço**: P. **Responsável**: `gameplay-engineer`. **Pronto quando**: `tools/test.sh` e `tools/smoke.sh` sem a linha.

### DT-006 Vídeo dirigido do bloqueio de corpo
- Parcial desde o C10. Cabe no vídeo de travessia dos corredores da Cripta (C12). **Responsável**: `qa-performance`.

### DT-008 Pico de 47 ms no passo da simulação em partida de gente
- **Evidência**: `step_ms_peak` 46,74 (1ª partida), 24,11 (2ª), 11,95 (3ª) no `runs.jsonl`, com média 0,16 ms.
- **Impacto**: um quadro de 47 ms é um engasgo visível; pode ser a escolha de dom, o carregamento de uma sala ou o primeiro
  uso de um efeito, não necessariamente o passo. Com campo de fluxo (C12) o passo vai pesar mais.
- **Esforço**: P. **Responsável**: `qa-performance` (achar o momento), `gameplay-engineer`.
- **Pronto quando**: o RESULT diz em que momento foi o pico; abaixo de 8 ms fora das trocas de sala.

---

## 4. Arenas variadas (pedido do Daniel de 2026-11-16)

Tudo nesta seção é **proposta**: nenhuma arena está aprovada até o Daniel aprovar o escopo (D-25). Avaliação, contas e
riscos em `docs/design/cycle12_arenas_plan.md`. Evidências de toda arena em `docs/gallery/cycle12_maps/` (sem personagens,
com o Explorador, em combate, o obstáculo principal, entrada e saída, lado a lado com a referência, vídeo de travessia) e
`docs/gallery/cycle12_maps/ART_REVIEW.md`.

### Fundação (entrega 1, antes de qualquer arte)

| ID | Item | Prioridade | Responsável | Justificativa | Aceite | Depende de | Estado |
|---|---|---|---|---|---|---|---|
| C12-F1 | `RoomLayout` estendido: `id`, `size_class`, `difficulty`, `depth`, `max_alive`, `look`, `obstacles`, `spawns`, `exits`, `cam_bounds`, `variants`; tudo gerado pelo `_stage` do `make_data.gd` | P1 | `gameplay-engineer` | conteúdo é dado; reusa o que a câmara já estendeu, sem `ArenaDefinition` paralela | o salão de hoje descrito pelos campos novos sem mudar nada no jogo (smoke igual, capturas iguais) | D-25 | proposta |
| C12-F2 | `FloorShape.POLY`: união de polígonos e buracos, com `contains`, `clamp`, `edge_distance`, `cut`; movimento do herói, da esquiva, dos empurrões e dos inimigos **varrido** (corta o passo na borda) | P1 | `gameplay-engineer` | abismo dentro da sala; o `resolve` de hoje deixaria a esquiva atravessar um vão estreito | teste 2 do plano: 200 posições x 16 direções por buraco, a 60 e a 30 FPS, nunca dentro nem do outro lado | F1 | proposta |
| C12-F3 | `NavGrid` (core, puro): grade de 0,5 m, campo de fluxo até o herói refeito no máximo 4 vezes por segundo, `reachable`, `next_step`, `clear_line`; inimigo anda reto quando a linha está livre e segue o campo quando não está | P1 | `gameplay-engineer` | hoje o inimigo anda reto e fica preso em qualquer fenda; decisão técnica minha: campo de fluxo próprio, não o `NavigationServer2D` (determinístico, testável sem cena, serve ao robô) | testes 1 e 4: nenhuma ilha morta; 64 lutas por arena sem inimigo parado sem caminho por mais de 3 s; `step_ms_peak` abaixo de 2 ms com 8 inimigos | F2 | proposta |
| C12-F4 | Linha de tiro e tiros que param na pedra (inclui BUG-015): obstáculo com `blocks_shots`; atirador só prepara com `clear_line` e anda até ter; ninguém prepara tiro com o corpo fora de 5% a 95% da tela | P1 | `gameplay-engineer` | cobertura real; nada ataca de fora da tela | teste 5 do plano; a câmara de Morvath igual (`test_boss_exits.gd` e `test_boss.gd` passam) | F1, F3 | proposta |
| C12-F5 | Nascimento e saídas em dado (inclui BUG-016): zonas de nascimento, saídas por arena, caminho garantido do início a cada saída e zona | P1 | `gameplay-engineer` | "nenhum inimigo surge em área inacessível", "a saída permanece acessível" | teste 1 em toda arena e variante | F3 | proposta |
| C12-F6 | Câmera por arena: `cam_bounds` para o alvo, `CamFrame.keep` mantém os 18%, sem zoom por sala | P1 | `gameplay-engineer` | salas grandes e compridas pedem que a câmera ande; nada de zoom brusco | vídeo de travessia de ponta a ponta sem salto do alvo (diferença de alvo entre quadros abaixo de 0,5 m a 60 FPS); herói sempre dentro da moldura segura | F1 | proposta |
| C12-F7 | Robô com caminho (`NavGrid`) e métricas por sala: `arena`, `stuck` por inimigo, `shots_blocked`, tempo até o primeiro contato | P1 | `gameplay-engineer` | sem isso as métricas das arenas novas são falsas (DT-002) | robô nunca preso em 64 lutas por arena | F3 | proposta |
| C12-F8 | Escolha da arena: `RunMap._layout()` por profundidade e dificuldade, sem repetir a anterior, com semente; fonte e loja no salão | P1 | `gameplay-engineer` | variedade sem caos; difícil não sai cedo | teste: 1000 descidas com semente, nunca a mesma arena seguida, nenhuma de dificuldade alta antes de 40% da descida | F1 | proposta |
| C12-F9 | Laboratório: `--arena=id --variant=n`, `tools/arena_lab.gd` (vista sem personagens; de cima com a grade de caminho, os buracos e as zonas desenhados; na câmera do jogo) | P1 | `gameplay-engineer`, `qa-performance` | as evidências da seção 16 do pedido e a revisão de arte dependem disso | as seis capturas de cada arena saem por comando | F1 | proposta |

### Arenas da entrega 1 (minha recomendação: 3, cada uma com 2 variantes)

| ID | Arena | Prioridade | Responsável | Justificativa | Aceite | Depende de | Estado |
|---|---|---|---|---|---|---|---|
| C12-A1 | **Cripta dos Esquecidos** (pequena, cerca de 22 x 20 m andáveis; sarcófagos e colunas que bloqueiam tiro, corredores de 3,5 m ou mais, nichos com estátua encapuzada, velas) | P1 | `environment-artist` (cenário), `gameplay-engineer` (obstáculos, teto 4 a 6, no máximo 2 atiradores, sem sacerdote) | a mais barata (todas as peças existem) e a que prova cobertura e linha de tiro | testes 1, 4, 5, 6; capturas da seção 16; revisão do `art-director` sem pendência alta | F1 a F9 | proposta |
| C12-A2 | **Salão das Fendas** (grande, cerca de 40 x 30 m; fenda de 6 a 9 m cortando 60% do chão, 2 pontes de 5 m e uma passagem lateral, borda quebrada, vista do abismo violeta) | P1 | `environment-artist`, `gameplay-engineer` (teto 6 a 8) | prova buracos, caminho e câmera que anda; é o pedido central do Daniel (salas com abismo) | testes 1 a 4 e 6; nenhum vão entre 3 e 6 m sem ponte; vídeo de travessia | F1 a F9 | proposta |
| C12-A3 | **Jardim das Raízes Mortas** (média, cerca de 34 x 28 m; árvore **petrificada** de pedra com tronco de 3,5 m de raio que bloqueia corpo e tiro, 4 a 6 raízes baixas, cristais espectrais só de enfeite, copa no pontilhado em volta do herói) | P1, se a D-30 aceitar | `environment-artist`, `art-director` | obstáculo grande no meio, contornar e usar como cobertura; é a peça de arte mais difícil sem Meshy, por isso vem por último e pode cair | testes 1, 4, 5; herói visível em 100% das posições atrás da copa (captura em grade de 2 m); revisão do `art-director` aprova a árvore lado a lado com a `04` | F1 a F9, D-30 | proposta |
| C12-A0 | **Salão das Catacumbas** (o de hoje, da pintura do Daniel) como uma das arenas: abertura, fonte e loja | P1 | `gameplay-engineer` | é a referência aprovada; continua sendo a sala de dificuldade baixa | descrito por F1 sem mudança visível | F1, D-26 | proposta |

### Arenas das entregas seguintes

| ID | Arena | Entrega | Por que depois | Decisão |
|---|---|---|---|---|
| C14-A4 | Santuário Desmoronado (grande, guardiões, dificuldade baixa a média) | 2 | só obstáculos; é a casa natural do guardião, entra junto com a descida mais longa | |
| C14-A5 | Ponte dos Condenados (comprida, 2 plataformas de 16 m, ponte de 5 m, ninguém nasce na ponte, 3 a 5 por plataforma) | 2 | reaproveita os buracos da fenda; risco alto de bloqueio injusto e de câmera; precisa da entrega 1 validada | |
| C14-A6 | Câmara das Runas Instáveis (média, perigo de chão periódico, no máximo 25% do chão ao mesmo tempo, desenhado por baixo dos avisos dos inimigos) | 2 | único sistema novo de perigo; dificuldade alta; círculos no chão são só de Morvath desde `da35721` | D-29 |
| C16-A7 | Biblioteca Sepultada (em L, estantes destrutíveis que abrem passagem e mudam o caminho) | 3 | pede destrutíveis com caminho recalculado e estantes que não existem no kit | D-32 |
| C16-A8 | Reservatório das Almas (ilhas e água rasa que desacelera) | 3 | terreno que desacelera é a mesma sensação da maldição de Morvath (30% mais lento); água não existe no kit | D-31 |

---

## 5. Próximos ciclos

Ordem recomendada: **C12a2 "Medir certo"** (horas, já) → **C12 "Arenas I"** (fundação e 3 arenas) → **T2, teste do Daniel**
(a entrega inteira, com os atiradores) → **C13 "Progressão do Hades"** (descida inteira, romã, raridade, loja) → **C14
"Arenas II"** → **C15 "Som"** → **C16 "Steam"** (e as arenas da entrega 3 quando couberem). Mudança em relação à revisão
anterior: o antigo C12 "Combate do Hades por inteiro" vira C13 e cede a vez às arenas, porque o Daniel pediu as arenas
agora e porque o teste dos atiradores precisa ser lido antes de mexer em economia. O som cai mais uma posição; opinião: é a
maior distância para o Ember & Blade que nunca foi medida, não deve passar do C15.

### C12a2 "Medir certo" (poucas horas, sem pedir teste)
- **Objetivo**: o próximo teste de gente responder o que precisamos saber.
- **Por que agora**: o registro de hoje está errado no "Derrotado por" e não diz qual atirador fere nem com quanta vida o
  jogador chega no chefe.
- **Entregas**: BUG-014, QW-011, QW-013, DT-008 (achar o momento do pico).
- **Aceite**: os critérios de cada item; 437 testes ou mais passando.
- **Responsáveis**: `gameplay-engineer`, `qa-performance`. **Riscos**: nenhum relevante.

### C12 "Arenas I": fundação e três arenas
- **Objetivo**: a descida passar por salas de forma, tamanho e cobertura diferentes, sem nenhum inimigo ou herói preso.
- **Por que agora**: pedido do Daniel; e o combate espacial (cobertura, contornar, linha de tiro) é a próxima camada de
  combate depois dos atiradores, que já usam cobertura.
- **Entregas**: C12-F1 a F9, C12-A0 a A3, a descida de teste escolhida na D-27, DT-004 junto com os vídeos de travessia,
  DT-003 medido no Compatibility.
- **Aceite**: todos os critérios das tabelas da seção 4; 64 lutas do robô 0,25 por arena sem preso; partida inteira do
  robô 0,25 com a descida de teste entre 3 e 6 vitórias em 8; quadro a 1080p na RTX 5060 até 6 ms por arena; tempo até
  Morvath do robô entre 3 e 5 min na descida de teste.
- **Evidências**: `docs/gallery/cycle12_maps/` (seis capturas e um vídeo por arena), `ART_REVIEW.md` do `art-director`,
  `docs/qa/latest_report.md` com os testes 1 a 7 do plano.
- **Responsáveis**: `gameplay-engineer` (F1 a F9, encontros), `environment-artist` (A1 a A3), `art-director` (spec de cada
  arena antes de construir e revisão depois), `ui-ux-designer` (leitura das bordas do abismo e das saídas; regra de que
  nada de cenário cobre aviso), `qa-performance` (testes, medidas, capturas).
- **Ordem dentro do ciclo**: F1 a F9 com testes e uma sala cinza de prova; depois a Cripta; depois a Fendas; por último o
  Jardim. Paralelo possível: o `art-director` escreve as specs das três enquanto a fundação é feita.
- **Riscos**: navegação (o maior); esquiva atravessando vão; a cobertura facilitar as salas ao mesmo tempo em que os
  atiradores as dificultaram (medida misturada: por isso o QW-011 vem antes); árvore sem Meshy; desempenho em sala grande.
  Detalhes e mitigação no plano, seção 8.

### T2 Teste do Daniel (a entrega inteira)
- 3 partidas com o registro novo; perguntas: as salas parecem lugares diferentes? ficou preso ou viu inimigo preso? a fenda
  e a cobertura mudaram como você luta? os atiradores são justos? quanto durou até Morvath?
- Depois dele, o teste com três pessoas da revisão anterior (D-13).

### C13 "Progressão do Hades" (o antigo C12)
- **Objetivo**: chegar a Morvath com 5 a 8 dons, com a progressão de dons do Hades II.
- **Entregas**: DT-001 (descida inteira), baralho de recompensas, romã por nível, loja em 3 grupos, ouro por inimigo, D-09 e
  D-10 decididos com o registro; arenas distribuídas pela descida inteira (plano, seção 6).
- **Aceite**: robô chega com 5 a 8 dons em 8 partidas; partida inteira entre 10 e 13 min; robô 0,25 entre 4 e 7 vitórias
  em 8. **Responsáveis**: `gameplay-engineer`, `ui-ux-designer`, `qa-performance`.

### C14 "Arenas II"
- Santuário, Ponte e Runas (com a D-29), terceira variante das arenas do C12. Mesmos testes e evidências.

### C15 "Som" e C16 "Steam"
- Como na revisão anterior: ART-002 (som de combate e música, D-12), ART-010, ART-011; depois controle com ícones, opções de
  vídeo, save robusto, DT-003 nas metas da Steam, D-07, D-13; Biblioteca e Reservatório se o Daniel quiser antes do lançamento.

### Itens de arte que seguem abertos

| ID | Título | Esforço | Responsável | Quando |
|---|---|---|---|---|
| ART-002 | Som de combate e música | G | `art-director`, Daniel (fonte) | C15 |
| ART-010 | Peças definitivas (estátuas, sarcófagos, porta em relevo, foice de Morvath; árvore se a D-30 pedir Meshy) | M | `art-director`, `environment-artist`; Daniel autoriza créditos | C15 |
| ART-011 | Gancho amarelo de Morvath e ouro das elites por repintura | P | Daniel | C15 |
| QW-009, QW-010 | Coroa da fachada fora do quadro; medir a `02` contra a planta | P | `art-director` | quando sobrar |

---

## 6. Decisões do Daniel

### Novas (arenas, 2026-11-16)

| ID | Pergunta | Opções | Minha recomendação | Estado |
|---|---|---|---|---|
| D-25 | Escopo da primeira entrega das arenas | (a) as 4 que você sugeriu (Fendas, Jardim, Cripta, Runas); (b) 3: Cripta, Fendas, Jardim, com Runas na 2ª; (c) só Cripta e Fendas | **(b)**. Runas é a única que pede um sistema novo de perigo, é difícil (sairia tarde na descida de teste) e esbarra na regra de hoje dos círculos no chão. Se a árvore não ficar boa sem Meshy, cai para (c) | pendente |
| D-26 | O Salão das Catacumbas (a sua pintura) continua como uma das arenas? | sim: abertura, fonte e loja; sim, só fonte e loja; não | **Sim, abertura, fonte e loja** | pendente |
| D-27 | Tamanho da descida de teste da próxima entrega | 5 salas como hoje (só 2 lutas comuns: quase não se vê a variedade); 7 salas (3 lutas, fonte, guardião, loja, Morvath; cerca de 4 a 5 min até o chefe); a inteira (10 e Morvath na 11) | **7 salas** no teste; a inteira no C13 | pendente |
| D-28 | Golpe que empurra um inimigo para o abismo | ele para na borda; ele cai e morre (novo, muda o combate) | **Para na borda** nesta entrega; cair pode ser um dom depois, decisão sua | pendente |
| D-29 | Forma das runas instáveis (entrega 2) | círculos (quebra a regra de hoje: círculo no chão é só de Morvath); faixas e ladrilhos ao longo das inscrições do chão, vermelho translúcido com runa | **Faixas e ladrilhos**, nunca círculo | pendente |
| D-30 | A árvore do Jardim | petrificada, de pedra, feita no código (sem créditos); árvore viva pelo Meshy (créditos, depois do C12); tirar o Jardim | **Petrificada, de pedra**; se a revisão de arte reprovar, sai da entrega 1. Sem texto nem história sobre ela: o cânone não tem árvore nas catacumbas | pendente |
| D-31 | Água rasa que desacelera (Reservatório, entrega 3) | desacelera herói e inimigos; só enfeite | **Decidir depois do T2**: a lentidão já é a marca da maldição de Morvath | pendente |
| D-32 | Destrutíveis que abrem passagem (Biblioteca, entrega 3) | sim; não, só cobertura que quebra | **Depois do T2** | pendente |
| D-33 | Nomes das arenas aparecem para o jogador ao entrar? | sim, por 2 s, como o nome das fases de Morvath; não | **Sim**, com os nomes que você deu (Cripta dos Esquecidos etc.); nenhum texto de história sobre elas | pendente |

### Tomadas pela sessão na noite de 2026-11-16 (a confirmar; o Daniel ainda não respondeu)

| ID | Decisão tomada | Onde está | Recomendação |
|---|---|---|---|
| D-08 | Quadro P&B só em Ômega acertado e quebra de fase, 1 a cada 10 s, com opção | `dcf6632`, `196f33c` | Confirmar |
| D-14 | Na luta, a porta selada no lugar do portal vermelho | `482eb6f` | Confirmar |
| D-15 | Salas comuns no salão, só Morvath na câmara | `6b16045` | Confirmar a câmara só dele (o pedido das arenas já confirma); a primeira metade muda com as arenas |
| D-16 | Selo com o leão de pé (patas de trás) | `482eb6f` | Confirmar |
| D-17 | Espada erguida no lugar da cruz | `482eb6f`, `00dd13b` | Confirmar |
| D-18 | Raio de 12,5 m | `boss_arena.md` | Confirmar |
| D-20 | Morvath vai ao centro nas fases 3 e 4 | `6b16045` | Confirmar |
| D-21, D-22 | "A Câmara do Selo"; tela de fim sem nível | `6801e87` | Confirmar |
| C12a | O miolo do selo escurece com as faixas da tempestade | `b7f5f4d` | Confirmar |
| D-06 | Descida curta mantida | `make_data.gd` | Trocar pela D-27 |

### Abertas de antes

| ID | Pergunta | Recomendação |
|---|---|---|
| D-23 | O que é a porta selada e o véu de runas | O Daniel (2026-11-16): pendente na história; sem texto até o cânone ter |
| D-11 | Meta de dificuldade da primeira vitória | Até 3 tentativas para quem jogou Hades, com a descida inteira; hoje: 1 vitória em 3 com 3 dons |
| D-09 | Magia na luta do chefe | O Daniel usou 2 a 6 Ômegas por partida; decidir no C13 |
| D-10 | Bônus de sequência (não existe no Hades II) | Tirar no C13 se ele não sentir falta |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" ou "o Lich-Rei do Sul" (cânone) |
| D-02, D-04 | Quem sela Morvath; nomes dos paladinos | Seguir o cânone de 12/11; nomes depois |
| D-05 | Créditos do Meshy (546) | Nada no C12 (regra do pedido); peças definitivas no C15 |
| D-07, D-12, D-13 | Entre partidas; origem do som; executável para testadores | Como antes |
| D-03 | Imagens da Hécate | Desistir |
