# Efeitos, personagens e shaders de combate

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Ciclo LC, preparação dos atiradores (LC-1 a LC-3; evidências em `docs/gallery/lc/windup/`)
- Só desenho, sem mudar tempo, alcance, dano nem duração de clipe. As luzes da preparação (`EnemyFx`) ficam onde a
  pose desenhada tem a peça: `BakedModel.point(nome, clipe, t)` (média dos vértices da peça na mistura de duas poses,
  lida uma vez por clipe), com os nomes do assado em `parts` (`crossbow`) ou em `marks` (`orb` dos cajados, `hands`,
  `hand_l`, `hand_r` do sacerdote, por `"marks"` do `tools/bake.gd`, vértices presos àqueles ossos); `Horde.render`
  passa o modelo, o clipe e o tempo para `EnemyFx.tell` e `loosed` (`EnemyFx.spot`; sem modelo cai no `tell_at`).
- **Besteiro**: besta a 0,62 com o arco claro (`CROSSBOW_PAINT`, ferro gasto `blade`); na mira (LC-1b) a besta é um ícone
  desenhado no plano da tela, apontando para onde a mira aponta na tela (nunca encurtado pela inclinação da câmera):
  coronha `CROSSBOW_STOCK` 1,0 m, os dois braços do arco `CROSSBOW_ARM` 0,62 m varridos `CROSSBOW_SWEEP` 0,3 rad e a corda
  reta entre as pontas, em traços duros (`Shape.BAR`) com tinta escura em volta (`Shape.INK`, `INK_EDGE`, `INK_ALPHA`
  0,6), cerca de 70 px a 1080 (eram 30 a 40); a ponta que brilha antes do tiro (`TIP_GLINT`) e a linha de mira que desce
  da ponta até o fio do aviso no chão, `SIGHT` 3,4 m à frente dos pés (`_stroke`): quem mira ligado a por onde o virote
  passa. Tudo por cima do próprio corpo (`enemy_tell_over.gdshader`, agora `blend_premul_alpha` com `#define PREMUL`:
  as luzes somam como antes, a tinta escurece); traços no teto da tela (`EnemyFx.lit`: `ScreenTone.fit` linear vezes
  `STROKE_ROOM` 0,9, cerca de 220 de 255).
- **Feiticeiro**: no topo do cajado um miolo que cresce de `ORB_CORE` 0,16 a `ORB_CORE_FULL` 0,42 m e anéis que se fecham
  nele (`ORB_GATHER` 1,1 m, `ORB_RINGS` 2), as centelhas entrando; nada acima do limiar do glow.
- **Sacerdote**: o rito é os dois braços abertos para cima em V (`cast` = `Cheer` do KayKit de 0 a 0,84 s em 0,8 s,
  `RITE_BEND`: o tronco e a cabeça jogados para trás), a chama sobre as mãos (`RITUAL_FLAME`, `RITUAL_LIFT`), o anel no
  chão como antes e um fio da chama ao anel na espera (`RITUAL_THREAD`). LC-3b: o V dos braços desenhado em luz da magia
  com tinta em volta, do peito (`RITUAL_NECK` 0,6 da altura) às palmas, no plano da tela e por cima do corpo; visto de
  lado ou de costas ele abre até `RITUAL_SPREAD` 0,8 m de largura e `RITUAL_RAISE` 0,45 m acima do peito, então lê igual
  de qualquer lado; a luz de cada palma (`RITUAL_PALM`) e a chama também por cima.
- Medido (LC-1b e LC-3b, RTX a 1920 x 1080, estilizado, câmera do jogo, `--stress=6 --stress-ids=archer,mage,priest
  --seed=5 --hero-at=0,0`, quadros a cada 0,1 s): besta de luz do besteiro de 35 x 18 px (a cruz fina) para 64 a 70 x 67 a
  69 px, traços em luma p50 217 a 219 (antes 228 a 241, até 255); sacerdote de costas no meio de outros
  (`--seed=7 --hero-at=0,-6`): antes só uma palma à vista, depois o V inteiro com cerca de 80 px de largura e pixels
  violeta na caixa da cabeça de 1708 para 2085; o quadro inteiro igual (luma p50 57, matiz 216 a 218). Ferramenta:
  `tools/enemy_lab.gd ... --spin` (a fileira gira, cada figura vista de um lado). Evidências em
  `docs/gallery/lc/windup/after2/` (tiras antes e depois, vídeos em velocidade real lado a lado, clássico e Compatibility).
- O que é desenhado por cima (`EnemyFx.OVER_PRIORITY` 11) sai depois das barras de vida (`CrowdRenderer.BAR_PRIORITY`
  10): na multidão as barras de quem está na frente cobriam o V do Sacerdote e a besta.
- Testes em `tests/test_enemy_fx.gd` e `tests/test_indicators.gd`. Pendência conhecida do assado: dobra (`bend`) em osso
  que o rig do KayKit não move (`Spine01`, `neck`) se acumula pose após pose; o rugido de Morvath (`ROAR_BEND` no
  `Taunt_Longer`) provavelmente tem isso (medir antes de reassar Morvath).

## Ciclo LC, Compatibility (LC-4 e LC-5, só no estilizado do Compatibility; antes e depois em `docs/gallery/lc/compat/`)
- Causa: no Compatibility a luz chega à tela sem o passo de linear para sRGB do desktop (uma rampa de emissão v sai como
  cerca de v^2,2 da do Forward+). O corpo estilizado é feito de luz bem abaixo de 1 (`style_light`, `style_scene`) e ia ao
  preto dentro do contorno; um vermelho somado ao chão pintado (que lá é mais claro e frio) lia rosa pálido.
- **Figuras (LC-4)**: só nesse renderizador a luz da figura estilizada sobe a `CrowdRenderer.COMPAT_GAMMA` 0,55 pela
  luminância, mantendo matiz e saturação (`style_gamma` no `crowd.gdshader`, `figure_gamma` no
  `figure_paint.gdshaderinc`); o herói igual (`HeroBody.COMPAT_GAMMA`, `gamma` no `hero_paint.gdshader`: albedo, cada luz
  e a luz própria). O contorno fica como estava (subido, virava halo cinza). 0,55 casa a luma das figuras do
  `tools/enemy_lab.gd` com a do Forward+ (1/2,2 passava um terço). Santuário: fachos e chave da nave a
  `SanctuaryLook.STY_COMPAT_SHAFT` 0,25 no Compatibility.
- **Avisos (LC-5)**: só nesse renderizador, no estilizado, todo aviso (style 0) soma `GroundLook.COMPAT_GAIN` 1,1 da luz e
  a segunda passada escurece o chão sob a área a 1 - `COMPAT_UNDER` 0,3, também nos avisos assinados de Morvath (a
  Tempestade), devolvendo o vermelho da primeira passada por cima; os assinados somam `style_compat_warn` (1; 0,13; 0,1)
  (`ground.gdshaderinc`: `style_compat_gain`, `style_compat_under`, `style_compat_warn`; a mira do besteiro e o bote não
  escurecem). Padrões neutros: Forward+ e todo o clássico iguais (capturas Forward+ antes e depois diferem só em chamas e
  partículas; teste em `tests/test_stylized_figures.gd`).
