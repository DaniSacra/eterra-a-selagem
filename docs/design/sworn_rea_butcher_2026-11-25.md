# SWORN: o "Butcher" (chefe da floresta), a investida com escudo e a recuperação dos inimigos, 2026-11-25

Estudo só de leitura, a pedido do Daniel (dono do jogo instalado): "o nosso cavaleiro é parecido com o butcher do SWORN, vamos
pegar os mesmos números e mecânicas para testar, só não coloca o pulo dele" e "ainda acho os bosses meio lentos, tanto no ataque
quanto na recuperação depois que atacaram, não só eles, mas os inimigos também, então a janela de contra-ataque fica meio grande".
Nada de arte, áudio, modelo, texto ou nível entrou no projeto. Os nomes em inglês são só identificadores do estudo.

Complementa `sworn_rea_kingswood_2026-11-25.md` (método, inimigos, avisos) e `sworn_gawain.md` (a luta do chefe inteira, princípios).
Este documento acrescenta: **quem é o Butcher**, a **árvore de comportamento decodificada** (cooldowns e esperas da IA, que o estudo de
Kingswood deixou como desconhecido), a **recuperação medida** de cada inimigo, a **investida com escudo** de referência e uma proposta
de números com os campos do nosso `make_data.gd`.

Convenção: **[L]** lido num campo (com a fonte), **[D]** conta feita sobre campos lidos, **[I]** inferência minha.

## 0. Fontes e método

- Bundles (Addressables, `SWORN_Data/StreamingAssets/aa/StandaloneWindows64/`): `base_mob_gawain`, `patch_mob_gawain`,
  `patch_mob_kay`, `base_mob_hammermob`, `base_mob_axethrower`, `base_mob_boar`, `base_mob_mortoad`, `base_mob_snake`,
  `base_mob_questingbeast`, `base_mob_baneofcrows`. Lidos com UnityPy 1.25.4 (typetree dos MonoBehaviours, colliders e AnimationClips).
- **Tempos**: cada habilidade é um `TimelineAsset` em modo "BasedOnClips" (`m_DurationMode` 0 [L]), então a duração é o fim do último
  clipe. Hitbox = `ActivationPlayableAsset` da faixa de ativação; aviso = início da hitbox; movimento = `MovementModifierClip`
  (tipo 0 = multiplicador da caminhada, tipo 2 = giro [I, como no estudo de Kingswood]).
- **IA**: as árvores do Behavior Designer (`mBehaviorSource.mTaskData`) estão em serialização binária. Decodifiquei pela ordem dos
  campos: `fieldSerializationData.startIndex[k]` aponta para `dataPosition`, que aponta para `byteDataArray`; os nomes de campo de
  cada tarefa vêm do `global-metadata.dat` (por exemplo `Cooldown`: completedCooldown, cancelledCooldown, setRandom, randomMin,
  randomMax, storeResult; `SetFloat`: floatValue, setRandom, randomMin, randomMax, storeResult; `SetCooldown`: minCooldown,
  maxCooldown; `HasPlayerWithinRange`: maxRadius, minRadius; `CheckHealth`: minPercentHealth, maxPercentHealth). Os nomes das
  tarefas ("Set Phase 2", "Is Health Under 80", "Wild Spin", "Axe Swing") estão em texto no próprio dado [L].
- As animações (AnimationClip) **não têm root motion** [L: `m_StartX`/`m_StopX` zerados em todas do javali]; o deslocamento das
  investidas é feito no código, por isso a velocidade só aparece onde há campo (`rushSpeed`).
- Os despejos ficaram fora do repositório e foram apagados no fim.

## 1. Quem é o Butcher

**FATO:** a tabela de texto em inglês tem `NAME_Gawain` = "Gawain, Butcher of Wirral" e `NAME_Gawain_Title` = "Butcher of Wirral"
(conquista "Butcher of the Wirral" = "Defeat Sir Gawain in the Wirral Forest"). O Butcher **é o chefe da primeira região** (o mesmo de
`sworn_gawain.md`, que não tinha achado o título), não um minichefe. Ele **não usa escudo e não tem investida**: o que fecha distância
nele são os **saltos** (os dois que o Daniel pediu para tirar). O cavaleiro **de escudo com investida contra parede** da mesma região é
o chefe alternativo, **Lady Kay** (seção 3): os números da investida e do escudo saem dela.

## 2. O Butcher (Gawain), números

