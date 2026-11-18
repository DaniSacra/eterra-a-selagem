# T5b: "a luta com o boss está estranha, tem uns esqueletos pulando novamente" (combat-feel-director, 2026-11-17)

Relato do PO jogando o exe do T5 (HEAD `fe07159`). Diagnóstico e especificação; nada de código de jogo foi alterado.
Evidências em `docs/gallery/t5b/boss/` (quadros, `data/` com as sondas, os scripts de análise e os resumos).

Legenda: **[M]** medido (fonte, 60 f/s fixos), **[O]** observado em imagem, **[C]** lido no código, **[I]** inferência,
**[H]** Hades II. "f" = quadro a 60 por segundo. Tamanhos em metros do jogo salvo "tamanho 1".

## 1. Resposta direta

**O que pula são os Esqueletos feiticeiros (`mage`, "Esqueleto feiticeiro" no jogo), não os esqueletos de espada.**
Confirmado [M]:

1. **O trote do feiticeiro é a "gazela" que o T5 tirou do esqueleto** (`Running_B` do KayKit com `MAGE_TROT`: `lift` 0,5,
   passada 0,62, `tools/bake.gd`, desde a E1b). No andar assado, 14 de 20 poses têm o corpo inteiro acima de 10 cm do
   chão (tamanho 1), até 0,30 m (0,38 m em jogo, tamanho 1,27); o alto do corpo sobe e desce 15 cm. Na luta real: **65%
   dos quadros de corrida com os dois pés no ar** (vértice mais baixo acima de 12 cm), mediana 19 cm, p95 37 cm; o
   feiticeiro passa 25 a 32% de toda a vida dele no ar. O esqueleto de espada, depois do T5: 1% (antes 59%).
   [O] `mage_trot_side_24f.jpg`: a sombra fica longe dos pés na maior parte da tira.
2. **O feiticeiro dá um pulo ao terminar de se erguer.** O `rise` dele (`LayToIdle` da UAL 2, 0,9 s) termina curvado,
   cajado deitado e baixo (alto da pose 1,88 contra 2,65 do `idle`, tamanho 1). No quadro em que o `RISE` acaba ele
   passa para o trote numa mistura de 0,1 s (`CLIP_FADE`): **o centro do corpo sobe 0,50 m em 6 quadros (1,23 para
   1,73 m), o alto da figura sobe 1,0 m (cajado), e ele já cai no trote saltado**, girando 60 graus em 3 quadros.
   Medido: `data/mage_rise_to_trot_f250_345.csv` (f305 a f317), [O] `mage_rise_side.jpg`.
3. Na luta de Morvath metade dos invocados são feiticeiros (ritual 2 esqueletos + 2 feiticeiros, reforço a cada 6 s
   `skeleton` + `mage`, camadas da fase 3 `layer_raise` `skeleton` + `mage`). Os feiticeiros são os que mais correm:
   eles fogem para manter a distância (`ARCHER`), na frente da câmera, sempre no trote.

**É regressão?** Não no clipe: o trote e o erguer do feiticeiro são idênticos em `5dfe97f` (pose por pose). Mas o T5
(1) tirou o pulo do esqueleto, deixando o do feiticeiro sozinho e mais visível ao lado dele, e (2) com a fuga nova
(T5-20: `FLEE_SLACK` 0,75 m, `FLEE_HOLD`) o feiticeiro corre mais: no ritual com o herói parado, 2.900 quadros de trote
antes contra 3.700 depois (+27%, 3 sementes). Para quem joga, "pulando novamente" é verdade: o mesmo pulo, agora no
esqueleto de cajado.

**O que não pula** [M], para fechar as hipóteses do pedido:

| Hipótese | Resultado |
|---|---|
| Corrida nova do esqueleto (`Jog_Fwd`, `plant`/`stand`/`lift`) | 1% dos quadros fora do chão (antes 19 a 31%); o sobe e desce do centro 8 cm. Não pula |
| Salto de posição (empurrão, separação, `Arena.resolve`, `keep_off_target`, `BodyBlock.EASE`, Morvath raio 1,4 empurrando) | nenhum passo de simulação acima de 0,25 m/quadro fora de ataque em 4 lutas com robô e 3 rituais; os passos de 0,12 a 0,17 m/quadro são todos o empurrão do golpe do herói (10 m/s por 3 quadros), com ferida ou atordoamento. Antes do T5 havia um de 0,70 m perto de Morvath (semente 1) |
| Bote do esqueleto | 2,5 m em 0,3 a 0,4 s, igual antes e depois (`data/skeleton_lunge.txt`); pés no chão, o corpo desliza. Lê como bote, não como pulo vertical (ver P2-5) |
| Erguer do esqueleto | sai do chão até ficar de pé (pés abaixo do piso até a pose 3); termina na altura da corrida (centro 1,17 contra 1,19). Desliza 0,5 m para frente durante o erguer (centro em z de -0,44 para -0,09, tamanho 1). Não pula |
| Morvath | posição simulada nunca salta (nenhum passo acima de 0,3 m fora da investida); os saltos que ele tem são de desenho (seção 2) |

