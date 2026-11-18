# T5: movimento e preparação dos inimigos e de Morvath (combat-feel-director, 2026-11-17)

Relatos do PO jogando: (1) **P0** "os inimigos mostram o aviso vermelho, mas não parecem preparar fisicamente o
ataque"; (2) **P1** "o esqueleto da primeira sala está andando tremendo"; (3) **P1** "os esqueletos do Sacerdote dos
Mortos (invocados) correm de forma artificial, lembrando uma gazela". Diagnóstico e especificação; nada de código de
jogo foi alterado. A especificação de correção, com números e critérios de aceite, está em
`docs/design/combat_cadence.md`, seção 6 (T5). Evidências em `docs/gallery/t5/motion/before/`.

Legenda: **[M]** medido (fonte e FPS), **[O]** observado em imagem, **[C]** lido no código, **[I]** inferência,
**[H]** Hades II (`docs/design/hades2_feel_study.md`). "f" = quadro a 60 por segundo.

## 1. Como foi medido

Commit `5dfe97f` (árvore limpa). A GPU estava ocupada por outro agente: nada de `tools/gpu.sh`; tudo sem tela ou na
CPU (OpenGL no Xvfb).

1. **Sonda de jogo** (`data/t5_probe.gd.txt`, cópia; rodar como `-s <arquivo>.gd`): joga o jogo real com
   `--fixed-fps 60` sem tela e grava, a cada passo da `Horde`, por inimigo: estado, `state_t`, clipe pedido e **clipe e
   pose desenhados** (decodificados do `drawn_row` do `CrowdRenderer`), posição, velocidade real suavizada, ângulo
   desenhado (`Enemy.yaw()`), distância ao herói, aviso no chão (vida e total da `Zone`), sons tocados (`Audio.listen`)
   e, com Morvath, o estado do `Boss` e todas as zonas de aviso com a fonte. Roteiros:
   - herói parado na loja com 3 do tipo (`--start=shop --stress=3 --stress-ids=<id>`, 25 s, vida 99999), para cada
     comum e elite, mais Cavaleiro e ancião (1 cada);
   - **a primeira sala de verdade** (`--play --seed=1..4 --hero-hp=9999`, 40 s, herói parado onde entra) e com o robô
     (`--bot --bot-reaction=0.25 --seed=1..3`, 50 s);
   - Morvath por ataque (`--start=boss --boss-only=<ataque> --hero-hp=9999`, fases 3 e 4 com `--boss-hp=0.3` e
     `0.12`; a investida com `--bot --bot-kite=0.9`).
   Análise: `data/an.py` (tremor no andar), `data/cyc.py` (ciclos de ataque), `data/bt.py` (linha do tempo de Morvath).
   Saídas: `data/cycles.txt`, `data/jitter_*.txt`, `data/morvath_*.txt`, CSV comprimidos.
2. **Poses assadas** (`data/pose_metrics.gd.txt`, saída `data/pose_metrics.txt`): para cada clipe de cada figura, por
   pose, o alto da figura, o quanto ela difere do `idle` e a **velocidade média dos vértices** até a pose seguinte
   (m/s de jogo, tamanho 1). É o "índice de movimento": um `idle` fica entre 0,03 e 0,19 m/s de pico.
3. **Andar** (`data/walk_metrics.gd.txt`): em cada pose do andar assado, o vértice mais baixo (pés no ar se acima de
   3 cm), o sobe e desce do corpo e a inclinação do tronco.
4. **Imagens na CPU** (OpenGL, Xvfb): `tools/walk_strip.gd` (andar sobre o xadrez de 0,5 m, 24 quadros a 30 qps) e
   `tools/enemy_lab.gd` (clipe espalhado numa fileira, vista de lado). `tools/clip_probe.gd` para a mão da arma nos
   clipes candidatos.

## 2. Resposta direta aos três relatos

### 2.1 "Aviso vermelho sem preparação física" (P0): confirmado em 7 de 9 figuras

Índice de movimento do clipe de preparação [M] (pico da velocidade média dos vértices, m/s, tamanho 1; `idle` de
referência 0,03 a 0,19; golpes de verdade 6 a 10):

| Figura | Clipe da preparação (o que o jogo toca) | Pico | Leitura |
|---|---|---|---|
| Esqueleto | `windup` = `Sword_Attack` 0,1 a 0,3 s esticado em 0,9 s | 0,30 | só o braço sobe (a mão de 1,4 a 1,74 m), tronco e pernas parados, câmera lenta de 4,5x |
| Corredor | `windup` = `Crouch_Idle` em laço | **0,04** | estátua agachada (com o tremor de 4 cm do `windup_shake`) |
| Feiticeiro (e elite) | `cast` = `Spell_Simple_Idle` em laço | **0,03** | estátua de cajado erguido |
| Besteiro (e elite) | `aim` = `Pistol_Idle` em laço | **0,01** | sobe a besta em 0,1 s (a mistura) e congela 0,7 s |
| Escudo | `brace` = `Shield_Dash_RM` 0 a 0,3 s em 1,15 s | 0,62 | agacha e põe o escudo à frente: **lê**, mas devagar |
| Escudo, golpe curto | `attack` esticado (0 a 0,6 s do `Sword_Attack`) | (do golpe) | ergue a espada: **lê** |
| Sacerdote | `cast` = `Spellcast_Summon` 1,0 a 3,05 s em 0,8 s | 2,77 | **lê** (ajoelha e ergue as mãos) |
| Cavaleiro (investida) | **`idle`** (não tem `brace`) [C] `horde.gd` `_behave_knight` | 0,08 | parado em pé 1,0 s com a faixa no chão |
| Ancião | `cast` = `Spell_Simple_Idle` | **0,03** | estátua |
| Morvath, Lâminas e Investida | `dash_windup` = `2H_Melee_Idle` em laço (o mesmo nos dois) | **0,14** | guarda parada; as duas preparações são iguais |

