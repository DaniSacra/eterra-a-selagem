> Índice: [art_fx.md](../art_fx.md)

## Passe de VFX, Lote 1, parte do technical-artist (2026-11-20; spec `docs/art/vfx_pass_spec.md`, capturas em `docs/gallery/vfx_pass/`)
- **Luz que cai sobre o que se pega (seção 6, `RewardShaft`, `scripts/game/reward_shaft.gd`)**: tronco de luz fraca de
  cima da tela até o relicário (0,6 m em cima, 1,25 no chão, 18 m, `reward_shaft.gdshader`), poça no chão (decalque,
  sem luz real, `reward_pool.gdshader`) e poeira caindo (`reward_dust.gdshader`); tudo `blend_premul_alpha` sob
  `ScreenTone.linear_peak(cor) x CAP_SHARE` 0,85; a 2,5 m do eixo do herói cai a 0,35 (a poça a 0,6) e abre em volta dele
  (`hero_hole`); tempo real. Cor: o matiz do esmalte da recompensa (`TONE`) ou do anjo da porta (`AngelSeal.TINT`), a
  saturação a `TINT` 0,55 da dela e no máximo `PALE` 0,28 (em HSV: misturado com marfim em RGB a romã e o Encanto iam 30
  a 48 graus para o marfim); Bênção de dois anjos ou do guardião em marfim; fonte `fountain_tint()`.
  **API para o gameplay-engineer** (`rooms.gd`, loja e fonte; a `game.column` do `_room_cleared` sai):
  `var s := RewardShaft.make(pai, Vector3(x, 0, z), RewardShaft.tint_of(recompensa, família_do_anjo))`; `s.appear()`
  (espera `WAIT` 0,45 s, desce em 0,35, pousa em 0,25 com pulso, respira); `s.appear(0.0, true)` (loja e fonte: já ali);
  `s.set_strength(RewardShaft.SHOP_CAN | SHOP_CANNOT)` (0,75 / 0,3 pelo ouro; fonte `FOUNTAIN` 0,8 no `make`);
  `s.take()` (sobe em 0,3 s e se apaga sozinho). `--no-shafts` esconde. `tools/gem_lab.gd -- --shafts [--at=s]
  [--shop=0.3]`. Medido (RTX 1080, estilizado, `shafts_sheet_stylized.png`): matiz de cada coluna a até 3 graus da tabela
  (romã 350, coração 340, Magia 226, ouro 40, prata 211, Memória 37, Encanto 137, Salmo 40, Vigília 85), saturação p50 até
  0,26, maior canal p99 159 (teto 210); no Compatibility igual a olho com `COMPAT_GAIN` 1,6. Teste `tests/test_reward_shaft.gd`.
  Falta: medalhão do Encanto e do Salmo é um aro vazio no `RewardGem` (sem marca).
- **Partículas sem bolinha (5.6)**: os `Fx.BURSTS` não usam mais `CPUParticles3D` com o ponto redondo (`Fx.soft_dot` e
  `Fx.quad` ficam para os halos das velas): `form` `chip` = lascas na MultiMesh das lascas (`Fx._spray`, gravidade por
  lasca, as de explosão não contam em `showing(&"motes")`), `wisp` = fiapos de fumaça de borda rasgada que sobem e se
  desfazem de baixo (`Fx.wisps`, MultiMesh de `WISP_POOL` 96, `wisp.gdshader`, premul: escuro cobre, claro soma pouco);
  cores todas abaixo de 1 (cura marfim-rosada, sombra de inimigo em fumaça escura, fogo com dois fiapos de fumaça no
  fim). `chip.gdshader` agora premul sob `cap` (226 na tela). Orçamento igual.
- **V-11 e V-12, inimigo**: orbe com núcleo escuro (`enemy_orb.gdshader`: tinta no meio, aro na cor, `rim` 0,21 e `hot` 0,1: o
  `ScreenTone.linear_peak` do magenta e do carmim a 210 é 0,21 a 0,24; a 0,48 a curva da tela levava o aro a 248 e 255) e
  fumaça rasgada com três espinhos girando em volta (`enemy_orb_halo.gdshader`, premul, `spike_light` 0,22); virote = agulha escura com a
  ponta na cor (`needle`), sem halo; rastro de fumaça a cada 0,45 m (virote) ou 0,7 m (orbe) (`Projectiles._trail`). Onde
  o golpe de um inimigo cai: anel de fumaça escura de borda rasgada que se abre, aro de dentro na cor sob 205 na tela, meio
  escuro, sete fiapos (`Fx.smoke_ring`, `smoke_ring.gdshader`, `Ground._land`; o `land_quick` é o anel fino); as
  erupções de Morvath ficam com o `Fx.ring`. A cor da magia (carmim e magenta) é do `make_data.gd` (gameplay-engineer).