## 2. Tudo mais que deixa a luta estranha (medido)

### 2.1 A troca de clipe "em degraus" (P1, desenho, todos; mais visível em Morvath)

Durante uma mistura de clipe (`CLIP_FADE` 0,1 s, `BOSS_CLIP_FADE` 0,12, `RECOVER_FADE` 0,3, o assentar da preparação),
`CrowdRenderer.add_kind` manda ao shader só a pose de onde saiu e **a pose mais perto** do clipe novo
(`row = a if p - a < 0.5 else next`): o alvo da mistura não é interpolado e salta de pose em pose no meio da mistura.
Medido [M] (`data/fade_pops.txt`, robô semente 1, 200 s): Morvath com 139 quadros de salto do corpo desenhado acima de
0,12 m entrando na foice (pior 0,39 m num quadro), 74 voltando ao andar, 46 entrando no arremesso; o pior caso, a
invocação: **0,55 m de lado num quadro** (f3941, `walk:17 > summon:0` passa a `walk:17 > summon:1`). Feiticeiro e
esqueleto também (0,38 a 0,66 m caindo mortos). Causa no código: `scripts/render/crowd_renderer.gd` `add_kind`, ramo
`from_row >= 0 and fade < 1.0`. Existe desde a E1c (não é regressão), mas o T5 alongou as misturas (assentar de 0,12 a
0,25 s, volta à guarda de 0,3 s): mais quadros em degraus.

### 2.2 Morvath gira de uma vez (P1, máquina de estados)

[M] `data/morvath_turns.txt`: o corpo dele salta **100 a 137 graus num quadro** ao começar a foice e a maldição (2 a 4
vezes por luta, em todas as sementes, antes e depois do T5). Causa [C] `scripts/game/boss.gd`: `e.dir = _dir` cru no
passo 0 de `_step_scythe` (linha ~460), nas Lâminas (`e.dir = (_dirs[0] + _dirs[1]).normalized()`), na maldição e na
investida (linhas ~737 e ~794). O resto do tempo ele vira por `slerp` (6 a 8 por segundo). Lê como "estalo" de 2 a 3
quadros com a lâmina indo para trás do corpo.

### 2.3 Morvath de costas (P2, leitura; geometria mais estados que não miram)

[M] De costas para a câmera (o rosto a menos de 60 graus do sentido da câmera): 26% da perseguição, 31 a 37% da foice
(é para onde o herói está), **70 a 80% do ritual** e 100% de uma tempestade (semente 2). Isso é geometria: o herói ao
norte dele. O que é nosso: em `ERUPTIONS`, `SUMMON`, `STORM` e `RECOVER` ele não acompanha o herói e fica de lado ou de
costas para ele 20 a 45% do tempo. No Hades II [H, inferência pela referência] o chefe conjurando continua virado ao
alvo. Correção barata: nesses estados `e.dir = e.dir.slerp(toward, dt * 2)`; na foice e nas Lâminas o giro vem antes
(2.2).

### 2.4 Invocado que levanta e ataca no mesmo instante (P1, cadência)

[M] `data/spawns.txt`: do fim do `RISE` à primeira preparação, p10 0,10 a 0,45 s, **mínimo 0,02 s** (semente 2); um
esqueleto levantou a 0,98 m do herói (semente 4, a runa foi marcada a 4 m e o robô andou para cima dela). Causa [C]
`Horde.spawn`: `cooldown = attack_cooldown * rand(0,4 a 1,0)` (esqueleto 0,56 a 1,4 s) e `_timers` desconta a recarga
durante o `RISE` de 0,9 s: em cerca de 40% dos esqueletos a recarga já acabou quando ele fica de pé. Leitura: "nasceu
e já veio" (sem respiro entre o erguer e o golpe). No Hades os invocados têm um tempo de chegada antes de agir [I].

