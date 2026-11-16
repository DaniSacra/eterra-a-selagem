# Backlog de A Selagem

- **Data**: 2026-11-16 (tarde). **Autor**: game-director (quarta revisão). **Commit lido**: `95c29c6` (HEAD de `arpg-3d`);
  mudanças desde a revisão anterior (`61f591e`): `f916ea5`, `752ceee` (plano e aprovação das arenas), `79dc454`, `501f3d8`
  (spec das arenas, leão nos estandartes), `f25ae5f` (C12a2 e fundação do C12), `e2297ee`, `91cc656` (cenário da Cripta, das
  Fendas e do Jardim), `fd72101` (evidências e QA), `f045b9d` (revisão de arte), `95c29c6` (correções C-1 a C-4, J-1 a J-4,
  G-1 na Cripta e no Jardim).
- **Em andamento, fora deste commit**: a rodada F-1 a F-5 nas Fendas (`rift_look.gd`), que entra num commit seguinte. Tudo
  que depende dela está marcado "em andamento".
- **Fontes lidas**: `docs/qa/latest_report.md` (sobre `91cc656`), `docs/gallery/cycle12_maps/ART_REVIEW.md`, `CAPTURAS.md`,
  `METRICAS.md`, a seção "Arenas" do `CLAUDE.md`, os commits acima; capturas olhadas: `rift/vA_c_combate`,
  `work/fix_garden_arvore_antes_depois`. Código conferido: `core/room_tally.gd` (campos do registro por sala).
- **Rodado por mim**: `tools/test.sh` no `95c29c6`: **462 de 462** testes passando (104635 asserções). Nada do jogo foi
  mudado.

## Estado do jogo em 5 linhas

1. A Fase 1 joga do título à selagem numa **descida de 7 salas** (D-27): abertura no salão da pintura, três lutas sorteadas
   entre **Cripta dos Esquecidos, Salão das Fendas e Jardim das Raízes Mortas** (duas variantes cada), fonte, guardião,
   loja e Morvath na Câmara do Selo.
2. A fundação espacial existe: chão com buracos, movimento varrido, caminho por grade e campo de fluxo, tiros que param na
   pedra, atirador que só prepara com linha livre e na tela. QA: **0 inimigo preso e 0 robô preso em 192 lutas e 8
   descidas**, 0 esquiva atravessando buraco em 6720 tentativas.
3. Robô com reação 0,25: **4 vitórias em 8 descidas**, Morvath aos 95 a 120 s com mediana de **24 de vida** ao entrar (12 a
   53; a base é 30); o feiticeiro na sala 3 e o Ancião como guardião fazem a maior parte do dano. **Ninguém jogou as arenas
   nem os atiradores novos** (`c666f4a`): o T2 é a próxima coisa que importa.
4. Arte: Cripta e Jardim aprovados pelo `art-director` e corrigidos (`95c29c6`); Fendas seguradas pela leitura da fenda
   (F-1 a F-3), em correção agora. O Daniel disse que nesta entrega vale a **variedade de salas, não a fidelidade** às
   imagens conceituais (D-36): a fidelidade fica para depois, talvez com Meshy.
5. Saúde técnica: 462 de 462 testes, quadro de 3,3 a 4,7 ms a 1080p nas arenas (salão 5,1), Jardim no Compatibility no
   limite de 6 ms; som ainda sintetizado; a referência `04` em tamanho cheio ficou no histórico do git (D-37).

Legenda: **Esforço** P (horas), M (1 a 2 dias), G (vários dias). **Prioridade** P0 (antes de tudo), P1 (neste ciclo), P2
(próximo), P3 (depois). **Estado**: aberto, em andamento, proposta (espera o Daniel), aprovado, feito. Responsáveis:
`gameplay-engineer`, `environment-artist`, `ui-ux-designer`, `art-director`, `qa-performance`; "Daniel" quando a decisão é dele.

---

## 0. Feito (fechado com evidência)

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
| C12-A2 | Salão das Fendas, 2 variantes | `e2297ee` | `cycle12_maps/rift/`; joga bem, arte segurada (F-1 a F-5 em andamento) |
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

Nenhum crítico nem alto aberto no jogo. O QA (`91cc656`) não achou falha alta; a revisão de arte deu três altas nas Fendas,
que estão em correção.

### Alto (arte, em andamento)

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| F-1 | Buracos das Fendas com fundo claro, leem como poços (dentro do buraco 64 de luminância contra 50 do chão) | `ART_REVIEW.md` F-1, `rift/vA_a_cenario` | M | `environment-artist` | em andamento | aceite da F-1 na `ART_REVIEW.md` |
| F-2 | Pontes leem como faixas do chão | F-2, `rift/vA_c_combate` (olhado: a ponte sul some no chão) | M | `environment-artist` | em andamento | aceite da F-2 |
| F-3 | Borda reta, boca norte fechada como sacada | F-3 | M | `environment-artist` | em andamento | aceite da F-3 |

