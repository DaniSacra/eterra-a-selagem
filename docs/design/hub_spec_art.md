# HUB-A: Santuário da Vigília, especificação de arte e espaço

- **Data**: 2026-11-19. **Autor**: art-director. **HEAD lido**: `47d06a7`. **Marco**: HUB-A (especificar, nada
  implementado). Nenhum crédito do Meshy gasto nem autorizado.
- **Diretriz**: `docs/design/hub/po_directive_hub01.md`, seções 1, 2, 5 e 7.
- **Referências** (imagens de IA, só locais em `docs/art/ref/hub/`, conceito e não planta; nunca evidência nem asset):
  - **H1** `01_santuario_vigilia_layout_final.png` (a principal): portal no alto, ao fundo, no eixo, entre dois leões.
  - **H2** `02_hub_layout_ux.png`: mesma praça com o medalhão do leão no meio e a fonte embaixo, entre duas escadas.
  - **H3** `03_hub_conceito_ambiente.png`: ambiente; leão gigante como fonte ao fundo e portal embaixo (não é o arranjo).
- **Lido também**: `CLAUDE.md` (câmera, `CamFrame`, `VisualProfile`, `ArenaKit`, `Masonry`, `TombKit`, `CatacombHall`,
  Lotes A a E, RS-C1), `docs/art/art_direction.md`, `docs/art/stylized_spec.md`, `docs/art/asset_inventory.md`,
  `docs/art/sworn_reference_ideas.md`, `docs/art/room_redesign_matrix.md` 0.4, `scripts/core/cam_frame.gd`,
  `scripts/core/feel.gd`, `masonry.gdshaderinc`, `catacomb_floor.gdshaderinc`, `ArenaKit.fountain`, `StoneTree`.
- **Como medi**: as posições de tela saem da projeção do próprio jogo (`CamFrame.screen_of`, refeita em Python no
  scratchpad: distância 54, inclinação 30, campo 24, 16:9); as posições das referências foram lidas em pixels e
  projetadas no chão pela mesma câmera (seção 1.3). Nada aqui foi capturado no Godot: o hub não existe. Os critérios da
  seção 5 só se conferem com captura real.
- **Lore**: tudo que diz quem é alguém ou o que um lugar é fica marcado **[PO]** e está na seção 6.

---

## 1. Leitura das referências

### 1.1 Princípios a seguir

| # | Princípio | De onde | Como entra no jogo |
|---|---|---|---|
| R1 | **Eixo único e simétrico**: chegada embaixo, praça, escada larga, portal no alto e no meio. O olho sobe pelo eixo sem procurar | H1, H2 | eixo do hub alinhado à vertical da tela (2.1) |
| R2 | **Portal é o mais claro e o único verde** do quadro; dois leões sentados o guardam, um de cada lado da escada | H1, H2 | portal do salão reaproveitado, leões no patamar (3.1) |
| R3 | **Quatro cantos, quatro ofícios**: cada estação é um nicho na borda, com fundo próprio (toldo, fornalha, arco da árvore, estante), e o meio fica livre | H1, H2 | estações fora do chão de andar, só o ponto de uso dentro (2.3) |
| R4 | **Cada estação tem uma luz e uma cor de luz próprias**: toldo com lanternas mornas, forja laranja-âmbar, árvore ouro, livro de velas | H1 a H3 | uma luz principal por estação (4.3) |
| R5 | **Arquitetura em camadas**: muro com arcos ao fundo abrindo para uma vista distante (ruínas, cascata), colunas e pilares nos lados, mureta baixa na frente | H1 a H3 | anel de arcadas ao norte, mureta e pilaretes ao sul (3.6) |
| R6 | **Chão de praça com marca de ouro velho no meio** (leão), lajes em anéis à volta | H1, H2 | medalhão do leão no chão, sem brilho (3.7) |
| R7 | **Vegetação nas bordas, nunca no meio**: trepadeiras nas paredes, canteiros nos cantos, uma árvore de folha cobre no alto à esquerda | H1 a H3 | musgo e flores pintadas, copa em cartões (3.8) |
| R8 | **Tom de abrigo**: muito fogo pequeno, nada ameaça, céu de entardecer frio atrás | H1 a H3 | ar mais claro e mais morno que qualquer sala (4.1) |

### 1.2 O que não copiar

| O que está nas imagens | Por que não | O que fazemos |
|---|---|---|
| Estrela de oito pontas (rosa dos ventos) no topo do portal e no ícone "Partir para a Aventura" | lê como sol; o símbolo é o leão (`art_direction.md` 7) | fecho do arco com o leão do selo em relevo (`lion_sdf.res`) |
| Cristais esmeralda e luz verde-ciano na Árvore de Dons; água ciano brilhante na fonte | esmeralda é da Emeth e do portal; ciano fica perto do petróleo do herói (2.1 do guia) | árvore em ouro velho e folhas de ouro pálido; água escura com reflexo marfim-azulado |
| Glicínias violeta saturadas em toda parte | violeta é de Morvath e da maldição | flores marfim, ocre pálido e rosa-terra apagado; musgo cinza-verde |
| Toldo vermelho vivo, tapetes carmim | vermelho vivo é do perigo | toldo em terra-ferrugem apagado (valor até 0,4) com o leão em ouro velho; tapetes petróleo e terra |
| Rótulos de todas as estações sempre à vista | a diretriz pede um prompt só, da estação em foco | nenhum rótulo parado; uma placa só (2.5) |
| Barra de vida, moedas no topo, "M Mapa" (H2) | a diretriz proíbe HUD de combate e mapa no hub | interface é do `ui-ux-designer`; a arte não reserva lugar para isso |
| Grafia "Akh", títulos "O Santuário de Eterra", "Refúgio dos Selados", "Refúgio de Akh" | o cânone é Ahk; os títulos são da imagem, não do Daniel | nenhum texto pintado no cenário; nome do lugar fica com o PO **[PO]** |
| Herói subindo a escada até o portal, portal 9 m acima da praça | o herói anda sempre em y 0 (a simulação é no plano); escada é borda, como no salão | o uso do portal é no pé da escada (2.4) |
| Fonte no eixo, bem no caminho entre o herói e o portal (H1) | a diretriz: "sem obstruir caminho direto ao portal" | fonte no eixo, pequena, com duas faixas largas de passagem e a chegada na faixa da esquerda (2.2); alternativa para o PO (Q-H1) |
| Leão gigante como fonte (H3) e portal embaixo (H3) | H1 é a principal | leão da fonte pequeno, em estela |
| Saturação de pôster (saturação p90 bem acima das nossas salas) | o "pintado" do perfil vem de valor e pincelada (`stylized_spec.md` 0) | tetos da seção 4.2 |
| Rostos dos NPCs (ferreiro careca de barba branca, vendedor encapuzado idoso) | personagem novo é lore | NPCs só como função e silhueta; quem são é do PO **[PO]** |