### 2.1 Corpo [L, `Sir Gawain (mob entity)`]

| Campo | Valor |
|---|---|
| Vida | 6000 (modo de chefes em sequência: igual) |
| Poise (barra de Stagger) | 800; atordoado **3,5 s** (`Gawain hitstun`, timeline de 3,5 s); cada quebra seguinte pede **x1,25** (`subseqentStunResistMultiplier`) |
| Golpes para congelar | 25 |
| Velocidade de andar | **6,0 m/s** (igual ao herói leve), giro 1000 graus/s, aceleração e frenagem 100 (instantâneas); não tem "correr" separado |
| Corpo | cápsula r 0,8 a 1,0, altura 3 |
| Armadura, escudo, redução de dano | 0, 0, 0 (`BaseShields` 0, `baseDamageReduction` 0) |
| Empurrão | imune (`immuneToKnockback` 1); costas 0,5 em 60 graus |
| Perseguição | sub-árvore "Chase" com `minRange` 2 e `maxRange` 30 |

### 2.2 Árvore de comportamento [L, `Sir Gawain Actions (behavior tree)`]

Um laço com seletor por utilidade; **todas as opções têm utilidade 1,0** [L], então vale a primeira da lista cujas condições passam
[I, regra do seletor: maior utilidade, empate fica com a primeira]. Uma ação por vez (trava `actionLock`). Cooldowns iniciais
(`SetInitialCooldowns`): cooldown1 = 5, cooldown2 = 10, cooldown3 = 10, cooldown4 = 10, cooldown5 = 6 s [L]. O cooldown é gravado
quando a ação termina (decorador `Cooldown`, `completedCooldown` e `cancelledCooldown` iguais) [L].

| Ordem | Ação | Condição [L] | Cooldown depois [L] | 1º uso [L] |
|---|---|---|---|---|
| 1 | Provocação inicial (1,82 s) | uma vez | | |
| 2 | Fase 2 + rugido (1,78 s, atingível) | vida < 80% e fase 1 | | |
| 3 | Fase 3 (sem rugido) | vida < 60% e fase 2 | | |
| 4 | Fase 4 + rugido | vida < 40% e fase 3 | | |
| 5 | Erupções | fase 4 | 20 s | 10 s |
| 6 | Convoca 3 (1 martelo, 2 machados), só com até 4 vivos | fase >= 3 | 30 s | 10 s |
| 7 | Ondas no chão | fase >= 2 | 15 s | 10 s |
| 8 | **Salto com pancada e anel** (PULO, fora) | sempre | 10 s | 5 s |
| 9 | **Giro louco** ("Wild Spin") | herói a até **6 m** | 10 s | 6 s |
| 10 | Básico A: **golpe em salto** (PULO, fora) | herói a até 12 m, contador 0 (vira 1) | **nenhum** | |
| 11 | Básico B: **tiro** | herói a até 12 m, contador 1 (vira 0) | **nenhum** | |
| 12 | Perseguir (2 a 30 m) | nada acima | | |

**O ponto que importa para a cadência:** entre os básicos **não existe espera de IA**. Ele encadeia golpe em salto, tiro, golpe em
salto... e a única pausa é a cauda de cada timeline (2.3). Os especiais têm cooldown longo e só entram no lugar de um básico.

### 2.3 Ataques [L, timelines; formas pelos colliders do bundle, sem a escala do objeto]

"Aviso" = início da habilidade até o dano; "cauda" = do fim da hitbox ao fim da timeline (parado, sem atacar).