- Medido (1920 x 1080, RTX; `tools/frame_stats.py --hue`): Tempestade aos 6,25 s, caixa 1300,470,150,40: vermelho na faixa
  69,5% para 100% (Forward+ 99,8%), saturação 0,42 para 0,64 (0,63), matiz 354 para 359 (358), luma 112 para 119 (117);
  na preparação (4,0 s, caixa 900,690,60,60) 43% para 97% (92%), saturação 0,33 para 0,57 (0,57); no começo do aviso
  (3,5 s) 11% para 22% (40%), a faixa já mais escura que o chão (luma 87 contra 106 fora). Santuário A aos 9 s: laje no
  facho 145 para 116 (Forward+ 88), cena p50 77 para 66 (63); esqueleto ao lado do herói p10 1 para 21 e p50 42 para 82
  (Forward+ 33 e 87). iGPU Intel pelo D3D12 do WSL (`MESA_D3D12_DEFAULT_ADAPTER_NAME=Intel GALLIUM_DRIVER=d3d12`,
  `xvfb-run`, opengl3, 1280 x 720 Baixa; o OpenGL do Windows escolhe a NVIDIA): Santuário 27,7 / 25,8 ms antes e
  24,8 / 23,9 depois, Tempestade 34,4 / 32,9 e 31,0 / 34,2 (nada perdido). Pendências: o chão pintado do Compatibility
  segue mais claro que o do Forward+ em todas as salas (Cripta, Santuário: é do `paint.gdshaderinc` e do ar das salas, do
  environment-artist); as erupções (`ritual_rune.gdshader`) e a Emeth seguem mais pálidas no Compatibility.
- **Runas no Compatibility (parecer de cadência 7, P1; só no estilizado do Compatibility)**: lá a laje armada não tem as
  luzes de cima (`RunesLook.ARM_LIGHTS` só no Forward+) e a luz própria sai sem o linear para sRGB: lia só pela moldura
  (+4 a +13 de luma, saturação 0,04). O `RunesLook.dress` põe no chão de runas, só nesse renderizador, `paint_compat_*`
  (`rune_tiles.gdshaderinc`, só no `PAINT`; padrões neutros, o chão clássico nem tem): a luz da laje vezes
  `COMPAT_GAIN` 1,6, a pedra armada `COMPAT_FILL` 0,4 a caminho do âmbar sem cinza a `COMPAT_TONE` 0,6 e com luz própria
  `COMPAT_GLOW` 0,45, as duas vezes o armar; no golpe e na brasa a mesma pedra vai ao marfim-âmbar com luz
  `COMPAT_STRIKE` 0,4 (no Forward+ o golpe é a laje inteira creme; aqui era cinza pálido que sumia em 0,1 s). Medido
  (Runas A, semente 5, estilizado, 1672 x 941, RTX; `docs/gallery/rooms_rp/cadence/*_after.png`): armada aos 3,9 s (0,75
  do aviso) luma p50 103 a 104 para 143 a 145 contra 82 a 113 das vizinhas (+30 sobre a mais clara), saturação 0,04 para
  0,40 a 0,41 (vizinhas 0,08), matiz 30; golpe (quadros a cada 33 ms, `runes_a_strike_*`) +27 para +126 sobre a vizinha
  escura, +18 para +89 e +53 a 0,07 e 0,13 s (Forward+ +125, +108, +86). Forward+ igual (777 pixels de chama e partícula
  de 1,57 milhão). iGPU Intel no Compatibility (D3D12 do WSL, 1280 x 720 Baixa): 34,8 / 35,0 ms antes, 34,0 a 36,2
  depois (GPU 27,8 contra 27,5 a 28,1). Teste em `tests/test_runes_compat.gd`.

## Lote 2B e TA-HB, parte do technical-artist (2026-11-20; evidências em `docs/gallery/lote2b/`, `docs/gallery/hb/`, `docs/gallery/c19/hurt_flash/`)
- **Ferramentas de `-s` que nomeiam classes com autoload** (`T`, `Audio`): o script de `-s` é compilado antes dos
  autoloads existirem. `tools/enemy_lab.gd`, `tools/walk_strip.gd`, `tools/rj1_lab.gd` e `tools/edge_lab.gd` são calços
  que carregam o corpo de `tools/lab/<nome>.gd` (um `Node`) em tempo de execução; ferramenta nova que monta o jogo faz
  igual. `Fx` lê o texto do ouro por `_gold_word()` (o `chamber_lab` e o `drawn_probe` voltaram a compilar).
  `walk_strip` aceita `id@modelo` (o mesmo inimigo com outro assado).
- **Golpe sofrido sem silhueta** (combat_cadence 8.3 item 4): o `flash.gdshader` somava uma cor morna chapada no corpo
  inteiro (+0,45 a +0,75 linear) e o herói virava marfim por 2 a 3 quadros nos dois looks. Agora o clarão é a própria
  pintura dele mais clara (`Player.HURT_FLASH_LIGHT` 0,45 somado ao `fill` do `HeroBody.set_fill`, o caminho do pisca) e
  o overlay só deixa uma borda morna (`flash_edge` 0,35, `flash_gain` 0,6). Medido a 60 qps (Movie Maker, 10 esqueletos
  elite, semente 5): luma da caixa do herói no pico 154 antes, 121 depois (105 em repouso), cores e rosto lidos.
- **Assado** (`tools/bake.gd`): opção `"centred"` no clipe (cada pose deslocada em x e z para o centro dos vértices ir em
  linha da origem ao da última pose; o erguer de quem levanta no lugar: esqueleto 0,23 para 0,05 m, corredor 0,18 para
  0,02, besteiro 0,14 para 0,03, sacerdote 0,26 para 0,06, Cavaleiro 0,30 para 0,14; feiticeiro, Escudo e ancião têm o
  pior na última pose, a guarda com cajado ou escudo, T5b P2-2); opção `"kick"` (`{at, up, down, bend}`: a dobra sobe em
  `up` s e volta em `down` s; o tiro do besteiro `CROSSBOW_KICK`, tronco 5 graus para trás em 0,06 s e de volta em 0,2,
  T5-19). Morvath: `curse_windup` (`OverhandThrow` 0 a 0,26 s, no lugar) armado pelo `Boss._step_curse` com o
  `Horde.windup_arm` antes do arremesso (T5-17) e `rain_wave` (`Spellcast_Raise` 0 a 0,5 s ida e volta) tocado uma vez
  por onda de erupção (`Boss._step_eruptions`, T5-18; o `rain:13` parado saiu). Assado novo `runner_elite.res`
  (`RUNNER_ELITE_JOG`, passada 1,55: 199 passos por minuto a 7,4 m/s, escorrega 4,6 cm; o comum daria 259), usado pela
  elite do corredor (`"model": &"runner_elite"` no `_pair` do `make_data.gd`).
