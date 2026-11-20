# Revisão de arte e de layout: o hub (Santuário) e a composição de tela, build `d2ff05d`

Autor: `art-director`, 2026-11-19. Contexto: o Daniel testou esse build e disse "ainda precisa de muitas melhorias".
**A aprovação artística final é dele.** Esta revisão é sobre **layout**: composição, escala, vazios, repetição, leitura
de estação e de porta, e o que ainda lê como protótipo.

## Material

- Spec: `docs/design/hub_spec_art.md` (HUB-A, escrita para um chão de 25 x 16,5 m; o hub de hoje tem 50 x 33 m,
  `HubPlan.HALF_U` 25, `NORTH`/`SOUTH` ±16,5, `CAM_REACH` 16).
- Capturas que já existiam: `b2/` (vitrine, cinco estações a 720, clássico, Compatibility) e `ui/` (placas, painéis,
  Livro, menu).
- **Capturas novas minhas** (RTX 5060, Forward+, 1920 x 1080, `--look=stylized` como o exe, semente 5, numa cópia
  isolada do `d2ff05d`), em `review/`:
  - `review/d2ff05d_sty_hub_arrival_far.jpg` (`--hub --shot-at=2`)
  - `review/d2ff05d_sty_hub_portal_far.jpg` (`--hub --hero-at=portal`)
  - `review/d2ff05d_sty_hub_smith_far.jpg` (`--hub --hero-at=smith`)
  - `review/d2ff05d_sty_hub_arrival_near.jpg` (`--hub --cam=near`)
  - `review/d2ff05d_sty_jogo_near.jpg` (`--bot --autopick --cam=near --shot-at=9`, Salão em luta)
- Medida (`tools/frame_stats.py --hue --scene`): chegada, câmera Longe: cena matiz 38, sat p50 0,22, luma p50 81, quente
  3,6% (alvo 4.2 da spec: 25 a 45 / 0,10 a 0,22 / 62 a 78 / 6 a 14%); caixa do portal (860, 0, 200, 90): verde 52%.
  Chegada, câmera Perto: quadro luma p10 **9** (o muro escuro da torre).
- Nenhuma imagem gerada por IA foi usada como evidência. As referências H1 a H3 só locais.

## Veredito

**Não aprovado para o próximo teste do Daniel como está.** A paleta e a luz estão na direção certa (pátio morno, sombra
petróleo, portal o único verde) e a interface das placas e das páginas está boa. O que falha é o layout: o hub dobrou de
tamanho (pedido do Daniel) mas as peças ficaram do tamanho antigo e foram empurradas para as bordas. O resultado é uma
praça vazia de lajes ocupando 60 a 70% de toda tela, com as estações pequenas, cortadas pela borda do quadro e sem
"lugar" próprio. Isso é exatamente o que lê como protótipo.

## Diferenças por prioridade

### P0 (bloqueiam o teste)

| Id | O que a captura mostra | Captura | Dono |
|---|---|---|---|
| H-P0-1 | **O portal sai do quadro.** Na chegada e em toda estação com a câmera Longe a soleira fica em y 0,08 e o arco é cortado pelo topo da tela; a spec pedia soleira em y 0,22 a 0,32 com a moldura inteira (A1). No ponto de uso do portal o herói está 6 a 7 m à frente do degrau, e a placa "Portal da Descida" flutua sobre a fonte, longe do portal. O destino do hub nunca é visto inteiro | `review/d2ff05d_sty_hub_arrival_far.jpg`, `_portal_far.jpg`, `b2/at_*_720.png` | gameplay-engineer (câmera do hub e ponto de uso), environment-artist (posição do portal) |
| H-P0-2 | **Câmera Perto no hub mostra o muro.** Na chegada, 45% da tela é o paredão escuro da torre abaixo da mureta (luma p10 9), o herói fica a 1 m da balaustrada e o portal não aparece. A Perto segue o herói sem o limite de borda que a Longe tem | `review/d2ff05d_sty_hub_arrival_near.jpg` | gameplay-engineer (`CamRig.near` no hub: segurar a borda sul como a Longe, ou chegada mais ao norte) |
| H-P0-3 | **Praça vazia.** Entre a fonte e as quatro estações há 15 a 20 m de laje sem nada (só quatro velas em pedestal iguais, dois bancos e dois "canteiros" que leem como caixões com pontos). Na chegada, o chão sem peça é cerca de 65% do quadro; da chegada ao Vendedor são uns 28 m (4 s) e do Vendedor ao Livro 46 m (quase 7 s), contra o teto de 3 s da spec 2.5 | `review/d2ff05d_sty_hub_arrival_far.jpg`, `b2/hub_overview_1080.png` | environment-artist (praça), room-designer/gameplay-engineer (distâncias) |
| H-P0-4 | **Estações sem lugar e pequenas demais.** Vendedor: barraca com toldo da altura do herói, encostada na parede, metade fora do quadro na chegada. Forjador: só uma bigorna de 0,9 m e um poste; o forno some atrás da parede oeste; não há fogo nem fumaça visíveis do ponto de uso. Livro: atril pequeno no canto, lê como mesinha. Só a Árvore tem silhueta própria. Nenhuma estação tem nicho, piso, cobertura ou luz que a separe da praça (princípio R3 e R4 da spec) | `review/d2ff05d_sty_hub_smith_far.jpg`, `b2/at_vendor_720.png`, `b2/at_book_720.png` | environment-artist |