| Ataque | Dano | Forma e alcance | Aviso | Ativo | Cauda (parado) | Movimento |
|---|---|---|---|---|---|---|
| Golpe em salto (PULO) | 15 | pouso esfera r 2; salto até 7 m, busca 12 m, desvio 0,5 m | alvo travado 0,17; no ar 0,33 a 0,75; dano **0,83** | 0,83 a 1,00 | **1,25 s** (até 2,25) | só o salto |
| Salto com pancada (PULO) | 15 + anel 7 | pouso esfera r 3; anel nasce r 1,2, cresce **7,5 m/s** até 22 m, espessura 0,25 | trava 0,75; dano **1,58 a 1,63** | 1,58 a 1,75 | **1,08 s** (até 2,83) | só o salto |
| Tiro múltiplo | 10 por bola (`sworn_gawain.md`: 20 m/s, 22 m, esfera r 1,5) | à frente | sinais 0,17 e 0,33; ativo **0,68** | 0,68 a 0,85 | **0,65 s** (até 1,50) | gira só até 0,17 |
| Giro louco | **10 por acerto, 6 acertos** | esfera **r 4** em volta dele | **0,83** parado (sinal 0,33) | 6 janelas de 0,5 s: 0,83 / 1,37 / 1,92 / 2,45 / 2,98 / 3,52 (fim 4,02); acerto renovado a cada ~0,53 s ("Clear Hits") | **2,07 s** (até 6,08); de 3,58 a 4,92 ainda se arrasta a 30% e 10% | anda **a 50% (3 m/s) atrás do herói** de 0,83 a 3,58 |
| Ondas no chão (fase 2) | saída 15, onda 7 | 4 ondas, zona morta de 135 graus; 5 m/s por 2,5 s (12,5 m), perseguem a partir de 0,5 s (giro 0,04) | **0,83** | 0,83 a 0,87 | **1,60 s** (até 2,47) | parado |
| Erupções (fase 4) | 10 | 3 salvas de 10 pontos, esfera r 2,5, perto do herói (1,5 m) e espaçadas 3 m | alvo 0,58 / 2,73 / 4,77, dano 1,43 / 3,70 / 5,87 (avisos 0,85 a 1,10) | | 0,9 s até "Ability Ended" 6,75 (clipes até 8,0) | parado |
| Convocação (fase 3) | | 3 a 12 m dele, 0,25 s entre cada, morrem com ele | 0,42 | | 1,08 s (1,5 total) | parado |
| Rugido / provocação | 0 | | | | 1,78 / 1,82 s inteiros | parado, atingível |

- **Pulo:** existem dois ("golpe em salto", que é metade do básico, e "salto com pancada"). **Não vamos usar** (pedido do Daniel).
- Armadura, escudo, imunidade de quadro: **nenhuma** em nenhuma timeline [L, ausência]; só troca de camada de colisão durante os saltos.
- Investidas: **o Butcher não tem** [L: nenhuma habilidade com `rushSpeed` ou `dashHitboxTag` no bundle dele].

### 2.4 Fases [L]

| Fase | Vida | O que soma |
|---|---|---|
| 1 | 100 a 80% | básicos alternados (salto/tiro), salto grande (cd 10), giro louco (cd 10, a até 6 m) |
| 2 | < 80% | + ondas no chão (cd 15); rugido na entrada |
| 3 | < 60% | + convocação de 3 (cd 30, teto 4 vivos); sem rugido |
| 4 | < 40% | + erupções (cd 20); rugido na entrada |

Nada fica mais rápido nas fases: o que muda é **quantos verbos** ele tem.

## 3. A investida com escudo de referência: Lady Kay [L, `patch_mob_kay`]

O chefe alternativo da mesma região é quem tem o que o nosso Cavaleiro tem (escudo, investida, parede). Vida 4500, andar 2,0 m/s,
poise 800, atordoado 3,5 s, x1,25, imune a empurrão.

- **Escudo:** barra própria de **1000** (`m_shieldMaxHealth`), bloqueia **100%** (`m_damageReduction` 1,0) num arco de **60 graus**
  à frente (`m_defaultShieldAngle`; 130 graus na postura de defesa), **volta sozinho em 18 s** (`m_shieldRecoveryTime`). Sem escudo
  a árvore troca de ramo ("Without Shield": combo de socos, leque de espinhos cd 10, trepadeira cd 5 a 8).
- **Investida ("BullRush")**: dano 15; preparação **0,68 s** (gira à vontade até 0,5, a 10% de 0,5 a 0,68: mira travada cerca de
  0,18 s antes); corre de **0,68 a 2,13 s (1,45 s) a 8 m/s = 11,6 m**, girando **30 graus/s** no caminho; uma por vez (nunca seguidas);
  cauda **0,83 s** (até 2,97). **Bater num pilar**: tira **250** do escudo (`damageToShieldOnHitPillar`) e a deixa parada **1,5 s**
  (`Lady Kay - Wallhit`). Cooldown: 20 s no começo, depois **9 a 12 s** sorteado (`SetAbilityCooldown`), só com linha livre até o herói
  (`IsTargetObstructed`, raio 0,5).
