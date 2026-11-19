# Redesenho artístico das salas: matriz das 18 vistas (Etapa 0)

- **Data**: 2026-11-18. **Autor**: art-director. **Commit lido**: `af5fd02` (galeria `docs/gallery/rooms_2026-11-18/`).
- **Pedido**: diretriz do PO `docs/art/po_directive_room_redesign_2026-11-18.md`. Decisões da noite (Game Director, a
  revisar pelo Daniel): `docs/art/room_redesign_decisions.md`. Leitura de level design: `docs/design/room_redesign_level_review.md`
  (room-designer). Onde este documento e as decisões divergirem, valem as decisões.
- **Especificações implementáveis** (environment-artist, em série): biblioteca e Lote A em
  `docs/art/room_redesign_lotA_spec.md`; depois `room_redesign_lotB_spec.md` (Santuário e Fendas),
  `room_redesign_lotC_spec.md` (Jardim e Ponte), `room_redesign_lotD_spec.md` (Runas, Provação, Altar),
  `room_redesign_lotE_spec.md` (Câmara do Selo, só fundo).
- **Imagens**: conceitos e pranchas só locais em `docs/art/ref/redesign_2026-11-18/` (IA; nunca commitar, nunca evidência,
  nunca Meshy). As referências de Sworn são de outro jogo: só leitura de sensação.
- Nada implementado aqui. Meshy: zero créditos.

## 0. O que medi e o que isso muda

### 0.1 Os conceitos não são planta

Os 18 conceitos são recortes de 548 x 146 px (3,75:1) da `prancha_18_salas_principal.png`, em vista baixa e
cinematográfica. Servem para clima, paleta, materiais e marcos; nunca para medir posição. A câmera do jogo (giro 35,
inclinação 30, campo 24, distância 54) mostra 65 a 75% de chão; parede e fundo ficam numa faixa no alto (norte e
oeste) e nas bordas do abismo (room-designer, 0.1). Consequência: **chão quieto, fundo rico**. A identidade mora no
valor e no matiz do chão, nas bordas, na faixa norte e no fundo.

### 0.2 Medidas (RTX, 1080, câmera do jogo, `--bot --autopick --seed=5 --shot-at=5`, as capturas da galeria)

Caixas no quadro inteiro sem HUD (x 5 a 95%, y 8 a 85%). Matiz = média circular ponderada pela saturação HSV por pixel
(script de caixa do art-director, no scratchpad; pedido ao technical-artist: um `--hue` no `tools/frame_stats.py`).
A saturação aqui é a HSV por pixel (pixels escuros pesam), não a `SATHIGH` do `frame_stats`.

| Vista | Clássico: matiz / luma p50 | Estilizado: matiz / luma p50 | Conceito: matiz / luma p50 |
|---|---|---|---|
| 01 Salão (chão do meio) | 254 / 60 | **42** / 76 | lajes lilás-ardósia sob luz âmbar |
| 02 Cripta A | 256 / 40 | 249 / 41 | 210 / 47 |
| 03 Cripta B | 254 / 40 | 247 / 41 | 195 / 43 |
| 04 Fendas A | 245 / 39 | 242 / 43 | 265 / 49 |
| 05 Fendas B | 244 / 46 | 242 / 53 | 250 / 52 |
| 06 Jardim A | 237 / 48 | 234 / 50 | 169 / 53 |
| 07 Jardim B | 243 / 53 | 240 / 56 | 194 / 53 |
| 08 Santuário A | 236 / 58 | 231 / 59 | 25 / 71 |
| 09 Santuário B | 239 / 58 | 233 / 59 | 26 / 73 |
| 10 Ponte A | 224 / 43 | 223 / 45 | 211 / 59 |
| 11 Ponte B | 225 / 45 | 224 / 46 | 190 / 56 |
| 12 Runas A | 232 / 42 | 231 / 45 | 173 / 65 |
| 13 Runas B | 232 / 45 | 231 / 48 | 199 / 55 |
| 14 Provação (laboratório) | 246 / 32 | sem captura | 9 / 64 |
| 15 Altar (laboratório) | 211 / 26 | sem captura | 45 / 52 |
| 16 Loja (Salão, sala 10) | 233 / 45 | **47** / 63 | 14 / 60 |
| 17 Fonte (Salão) | 229 / 47 | **50** / 64 | 137 / 59 |
| 18 Câmara do Selo | 259 / 37 | 252 / 37 | 276 / 54 |

Saturação no `frame_stats` (`SATHIGH`, p90): conceitos 29 a 44; nossas capturas 8 a 28; Sworn (quatro capturas) **10 a
14** com luma média 41 a 49.

O que isso diz:
1. **Hoje as 18 vistas são uma sala só em cor**: matiz 223 a 259 em todas as arenas, nos dois perfis. O perfil
   estilizado quase não muda as arenas (a pedra das arenas não passa pelo `ArenaKit.paint_look`, e o `air()` de cada
   sala sobrescreve o ar e a chave do estilizado; só estandartes, figuras, golpes e a saturação global mudam).
