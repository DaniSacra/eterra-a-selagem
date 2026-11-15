# Ciclo 6: revisão final do Art Director (2026-11-15)

HEAD revisado: `78b0642` (branch `arpg-3d`). Especificação: `docs/art/cycle6_spec.md`. Meta:
`docs/art/ref/arena_catacumbas_1672.png` e `docs/art/ref/inimigos_fase1.png` (fora do git).

## 1. Evidência

Capturas próprias na placa (RTX 5060 Laptop, Vulkan Forward+, 1672 x 941, `tools/gpu.sh shot`), no scratchpad da
sessão, pasta `final/ad/` (fora do git):

| Arquivo | Comando | `fps` |
|---|---|---|
| `vitrine.png` | `--showcase --seed=5 --shot-at=4` | 60 |
| `vitrine_t2.png` | `--showcase --seed=5 --shot-at=2` | (compilando shaders) |
| `luta.png` | `--bot --autopick --seed=5 --shot-at=9` | 60 |
| `luta_s7_t20.png` | `--bot --autopick --seed=7 --shot-at=20` | 60 |
| `medalhao.png` | `--showcase --cam-dist=32 --seed=5 --shot-at=2` | (compilando shaders) |
| `boss.png` | `--start=boss --bot --autopick --seed=5 --shot-at=12` | 60 |

Recortes lado a lado (pintura à esquerda): `cmp_topleft.png`, `cmp_facade.png`, `cmp_east.png`, `cmp_firenw.png`,
`cmp_sw.png`. Recortes ampliados: `crop_roxo.png`, `ref_roxo.png`, `crop_gigante.png`, `crop_estandarte.png`,
`crop_esquerda.png`, `crop_boss_leste.png`, `crop_runas.png`, `crop_luta_inimigos.png`, `crop_luta_esq.png`.
Antes (HEAD `5694624`): `antes_vitrine.png`. Medidas com os scripts da seção 0 da especificação.
Não refiz: desempenho (vale a medida do Environment Artist, +0,04 ms na luta), navegador, 1920 x 1080.

## 2. Medidas na vitrine (antes, agora, aceite, pintura)

| Medida | Antes | Agora | Aceite | Pintura |
|---|---|---|---|---|
| Critérios globais do ciclo 3 | 8 de 11 | 10 de 11 | >= 10 | 11 |
| p50 / p95 / p99 | 43,7 / 107,3 / 168,0 | 43,7 / 106,9 / 176,0 | 42 a 50 / >= 108 / >= 182 | 45,5 / 116,2 / 201,0 |
| Parcela L > 200 | 0,38% | 0,47% | 0,6% a 1,1% | 1,08% |
| Azul saturado acima de y 160 | 3,0% | 0,12% | <= 0,3% | 0,0% |
| Bruma alta: média / desvio / detalhe | 37,1 / 16,4 / 5,41 | 58,6 / 31,9 / 8,62 | 48 a 62 / >= 22 / >= 6,5 | 58,1 / 27,1 / 7,90 |
| Janelas chapadas, vitrine / luta | 11 / 21 | 7 / 9 | <= 5 / <= 8 | 3 |
| Detalhe da faixa alta, vitrine / luta | 9,14 / 7,56 | 8,75 / 7,52 | >= 10 / >= 9 | 10,48 |
| Azul sob o arco central | 2,5% | 10,9% | >= 20% | 35,3% |
| Azul na coluna esquerda | 2,5% | 8,9% | >= 10% | 16,2% |
| Esquerda, L < 25 | 31,8% | 33,3% | <= 26% | 22,6% |
| `abyss_left_cols` mediana / detalhe | falha / 4,19 | passa / 4,35 | passa / >= 5,0 | 5,58 |
| Miolo dos braseiros (NO, N, L, SE) | 0 / 306 / 0 / 0 | 0 / 159 / 0 / 0 | >= 150 cada | 355 / 263 / 275 / 566 |
| L máximo dos braseiros | 217 / 251 / 145 / 212 | 217 / 251 / 153 / 218 | >= 245 cada | 251 a 254 |
| Velas, pixels oliva (5 caixas) | 0 / 15 / 0 / 0 / 473 | 0 / 1 / 0 / 3 / 627 | 0 | 0 |
| `floor_clean_b` média | 66,3 | 61,0 | 48 a 58 | 50,1 |
| `portal_open` mediana de L; L > 200 | 163; 0% | 168; 0% | >= 180; >= 15% | 195; 27,5% |
| Cantos de cima do vão do portal, verde claro | 51% / 15% | 0% / 0% | <= 10% | 2% / 1% |
| Estandarte esquerdo / direito, vermelho | 0% / 0% | 56,7% / 0% | >= 30% / >= 4% | 37% / 5,6% |
| `facade` green | 0,161 | 0,209 | <= 0,20 | 0,131 |
| Medalhão a 32 m: parcela escura; desvio | 14,3%; 20,3 | 18,2%; 20,4 | >= 20%; <= 24 | |

## 3. Causa comum de seis falhas: a vinheta da tela

