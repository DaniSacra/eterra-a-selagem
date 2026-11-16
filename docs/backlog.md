# Backlog de A Selagem

- **Data**: 2026-11-16 (manhã). **Autor**: game-director (segunda revisão). **Commit lido**: `552b55c` (HEAD de
  `arpg-3d`); ciclos lidos: C10 e C11, `6dbcec5..552b55c` (12 commits, feitos durante a noite).
- **Fontes**: `CLAUDE.md`, `git log` e as mensagens de cada commit, `docs/qa/latest_report.md` (testado no `6bab080`),
  `docs/gallery/boss_arena/` (ART_REVIEW escrito antes do `552b55c`, CAPTURAS, METRICAS, capturas 01 a 11 e as montagens,
  olhadas), `docs/gallery/cycle10/`, `docs/gallery/README.md`, `docs/design/boss_arena.md`, `docs/art/boss_chamber_spec.md`.
- **Medidas minhas** nesta revisão (mediana de recortes das capturas refeitas no `552b55c`, luminância Rec. 709, pelo
  ffmpeg; nada no jogo foi mudado nem rodado): centro da tempestade em `09` (recorte 200 x 120 em 860, 470) luminância
  **121**, R 229 (antes do `552b55c`: 123, R 252; pixels acima de 200 caíram de 9,3% para 2,7%); chão do meio em `01`
  luminância **41 a 45**, B menos R de 29 a 33 (antes 16 a 19); topo do céu em `01` R 1, G 30, B 76; estrela da vitória em
  `10` (60 x 60 no centro) com **24,7%** dos pixels acima de 200; corpo de Morvath em `11` (geada, Ômega acabando de
  passar) luminância 87, R 102, G 82, B 98.
- Relatório executivo com o roteiro do teste de hoje: [`docs/design/game_director_review.md`](design/game_director_review.md),
  seção "Atualização de 2026-11-16 (C10 e C11)".

## Estado do jogo em 5 linhas

1. A Fase 1 é jogável do título à selagem; Morvath agora luta na **Câmara do Selo** (círculo de 12,5 m sobre o abismo, selo
   de ouro com o leão de pé, porta selada ao norte, cinco estados do selo); as salas comuns continuam no salão.
2. O C10 limpou o que a direção proibia: quadro P&B raro (4 em 125 s, 0 com a opção desligada), escudo, orbe e golpe final
   sem branco, ritual que cai com os 4 primeiros mortos, opções de conforto, "Derrotado por" e registro de partidas.
3. Saúde técnica boa: 413 de 413 testes, 0 arriscados, 0 erros em 368 simulações, câmara a cerca de 4 ms por quadro a
   1080p (1 ms mais leve que o salão); robô nunca preso em 136 lutas.
4. Pela simulação, a câmara deixou a luta mais fácil para o robô com reação humana (57 de 64 contra 43 de 64 no salão);
   as mortes se concentram na fase 4 (tempestade, maldição) e nos mortos; **ninguém jogou ainda**.
