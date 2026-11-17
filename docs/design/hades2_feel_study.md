# Estudo de game feel do Hades II: movimento, golpes, habilidades e inimigos (2026-11-16)

Pedido do Daniel depois do teste da E1: "REA novamente no Hades 2 para entender movimentação, ataques e habilidades
tanto dos heróis quanto dos inimigos". Só regras e números de mecânica e tempo; nada de arte, som, texto ou código
copiado. Nada no jogo instalado foi alterado; nada do projeto mudou além deste arquivo.

Complementa (sem repetir) `game_feel_measures.md` (hit stop, buffer, esquiva, cancelamentos medidos no nosso jogo) e
`game_feel_review.md`. O que lá já está medido aparece aqui só como referência curta.

## Fontes e método

- **Dados do jogo** (cópia do Daniel, só leitura). Abaixo, `C/` = `/mnt/c/Program Files (x86)/Steam/steamapps/common/Hades II/Content/`.
  Arquivos de texto (`.sjson` e `.lua`), lidos direto; cada número traz `arquivo:linha`. A skill REA foi carregada, mas
  o que importa aqui está em texto puro: não foi preciso decompilar o executável. Consequência: o que só o motor sabe
  (a fórmula exata do `Grip`, o que o `ManagerCap` corta, a randomização dentro dos eventos do FMOD) está marcado
  **a confirmar**.
- **Vídeo do Daniel** (`C:\Users\danie\Videos\Captures\Hades II 2026-11-16 21-26-20.mp4`, só referência local, não
  copiado). Nominal 60 qps, mas o arquivo tem 1452 quadros em 48,6 s (taxa variável, intervalos de 28 a 42 ms): a
  precisão das medidas é de **±0,035 s**. Medido com `ffprobe` (tempo de cada quadro), diferença de imagem do fundo
  quadro a quadro (a câmera do Hades segue a Melinoë quase sem atraso, então fundo parado = ela parada) e folhas de
  quadros recortadas em volta dela com o tempo impresso. Arma no vídeo: o cajado (os três golpes, o especial e a
  esquiva). Daniel segurou a direção o tempo todo.
- **Quadros**: `DurationFrames` é a 60 por segundo (como no estudo anterior). Escala: 80 unidades = 1 m.
- **Modelo do Grip (estimativa)**: tratei `Grip` como desaceleração linear em unidades/s² (distância = v² / 2·grip,
  cortada quando um efeito `GRIP` com `HaltOnEnd` termina). O teste de sanidade fecha: a investida da Hécate (3000 u/s,
  grip 2500 x 0,1, parada em 0,15 s) dá 447 u = 5,6 m, o mesmo alcance da esquiva da heroína (`BlinkMaxRange 450`).
  Mesmo assim, toda distância derivada do Grip está marcada "est.".

## 1. Os três golpes (cajado, a arma inicial) e o padrão nas outras armas

### 1.1 Cajado: dados

Arquivo `C/Game/Weapons/PlayerWeapons.sjson` (linhas entre parênteses), projéteis em
`C/Game/Projectiles/PlayerProjectiles.sjson` (PP).

| Golpe | Preparação (carga até o dano) | Golpe ativo | Ataque travado depois do disparo (duro + cortável) | Pernas presas depois do disparo | Plantado do aperto até andar |
|---|---|---|---|---|---|
| 1 | 0,06 s (`ChargeTime`, 766) | o corte é um projétil de 430 u a 4000 u/s: 0,11 s, 5,4 m (PP 1059-1060) | 6 + 2 = 8 quadros, 0,13 s (781, 789) | 11 quadros, 0,18 s (`Swing1DisableMoveHold`, 797-799) | **0,24 s** |
| 2 | 0,11 s (850) | igual ao 1, dano 25 (PP 1120) | 3 duros, 13 no total: 0,22 s (867, 875) | 19 quadros, 0,32 s (884-885) | **0,43 s** |
| 3 (giro) | 0,36 s (937) | explosão em volta, raio 240 u (3 m), detona aos 0,1 s e segue até 0,3 s (`Fuse`, `TotalFuse`, `MultiDetonate`, PP 1174-1181) | 9 duros, 18 no total: 0,30 s (952, 962) | 30 quadros, 0,50 s (971-972) | **0,86 s** |
| Golpe da esquiva | 0,06 s (1110) | como o 1 | 5 duros, 14 no total (1133, 1142) | 14 (as mesmas travas) | 0,29 s |