- **V-01 a V-05, a lâmina**: `slash.gdshader` premul (alfa 0 no clássico = a mesma soma), no estilizado o fio a
  `style_edge_pale` 0,45 e o teto pelo maior canal (`style_peak` = `ScreenTone.linear_peak` do fio, posto pelo
  `Fx.slash`; o teto por canal deixava o fio branco-cinza); o giro e os finalizadores são uma fita que varre
  (`crescent.gdshader`: `CRESCENT_SPIN` 300 graus, finalizador `CRESCENT_ARC` 120 a 180, cabeça 0,35 m e cauda 0,08 m,
  fio só no terço da cabeça, a cauda some primeiro); o brilho do finalizador é estrela de 6 pontas desiguais girada por
  golpe, sem cruz nem risco longo (`glint.gdshader` `seed`, `spike_min_m` 0,18, `spike_max_m` 0,42); a estocada é uma
  lâmina (`emeth_thrust.gdshader`: base a ponta 1,0 a 0,15 de `blade_share` 0,4 da largura do golpe, inteira lia como
  folha verde; fio de 2 px, miolo `core_light` 0,12, miolo escuro, tinta 0,4, entra em `THRUST_IN`
  0,06 s e sai em `THRUST_OUT` 0,15; Ômega com os veios e `THRUST_SPIKES` 5 lascas de cristal na ponta); o estalo no
  contato (`Fx.contact`, `contact.gdshader`: 5 a 7 espinhos desiguais, metade num leque de 70 graus para onde a lâmina
  foi, miolo marfim 0,12 m, 0,05 s crescendo a 1,25; orçamento próprio `contacts` de 8 por quadro), chamado no
  `Combat._draw_hit`.
- **V-16, foice e Ceifa**: `boss_scythe.gdshader` premul sob 226: borda roída por ruído (0,15 m em 0,4 m), aro e cabeça
  no violeta, lilás-marfim só no meio do setor, o `edge` espectral não é mais desenhado; `SCYTHE_WISPS` 7 fiapos violeta
  escuro saindo do alcance.
- **Também (fila do HB)**: a linha de tinta ligada por padrão (`PaintPass.INK_DEFAULT_ON`) e fora das figuras: o
  Forward+ marca instância que se mexe no alfa do `normal_roughness` (acima de 0,5) e nenhuma borda que toque uma é
  pintada (`needs_normal_roughness`, `mask` no `paint_pass.glsl`; `--ink-debug` mostra a marca); com 12 inimigos o
  contorno não dobra e não cruza as barras (`docs/gallery/hb/ink_crowd/near_*_masked.png`). HB3: herói no estilizado com
  a pintura `saturation` 1,8 (`hero_paint.gdshader`) e a Emeth com teto pelo maior canal e cristal mais saturado
  (`emeth.gdshader` `style_back`/`style_face`, `EmethSword.STYLE_CORE`): verde na caixa do herói 0,61% para 1,00% na GPU,
  matiz 130 (`docs/gallery/hb/hb3_*`). `chain_weight` refeito (elos a 90 graus, catenária, contrapeso de 0,7 m).
- **Corpo da multidão um quarto mais escuro no estilizado** (Game Director: no calcário do Santuário o osso lia tão claro
  quanto a laje): `crowd.gdshader` `style_light` 0,15, `style_scene` 0,075, `style_rim` 0,14, `style_hero` 0,15 (eram 0,2 /
  0,1 / 0,18 / 0,2); ouro das elites, "vai bater" e pisca iguais. Osso do esqueleto no Santuário A (RTX 1080, semente 5,
  `--arena=sanctuary --hero-at=-12,-9.5`, 4 s) p50 85 para 74 contra o chão 96 a 108 (22 a 34 abaixo, meta 25).