### P1 (corrigir neste ciclo)

| Id | O que a captura mostra | Captura | Dono |
|---|---|---|---|
| H-P1-1 | **Lajes a 35 graus das paredes.** As fiadas e as lajes correm na diagonal do quadro enquanto fachada, mureta e escadas são retas na tela: o chão parece escorregar. Pendência conhecida (`frame_yaw`), mas com 65% da tela em chão é o defeito mais visível do hub | todas | technical-artist (`frame_yaw` no `masonry.gdshaderinc` e no `catacomb_floor.gdshaderinc`) |
| H-P1-2 | **Fios de ouro que param no nada.** Os "fios para as estações" saem do anel da fonte, atravessam a praça e terminam no meio da laje, longe da estação; finos (2 a 3 px) e retos, leem como linha de depuração | `review/d2ff05d_sty_hub_arrival_far.jpg` | environment-artist (ou ir até a laje de uso de cada estação, com 2 a 3 vezes a largura e um losango no fim, ou tirar) |
| H-P1-3 | **Leões do portal não leem.** As duas estelas no terraço viraram pedestais pequenos com um relevo branco no alto; a 1080 leem como coelho ou cachorro sobre um marco. A spec pedia leão de 4 m com a cabeça em blocos (3.1) | `review/d2ff05d_sty_hub_portal_far.jpg` | environment-artist (escala 2x e cabeça; Meshy do leão sentado só com o Daniel, 15 créditos, Q-H6) |
| H-P1-4 | **Repetição sem hierarquia.** Quatro pedestais de vela iguais em losango, dois bancos iguais, dois "canteiros" iguais, quatro postes iguais, oito figuras encapuzadas iguais nos nichos da fachada: tudo em simetria perfeita e do mesmo tamanho. A praça lê como planta de teste | `review/d2ff05d_sty_hub_arrival_far.jpg` | environment-artist |
| H-P1-5 | **Fonte pequena para a praça.** Bacia de 2,8 m no meio de 50 m: lê como poço, não como centro. O leão do chão (medalhão sem anel visível) fica solto entre a fonte e a chegada | `review/d2ff05d_sty_hub_arrival_far.jpg` | environment-artist |
| H-P1-6 | **A vista geral é uma caixa sobre uma torre.** Na vitrine o hub é um bloco retangular sobre um paredão de tijolos lisos e escuros, cercado de silhuetas azuis recortadas; sem ruína, ponte, escada ou vegetação descendo. Lê como maquete | `b2/hub_overview_1080.png` | environment-artist |
| H-P1-7 | **Quente abaixo da meta** (3,6% contra 6 a 14%): os fogos estão nas bordas e cortados; a praça do meio não tem luz quente nenhuma | medida acima | environment-artist |

### P2