E os golpes que "saem" sem gesto [M]: feiticeiro `attack` 0,70, besteiro 0,48, sacerdote 0,32, ancião 0,73 m/s de pico;
o feiticeiro elite solta 7 orbes em 1,2 s e o clipe do tiro acaba no 2º (fica 1,4 s parado na última pose enquanto os
orbes saem, `data/cycles.txt`, `mage_elite`).

Recuperação congelada [M]: o esqueleto fica em `RECOVER` 2,1 s (127 f), mas o clipe do golpe acaba 0,34 s depois do
começo dela (1,4x) e a última pose fica **parada 1,76 s**; elite 1,5 s, 1,16 s parado. Escudo e Cavaleiro seguram a
última pose do golpe 1,1 s e 0,8 s. É o "congelar o modelo" que o PO não quer.

Sincronia do dano com o corpo [M] (o dano dos inimigos de perto é o aviso no chão que "aterra", não o corpo):

| Ataque | Quando o dano sai | Onde está o corpo nessa hora | Fonte |
|---|---|---|---|
| Esqueleto (bote) | 62 f depois do começo da preparação (0,15 s dentro do bote) | até **2,4 m** do herói quando começou a 3,6 m (`dland 2.43`) | `cycles.txt`, `skel_idle.csv` |
| Corredor (explosão) | no último quadro da preparação | o soco (`Punch_Cross`, um braço para frente) começa **depois** do dano; a explosão é em volta | `st_runner` |
| Escudo (investida) | no último quadro da preparação (f+68) | **3,5 m** longe: o corpo só chega 0,23 s depois (13 f) | `st_guard.csv.gz` f130 a f145 |
| Cavaleiro (investida) | no fim da preparação [C], o mesmo código do Escudo | até 14 m longe | `horde.gd` `_behave_knight` |
| Morvath, investida | quando a faixa aterra, no começo da corrida | **até 15,7 m** longe (corre 0,42 s depois) | `morvath_dash2.txt` f723 |
| Morvath, foice | quando o aviso aterra, na pose mais alta (`slash3:6`) | a lâmina desce nos 10 quadros **seguintes** (`slash3:6` a `:9`) | `morvath_scythe.txt` f328 |

O som está no lugar [M]: preparação no 1º quadro (`tell_*`), sopro do golpe no 1º quadro do ataque, `hurt` no quadro do
dano. O problema é o corpo e a hora do dano, não o som.

Causa provável (confirmada no código e nas poses): os clipes de preparação foram escolhidos por existirem no rig e
pela duração, e não por comunicarem o ataque; boa parte são `idle` de outra coisa (laços quase parados). Quando o
golpe é de corpo, o dano foi posto no aviso para ele bater com o fim do preenchimento, e o corpo chega depois.

### 2.2 "Esqueleto da primeira sala andando tremendo" (P1): confirmado, causa na IA de espera, não no clipe

Medido na primeira sala de verdade com o herói parado onde entra (perto da borda do patamar), semente 2 [M]
(`data/jitter_r1i_s2.txt`, `r1i_s2.csv.gz`, f600 a f642):

- O esqueleto #2 fica **pronto para atacar** (recarga vencida há 7 s) a 1,0 a 1,36 m do herói, mas dois outros já
  atacam (`max_attackers` 2). No ramo de espera do `_behave_runner` [C] ele anda em círculo a 0,8 da velocidade e, abaixo
  de `0,6 x attack_range` (2,2 m), **para fora** (`toward * -0.5`).
- O `_way` [C] troca `straight` a cada 0,09 a 0,15 s (`WAY_EVERY` 0,12) porque a distância cruza `WAY_NEAR` 1,2 m e, perto
  da parede, a grade de navegação não vê linha livre: `straight` = círculo para fora, não `straight` = campo de fluxo
  **para dentro**. Ele vai e volta a cada ~10 quadros.
- `_drawn_motion` [C] vira o corpo para a velocidade quando ela passa de 60 graus do rosto (`FACE_SPLIT`, sem
  histerese) a 1200 graus/s: **20 graus por quadro**, varrendo 100 graus em 5 quadros, para um lado e para o outro
  (35 quadros com mais de 8 graus por quadro em 8,4 s andando, 1,07 inversões por segundo).
- O andar e o parado trocam com um quadro de `idle` no meio (a velocidade passa por baixo de 0,3 m/s na virada): cada
  troca dispara uma mistura de 0,1 s (`CLIP_FADE`) e volta.
- Separação [C] `_separate` só a cada 2 quadros (`(i + _frame) % 2`): com corpos encostados a posição alterna 3 cm
  quadro a quadro (f560 a f600: x -10,985, -11,018, -11,003, -11,036...), 1,4 a 3,5 inversões por segundo.

Pior caso (herói caído no chão, todos esperando: `jitter_room1_dead_s2.txt`): 217 quadros acima de 8 graus, 5,9
inversões por segundo, 2,8 trocas andar/parado por segundo. Com o robô se movendo o tremor quase some (0 a 0,6
inversões por segundo): **é o esqueleto que espera perto de um herói parado ou encostado** (o PO parado na entrada da
primeira sala, com 4 esqueletos e 2 atacando por vez). Não é o clipe, nem raiz no clipe (deriva abaixo de 0,45 em todo
clipe), nem a passada.

### 2.3 "Esqueletos invocados correm como gazela" (P1): confirmado, é o andar do esqueleto (todos), mais visível nos invocados

Os invocados do ancião e de Morvath são o mesmo `skeleton` (`Horde._behave_priest`: `def(&"skeleton")`), com o mesmo
andar `Running_B` do KayKit assado com `SOLDIER_RUN` (`lock`, `stride` 0,68, `lift` 0,5) [C]. Medido no andar assado [M]
(`walk_metrics`, tamanho 1):

- **Pés no ar em 16 de 20 poses** (os dois acima de 3 cm; o pé de trás sobe até 25 cm, 29 cm em jogo): o apoio é 20%
  do ciclo; uma corrida a 3,75 m/s tem 30 a 40% de apoio [I].
