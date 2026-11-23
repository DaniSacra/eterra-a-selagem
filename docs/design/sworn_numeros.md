# Números de combate do jogo estudado e o que levamos para A Selagem

Estudo só de leitura, feito com o leitor UnityPy sobre os pacotes de dados do jogo que o Daniel comprou, com a autorização dele ("só para
verificar como foi feito e pegar ideias, sem copiar nada"). Lidos apenas campos numéricos, tempos de linha do tempo e nomes técnicos.
Nada de textura, malha, áudio, animação, texto narrativo ou código foi exportado; nada foi escrito na pasta do jogo; os dumps ficaram
na pasta de trabalho temporária. Não há tabela do jogo estudado copiada aqui: só faixas, medianas e papéis. Nomes dele não aparecem.
Certeza: **[L]** lido direto num campo, **[D]** derivado de campos lidos (conta nossa), **[I]** inferido (hipótese).

## (a) Faixas e medianas

### 1. Heróis
- **Vida**: herói leve 50, herói pesado 75 [L, ficha de cada classe]. Uma ficha geral de jogador mostra 100 e graça 0,5 s [L], provavelmente
  base que as classes sobrepõem [I]. Velocidade 6,0 (leve), 5,0 (pesado), 5,5 (misto) [L]. **Graça após dano 0,2 s** nas três classes [L].
- **Esquiva** (leve): recarga 0,8 s (pesado 0,85), **1 carga** de base (+1 pela meta) [L], duração do clipe 0,2 s (pesado, rolamento, 0,33 s)
  [L], camada de colisão de esquiva ligada durante todo o clipe (invulnerável no clipe inteiro) [I], alcance 2,5 de base e 5,0 no máximo [L,
  significado do máximo (segurar?) [I]]. Ela corta o golpe desde o primeiro quadro (marca a 0,03 s) e o golpe só cancela no meio [L].
- **Golpe leve** (famílias de arma, medianas): 3 a 5 golpes por combo, dano 15 a 40 (espada 20/20/40, garras 15/15/25/30, maça 40/40/60,
  martelo grande 60/60/120, cajado longo 15 x4 e 40, lança 15/15/25), duração 0,4 a 1,1 s por golpe (mediana 0,67 s), **o dano sai em 0,03
  a 0,3 s (mediana 0,15 s)** com hitbox de 0,05 a 0,15 s [L]. Janela de cancelamento (o próximo golpe ou esquiva) abre em 30 a 60% do
  clipe (mediana 45%), no finalizador em 70 a 75% [L, marcas de transição]. Há `bufferDuration` de **0,45 s** de entrada guardada [L].
- **Golpe pesado**: sem custo de recurso, com recarga de 0,7 a 1,5 s (mediana 0,9 s), dano 2 a 3 vezes o leve (40 a 120) e empurrão 10
  [L]. Alguns se carregam segurando (1,5 a 5 s de carga) [L]. Magia de arma custa 1 barra; o ultimate custa 100 de carga própria [L].
- **Parada de impacto** (`freezeDuration`, é a nossa hit stop [I]): 0,075 s no golpe comum, **0,2 s nos golpes 1 e 2 e no finalizador
  de espada e maça**, 0,1 s no cajado longo, 0,3 s no 5º golpe, 0,125 a 0,2 s nos pesados [L]. Tremor de câmera: leve 0,28 a 0,5 (0,2 a
  0,3 s), pesado 0,45 a 0,85 (0,3 a 0,5 s) [L]. Mira automática de 3 m nos primeiros 0,08 a 0,2 s do golpe [L].
- **Ponto doce** de espada 1,6 vezes o dano [L]; hero com bônus de costas 1,0 (inimigos 0,5, arco de 60 graus) [L, uso [I]].
- **Magia**: ganha 0,009 de barra por ponto de dano (espada), penalidade 0,5 em golpes que acertam vários [L]; cada magia gasta 1 barra,
  então uma barra pede cerca de 110 de dano [D]. Regeneração 0,15 por segundo [L, unidade [I]].
- **Peso do leve contra o resto** [D]: no combo de espada o 3º golpe vale 40 contra 20, o pesado 40, a magia de dano direto 50 a 100,
  o ultimate 30 a 450. Dano por segundo do leve em sequência: 33 a 65 (mediana 40) [D].

### 2. Inimigos (famílias; vale para uns 25 tipos lidos)
- **Vida do comum 100 a 450 (mediana 250; o comum "de escola" 150)**; menor tipo 10 a 40; **versão maior (minichefe de grupo) 1000 a 3000
  (6 a 10 vezes o comum)**; minichefe de sala 6000 a 10000; chefe final 18000 a 22000 [L]. Velocidade do comum 2,0 a 4,5 (mediana 3,75),
  rápidos 5 a 6, parados 0 a 1; herói é 1,6 vez mais rápido que o comum [L, D].
- **Poise (resistência a atordoar)**: comum 5 a 150 (150 de vida = 75 de poise), maior 300 a 500, minichefe 800 a 1300, final 1600; razão
  poise/vida mediana 0,26 [L, D]. `hitsToFreeze` 4 a 5 no comum, 15 a 25 no maior, 30 a 50 nos chefes [L]. Todo maior e todo chefe é imune
  a empurrão; comum não [L]. **Atordoamento ao quebrar: 2,0 s no comum (0,5 s nos fracos que atiram de longe), 3,5 s num minichefe** [L].
- **Dano por golpe**: comum 8 a 10 (mediana 10), forte 12 a 15, chefe 10 a 16; raios 5 a 9 por pulso a cada 0,4 a 0,5 s [L]. Projéteis
  trazem dano 1 no ataque e o real na entidade (não lido) [L].
- **Aviso até o dano, corpo a corpo comum** (primeira janela ativa): 0,33 a 0,83 s, **mediana 0,67 s** (investida, estocada e salto 0,48 a
  0,67; pancada de martelo e anel 0,83) [L]. **Janela ativa** 0,07 a 0,5 s (mediana 0,2 s). **Duração total do ataque** 1,5 a 2,8 s
  (mediana 1,65); **recuperação depois do último dano** 0,5 a 1,8 s (mediana 0,8 s) [L, D]. Sequência de golpes de maior: um golpe a
  cada 0,4 s (triplo e quíntuplo) [L]. A mira trava logo (rotação zerada a partir de 0,08 s do aviso) [L].
- **À distância**: o primeiro projétil sai em 0,23 a 0,8 s (mediana 0,65 s) de ataques de 1,1 a 2,3 s; rajada tripla com 0,45 s entre
  os projéteis; mortero marca a área e demora 1,0 a 1,5 s; raio varre 30 graus em 3,4 s [L].
- **Famílias de comportamento vistas com número**: investida/salto, estocada com recuo, anel (golpe no chão 12 a 15), giro (4 pancadas a
  cada 0,45 s), rajada, mortero (3 por salva), raio contínuo, invocação (3 a 5 inimigos, 0,4 s entre eles, raio 6 m; o maior invoca ao
  começar), cura em grupo (3,35 s), grito que acelera o bando (15 s de efeito, 8 m), escudo de grupo (raio 8 m), fuga (3,5 s), explosão ao
  morrer (0,6 s de corrida e dano 8) [L].
- **Intervalo entre ataques e fila de atacantes**: o intervalo mora numa árvore de comportamento serializada em binário, **não decodificado**
  [não lido]. Não achei campo de fichas de ataque (máximo de atacantes); só pontos de ameaça por distância para escolher o alvo [L].
- **Tamanho dos grupos**: custo de cada inimigo no sorteio: pequeno 1, comum 3, médio 5, feiticeiro 7 a 7,5, maior 9 a 13, minichefe 6 a
  100, chefe 999 [L]. Orçamento da sala por índice: 4 a 12 pontos (veja 3) [L], ou seja 2 a 4 comuns ou 1 maior [D]; reforço quando
  restam 2 vivos (`mobMinimumThreshold`) e no máximo 15 vivos em eventos de horda [L].

### 3. Curva de dificuldade
- **Não há escala de vida ou dano por sala nem por bioma**: a vida de cada tipo é fixa. O que cresce é a **curva de orçamento por sala** de
  cada região: 4 a 8 (vale em 6) a 11; 6 a 8 (vale 7) a 11; 5 a 8 (vale 5) a 10; a última região 6 plano [L]. Picos com vale de alívio.
- **Seis níveis de dificuldade**: vida x0,7 / 1,0 / 1,3 / 1,6 / 2,0 / 2,5, dano x0,85 / 1,0 / 1,15 / 1,3 / 1,5 / 2,0, chance de inimigo
  corrompido 0 / 0 / 5 / 10 / 15 / 20%, corrupções por sala 0 / 0 / 0,8 / 1,6 / 2,4 / 3,2, de chefe 0 / 0 / 0 / 1 / 1 / 2, ganho de moeda
  de meta x1,0 a 1,25 [L]. Chance de corrupção sobe em degraus de 10 pontos, de -40 a +40 [L].
- **Corrupção de sala** (peso 0,4 a 1,3): inimigos x1,5 de dano, x1,5 de vida, x1,5 de velocidade de andar, +20% de ataque, regeneram 15 de
  vida depois de 3 s, explodem ao morrer, campo lento, armadilha x2; contra o jogador: andar x0,7, recarga de esquiva x1,5, regeneração de
  Magia x0,5; chefe: dano x1,25 e vida x1,2 [L]. **Inimigo corrompido** tem 1,5 a 2 vezes a vida do comum e 1,5 a 2 vezes o poise [L, D].
- **Cooperativo**: vida de inimigo x1,0 a x2,0 de 1 a 4 jogadores, de chefe x1 a x4, "intensidade" (orçamento) x1 a x2; reviver devolve 30% [L].

### 4. Bênçãos e crescimento entre partidas
- Cinco raridades; para um mesmo efeito, mediana: incomum 1,17, rara 1,33, épica 1,50, **lendária 1,67 vez o comum** (extremos 0,2 a 8, mas
  quase todos entre 1,3 e 2,0) [L, D]. Valores de porcentagem comuns 0,15 a 0,5 (mediana 0,30); fixos 3 a 80; recargas caem 1 s por degrau [L].
- Crescimento (jogador no máximo contra novo): vida +50 em 5 níveis (100% no leve, 67% no pesado), dano base +15%, velocidade +15%, **+1
  carga de esquiva**, +2 cargas de Magia, +5 de vida por sala, 1 a 3 reanimações; dano da magia +50%, do 3º golpe +75% [L].
  Resultado: **evoluído = 1,7 a 2,0 vez a vida, 1,15 vez o dano, 2 cargas de esquiva** [D].

### 5. Derivados (todos [D]; o dano depende de arma e de nível de dificuldade)
- Golpes leves para matar um comum de 150: espada 7 a 8, garras 7, maça 4, martelo grande 2; mediana 6. Tempo: 3 a 4 s. Maior (1000 a
  1500): 40 a 70 golpes leves, 25 a 35 s. Minichefe de sala: 2,5 a 4 minutos; chefe final: 5 a 9 minutos (as Bênçãos encurtam).
- Golpes do comum para matar o herói leve: 5 a 6 (50 de vida, 9 a 10 de dano); pesado 7 a 8; no nível 5 (dano x2) 3 golpes.
- Um comum ataca a cada 1,6 a 2,2 s (total + espera [I]), então 3 comuns dão 15 a 17 de dano por segundo no herói leve se todos acertam.

## (b) Lado a lado

| Tema | Jogo estudado | A Selagem (Guerreiro) |
|---|---|---|
| Vida do herói | 50 (leve), 75 (pesado); evoluído 100 | 30 base; Maestria +25 (55) |
| Graça depois de levar dano | **0,2 s** | **1,3 s** (`hurt_invuln`), 6,5 vezes mais |
| Esquiva | 1 carga, recarga 0,8 s, 0,2 s de clipe; evoluído 2 cargas | 1 carga, recarga 1,1 s, 0,2 s, 5,6 m, 18 quadros de proteção |
| Velocidade do herói / comum | 6,0 / 3,75 (1,6x) | 6,75 / 3,75 esqueleto, 4,9 corredor (1,4 a 1,8x) |
| Leve: golpes e dano | 3 a 5, 15 a 40 (espada 20/20/40) | 3 (15/15/20), mais o 4º do Dom |
| Leve: tempo do dano / ciclo | 0,15 s / 0,67 s por golpe | 0,08, 0,13, 0,36 s / combo de 3 em 1,22 s (0,4 s por golpe) |
| Dano por segundo leve | 33 a 65 (mediana 40) | 41 (50 em 1,22 s) |
| Pesado | grátis, recarga 0,9 s, 2 a 3x o leve | onda custa 12 Magia, 0,5 s entre disparos, 35; Ômega 100 por 20 Magia |
| Magia / recurso | 1 barra por magia; sobe com dano (0,9%/ponto) | Magia máx 50; sobe por finalizador e abate; Q (Brado) é recarga de 12 s, sem Magia |
| Parada de impacto | 75 a 300 ms (mediana 200 ms nos golpes grandes) | 25, 65, 70 ms no combo; 80 Brado; 50 Ômega |
| Ponto doce / costas | x1,6 / bônus de costas | não existe |
| Vida do comum | 100 a 450 (mediana 250) | 45 a 130 (esqueleto 60, corredor 45, besteiro 130) |
| Vida do maior / elite | 1000 a 3000 (6 a 10 x comum) | guarda 255, elite = comum com armadura |
| Minichefe / chefe final | 6000 a 10000 / 18000 a 22000 | Cavaleiro 450, Ancião 510 / Morvath 6050 |
| Dano do comum / do herói em % | 8 a 10 de 50 (16 a 20%) | 5 de 30 (17%), 8 (27%), guarda 14 (47%), Cavaleiro 16 a 18 (55%) |
| Aviso do comum (mediana) | 0,67 s (0,33 a 0,83); mira trava em 0,08 s | 0,9 (esqueleto), 1,0 (corredor), 1,15 (guarda); mira rastreia 0,3 s |
| Descanso depois do golpe | 0,8 s (0,5 a 1,8) | 1,2 / 1,35 / 1,1 s (`recover_time`) |
| Poise e atordoamento | todos têm; quebrar atordoa 2 s; maior e chefe imunes a empurrão | só elite tem armadura; regra F8 `NONE` não atordoa |
| Vivos de uma vez | 2 a 4 comuns ou 1 maior (orçamento 4 a 12) | 4 a 8 comuns (teto 20), até 3 atacando |
| Escala de dificuldade | 6 níveis (vida 0,7 a 2,5, dano 0,85 a 2,0) | uma só |
| Raridade | x1 / 1,17 / 1,33 / 1,5 / 1,67 | x1 / 1,5 / 2 / 2,5 |

Leitura: o dano por segundo do herói já bate (41 contra 40) depois do "herói fraco" do lote C1; o resto não. O inimigo comum tem **um
terço da vida** e o herói **seis vezes e meia a graça**, então o ataque básico nunca perde a troca; e o aviso do comum é 35% mais longo
que o de lá, com descanso 50% maior, o que dá tempo demais para quem só bate.

## (c) Propostas (originais, ordenadas pelo impacto em "é só apertar o botão de atacar")
1. **Graça após dano de 1,3 para 0,5 s** (faixa 0,4 a 0,6; o outro jogo usa 0,2). Motivo: com 1,3 s o dano que entra tem teto de um golpe a
   cada 1,3 s, qualquer que seja a multidão; trocar golpes sai de graça. Muda: `hurt_invuln` em `_hero` do `make_data.gd` e `Player.hurt`;
   medir com o robô (12 sementes) e subir o dano do esqueleto de 5 para 6 só se morrer pouco.
2. **Aviso curto, janela ativa curta e descanso que castiga**: comum corpo a corpo `attack_windup` 0,65 (esqueleto 0,9 para 0,65, corredor
   1,0 para 0,7), guarda 0,85; golpe ativo 0,15 a 0,25 s; `recover_time` 0,8 a 1,0 s (hoje 1,1 a 1,35); `aim_lock` de 0,3 para 0,15 s (a mira
   trava cedo, quem se mexe de lado escapa). Motivo: aviso longo deixa bater por cima; aviso curto exige olhar. Muda: `EnemyDef`,
   `ENEMY_RECOVER`, `Horde._behave_*`, `EnemyFx` (o brilho cresce no mesmo ritmo); testes de cadência de `combat_cadence.md`.
3. **Barra de poise em todo inimigo e quebra que abre janela**: poise = 50% da vida no comum, 35% no maior; golpe leve enche 1x, onda e
   Ômega 2x (hoje `ARMOR_SPECIAL` 1,5), Brado 1x em área; ao quebrar, **atordoado 1,5 s e leva +50% de dano** (uma melhoria de meta do outro jogo
   chega a +50% contra atordoado). Motivo: dá um objetivo ao combo (encher e quebrar) sem voltar ao atordoamento de graça. Muda: `EnemyDef.poise`,
   `stagger_time`, `Horde` (hoje só elite), `Combat`, barra pequena no `EnemyFx`; respeita a regra F8 (só quebra atordoa).
4. **Vida do comum para 2 a 2,5 vezes**: matar um comum em 3 s (mediana de lá), 2 combos: esqueleto 60 para 120, corredor 45 para 90,
   besteiro 130 para 160, feiticeiro 80 para 130. Motivo: hoje cai em 1,5 s, nunca dá tempo de o aviso acontecer. Muda: `_pair` no
   `make_data.gd`; reduzir o teto de vivos de 4 a 8 para 3 a 6 junto (veja 9).
5. **Ponto doce na ponta da lâmina**: os 35% externos do alcance dão x1,5, o miolo x1,0; o corte em volta (giro) sem ponto doce. Motivo:
   obriga a medir distância em vez de colar no inimigo (o outro jogo tem x1,6 em espadas). Muda: `ComboNode.sweet_start`, `sweet_mult`,
   `Combat` (hoje o alcance de 5,4 m acerta tudo igual), marca de anel na espada.
6. **Golpe comprometido**: ciclo do golpe 1 e 2 de 0,22 e 0,35 s para 0,45 s cada, finalizador 0,8 s; cancelável só pela esquiva até 45% (70%
   no finalizador); dano 15/15/20 para 21/21/29 (mesmo 41 de dano por segundo). Motivo: menos aperto por segundo, cada golpe vira decisão.
   Muda: `windup`, `recovery`, `move_hold`, `damage` de `cut1..3` e `FOURTH`; revisar `test_combo`, `test_warrior_talents`.
7. **Parada de impacto maior onde dói**: golpe 1 80 ms, golpe 2 100 ms, finalizador 160 ms, Ômega 200 ms, Brado 120 ms (hoje 25, 65, 70,
   50, 80); no máximo 12% do tempo da luta. Motivo: o outro jogo para 75 a 300 ms; o golpe pesa e o aperto vira ritmo. Muda: `hit_stop_ms`,
   limite em `HitStop`.
8. **Versão maior de dois comuns, como dado**: vida 7 vezes (esqueleto grande 420, corredor grande 315), poise 35%, imune a empurrão, uma
   habilidade a mais (esqueleto grande invoca 3 esqueletos a cada 8 s a 0,4 s entre eles; corredor grande dá 2 investidas). Custo 10 contra 3.
   Motivo: pico de tensão sem inventar inimigo novo. Muda: `EnemyDef` novo por `_pair` com `major: true`, `EncounterPool`, `EncounterGen`.
9. **Orçamento por pontos com vale de alívio**: custo por inimigo (pequeno 1, comum 3, médio 5, feiticeiro 7, maior 10) e curva por sala
   (4, 7, 6, 10, 8, 11, 11), reforço quando restam 2. Motivo: grupos pequenos, mais variados, e uma sala fácil depois de uma difícil. Muda:
   `EncounterGen` (hoje 55 + 15 por sala) lê `StageDef.budget_curve`; `rating` do `EnemyDef` vira o custo; `tier_alive` 3 a 6.
10. **Brado e Magia carregam batendo**: Magia por dano causado 0,25 por ponto de dano (200 de dano enchem a barra de 50; ajustar com o robô) além do
    finalizador; Brado volta em 12 s **ou** 120 de dano, o que vier antes. Motivo: o bater alimenta o resto, então apertar sem foco enche
    pouco quando o alvo escapa. Muda: `Magick`, `Player` (recarga do Brado), `hud` (barra do Brado já existe).
11. **Dificuldade em 6 degraus e corrupções de sala**: vida x0,7 a x2,5, dano x0,85 a x2,0, chance de inimigo corrompido 0 a 20%, e lista
    de 6 corrupções (dano x1,5, vida x1,5, andar x1,5, regenera 15 em 3 s, explode ao morrer, campo lento) com sorteio por sala. Motivo:
    mais para quem domina o combo; a corrupção troca regras em vez de só números. Muda: novo `DifficultyDef` e `RoomMod` em `data/`,
    `make_data.gd`, `Rooms`, tela de início; uma chave só (não escala por sala).
12. **Esquiva em dois tamanhos e recarga 0,8 s** (depois da 1): toque 3 m, segurar 5,6 m; recarga 1,1 para 0,8 s; proteção do clipe
    inteiro. Motivo: com graça curta, a esquiva é a defesa de verdade e precisa voltar rápido. Muda: `Player` esquiva (`dodge_*` em `_feel`
    e `_hero`), `Feel`; testar com Passos (carga extra).

## (d) O que não deu para ver
- **Intervalo entre ataques de cada inimigo e regra de fila**: a árvore de comportamento é binária e não decodifiquei; só tenho o
  comprimento de cada ataque. Não há campo de fichas de ataque visível, então pode não existir regra de fila.
- Dano real de projéteis (a ficha do ataque traz 1; o valor mora na entidade), distância das investidas e dos saltos, dano de ultimates e
  magias além do base, quanto de poise cada golpe tira, regras de carga dos pesados, curva de custo das magias e da carga do ultimate.
- Significado exato de alguns campos: alcance base e máximo da esquiva, `freezeDuration` (leio como hit stop), unidade da regeneração de
  Magia, e se a camada de esquiva cobre o clipe inteiro (leio que sim). Valores de pacotes de atualização substituem os base; usei os
  dois e priorizei o de atualização quando havia choque.
- Orçamento exato de cada sala (a curva é por índice; a mistura de inimigos sai de tabelas de sorteio por região, não lidas), quantas
  salas tem cada região, e modos extras (corrida de chefes) só em parte.
