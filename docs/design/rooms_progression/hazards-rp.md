> Índice: [rooms_progression.md](../rooms_progression.md)

## Feito em 2026-11-20 (gameplay-engineer): RP-16 e RP-17

- **RP-16, seteira ligada à laje, na Cripta B.** As duas lajes do pé do muro divisor (RP-06) armam cada uma a seteira do
  outro lado: uma seteira na parede norte de cada lado do muro ((-1,5; -10,75) e (1,55; -10,75), a leste fora da boca da
  porta norte), faixa de 1 m atirando para o sul até a fileira dos sarcófagos (z 2,4), aviso 1,0 s em âmbar, 7 no herói
  e 60 no inimigo, recarga 5 s. Robô: pisa na laje quando 2 inimigos ou mais estão na faixa e ele não, a até 8 m. Ponte A
  e Santuário ficaram de fora: a Ponte A tem a corrente (RP-11) e o Santuário já tem lajes e a coluna; um perigo que fere
  por sala (item 5 dos Riscos). Medido (24 sementes, régua de sempre): 6 salas da Cripta B da sala 4 em diante, seteira
  acertou 1 inimigo ou mais em 5 (meta: metade), 32,5 de dano nos inimigos por sala e 0 no herói (meta: 25 vezes o do
  herói); 15 vitórias de 24, `stuck` 1 (o de sempre).
- **RP-17, mureta.** Cripta A: uma de 5,5 m ao sul do túmulo grande (x -3,5 a 2, z 3,8; encurtada para deixar passagem
  junto ao sarcófago sul). Jardim A: duas quebradas num arco a 6 m do tronco, a leste (-6 a 21 graus) e ao sul (64 a 98),
  as raízes que cruzam o arco (-26, 43 e 118 graus) no meio das três entradas de 4,5 m. Medido contra o RP-16 (mesmas 24
  sementes): Cripta A tiros barrados 42 para 18% (cai, como a meta quer), primeiro contato 3,3 para 3,4 s (meta +1 s,
  **não**), zonas iguais (meio 34%, sul 30 para 35%); Jardim A o pátio fica vazio (`tree_shade` 0 para 1%, meta 30 a 60%,
  **não**: o robô e os inimigos lutam no campo leste, como no RP-10), dano por sala 2,1 para 1,2; `stuck` 1 para 0,
  vitórias 15 para 14 (ruído). Leitura para o room-designer: no Jardim o pátio só pesa se a luta for até ele (nascimentos,
  ou o pátio no campo leste).

## Feito em 2026-11-20 (gameplay-engineer): RP-10 (raiz que golpeia, Jardim)

- Comportamento: o `PLATES` do RP-06 com faixas giradas (`HazardDef.strips`, 3 m de largura: a raiz de 1 m e 1 m de cada
  lado), espera para armar (`dwell` 0,5 s: quem fica em cima, herói ou inimigo) e empurrão para fora da linha da raiz
  (`push_out` 1 m); aviso 1,2 s em âmbar com poeira, golpe 0,25 s, herói 7 e inimigo 60 (RP-03), recarga 6 s por raiz,
  dormente antes da sala 4 (0,34), nada nos 3 s do começo, no máximo 3 de uma vez (regra das lajes).
- Onde (`_roots` no `make_data.gd`): A, a raiz do norte (da face do tronco a (1,8; -8,1)) e a do oeste, cortada em
  (-11,4; 1,9) para a faixa ficar a 6 m ou mais da entrada; B, a do oeste cortada em (-6,2; 3,6) e o toco junto da parede
  oeste (a do norte da B passa a 5,4 m do meio: ficou de fora, como a proposta pede).
- "Derrotado por: Raiz Morta" (`killer_roots`, nome provisório para o Daniel); `rooms[].hazard` `kind` `roots`. Desenho
  provisório: a moldura da laje do RP-06 ao longo da raiz (`GroundLook.plate_band`); a raiz que racha é do
  environment-artist.