| Id | O que | Captura | Dono |
|---|---|---|---|
| H-P2-1 | Árvore de Dons: folhas em pontos de ouro miúdos leem como ruído (pipoca) a 1080; agrupar em massas maiores, menos cartões | `b2/at_tree_720.png` | environment-artist |
| H-P2-2 | Estela da fonte com o leão branco-prateado; o resto do leão do hub é ouro velho | `review/d2ff05d_sty_hub_arrival_far.jpg` | environment-artist |
| H-P2-3 | Escada de chegada desce até uma grade fechada logo abaixo: lê como beco. Melhor uma escada que some na bruma ou numa ponte | `review/d2ff05d_sty_hub_arrival_near.jpg` | environment-artist |
| H-P2-4 | Placa "Vendedor / A definir": correta, mas com o Vendedor sem NPC e sem mercadoria legível a estação parece quebrada; até o HUB-D, mercadorias maiores no balcão | `b2/at_vendor_720.png` | environment-artist |

## Interface (placas, painéis, Livro)

| Bate | Difere |
|---|---|
| Uma placa só, da estação em foco, com a tecla real; legível a 720 (`ui/sign_*`) | Placa do portal sobre a fonte, longe do portal (consequência de H-P0-1). Com o portal no quadro, a âncora volta ao terço de cima |
| Folha "Descer às catacumbas?" limpa, Descer em destaque (`ui/panel_portal_720.jpg`) | Os painéis do Vendedor e do Forjador ("A definir") são honestos, mas três de cinco estações sem função deixam o hub com cara de esqueleto: isso é de produto, não de arte (Game Director) |
| Livro de Ahk: retrato, Arma, Estilo, Habilidades, os três lugares selados sem rosto (`ui/book_hero_720.jpg`) | nada |

## Composição de tela no jogo (HUD e câmeras)

- **Câmera Longe** nas salas (`docs/gallery/redesign/sworn_p1/after_*`, `rs_c1/after_game_*`): sala inteira, herói
  com cerca de 120 px a 1080, HUD nas bordas sem cobrir o chão de luta. Aprovado.
- **Câmera Perto** nas salas (`review/d2ff05d_sty_jogo_near.jpg`, `camera_near/*`): o herói lê grande, o medalhão do
  Salão e os inimigos ficam claros, a borda da sala some no quadro sem buraco. Aprovado; é a que mais se parece com a
  sensação do Ember & Blade. No hub, ver H-P0-2.
- HUD: "OURO" e "Mapa [M]" ficam sobre o cenário claro do alto (velas e caixotes do Salão na Perto); sombra do texto
  segura a leitura. Contador "GOLPES" e nome do golpe à direita sem cobrir figura nas capturas. Sem pedido.

## Pedido de correção para o próximo marco do hub (com critérios)

Ordem sugerida: primeiro câmera e planta (H-P0-1, H-P0-2, H-P0-3), depois estações (H-P0-4), depois o resto.

1. **Portal inteiro no quadro** (gameplay-engineer + environment-artist). Com a câmera Longe, da chegada e de qualquer
   estação: o arco inteiro do portal visível, soleira em y 0,15 a 0,30 a 1080, os dois leões visíveis. Caminhos: alvo
   da câmera mais ao norte e `CAM_REACH` menor no sentido norte-sul, ou fachada trazida 6 a 8 m para dentro (a praça
   encolhe do lado norte). Ponto de uso do portal no pé da escada (a menos de 1,5 m do primeiro degrau) e a placa
   ancorada sobre a escada. Captura: `--hub --look=stylized` e `--hub --hero-at=portal`.
2. **Câmera Perto no hub** (gameplay-engineer): a borda sul do chão nunca acima de y 0,85 da tela; nenhuma captura com
   mais de 15% de muro externo. Captura: `--hub --cam=near` na chegada e em cada estação.
3. **Praça com zonas, não um tapete** (environment-artist; planta conferida pelo gameplay-engineer). Manter a área que o
   Daniel pediu, mas dividir: um anel de lajes em volta de uma fonte maior (bacia de 5 a 6 m, estela de 2,5 m), dois
   canteiros elevados de 0,4 a 0,6 m com árvores pequenas ou arbustos de cobre entre a fonte e as estações de cima,
   duas muretas baixas de 0,6 m que fazem "salas" para as estações de baixo, caminhos de laje mais clara ligando cada
   estação à fonte. Critério: na chegada (Longe), nenhuma área livre de peça com mais de 8 x 8 m visível no meio da tela;
   caminhada entre estações vizinhas até 3 s e entre opostas até 5 s (`HubPlan`).