2. **No Salão o estilizado foi para o lado oposto ao da diretriz**: pedra umbra morna (matiz 42 a 50) em 01, 16 e 17,
   enquanto a diretriz pede "pedra azul-petróleo" e o conceito 01 tem ardósia lilás-azulada com poças âmbar. A pedra
   umbra vinha da R1 do STY (pergunta S-Q5, recomendação (a)); a diretriz nova a substitui (decisão L-1).
3. **A riqueza dos conceitos não vem da saturação**: Sworn, que o PO cita como modelo de riqueza e leitura, é mais
   escuro e menos saturado que o nosso jogo. Riqueza = valor por laje e por bloco, bordas povoadas, fundo em camadas,
   poças de luz definidas. **Não perseguir a saturação dos conceitos** (p90 29 a 44): o teto da `art_direction.md` 3
   (cenário até 32) continua.
4. **Cripta (confirmação do pedido do Game Director)**: confirmado com correção. Chão de luta estilizado matiz 263 a 264
   (lilás), saturação HSV p50 0,15, luma p50 79 a 92, contra o conceito com matiz 204 a 208, saturação 0,29 a 0,40,
   luma p50 67 a 79. Poças quentes: 0,1 a 2,5% da caixa contra 9% no conceito. Fundo: cinza neutro chapado (26, 26,
   26, desvio zero). **Correção**: a parede norte não é "clara" (luma 40, igual à do conceito, 38); o claro demais é só o
   chão (10 a 15 níveis acima do conceito). O estilizado da Cripta é idêntico ao clássico (mesma captura por caixa,
   diferença de 1 a 2 níveis): nunca foi pintado.

### 0.3 Regras que valem acima dos conceitos (decisões da noite e guias)

1. Câmera, colisão, rotas, portas, nascimentos, perigos, avisos, raio-x e combate não mudam.
2. **As peças que barram ficam e viram os marcos** (sarcófago do meio e muro do Ossuário na Cripta, colunas do
   Santuário, árvore e raízes do Jardim, ruína do meio da Ponte, pilares das Runas).
3. **Nada novo acima de 0,3 m no chão andável**; decoração nova fica fora do polígono do chão, em cima de uma peça que
   já barra (dentro do contorno dela, 0,1 m para dentro) ou abaixo de 0,15 m (relevo, decalque, pintura). Do lado sul de
   cada sala, nada acima de 0,9 m a 2 m da borda (room-designer 2.2).
4. **Círculo no chão só no Salão** (o medalhão) **e na Câmara do Selo** (o selo). Nas outras salas o centro se lê pelo
   padrão das lajes (losangos, quadros, faixas), nunca por anel ou disco.
5. **Cores reservadas fora dos biomas perto do chão**: esmeralda da Emeth (133), verde espectral e esmeralda corrompido
   de Morvath (157 a 165), violeta dos inimigos e de Morvath (253 a 270), vermelho dos avisos (4), âmbar das Runas (30,
   só nas Runas; o fogo âmbar das outras salas é poça de luz, não pintura de chão). Petróleo saturado só no herói.
   Nenhum fogo verde, nenhum glifo verde, nenhuma folha vermelho-vivo.
6. CLASSIC reversível e intacto (diferença até 2 por canal); STYLIZED por bioma, sem filtro global. Nenhuma sala mistura
   peça pintada e peça clássica no mesmo perfil.
7. Nada de figura alada, auréola, sol, cruz (inclusive vela em cruz), estrela de pontas; estandartes só petróleo com
   leão em ouro velho; nada vermelho em pano.
8. Meshy zero. Só KayKit (o que está em `assets/models/dungeon*`), `Masonry`, `TombKit`, `ArenaKit`, geometria
   procedural, shaders, decalques e luz.
9. Nenhum perigo ou interação nova (H-1 a H-7 do room-designer são proposta separada).

### 0.4 Paleta por bioma (perfil estilizado)

Números de partida de material (sRGB 0 a 1, para o `paint_stone`/`paint_shadow` de cada sala, mantendo a luminância
linear da pedra pintada de hoje vezes o fator) e alvos de tela (o que se aceita). O environment-artist ajusta o
material até bater a tela. "Acento" é luz ou pintura de borda, nunca chão de luta.

