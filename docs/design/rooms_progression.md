# Progressão das salas (room-designer)

Plano de progressão das salas da descida: a ideia de jogo de cada arena, tamanho, perigos, em que profundidade aparece,
como evolui e as métricas do robô que provam que ela joga diferente. Base das medidas de forma e de exposição:
`docs/design/room_redesign_level_review.md` (seções 0 e 1). Plantas: `_stage` do `tools/make_data.gd`.

## Estado em 2026-11-19 (o que existe)

| Sala | Tamanho, andável | Ideia de jogo (a pergunta da sala) | Profundidade (progresso) | Teto de pé | Perigo |
|---|---|---|---|---|---|
| Salão das Catacumbas | 32 x 30 m, cerca de 900 m² | abertura no claro; também fonte e loja | 1, 5 a 8 (fonte), 10 | 4 a 8 | nenhum |
| Cripta A | 24 x 21 m, 498 m² | cobertura: contornar o sarcófago do meio contra até 2 atiradores | 0,1 a 1,0 | 4 a 6, sem sacerdote | quatro lajes rachadas junto das paredes (RP-06), dormentes nas salas 2 e 3 |
| Cripta B (Ossuário) | igual | de que lado do muro divisor | igual | igual | duas lajes no pé do muro (RP-06) |
| Fendas A | 42 x 30 m, cerca de 1060 m² | em que ponte cruzar, ou dar a volta pelo sul; três tocos de apoio (RP-05) | 0,1 a 1,0 | 6 a 8 | nenhum |
| Fendas B | igual, ponte norte caída | uma ponte só e a volta sul | igual | igual | nenhum |
| Jardim A / B | 34 x 28 m, 875 m² | o tronco como escudo, raízes que cortam o passo | 0,1 a 1,0 | 6 a 8 | nenhum |
| Santuário A | 44 x 28 m, 1192 m² | nave aberta ou naves laterais (casa do guardião) | 0,4 a 1,0; guardião em qualquer uma | 6 a 8 | duas lajes em cada nave lateral (RP-06), também no guardião |
| Santuário B | igual, buraco na nave | o buraco entre o herói e o guardião | igual | igual | as lajes das laterais e a borda que desmorona nas pontas do buraco (RP-13) |
| Ponte A | 56 x 18 m, 771 m² | atravessar sob fogo: todos nascem no leste, bloco no fim da ponte 2 (RP-04) | 0,5 a 1,0 | 6 a 8, sem sacerdote | nenhum |
| Ponte B | 56 x 18 m, 701 m² | a ponte longa com patamar | igual | igual | nenhum |
| Runas A | 30 x 24 m, 702 m² | atrair os inimigos para a faixa que vai acender | 0,5 a 1,0 | 4 a 6 | faixas (sweep, comb, cut); herói 7, inimigos 60, nada a 6 m da entrada (RP-02, RP-03) |
| Runas B | igual | ilhas e a pedra quieta | igual | igual | ladrilhos (checker, frame, islands); idem |
| Provação, Altar | 16 x 14, 18 x 14 m | escolha sem luta | 2 a 7, 2 a 8 | sem luta | nenhum |
| Câmara do Selo | círculo de 12,5 m | Morvath | 11 | Morvath + até 6 | os ataques dele |

---

## Feito em 2026-11-19 (noite): RP-06 (laje rachada) e RP-13 só no Santuário B

**O que entrou.** `HazardDef.kind` `PLATES` (`plates`, `rearm`, `from_progress`, por laje `plate_hero_damage` e
`plate_push`), lógica pura `PlateHazard` (`scripts/core/plate_hazard.gd`), no jogo `PlateFloor`
(`scripts/game/plate_floor.gd`), dado `_plates` no `_stage`. Números: aviso 1,0 s (a laje acende da borda para o meio),
golpe 0,25 s, herói 7, inimigo 60 (RP-03), recarga 5 s, nada nos 3 s do começo, nunca em laje na boca de porta, no
máximo 3 armadas de uma vez (o 222700 do Sworn), dormentes antes do progresso 0,34 (salas 2 e 3: desenhadas, não ferem).
Lugares (todas de 3 x 3 m, inteiras no chão, fora de peça, porta e nascimento, 6 m ou mais da entrada; GUT):

| Sala | Lajes |
|---|---|
| Cripta A | (-7,2..-4,2; -10,3..-7,3) parede norte; (8..11; -7,5..-4,5) nordeste; (2..5; 7,3..10,3) sul; (8..11; 1,3..4,3) leste. O canto sudoeste é a entrada (6 m) e o noroeste é nascimento: "quatro cantos" virou "junto das paredes, fora dos corredores do sarcófago" |
| Cripta B | (-3,4..-0,4; -6,3..-3,3) e (1,4..4,4; -6,3..-3,3): os dois lados da ponta do muro divisor |
| Santuário A e B | nave lateral norte (-13,5..-10,5; -11..-8) e (10,5..13,5; -11..-8); sul (-7,5..-4,5; 8..11) e (0..3; 8..11). Valem também na luta do guardião |
| Santuário B (RP-13) | a borda que desmorona: (-2,6..0,4; -1,5..1,5) e (9,6..12,6; -1,5..1,5), nas pontas do buraco (ao longo dele a nave tem só 1,85 m), ferem 5 e jogam 2,5 m para longe do buraco; zona `hole_edge` |

As Fendas B ficaram sem a borda que desmorona: a tabela do Sworn (seção 3) diz "nunca lajes nas Fendas, a beira já pede
atenção", e o RP-08 (fenda que respira) é o perigo delas. Desenho: placeholder no estilo HAZARD do `ground.gdshaderinc`
(`plate`, `crack_m`): moldura e duas rachaduras em osso apagado em repouso (nunca âmbar), o âmbar entra da borda ao
armar. Falta a peça do `environment-artist` (SW-G7).

**Como medi.** Igual ao de cima, 36 sementes (1 a 36), base = este código sem o RP-06 (cópia isolada), final = RP-06 e
RP-13. Saídas: `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/rp06/`.

| Medida (por sala; "acordada" = sala 4 ou mais) | Base | Final | Aceite |
|---|---|---|---|
| Vitórias (36) | 29 | 25 | no máximo 3 abaixo (ver leitura) |
| `stuck` / `bot.stuck` | 0 / 0 | 0 / 0 | 0 |
| Morvath alcançado (mediana) | 236 s | 232 s | |
| Dano das lajes no herói, todas as vistas | | **0** em 91 salas | 0,5 a 2 |
| Cripta A acordada (6): golpes, dano nos inimigos, abates | | 3,0 / 50 / 0,17 | |
| Cripta B acordada (11) | | 2,7 / 30 / 0,27 | |
| Santuário A (25) / B (29) | | 0,5 / 2,4 e 1,1 / 4,1 | |
| Quem arma (Cripta A acordada, herói / inimigo) | | 1,2 / 1,8 | |
| Segundos do herói em cima (Cripta B / Santuário) | | 1,8 / 0,1 a 0,4 | |
| Cripta A zonas (norte, meio, sul) | 42 / 30 / 27 | 44 / 29 / 26 | |
| Santuário A naves laterais | 34% | 28% | 20 a 35% |
| Santuário B naves laterais, `hole_edge` | 28% | 26%, 1% | |
| Dano por sala (Cripta A / B acordada) | 0,0 / 1,75 | 0,67 / 2,55 | |

**Leitura.** As lajes armam e golpeiam (2,7 a 3 golpes por sala de Cripta acordada, metade armadas por inimigos), mas
**o robô nunca é atingido**: 1,0 s de aviso numa laje de 3 m é saída fácil para quem reage em 0,25 s (anda 5 m). É o que
o RP-03 já mostrou com as Runas: o robô lê bem o âmbar e o aceite de dano no herói vira a sessão do Daniel. Não encurto
o aviso (a regra é 1,0 s ou mais). Os inimigos também saem (andam atrás do herói), então o dano neles é baixo (14 a 50 por
sala); a laje hoje muda pouco onde se luta (Cripta igual, Santuário laterais 34 para 28%). As 4 vitórias a menos não vêm
das lajes (nenhum dano delas no herói): 5 das 6 sementes que trocaram de resultado morrem em Morvath, a partida diverge
na primeira sala com laje (efeito borboleta); com 36 sementes isso está no ruído (a seção de cima mediu 37 a 39 em 48 sem
mudar dano). O que levantaria a laje sem quebrar regra, para a sessão com gente: laje no caminho que o robô e o jogador
fazem de verdade (RP-21, lajes nas cabeceiras do sarcófago da Cripta A) e a seteira ligada (RP-16), que faz o jogador
pisar de propósito.

**Conferido.** `tools/check.gd` e `tools/test.sh` inteiro verdes; `tests/test_plates.gd` (10 testes: ritmo, inimigo
arma, dormente, porta, três de cada vez, lugares, saída andando de 12 x 12 pontos com 0,25 s de reação, sala real com
os números do `RESULT`, empurrão, a borda do Santuário B); `tools/fit_probe.gd` Cripta A e B e Santuário A e B iguais à
base (fantasma 0,32 / 0,31 / 1,20 / 1,20 m²; a laje é marca no chão, não peça). Sem captura na GPU (worktree fora do
espelho).

## Feito em 2026-11-19: RP-01 a RP-05 (quickwins aprovados pelo Daniel)

Só dado no `_stage` do `tools/make_data.gd` (regerado com `-- stage`) e um teste novo; nenhuma peça nova (as que o look
já desenha), nenhum texto novo. RP-17 e RP-19 ficaram para depois (ver o fim desta seção).

**Como medi.** `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 48, na mesma base
(código `47d06a7`, que dá exatamente os números de `a0d9bb9` da seção Sugestões), cada configuração numa cópia isolada
do projeto (outra frente mexia no repositório ao mesmo tempo). Configurações: **base**, **RP-03 sozinho** (só os dois
números das Runas) e **final** (RP-01 a RP-05). As partidas só se separam na primeira sala mudada, então cada sala tem
duas leituras: todas as salas da descida (n de 20 a 37 por vista) e a **pareada**, a primeira sala mudada de cada
semente, igual até ali. Ruído: nas salas que não mudaram (Cripta, Jardim, Santuário) as médias andam até 0,6 de dano e
10 pontos de tiro barrado só porque a partida chegou lá por outro caminho; diferença menor que isso não é efeito. Para
as Runas também 40 sementes de cada variante começando nelas (`--arena=runes --variant=v --smoke=40`, só a primeira
sala). Saídas e scripts fora do repositório:
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/rp/`.

**Descida inteira (48 sementes).** Vitórias 37 (base), 39 (RP-03 sozinho), 39 (final); `stuck` 0 e `bot.stuck` 0 nas
três; Morvath alcançado aos 236 s, 233 s e 237 s (mediana).

**RP-01, zonas em toda sala de luta.** Feito: Cripta A (`north` z < -3, `middle`, `south` z > 3), Cripta B
(`west_of_wall`, `east_of_wall`, `south_open` z > -3), Fendas (`bridge_n`, `bridge_s`, `south_way` ao sul do buraco sul,
`west`, `east`; a B herda, sem a ponte norte), Jardim (`tree_shade` 12 x 12 m em volta do tronco, `east_field` x > 2,
`rest`), Runas A (`pillars` os quatro ladrilhos em volta de cada pilar, `middle` a cruz entre eles, `edge`) e Runas B
(`quiet`, `middle`, `edge`). Zona dominante (final, % do tempo):

| Vista | Zonas | Dominante | Aceite 35 a 75% |
|---|---|---|---|
| Cripta A | north 42, middle 31, south 26 | 42 | sim |
| Cripta B | south_open 75,1, east_of_wall 16, west_of_wall 7 | 75,1 | **no limite**: a luta é no sul aberto, o muro quase não divide |
| Fendas A | east 58, south_way 17, west 15, bridge_s 7, bridge_n 3 | 58 | sim |
| Fendas B | east 63, west 15, south_way 14, bridge_s 7 | 63 | sim |
| Jardim A | east_field 54, rest 43, **tree_shade 2** | 54 | sim, mas o tronco como escudo não é usado |
| Jardim B | rest 48, east_field 46, tree_shade 5 | 48 | sim |
| Runas A | edge 38, middle 31, pillars 30 | 38 | sim |
| Runas B | middle 58, edge 32, quiet 10 | 58 | sim (a pedra quieta 7 para 10%) |