4. **Estações com lugar** (environment-artist). Cada uma com: piso próprio (tapete, plataforma de um degrau ou lajes
   emolduradas), algo alto atrás (toldo grande, coifa da forja, estante alta, nicho da árvore) com 4 a 6 m, e a luz da
   estação visível do ponto de uso. Escala: o objeto principal pelo menos 1,5 vezes a altura do herói. Forjador:
   fornalha virada para a câmera (dentro do quadro do ponto de uso) com brasa e fumaça. Critério: em cada
   `--hub --hero-at=<estação>` a estação inteira cabe no quadro e se reconhece sem a placa.
5. **Chão alinhado às paredes** (technical-artist): `frame_yaw` no hub; salas iguais com 0 (antes e depois na GPU).
6. Depois: H-P1-2 a H-P1-7 e os P2.

## O que depende de assets

- NPCs do Vendedor e do Forjador (HUB-D; KayKit repintado provisório ou Meshy com o Daniel, 40 créditos).
- Leão sentado de pedra (Meshy, 15 créditos, só com o Daniel) resolveria H-P1-3 de vez; o procedural com escala 2x
  serve para o próximo teste.
- Nada mais pede crédito.

## Veredito final

Hub: **reprovado no layout** (4 P0). A direção de cor e luz, a interface das placas, o painel do portal e o Livro estão
aprovados. Câmera Perto nas salas aprovada; no hub, não. Recomendo segurar o hub do próximo teste do Daniel até os itens
1 a 4 acima terem captura nova.

---

# Re-revisão, depois das correções do HUB-D (environment-artist e technical-artist)

Autor: `art-director`, 2026-11-19 (noite). Árvore de trabalho sem commit sobre `4efa876`. A aprovação final é do Daniel.

## Material

- Capturas do environment-artist (RTX, Forward+, estilizado, 1920 x 1080 salvo indicação): `d/env_arrival_far_1080.png`,
  `d/env_arrival_near_1080.png`, `d/env_at_{portal,vendor,smith,tree,book}_1080.png` (Longe),
  `d/env_at_{portal,vendor,smith}_near_1080.png` (Perto), `d/env_arrival_classic_1080.png`, `d/env_arrival_compat_720.png`.
- Do technical-artist: `d/smith_sty_near_5.55.jpg`, `d/smith_blow_strip_sty.png`, `d/vendor_sty_720.jpg`,
  `d/arrival_sty_1080.jpg`; `../rj1/angel_seals.png`, `../rj1/emeth_temper_{stylized,classic}.jpg`.
- Não fiz captura nova: as de cima cobrem todos os critérios que eu tinha dado. Medidas minhas:
  `tools/frame_stats.py --hue --scene` nas capturas e uma conta do maior quadrado livre de peça na planta do
  `HubPlan` (grade de 0,25 m, peças com o tamanho do código; caminhos pintados no chão não contam como peça).

## Os quatro P0