| Bioma | Pedra (`paint_stone`) | Fator de valor | Sombra (`paint_shadow`) | Chão de luta na tela: matiz / sat HSV p50 / luma p50 | Acento e fundo |
|---|---|---|---|---|---|
| Salão (01, 16, 17) | (0,325; 0,341; 0,386), matiz 224 | 1,0 | (0,833; 0,877; 0,98) | 215 a 235 / 0,08 a 0,16 / 65 a 78 | poças âmbar 27 a 34; portal esmeralda (o único verde); abismo azul 205 a 220 |
| Cripta (02, 03) | (0,285; 0,32; 0,347), matiz 206 | 0,85 | (0,784; 0,898; 0,98) | 198 a 215 / 0,10 a 0,20 / 60 a 75 | poças âmbar de vela 26 a 34; névoa e fundo ciano-petróleo 195 a 205, sat até 0,3, só fora do chão |
| Santuário (08, 09) | calcário (0,38; 0,363; 0,334), matiz 38 | 1,15 | fria (0,86; 0,9; 0,98) | 30 a 45 / 0,06 a 0,14 / 70 a 85 | fachos marfim-dourados (ouro velho 34 a 42), estandartes petróleo; o único bioma de pedra morna entre as salas de luta |
| Fendas (04, 05) | ardósia-índigo (0,327; 0,319; 0,363), matiz 250 | 0,9 | (0,87; 0,833; 0,98) | 235 a 255 / 0,06 a 0,14 / 50 a 65 | violeta só abaixo da borda e no fundo, sat da tela até 0,45; fogo âmbar nas cabeceiras |
| Jardim (06, 07) | cinza-musgo (0,312; 0,331; 0,285), matiz 85 | 0,9 | (0,86; 0,92; 0,98) | 70 a 100 / 0,08 a 0,18 / 55 a 70 | folha morta ferrugem (matiz 15 a 25, sat até 0,45, valor até 0,4); água escura azul 200 a 210 só fora do chão |
| Ponte (10, 11) | cinza-azulado gasto (0,318; 0,335; 0,354), matiz 212 | 0,95 | (0,833; 0,906; 0,98) | 205 a 220 / 0,06 a 0,14 / 55 a 70 | bruma azul 205 a 215 sat até 0,35; cascatas marfim-azuladas; fogo âmbar nas cabeceiras |
| Runas (12, 13) | pedra clara fria (0,344; 0,349; 0,366), matiz 225 | 1,05 | (0,902; 0,921; 0,98) | 220 a 235 / 0,03 a 0,10 / 62 a 75 | fio de ouro velho nas lajes; glifos dos pilares em marfim e ouro velho; **âmbar só na laje acesa** |
| Provação (14) | lilás-cinza (0,338; 0,317; 0,352), matiz 275 | 0,9 | (0,923; 0,843; 0,98) | 265 a 285 / 0,06 a 0,14 / 50 a 62 | lilás acinzentado da maldição nas veias e na fenda da estela; foco marfim |
| Altar (15) | pedra morna calma (0,354; 0,339; 0,319), matiz 35 | 1,0 | fria (0,88; 0,9; 0,98) | 28 a 42 / 0,05 a 0,12 / 50 a 62 | velas e ouro velho; estandartes petróleo desbotados |
| Câmara do Selo (18) | sem mudança de pedra | | | a de hoje | azul-marinho e violeta só no fundo distante, saturação até 0,45 |

Regra de convivência: duas salas vizinhas na descida nunca têm a mesma família de matiz no chão (o mapa sorteia; com
dez famílias distintas acima, isso já vale).

## 1. Matriz por vista

Formato: sala real e arquivos; captura e conceito; o que o conceito propõe; o que existe e reaproveita; viável (shader,
peça procedural, luz, decalque); inviável sem malha nova; paleta e luz; marco; peças e onde; riscos de leitura;
esforço (P até 1 sessão, M 1 a 2, G 2 a 4 sessões do environment-artist com capturas); dependências.

### 01 Salão das Catacumbas (também 16 Loja e 17 Fonte)
- **Real**: `CatacombHall` (`scripts/game/catacomb_hall.gd`), layout `hall` no `_stage`; `ArenaKit`, `Masonry`,
  `catacomb_floor*.gdshader`, `portal.gdshader`; estilizado em `CatacombHall._stylize`, `VisualProfile`. 32 x 30 m sobre
  o abismo, câmera que segue.
- **Captura / conceito**: `docs/gallery/rooms_2026-11-18/atual|estilizado/01_salao_catacumbas.jpg`;
  `conceitos/01_salao_catacumbas.png`.
- **Propõe**: salão de pedra azul, arcos em profundidade, dois pares de estátuas encapuzadas e estandartes petróleo com o
  leão, braseiros âmbar, círculo discreto no chão, portal esmeralda ao fundo, velas em grupos nos plintos.
- **Existe**: tudo isso (é a pintura de referência de 2026-11-14 vista de baixo): estátuas do portal, estandartes,
  braseiros, medalhão, portal com profundidade (AP-1), arcadas e ruínas do abismo, velas em grupos (metade apagadas).
- **Viável**: pedra de volta à ardósia azul no estilizado (preset do bioma), sombra fria colorida, poças âmbar já
  feitas (STY-10), velas apagadas com cera velha (já), urnas e oferendas nos plintos e no pé das estátuas (sobre peças),
  balaustrada quebrada em trechos só no desenho (decisão do room-designer: sem mexer na colisão).
- **Inviável sem malha**: estátuas com pregas fundas e moldura do portal esculpida (ART-03.8; estimativa já feita:
  15 créditos cada, não autorizado).
- **Paleta e luz**: ver 0.4. Chave estilizada morna-neutra de trás da câmera (fica), ambiente puxado ao frio, poças
  âmbar com borda.
- **Marco**: o portal no fim do eixo da escada (já é).
- **Riscos**: vela em cruz do conceito (recusada); medalhão de quatro pontas (S-Q6, pendente); ciano do fundo perto do
  herói (caixa de 300 px: verde e ciano até 2%); borda falsa de 39 m² não pode crescer.