### 1.3 A câmera das referências contra a nossa

As referências estão de frente (o eixo é a vertical da imagem) e mais inclinadas que a nossa câmera (a praça aparece
quase como planta). Projetando na nossa câmera os pontos de H1 (pixels lidos na imagem de 1672 x 941), a praça dá cerca
de 30 m de largura e 26 m de fundo, com o portal 12 m atrás da fonte: é larga demais e funda demais para a nossa
inclinação de 30 graus (a mesma praça, vista por nós, ficaria com o portal saindo pelo alto da tela). A planta da seção
2 encolhe isso para 25 x 16,5 m de chão de andar, mantendo **onde cada estação cai na tela** perto de H1 (tabela 2.3).

---

## 2. Planta e câmera

### 2.1 Câmera e orientação

- **Câmera**: a do jogo, sem mudança: giro 35, inclinação 30, campo 24, distância 54 (`_feel` do `make_data.gd`). O herói
  tem 110 a 131 px de altura a 1080 em qualquer ponto do chão do hub (medido pela projeção).
- **Enquadramento**: quase fixo. `CamFrame.hold` como na Câmara do Selo, alvo fixo no ponto local (0; 1) = mundo
  (-0,6; -0,8), `reach` 3 m, `follow` ligado e sem o adiantamento da corrida (`cam_lead`). Em quase todo o chão o herói
  fica dentro dos 18% de margem sem a câmera se mexer; só nos dois cantos da frente (forja e livro, u ±12,5, v -7,5) ela
  anda até cerca de 1,5 m. Assim a composição de H1 fica sempre de pé.
- **O hub é girado para a tela**. Para o eixo portal-fonte-chegada ser a vertical da tela (R1), toda a planta é desenhada
  num sistema local (u, v): **u para a direita da tela, v para o alto da tela** (para longe da câmera), origem no centro
  da fonte, y para cima. Conversão (giro 35):
  - mundo `x = 0,819 u - 0,574 v`, `z = -0,574 u - 0,819 v`;
  - de volta: `u = 0,819 x - 0,574 z`, `v = -0,574 x - 0,819 z`.
  - Em código: o nó raiz do hub com `rotation.y = deg_to_rad(Feel.cam_yaw)` e tudo dentro dele em (u, y, -v); a
    colisão e os pontos de uso convertidos pela fórmula (dono: gameplay-engineer).
  - **Consequência na pedra**: a cantaria (`masonry.gdshaderinc`) e as lajes (`catacomb_floor.gdshaderinc`) são mapeadas
    em coordenadas do mundo; com a sala girada as fiadas e as lajes ficariam a 35 graus das paredes. Pedido ao
    technical-artist: um uniform `frame_yaw` (graus, padrão 0) nos dois includes que gira `world.xz` antes de achar o bloco
    e a laje. Com 0 nada muda em sala nenhuma (conferir com captura das salas antes e depois). Sem isso, o hub não se
    monta girado.
  - Alternativa rejeitada: hub alinhado ao mundo com o portal no canto noroeste (fica 10 graus fora da vertical e a praça
    vira losango, contra H1); câmera de giro 0 só no hub (quebra a regra "a câmera do jogo" e o teclado).

### 2.2 Tamanho e chão de andar

- **Chão de andar** (polígono local, y 0, tudo plano): (-8,5; -10,5), (-12,5; -7,5), (-12,5; 6,0), (12,5; 6,0),
  (12,5; -7,5), (8,5; -10,5). Cerca de 400 m², 25 m de largura e 16,5 m de fundo. Em mundo: (-0,9; 13,5),
  (-5,9; 13,3), (-13,7; 2,3), (6,8; -12,1), (14,5; -1,0), (13,0; 3,7).
- **Obra inteira** (com arcadas, nichos e o patamar do portal): u -17 a 17, v -13,5 a 13 (34 x 26,5 m), mais o fundo
  distante além do anel.
- **Obstáculos dentro do chão** (todos visíveis e da altura do que são, nada invisível):
  - fonte: círculo r 1,6 em (0; 0);
  - balcão do Vendedor: caixa 1,0 x 3,2 m em (-11,4; 4,2);
  - bigorna: círculo r 0,6 em (-10,6; -5,0); Forjador: círculo r 0,45 em (-12,0; -5,8), no canto, fora de qualquer rota;
  - estrado da Árvore: círculo r 2,6 em (12,2; 5,4);
  - atril do Livro: caixa 0,8 x 1,0 em (11,0; -5,0);
  - dois postes de lanterna na borda sul, r 0,3 em (±5,0; -10,2), metade fora do chão.
- **Bordas**: norte (v 6,0) é o pé da escada do portal no meio e canteiros baixos nos lados; oeste e leste (u ±12,5) são
  os nichos das estações e paredes; sul (v -10,5) é mureta baixa com o vão da escada de chegada (u -3 a 3). A escada
  de chegada desce 1 m até uma grade baixa fechada no pé (o topo da grade fica abaixo do chão da praça): a borda se lê
  como fechada sem limite invisível.
- **Passagens**: entre a fonte e as estações ficam pelo menos 9 m livres de cada lado; entre o balcão e a bigorna, 7 m;
  entre o estrado e o atril, 6 m. Nenhuma passagem com menos de 3 m.
