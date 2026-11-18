# Auditoria do cenário, 2026-11-18 (environment-artist)

Base: `arpg-3d` em `dd1f5ba`. Só leitura de código; nada alterado além deste relatório e das capturas em
`docs/reports/2026-11-18/environment/`. Capturas reais na RTX 5060 (Forward+, `tools/gpu.sh shot`, 1672 x 941, guardadas em JPG) e no
renderizador do navegador (OpenGL 3 na mesma GPU, `tools/gpu.sh run --rendering-driver opengl3`); desempenho na placa
integrada do notebook (Intel RaptorLake-S, `--gpu-index 1`, 1280 x 720, `--smoke=12` com janela, vsync desligado).
Encaixe desenho x colisão por `tools/fit_probe.gd` (headless) em todas as arenas e variantes.

## Resumo (5 linhas)
1. Nenhum P0: nada bloqueia sem desenho de forma relevante (no máximo 1,6 m² no Jardim, raízes), toda peça alta é `see_through`, toda luz de cenário tem `light_cull_mask`, portas e entradas seguem livres.
2. O que mais denuncia protótipo hoje são as **gemas das recompensas**: caixas, prismas e esferas sem sombreamento (`Rooms.gem_mesh`, `SHADING_MODE_UNSHADED`) que na tela são quadrados chapados de cor pura (loja, altar, Provação, portas).
3. Três leituras do chão andável enganam: o parapeito da ponte longa atravessa o patamar da Ponte B (8,7 m² de "fantasma"), a pedra quieta das Runas B parece um buraco preto, e a beira do buraco do Santuário B desenha laje 0,4 m ou mais além do chão.
4. Luz: a Cripta e o Santuário têm metade da sala quase preta longe das velas; Ponte e Fendas ficam monocromáticas (azul e violeta chapados); o Compatibility satura e salpica o chão (lajes coloridas demais).
5. Desempenho na iGPU: Baixa 57 a 83 qps em todas as salas (Fendas a mais pesada, 57), Média 21 a 27 nas salas do E5; na RTX, Alta 376 a 415. KayKit ainda aparece no entulho do salão, nas velas em volta das pilastras e nas escadas das portas.

## Como medi
- Forward+: `tools/gpu.sh shot <saída> --arena=<id> --variant=<n> --bot --autopick --seed=5 --shot-at=4`; salão com as duas
  verificações padrão (`--bot --autopick --seed=5 --shot-at=9` e `--showcase --seed=5 --shot-at=2`); Provação e Altar com
  `--start=trial|altar --seed=5 --shot-at=2` (sem robô: com ele a sala já passou); Câmara com `--start=boss` e fase 4 com `--boss-hp=0.14`.
- Compatibility: `tools/gpu.sh run --rendering-driver opengl3 --resolution 1672x941 --fixed-fps 30 -- --nosave --arena=<id> --bot --autopick --seed=5 --shot-at=4 --shot=...`.
- Encaixe: `~/tools/godot/godot --headless --path . -s tools/fit_probe.gd -- --arena=<id> --variant=<n> --png=...`.
- iGPU: `tools/gpu.sh run --rendering-driver vulkan --gpu-index 1 --resolution 1280x720 --disable-vsync -- --nosave --quality=<baixa|media> --arena=<id> --bot --autopick --seed=5 --smoke=12`
  (o `fps` do `RESULT` é o do último segundo; o WSL estava carregado por outros agentes, mas a GPU ficou só comigo pela trava do `gpu.sh`).

## Medidas

### Encaixe desenho x colisão (`fit_probe`, m²)
Fantasma = desenho acima do joelho em chão livre; sem desenho = peça que bloqueia sem nada visível; beira falsa = laje
desenhada fora do chão andável. Imagens: `environment/fit_<arena>_<variante>.png` (vermelho fantasma, azul sem desenho, amarelo beira falsa).

| Sala | fantasma | sem desenho | buraco falso | beira falsa | Leitura |
|---|---|---|---|---|---|
| Salão | 9,86 | 0 | 0 | 39,06 | quase tudo bocas de porta e o patamar sudoeste: o `fit_probe` não conhece `Arena.walk` (ver P2-7) |
| Cripta A / B | 0,32 / 0,31 | 0,04 | 0 | 0 | limpo (só os braseiros da porta norte) |
| Fendas A / B | 1,49 / 1,49 | 0 | 0 | 5,10 / 4,99 | o que sobrou da etapa 4 (bocas, base da torre) |
| Jardim A / B | 1,99 / 1,99 | 1,62 / 1,64 | 0 | 2,66 | idem etapa 4 (bloco a 11,5 tem 9% sem desenho) |
| Santuário A / B | 1,20 / 1,20 | 0,17 / 0 | 0 | 9,16 / **16,56** | B: anel amarelo em volta do buraco da nave (P1-3) |
| Ponte A / B | 4,12 / **8,67** | 0 | 0 | 11,14 | B: parapeito atravessa o patamar (P1-2) |
| Runas A / B | 2,61 / 2,61 | 0 | 0 | 0,45 | só bocas de porta |