- **Esforço**: P a M (é reajuste de números e um preset). **Dependências**: biblioteca (Lote A), L-1.

### 02 Cripta dos Esquecidos A
- **Real**: layout `crypt` variante 0 (`_crypt` no `make_data.gd`: 24 x 21 m, corte a nordeste), `CryptLook`
  (`scripts/game/crypt_look.gd`), `ArenaRoom`, `TombKit` (túmulo, nicho, laje). Câmera fixa em (1,0; 1,5).
- **Captura / conceito**: `.../02_cripta_A.jpg`; `conceitos/02_cripta_A.png`.
- **Propõe**: cripta íntima, sarcófagos baixos com efígie, velas agrupadas em poças quentes, névoa azul-fria, nichos com
  urnas, janela fria ao fundo.
- **Existe**: quatro nichos (dois com estátua encapuzada, dois com prateleiras de potes e ossos), túmulo grande com
  degraus e velas, três sarcófagos, lajes de túmulo no chão, facho frio do teto com poeira, braseiros nos recessos com
  estandartes do leão, monte de blocos a nordeste, frente cortada a 0,9 m.
- **Viável**: pedra petróleo pintada (preset), efígie amortalhada procedural sobre a tampa do túmulo grande (em cima de
  peça que barra), urnas de pedra e bronze (`Masonry.pot` com outro material) nos nichos e no parapeito das paredes,
  velas agrupadas apagadas e acesas nos nichos, brilho frio dentro do arco da porta norte, fundo em camadas com bruma
  ciano (`ArenaRoom.backdrop`, só estilizado), chaves de luz e ar do bioma.
- **Inviável sem malha**: crânios empilhados (não essenciais; ossos em feixe já existem).
- **Marco**: o túmulo grande com a efígie sob o facho frio.
- **Riscos**: ciano no chão perto do herói (proibido: névoa só fora do chão); petróleo da pedra perto do cachecol do
  herói (separação pela saturação: pedra até 0,2, cachecol 0,57); poças quentes perto dos avisos vermelhos (aro 40 acima
  da laje continua obrigatório).
- **Esforço**: M. **Dependências**: biblioteca.

### 03 Cripta dos Esquecidos B ("Ossuário")
- **Real**: `crypt` variante 1: muro divisor de 7 x 0,8 x 3,2 m saindo da parede norte em x 0,5 (z -10,5 a -3,5), em
  pontilhado, com nichos de ossos e o pilarete da espada na ponta sul (`CryptLook.ruin_wall`); metade sul aberta.
- **Captura / conceito**: `.../03_cripta_B.jpg`; `conceitos/03_cripta_B.png`.
- **Propõe**: cripta ritual vertical, figura velada monumental, urnas, pequenas escadas, luz verde distante, vazio
  central.
- **Existe**: o muro (a regra da B), o facho frio na ponta dele, velas apagadas na baía oeste.
- **Viável**: figura velada na ponta sul do muro, sobre o topo do pilarete (marco vertical; mesma `hooded_statue`, sem
  rosto), urnas no pé do muro dentro da caixa de colisão dele, fundo frio mais forte pela porta norte. **Luz distante
  fria azul-marfim, não verde** (regra das cores).
- **Inviável**: escadas no chão andável (degrau falso); braseiros verdes.
- **Marco**: o muro com a figura velada sob o facho.
- **Riscos**: figura alta perto do herói: o muro já está em pontilhado (`see_through`), a figura também tem de estar.
- **Esforço**: P (sobre o trabalho da A). **Dependências**: 02.

### 04 Salão das Fendas A
- **Real**: `rift` variante 0 (42 x 30 m, fenda de norte a sul, duas pontes de 5 m, buraco a leste); `RiftLook`
  (`rift_look.gd`, `rift_haze.gdshader`, `ArenaRoom.bridge`, `broken_lip`).
- **Captura / conceito**: `.../04_fendas_A.jpg`; `conceitos/04_fendas_A.png`.
- **Propõe**: ruína sobre abismo violeta, arcos fraturados, correntes, braseiros em pedestal, cacos flutuando.
- **Existe**: lábios quebrados, bruma violeta em três folhas, pontes em arco, fachada com pórtico, estátuas, torre e
  correntes, arcos cegos.
- **Viável**: pedra índigo pintada, mais correntes e arcos partidos só ao norte (além da borda), cacos de pedra parados no
  ar da fenda (blocos procedurais, abaixo do nível do chão), braseiros âmbar nas cabeceiras fora do tabuleiro.
- **Inviável**: o pátio redondo com círculo de ouro do conceito (não é a sala).
- **Marco**: as duas pontes sobre a fenda.
- **Riscos**: violeta subindo da fenda sob os orbes violeta do feiticeiro e as trepadeiras dos sacerdotes: saturação da
  bruma até 0,45 (C18), violeta acima de 60% até 5% da tela; fogo verde recusado.
- **Esforço**: M. **Dependências**: biblioteca; Lote B.

