# Roteiro da Fase 1: revisão executiva e próximos ciclos

- **Data**: 2026-11-16 (tarde). **Autor**: game-director. **Commit lido**: `87ba686` (HEAD de `arpg-3d`).
- **Pedido**: `docs/design/roadmap_brief_2026-11-16.md` (resumo fiel do Daniel). Este documento é o planejamento; o
  backlog executável está em `docs/backlog.md` (seção "C12c" e as seguintes).
- **Decisão confirmada pelo Daniel hoje (D-39)**: "vale copiar do Hades, nomes nossos". Continua valendo a regra antiga:
  do Hades II copiamos as mecânicas e os números, fielmente; nomes, personagens, UI e arte são de Eterra. O C13 é
  planejado com isso. O conflito com a frase do pedido ("não copiar mecanicamente") está resolvido: o benchmarking serve
  para entender os princípios, e a cópia dos números continua como base.
- **Fontes lidas**: `CLAUDE.md`, `docs/backlog.md`, `docs/design/` (comparativo, hades2_sistemas, morvath_boss_fight,
  cycle12_arenas_plan, game_director_review), `docs/qa/latest_report.md` (sobre `91cc656`),
  `docs/gallery/cycle12_maps/` (ART_REVIEW, CAPTURAS, METRICAS, `work/fix_rift_vA_antes_depois_cenario.jpg`),
  `git log` dos últimos 40 commits e o diff do `87ba686`.
- **Rodado por mim**: `tools/test.sh` no `87ba686`: **462 de 462** passando (104113 asserções, 77,8 s). Nada do jogo foi
  mudado.
- **Telemetria humana lida**: `%APPDATA%\EterraASelagem\runs_antes_ciclo12.jsonl` (3 partidas, descida de 5 salas, só
  teclado, 1 vitória) e `runs.jsonl` (1 partida de hoje, 12:46, sem mouse: o Daniel pediu para tratar como pouco
  representativa).
- **Vídeo olhado**: `C:\Users\danie\Videos\ASelagem\partida_ASelagem.mp4` (robô com reação 0,25, 4 min 10 s, 1280 x
  720, com som; derrota na fase 4 de Morvath aos 3:50). Tirei folhas de um quadro a cada 10 s, quadros nas transições
  (1:20 a 1:31, 1:58 a 2:08) e medi o som com `ffmpeg` (`volumedetect`, `astats`, `silencedetect`).

Legenda: "medido" é dado do jogo ou do vídeo; "simulação" é o robô (não é diversão); "opinião" é minha; "pede teste
humano" é o que só o Daniel jogando responde.

---

## A. Diagnóstico

### A.1 Pronto (com evidência)

| O quê | Evidência |
|---|---|
| Combate do Hades II com os números (ataque 20/25/60, especial, Ômegas, avanço 0,2 s, círculo, vida 30) e a sensação do Ember & Blade (fita, talho, hit stop, câmera lenta do último abate, quadro P&B raro) | `CLAUDE.md`; ciclos 7 a 10; vídeo 1:20 e 1:58 (câmera lenta com desfoque no último abate) |
| Morvath em 4 fases na Câmara do Selo, com avisos assinados, ritual, maldição, tempestade, vitória com selagem | C9 a C11, `test_boss*.gd`, `test_boss_exits.gd`; vídeo 2:08 a 3:50 |
| Três arenas novas com duas variantes, chão com buracos, campo de fluxo, tiros que param na pedra | `f25ae5f`, `e2297ee`, `91cc656`; QA: 0 preso em 192 lutas e 8 descidas; 0 esquiva sobre buraco em 6720 |
| Fendas corrigidas (F-1 a F-6, G-1): buracos escuros com bruma violeta, bordas quebradas, pontes com lajes, parapeito vazado | `87ba686`; `work/fix_rift_vA_antes_depois_cenario.jpg` (olhado: agora lê como fenda com pontes); falta a reconferência do `art-director` |
| Registro de partidas de gente por sala (`rooms`, `hp_at_boss`, `defeated_by`, dons, controle) | `core/room_tally.gd`, `core/run_log.gd`; a linha de hoje traz `rooms` |
| Desempenho no PC: 3,3 a 5,1 ms por quadro a 1080p na RTX 5060 | `cycle12_maps/METRICAS.md` seção 5 |
| Testes: 462 de 462 | rodado no `87ba686` |