- Ritmo com escudo: alterna **golpe leve** (golpe 15, aviso 1,03 s, cauda 1,5 s; ou golpe de costas 0,55 s) e **golpe pesado**
  sorteado sem repetir (defesa com projéteis, espinhos, bumerangue), sem espera de IA entre eles; investida e convocação (cd 20 a 30)
  entram por cima quando prontas.
- Comparação rápida: javali comum de Kingswood corre 0,67 a 2,12 s, bate na parede e fica **1,0 s** (`Boar - Wallhit`).

## 4. Recuperação e janela de contra-ataque, SWORN x nosso

Definições: **parado** = cauda da timeline depois do golpe (SWORN) ou `recover_time` (nosso), o inimigo não anda nem ataca;
**espera** = recarga da IA depois disso (SWORN: `Cooldown`/`SetFloat`/`SetCooldown` da árvore; nosso: `Horde.AFTER_RECOVER` 0,25 +
até 0,5 de sorteio, ou `gap_*` dos guardiões); nessa espera o inimigo **anda mas não ataca**; **até o próximo dano** = parado +
espera + aviso do próximo golpe. SWORN [L] para os tempos; o que o inimigo faz na espera é [I] (a perseguição passa pela mesma checagem
de cooldown, então ele vagueia ou se reposiciona).

### 4.1 SWORN [L]

| Inimigo | Aviso | Parado depois do golpe | Espera da IA | Até o próximo dano |
|---|---|---|---|---|
| Cobra (snake) | 0,48 | 0,60 a 0,83 | 0,5 a 1,5 sorteado | 1,6 a 2,8 |
| Machadeiro (axe) | 0,58 a 0,70 | 0,57 a 0,83 | 0,75 a 1,5 sorteado | 1,9 a 3,0 |
| Martelo (hammer) | 0,67 | **1,30** | 0,75 a 1,5 sorteado | 2,7 a 3,5 |
| Javali (boar) | 0,67 | 0,90 (parede: 1,0 de atordoado) | 1,0 a 1,5 sorteado | 2,6 a 3,1 |
| Sapo morteiro (mortoad) | 0,50 | 0,73 | 0,75 fixo (salta para longe se o herói chega a 4 m, cd 1,5 a 2) | cerca de 2,0 |
| Capitão martelo (onda) | 1,23 | 1,13 | 1,0 a 1,75 | 3,4 a 4,1 |
| Capitão javali | 0,67 | 0,90 | 1,5 fixo | cerca de 3,1 |
| Besta Questora (minichefe) | 0,67 | 0,45 (tiro) a 0,65 (cauda) | cauda 0,5, tiro 2, global 0 | 1,2 a 1,8 |
| Bane of Crows (minichefe parado) | 0,72 a 1,05 | 0,45 a 0,8 | **3 a 5 s sorteado** depois de todo ataque | 4 a 6 |
| **Butcher, básicos** | 0,68 a 0,83 | **0,65 (tiro), 1,25 (golpe em salto)** | **0** | **1,3 a 2,1** |
| Butcher, giro louco | 0,83 | 2,07 | 0 | 2,7 a 2,9 |
| Butcher, salto grande / ondas | 1,6 / 0,83 | 1,08 / 1,60 | 0 | 1,8 a 2,4 |
| Lady Kay, investida | 0,68 | 0,83 (pilar 1,5) | 0 | 1,5 a 2,3 |
| Lady Kay, golpe leve | 1,03 | 1,50 | 0 | 2,2 a 2,6 |

### 4.2 Nosso (`data/enemies/*.tres` gerado de `tools/make_data.gd`, HEAD `91252ac`) [L]