- **Fonte e caminho ao portal**: a fonte fica no eixo (R1) mas com 1,6 m de raio; a chegada é em u -2,4, então segurar
  "para cima" desde a chegada passa livre à esquerda da fonte e chega ao lado esquerdo da escada (8 m de largura). O
  caminho reto da chegada ao ponto de uso do portal passa a 0,8 m do centro da fonte: o contorno custa cerca de 0,8 m,
  0,1 s. Pedido ao gameplay-engineer: quem empurra exatamente no centro de um obstáculo redondo desliza para um lado
  (nunca fica parado no eixo). Se o PO quiser o eixo inteiro livre, ver Q-H1.

### 2.3 Onde fica cada coisa

Tela: ponto no chão (ou na altura indicada) a 1920 x 1080 com o alvo fixo.

| Peça | local (u; v) | mundo (x; z) | tela (x; y px) | Em H1 (proporção da tela) |
|---|---|---|---|---|
| Alvo da câmera (fixo) | (0,0; 1,0) | (-0,6; -0,8) | (960; 540) | |
| Chegada: onde o herói aparece | (-2,4; -8,8) | (3,1; 8,6) | (826; 814) | herói em (0,48; 0,88) |
| Topo da escada de chegada | (0,0; -10,5) | (6,0; 8,6) | (960; 872) | |
| Medalhão do leão no chão (r 2,4) | (0,0; -5,5) | (3,2; 4,5) | (960; 711) | (0,51; 0,66) |
| Fonte do leão | (0,0; 0,0) | (0,0; 0,0) | (960; 564) | (0,50; 0,50) |
| Pé da escada do portal | (0,0; 6,0) | (-3,4; -4,9) | (960; 431) | (0,50; 0,41) |
| Patamar do portal, y 1,2 | (0,0; 9,5) | (-5,4; -7,8) | (960; 319) | |
| Soleira do portal, y 1,2 | (0,0; 11,0) | (-6,3; -9,0) | (960; 293) | (0,50; 0,28) |
| Leão oeste, base no patamar | (-4,6; 10,0) | (-9,5; -5,6) | (769; 310) | (0,42; 0,27) |
| Leão leste, base no patamar | (4,6; 10,0) | (-2,0; -10,8) | (1151; 310) | (0,59; 0,27) |
| Vendedor: balcão | (-11,4; 4,2) | (-11,7; 3,1) | (450; 468) | (0,17; 0,42) |
| Vendedor: NPC, fora do chão | (-12,9; 4,4) | (-13,1; 3,8) | (384; 464) | |
| Forjador: fornalha, fora do chão | (-13,8; -5,6) | (-8,1; 12,5) | (234; 714) | (0,08; 0,66) |
| Forjador: bigorna | (-10,6; -5,0) | (-5,8; 10,2) | (408; 696) | (0,22; 0,70) |
| Forjador: NPC | (-12,0; -5,8) | (-6,5; 11,6) | (326; 720) | |
| Árvore de Dons: estrado, y 0,5 | (12,2; 5,4) | (6,9; -11,4) | (1496; 443) | (0,87; 0,40) |
| Livro de Ahk: atril | (11,0; -5,0) | (11,9; -2,2) | (1533; 696) | (0,86; 0,70) |
| Livro de Ahk: estante, fora do chão | (13,8; -5,4) | (14,4; -3,5) | (1683; 708) | |

As estações ficam um pouco mais para dentro que em H1 (x 0,17 a 0,80 contra 0,08 a 0,87): a praça é mais compacta para
as caminhadas ficarem curtas e o herói ler grande. O topo do arco do portal (y 7,4 sobre o chão) cai em y 48 px: a
moldura inteira cabe; o muro acima dela sai da tela, como em H1.

### 2.4 Pontos de uso, raio e placa

Cada estação tem um ponto de uso no chão, na frente da peça, sobre uma laje emoldurada de 2,4 x 2,4 m em relevo baixo
(SW-G3, losangos sulcados do `floor_decal.gdshader` `kind` 4; nunca círculo). É ali que o jogador entende "aqui se usa".

| Estação | Ponto de uso local (u; v) | mundo (x; z) | Peito do herói na tela (px) | Âncora da placa local (u; v; y) |
|---|---|---|---|---|
| Portal da Descida | (0,0; 4,6) | (-2,6; -3,8) | (960; 410) | (0,0; 7,0; 2,8), sobre a escada, abaixo da soleira |
| Vendedor | (-9,2; 3,0) | (-9,3; 2,8) | (536; 444) | (-11,4; 4,2; 2,6), sobre o balcão |
| Árvore de Dons | (9,4; 3,0) | (6,0; -7,8) | (1393; 444) | (11,0; 4,4; 3,2), ao lado do tronco |
| Forjador | (-8,4; -3,8) | (-4,7; 7,9) | (526; 608) | (-10,6; -5,0; 2,2), sobre a bigorna |
| Livro de Ahk | (8,6; -3,8) | (9,2; -1,8) | (1404; 608) | (11,0; -5,0; 2,2), sobre o atril |

- **Raio**: entra em foco a 2,2 m do ponto de uso, sai a 2,8 m (histerese). Com dois em alcance, vale o mais perto, e o
  que está em foco só perde para outro 0,4 m mais perto. Os pontos ficam a 6,8 m ou mais uns dos outros: nunca há
  dois em alcance de verdade.
- **Placa**: uma só na tela (a da estação em foco), presa à âncora, no estilo `DoorSign` (nome em ouro claro, uma linha
  de descrição em marfim, a tecla real ou o botão do controle e "Interagir"; `CAP_PX` 19 a 1080, contraste 4,5:1). Texto
  e forma são do `ui-ux-designer`; a arte só exige: nenhuma placa sem foco, nenhuma placa cobrindo o herói (a âncora
  fica 2 m ou mais além do ponto de uso, para longe da câmera) e nenhum ícone de estrela ou sol.