### A.2 A melhorar (com evidência)

1. **A partida é curta demais para o chefe que temos** (medido). Nas 3 partidas de gente que chegaram a Morvath antes do
   C12 ele chegou com **3 dons** (`gifts` de cada linha); o robô do vídeo também (tela de fim: "Dons 3"). Morvath tem
   6050 de vida desenhados para 5 a 8 dons (`morvath_boss_fight.md` seção 7). A loja da sala 6 não vende nada: o robô
   chegou com **37 de ouro** (vídeo 2:02) e o item mais barato custa 60 (`shop_prices` 150, 100, 125, 60 no `_stage`).
   Isso é o C13.
2. **Clarões fora da paleta** (medido no vídeo e no código). A coluna de recompensa ao vencer a sala é um pilar amarelo
   saturado com miolo branco que cobre o herói (vídeo 1:20, 1:58); a coluna de entrada de Morvath é um pilar ciano que
   transforma ele numa silhueta preta por 1 s, com o nome da sala por cima (vídeo 2:08). Causa: `Fx.beam` com
   `BEAM_INTENSITY` 2,5 e sem teto (`rooms.gd:297`, `boss.gd:218`, `game.gd:702` fonte, `game.gd:492`, `game.gd:641`,
   `game.gd:796`, `rooms.gd:226`); o próprio `boss.gd:979` diz que essa coluna mistura para o branco. As gemas das
   portas são esferas amarelas acima do limiar do glow (`rooms.gd:418`, albedo x 2,2 sem sombra). A regra da direção é
   "nada de clarão branco, amarelo saturado ou partículas sobre o herói".
3. **Silêncio e pico no som** (medido no vídeo). 12 trechos de 2 s ou mais abaixo de -50 dB, somando cerca de 50 s dos
   250 s (20%): nas transições (1:24 a 1:26, 1:30 a 1:39), na loja e na entrada de Morvath (2:06 a 2:14) e no fim. O pico
   chega a **0,04 dBFS** (corte) aos 12 s, numa luta no salão. O `scripts/audio.gd` cria os barramentos `Music` e `SFX` e
   não tem limitador no `Master`. Música desligada; sem ambiência.
4. **Cripta escura na luta** (medido pela revisão de arte; leitura pede teste humano). Chão longe das velas com
   luminância 40 na luta (alvo 45 a 60, `ART_REVIEW.md`, Medidas); no vídeo (1:01 a 1:23) o terço esquerdo do quadro é
   preto e o herói e o feiticeiro leem no meio.
5. **O registro ainda não separa "injusto" de "não reagiu"** (medido no código): `RoomTally` guarda dano por fonte, mas
   não quantos golpes, quantas esquivas por sala, quanto tempo o aviso ficou à vista antes do golpe, se a esquiva estava
   pronta, nem se o atacante estava fora da tela. Sem isso o teste do Daniel não diz se o feiticeiro e a foice são justos.
6. **Pendências baixas do QA** (B-1 a B-4) e a câmera sem número de salto (DT-009).

### A.3 Riscos

| Risco | Por quê | Mitigação |
|---|---|---|
| Rebalancear pelo robô | o robô com reação 0,25 morre na fase 3 e 4 (tempestade, maldição); o Daniel, quando apanhou de Morvath, apanhou da **foice** (36 de 62 de dano na vitória, 12 de 24 na derrota, `boss.hurt_by`) | nenhum número de Morvath, atirador ou guardião muda no C12c; só instrumentação |
| Amostra humana mínima | 3 partidas antigas e 1 sem mouse | teste final do Daniel no fim do C12c com o registro novo; teste com mais pessoas (D-13) antes de mexer forte |
| C13 muda tudo de novo | dons, ouro e salas mexem na curva inteira | C13 só depois do teste do C12c, com a mesma tabela por sala para comparar |
| Escopo de arte | Arenas II pede 3 salas novas procedurais | uma decisão de combate por arena; sem Meshy |
| Som sem fonte | só CC0, CC-BY ou síntese | C15 com lista de fontes e licença por arquivo em `audio/` |
| Máquina fraca nunca medida | Steam | DT-003 antes do C16 |