- Tronco **a prumo** (3 a 5 graus) com o pé de trás chutado até a altura do quadril e a perna da frente esticada com a
  ponta do pé para baixo [O] (`skeleton_run_side_24f.jpg`, `walk/skeleton_walk.jpg`); o corredor, no mesmo clipe, tem
  16 a 19 graus de inclinação e não lê assim.
- Sobe e desce do corpo 11 cm (13 cm em jogo) a 149 passos por minuto, braço da espada travado na guarda (não balança).

Tronco duro e vertical + coice alto do pé de trás + 80% do tempo no ar = o pulo saltitante da gazela. O "meio pulo"
(`lift` 0,5) e a passada curta (`stride` 0,68, que encurta o passo sem tirar a perna alta do clipe de corrida) somam.
Os invocados mostram mais porque saem a 3,5 m do herói e correm reto pelo chão aberto, a toda velocidade, na frente da
câmera; os da primeira sala o PO vê mais esperando (ver 2.2).

## 3. Por figura: preparação, golpe, dano e recuperação (60 f/s, [M] salvo indicado)

| Figura | Aproximação | Preparação (f) e clipe | Ataque (f) e clipe | Dano | Recuperação (f) | Classe |
|---|---|---|---|---|---|---|
| Esqueleto (e elite) | corre 3,75 m/s (elite 4,75), para no começo da preparação | 54, `windup` (só o braço, pico 0,30) | 18, `attack` do alto (desce nos 6 primeiros f) | aviso aterra a +62 f, corpo a até 2,4 m | 127 (elite 91), 1,76 s (elite 1,16) **parado** | P0 preparação, P1 sincronia, P1 recuperação |
| Corredor (e elite) | 4,9 m/s (elite 7,4) | 42, `Crouch_Idle` (0,04) | 25, `Punch_Cross` (soco para frente) | no último f da preparação, antes do soco | 81 (elite 31) com o fim do soco | P0 preparação, P1 gesto e sincronia |
| Feiticeiro (e elite) | 3,5 m/s | 60, `Spell_Simple_Idle` (0,03) | 3 orbes (elite 7) com um tiro de clipe só | orbe | 48 | P0 preparação, P1 tiro sem gesto |
| Besteiro (e elite) | 3,6 m/s | 48, `Pistol_Idle` (0,01), subida da besta em 6 f | 26, `Pistol_Shoot` (0,48) | virote | 36 | P1 (a mira parada é aceitável; a subida em 0,1 s não) |
| Escudo (e elite) | 3,25 m/s | investida: 69, `brace` (0,62); golpe curto: 39, `attack` esticado | investida 25 f desenhada com o **golpe de espada** do meio do clipe; curto 31 | investida: no último f da preparação, corpo a 3,5 m; curto: no fim da preparação (casa) | 66, última pose parada | P1 investida (clipe e sincronia), P2 golpe curto |
| Sacerdote (e elite) | parado | 48, `cast` (2,77) | 25, `Spell_Simple_Shoot` (0,32) | trepadeira | 0 (volta ao `idle`) | P2 (prep. boa, tiro fraco) |
| Cavaleiro | 2,5 m/s | investida: 60, **`idle`** [C]; golpe curto: 48, `attack` esticado | investida com `attack`; curto 31 | investida no fim da preparação [C] | 48 parado | **P0** investida |
| Ancião | 2,0 m/s | 60, `Spell_Simple_Idle` (0,03) | 31, tiro (0,73) | leque de orbes / ergue esqueletos com o mesmo gesto | 0 | P1 |
| Elites | as mesmas figuras e clipes; só mudam velocidade, recuperação e armadura | | | | | herdam |

Morvath (`data/morvath_*.txt`):

| Ataque | Preparação | Golpe | Dano x corpo | Recuperação | Classe |
|---|---|---|---|---|---|
| Foice | 0,8 s: `slash3` erguido devagar até o alto (lê bem) | `slash3:6` a `:9` em 10 f | aterra no quadro do alto, **10 f antes** de a lâmina descer | 0,84 s com o resto do clipe | P1 sincronia |
| Lâminas das Almas | 0,7 s: `dash_windup` parado 0,53 s, depois o arremesso (solta no quadro do tiro, ok) | `slash2` | meias-luas no quadro da soltura (ok) | 0,8 s | P1 preparação igual à investida e parada |
| Investida | 0,8 s: `dash_windup` parado | `dash` | **no começo da corrida, até 15,7 m antes do corpo** | 1,1 s | **P0** sincronia, P1 preparação |
| Maldição | 0,76 s: `summon` (o começo do invocar) | `volley` solto no quadro do tiro | projétil | 0,6 s | P2 (o mesmo gesto do invocar) |
| Erupções | `rain` 1,15 s na 1ª leva | a 2ª leva com `rain:13` **parado** 1,1 s | círculos no chão | `idle` | P2 |
| Invocação | `summon` 1,55 s | | runas | 0,53 s | ok |
| Tempestade | `rain` 0,82 s por onda, `volley` na 1ª meia-lua, `roar` no fim | | faixas | | ok |
| Rugido, ritual | não medidos nesta rodada | | | | pendente |

## 4. Correções priorizadas (para o gameplay-engineer, pelo Game Director)

Números, clipes e critérios em `docs/design/combat_cadence.md` 6.3 a 6.6. Ordem:

1. **P0** Preparação física de todo comum, elite e Cavaleiro (T5-01 a T5-07): clipes novos no assado
   (`tools/bake.gd` `MODELS`, só clipes CC0 que já temos: UAL 1 e 2, KayKit `Skeleton_Warrior.glb`), uma preparação
   em três tempos (assentar, armar, segurar com o tremor dos últimos 0,3 s) desenhada pelo `Horde.render`, critério
   objetivo de movimento (pico de vértices de 1,0 m/s ou mais e pose final diferente da guarda). Cavaleiro ganha
   `brace` e corrida de escudo.
2. **P0** Dano no corpo, não no aviso, nas investidas (Escudo, Cavaleiro, Morvath) e no bote do esqueleto (T5-08,
   T5-09): o aviso fica só desenho; o dano sai no contato do corpo (ou no quadro da lâmina) e uma vez por ataque.