`assets/shaders/screen.gdshader` multiplica a imagem final por `1 - v * 0,55`. Pela fórmula do shader, o fator é
0,84 nos braseiros noroeste e sudeste, 0,82 no portal, 0,56 no braseiro leste, 0,51 no estandarte direito e 0,64
no grupo de velas do oeste. O L máximo de 217 do braseiro noroeste dividido por 0,84 dá 258: o miolo sai branco do
cenário e a vinheta o apaga. O mesmo vale para o portal (G 207 a 216 na tela) e para o estandarte direito (R 83 na
tela, cerca de 164 antes da vinheta). O braseiro norte, perto do centro, é o único que passa. Miolo do fogo, L
máximo, portal, p99, parcela L > 200 e estandarte direito falham por isso, não pelo cenário.

## 4. Veredito por item

| Item | Veredito | Observação |
|---|---|---|
| A1 massas próximas (ponte, torre, portão, pilone) | manter, com as correções 3 e 6 | sem fileira de pilares iguais, sem pilar claro em primeiro plano |
| A2 cartões de ruína | manter | três topos de torre de alturas diferentes atrás do plano próximo; os dentes do teto de caverna são regulares (prioridade baixa) |
| A3 bruma e violeta | manter, com as correções 2, 3 e 6 | azul no alto resolvido; bruma dentro do alvo |
| Lanterna | manter | laranja, uma travessa e um montante; centro em cerca de (125, 295), 3 px além da tolerância em y |
| B1 chama | manter, com a correção 1 | miolo fixo funciona; a forma é uma ponta única (lê como chama de vela grande), sem línguas laterais: prioridade baixa |
| B2 velas | manter | círios grossos e creme; o aro amarelo da poça de cera lê um pouco como marcador (prioridade baixa); oliva no grupo oeste: medir de novo depois da correção 1 |
| C medalhão | manter | runas legíveis a 32 m (7 glifos contáveis no arco de baixo), parcela escura a 1,8 ponto do aceite; aviso vermelho contínuo por cima |
| D luz | corrigir (correção 1) | ver seção 3 |
| E1 portal em arco de ponta | manter | vértice visível, dentes acompanham, o vermelho de Morvath usa a mesma máscara; cor ainda puxa para o ciano (correção 7) |
| E2 estandartes | manter, com a correção 5 | lugar e comprimento da pintura; sem emblema (pergunta ao Daniel aberta) |
| E3 estátuas | corrigir (correção 4) | silhueta larga e alta como pedido; a cabeça lê como disco claro com aro escuro |
| E4 pedestal do gigante | manter | pilha de blocos, topo escuro |
| E5 caixotes, E6 pé da escada, E7 potes | manter | sem moldura azul; entulho trocado por caixotes, pote e velas |
| `camera.far = 160` (`game.gd:246`) | manter | nenhum corte de cartão nas seis capturas; os cartões ficam a 98 a 120 m |
| Arco noroeste coberto pela balaustrada | aceitar | a pintura também cobre o pé do arco com a balaustrada; não mover o portão nem a balaustrada |
| Reverter | nada | |

## 5. Correções pedidas (por prioridade)

1. **Vinheta poupa os claros** (`assets/shaders/screen.gdshader`, linha `c *= 1.0 - v * vignette;`; dono: Game
   Director decide, o arquivo é da tela inteira). Trocar por
   `c *= 1.0 - v * vignette * (1.0 - smoothstep(0.6, 1.0, max(c.r, max(c.g, c.b))));` e baixar `vignette` de 0,55
   para 0,45. Aceite na vitrine: miolo >= 150 e L máximo >= 245 nos quatro braseiros; `portal_open` L > 200 >= 15%;
   p99 >= 182; p50 dentro de 42 a 50 e parcela L < 20 dentro de 9% a 17%; estandarte direito >= 4% de vermelho (se
   não chegar, subir `ArenaKit.BANNER_GLOW`). Não testado: medir antes de aceitar.
2. **Painel violeta do leste com borda reta** (`boss.png`, `crop_boss_leste.png`: borda esquerda e de baixo retas,
   textura em facetas, em (1400,500)-(1672,780)). Falha o critério "bordas de cartão" da seção A. Vem do ciclo 5;
   o `ragged * 1.6` deste ciclo deixa o cartão com brilho até a borda do quadrilátero. Em
   `assets/shaders/abyss_glow.gdshader`: multiplicar `h` por `smoothstep(0.5, 0.38, abs(UV.x - 0.5))`, `foot_fade`
   de 0,12 para 0,3, e alargar o corte dos farrapos (`keep`: de +-0,15 para +-0,3). Aceite: nenhuma borda reta em
   `--start=boss --bot --autopick --seed=5 --shot-at=12`. Dono: Environment Artist.