### 05 Salão das Fendas B
- **Real**: `rift` variante 1 (ponte norte caída, buraco a oeste, segunda onda no noroeste).
- **Captura / conceito**: `.../05_fendas_B.jpg`; `conceitos/05_fendas_B.png`.
- **Propõe**: fenda cósmica, arco circular partido, fragmentos suspensos, vórtice violeta.
- **Decisão P-6**: o marco é a **ponte caída** (tocos, pedaços pendurados, que existem); o vórtice só como acento
  distante e baixo no fundo, dessaturado.
- **Viável**: arco partido grande atrás da ponte caída (voussoirs procedurais, `Masonry.voussoir_arch`), pedaços da ponte
  suspensos nas correntes, brilho violeta só abaixo da borda.
- **Riscos**: vórtice no alto da tela onde nascem os inimigos do norte.
- **Esforço**: P a M. **Dependências**: 04.

### 06 Jardim das Raízes Mortas A
- **Real**: `garden` variante 0 (34 x 28 m, árvore de pedra em (-8; -5) de raio 3,5 m, quatro raízes baixas);
  `GardenLook` (`garden_look.gd`, `stone_tree.gdshader`, `canopy.gdshader`, `root_moss.gdshader`, `crystal_edge.gdshader`).
- **Captura / conceito**: `.../06_jardim_A.jpg`; `conceitos/06_jardim_A.png`.
- **Propõe**: bosque corrompido, árvore antiga com raízes, folhas vermelhas, fungos, água turquesa, ruínas engolidas.
- **Decisão P-7**: árvore de pedra (D-30), folhagem morta e ferrugem só nas bordas e na copa.
- **Viável**: pedra musgosa pintada, copa em cartões (existe) com folha ferrugem apagada, musgo pintado no pé das paredes
  e ao longo das raízes (existe, ganha gêmeo pintado), água escura atrás das janelas cegas e além do corte noroeste,
  fungos pálidos em cachos sobre as peças (sem brilho verde).
- **Inviável**: árvore viva frondosa como modelo (copa em cartões resolve).
- **Marco**: a árvore.
- **Riscos**: folha vermelha perto da borda onde os avisos chegam (valor até 0,4 e sat até 0,45); turquesa (perto do
  petróleo do herói e da Emeth): água em azul escuro 200 a 210.
- **Esforço**: M a G. **Dependências**: biblioteca (musgo, água); Lote C.

### 07 Jardim das Raízes Mortas B
- **Real**: `garden` variante 1 (raízes mais curtas, centro de luta a leste).
- **Propõe**: pátio invadido, cascatas, lago, bioluminescência.
- **Viável**: cascata e lago **fora da borda oeste**, no lugar visual da parede (sem mudar o polígono), espuma clara
  abaixo do glow; bioluminescência azul-fria pontual nas bordas.
- **Riscos**: brilho verde (diretriz: evitar), cascata clara atrás dos inimigos (silhueta boa; cor não).
- **Esforço**: M. **Dependências**: 06.

### 08 Santuário Desmoronado A (casa do guardião)
- **Real**: `sanctuary` variante 0 (44 x 28 m, nave entre colunas, presbitério atrás da grade a oeste, guardião em
  `boss_spawn`); `SanctuaryLook` (`sanctuary_look.gd`, `moon_shaft`).
- **Captura / conceito**: `.../08_santuario_A.jpg`; `conceitos/08_santuario_A.png`.
- **Propõe**: templo abandonado, estátuas encapuzadas, grandes arcos, fachos dourados, estandartes velhos, entulho,
  escadaria cerimonial ao fundo.
- **Existe**: nave, janelas cegas, presbitério elevado com altar, estandartes, estátuas em nichos, fachos de lua,
  colunas em três silhuetas, monte da abóbada caída.
- **Viável**: calcário morno pintado, fachos de lua passam a marfim-dourado (ouro velho) com poeira, facho sobre o
  `boss_spawn`, estátuas e estandartes contra as paredes norte e oeste, entulho dentro das caixas das colunas quebradas,
  escadaria do presbitério como marco (já existe, ganha velas e luz).
- **Riscos**: facho forte clareando o chão onde caem os avisos: aro do aviso 40 acima da laje medido dentro do facho.
- **Esforço**: M. **Dependências**: biblioteca; Lote B.

### 09 Santuário Desmoronado B
- **Real**: `sanctuary` variante 1 (buraco de 9 x 7 m na nave, cripta de baixo `UNDER`).
- **Decisão**: sem céu de poente; a **abóbada caída** sobre o buraco, rasgo de luz fria de cima caindo nele.
- **Viável**: rasgo da abóbada como peça alta fora da vista do chão (só a luz e a poeira descem), facho frio mais forte
  sobre o buraco, `broken_lip` (existe).
- **Esforço**: P a M. **Dependências**: 08.

### 10 Ponte dos Condenados A
- **Real**: `bridge` variante 0 (56 x 18 m, três plataformas e duas pontes de 5 x 7 m); `BridgeLook` (`bridge_look.gd`).
- **Propõe**: ponte monumental, arcos de sustentação, correntes, tochas, colunas, abismo azul com cascatas.
- **Viável**: pedra cinza-azulada pintada, pilares com braseiro nas cabeceiras **fora do tabuleiro**, arcos e correntes
  embaixo, cascatas ao norte no fundo, bruma azul que corre (existe).