Leitura nova: o Jardim e a Cripta B não fazem a pergunta deles para o robô (tronco 2 a 5% do tempo; lado do muro 23%).
Pode ser o robô, que não procura cobertura (risco 7.1); é a primeira coisa a olhar com gente.

**RP-02, nada aceso a menos de 6 m da entrada.** Feito: `RUNES_ENTRY` (colunas 0 e 1 das linhas 3 a 7, coluna 2 das 3
a 6: todo ladrilho com algum chão a menos de 6 m de (-12,5; 3,5)) somado ao `HazardDef.quiet` das duas variantes. O
`RunesLook` pinta a pedra quieta pela peça `quiet`, não pelo campo, então esses ladrilhos continuam com a cara de runa
(só não acendem). GUT `test_nothing_lights_within_6_m_of_the_way_in` (`tests/test_hazard.gd`): 2000 padrões por variante,
herói em qualquer lugar e 0 a 8 de pé; nenhum ladrilho aceso a menos de 6 m e "vizinho apagado" em todos. Na base o
mesmo teste acha 6933 (A) e 8333 (B) ladrilhos acesos perto da entrada.

**RP-03, runas com peso (medido sozinho antes dos outros).** Herói 4 para 7, inimigos 35 para 60.

| Medida (por sala de Runas) | Base | RP-03 sozinho | Final (com RP-02) | Aceite |
|---|---|---|---|---|
| Dano das runas no herói, descida (A / B / as duas) | 0,67 / 0,80 / 0,73 | 1,17 / 2,10 / 1,59 | 1,46 / 0,35 / 0,95 | 1,5 a 3,5 |
| Dano das runas no herói, 40 começando nelas (A / B) | 0,40 / 0,70 | 0,53 / 1,57 | 1,23 / 1,23 | |
| Abates das runas, descida (A / B) | 0,79 / 0,50 | 2,00 / 1,25 | 2,38 / 1,45 | 1,5 ou mais |
| Dano nos inimigos, descida (A / B) | 121 / 97 | 196 / 114 | 208 / 138 | 25 vezes o do herói |
| Inimigos / herói (A / B) | 181 / 121 | 167 / 54 | 142 / 394 | |
| Vitórias (48) | 37 | 39 | 39 | no máximo 3 abaixo |

Leitura: os inimigos sentem (abates 2 a 3 vezes); o herói é tocado 0,1 a 0,3 vez por sala (3 a 9 golpes em 40 salas):
o robô lê bem o âmbar de 1,2 s, então o dano no herói por sala oscila em volta de 1 (0,35 a 2,1 conforme a amostra) e
fica abaixo da faixa de 1,5 a 3,5 na média. Não subo o número por isso: o passo 2 (10, o do Hades) fica para a sessão
do Daniel, como o RP-03 previa. O `combat-feel-director` ainda precisa revisar (dano novo no herói).

**RP-04, Ponte A: atravessar sob fogo.** Feito: `spawns` só na plataforma leste (saiu o retângulo do meio; a 2ª onda
continua fechando a oeste pelo `late_spawns`) e um `block` de 1,0 x 2,4 m, topo 2,2 m, em (16; 0), 1,5 m depois do fim
da ponte 2 (o herói desce da ponte atrás dele; corredores de 1,5 m e mais em volta).

| Medida | Base | Final | Aceite |
|---|---|---|---|
| Zona leste | 6% | 27% | 20% ou mais |
| Pontes (1 + 2) | 13 + 6 = 19% | 6 + 15 = 21% | 10 a 25% |
| Meio | 56% | 41% | abaixo de 45% |
| Dano por sala | 2,00 | 1,60 | 1,5 a 3,5 |
| Primeiro contato | 4,3 s | 6,1 s | |
| Tiros barrados | 21% | 16% | |
| `stuck` | 0 | 0 | 0 |

**RP-05, Fendas A: apoio dos dois lados.** Feito, com uma mudança: um toco de coluna de 1,5 m (raio 0,6, barra tiro)
de cada lado da fenda entre as cabeceiras, (-10,5; -4) e (5,5; -4), **e um terceiro na luta do leste**, (12,5; 1),
porque a luta é no leste (58% do tempo). Medido na pareada (23 salas): só os dois tocos 6,0% de tiros barrados;
oeste e leste da luta 7,4%; os três 10,7%.

| Medida | Base | Final | Aceite |
|---|---|---|---|
| Tiros barrados, pareada (23 salas) | 4,1% | 10,7% | 10 a 18% |
| Tiros barrados, descida (27 salas) | 4,4% | 9,5% | |
| Tempo (mediana) | 24,2 s | 24,7 s | dentro de 20% |
| Dano por sala (descida) | 1,30 | 1,26 | dentro de 20% |
| `fit_probe` (os dois looks) | fantasma 1,49, sem desenho 0 | fantasma 1,49, sem desenho 0, os três tocos 0% | igual |

A B (18% barrado na base, 16% no final) não mudou. A sala continua a mais aberta do jogo.

**Conferido.** `tools/check.gd` e `tools/test.sh` inteiro (numa cópia do código-base com só estas mudanças; ver o
relatório ao Game Director); `test_arenas.gd` (centro livre, 400 pontos nas peças, "cercado") verde;
`tools/fit_probe.gd` Fendas A e Ponte A iguais à base nos dois looks, toda peça nova desenhada (0% sem desenho);
`tools/arena_lab.gd --top` na GPU das duas salas (bloco e tocos no chão, `NavGrid` sem ilha cortada).

**Ficou para depois.** RP-17 (mureta): o que a medida pede é o Jardim (tronco 2 a 5%) e a Cripta B (sul aberto 75%), mas
nos dois o problema lido é o robô não buscar cobertura; uma mureta não o leva lá e muda a cara das salas do começo,
que hoje jogam bem. Fica para depois da sessão do Daniel. RP-19 (saídas no fundo): nenhuma medida do robô aponta
problema nas portas; é leitura de placa, pede captura e o `ui-ux-designer`.

---

## Sugestões 2026-11-19

Pedido do PO pelo Game Director: análise das 18 salas e variantes e sugestões priorizadas. **Nada foi implementado**;
nenhum código, dado, `CLAUDE.md` ou backlog foi tocado. O Game Director integra.

### 1. Como medi

