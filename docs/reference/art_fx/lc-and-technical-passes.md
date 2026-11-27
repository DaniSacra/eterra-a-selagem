> Índice: [art_fx.md](../art_fx.md)

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