### 2.5 O que foi conferido e está bem

- Aviso x golpe de Morvath: a foice acerta em `slash3:7` (T5-14), Lâminas soltam no quadro do arremesso; nada mudou.
- Invocações: em 4 lutas, 0 a 1 por luta a menos de 2 m do herói, todas onde o herói andou para a runa; `summon_clear`
  4 m vale no momento da marcação.
- Nenhuma posição de Morvath ou invocado salta na simulação; nenhum invocado preso.

## 3. Como foi medido

HEAD `fe07159` e `5dfe97f` (cópia por `git archive` fora do repositório, importada), CPU sem tela, `--fixed-fps 60`,
`--start=boss --nosave --hero-hp=9999`:

- herói parado no ritual (`--boss-hp=0.6`, sementes 1 a 3, 50 s), fase 1 parado (60 s), robô `--bot
  --bot-reaction=0.25` sementes 1 a 4 (200 s, a luta inteira até a vitória), fases 3 e 4 (`--boss-hp=0.3` e `0.13`,
  sementes 1 e 2, 90 s).
- Sonda nova `data/drawn_probe.gd.txt` (rodar como `-s <arquivo>.gd`): a cada quadro lê **o que o `CrowdRenderer`
  escreveu nos MultiMesh** (transformação, as duas poses e a fração da mistura) e calcula o corpo desenhado de cada
  inimigo: centro (x, y, z), vértice mais baixo e mais alto; junta com o estado, o clipe e a posição simulada. É a
  primeira sonda que mede o desenho, não o pedido de desenho (as do T5 decodificavam só `drawn_row`).
- Análise: `data/an.py` (saltos por estado e clipe), `bob.py` (altura e pés por clipe), `sum.py` (quadros fora do
  chão), `fadepop.py` (saltos dentro das misturas), `morv.py` (giros e costas de Morvath), `spawn.py` (onde e quando os
  invocados levantam), `lunge.py` (bote), `snap.py` (saltos da simulação). Poses assadas (tamanho 1):
  `data/baked_poses_size1.txt`.
- Quadros na CPU (OpenGL no Xvfb): `tools/walk_strip.gd` (feiticeiro e esqueleto) e `tools/enemy_lab.gd ... rise clip
  mage x6`. Sem vídeo na GPU (pedido para não usar).

## 4. Problemas priorizados e especificação

### P1-1 Trote do feiticeiro sem pulo (causa confirmada): gameplay-engineer + art-director

- Onde: `tools/bake.gd`, `MAGE_TROT` e a linha `"walk"` do `mage` (o feiticeiro elite usa o mesmo assado).
- Fazer como o T5-11 fez com o esqueleto: trocar `Running_B` por um andar travado de pés no chão. Ponto de partida
  (números do esqueleto aprovados): `Jog_Fwd` da UAL com `"lock": true`, `"plant": 0.5`, `"stand": 0.15`, `"lift"` 0,3,
  passada para dar 130 a 150 passos por minuto a 3,5 m/s com tamanho 1,27, e a guarda dos braços do `MAGE_TROT`
  (cajado à frente, braço livre junto ao corpo). Alternativa a medir: `Walk_Formal` ou um andar rápido (o feiticeiro é
  conjurador, não corredor; o andar rápido lê melhor que um trote) com a velocidade da simulação intacta.
- Critério de aceite (no assado, tamanho 1, `tools/clip_motion.gd`, mais um caso no `tests/test_enemy_motion.gd` ou
  `test_living_crowd.gd` igual ao do esqueleto): corpo inteiro acima de 0,10 m em no máximo 6 de 20 poses (hoje 14);
  vértice mais baixo nunca acima de 0,15 m (hoje 0,30); sobe e desce do centro até 7 cm; escorregamento até 5 cm.
  Na luta (sonda desta pasta, ritual parado sementes 1 a 3 e robô 1 a 4): feiticeiro fora do chão em no máximo 3% dos
  quadros de vida (hoje 25 a 32%), como o esqueleto (1%).
- Mesmo problema fora da luta [M]: besteiro (12 de 20 poses, até 0,28 m) e corredor (12 de 20, até 0,35 m) usam o mesmo
  `Running_B` com meio pulo. O corredor pode correr (é o papel dele, decisão de arte); o besteiro deve seguir o
  feiticeiro. Medir os dois com o mesmo critério.

### P1-2 O feiticeiro não pula ao terminar de se erguer (causa confirmada): gameplay-engineer