- **Destaque da estação em foco** (discreto, sem círculo no chão): a luz própria da estação sobe 25% em 0,2 s; a peça
  principal (toldo e mercadorias, bigorna, copa da árvore, livro aberto, moldura interna do portal) ganha uma borda de
  ouro velho por fresnel (potência 3,5, força 0,15, abaixo de 1,0) e a laje do ponto de uso clareia 10%. Some em 0,3 s.

### 2.5 Caminhadas a 6,75 m/s

Distância em linha reta entre pontos de uso (contornando a fonte quando passa por ela).

| De | Para | m | s |
|---|---|---|---|
| Chegada | Portal | 15,0 | 2,2 |
| Chegada | Vendedor | 13,6 | 2,0 |
| Chegada | Árvore | 16,7 | 2,5 |
| Chegada | Forjador | 7,8 | 1,2 |
| Chegada | Livro | 12,1 | 1,8 |
| Portal | Vendedor / Árvore | 9,3 / 9,5 | 1,4 |
| Portal | Forjador / Livro | 11,9 / 12,0 | 1,8 |
| Vendedor | Forjador | 6,8 | 1,0 |
| Árvore | Livro | 6,8 | 1,0 |
| Forjador | Livro | 17,0 | 2,5 |
| Vendedor | Árvore | 18,6 | 2,8 |
| Vendedor | Livro | 20,5 | 3,0 |
| Árvore | Forjador | 20,5 | 3,0 |

- O par mais usado junto (Árvore de Dons e Livro de Ahk, que abrem capítulos do mesmo livro, `HeroScreen`) fica lado a
  lado, à direita, a 1 s. Vendedor e Forjador, à esquerda, a 1 s. O portal fica a 1,4 a 1,8 s de qualquer estação.
- Nenhuma caminhada passa de 3 s.

---

## 3. Peças e materiais por estação

Regra para tudo: só no perfil estilizado é que o hub foi pensado (a direção visual do hub, diretriz 5); o clássico é a
mesma montagem sem os gêmeos pintados (o `ArenaKit.paint_look` faz a troca, F7 ida e volta igual, como nas salas). Peças
de pedra em `Masonry` com o preset do hub (4.1); fogos pelo `ArenaKit.stylize_fires`; ar por `style()[&"air"]`.
Custo: P até 1 sessão, M 1 a 2, G 2 a 4 do dono. "Novo" = procedural novo, sem textura nova.

### 3.1 Portal da Descida (alto, no eixo)

| Peça | Como | Reuso / novo | Custo | Dono |
|---|---|---|---|---|
| Escada larga | 6 degraus de 0,2 m e 0,5 m de piso, u -4 a 4, de v 6,0 a 9,0; borda de andar no primeiro degrau | `Masonry.stairs(..., mat)` | P | environment-artist |
| Patamar | u -5,5 a 5,5, v 9,0 a 11,5, y 1,2, frente com filete de ouro velho | `Masonry.block`, filete do `ArenaRoom` | P | environment-artist |
| Arco do portal | arco de ponta, vão 3,6 x 5,0 m sobre o patamar, 3 ordens de moldura recuadas (como o salão: `PORTAL_ORDERS`, `PORTAL_SPRING`), topo da moldura a 7,4 m do chão da praça | portal do `CatacombHall` (fachada) ou `Masonry.pointed_arch` + `arch_ring` | M | environment-artist |
| Folha do portal | `ArenaKit.portal_glow(..., arch)` com o `portal.gdshader` do AP-1 (oco escuro, anéis que entram, coração pálido pequeno, `body_saturation` e `body_value` do salão) | reuso | P | environment-artist |
| Fecho do arco | o leão do selo em relevo numa pedra de 0,9 m (`altar_lion.gdshader`, campo `lion_sdf.res`), ouro velho; **nunca estrela** | reuso | P | environment-artist |
| Leões | dois leões sentados em plintos de 0,6 m no patamar, u ±4,6, v 10,0, virados para a praça, topo a cerca de 4,0 m do chão da praça. **Sem Meshy**: pilar-estela de 1,0 x 0,8 x 2,2 m com o leão rampante em alto-relevo na face da praça (o campo do leão do selo, relevo fundo e moldura), coroado por uma cabeça de leão estilizada em blocos chanfrados (`Masonry.bevel_mesh`). Lê como "leão" pela face, que é o que a câmera vê. Com Meshy (seção 3.9): estátua de leão sentado | relevo: reuso; cabeça em blocos: novo | M | environment-artist |
| Estandartes | dois estandartes do leão (gêmeo petróleo do estilizado, `BANNER_PAINT_*`) pendurados na fachada, u ±6,5, topo a 7 m | `ArenaKit.banner(..., Emblem.LION)` | P | environment-artist |
| Velas e braseiros | dois braseiros baixos no pé da escada (u ±4,8, v 6,4, fora do chão), velas nos plintos | `ArenaKit.brazier`, `Masonry.candle` | P | environment-artist |
| Vista além do portal | a folha do portal já é a "vista misteriosa"; atrás do muro, ruínas distantes e bruma (3.6) | reuso | P | environment-artist |

### 3.2 Vendedor (alto, à esquerda)

| Peça | Como | Reuso / novo | Custo | Dono |
|---|---|---|---|---|
| Toldo | pano de 4,5 x 3,0 m inclinado sobre dois postes de madeira e a parede, borda em festão; terra-ferrugem apagado (matiz 15 a 20, saturação até 0,45, valor até 0,38) com o leão em ouro velho no meio | novo (malha de pano como a do `ArenaKit._banner_mesh`, material do estandarte) | M | environment-artist |
| Balcão | caixa de madeira 1,0 x 3,2 x 1,0 m com pano petróleo caído na frente (`reliquary_cloth.gdshader`) | `Masonry.crate`, pano do relicário | P | environment-artist |
| Mercadorias | frascos e jarros (torno do `Masonry.urn`, vidro opaco em âmbar, marfim e azul-ardósia; **nenhum verde, ciano ou violeta**), rolos, caixas pequenas e barris do KayKit nas prateleiras atrás | `Masonry.urn`, KayKit `box_small`, `barrel_small` | P | environment-artist |
| Lanternas | duas lanternas penduradas no toldo | `ArenaRoom.hanging_lantern` / `TombKit.Lamp` | P | environment-artist |
| Fundo | parede com prateleira de pedra (`ArenaRoom.wall_ledge`) e trepadeira (`wall_moss`) | reuso | P | environment-artist |
| NPC | ver 3.8 | | | |

