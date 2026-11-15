# Relatório de QA e desempenho

- **Data**: 2026-11-15 (madrugada, 00:15 a 01:20)
- **Branch**: `arpg-3d`
- **Commits testados**: o pedido era `37631ab` (arena ciclo 4). Durante a rodada o Game Director fez o commit `72fbf0a`
  (correções rápidas do Art Director: friso dourado dos elites, luz-chave, véu do portal, aro do braseiro, brilho
  leste, cera das velas). Os arquivos mudaram no disco às 00:39:37. Por isso:
  - checagem, testes e partidas do robô rodaram nos **dois** commits (resultados idênticos);
  - as capturas sem prefixo `v2_` iniciadas antes de 00:39:37 são do `37631ab`; as `v2_*`, a galeria de inimigos,
    a sequência do guardião, `stress_1672`, `title_1672`, `fight_gl3_1672_t9` e as medidas de tempo de quadro são do
    `72fbf0a` (a versão que vai para o Daniel).
- **Ambiente**: WSL2 (Linux 6.18), 12 núcleos, 7 GB de RAM, **sem placa de vídeo**: Vulkan e OpenGL rodam por
  software (Mesa llvmpipe), tela virtual (xvfb), **sem som** (o `ERR_CANT_OPEN` e o "All audio drivers failed" do log
  são do áudio do WSL). A máquina estava carregada por outros agentes (carga de 9 a 29); capturas de 9 a 14 s levaram
  de 220 a 600 s, mais que os 180 s do `tools/shot.sh`. Usei uma cópia com log completo e limite de 900 s
  (`.../scratchpad/qa/shotlog.sh`, mesmos argumentos do `shot.sh`).

Pasta das evidências (tudo abaixo é relativo a ela):
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/qa/`

## Veredito

**Pronto para o Daniel testar, com ressalvas.** Nada quebra: zero `SCRIPT ERROR`, zero `Parse Error`, zero erro de
shader, 133 de 134 testes passando (o arriscado é o conhecido), o robô chega em Morvath nas cinco sementes, e as
telas de luta, guardião, chefe, loja, título e navegador abrem e são legíveis. As ressalvas são visuais e de interface
(lista abaixo, nenhuma crítica) e um custo maior de renderização por software que **não foi medido em placa de vídeo**.
O critério visual final é do `art-director` e do Daniel.

## 1. Importação, scripts e testes

| Comando | 37631ab | 72fbf0a |
|---|---|---|
| `godot --headless --path . --import` | ok (3 s) | ok |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok`, 0 SCRIPT ERROR, 0 Parse Error | igual |
| `tools/test.sh` (tudo, 11 arquivos) | 134 testes, 133 passando, 0 falhando, 1 arriscado (`test_only_finishers_glint`, "Did not assert"), 9638 asserções | igual |

Em toda saída do Godot (importação, check, testes, smoke, capturas) aparecem no fim
`WARNING: 2 ObjectDB instances were leaked at exit` e `ERROR: 1 resources still in use at exit`. **Não é novo**: o
mesmo par aparece no `903c81b` (worktree temporária). Baixa prioridade.

## 2. Partidas do robô (sem tela, `--fixed-fps 60`)

Resultados idênticos no `37631ab` e no `72fbf0a` (a partida é determinística por semente).

| Comando | Sala | Modo | Tempo | Abates | Dons | Vida de Morvath | step_ms |
|---|---|---|---|---|---|---|---|
| `tools/smoke.sh 300 --seed=5` | 5 (Morvath) | OVER (perdeu) | 183,5 | 20 | 2 | 2623 (fase 2) | 0,07 a 0,10 |
| `... 300 --seed=1` | 5 | OVER | 200,7 | 32 | 2 | 1382 (fase 3) | 0,13 |
| `... 300 --seed=2` | 5 | OVER | 153,1 | 16 | 2 | 3106 (fase 2) | 0,10 |
| `... 300 --seed=3` | 5 | OVER | 130,0 | 10 | 2 | 4001 (fase 1) | 0,09 |
| `... 300 --seed=7` | 5 | OVER | 213,4 | 51 | 2 | 994 (fase 3) | 0,23 |
| `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` | 5 | PLAY (Morvath com 5 de vida) | 118,3 | 21 | 8 | 5 (fase 3) | 0,10 a 0,13 |
| `tools/smoke.sh 120 --start=miniboss --seed=5` | 5 | OVER (venceu o guardião, perdeu para Morvath) | 95,2 | 1 | 1 | 4181 | 0,06 a 0,13 |
| `tools/smoke.sh 120 --start=shop --seed=5` | 5 | PLAY | 118,7 | 8 | 0 | 3139 | 0,06 a 0,11 |
| `tools/smoke.sh 120 --stress=300 --seed=5` | 1 | PLAY | 118,1 | 259 (41 de pé no fim) | 0 | | 0,33 a 0,6 (fim, com 41 vivos) |