- **Arranque, parada, finalizador e esquiva no desenho do herói (GF-15, VX-17, B-b; gameplay-engineer; testes em
  `tests/test_hero_motion_look.gd`, sonda 41/41)**: a UAL não tem clipes de arrancar e parar, então o `Player` faz por
  código: da guarda à corrida e da corrida à guarda o clipe mistura em `RunLean.BLEND` 0,1 s e o corpo inclina num pulso
  de `RunLean.TIME` 0,3 s (pico a um terço), `START_DEG` 7 graus para frente ao sair e `STOP_DEG` 5 para trás ao parar
  (`RunLean`, `core/run_lean.gd`, puro; `_model.rotation.x`, só desenho, nunca durante golpe ou esquiva). O finalizador
  (golpe com a tag `finisher`: giro, lança) segura a última pose do clipe `Player.FINISHER_HOLD` 0,3 s e só então vai à
  guarda numa mistura de `FINISHER_SETTLE` 0,3 s (antes voltava em 0,08 s); andar ou outro golpe cortam no quadro. A
  esquiva toca o `Dash` do começo e sem mistura (`_play(..., from, blend)`). Resposta ao direcional e tempos iguais.
- **`--shot-on` antes do `--shot-at`** (Q-T5-7): o `Game._shot` escuta os momentos `boss:` desde o começo; se o momento
  já passou quando o `--shot-at` chega, captura no quadro seguinte e imprime `SHOT ... came N time(s) before --shot-at`.
- **Orbes do Redemoinho** (Q-T5-6): miolo, halo e rastro abaixo do limiar do glow (`Skills.ORB_CORE`, `ORB_HALO`,
  `ORB_TRAIL`; eram 3,0 / 2,4 / 2,6 e viravam dois globos laranja estourados perto do herói).
- **Linha de tinta nas peças (TA-HB1)**: `PaintPass` com `ink` (só contorno por salto de profundidade, sem Kuwahara,
  depois dos transparentes, MSAA mantido): `INK_PX` 2, `INK_COLOR` no tom da sombra, `INK_ALPHA` 0,7, `INK_JUMP` 0,015.
  Só Forward+, estilizado, Alta e Média (na Baixa a iGPU perdia 6 qps), **desligada** (`INK_DEFAULT_ON` false) até o
  art-director aprovar; `--ink-line=1` liga. Custo na RTX a 1080: GPU 2,37 para 2,41 ms.
- **Kit de borda e primeiro plano (TA-HB2)**: `EdgeKit` (`scripts/game/edge_kit.gd`, `EdgeKit.new(kit)` sobre o
  `ArenaKit` da sala): `broken_pillar`, `broken_arch`, `rubble`, `root_curtain`, `ivy`, `chain_weight`; nada colide; tudo
  abre em pontilhado em volta do herói e de Morvath (`see_through`); pedra = a cantaria da sala com `see_through` (pintada
  pelo `paint_look`), raiz, hera e ferro um material cada (`edge_piece.gdshader`, gêmeo `edge_piece_paint.gdshader` pelo
  `VisualProfile`). Triângulos e chamadas por peça em `docs/art/asset_inventory.md`; tabuleiro `tools/edge_lab.gd`.
- **Hub, BH-07 (luz por estação)**: no estilizado o pátio um degrau mais escuro (`HubLook.STY_AMBIENT_GAIN` 0,8, lua
  `STY_MOON` 0,45, preenchimento a `STY_KEY_SHARE` 0,45) e cada estação com poça própria de luz morna vinda do alto
  (`STY_POOLS`: estação, mira, origem, energia, cone, alcance, cor; `_station_pools` monta os `SpotLight3D` difusos,
  `light_specular` 0, sem sombra, `cull_mask` sem a multidão, meta `NOT_FIRE`, num nó só do estilizado): Forja entre a
  boca do forno e a bigorna (fogo do forno a `STY_FORGE_GAIN` 1,5), Livro com uma luz de leitura estreita no atril e
  uma larga no tapete, Vendedor no balcão, Árvore no estrado, e uma poça verde-pálida no pé da escada do portal (na
  chegada a câmera segura o portal fora do quadro: a poça no alto da tela aponta o caminho). Medido (RTX 1080, luma p50
  do chão de uso contra a praça, antes / depois): Forja 153/78 = 1,96 para 166/52 = 3,2; Livro 121/79 = 1,53 para
  109/53 = 2,06; Vendedor 111/61 = 1,82; Árvore 145/46 = 3,2 (meta 1,8). Cena luma p50 80 para 54 a 56, saturação 0,23
  para 0,25 a 0,26. O ENV-HB6 completo (meio 90 ou mais, bordas até 0,35 do meio, saturação 0,30) não foi atingido:
  pede escurecer as bordas do pátio a um terço do meio, o que briga com a spec do hub (4.2, o chão mais claro do jogo);
  fica para o Game Director decidir. `tools/hub_walk.gd` (ferramenta de arte) anda o herói da chegada até uma estação
  pelo `VirtualPad` e grava quadros (`--walk-to`, `--walk-frames`, `--walk-every`, `--walk-count`, `--walk-wait`;
  comando no topo). Testes: `test_room_style` 43/43, `test_hub*` 54/54; fit_probe do hub igual (6,09 / 7,18).

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

## Combate C1: leitura na tela (2026-11-22, código; sem captura ainda)
Especificação em `docs/art/combate_c1_leitura.md`; só desenho e som, a simulação e o `RESULT` não mudam.
- **Brado que absorve** (`Player._show`): anel dos pés e brilho do corpo em esmeralda enquanto `gifts.ward > 0`, pisca a 4 Hz no último 1,0 s; ao absorver, `fx.ring` fino, 10 `chips` e `blade_pulse` (o `burst(&"heal")` rosa saiu). O ponto do selo do Q no HUD ficou para o `ui-ux-designer`.
- **Faixa que rastreia e "travou"** (`Ground.track_line`, `Ground.lock_line`, `GroundLook.tracking/lock_pulse`): enquanto segue, fio fino (linha 0,7; mira 0,30 e 3,5 px, sem enchimento); na trava um pulso de 0,07 s e o enchimento começa. Esqueleto, Cavaleiro (só se o rastreio ocorreu, a 5 m ou mais) e a 2ª flecha do besteiro. Som `lock_click` 0,02 s depois (+3 dB, passa pelo `VoiceGate`). O brilho da lâmina e o traço do escudo terminam na trava (`EnemyFx.lock_at`).
- **Escudo** (`Horde.guard_up`, lida por `blocks_front` e pelo desenho): cinco traços de aço (`EnemyFx.STEEL`) em arco à frente (`guard_marks`), voam ao abrir (`guard_fling`) e voltam um a um no último 1,0 s; clipes `walk_open` e `idle_open` só no `guard.res` (`SHIELD_CLOSED` -24, `SHIELD_OPEN` 38 em `tools/bake.gd`; troca por `Horde.render` com fade de 0,12 s). Golpe barrado: faíscas de aço (5), número cinza, traço do meio a 0,8, sem squash.
- **Sacerdote** (`Horde._draw_ward_threads`, `EnemyFx.ward_thread`): fio ouro velho da palma ao peito do blindado (até 6) com uma conta que corre; o blindado pulsa em ouro (`WARDED_GLOW`, 1,2 Hz) pelo `state.r`; anel ao blindar em ouro velho 0,35 s.
- **Corredor como pavio** (`Horde.render`, `dying`): brasa e beirada crescendo (`state.b`), tremor e inchaço até `death_burst`, dissolve só depois; a explosão (`Ground.add_ember_warning`) pousa em cinza de brasa com `burst(&"fire")` e 8 `chips` de osso, e com mais de 3 círculos o preenchimento cai a 60%.
- Besteiro: `magic_color` laranja (`CROSSBOW_ORANGE` em `tools/make_data.gd`), nunca o vermelho do aviso.