Provação, Altar e Câmara do Selo não estão no `fit_probe` (só lê `stage.layouts`); a Câmara já tem o teste por vértice
(`tests/test_chamber_look.gd`).

### Peças altas que podem cobrir o herói
Toda peça de obstáculo acima de 1,8 m é `see_through` (lista tirada do `catacombs.tres` por script, todas as arenas e
variantes: colunas, pilares das Runas, divisor do ossuário da Cripta B, tronco do Jardim, pilone, blocos). As que não
abrem são baixas (sarcófagos 1,4 a 1,5, braseiros 1,2, altar 1,3). Problemas são de leitura, não de colisão (P2-1, P2-2).

### Luzes
Toda `OmniLight3D`/`SpotLight3D` dos scripts de cenário tem `light_cull_mask` (contagem por arquivo: `arena`, `arena_kit`,
`arena_room`, `boss_chamber`, `catacomb_hall`, `crypt_look`, `garden_look`, `bridge_look`, `rift_look`, `runes_look`,
`sanctuary_look`, `tomb_kit`, `rooms`). Exceção de custo, não de máscara: cada gema de recompensa acende uma omni própria
(energia 2, alcance 5) e cria um `StandardMaterial3D` por instância (`Rooms._marker`); na loja são 5 a 6 ao mesmo tempo.

### Desempenho na placa integrada (1280 x 720, Forward+, robô lutando)
| Sala | Baixa (qps) | Média (qps) |
|---|---|---|
| Salão | 61 | |
| Cripta | 83 | |
| Fendas | 57 | |
| Jardim | 61 | |
| Santuário | 70 | 21 |
| Ponte | 80 | 27 |
| Runas | 81 | 25 |
| Câmara do Selo (fase 1) | 64 | |
| Provação (a sala depois dela) | 61 | |

RTX 5060, Alta, 1920 x 1080: Santuário 376 qps, Câmara 415 qps.
Leitura: a Baixa passa de 60 em quase tudo; as Fendas ficam no limite (57: bruma em três folhas, lábios, pontes). A Média
das salas novas do E5 (não medida antes) fica em 21 a 27 qps, como a Média das antigas na E6 (20 a 22): a Baixa é a
opção da placa integrada. Na RTX o cenário sobra (376 e 415 qps). Medida de um segundo só, por sala: serve para ordem de
grandeza, não para comparar 57 com 61.

## Achados

### P0
Nenhum. Nada de colisão invisível relevante, nada alto sem abrir em volta do herói, nenhum erro de script nas capturas.

### P1
- **P1-1. Gemas das recompensas em cor chapada (aparência de protótipo).** `Rooms.gem_mesh` devolve `BoxMesh`, `PrismMesh`,
  `SphereMesh` e `CylinderMesh` com `SHADING_MODE_UNSHADED`: a 54 m de distância viram quadrados lisos de cor pura,
  sem forma nem brilho. É a coisa mais "protótipo genérico" das salas e aparece em toda porta, na loja e nas salas de evento.
  Evidência: `environment/fwd_shop.jpg` (cinco cubos amarelo, verde, vermelho, azul, roxo em volta do medalhão),
  `fwd_altar_room.jpg` (quatro), `fwd_trial_room.jpg` (o roxo ao lado do bloco). Também: material e omni por gema.
- **P1-2. Ponte B: o parapeito da ponte longa atravessa o patamar do meio.** 8,67 m² de fantasma contra 4,12 na A; duas
  linhas de 6 m de parapeito sobre chão andável nos dois lados do patamar (`fit_bridge_1.png`, faixas vermelhas no meio).
  O jogador vê o patamar como fora de alcance e os inimigos que andam nele parecem do outro lado da balaustrada.
  Evidência: `fit_bridge_1.png`, `fwd_bridge_1.jpg`.
- **P1-3. Santuário B: a beira do buraco desenha laje onde não se anda.** Anel de "beira falsa" de cerca de 7 m² em volta
  do buraco da nave (16,56 contra 9,16 da A, que só tem a escada da porta): o herói para 0,4 m ou mais antes da beira
  que vê. É o mesmo caso que a etapa 4 resolveu nas Fendas afundando as lascas um degrau. Evidência: `fit_sanctuary_1.png`, `fwd_sanctuary_1.jpg`.