- **Inviável**: ornamento de ouro no tabuleiro (decalque dourado no chão lê como círculo ou aviso: recusado).
- **Riscos**: fantasma de 4,1 m² (o maior das arenas): nada que o aumente; fundo ciano atrás dos atiradores.
- **Esforço**: M. **Dependências**: biblioteca; Lote C.

### 11 Ponte dos Condenados B
- **Real**: `bridge` variante 1 (ponte de 24 x 5 m com patamar de 6 x 9 m).
- **Viável**: passarelas e ponte desabada só no fundo, lanternas suspensas acima de 2,6 m sem luz forte no tabuleiro.
- **Riscos**: tabuleiro quebrado na borda lido como queda; o fantasma de 2,8 m² da alvenaria do patamar deve cair antes de
  enfeitar.
- **Esforço**: P a M. **Dependências**: 10.

### 12 Câmara das Runas Instáveis A
- **Real**: `runes` variante 0 (30 x 24 m, grade de 10 x 8 lajes de 3 m, quatro pilares de runas); `RunesLook`
  (`runes_look.gd`), `rune_floor.gdshader` (sem gêmeo pintado), `rune_tiles.gdshaderinc`, `rune_groove.gdshader`.
- **Propõe**: laboratório rúnico, obeliscos com glifos, mecanismo circular dourado ao fundo.
- **Viável**: pedra clara fria pintada, glifos dos pilares em marfim e ouro velho que esquentam com as lajes (sulcos já
  esquentam), mecanismo ao fundo **quadrado ou em losango** (D-29: nada redondo), em ouro velho apagado, na parede norte.
- **Inviável**: círculo e glifos verdes no chão (falso aviso).
- **Riscos**: qualquer marca luminosa no chão que não seja o estado da laje; âmbar decorativo.
- **Esforço**: M (gêmeo pintado do `rune_floor`). **Dependências**: biblioteca; Lote D.

### 13 Câmara das Runas Instáveis B
- **Real**: `runes` variante 1 (dois pilares e a pedra quieta de 6 x 6 m no meio).
- **Viável**: o cristal **fora do chão, ao norte**, atrás da borda, frio marfim-azulado com brilho só na aresta; a pedra
  quieta com um fio de ouro (existe).
- **Inviável**: cristal alto no meio (esconde inimigos, fantasma).
- **Esforço**: P. **Dependências**: 12.

### 14 Câmara da Provação
- **Real**: `trial` (`_trial_room`, 16 x 14 m, sem luta), `TrialLook` (`trial_look.gd`, estela `stele_crack.gdshader`,
  `trial_veins.gdshader`, `backdrop`). Captura atual só do laboratório: `.../atual/14_camara_provacao.jpg`.
- **Propõe**: arena ritual, piso geométrico, estandartes vermelhos, braseiros, "símbolo central de Eterra".
- **Decisões**: lilás, sem cara de arena (P-8); o símbolo é o selo rachado da estela que existe; nada vermelho; nada de
  pedestal de fogo no chão.
- **Viável**: pedra lilás-cinza pintada, piso em losangos concêntricos quadrados (relevo pintado, sem círculo),
  estandartes petróleo desbotados nas paredes do fundo, braseiros frios apagados fora do chão, a fenda da estela como a
  única luz lilás.
- **Esforço**: P a M. **Dependências**: Lote D.

### 15 Altar Esquecido
- **Real**: `altar` (`_altar_room`, 18 x 14 m), `AltarLook` (`altar_look.gd`: arco cego, leão em relevo
  `altar_lion.gdshader`, 11 velas que se acendem, estandartes desbotados). Captura: `.../atual/15_camara_altar.jpg`.
- **Propõe**: figura alada velada com auréola, altar, luz dourada, oferendas.
- **Decisão P-9**: sem figura alada nem auréola. Fica o leão em relevo e as velas.
- **Viável**: pedra morna calma, oferendas (urnas, potes, panos dobrados) no degrau do altar e nas bordas, hera e musgo
  discretos no arco, facho dourado fraco sobre o altar.
- **Esforço**: P a M. **Dependências**: Lote D.

### 16 Loja (Salão na sala 10)
- **Real**: o Salão (`CatacombHall`) com 5 placas numa fileira (`Rooms.SHOP_STEP` 5 m, `SHOP_SHIFT` 3,5 m),
  `RewardGem`, `DoorSign`. Pisar compra.
- **Decisão P-10**: Salão vestido.
- **Viável (Lote A, vestido do Salão)**: tenda de pano terroso e prateleiras de caixotes **atrás da fileira** (lado norte,
  fora da rota), panos e lanternas acima de 2,6 m, tapete pintado sob a fileira (relevo, sem altura).
- **Inviável sem malha**: frascos, mapas e balcão finos (o KayKit do projeto não tem prateleira, mesa nem frasco;
  pesquisa de pacote CC0 gratuito fica com o technical-artist, nada baixado).