Janela para emendar o próximo (`ControlWindow`): 0,4 s depois do golpe 1 e 2 e 0,6 s depois do 2 para o 3 (849, 936).
Reação do inimigo sem armadura ao golpe: preso 0,5 s nos golpes 1 e 2 e 1,1 s no giro (`OnHitStun`, `OnHitStunHeavy`:
`DisableMove`, `DisableRotate`, `DisableAttack`; PP 1100-1104 e 1211-1215).

### 1.2 Cajado: medido no vídeo

| Golpe | Medido (do quadro em que a câmera para até o primeiro em que volta a andar) | Detalhe quadro a quadro | Dados |
|---|---|---|---|
| 1 | 0,24 s (39,022 a 39,259); 0,24 s (25,820 a 26,056); 0,24 s (32,675 a 32,904); 0,25 s (34,008 a 34,258) | o corte já aparece no 1º quadro parado (carga menor que um quadro do vídeo) | 0,24 s |
| 2 | 0,40 s (39,321 a 39,724); 0,40 s (28,154 a 28,556); 0,40 s (33,036 a 33,439) | cajado puxado para trás em 39,321, disco do golpe em 39,418 (preparação 0,10 s); pernas presas até 39,72 (0,30 s depois do disparo) | 0,11 + 0,32 = 0,43 s |
| 3 | 0,83 s (39,786 a 40,620); 0,85 s no combo emendado (disparo em 38,0 a andar em 38,536) | giro do cajado de 39,89 a 40,09, explosão em 40,12 (preparação 0,33 s); pernas presas até 40,62 (0,50 s depois) | 0,36 + 0,50 = 0,86 s |
| 1, 2, 3 emendados sem andar | golpe 1 em 42,13, golpe 2 em 42,40, giro em 42,93; anda em 43,45 | intervalo 1 para 2: 0,27 s; 2 para 3: 0,53 s | 0,13 + 0,11 = 0,24 s; 0,22 + 0,36 = 0,58 s |

Quando o Daniel apertou o seguinte depois de as pernas soltarem, ela **anda** 1 a 4 quadros (0,03 a 0,14 s) entre os
golpes (25,8 a 26,8; 29,6; 32,9; 34,3): o jogo não segura ninguém além da trava. Durante todas as paradas o fundo fica
parado (diferença de imagem 0,2 a 0,5 contra 7 a 9 correndo): **nenhum avanço, nenhum deslize** nos golpes do cajado.
A pose é a do golpe e do retorno, pernas firmes; nenhum quadro de corrida aparece enquanto ela está presa, mesmo com a
direção segura.

### 1.3 Ela se desloca durante o golpe?

| Arma, golpe | Campo nos dados | Efeito | Deslocamento |
|---|---|---|---|
| Cajado 1, 2, 3 | `SelfVelocity 0`, `ChargeSelfVelocity 0` (770, 853-854, 939-941); `BlockMoveInput true` (749, 831, 918); `RootOwnerWhileFiring true` no 1 e 2 (748, 830) | entrada de movimento ignorada; velocidade zerada ao carregar e ao disparar (`ChargeCancelMovement`, `CancelMovement`, 750-751, 834, 920-921) | **zero** (confirmado no vídeo). Velocidade residual cortada no 2 (`Swing2Halt`, `GRIP` com `HaltOnEnd` em 0,08 s, 899-906) |
| Cajado, "lentidão" na carga | `SpeedModifier` 0,05 / 0,15 / 0,8 (806-808, 892-894, 978-981) | só vale para quem ainda tem velocidade (a entrada está bloqueada) | nada visível |
| Mira | `AutoLock` 390 u (4,9 m) no 1 e 490 u (6,1 m) no 2 e 3, arco 130 graus (753-755, 836-838, 923-925) | o golpe **gira** para o inimigo mais perto | ela vira, não anda |
| Adagas 1 e 2 | `BlockMoveInput false`, `RootOwnerWhileFiring false` (1872-1873); velocidade 1% na carga e 30% por 15 quadros no disparo (1921-1938) | anda devagar enquanto corta | a 30%: cerca de 2 m/s |
| Machado 1 | `ChargeSelfVelocity 500` (2429), `RootOwnerWhileFiring true` (2410) | impulso para frente **na preparação**, raiz no disparo | 500 u/s, cerca de 1,6 m (est.) durante os 0,30 s de carga |
| Machado 2 | `SelfVelocity 700` (2600), `Swing2Halt` 0,4 s (2607-2613) | impulso **no disparo** | cerca de 3 m (est.) |
| Machado 3 | `BarrelLength 250` (2690) | parado; o golpe nasce 3,1 m à frente | zero |
| Especial do cajado | `SelfVelocity -610` (1309) | **recuo** de 7,6 m/s no disparo | pequeno no vídeo (a câmera anda poucos pixels de 43,89 a 44,05); a distância exata depende do Grip, **a confirmar** |