- Robô (24 sementes, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`): 27 salas de Jardim (18 nas salas 2 e 3, 9 da 4
  em diante); **nenhuma raiz acordou**: a luta fica no campo leste (`east_field` 50 a 90% do tempo), `tree_shade` 2 a 3%
  (já estava abaixo dos 30% da meta antes, então essa meta não mede nada hoje), ninguém fica 0,5 s junto das raízes de
  fora. Dano no herói 0 por sala (teto 1,5 cumprido por vazio) e nos inimigos 0 (meta de 10 vezes o do herói, sem
  dado). 24 de 24 em Morvath, `stuck` 1 (o mesmo esqueleto elite da semente 22, sala sem raiz). Leitura: as raízes de
  fora ficam longe de onde o robô e os inimigos lutam; para o perigo pesar, o room-designer decide entre (a) a raiz de
  dentro (a que chega ao meio), (b) espera menor para o inimigo, que só passa por ela, ou (c) medir com gente. Testes em
  `tests/test_roots.gd`.
- **Terceira passada**: parte da 2ª onda nascendo a oeste do tronco, ao sul dele (`late_spawns` + (-16..-12,5;
  -0,5..4,5)): 0 raízes acordadas e as salas de Jardim tardias com o mesmo tempo; devolvido.
- **Quarta passada (Game Director, 2026-11-20: a luta precisa usar o pátio)**: metade da 1ª onda nascendo a oeste e ao
  sul do tronco, como zonas das `spawns` (sorteadas pela área: (-16,5..-12; -12..-1) e (-11..-3; 1,5..5), 77,5 m² contra
  83 das outras quatro). 24 sementes contra o RP-17: A `tree_shade` 1 para 9% (dano 1,2 para 0,2 por sala), B 4 para
  20%, raiz acordada em 2 salas da B (era 0), mortes e `stuck` iguais. Uma segunda tentativa com as zonas dentro do pátio
  ((-14,5..-11,5; -12..1) e (-11..-4; -1..1), 53 m²) deu menos (A 7%, B 18%) e um `stuck`; saiu. **Ficou só na B**
  (`ArenaVariant.spawns`): de novo nas 24 sementes, B `tree_shade` 20% (`rest` 80%, `east_field` 0), raiz acordada em 2
  de 13 salas (2 golpes, 23 de dano nos inimigos), dano no herói 0,4 para 0,2 por sala, sala 23,2 para 18,5 s, vitórias
  14 para 17, `stuck` 0, nenhuma morte no Jardim. Mas essas zonas ficavam sob a faixa de duas raízes (regra do
  `test_roots.gd`: nenhuma raiz sobre um nascimento); fora das faixas ((-16,5..-14; -12..1), (-12,5..-8,3; -0,8..5,5),
  (-4,5..-1,5; 1,5..5), 69,5 m²) a B deu `tree_shade` 15% (`rest` 84%, `east_field` 0), raiz acordada em 1 de 13 salas,
  `stuck` 0, nenhuma morte no Jardim, vitórias 15. Não passa dos 20%: **devolvido**, nas duas variantes. A luta sai do
  campo leste, mas vai para o sudoeste fora do pátio; para o pátio pesar faltaria nascer dentro dele, onde estão as
  raízes (trocar a regra ou as raízes é do room-designer).
- **Segunda passada (Game Director)**: o inimigo acorda a raiz em 0,2 s (`HazardDef.enemy_dwell`; o herói segue 0,5 s).
  Mesmas 24 sementes: **nenhuma raiz acordou de novo** (0 golpes, 0 de dano, vitórias 15 de 24, `stuck` 1, iguais). Medi
  também, só como experimento e devolvido, a raiz de dentro de cada variante (A: da face do tronco a (0,3; 1,2), a que
  chega ao meio; B: a do norte, até (0,9; -5,4)): ainda **0** golpes. A luta do Jardim acontece a leste do tronco
  (`east_field` 49% do tempo, o resto no sudoeste da entrada); nenhuma raiz, nem a de dentro, chega lá. Para a raiz
  pesar, o perigo precisa estar no campo leste (raiz nova saindo do tronco para leste, peça e desenho novos) ou os
  inimigos precisam nascer a oeste do tronco: decisão do room-designer. A raiz de dentro **não** entrou (falta a
  aprovação dele aqui).
- **RP-21 na Cripta A, tentado e devolvido**: a laje na cabeceira leste do túmulo grande ((4,6..7,6; -1,5..1,5); a
  oeste fica a menos de 6 m da entrada) faz o `ArenaRoom.clear_of_plates` apagar a laje emoldurada desenhada nessa
  cabeceira (SW-G3, `CryptLook.STY_FRAMES_A`, a 4,4; 0): a de enfeite e a que fere ficariam lado a lado. Precisa do
  environment-artist mover ou trocar o par emoldurado antes.

## Feito em 2026-11-20 (gameplay-engineer): RP-09 (coluna rachada que tomba)

- Dado: `ArenaObstacle.hits_to_fall` 2, `fall_length` 5, `fall_width` 1,2, `fall_time` 0,6, `fall_damage` 50 (`_cracked` no
  `make_data.gd`) nas colunas quebradas do Santuário A e B (15; -6) e (-9; 6), do Jardim A (4,5; 7) e da Cripta B (6,5; -6).
- 1º golpe do herói racha, 2º tomba para onde o golpe foi (nunca de volta nele); faixa âmbar 0,6 s; 50 a cada inimigo
  que o corpo toca a faixa; 0 ao herói; toco no mesmo lugar (corpo sim, tiro não); uma vez por coluna por sala.
- Robô (24 sementes, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`): 65 salas com coluna, tomba em 35 (54%, meta 30%
  cumprida); dano médio por sala com coluna derrubada 28 (meta 40 **não** cumprida): metade dos tombos é acidental (a
  coluna está no arco de um golpe dado contra outro inimigo) e cai em ninguém; quando o robô planeja (`Bot.column_plan`)
  o tombo dá 50 a 100. Com gente, mirar a coluna é o natural: medir no teste. Robô: 22 de 24 em Morvath, `stuck` 1
  (esqueleto elite numa sala sem coluna); as duas mortes em salas sem coluna.