5. Pendências visuais que restam são de leitura fina (centro da tempestade, velas sobre o herói, estrela da vitória) e de
   fidelidade à pintura; o som continua sintetizado e a descida continua curta (5 salas).

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). Responsáveis: `gameplay-engineer`, `environment-artist`,
`ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito nos ciclos C10 e C11 (fechado com evidência)

| ID | Item | Commit | Prova |
|---|---|---|---|
| BUG-001 | Quadro P&B só em Ômega acertado e quebra de fase, no máximo 1 a cada 10 s, opção "Clarões de impacto" | `dcf6632`, `196f33c` | `cycle10/folha_quadros_2min.jpg` (4 em 125 s), `folha_quadros_pb_ligado_desligado.jpg` (0), `test_impact_frame.gd` |
| BUG-002 | O escudo cai com os 4 primeiros mortos; reforços não contam | `dcf6632` | ritual mediano 10,8 s nas partidas inteiras (meta abaixo de 15) |
| BUG-003 | Brilho de antecipação dos finalizadores ligado e testado | `dcf6632` | QA: 0 arriscados, `test_only_finishers_glint` passa de verdade |
| BUG-004 | Morvath escurece no golpe final | `dcf6632` | `cycle10/golpe_final_sem_branco.jpg` |
| BUG-005 | Escudo do ritual sem pontos brancos | `8a8fed2` | `cycle10/escudo_ritual_zoom.jpg` |
| BUG-006 | Orbe do feiticeiro com cor, sem miolo branco | `8a8fed2` | `cycle10/orbe_feiticeiro_zoom.jpg` |
| BUG-007 | Tingido de dano só nas bordas, curto, violeta amaldiçoado | `196f33c` | `cycle10/golpe_sofrido_comum.jpg`, `_amaldicoado.jpg` |
| BUG-008 | Sem "Novo melhor tempo" sem save | `196f33c`, `dcf6632` | QA seção 1 |
| BUG-009 | Métrica do ritual guardada na morte | `dcf6632` | `METRICAS.md` (ritual nas derrotas) |
| QW-001 | Registro de partidas em `user://runs.jsonl` | `dcf6632` | `cycle10/runs_exemplo.jsonl` |
| QW-002 | Opções de conforto (tremor, clarões, câmera lenta, separação de cores) | `196f33c` | `cycle10/opcoes.jpg`, `test_comfort_ui.gd` |
| QW-003 | "Derrotado por" na derrota | `196f33c` | `cycle10/derrotado_por.jpg` |
| QW-004 | `--bot-kite`: investida em 72 de 72 lutas da câmara | `dcf6632` | `METRICAS.md` |
| QW-005 | Contador do ritual em losangos, "Derrube os mortos" | `196f33c` | `cycle10/contador_ritual.jpg`, `05` |
| ART-001 | Avisos de Morvath assinados (miolo 0,35, aro, runas, ordem da tempestade) | `6b16045`, `552b55c` (erupções) | `03`, `04`, `07`; resta P8 e o centro da tempestade (BOSS-001) |
| ART-003 | Portal vermelho fora da luta de Morvath (porta selada na câmara) | `482eb6f` | `01`; nas salas comuns segue a D-14 |
| ART-004 | Colunas sobre Morvath apagadas e limitadas (Lança de Luz, geada) | `dcf6632`, `552b55c` | `11_geada_golpe_forte.jpg`; falta vídeo novo (DT-004) |
| ART-005 | Cortina espectral na borda do escudo no lugar do feixe branco | `8a8fed2` | `before_after_ritual.jpg` |
| ART-006 | Verde corrompido mais frio e escuro que o da Emeth | `8a8fed2` | `cycle10/fase4_clima.jpg` |
| ART-007 | Queimadura em brasas, sem corpo branco (também em Morvath) | `8a8fed2`, `00dd13b` | `cycle10/queimadura_fogo_t7`, `_t12`; `work/fix_m1_*_depois` |
| ART-008 | Fase 4 com clima próprio, restaurado na selagem | `8a8fed2`, `6bab080` | `cycle10/fase4_clima.jpg`, `selo_estados.jpg` |
| ART-009 | Pontos de luz cor de marfim atrás do herói | `dcf6632` | mensagem do commit; sem captura dedicada |
| C11 | Câmara do Selo inteira (chão de 12,5 m em dado, avisos recortados, câmera fixa, cinco estados, testes de saída 12 x 12) | `6b16045`, `482eb6f`, `6bab080`, `00dd13b`, `552b55c` | QA seção 5 (C11 todos SIM), `test_boss_exits.gd`, `selo_estados.jpg` |
| QA M-1 | Morvath branco queimando | `00dd13b` | ART_REVIEW seção 6 |
| QA M-2 | Herói "sobre" o sarcófago leste | `00dd13b` | `work/fix_m2_e12_depois`; as velas do sul seguem abertas (BOSS-002) |
| QA B-6, O-4 | Tela de fim sem "Nível"; a sala chama "A Câmara do Selo" | `6801e87` | `data/text_pt.tres:226` |
| ART P1 | Chão da câmara mais claro | `552b55c` | `01`: luminância 41 a 45, B menos R cerca de 30 (meta 40 a 55 e 25 a 45) |
| ART P3 | Capturas oficiais refeitas no código final | `552b55c` | `CAPTURAS.md`; os dois vídeos continuam do `6bab080` (DT-004) |
| ART P5 | Erupções com o miolo vermelho | `552b55c` | `07_erupcoes.jpg` (miolo vermelho dentro das runas, olhado) |
| ART P6 (céu) | Céu azul-marinho no topo | `552b55c` | `01`: B menos R 75, G menos R 29 (meta 50 e 20) |
| D-19 | Mortos do ritual atravessáveis | não precisou | 0 lutas presas em 136; reabrir só se o teste humano pedir |