- **P1-4. Runas B: a pedra quieta lê como buraco.** O quadrado de 2 x 2 lajes lisas no meio é quase preto e sem moldura:
  parece um poço, não o lugar seguro da sala. Evidência: `fwd_runes_1.jpg` (centro da sala).
- **P1-5. Cripta e Santuário escuros demais longe das velas.** Na Cripta a metade oeste das paredes e a borda sul viram preto
  (`fwd_crypt_0.jpg`, `fwd_crypt_1.jpg`); no Santuário a nave da esquerda e a parede sul somem. O chão de luta ainda lê, mas
  a sala perde forma e os inimigos nas bordas escuras dependem só da barra de vida.
- **P1-6. Capitéis das colunas em "Y".** As colunas de 5 m (Santuário, Cripta) têm um capitel que na câmera de jogo vira
  um garfo de duas pontas, sem leitura de pedra lavrada; na fileira da frente do Santuário são seis garfos ocupando a tela.
  Evidência: `fwd_sanctuary_0.jpg`, `compat_sanctuary.jpg`.

### P2
- **P2-1. Pilar das Runas abrindo em volta do herói vira poeira laranja.** O pontilhado do `see_through` passa sobre os
  sulcos acesos e sobra um chuvisco de pontos âmbar (`fwd_runes_0.jpg`, ao lado do herói; igual no `compat_runes.jpg`).
- **P2-2. Parapeito da frente das pontes cobre as pernas do herói.** Na Ponte o herói andando na beira de baixo some da
  cintura para baixo atrás do parapeito de 0,9 m (`fwd_bridge_0.jpg`, `fwd_bridge_1.jpg`); o pontilhado só abre a pedra
  alta. Leitura de combate pior justamente no lugar mais apertado.
- **P2-3. Cripta: massa escura fora da sala a nordeste.** Entulho e um pano escuro além da borda leste, sem luz, lendo como
  borrão (`fwd_crypt_0.jpg`, `compat_crypt.jpg`, canto direito acima do meio).
- **P2-4. Compatibility satura e salpica o chão.** Lajes com variação de cor muito maior que no Forward+ (azul, marrom, roxo
  lado a lado) no Salão, Ponte e Santuário (`compat_hall.jpg`, `compat_bridge.jpg`, `compat_sanctuary.jpg`); na Cripta o
  facho frio deixa listras finas no chão (`compat_crypt.jpg`, perto do sarcófago do meio). Navegador é secundário.
- **P2-5. Ponte e Fendas monocromáticas.** Tudo no mesmo azul (Ponte) ou violeta (Fendas), poucos acentos quentes; o chão
  ilumina por igual e a profundidade some (`fwd_bridge_*.jpg`, `fwd_rift_*.jpg`).
- **P2-6. KayKit ainda à vista.** Pelo inventário (`docs/art/asset_inventory.md` seção 4), numa descida se carregam
  `rubble_half`, `rubble_large`, `barrel_large`, `candle_lit`, `candle_triple`, `stairs_wide`, `wall*`, `pillar*`,
  `torch_mounted`, `sword_shield_broken`, `banner_*`, `floor_tile_large`, `box_small`. Onde mais se nota: o entulho na boca
  da porta leste do salão (`kit.piece("rubble_half")` em `catacomb_hall.gd`, e o entulho do lado sul em `Arena`;
  `fwd_hall_vitrine.jpg`, canto inferior direito; boa parte dos 8 m² de fantasma do salão em x 13 a 15) e as velas
  `candle_triple`/`candle_lit` que `Arena` ainda põe em volta das pilastras. As velas do salão em si já são do `Masonry`.
  40 peças do `dungeon_r/` nunca carregam (provável sem uso).
- **P2-7. O `fit_probe` não conhece o salão nem as salas de evento.** Usa `arena.shape()` sem o `Arena.walk` (o patamar
  sudoeste e as escadas viram 39 m² de "beira falsa") e não lê `trial_layout`, `altar_layout`, `boss_layout`. Sem isso,
  regressões no salão passam sem número.
- **P2-8. Altar Esquecido parece novo demais.** Paredes lisas e limpas sobre um fundo azul-ciano de céu aberto, sem pó,
  rachadura nem ruína; destoa do resto das catacumbas (`fwd_altar_room.jpg`).

## As 10 melhorias de maior ganho

Critério: ganho na leitura do combate e na impressão de "jogo acabado" para quem abre o jogo, dividido pelo esforço, sem
mexer em colisão nem em regra. Ordem decrescente.