3. **P1** Esqueleto que espera não treme (T5-10): anel de espera com histerese, sem campo de fluxo perto do herói,
   histerese no rosto e no andar/parado, separação todo quadro.
4. **P1** Corrida do esqueleto sem "gazela" (T5-11): outro clipe ou o mesmo com passada e meio pulo novos, tronco
   inclinado, pés no chão em pelo menos 35% do ciclo.
5. **P1** Recuperações vivas (T5-12): nenhum corpo parado mais de 0,3 s numa recuperação.
6. **P1** Tiros com gesto por tiro (T5-13), foice de Morvath com o dano na descida (T5-14), preparação própria das
   Lâminas e da Investida de Morvath (T5-15).
7. **P2** Corredor com explosão em volta (gesto), Escudo, maldição e erupções de Morvath, besta (T5-16 a T5-19).

## 5. Limites desta medição

- Sem vídeo na GPU (ocupada); as imagens são da CPU e dos laboratórios, que desenham pelo mesmo `CrowdRenderer`. O
  tremor em movimento foi medido, não assistido; o Game Director pode pedir um vídeo `tools/movie.sh` do roteiro
  `--play --seed=2 --hero-hp=9999` entre 9,5 e 11 s quando a GPU estiver livre.
- O dano "à distância" foi medido com o herói parado; com o herói esquivando ele aparece menos, mas a regra é a mesma.
- Rugido, ritual, troca de fase e a reação ao golpe (atordoamento) não foram refeitos nesta rodada (ver seções 1.3 e
  1.4 do `combat_cadence.md`).

## 6. Depois (T5 implementado pelo gameplay-engineer, 2026-11-17)

Mesmas medidas, mesmas sementes. Ferramentas que entraram no projeto: `tools/clip_motion.gd` (poses assadas: pico,
pose armada, andar; saída em `docs/gallery/t5/motion/after/data/clip_motion.txt`), `tools/enemy_motion_probe.gd` (a
sonda do diretor, agora com o canal de cada golpe no herói, raio, alcance da lâmina, preparação e `windup_hold`) e
`tools/enemy_motion_probe.py` (lê os CSV e imprime tremor, golpes x corpo x aviso e a maior pose parada na preparação e
na recuperação; relatórios em `after/data/`). Teste novo `tests/test_enemy_windup.gd` com os critérios do 6.1.
Quadros: `docs/gallery/t5/motion/after/lab_*_side.jpg` (CPU, `tools/enemy_lab.gd`), comparação antes e depois por
figura em `after/sheet_*.jpg` (para o art-director) e a corrida em `after/walk/` e `after/sheet_skeleton_walk.jpg`.

### 6.1 Preparação (critério: pico 1,0 m/s ou mais desenhado, pose armada 0,30 m ou mais, tamanho 1)

Pico do clipe assado / pico desenhado (o clipe tocado por `Horde.windup_arm` entre o fim do assentar e o começo do
segurar, com a curva suave: comprimento do clipe / tempo de armar x 1,5) / pose armada:

| Figura | Antes | Depois (clipe) | Pico do clipe | Pose armada |
|---|---|---|---|---|
| Esqueleto | 0,30, braço só | `Sword_Attack` 0 a 0,35 s com o tronco enrolando para trás e para a lâmina | 6,04 | 0,31 |
| Corredor | 0,04, `Crouch_Idle` | `Jump_Start` 0,18 a 0,33 s (agacha, braços para trás) e o giro `2H_Melee_Attack_Spinning` no ataque | 5,07 | 0,34 |
| Feiticeiro | 0,03, laço | `Spell_Simple_Enter` (o cajado sobe, tronco recua), segura em `Spell_Simple_Idle` | 1,56 | 0,33 |
| Besteiro | 0,01 (sobe em 0,1 s) | a besta sobe ao ombro no assentar de 0,25 s (`windup_settle`) e segura | 0,30 m em 0,25 s = 1,2 | 0,30 |
| Escudo | 0,62 | o mesmo `brace` (lia), agora armado em três tempos | 0,62 no clipe, 1,0 ou mais desenhado (teste) | 0,44 |
| Sacerdote | 2,77 | igual (lia) | 2,77 | 0,44 |
| Cavaleiro | 0,08, `idle` | `brace` próprio (`Shield_Dash_RM` 0 a 0,3 s) | 3,33 | 0,51 |
| Ancião | 0,03 | `Spell_Simple_Enter`; ao erguer os mortos o `Spellcast_Summon` (`summon`) | 1,62 / 6,03 | 0,34 / 0,82 |
| Morvath, Investida | 0,14 (igual às Lâminas) | `Sword_Dash_RM` 0 a 0,12 s, tronco para frente | 11,85 | 0,71 |
| Morvath, Lâminas | 0,14 | `Sword_Regular_B` 0 a 0,2 s em duas mãos, tronco para trás | 4,92 | 0,71 |

As duas preparações de Morvath ficam 0,30 m ou mais uma da outra (teste). Tremor (`windup_shake`) só no segurar.
Maior pose parada na preparação antes do segurar (sonda, `play_s1-4` e robô `bot_s7`): 0,13 a 0,30 s em todas as
figuras (critério 0,3).

### 6.2 Dano x corpo e aviso x dano

| Ataque | Antes | Depois |
|---|---|---|
| Bote do esqueleto | dano do aviso, até 2,4 m do corpo | lâmina do corpo no quadro em que ele chega (`strike_at` 0,1 s no bote): 1,00 a 2,00 m do centro, alcance 2,21; 100% dentro (110 golpes, sementes 1 a 4); aviso enche no quadro do golpe: 109 de 110 em 0 f, 1 em 1 f |
| Investida do Escudo e do Cavaleiro | no fim da preparação, corpo a 3,5 m | contato varrido do corpo, uma vez por investida (teste: 1,20 m do centro, corpo 1,25; aviso termina no mesmo quadro ou 1 antes); robô: Cavaleiro a 1,60 m varrido no quadro (corpo 1,55), aviso -1 f |
| Investida de Morvath | até 15,7 m antes do corpo | contato do corpo (`Ground.strike`, `last_source` dash): 1,81 m do centro, corpo 1,90; a faixa enche até o quadro do contato (0 f) |
| Foice de Morvath | no alto, 10 f antes da descida | aviso + 0,07 s (`SCYTHE_HIT`): dano em `slash3:7` em 9 de 9 golpes |
| Explosão do corredor | antes do soco | aviso até `strike_at` (0,1 s no giro, os braços abrindo) |