### 3.3 Forjador (baixo, à esquerda)

| Peça | Como | Reuso / novo | Custo | Dono |
|---|---|---|---|---|
| Fornalha | nicho de arco de aduelas na parede, boca de 1,6 x 1,2 m, brasas e chama baixa dentro, coifa de pedra acima | `Masonry.voussoir_arch`, `ArenaKit._coals`, `ArenaKit.fire` | M | environment-artist |
| Bigorna | peça procedural em ferro escuro (base em tronco, corpo, chifre em prisma), 0,9 m de altura | novo (`Masonry.prism`, `_cold_metal`) | P | environment-artist |
| Armas e escudo | suporte de madeira com três lâminas e um escudo do leão; espadas desenhadas como a espada erguida da câmara, **nunca em cruz** | KayKit `sword_shield_broken`, `BossChamber._sword` como modelo | P | environment-artist |
| Tina de têmpera | caixa de pedra com água escura (`dark_water.gdshader` `form` 0) | reuso | P | environment-artist |
| Fagulhas | só no golpe do martelo: 6 a 10 riscos âmbar (`chip.gdshader`), 0,25 s, uma rajada a cada golpe (cerca de 1,2 s); nada contínuo | reuso | P | technical-artist (sincronia com o clipe) |
| NPC e martelo | ver 3.8; martelo procedural preso à mão | novo | P | technical-artist |

### 3.4 Árvore de Dons (alto, à direita)

| Peça | Como | Reuso / novo | Custo | Dono |
|---|---|---|---|---|
| Estrado | octógono de dois degraus (0,25 m cada), r 2,6, cantaria | `Masonry.prism`, `stairs` | P | environment-artist |
| Nicho | arco de ponta de 5 m atrás da árvore, com o leão no fecho; raízes de pedra saindo do estrado | `Masonry.pointed_arch`, perfil de raiz do `StoneTree` | M | environment-artist |
| Árvore | o gerador do `StoneTree` (seções varridas) numa escala de 0,32 (tronco de cerca de 1,1 m na base, forquilha a 1,5 m, copa até 5,5 a 6 m), casca em ouro velho fosco (matiz 36 a 40, saturação 0,45 a 0,55, valor 0,45 a 0,6, aresta mais clara); hoje as medidas são constantes, precisa de um parâmetro de escala ou de uma variante | `StoneTree` + parâmetro | M a G | environment-artist |
| Folhas | cartões da copa (`canopy.gdshader`, MultiMesh) em ouro pálido (matiz 40 a 46, saturação até 0,5, maior canal até 1,0 no material; abaixo do glow), abrindo em volta do herói como no Jardim | reuso | P | environment-artist |
| Luz | uma omni ouro morno sem sombra na copa (4.3) | reuso | P | environment-artist |
| Evolução (opcional, **[PO]** se mexe na leitura dos Dons) | as folhas acesas contam os Dons destravados (19 grupos, um por Dom; apagados ficam bronze escuro). Só desenho, lido do save; nada de regra nova | novo | P | environment-artist + gameplay-engineer (o número) |

### 3.5 Livro de Ahk (baixo, à direita)

| Peça | Como | Reuso / novo | Custo | Dono |
|---|---|---|---|---|
| Atril | pé de pedra com tampo inclinado de madeira, 1,1 m | `Masonry.block`, madeira do `Masonry.crate` | P | environment-artist |
| Livro aberto | duas folhas curvas de pergaminho (0,9 x 0,6 m aberto), tinta e rubrica desenhadas sem texto legível (as cores do `Book`: `INK`, `RUBRIC`, `GILT`), fita petróleo caindo | novo (malha simples + shader 3D do pergaminho; o `book_page.gdshader` é de interface) | P | environment-artist |
| Biblioteca | estante de nichos com rolos (cilindros) e livros fechados (caixas chanfradas), escadinha de madeira | `Masonry.bevel_mesh`, `shaft` | P | environment-artist |
| Velas | 5 a 7 velas acesas no atril e na estante; metade das velas do hub apagadas fica em outros grupos | `Masonry.candle` | P | environment-artist |
| Tapete | tapete petróleo e terra com moldura de ouro velho diante do atril | `floor_decal.gdshader` (o tapete da loja) | P | environment-artist |
| Ahk | **nenhuma figura**: Ahk não tem rosto (Q-03, Q-23); a estação é objeto e voz | | | |

### 3.6 Arquitetura em volta

| Parte | Como | Reuso / novo | Custo |
|---|---|---|---|
| Fachada norte | muro de 10 m com o portal no meio e duas arcadas de três arcos de cada lado (v 11,5 a 12), abertas para a vista | `Masonry.voussoir_arch`, `ArenaRoom.wall` | M |
| Vista | ruínas em duas profundidades e bruma (`ArenaRoom.backdrop`, `ruin_card`), uma cascata marfim-azulada à esquerda do portal (`dark_water` `form` 1), céu azul-noite | reuso | P |
| Lados | oeste e leste: paredes de 5 a 6 m com os nichos das estações; pilastras entre eles | `ArenaRoom.wall`, `wall_part` | M |
| Frente (sul) | mureta de 0,7 m com balaústres (`Masonry.balustrade`), pilaretes, dois postes de lanterna; **nada acima de 0,9 m a 2 m da borda sul** (P7); tocos baixos e escuros como primeiro plano (SW-G6) | reuso | P |
| Escada de chegada | 5 degraus descendo 1 m, u -3 a 3, grade baixa fechada no pé | `Masonry.stairs`, grade do `TombKit` | P |