Opinião minha depois da D-36: F-1 a F-3 continuam valendo, porque não são fidelidade e sim leitura de jogo ("aqui é
abismo, ali é ponte"). Mas se a rodada não convergir em mais uma passada, **o T2 sai assim mesmo** e a variante de uma
ponte só (ideia da F-3) fica para depois do teste. Ver D-38.

### Médio

| ID | Título | Evidência | Esforço | Responsável | Estado | Pronto quando |
|---|---|---|---|---|---|---|
| F-4 | Chão das Fendas escuro longe das lanternas (25 a 29 na luta) | F-4 | P | `environment-artist` | em andamento | recortes da F-4 com 40 ou mais |
| F-5 | Paredão de cantaria azul iluminada sob as bordas de fora | F-5 | P | `environment-artist` | em andamento | recorte do paredão até 60% do chão |
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

## 2. Quickwins

| ID | Título | Evidência | Impacto | Esforço | Responsável | Prioridade | Pronto quando |
|---|---|---|---|---|---|---|---|
| QW-014 | Montar a versão do T2 | regra de entrega MVP; memória "Test build folders" | o Daniel testa tudo de uma vez | P | sessão principal | P0, depois de F-1 a F-5 | `ASelagem.exe` exportado do commit das Fendas, copiado para `Downloads\ASelagem-3D` e `ASelagem-teste`; `runs.jsonl` antigo do Daniel guardado com outro nome para não misturar com o T2 |
| QW-015 | Ler o T2 por um roteiro fixo | QW-011 já grava o que precisamos | separar "salas difíceis" de "Morvath difícil" e "atirador injusto" de "atirador fácil" | P | `qa-performance` | P0 depois do T2 | tabela por sala do T2 (arena, `hp_in`, dano por fonte, tempo, `contact`) ao lado da mesma tabela do robô 0,25 (`METRICAS.md` seção 1) |
| QW-012 | Teste humano dos atiradores novos | `c666f4a` nunca jogado | decide o balanceamento deles | P | Daniel | P0 (dentro do T2) | 3 partidas no registro e as respostas do roteiro do T2 |
| G-1b | Compatibility das Fendas (vermelho some, azul satura) | `ART_REVIEW.md` G-1, `rift/vA_h_compatibility_combate`; o `95c29c6` só corrigiu Cripta e Jardim | navegador; desktop não muda | P | `environment-artist` | P2 | recortes do `vA_c` em Forward+ e Compatibility com diferença de até 15 por canal |

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

**Quando**: depois do commit de F-1 a F-5 e do QW-014. **Quanto**: 3 partidas, do título ao fim (vitória ou morte), no
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

Ordem recomendada: **C12b "Fecho das Fendas"** (agora) → **T2** → **C12c "Leitura do T2"** (balanceamento pelos dados de
gente) → **C13 "Progressão do Hades"** → **C14 "Arenas II"** → **C15 "Som"** → **C16 "Steam"**. Mudança em relação à
revisão anterior: entra o C12c, curto, para mexer nos atiradores e no guardião só com dados de gente, antes de mudar a
economia de dons (que muda tudo de novo). Opinião: o som (C15) é a maior distância para o Ember & Blade que ainda não foi
medida; se o T2 disser que os golpes estão bons e as salas justas, vale trocar C14 e C15 de lugar.

### C12b "Fecho das Fendas" (em andamento)
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

### Abertas

| ID | Pergunta | Opções | Minha recomendação |
|---|---|---|---|
| D-37 | A referência `04` (feita por IA) em tamanho cheio está no histórico do git e no GitHub (`91cc656`) | (a) deixar como está, já que o repositório é seu e as referências são suas; (b) reescrever o histórico e forçar o envio (só com a sua ordem expressa; quebra as cópias e os outros ramos); (c) deixar e só proibir de novo | **(a) com (c)**, se o repositório for privado: não vale reescrever história por uma imagem sua. Se ele for público, ou for ficar público antes do lançamento, **(b)** numa única vez, com você mandando |
| D-38 | Se depois de F-1 a F-5 a fenda ainda ler como poços | (a) o T2 sai assim; (b) segurar o T2 e passar a variante A para uma ponte só (o rasgo ganha comprimento; muda a forma andável e os testes) | **(a)**: pela D-36 o que vale agora é a sala ser diferente, e ela já é; a ponte única entra no C14 se você sentir falta |
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
| D-10 | Bônus de sequência (não existe no Hades II) | Tirar no C13 se você não sentir falta |
| D-01 | Título de Morvath | "o Rei que Traiu a Luz" ou "o Lich-Rei do Sul" (cânone) |
| D-02, D-04 | Quem sela Morvath; nomes dos paladinos | Seguir o cânone de 12/11; nomes depois |
| D-05 | Créditos do Meshy (546) | Nada até você pedir; fidelidade das arenas é candidata (D-36) |
| D-07, D-12, D-13 | Entre partidas; origem do som; executável para testadores | Como antes |
| D-03 | Imagens da Hécate | Desistir |