Não existe campo `AllowMovementDuring` nem parecido nos dados (busca em `PlayerWeapons.sjson` e nas animações): o
movimento durante o golpe é decidido só pelos campos acima e pelas travas `DisableMove`.

### 1.4 O padrão "1 rápido, 2 mais lento, 3 o mais lento"

| Arma | Carga 1 / 2 / 3 (s) | Ataque travado 1 / 2 / 3 (quadros) | Pernas presas 1 / 2 / 3 (quadros) | Linhas |
|---|---|---|---|---|
| Cajado | 0,06 / 0,11 / 0,36 | 8 / 13 / 18 | 11 / 19 / 30 | 766, 850, 937; 781-799, 867-885, 952-972 |
| Adagas (4 golpes) | 0,04 / 0,05 / 0,08 (5 estocadas a cada 0,08 s) / 0,27 | 10 / 10 / 28 / 28 | anda devagar nos 3 primeiros; 13 a 28 presas no 4º | 1891, 1953, 2010-2013, 2070; 1905-1918, 1960-1974, 2021-2034, 2079-2092 |
| Machado | 0,30 / 0,48 / 0,78 | 24 / 28 / 59 | 35 / 28 / 59 | 2428, 2597, 2702; 2458-2477, 2627-2636, 2719-2728 |

Regra que os três seguem: **o finalizador custa de 3 a 6 vezes a preparação do primeiro e trava o dobro**; o golpe 2 fica
perto do 1 (1,25 a 1,8 vezes). O ciclo do cajado (carga + trava de ataque) é 0,19 / 0,33 / 0,66 s, razão 1 : 1,7 : 3,4.
Golpe ativo curto em todas: arcos varrem a 1600 a 2400 graus/s, de 0,08 a 0,11 s (adaga 130 graus a 1600, PP
2747-2749; machado 240 graus a 2400 e 220 a 2000, PP 3588-3590 e 3523-3525); o golpe pesado do machado detona aos
0,16 s e a onda cresce por 0,45 s (PP 3635-3644).

### 1.5 Cancelamento pela esquiva

A esquiva (`WeaponBlink`) tem `CanCancelDisables true` (42): ela corta toda trava com `Cancelable = true` (a parte
cortável do ataque travado e todas as `MoveHold`), mas **não** as travas duras (cajado 6 / 3 / 9 quadros, especial 12).
Golpes não cortam travas (`CanCancelDisables false`, 771, 860, 947). Detalhes de buffer e esquiva já medidos em
`game_feel_measures.md` (tabelas 3 a 5).

## 2. Especial e Ômegas: preso, por quanto tempo, e o que evita "patinar"

| Ação | Carga | Travas depois do disparo | Pernas presas | Linhas |
|---|---|---|---|---|
| Especial (`WeaponStaffBall`) | 0,1 s, velocidade a 60% na carga (`InstantStop`) | 12 duros + 18 sem atacar (0,3 s) | **0,71 s** (`Special1DisableMoveHold`, `DisableRotate` também), cortável só pela esquiva | 1313, 1338-1360, 1362-1368 |
| Especial: recarga | | `Cooldown 0,7`, `ClipRegenInterval 0,35` | | 1312, 1318 |
| Ômega do especial | segurar 0,65 s, 10 de Magia | `Cooldown 0,31`, sem recuo (`SelfVelocity 0`) | as mesmas 0,71 s (`ApplyEffects`) | `WeaponData_Staff.lua` 474-501 |
| Ômega do ataque (`Swing5`) | 0,8 s, velocidade 3%, giro quase travado por 49 quadros, parada (`Halt`) 0,13 s | 20 duros + 47 cortáveis (0,78 s) sem andar nem atacar | 0,78 s | 1028, 1053-1100 |

**Medido no vídeo (especial, 43,72 a 44,62)**: esquiva até 43,76; em 43,786 ela já está de pé mirando; disparo em 43,89
(carga 0,1 s); fica na pose do disparo e depois baixa o cajado, pernas firmes, **sem nenhum quadro de corrida** com a
direção segura; volta a correr em 44,62, **0,73 s depois do disparo** (dados: 0,71). Outras duas vezes: 45,69 a 46,47
(0,78 s do aperto) e 47,18 a 47,84.

Como o Hades evita patinar (todas as peças estão nos dados):