### A.4 Hipóteses da revisão externa

| # | Hipótese | Veredito | Evidência | O que fazer |
|---|---|---|---|---|
| A | Falta sensação de catacumbas interligadas | **pede teste humano** (opinião: provável) | cada sala é um cenário próprio carregado depois de um corte escuro (vídeo 1:23 a 1:24); não há corredor, mapa nem vista da sala seguinte; a porta só mostra a recompensa | não construir exploração agora; perguntar no teste (pergunta 1 do roteiro); no C14 a Ponte dos Condenados é a candidata a "ligação" |
| B | A árvore e as raízes não influenciam o combate | **parcial, simulação** | Jardim barra 0,47 a 0,50 tiro por luta contra 1,1 a 1,3 na Cripta; corredor mais estreito 3,6 m; o robô não usa cobertura de propósito (DT-002) | instrumentar: tiros barrados por peça (`blocked_by` com o id do obstáculo) e golpes levados a até 2 m de uma peça; decidir com o teste |
| C | A escuridão da Cripta atrapalha a leitura | **parcial, medido** | chão na luta 40 (alvo 45 a 60); terço esquerdo preto no vídeo; herói e inimigos leem no meio | ENV-01 sobe o chão da luta para 45 a 60 sem acender a periferia; leitura final pede teste humano |
| D | Morvath: transições, impacto, justiça e legibilidade antes de ataques novos | **confirmada em parte** | entrada com coluna ciano que esconde ele (vídeo 2:08, `boss.gd:218`); gente apanha da foice, robô da tempestade (dados acima) | GP-01 tira o clarão; GP-02 mede o aviso à vista em cada golpe; nenhum ataque novo, vida e dano iguais |
| E | A descida é curta | **confirmada, medido** | 3 dons ao chegar em Morvath em 3 de 3 partidas de gente e no vídeo; loja sem compra possível (37 de ouro) | C13 (10 salas e Morvath na 11, economia do Hades II) |
| F | O som é fraco | **confirmada no técnico, medido**; qualidade pede teste humano com som | 20% de silêncio no vídeo, pico de 0,04 dBFS, sem limitador, sem música | GP-05 põe o limitador já (seguro); o resto é o C15 |

---

## B. Roadmap

**Ordem recomendada: C12c "Qualidade da experiência" (hoje) → teste final do Daniel → C13 "Progressão e
rejogabilidade" → C15 "Som e polimento" → C14 "Arenas II" → C16 "Steam".**

Mudança em relação ao pedido: **C15 antes do C14** (opinião minha, decisão D-40 do Daniel). Por quê:
1. O som está em todo golpe de toda sala; as arenas novas acrescentam 3 salas. A meta é "uma Fase 1 que o jogador queira
   repetir", e o golpe que pesa é o coração (a direção do jogo). Hoje 20% da partida é silêncio (medido).
2. O C13 alonga a descida para 10 salas com as 4 arenas que já existem; só depois dele sabemos se a repetição de salas
   cansa (pergunta do teste do C13). Se cansar, o C14 sobe na frente do C15 sem perda.
3. O C15 não depende de arte nova e não mexe em colisão; o C14 depende de três especificações de arte.
Sem resposta do Daniel, **vale a ordem do pedido** (C14 antes do C15); o C12c e o C13 não mudam com isso.

| Ciclo | Objetivo em uma frase | Por que agora | Tamanho |
|---|---|---|---|
| **C12c** | A versão atual sem clarão fora da paleta, com a Cripta lendo na luta, o som sem corte e o registro que separa injusto de não reagiu, pronta para o teste final | é a única forma de o teste do Daniel virar decisão de número; nada aqui muda balanceamento | 1 dia, 4 agentes em paralelo |
| **C13** | Chegar a Morvath com 5 a 8 dons por uma descida de 10 salas com a economia do Hades II (D-39) | o dado mais forte que temos: 3 dons e loja inútil | G |
| **C15** | Cada ação, aviso e inimigo com som próprio; música de combate e de Morvath; ambiência; mixagem sem corte | 20% de silêncio; som provisório | G |
| **C14** | Três arenas novas, cada uma com uma decisão de combate que as outras não têm | variedade para a descida longa | G |
| **C16** | Steam: controle com ícones, opções de vídeo, save robusto, máquina fraca, `steam-ia.md` | depois do conteúdo da Fase 1 | G |

