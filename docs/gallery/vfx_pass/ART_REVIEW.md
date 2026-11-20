# Revisão de arte, passada de VFX, Lote 1 (2026-11-20)

Revisor: art-director. Spec: `docs/art/vfx_pass_spec.md` (ordens 1 a 5 da seção 9). Árvore de trabalho sobre `a649036`,
estilizado, Forward+ na RTX 5060, 1920 x 1080, semente 5.

## Evidência
- Do technical-artist: `s_swing`, `s_hit`, `s_omega`, `h_spin`, `e_melee`, `e_ranged`, `e_runner`, `n_scythe`, `n_reap`,
  `shafts_sheet_*` (nesta pasta); antes em `docs/art/shots/vfx_pass_before/`; tinta em `docs/gallery/hb/ink_crowd/`;
  HB3 em `docs/gallery/hb/hb3_*`.
- Capturas desta revisão (GPU, quadros a cada 0,07 e 0,08 s):
  - `review_runner_burst_f0.png` e `review_runner_burst.png`: explosão do corredor, quadro antes e quadro do anel
    (`--stress=4 --stress-ids=runner,... --hero-at=0,0 --hero-hp=9999 --frames --shot-at=1.8 --every=0.07`, quadros 9 e 10).
  - `review_boss_cut.png`, `review_boss_cut2.png`: corte comum e estalo sobre Morvath (`--bot --start=boss --hero-hp=9999
    --frames --shot-at=2.5 --every=0.08`, quadros 15 e 18); da mesma série `review_boss_contact_cross.png` (quadro 9),
    `review_boss_flash.png` (quadro 8) e `review_boss_cast_circle.png` (quadro 3).
- Medida: maior canal e matiz por caixa (contador simples no scratchpad; "branco" = os três canais acima de 235).

## Veredito por item

| Item | Veredito | O que a captura mostra |
|---|---|---|
| 6, luz sobre o que se pega (`RewardShaft`) | **Aprovado como peça; aceite no jogo pendente** | Folha: cores de cada coluna pálidas e na família (romã rosada, Magia azulada, ouro, Prata quase branca, Encanto verde-pálido), sem vermelho de perigo nem violeta; teto ok (p99 159). Compatibility lê igual. A folha não é a câmera do jogo: os critérios 6.6 (1 a 4, 6) só valem com o facho ligado. A poça lê como um aro claro em volta do relicário, fraca; julgar no chão real. |
| 5.6, partículas sem bolinha | **Aprovado com P1** | Nada de bolha de sabão nas capturas. Restam: lascas marfim do `light` acima da cabeça do herói no Ômega (`s_omega`, a regra é nunca acima do ombro) e o miolo do estalo, que é um disco macio branco (ver V-05). |
| Teto (regra 1) | **Aprovado com P1** | Estocada: p99 de 255 / branco 5% para 213 / 0%. Ômega, foice, Ceifa, orbes, fita do giro: dentro de 226. Fora do teto: o estalo (p99 247 a 255, branco até 1,4%), um traço branco vertical sobre o inimigo atingido (`s_hit`, x 500 a 520: p99 255, branco 6,7%; já estava no antes) e o preparo do feiticeiro (`e_ranged`, ponta do cajado, p99 255; é V-13 do Lote 2). |
| V-11, magia dos mortos e orbe | **Aprovado com P2** | Orbe de núcleo escuro e aro magenta, p99 180 a 185, nada acima de 210; a Chama do herói (31) e o violeta de Morvath (264) bem longe. Matiz 313, 7 graus abaixo da faixa 320 a 330. Lê como disco chapado com borda rasgada; os espinhos girando não aparecem nesse tamanho. O virote não aparece em nenhuma captura depois: não avaliado. |
| V-12, explosão do corredor | **Aprovado com P2** | Antes: disco laranja com 67% acima de 235. Agora: anel carmim de borda rasgada com fumaça escura por fora, sem preenchimento, nada de branco (`review_runner_burst`). É fino e fraco: o estouro mal se lê ao lado do herói; o miolo escuro e os fiapos quase não aparecem. |
| V-01, corte de volta ao esmeralda | **Aprovado com P2** | Fita sobre Morvath matiz 124 a 143 (p50 129 a 131), p99 214 a 225, branco 0%; giro 129 a 155; Ômega 123 a 137. O ciano saiu. Saturação p50 0,18 sobre Morvath e 0,26 no giro, abaixo dos 0,45 da tabela: lê como menta pálida, mas separa do violeta sem dúvida. |
| V-02, giro sem elipse | **Aprovado** | Fita que varre e se abre, cabeça larga em pinceladas e cauda fina, nenhum anel fechado (`h_spin`). |
| V-03, brilho sem cruz | **Aprovado com P1** | Nenhuma linha longa atravessando o herói. Mas o aro do brilho em marfim passa por cima do tronco dele (`h_spin`, recorte): lê como marcador de interface sobre o corpo. |
| V-04, estocada e Ômega como lâmina | **Aprovado** | Saiu o sabre de néon: miolo escuro, fio de 2 px, veios de ouro no Ômega, dentro do teto (`s_omega`). O afinar até a ponta quase não se vê porque a lança atravessa a tela; aceitável. |
| V-05, estalo no contato | **Não aprovado (P1)** | Existe e tem 5 a 6 espinhos desiguais no acerto real (`s_hit`, `review_boss_cut2`), mas: o miolo é um disco branco macio (regra 3) e passa do teto (p99 247 a 255); num quadro mais tarde só sobram duas pontas longas que leem como cruz. Em `review_boss_contact_cross` aparece uma cruz de 4 pontas brancas sobre Morvath: é o acerto da Onda de Luz (estrela furada antiga, `SPECIAL_STAR`), item V-06 do Lote 2, mas fere a regra 4. |
| V-16, foice e Ceifa | **Aprovado com P2** | Matiz 260 a 267, p99 204, nenhum ciano, nenhum branco (`n_scythe`, `n_reap`). O setor sai chapado num violeta só (o lilás-marfim do miolo não aparece) e os fiapos leem como gotas em pé espalhadas por igual. |
| Linha de tinta (HB, ligada por padrão) | **Aprovado** | Com 12 inimigos nenhuma figura ganha contorno dobrado e a linha não cruza as barras (`near_alta_ink1_masked`). |
| HB3, herói e Emeth | **Aprovado** | Herói mais saturado, Emeth no verde (matiz 130). |
| Corpo da multidão mais escuro | **Aprovado** | Osso abaixo da laje no Santuário pelos números; nas capturas os mortos leem como figuras escuras de borda morna. |