- Medido no fim (RTX 1080, estilizado, semente 5, `docs/gallery/vfx_pass/`): orbes p99 180 a 185, nenhum pixel acima de
  210, matiz 313 (a cor do feiticeiro do `make_data.gd`; a spec pede 320 a 355); fita do giro matiz p50 135, p99 226;
  estalo do contato até 225; foice e Ceifa matiz p50 250 a 254, sem ciano no setor. Sonda de sensação 41/41.

## Passe de VFX, correções do Lote 1 e Lote 2, parte do technical-artist (2026-11-20; revisão `docs/gallery/vfx_pass/ART_REVIEW.md`, capturas `fix_*` e `l2_*`)
- **P1 da revisão**: estalo do contato (`contact.gdshader`) com miolo em estrela dura de 5 pontas (`heart_m` 0,12, não o
  disco macio), 6 ou 7 espinhos com os do leque espalhados por ele, todos encolhendo juntos para o menor no fim (nunca um
  par sobrando em cruz), teto `Fx.CONTACT_SCREEN` 210: na caixa de 80 x 80 sobre Morvath maior canal 209, branco 0%. O
  traço branco vertical era o talho (`impact.gdshader`, `Fx.gash`) somado e visto de ponta: agora premul sob
  `ScreenTone.linear_peak` a `GASH_SCREEN` 210 e `pale` 0,35 (branco nos quadros da multidão 6,7% para até 0,03%). Aro do
  brilho do finalizador (`glint.gdshader`) não se desenha sobre o corpo do herói (a estrela fica com `over_body`). Lascas
  de luz do herói (`Fx.hero_burst(&"light")`) saem baixas e caem (`HERO_LIGHT_TOP` 0,9, nunca acima de `HERO_SHOULDER`
  1,9 m; o atordoar do combo também passa por ele). Morvath no estilizado pisca no próprio violeta (`own_flash` no
  `crowd.gdshader` pelo `style_vivid`, teto `style_boss_flash_cap` 0,5, sem o quadro marfim). P2: anel da explosão do
  corredor mais largo e com meio escuro (`band` 0,3, `middle_dark` 0,5, `rim_light` 0,8), foice com o lilás-marfim no
  miolo (`pale_light` 0,55) e fiapos deitados, fita do herói mais saturada no estilizado (`style_edge_pale` 0,3,
  `style_core_sat` 0,65), virote capturado (`fix_bolt.png`: agulha escura de ponta carmim).
- **5.3, formas das famílias**: `family_mark.gdshader` (`Fx.family_mark(família, ponto, raio, cor, tempo, rumo, arco)`,
  pool `MARK_POOL` 12, orçamento `marks`): Chama línguas de fogo sobre um anel chamuscado, Geada placas hexagonais que se
  espalham e racham, Luz um aro fino desenhado a partir do lado do herói com 8 marcas e fio de ouro, Vigília três arcos
  segmentados que se abrem. `Fx.family_of(cor)` acha a família pela cor (`Combat.FIRE`... e `Boon.FAMILY_COLOR`);
  `Fx.family_hit` no acerto (`Combat._draw_hit`): línguas, farpas de gelo, raio fino com o aro da Luz, grito da
  Vigília. Lascas com forma (`chip.gdshader`, `shape` em `MODEL_MATRIX[1].z`: lente, farpa, língua; `Fx.SHAPE_*`). Cortes
  (`slash.gdshader` `family`): Chama cauda em línguas (e 3 a 5 línguas soltas), Geada farpas na borda, Luz fio mais fino
  e longo, Vigília três traços partidos. `Skills`: NOVA, CONSECRATE e o pouso pelo `family_mark` (sem anel cheio nem
  explosões redondas), STRIKES da Luz um raio fino (`STRIKE_RAY` 0,08 m) e das outras famílias lascas caindo de 7 m,
  orbe de fogo uma brasa alongada com fumaça (sem halo nem `CPUParticles3D`). Corpo congelado com casca facetada
  (`frost_cell` 0,16 m, juntas `frost_seam`). Bênção e Salmo tomados sem coluna: a forma da família no chão em volta dele.