Todas chegam em Morvath (sala 5 de 5). O robô perde para Morvath em todas as sementes com 2 dons; no `903c81b` a
semente 5 também perde (vida 1181), então não é regressão desta versão. Nenhuma linha de erro nos logs.

## 3. Desempenho

### Simulação (sem tela)
`step_ms` com a multidão de pé (`--stress=300`, medido aos 6 e 30 s, duas vezes, máquina menos carregada):

| | aos 6 s | aos 30 s |
|---|---|---|
| 72fbf0a | 248 inimigos, 1,98 a 1,99 ms | 227 inimigos, 1,77 a 1,83 ms |
| 903c81b | 237 inimigos, 1,86 a 1,89 ms | 213 inimigos, 1,69 a 1,71 ms |

Mesmo custo por inimigo (cerca de 8 µs). Sem regressão de simulação. O `step_ms` da linha final do smoke de 120 s não
compara versões porque depende de quantos sobram vivos. O `fps` do smoke sem tela não é FPS de jogo.

### Renderização (tela virtual, sem `--fixed-fps`, 1280 x 720)
Medido com um script de sonda fora do repositório (`tools/frame_probe.gd` no scratchpad): roda a cena principal em
tempo real, descarta 12 s e mede 25 s. Contadores do `RenderingServer` (máximo por quadro). **llvmpipe é CPU**: o
tempo de quadro aqui mede custo de rasterização por software, não o FPS numa placa de vídeo.

| Versão | Cena | Driver | ms por quadro (média / p95) | Chamadas de desenho | Objetos | Primitivas | Nós |
|---|---|---|---|---|---|---|---|
| 72fbf0a | luta `--bot --seed=5` | Vulkan | 339 / 368 e 380 / 415 (2 rodadas) | 958 | 1473 | 410 mil | 804 |
| 70ea8da | luta | Vulkan | 267 / 294 | 2436 | 3192 | 248 mil | 1549 |
| 903c81b | luta | Vulkan | 274 / 305 e 276 / 314 | 2331 | 2743 | 245 mil | 1544 |
| 72fbf0a | `--stress=300` | Vulkan | 1660 / 1761 | 1124 | 1790 | 2,17 milhões | 872 |
| 903c81b | `--stress=300` | Vulkan | 1601 / 1787 | 2525 | 3111 | 2,03 milhões | 1629 |
| 72fbf0a | luta | OpenGL 3 (navegador) | 445 / 490 | 1182 | 1512 | 379 mil | 801 |
| 903c81b | luta | OpenGL 3 | 285 / 340 | 3191 | 2869 | 246 mil | 1541 |

Leitura:
- O ciclo 4 (`37631ab`; o `70ea8da` ainda está igual ao `903c81b`) **cortou chamadas de desenho em 59%** e nós em
  48% (pedra juntada por material), mas **aumentou as primitivas em 65%** (248 mil para 410 mil: cantaria chanfrada,
  lajes irregulares, estátuas com pregas, portal). Por software isso custa 25 a 40% a mais no Vulkan e 56% a mais no
  OpenGL 3.
- Numa placa de vídeo de PC, 410 mil triângulos é pouco e a queda de chamadas de desenho tende a ajudar; **não foi
  medido** (não há GPU neste ambiente). No navegador e no celular (Compatibility) o aumento de primitivas é o risco.
  Recomendo medir na máquina do Daniel e no `tools/web.sh` dele.
- A multidão de 300 custa cerca de 1,9 milhão de primitivas por si (igual nas duas versões).
- Na captura com tela e 286 inimigos (`stress_1672.png`) o `step_ms` foi 4,24, com a máquina carregada; sem tela,
  1,99. Não isolei a diferença (renderer da multidão no passo ou só carga).

## 4. Medidas de arte (`tools/art_metrics.py`)