---

## 1. Bugs

Nenhum crítico nem alto confirmado: sem crash, sem travamento, sem regra que impeça vencer (QA, 368 simulações e 9
partidas de regressão). O que segue é médio ou baixo.

### Médio

#### BOSS-001 Centro da tempestade ainda rosa claro (P2 do ART_REVIEW, só parte resolvida)
- **Evidência**: `09_tempestade_seis_almas.jpg` refeita no `552b55c`; medida minha: luminância **121** no recorte 200 x 120
  do centro (meta do ART_REVIEW: até 90), R 229; os pixels quase brancos caíram de 9,3% para 2,7%. As faixas agora não se
  somam (cada uma na sua cunha, `test_storm_wedge.gd`), mas o miolo de cada faixa ficou mais claro junto com o chão (fora
  do centro, R 162 a 164, luminância 87 a 97, contra 62 antes). O que sobra no centro é o encontro das seis cunhas com o
  aro marfim do círculo do herói (`09`: o aro passa exatamente ali).
- **Impacto**: os pontos de ordem se contam agora (olhei: as fileiras de pontos brancos aparecem nas raízes), mas o centro
  é a forma mais clara da tela durante o aviso mais perigoso da luta, e é ali que Morvath está. Opinião minha: as seis
  faixas estão perto do vermelho opaco, não do "vermelho translúcido" da direção; com o chão mais claro, o miolo de 0,35
  deveria baixar junto.
- **Esforço**: P. **Responsável**: `environment-artist` (`ground.gdshader`, `GroundLook`).
- **Pronto quando**: em `09` o recorte do centro (860, 470, 200 x 120) com luminância até 90 e o meio de uma faixa com as
  juntas do chão visíveis (luminância de 60 a 80); os pontos de ordem contáveis; o aviso da foice e da investida sem
  mudança de leitura (`03`, `04`).

#### BOSS-002 Velas da balaustrada sul desenhadas sobre as pernas do herói (P7)
- **Evidência**: `borda_e_camera.jpg`, quadro "herói em (8.5,8.5)": as chamas e os tocos das velas cobrem as pernas dele;
  QA M-2 (parte das velas não foi coberta pelo `00dd13b`).
- **Impacto**: herói legível na borda sul, onde ele mais foge (é a borda mais perto da câmera); lê como se pisasse nas velas.
- **Esforço**: P. **Responsável**: `environment-artist` (`boss_chamber.gd`).
- **Pronto quando**: `--no-boss --hero-at=8.5,8.5` mostra as pernas inteiras (velas no pontilhado em volta do herói, como a
  balaustrada) e o mesmo em `0,12` e `12,0`.

#### BOSS-003 Estrela da vitória estoura em branco dourado (P9)
- **Evidência**: `10_vitoria_selagem.jpg`; medida minha: 24,7% dos pixels acima de 200 num recorte de 60 x 60 no centro do
  selo; ART_REVIEW critério 7 (PARCIAL).
- **Impacto**: é o quadro que fecha a luta; a regra é "nada de clarão branco". Pequeno na tela, mas é o último que se vê.
- **Esforço**: P. **Responsável**: `environment-artist`.
- **Pronto quando**: miolo da estrela com máximo 1,0 (abaixo do limiar do glow); no mesmo recorte, menos de 5% acima de 200.

### Baixo