3. **Forma roxa atrás da balaustrada noroeste** (`crop_roxo.png` contra `ref_roxo.png`). É o arco do portão central
   (`GATE_ARCH`) com o cartão violeta por trás (primeira linha de `GLOW_WEST`). Está no lugar certo, mas é um violeta
   chapado e saturado (reach 1,0, falloff 1,2, energia 1,0) num recorte com degraus (topo estreito, corpo largo),
   sem nada dentro; a pintura tem um arco curvo com névoa violeta em gradiente e fustes escuros dentro. Em
   `scripts/game/catacomb_hall.gd`: nessa linha de `GLOW_WEST`, energia 1,0 para 0,6 e falloff 1,2 para 2,0; dois
   fustes finos na cor `GATE_PASSAGE` entre o portão e o cartão; conferir os cantos (`corner` em `_gate`) para o
   vão seguir a curva do anel. Aceite: no recorte 4x, contorno curvo sem degrau, topo do violeta mais escuro que o
   pé, pelo menos um fuste escuro dentro; azul sob o arco pode ficar entre 10% e 20% (a meta de 20% contava com um
   vão maior do que a balaustrada deixa ver). Dono: Environment Artist.
4. **Rosto das estátuas** (`crop_gigante.png`): `Masonry.MASK` é desenhada em branco e lê como um disco claro dentro
   de um aro escuro. Em `scripts/game/masonry.gd` (`_build_statue`, linha da `MASK`): tirar a máscara ou pintá-la
   com `stone_v * 0.3`, para o vão do capuz ser a parte mais escura da figura. Aceite: recorte 4x do gigante e das
   duas estátuas do portal sem pixel mais claro que o capuz dentro do vão. Provisório até a estátua do Meshy.
5. **Triângulos escuros nos estandartes** (`crop_estandarte.png`): uma fileira de 3 ou 4 furos triangulares perto
   da barra em ponta, nos dois estandartes. `ArenaKit.banner` (`scripts/game/arena_kit.gd`, linhas 199 a 232):
   conferir o sentido dos triângulos do friso da ponta e o descarte de faces do material. Aceite: pano inteiro no
   recorte 4x.
6. **Frestas violeta entre os pilares da ponte oeste** (`crop_esquerda.png`: duas faixas verticais retas e claras em
   x 165 a 185 e 222 a 235 da vitrine). `BRIDGE_PIERS`: tirar o pilar fino de -20,35 (um vão só, com arco) e baixar
   a energia da terceira linha de `GLOW_WEST` de 0,85 para cerca de 0,55. Aceite: nenhuma faixa vertical de borda
   reta com mais de 150 px de altura; esquerda com L < 25 em <= 30%.
7. **Verde do portal** (`cmp_facade.png`): miolo #4bd78a a #6bd8b1, a pintura é #33f953. `ArenaKit.PORTAL_SHEET`
   (0.22, 1.0, 0.34) com menos azul no miolo claro do `portal.gdshader`; se o `facade` green passar de 0,22 depois
   da correção 1, baixar `ArenaKit.PORTAL_LIGHT` de 3,5 para cerca de 3,1.

Prioridade baixa, sem bloquear: fiadas visíveis na face do portão central (as 6 janelas chapadas em x 456 a 528,
y 144 a 216), dentes do teto de caverna irregulares, línguas laterais na chama, aro da poça de cera sem brilho.

Para o QA: as primitivas da luta foram de 678 mil para 930 mil (as da vitrine ficaram em 69 mil). Na RTX o custo
medido foi +0,04 ms; conferir de onde vêm (velas nas sombras dos braseiros?) antes de mirar placa fraca ou navegador.

## 6. Inimigos e herói contra a prancha

Esqueleto de Escudo em `crop_luta_inimigos.png`: caveira de marfim, tabardo carmesim, metal escuro e escudo torre,
como na prancha, na proporção adulta do herói; barra de vida e aviso vermelho legíveis; herói com anel petróleo.
Diferença registrada: a prancha pinta a magia do Feiticeiro em verde; o jogo usa violeta frio (regra do projeto:
verde só da Emeth e do portal). Decisão do Daniel, não é pedido de correção.

## 7. Ciclo 6 (Fable) contra o ciclo 5

Melhorou, com captura que mostra: abismo (a nave de pilares iguais e as faixas azuis até o topo sumiram; bruma na
média da pintura), velas (círios grossos, creme), portal em arco de ponta, estandartes no lugar e no tamanho,
caixotes sem moldura azul, pé da escada, silhueta do gigante, runas do medalhão, inimigos e espada do Meshy.
Critérios globais de 8 para 10 de 11. Não melhorou: topo da curva de luz (vinheta), detalhe da faixa alta, lado
esquerdo escuro (31,8% para 33,3%), verde da fachada (0,161 para 0,209), oliva nas velas do oeste. Defeitos novos:
rosto das estátuas, furos nos estandartes, arco roxo chapado, frestas da ponte.

## 8. Veredito

Nada a reverter. **Ainda não aprovado para o teste do Daniel**: as correções 1 a 5 são pequenas e tratam de coisas
que ele vê nos primeiros segundos (cabeça do gigante, forma roxa, painel na sala de Morvath, fogo sem miolo fora do
centro). Com elas aplicadas e recapturadas, aprovado como a versão do ciclo 6, sem declarar fidelidade alta:
estátuas, moldura do portal, obeliscos, braseiros e ruínas seguem provisórios até os modelos do
`meshy_asset_plan.md`. A aprovação final é do Daniel.

Steam: nada novo a declarar neste ciclo de cenário (sem IA, sem recurso externo novo).