| Inimigo | Aviso (`attack_windup` final) | Parado (`recover_time`) | Espera | Até o próximo dano |
|---|---|---|---|---|
| Esqueleto (`skeleton`, `skeleton_raised`) | 0,60 | **1,20** | 0,25 a 0,75 | 2,05 a 2,55 |
| Trinca (`trinca`) | 0,68 | 1,00 | 0,25 a 0,75 | 1,9 a 2,4 |
| Rato de osso (`bone_rat`) | 0,50 | 0,70 | 0,25 a 0,75 | 1,45 a 1,95 |
| Corredor (`runner`) | 0,68 | **1,35** | 0,25 a 0,75 | 2,3 a 2,8 |
| Esqueleto grande (`skeleton_big`) | 0,88 | **1,40** | 0,25 a 0,75 | 2,5 a 3,0 |
| Corredor grande (`runner_big`) | 1,20 | 1,20 | 0,25 a 0,75 | 2,65 a 3,15 |
| Escudo (`guard`) | 0,92 | 1,10 | 0,25 a 0,75 | 2,3 a 2,8 |
| Varredor (`varredor`) | 1,20 | **1,40** | 0 (a espera é o próprio `recover_time`) | 2,6 |
| Saltador (`saltador`) | 0,64 | 1,00 | 0,25 a 0,75 | 1,9 a 2,4 |
| Besteiro / lanceiro (`archer`, `lancador`) | 0,64 | 0,60 | `attack_cooldown` 2,34 / 3,06 | cerca de 2,4 / 3,1 |
| Feiticeiro (`mage`) | 0,70 | 0,80 | `attack_cooldown` 2,7 | cerca de 2,7 |
| Capitão (`capitao`) | 1,20 | 1,10 | `gap` 0,4 a 1,4 (0,3 a 0,8 no fim) | 2,7 a 3,7 |
| **Cavaleiro** (`knight`), investida | 0,60 | 0,55 | **`gap` 0,3 a 1,5** (0,2 a 0,7 no fim) | 1,45 a 2,65 |
| Ancião (`priest_elder`) | 0,80 | | `attack_cooldown` 3,51 | cerca de 3,5 |
| Morvath, depois de cada ataque | 0,6 a 0,85 (x0,8 a 0,85 por fase) | 0,6 (lâminas, investida, erupção, maldição, rajada), 0,7 (foice), 0,9 (tempestade), **1,4 (ceifa dupla)** | `gap` 0,1 a 0,7 (0,05 a 0,3 no fim) | 1,3 a 2,9 |

### 4.3 Leitura (o que o dado diz e o que não diz)

1. **O ciclo inteiro dos comuns do SWORN não é mais curto que o nosso** (até o próximo dano: 1,6 a 3,5 s lá, 1,5 a 3,2 s aqui).
   [D] O que muda é **onde o tempo fica**: lá o comum leve fica **parado 0,6 a 0,85 s** e passa o resto da recarga se mexendo; aqui o
   esqueleto e o corredor ficam **parados 1,2 a 1,35 s** e a espera depois é curta. A "janela de contra-ataque" (o inimigo parado
   na sua frente) é **quase o dobro** nos nossos leves. Só o martelo do SWORN (o pesado de 250 de vida) fica 1,3 s.
2. **Chefes:** o Butcher e a Lady Kay **não têm espera nenhuma** entre ataques; a única pausa é a cauda (0,65 a 1,25 s nos básicos,
   2,07 só no fim do giro de 6 golpes). O nosso Cavaleiro tem cauda menor (0,55) mas soma um sorteio de 0,3 a 1,5 s parado na guarda;
   na média dá 1,45 s contra cerca de 1,0 do Butcher, e o sorteio deixa buracos de até 2 s, que é o "lento" que o Daniel sente [I].
   Morvath: a ceifa dupla com 1,4 s é a cauda mais longa do jogo depois do giro louco (que tem 6 golpes).
3. **Avisos:** os nossos comuns já estão na faixa (0,5 a 0,7) ou abaixo; os pesados (escudo 0,92, esqueleto grande 0,88) passam do
   martelo do SWORN (0,67). Avisos de 1,2 s lá só existem em golpe de área grande (onda do capitão 1,23): batem com o nosso Varredor,
   Corredor grande e Canalizador (marcados no chão).
4. **Exceção que o SWORN confirma:** o conjurador parado (Bane of Crows) espera **3 a 5 s** depois de cada ataque; o nosso Ancião
   (3,5 s) está igual. Não encurtar.

## 5. Butcher x nosso Cavaleiro