## N2 (2026-11-23, `docs/art/identidade_c1v.md` 2.3): efeitos de combate memoráveis (só desenho, `RESULT` igual)
- **Quebra**: `EnemyFx.armor_break` com `POISE_BREAK` solta, além das lascas, um anel marfim partido em 6 arcos (`Shape.ARC`, forma 6 do
  `enemy_tell.gdshaderinc`: anel cortado em ±0,42 rad) que se abre de 0,5 a 1,6 vezes o corpo em 0,25 s e some. A palavra "Quebrou!" cai para 15 px
  (`Fx.POISE_WORD_SIZE`, escolhida pelo texto de `word_poise`). Marfim sob o teto (`toned(lit(...), 0,8)`).
- **Golpe final**: `Fx.crescent` (só arcos, não o giro) ganha uma segunda meia-lua (`_crescent_echo`): 20% maior, só fio de ouro (sem corpo nem tinta), cabeça
  mais lenta (varredura x1,35, que faz o atraso). Pool de meias-luas 6 para 8.
- **Pó de osso**: a morte de morto-vivo (`burst(&"bone")`) solta mais 2 fiapos pálidos (`BONE_DUST`, luma baixa), largos e lentos, depois da cinza.
- **Esquiva**: `dodge_ghost.gdshader` em azul-petróleo pálido com pinceladas por altura (`brush`); `player.gd` e `fx.gd` da esquiva intocados.
- Não feito: sulco escuro no chão do golpe final, marca de tinta do impacto pesado, mancha de pó no chão (pedem decalque) e todo o 2.2 (contraste das figuras,
  pede medida em captura). Teste novo: `test_poise_break_draws_six_arcs`.

## Escudo do Cavaleiro de verdade (2026-11-23, `scripts/render/thrown_shield.gd`, `tests/test_thrown_shield.gd`; sem captura ainda)
- **Some da mão enquanto está longe**: o escudo do `knight.res` é uma peça presa (`parts["shield"]`) e fica numa faixa contígua no fim da malha (vértices 5481 a 6435), então não foi preciso reassar. `CrowdRenderer.register` grava `hide_from`/`hide_to` nos dois materiais (corpo e contorno); `CrowdRenderer.state(..., away)` põe alfa -1 no estado do instante (vivo não tem dissolver) e `crowd_pose.gdshaderinc` (`crowd_away`) colapsa a faixa num ponto (triângulos sem área). `Horde.render` liga o sinal com `d.throw_flight > 0 and shield_away(e)`, então o Guarda e os demais não mudam; ao voltar à mão (`away_t` zera) o escudo reaparece. Sem malha nova, sem textura, sem custo de pacote.
- **Escudo no ar e no chão**: `ThrownShield.build` recorta do mesmo `BakedModel.mesh` os triângulos do escudo (cerca de 750, UV e normais do modelo, pintura do atlas dele), centra, deita com a face (o lado do botão) para cima; `C1eMarks` o gira no arco (`flight_basis`: giro de 15 rad/s no eixo vertical, inclinado até pousar chato) e o deixa deitado em `Enemy.shield_lies` até `away_t` acabar. Material `StandardMaterial3D` com o atlas e 0,35 de autoluz. Se o modelo não tiver o escudo, volta ao aro de aço antigo.
- Aquecimento (`tools/make_warmup.sh`): o shader do bando mudou só em código de vértice (mesmas variantes), mas o primeiro arremesso cria um `StandardMaterial3D` novo (possível engasgo único); rodar `tools/make_warmup.sh` é opcional, para incluir esse material.

## Lote E (2026-11-24): Supremo cheio no corpo e tiro 3 da Maga
- `Player._make_ult_ring`: segundo anel no chão com o shader `hero_ring` (sem shader novo), 3,1 m, âmbar `(1, 0.72, 0.22)`; pulsa 1,5 s ao encher
  (abre 1,3x e assenta) e respira leve até o uso (`Player.ult_ring_look`, testado em `tests/test_ult_ring.gd`). Som `ult_ready` (sino de duas notas, síntese em `audio.gd`).
- Tiro 3 da Maga (nó com tags `bolt` e `finisher`): `dart` a 0,62 de tom e recuo do bastão de 4 quadros e 0,1 m contra a mira (`_step_kick`).

## Passe de força nos efeitos do Guerreiro (2026-11-24; o Daniel: "os efeitos estão muito fracos")
Só visual: nenhum número de jogo mudou; `--smoke=120 --stress=300 --seed=5` dá o mesmo `RESULT` antes e depois (passo 2,91 para 2,96 ms, média 7,20 para 7,26 ms, 143 para 142 fps no CPU sem tela). Nenhum shader novo (reaproveita `ring`, `chip`, `wisp`, `slash`, `crescent`, `contact`), então o aquecimento (`warmup.gd`) não muda; a luz pontual não é material.
| Efeito (constante em `scripts/game/fx.gd`) | Antes | Depois |
|---|---|---|
| Corte 1 a 3 e giro: início da malha de luz e de tinta (`SLASH_INNER`, `INK_INNER`) | 0,12 | 0,05 (faixa mais larga) |
| Brilho do corte (`SLASH_BOOST` x `Feel.slash_intensity` 1,7) | x1,0 | x1,35 |
| Núcleo do corte (`SLASH_CORE`, fundo e luz) | 0,7 e 0,4 | 0,82 e 0,62 |
| Dourado do corte sem família (`SLASH_GOLD`), mais perto do verde da Emeth | 0,45 | 0,30 |
| Meia-lua do golpe final (`CRESCENT_INNER`, `CRESCENT_BODY`, `CRESCENT_GROW`, `CRESCENT_TIME`) | 0,6, 0,5, 1,5x, 0,30 s | 0,5, 0,65, 1,7x, 0,34 s |
| Brilho do giro (`CRESCENT_SPIN_PEAK`) | 0,36 | 0,50 |
| Clarão do acerto (`CONTACT_SPIKES`, comum / pesado, em m) | 0,25 a 0,6 / 0,4 a 0,9 | 0,4 a 0,9 / 0,6 a 1,4 |
| Clarão do acerto (`CONTACT_GROW`, `CONTACT_TIME`) | 1,25x, 0,05 s | 1,4x, 0,08 s |
| Talho no inimigo (`GASH_BOOST`, `GASH_LIFE`) | x1, x1 | x1,3 comprimento, x1,25 duração |
| Pisca do inimigo (`crowd.gdshader`: `hit_warm`, `hit_gold`, `hit_floor`) | (1,0,5,0,22), (1,0,78,0,36), 0,2 | (1,0,56,0,26), (1,0,84,0,46), 0,32 |
| Morte, `burst(&"bone")`: lascas, velocidade, tamanho, vida | 8, 5,5, 0,2, 0,6 s | 12, 6,5, 0,26, 0,7 s |
| Pó de osso da morte (`wisps`: quantidade, tamanho, vida, abertura) | 2, 0,4, 1,4 s, 1,6 | 3, 0,5, 1,5 s, 1,9 |
| Luz pontual (`hit_light`, novo): acerto pesado, final, Apogeu, Brado, Supremo | nenhuma | energia 1,8 a 4,0, alcance 4 a 9 m, 0,14 s, no máximo `LIGHT_POOL` 3 ao mesmo tempo (a mais velha cede); sem luz no Compatibility |
| `Fx.shock` (novo): anel grosso no chão, anel fino a 1,45x, 7 a 14 pedras e osso, poeira, luz | nenhum | Golpe Carregado (poder 0,6, raio 1,8 m), golpe final (1,0, 2,4 m), Apogeu (1,6, 3,3 m, `omega`), Brado (0,7, 0,8 do alcance), cada duas lajes do Supremo Corte do Juízo (1,0, 1,5 m) |
| `Fx.dash_trail` (novo): 3 fiapos de poeira e 6 lascas da cor da Emeth ao longo da Investida | nenhum | em todo golpe com tag `dash` |
Tetos: as pedras entram no `budget` de motes (40 por quadro) e na reserva de 192; poeira e osso no de rajadas (6). Teste novo `test_hit_lights_are_capped_and_fade`; `test_fx_on_hit` ajustado (o Brado e a Investida agora soltam pedras e lascas, e o final tem 3 anéis: o dele mais os dois do `shock`).
Para conferir (ver o relatório): a distorção do Brado (refração de tela) não foi feita; fica o anel duplo mais as pedras e a luz.