- Onde: `tools/bake.gd` `"rise"` do `mage` (`LayToIdle`, `"time": 0.9`) e `Horde._timers` (`RISE` termina em 0,9 s).
- O clipe tem de acabar de pé, na guarda do `idle` (cajado de pé na mão): estender o trecho do `LayToIdle` até ele ficar
  de pé, ou emendar os últimos 0,25 s indo para a pose da guarda dentro do assado; e a troca do `RISE` para o andar com
  mistura de 0,25 s (como o `RECOVER_FADE`), não 0,1.
- Critério (sonda): na saída do `RISE`, o centro do corpo desenhado sobe no máximo 0,05 m por quadro e no máximo 0,15 m
  no total depois do último quadro do `RISE` (hoje 0,50 m em 6 quadros); o alto da figura no máximo 0,2 m (hoje 1,0);
  nenhum giro acima de 8 graus por quadro nos primeiros 0,3 s (hoje 20 graus por quadro, 3 quadros). Mesmo critério
  para o erguer do esqueleto (passa hoje) e para todo `rise` novo.

### P1-3 Mistura de clipe sem degraus (causa confirmada): gameplay-engineer

- Onde: `scripts/render/crowd_renderer.gd` `add_kind` (ramo da mistura) e `assets/shaders/crowd_pose.gdshaderinc`
  `crowd_pose`.
- O alvo da mistura tem de ser a pose interpolada do clipe novo (a e próxima com a fração), não a pose mais perto.
  Sugestão: na mistura, a cor da instância leva `r` a pose de onde saiu, `g` a pose a do clipe novo, `b` a fração da
  mistura e `a` = `-(próxima + fração do clipe)` (negativo = modo mistura); o shader faz `alvo = mix(pose(g),
  pose(floor(-a)), fract(-a))` e `mix(pose(r), alvo, b)` (três leituras de textura só nas instâncias em mistura). Fora
  da mistura nada muda (`a` = 1).
- Critério (sonda `fadepop.py`, robô semente 1, 200 s): dentro das misturas, nenhum salto do centro desenhado em relação
  ao simulado acima de 0,12 m num quadro que não exista no próprio clipe (hoje 139 na entrada da foice, pior 0,55 m na
  invocação). Teste puro: com a mistura parada numa fração, o centro desenhado varia continuamente com `t`.

### P1-4 Morvath vira em vez de estalar (causa confirmada): gameplay-engineer

- Onde: `scripts/game/boss.gd`, os `e.dir = _dir` e `e.dir = (_dirs[0] + _dirs[1]).normalized()` no começo da foice,
  das Lâminas, da maldição e da investida.
- O rumo do ataque (`_dir`, os avisos) continua instantâneo (o aviso no chão não muda); só o corpo vira, até 720 graus
  por segundo, nos primeiros 0,15 s da preparação (a foice tem 0,8 s de preparo: sobra). Para isso o desenho precisa
  separar o rosto da mira como os comuns (`Enemy.face`) ou o `Boss` virar `e.dir` por passo.
- Critério (`morv.py`): nenhum giro do corpo desenhado acima de 15 graus num quadro em toda a luta (hoje 100 a 137
  graus, 2 a 4 por luta); o golpe sai na mesma hora (teste da foice em `slash3:7` continua).

### P1-5 Invocado respira antes de atacar (causa confirmada): gameplay-engineer

- Onde: `Horde._timers` ou `Horde.spawn`: com `rising`, a recarga não desconta durante o `RISE`, ou no fim do `RISE`
  `cooldown = maxf(cooldown, ARRIVE)` com `ARRIVE` 0,6 s (proposta; o `AFTER_RECOVER` de 0,25 s é o piso que já usamos).
- Critério (`spawn.py`, robô sementes 1 a 4): do fim do `RISE` à primeira preparação, no mínimo 0,6 s em 100% dos
  invocados (hoje mínimo 0,02 s). Dano por segundo dos invocados medido no robô antes e depois: queda esperada abaixo de
  10% (o Game Director decide se compensa em outro número).

### P2-1 Morvath olha o herói conjurando

`ERUPTIONS`, `SUMMON`, `STORM`, `RECOVER`: `e.dir` segue o herói a 2 por segundo (`slerp`). Critério: virado a mais de 90
graus do herói em no máximo 10% desses estados (hoje 20 a 45%). Não mexe nos avisos.

### P2-2 Erguer do esqueleto desliza 0,5 m