- **V-06**: onda do especial com corpo 0,75 e borda 0,5 (`WAVE_BODY_LIGHT`, `WAVE_EDGE_PALE`), rastro de lascas de
  cristal a cada 0,6 m (`Projectiles._trail`, `WAKE_CHIP*`), acerto = o estalo V-05 com pontas de ouro velho e a forma da
  família (sai a estrela furada `SPECIAL_STAR`). **V-07**: o círculo de luz lança com o aro da Luz e 5 lascas caindo no
  aro (`Fx.circle_cast`), o Ômega explode em 10 espinhos de cristal do aro para dentro (`Fx.circle_burst`); o aro do chão
  a `circle_rim` 0,62 (ia a 233 a 235). **V-13**: `EnemyFx.PALE` marfim-avermelhado (1,05; 0,78; 0,74); o brilho da
  lâmina do esqueleto é um traço que corre a lâmina com um ponto quente na ponta (`GLINT_LINE`, `GLINT_RUN`), sem
  estrela; o orbe do feiticeiro escuro por dentro com a cor no aro. **V-14**: a morte arde em brasa suja
  (`dissolve_color` (0,35; 0,07; 0,06)) e solta um fiapo cinza (`Fx.DEATH_ASH`); as lascas de osso já eram cinza-osso.
  **V-15**: elite surgindo e caindo (horda) com anel de fumaça que se fecha e borda de ouro apagado (`Fx.elite_surge`,
  `smoke_ring.gdshader` `closing`), sem coluna. **V-17**: meias-luas de Morvath premul sob 215, borda roída, corpo
  escuro, lilás só no terço do meio, três caudas de fumaça e giro de 15 graus/s (`Projectiles.SOUL_*`; o rastro aditivo
  `boss_wake` escondido). **V-18**: erupções em lilás-marfim (`eruption_color`) sob `eruption_cap` 0,62.
  **V-09**: Corte do Juízo sem a faixa verde chapada (`ult_rift.gdshader` `breath` 0, as duas bordas em fio
  marfim-menta), 10 espinhos de cristal em duas fileiras saindo da fenda em 0,12 s e quebrando em lascas
  (`Fx.crystal_spike`, `crystal_spike.gdshader`, `Ultimates.CLEAVE_*`; espalhamento por hash, nunca o sorteio da partida),
  acerto pelo estalo pesado. **V-10**: Voragem com véu 0,15 puxado para o amarelo da Emeth, chão escurecido (`ink`
  0,35) e braços partidos em lascas (`dash_m`). **5.7**: número entra a 1,3 e volta a 1,0 em 0,08 s (`Fx.NUMBER_POP`).
- Falta: as lascas de ouro velho das elites ao morrer (uma linha no `horde.gd`, gameplay-engineer). V-08 e as capturas
  saíram no AP-2 (abaixo).

## AP-2 "Combate que se lê", parte do technical-artist (2026-11-21; backlog A6; capturas em `docs/gallery/ap2/`, testes em `tests/test_ap2_read.gd`)
- **ART-05.2, menos vermelho na fase 3**: o vermelho das erupções segue o regime dos avisos comuns
  (`ritual_rune.gdshader`: `fill_early` 0,12 da cor enquanto o golpe está longe, inteira só nos últimos `fill_late` 30%;
  `red_after` 0,2 s depois do pouso some; teto `danger_alpha` 0,24 igual) e o preenchimento dos avisos assinados de
  Morvath também (`ground.gdshaderinc`: `sign_early` 0,3, `sign_level()`, no traço, no arco e no círculo; aro, fio
  violeta e runas inteiros desde o primeiro quadro). Raio, tempo e dano iguais.
- **ART-05.4, foice que abre em volta do herói**: `boss_scythe.gdshader` com `hero_pos`, `hero_hole` (0,7; 1,5) m e
  `hero_keep` 0,3: preenchimento e miolo pálido caem a 0,3 em volta dele; aro e fio da lâmina nunca.
- **ART-05.3**: herói atrás de Morvath conferido na GPU (o raio-x do ciclo 8 já o mostra inteiro com o anel; sem mudança).
- **P2-C19a, corredor elite**: o aro fino do primeiro estouro (`land_quick`) para em `thin_reach` 0,62 do anel
  (`smoke_ring.gdshader`), dentro do aro do segundo aviso, que fica à vista até a segunda explosão.