- Visual provisório (malhas da coluna num pivô que inclina, toco do `TombKit`); o pedido ao environment-artist está no
  CLAUDE.md (Coluna rachada que tomba).

## Feito em 2026-11-20 (gameplay-engineer): RP-08 nas Fendas (a fenda que respira)

- O mesmo `LINE` do RP-11 sem dano (`HazardDef.band_source` `breath`, `_breath` e `BREATH_PUSH` no `make_data.gd`): três
  trechos da beira, um por vez a cada 7 s depois de 3 s de calma, aviso 1,2 s (a faixa âmbar provisória, até a bruma do
  environment-artist), empurrão de 2,5 m para longe da beira; quem é empurrado preparando ou atacando tem o golpe
  cortado (`PlateFloor.strike(..., cut)`, nunca a investida do Escudo nem guardião). A: oeste da fenda do meio (x -10,8
  a -8, z -7 a -1, com o toco do RP-05 dentro), leste dela (x 2,9 a 5,2: mais largo, o empurrão cairia no buraco do
  leste) e sul da fenda de baixo (x -5,5 a 0,5, z 10,2 a 12,2); B: o oeste ao longo da ponte caída (x -10 a -7,2, z -13 a
  -7). Fora das cabeceiras das pontes e das zonas de nascimento (GUT). Aviso do chão sem dano não fere nem conta golpe
  (`Ground`: `Zone.floor_own`, só `power` acima de 0 chama o herói). `rooms[].hazard` `kind` `breath`, `pushed`, `cut`.
- **Ajuste (mesmo dia, pedido do Game Director)**: os trechos foram para onde a luta do robô acontece e a bruma sobe no
  trecho com mais inimigos (`HazardDef.band_busy`; empate ou nenhum: em ordem). A e B: beira leste da fenda do meio (x
  2,9 a 5,2, z -7 a -1), leste da fenda de baixo junto da ponte do sul (x 2,9 a 4,9, z 4,2 a 9), caminho do sul (x -8 a
  2, z 10,2 a 12,2), mais o oeste da fenda do meio na A (x -10,8 a -8) e o oeste ao longo da ponte caída na B (x -10 a
  -7,2, z -13 a -7). A faixa ao lado da cabeceira leste da ponte do sul (z -1 a 4) ficou de fora: atrás dela é a ponte,
  não a fenda, e o empurrão não leva para longe de beira nenhuma.