O `rise` do esqueleto (`Spawn_Ground_Skeletons`) anda o centro de -0,44 para -0,09 m (tamanho 1): meio metro de
deslize enquanto sobe. Critério: deriva do clipe até 0,15 m (`tools/pose_drift.gd`), como o `in_place` de Morvath.

### P2-3 Bote do esqueleto (observar no vídeo, sem correção agora)

2,5 m em 0,3 a 0,4 s a 8,75 m/s com os pés plantados no golpe: medido igual antes e depois do T5. Lê como bote. Se o PO
apontar o bote como "pulo" no vídeo, a correção é dar passos no bote (um passo largo no começo do `attack`), não
encurtar a distância (o aviso mostra até onde ele vai).

## 5. Ordem para o gameplay-engineer (pelo Game Director)

1. **P1-1** trote do feiticeiro (e besteiro) sem pulo, critério no assado e na luta. É a resposta ao relato do PO.
2. **P1-2** erguer do feiticeiro termina de pé e mistura de 0,25 s.
3. **P1-3** mistura de clipe interpolada no shader (vale para todos; remove os saltos de 0,3 a 0,55 m de Morvath).
4. **P1-4** Morvath vira em até 0,15 s em vez de estalar 100 a 137 graus.
5. **P1-5** invocado espera 0,6 s depois de levantar.
6. P2-1, P2-2; P2-3 só depois do vídeo.

Depois: rodar a mesma sonda (comandos na seção 3) e anexar os números aqui; vídeo 60 qps de um ritual (`--start=boss
--boss-hp=0.6 --hero-hp=9999`, 20 s) quando a GPU estiver livre, para o PO e o art-director (P1-1 precisa da aprovação
de arte do clipe novo).

## 6. Depois (gameplay-engineer, 2026-11-18)

Mesmas corridas da seção 3 (CPU sem tela, `--fixed-fps 60`, `--start=boss --nosave --hero-hp=9999`; ritual parado
`--boss-hp=0.6` sementes 1 a 3, 50 s; robô `--bot --bot-reaction=0.25` sementes 1 a 4 até a vitória) com
`tools/drawn_probe.gd` (a sonda da seção 3, agora no repositório, que lê a mistura nova como o shader). Números em
`docs/gallery/t5b/boss/after/` (`off_floor_summary.txt`, `fade_steps.txt`, `risen.txt`, `morvath_turns.txt`,
`baked_poses_size1.txt`; scripts novos em `after/data/`, duas corridas gravadas em `after/data/*.csv.gz`). O "antes" dos
scripts novos é a corrida `head_*` da seção 3. Quadro na GPU: `after/ritual_gpu.jpg`.

| Item | Antes | Depois | Critério |
|---|---|---|---|
| P1-1 trote do feiticeiro, assado (tamanho 1) | 14 de 20 poses acima de 0,10 m, vértice mais baixo até 0,30 m | 0 de 20, até 0,09 m; sobe e desce 7,4 cm; 136 passos por minuto, escorrega 2,9 cm | 6 de 20, 0,15 m, 7 cm (aceito 7,5: o do esqueleto aprovado é 8,6) |
| P1-1 besteiro, assado | 12 de 20, até 0,28 m | 2 de 20, até 0,12 m; 7,3 cm; 127 passos por minuto | o mesmo |
| P1-1 feiticeiro fora do chão na luta | 25 a 32% dos quadros | 0% (6 a 13 quadros por luta, golpes e quedas) | 3% |
| P1-2 saída do `RISE` do feiticeiro | sobe 0,077 m/quadro, 0,52 m no todo, alto da figura 1,03 m, 20 graus por quadro | 0,022 m/quadro, 0,11 m, 0,19 a 0,20 m, 8 graus | 0,05 / 0,15 / 0,2 / 8 |
| P1-2 o `rise` termina na guarda (todos) | feiticeiro a 0,40 m da guarda, cajado deitado | 0,04 m (todos entre 0,04 e 0,22), alto da figura igual ao do `idle` | |
| P1-3 saltos dentro das misturas (`fadestep.py`: acima de 0,12 m e do próprio clipe + 0,02) | robô s1: 55 quadros, pior 0,55 m (invocação); ritual s1: 59, pior 0,53 m | robô s1 a s4: 6, 20, 21, 26 quadros, pior 0,38 m (Morvath voltando ao andar, o clipe sozinho faz 0,25); ritual: 0 | nenhum acima do clipe |
| P1-4 giro de Morvath | até 137 graus num quadro, 25 quadros acima de 15 (robô s1) | 12 graus por quadro no máximo, nenhum acima de 15, nas 7 corridas | 15 |
| P1-5 do fim do `RISE` à primeira preparação | mínimo 0,02 s, p10 0,10 a 0,45 | mínimo 0,60 s, p10 0,62 a 0,67 | 0,6 s |
| P2-1 Morvath de costas para o herói (mais de 90 graus) | erupções 20 a 45%, invocação 0 a 54%, tempestade 20 a 37%, recuperação 19 a 34% | erupções 0 a 4%, invocação 0 a 10%, tempestade 0 a 3%, recuperação 0 a 4% | 10% |
| P2-2 deriva do erguer do esqueleto | 0,46 m | 0,23 m (`BakedModel.drift`) | 0,15 (não alcançado, ver abaixo) |