### 6.3 Esqueleto que espera (sondas `--play --seed=1..4 --hero-hp=9999`, herói parado)

| Medida (por esqueleto em WALK) | Antes (semente 2) | Depois (sementes 1, 2, 3, 4) | Critério |
|---|---|---|---|
| Quadros com mais de 8 graus de giro | 35 em 8,4 s (42 por 10 s) | 0 / 0 / 0 / 2,4 por 10 s | 1 por 10 s fora da troca de alvo |
| Inversões de giro | 1,07/s | 0,00 / 0,03 / 0,00 / 0,21 | 0,3/s |
| Trocas andar/parado | até 0,62/s | 0,15 / 0,14 / 0,18 / 0,14 | 0,5/s |
| `idle` de 1 a 3 quadros | vários | 0 | nenhum |
| Inversões de posição de 2 quadros | até 3,46/s | 0,00 / 0,07 / 0,00 / 0,03 | 0,2/s |

Na semente 4 os giros restantes são o virar para o herói depois de outra coisa (troca de alvo), não pisca. Causas
tratadas: separação todo quadro com metade da força (`Horde.SEPARATE`), histerese no rosto (`FACE_SPLIT` 70, `FACE_BACK`
45, e quem tem passo lateral só vira acima de `FACE_SPEED` 1,2 m/s), troca andar/parado só depois de 0,15 s (`STAND_AFTER`)
ou 0,10 s (`WALK_AFTER`), linha reta mantida até 3 m (`WAY_NEAR` 2,5, `WAY_FAR` 3), anel de espera a 0,75 do alcance
com folga e passo lateral para o mesmo lado por 1,2 s no mínimo, a no máximo `RING_SPEED` 1 m/s (andava a 2,5 m/s para
fora e virava de costas), passos laterais e de costas próprios (`strafe_l`, `strafe_r`, `back` do KayKit) olhando o
herói, e o fim da recuperação virando para ele a 360 graus/s (`RECOVER_TURN`; antes um estalo de 20 graus por quadro).
Fora do escopo do T5-10 e anotado: com o robô, besteiros, feiticeiros e o Cavaleiro giram ao fugir e voltar (giros
legítimos de quem foge), o esqueleto elite pisca `idle` 11 vezes (ver 6.6).

### 6.4 Corrida do esqueleto (`walk_metrics` em `clip_motion.txt`, tamanho 1; em jogo x 1,15)

| Medida | Antes (`Running_B`, `SOLDIER_RUN`) | Depois (`Jog_Fwd`, `SOLDIER_JOG`) | Critério |
|---|---|---|---|
| Os dois pés no ar | 16 de 20 poses | 5 de 20 | 6 de 20 |
| Pé levantado mais alto | 29 cm em jogo | 30 cm em jogo (0,26 m; medida nova, pernas separadas da lâmina) | 15 cm |
| Sobe e desce | 13 cm em jogo | 10,6 cm em jogo (0,092 m) | 7 cm |
| Tronco | 3 a 5 graus | 13 a 17 graus | 8 a 15 |
| Passos por minuto | 149 | 161 | 160 a 170 |
| Escorregamento | 0,5 cm | 3,0 cm | 5 cm |

Três de seis no critério, os outros perto. O `Jog_Fwd` chuta o pé de trás alto por si; o assado ganhou a opção
`"plant"` (o corpo desce, por pose, essa parte do caminho até o ponto mais baixo da própria pose: no voo ele fica perto do
chão), que tirou os pés do ar (16 para 5) sem deixar escorregar. Testadas e piores: `Running_A`, `Running_B`, `Running_C`
e `Sprint` com `plant` (pés no ar 12 a 18, tronco de -35 a 43 graus). O resto (pé e sobe e desce) pede um clipe de trote
mais contido que as bibliotecas CC0 não têm, ou a decisão do Daniel na 6.4 do `combat_cadence.md` (andar a 2 m/s perto).
Para o art-director aprovar: `after/sheet_skeleton_walk.jpg`.

### 6.5 Recuperação e tiros

- Maior pose igual desenhada em `RECOVER` (sondas e robô): 0,00 a 0,28 s em todas as figuras (antes 1,76 s no esqueleto,
  1,1 no Escudo, 0,8 no Cavaleiro). O resto do golpe toca no ritmo do próprio clipe e depois a guarda (mistura de 0,3 s);
  Escudo e Cavaleiro depois da investida: `Idle_Shield_Break` (o escudo baixando). Entre o fim da recuperação e a próxima
  preparação, pelo menos 0,25 s (`AFTER_RECOVER`).
- Tiro por orbe (T5-13): feiticeiro `shot` (o `Spell_Simple_Shoot` inteiro em 0,17 s, recomeçado a cada orbe) com pico
  1,57 m/s (critério 1,5), sacerdote elite `Spellcast_Shoot` do KayKit em 0,3 s por trepadeira, 5,42 m/s; o cajado desce
  (`Spell_Simple_Exit`) na recuperação.

### 6.6 O que ficou

- T5-11: pé levantado e sobe e desce acima do critério (ver 6.4).
- P2 não feitos: gesto próprio da maldição (T5-17), trecho das mãos nas erupções (T5-18), recuo da besta (T5-19). O
  corredor (T5-16) ganhou o giro.
- O primeiro quadro da preparação do corredor (`Jump_Start` 0,18 s) tem um joelho erguido; o assentar mistura do
  andar para ele em 0,12 s.