- **V-08, esquiva e Retorno**: na esquiva o `Fx` (`_animate_ghosts`) deixa até 4 silhuetas de tinta do herói, uma a cada
  `GHOST_EVERY` 0,05 s, cada uma `GHOST_TIME` 0,12 s (`dodge_ghost.gdshader`: tinta do corte, alfa 0,25 a 0,1, fio
  marfim só nas bordas viradas para cima; pose assada por `bake_mesh_from_current_skeleton_pose`, pool de 8; nada sem
  tela). Retorno do Corte: um fio esmeralda fino com um nó que corre a lâmina enquanto a janela de 1 s está aberta
  (`emeth.gdshader` `return_thread`, `EmethSword.set_return(lâmina, k)`, lido do `Combat._return_t` no
  `Fx._animate_return`; no estilizado sob o `style_cap`); `tools/rj1_lab.gd -- --return=1` mostra a lâmina com ele.
- Casca da Geada com juntas mais finas e fracas (`crowd.gdshader` `frost_seam` (0,22; 0,36; 0,46), `frost_seam_from`
  0,455; a 720 lia como rede branca). Capturas das quatro famílias e do Cavaleiro se erguendo na sala em `docs/gallery/ap2/`.
- **ART-05.5** (entrada de Morvath mais lida) depende do tempo da entrada no `boss.gd`: fica para o gameplay-engineer e
  o combat-feel-director. `chain_weight` do `EdgeKit` já refeito (2026-11-20), espera a nova revisão do art-director.

## AP-4, esboço em traço dos inimigos e motivos dos Dons (technical-artist, 2026-11-21; spec `docs/art/ap4_spec.md` 2.1 a 2.3; testes em `tests/test_figure_sketch.gd`, `tests/test_talent_motif.gd`)
- `FigureSketch` (`scripts/render/figure_sketch.gd`): o inimigo do Compêndio desenhado a tinta no papel do Livro a partir
  do próprio modelo assado (sem IA), em três passes sobre a página, vazados entre as linhas: só profundidade
  (`figure_sketch.gdshader`, o corpo de perto esconde o de trás), contorno (`figure_sketch_edge.gdshader`, o corpo
  inflado `EDGE_WIDTH` 0,025 m e desenhado por trás) e as linhas de dentro (`figure_sketch_ink.gdshader`: dobras onde a
  superfície vira, hachura na sombra de uma luz fixa do alto à esquerda, uma camada abaixo de `shade_one` 0,5 e outra
  cruzando abaixo de `shade_two` 0,26, a `HATCH_PX` 5 px a 1080, nunca abaixo de `HATCH_MIN` 3; o corpo é o papel tingido
  `fill` 0,26 de um cinza da tinta (`wash_ink`, neutro: o papel escurece sem amarelar); aguada `wash` onde a pintura do modelo é escura; as células que brilham no jogo, olhos e gemas,
  `BakedModel.glow_from`, viram aguada de tinta `glow_ink` 0,5, então a caveira tem órbitas). Elites (`EnemyDef.gild`): o aço
  (a máscara do `crowd.gdshader`, o resto a `gilt_rest` 0,45) numa aguada do ouro do Livro (`Book.GILT`, `gilt_alpha` 0,55); as linhas com a tinta do Livro a no máximo `INK_SAT` 0,32 de saturação, para só o ouro ler como ouro com a hachura por cima.
  Hachura leve no osso claro virado da luz (`bone_from`, `bone_shade`, `bone_alpha` 0,4: a caveira não fica papel em
  branco sobre o corpo hachurado). Vista de 3/4 (`VIEW_YAW` 30 graus para o lado em que a arma fica mais comprida na
  tela, `FigureSketch.yaw(modelo)`: o esqueleto e o Cavaleiro a -30; câmera ortográfica inclinada `PITCH` 12), a pose do `idle`
  que mostra a arma mais comprida na tela (`pose_time`, partes `WEAPONS` do assado), enquadrada pela caixa de todas as
  poses do clipe com `MARGIN` 4% (`fit`, `clip_box`). Sob os pés, sem sombra redonda (`CrowdRenderer.ground_shade`
  falso), quatro traços de tinta de 1 px a 1080 e alfa 0,5 por `GROUND_SPAN` 0,7 da largura dos pés, o mais longo sob o
  pé de apoio (`figure_sketch_ground.gdshader`, `ground`). Para o ui-ux-designer, no `FigureView`, depois do
  `register(def)`: `FigureSketch.apply(renderer, def, Book.INK, altura da vista em px)`, `FigureSketch.fit(câmera, def,
  modelo, &"idle", aspecto)` e o `add_kind` em `pose_time` com `FigureSketch.yaw(modelo)`. Prancha: `tools/sketch_lab.gd`
  (comando no topo), `docs/gallery/ap4/sketch_enemies_*`.