O que mudou:
- `tools/bake.gd`: feiticeiro e besteiro no `Jog_Fwd` com os pés travados (`MAGE_JOG`, `CROSSBOW_JOG`; saíram `MAGE_TROT`
  e `CROSSBOW_TROT`; o corredor continua no `Running_B`, é o papel dele). `rise` comum com `in_place`; feiticeiro e
  ancião (`STAFF_RISE`) e Cavaleiro (`SHIELD_RISE`) com a opção nova `"settle"`: os últimos 0,45 s do clipe vão para a
  primeira pose do clipe da guarda (cajado de pé, escudo à frente). Reassados os oito comuns (Morvath não mudou).
- `CrowdRenderer.add_kind` e `crowd_pose.gdshaderinc`: na mistura, o alvo é a pose interpolada do clipe novo, pela cor
  da instância com alfa negativo (`CrowdRenderer.fade_target` / `fade_pick`; o código cabe na meia precisão do
  Compatibility, testado). Fora da mistura nada muda. `Horde.BOSS_CLIP_FADE` 0,12 para 0,18 (do fim da foice, da
  tempestade e do atordoamento para a guarda o corpo cruzava 0,13 a 0,16 m por quadro).
- `Horde`: no fim do `RISE`, `cooldown = max(cooldown, ARRIVE)` (0,6 s), a mistura de saída do `rise` em `RISE_FADE`
  0,25 s e o giro do corpo limitado a `RISEN_TURN` 480 graus/s por `RISEN_TIME` 0,3 s.
- `Boss`: o corpo desenhado (`Enemy.face`) vira até `BODY_TURN` 720 graus/s para `e.dir` (o rumo do ataque e os avisos
  continuam instantâneos; a foice acerta em `slash3:7` como antes); em erupções, invocação, tempestade e recuperação
  `e.dir` segue o herói a `FOLLOW_RATE` 2.

Testes: `tests/test_t5b_fight.gd` (trote no chão de feiticeiro, besteiro e esqueleto; todo `rise` termina de pé na
guarda; erguer do esqueleto no lugar; código da mistura, também em meia precisão; o corpo na mistura anda com o clipe
novo; o invocado espera `ARRIVE`, mistura em `RISE_FADE` e vira devagar) e `tests/test_boss_body.gd` (nenhum giro de
Morvath acima de 15 graus por quadro na luta inteira).

Pendências:
- P2-2: o erguer do esqueleto ainda anda 0,23 m (o `in_place` prende o quadril, o resto é o corpo deitado se dobrando
  para ficar de pé); meta 0,15 não alcançada, sem efeito visível nas sondas (sobe 0,02 m depois do `RISE`).
- Restam degraus pequenos em Morvath ao entrar no arremesso depois da invocação (`summon:2 > volley`, 0,19 a 0,20 m
  contra 0,14 do próprio clipe, 12 a 20 quadros por luta) e ao voltar ao andar (0,29 a 0,38 contra 0,25): são as
  poses de partida longe da guarda, não o alvo da mistura.
- Maldição: com o corpo virando (P1-4), em uma luta (semente 1) ele ficou de costas 23% dos quadros da maldição
  (a maldição dura pouco; o arremesso sai na direção certa, só o corpo atrasa até 0,25 s).
- P1-5: dano por segundo dos invocados antes e depois não medido separadamente; o robô venceu as 4 lutas.
- P1-1 precisa da aprovação de arte do clipe novo (art-director) e do vídeo 60 qps do ritual pedido na seção 5.
- P2-3 (bote do esqueleto) sem mudança, como pedido.