---

## C. Backlog priorizado

Os itens completos (ID, ciclo, prioridade, descrição, problema, valor, aceite, dependências, responsável, estado,
evidência) estão em `docs/backlog.md`, seção 1. Resumo:

| ID | Ciclo | P | Título | Responsável |
|---|---|---|---|---|
| GP-01 | C12c | P0 | Colunas de luz e gemas das portas abaixo do glow, sem cobrir o herói nem Morvath | `gameplay-engineer` |
| GP-02 | C12c | P0 | Registro que separa injusto de não reagiu (golpes, esquivas, aviso à vista, atacante fora da tela, tiros por tipo, ouro e loja, origem humana ou robô) | `gameplay-engineer` |
| GP-05 | C12c | P1 | Limitador no barramento `Master` | `gameplay-engineer` |
| GP-03 | C12c | P1 | B-2: `resolve` no centro de uma peça; invocações nunca dentro de peça | `gameplay-engineer` |
| GP-04 | C12c | P1 | B-3: teste "cercado" com inimigos | `gameplay-engineer` |
| GP-06 | C12c | P1 | DT-009: `--trace-cam` com o maior salto do alvo | `gameplay-engineer` |
| ENV-01 | C12c | P0 | Chão da luta na Cripta entre 45 e 60 | `environment-artist` |
| ENV-02 | C12c | P2 | J-5: fraturas da árvore no valor do marfim | `environment-artist` |
| ENV-03 | C12c | P2 | B-4: Jardim no Compatibility até 6 ms no p90 | `environment-artist` |
| UI-01 | C12c | P1 | Placas das portas legíveis a 1080 (classe nova `DoorSign`) | `ui-ux-designer` |
| UI-02 | C12c | P1 | Tela de derrota com a sala, a arena e os dons levados | `ui-ux-designer` |
| QA-01 | C12c | P0 | Linha de base antes das mudanças (capturas, vídeo com som, métricas) | `qa-performance` |
| QA-02 | C12c | P0 | Medidas depois, relatório e galeria `cycle12c` | `qa-performance` |
| ART-R1 | C12c | P1 | Reconferir F-1 a F-6 nas Fendas (`87ba686`) | `art-director` |
| C13-01 a C13-08 | C13 | P1 | descida de 10, baralho de recompensas, raridade em sequência, ouro por inimigo, loja em 3 grupos, romã por nível, Elo 12%, bônus de sequência (D-10) | `gameplay-engineer`, `ui-ux-designer`, `qa-performance` |
| C15-01 a C15-05 | C15 | P2 | mixagem, sons de ação e aviso, inimigos, música, ambiência | `gameplay-engineer` (sistema), `art-director` (curadoria), `qa-performance` |
| C14-A4 a A6 | C14 | P2 | Santuário, Ponte, Runas | `environment-artist`, `gameplay-engineer`, `art-director` |
| DT-003 | C16 | P2 | Máquina fraca | `qa-performance` |

P3 (depois): densidade das arenas contra as referências, G-2, ART-010 (Meshy, só com o Daniel), Biblioteca e
Reservatório (D-31, D-32).

---

## D. Aceite por ciclo

### C12c
1. Nenhum bug crítico ou alto aberto; 0 inimigo preso e 0 robô preso em 96 lutas (16 sementes por arena e variante) e em
   8 descidas de 7 salas com reação 0,25.
2. Nenhuma sala impossível: em cada arena e variante o robô vence a sala 1 em 16 de 16 sementes; `NavGrid.reachable` do
   início a cada saída e zona (teste existente) passa.
3. Avisos legíveis: nenhum clarão acima do limiar do glow sobre o herói ou Morvath nos momentos medidos (GP-01); o chão
   da Cripta na luta entre 45 e 60 (ENV-01).