1. **A entrada de movimento é ignorada**, não guardada: `BlockMoveInput true` (1288). Sem entrada, a unidade não entra
   em locomoção, então o clipe de corrida (`MoveGraphic`) nunca toca.
2. **A velocidade é zerada** ao carregar e ao disparar (`ChargeCancelMovement`, `CancelMovement`, 1289-1290) e a
   unidade fica enraizada no disparo (`RootOwnerWhileFiring`, 1287).
3. **A trava de pernas é um efeito com tempo fixo** (`DisableMove`, 0,71 s), cortável só pela esquiva.
4. **O corpo toca o clipe da ação, não o de andar**: disparo (`Special1_Fire`) e depois o retorno (`Special1_End`,
   `Hero_Melinoe_Staff_Attacks_Animation.sjson` 683-685 e 752-757). O retorno tem `CancelOnOwnerMove true`: andar o corta,
   mas só quando andar é possível, isto é, depois da trava.
5. **A transição para a corrida é misturada** em 11 quadros a partir do retorno do especial e em 4 a 10 a partir dos
   retornos dos golpes (`Hero_Melinoe_Staff_Locomotion_Animation.sjson` 437-458).
6. O único deslize é intencional e curto: o recuo do especial (`SelfVelocity -610`), na pose do disparo.

## 3. Movimento

| Medida | Hades II | Linha |
|---|---|---|
| Velocidade | 540 u/s = 6,75 m/s, sem aceleração | `PlayerUnits.sjson` 26 |
| Virar a direção | instantâneo (`RotationSpeed 216000`) | 25 |
| Virar o corpo desenhado | 1340 graus/s | 19 |
| Atrito de impulsos | `Grip 1000` (inimigos 2500) | 47; `Enemies.sjson` 30 |
| Arrancar e parar | clipes próprios (`MelinoeStart`, `MelinoeStop` = `Run_Start`, `Run_End`); a parada tem `CancelOnOwnerMove` | `PlayerUnits.sjson` 27-28; `WeaponData_Staff.lua` 29-31; Locomotion 371-375, 595-600 |
| Virar correndo | clipes de 180 graus (velocidade 1,2) e 90 graus para cada lado (0,8), que voltam ao ciclo de corrida | Locomotion 192-201, 231-238, 307-315 |
| Ciclo de corrida casado com a velocidade | `NativeMoveSpeed 540` na corrida e nas viradas, 740 na corrida longa; passos nos quadros 9, 25, 41... (um a cada 16 quadros, 1,8 m por passo a 540 u/s se os clipes forem a 60 qps) | 413, 421, 714; 514-580 |
| Velocidade durante o golpe | cajado: zero (entrada bloqueada); adagas: 30%; machado 1 e 2: 35% na carga | ver 1.3 |
| Esquiva | 3 quadros de carga, 0,2 s, 5,6 m, 1 carga a cada 0,74 s, proteção 10 + 16 quadros, corta travas cortáveis, guarda o ataque 23 quadros para virar golpe da esquiva | `PlayerWeapons.sjson` 14, 20, 26, 28, 42, 62, 78-97 |
| Ferido | 0,2 s sem andar nem girar, mas **pode atacar**, cortável pela esquiva; desliza 0,3 s com atrito a 5% e para | `Enemy_BiomeF_Projectiles.sjson` 30-47 |

O que corta o quê, em uma linha: esquiva corta tudo o que é cortável; golpe nunca corta trava; andar só corta o clipe de
retorno (`CancelOnOwnerMove`), nunca uma trava.

## 4. Inimigos de Érebo

Conjunto da região: `Guard`, `Brawler`, `Radiator`, `Screamer`, `Mage`, `SiegeVine`, cada um com elite
(`EnemySets.lua` 4-33). Velocidades em `C/Game/Units/Enemies.sjson`; ataques nos `WeaponData_*.lua`; golpes em
`Enemy_BiomeF_Projectiles.sjson` (EBF). Base de todos: giro 1200 graus/s, `Grip 2500` (`Enemies.sjson` 8, 30).

### 4.1 Sequência comum de ataque (todos)