- `TalentMotif` (`scripts/ui/talent_motif.gd`): o motivo pintado de cada um dos 19 Dons, o glifo do `TalentGlyph` vestido
  numa receita só: até três tons por forma de borda dura (base na cor do ramo levada ao papel, saturação até `SAT_MAX`
  0,58; sombra `SHADE` 0,62 embaixo à direita; luz `LIGHT` 1,22 com canal até 0,9 em cima à esquerda), fio de ouro gravado
  na borda iluminada da forma principal, contorno de tinta de 1,5 a 3 px pelo raio, detalhe de dentro só de `DETAIL_FROM`
  22 px; esmeralda só no ramo da Emeth, no quarto corte e no Coração da Emeth. `TalentMotif.draw(ci, id, centro, raio,
  HeroLoadout.State.X)` (trancado a 0,35 com o contorno, selado 0,6, bloqueado acinzentado); abaixo de `LOD_UNDER` 14 px
  desenha o glifo em tinta; falso sem motivo. Formas em `shapes(id)` (polígonos no círculo unitário). Ligar no
  `TalentNode` e no detalhe do Compêndio é do ui-ux-designer. Medidas: `tools/motif_sheet.gd` (sem tela: pares de
  silhuetas por interseção sobre união a raio 16, a maior 0,64; cor, saturação e matiz contra o ramo, todos a 0 graus;
  contorno sobre o nó 4,2:1; trancado 48 de luma abaixo do fundo; com `--png=` a prancha dos 5 estados a raio 16 e 32,
  `--big` todos a raio 80).
- Aro dos medalhões desenhados (2.3): `BoonIcon.ring(ci, centro, raio de fora, largura)` com o perfil do aro dos PNG
  pintados (`RING_BANDS`, medido no `vapor.png`: borda escura, bronze, sulco, filete claro, bronze, sulco, faixa baça e a
  sombra para dentro), `RING_PX` 12,2 px na carta (a largura do aro pintado a 128 px) e `RING_SHARE` 0,12 do tamanho nos
  pequenos; usado pelo `BoonIcon` (Bênçãos sem PNG e Elos) e pelo `PsalmIcon` por cima do selo.


## Lote 4 (2026-11-21): golpe em meia-lua branca e dourada, contorno de tinta (SR-G4, SR-G5)
- `Fx.crescent` (giro e finalizadores): faixa mais larga (`CRESCENT_INNER` 0,6, cabeça `CRESCENT_HEAD`, cauda `CRESCENT_TAIL`),
  arco 140 a 200 graus, cresce a 1,5x (`CRESCENT_GROW`), cor 60% rumo ao dourado (`CRESCENT_GOLD`) e borda quase branca
  (`CRESCENT_PALE`). Corte comum (`Fx.slash`): cauda 0,8 e 170 graus (`SLASH_TAIL*`), núcleo mais fundo e claro
  (`SLASH_CORE`), 45% dourado (`SLASH_GOLD`); só no golpe sem família (as famílias de dom mantêm a cor delas).
- Pisca do inimigo atingido: no estilizado `crowd.gdshader` usa `hit_warm` (vermelho-laranja), `hit_gold` (primeiro quadro
  de golpe forte) e `hit_floor` 0,2, abaixo do `flash_cap`; o pisca do clássico, o aviso de golpe e o de Morvath não mudam.
- Contorno de tinta: experimento desligado. `--ink` (ou `--ink=N`; `--outline` é a borda do raio-x) multiplica por `HeroBody.INK_THICK` (2,5) a
  casca de contorno do herói e dos inimigos (`HeroBody.ink_scale`); sem custo de draw call novo (só a espessura da casca).
  Não medido em fps (precisa de GPU).

## Mira dos atiradores mais discreta (2026-11-21, fim do dia)
`GroundLook.AIM_PX` 4,5 (era 6) e `AIM_LIGHT` 0,38 (era 0,5): as duas linhas vermelhas que cruzavam a tela inteira
ficam finas e escuras, a ponta brilhante continua. Cabo da foice de Morvath mais fino (`tools/bake.gd`, 0,03 por
0,034; lia como barra branca), reassado.