- Esqueleto elite com 11 `idle` curtos sob golpes na armadura (fora do T5-10, que mede o comum).
- Vídeo na GPU a 60 qps para o PO e o art-director: não feito (a GPU estava com outro agente).

## 7. Revisão do combat-feel-director (2026-11-17, `24c298e`)

Refeito na CPU, sem tela, com `--fixed-fps 60` (a GPU estava com o qa-performance), com os mesmos roteiros e sementes:
`tools/enemy_motion_probe.gd` em `--play --seed=1..4 --hero-hp=9999` (40 s), robô `--bot --bot-reaction=0.25
--seed=1,2,3,7` (50 s), loja `--start=shop --stress=3 --stress-ids=<id>` para esqueleto, corredor, mago, besteiro,
Escudo, sacerdote, esqueleto elite e Escudo elite (`--stress=1` para Cavaleiro, ancião, mago elite e corredor elite;
25 s), Morvath `--boss-only=scythe|blades` e a investida com `--bot --bot-kite=0.9 --bot-reaction=0.6`; poses por
`tools/clip_motion.gd`; testes `test_enemy_windup` (7/7) e `test_enemy_motion` passam. Relatórios em
`docs/gallery/t5/motion/after/data/review/` (`play_report.txt`, `bot_report.txt`, `st_report.txt`, `clip_motion.txt`,
`archer_flee_bot_s2.txt`). Os números do implementador se repetem (as sementes 1 a 4 dão os mesmos golpes, agora todos
com o aviso em 0 f). Legenda: [M] medido aqui, [O] observado nas imagens de `after/`, [I] inferência.

### 7.1 Veredito por item

| Item | Veredito | Evidência |
|---|---|---|
| T5-01 preparação em três tempos | **Aprovado** | [M] maior pose parada antes do segurar: 0,13 a 0,28 s em toda figura que atacou (critério 0,3); tremor só no segurar (teste) |
| T5-02 esqueleto (comum, elite, invocado) | **Aprovado com ressalva** | [M] armar a 1,0 a 1,7 m/s por pose e 6,04 no último passo; pose armada 0,31 (no limite de 0,30). **Fora do critério**: alto da pose armada 1,85 m (tamanho 1; o `idle` tem 1,91; pedido 2,1): a lâmina vai para trás por cima do ombro, não acima da cabeça, e o tronco gira uns 90 graus no último décimo do clipe (pose 8 para 9) [O] `lab_skeleton_windup_side.jpg`. Lê como armado, mas pede olho humano |
| T5-03 feiticeiro e ancião | **Aprovado** | [M] 1,56 e 1,62 m/s, 0,33 e 0,34 m; o erguer dos mortos 6,03 e 0,82. Mago elite e sacerdote não atiraram no roteiro da loja (sem linha de tiro ou fora da tela): medidos só pelo clipe e pelo teste |
| T5-04 / T5-16 corredor | **Aprovado com ressalva** | [M] pico 5,07, agacha 21 cm (pedido 15), explosão no giro no quadro dos braços abrindo, 26 golpes com aviso em 0 f. [O] primeira pose com o joelho erguido (pose de cegonha por 0,12 s) e os braços não puxam ao peito |
| T5-05 besteiro | **Aprovado** | [M] a besta sobe no assentar de 0,25 s; mira parada aceita pela spec |
| T5-06 Escudo | **Aprovado com ressalva** | [M] corrida desenhada com `charge` (antes o golpe de espada); contato a 0,16 m do contorno. Um caso com o **aviso terminando 7 f (0,12 s) antes do contato** (`st_guard` f277 x f284: o herói foi empurrado 0,12 m por outro Escudo e a corrida desenhada anda 10 a 14 m/s, não 15). P2 |
| T5-07 Cavaleiro | **Aprovado** | [M] `brace` 3,33 m/s, 0,51 m; contato a 0,08 m do contorno, aviso +1 f. [O] `sheet_knight_brace.jpg` lê como carga de escudo |
| T5-08 dano no corpo (investidas) | **Aprovado** | [M] Escudo e Cavaleiro acima; Morvath varrido de 2,16 para 1,77 m cruzando o contorno de 1,85. Com o robô andando a faixa de Morvath termina 2 a 3 f antes (enche até onde o herói estava: comportamento pedido) |
| T5-09 bote do esqueleto | **Aprovado** | [M] 160 golpes de corpo nas sondas: lâmina a 0,93 a 2,00 m do centro, alcance 2,21: 100% dentro; aviso x dano: 157 em 0 f, 1 em +1, 1 em -1 (golpe curto do Escudo), 1 em +7 (o caso do T5-06) |
| T5-10 esqueleto esperando | **Aprovado com ressalva** | [M] sementes 1 a 3: 0 giros acima de 8 graus, 0 a 0,03 inversões/s, 0,14 a 0,18 trocas/s, nenhum `idle` curto. Semente 4, esqueleto #1: **um estalo de 7 quadros** (f628 a f634, 20 graus por quadro até -54 e volta em 3 quadros) quando a velocidade cruza `FACE_SPEED` 1,2 m/s (1,23, 1,38, 1,30, 1,19): 1,37 inversões/s nesse esqueleto, 0,34/s no conjunto (critério 0,3). Não é troca de alvo: falta histerese na velocidade. P2 |
| T5-11 corrida do esqueleto | **Reprovado no critério (3 de 6), não bloqueante** | [M] pés no ar 5/20, tronco 13 a 17, 161 passos/min, escorregamento 3 cm passam; pé levantado 0,26 m (30 cm em jogo, pedido 15), sobe e desce 0,092 (10,6 cm, pedido 7) não. [M] novo: o `plant` baixa o corpo 23 cm (meio do corpo -0,227 contra a guarda): [O] `sheet_skeleton_walk.jpg` lê como trote agachado, de joelho dobrado. A gazela sumiu; o risco agora é parecer agachado. Decisão do art-director e do Daniel (6.4: andar a 2 m/s perto) |
| T5-12 recuperações vivas | **Aprovado** | [M] 0,00 a 0,28 s em toda figura. O 0,42 s do esqueleto no robô semente 3 é a câmera lenta do último abate (o `state_t` anda 0,003 s por quadro em `idle`): falso positivo da sonda, que conta quadros reais |
| T5-13 tiro com gesto | **Aprovado** | [M] mago `shot` 1,57 m/s (pedido 1,5), sacerdote elite 5,42. O `after/data/clip_motion.txt` do commit ficou velho (1,06 e 0,38); o que vale é o `review/clip_motion.txt` |
| T5-14 foice de Morvath | **Aprovado** | [M] 5 de 5 golpes com o dano em `slash3:7`, aviso +1 f |
| T5-15 Lâminas e Investida de Morvath | **Aprovado** | [M] 4,92 e 11,85 m/s, 0,71 m; poses diferentes (teste). [O] a investida agacha para frente, as Lâminas recuam a arma |
| T5-17, T5-18, T5-19 (P2) | **Pendentes** | não feitos (maldição com o gesto do invocar, 2ª leva das erupções parada, recuo da besta) |