Incorporei ao script as medidas por região do Art Director (`extra.py` do scratchpad e `docs/art/cycle4_spec.md`,
seção (e)): por região `mean`, `sd`, `detail` (laplaciano médio da luminância), saturação, fração verde, fração de halo
quente e mediana; as 13 linhas PASS/FAIL do aceite do ciclo 4 e as 11 globais do ciclo 3 (`arena_reference.md`,
"Medidas globais"). Os números do `903c81b` batem com a coluna "Hoje" da especificação (verde da fachada 48,8% contra
49%; sd do portal 8,9 contra 9), então o script reproduz o estudo.

Vitrine `RES=1672x941 --showcase --seed=5`, 2 s:

| | 903c81b | 37631ab (`showcase_1672.png`) | 72fbf0a (`v2_showcase_1672.png`) |
|---|---|---|---|
| Aceite do ciclo 4 (regiões) | 0 de 13 | **8 de 13** | **8 de 13** |
| Globais do ciclo 3 | 9 de 11 | 5 de 11 | 4 de 11 |

Falham no 72fbf0a, regiões: detalhe da fachada direita 6,8 (meta 7), detalhe das estátuas do portal 8,9 (10), detalhe
do chão 7,6 (8,5), sd do chão ao fundo 18,9 (25), detalhe das colunas do abismo 3,3 (4,5).
Globais: p1 1,6 (4 a 10), p5 9,1 (10 a 16), p99 167,7 (>= 170), escuros 19% (9 a 17%), quentes estourados 0,5%
(>= 0,7%), violeta à direita 0,0% (>= 3%), **chão com azul dominante 71% (40 a 65%; era 56% no 37631ab)**.

Aceites das correções rápidas do `72fbf0a` (`docs/art/cycle4_final.md`, seção 3):

| # | Aceite | Medido | |
|---|---|---|---|
| 1 | Elites e guardiões sem halo largo | Galeria e guardião praticamente iguais antes e depois (`crop_mini_v1_v2.png`) | FALHA (ver M1) |
| 2 | Pixel (800, 500) da vitrine L <= 60; `floor_center` mediana R >= B; p50 42 a 50; azul dominante 40 a 65% | L 70; mediana #233653 (R 35 < B 83); p50 43,2; azul 71% | FALHA em 3 de 4 |
| 3 | `portal_open` mediana B >= 60, G >= R + 120, L >= 150; verde na fachada <= 20% | #2fcb6c; fachada dentro | passa |
| 4 | Halo quente no braseiro leste <= 16%; quentes estourados >= 0,4% | 12,5%; 0,5% | passa |
| 5 | Luta de 14 s, (1600, 600) L <= 100 e violeta presente | L 136 para 100; violeta presente | passa (no limite) |

Herói (caixa dele na luta, pixels dourados: matiz 35 a 55°, saturação > 0,4, valor > 0,45; `tools/gold.py`): 1,4% aos
9 s e 0,2 a 0,3% aos 14 s (meta <= 3%), nos dois commits. Esqueleto na galeria (`enemylab_game.png`, pixels acima do
fundo): p10 40, p90 172, faixa 132 (meta >= 100 e p10 <= 40; o limiar do fundo afeta o p10).

## 5. Capturas (Vulkan, reais, abertas e olhadas uma a uma)

| Arquivo | Commit | Comando | O que mostra |
|---|---|---|---|
| `showcase_1672.png` | 37631ab | `RES=1672x941 ... 2 --showcase --seed=5` | vitrine |
| `v2_showcase_1672.png` | 72fbf0a | igual | vitrine depois das correções |
| `showcase_903c81b_1672.png` | 903c81b | igual | comparação com o ciclo 3 |
| `fight_1672_t9.png`, `v2_fight_1672_t9.png` | 37631ab, 72fbf0a | `RES=1672x941 ... 9 --bot --autopick --seed=5` | luta aos 9 s |
| `fight_1672_t14.png`, `v2_fight_1672_t14.png` | 37631ab, 72fbf0a | `... 14 ...` | luta aos 14 s (três Escudos, canto leste) |
| `fight_1920_t9.png` | 37631ab | `RES=1920x1080 ... 9 --bot --autopick --seed=5` | HUD em 1080p |
| `fight_1280_t9.png` | 37631ab | `RES=1280x720 ...` | HUD em 720p (`crop_1280_hud.png` ampliado) |
| `miniboss_1672.png`, `v2_miniboss_1672.png` | 37631ab, 72fbf0a | `... 8 --start=miniboss --bot --autopick --seed=5` | Cavaleiro esqueleto |
| `seq/mini_00..07.png`, `seq/mini_strip.png` | 72fbf0a | `--frames` aos 6 s, a cada 0,06 s, 1280 x 720 | guardião em sequência (piscar) |
| `boss_1672.png`, `v2_boss_1672.png` | 37631ab, 72fbf0a | `... 8 --start=boss ...` | Morvath |
| `shop_1672.png`, `v2_shop_1672.png` | 37631ab, 72fbf0a | `... 4 --start=shop ...` | loja |
| `title_1672.png` | 72fbf0a | `... 3 --title` | tela de título (`crop_title_text.png`) |
| `fight_gl3_1672_t9.png` | 72fbf0a | `DRIVER=opengl3 RES=1672x941 ... 9 --bot --autopick --seed=5` | renderizador do navegador |
| `stress_1672.png` | 72fbf0a | `... 6 --stress=300 --bot --seed=5` | 286 inimigos |
| `enemylab_game.png`, `_front`, `_back` | 72fbf0a | `tools/enemy_lab.gd` (1672 x 941) | os nove inimigos e os seis elites |