| Id | Critério que eu dei | O que as capturas mostram | Estado |
|---|---|---|---|
| H-P0-1 | Longe, da chegada e de toda estação: arco inteiro, soleira em y 0,15 a 0,30, os dois leões; ponto de uso a menos de 1,5 m do primeiro degrau, placa sobre a escada | Soleira em y 0,23 na chegada e nas cinco estações (a câmera quase não anda entre elas); arco e as duas estelas dos leões inteiros; herói ao pé da escada e "Portal da Descida" sobre ela (`env_at_portal_1080`) | **Resolvido** |
| H-P0-2 | Perto: borda sul do chão abaixo de y 0,85; no máximo 15% de muro externo | Chegada Perto: balaustrada sul em y 0,90 a 0,96, muro externo cerca de 4% da tela (antes 45%), luma p10 da cena 47 (antes 9) | **Resolvido**. Observação: na chegada Perto o portal não aparece (fica acima do quadro); não era critério e a Longe é a que mostra o destino |
| H-P0-3 | Na chegada (Longe) nenhuma área livre de peça maior que 8 x 8 m no meio da tela; vizinhas até 3 s, opostas até 5 s | Ciprestes em vasos, urnas maiores, bancos, fonte de 5,6 m e caminhos de laje partem a praça. Pela planta, ainda sobra um quadrado livre de **9,75 m** em cada quadrante de baixo (centro em u ±7,9, v -3,4: entre a fonte, a chegada e o Forjador / o Livro), cortado só pelo caminho pintado. Distâncias: chegada até Forjador ou Livro 12 m (1,8 s), Vendedor até Forjador 14 m (2,1 s), Vendedor até Árvore e Forjador até Livro 23 m (3,4 s), Vendedor até Livro 27 m (4 s) | **Quase**: desce a P1 (pedido E-1). Os 3,4 s entre as estações do mesmo lado de cima e de baixo ficam aceitos (o LR-07 pediu até 4 s) |
| H-P0-4 | Cada estação com piso próprio, algo de 4 a 6 m atrás, luz visível do ponto de uso, peça principal com 1,5 vez o herói; reconhecível sem placa e inteira no quadro | Vendedor: toldo listrado de cerca de 1,9 vez o herói, balcão, mercadorias, NPC atrás; Forjador: forno com a boca e o fogo virados para a câmera, chaminé alta, bigorna, poça quente no chão, NPC; Livro: estante alta de rolos, tapete petróleo, atril com velas; Árvore: estrado e copa. As quatro se reconhecem sem a placa. Falha pequena: **a copa da Árvore sai pelo topo da tela** em toda vista Longe e no ponto de uso dela (`env_at_tree_1080`), e a estante do Livro encosta na borda direita na chegada | **Resolvido**, com a copa como P1 (E-3) |

Também resolvidos: **H-P1-1** (lajes e cantaria alinhadas às paredes pelo `frame_yaw`, em todas as vistas e no
Compatibility), **H-P1-2** (os fios de ouro terminam no losango de cada estação), **H-P1-5** (fonte de 5,6 m com estela,
lê como centro). **H-P1-3** melhorou: os leões das estelas agora leem como leão rampante, mas seguem brancos e pequenos
(fica como P2, E-6). **H-P1-4** (repetição) melhorou porque as estações quebram a simetria; ciprestes, vasos de cobre e
figuras dos nichos seguem espelhados (P2). **H-P1-6** (vista geral) não foi recapturado: fica aberto.

## Parte quente acima do teto (H-P1-7 virou o contrário)

Medido (cena, sem HUD): chegada Longe 12,6%, portal 13,7%, Vendedor 12,7%, Árvore 12,4%, Livro 14,5%, Forjador
16,1%, chegada Perto 14,2%, portal Perto 16,6%, Forjador Perto 15,3% (teto da spec 14%). De onde vem, por caixa
(1920 x 1080): **os discos de luz na fachada** (caixas 300,40,500,230 e 1250,40,450,230) 35 a 57% quentes e a **copa da
Árvore** (1350,0,520,430) 35 a 41%, saturação 0,24 a 0,31 e p90 até 153. O chão do meio não é a causa (matiz 36, saturação
0,23, igual à chegada de antes).

Decisão: **não baixar o chão**. Os quatro discos redondos de borda dura na parede do fundo, atrás das estelas, são a
poça pintada dos dois braseiros do terraço (`HubLook.BRAZIERS`, v 15,9, quase encostados na fachada) caindo na parede
vertical: leem como holofote, são o que mais parece protótipo na tela nova e são metade do excesso. Tirar os discos e
apagar um pouco o ouro da Árvore leva o quente para a faixa sem mexer em mais nada (E-2, E-3).

## NPCs (technical-artist; provisórios do KayKit, como combinado)

- **Forjador escuro, sim.** Corpo com luma p50 50 (caixa 735,590,60,120 em `smith_sty_near_5.55.jpg`), contra 80 do
  chão em volta e 93 do herói ao lado. Ele fica fora da poça do forno (que cai na frente da boca, à esquerda dele) e a
  pintura das figuras é a da multidão estilizada, feita para ficar abaixo da laje. Para inimigo é certo; para alguém do
  lugar, ele lê como sombra. O golpe do martelo pousa na bigorna e as fagulhas são pequenas e abaixo de 1,0: bom
  (`smith_blow_strip_sty.png`).