4. Câmera funcional: maior salto do alvo abaixo de 0,5 m entre quadros a 60 FPS em uma travessia de cada arena (GP-06).
5. Som sem corte: pico de no máximo -1,0 dBFS em um vídeo de descida inteira com som (GP-05).
6. Registro: uma partida humana simulada (`--runlog` com o robô marcado `source: bot`) traz todos os campos novos do
   GP-02; a tela de derrota mostra sala, arena e dons (UI-02).
7. `tools/test.sh` todo passando, com os testes novos; `tools/check.gd` ok; `title_flow_check.gd` ok; smoke de regressão
   `300 --seed=5` vence; quadro a 1080p na RTX 5060 sem piora de mais de 0,3 ms por arena.
8. Evidências em `docs/gallery/cycle12c/` (seção F) e relatório do QA.
9. Nenhum número de combate mudado (diff de `tools/make_data.gd` sem mudança em inimigos, chefes, ondas, dons).

### C13
1. Descida de 10 salas e Morvath na 11 por padrão; a de 7 por `--short7` (ou nome que o engenheiro escolher) e a de 5 por
   `--short`.
2. Robô (reação 0,25, 8 partidas): chega a Morvath com **5 a 8 dons** em pelo menos 6 de 8; compra algo na loja em pelo
   menos 6 de 8; vence entre 3 e 6 de 8. Simulação: confirma a mecânica, não a diversão.
3. Economia igual ao Hades II (D-39): baralho de recompensas, raridade em sequência, ouro por inimigo com teto de 10 a 15 +
   0,5 por profundidade e 70% por morte, recompensa de ouro 100, loja em 3 grupos com cura 50, romã com ganho por nível;
   cada número com a fonte em `hades2_sistemas.md`; testes de cada regra.
4. Distribuição de arenas sem repetir seguidas, com as ainda não vistas primeiro; nenhuma arena mais de 3 vezes em 10
   salas.
5. Gente (teste do C13): partida inteira de 10 a 13 min medida no `runs.jsonl` (pede teste humano).

### C15
1. Toda ação do herói, todo aviso inimigo e todo ataque de Morvath com som (lista conferida por teste que lê a tabela de
   eventos de som e acusa evento sem som).
2. Mixagem: pico verdadeiro até -1 dBTP; volume integrado da partida entre -18 e -14 LUFS; nenhum silêncio de 2 s ou
   mais com a música ligada (medido com `ffmpeg` em vídeo de descida inteira com som).
3. Música de combate e de Morvath que muda por fase; ambiência por arena.
4. Toda fonte com licença CC0 ou CC-BY registrada em `audio/LICENSES.md` e créditos na tela, ou síntese; nada pago.
5. Opções de volume (geral, música, efeitos) que funcionam e salvam.

### C14
1. Três arenas, duas variantes cada, com os mesmos testes do C12 (caminho, borda, cercado, preso, linha de tiro).
2. Cada arena com uma decisão de combate escrita na spec e medida: por exemplo, a Ponte com tiros barrados e tempo na
   ponte, as Runas com dano de chão evitável (faixas e ladrilhos, D-29), o Santuário com o guardião usando o espaço.
3. Aprovação do `art-director` com medidas; quadro até 6 ms a 1080p.

---

## E. Plano de testes

| Tipo | O quê | Quando |
|---|---|---|
| GUT | lógica nova de cada item (teto das colunas, campos do registro, `resolve` no centro, cercado com inimigos, limitador, `DoorSign`, tela de derrota) | em cada entrega de agente; `tools/test.sh` inteiro antes do commit |
| Checagem | `tools/check.gd`, `--import`, `title_flow_check.gd` | antes do commit |
| Smoke de regressão | `tools/smoke.sh 300 --seed=5`, `120 --start=boss --boons=25 --seed=5`, `120 --stress=300 --seed=5` | depois de integrar |
| Simulação por arena | 16 sementes por arena e variante, sala 1, reação 0,25 (`stuck`, `bot.stuck`, mortes, contato, tempo) | QA-02 |
| Descida | 8 descidas de 7 salas, reação 0,25 (vitórias, `hp_at_boss`, dons ao chegar, ouro na loja) | QA-02 |
| Capturas e medidas | recortes de luminância e maior canal (Cripta, colunas, gemas, entrada de Morvath), na GPU | QA-01 e QA-02 |
| Som | vídeo de descida inteira com som, `astats` (pico), `silencedetect` (-50 dB, 2 s) | QA-01 e QA-02 |
| Câmera | `--trace-cam` numa travessia por arena | QA-02 |
| Desempenho | quadro a 1080p por arena (Forward+ e Compatibility) | QA-02 |
| Teste humano final | o roteiro abaixo, 3 partidas, registro inteiro | depois do commit do C12c |