| ID | Título | Evidência | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|
| BUG-010 | Dica do ritual sem ritual com `--boss-hp` (só ferramenta) | QA do ciclo 9, B5; nenhum commit do C10 cita | P | `gameplay-engineer` | com `--boss-hp` abaixo de 0,66 o ritual roda ou a dica não aparece |
| BUG-011 | Névoa volumétrica e SSR ligadas no Compatibility (só aviso no log) | QA B-5, `game.gd:244` e `:255` | P | `environment-artist` | log do `--rendering-driver opengl3` sem os dois avisos |
| BUG-012 | `step_ms` do `RESULT` lido no fim, com a sala limpa | QA B-3 | P | `gameplay-engineer` | `RESULT` com o pico e a média enquanto há inimigos de pé |
| BUG-013 | O comando do antes e depois da investida na especificação nunca dá investida na câmara | QA B-1, `CAPTURAS.md` | P | `art-director` | `boss_chamber_spec.md` seção 9 com `--bot --bot-kite=1` |

---

## 2. Quickwins

Fazer **depois** da partida do Daniel, junto com o que ele anotar (regra das versões completas: nada de pedir outro teste
por isso).

| ID | Título | Evidência | Impacto | Esforço | Responsável | Pronto quando |
|---|---|---|---|---|---|---|
| QW-006 | Janelinhas do anel distante: 10 a 20, lendo como janelas | `01`: contei 8 retângulos quentes (a sessão contou 7; meta do P6, 10 a 20); opinião minha: os de x 45 e x 228 flutuam sobre a bruma como cartões, sem parede atrás | fundo da pintura (o anel de arcadas) | P | `environment-artist` | `01` com 10 a 20 janelas, cada uma sobre uma silhueta de arcada |
| QW-007 | Fio violeta dos avisos visível (P8) | ART_REVIEW critério 11 (b) | assinatura "de Morvath" | P | `environment-artist` | fio de 2 px com `Boss.VIOLET` x 0,8 visível em `03` a 200% |
| QW-008 | Sarcófagos oeste e espada dos estandartes (P11) | ART_REVIEW seção 2; `01` | fidelidade e símbolos | P | `environment-artist` | sarcófagos com tampa mais clara e friso a 1080; espada de 1,2 m nos estandartes |
| QW-009 | Coroa da fachada fora do quadro na câmera de luta | ART_REVIEW seção 2 (estandartes e pináculo cortados); `01` | monumentalidade (opinião minha) | P | `art-director` decide se aceita | decisão registrada no `boss_chamber_spec.md` |
| QW-010 | Medir os marcos da `02` contra a planta (P10) | ART_REVIEW critério 2, NÃO MEDIDO | fidelidade comprovada | P | `art-director` | tabela de desvios em px no `ART_REVIEW` |

---

## 3. Dívidas

### DT-001 A descida curta continua o padrão e distorce todo balanceamento
- **Evidência**: `tools/make_data.gd:348-350` (`st.rooms = 4`, `elite_from_depth = 2`); a sessão manteve a D-06 curta;
  nas partidas inteiras com reação 0,25 o robô chega com 1 a 3 dons e vence 4 de 8 na câmara (`METRICAS.md`).
- **Impacto**: Morvath tem os números da chefe do Hades II (6050 de vida) para 6 a 8 dons; qualquer ajuste feito agora,
  com 2 dons, sai errado. Para o teste de hoje a curta é boa (partida de 5 min); para o C12 não.
- **Esforço**: P. **Responsável**: `gameplay-engineer`; decisão do Daniel (D-06).
- **Pronto quando**: `--short` mantém a descida de teste; o padrão volta às 10 salas e o chefe na 11; 8 partidas do robô
  chegando com 5 a 8 dons.

### DT-002 O robô não mede dificuldade (a câmara pode ter ficado fácil)
- **Evidência**: reação 0 vence 32 de 32; investida em todas as 72 lutas com afastamento e **nunca acertou** o robô; a
  câmara subiu de 43 para 57 vitórias em 64 com reação 0,25 (`METRICAS.md`). Duração nas vitórias de 92 a 162 s (meta de
  2 a 4 min na D-11).
- **Impacto**: o robô diz "mais fácil", gente pode achar o contrário (sem cantos para descansar, a câmara põe tudo perto).
  Só a coluna de gente responde. Nenhuma mudança de vida ou dano de Morvath antes dela.
- **Esforço**: M. **Responsável**: `qa-performance` (planilha com três colunas: robô 0, robô 0,25, gente pelo `runs.jsonl`).