## Revisão de arte 2026-11-25 (AD2-01, 02, 03, 05, 06 e CF2-07; só visual)
`--smoke=120 --seed=5` dá o mesmo `RESULT` antes e depois (menos `fps` e `step_ms`). Nenhum shader novo: o aquecimento não muda. Sem captura na GPU; uma captura CPU conferiu o azul da capa (luma 123, matiz 172, saturação 0,48 com `cape_value` 0,5; baixado para 0,42 e cor mais azulada, falta confirmar na GPU).
| O quê (onde) | Antes | Depois |
|---|---|---|
| Capa do herói (`hero_paint.gdshader`: `cape_color`, `cape_value`, `cape_rim`; zona = verde da pintura, `g > r` e `b <= g`) | verde lavado, luma 131 a 158 | petróleo (0,2; 0,55; 0,64) x 0,42, o fio quente da capa a 0,55 |
| Corte do herói, só com `blade > 0` (`Fx.SLASH_STYLE_*`, `slash.gdshader`, `slash_ink.gdshader`) | `style_core_light` 0,216, `style_core_depth` 0,6, `style_veil` 0,72, sem fio acima do teto | 0,35, 0,75, 1,0, e fio da cor do golpe a 1,5 só no fio (`style_wire_glow`, teto 1,3 num canal). Inimigos e chefes (`blade` 0) ficam como eram. Nota: `style_edge_cap` já não era lido pelo shader |
| Emeth (`emeth.gdshader`, `HeroBody.EMETH_SCALE`, `EmethSword.CORE_WIDTH`) | teto 0,6, lâmina x1,0, fio fino 0,022 sob a capa | teto 0,72 (0,9 no golpe, `style_cap_swing`), lâmina x1,15 (cajado da Maga igual), fio 0,03 sem teste de profundidade (aparece por cima da capa) |
| Anéis do `shock` e do Brado (`Fx.ring(..., bright)`, `ring.gdshader` `ivory`) | `intensity` 1,5, marfim 0,4, linha de 3,5 a 8% do raio | 2,4, marfim 0,75, linha de no mínimo 0,14 m, miolo 0,3. Brado: anel fino no alcance real e eco aceso 0,08 s depois (`Fx.ring_later`), mais o par do `shock` |
| Clarão e luz em todo acerto (`Fx.contact(..., level)`, `CONTACT_LIGHT`) | luz só nos pesados | golpes 1, 2, 3: energia 1,0 / 1,4 / 1,8, alcance 3 m, 0,08 s; 4 lascas brancas de 0,15 s; o ponto é o peito do atingido, 0,15 m para o lado da lâmina (era 0,3) |
| Pó de osso da morte (`BONE_DUST_AT`) | nascia a 0,3 m do chão e subia | nasce a 1,0 m e desce de leve (-0,25) |
Testes novos em `tests/test_fx_on_hit.gd`: `test_plain_contact_lights_and_sparks_at_the_target`, `test_brado_echo_ring_comes_later`.

## Lote E1 (2026-11-25; só visual, sem captura na GPU ainda)
| Item | O quê (onde) |
|---|---|
| E1-1 | Faíscas do acerto: velocidade 5 para 2,2 m/s e vida 0,15 para 0,12 s (`CONTACT_SPARK_SPEED`, alcance no máximo 0,3 m), cor marfim-menta (`CONTACT_SPARK_TINT`), não mais branco puro. |
| E1-2 | Corte do herói (`blade > 0`): esmeralda de matiz 150 (`SLASH_EMERALD`, sem o puxão para o ouro), pico de tela 222 (`SLASH_STYLE_SCREEN`), fio de 3 px x 1,0 / 1,2 / 1,6 por golpe (`SLASH_EDGE_LEVELS`, pelo tempo pedido: 0,12 / 0,16 / 0,3), ponta a 2,9 m (`BLADE_REACH`, era 2,6), núcleo apagado a menos de 1 m do corpo (`body_clear_m` em `slash.gdshader`). |
| E1-3 | Giro (largura >= 300 graus): anel esmeralda na cintura com `SLASH_MIN_LIFE + 0,034 s` (`SPIN_RING_EXTRA`). |
| E1-4 | Rastro da Onda: faixa de no mínimo 1,4 m (`WAVE_BAND_MIN`), `Fx.thrust(..., band = true)`: ponta a 0,85 da base, miolo claro, fio esmeralda. |
| E1-5 | Largura do rastro 1,0 / 1,2 / 1,6 (item 2); a luz pontual por golpe já existia (`CONTACT_LIGHT`). |
| E1-6 | Números: pop 1,4x em 0,12 s, contorno 2 px, grandes em ouro velho (`NUMBER_BIG_COLOR`) e 29 px, espalhados de lado até 0,45 m. A altura de nascimento ficou em 1,0 m (o teste de `test_fx_on_hit` exige acima da barra). |
| E1-7 | Anel do herói sempre petróleo; o amparo do Brado acende um fio esmeralda por dentro (`inner`, `inner_color` em `hero_ring.gdshaderinc`). Regra na §2.1 do `art_direction.md`. |
| E1-8 | "!" de aviso em ouro velho (0,98; 0,76; 0,28), matiz 41, com contorno de tinta. |

## Passe de efeitos "mais fortes" (2026-11-25, technical-artist; só desenho, `RESULT` do `smoke.sh 900 --seed=5` igual)
- **Texturas pintadas por código** (`tools/make_fx_textures.gd` → `assets/textures/fx/`): estrelas de 4 e 6 pontas, flipbook de
  poeira de osso (8 quadros), riscos de pincel. Registro em `docs/steam-ia.md` e inventário seção 14.