### 7.2 Problema novo: T5-20 (P1) atirador fugindo balança o corpo

[M] Robô semente 2, besteiro #7 (`review/archer_flee_bot_s2.txt`, f969 a f1067): correndo reto a 3,5 m/s, a velocidade
desenhada estável (vx 3,48, vz perto de 0), o corpo desenhado vai de 80 a 100 graus e volta a cada 3 a 5 quadros, 20
graus por quadro: 154 quadros com giro acima de 8 graus por 10 s e 8,7 inversões por segundo. Nos besteiros das 4
sementes do robô: 70 a 148 quadros por 10 s, 0,8 a 6,7 inversões/s; corredores 0 a 13. É a "pendência dos que giram
ao fugir", mas **não é giro legítimo**: é o mesmo sintoma "andando tremendo" do relato do PO, num atirador.
Causa provável [I, lida no código]: `Horde.flee_dir` escolhe entre os candidatos 0 e 35 graus quadro a quadro (a sonda
de `RANGED_LOOK` perto de borda ou pedra liga e desliga), `_behave_ranged` grava `e.dir = away` cru, e no
`_drawn_motion` o rosto segue `e.dir` (o ângulo para a velocidade fica abaixo de `FACE_BACK`, `face_walk` falso) até
`TURN_RATE` 1200 graus/s. A lógica de fuga é anterior ao T5 (não é regressão). Correção para o gameplay-engineer: guardar
o candidato de fuga por pelo menos 0,3 s (só trocar se o atual ficar bloqueado) e, fugindo, o rosto pela velocidade
suavizada (`e.vel`), não pela direção crua. Aceite: os critérios do T5-10 valendo para quem foge (inversões até 0,3/s,
nenhum vai e volta de mais de 8 graus em até 5 quadros) no robô sementes 1, 2, 3, 7.

### 7.3 Ferramenta

`tools/enemy_motion_probe.py` quebra nos golpes de Morvath (`ValueError` no `:+` quando não há aviso do próprio corpo,
linha 134): formatar o número antes. Morvath foi medido à mão nos CSV.

### 7.4 O que precisa de olho humano (vídeo a 60 qps, 0,25x, quando a GPU estiver livre)

1. Esqueleto: a pose armada com a lâmina atrás do ombro e o giro rápido do tronco no fim do armar lê como "vai bater"?
2. Corredor: o joelho erguido no começo da preparação.
3. Corrida do esqueleto: trote agachado (corpo 23 cm abaixo) contra a gazela de antes; decidir T5-11.
4. Morvath: a investida agachada fica de costas para a câmera em parte das direções.
5. Escudo: o `brace` de 1,15 s ainda é lento (o clipe tem 0,62 m/s; o desenho passa de 1,0 só pela curva).
6. O PO reconhece cada golpe pela pose sem olhar o chão (critério de vídeo do 6.1, ainda não feito).

**Veredito geral**: o T5 está **aprovado com ressalvas**. Os dois P0 (preparação sem corpo, dano antes do corpo) estão
resolvidos e medidos; não reprovo a entrega. Ficam o T5-11 fora do critério (decisão de arte e do Daniel), o T5-20 novo
(P1, para o próximo lote), os estalos do T5-10 e o aviso curto do Escudo (P2), os P2 T5-17 a T5-19 e o vídeo.

## 8. Depois da revisão de arte (gameplay-engineer, 2026-11-17)

Pedidos A-T5-1 a A-T5-4 de `docs/gallery/t5/ART_REVIEW.md` e T5-20, o resto do T5-10 e a ferramenta da seção 7. Só
clipes CC0 que já tínhamos. Quadros na CPU em `docs/gallery/t5/motion/after2/` (`sheet_*.jpg`: em cima o `after/`, embaixo
o novo; `lab_*_side.jpg`; `walk/skeleton_walk.jpg` e `sheet_skeleton_walk.jpg`), medidas em `after2/data/`
(`clip_motion.txt`, `charge_probe.txt`). Testes novos em `tests/test_enemy_windup.gd` (os quatro critérios de arte) e
`tests/test_enemy_motion.gd` (fuga e rosto).

### 8.1 Movimento (tamanho 1)