### DT-003 Desempenho em máquina fraca nunca medido
- **Evidência**: QA seção 3 ("Não medido: celular, placa fraca, navegador com números"); só a RTX 5060 medida.
- **Esforço**: M. **Responsável**: `qa-performance`.
- **Pronto quando**: uma rodada no Compatibility e uma em 1280 x 720 com escala 0,67 nas três cenas; meta de 60 FPS escrita
  para os requisitos mínimos da Steam.

### DT-004 Vídeos em 720p, mudos e de antes das correções
- **Evidência**: QA B-2, `CAPTURAS.md` ("Saiu em 1280 x 720"); os dois vídeos da luta são do `6bab080`, antes do `00dd13b`
  e do `552b55c` (Morvath clareando, coluna de geada, tempestade antiga).
- **Esforço**: P. **Responsável**: `gameplay-engineer` (opção de gravação a 1080), `qa-performance` (regravar).
- **Pronto quando**: um vídeo da luta no HEAD, 1920 x 1080, com som; nenhum quadro com Morvath coberto de branco.

### DT-005 "Resources still in use at exit" continua
- **Evidência**: o `dcf6632` tirou o vazamento de ObjectDB; o QA ainda vê "resources still in use at exit" em toda execução.
- **Esforço**: P. **Responsável**: `gameplay-engineer`. **Pronto quando**: `tools/test.sh` e `tools/smoke.sh` sem a linha.

### DT-006 Vídeo dirigido do bloqueio de corpo (REG-001, parcial)
- **Evidência**: `cycle10/bloqueio_de_corpo.mp4` é o robô lutando cercado, não um andar dirigido (QA C10, B-4). O risco de
  ficar preso foi medido (0 em 136 lutas), a sensação não.
- **Esforço**: P. **Responsável**: `gameplay-engineer` (`--walk-to`, `--stress-line`), `qa-performance` (vídeo); Daniel (sensação, hoje).

### DT-007 `docs/steam-ia.md` com a origem das referências de Morvath em aberto
- **Evidência**: `docs/steam-ia.md:8` ("A confirmar com o Daniel se também são de IA: as quatro imagens de Morvath").
- **Esforço**: P. **Responsável**: a sessão principal, com a resposta do Daniel (D-24).

---

## 4. Próximos ciclos

Ordem recomendada (confirmo a da sessão, com um ajuste): **T1, teste do Daniel hoje** (sem mexer em nada antes) →
**C12a "Fechar a Câmara e ouvir o teste"** (poucas horas a 1 dia: o que o Daniel anotar mais BOSS-001 a 003 e o vídeo
novo) → **C12 "Combate do Hades por inteiro"** (com a descida inteira) → **T2, teste com três pessoas** → **C13 "Som"** →
**C14 "Steam"**. O ajuste: separar um C12a pequeno, porque o C12 é grande e mexe na economia; misturar os retoques da
câmara nele atrasaria as duas coisas e confundiria a medida.

### T1 Teste do Daniel (hoje)
- **Objetivo**: a primeira coluna de gente na luta nova, com registro.
- **Por que agora**: tudo o que o C10 e o C11 pediam está pronto; o robô não responde se é divertido nem se é justo.
- **Entregas**: o Daniel joga 3 partidas no build de Windows da pasta de teste (há um `ASelagem.exe` de 01:55 em
  `C:\Users\danie\ASelagem-teste`, mesma hora do `552b55c`; a sessão confirma que é o HEAD e copia também para
  `Downloads\ASelagem-3D`), com o roteiro do relatório executivo; o `runs.jsonl` fica em
  `%APPDATA%\EterraASelagem\runs.jsonl`.
- **Aceite**: 3 linhas no `runs.jsonl`; respostas às perguntas do roteiro; decisões da seção 5 confirmadas ou trocadas.
- **Responsáveis**: Daniel; `qa-performance` lê o `runs.jsonl` e soma à planilha.
- **Riscos**: o Windows dele bloqueia o executável sem assinatura (Smart App Control; memória do projeto).