- **Estrela de impacto** `Fx.hit_star` (`hit_star.gdshader`, HDR até 3,2 e 4,6, branco-quente nos primeiros 30% e depois a cor do golpe;
  `STAR_SIZE` 2,7 e 4,4 m, 0,15 e 0,24 s, no máximo 5 por quadro): chamada em todo `Fx.contact`, no Brado (centro do peito), no Supremo
  e no centro de todo `Fx.shock`. No Compatibility a luz cai a 1,0.
- **Poeira de osso e clarão da morte**: `Fx.puff` (`puff.gdshader`, flipbook, `lit` faz os primeiros quadros estourarem quentes) no
  `burst(&"bone")` junto de uma estrela pequena; também na esquiva (poeira atrás dele) e no `shock`.
- **Chão escurecido sob o efeito**: `Fx.scorch` (`scorch.gdshader`, mancha irregular do quadro 0 da poeira, 0,55 de opacidade,
  0,7 s) em todo `shock` (golpe forte, finalizador, Brado, Supremo), para os anéis acesos lerem sobre o chão verde.
- **Rastro**: o arco do herói ganha riscos de pincel (`paint_amt` 0,75, quebra o miolo e rasga a borda rumo à cauda), a borda mais
  branca (`edge_white` 0,4; a cor da família fica no fio de `style_wire_glow`, agora 2,4, teto `SLASH_WIRE_CAP` 2,6 acima do limiar do
  brilho 1,3, só no fio) e o golpe 3 desenhado 22% maior (`FINISHER_SLASH_SCALE`, só desenho: o alcance é do `Combat`).
- **Clarão de tela** `Fx.screen_flash` (`flash` em `screen.gdshader`, +0,28 no máximo, 0,09 s): só Golpe Carregado (0,7), Omega (1,0),
  Apogeu (1,0), Brado (0,8) e Supremo (1,3); desligado pelas opções de quadros de impacto e de tremor desligados. Nunca no golpe comum.

## Chegada do Guerreiro (SW-O1, 2026-11-25, environment-artist; `docs/design/onboarding_sw_o.md`; sem captura na GPU ainda)
A cena da primeira descida: só o que já existe (preto, uma estrela, a luz de Elun, o selo, cristais de Emeth, fagulhas, o herói se formando).
- **Relógio puro** `ArrivalTimeline.state_at(t)` (`scripts/core/arrival_timeline.gd`, constantes nomeadas): 0,0 preto; 0,6 estrela (6 px,
  halo esmeralda, pulsa); 1,6 o preto abre em 0,8 s, a estrela desce até o ponto de nascimento e o `RewardShaft` cai (2,5 m no chão); 2,4 o
  anel de runas (`ritual_rune.gdshader`, círculo fixo kind 2, ouro velho, cresce do meio) e 5 cristais (`crystal_spike.gdshader` parado
  no tamanho cheio, a 2,5 m) sobem em 0,6 s; 3,0 a 3,5 as fagulhas (`SpectralMotes` GATHER, 6 por cristal) correm ao feixe e acabam
  antes do herói; 3,6 o herói se forma de baixo para cima em 0,4 s (`arrival_form.gdshader`); 4,0 controle (`finished`), o feixe apaga
  em 0,8 s, a luz da sala sobe de 25% a 100% em 1,0 s; 4,2 legenda (`hud.arrival_caption.show_line(&"arrival_line", 0)`); 5,0 fim.
- **`ArrivalScene`** (`scripts/game/arrival_scene.gd`): `play(game, at)`, sinal `finished` (aos 4,0 s), `skip()` (só depois de 1,0 s, leva ao
  4,0 e a legenda sai curta, 2,5 s), `has_control()`. Cobre com sua `CanvasLayer` 50 (acima do HUD, que fica escondido até os 4,0 s), segura
  o herói no ponto (`player.place`, invulnerável, invisível até 3,6), escurece a sala por `Environment.adjustment_brightness`
  (`DIM_BRIGHTNESS` 0,55; o `RoomMood` não toca nesse campo) e devolve tudo. Os cristais ficam no nó como cenário (sem colisão): liberar o
  nó com a sala.
- **`arrival_form.gdshader`**: pinta o corpo com a própria textura e `tint` do material (estilizado ou clássico), descarta acima de `cut`
  (metros no mundo), fio esmeralda sob o corte, `flash` leva ao marfim, tudo sob `cap` (teto do `ScreenTone`). Troca só o `material_override`
  das malhas pintadas por 0,4 s; a lâmina e o resto ficam ocultos até acabar. No `warmup_set.res` (entrada acrescentada por
  `tools/make_warmup.gd`, sem regerar o conjunto).
- **Cometa (PT-25-7, 2026-11-25, sem captura ainda)**: o feixe do `RewardShaft` saiu da chegada. De 1,6 a 2,4 s (`FALL_TIME` 0,8, a estrela some em 0,4 s) um cometa dourado
  (`BEAM_TINT`) cai em diagonal, vindo de `COMET_UP` 15 m acima e `COMET_SIDE` 9 m à esquerda da câmera: cabeça e 14 quadros de cauda
  (`Fx.quad`, aditivo, sem textura nova), velocidade crescente (`COMET_EASE`). No impacto (`T_IMPACT` 2,4, o mesmo instante do selo e dos cristais):
  clarão de tela (`FLASH_ALPHA` 0,5, 0,3 s), anel de luz no chão (`arrival_impact.gdshader`, 0,7 s, raio 3,4 m), anel de poeira
  (`CPUParticles3D` de uma vez, 44 grãos), tremor `fx.shake(SHAKE)` (respeita a opção de tremor) e um brilho baixo em volta do herói até os 4,0 s.
  O corte de baixo para cima do herói agora tem a borda dourada. Relógio: chaves novas `comet`, `impact`, `shock`, `flash`; `star_move` saiu.
  Duração e controle (4,0 s) iguais. Para ver: `--arrival --arrival-hold=2.0` (cometa no ar), `2.5` (impacto, anel e poeira), `3.0`, `3.8` (herói se formando).
- **Para ver sozinha** (sem o 3A1): `--arrival` toca sobre a primeira sala; `--arrival-hold=SEGUNDOS` congela o relógio num instante.

## Pente fino lote B (2026-11-25)
- Tiros dos conjuradores, do sacerdote e do Ancião: `DEAD_MAGENTA` (`make_data.gd`) virou verde doentio (matiz cerca de 100); `enemy_orb.gdshader` sem miolo preto (`core_tone`). Rosa fica só da maldição.
- "Mais Vida": `Rooms._reward_color` e `RewardShaft.TONE` em vermelho-coração apagado (matiz 6 a 8). Pendente (dono de `reward_gem.gd`): `ENAMEL_HEART` ainda é 345.
- Redemoinho de Fogo (`Skills._step_orbit`): corpo laranja, miolo âmbar, brilho aditivo e cauda de três brasas.
- Raio-x dos avisos: global `warn_pos` (`project.godot`), posto por `Ground._publish_warning` (o aviso mais perto do herói) e lido em `see_through.gdshaderinc` como terceiro "quem" ao lado de `hero_pos` e `boss_pos`.

