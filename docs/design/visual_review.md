# Revisão visual para a Game Feel Review (pilar 2 e a parte visual do pilar 1)

Autor: `art-director`, 2026-11-16. Árvore principal, HEAD `beb6c27` (C12c). Nada do jogo foi mudado. Diretriz:
`docs/design/game_feel_directive.md`. Direção aprovada: `docs/arte/estetica.md` (sensação do Ember & Blade, qualidade do
Hades II, sem copiar), `docs/art/enemies_phase1.md`, `docs/art/boss_chamber_spec.md`, `docs/art/cycle12_arenas_spec.md`.

## Evidências

Capturas novas, todas na placa de vídeo (RTX 5060, Vulkan, Forward+, 1920 x 1080, `MIRROR=.../eterra-gpu-art`), guardadas
em `docs/gallery/cycle12c/visual_review/`. Nenhuma imagem gerada ou retocada; as folhas só juntam quadros ou recortes.

| Arquivo | Comando | O que mostra |
|---|---|---|
| `finalizador_salao_a.jpg`, `_b.jpg` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 -- --nosave --bot --autopick --seed=5 --bot-reaction=0.25 --frames=... --shot-at=6 --count=40 --every=0.033`, recorte 600 x 400 em (650, 300) | 40 quadros seguidos (cerca de 1 quadro do jogo cada): finalizador com brilho, meia-lua, golpe seguinte, corrida |
| `perto_cripta_a.jpg`, `_b.jpg` | o mesmo com `--arena=crypt --cam-dist=26 --shot-at=4 --count=48` | a luta de perto: herói, esqueletos, armas, avisos em linha, círculo de luz, especial e lascas |
| `especial_recorte.jpg`, `special_1080.jpg` | `RES=1920x1080 tools/gpu.sh shot ... --bot --autopick --seed=5 --shot-at=3 --shot-on=special --shot-after=0.05` | a Seta de Luz saindo |
| `omega_recorte.jpg`, `omega_1080.jpg` | o mesmo com `--shot-on=omega --shot-after=0.08` | o Ômega do ataque acertando três |
| `folha_descida.jpg`, `folha_partida.jpg` | `ffmpeg -vf "fps=12/<duração>,scale=640:-1,tile=3x4"` sobre `docs/gallery/cycle12c/before/descida_com_som.mp4` (245 s) e `/mnt/c/Users/danie/Videos/ASelagem/partida_ASelagem.mp4` (250 s) | as 7 salas e Morvath em 12 quadros (os tempos escritos nas folhas são do filtro, aproximados) |
| `corte_jardim_video.jpg` | `ffmpeg -ss 36.2 -t 0.8 ... crop=240:200:800:180,tile=6x4` sobre a descida | um corte no Jardim quadro a quadro (vídeo 720p, CRF 30) |
| `morvath_queimando.jpg` | quadros da descida aos 2:21, 2:45, 3:06 e 3:32, recorte 800 x 450 | Morvath com a queimadura e a meia-lua verde |
| `carta_dom_720.jpg` | quadro da descida aos 0:20,4 | a tela de escolha de dom |

Também revistas: `docs/gallery/enemies/` (os nove, Morvath e o herói lado a lado; `_todos_front`, `_todos_game`,
`skeleton_attack_side`, `mage_idle_front`), `docs/gallery/hero/` (`Slash_C_0`), `docs/gallery/boss_arena/03b_foice_golpe.jpg`,
`docs/gallery/cycle10/golpe_sofrido_comum.jpg`, `docs/gallery/cycle12_maps/crypt/vA_c_combate.jpg` e `rift/vA_c_combate.jpg`
(HEAD), `docs/gallery/cycle12c/work/ui_after_doors_1080.jpg`. Código lido para confirmar causas: `tools/bake.gd`
(quadros assados por clipe), `scripts/render/crowd_renderer.gd:242`, `scripts/game/horde.gd:245`.

Limites: o vídeo da descida é o "antes" do C12c (colunas brancas já corrigidas no HEAD; não as conto como problema). Os
dois vídeos são do robô, não de gente: servem para o visual, não para julgar a resposta do controle. Não medi pés
deslizando com número (só pelo código e a olho). Os vídeos `travessia.mp4` das arenas não foram decompostos nesta revisão.

## Resumo franco

O cenário está acima do resto: o salão, as Fendas, o Jardim e a Câmara do Selo têm personalidade, luz com intenção e
paleta coerente (fria com acentos quentes, violeta no abismo). Os modelos do Meshy (Explorador, os nove inimigos, Morvath)
têm silhueta e papel legíveis na câmera do jogo. O que está muito abaixo do Hades II é **o movimento e o impacto**: os
inimigos animam em poucos quadros sem mistura (parecem stop motion ao lado do herói), o corte comum da Emeth é uma folha
verde opaca solta no chão em vez de um rastro de luz preso à lâmina, as armas dos inimigos e de Morvath ainda são do
KayKit (outro estilo, desproporcionais), e alguns efeitos grandes (brilho do finalizador, avisos em linha empilhados,
queimadura em Morvath) cobrem justamente o que deveria ler.

### Os 5 problemas mais graves

1. **Inimigos e Morvath animados aos saltos** (alta). Cada clipe é assado em poucas poses e desenhado por
   `int(t * fps)` sem mistura entre elas (`crowd_renderer.gd:242`): andar 10 poses por ciclo, ataque 6 a 8, golpe sofrido 4,
   parado 4, morte 8 (`tools/bake.gd:82-87`, `125-258`; Morvath igual, `idle` 4 e `slash1` 8). Na tela, a 30 qps, o
   esqueleto troca de pose a cada 3 ou 4 quadros enquanto o herói (esqueleto animado de verdade) é liso: `perto_cripta_b.jpg`
   quadros 0 a 9 (esqueletos parados na mesma pose) e 24 a 47. O andar usa um passo genérico (`clip_rate` = velocidade / 2,3,
   preso entre 0,6 e 1,6, `horde.gd:245`): risco de pé deslizando no corredor (3,75 m/s) e no Ancião lento.
2. **Corte comum da Emeth: forma verde chapada e opaca, separada da lâmina** (alta). A fita do corte sai como uma folha
   cheia de verde saturado (pixels medidos em `cycle12_maps/crypt/vA_c_combate.jpg` e `rift/vA_c_combate.jpg`: R 26 a 64,
   G 110 a 232, B 35 a 127, saturação perto de 0,8), sem borda branca estourada, sem gradiente até a cauda e longe do
   arco que a espada desenhou: `finalizador_salao_b.jpg` quadros 7 a 9 (a espada já está embaixo à esquerda e a "folha"
   aparece 3 m à direita, sobre os inimigos), `corte_jardim_video.jpg` quadros 3, 4, 14, 15, a descida aos 0:36,3 e a
   luta de Morvath aos 2:21 (`morvath_queimando.jpg`, canto superior esquerdo). O guia pede tinta escura com a borda de
   ataque branca (seção 3 do `estetica.md`) e o verde-menta pálido da Emeth; hoje lê como um objeto, não como luz.
3. **Armas do KayKit nas mãos dos modelos do Meshy** (alta). O cutelo listrado do esqueleto (marrom e branco, blocado,
   maior que o tronco) em `perto_cripta_b.jpg` quadros 0 a 23 e `docs/gallery/enemies/skeleton_attack_side.jpg`; a lâmina
   do KayKit em Morvath, com a guarda em gancho amarelo vivo, em `boss_arena/03b_foice_golpe.jpg` e
   `cycle10/golpe_sofrido_comum.jpg` (o "C" amarelo junto ao quadril). Outro estilo (brinquedo de baixa contagem) colado
   em figuras pintadas; o amarelo do gancho fura a paleta de Morvath (violeta, ouro velho).
4. **Efeitos que cobrem o herói e o alvo** (média, sobe para alta em grupo). O brilho do finalizador (cruz, anel e risco)
   tem o anel maior que o herói, centrado no peito, por 5 a 6 quadros: `finalizador_salao_a.jpg` 11 a 16 e
   `perto_cripta_a.jpg` 0 a 3 (o herói some atrás da cruz). Avisos em linha dos besteiros em vermelho chapado quase opaco, três
   empilhados sob o herói: `perto_cripta_a.jpg` 0 a 15, `corte_jardim_video.jpg`, descida 0:20 (folha). O Ômega cruza o
   herói com o feixe mais claro da tela (`omega_recorte.jpg`), aceitável por ser raro.
5. **Morvath perde a cor dele quando queima** (média). Com um dom de fogo, a borda laranja e as brasas cobrem o manto
   violeta por boa parte da luta: `morvath_queimando.jpg` (2:45 e 3:32) e as folhas aos 3:03, 3:28 e 3:44. O chefe passa a
   ler vermelho-alaranjado, o oposto da direção (violeta profundo, verde espectral, ouro velho).

## Por área

Severidade: alta (abaixo da direção a ponto de o Daniel notar em segundos), média (nota-se na luta), baixa (acabamento).
"Sem modelo" = dá com shader, dado, assado ou cena; "com modelo" = precisa de Meshy (créditos do Daniel) ou animação nova.

### 1. Personagens e silhuetas

Bom:
- Explorador: cabelo ruivo, manto verde e a Emeth fazem uma silhueta que se acha na tela em todas as salas (`omega_1080.jpg`,
  `cycle12_maps/rift/vA_c_combate.jpg`); proporção adulta e esguia, nada de cabeçudo. Poses de golpe com bom arco do corpo
  (`docs/gallery/hero/Slash_C_0.jpg`).
- Os nove inimigos se distinguem pela silhueta e pela arma na câmera do jogo (`enemies/_todos_game.jpg`): escudo grande,
  cajado com orbe, besta, corpo curvado do corredor. Elites em ouro velho só no aço, guardiões maiores.
- Morvath: manto aberto, coroa pálida, violeta; o maior da tela sem ser caricato (`boss_arena/03b_foice_golpe.jpg`).

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-P1 | alta | Armas do KayKit nos modelos do Meshy (cutelo listrado do esqueleto, lâmina e gancho amarelo de Morvath, besta, cajado do mago) | `perto_cripta_b.jpg` 0 a 23; `enemies/skeleton_attack_side.jpg`; `cycle10/golpe_sofrido_comum.jpg` | Curto prazo: repintar no assado (`remap` do `held` em `tools/bake.gd`) para ferro escuro e osso sem listras, nenhum amarelo saturado (canal B acima de 0,35 do R no ouro), e reduzir o cutelo para no máximo 0,6 da altura do tronco; critério: em `enemy_lab` a arma não tem duas cores em faixas e o gancho de Morvath lê ouro velho (matiz 35 a 45, saturação até 0,5). Final: armas geradas no Meshy junto da prancha | sem modelo (paliativo); com modelo (final) |
| V-P2 | baixa | O cajado do mago estoura em branco na faixa da gema | `enemies/mage_idle_front.jpg` | Gema e anel do cajado com o maior canal até 235 a 1080 em `enemy_lab` | sem modelo |
| V-P3 | baixa | Herói e inimigos comuns quase da mesma altura na tela (herói 2,75 m); o Hades põe a heroína um pouco menor que os brutos | `_todos_game.jpg` | Nada agora; registrar para quando houver o modelo final do herói | n/a |

### 2. Animação (fluidez, antecipação, recuperação, pés, transições)

Bom:
- O herói é animado de verdade (esqueleto, clipes da Quaternius retargetados): corrida, guarda com a Emeth à frente,
  golpes com o corpo inteiro; a transição golpe para corrida é limpa (`finalizador_salao_b.jpg` 10 a 19).
- Antecipação do finalizador existe e se lê (`finalizador_salao_a.jpg` 3 a 10, a lâmina sobe e varre).

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-A1 | alta | Multidão e Morvath em poses assadas sem mistura: 10 por ciclo de andar, 4 no golpe sofrido, 4 parado | `crowd_renderer.gd:242`, `tools/bake.gd:82-87`; `perto_cripta_b.jpg` | (a) Assar mais poses: andar 20 a 24, ataque 14 a 16, golpe sofrido 8, parado 12, morte 16 (custa memória: medir o pacote, hoje cerca de 44 MB de assados) e (b) misturar a pose atual com a seguinte no vértice (duas posições por instância e `fract(t * fps)`), ou passar Morvath e guardiões (poucos na tela) para esqueleto animado de verdade. Critério: num vídeo a 30 qps, nenhum inimigo andando repete a mesma pose em 2 quadros seguidos | sem modelo |
| V-A2 | média | Passo do andar genérico (velocidade / 2,3), não medido por clipe como o do herói (`RUN_CLIP_PACE`) | `horde.gd:245` | Medir o passo de cada clipe de andar no assado (como `bake_hero.gd` faz) e guardar no `BakedModel`; critério: o pé de apoio desliza menos de 5 cm por passo no `enemy_lab` com chão quadriculado | sem modelo |
| V-A3 | média | Reação ao golpe pouco visível no corpo: o pisca morno lê, o recuo (`RECOIL_TILT`) quase não; 4 poses de `hit` | `perto_cripta_b.jpg` 10 e 11, `finalizador_salao_b.jpg` 7 e 8 | Junto do V-A1: golpe sofrido com 8 poses e um empurrão de 0,15 a 0,3 m no sentido do corte que se vê em 3 quadros; critério: em `--shot-on=hit` seguido de 6 quadros, o alvo se desloca e volta | sem modelo |
| V-A4 | baixa | Pose final do golpe do finalizador segura o braço esticado por cerca de 6 quadros antes do brilho (lê como parada, não como carga) | `finalizador_salao_a.jpg` 0 a 9 | Ajustar com o gameplay-engineer depois do V-E1: o brilho cresce desde o começo da pausa e o corpo recua 5 a 10 cm (carga), em vez de ficar parado | sem modelo |
| V-A5 | média | Morvath sem clipes próprios: ataques são golpes de espada genéricos e feitiços do KayKit (`slash1`, `rain`, `roar`) | `tools/bake.gd` (bloco de Morvath); `enemies/morvath_*` | Clipes CC0 mais pesados (Quaternius UAL tem golpe de duas mãos e lançamento) para foice e tempestade; o final pede animação feita para ele | com animação nova |

### 3. Efeitos dos golpes (impacto, rastro, flash, partículas)

Bom:
- O Ômega do ataque é o melhor efeito do jogo: feixe para frente e para trás, veios de ouro, alvo pisca morno, números
  verdes grandes (`omega_recorte.jpg`).
- Pisca do inimigo morno e abaixo do glow, nada de bola branca (`perto_cripta_b.jpg` 10 e 11, `finalizador_salao_a.jpg` 13).
- O brilho do finalizador tem a forma certa do guia (cruz, risco longo, anel) e a meia-lua do finalizador cresce e some
  no tempo pedido.

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-E1 | alta | Fita do corte comum é uma folha verde saturada e opaca, sem borda clara, longe do arco da lâmina | ver problema 2 do resumo | `slash.gdshader`: corpo em tinta escura translúcida (alfa até 0,6, valor até 0,25), borda de ataque fina marfim-menta (maior canal 230 a 255 só nos 2 a 4 px da borda), cor do miolo no verde da Emeth pálido (saturação até 0,45); a fita começa na ponta da espada no quadro em que o golpe sai e varre junto com ela por 2 a 3 quadros. Critério: em `--shot-on=hit --shot-after=0.033`, menos de 15% dos pixels da fita com saturação acima de 0,6, e a ponta da fita a menos de 0,5 m da ponta da Emeth | sem modelo |
| V-E2 | média | Brilho do finalizador cobre o herói (anel maior que ele, no peito) | `finalizador_salao_a.jpg` 11 a 16; `perto_cripta_a.jpg` 0 a 3 | `Fx.GLINT_SIZE` menor (anel com raio até 0,6 da altura do herói) e o centro na ponta da espada, nunca no torso; cruz com miolo transparente. Critério: no quadro do brilho, a cabeça e o tronco do herói visíveis (nenhum pixel do anel sobre a caixa do corpo com alfa acima de 0,5) | sem modelo |
| V-E3 | média | Lascas como pontos redondos brancos que ficam 10 ou mais quadros no ar | `perto_cripta_b.jpg` 14 a 23; `finalizador_salao_a.jpg` 0 a 9 | Lascas alongadas na direção do corte (2:1 a 4:1), marfim a cinza, vida até 0,25 s; critério: nenhuma lasca visível 8 quadros depois do golpe | sem modelo |
| V-E4 | baixa | O especial (Seta de Luz) é um traço fino; lê, mas sem peso no acerto | `especial_recorte.jpg` | Manter a forma; acerto com a estrela furada mais visível (já existe `SPECIAL_STAR`): conferir em `--shot-on=hit` com o especial | sem modelo |

### 4. Magias e habilidades

Bom: círculo de luz lê como zona; colunas e gemas já limitadas no HEAD (GP-01); escudo do ritual e runas de Morvath
dentro da paleta (`boss_arena/`, ciclo 10).

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-M1 | média | Círculo de luz: aro marfim grosso e opaco de 5,4 m por 3 s, lê como marca de interface por cima dos corpos | `perto_cripta_b.jpg` (todo), `special_1080.jpg`, `rift/vA_c_combate.jpg` | Aro com alfa até 0,45, metade da espessura, e os traços girando mais finos; critério: um esqueleto em pé sobre o aro continua com os pés legíveis | sem modelo |
| V-M2 | média | Dons de fogo pintam Morvath de laranja | `morvath_queimando.jpg` | Em Morvath e guardiões (`BOSS`): borda de fogo até 0,25 e brasas pela metade; a cor dele sempre ganha. Critério: no meio da fase 3 queimando, a mediana do manto continua com matiz entre 260 e 300 | sem modelo |
| V-M3 | baixa | Ícones dos dons (riscos, coração, estrela em disco dourado) genéricos para o peso do momento | `carta_dom_720.jpg` | Ícones pintados por família (Luz, Geada, Fogo) num só estilo; é tarefa do ui-ux-designer com uma folha de referência minha | com arte nova (2D) |

### 5. Leitura do combate e avisos

Bom: herói sempre achado (anel petróleo, cabelo); barras finas sobre os inimigos; números com soma; vermelho reservado ao
perigo.

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-L1 | média | Avisos em linha e retângulo vermelho chapado, alfa alto, empilhando em massa vermelha sob o herói | `perto_cripta_a.jpg` 0 a 15; `especial_recorte.jpg`; descida 0:20 | Preenchimento com alfa até 0,35 que sobe só nos últimos 30% do preparo, borda e divisa como já desenhadas; sobreposição por máximo e não por soma; critério: três avisos sobrepostos não passam do alfa de um aviso cheio, e o anel do herói continua visível dentro deles | sem modelo |

### 6. Morvath e a Câmara do Selo

Bom: a câmara é a sala mais forte (céu azul-marinho, abismo violeta, selo de ouro velho com o leão, balaustrada de velas);
a foice em setor ciano e as runas leem (`boss_arena/03b_foice_golpe.jpg`).

Problemas: V-P1 (lâmina e gancho amarelo), V-A1 e V-A5 (animação), V-M2 (queimadura). A meia-lua verde do herói contra
ele (descida 2:21) tem o mesmo defeito do V-E1.

### 7. Cenários, luz e materiais

Bom:
- Salão: composição da pintura, portal verde, estátuas, abismo petróleo e violeta; pedra triplanar coerente.
- Fendas e Jardim: matiz próprio do ar, árvore com presença, luz violeta de baixo nas bordas (`folha_descida.jpg`, 0:20 e 0:40).
- Câmara do Selo: a melhor luz do jogo.

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-C1 | média | Velas demais no salão: cerca de 15 grupos e braseiros acesos espalham pontos quentes por toda a borda; o guia pede quente só como acento | `omega_1080.jpg`, `special_1080.jpg` | Tirar ou apagar metade dos grupos da borda leste e sul (ficam os do altar e dos braseiros); critério: fração de pixels quentes saturados (R acima de 200 e B abaixo de 120) na vitrine cai pela metade sem baixar a mediana do chão abaixo de 45 | sem modelo |
| V-C2 | média | Peças do KayKit (blocos chanfrados, escadas, caixotes, velas grossas) ao lado de personagens pintados; o cenário é "brinquedo bem iluminado" e os personagens são pintura | todas as capturas | Já se compensa com `Masonry`; o resto pede peças próprias (balaústre, sarcófago, vela, braseiro) no Meshy, uma família por vez, começando pelo que aparece em todas as salas (velas e balaustradas) | com modelo |
| V-C3 | baixa | Cripta ainda é a sala mais escura nas bordas (o HEAD subiu o chão da luta para 45 a 60; as bordas oeste e norte seguem pretas) | `cycle12_maps/crypt/vA_c_combate.jpg` | Conferir de novo depois do ENV-01 com os recortes do `BEFORE.md`; nada novo agora | n/a |

### 8. Interface

Bom: HUD discreto e coerente (medalhão, barras com ponta, losangos com a tecla real); placas das portas novas (UI-01)
legíveis; barra de Morvath com fases.

Problemas:
| Id | Sev. | Problema | Evidência | Proposta verificável | Tipo |
|---|---|---|---|---|---|
| V-U1 | média | Marcador `PALADIN_4` e `PALADIN_3` aparece para o jogador na carta de dom ("Luz, dom de PALADIN_4") | `carta_dom_720.jpg` | Enquanto o Daniel não define os nomes, esconder a linha "dom de X" ou trocar por um texto neutro em `text_pt.tres` (não inventar nome) | sem modelo |
| V-U2 | baixa | Retrato do medalhão é ilustração anime da arte do título; o boneco 3D é outro rosto e outro estilo | `ui_after_doors_1080.jpg` (canto inferior esquerdo) | Retrato a partir de uma captura do próprio Explorador com luz de estúdio, pintado por cima no mesmo estilo da HUD | com arte nova (2D) |
| V-U3 | baixa | Contador de golpes e nome do golpe grandes à direita, em Cinzel, competem com a luta ("6 GOLPES", "GIRO DA ALVORADA") | `boss_arena/03b_foice_golpe.jpg` | Altura do número até 48 px a 1080 e o nome do golpe com alfa 0,7 | sem modelo |

## O que fazer sem modelo novo (ordem sugerida)

1. V-E1 fita do corte (environment-artist no shader `slash.gdshader`; gameplay-engineer só se a fita precisar seguir a
   ponta da espada pelo `Combat`).
2. V-A1 e V-A3 mais poses e mistura entre poses (gameplay-engineer no `crowd.gdshader` e `CrowdRenderer`, environment-artist
   no `tools/bake.gd`), medindo memória e quadro com o qa-performance.
3. V-P1 paliativo das armas do KayKit (repintura e escala no assado).
4. V-E2 brilho do finalizador, V-L1 avisos, V-M2 queimadura no chefe, V-M1 círculo de luz, V-E3 lascas.
5. V-U1 marcador na carta (ui-ux-designer), V-C1 velas do salão (environment-artist).

## O que só melhora com modelo ou animação nova

- Armas próprias dos inimigos e de Morvath (Meshy; hoje KayKit). Depende dos créditos do Daniel (546 restantes).
- Clipes de Morvath e dos guardiões feitos para eles (foice, tempestade, ritual); paliativo CC0 da Quaternius.
- Peças de cenário próprias no lugar do KayKit (velas, balaustradas, sarcófagos, braseiros).
- Ícones dos dons e retrato do medalhão (arte 2D própria).

## Veredito

Não aprovado como "excelência visual" da diretriz. Cenário e silhuetas estão no caminho; animação da multidão, o corte
comum e as armas do KayKit estão muito abaixo do Hades II e se notam em segundos de luta. Os itens V-E1, V-A1 e V-P1
(paliativo) dão para fazer sem créditos e são os que mais mudam a sensação; depois deles, refazer as mesmas capturas
(`--frames` com `--cam-dist=26` na Cripta e no salão, `--shot-on=hit`, `--shot-on=omega`) e comparar quadro a quadro. A
aprovação artística final é do Daniel.
