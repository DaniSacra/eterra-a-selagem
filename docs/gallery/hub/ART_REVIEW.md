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