## Revisão de arte 2026-11-26: efeitos e peças (technical-artist)
- **Cometa** (`arrival_scene.gd`): cabeça = halo dourado fraco (`HEAD_SIZE` 1,0, `HEAD_LIGHT` 0,9) com núcleo branco quente
  pequeno (`CORE_SIZE` 0,3), cauda `TAIL_STEP` 0,045 e `SPARKS` 8 faíscas soltas (`_dress_sparks`, deslocamento fixo, sem
  sorteio). Cristais e fagulhas da chegada em âmbar/dourado (`CRYSTAL_COLOR`, `MOTES_COLOR`), não mais esmeralda; o formato
  continua de pé (1,2 a 2,0 m), só a cor mudou. Sem sol: o halo é pequeno e o núcleo é o foco.
- **Água** (`shallow_water.gdshader`): as pintas laranja eram o brilho das cristas (`glint`); agora fraco e dourado pálido,
  com manchas de musgo/limo escuro (`moss_color`, `moss`) e reflexo azul-cinza #536F7A com teto (`reflect_color`, `reflect_amount`
  0,42, `min` no emissivo), brilho dourado vem do `sheen`. Uniforms `foam` (0 = nenhuma) e `foam_color`: linha de espuma
  quebrada junto às margens, ligada só no `GapFloor` (0,75) para as ilhas de esquiva.
- **Laje 2x2** (`HazardPiece.plate` + `hazard_mark.gdshader`): junta em cruz 1,6x a espessura da junta (cerca de 10 cm),
  chevron com traço 0,11 e braço 0,4, cor `chev_mul` mais escura (0,5, 0,4, 0,26).
- **Lajes soltas do Salão** (`hall_life.gd`): `SLAB_TINT` 0,62 sobre a pedra do piso (laje e lasca).

## Lote 1 de 2026-11-26 (BG-1, PM-1, QW-1, DT-1)
- **BG-1, auditoria no código**: `RewardShaft` ligado (rooms.gd: sala vencida, cada item da loja; game.gd: fonte): FEITO. Traço branco vertical
  (`impact.gdshader`, `pale` 0,35 sob `GASH_SCREEN`), `glint` sem cobrir o herói (`over_body`), `hero_burst(light)` baixo (`HERO_LIGHT_TOP`),
  clarão de Morvath no violeta (`own_flash`), preparo do Feiticeiro (miolo e anéis no cajado, sem acima do limiar): FEITO nas notas da seção do
  pass de VFX e sem regressão no código. Contato com miolo branco e cruz (a captura `docs/gallery/lote1_2026-11-26/before_hit.png` mostrou
  disco branco): CORRIGIDO (abaixo). Onda do especial: o acerto passa por `contact`, então herdou a correção; a onda em si é faixa (`band`).
  Círculo: `family_mark` LUZ forma 2, sem disco chapado no código (NÃO REPRODUZIDO; conferir em captura).
- **PM-1 (a), tinta no contato (só estilizado, CLASSIC igual)**: `contact.gdshader` ganhou o uniform `ink` (Fx liga com `VisualProfile.stylized()`):
  3 a 5 fragmentos (`CONTACT_INK_FRAGMENTS`) todos num leque para o lado da lâmina e curvados, núcleo escuro (`CONTACT_INK_CORE` 0,14 m) deslocado
  para a lâmina com aro marfim-menta, sem coração branco; `Fx.contact` não chama mais `hit_star` (só o golpe pesado, a 0,6). O `clap`
  redondo e branco do `hit_star.gdshader` cai a 12% no estilizado (`art_style`).
- **PM-1 (b), coleta**: `RewardShaft` já tinha descida, poça, respiração e retirada no `take()`; o que mudou foi a leitura de coluna larga e
  chapada: `TOP_RADIUS` 0,4, `FOOT_RADIUS` 0,85, `SHAFT_BODY` 0,2 e `SHAFT_SIDE_SOFT` 3,4.
- **QW-1**: números sobrepostos primeiro saem para o lado (`NUMBER_SIDE_TRIES` 2, alternando direita e esquerda por rótulo, `NUMBER_SIDE_LIFT` 6 px),
  só depois sobem.
- **DT-1**: apagados `dome_film`, `dome_clock`, `fury_ember`, `dark_water_matte` (e `.uid`); sem referência em código, cenas, dados e testes; as
  quatro entradas saíram de `assets/warmup/warmup_set.res` (regravado por script, 36 KB para 179 KB no disco; `test_warmup` verde).

## GP-3 de 2026-11-26: VFX "tinta em movimento", parte 2 (technical-artist; só desenho, `RESULT` do `smoke.sh 30 --seed=5` igual; sem captura)
- **Assinatura 4, formas por família** em `family_mark.gdshader` (mesmo shader, sem arquivo novo, então o `warmup_set` não muda): forma 4 Véu (bruma
  cinza-amarelada em faixa sobre o anel, só a borda do banco de névoa em âmbar apagado, sem violeta), 5 Maré (duas fitas que ondulam em volta do
  anel, espuma prateada nas cristas, `arc` estreita para uma direção), 6 Marca (incisões finas oblíquas e curtas, bronze, nunca linha longa), 7 Peste
  (fios de névoa enxofre subindo do anel, sementes de líquen que brilham, miolo carvão `PESTE_CHARCOAL` por baixo), 8 Trovão (6 raios em
  segmentos com uma bifurcação na metade, ardósia; nos primeiros 0,05 s só o clarão `TROVAO_FLASH`). As quatro de antes seguem iguais.