- O rosto é o do KayKit (redondo, olhos grandes): lê infantil ao lado do Guerreiro. Aceito como provisório até o
  Meshy (40 créditos, só com o Daniel), registrado em "depende de assets".
- Vendedor: figura encapuzada escura atrás do balcão, lê como pessoa de perto; de longe é uma mancha. Aceito como
  provisório.

## Selos dos anjos (`rj1/angel_seals.png`)

- Chama (brasa no losango com três línguas) e Geada (floco de seis braços com o miolo azul) leem bem de 24 a 140 px e
  no papel. Aprovados.
- **Luz lê como obelisco** (ou alfinete de mapa): a ponta afiada no alto e a base estreita sobre o losango fazem uma
  pedra em pé, não um feixe. Pedido T-2.
- **Vigília: verde-oliva (0,58; 0,68; 0,43)**, não petróleo. O petróleo (0,3; 0,62; 0,6, matiz cerca de 178) fica a uns
  30 graus do esmeralda da Emeth e é o mesmo petróleo do cachecol do herói, do anel dele no chão e do esmalte da Bênção
  no relicário: um selo de anjo não pode falar com a cor do herói. O oliva fica a uns 55 graus da Emeth, longe do
  vermelho do perigo e longe do âmbar da Chama, e casa com o musgo seco do chão. A trombeta lê como trombeta a partir de
  46 px; a 24 px vira uma cunha, aceitável para um ícone de fileira.

## Temperar da Emeth (`rj1/emeth_temper_*.jpg`)

- De perto (laboratório, lâmina de cerca de 90 px de largura): posto 1 com um veio de ouro velho num lado até a metade e
  o fio pálido, posto 2 com os dois veios até a ponta; distintos nos dois looks, nada estourado, o estilizado com o fio
  mais suave. **Aprovado para os closes** (página da Forja, Livro).
- **No jogo não dá para conferir ainda**: `EmethSword.set_temper` não é chamado por ninguém (falta ligar ao
  `ForgeRank`, dono gameplay-engineer). Com o herói de cerca de 120 px a lâmina tem 6 a 8 px de largura e um veio de 2 px
  na escala do laboratório some. Pedido G-2 (captura) antes de dizer que o Temperar se vê na luta.

## Novos, vistos nas capturas

| Id | O que | Captura | Prioridade |
|---|---|---|---|
| N-1 | Discos de luz de borda dura na fachada (ver acima) | `d/env_at_portal_near_1080.png`, todas | P1 |
| N-2 | A água da fonte no Forward+ é preta com zigue-zagues brancos: lê como mármore rachado ou relâmpago, não como água; no Compatibility é um disco preto liso | `d/env_arrival_near_1080.png`, `d/env_arrival_compat_720.png` | P2 |
| N-3 | Folhagem em blocos (ciprestes, arbustos de cobre e a copa da Árvore): cartões quadrados que leem como pixel ou pipoca a 1080, o H-P2-1 estendido às peças novas | `d/env_at_vendor_near_1080.png` | P2 |

## Pedidos de correção, por dono

**environment-artist**

- E-1 (H-P0-3, agora P1): uma peça baixa em cada quadrante de baixo, entre o caminho chegada-estação e o caminho
  fonte-estação, por volta de u ±6,5, v -3,2 (banco curvo, urna baixa ou canteiro de 0,5 m; fora das duas linhas retas,
  sem bloquear o caminho). Critério: na planta, nenhum quadrado livre de peça maior que 8 m dentro de |u| < 12,
  -9 < v < 12 (a mesma conta: grade de 0,25 m); robô e herói chegam a toda estação em linha reta.
- E-2 (N-1, parte quente): os dois braseiros do terraço não pintam poça de borda dura na fachada: luz difusa nesses dois
  (`light_specular` 0, o caminho `paint_diffuse` do `paint.gdshaderinc`) ou os braseiros 1,5 m mais para a frente com o
  alcance que não chega à parede. Critério: nenhum contorno redondo na fachada; caixas 300,40,500,230 e 1250,40,450,230
  (1920 x 1080, `--hub --hero-at=portal --cam=near`) com até 20% quentes (hoje 39 e 57%).