O que passou, por item pedido:
- **Herói**: ruivo, cachecol e capa petróleo, roupa escura, lâmina verde; não está dourado nem branco
  (`crop_t9_hero.png`, `crop_t14_hero.png`, `title_1672.png`).
- **Inimigos normais**: distintos entre si na galeria (Esqueleto com elmo e pano vermelho, Corredor curvado,
  Feiticeiro e Besteiro de capuz roxo escuro, Escudo de chifres e broquel, Sacerdote roxo) e legíveis na luta
  (`v2_fight_1672_t14.png`).
- **HUD**: retrato, barras com número, quatro losangos com a tecla real (mouse esquerdo, mouse direito, Q, Espaço),
  sala, relógio, ouro e contador de golpes; nada cortado nem sobreposto em 1280 x 720, 1672 x 941 e 1920 x 1080.
- **Textos**: em português, sem travessão (nenhum `—` ou `–` em `data/text_pt.tres`; só o painel de ajuste do
  desenvolvedor tem texto em inglês fora dele).
- **Navegador** (`DRIVER=opengl3`): abre e joga, sem quebra; mais escuro e sem o violeta do abismo (conhecido).
- **Piscar**: a sequência do guardião mostra só o pisca branco do acerto, que é o pretendido; nada estranho.

## 6. Falhas e regressões por gravidade

Nenhuma crítica (nada trava, perde progresso ou impede jogar).

### Média

**M1. Contorno dourado dos elites e guardiões ainda engole a figura** (`72fbf0a`). Responsável: Gameplay Engineer
(`scripts/render/crowd_renderer.gd`) com o shader `assets/shaders/crowd_outline.gdshader` (Environment Artist), aceite
do Art Director.
Passos: `xvfb-run -a ~/tools/godot/godot --path . --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- out idle`
e `RES=1672x941 tools/shot.sh out.png 8 --start=miniboss --bot --autopick --seed=5`.
Visto: nos elites da galeria (`crop_lab_left.png`, `crop_lab_right.png`) o dourado cobre manchas dentro da silhueta
(costelas, joelhos, braços) com borda serrilhada; no Cavaleiro esqueleto o elmo e a capa ficam amarelo chapado e o
contorno serrilhado contorna o escudo (`crop_mini_v1_v2.png`: antes e depois do `OUTLINE_INTENSITY` 2.4 para 1.1
quase iguais). Morvath tem o mesmo efeito em magenta (`crop_boss.png`). A correção 1 não atingiu o aceite do próprio
Art Director. Suspeita: casco invertido (`cull_front`) crescendo pela normal em malhas com normais separadas, e o
casco de uma parte aparecendo na frente de outra.

**M2. Linha de controles da tela de título cortada à direita.** Responsável: UI/UX (`scripts/boot.gd`, linha 124).
Passos: `RES=1672x941 tools/shot.sh out.png 3 --title` (`title_1672.png`).
Visto: o texto `title_controls` é mais largo que a tela (rótulo sem quebra de linha) e termina em "...para a versão
Ômega, qu"; o "Esc: pausa" não aparece; a linha do controle fica centrada fora do meio. Vem desde `affd7bb` (o texto
cresceu), não é desta versão, mas é a primeira tela que o Daniel vê. Pode ser pior em 1280 x 720 (não capturado).