- **Riscos**: pano vermelho saturado ao lado do preço rosa "faltam N": pano em umbra e ocre apagados.
- **Esforço**: M. **Dependências**: 01; posição exata das placas (`Rooms`).

### 17 Fonte (Salão)
- **Real**: na descida a fonte é **fixa em (0; -2) do Salão** (`rooms.gd`, `game.spawn_fountain(Vector2(0, -2.0))`;
  o lugar sorteado a 13 m do `Game._spawn_fountain` é o do modo horda): bacia `ArenaKit.fountain`,
  `fountain_water.gdshader`.
- **Decisão P-11**: bica de pedra simples.
- **Viável (Lote A)**: musgo pintado e flores pálidas no pé da bacia (decalque no chão em volta, abaixo de 0,15 m), luz de
  descanso marfim-azulada, bacia na pedra do bioma.
- **Riscos**: água azul fria sobre pedra azul perde contraste: medir a caixa da fonte (luma da água 40 acima da laje).
- **Esforço**: P. **Dependências**: 01.

### 18 Câmara do Selo
- **Real**: `BossChamber` (`boss_chamber.gd`), `SealLook`, `chamber_floor.gdshader`, círculo de 12,5 m; nada pode
  entrar no círculo (`test_chamber_look.gd`).
- **Propõe**: arcos destruídos, correntes, vazio violeta, selo circular, portal cósmico.
- **Decisão**: só fundo e atmosfera; sem sol negro, sem braseiros no anel; Morvath é o centro.
- **Viável**: arcos partidos e correntes a mais no anel distante, cacos parados no ar além do círculo, ar violeta
  distante abaixo de 0,45.
- **Esforço**: P a M. **Dependências**: biblioteca; Lote E.

## 2. Biblioteca compartilhada (resumo; detalhes no `room_redesign_lotA_spec.md`)

| Peça | Tipo | Existe | O que falta | Lote que a cria |
|---|---|---|---|---|
| Preset de bioma (`style()` de cada sala: pedra, sombra, fogo, ar, fundo) | dado em código | não (só o `_stylize` do Salão) | gancho comum no `ArenaRoom` e no `CatacombHall` | A |
| Pedra e chão pintados | shader | `masonry_paint`, `catacomb_floor_paint`, `paint.gdshaderinc` | `paint_stone`/`paint_shadow` por material (já são uniforms), aplicação nas arenas | A |
| Poças de fogo | luz | `CatacombHall._stylize` | levar para o `ArenaKit` (`stylize_fires`) | A |
| Ar estilizado por sala | ar | `VisualProfile.dress_world` (global) | `air()` do estilizado em cada sala e troca no F7 | A |
| Fundo em camadas | geometria e shader | `ArenaRoom.backdrop`, `ruin_card`, `mist_bank` | uso nas arenas fechadas, só estilizado | A |
| Metal (ouro velho, bronze, ferro) | material | `TombKit.gold`, `iron`, `_bronze` | gêmeo fosco por `VisualProfile.vary` | A |
| Pano | material | estandartes petróleo (`BANNER_PAINT_*`) | paleta terrosa para a Loja | A (Loja) |
| Cera e vela | material | `STY_WAX`, chamas âmbar | nada | |
| Efígie amortalhada, urna de pedra | peça procedural | `Masonry.pot`, `hooded_statue`, `_lathe` | efígie deitada; urna com material de pedra ou bronze | A |
| Musgo | shader | `root_moss.gdshader` | gêmeo pintado | C |
| Folha morta, fungo | cartões | `canopy.gdshader` | cor ferrugem; cachos de fungo | C |
| Água | shader | `fountain_water.gdshader` | lago e cascata escuros | C (Fonte no A só recolor) |
| Runas | shader | `rune_floor`, `rune_tiles`, `rune_groove` | gêmeo pintado do `rune_floor`; glifos marfim | D |

Densidade (vale para todos os lotes): por 10 m de borda vista, um marco (estátua, nicho, túmulo, braseiro) e dois a três
grupos menores (urnas, velas, entulho); grupos de velas acesos no máximo um a cada 6 m de borda e pelo menos metade dos
grupos apagados; nada novo a menos de 1,5 m da boca de uma porta acima de 0,3 m; nenhuma peça nova com saturação acima
de 0,45 (fogo e cores reservadas à parte); nenhuma peça nova mais clara que o meio do chão (fogo e marco à parte).

## 3. Decisões de lore e simbologia

Estado depois das decisões da noite (Game Director, `room_redesign_decisions.md`), **todas a revisar pelo Daniel**:

| # | Assunto | Cânone (`../dungeon-rpg/docs/mundo/canone.md`) | Decisão da noite | Minha recomendação |
|---|---|---|---|---|
| L-1 | Pedra do estilizado: morna (STY S-Q5 a) ou azul-petróleo (diretriz) | sem relação | por bioma (decisões, "cores") | **Frio por bioma, poças mornas**; o Salão sai da umbra para a ardósia azul. Confirmar com o Daniel que a diretriz substitui a S-Q5 |
| L-2 | Estandartes com o leão | o leão é o sinal de Hanokh e de Elun, entalhado em cada selo; sobre cada selo há uma igreja | continuam, petróleo e ouro velho (D-64 a D-71, Q-22 a) | De acordo; no máximo dois por sala; nunca na Câmara do Selo (lá a espada erguida) |
| L-3 | Estandartes e panos vermelhos (14, 16) | vermelho é o Dragão e o selo real em cera; nos estandartes, nada | não | De acordo; Loja em pano umbra ou ocre apagado |
| L-4 | Bica de leão na fonte (17) | as fontes de luz são o sinal do Sopro, onde guardiões e paladinos deram a vida; o leão é outro sinal | bica de pedra simples (P-11) | De acordo: misturar o sinal do Sopro com o do Leão é lore nova |
| L-5 | Figura alada e auréola no Altar (15) | nada de anjos no cânone; sol e cruz recusados | não (P-9) | De acordo; o Altar continua com o leão em relevo |
| L-6 | "Símbolo central de Eterra" (14) | não existe; os três símbolos são leão, espada erguida e as fontes de luz | o selo rachado da estela | De acordo |
| L-7 | Círculos dourados no chão (10 conceitos) | | só Salão e Câmara (P-4) | De acordo; e o medalhão do Salão ainda depende da S-Q6 (quatro pontas) |
| L-8 | Fogo e glifos verdes (03, 04, 12, 13, 15) | | não (cores reservadas) | De acordo; luz distante da Cripta B fria azul-marfim |
| L-9 | Céu de poente (09) | descida subterrânea | abóbada caída | De acordo |
| L-10 | Sol negro / portal cósmico (18) | o Abismo é a prisão do Dragão; portal aberto seria lore | sem sol negro | De acordo; a porta selada que já existe é o portal |
| L-11 | Mercador da Loja (16) | nenhum mercador definido | Salão vestido, sem personagem | Posto sem ninguém (caixotes, panos, lanternas); quem vende é pergunta para o Daniel |
| L-12 | O cristal da pedra quieta (13) como razão de ela não acender | nada | cristal fora do chão | Fica como imagem, sem explicação em texto |

## 4. Ordem dos lotes e aceite

Ordem decidida (P-13, pela exposição real; justifica a troca do Santuário para o B: toda descida passa pelo guardião
lá, 1,57 vez por descida):

1. **Lote A**: biblioteca, Cripta A e B, Salão (com Loja e Fonte vestidas). Dentro do lote: biblioteca e Cripta
   primeiro (sala fechada, câmera fixa, nunca pintada: prova o preset de bioma), depois o Salão (reajuste do que o STY
   já fez) e por fim Loja e Fonte (só vestido do Salão).
2. **Lote B**: Santuário A e B, Fendas A e B.
3. **Lote C**: Jardim A e B, Ponte A e B (musgo, folha, água).
4. **Lote D**: Runas A e B, Provação, Altar (gêmeo pintado das Runas; câmaras de evento).
5. **Lote E**: Câmara do Selo, só fundo e atmosfera.

Aceite comum a todo lote (cada spec acrescenta o seu):
- **Clássico intacto**: as capturas clássicas das salas tocadas iguais às da galeria de 2026-11-18 (diferença até 2 por
  canal fora das chamas); `tools/test.sh -gselect=test_visual_profile` e um teste do lote que monta cada sala tocada,
  troca o look duas vezes e compara materiais, luzes, visibilidade e colisão.
- **F7 dentro de cada sala** troca e volta exato (o ar da sala também).
- **Jogo**: `tools/fit_probe.gd -- --arena=<id> --variant=<n> --look=stylized` sem subir fantasma nem peça sem desenho
  (mais de 0,1 m²), `tools/test.sh -gselect=test_arenas`, 8 sementes do robô por sala tocada sem `stuck`.
- **Capturas**: `RES=1920x1080 tools/gpu.sh shot` com a mesma linha da galeria (`--arena=<id> --variant=<n> --bot
  --autopick --seed=5 --shot-at=5`, `--look=stylized`), mais 1280 x 720 e uma em luta com aviso (`--shot-at=9`); antes e
  depois em `docs/gallery/redesign/<lote>/`; `python3 -I tools/frame_stats.py` no quadro e na caixa do herói.
- **Leitura**: alvos de tela da 0.4; quadro de luta luma média 52 a 70; `SATHIGH` até 26; caixa de 300 x 300 px do
  herói com verde e ciano até 2%; aro de aviso 40 ou mais acima da laje; herói achado em 1 s; nenhum círculo novo no
  chão; nenhuma cor reservada fora do dono.
- **Desempenho**: no máximo 6 luzes com sombra por sala; RTX 1080 Alta e iGPU 1280 x 720 Baixa
  (`tools/gpu.sh run ... -s tools/sty_probe.gd ... --quality=baixa`) a no máximo 3 qps abaixo da linha de base do
  estilizado medida antes do lote; compilação de shader sem erro no Forward+ e no Compatibility (`DRIVER=opengl3
  tools/shot.sh`, uma captura por sala).
- **Revisão**: art-director registra em `docs/art/visual_review.md`; o combat-feel-director confere avisos e golpes
  numa captura de luta por bioma.