### 3.7 Praça e fonte

| Peça | Como | Reuso / novo | Custo |
|---|---|---|---|
| Chão | lajes pintadas do perfil (`catacomb_floor_paint.gdshader`) com o `frame_yaw` do hub; em volta do medalhão duas faixas de lajes em anel (r 2,4 a 4,5) | reuso + uniform | P |
| Medalhão | o leão em ouro velho embutido no chão, r 2,4, com o filete do medalhão do salão; **sem brilho nem luz** (é chão, não aviso). Um filete de ouro velho no eixo, do medalhão ao pé da escada, interrompido sob a fonte (R1: leva o olho ao portal) | `catacomb_floor.gdshaderinc` (medalhão), campo do leão | P a M |
| Fonte do leão | bacia redonda de r 1,4 em blocos (a do `ArenaKit.fountain`, sem o jorro vertical, que é o sinal da fonte que cura nas salas), uma estela de 1,6 m na borda norte da bacia com a cabeça de leão em relevo e a boca soltando um fio de água em arco (`dark_water` `form` 1 num cartão curvo), musgo e flores na borda (`CatacombHall.dress_fountain`) | reuso + estela nova | P a M |
| Função | **decoração**: a fonte do hub não cura nem se usa (não confundir com a fonte das salas) | | |

### 3.8 NPCs (Vendedor e Forjador) sem Meshy

O que existe: os bonecos do KayKit (`Knight`, `Mage`, `Rogue_Hooded`, CC0, guardados em `assets/models/characters`,
fora do pacote), a UAL da Quaternius, o `tools/bake.gd` com o modo `-- kaykit`, o `Slender` que afina os cabeçudos, a
estátua encapuzada feita em código (`Masonry._build_statue`). Os modelos do Meshy sem uso (`hero_sombra`, `paladin_1`)
são heróis e não servem como NPC.

| NPC | Proposta | Animação | Estado |
|---|---|---|---|
| Vendedor | `Rogue_Hooded` do KayKit, assado como figura (`BakedModel`, um MultiMesh de 1), afinado pelo `Slender`, repintado: capuz petróleo escuro (valor até 0,25), manto terra apagado, couro; atrás do balcão, que esconde as pernas (o balcão tem 1,0 m) | parado (`Idle`) e, a cada 6 a 9 s, um gesto curto de arrumar (`Interact` do KayKit ou um trecho de `Spell_Simple`) | **provisório** |
| Forjador | `Knight` do KayKit sem elmo e sem escudo (malhas escondidas no assado), repintado: avental de couro, braços nus no tom de pele, ferro escuro; martelo procedural na mão direita (`held`) | laço de golpe na bigorna a cada 1,2 s (`1H_Melee_Attack_Chop` ou o `Sword_Attack` da UAL cortado), fagulhas no quadro do impacto (3.3) | **provisório** |
| Plano B (se o KayKit destoar demais na captura) | silhuetas: o Vendedor como a estátua encapuzada em pano pintado, parada, com respiração no shader; o Forjador só como sombra recortada na luz da fornalha (cartão) | respiração no vértice | provisório |

Regras: os dois no estilo das figuras estilizadas (`figure_paint.gdshaderinc`, corpo mais escuro que o chão, borda morna,
contorno de casca); nenhum dos dois usa petróleo saturado, esmeralda nem ouro de elite; os dois ficam fora do caminho
(Vendedor fora do chão de andar, Forjador num círculo no canto). Altura na tela: Vendedor cerca de 76 px e Forjador
cerca de 85 px a 1080 (figuras de 1,9 m): leem pela silhueta e pela peça (toldo, bigorna e fogo), não pelo rosto. Quem
eles são, nome e fala: **[PO]**.

### 3.9 Estimativa Meshy (só se valer a pena; nada autorizado, nada gerado)

Custos do plano: prévia 5, textura 10, esqueleto 5, animação 3 por ação.

| Peça | Por que | Créditos |
|---|---|---|
| Leão sentado de pedra (um modelo, espelhado para o outro lado) | o relevo em estela é a parte mais fraca da composição de H1; um leão de verdade muda o foco do quadro | 15 |
| Cabeça de leão da fonte (relevo de parede) | menos importante: o relevo do campo do leão resolve | 15 |
| Vendedor, com esqueleto | troca o KayKit cabeçudo; clipes pela UAL e `Retarget` (sem animação do Meshy) | 20 |
| Forjador, com esqueleto | idem | 20 |
| **Total se tudo** | | **70** (de 500) |

Recomendação: 0 agora. Se o Daniel quiser gastar, só o leão sentado (15) depois da primeira captura da HUB-B, e os
dois NPCs (40) depois que ele disser quem são.

---

## 4. Luz, paleta e ar

### 4.1 Preset do bioma "hub" (`style()`, só estilizado; proposta de partida, o environment-artist acerta pela tela)

| Chave | Valor | Por quê |
|---|---|---|
| `stone` | (0,40; 0,375; 0,345), matiz 35 | calcário morno um degrau mais claro que o Santuário (0,38; 0,368; 0,35) e o Altar |
| `floor_stone` | (0,375; 0,355; 0,325) | |
| `shadow` | (0,80; 0,90; 0,96), matiz cerca de 200 | **sombra petróleo** (diretriz); as salas mornas têm sombra fria neutra (0,86; 0,9; 0,98) |
| `joint_cold` | (0,86; 0,93; 0,98) | junta um pouco azulada, como a sombra |
| `slab_paint`, `slab_hue`, `olive_share` | (0,82; 1,18), 6, 0,03 | variação por laje do Santuário, pouco oliva |
| `fire` | velas e braseiros como o Salão, poça de braseiro 2,0 a 2,5 m; `pool_saturation` 0,8 | |
| `air` | céu (0,06; 0,08; 0,13), névoa (0,14; 0,13; 0,13), ambiente (0,78; 0,76; 0,72) x 1,9, lua de chave (1,0; 0,92; 0,80) 1,0 com sombra, de trás e da esquerda da câmera, inclinação 55 graus | mais claro e mais morno que toda sala; o frio fica no céu e na vista |