**M3. Correção rápida 2 (luz-chave) deixou o chão do centro azul demais.** Responsável: Environment Artist
(`scripts/game/catacomb_hall.gd`, `KEY_*`), avaliação do Art Director.
Passos: `RES=1672x941 tools/shot.sh v.png 2 --showcase --seed=5` e `python3 -I tools/art_metrics.py v.png`.
Visto: `floor_blue_dominant` 56% (passava) para 71% (fora de 40 a 65%), mediana do `floor_center` #454061 para
#233653 (o aceite pedia R >= B), pixel (800, 500) L 70 (aceite <= 60). O centro ficou menos lilás, mas mais
azul-acinzentado em vez de quente.

**M4. Renderização por software 25 a 56% mais lenta no ciclo 4** (primitivas +65%). Responsável: Environment Artist
(cantaria e lajes em `masonry.gd`, `catacomb_hall.gd`, `arena_kit.gd`). Ver a seção 3. Gravidade média só porque o
navegador e o celular (Compatibility) são alvo; numa placa de vídeo de PC pode não importar. **Não medido em GPU**.

### Baixa

- **B1. Globais do ciclo 3 fora da faixa** (5 de 11 no 37631ab, 4 de 11 no 72fbf0a; eram 9 de 11): p99, escuros,
  quentes estourados, violeta à direita (0%), e agora o azul do chão (M3). O Art Director já registrou os quatro
  primeiros em `docs/art/cycle4_final.md`; o aceite dizia que elas deviam continuar na faixa. Art Director decide.
- **B2. Cartão violeta do abismo leste com bordas retas** visíveis na câmera de jogo ao ir para o leste
  (`crop_t14_violet.png`, `v2_fight_1672_t14.png`, canto direito): um retângulo lilás com canto e borda reta, mais
  um plano translúcido vertical. Mais fraco depois do `GLOW_EAST` 1.5, mas a borda continua. Environment Artist.
- **B3. Espaçamento irregular das palavras na premissa do título** ("traiu a" e "sob a" quase grudados, "trai u"
  separado; `crop_title_text.png`, Alegreya Sans em 1672 x 941). Pode ser posição de glifo arredondada com a escala
  da tela; conferir em 1920 x 1080 e nas opções de fonte (subpixel, hinting). UI/UX.
- **B4. Avisos flutuantes sem fundo**: "FALTA OURO" na loja sai translúcido sobre a estátua e as correntes, quase
  ilegível (`shop_1672.png`, alto ao centro); o nome de Morvath e o relógio passam por cima das correntes
  (`v2_boss_1672.png`). UI/UX.
- **B5. Barra de vida aparece antes do corpo** enquanto o inimigo sobe do chão (`crop_t9_right.png`,
  `crop_t9_left.png`: barra e partículas roxas sem figura). Parece intencional (animação "rise"); fica o registro para
  o Gameplay Engineer confirmar.
- **B6. Avisos do renderizador no navegador**: no OpenGL 3 o log tem "Volumetric fog is only available when using the
  Forward+ renderer" e o mesmo para SSR (`scripts/game/game.gd:190` e `:201`). Inofensivo, vem de antes (`903c81b`
  igual); dá para ligar só no Forward+. Environment Artist.
- **B7. Vazamento ao sair** (`2 ObjectDB instances leaked`, `1 resources still in use`): em toda execução, igual no
  `903c81b`. Gameplay Engineer, quando houver tempo.
- **B8. Ferramenta**: o `tools/shot.sh` corta em 180 s; com a máquina carregada as capturas de luta passaram disso
  (220 a 600 s). Sugiro deixar o limite configurável (`TIMEOUT=`). Game Director.

## 7. Limitações

- Sem GPU: todo tempo de quadro é do llvmpipe; FPS em placa de vídeo, em PC fraco e em celular **não foi medido**.
- Sem som: áudio não verificado.
- Sem gente jogando: só o robô; sensação, dificuldade e leitura em movimento ficam para o teste do Daniel.
- Navegador verificado pelo driver `opengl3` do Godot, não num navegador de verdade (o pacote web não foi exportado
  nesta rodada).
- Builds de Windows e Web não foram exportados (não pedidos).
- Máquina carregada por outros processos: tempos de quadro com variação de cerca de 10% entre rodadas iguais.
- Worktrees temporárias do `903c81b` e do `70ea8da` foram criadas no scratchpad para comparar e removidas no fim.
