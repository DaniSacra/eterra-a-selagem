> Índice: [rooms_progression.md](../rooms_progression.md)

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

**[Feito 2026-11-20, ver "Feito em 2026-11-20 (gameplay-engineer): RP-10"] RP-10 (P2) Raiz que golpeia (H-1), o Jardim acorda da sala 4.**
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