`EnemyAILogic.lua`: preparação = `PreAttackDuration`; os últimos `min(0,5 s, preparação)` são o "vai bater" (2088):
tremor de 3 u a 400 e clarão branco subindo até 0,95 do corpo (2374-2377, `PreAttackEndShake`). `StopBeforeFire`
para o corpo no fim da preparação (2414); `PreAttackStop` para no começo (2073). Depois `FireDuration` e
`PostAttackDuration` (a janela de punição). Reação ao golpe: comuns tocam a animação de atordoamento e a espera da IA
acaba (`EndThreadWaitsOnStun`, `EnemyData.lua` 75), com o golpe em preparação apagado quando o tipo tem
`ExpireProjectilesOnHitStun` (`WeaponData_Guard.lua` 32, `EnemyData_Radiator.lua` 44). Duração do atordoamento: a do
golpe da heroína (0,5 s, 1,1 s no pesado; seção 1.1). Elites com armadura não atordoam até ela quebrar (já
implementado na E1b). Surgir: 1,8 s de apresentação (`ActivateDuration`), aparece aos 0,5 s com 1 s de fade
(`EnemyData.lua` 87-95); reação ao ver a heroína 0,05 a 0,2 s (119-120).

### 4.2 Por inimigo

| Inimigo | Anda | Para antes? | Preparação / golpe / recuperação | Desloca no golpe | Linhas |
|---|---|---|---|---|---|
| Guard (corpo a corpo) | 125 u/s = 1,6 m/s (elite 3,1) | segue andando e mirando na preparação, para no fim (`TrackTargetDuringCharge`, `StopBeforeFire`) | 0,9 s (clipe a 0,45) / 0,3 s, explosão de 3,1 x 2 m à frente, sai aos 0,18 s / **2,1 s** (elite 1,5, dois golpes a 0,2 s, não para) | investida 700 u/s, cerca de 1,2 m (est.); alcance para começar 290 u = 3,6 m | `Enemies.sjson` 112, 139; `WeaponData_Guard.lua` 12-23, 52-61; EBF 9-17 |
| Brawler (bruto) | 160 u/s = 2 m/s (elite 3,5) | precisa de linha de visão; para no fim | 1,15 s (último 0,4 s tremendo) / 0,4 s / 0, **emenda** golpe curto: 0,65 s (0,5 s tremendo e piscando) / 0,4 s (arco de 190 graus a 1000 graus/s) / **1,1 s** | investida 1800 u/s com atrito x1,3 parado em 0,3 s: cerca de 4,9 m (est.), começa a 6,25 m; o golpe curto 300 u/s | `Enemies.sjson` 167, 194; `EnemyData_Brawler.lua` 111-185; `EffectData.lua` 1928-1937; EBF 54-131 |
| Radiator (giro) | 390 u/s = 4,9 m/s (elite 7,4) | para na preparação (`PreAttackStop`) | 1,5 s / 1,6 s girando 356 graus a 250 graus/s (elite 500) / 1,35 s (elite 0,5) | zero; só ataca a 1,9 m e desiste de chegar em 4 s | `Enemies.sjson` 202, 232; `WeaponData_Radiator.lua` 15-26, 66; EBF 247-251, 302-304 |
| Screamer (cone) | 290 u/s = 3,6 m/s, gira 720 graus/s (elite 4,9) | **não para**: anda e gira devagar (amortecimento 0,8) enquanto o cone sai | 1,2 s / cone preso a ele por 3,8 s (dano a cada 0,5 s e lentidão 0,35 s) / 0,6 s; depois recua 1,5 a 1,75 s; no máximo 2 atacando; se ferido a menos de 1,6 m, revida | zero | `Enemies.sjson` 404-405, 437; `EnemyData_Screamer.lua` 38-58; `WeaponData_Screamer.lua` 48-64; EBF 330-379 |
| Mage (atirador) | 280 u/s = 3,5 m/s (elite 5,5) | espera virar (até 1 s), mira quase travada (0,08), para no fim | 1,0 s / 3 orbes a cada 0,17 s (elite 7) / 0,7 a 0,9 s | **recua** 400 u/s por orbe (x0,95 cada) | `Enemies.sjson` 54, 79; `WeaponData_Mage.lua` 9-40, 61-65; EBF 183-195 |
| SiegeVine (trepadeira) | parado | | 0,8 s / trepadeira a 150 u/s, aceleração -15, 12 s / 3,25 s (elite 3 a cada 0,7 s, 2,25 s) | zero | `Enemies.sjson` 604; `WeaponData_SiegeVines.lua` 12-16, 41-45; EBF 427-441 |

Ferir a heroína: todo golpe de perto de Érebo trava as pernas dela 0,2 s e a faz deslizar 0,3 s (EBF 30-47, 96-105).

### 4.3 Teleporte (blink)