### 4.2 Paleta na tela (o que manda; medido com `tools/frame_stats.py --hue`)

| Região | Alvo |
|---|---|
| Cena (`--scene`) | matiz médio 25 a 45, sat HSV p50 0,10 a 0,22, luma p50 62 a 78; saturação p90 do quadro (SATHIGH) até 32 |
| Chão da praça (caixa entre fonte e medalhão) | matiz 28 a 42, sat 0,08 a 0,20, luma p50 75 a 92 (**o chão mais claro do jogo**: abrigo; as salas ficam em 50 a 85) |
| Sombra de parede (caixa numa parede lateral em sombra) | matiz 185 a 215, sat 0,12 a 0,30, luma p50 30 a 50 |
| Vista e céu (caixa sobre as arcadas) | matiz 205 a 225, sat até 0,40, luma p50 25 a 55 |
| Portal (caixa da folha) | verde (faixa `green`) 25% ou mais; nenhum pixel com os três canais acima de 235 |
| Fora da caixa do portal e da do herói | `g+c` até 0,8% (esmeralda só no portal) |
| Quente (faixa `warm`) na cena | 6 a 14% (fogos e lanternas como acento, não tapete) |
| Violeta | até 0,3% da cena |
| Vermelho (faixa `red`) | até 0,5% da cena (nada de vermelho de perigo; o toldo é terra apagada) |

Ouro velho: matiz 34 a 42, saturação até 0,6 em material e tela, como no guia (2.2). Flores: marfim, ocre pálido
(matiz 40 a 50, saturação até 0,4) e rosa-terra (matiz 10 a 20, saturação até 0,35, valor até 0,45); folhas cobre da
árvore do canto oeste como a copa do Jardim (`STY_LEAF_A`/`B`).

### 4.3 Luzes

| Luz | Tipo | Sombra Forward+ | Sombra Compatibility |
|---|---|---|---|
| Chave (lua morna de trás da câmera) | direcional | **sim** | sim, se couber no orçamento da iGPU; senão não |
| Fornalha | omni âmbar, 4,5 m, queda 1,5 | **sim** (a única de fogo, `KEEP_SHADOW`) | não |
| Portal | omni esmeralda baixa no patamar + duas baixas nas ombreiras (como o salão, `tint_with_portal`) | não | não |
| Árvore | omni ouro morno 5 m na copa | não | não |
| Toldo | duas lanternas, 3,5 m | não | não |
| Livro | uma omni de velas, 3,5 m | não | não |
| Braseiros do pé da escada | 2 omni, 4,5 m | não (estilizado sem sombra nos braseiros, STY-10) | não |
| Postes da frente | 2 omni, 3 m | não | não |

**Duas luzes com sombra** (teto do guia: 6) e 11 sem sombra. No Compatibility, cada malha mesclada do chão e da pedra em
células de 8 m (como `floor_plate`) para nenhuma ter mais de 8 luzes.

### 4.4 Ar e efeitos

- Névoa só na vista e abaixo da borda sul; a praça limpa (4.1).
- Partículas contínuas: só poeira lenta na luz do portal (até 20, como o facho de lua) e a fumaça da fornalha (até 12).
  Fagulhas e brilho do foco são rajadas.
- Nada acima do limiar do glow (1,3); o portal e as chamas dentro do teto da tela (`ScreenTone.SAFE` 226 na mira, 235
  absoluto); chamas com núcleo âmbar.
- Vinheta do jogo sem mudança.

### 4.5 Desempenho e Compatibility

- Alvo: iGPU Intel, 1280 x 720, qualidade Baixa, no máximo o tempo de quadro do Salão (15,3 ms, `CLAUDE.md` Lote A) mais
  0,5 ms; RTX 1080 Alta até 2,5 ms de GPU; até 900 chamadas de desenho (salas: 616 a 926); nenhuma textura nova (tudo
  procedural ou da paleta do KayKit); os dois NPCs assados somam no máximo 12 mil triângulos.
- Compatibility (navegador): abre sem erro no log; chão da praça a até 15 de luma do Forward+ (o chão pintado lá é mais
  claro: usar `STY_COMPAT_AMBIENT` próprio, como a Cripta e o Santuário); portal continua o maior verde da tela; figuras
  pelo `COMPAT_GAMMA` do LC-4.

---

## 5. Critérios de aceite e riscos

### 5.1 Capturas que provam (todas reais, na GPU; nunca imagem gerada)

O modo de entrar no hub direto é do gameplay-engineer (proposta: `--hub`, com `--hero-at` aceitando o ponto local
convertido). Capturas mínimas, 1920 x 1080 e 1280 x 720, semente 5:
1. hub vazio com o herói na chegada (`--hub --shot-at=2`);
2. o herói em cada um dos cinco pontos de uso, com a placa (`--hero-at=<mundo>`), a 720;
3. Compatibility (`DRIVER=opengl3 tools/shot.sh`) da vista 1;
4. vídeo curto percorrendo as cinco estações (HUB-B).

### 5.2 Critérios medíveis