## Pedidos de correção

### P0 (antes do teste do Daniel)
- **gameplay-engineer**: ligar o facho (`RewardShaft.make` / `appear` / `take`) no `_room_cleared`, na loja (força pelo ouro)
  e na fonte. Hoje a coluna de 1 s da recompensa saiu e o facho não entrou: a sala vencida não marca a recompensa de cima,
  pior que antes. Depois disso, capturas da 6.6 (1 a 4 e o vídeo do pouso) para o aceite do art-director.

### P1 (technical-artist, ainda no Lote 1)
1. Estalo (`contact.gdshader`): miolo como forma dura pequena (losango ou estrela de 5 pontas de 0,12 m), não disco
   macio; maior canal p99 até 226 e branco 0% na caixa de 80 x 80; o último quadro não pode ficar só com duas pontas em
   ângulo reto (apagar as pontas juntas ou pela ordem de comprimento, não deixando um par).
2. Traço branco vertical sobre o inimigo atingido (`s_hit`, `s_swing`): identificar a peça (talho do `Fx.gash` visto de
   ponta, ou a marca do ouro) e trazer para o teto 226, fora do branco.
3. Aro do brilho do finalizador (`glint.gdshader`): não desenhar sobre o corpo do herói (abrir em volta dele, `hero_hole`,
   ou ficar atrás na vista).
4. Lascas `light` do herói: nada acima do ombro dele na tela (`s_omega` tem lascas acima da cabeça).
5. Clarão de Morvath no golpe forte (`review_boss_flash`): no estilizado o corpo inteiro vai a bege claro (branco 0,7%
   na caixa). Mantê-lo violeta mais claro, abaixo de 226, como o pisca do corpo comum.

### P2
- gameplay-engineer: `DEAD_MAGENTA` até a tela dar 320 a 330 (hoje 313).
- technical-artist: anel da explosão do corredor um pouco mais largo e com o miolo escuro visível (é o "estourou" do
  inimigo); foice com o lilás-marfim no miolo e os fiapos em fiapo rasgado, não gota em pé; fita do herói com saturação
  p50 perto de 0,4 (hoje 0,18 a 0,26).
- technical-artist: uma captura do virote do besteiro (a spec pede agulha escura com ponta carmim; não há evidência).

## Depende de asset ou de outra frente
- Medalhão do Encanto e do Salmo vazio no `RewardGem` (aro sem marca): marca nova, technical-artist ou ui-ux-designer.
- O Círculo ainda acende como disco branco cheio no lançamento (`review_boss_cast_circle`, p99 239) e fica como elipse
  fina perfeita: é o V-07 do Lote 2.

## Lote 2
**Pode começar** em paralelo com os P1 acima (arquivos diferentes, exceto o `contact.gdshader`, que o V-06 reusa: fazer o
P1-1 primeiro). Entram no Lote 2 com prioridade: V-06 (o acerto da onda ainda é a cruz de 4 pontas), V-07 (disco branco
do círculo), V-13 (preparo do feiticeiro e do Ancião acima do teto), V-15 e o fim das `Game.column` restantes (Bênção e
Salmo tomados, elite surgindo).

**Veredito do Lote 1**: não vai ao Daniel ainda. Falta o P0 (facho ligado) e os P1-1 a P1-3. Com eles, aprovado para teste.

## Para o combat-feel-director conferir
1. **Faísca de acerto (`Fx.contact`)**: nasce no mesmo quadro do acerto real (nunca no golpe que erra nem no escudo do
   ritual) e dura 3 quadros; não atrasa nem encobre o clarão do inimigo; com 8 acertos no mesmo quadro (orçamento
   `contacts`) nenhum some no golpe que derruba; o hit stop e o tranco da câmera iguais aos de antes (sonda 41/41).
2. **Estocada (`emeth_thrust`, `THRUST_IN` 0,06 s, `THRUST_OUT` 0,15 s)**: a luz chega à ponta no quadro do acerto, não
   depois (o golpe não pode parecer atrasado em relação ao dano nem ao número); Corte Veloz e Ômega do ataque com a lâmina
   inteira visível no quadro em que fere; os 5 espinhos do Ômega no quadro do acerto, não no aperto.
3. Explosão do corredor: o anel de fumaça aparece no quadro do dano (aviso a -1 a +1 quadro no `enemy_motion_probe`) e o
   aro do segundo anel do corredor elite continua 0,4 s à vista antes da segunda explosão (P2-C19a).
4. Foice e Ceifa: o setor novo cobre exatamente a área que fere no quadro do golpe (borda roída sem passar do alcance).