- `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 48, código `a0d9bb9` (descida de 11
  salas no grafo da DV-1). Resultado: 37 vitórias de 48, Morvath alcançado aos 236 s (mediana), 0 `stuck`, 0
  `bot.stuck`, `max_alive` 8 em 42 descidas. Saídas e o script de leitura (fora do repositório):
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/runs/` e
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/tools/rooms.py`.
- Números dos perigos do Hades II lidos nos dados do jogo do Daniel (`Hades II/Content/Scripts/EnemyData_Traps.lua`,
  `WeaponData_Traps.lua`, `Content/Game/Projectiles/Enemy_Traps_Projectiles.sjson`), convertidos por 80 unidades = 1 m.
- Ressalva: é o robô com 0,25 s de reação, não gente. Ele lê bem os avisos e mal a posição; o que ele não mede (se a
  sala parece outra, se o perigo é legível) fica para a sessão do Daniel.

### 2. O que as medidas mostram

**2.1 Por sala e variante (48 descidas; dano = vida perdida pelo herói por sala, média)**

| Sala | Salas | Prof. média | Tempo (med.) | 1º contato (med.) | Dano | Golpes levados | Tiros barrados | Maior fonte de dano |
|---|---|---|---|---|---|---|---|---|
| Cripta A | 30 | 3,7 | 23,5 s | 3,5 s | 1,27 | 0,33 | 28% | mago |
| Cripta B | 29 | 5,3 | 27,2 | 3,1 | 1,38 | 0,38 | 24% | mago |
| Fendas A | 27 | 3,7 | 24,2 | 4,1 | 1,30 | 0,30 | **4%** | sacerdote |
| Fendas B | 33 | 3,7 | 24,1 | 4,2 | 1,21 | 0,33 | 18% | mago |
| Jardim A | 34 | 4,6 | 23,3 | 3,5 | 1,65 | 0,41 | 21% | mago |
| Jardim B | 24 | 3,9 | 24,5 | 3,5 | 1,62 | 0,42 | 26% | mago |
| Santuário A | 35 | 6,3 | 31,8 | 4,9 | 5,60 | 0,69 | 22% | Ancião, Cavaleiro |
| Santuário B | 37 | 6,0 | 31,8 | 5,1 | 6,05 | 0,70 | 20% | Ancião, Cavaleiro |
| Ponte A | 24 | 7,4 | 28,5 | 4,3 | 2,00 | 0,54 | 21% | mago |
| Ponte B | 25 | 6,8 | 29,5 | 5,5 | 2,96 | 0,80 | 5% | mago |
| Runas A | 24 | 6,5 | 27,1 | 3,0 | 2,08 | 0,54 | 11% | mago, runas 0,7 |
| Runas B | 20 | 7,2 | 26,6 | 3,5 | 1,60 | 0,35 | 3% | runas 0,8, mago |

**2.2 Onde o herói fica (`rooms[].zones`, % do tempo) e o perigo (`rooms[].hazard`, por sala)**

| Sala | Zonas | Perigo |
|---|---|---|
| Santuário A / B | nave 68 / 66, naves laterais 32 / 34 | |
| Ponte A | oeste 19, ponte 1 13, **meio 56**, ponte 2 6, **leste 6** | |
| Ponte B | oeste 14, **ponte longa 36**, patamar 20, leste 30 | |
| Runas B | pedra quieta **7**, resto 93 | 5,4 disparos, 102 de dano nos inimigos, 0,5 abate; herói 0,8 |
| Runas A | (sem zonas no dado) | 5,7 disparos, 121 de dano nos inimigos, 0,8 abate; herói 0,7 |
| Cripta, Fendas, Jardim | **sem zonas no dado** | |

**2.3 Pela descida (salas de luta sem guardião)**

| Profundidade | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 11 (Morvath) |
|---|---|---|---|---|---|---|---|---|---|
| Dano por sala | 0,17 | 0,12 | 2,20 | 0,79 | 1,03 | 2,16 | 3,55 | 3,87 | 24,5 |
| Salas com algum dano | **4%** | **4%** | 40% | 13% | 18% | 42% | 48% | 57% | |

Exposição por profundidade (48 descidas): Cripta, Fendas e Jardim caem 74% das vezes nas salas 2 a 4; Ponte e Runas só
de 5 a 9; o Santuário de 4 a 9 (guardião 1 vez por descida, luta comum mais 0,57).

**2.4 Leitura (o que é problema)**

1. **As três salas do começo jogam igual para o robô.** Nas salas 2 a 4, Cripta, Fendas e Jardim dão 22 a 24 s, 0,6 a
   0,8 de dano, primeiro contato em 3,5 a 4,2 s e o mago como maior fonte nas três. O que muda é só o tiro barrado
   (Cripta 28%, Jardim 21 a 26%, Fendas A 4%). As três ideias de jogo existem no desenho, mas não pesam.
2. **As salas 2 e 3 não pedem nada.** O robô sai ferido de 4% delas. O Hades começa fácil, mas aqui não há nem uma
   lição de espaço nas primeiras lutas.
3. **A curva sobe só pelos inimigos.** A mesma arena é a mesma sala na 2 e na 9 (variante sorteada 50/50 em qualquer
   profundidade, `RunMap`, `r.variant`). A Ponte B fere 48% mais que a A (2,96 contra 2,00), mas pode sair na 5; a Runas
   B, mais fácil que a A (1,60 contra 2,08), pode sair na 9.
4. **As Runas são uma arma de graça, não um perigo.** 121 de dano nos inimigos por sala contra 0,7 no herói (um golpe
   de 4 a cada 5 a 6 salas). No Hades II o perigo de sala fere a Melinoë 10 (barril de fogo, cubo de vapor,
   `FireBarrelExplosion`, `SteamCubeExplosion`) sobre os mesmos 30 de vida, e os inimigos 20 vezes isso
   (`BaseTrap.NonPlayerMultiplier` 20). O nosso 4 é 13% da vida; o dele, 33%.
5. **A pedra quieta da Runas B não é procurada** (7% do tempo para 36 m² de 702, 5%): a ilha segura não muda o jogo
   do robô. Pode ser o robô; com gente é a primeira coisa a olhar.
6. **A Ponte A não faz a pergunta dela.** "Segurar a ilha ou atravessar": o herói fica 56% no meio e 6% na plataforma
   leste. Os inimigos atravessam até ele; ninguém o obriga a cruzar.
7. **O buraco da Santuário B não muda onde se luta** (nave 66% contra 68% na A; dano 6,05 contra 5,60).
8. **Fendas A sem cobertura**: 4% dos tiros barrados (a B tem 18%). É a identidade dela (o salão aberto com atiradores
   do outro lado da fenda), mas o sacerdote, que é a maior fonte ali, atira por cima de tudo.
9. **Sem zonas em 7 das 12 vistas de luta**: não dá para provar que Cripta, Fendas, Jardim e Runas A jogam diferente.
10. **Regra quebrada pequena**: nas Runas nenhum ladrilho perto do ponto de entrada (`hero_spawn` em (-12,5; 3,5)) está
    proibido; só a calma de 3 s e as bocas das portas de saída protegem (`RuneFloor._init` passa só `exits`). A regra do
    perigo pede "nunca perto da porta de entrada".

### 3. Referência do Hades II (perigos de sala, dados do jogo)

| Perigo (bioma) | Como dispara | Aviso | Efeito na Melinoë | Efeito nos inimigos | Lição para nós |
|---|---|---|---|---|---|
| Árvore que tomba (`DestructibleTree`, Érebo) | 2 golpes da heroína; tomba para o lado do golpe | a árvore racha no 1º golpe | **0** (`PlayerMultiplier` 0) | lascas de 10 x 5 = 50 (até x 15 em outros modos) | perigo que o jogador **usa**; nunca fere quem o usa |
| Vapor (`SteamTrap`, Oceanus) | qualquer um a 2 m (`AttackDistance` 160, alvos inimigos e herói) | 0,2 s mais o chiado | 1 a cada 0,2 s por 3 s | x 20 | armadilha de proximidade; recarga longa (6 s) |
| Jato d'água (`FloodTrap`, Oceanus) | ciclo da sala | 0,55 s | 0 de dano, empurra | 0 (`NonPlayerMultiplier` 0) | perigo **sem dano** que muda a posição |
| Cubo de vapor e barril (`SteamCubeExplosion`, `FireBarrelExplosion`) | golpe | o pavio | 10, raio 7,5 m e 5 m | x 20 | 10 = um terço da vida |
| Raio (`BeamTrap`) | ciclo | aceso antes | 5 a cada 0,25 s, 13 m | x 20 | linha que varre |

Nossa regra (do Daniel) é mais estrita que a do Hades: aviso **nunca abaixo de 1,0 s** (o preparo do corredor e a mira do
mago), nada nos 3 primeiros segundos nem a menos de 6 m da entrada, sempre uma saída livre. Copiamos os números de dano e
a assimetria herói / inimigo; o aviso fica nosso.

### 4. Sugestões priorizadas

Custo: P até meio dia, M 1 a 2 dias, G 3 dias ou mais. Todas com a régua do item 1 (48 sementes; 8 por sala tocada no
mínimo) e os testes de sempre (`tools/check.gd`, `tools/test.sh`, `test_arenas.gd`, `test_descent.gd`, `fit_probe` sem
piorar). Vitórias nunca mais que 3 abaixo da base de 37 de 48 sem decisão do Game Director.

#### Quickwins (só dado, ou quase)

**[Feito 2026-11-19, ver "Feito em 2026-11-19"] RP-01 (P1) Zonas nomeadas em todas as salas de luta.**
- Problema: 2.2 e 2.4.9; sem zonas não se prova que Cripta, Fendas, Jardim e Runas A jogam diferente.
- Proposta: `_areas` em `_crypt` (fileira norte z < -3, centro em volta do sarcófago, fileira sul z > 3; na B "oeste do
  muro", "leste do muro", "sul aberto"), `_rift` ("oeste", "leste", "ponte norte", "ponte sul", "volta sul" z > 4),
  `_garden` ("sombra da árvore" num retângulo de 12 m em volta do tronco, "campo leste" x > 2, "resto"), `_runes` A
  ("pilares" os 4 ladrilhos em volta de cada pilar, "aberto").
- Dado: só `_areas(l, [...])` e `_areas(variante, [...])`; nada novo.
- Aceite: toda sala de luta com `zones` no `RESULT`; em cada uma a zona dominante entre 35 e 75% (uma zona com mais de 75%
  diz que a sala tem um lugar só).
- Dono: `room-designer`. Custo: P.

**[Feito 2026-11-19, ver "Feito em 2026-11-19"] RP-02 (P1) Runas: nenhum ladrilho perto da entrada.**
- Problema: 2.4.10.
- Proposta: a área de 6 m em volta do `hero_spawn` nunca acende.
- Dado: `HazardDef.quiet` aceita retângulos; somar `_rect(-15, -9, 0.5, 6.5)` nas duas variantes (os ladrilhos (0..1, 4..6)).
  Confirmar com o `environment-artist` que o `RunesLook` não pinta esses ladrilhos como a pedra quieta da B (a pedra é a
  peça `quiet`, não o campo do `HazardDef`; se pintar, a mudança vira P no `RuneFloor._init`: somar o retângulo da
  entrada às `doors`, sem dado).
- Aceite: GUT em `test_hazard.gd`: 2000 padrões nas duas variantes, nenhum ladrilho aceso a menos de 6 m do `hero_spawn`;
  `max_share` e "vizinho apagado" continuam.
- Dono: `room-designer` (dado), `gameplay-engineer` se for o caminho do código. Custo: P.

**[Feito 2026-11-19, ver "Feito em 2026-11-19"] RP-03 (P1) Runas com o peso do Hades: o herói sente, os inimigos caem.**
- Problema: 2.4.4.
- Proposta, em dois passos medidos: passo 1 `hero_damage` 4 para 7 e `enemy_damage` 35 para 60 (um esqueleto inteiro,
  três quartos de um mago); passo 2, se a sessão do Daniel achar justo, 10 (o do Hades) no herói. Aviso fica 1,2 s.
- Dado: os dois números em `_hazard()`.
- Aceite (48 sementes): dano das runas no herói 1,5 a 3,5 por sala de Runas; abates das runas 1,5 ou mais por sala;
  dano nos inimigos pelo menos 25 vezes o do herói; vitórias dentro da regra acima.
- Dono: `room-designer`; `combat-feel-director` revisa (é dano novo no herói). Custo: P.

**[Feito 2026-11-19, ver "Feito em 2026-11-19"] RP-04 (P1) Ponte A: atravessar sob fogo.**
- Problema: 2.4.6 (leste 6%).
- Proposta: a primeira onda só na plataforma leste (os atiradores já ficam lá por `max_ranged` 3) e um bloco de cobertura
  de 1,0 x 2,4 m, topo 2,2 m, na cabeceira leste da ponte 2, fora do tabuleiro (o herói chega ao fim da ponte coberto);
  a segunda onda continua fechando por trás, a oeste.
- Dado: `l.spawns` sem `_rect(-4, 4, -5.5, -3)`; um `_piece(15.8, 3.6, 1.0, 2.4, 2.2, &"block", true)` (a conferir no
  `arena_lab` contra a boca da ponte e no `fit_probe`).
- Aceite: leste 20% ou mais do tempo, pontes 10 a 25%, meio abaixo de 45%; nenhum `stuck`; dano por sala dentro de 1,5 a
  3,5; `test_arenas` "cercado" verde.
- Dono: `room-designer`; `environment-artist` desenha o bloco (peça que já existe). Custo: P.

**[Feito 2026-11-19, ver "Feito em 2026-11-19"] RP-05 (P2) Fendas A: uma meia cobertura em cada lado da fenda.**
- Problema: 2.4.8 (4% barrados, sacerdote a maior fonte).
- Proposta: um toco de coluna baixo (topo 1,5 m, barra tiro) em cada plataforma, a 3 m da cabeceira de cada ponte, fora
  da linha da ponte; a sala segue a mais aberta do jogo, mas cruzar tem um ponto de apoio.
- Dado: dois `_column(x, z, 1.5, 0.6)` em `_rift` A.
- Aceite: tiros barrados 10 a 18% na A; tempo e dano dentro de 20% de hoje; `fit_probe` sem peça sem desenho.
- Dono: `room-designer`, `environment-artist` (peça). Custo: P.

#### Médios (um comportamento novo de perigo de cada vez; depois disso, dado)

Regras comuns a todo perigo daqui (nada novo nelas): aviso legível no chão **ou** no corpo da peça, de 1,0 s ou mais;
fere inimigos também (na proporção da tabela 3), chave em `DefeatCause` e texto em `data/text_pt.tres` (nome a validar
com o Daniel); nunca a menos de 6 m do `hero_spawn` nem nos 3 primeiros segundos; teste de saída no molde do
`test_boss_exits.gd` (de 12 x 12 posições dentro do aviso, andar 1,0 s ou uma esquiva sai); `rooms[].hazard` por fonte
no `RESULT` (`enemy_damage`, `kills`, `strikes`, mais `hero_damage`). Desenho: entrego forma, tempo e estado como o
`RunesLook.set_tile`; placeholder do `GroundLook.Style.HAZARD` até o `environment-artist` com a spec do `art-director`.

**[Feito 2026-11-19 noite, ver "Feito em 2026-11-19 (noite)"] RP-06 (P1) Primeiro comportamento novo: `HazardDef` com gatilho de proximidade ("laje de pisar", H-2).**
- Problema: 2.4.1 e 2.4.2 (salas iguais e as primeiras sem lição); é o perigo mais barato que muda onde lutar.
- Proposta: lajes de 3 x 3 m fixas, marcadas sempre (moldura rachada no chão, visível em repouso), que **qualquer um** arma
  ao pisar (herói ou inimigo, como o vapor do Hades, que mira inimigos e herói); 1,0 s de aviso (a laje acende da borda
  para o meio), golpe de 0,25 s em quem estiver em cima, recarga 5 s. Herói e inimigos com os números do RP-03.
  Onde: Cripta A nos quatro cantos (nunca nos corredores de 4 m do sarcófago do meio), Cripta B no pé do muro divisor dos
  dois lados, Santuário A e B nas naves laterais (a pergunta da sala ganha um preço: a nave tem a investida do Cavaleiro,
  a lateral tem as lajes). Desde o progresso 0,34 (sala 4); antes disso a laje aparece apagada, sem disparar (a moldura
  ensina sem ferir).
- Dado: `HazardDef.kind` (`GRID` de hoje, `PLATES` novo), `plates: Array[Rect2]`, `rearm`, `from_progress`; o resto já
  existe (`warn`, `fire`, `hero_damage`, `enemy_damage`, `start_delay`). Lógica pura num `PlateHazard` em `scripts/core/`
  com GUT; no jogo o mesmo `Ground.add_hazard` das Runas. Depois do primeiro, laje em qualquer sala é só dado.
- Aceite: nas salas com lajes, dano das lajes no herói 0,5 a 2 por sala e nos inimigos pelo menos 10 vezes isso; Cripta A
  com a zona "cantos" abaixo de 25% do tempo (hoje desconhecido, ver RP-01); Santuário com naves laterais entre 20 e 35%;
  8 sementes por sala sem `stuck`; teste de saída verde.
- Dono: `gameplay-engineer` (código e testes), `room-designer` (lugares e números), `environment-artist` (moldura e
  acender), `combat-feel-director` (aviso). Custo: M.

**RP-07 (P1) Variante e intensidade pela profundidade.**
- Problema: 2.4.3.
- Proposta: `ArenaVariant.depth` (faixa de progresso como a do `RoomLayout`) e o `RunMap` sorteia só entre as variantes
  que cabem (cai na primeira se nenhuma couber). Proposta de faixas, pelo dano medido: Ponte A 0,5 a 0,8 e B 0,67 a 1,0;
  Runas B 0,5 a 0,8 (mais fácil, a pedra quieta) e A 0,67 a 1,0; Fendas A 0,1 a 0,6 e B 0,34 a 1,0; Cripta e Jardim
  sem faixa (as duas iguais em dano). Depois, a intensidade do perigo pela mesma faixa: a variante tardia leva um
  `HazardDef` próprio (Runas A tardia com `rest` 2,4 para 1,8 e `max_share` 0,35 para 0,4), sem comportamento novo.
- Dado: o campo e as faixas no `_stage`; o filtro é 3 a 5 linhas no `RunMap` (onde `r.variant` é sorteado) mais o
  `_keeps_rules`.
- Aceite: `test_descent.gd` com 1000 grafos verde e uma asserção nova (nenhuma variante fora da faixa); na régua, dano por
  sala sobe de forma monótona por faixa (2 a 4, 5 a 7, 8 a 9) em cada arena com duas variantes.
- Dono: `gameplay-engineer` (filtro), `room-designer` (faixas). Custo: P a M.

**RP-08 (P2) Fenda que respira (H-4), o perigo sem dano das salas do começo.**
- Problema: 2.4.1 e 2.4.2: as Fendas caem 74% das vezes nas salas 2 a 4, onde ninguém se fere.
- Proposta: o jato d'água do Hades (`FloodTrap`: 0 de dano, empurra). Três trechos de 6 m da borda da fenda, um por vez,
  em ciclo de 7 s: a bruma sobe 1,2 s (aviso no chão, faixa de 6 x 3 m na beira), depois empurra 2,5 m **para longe da
  borda** todo corpo no trecho, por 0,3 s. Sem dano: corta o bote de quem está na beira e tira o herói do caminho da
  investida. Nunca no trecho das zonas de nascimento nem das cabeceiras das pontes (não empurra para dentro de um grupo
  que acabou de nascer).
- Dado: `HazardDef.kind` `PUSH` com `zones: Array[Rect2]`, `push`, `push_dir` (normal da borda); o empurrão já existe
  (`Arena.sweep` para corpos empurrados). Comportamento novo uma vez.
- Aceite: 0 de dano; abates por queda 0 (ninguém cai, D-28); inimigos empurrados 3 ou mais por sala; tempo da sala dentro
  de 15% de hoje; zonas das Fendas mudam (cabeceiras das pontes com menos tempo que hoje, via RP-01).
- Dono: `gameplay-engineer`, `room-designer`, `environment-artist` (bruma). Custo: M.

**RP-09 (P2) Coluna rachada que tomba (o "árvore que cai" do Érebo).**
- Problema: o pedido do PO ("o jogador pode usar a seu favor") e 2.4.1; hoje nenhuma peça reage ao herói.
- Proposta: fiel ao `DestructibleTree`: certas colunas já quebradas (Santuário (15; -6) e (-9; 6), Jardim (4,5; 7), Cripta
  B (6,5; -6)) racham no 1º golpe do herói (aviso no corpo: fenda e poeira, que já é o aviso) e no 2º tombam para o lado
  do golpe: faixa de 1,2 x 5 m no chão marcada por 0,6 s enquanto ela inclina, golpe de 50 nos inimigos, **0 no herói**
  (como no Hades); fica o toco (`column_base`, barra corpo, não tiro). Um uso por coluna por sala. Só o herói derruba.
- Dado: `ArenaObstacle.hits_to_fall` (0 = nunca), `fall_length`, `fall_damage`; no tombo a peça vira o toco
  (`piece` e `blocks_shots` trocados); `NavGrid` refeito uma vez (a pegada encolhe, nunca cresce: ninguém fica preso).
- Aceite: em 48 sementes o robô derruba alguma coluna em 30% ou mais das salas que têm uma (o robô precisa aprender:
  mirar inimigos alinhados atrás da coluna); dano das colunas nos inimigos 40 ou mais por sala com coluna derrubada;
  0 no herói; `test_arenas` (pontos dentro de peças) com a coluna e com o toco.
- Dono: `gameplay-engineer` (peça que muda, robô), `room-designer`, `environment-artist` (racha, tombo, toco). Custo: M a G.

**RP-10 (P2) Raiz que golpeia (H-1), o Jardim acorda da sala 4.**
- Problema: o Jardim aparece 41 de 58 vezes nas salas 2 a 4 e não fere (0,76); as raízes só cortam o passo.
- Proposta: só as duas raízes de fora (as que não chegam a 6 m do centro do chão livre). Quem fica 0,5 s a menos de 1,5
  m dela (herói ou inimigo) arma; a raiz racha e solta poeira por 1,2 s, com a faixa de 1 m ao longo dela mais 1 m de cada
  lado marcada; golpe de 0,25 s com os números do RP-03 e empurrão de 1 m para fora; recarga 6 s por raiz. Dormente antes
  do progresso 0,34 (as raízes da sala 2 e 3 ficam como hoje).
- Dado: com o RP-06 pronto, é `HazardDef` `PLATES` com retângulos girados ao longo da raiz e gatilho por tempo de
  permanência (`dwell` 0,5); se o retângulo girado não couber no `PlateHazard`, é o único código novo.
- Aceite: dano das raízes no herói até 1,5 por sala de Jardim tardia; inimigos 10 vezes isso; zona "sombra da árvore" (RP-01)
  cai para menos de 30% nas salas tardias sem cair nas do começo.
- Dono: `gameplay-engineer`, `room-designer`, `environment-artist` (a raiz que racha). Custo: M (P depois do RP-06).

**RP-11 (P2) Corrente que varre a ponte e raio entre pilares (H-3 e "raio que varre"): um comportamento, duas salas.**
- Problema: 2.2: na Ponte B o herói passa 36% na ponte longa; nada a torna perigosa. Nas Runas A os pilares são só
  cobertura.
- Proposta: comportamento `LINE` (faixa entre dois pontos que avisa e depois golpeia; opcionalmente anda ao longo da
  própria normal). Ponte B: a corrente do pilone balança e varre uma faixa de 2 m atravessando a ponte longa, aviso 1,2 s
  (faixa no tabuleiro e a corrente rangendo), golpe 0,25 s, empurra ao longo da ponte (nunca para fora), ciclo 6 s,
  nunca a menos de 4 m do patamar (o patamar é o abrigo). Ponte A: uma ponte por vez, alternando. Runas A, só tardia
  (RP-07): raio entre dois pilares vizinhos ao longo da linha da grade, 1 m de largura, no lugar de um padrão de faixa
  (conta nos 35%).
- Dado: `HazardDef.kind` `LINE`, `lines: Array[PackedVector2Array]`, `width`, `sweep_speed`; o resto existente.
- Aceite: Ponte B com a ponte longa entre 15 e 25% do tempo e o patamar acima de 25%; dano da corrente no herói 0,5 a 2
  por sala; nunca as duas pontes da A ao mesmo tempo (GUT); teste de saída (da faixa, sempre uma esquiva para o patamar
  ou uma plataforma).
- Dono: `gameplay-engineer`, `room-designer`, `environment-artist` (corrente, raio). Custo: M.

#### Maiores (depois da sessão do Daniel)

**RP-12 (P3) Urna de óleo e fogo que corre (o barril do Hades) na Cripta tardia.**
- Proposta: urnas (`Masonry.urn` já existe) no pé das paredes que o golpe do herói acende: pavio de 1,0 s com o aro no
  chão de 2,5 m, explosão de 8 no herói e 80 nos inimigos; o óleo derramado corre por um canal raso de 6 m (linha do
  RP-11, andando a 3 m/s, aviso à frente dele) e apaga em 2 s. Só depois do progresso 0,67. Custo M depois do RP-11.

**[Feito só no Santuário B, 2026-11-19 noite] RP-13 (P3) Borda que desmorona no Santuário B e nas Fendas B (o "chão que cai" sem buraco novo).**
- Problema: 2.4.7. Proposta: lajes da beira do buraco (RP-06) que racham ao pisar e, no golpe, ferem 5 e empurram para o
  chão firme (a queda fere e devolve; nenhum chão some, então nada de `NavGrid` dinâmico, o risco que fez o H-6 ser
  "não"). Aceite: zona "beira do buraco" com tempo próprio e dano dela até 1 por sala. Custo P depois do RP-06.

**RP-14 (P3) Cristal que se descarrega na Runas B (H-5).**
- O cubo de vapor do Hades: o cristal ao norte (fora do chão) enche a cada 3 golpes do herói perto dele e descarrega na
  fileira de lajes para onde aponta (a regra de 35% vale). Dá à pedra quieta (2.4.5) uma razão de ser: é para onde se
  foge da descarga que você mesmo chamou. Custo M; espera o L-12 do Daniel.

**RP-15 (P3) Fonte e loja em câmaras próprias (P-10, já com o Daniel).** O Salão aparece 2,5 vezes por descida; a medida
  de hoje não muda a recomendação da leitura de 18/11. Só registro.

### 5. Progressão proposta (com tudo acima)

| Salas | Arenas | O que pede | Perigo |
|---|---|---|---|
| 1 | Salão | aprender a luta no claro | nenhum |
| 2 e 3 | Cripta, Fendas A, Jardim | cobertura, ponte, tronco | lajes e raízes visíveis e dormentes; fenda que respira (sem dano) |
| 4 a 6 | guardião no Santuário; Cripta B, Fendas B, Jardim tardio, Ponte A, Runas B | escolher o lado | lajes acordam (Cripta, Santuário); raízes do Jardim; coluna que tomba |
| 7 a 9 | Ponte B, Runas A, Cripta, Santuário B | posição sob pressão | corrente e raio, Runas tardias, urnas de óleo, borda que desmorona |
| 10, 11 | loja, Morvath | | |

Meta da curva na régua (48 sementes, salas de luta sem guardião): dano por sala 0,3 a 0,8 nas salas 2 e 3 (hoje 0,12 a
0,17), 1 a 2 nas 4 a 6, 2,5 a 4,5 nas 7 a 9; nenhuma sala de luta com uma zona acima de 75% do tempo; nenhuma regra de
perigo quebrada (aviso, entrada, saída livre).

### 6. Métrica de "joga diferente" (para todo item)

Duas vistas jogam diferente quando, na régua, diferem em pelo menos duas destas: zona dominante (outra zona ou 15
pontos), tiros barrados (2 vezes ou 10 pontos), maior fonte de dano (outro papel ou o perigo), primeiro contato (1,5 s),
dano do perigo (presente ou não). Hoje, nas salas 2 a 4, Cripta, Fendas e Jardim diferem só nos tiros barrados.

### 7. Riscos

- O robô não procura cobertura nem ilha segura (2.4.5): metas de zona podem precisar de ajuste no `Bot` antes de valerem
  como aceite; nesse caso o aceite vira a sessão do Daniel.
- Mais dano de perigo (RP-03, RP-06) soma ao mago, que já é a maior fonte em quase toda sala: medir RP-03 sozinho antes
  de ligar os outros.
- Cada comportamento novo (RP-06, RP-08, RP-09, RP-11) é uma entrega; um por ciclo, na ordem RP-06, RP-11, RP-08, RP-09.
- Nomes dos perigos e as chaves "Derrotado por" passam pelo Daniel (cânone).

### 8. O que precisa de arte (`environment-artist` com a spec do `art-director`)

Moldura rachada e acender da laje (RP-06, RP-13), bruma que sobe da fenda (RP-08), coluna que racha, tomba e o toco
(RP-09), raiz que racha (RP-10), corrente que balança e o raio entre pilares (RP-11), urna e óleo (RP-12), cristal (RP-14),
bloco da Ponte e tocos das Fendas (RP-04, RP-05: peças que já existem). Regras de cor: âmbar só para perigo de chão
aceso, nunca verde Emeth nem o violeta de Morvath; nada redondo nas Runas (D-29).

---

## Ideias da referência Sworn (2026-11-19)

Pedido do PO pelo Game Director: estudar as capturas do Sworn que o Daniel juntou (pasta local
`OneDrive/Imagens/Sworn/`, 11 capturas de um vídeo e uma foto; o zip é cópia das mesmas) como referência de
**design de salas**. Só princípios: nada de arte, nome, personagem, layout exato ou identidade do Sworn. Tudo vira
Eterra (catacumbas sob a igreja de Valmor, o leão, tom de aventura); âmbar só para perigo de chão; nada do verde da
Emeth nem do violeta de Morvath num perigo; nada redondo nas Runas (D-29); Meshy zero. **Nada foi implementado.**

### 1. O que cada captura mostra (para a sala, não para a arte)

| Captura | O que se observa |
|---|---|
| 222408 | Tela de escolha de bênção com o patrono ao lado. Nada de sala; só confirma que a escolha pausa a luta. |
| 222420 | Fim de sala: a saída é um portão grande na parede de fundo, de frente para a câmera, com a recompensa flutuando na frente dele e o nome escrito. Um filete de água rasa corta o chão em diagonal sem bloquear; um pilar solto e pedestais com urna perto da porta. |
| 222430 | **Kit de armadilha** visível em repouso: lajes quadradas com moldura saliente e rachaduras (gatilho), blocos de pedra com caveiras na face e uma **seta gravada no topo** que diz para onde atiram. Poças rasas na borda. Os blocos ficam colados ao chão livre, mirando através dele. |
| 222445 | Terraço elevado com balaustrada separando dois níveis; num canto um objeto que "inicia as provas de combate" (desafio opcional dentro da sala). Grupos de potes quebráveis encostados no muro. |
| 222504 | Uma peça central (poço com mureta) **cercada por quatro lajes** em cruz: a melhor cobertura da sala tem preço. Blocos de tiro dos dois lados mirando para dentro. Muretas baixas dividem a sala em faixas; tocos de coluna na entrada. |
| 222527 | Passarela sobre água com mureta dos dois lados; blocos de tiro na mureta mirando **através** da passarela; pares de lajes no acesso dela. Atirador inimigo do outro lado. Aviso de golpe inimigo em aro vermelho no chão. |
| 222537 | Antecâmara pequena só com as duas saídas lado a lado na parede do fundo, cada uma com o símbolo da recompensa; lajes num canto. As portas ficam longe do miolo da luta. |
| 222549 | **Campo de pilares** baixos em grade (alguns quebrados, um com caveira em cima), grades de quatro painéis no chão (provável espeto ou respiro; nenhum disparo nas capturas), um arco partido. Cobertura espalhada, nenhuma grande. |
| 222603 | Objeto interativo opcional numa sala de luta ("espada na pedra") num degrau junto ao muro, ao lado de uma cascata; pilares e grades. |
| 222700 | Arena do chefe ao ar livre: **muitos aros vermelhos** de queda ao mesmo tempo (uns 12), na mesma cor dos avisos dos inimigos, mais a borda da tela vermelha da vida baixa. Ler o que é perigo da sala e o que é ataque fica difícil. |
| 222731 | Projétil em arco com **um rastro da origem até o aro** onde vai cair: o aviso diz onde e de onde. Pedestal com urna como cobertura, grades no chão. |
| pexels-4065021 | Escolha de bênção no mundo: três orbes sobre uma estátua e os patronos ao lado. Nada de sala. |

**O princípio que mais pesa**: o Sworn faz salas diferentes com um **kit pequeno de peças de perigo** (laje,
bloco que atira, grade) sempre visível em repouso e com a direção gravada nele, recombinado em plantas diferentes.
Cada sala tem uma combinação e uma peça central. O que nós temos hoje é o contrário: um perigo só (Runas), numa sala
só. A lição do 222700 é negativa: perigo de sala na cor do ataque inimigo e em quantidade confunde; nós mantemos o
âmbar só para a sala e no máximo 3 avisos de sala ao mesmo tempo.

### 2. Ideias traduzidas para Eterra

Custo: P até meio dia, M 1 a 2 dias, G 3 dias ou mais. Aceite pela régua do item 1 das Sugestões (48 sementes,
`--bot-reaction=0.25 --ultimate=cleave`) e pela métrica "joga diferente" (item 6). Toda regra de perigo das Sugestões
vale (aviso de 1,0 s ou mais, fere inimigos, `DefeatCause`, nunca a menos de 6 m da entrada nem nos 3 s do começo,
saída livre testada no molde do `test_boss_exits.gd`, queda fere e devolve). Nomes de peça e de perigo abaixo são
técnicos e provisórios; o nome para o jogador passa pelo Daniel.

#### Prioridade 1

**RP-16 (novo) Seteira ligada à laje: o primeiro perigo que o jogador arma contra os inimigos.**
- Da referência: 222430, 222504, 222527 (bloco com a direção gravada que atira através do chão livre).
- Eterra: uma seteira de túmulo (bloco de cantaria baixo, encostado na parede ou na mureta, com uma **divisa reta
  gravada no topo** apontando para onde atira, a mesma linguagem das divisas das Runas e do `DoorGlyph`). Liga a uma ou
  duas lajes do RP-06. Quem pisa na laje (herói ou inimigo) arma a seteira: a divisa acende em âmbar e uma faixa de
  1 m de largura aparece no chão da boca da seteira até a parede oposta, 1,0 s; depois uma rajada de virotes de pedra
  por 0,25 s ao longo da faixa. Herói com o número do RP-03 (7), inimigos 60; recarga 5 s por seteira. O jogador atrai
  o grupo para a faixa e pisa na laje do outro lado (o "usar a seu favor" do PO).
- Onde: Cripta B (duas seteiras no Ossuário, uma de cada lado do muro divisor, mirando o corredor norte-sul); Ponte A
  (uma em cada plataforma de ponta, mirando **através** da plataforma, nunca ao longo de uma ponte: na ponte não há
  para onde sair); Santuário (sob as janelas cegas das naves laterais, somando ao preço das laterais do RP-06).
- Dado: `ArenaObstacle` com `piece` `&"bolt_slit"` (o `yaw` dá a direção; corpo e tiro barrados, topo 1,2 m). O
  perigo é o `LINE` do RP-11 com gatilho: `HazardDef.kind` `PLATES` ganha `links: Array[int]` (laje i arma a linha
  `links[i]`) e `lines` vêm do RP-11. Com RP-06 e RP-11 prontos, é só dado (a ligação é a única lógica nova, pura,
  em `PlateHazard`, com GUT).
- Aceite: nas salas com seteira, dano dela nos inimigos 25 vezes ou mais o do herói; pelo menos 1 inimigo atingido por
  sala em metade das salas (o robô precisa pisar de propósito: regra simples no `Bot`, "pisa na laje se 2 ou mais
  inimigos estão na faixa e ele não"); Cripta B passa a diferir da A em zona dominante e maior fonte de dano.
- Dono: `gameplay-engineer` (ligação e robô), `room-designer` (lugares e números), `environment-artist` (seteira,
  divisa acesa, rajada), `combat-feel-director` (aviso). Custo: M depois do RP-06 e do RP-11.

**RP-17 (novo) Mureta baixa: o corpo dá a volta, o tiro passa por cima.**
- Da referência: 222504, 222445, 222527 (muretas e balaustradas que dividem a sala em faixas e níveis).
- Eterra: muretas de 0,9 m (a regra do tiro já existe: até 1,0 m passa por cima) dividindo a sala em faixas. Muda a
  pergunta para os atiradores: o mago atira por cima, o esqueleto tem de contornar, o herói escolhe de que lado ficar.
  Um desnível de verdade (terraço) não existe na simulação (o chão é um plano); a mureta faz o mesmo papel no jogo e o
  desenho pode ter um degrau de 0,3 m do outro lado sem mudar a colisão.
- Onde: **Jardim A** (duas muretas quebradas em arco a 6 m do tronco, deixando 3 aberturas de 3 m: a "sombra da árvore"
  vira um pátio fechado); **Cripta A** (uma mureta de 6 m ao sul do sarcófago, paralela a ele, separando a fileira sul
  da do meio). Não nas Fendas (já têm a fenda como divisor) nem nas Runas (atrapalha ler as lajes).
- Dado: só `ArenaObstacle` caixa com `blocks_move` true, `blocks_shots` false, `height` 0,9, `piece` `&"low_wall"` (o
  look desenha com `cut_wall`/`wall_part`, a conferir com o `environment-artist`). Nada de código.
- Aceite: tiros barrados nas salas tocadas **caem** (a mureta não é cobertura) e o primeiro contato sobe 1 s ou mais;
  zona do pátio do Jardim entre 30 e 60%; `test_arenas` (pontos dentro de peças, "cercado") verde; `NavGrid` e robô sem
  `stuck` em 8 sementes por vista.
- Dono: `room-designer`; `environment-artist` desenha a mureta. Custo: P.

**RP-18 (novo) Colunata: um campo de pilares baixos como variante tardia.**
- Da referência: 222549 (cobertura espalhada em grade, nenhuma grande, alguns pilares quebrados).
- Eterra: **Santuário C, "a nave das colunas caídas"**, ou Cripta C se o Daniel preferir a cripta (as duas têm a
  coluna redonda pronta, `round_column`, `column_base`, `drums`). Grade de 3 x 3 colunas de 0,7 m de raio, 4 m entre
  eixos, duas delas tocos (barram corpo, não tiro) e uma caída atravessada (caixa baixa). Nada de perigo novo: a sala
  é a cobertura que vira. É onde a coluna que tomba do RP-09 rende mais.
- Dado: só `ArenaVariant` nova com `obstacles` (pilares e tocos que já existem), `spawns` fora da grade e `areas`
  ("colunata", "beira"). Entra com a faixa do RP-07 (progresso 0,5 a 1,0).
- Aceite: tiros barrados 35% ou mais (a Cripta A, a mais coberta, tem 28%); primeiro contato 1,5 s acima da Santuário A;
  zona "colunata" 40 a 70%; robô sem `stuck` (a grade de 4 m dá corredores de 2,6 m, acima da folga de 0,55 do
  `NavGrid`); `fit_probe` sem fantasma.
- Dono: `room-designer`; `environment-artist` (variante da nave). Custo: P no dado, M na arte.

**RP-19 (novo) Saídas na parede de fundo, longe do miolo da luta.**
- Da referência: 222420 e 222537 (portões grandes de frente para a câmera, recompensa na frente de cada um, e as
  saídas juntas num fim de sala, fora da luta).
- Eterra: auditoria das `ArenaExit` das 12 vistas de luta. Regra proposta: toda saída numa parede que a câmera vê de
  frente (norte ou leste na nossa câmera de 35 graus), a pelo menos 8 m do `hero_spawn` e fora das zonas de
  nascimento; quando a sala tem duas ou três saídas, elas ficam do mesmo lado, a 5 m ou mais uma da outra (o jogador
  lê as placas juntas, como hoje na Ponte). Quem descumpre hoje é o que a auditoria vai dizer; não muda nenhuma peça
  de perigo.
- Dado: `exits` no `_stage`; uma asserção nova em `test_arenas.gd` (distância ao `hero_spawn`, às `spawns` e entre
  saídas).
- Aceite: teste verde nas 12 vistas; captura na GPU de cada sala mudada com as placas inteiras na tela a 720.
- Dono: `room-designer`; `ui-ux-designer` confere as placas. Custo: P.

#### Prioridade 2

**RP-20 (novo) Pedras que caem da abóbada rasgada (Santuário B).**
- Da referência: 222700 e 222731 (queda avisada por aro no chão; o rastro da origem ao aro diz de onde vem). Lição
  inversa do 222700: poucas por vez e numa cor que não é a dos inimigos.
- Eterra: a abóbada rasgada do Santuário B (Lote B, `VAULT_*`) solta pedras sobre a nave: no máximo 2 por vez, a cada 4
  s, só na metade da nave sob o rasgo; aviso de 1,2 s com a sombra quadrada da pedra crescendo no chão em âmbar e poeira
  caindo do teto no mesmo ponto (o "de onde vem" do rastro, sem linha nova); golpe de 0,25 s em 2 x 2 m, 7 no herói e
  60 nos inimigos; a pedra fica 3 s como entulho baixo e se desfaz. Nunca a menos de 6 m da entrada nem sobre o
  `boss_spawn` nos 3 s em que o guardião surge. Dá ao buraco da B o que falta (2.4.7: a B joga igual à A).
- Dado: `HazardDef.kind` `DROPS` com `zones: Array[Rect2]`, `size`, `count`, `every`; o resto (`warn`, `fire`,
  danos, `start_delay`, `quiet`) já existe. Comportamento novo uma vez (lógica pura `DropHazard`, GUT); depois, pedra
  que cai em qualquer sala com teto rasgado é dado (Cripta tardia, Fendas B).
- Aceite: Santuário B com nave abaixo de 55% (A 68%); dano das pedras no herói 0,5 a 2 por sala, inimigos 25 vezes isso;
  nunca 3 avisos de sala ao mesmo tempo (GUT); teste de saída verde.
- Dono: `gameplay-engineer`, `room-designer`, `environment-artist` (sombra, poeira, entulho). Custo: M.

**RP-21 (novo) A melhor cobertura tem preço: lajes em volta da peça central.**
- Da referência: 222504 (poço cercado por quatro lajes).
- Eterra: regra de colocação do RP-06, não perigo novo. A peça que mais barra tiro em cada sala ganha lajes nas pontas
  curtas, nunca nos corredores de 4 m (que seguem livres): o sarcófago do meio da Cripta A (lajes nas duas cabeceiras),
  o tronco do Jardim (uma laje no lado norte, a sombra contra os atiradores do sul) e o patamar da Ponte B (uma laje no
  meio do patamar: o abrigo do RP-11 deixa de ser de graça). Ficar coberto continua possível, mas não parado.
- Dado: só retângulos em `plates` depois do RP-06.
- Aceite: tiros barrados nas salas tocadas caem no máximo 5 pontos (a cobertura continua valendo); dano das lajes 0,5 a
  1,5 por sala; a zona da cobertura cai 10 pontos ou mais.
- Dono: `room-designer`. Custo: P depois do RP-06.

**RP-22 (novo) Filete de água de infiltração: o chão que muda o passo.**
- Da referência: 222420, 222430 (água rasa cortando o chão sem bloquear).
- Eterra: água que escorre das cascatas do Jardim (Lote C já pôs cascatas e o lago da B fora do chão) por um canal raso
  de 2 m de largura atravessando o chão de lado a lado. Dentro dele todo mundo anda a 75% (herói e inimigos; a esquiva
  e a investida não perdem nada). Sem dano, sem aviso (é chão, sempre visível; a regra do aviso é para o que fere).
  Separa a sala em duas margens sem cortar o caminho: os esqueletos que atravessam ficam lentos na frente do herói.
  Também nas Fendas, no fundo do vão sob a ponte caída da B, se a sala pedir.
- Dado: `RoomLayout.slow_zones: Array[Rect2]` e `slow_scale` (também na `ArenaVariant`); comportamento novo pequeno
  (`Horde.speed_scale` e `Player` por posição, `Arena.slow_at`), lógica pura testada.
- Aceite: Jardim com zona "margem leste" e "margem oeste" e nenhuma acima de 70%; dano por sala do Jardim sobe para 1
  a 2 nas salas 4 a 6 (os corredores lentos na frente dele); robô sem `stuck`.
- Dono: `gameplay-engineer` (o lento), `room-designer`, `environment-artist` (o filete; a água escura do Lote C,
  `dark_water.gdshader`, já existe). Custo: M.

**RP-23 (novo) Grade de respiro: a laje de proximidade em outra pele.**
- Da referência: 222549, 222603, 222731 (grades no chão, sempre visíveis).
- Eterra: grade de ferro sobre um respiro do ossário (Cripta e Santuário). Quem fica a menos de 1 m dela (herói ou
  inimigo) arma; 1,0 s de aviso (a grade acende em âmbar pelas frestas e sobe pó de osso); depois poeira quente por 1,5
  s, 1 a cada 0,25 s, como o vapor do Hades (`SteamTrap`: alvo herói e inimigos, recarga 6 s). Difere da laje por ferir
  por tempo, não de uma vez: ensina a sair, não a esquivar.
- Dado: o `PlateHazard` do RP-06 com `ticks` e `tick_every` (zero no RP-06), mais a peça `&"vent_grate"` (só desenho,
  não barra nada). Nada novo além dos dois números se o RP-06 já nascer com eles; recomendo que nasça.
- Aceite: dano médio por disparo no herói abaixo de 3 (ele sai antes do fim); inimigos 20 vezes isso.
- Dono: `room-designer`, `gameplay-engineer` (dois campos), `environment-artist` (grade). Custo: P depois do RP-06.

#### Prioridade 3 (depois da sessão do Daniel)

**RP-24 (novo) Urnas quebráveis em grupos (ouro) e a urna de óleo (RP-12) lidas como coisas diferentes.**
- Da referência: 222430, 222445, 222537 (grupos de potes ao pé dos muros; recompensa por varrer os cantos).
- Eterra: urnas de cerâmica comum em grupos de 3 a 5 ao pé das paredes, que quebram num golpe e soltam um pouco de ouro
  (o Hades II também tem). As de óleo do RP-12 ficam isoladas, em bronze escurecido e com o pavio à mostra: nunca no
  mesmo grupo nem na mesma cor. Muda pouco a luta, muda muito a identidade de cada canto.
- Dado: `ArenaObstacle.breakable` e `drop_gold`; comportamento novo uma vez (peça que some, `NavGrid` refeito encolhendo).
  Ouro é economia: os números são do `gameplay-engineer` e não podem mexer no ouro da descida mais que 5%.
- Dono: `gameplay-engineer`, `environment-artist`. Custo: M.

**RP-25 (novo) Desafio opcional dentro da sala de luta.**
- Da referência: 222445 e 222603 (um objeto na sala que começa uma prova ou dá algo, à escolha do jogador).
- Eterra: depois da luta, às vezes um relicário fechado num canto; tocá-lo chama uma onda curta a mais (com uma elite)
  e, vencida, dá uma recompensa a mais. Sobrepõe a Provação (que já é "risco por Bênção"): só vale se for diferente
  dela (sem maldição, risco só da onda). Precisa de decisão do Daniel antes de qualquer dado; nome e o que é o
  relicário são cânone.
- Dono: Game Director decide; `gameplay-engineer`. Custo: M.

### 3. O que mais deixaria as salas diferentes umas das outras

O Sworn não faz cada sala com um sistema; faz cada sala com **uma combinação** de poucas peças. Com RP-06, RP-11 e
RP-16 a RP-23 prontos, nós temos o kit (laje, seteira, grade, mureta, pedra que cai, filete de água, coluna que tomba)
e cada arena ganha uma assinatura própria, sem repetir a peça central:

| Arena | Peça central (o que a sala pergunta) | Kit dela | Nunca nela |
|---|---|---|---|
| Cripta A | o sarcófago coberto, mas com lajes nas cabeceiras (RP-21) | lajes nos cantos (RP-06), mureta sul (RP-17), grade (RP-23) | seteira |
| Cripta B | o muro divisor varrido pelas seteiras (RP-16) | lajes no pé do muro, grade | mureta |
| Fendas A / B | a ponte; a fenda que respira empurra (RP-08) | tocos (RP-05); na B pedra que cai sob a ponte caída (RP-20) | lajes (a beira já pede atenção) |
| Jardim A / B | o pátio fechado da árvore (RP-17) e a raiz que golpeia (RP-10) | filete de água (RP-22), laje ao norte do tronco | seteira |
| Santuário A | nave ou laterais; laterais com lajes e seteiras (RP-06, RP-16) | coluna que tomba (RP-09) | pedra que cai |
| Santuário B | o rasgo da abóbada que solta pedras (RP-20) | grade, coluna que tomba | seteira |
| Santuário C (nova) | a colunata (RP-18) | coluna que tomba (RP-09) | perigo de chão |
| Ponte A / B | atravessar sob fogo (RP-04); a corrente que varre (RP-11) | seteira nas plataformas da A (RP-16), laje no patamar da B (RP-21) | grade, água |
| Runas A / B | o chão inteiro é o perigo | raio entre pilares na A tardia (RP-11), cristal da B (RP-14) | qualquer outra peça (leitura das lajes) |

Medida: com a tabela acima, nas salas 2 a 6, cada par de vistas tem de diferir em pelo menos duas das cinco medidas do
item 6 das Sugestões (hoje Cripta, Fendas e Jardim diferem só nos tiros barrados).

### 4. Ordem recomendada (junto das Sugestões)

1. RP-01, RP-02, RP-03 (já recomendados) e **RP-17, RP-19** (só dado, P): mureta e saídas.
2. RP-06 nascendo com `ticks` (para o RP-23) e `links` (para o RP-16); logo depois **RP-21** e **RP-23** (só dado).
3. RP-11 e **RP-16** (a seteira é o LINE com gatilho).
4. **RP-18** (variante, só dado) com o RP-07 (faixas) e o RP-09 (coluna que tomba).
5. **RP-20** e **RP-22** (um comportamento novo cada).
6. RP-24 e RP-25 depois do Daniel.

### 5. Riscos

- Kit demais numa sala só vira o 222700: no máximo **um** perigo que fere por sala de luta (a mureta, a água e a coluna
  que tomba não contam) e no máximo 3 avisos de sala ao mesmo tempo.
- A seteira (RP-16) e a laje no patamar (RP-21) na Ponte podem prender o herói entre uma faixa e o abismo: teste de
  saída obrigatório com as pontes, e nunca faixa ao longo de uma ponte.
- O robô não usa o chão a favor (2.4.5): RP-16 e RP-21 pedem uma regra nova no `Bot`, senão o aceite vira a sessão do
  Daniel.
- A lentidão da água (RP-22) no herói pode irritar: medir com gente; se irritar, só os inimigos ficam lentos.

### 6. O que precisa de arte (`environment-artist` com a spec do `art-director`)

Seteira com a divisa reta gravada no topo e a rajada (RP-16); mureta baixa quebrada nos looks da Cripta e do Jardim
(RP-17); variante da nave com a colunata (RP-18); sombra quadrada, poeira do teto e entulho da pedra que cai (RP-20);
filete de água no chão do Jardim (RP-22, da família do `dark_water`); grade de ferro com âmbar nas frestas e pó de osso
(RP-23); urnas de cerâmica comum em grupo, distintas da urna de óleo (RP-24). Placeholder enquanto isso: o estilo
`GroundLook.Style.HAZARD` para todo aviso e as peças que já existem (`block`, `cut_wall`, `column_base`, `Masonry.urn`).

---

## Revisão de layout 2026-11-19 (build d2ff05d)

Pedido do Game Director depois do teste do Daniel do build `d2ff05d` ("ainda precisa de muitas melhorias"): olhar as
salas da descida e o hub como level designer, com a câmera Longe (54 m) e a Perto (37 m). **Nada implementado**; nenhum
dado, código ou teste do repositório mudou.

### 1. Como medi

- Cópia isolada do `d2ff05d` em `/home/dani/tools/rd_layout` (fora do repositório). Nela, só para medir, uma amostra a
  cada 0,25 s da posição do herói e de cada inimigo vivo por sala (`--heat`, linha `HEAT`; não vai para o jogo).
- `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 24, duas vezes: Longe (padrão) e
  `--cam=near`. 48 descidas, 0 `stuck`, 0 `bot.stuck`, 20 de 24 vitórias nas duas, Morvath aos 228 s (Longe) e 221 s
  (Perto). Saídas e scripts: `/home/dani/tools/rd_layout_runs/` (`an.py` por sala, `heat.py` distâncias e fora da
  tela, `thirds.py` terços da sala).