- **Nenhum comum de Érebo se teleporta.** Quem some e reaparece é a **elite com o atributo "Blink"** (sorteado entre
  os atributos de elite, `EnemySets.lua` 649-663; elites só a partir da 3ª sala, `EnemyData.lua` 253-259):
  a cada 5,5 a 9 s, antes de andar, para, toca o efeito de aviso no lugar onde está (`BlinkPreWait`), vira para o
  destino, espera **0,5 s**, some e aparece num ponto de nascimento a até 1000 u (12,5 m) da heroína com o efeito de
  chegada, e espera **0,2 s** antes de agir (`EnemyData.lua` 267-283; `EnemyAILogic.lua` 1086-1229). Ao sumir, a mira
  automática da heroína solta o alvo (`ClearAutoLock`, 1202). Golpes emendados marcam "Blink ban" para nunca
  teleportar no meio de um combo (`EnemyData_Brawler.lua` 182-183).
- **Hécate (chefe)**: corre a 600 u/s = 7,5 m/s (mais que a heroína), gira 900 graus/s, 6050 de vida, fases em 66% e
  33% com intervalos de invocação (`Enemies.sjson` 4819-4820; `EnemyData_Hecate.lua` 79, 285-411).
  - **Teleporte para perto** (`HecateTeleport`, só na fase 3 da luta normal): clipe de saída no lugar dela e **0,5 s**,
    aparece a até 200 u (2,5 m) da heroína com o clipe de entrada e espera **0,8 s**; emenda o golpe de perto, que tem
    0,7 s de preparação (no mínimo 0,42 s de clarão até 0,8), golpe de 0,2 s com um salto para trás (-2100 u/s) e
    **2,2 s** de recuperação (`WeaponData_Hecate.lua` 806-846, 867-913). Do aparecer ao dano: no mínimo 1,5 s.
  - **Divisão** (fases 1 a 3): some sem espera e reaparece a 4,4 a 25 m com duas cópias invulneráveis a pelo menos
    10 m umas das outras; as três atiram juntas (linha de tochas: 1,0 s de preparação, 7 tiros a cada 0,5 s, 2,2 s)
    (1154-1244; cópia invulnerável em `Enemies.sjson` 4861-4875). Com a dificuldade ligada, 800 de dano em 1 s força uma
    divisão, uma vez a cada 9,5 s (`EnemyData_Hecate.lua` 150-157).
  - **Investida** (só na versão difícil e na forma sombria): gira rápido, 0,25 s de preparação, 3000 u/s por 0,13 s com
    parada em 0,15 s (5,6 m, est.), 0,27 s (1316-1382), quando a heroína está a mais de 6,25 m (1049-1050).
  - Golpes de perto em par: direita 0,85 / 0,4 / 0,35 s e logo esquerda 0,5 / 0,5 / **2,2 s** (935-1017): a dupla
    rápida termina sempre numa janela longa.

## 5. Som: como o golpe rápido não fica repetitivo

| Mecanismo | Dado | Linha |
|---|---|---|
| Camadas por golpe | 2 sons no disparo: o sopro do cajado e uma voz curta de esforço (o giro troca a voz por uma de golpe forte) | `WeaponData_Staff.lua` 89-93, 149-153, 217-221 |
| Variações | o evento do sopro (`MelStaffSwipeWhoosh`) usa **13 amostras** (`StaffSwipeWhoosh_1` a `_13` no `Fx.bank`); a escolha e a variação de tom ficam dentro do FMOD (**a confirmar**) | `C/Audio/Desktop/Fx.bank` (nomes das amostras), `C/Audio/GUIDs.txt` |
| Impacto por material | osso e carne `StaffImpact`, pedra e metal `MetalStoneClangShort`, com armadura um ricochete, invulnerável um tinido, obstáculo a versão pequena; o giro usa a versão grande | `WeaponData_Staff.lua` 94-108, 154-168, 222-236; `CombatPresentation.lua` 2940-3012 |
| Limite simultâneo | todo `PlaySound` leva `ManagerCap` (46 nos sons de arma, 32 nos impactos de material, 26 em armadura, invulnerável e padrão; inimigos 32) | `CombatPresentation.lua` 2258, 2985-2999; `Enemies.sjson` 14 (o motor aplica; o efeito exato é **a confirmar**) |
| Recarga por som | cada som pode ter `Cooldown`: não toca de novo antes do tempo (relógio global por nome) | `CombatPresentation.lua` 2269; `UtilityLogic.lua` 807-829 |
| Som de carga | toca durante a carga, para com 0,2 s de fade quando dispara ou cancela (`StoppedBy`); no Ômega o tom segue o tempo de carga (`SetPitchToPropertyValue`) | `WeaponData_Staff.lua` 210-215, 282-289; `CombatPresentation.lua` 2276-2308 |
| Som no quadro da animação | passo pesado no quadro do golpe (3 no golpe 1, 6 no 2, 3 no giro), um baque extra no quadro 5 do giro, um giro de lâmina no quadro 14 da preparação dele | `Hero_Melinoe_Staff_Attacks_Animation.sjson` 58-65, 157-164, 251-262, 290-301 |
| Falas | sorteio sem repetir até esgotar (`RandomRemaining`), chance 10% em seguida (`SuccessiveChanceToPlay`), recargas de 8 a 300 s | `EnemyData_Guard.lua` 71-91; `EnemyData_Hecate.lua` 416-461 |
| Inimigos | um som de preparação próprio por tipo (`PreAttackSound`) e um de alerta | `EnemyData_Guard.lua` 20, 44; `EnemyAILogic.lua` 2144 |