- Robô (reação 0,25): 0 de dano, `stuck` 0. Inimigos empurrados por sala, primeira sala, sementes 1 a 8: A 1,1 (antes
  0,4), B 0,6; na descida (12 sementes, `smoke 600`, 12 salas das Fendas nas profundidades 2 a 9) 0,75, 0 a 2, golpes
  cortados 3 em 12 salas. **Não fecha a meta de 3 ou mais**: as salas das Fendas duram 15 a 40 s, o que dá 1 a 5 sopros
  por sala, e o robô luta andando (os inimigos que o seguem raramente param na beira). Fica para o teste com gente
  (o jogador que segura a beira, como o perigo pede) e, se ainda faltar, um ciclo mais curto (número, do balance-designer
  com o room-designer).
- Testes em `tests/test_breath.gd`.

## Feito em 2026-11-20 (gameplay-engineer): RP-11 na Ponte (a corrente que varre)

- Comportamento `LINE` (`HazardDef.Kind.LINE`: `bands`, `band_push`, `cycle`; puro em `BandHazard`, no jogo `BandFloor`,
  ligado pelo `Rooms._start_hazard`): faixas que golpeiam uma por vez, em ordem, no relógio da sala; 3 s de calma, uma a
  cada 6 s, aviso 1,2 s (a faixa âmbar das Runas, `Ground.add_hazard` desenhado, até a corrente do environment-artist),
  golpe 0,25 s com os números do RP-03 (7 no herói, 60 no inimigo) e empurrão de 2,5 m ao longo da ponte para a
  plataforma a que ela leva (`PlateFloor.strike`, comum às lajes; ninguém cai). Faixa sobre boca de porta nunca golpeia.
  Dado (`_chain` no `make_data.gd`): Ponte A uma faixa de 2 m em cada ponte (x -11,5 a -9,5 e 9,5 a 11,5), alternando;
  Ponte B as duas metades da ponte longa (x -11 a -9 e 9 a 11), a 6 m do patamar. "Derrotado por: Corrente da Ponte"
  (`killer_chain`, nome provisório para o Daniel), `rooms[].hazard` com `kind` `chain` e `hero_in_s`. Som: o das Runas.
- Robô (reação 0,25, a Ponte como primeira sala, sementes 1 a 8): A ponte 1 + ponte 2 de 9 a 24% do tempo, meio 45 a
  76%; B ponte 10 a 36% (mediana 20), patamar 14 a 68% (abaixo de 25% em 2 de 8); dano da corrente no herói 0 em 16
  salas (o robô sai de todo aviso no chão; a meta de 0,5 a 2 por sala é para gente), nos inimigos 0 a 120 (2 a 4
  golpes por sala, 4 abates em 16 salas); `stuck` 0. Fica de fora: o raio entre pilares das Runas A tardias (o mesmo
  `LINE`, só dado, quando o room-designer escolher os pares) e a medida em salas tardias.
- Testes em `tests/test_chain.gd` (relógio e ordem, nunca duas, porta, faixas inteiras no tabuleiro, empurrão no chão,
  saída com uma esquiva ao longo da ponte de qualquer ponto da faixa, sala real).

## Feito em 2026-11-20 (gameplay-engineer): LR-03 e RP-07; LR-04 e LR-06 provados e devolvidos

Medido com `smoke 900 --bot-reaction=0.25 --ultimate=cleave --trace-thirds`, sementes 1 a 24 (salas de luta sem
guardião; terços como na 2.3, agora contados pelo próprio jogo: `--trace-thirds`, `hero_x0..2`, `hero_z0..2`,
`foe_x0..2` em `rooms[].zones`).

- **LR-03, entrou** (`_rect(4, 12, 8, 12)` e `_rect(-2, 6, -12, -8.5)` na primeira onda do Santuário). Luta comum,
  A (8 salas) / B (4): terço leste do herói 46 / 51% (era 14 / 21), dos inimigos 18 / 22% (era 1 / 5), primeiro
  contato 2,3 / 3,2 s (era 5,0): passam. **Não passam**: a nave cai para 44 / 40% (meta 50 a 65; as naves laterais
  ficaram com 56 / 57%) e o dano por sala 1,0 / 0,5 (amostra pequena; a meta pedia dentro de 20% de hoje). Para o
  room-designer: trocar um dos dois retângulos por um no meio leste da nave devolveria a nave sem perder o leste.