- Enquadramento calculado pela fórmula do jogo (`CamFrame.screen_of`, 16:9, giro 35, inclinação 30, campo 24) sobre o
  chão de cada `RoomLayout` numa grade de 0,5 m: `tools/rd/frame_cover.gd` na cópia.
- Capturas na GPU (Forward+, 1672 x 941, semente 5, 9 s, robô), só no scratchpad:
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/layout/`
  (`crypt_near`, `bridge_far`, `bridge_near`, `sanctuary_far`, `sanctuary_near`, `garden_far`, `hub_far`, `hub_near`).
- Ressalva de sempre: é o robô. Ele não procura cobertura nem ilha segura; o que for "lugar não usado" pode ser só ele.
  Onde a leitura depende disso, digo.

### 2. O que as medidas mostram

**2.1 Quanto da tela cada sala ocupa** (câmera no ponto de repouso da sala; "tela" = largura x altura do chão projetado
em telas; "cheia" = parte da tela que é chão andável)

| Sala | Chão | Longe: tamanho na tela | Longe: chão visto / tela cheia | Perto: tamanho na tela | Perto: chão visto / tela cheia |
|---|---|---|---|---|---|
| Cripta A e B | 520 m² | 0,72 x 0,68 | 100% / 26% | 1,05 x 1,03 | 98% / 55% |
| Runas A e B | 726 | 0,85 x 0,76 | 100% / 39% | 1,25 x 1,18 | 87% / 72% |
| Jardim A e B | 941 | 0,98 x 0,84 | 100% / 52% | 1,45 x 1,33 | 77% / 81% |
| Salão | 929 | 1,03 x 1,02 | 97% / 55% | 1,51 x 1,73 | 75% / 81% |
| Fendas A / B | 1076 / 1038 | 1,16 x 1,02 | 91% / 56% | 1,71 x 1,70 | 61% / 70% |
| Santuário A / B | 1225 / 1170 | 1,17 x 1,23 | 90% / 62% | 1,77 x 2,24 | 65% / 84% |
| Ponte A / B | 814 / 742 | 1,37 x 1,11 | 78% / 32% e 28% | 2,19 x 1,94 | 54% / 42% e 30% |
| Provação / Altar | 233 / 268 | 0,47 x 0,42 / 0,56 x 0,49 | 100% / 12% e 14% | 0,69 x 0,62 / 0,81 x 0,74 | 100% / 26% e 31% |
| Câmara do Selo | 490 | 0,61 x 0,55 | 100% / 27% | 0,92 x 0,84 | 100% / 60% |
| Hub | 1601 | 1,48 x 0,80 | 81% / 78% | 2,39 x 1,30 | 49% / 86% |

Leitura: **com a Longe, nenhuma sala de luta é maior que a tela**; Cripta, Runas e Jardim cabem inteiras com folga e a
Cripta é um quarto da tela, o resto parede e escuro. As salas do Érebo do Hades II são maiores que a tela (a Perto é o
ZoomFraction 0,85 delas). **Com a Perto as salas viram o que o desenho pediu**: Cripta do tamanho da tela, Jardim, Salão e
Runas 1,2 a 1,5 telas, Fendas e Santuário 1,7 a 2,2, a Ponte comprida. As câmaras sem luta (Provação, Altar, Selo) são
pequenas nas duas, o que serve a elas (escolha, não luta), mas com a Longe Provação e Altar são uma ilha de 12 a 14% da tela.

**2.2 A câmera Perto muda o jogo, não só a vista.** O atirador só prepara dentro de 5 a 95% da tela da câmera em uso
(`Horde._can_fire`). Com a Perto, nas salas grandes, um terço do tempo deles fica fora dessa faixa:

| Sala | Atirador fora de 5-95% (Longe / Perto) | Tiros por sala (Longe / Perto) | Dano por sala (Longe / Perto) |
|---|---|---|---|
| Jardim A / B | 10 a 11% / 34 a 37% | 9,3 / 5,2 e 11,8 / 12,0 | 1,40 / 0,27 e 1,57 / 1,00 |
| Fendas A / B | 15 e 9% / 31 e 23% | 5,4 / 3,6 e 8,8 / 5,2 | 1,17 / 0,35 e 1,62 / 0,69 |
| Santuário A / B (luta comum) | 17 e 19% / 39 e 37% | 6,4 / 3,9 e 8,9 / 7,9 | 4,39 / 5,83 e 7,10 / 6,10 |
| Ponte A / B | 18 e 17% / 32% | 6,9 / 3,8 e 7,1 / 5,7 | 2,36 / 1,45 e 1,33 / 0,53 |
| Cripta A / B | 2 e 0% / 20 e 11% | 2,6 / 2,1 e 3,5 / 3,0 | 0,62 / 0,62 e 0,64 / 0,64 |

(Fora da tela medido com a câmera no herói, sem a margem da sala: na Longe é o pior caso, nas salas de quadro fixo é
menos.) Na descida inteira o dano por sala de luta cai de 2,48 (Longe) para 1,90 (Perto), 23% a menos, e a vida ao chegar
em Morvath sobe de 52,7 para 56,1. **A opção de câmera é hoje uma opção de dificuldade escondida**, e quanto maior a sala,
mais fácil com a Perto: o papel do atirador some justo nas salas feitas para ele (Fendas, Jardim, Ponte).

**2.3 Onde a luta acontece** (% do tempo do herói em cada terço da sala, oeste/meio/leste e norte/meio/sul; inimigos em
oeste/meio/leste; 48 descidas)

| Sala | Herói O / M / L | Herói N / M / S | Inimigos O / M / L | Zona dominante (RP-01) |
|---|---|---|---|---|
| Cripta A | 28 / 37 / 35 | 32 / 37 / 31 | 15 / 27 / 58 | middle 34, north 34, south 31 |
| Cripta B | 16 / 46 / 38 | 16 / 44 / 40 | 11 / 28 / 61 | **south_open 79 a 82** |
| Fendas A | 18 / 56 / 26 | 14 / 40 / 47 | 8 / 45 / 47 | east 49 a 57; **bridge_n 1 a 2** |
| Fendas B | 15 / 42 / 42 | 8 / 40 / 53 | 6 / 41 / 53 | east 60 a 65 |
| Jardim A | 25 / 54 / 21 | 13 / 34 / 53 | 12 / 56 / 32 | rest e east_field; **tree_shade 3 a 5** |
| Jardim B | 19 / 55 / 26 | 23 / 29 / 48 | 5 / 54 / 41 | **tree_shade 4 a 7** |
| Santuário A (comum) | 46 / 40 / **14** | 34 / 59 / **8** | 66 / 33 / **1** | nave 71 a 73 |
| Santuário B (comum) | 34 / 46 / 21 | 46 / 48 / **6** | 48 / 47 / **5** | nave 67 a 72 |
| Santuário com guardião | 25 a 56 / 33 a 58 / 11 a 17 | 3 a 12 / 74 a 76 / 14 a 22 | 54 a 83 / 16 a 44 / 0 a 2 | |
| Ponte A | 16 / 54 / 31 | | 4 / 23 / 73 | middle 40 a 54, east 12 a 27 |
| Ponte B | 16 / 35 / 49 | | 6 / 16 / 78 | east 41 a 43, bridge 25 a 28 |
| Runas A | 26 / 47 / 27 | 27 / 42 / 31 | 11 / 54 / 35 | equilibrada |
| Runas B | 18 / 52 / 30 | | 10 / 63 / 27 | middle 56 a 63, quiet 9 a 14 |

**2.4 Outros números de forma**

- Distância ao inimigo mais perto: mediana 5,4 a 6,2 m em **toda** sala (5 m com o guardião). A sala não muda a
  distância da luta; muda só por onde se anda até ela.
- Inimigos a mais de 12 m do herói: Cripta B 21%, Cripta A e Runas B 27%, Jardim 50 a 51%, Fendas 42 a 48%, Santuário 42 a
  43%, Ponte 41 a 43%. Nas salas grandes metade da sala de pé está longe: é a fatia que a Perto apaga dos atiradores.
- Primeiro contato (mediana): Cripta 3,2 a 3,7 s, Runas 2,6 a 3,5, Jardim 3,3 a 3,5, Fendas 4,0, Santuário 5,0, Ponte
  5,3 a 6,6 s.
- Amontoado (pares de inimigos a menos de 1,5 m, por amostra): Ponte 0,85 a 0,94, o dobro das outras (Cripta 0,38 a 0,46,
  Jardim 0,29 a 0,40, Salão 0,14). Na captura `bridge_far` o grupo inteiro empilha na cabeceira da ponte 2, de 5 m. Nas
  outras salas não há aperto: média de 3 a 4,5 de pé, 0,24 a 0,48 a menos de 4 m do herói.
- O que barra tiro (`blocked_by`, 24 descidas Longe): no Jardim o **tronco** barrou 1 tiro em 15 salas A e 3 em 14 B (as
  sarcófagos 8 e 6); no Santuário as colunas 31 e 39; nas Runas A os pilares 29, na B 1; na Cripta os sarcófagos.
- Runas: por sala de Runas, 5,2 a 5,9 disparos, 2,3 a 2,7 abates na A e 1,6 a 1,8 na B, 105 a 242 de dano nos inimigos;
  no herói 1,27 (Longe) e 0,32 (Perto) por sala, a mesma faixa ruidosa do RP-03.

**2.5 Hub (`HubPlan`, 50 x 33 m)**

| De / para | Portal | Vendedor | Árvore | Forjador | Livro |
|---|---|---|---|---|---|
| Chegada | 29,8 m, 4,4 s | 29,3, 4,3 | 31,7, 4,7 | 18,9, 2,8 | 24,4, 3,6 |
| Portal | | 21,3, 3,2 | 19,7, 2,9 | 28,9, 4,3 | 28,9, 4,3 |
| Vendedor | | | 39,0, 5,8 | 15,0, 2,2 | **42,9, 6,4** |
| Árvore | | | | 41,1, 6,1 | 14,6, 2,2 |
| Forjador | | | | | 39,6, 5,9 |

(Linha reta, andando a 6,75 m/s; correndo 11,1 m/s é 60% disso.) A spec do hub (`hub_spec_art.md` 2.5) pedia nenhuma
caminhada acima de 3 s; com o chão dobrado, 6 dos 10 pares passam disso. O circuito de toda volta (chegada, Árvore ou
Livro, Portal) é 51 a 54 m, 7,6 a 8 s andando. As cinco estações estão coladas nas paredes (u entre 18,6 e 22,8 de 25);
entre elas e a fonte (raio 2,3) fica uma praça de uns 30 x 30 m com dois bancos e quatro urnas (`hub_far`: o quadro é chão
liso com a fonte no meio). Com a Longe o hub inteiro cabe quase numa tela (81% do chão visto de onde a câmera repousa):
não há o que descobrir andando. O Vendedor e o Forjador ainda são "A definir": metade oeste do hub (cerca de 800 m²) hoje
não tem uso.

### 3. Problemas e propostas

Custo: P até meio dia, M 1 a 2 dias. Aceite sempre com a régua do item 1 (24 sementes por câmera no mínimo, 0 `stuck`,
`test_arenas.gd`, `fit_probe` sem piorar) e vitórias dentro de 2 das de hoje (20 de 24).

#### P0

**LR-01 Decidir a câmera padrão e dimensionar as salas para ela.**
- Evidência: 2.1. Com a Longe toda sala de luta cabe numa tela (Cripta em 26% dela, Runas 39%, Ponte 28 a 32%); a
  sensação de "maquete" e de sala pequena vem daí, não do desenho. Com a Perto os tamanhos ficam no padrão do Hades
  (1 a 2,2 telas) sem mudar nenhuma planta.
- Proposta: **Perto como padrão** (decisão do Daniel pelo Game Director; a Longe fica na opção). Com a Perto, nenhuma sala
  de luta precisa crescer; só a Cripta fica no limite (1,05 tela) e pode ganhar 2 a 3 m se o teste pedir. Se a Longe
  continuar padrão, o contrário: Cripta e Runas precisam crescer cerca de 40% na largura (Cripta 24 para 34 m, Runas 30
  para 40) e as outras 20 a 30%, o que mexe em todo look e em todo `HazardDef`: caro (G) e eu não recomendo.
- Junto: Provação e Altar ficam como estão (sala de escolha); com a Longe valeria só aproximar a câmera nelas
  (`cam_target` com distância própria, gameplay-engineer).
- Dono: Game Director decide; `gameplay-engineer` (padrão do save), `ui-ux-designer` (opção). Custo: P.
- **Feito (gameplay-engineer, 2026-11-19): Perto como padrão.** `SaveData` versão 7, padrão `"near"`; save de antes no
  padrão antigo `"far"` passa a `"near"` uma vez, a menos que o jogador tenha escolhido (`camera_chosen`, marcado por
  `Save.set_option("camera", ...)`; saves da versão 6 não tinham a marca, então quem escolheu Longe no dia de hoje volta
  para Perto uma vez). No hub, com a Perto, nenhuma estação aparece nomeada da chegada (`test_ui_review` fixa a Longe
  nesse caso): é do LR-11.

**LR-02 A Perto não pode calar os atiradores.**
- Evidência: 2.2. A faixa de 5 a 95% da tela da câmera em uso tira um terço do tempo de tiro nas salas grandes; dano por
  sala 23% menor na Perto, e o papel do atirador some nas salas feitas para ele. Precisa vir junto do LR-01 (com a Perto
  padrão, o jogo inteiro fica mais fácil e o `balance-designer` mede a coisa errada).
- Proposta: a regra de justiça lê sempre o quadro da Longe centrado onde a câmera em uso olha (o atirador fora da tela
  da Perto mas dentro da da Longe prepara, e o aviso dele precisa então de uma divisa na borda da tela, como a de elite e
  chefe, `ui-ux-designer`). Alternativa só de sala: nas salas grandes, atiradores nascem e ficam a até 12 m do meio da
  luta (`keep_away` por sala); pior, porque muda o comportamento do inimigo por sala.
- Aceite: tiros por sala e dano por sala na Perto dentro de 10% da Longe nas 12 vistas; `hurt_ctx.offscreen` sem subir.
- Dono: `gameplay-engineer` (`Horde._can_fire`), `ui-ux-designer` (divisa). Custo: P a M.
- **Feito (gameplay-engineer, 2026-11-19, junto com o LR-01).** A regra lê o quadro que a câmera Longe teria (54 m, posta
  pelas regras dela, sem a folga da Perto: `Game._screen_of(..., as_far)`, `CamRig.look_at(..., as_far)`), não o quadro da
  Longe centrado na Perto: assim a câmera não muda nada da simulação. `RESULT` de `--cam=far` igual ao de antes do LR-02
  (semente 5) e, nas 24 sementes da régua (`--bot-reaction=0.25 --ultimate=cleave`), `--cam=near` e `--cam=far` dão o
  mesmo `RESULT` nas 24 (fora fps e tempo de passo). Tiros e dano por sala na Perto (antes / depois, depois = Longe):
  Jardim A 5,2 / 8,4 tiros e 0,27 / 1,35 de dano, Jardim B 12,0 / 11,7 e 1,00 / 2,85, Ponte A 3,8 / 5,8 e 1,45 / 1,33,
  Ponte B 5,7 / 9,1 e 0,53 / 0,77 (as colunas "depois" são de hoje, com a Laje Rachada e a Fatia 1; compare com a Longe
  de hoje, igual). 0 `stuck`, 0 `bot.stuck`. A tela em uso fica para o registro (`Horde.seen`, `screen_flag`) e para a
  divisa: `Horde.off_screen_windups()` (atiradores e sacerdote ancião preparando fora da tela em uso).

#### P1

**LR-03 Santuário: um terço da sala é corredor.**
- Evidência: 2.3. Na luta comum o herói fica 14% (A) e 21% (B) no terço leste e os inimigos 1 a 5%; o sul (a nave lateral
  sul) tem 6 a 8% do herói. O herói entra em (19,5; 2) e anda 5 s até a luta, que é a oeste (nascimentos em x -20 a -2).
  A pergunta da sala (nave aberta ou naves laterais) só existe na metade oeste. `sanctuary_far`: a luta no meio da nave,
  a metade de baixo do quadro vazia.
- Proposta (só dado): na luta comum, a primeira onda nasce também na nave lateral sul e no meio leste
  (`_rect(4, 12, 8, 12)`, `_rect(-2, 6, -12, -8.5)`), a segunda continua fechando por trás (`late_spawns` de hoje); o
  guardião não muda (ele nasce no `boss_spawn`). Assim a luta abre nas duas naves e o lado leste deixa de ser só caminho.
- Aceite: terço leste 25% ou mais do herói e 15% ou mais dos inimigos; nave entre 50 e 65%; primeiro contato abaixo de
  4 s; dano por sala dentro de 20%.
- Dono: `room-designer`. Custo: P.

**LR-04 Jardim: a árvore está fora da luta.**
- Evidência: `tree_shade` 3 a 7% do tempo, o tronco barrou 4 tiros em 29 salas. O tronco fica no canto noroeste (-8; -5);
  o herói entra no sudoeste e a luta vai para o meio e o sul (meio 54 a 55%, sul 48 a 53%). Pode ser em parte o robô (não
  busca cobertura), mas nem os atiradores ficam do outro lado dela.
- Proposta (só dado): os atiradores da primeira onda nascem ao norte do tronco (trocar `_rect(-6, 0, -13.2, -10.5)` por
  `_rect(-12, -5, -13.5, -10.5)`) e a do leste continua: entre a entrada e o grupo do norte fica o tronco, e quem cruza o
  campo leste fica exposto aos dois. Mexer no tronco (mudá-lo para o meio) seria M a G de arte; só se isso não bastar.
- Aceite: `tree_shade` 15% ou mais; tiros barrados pelo tronco 1 ou mais por sala; nenhuma zona acima de 60%.
- Dono: `room-designer`. Custo: P.

**LR-05 Fendas A e B jogam igual; a ponte norte não é usada.**
- Evidência: `bridge_n` 1 a 2% na A; A e B com o leste em 57 e 60% e o mesmo dano. O herói entra no sudoeste (-18; 6,5),
  ao lado da ponte sul e da volta sul: a ponte norte (a diferença da A) fica longe de tudo. A RP-05 deu cobertura, não
  rota.
- Proposta: entrada da A no noroeste, (-18; -9) (a da B fica): na A a ponte mais perto é a do norte e a pergunta "ponte
  norte ou volta sul" aparece; na B, sem ela, a mesma entrada obriga a descer até a ponte sul, outra sala. Pede o
  `environment-artist` (a abertura de entrada é desenhada pelo look, não pelo `hero_spawn`) e a regra de nada perto da
  entrada vale para as zonas de nascimento (o `late_spawns` da B em (-19,5..-15,5; -12..-7) sai de perto).
- Aceite: `bridge_n` 15% ou mais na A; A e B diferem em zona dominante e em primeiro contato (métrica "joga diferente",
  Sugestões 6).
- Dono: `room-designer` (dado), `environment-artist` (entrada). Custo: P a M.

**LR-06 Cripta B: o muro divisor não divide.**
- Evidência: `south_open` 79 a 82% (o aceite do RP-01 era até 75%); oeste do muro 2 a 8%. O muro tem 7 m vindo do norte
  e a luta acontece toda abaixo da ponta dele.
- Proposta (só dado): o muro desce até z 1,5 (de 7 para 12 m, caixa de 0,8 x 12 com centro em z -4,5), deixando 9 m de
  passagem ao sul; a primeira onda nasce a leste dele (já é) e um atirador a oeste (`_rect(-10, -7.5, -10, -8)` já
  existe: mantê-lo na B). A pergunta "de que lado do muro" vira real.
- Aceite: `south_open` abaixo de 60%; `west_of_wall` 15% ou mais; `test_arenas` (cercado) verde, NavGrid sem ilha.
- Dono: `room-designer`; `environment-artist` estende o ossuário (peça que existe). Custo: P.

**LR-07 Hub: caminhadas longas e praça vazia.**
- Evidência: 2.5. Pares a 5,8 a 6,4 s; circuito de toda volta 8 s; estações nas paredes, praça de 30 x 30 m vazia; metade
  oeste sem uso enquanto Vendedor e Forjador são "A definir".
- Proposta (só `HubPlan`, o chão de 50 x 33 que o PO pediu fica): as duas estações de toda volta, Árvore e Livro, vêm para
  perto do eixo chegada-portal, a 10 a 12 m dele, (13; 7) e (12; -5), e Vendedor e Forjador para (-13; 7) e (-12; -5); o
  resto do chão fica de cenário e passeio (ruínas, canteiros, a cascata). Distâncias propostas: chegada-Livro cerca de 18
  m (2,7 s), Livro-Árvore 12 m, Árvore-Portal 15 m (2,2 s); o maior par cerca de 27 m (4 s). A praça entre elas ganha
  as peças que hoje estão nas bordas (bancos, urnas) como divisores baixos. Com a Perto, mais de metade do hub fica fora
  da tela e o andar volta a descobrir.
- Aceite: nenhum par acima de 4 s; circuito de toda volta até 5 s; `test_hub.gd` e `test_camera_near.gd` verdes; o
  `HubLook` redesenhado em volta (environment-artist, art-director).
- Dono: `room-designer` (plano), `environment-artist` (`HubLook`), `ui-ux-designer` (placa). Custo: M.
- Nota: a frente HUB-D, em curso na árvore de trabalho (não no `d2ff05d`), já move as urnas, põe ciprestes em canteiros
  na praça e leva a forja para o canto sudoeste, sem mudar os pontos de uso (`HubPlan.USE`); ela trata a praça vazia,
  não as distâncias. LR-07 vem depois dela e precisa ser casado com ela pelo Game Director.

#### P2

**LR-08 Ponte: o grupo empilha na ponte 2.** Pares a menos de 1,5 m o dobro das outras salas; o grupo inteiro sobe na
ponte de 5 m (`bridge_far`). É a ideia da sala (atravessar sob fogo), mas o amontoado vira uma fila que o herói varre da
cabeceira. Proposta: ponte 2 com 6,5 m (de -3,25 a 3,25) e o bloco do RP-04 1 m mais para o sul; medir pares e a zona
`bridge2`. Pede o `environment-artist` (tabuleiro). Custo: P a M.

**LR-09 Contato demorado na Ponte e no Santuário.** 5,3 a 6,6 s até o primeiro golpe (Cripta 3,2). O LR-03 resolve o
Santuário; na Ponte a demora é a travessia, parte da ideia. Medir de novo depois do LR-03 e do LR-08 antes de mexer.

**LR-10 Runas B: a pedra quieta continua 9 a 14%.** A mesma leitura do RP-01 (o robô não procura ilha). Não mexer antes
da sessão do Daniel; com gente, se ela não for procurada, o RP-14 (cristal) dá o motivo.

**LR-11 A distância da luta é a mesma em toda sala** (5,4 a 6,2 m até o mais perto). O espaço muda o caminho, não a luta.
É o que os perigos da lista de Sugestões (RP-06, RP-11, RP-16) e a mureta (RP-17) atacam; a ordem recomendada lá não muda.

### 4. A câmera Perto e o que as salas pedem (resumo)

- Com a **Longe**, as salas de luta mostram tudo de uma vez: nenhum canto escondido, nenhum atirador fora do quadro, as
  pequenas (Cripta, Runas) e a Ponte com muito vazio em volta. As salas não estão grandes demais nem pequenas demais para
  o jogo; estão pequenas para a tela.
- Com a **Perto**, as salas ficam do tamanho das do Hades (1 a 2,2 telas) sem mudar nenhuma planta; Cripta no limite.
  Nada fica pequeno demais. O que quebra é a regra do atirador (LR-02), que faz das salas grandes as mais fáceis.
- Recomendação: Perto como padrão **junto** com o LR-02; depois disso refazer a régua (24 a 48 sementes) antes de mexer em
  tamanho de sala. As propostas LR-03 a LR-06 valem para as duas câmeras (são de rota e de onde se nasce).

### 5. Riscos

- LR-01 e LR-02 mudam a dificuldade de toda a descida: medir com o `balance-designer` antes do exe.
- LR-03 e LR-04 põem atiradores mais perto da entrada: conferir a regra "nada nos 3 s do começo nem a menos de 6 m da
  entrada" para nascimento (hoje vale para perigo, não para inimigo) e o primeiro contato.
- LR-05 e LR-07 mexem em cenário já aprovado (entrada das Fendas, hub): passam pelo `art-director`.
- Tudo medido com o robô; "lugar não usado" (tronco, pedra quieta, muro) pode ser o robô. A sessão do Daniel decide os
  itens marcados.

### 6. O que precisa de arte

Entrada das Fendas A no noroeste (LR-05); ossuário mais longo na Cripta B (LR-06); hub com as estações mais perto do
eixo e a praça com peças no meio (LR-07, `HubLook`); ponte 2 mais larga (LR-08). Nenhuma peça nova; nenhum perigo novo.