`SimultaneousPlayLimit` não aparece nos dados; o limite simultâneo do Hades é o `ManagerCap`.

## O que aplicar em A Selagem

### Em destaque: andar não corta o golpe (o que o Daniel pediu e o vídeo confirma)

No vídeo, com a direção segura o tempo todo, ela para, golpeia e só volta a andar quando a trava acaba: **0,24 s no
golpe 1, 0,40 s no 2, 0,83 a 0,85 s no giro, 0,73 s depois do disparo do especial** (dados: 0,24 / 0,43 / 0,86 / 0,71).
A regra nos dados é a soma de cinco peças, e é isso que o Guerreiro deve copiar:

1. **Entrada de movimento ignorada durante carga e disparo** (`BlockMoveInput true`). Não guardar a direção para
   "soltar" deslizando depois: ela simplesmente vale de novo quando a trava acaba.
2. **Velocidade zerada ao começar e ao disparar** (`ChargeCancelMovement`, `CancelMovement`, `RootOwnerWhileFiring`) e
   corte da velocidade residual (`Halt`).
3. **Trava de pernas com tempo fixo depois do disparo** (`SwingNDisableMoveHold`: 11, 19 e 30 quadros; especial 0,71 s),
   que **só a esquiva corta** (`Cancelable` + `CanCancelDisables` da esquiva). Nem andar nem outro golpe cortam.
4. **O corpo toca o clipe do golpe e depois o do retorno**, nunca o de correr, enquanto a trava dura; o retorno é o
   único que andar corta (`CancelOnOwnerMove`), e só depois da trava.
5. **Mistura curta para a corrida**: 4 a 10 quadros (0,07 a 0,17 s) a partir do retorno de um golpe, 11 (0,18 s) a
   partir do especial.

Hoje (E1c) `move_scale` 0 segura o golpe, mas "andar corta o fim do golpe depois que ele acerta" e o especial solta as
pernas em `SPECIAL_WALK_AFTER` 0,1 s. A troca proposta: o fim da trava passa a ser o `MoveHold` do Hades, cortável só
pela esquiva. O "patinar" que o Daniel viu no especial não se resolve tirando a trava; resolve-se com os itens 1, 2 e 4
(velocidade zero e clipe de pose, nunca o de corrida, enquanto preso).

### Golpes do Guerreiro, plantados: preparação, golpe e retorno

Números em segundos depois do aperto. "Ataque livre" = quando o próximo golpe pode sair (o aperto antes disso fica
guardado); "anda" = fim da trava de pernas.

| Golpe | Preparação | Golpe ativo | Ataque livre | Anda | Hades (cajado) | Hoje |
|---|---|---|---|---|---|---|
| 1 | 0,06 a 0,12 | 0,10 (varre o arco) | preparação + 0,13 | preparação + 0,18 (total 0,24 a 0,30) | 0,06 / 0,13 / 0,18 | 0,12, recuperação 0,22, anda ao acertar |
| 2 | 0,11 a 0,16 | 0,10 | preparação + 0,22 | preparação + 0,32 (total 0,43 a 0,48) | 0,11 / 0,22 / 0,32 | 0,16, 0,28 |
| 3 (giro) | **0,36** (0,28 + 0,08 de brilho) | detona aos 0,1 e segue até 0,3 | preparação + 0,30 | preparação + 0,50 (total 0,86) | 0,36 / 0,30 / 0,50 | 0,26, 0,42 |

- Ritmo: manter a escada do Hades (giro de 3 a 6 vezes a preparação do golpe 1, trava do giro o dobro). A queixa do
  Daniel "o primeiro é rápido demais" pede a ponta de cima da faixa (0,12 s), não a do cajado; o giro é o que está
  curto hoje (0,26 contra 0,36).