- **Ponto de entrada (para o código das Bênçãos)**: `Fx.form_of(family)` acha a forma pelo NOME da família em `Boon.Family` (`FORM_BY_NAME`; um nome
  que o enum ainda não tem, como PESTE e TROVAO, dá -1 sem erro; quando o outro agente criar `PESTE` e `TROVAO` no enum, funciona sem mexer em
  `Fx`). Chão: `fx.family_mark(family, centro, raio, cor, Fx.mark_time(family), dir, arc_deg)` (ou `fx.form_mark(form, ...)` com o número da forma);
  `Fx.form_of(f) < 0` (Elo, família sem forma) pede o `ring` simples. Golpe que acerta: `fx.family_hit(Fx.family_of(cor), pos, dir, cor, pesado)`, que o
  `Combat` já chama; `family_of` agora também conhece Véu, Maré, Marca, Peste e Trovão pela cor em `Boon.FAMILY_COLOR` (o Elo continua -1).
  Cores de Peste (sulfur #C9B458, líquen #9FAE7A, carvão #2E2B26) e Trovão (ardósia #4E5866, tempestade #7D8590, clarão #F1E08A) em `Fx.PESTE_*`/`TROVAO_*`;
  `Boon.FAMILY_COLOR` das duas deve ser sulfur e ardósia para a carta e o efeito concordarem. Peças que sobem do chão: `_form_extras` (orçamento `motes`/`wisps`).
  Golpe: `_family_hit_new` (Véu fumaça, Maré gotas longas pela direção do golpe, Marca lascas oblíquas, Peste fio e sementes, Trovão faíscas).
- Chamadores trocados: `skills.gd::_mark` e `game.gd` (escolha da Bênção) usavam `Fx.MARK_FORM.has` e `MARK_TIME[family]` (índice fora do limite com
  família nova); agora `Fx.form_of` e `Fx.mark_time`. `Fx.MARK_FORM` continua com as quatro de antes.
- **Assinatura 5**: `enemy_orb.gdshader` ganhou borda suja (o contorno da bola comido por ruído, `dirt` 0,14; a agulha da besta fica inteira; tamanho e
  acerto iguais); `soul_crescent.gdshader` ganhou corrosão (buracos no corpo, nunca na linha do meio). Já existiam e ficam: magia dos mortos em carmim e
  magenta com miolo escuro (V-11), cauda de fumaça violeta (`SOUL_TAIL`, `SCYTHE_SMOKE`), foice com borda roída (V-16). O aviso vermelho do chão não foi tocado
  (a fase 4 só muda o ar, `RoomMood.LAST_BREATH`); a conferência é por captura: `tools/gpu.sh shot x.png --bot --start=boss --boss-hp=0.2 --shot-at=14`.
- Testes: `tests/test_gp3_families.gd`. Capturas para a sessão principal: `--start=boss --boss-hp=0.2` (fase 4, meias-luas e aviso), `--boons=25` com
  `--bot` (famílias), e um quadro por forma chamando `fx.form_mark(N, ...)`.
- **Revisão 2026-11-26c** (`docs/art/ART_REVIEW_2026-11-26c.md`): contato com tinta lia como retícula; `CONTACT_INK_CORE` 0,10, aro do
  `contact.gdshader` até 1,12 e raiz dos traços 0,075 (só `ink`). Trovão (forma 8) com espaçamento e comprimento irregulares para não
  ler como sol. Pendentes: corte com Bênção sobre o herói, cor da Marca, `--lab-form=N` para capturar Peste e Trovão.

## Revisão 2026-11-26c, correções (technical-artist; só VFX, `RESULT` do `smoke.sh 30 --seed=5` igual; sem captura)
- **P1-2**: `Fx.slash` passa `body_clear_m` (1,0 m) também com `family >= 0`, e o `slash.gdshader` aplica a mesma limpeza (`clear`) à luz da família
  (`fam`), não só ao miolo; `slash_ink.gdshader` ganhou `body_clear_m` (só com família). Corte sem família: igual.
- **P1-3**: `Fx._family_white(family)`: o pico de tela do corte usa 0,1 de branco para Marca e Véu (0,3 nas outras).
- **P1-5 (decisão do Game Director)**: forma 8 (Trovão, anjo) agora **cai de cima**: tronco grosso e torto no lado de cima da tela (-z), 1 ou 2
  galhos curtos, coroa de seixos no impacto, ardósia com clarão #F1E08A nos 0,05 s; pó de pedra (`STONE_DUST`) em vez de farpas. Forma nova 9 (`ARCO`,
  `FORM_BY_NAME`, `FORM_SCREEN`, `FORM_TIME` 0,3 s): o raio da Maga, uma linha fina e contínua que salta na horizontal (eixo `start`), sem queda,
  sem galho, sem falhas, na cor `ElementLook.VOLT`. Nenhum shader novo (ramo novo em `family_mark.gdshader`). Nada chama a forma 9 ainda
  (a Maga está parada); fica pronta.
- **P2**: `SLASH_PAINT` 0,9 e o fio externo do corte da Emeth ganha falhas (textura de pincel em outra frequência); `FAMILY_NUMBER_OUTLINE` 2 nos
  números diretos com cor de família; `tick_color` devolve `TICK_VEIL` (âmbar apagado) para o Véu em vez do verde da Emeth.
- **Captura**: `--lab-form=N` (opcional `--lab-form-at=m`, `--lab-t`) no `_lab` do `game.gd` chama `fx.form_mark(N, ...)` à frente do herói;
  `Fx.freeze_t` agora também congela as marcas.
- Linhas tocadas em `fx.gd` (outro agente mexe no orçamento): constantes `FORM_BY_NAME/SCREEN/TIME`, `STONE_DUST`, `TICK_VEIL`, `FAMILY_NUMBER_OUTLINE`,
  `_family_white` (antes de `slash`), as 3 linhas de `body_clear_m`/`style_peak` em `slash`, `_form_extras` caso 8, `_family_hit_new` caso 8, `number`, `tick_color`,
  o laço de `_marks` no passo.

## Efeitos das Bênçãos V2 (GP-2) (technical-artist; só VFX, `RESULT` de `smoke.sh 30 --seed=5` e de `--boons=25` iguais; sem captura)
- Sem shader novo: `Fx.form_mark` (formas 7, 8, 9) e `_spray`/`wisps`/`puff`, tudo sob os orçamentos `motes`, `wisps` e `marks` do `FxBudget`.
  Funções novas em `fx.gd`: `poison_rise` (bolhas de enxofre e semente de líquen subindo, até 3 por tique, uma por carga),
  `bleed_drop` (duas gotas e fiapo de pó de osso escuro `BLEED_DUST`; nada de vermelho), `shock_spark` (faísca ardósia e um fio amarelo `TROVAO_FLASH`),
  `thunder_fall` (forma 8 caindo no alvo da Descarga, com pó de pedra), `conduction` (faíscas pelo salto e um Trovão pequeno no segundo alvo; não usa a
  forma 9 para não confundir com a Maga), `arc_leap` (forma 9 em `ElementLook.VOLT` entre dois alvos), `plague_ground` (forma 7 em enxofre mais semente de líquen),
  `opening_flash` (puff e anel marfim pálido, sem cruz nem sol).
- Chamadas (só visual, nenhuma regra): `celestial.gd` no `_tick` (veneno e sangramento, a cada 0,5 s por inimigo), `apply_shock`, `_discharge`
  (Descarga e Condução) e `_meter` (clarão quando a Abertura abre); `arcane.gd::_arc` chama `arc_leap`; `ground.gd` redesenha o chão `PLAGUE` a cada
  `Fx.PLAGUE_REDRAW` (0,8 s) e deixa a área comum só como mancha (`PLAGUE_STAIN` 0,3).
- **Gancho de HUD** (a tela é do ui-ux-designer): `Celestial.meters_of(enemy)` devolve `{cold, cold_need, impact, impact_need, open}` para os pontinhos de Frio e
  Impacto sob a barra do chefe; ainda não há nada na UI.
- Capturas a rodar pela sessão principal (uma por vez, `tools/gpu.sh shot`): `x.png --bot --boons=25 --shot-at=14` (famílias e efeitos),
  `x.png --lab-form=7`, `--lab-form=8`, `--lab-form=9` (as três formas), `x.png --bot --angels=zerael --boons=25 --shot-at=12`
  (veneno e chão da Peste), `--angels=saarael` (Eletrificação e Descarga), `--angels=qeshael` (sangramento), `--start=boss --boons=25 --shot-at=14` (Abertura).

## Efeitos pintados da espada (2026-11-27)
`Fx.painted_*` + `assets/shaders/painted_fx.gdshader`: cartas de flipbook (folhas em `assets/textures/fx/painted/`, de `docs/art/vfx_painted/`) no lugar da fita do `slash`, da meia-lua e do `contact` no look estilizado; `--painted-fx=off` e o classico voltam aos efeitos de malha. Folha por golpe: `Fx.painted_sheet` (giro, esmagador, finalizador cut2, leves alternando cut1/cut2). Quadro em degrau, arco aparado ao angulo do golpe a partir da cauda. Cor padrao = verde da Emeth (`Fx.painted_colors`). Sem folha: investida (`thrust`).