| Item | Butcher (SWORN) [L] | Lady Kay (escudo) [L] | Nosso Cavaleiro (`knight`) [L] |
|---|---|---|---|
| Papel | chefe (sala 13 de 15) | chefe alternativo | guardião (sala 5 ou 6 de 14) |
| Vida | 6000 | 4500 | 380 + armadura 1100 (`armor_soft` 0,3: o leve tira 30% da armadura) |
| Tempo para matar sem melhoria [D] | 92 s (espada 65 de dano por segundo) | 69 s | cerca de 36 s (Guerreiro 41 por segundo, sem contar `armor_soft`) |
| Dano por acerto / vida do herói | 7 a 15 / 50 (14 a 30%) | 15 / 50 (30%) | 5 a 6 / 40 (12 a 15%); corpo 10 |
| Poise e atordoado | 800, 3,5 s, x1,25 | 800, 3,5 s, x1,25 | `poise` 100 x `poise_mult` 0,3, `poise_stun` 3,5, `poise_growth` 1,25 (igual) |
| Andar | **6,0 m/s** (= herói) | 2,0 | **2,875** (43% do herói de 6,75) |
| Fecha distância com | salto (fora) | investida 8 m/s x 1,45 s = 11,6 m, gira 30 graus/s | investida 24 m/s x 0,6 s = 14,4 m, até 3 seguidas |
| Aviso da investida | (salto 0,83) | 0,68, mira trava ~0,18 antes | 0,60, `aim_lock` 0,15 (2ª e 3ª 0,45) |
| Parede | | pilar: 1,5 s parada, -250 do escudo | `wall_stun` 1,5 (igual) |
| Escudo | nenhum | 1000, 100% em 60 graus, volta em 18 s | `front_block` 0,7 (70%) na frente; guarda por tempo a cada 14 s |
| Arremesso + anel | salto grande: anel 7, 7,5 m/s, 0,25 de espessura, até 22 m, cd 10 (1º 5) | bumerangue | escudo: 6 + anel 5 a 12 m/s, 0,8 de espessura, 32 m, cd 18 (1º 8) |
| Resposta de perto | giro louco: 0,83 parado, 6 x 10 em r 4 andando a 3 m/s, cauda 2,07, cd 10, a até 6 m | golpe leve 15, aviso 1,03 | golpe de perto 6, aviso 0,5, a até 3,2 m |
| Resposta de longe | tiro 10 alternado com o básico | trepadeira, espinhos | arremesso |
| Espera entre ataques | 0 | 0 | `gap` 0,3 a 1,5 + `attack_cooldown` 2,16 desde o aviso |
| Fases | 80 / 60 / 40%: cada uma soma um verbo | escudo inteiro / quebrado | investidas em fileira de 1 (100%), 2 (75%), 3 (30%) |
| Ajudantes | 3 por vez, teto 4 vivos, cd 30, da fase 3 | 1 a 3, cd 20 a 30 | `escort` 2 magos, `raise_count` 3, `raise_max` 6 |

## 6. Proposta (para o gameplay-engineer aplicar em `tools/make_data.gd`, regerar `enemies` e `bosses`)

Regra de escala usada [D]: dano x0,8 (herói 40 contra 50), vida pelo tempo de matar (Guerreiro 41 por segundo contra 65 da espada),
tempos iguais aos do SWORN. Tudo é proposta de teste para o Daniel e para o robô de 12 sementes, não número fechado.

### 6.1 Cavaleiro "Butcher sem pulo" (`_enemy({"id": &"knight", ...})`)

O pulo sai; o papel dele (fechar distância de 7 m em 0,83 s e punir com 1,25 s de cauda) passa para a **investida**. O salto grande com
anel passa para o **arremesso do escudo** (o escudo voa no lugar do corpo). O giro louco vira a **guarda por tempo** (anda atrás do
herói batendo). O escudo fica com a Lady Kay como referência.