### C12a "Fechar a Câmara e ouvir o teste"
- **Objetivo**: corrigir o que o Daniel viu e fechar as três pendências de leitura da câmara.
- **Por que agora**: são horas; deixam a luta pronta para mostrar a outras pessoas (o ART_REVIEW pede P1 a P3 antes disso).
- **Entregas**: BOSS-001, BOSS-002, BOSS-003, QW-006 a QW-008, DT-004 (vídeo novo a 1080 com som), a lista do Daniel.
- **Aceite**: os critérios de cada item; `tools/test.sh` 0 falhas e 0 arriscados; 64 lutas do robô sem queda de vitórias
  acima de 4 em 64 contra o `METRICAS.md` atual (nada de balanceamento aqui).
- **Evidências**: `09`, `10`, `borda_e_camera`, `01` refeitas; vídeo novo; revisão curta do `art-director`.
- **Responsáveis**: `environment-artist`, `gameplay-engineer` (gravação), `qa-performance`, `art-director`.
- **Riscos**: crescer com pedidos novos do Daniel; o que for sistema novo vai para o C12.

### C12 "Combate do Hades por inteiro": descida, economia, romã e raridade
- **Objetivo**: a partida ter a progressão de dons do Hades II e o jogador chegar a Morvath com 5 a 8 dons.
- **Por que agora**: o C11 resolveu a arena; o que mais pesa na luta hoje é chegar com 1 a 3 dons (DT-001), e a escolha de
  dons é rasa sem raridade em sequência, romã e loja do Hades (`docs/design/hades2_sistemas.md`, itens 1 a 3).
- **Entregas**: DT-001 (descida inteira com `--short`); baralho de recompensas, romã por nível, loja em 3 grupos, ouro por
  inimigo; D-09 e D-10 decididos com o `runs.jsonl`; ajuste de Morvath só se a coluna de gente pedir (D-11).
- **Aceite**: robô chega com 5 a 8 dons em 8 partidas; nenhuma sala comum acima de 8 de pé; 32 dons em `base` e
  `per_level` com teste de cada Elo; partida inteira do robô 0,25 entre 4 e 7 vitórias em 8.
- **Evidências**: `METRICAS` com a coluna de gente; capturas de loja, romã e carta; relatório de QA.
- **Responsáveis**: `gameplay-engineer`, `ui-ux-designer`, `qa-performance`.
- **Riscos**: mexer nos 32 dons quebrar Elos; a partida passar de 12 min e cansar o teste (manter `--short` para teste).

### T2 Teste com três pessoas (depois do C12)
- Protocolo da seção 8 do relatório executivo (quem já jogou Hades, quem nunca jogou, quem joga de controle). Requer a
  D-13 (executável para estranhos).

### C13 "Som e acabamento"
- **Objetivo**: golpes e a luta com som de verdade; peças definitivas se a D-05 liberar.
- **Por que nessa ordem**: o "peso" do golpe é a maior distância para o Ember & Blade que nunca foi medida; nenhum vídeo tem
  som. Entregas: ART-002 (fonte decidida na D-12), ART-010, ART-011, QW-009. Aceite: o Daniel diz de olhos fechados qual
  ataque de Morvath vem em 7 de 8; vídeo de 2 min a 1080 com som; `docs/steam-ia.md` em dia.
- **Responsáveis**: `art-director`, `environment-artist`, `gameplay-engineer`, `qa-performance`.

### C14 "Caminho da Steam"
- Como antes: controle físico com ícones, opções de vídeo, save robusto, DT-003, a menor meta progressão (D-07),
  executável assinado (D-13). Aceite: fluxo inteiro só no controle verificado por gente; 60 FPS no preset baixo.

### Itens de arte que seguem abertos

| ID | Título | Esforço | Responsável | Quando |
|---|---|---|---|---|
| ART-002 | Som de combate e música | G | `art-director`, Daniel (fonte) | C13 |
| ART-010 | Peças definitivas (estátuas, sarcófagos, porta em relevo, foice de Morvath; P14) | M | `art-director`, `environment-artist`; Daniel autoriza créditos | C13 |
| ART-011 | Gancho amarelo de Morvath e ouro das elites por repintura | P | Daniel | C13 |

---

## 5. Decisões do Daniel