- **LR-04, devolvido**: com o grupo do norte em x -12 a -5, `tree_shade` ficou 5 / 7% (era 3 a 7) e o tronco barrou
  0,08 a 0,12 tiro por sala (meta 1 ou mais). Como a proposta dizia, pode ser o robô (não procura cobertura); o tronco
  no meio é a outra saída, de arte.
- **LR-06, devolvido**: com o muro de 12 m (fim em z 1,5) a luta foi para o sul: terço sul do herói 40 para 55%,
  `south_open` (as áreas de antes) 79 a 82 para 77%, `west_of_wall` 6% (meta 15). O herói entra no sudoeste e os
  inimigos nascem a leste: o muro mais longo só fechou o meio.
- **RP-07, entrou** (filtro no `RunMap`, faixas desta página no `_stage`; ver CLAUDE.md "Arenas"). A intensidade do perigo
  pela faixa (Runas A tardia com `rest` 1,8 e `max_share` 0,4) ficou de fora: é número, vai com o balance-designer.

## Feito em 2026-11-19 (noite): RP-06 (laje rachada) e RP-13 só no Santuário B

**O que entrou.** `HazardDef.kind` `PLATES` (`plates`, `rearm`, `from_progress`, por laje `plate_hero_damage` e
`plate_push`), lógica pura `PlateHazard` (`scripts/core/plate_hazard.gd`), no jogo `PlateFloor`
(`scripts/game/plate_floor.gd`), dado `_plates` no `_stage`. Números: aviso 1,0 s (a laje acende da borda para o meio),
golpe 0,25 s, herói 7, inimigo 60 (RP-03), recarga 5 s, nada nos 3 s do começo, nunca em laje na boca de porta, no
máximo 2 armadas de uma vez (R9; era 3, o 222700 do Sworn), dormentes antes do progresso 0,34 (salas 2 e 3: desenhadas, não ferem).
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
arma, dormente, porta, duas de cada vez, lugares, saída andando de 12 x 12 pontos com 0,25 s de reação, sala real com
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

## Lote 3, SR-P4 e SR-P1 (2026-11-21, room-designer; princípios do SWORN, nada copiado)

### 1. Armadilha de parede (SR-P1)
| Sala | Linhas (parede, sentido, comprimento) | Dorme até | Ciclo | Por que ali |
|---|---|---|---|---|
| Jardim A | leste (17,-7) para oeste 12 m; sul (-0,5,14) para norte 10 m | 0,3 | 6 s | o campo leste, onde a luta vai (54%); entre as portas norte e leste |
| Santuário A | norte (-6,-14) para sul 18,5 m; sul (-1,5,14) 19 m; sul (12,14) 18 m para norte | 0,5 | 4,5 s | corta a nave e as naves laterais entre as colunas; a entrada (leste, 19,5) fica a 7 m da última |
| Santuário C | as duas primeiras | 0,5 | 4,5 s | a grade de colunas ocupa x 2 a 12: só o oeste |

Regra: 1,2 s de aviso (o do inimigo comum), 10 no herói, 60 no inimigo, calma de 5 s, uma linha por vez, a com mais
inimigos primeiro. Nunca a menos de 6 m da entrada nem sobre a boca de uma porta, sempre uma saída livre (linhas a 4,5 m
ou mais uma da outra). Ficam de fora de propósito: Ponte e Fendas (já têm faixa em `bands`), Runas (já são o perigo da
sala), Cripta (laje + urna/nicho/seteira). Aceite: 0 `stuck`; dano no herói de 0 a 2 por sala acordada; os inimigos pegam
mais do que o herói.

### 2. Medidas do robô (12 descidas, `smoke 900 --bot-reaction=0.25`, sementes 1 a 12, árvore com o kit do herói em obra)
Sem as armadilhas: 1 vitória em 12, 0 `stuck`, nenhuma morte por perigo (a mesma árvore, `NO_TRAPS` temporário). Com: 0 vitórias
em 12 (a semente 4 deixou de chegar a Morvath por outra rota sorteada; mortes por mago, cavaleiro e runas), 0 `stuck`,
**0 morte e 0 dano de armadilha no herói** em 11 salas com armadilha vistas (4 acordadas em 2 sementes). Nas acordadas:
Santuário A (sala 9) 11 disparos, 0 golpe no herói e 0 no inimigo, herói 4,6 s dentro das linhas; Jardim A (sala 4) 4
disparos, 60 e 1 abate no inimigo. Leitura: legível demais para o robô (reação 0,25 s), pouco usada contra o bando; falta
um segundo número para provar que joga diferente (zonas do Santuário com a linha: o robô cruza a nave pelas colunas).
Próximo ajuste se o Daniel quiser mais bite: faixa de 1,6 m e ciclo de 3,5 s no Santuário.