### Roteiro do teste final do Daniel (C12c)
Três partidas do título ao fim, com mouse e teclado ou controle, sem nada à parte. Responder uma linha por pergunta:
1. Pareceu descer por catacumbas ligadas ou pular de sala em sala? (hipótese A)
2. Usou a árvore, as raízes, as colunas ou as pontes para se proteger de tiro? (B)
3. Na Cripta deu para ver os inimigos e os avisos em todo canto? (C)
4. Em Morvath, algum golpe pareceu sem aviso ou impossível de sair? Qual? (D)
5. Com quantos dons chegou e se a luta pareceu longa ou curta. (E)
6. O som ajudou ou atrapalhou a ler os golpes? (F)
7. Algum clarão escondeu o herói ou um aviso?
Mandar o `%APPDATA%\EterraASelagem\runs.jsonl` inteiro (o da partida sem mouse foi guardado com outro nome pela sessão
antes de montar a versão).

---

## F. Plano de evidências

Pasta `docs/gallery/cycle12c/` (o QA cria), com `CAPTURAS.md` (comando de cada arquivo), `METRICAS.md` e:
- `antes/` e `depois/`: os mesmos quadros na GPU a 1920 x 1080: coluna da recompensa (Cripta A, sala vencida), fonte,
  entrada de Morvath (`--start=boss`, 0,5 s), gema da porta, Cripta A combate (`vA_c`), Jardim fraturas.
- `descida_com_som.mp4`: descida inteira de 7 salas a 1920 x 1080 com som (DT-004), robô com reação 0,25, semente fixa.
- `travessia_<arena>.mp4` com a saída do `--trace-cam` no `METRICAS.md`.
- Tabela por sala do robô com os campos novos (GP-02) e uma linha `runs.jsonl` de exemplo com `source: bot`.
- Regra que continua: referência de IA só em miniatura de 480 px rotulada; nada de vídeo sem a linha de comando.

---

## G. Decisões pendentes que exigem o Daniel

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| D-40 | Ordem depois do C13 | (a) C14 Arenas II e depois C15 Som (pedido); (b) C15 antes do C14 | **(b)**, pelas razões da seção B; sem resposta vale (a) |
| D-10 | Bônus de sequência de golpes (`DamageCalc.combo_bonus`) não existe no Hades II | (a) tirar no C13, pela D-39; (b) manter como coisa nossa | **(a)**: é o único número fora do Hades no combate básico |
| D-41 | Nomes de Eterra para os sistemas do Hades que entram no C13 (romã, raridades, loja) | aceitar os nomes do `hades2_sistemas.md` (por exemplo Brasa da Vigília para a romã) ou mandar os seus | mandar só os que quiser trocar; o resto entra com o nome provisório, só no `text_pt.tres` |
| D-12b | Licença do som e da música no C15 | (a) só CC0 e síntese; (b) CC0 e CC-BY com créditos na tela | **(b)**: abre música de qualidade (CC-BY exige só crédito) |
| D-37 | Referência `04` no histórico do git | como no backlog | **(a) com (c)** se o repositório for privado |
| D-08, D-14, D-16 a D-18, D-20 a D-22 | Decisões da noite de 2026-11-16 | confirmar no teste final | confirmar todas |
| D-11 | Meta de dificuldade da primeira vitória | | até 3 tentativas para quem jogou Hades, com a descida inteira (C13) |

Decididas hoje: **D-39** (Hades fiel, nomes nossos), D-34, D-35, D-36. **D-38** perde o objeto se o `art-director`
aprovar as Fendas no ART-R1 (a fenda já lê como rasgo com pontes no `87ba686`).