- Travas duras (nem a esquiva corta): 6 / 3 / 9 quadros (0,1 / 0,05 / 0,15 s) depois do disparo; o resto, só a esquiva.
- Janela para emendar: 0,4 s nos golpes 1 e 2, 0,6 s antes do giro (já é o nosso).
- Sem avanço no golpe: o Hades **gira** o golpe para o inimigo mais perto (4,9 a 6,1 m, arco 130 graus) em vez de levar
  o corpo até ele. Se o Guerreiro quiser o puxão do `LUNGE_MAGNET`, o padrão do Hades é o do machado: o impulso vai **na
  preparação** (cerca de 1,6 m em 0,3 s) ou no disparo do golpe 2 (cerca de 3 m) e nunca no retorno; o pé fica plantado
  na trava. Decisão do Daniel (ele pediu "atacar parado").
- Inimigo comum atingido: preso 0,5 s (golpes 1 e 2) e 1,1 s (giro).

### Especial sem patinar

- Carga 0,1 s, dardo, **pernas presas 0,71 s depois do disparo** (cortável só pela esquiva), ataque livre 0,3 s depois,
  especial de novo 0,7 s depois.
- Durante as 0,71 s: velocidade zero, entrada ignorada, corpo no clipe de disparo e depois no de retorno; nada de corrida.
  Recuo opcional na pose do disparo (Hades: 7,6 m/s, curto; medir no nosso antes de pôr).
- Ômega do especial: segurar 0,65 s, mesma trava de 0,71 s, sem recuo. Ômega do ataque: 0,8 s de carga a 3% de
  velocidade com o giro travado; depois 0,78 s sem andar nem atacar (0,33 s duros).

### Inimigos

- O aviso final é igual para todos: os últimos min(0,5 s, preparação) com tremor e clarão subindo (o nosso
  `EnemyFx.ramp` faz o papel; conferir que o pico cai no mesmo intervalo).
- Esqueleto (nosso Guard): 1,6 m/s, 0,9 s de preparação andando e mirando, para no fim, 0,3 s de golpe, investida de
  cerca de 1,2 m e **2,1 s** de janela depois. O nosso já tem 0,9 s e a investida de 700/U por 0,3 s; conferir a janela
  (hoje `attack_cooldown` 1,4).
- Bruto (Brawler): investida longa (cerca de 4,9 m em 0,3 s) e golpe curto emendado sem andar; janela de 1,1 s no fim.
- Atiradores: o Mago recua 400 u/s por orbe; o Screamer anda enquanto ataca e recua 1,5 a 1,75 s depois.
- Heroína ferida: pernas presas 0,2 s, **ataque liberado**, cortável pela esquiva, deslize de 0,3 s.
- Teleporte: nenhum comum. Se quisermos um elite que some, a receita é a do "Blink": 0,5 s de aviso no lugar de origem,
  reaparece a até 12,5 m, 0,2 s antes de agir, nunca no meio de um combo, a cada 5,5 a 9 s. Para Morvath, a da Hécate:
  0,5 s de saída visível, reaparece a até 2,5 m, 0,8 s de espera, golpe com 0,7 s de preparação e 2,2 s de janela
  (mínimo de 1,5 s entre aparecer e ferir). Decisão do Daniel (Morvath hoje não teleporta).

### Som

- Duas camadas no disparo de cada golpe (lâmina + respiração ou esforço), nunca só no acerto. Pelo menos 8 a 13
  variações do sopro da lâmina sorteadas sem repetir a anterior, com tom variando pouco (o quanto o Hades varia não está
  nos dados; sugestão nossa: ±4%).
- Impacto por material do alvo (osso, carne, pedra, armadura, invulnerável) e uma versão grande para o finalizador.
- Limite por som: no máximo 3 ou 4 cópias do mesmo som tocando, a mais velha cortada (o papel do `ManagerCap`), e uma
  recarga curta por nome (0,03 a 0,05 s, sugestão nossa) para os acertos de muitos alvos no mesmo quadro.
- Som de carga com o tom subindo com a carga e fade de 0,2 s ao soltar ou cancelar.
- Passo pesado no quadro do golpe (o pé que planta), que também vende o "parado".
- Voz: no máximo 1 em 10 golpes, sem repetir até esgotar.

## Perguntas em aberto

- Fórmula do `Grip` e o que o `ManagerCap` faz no motor (pedem decompilar o executável com a REA, se valer o custo).
- Distância exata do recuo do especial (medir de novo com uma captura a 60 qps de verdade; a de hoje tem 29 qps
  efetivos).
- Duração própria de cada clipe da Melinoë (estão nos `.gr2`, binários; os tempos acima vêm das travas e do vídeo).