### 3. SR-P2 Laje que cede (especificação, não feita)
Laje de 3 x 3 m marcada com rachaduras (o repouso da laje do RP-06). Quem fica nela (herói ou inimigo) por `dwell` 1,0 s
a faz ceder: aviso de 1,2 s (padrão P4, a laje inteira), depois afunda 0,6 s e o buraco fere 10 no herói e 60 no inimigo
**e devolve ao chão** (empurrão de 1 m para a beira firme, nada de queda que mata: D-28), volta a subir em 6 s. É um `PLATES`
com `dwell` > 0 e `push_out` (o mecanismo da raiz, RP-10); só falta o desenho (laje que afunda, do environment-artist) e a
chave `killer_sink`. Lugar: Cripta A no lugar de duas das quatro lajes (acordadas desde 0,34), Ponte B no patamar.
Sem código novo de lógica.

### 4. O que precisa de arte (`environment-artist`, com a spec do `art-director`)
- **Bloco da armadilha**: hoje é a peça da seteira (bloco de pedra, boca escura acendendo, três chevrons) com 1,2 x 0,6 m.
  Pedir: bloco de parede com a direção talhada (setas ou lâminas esculpidas), boca que mostra a lâmina saindo, e a lâmina
  voando pela faixa nos 0,25 s do golpe (hoje a faixa acende inteira de uma vez).
- **Aviso**: tudo no mesmo vermelho do jogo; as peças âmbar (moldura da laje armando, brasa das raízes) podem ser
  reavaliadas para o vermelho e a luz âmbar da peça combinarem com o aviso no chão.
- Texto "Armadilha de Lâminas" é provisório (nome para o Daniel).

## Lote SR-P (2026-11-21, room-designer): laje que cede, grade de espinhos, relíquia, armadilha mais dura

Ideia de jogo de cada um e onde entra na descida (progresso = `EncounterGen.progress`):

| Perigo | O que pede | Salas | Desde |
|---|---|---|---|
| Laje que cede (`sag`) | não parar no chão rachado; atrair o bando para ele | Fendas A (2 lajes a leste), Santuário A (3, nave e oeste) | 0,4 e 0,5 |
| Grade de espinhos (`spikes`) | puxar o bando para a grade que vai subir (a com mais inimigos primeiro) | Cripta A e B, Santuário B | 0,4, 0,4 e 0,55 |
| Armadilha de parede (SR-P1, mais dura) | atravessar a linha de 1,6 m entre os golpes; ciclo cai com a descida | Jardim A (5 s, 4 s desde 0,7), Santuário A e C (3,5 s, 2,8 s desde 0,7) | 0,3 e 0,5 |
| Relíquia na pedra (SR-P5) | uma volta extra até o canto depois da luta, por 30 de ouro ou 6 de Prata | Cripta, Fendas, Jardim, Santuário | sala 3, 50% das lutas |

Todos: aviso de 1,2 s ou mais, 10 ao herói e 60 ao inimigo, calma de 5 s no começo, dormentes antes do "desde", fora da
porta, a 6 m ou mais da entrada, sem tocar outro perigo da sala (`tests/test_hazard_sr.gd`). Só o descanso encurta com a
profundidade (`cycle_late`, `rearm_late`, desde 0,7). Métricas do robô (12 sementes `smoke 600 --bot-reaction=0.25` e 6 com
`--hero-hp=300`, 900 s): nenhum `stuck`; o robô quase não leva dano do perigo (reage ao aviso em 0,25 s; 0 a 10 de cada
fonte por descida, mais as rochas e as lajes), mas a armadilha dá 51 golpes e 197 de dano nos inimigos em 7 salas e as
lajes 53 golpes e 302. As grades e a laje que cede quase não apareceram (salas sorteadas cedo; só dormentes até 0,4/0,55).