| Pedido | Antes | Depois | Critério |
|---|---|---|---|
| A-T5-1 investida do Escudo | `Shield_Dash_RM` 0,3 a 0,8 s: tronco 27 graus caindo a 9 a 12 no fim, corpo de pé | pernas do `Sprint` (12 poses em 0,45 s, em laço) com o tronco preso no fim do `brace` (`BRUTE_RUSH`): escudo 0,47 a 0,54 m à frente do peito, tronco 19 a 29 graus, cabeça 5 cm atrás da borda de cima | 0,3 m, 12 graus, atrás |
| A-T5-1 investida do Cavaleiro | o mesmo trecho: escudo indo para trás e para fora | `KNIGHT_RUSH` (tronco e braço do escudo presos, mais 14 graus no `Spine02`): escudo 0,50 a 0,53 m, tronco 13 a 33 graus, cabeça 0,6 m atrás da borda | idem |
| A-T5-2 corrida do esqueleto | `plant` 0,65: meio do corpo -0,227 m, cabeça 92% da parada (medida nova, sem a lâmina) | `plant` 0,5 e `stand` 0,15 (o quadril mais alto sobre as mesmas pegadas, joelho menos dobrado), passada 0,74: meio do corpo -0,083, cabeça 100% | 90% |
| ... pés no ar | 5 de 20 | 6 de 20 | 6 de 20 |
| ... passos por minuto, escorregamento | 161, 3,0 cm | 161, 3,8 cm | 160 a 170, 5 cm |
| ... sobe e desce, tronco | 9,2 cm, 13 a 17 graus | 8,4 cm, 12 a 16 graus | 7 cm, 8 a 17 |
| ... pé levantado | 0,26 m | 0,26 m (não melhorou: é o chute do `Jog_Fwd`) | 0,15 m |
| A-T5-3 preparação do corredor | `Jump_Start` 0,18 a 0,33 s: um pé 0,22 m acima do outro nas primeiras poses (0,24 ainda dava 0,22 e 0,17) | 0,26 a 0,4 s: no máximo 0,08 m; desenhado 1,0 m/s ou mais (teste), pose armada 0,33 m | 0,15 m |
| A-T5-4 tiro do feiticeiro | o `Spell_Simple_Shoot` move a mão 5 cm (o segurar já está com o braço esticado), pico 1,57 m/s | o cajado recua pela subida e volta (`Spell_Simple_Enter` 0,53 a 0,22 s e de volta, opção `there_and_back`, 0,17 s): mão de +0,70 para +0,43 m à frente do peito e de volta (0,27 m), ponta do cajado até 0,77 m da pose de segurar, pico 5,40 m/s; começa e termina na pose de segurar (sem salto a cada orbe) | 0,25 m |

Ferramentas: `"stand"` (andar travado) e `"there_and_back"` no assado, `"guard"` com segundo fixo, `"name"` nas peças
(`BakedModel.parts`, `guard_pose`, `body_top`), `tools/charge_probe.gd`, `tools/clip_probe.gd` imprime as mãos à frente do
peito, `tools/clip_motion.gd` a cabeça no andar.

### 8.2 T5-20, atirador fugindo (robô `--bot-reaction=0.25`, 50 s, sementes 1, 2, 3, 7)

Causa confirmada: a direção de fuga trocava entre 0 e 35 graus perto de borda ou pedra e o rosto seguia a direção crua; e,
na linha do `retreat_far`, ele parava e voltava a fugir (corpo virando para o herói e de volta). Correção: a direção
escolhida fica `FLEE_HOLD` 0,4 s enquanto livre (`Horde._flee`), a fuga segue `FLEE_SLACK` 0,75 m além da linha onde
começa, e correndo por conta própria (fuga, recuo, coluna, caminho até ele) o corpo olha a velocidade suavizada por
`RUN_FACE` 0,3 s depois (`Enemy.run_t`; mais lento que `WALK_FROM` nesse tempo, como no fim de um atordoamento, ele mantém
o rosto).

| Besteiros (todas as sementes) | Antes | Depois |
|---|---|---|
| Vai e volta de mais de 8 graus em até 5 quadros | 1 / 29 / 7 / 9 | 0 / 4 / 2 / 0 |
| Inversões por segundo | 0,83 / 6,71 / 0,82 / 1,93 | 0,48 / 1,24 / 0,62 / 0,82 |
| Quadros acima de 8 graus por 10 s | 70 / 148 / 75 / 106 | 42 / 99 / 43 / 55 |

O que ficou acima de 0,3 inversões/s não é tremor: são giros inteiros e separados (vira de costas para fugir depois do
tiro e volta para mirar, dois por ciclo de uns 3 s), e os 6 vai e volta restantes são o corpo seguindo uma velocidade
que faz curva (besteiro encurralado a 3,5 m do herói). O critério do T5-10 (feito para quem espera) não serve para quem
atira e foge; proposta: medir só vai e volta em até 5 quadros (0 nas sementes 1 e 7). Feiticeiro e Cavaleiro (loja,
`--stress`, semente 1, 25 s): feiticeiro 0,23 para 0,21 inversões/s, nenhum vai e volta; Cavaleiro 1,12 para 0,75/s, 3
para 6 vai e volta, todos encostado no herói (o rosto segue a direção até ele, que gira em volta): não é fuga.

### 8.3 T5-10, o estalo da semente 4

A troca entre olhar a mira e olhar para onde anda espera `FACE_AFTER` 0,1 s, e quem tem passo lateral só volta à mira
abaixo de `FACE_SPEED_BACK` 0,9 m/s (entra acima de `FACE_SPEED` 1,2). `--play --seed=4`: esqueleto #1 de 9,6 para 0
quadros acima de 8 graus por 10 s, o conjunto de 2,4 para 0; inversões 0,34 para 0,31/s (o que sobra são ajustes de 1 a 4
graus encostado no herói). Sementes 1 a 3 sem mudança (0 acima de 8 graus).

### 8.4 Ferramenta

`tools/enemy_motion_probe.py` não quebra mais nos golpes de Morvath (sem aviso próprio, imprime `-`).

### 8.5 Verificação

`tools/check.gd` ok; `tools/test.sh` 936 testes (a tabela de durações de `test_living_crowd.gd` passou a investida para
o laço de 0,45 s, de propósito); `tools/smoke.sh 600 --seed=5` termina em `ENDING` (Morvath aos 251,8 s com 65 de vida,
113 abates, pico 8 de pé, passo médio 0,35 ms, robô nunca preso) e `tools/smoke.sh 180 --start=boss --boons=25 --seed=5`
em `ENDING` aos 75,1 s. Sem vídeo na GPU (pedido para não usar): falta o olho na câmera do jogo (A-T5-8).