| Campo | Hoje | Proposta | De onde |
|---|---|---|---|
| `hp` / `armor` | 380 / 1100 | **500 / 1400** (1900 no total, 46 s) | minichefe do SWORN (Besta Questora 3000 / 65 = 46 s). Cópia fiel do Butcher seria 3800 (92 s): longo demais para a sala 5 [I] |
| `speed` | 200.0 / U (2,875 final) | **417.0 / U** (6,0 m/s final com `ENEMY_PACE`) | Butcher anda a 6,0 = herói. [I] risco: com armadura e investida pode ficar opressivo; testar primeiro |
| `attack_windup` (investida, `exact_windup`) | 0,6 | **0,65** | golpe em salto: contato em 0,83 s = 0,65 de aviso + 0,18 de corrida |
| `lunge_speed` / `lunge_time` | 24 / 0,6 (14,4 m) | **24 / 0,3** (7,2 m) | `maxJumpRange` 7 |
| `attack_range` | 14 | **12** | `targetSearchRange` 12 e o "a até 12 m" do básico |
| `attack_damage` | 6 | **12** | 15 x 0,8 |
| `aim_lock` | 0,15 | 0,15 (igual) | Kay ~0,18 |
| `recover_time` | 0,55 | **0,9** | caudas do Butcher 0,65 (tiro), 1,08 (salto grande), 1,25 (golpe em salto) |
| `gap_min` / `gap_max` | 0,3 / 1,5 | **0,0 / 0,15** | Butcher e Kay: espera 0 (não usar `gap_max` 0: cai no `AFTER_RECOVER`) |
| `gap_min0` / `gap_max0` | 0,2 / 0,7 | **0,0 / 0,05** | idem |
| `attack_cooldown` | 2,4 (2,16 final) | **1,8** | para não segurar o ciclo de 0,65 + 0,3 + 0,9 = 1,85 s |
| `moves` investida | 3 linhas (`count` 1, 2 em 0,75, 3 em 0,3) | **uma linha**: `_kmove(&"charge", {"count": 1, "from_life": 1.0, "cooldown": 0.0, "min_dist": 3.2, "max_dist": 12.0})` | Butcher nunca repete o fechamento em fileira; Kay: uma por vez |
| `moves` arremesso | cd 18, 1º 8, 4 a 16 m | **`cooldown` 10, `first` 5, `min_dist` 4, `max_dist` 0** | salto grande: cd 10, 1º 5, sem condição de distância |
| `throw_windup` / `throw_flight` | 0,5 / 1,0 | **0,5 / 1,1** (pouso em 1,6) | dano do salto grande em 1,58 a 1,63 |
| `throw_lock` | 0,35 | **0,85** | alvo travado em 0,75 de 1,63 |
| `throw_damage` | 6 | **12** | 15 x 0,8 |
| `throw_open` | 1,8 | **1,1** | cauda do salto grande 1,08 |
| `ring_speed` / `ring_thick` / `ring_reach` / `ring_delay` | 12 / 0,8 / 32 / 0,25 | **7,5 / 0,4 / 22 / 0,0** | anel 7,5 m/s, 0,25 de espessura [I: 0,4 porque o nosso anel é desenhado mais grosso], 22 m, nasce no pouso |
| `ring_damage` | 5 | **6** | 7 x 0,8 |
| `close_damage` / `close_windup` / `close_range` | 6 / 0,5 / 3,2 | **8** / 0,5 / 3,2 | o Butcher fase 1 não tem golpe curto; a forma verdadeira tem pisão de 10 em 0,17 s, r 3 |
| `guard_up_every` | 14 | **10** | giro louco cd 10 (1º 6; hoje o primeiro sai em `every` x 0,5 = 5) |
| `guard_up_windup` | 0,6 | **0,85** | 0,83 parado antes do primeiro golpe |
| `guard_up_time` | 4,0 | **3,2** | golpes de 0,83 a 4,02 |
| `guard_up_walk` | 0,6 | **0,5** | anda a 50% atrás do herói |
| `guard_up_hit_every` / `guard_up_hit_range` | 1,6 / 1,6 | **0,53 / 4,0** | 6 janelas a cada ~0,53 s, esfera r 4 |
| `guard_up_hit_damage` / `guard_up_hit_windup` | 6 / 0,6 | **8 / 0,6** (o piso do `_quick` pesado é 0,6) | 10 x 0,8 |
| `guard_up_armor` | 0,5 | **0,0** | o giro sai em qualquer fase, só a até 6 m |
| `raise_max` | 6 | **4** | teto de 4 vivos |
| `wall_stun` | 1,5 | 1,5 (igual) | Kay 1,5, javali 1,0 |
| `poise_stun` / `poise_growth` | 3,5 / 1,25 | igual | igual ao SWORN |

**Fica fora sem código** (comportamento que o `KNIGHT` não tem hoje; o gameplay-engineer decide se vale): fases por vida que **somam
verbos** (80% ondas, 60% chamado, 40% erupções) com rugido atingível de 1,78 s nas entradas de 80 e 40%; `from_life` e "só a até 6 m"
para a guarda por tempo; cauda própria de 2,0 s no fim da guarda (o giro louco termina parado e se arrastando); ondas no chão que
perseguem (o mais próximo é o `volley_*` do Ancião); chamado por cooldown (30 s) em vez de por fileira de investidas.

### 6.2 Comuns e elites (recuperação mais curta, como os leves do SWORN)

Em `ENEMY_RECOVER` (linha 284, `[comum, elite]`) e nos `recover_time` literais:

| Campo | Hoje | Proposta | Referência SWORN |
|---|---|---|---|
| `ENEMY_RECOVER.skeleton` | [1.2, 1.0] | **[0.75, 0.65]** | cobra 0,60 a 0,83 |
| `ENEMY_RECOVER.runner` | [1.35, 0.5] | **[0.8, 0.5]** | machadeiro 0,57 a 0,83 |
| `ENEMY_RECOVER.guard` | [1.1, 1.1] | **[1.0, 0.9]** | javali 0,90; martelo 1,30 |
| `ENEMY_RECOVER.mage` | [0.8, 0.8] | **[0.65, 0.65]** | sapo 0,73 |
| `ENEMY_RECOVER.archer` | [0.6, 0.6] | igual | machadeiro |
| `trinca` / elite | 1,0 / 0,8 | **0,7 / 0,6** | cobra |
| `bone_rat` | 0,7 | **0,6** | cobra |
| `saltador` | 1,0 | **0,8** | javali menos a corrida |
| `skeleton_big` | 1,4 | **1,1** | martelo 1,30 (o mais lento do SWORN) |
| `runner_big` | 1,2 | **1,0** | |
| `varredor` / elite | 1,4 | **1,1** | onda do capitão 1,13 |
| `capitao` `gap_min`/`gap_max`/`gap_min0`/`gap_max0` | 0,4 / 1,4 / 0,3 / 0,8 | **0,2 / 0,8 / 0,1 / 0,4**; `recover_time` 1,1 para **1,0** | capitão do SWORN: cauda 0,9 a 1,13 |
| avisos finais do `guard` e do `skeleton_big` | 0,92 / 0,88 | **0,70** (com `exact_windup` ou fonte ajustada; o `_quick` não desce o pesado de 0,6) | martelo 0,67 |
| `Horde.AFTER_RECOVER` e `AFTER_RECOVER_JITTER` | 0,25 e 0,5 | **igual** | a espera do SWORN (0,5 a 1,5) é até maior: o que encurta é o tempo parado |

Esperado [D]: o esqueleto fica parado 0,75 s em vez de 1,2 e volta a ameaçar 0,45 s mais cedo (ciclo até o próximo dano de 2,05 a 2,55
para 1,6 a 2,1). O Ancião e os atiradores ficam como estão (seção 4.3, item 4).

### 6.3 Morvath (`_bosses()`)

| Campo | Hoje | Proposta | Referência |
|---|---|---|---|
| `gap_min` / `gap_max` | 0,1 / 0,7 | **0,0 / 0,3** | Butcher: espera 0 |
| `gap_min0` / `gap_max0` | 0,05 / 0,3 | **0,0 / 0,1** | |
| `reap_recovery` | 1,4 | **1,1** | salto grande 1,08; golpe em salto 1,25 |
| `storm_recovery` | 0,9 | **0,8** | ondas 1,6 para um ataque bem maior; tempestade é média |
| `scythe_recovery`, `blade_recovery`, `dash_recovery`, `eruption_recovery`, `curse_recovery`, `barrage_recovery` | 0,6 a 0,7 | igual | tiro do Butcher 0,65 |
| `rest` (rugido, atordoado, ritual) | [0.9, 0.8, 0.5, 0.35] x `BOSS_REST` | igual | só vale fora do pós-ataque |

## 7. Medido x inferido, em resumo

- **Medido [L]:** título do Butcher; vida, poise, velocidade, imunidades; todos os tempos de timeline (aviso, ativo, cauda); danos,
  formas dos colliders (sem a escala), anel e ondas; a árvore inteira do Butcher, da Kay, dos comuns e dos minichefes (condições,
  distâncias, cooldowns e sorteios); escudo da Kay (1000, 100%, 60 graus, 18 s, -250 no pilar, 1,5 s parada); investida da Kay
  (8 m/s, 1,45 s, 30 graus/s, cd 9 a 12).
- **Inferido [I]:** regra de desempate do seletor por utilidade (primeira da lista); o que o comum faz durante a espera da IA
  (vaguear); o tamanho real das hitboxes (escala do objeto não aplicada); a velocidade da investida do javali (está no código, sem
  root motion); a duração do Butcher na nossa escala; a espessura 0,4 do anel e a vida 1900 propostas.
- **Não achado:** o dano real dos ajudantes (fica na entidade), o valor de `MaxGlobalAttackCooldown` da Besta Questora (0 no dado,
  talvez definido em tempo de jogo).