| # | Critério | Como medir |
|---|---|---|
| A1 | Portal no alto e no meio: centro da folha em x 0,47 a 0,53, soleira em y 0,22 a 0,32; topo da moldura visível (y 0,02 ou mais) | pixels na captura 1 |
| A2 | Dois leões visíveis um de cada lado da escada (x 0,36 a 0,44 e 0,56 a 0,64) e a escada visível entre o portal e a fonte | captura 1 |
| A3 | Estações nos quadrantes: Vendedor x 0,15 a 0,35 e y 0,30 a 0,50; Forjador x 0,08 a 0,30 e y 0,55 a 0,75; Árvore x 0,65 a 0,85 e y 0,15 a 0,50; Livro x 0,70 a 0,90 e y 0,55 a 0,75; fonte x 0,48 a 0,52 e y 0,48 a 0,56 | captura 1 |
| A4 | Portal é o foco: a caixa da folha tem a maior luma p90 das seis caixas (portal e cinco estações) e verde 25% ou mais; fora dele e do herói `g+c` até 0,8% | `frame_stats --hue --box` |
| A5 | Paleta da 4.2 (cena, chão, sombra, vista, quente, violeta, vermelho, SATHIGH) | `frame_stats --hue --scene --box` |
| A6 | Herói: 115 a 145 px de altura a 1080 na chegada; corpo com luma p50 pelo menos 15 abaixo do chão em volta; `g+c` até 2% na caixa de 300 x 300 fora da Emeth | caixa no herói |
| A7 | NPCs: cada um com 75 px ou mais de altura e luma p50 da figura 20 ou mais abaixo do fundo atrás dele | caixas nos NPCs |
| A8 | Uma placa só por captura da série 2, legível a 720 (contraste 4,5:1, `DoorSign.contrast`), sem cobrir o herói | captura 2 |
| A9 | Andar: as cinco estações alcançáveis da chegada; nenhuma passagem com menos de 3 m; desenho onde a colisão para (`tools/fit_probe.gd` adaptado ao hub: fantasma até 1,5 m², peça sem desenho até 1,0 m²) | fit_probe e teste do gameplay-engineer |
| A10 | Nenhuma placa, rótulo ou HUD de combate sem foco; nenhuma barra de vida, inimigo ou aviso | capturas 1 e 2 |
| A11 | Nada de cruz, sol ou estrela; leão é o único símbolo; texto pintado nenhum | revisão das capturas |
| A12 | Desempenho e Compatibility da 4.5 | `tools/sty_probe.gd`, `tools/gpu.sh run --gpu-index 1`, log do opengl3 |
| A13 | Salas sem mudança: com `frame_yaw` 0 o Salão e a Cripta capturam iguais ao antes (fora de chamas e partículas) | antes e depois na GPU |

### 5.3 Riscos

| Risco | Efeito | Mitigação |
|---|---|---|
| Pedra e chão mapeados no mundo com o hub girado | fiadas e lajes tortas | uniform `frame_yaw` (2.1) antes de montar; A13 confere as salas |
| Leões em relevo lendo como estela, não como guardiões | o foco de H1 enfraquece | cabeça em blocos por cima; se a captura mostrar, Meshy do leão (15, só com o Daniel) |
| NPCs do KayKit cabeçudos e de brinquedo ao lado do herói do Meshy | quebra a coerência | `Slender`, pintura estilizada, balcão escondendo as pernas; plano B silhueta; Meshy só com o Daniel |
| NPCs pequenos (76 a 85 px) | rosto não lê | leitura por silhueta, peça e luz; aproximar a câmera só com o PO (Q-H4) |
| Árvore do `StoneTree` com constantes fixas | não escala sem trabalho | variante ou parâmetro de escala (M a G); plano B: árvore de cartões da copa sobre um tronco simples |
| Fonte no eixo atrapalhando quem segura "para cima" | sensação de bloqueio | chegada em u -2,4 e deslize garantido; Q-H1 |
| Chão claro demais lavando o herói e o portal | perde a hierarquia | A4 e A6; o chão para em luma 92 |
| Excesso de pequenos fogos e cor (como as referências) | ruído, quente acima de 14% | A5; metade das velas apagadas |
| Muitas luzes por malha no Compatibility | luz cortada | células de 8 m (4.3) |
| Placas da referência e nomes nela ("Akh", "Refúgio") vazando para o jogo | lore e grafia errados | nada de texto do cenário; textos só pelo `ui-ux-designer` em `text_pt.tres` |

---

## 6. Decisões para o PO (pelo Game Director)

| # | Pergunta | Opções | Recomendação |
|---|---|---|---|
| Q-H1 | Fonte do leão | (a) no meio da praça, no eixo, pequena, com faixas largas e a chegada à esquerda (H1); (b) na borda sul, no eixo, entre duas escadas de chegada, com o eixo inteiro livre (H2) | (a): é a composição da principal e não bloqueia; (b) se o PO ler "caminho direto" ao pé da letra |
| Q-H2 | Onde fica o Santuário da Vigília no mundo **[PO]** | (a) pátio a céu aberto (o entardecer das referências); (b) salão alto sob a terra com luz de cima | define céu, vista e a chave; a spec segue (a) por ser o que as três referências mostram |
| Q-H3 | Quem são o Vendedor e o Forjador, nome e fala **[PO]** | | até lá, só função e silhueta |
| Q-H4 | Câmera do hub | (a) a do jogo, distância 54, hub inteiro numa tela; (b) 46 a 48, NPCs maiores, a câmera passa a seguir o herói | (a) |
| Q-H5 | Árvore de Dons que mostra os Dons destravados (3.4) | sim / não | sim, só desenho |
| Q-H6 | Meshy | 0; ou só o leão sentado (15); ou leão e os dois NPCs (55) | 0 agora; decidir depois da captura da HUB-B |
| Q-H7 | Nome do lugar na tela | "Santuário da Vigília" (diretriz) ou outro **[PO]**; "Vigília" já aparece como voto provisório do PALADIN_1 | confirmar com o Daniel antes de virar texto |

## 7. Quem faz o quê (proposta para o plano do Game Director)

| Dono | Arquivos | O quê |
|---|---|---|
| technical-artist | `masonry.gdshaderinc`, `catacomb_floor.gdshaderinc` (uniform `frame_yaw`), `tools/bake.gd` (NPCs do KayKit) | giro da pedra, NPCs assados e martelo, fagulhas sincronizadas |
| environment-artist | cena e script novos do hub (por exemplo `scripts/game/hub_look.gd`), `ArenaKit`, `Masonry`, `StoneTree` (variante) | toda a montagem das seções 3 e 4 |
| gameplay-engineer | colisão, pontos de uso, `CamFrame.hold`, entrada direta para captura | 2.2, 2.4 e 5.1 |
| ui-ux-designer | placa e prompt | 2.4 |
| art-director | `docs/art/visual_review.md` | revisão das capturas contra a 5.2 |
