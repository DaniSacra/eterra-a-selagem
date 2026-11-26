# Revisão de arte 2026-11-26b: Santuário da Vigília contra a arte aprovada

Art-director, 2026-11-26. Referência: `docs/art/ref/hub01_2026-11-25/eterra_hub/01-arte-aprovada.jpg`.
Capturas (GPU, rodada 8): `docs/gallery/hub_refine_2026-11-26/r8_arrive.png`, `r8_heroes.png`, `r8_axis.png`, `r8_vine.png`,
`r8_far.png`. Responsável por todos os itens: environment-artist. Tudo é peça provisória (formas simples, sem modelo final).

## O que já bate
Paleta quente de entardecer, lanternas, glicínias nos beirais, cipestres escuros, telhados vermelhos, Aposento com escada de tapete
vermelho entre dois estandartes do leão, portas "Área Futura" em arco com cadeado, cascatas finas, árvore vermelha no canto. Herói legível.

## Lista por prioridade

1. **Tirar o abismo do meio do mapa** (`HubPlan.OUTLINE`, o recorte entre (0,35, -8,5), (-7, -8,5) e (-12,25, -17); a cascata que
   cai ali, `HubScenery.EXTRA_FALLS`/`FALL_OPEN`). Na arte, ao sul da Videira há uma praça baixa com um canteiro grande de flores
   no centro e duas escadas largas descendo para as duas Áreas Futuras; não há vazio nem cachoeira ali (as cachoeiras ficam só a
   leste, sob a ponte do Portão). Fazer: preencher o recorte como terraço baixo (nível -1,2, o inverso de `TIER_H`) com canteiro
   central e dois lances (`STAIR_STEPS` 6) junto às portas; cachoeiras só em `FALLS` (u >= 16). Mexe em `scripts/core/hub_plan.gd`
   (piso andável e `NavGrid`): precisa de aval do Game Director. É a maior diferença de composição em `r8_far`/`r8_axis`.
   Aprovação: na `r8_far`, a metade de baixo da tela é piso, flores e escadas, sem faixa escura vertical.

2. **Videira como gazebo redondo com a fonte no centro** (`HubScenery.PERGOLA_*`, `HubPlan.VINE_ARCH`/`VINE_BED`, `HubLook`
   da fonte `FOUNTAIN_BASIN`). Hoje é uma pérgula retangular sobre um canteiro de terra escura, com um pórtico de pedra quadrado na
   frente que esconde a fonte. Na arte: anel de 6 a 8 colunas creme em volta de uma fonte redonda clara, cúpula de folhas e uvas por
   cima, cachos roxos caindo entre as colunas, piso de pedra (sem terra escura) e um degrau redondo. Tirar o pórtico (`VINE_ARCH`);
   o ponto de uso passa para a borda do degrau. Aprovação: na `r8_vine`, água azul-clara da fonte visível entre as colunas.

3. **Piso: pedra creme-dourada em pedras pequenas, não lajões rosados** (`HubLook.STY_FLOOR_STONE` 0.8,0.66,0.56 e o tamanho de
   laje do material do piso no hub). A arte tem calçamento miúdo (pedras de 0,3 a 0,5 m, em leque nas praças) cor creme-mel. Fazer:
   `STY_FLOOR_STONE` perto de (0.86, 0.75, 0.58), `slab_hue` menor (6 para 3), lajes do hub com metade do tamanho atual e juntas
   mais finas e claras. Aprovação: a praça lê mais clara e mais amarela que as paredes, sem cara de assoalho marrom.

4. **Fundo: falésias e montanhas, não azul-marinho liso** (`HubScenery.SKY_*`, `SKY_CARD`, `hub_sky.gdshader`;
   `HubLook.CLIFF_*`). Na arte, o entorno é rocha cinza-lilás com mato e cipestres, e no horizonte do Portão montanhas lilases.
   Nas capturas o canto esquerdo (`r8_arrive`) é chapado escuro. Fazer: rocha de falésia subindo atrás das bordas oeste e norte
   (pelo menos 6 m acima do piso), gradiente do céu de lilás (`SKY_HORIZON`) até o azul só no alto da tela. Aprovação: nenhum
   trecho de azul uniforme maior que 1/8 da tela na `r8_arrive`.