---

## H. Próxima execução: C12c, hoje

**Por quê**: é a menor mudança que deixa o teste final do Daniel útil. Tira os dois clarões que a direção proíbe (vistos
no vídeo), sobe a Cripta para o alvo medido, protege o som de corte e, principalmente, grava o que falta para decidir
números com gente. Nada de balanceamento, nenhum ataque novo, nenhuma arena nova.

### Arquivos donos por agente (paralelo sem conflito)

| Agente | Arquivos donos | Não mexe em |
|---|---|---|
| `gameplay-engineer` | `scripts/game/fx.gd`, `scripts/game/rooms.gd`, `scripts/game/boss.gd` (só a coluna de entrada), `scripts/game/game.gd`, `scripts/game/skills.gd`, `scripts/game/arena.gd`, `scripts/game/horde.gd` e `projectiles.gd` (só para alimentar o registro), `scripts/core/room_tally.gd`, `scripts/core/run_log.gd`, `scripts/audio.gd`, `scripts/core/cam_frame.gd`, testes novos `tests/test_cycle12c.gd`, `tests/test_arenas.gd` | `scripts/ui/*`, `*_look.gd`, `data/text_pt.tres` |
| `environment-artist` | `scripts/game/crypt_look.gd`, `scripts/game/garden_look.gd`, `scripts/game/stone_tree.gd`, `assets/shaders/stone_tree.gdshader` | `rift_look.gd` (só se o ART-R1 pedir), código de jogo |
| `ui-ux-designer` | `scripts/ui/door_sign.gd` (novo), `scripts/ui/end_screen.gd`, `data/text_pt.tres`, `tests/test_end_screen_run.gd` (novo) | `rooms.gd` (o gameplay-engineer troca a chamada, ver UI-01) |
| `qa-performance` | `docs/qa/latest_report.md`, `docs/gallery/cycle12c/`, roteiros fora do repositório | código, arte, testes do projeto |
| `art-director` | `docs/gallery/cycle12_maps/ART_REVIEW.md` (adendo) | código |

### Itens (aceite verificável, sem teste humano)

**gameplay-engineer**
- **GP-01 Colunas e gemas sem clarão** (P0). `Fx.beam` passa a ter teto padrão `BEAM_CORE_CAP` 1,0 (o `BEAM_NO_CAP`
  só por pedido explícito); a coluna de entrada de Morvath (`boss.gd:218`) some ou vira a runa de invocação no chão, nada
  na altura do corpo dele; a coluna da recompensa e da fonte com intensidade de `BEAM_OVER_BOSS` quando o herói está a
  menos de 2 m; gemas das portas (`rooms.gd:418`) com albedo até 1,0 por canal e o brilho só pela luz. Aceite: teste GUT
  que chama cada ponto de `Fx.beam` do jogo e confere `cap` até 1,0; nas capturas do QA-02 o recorte da coluna sobre a
  Cripta e o da entrada de Morvath com maior canal até 235 e o corpo de Morvath visível (mediana do recorte dele acima de
  30) no quadro de 0,5 s.
- **GP-02 Registro para o teste humano** (P0). Por sala: `variant`, `dodges`, `hits` (quantos golpes levou), `hits_by`
  (contagem por fonte), `shots` por tipo de inimigo `{fired, hit, blocked}`, `blocked_by` (id da peça que barrou), `gold_in`,
  `boons_in`. Por partida: `source` (`human` ou `bot`), `boons_at_boss`, `shop` `{gold, bought}`, `fountain_used`. Por
  golpe levado (até 60 por partida, `hurt_ctx`): fonte, `warn_s` (segundos entre o aviso aparecer e o golpe; -1 sem
  aviso), `dash_ready`, `offscreen` (atacante fora dos 5 a 95% da tela no disparo). Aceite: `tests/test_cycle12c.gd` com
  `RoomTally`/`RunLog` puros cobrindo cada campo; `tools/smoke.sh 120 --seed=5 --runlog=<arquivo>` grava uma linha com
  todos, `source: bot`; nenhuma mudança no `RESULT` antigo (campos novos só acrescentados).
