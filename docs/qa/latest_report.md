# Relatório de QA e desempenho: ciclo 5 (polimento visual)

- **Data**: 2026-11-15, 10:55 a 12:25
- **Branch**: `arpg-3d`
- **Testado**: o working tree do ciclo 5 **sem commit**, sobre o `4e67876` ("depois"), comparado com o `4e67876`
  ("antes"). O "antes" roda numa cópia exata do HEAD fora do projeto
  (`.../scratchpad/c5/base/`; conferida com `diff -rq` contra um `git archive HEAD`: só a pasta `.godot` difere).
- **Ambiente**: WSL2 (Linux 6.18), 12 núcleos, 7 GB. Notebook do Daniel na tomada, em modo desempenho, nas duas
  versões. As capturas de Linux usam Vulkan por software (llvmpipe) em tela virtual (xvfb). O desempenho foi medido
  na **placa de vídeo real** (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan Forward+, Godot 4.7.2 de Windows) por
  `tools/gpu.sh`. **Sem som** (o áudio do WSL falha; não verificado).

Evidências (tudo abaixo é relativo a esta pasta, salvo indicação):
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/`

## Veredito

**Pronto para o Daniel testar.** Nada quebra: 0 `SCRIPT ERROR`, 0 `Parse Error`, 137 testes com 136 passando (o
arriscado é o conhecido), as partidas do robô dão resultados **idênticos** antes e depois (nenhum número de combate
mudou), e na placa de vídeo o custo novo é pequeno: no máximo +0,34 ms por quadro (`--stress=90`), o jogo fica entre
3,3 e 8,2 ms por quadro (de 120 a 300 quadros por segundo) em todas as cenas medidas. O que melhorou se vê nas
capturas: halo amarelo dos elites e do Ancião sumiu, herói maior e mais detalhado, medalhão em pedra, HUD com moldura.

Não há falha crítica nem alta. As ressalvas médias são de leitura (herói some no bolo de inimigos, como antes; elite
pouco diferente do comum na galeria; câmera mais perto deixa o herói perto da borda da tela no patamar oeste) e um
achado de conteúdo: na partida curta **nenhum inimigo `_elite` aparece** nas salas. O critério visual final é do
`art-director` e do Daniel.

## 1. Checagem, testes e partidas do robô

| Comando | Antes (`4e67876`) | Depois (ciclo 5) |
|---|---|---|
| `godot --headless --path . --import` | | ok, 0 erro de script |
| `godot --headless --path . -s tools/check.gd` | | `CHECK ok`, 0 SCRIPT ERROR, 0 Parse Error |
| `tools/test.sh` | 11 arquivos, 134 testes, 133 passando, 1 arriscado, 9638 asserções | **12 arquivos, 137 testes, 136 passando, 0 falhando, 1 arriscado** (`test_only_finishers_glint`, "Did not assert"), 9661 asserções; novo `test_hero_look.gd` (2 de 2) |

Partidas do robô (`qa5/smoke/antes.txt` e `qa5/smoke/depois.txt`). **As linhas `RESULT` são idênticas** antes
e depois, número por número (só o `fps` sem tela varia, e ele não é FPS de jogo):

| Comando | Sala | Modo | Tempo | Abates | Dons | Vida de Morvath | step_ms |
|---|---|---|---|---|---|---|---|
| `tools/smoke.sh 300 --seed=5` | 5 (Morvath) | OVER (perdeu) | 183,5 | 20 | 2 | 2623 (fase 2) | 0,06 |
| `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` | 5 | PLAY (Morvath com 5) | 118,3 | 21 | 8 | 5 (fase 3) | 0,10 |
| `tools/smoke.sh 120 --stress=300 --seed=5` | 1 | PLAY | 118,1 | 259 (41 de pé) | 0 | | 0,33 |

Sequência de 49 s na tela (`qa5/seq/s5_00..09.png`, folha `qa5/seq_s5_sheet.png`): sala 1, fonte (sala 2), guardião
Ancião (sala 3) chegando aos 29 s; 0 erro. Em toda execução seguem o `2 ObjectDB instances leaked` e o
`1 resources still in use at exit` de antes (baixa, já registrado).

## 2. Desempenho

### Placa de vídeo (o que o Daniel sente)
RTX 5060 Laptop, Vulkan Forward+, janela 1672 x 941, `--fixed-fps 30 --disable-vsync` (os mesmos instantes de jogo em
toda rodada), `--seed=5`. Sonda `qa5/gpuperf.gd` (cópia em `C:/Users/danie/tools/qa/`): descarta 300 quadros
(compilação dos shaders), mede os 300 seguintes. "Quadro" = tempo real entre quadros (CPU + GPU, com a simulação);
"GPU" = `viewport_get_measured_render_time_gpu`. Antes no espelho `C:/Users/danie/tools/eterra-gpu-head`
(`MIRROR=`), depois no `eterra-gpu`. Três rodadas alternadas; a tabela mostra a mediana das três medianas
(`qa5/gpu_perf.txt` tem as 24 linhas).

| Cena | Quadro antes | Quadro depois | Diferença | GPU antes | GPU depois | Primitivas antes / depois | Chamadas de desenho |
|---|---|---|---|---|---|---|---|
| Vitrine `--showcase` | 1,22 ms | 1,29 ms | +0,07 | 1,15 | 1,20 | 47 mil / 65 mil (+38%) | 72 / 62 |
| Luta `--bot --autopick` | 3,38 ms | 3,48 ms | +0,10 | 3,27 | 3,33 | 420 mil / 678 mil (+61%) | 1022 / 986 |
| `--bot --autopick --stress=90` | 3,75 ms | 4,09 ms | **+0,34** | 3,30 | 3,42 | 841 mil / 1,16 milhão | 1107 / 1090 |
| `--bot --autopick --stress=300` | 8,23 ms | 8,21 ms | 0 (ruído) | 3,24 | 3,27 | 2,11 / 2,43 milhões | 1106 / 1026 |

Leitura:
- O guarda do ciclo (`cycle5_spec.md` D: no máximo +0,5 ms com `--stress=90` no desktop) **passa**: +0,34 ms.
  A variação entre rodadas iguais é de 0,1 a 0,9 ms (na rodada 2 o `stress=300` depois foi mais rápido que o antes).
- As primitivas sobem cerca de 258 mil por quadro na luta: é o herói do Meshy desenhado em várias passadas (sombras
  das luzes, profundidade, contorno). A GPU quase não sente (+0,06 ms); com 300 inimigos o gargalo é a CPU
  (simulação e multidão), não a GPU, e lá não muda.
- Em quadros por segundo: de 290 (luta) a 120 (300 inimigos), muito acima de 60. **Não medido**: celular,
  navegador de verdade, placa de vídeo fraca.

### Processador sem placa (só nota)
O `step_ms` da simulação é igual (tabela da seção 1). O tempo de quadro por software (llvmpipe) não entrou: o Game
Director pediu a GPU real e a rodada de CPU foi interrompida. A medição do Environment Artist no llvmpipe
(`perf/exp3.txt`, `exp4.txt`) dá a vitrine igual e o `--stress` de 918 para 1018 ms por quadro (+11%), pelo mesmo
aumento de primitivas.

## 3. Capturas (reais, abertas e olhadas uma a uma)

Pares antes | depois, 1672 x 941, Vulkan, `--seed=5`, em `c5/depois/`:

| # | Par | Comando (depois de `--`) | O que se vê |
|---|---|---|---|
| 1 | `cmp_1_arena.png` | `--showcase --shot-at=4` | medalhão em pedra, abismo com arcos e bruma, lanterna com caixilho |
| 2 | `cmp_2_combate.png` | `--bot --autopick --shot-at=9` | herói maior (Explorador), aviso vermelho sobre o medalhão inteiro e legível |
| 3 | `cmp_3_sacerdote.png` | `--start=miniboss --seed=2 --bot --autopick --shot-at=9` | Ancião sem halo amarelo, de capuz; antes em `c5/antes_qa/8_sacerdote.png` |
| 3b | `cmp_3_lab_game.png` | `tools/enemy_lab.gd` | galeria dos nove inimigos e seis elites |
| 4 | `cmp_4_elite.png` | `--start=miniboss --seed=5 --bot --autopick --shot-at=9` | Cavaleiro (guardião, `elite = true`) na arena das catacumbas; ver M1 sobre `_elite` |
| 4b | `cmp_4b_elite_horda.png` | `--horde --start=elite1 ...` | o par antigo, no modo horda |
| 5 | `cmp_5_medalhao.png` | `--showcase --cam-dist=32 --shot-at=4` | faixa larga de 16 pedras, runas, bronze escuro |
| 6 | `cmp_6_horda.png` | `--bot --autopick --stress=90 --shot-at=6` | combate com vários |
| 7 | `cmp_7_morvath.png` | `--start=boss --bot --autopick --shot-at=12` | Morvath, arco de aviso inteiro, barra do chefe |
| 8 | `cmp_8_cercado.png` | `--bot --autopick --stress=40 --shot-at=7` | herói cercado de perto (o `10_cercado.png` aos 5 s caiu no clarão vermelho do golpe e não serve) |
| 9 | `cmp_9_titulo.png` | `--title --shot-at=3` | tela de título com o Explorador |

Mais: `c5/depois/2_combate_1280_gpu.png`, `2_combate_1920_gpu.png`, `2_combate_gpu.png` (placa de vídeo) e
`2_combate_gl3_gpu.png` (OpenGL 3, o renderizador do navegador, na placa): abrem, HUD inteiro e sem sobreposição nos
três tamanhos, nada faltando no OpenGL 3. Recortes ampliados em `qa5/crops/` (`hero_cmp.png`, `boss_hero_cmp.png`,
`elder_cmp.png`, `blob_cmp.png`, `d_cerc.png`, `d_lab.png`).

### Medidas (scripts do Art Director em `tools/`, `tools/art_metrics.py`)

| Medida | Antes | Depois | Meta |
|---|---|---|---|
| Ancião (770,400)-(900,610) em `8_sacerdote`: amarelo saturado / L > 200 | 9,0% / 10,6% | **1,8% / 1,7%** | <= 2% |
| Cavaleiro (560,440)-(730,620) em `9_elite_arena`: amarelo saturado / L > 200 | 7,2% / 5,1% | **0,9% / 0,7%** | <= 2% / <= 3% |
| Herói de pé (Morvath, `boss_hero_cmp.png`, grade de 10 px) | cerca de 77 px | **cerca de 93 px** | 85 a 100 |
| Herói (795,365)-(860,470) em `7_morvath`: média / desvio de L | 71,4 / 29,7 | 76,1 / 31,5 | não lavar: contraste não caiu |
| Herói na luta (`2_combate`): desvio de L | 38,3 | 37,6 | igual |
| Vitrine p1 / p50 / p95 / p99 | 1,6 / 44,8 / 107,8 / 166,8 | 4,9 / 45,3 / **104,4** / 166,5 | p50 42 a 50, p95 >= 105 |
| Globais do ciclo 3 | 5 de 11 | 7 de 11 | |
| Aceite por regiões do ciclo 4 | 7 de 13 | 7 de 13 | |

Saída completa: `qa5/art_metrics_1_arena.txt`.

### Regressões e legibilidade, item por item
- **Herói**: Explorador do Meshy com cabelo ruivo, cachecol e manto petróleo, couro com contraste, lâmina verde
  esmeralda; maior e mais detalhado (`qa5/crops/hero_cmp.png`, `boss_hero_cmp.png`). Contraste não caiu (tabela).
- **Inimigos**: legíveis no chão; Ancião com capuz escuro e sem contorno amarelo (`elder_cmp.png`); Cavaleiro sem o
  vulto amarelo (`cmp_4_elite.png`).
- **Avisos vermelhos sobre o medalhão**: inteiros, borda contínua, o medalhão não tem vermelho (`2_combate.png`,
  `9_elite_arena.png`, `7_morvath.png`).
- **Clarão do golpe**: inimigos piscam branco (`qa5/seq/s5_08.png`, Ancião e soldados brancos no acerto).
- **Barra de armadura**: amarela por cima da barra do guardião e do chefe (`8_sacerdote`, `9_elite_arena`), igual.
- **Marcação de elite**: ver M2.
- **Câmera a 54**: na sequência de 49 s (`seq_s5_sheet.png`) as portas com recompensa ("Fonte de luz", "Mais vida",
  "Guardião") e a escada leste aparecem inteiras; todo aviso vermelho dos quadros aparece inteiro; o arco de Morvath
  e a barra do chefe cabem (`7_morvath.png`). Exceção no patamar oeste: M3.
- **Tela de título**: o Explorador cabe inteiro, texto e botões no lugar (`12_titulo.png`); a câmera do título não
  usa a distância de jogo.

## 4. Falhas e regressões por gravidade

Nenhuma crítica nem alta.

### Média

**M1. Nenhum inimigo `_elite` aparece na partida curta** (não é regressão; o pedido de capturar um elite comum na
arena não é possível). Responsável: Gameplay Engineer (`tools/make_data.gd` `_stage`, `scripts/core/stage_def.gd`).
Por quê: `StageDef.elite_from_depth = 3` (`stage_def.gd:41`), e na descida encurtada (`st.rooms = 4`, guardião fixo
na 3) as salas de luta comum só existem nas profundidades 1 e 2 (`run_map.gd` `options`: 3 é o guardião, 4 a loja, 5
Morvath). `EncounterGen.pick_types` (`encounter_gen.gd:56`) tira os `_elite` antes da 3. O `--stress` só põe comuns.
Efeito: o Daniel não vai ver o novo visual dos elites no teste (só os dois guardiões, que têm `elite = true`). Passos:
ler as linhas citadas, ou `tools/smoke.sh 300 --seed=N` para qualquer semente: a sala 1 e a 2 nunca têm armadura
amarela fora do guardião. Sugestão: `elite_from_depth = 2` enquanto a partida for curta (decisão do Game Director).

**M2. Elite quase igual ao comum fora do combate.** Responsável: Art Director (aceite), Gameplay Engineer
(`make_palettes.gd`, `crowd_renderer.gd`). Na galeria (`qa5/crops/d_lab.png`, fileira de cima = elites) só os
frisos de ouro velho distinguem, e no Escudo e no Feiticeiro quase não se vê a diferença lado a lado. Em jogo a barra
amarela de armadura marca o elite, então a leitura funcional fica; a dúvida é estética. Não medi o aceite "frisos de
ouro >= 2% da caixa no `6_horda`" porque nenhum `_elite` aparece nessa cena (M1).

**M3. No patamar oeste o herói fica perto da borda esquerda da tela.** Responsável: Gameplay Engineer
(`scripts/game/game.gd` `CAM_MARGIN := Vector2(10.0, 5.0)` e `CAM_SOUTH`, ajustados para a distância 60).
Passos: `--bot --autopick --stress=40 --seed=5`, captura aos 7 s (`cmp_8_cercado.png`). Visto: o herói (no meio do
bolo) passa de cerca de x 270 (16% da largura) para cerca de x 185 (11%); o que estiver a oeste dele no patamar tem
menos tela. Com a câmera mais perto, a mesma margem de trava deixa ver menos além da beira. Sugestão: reduzir
`CAM_MARGIN.x` em proporção (cerca de 10% menor) e recapturar.

**M4. O herói continua sumindo dentro do bolo de inimigos** (vinha de antes; o aceite A2 do ciclo pedia achá-lo em
menos de 2 s). Responsável: Gameplay Engineer (raio-x do herói), Art Director (aceite).
Passos: `--bot --autopick --stress=90 --shot-at=6` (`cmp_6_horda.png`, recorte `qa5/crops/blob_cmp.png`) e
`--stress=40 --shot-at=7` (`qa5/crops/d_cerc.png`). Visto: o raio-x ainda é uma mancha azul-esbranquiçada, só o
cabelo aparece um pouco; no `--stress=40` não achei o herói sem saber onde ele estava.

### Baixa
- **B1. p95 da vitrine 104,4** (guarda D pede >= 105; era 107,8). O p50 e o p1 melhoraram. Art Director decide.
- **B2. `docs/steam-ia.md` desatualizado**: ainda descreve o herói "Sombra" repintado; não cita o Explorador do Meshy
  (`assets/models/meshy/hero_explorer/`, agora no jogo), os nove inimigos e a Emeth do Meshy (no disco). O
  `CLAUDE.md` exige mantê-lo em dia. Game Director.
- **B3. Cartão violeta do abismo leste ainda com bordas retas** em `7_morvath.png` (canto direito). Vem do ciclo 4.
  Environment Artist.
- **B4. Espaçamento irregular das palavras na premissa do título** ("traiu a luz", "sob a igreja"; `12_titulo.png`),
  vem do ciclo 4. UI/UX.
- **B5. Vazamento ao sair** (`2 ObjectDB instances leaked`, `1 resources still in use`), igual a antes.

Resolvidos neste ciclo em relação ao relatório anterior: contorno dourado dos elites e guardiões (M1 antigo:
`elder_cmp.png`, `cmp_4_elite.png`); linha de controles do título agora quebra e cabe (M2 antigo, `12_titulo.png`).

## 5. Limitações
- Desempenho na placa do notebook do Daniel (RTX 5060), uma janela de 1672 x 941; **não medido** em celular,
  navegador de verdade (o OpenGL 3 só foi capturado, não medido) nem em placa fraca. Variação entre rodadas iguais de
  até 0,9 ms.
- Capturas de comparação em Vulkan por software (llvmpipe), para bater com o "antes" do Game Director; as da placa
  (`*_gpu.png`) mostram a mesma cena.
- Sem som; sem gente jogando (só o robô): sensação e leitura em movimento ficam para o Daniel.
- Builds de Windows e Web não exportados (não pedidos).
- Mudei só arquivos fora do projeto, mais este relatório; a cópia do HEAD recebeu o `tools/gpu.sh` para medir.