### Tomadas pela sessão durante a noite (reversíveis; a confirmar pelo Daniel)

| ID | Decisão tomada | Onde está | Minha recomendação |
|---|---|---|---|
| D-08 | Quadro P&B só em Ômega acertado e quebra de fase, no máximo 1 a cada 10 s, com opção de desligar | `dcf6632`, `196f33c` | Confirmar; perguntar depois da partida se ele notou e se vale |
| D-15 | Salas comuns continuam no salão; só Morvath na câmara | `6b16045` | Confirmar; guardiões numa câmara menor só se o teste pedir |
| D-18 | Raio de 12,5 m (12 m andáveis) | `docs/design/boss_arena.md` | Confirmar; é dado, ajustável depois do T2 |
| D-14 | Na luta, a porta selada no lugar do portal vermelho | `482eb6f` | Confirmar na luta; nas salas comuns o portal vermelho continua (proponho violeta apagado) |
| D-16 | Selo com a geometria da pintura (anel duplo, oito pontas) e o leão de pé do cânone no miolo | `482eb6f` | Confirmar; perguntar se "de pé" é nas patas de trás (como está) |
| D-17 | Espada erguida no lugar da cruz (pilaretes, sarcófagos, estandartes); leão só no selo | `482eb6f`, `00dd13b` | Confirmar; o cânone não cita cruz |
| D-20 | Morvath vai ao centro ao abrir as fases 3 e 4 | `6b16045` | Confirmar; é o que dá o vão da tempestade (`boss_arena.md`, conta 2) |
| D-21 | A sala do chefe chama "A Câmara do Selo" | `6801e87` | Confirmar |
| D-22 | A tela de fim não mostra o nível (o modo por salas não tem) | `6801e87` | Confirmar (é correção) |
| D-06 | Descida curta mantida (5 salas) | `make_data.gd:348` | Manter para o T1; voltar à inteira como padrão no C12 |

### Abertas

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| D-23 | O que é a porta selada ao norte e o véu de runas da escadaria sul (P12) | dar nome e papel no cânone; deixar sem explicação; trocar por parede | Não inventar: perguntar ao Daniel o que fica atrás da porta; até lá, sem texto |
| D-24 | As quatro imagens de Morvath em `docs/art/ref/morvath/` são de IA? | sim (declarar como referência); não | Responder para fechar o `docs/steam-ia.md` (DT-007) |
| D-11 | Meta de dificuldade da primeira vitória | 1ª tentativa; até 3; até 10 | Até 3 tentativas para quem jogou Hades, com a descida inteira; a partida de hoje dá o primeiro número |
| D-09 | Magia na luta do chefe | como o Hades; mais Magia por janela punida ou pelos mortos | Ler os Ômegas no `runs.jsonl` de hoje antes de mudar |
| D-10 | Bônus de sequência (não existe no Hades II) | manter; tirar | Tirar no C12 se o Daniel não sentir falta hoje |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" (no jogo); "o Lich-Rei do Sul" (cânone) | Um dos dois; nunca "Guardião" (no cânone é o Juramentado) |
| D-02 | Quem sela Morvath | quatro paladinos; um paladino do leão e quatro guardiões (cânone de 12/11); fora da tela | Seguir o cânone de 12/11; texto neutro até lá |
| D-04 | Nomes de `PALADIN_1` a `PALADIN_4` e das famílias de dons | agora; depois da D-02 | Depois da D-02 |
| D-05 | Créditos do Meshy (546) | peças da câmara e do salão; repintura de Morvath e elites; segurar | No C13: sarcófago, estátua encapuzada, porta em relevo e a foice (P14); nada antes do T1 |
| D-07 | Algo entre partidas | nada; Juramentos; hub | Nada até o T2; Juramentos no C14 |
| D-12 | Origem do som e da música | só CC0; encomenda; IA (declarar) | CC0 para efeitos; música por encomenda ou CC0 escolhida por ele |
| D-13 | Executável para testadores | certificado; instruções | Instruções agora (T2); certificado antes da página da Steam |
| D-03 | As nove imagens da Hécate | reenviar; desistir | Desistir: para a mecânica os dados bastam |