1. **Gemas das recompensas com forma e luz própria** (P1-1). Trocar o `UNSHADED` por um material de gema único por tipo
   (fresnel, faceta, miolo claro sob o teto da tela), prisma lapidado, romã e moeda de verdade; um material compartilhado
   por cor e luz só na porta escolhida. Aparece em toda sala, ganho imediato; esforço pequeno (`Rooms.gem_mesh`, `_marker`).
2. **Patamar da Ponte B aberto** (P1-2). O parapeito para nas cabeceiras do patamar e contorna a borda dele. Critério: fantasma
   da B igual ao da A (cerca de 4 m²) no `fit_probe`.
3. **Pedra quieta das Runas B com cara de lugar seguro** (P1-4). Laje clara e lisa com moldura de ouro velho apagada, sem
   runas, em vez do quadrado preto. Critério: valor do quadrado no meio da faixa do chão (nunca abaixo das lajes vizinhas).
4. **Beira do buraco do Santuário B** (P1-3). Aplicar o `broken_lip` afundado das Fendas. Critério: beira falsa da B igual à
   da A (9,2 m²) no `fit_probe`.
5. **Preenchimento de luz da Cripta e do Santuário** (P1-5). Uma luz de preenchimento só das paredes e da borda (camada
   própria, sem sombra, como o `FLOOR_FILL` da Cripta), para a sala ter forma. Critério: nenhuma parede da sala abaixo de 20
   de valor a 1080 nas capturas; chão de luta entre 45 e 60 como no C12c.
6. **Capitel de verdade nas colunas altas** (P1-6). Ábaco e equino em caixas (`Masonry`), sem o garfo. Esforço pequeno,
   aparece em três salas.
7. **Entulho e velas do KayKit fora do salão** (P2-6). Trocar o entulho da boca leste e do lado sul por pedras do
   `Masonry` e as velas do KayKit pelas do `Masonry.candle` (já existem). Critério: nenhuma peça do `dungeon/` na vitrine
   e o fantasma do salão em x 13 a 15 abaixo de 2 m² no `fit_probe`.
8. **Sulcos do pilar das Runas sem chuvisco** (P2-1). Desligar o pontilhado no canal de emissão (ou abrir só a pedra) no
   `rune_pillar`. Critério: nenhum ponto âmbar isolado em volta do herói na captura com ele atrás do pilar.
9. **Parapeito baixo das pontes abrindo em volta do herói** (P2-2). `see_through` também no parapeito da frente (só a
   metade virada para a câmera), como as velas da Câmara. Critério: pés do herói visíveis na beira de baixo da ponte.
10. **`fit_probe` com `Arena.walk` e as salas de evento** (P2-7). Mede o salão, a Provação, o Altar e a Câmara; entra como
    teste de regressão do encaixe (limites por sala nos números de hoje).

## Dependem de modelo (Meshy ou outro, sem gastar créditos sem o Daniel)
- Estátuas encapuzadas, estátua gigante, entulho e velas do salão, gemas lapidadas: hoje caixas e KayKit (`docs/art/meshy_asset_plan.md`).
- Árvore do Jardim e capitéis podem ficar em caixas; não dependem de modelo.

## Capturas desta auditoria (`docs/reports/2026-11-18/environment/`)
- Forward+: `fwd_hall_jogo.jpg`, `fwd_hall_vitrine.jpg`, `fwd_crypt_0.jpg`, `fwd_crypt_1.jpg`, `fwd_rift_0.jpg`,
  `fwd_rift_1.jpg`, `fwd_garden_0.jpg`, `fwd_garden_1.jpg`, `fwd_sanctuary_0.jpg`, `fwd_sanctuary_1.jpg`, `fwd_bridge_0.jpg`,
  `fwd_bridge_1.jpg`, `fwd_runes_0.jpg`, `fwd_runes_1.jpg`, `fwd_trial_room.jpg`, `fwd_altar_room.jpg`, `fwd_shop.jpg`,
  `fwd_boss.jpg`, `fwd_boss_phase4.jpg` (`fwd_trial.jpg` e `fwd_altar.jpg` são a sala depois do evento: o robô já tinha passado).
- Compatibility: `compat_hall.jpg`, `compat_crypt.jpg`, `compat_rift.jpg`, `compat_garden.jpg`, `compat_sanctuary.jpg`,
  `compat_bridge.jpg`, `compat_runes.jpg`, `compat_boss.jpg`.
- Encaixe: `fit_hall_0.png`, `fit_crypt_0/1.png`, `fit_rift_0/1.png`, `fit_garden_0/1.png`, `fit_sanctuary_0/1.png`,
  `fit_bridge_0/1.png`, `fit_runes_0/1.png`.