- **GP-03 B-2** (P1). `Arena.resolve` com o ponto no centro exato de caixa ou círculo empurra para a face mais perto.
  Aceite: teste GUT em cada peça de cada arena; teste que sorteia 200 invocações do Ancião e 200 reforços de Morvath e
  nenhuma cai dentro de peça.
- **GP-04 B-3** (P1). Aceite: teste GUT com 2 esqueletos de cada lado nos 4 corredores mais estreitos de cada arena e
  variante: pelo menos 12 de 16 esquivas saem mais de 2,5 m (o número do QA à mão).
- **GP-05 Limitador** (P1). `AudioEffectHardLimiter` no `Master` com teto -1,0 dB. Aceite: teste GUT que confere o efeito
  no barramento depois do `Audio` iniciar; no vídeo do QA-02, pico até -1,0 dBFS.
- **GP-06 `--trace-cam`** (P1). Imprime o maior salto do alvo da câmera entre quadros e onde. Aceite: a opção existe,
  documentada no `CLAUDE.md`, e o QA-02 mede abaixo de 0,5 m nas 4 arenas a 60 FPS.
- **Integração do UI-01**: trocar o `Label3D` do `_marker` pela `DoorSign` quando o ui-ux-designer entregar (sem mudar
  posição nem colisão).

**environment-artist**
- **ENV-01 Cripta lendo na luta** (P0). Luz de preenchimento ou ar (`crypt_look.gd`), sem acender paredes de fora nem o
  facho. Aceite: em `crypt/vA_c_combate` e `vB_c_combate` refeitas, os recortes de chão longe das velas com mediana entre
  45 e 60; a tampa sob o facho continua até 150 (C-1); quadro na RTX 5060 sem piora de mais de 0,3 ms.
- **ENV-02 J-5** (P2). Aceite: as fraturas dos galhos quebrados com maior canal até 200 e abaixo do glow no recorte do
  `garden/vA_a_cenario`.
- **ENV-03 B-4** (P2). Aceite: Jardim A no Compatibility a 1080p com p90 até 6,0 ms (medido pelo QA), ou registrado como
  aceito se custar a aparência no Forward+.

**ui-ux-designer**
- **UI-01 Placas das portas** (P1). `DoorSign` (Label3D com Alegreya Sans Bold, contorno escuro, ouro velho para o
  nome da recompensa, tamanho fixo em pixels). Aceite: teste GUT da classe (texto, cor, `fixed_size`); na captura a 1080
  do QA-02, a altura das maiúsculas da placa de pelo menos 16 px e contraste com o fundo de pelo menos 4,5:1.
- **UI-02 Tela de derrota útil para o teste** (P1). "Sala N de M", nome da arena e os dons levados (como na vitória), só
  pelo `text_pt.tres`, sem travessão. Aceite: teste GUT abrindo a `EndScreen` com estatísticas de derrota na sala 3 da
  Cripta com 2 dons e conferindo os textos; captura `--shot-on=end` no QA-02.

**qa-performance**
- **QA-01 Linha de base** (P0, antes de qualquer integração): capturas `antes/` da seção F, vídeo de descida com som,
  medidas de som (pico, silêncios).
- **QA-02 Depois** (P0, depois da integração): tudo do aceite do C12c (seção D), relatório `docs/qa/latest_report.md`,
  `docs/gallery/cycle12c/` com `CAPTURAS.md` e `METRICAS.md`, tabela por sala com os campos novos.

**art-director**
- **ART-R1** (P1): adendo na `ART_REVIEW.md` com os aceites de F-1 a F-6 medidos nas capturas do `87ba686`; se passar,
  D-38 fecha.

### Ordem do dia
1. QA-01 roda primeiro (só leitura e capturas) enquanto os outros três começam.
2. `gameplay-engineer`, `environment-artist`, `ui-ux-designer` e `art-director` em paralelo.
3. A sessão integra (DoorSign no `rooms.gd` pelo gameplay-engineer), roda testes e smokes.
4. QA-02 mede, a sessão faz o commit, monta a versão para o teste final (guarda o `runs.jsonl` atual com outro nome) e
   entrega o roteiro da seção E. **Não começar o C13** antes do teste.