- E-3 (copa e quente): a Árvore inteira dentro do quadro no ponto de uso dela, Longe (`--hub --hero-at=tree`): topo da
  copa abaixo de y 0,04. Caminho preferido: `TREE_SCALE` de 0,65 para cerca de 0,55 (ou subir o `SHOW` da Árvore com o
  gameplay-engineer); ouro da copa e do tronco mais velho, saturação p50 da caixa 1350,0,520,430 até 0,20 e p90 de luma
  até 140. Critério do conjunto E-2 + E-3: parte quente da cena de 6 a 14% nas dez vistas medidas acima (chegada Longe e
  Perto, as cinco estações Longe, portal, Vendedor e Forjador Perto).
- E-4 (NPC, junto com T-1): a luz do forno alcança o Forjador e a bigorna (poça deslocada ou alargada cerca de 1,5 m
  para leste, ainda sem sombra nova).
- E-5 (N-2, P2): água da fonte com o reflexo em manchas largas e suaves, nada de linha branca contínua; maior valor da
  água abaixo do chão claro em volta (p90 da caixa da água abaixo de 120), no Compatibility com algum reflexo.
- E-6 (P2): leões das estelas do terraço em ouro velho ou na pedra com sombra, não brancos (como o resto dos leões do
  hub); folhagem em massas maiores (N-3).

**technical-artist**

- T-1 (Forjador escuro): os NPCs do hub com luz própria de figura de lugar, não de inimigo (por exemplo `style_light` e
  `style_scene` próprios do `HubNpc`, cerca de 0,35 e 0,2), mais a borda morna do lado do forno. Critério: em
  `--hub --hero-at=smith --cam=near`, corpo do Forjador com luma p50 de 70 ou mais, ainda abaixo do herói; Vendedor
  com a mesma regra no ponto de uso dele.
- T-2 (selo da Luz): tirar a ponta do feixe. O feixe sem ápice, com o topo esmaecendo (alfa de cerca de 0,2 no alto a 0,9
  embaixo) e alargando para baixo até a largura do losango (largura embaixo de 1,6 vez a do alto ou mais), com duas
  linhas finas nas bordas; nada de raios, sol nem cruz. Critério: a 46 e a 96 px, nenhuma silhueta de pedra em pé (topo
  sem ponta, lados divergindo para baixo).
- T-3 (selo da Vigília): `AngelSeal.TINT` da Vigília fica no oliva (0,58; 0,68; 0,43). Não trocar para petróleo.

**gameplay-engineer**

- G-1 (se o E-3 escolher o caminho da câmera): `HubPlan.SHOW[TREE]` com altura da copa de verdade (cerca de 10 m),
  mantendo a soleira do portal em y 0,15 a 0,30.
- G-2 (Temperar no jogo): ligar o `ForgeRank` ao `EmethSword.set_temper` (hub e partida) e mandar uma captura
  `--bot --autopick --forge=2 --cam=near --look=stylized --seed=5` com um recorte 2x do herói ao lado de uma com
  `--forge=0`. Critério: os veios ou o fio pálido do posto 2 se distinguem do posto 0 no recorte. Se não se distinguirem,
  volta para o technical-artist alargar o veio (largura em metros da lâmina, não em fração) antes de qualquer outra coisa.

## O que depende de assets

- NPCs com rosto adulto (Meshy, 40 créditos) e leão sentado de pedra (15 créditos): só com o Daniel. O KayKit repintado
  serve para o teste.

## Veredito da re-revisão

**Aprovado para o teste do Daniel, com ressalvas.** Os quatro P0 de layout caíram: o portal está inteiro e no lugar de
destino, a câmera Perto não mostra mais o muro, a praça tem zonas e peças em pé, e cada estação tem lugar próprio e se
reconhece sem placa. O que sobra não bloqueia: os discos de luz na fachada (N-1) e a copa cortada (E-3) são os dois que
mais chamam o olho e os recomendo antes do exe se couberem na noite (são ajustes de luz e escala, sem planta nova); o
Forjador escuro (T-1) logo em seguida. Selos: Chama, Geada e Vigília (oliva) aprovados, Luz não (T-2). Temperar aprovado
de perto, sem prova no jogo (G-2).