5. **Flores menores e misturadas** (`HubLook.BLOOM_TALL` 1,15, `BLOOM_WIDE` 0,82, `BLOOM_BLOSSOMS` 7). Os tufos viraram bolas
   lilases do tamanho do herói, todos iguais (`r8_heroes`, primeiro plano). Na arte são canteiros densos de florzinhas roxas,
   rosas e algumas brancas, com mais verde. Fazer: tamanho em 0,55 a 0,7, `BLOOM_BLOSSOMS` 12 a 16 flores menores, 3 tons por
   canteiro (roxo, magenta, branco creme 15%). Aprovação: nenhuma flor isolada maior que a cabeça do herói.

6. **Balaustradas mais finas** (`HubScenery.RAIL_*`; `HubLevels.PARAPET_WIDE` 0,9, `COPING`). Os pilares de balaústre estão
   grossos e altos (quase a altura do herói), em blocos escuros que pesam no primeiro plano (`r8_arrive`, `r8_axis`). Na arte são
   baixos, creme, com balaústres torneados e lanterna em alguns pilares. Fazer: pilar 0,5 m de lado, altura 0,8, corrimão creme
   claro (a cor do piso, não marrom), lanterna a cada 4 pilares (já é). Aprovação: o herói fica com o peito acima do corrimão.

7. **Colunas de hera no meio das praças** (`HubScenery.IVY_EVERY` 2,6, `IVY_TALL` até 5,5). Há muitas colunas verdes altas
   soltas no piso da praça da Videira e na entrada (`r8_far`), que cortam a leitura. Na arte, cipestres ficam nas bordas e atrás dos
   prédios. Fazer: hera só encostada em parede ou falésia, `IVY_EVERY` 4, nenhum cipreste a menos de 3 m das linhas de caminho.

8. **Ponto de Vigília com nicho em arco atrás do fogo** (`HubScenery.VIGIL_NICHE`, `VIGIL_FLAME`). Na arte o braseiro fica num
   estrado redondo de 2 degraus com um arco de pedra alto atrás, estandarte ao lado. Hoje o nicho é baixo e fica escondido sob o
   canteiro. Fazer: arco de 2,4 m de vão por 3 m de altura logo atrás do braseiro (oeste), voltado para a praça. Aprovação: na
   `r8_arrive`, o fogo tem um arco claro emoldurando-o.

9. **Contornos e sombras de folhagem muito pretos** (material estilizado das folhas: `HubScenery.TREE_DARK`, `IVY_A`,
   `CYPRESS_A`). As folhas têm borda serrilhada escura que vira ruído na tela inteira. Fazer: sombra das folhas para o verde-oliva
   (subir uns 30% o valor de `IVY_A`/`TREE_DARK`) e borda mais fina. Aprovação: a hera lê como massa verde, não como pontilhado.

10. **Mercador e Forja: toldo e cor** (`HubFacades`, toldo do Mercador). O toldo listrado vermelho e branco está saturado e
    branco puro; na arte é vinho e creme. Fazer: listras `VINOUS` e creme (0.9, 0.82, 0.68). Menor; fazer junto com o item 3.

## Sala em combate (`docs/gallery/sweep_2026-11-26/status_pips.png`)
Nada grave. Só uma nota: a faixa de água/musgo que corta a sala é larga e com brilho forte; compete com os avisos no chão. Fica
para a revisão das salas, não para este lote.

## Veredito
Não aprovado ainda: os itens 1 e 2 mudam a composição central e são o que mais afasta o hub da arte. Com 1 a 5 feitos e
capturados de novo na GPU (mesmos cinco enquadramentos), pode ir para o Daniel. A aprovação final é dele.
