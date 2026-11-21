# HV: Santuário da Vigília Rev. 02, spec de arte

Dono: `art-director`. Para: `room-designer` (HV-0, a planta que manda), `environment-artist` (HV-A mínimo, HV-C, HV-D),
`technical-artist` (NPCs no lugar novo), `ui-ux-designer` (placa no pé, HV-D), `gameplay-engineer` (HV-A, HV-B).
Data: 2026-11-21. Lido: pacote `docs/design/po_2026-11-20/santuario_vigilia/eterra_santuario_vigilia/` (`LEIA_PRIMEIRO`,
`03_07_DIRECAO_ARTISTICA_E_IMPLEMENTACAO`, planta `02_` em imagem, pintura `01_`), `docs/backlog.md` (P.1, P.5),
`docs/design/hub_spec_art.md` (paleta 4.2 com a emenda de 2026-11-20), `scripts/core/hub_plan.gd`,
`scripts/game/hub_look.gd`, `CLAUDE.md` (Hub, HUB-D, BH-07). Sem Meshy.

**Decisões que valem** (o Daniel, 2026-11-21, pela recomendação):
- **Q-HV1 (a)**: disposição de hoje (Vendedor e Árvore em cima, Forja e Livro embaixo) com os raios da planta.
- **Q-HV2 (a)**: o poço sul sai; toda chegada é no selo sudeste.
- O Alquimista é **espaço e cenário**, sem NPC, sem nome, sem placa, sem uso, bancada vazia (Q-OF7 atualizada).
- **Nenhum quebrável no hub**; vasos e caixas de clima são decoração e não podem ler como os da descida (ver 5).
- Onde a pintura e a planta discordam, a planta manda em posição e medida, a pintura em cor, forma e clima, e a câmera do
  jogo é a prova final. A pintura põe a banca de frascos a leste; vale o **oeste** da planta e do texto.

Esta spec liga a lista ESSENCIAL e CLIMA às peças que já existem, diz o que é novo, dá luz, cor e leitura. As coordenadas
finais da planta são do `room-designer` no HV-0 (`docs/design/hub_spec.md`, seção Rev. 02); as daqui são a proposta de
arte e respeitam larguras, rotas e linha de vista do pacote.

## 1. Eixo e conversão

O `HubPlan` usa (u; v) com a origem na Fonte, u para a direita da tela e v para cima. A planta usa x leste e z norte
com a mesma origem. Como o norte da planta é o alto da tela, **u = x e v = z**; o `HubPlan.to_world` gira pelo
`cam_yaw`. Com a Q-HV1 (a), as estações de baixo e de cima trocam de linha em relação à planta literal (v vira -v para
Forja, Vendedor, Árvore e Livro).

**Regra de frente para as estações de baixo**: a câmera olha para +v; uma peça ao sul do ponto de uso fica entre a câmera
e o herói (cobre ele e mostra as costas). Então, embaixo, a peça fica **para fora** (Forja a oeste do uso, Livro a leste),
de lado, com a frente virada para o meio da praça (três quartos para a câmera), como o HUB-D já faz. Em cima, a peça fica
ao norte do uso, de frente para a câmera.

## 2. Planta de arte em (u; v)

| Peça | Hoje | Rev. 02 (proposta de arte) | Pegada que colide | Notas |
|---|---|---|---|---|
| Chão | 50 x 32,5 m, lóbulos ao norte, poço sul (`WELL`), cantos cortados (`CUT`) | 50 x 32 m de u -25 a 25, v -16 a 16; **sem o poço**; o canto sudeste sem o corte (o chão vai até (25; -16) para caber a escada); norte como hoje (terraço, lóbulos) | contorno não retangular, borda de penhasco física | o canto sudoeste mantém o corte |
| Selo do Retorno | medalhão de chegada na praça (0; -4,6) | **(18; -11,4)**, 3 m de diâmetro | não barra | `ARRIVAL` = (18; -11,4) |
| Escada do Retorno | poço sul com 20 degraus | borda sul, u 14,5 a 21,5, descendo de v -16 a -18,5 para a bruma (7 x 2,5 m) | degraus não são chão | o herói chega subindo por ela (a câmera vê os degraus de cima) |
| Portal (uso) | (0; 11) | **(0; 11), fica** | fachada e escada de hoje | o enquadramento da Longe foi medido nele |
| Fonte do Leão | bacia de 5,6 m, `FOUNTAIN` raio 2,6 | bacia de **6,2 m**, raio de bloqueio **3,1** | círculo 3,1 | passagem em volta de 3,5 m ou mais |
| Vendedor (uso) | (-11,5; 10,6), balcão em (-13; 13) | uso **(-10,3; 5,2)**, barraca 6,5 x 3,6 m centrada em **(-10,6; 8,0)** (v 6,2 a 9,8) | só o balcão (`COUNTER` com `COUNTER_HALF`); o toldo não | frente para o sul; o Vendedor (`VENDOR_SPOT`) atrás do balcão |
| Árvore de Dons (uso) | (11,5; 10,6), estrado em (14,8; 13,4) | uso **(10,1; 5,0)**, base 6 x 5 m centrada em **(11,0; 8,6)** (u 8 a 14, v 6,1 a 11,1) | tronco e raízes no estrado | o pé da base a 1,1 m à frente do uso |
| Forja (uso) | (-11,5; -3,6), forno em (-17; -0,6), bigorna (-13,4; -4,4) | uso **(-10,3; -5,2)**; plataforma 3,7 x 6,6 m (deitada ao longo de v) centrada em **(-14,4; -6,1)** (u -16,25 a -12,55, v -9,4 a -2,8): forno com chaminé no lado oeste, boca para o leste, bigorna à frente a cerca de (-12,6; -5,6) | forno, bigorna, cavalete (`SMITH_SPOT` onde o martelo pousa) | sai de cima do espaço do Alquimista; o pátio `YARD` vai junto para o sudoeste, cerca de (-20; -7,5) |
| Livro de Ahk (uso) | (11,5; -3,6), atril (13,4; -4,4), estante (17; -0,6), mesa (21; -3,2) | uso **(10,1; -5,1)**; arcada 3,6 x 6 m (deitada ao longo de v) centrada em **(14,6; -4,0)** (u 12,8 a 16,4, v -7 a -1), aberta para o oeste, atril na boca, estante e mesa dentro | estantes, atril, mesa; o tapete não | a arcada fica a leste da linha selo até o Livro (rota livre) |
| Alquimista (sem uso) | nada | espaço 4,3 x 5 m centrado em **(-18,4; 0)** (u -20,55 a -16,25, v -2,5 a 2,5), bancada de 2 x 0,8 m no fundo oeste, de frente para o leste | bancada e prateleira; o toldo não | constante `ALCHEMIST`, **fora de `STATIONS`**: sem foco, placa, uso, luz de foco |

Conflitos de lugar que o HV-0 resolve (peças de hoje no caminho novo):
- `CYPRESSES` (-10,4; 2,6) e (10,4; 2,6) ficam na rota do anel entre Forja, Alquimista e Vendedor (e do lado leste entre
  Livro e Árvore): sair para a borda (proposta: (±21,5; 6,5), atrás das estações, junto da arcada lateral).
- `URNS` (±15,6; 5,6) ficam a 1,6 m das bases do Vendedor e da Árvore: ir para o pé das paredes laterais.
- `ARRIVAL_FIRES` (±4,8; -11,4) saem da praça e viram os **dois braseiros menores** do Retorno (5.2).
- `GOODS` e `ARBOUR` dos lóbulos ficam como clima (o Vendedor desce); os lóbulos norte viram descanso (bancos, flores,
  estandartes), sem nada de uso.
- O medalhão do leão na praça (`MEDALLION` (0; -4,6)) **fica**, sem ser chegada: vira o centro do anel sul da praça. O
  selo do Retorno é menor e mais gasto (2.1 da hierarquia: o Retorno é discreto).

**Linha de vista do Retorno ao Portal**: a reta de (18; -11,4) a (0; 11) passa a 6,9 m do centro da Fonte e a oeste da
arcada do Livro e da base da Árvore; nenhuma peça alta fica sobre ela no chão. Na tela, o que vale é a captura (6.1): do
selo, o arco inteiro do Portal e o verde dentro dele à vista na Perto e na Longe, sem a arcada do Livro (até 4,5 m de
altura no lado oeste) nem a copa da Árvore por cima.

Tempos (linha reta a 6,75 m/s, o mínimo; o HV-B mede pela `NavGrid`): Forja e Árvore 22,8 m, 3,4 s, mais o contorno da
Fonte; Vendedor e Livro 22,9 m, 3,4 s; Alquimista (de (-15; 0), a frente dele) e Livro 25,6 m, 3,8 s, no limite;
Retorno e Portal 28,7 m, 4,3 s (o Retorno não é estação).

## 3. ESSENCIAL e CLIMA contra o `HubLook` de hoje

### 3.1 Essenciais (não cortar sem novo layout)

| Peça do pacote | O que existe | Ação |
|---|---|---|
| Piso do pátio e contorno | chão do `HubLook` (calcário, `STYLE`, `STY_RIM_FLOOR`, bordas de penhasco `edge`) | **fica**; muda o contorno (sem poço, canto sudeste) |
| Escada e selo do Retorno | poço sul (`WELL`, 20 degraus) e o medalhão como chegada | **novo**: selo de 3 m, escada de 7 x 2,5 m; **sai** o poço |
| Portal e escada norte | fachada, três ordens de aduelas, aduela do leão, escada de 6 degraus, terraço com estelas do leão, braseiros | **fica** inteiro |
| Fonte do Leão | bacia em blocos, estela com o leão, água escura (`dark_water_matte`), musgo e flores | **cresce** de 5,6 para 6,2 m; o resto fica |
| Forja, bigorna e Forjador | forno com chaminé, coifa e fumaça, bigorna, cavalete com lâminas e o escudo do leão, `HubNpc` Forjador | **move** para o sudoeste (2); a boca do forno vira para o leste |
| Vendedor e toldo | barraca com toldo de 5,8 m listrado terra e ocre, prateleiras, mercadorias, duas lanternas, `HubNpc` Vendedor | **move** para (-10,6; 8,0); toldo de duas águas assimétrico (6.2) |
| Árvore de Dons | `StoneTree` a 0,56 em ouro velho no estrado octogonal, folhas de ouro pálido | **move** para (11,0; 8,6); copa até 0,65 se a captura da Longe da chegada mostrar a copa inteira |
| Livro de Ahk | atril de 1,5 m sobre degrau, castiçais, tapete, estante alta, mesa de escrita | **move** para dentro de uma **arcada nova** (3 arcos, 4 a 4,5 m) a (14,6; -4,0) |
| Espaço do Alquimista | nada | **novo** (4) |
| Trilhas e anel da Fonte | caminhos de lajes com meio-fio e fio de ouro (`_pave_way`, `WAY_FILET`), lajes de uso com losangos | **refaz** para os pontos novos; acrescenta o caminho do Retorno até o anel; fio de ouro só como guia, nunca chão claro |

### 3.2 Clima (corta, reduz ou move se atrapalhar)

| Peça do pacote | O que existe | Ação |
|---|---|---|
| Arcadas quebradas e colunas ao fundo | arcadas laterais de quatro arcos, ruínas, `backdrop`, cascatas | **fica**; nada no chão andável |
| Cascatas e penhasco | cascatas, bruma, penhascos do `edge` | **fica**; acrescentar uma cascata sob a escada do Retorno só se custar até 0,2 ms na iGPU |
| Vasos e caixas | urnas grandes com arbusto de cobre, urnas no degrau das paredes | **fica** só junto das paredes (5) |
| Braseiros e lanternas | braseiros do terraço, postes com lanterna (`LAMPS`), braseiros da chegada | os da chegada **vão para o Retorno**; os outros ficam |
| Flores, hera, canteiros | canteiros (`BEDS`), arbustos de cobre, flores da Fonte | **fica**; violeta muito moderado (até 0,3% da cena) |
| Estandartes do leão | estandartes da fachada e do terraço | **fica**; nada de iconografia nova |
| Bancos | `BENCHES` no eixo do portal | **fica**; mais dois nos lóbulos norte |
| Ferramentas, manuscritos, frascos | mercadorias, cavalete, rolos | **fica**; frascos vazios no Alquimista (4) |
| NPCs de ambientação | os dois `HubNpc` | só os dois; nenhum NPC novo |

## 4. O espaço do Alquimista (reservado)

- **Silhueta**: bancada semicoberta: um **telheiro de uma água** de madeira escura sobre dois postes (2,8 m na frente,
  2,2 m no fundo), contra a parede oeste; bancada de 2 x 0,8 m; prateleira atrás com **frascos altos** de pé (0,3 a 0,6 m,
  5 a 9), ervas secas penduradas no telheiro em feixes (ocre e oliva seco), almofariz, balança de pratos (sem ouro
  brilhante), dois banquinhos.
- **Vazio e cuidado**: frascos vazios ou com sedimento escuro, nada borbulhando, nada aceso dentro do vidro; um pano sobre
  parte da bancada. Lê "lugar à espera", não "loja fechada" (sem tranca, sem placa).
- **Cor**: madeira escura (25 a 30; 0,30; 0,25), cerâmica terra, vidro verde amortecido **só no material** (o #9BAE83 do
  pacote, matiz 86, saturação até 0,25, sem emissão). O verde é a sálvia da Vigília nos efeitos; no hub, sem combate, não
  confunde, mas fica fosco e pequeno. **Nunca um segundo portal esmeralda.**
- **Luz**: uma lamparina âmbar baixa na bancada (#BCA07B, 2,5 m de alcance, sem sombra), poça até 1,2 vez a praça; atrás
  dele a parede mais escura (volumes atrás do Alquimista "mais escuros", pacote 4).
- HV-E E5 (bandeira desligada): só a bancada vazia até o Roteiro C.

## 5. O Pátio do Retorno

- **Selo**: disco de 3 m de lajes em anel com o leão **gasto** em ouro velho apagado (o `INLAY_GOLD` (0,27; 0,20; 0,10) a 0,8
  do valor, com falhas e juntas atravessando o desenho), menor e mais calmo que o medalhão da praça. Nada que pareça
  círculo mágico: sem runas, sem brilho, sem aro aceso.
- **Escada**: 7 x 2,5 m, 7 degraus da pedra do pátio, gastos no meio, descendo para a bruma; muretas baixas dos dois lados
  (até 0,65 m, como `YARD_WALL`), sem grade.
- **Dois braseiros menores** (0,9 m) no topo da escada, um de cada lado, sem sombra; **lampião baixo** (1,4 m) a leste do
  selo, #BCA07B. Poça do Retorno **até 1,3 vez a praça** (o herói lê, o Portal manda).
- Um estandarte do leão na mureta e hera; nada mais alto que 2 m perto do selo (não cobre o herói ao chegar).

## 6. Estações: silhueta e luz (HV-C e HV-D)

### 6.1 Hierarquia em 3 s (a captura da chegada prova)

1. **Portal**: o único rasgo verde alto; o ponto mais claro e mais saturado da tela.
2. **Fonte do Leão**: massa larga e horizontal no meio, valor médio, o leão iluminado pelo poente.
3. **Estações**: cada uma uma silhueta e uma poça (6.2).
4. **Retorno e Alquimista**: discretos.

### 6.2 Uma silhueta e uma luz por estação

| Estação | Silhueta (de longe) | Luz (pacote, tabela 4) e poça na tela | `STY_POOLS` (mira nova, proposta) |
|---|---|---|---|
| Portal | arco alto com o leão no coroamento e o vazio luminoso | verde-pálido no vão e na escada, não na fachada inteira; o valor de hoje (verde 25% ou mais na caixa) manda sobre o #9FC8A1: empalidecer só se o verde continuar acima de 25% | a de hoje: (0; 10,4) |
| Forja | **forno baixo com chaminé** (a única silhueta vertical estreita de baixo à esquerda) e a bigorna à frente | fogo âmbar #E8A15C na boca, embaixo; a única luz de fogo com sombra; poça 1,8 vez a praça ou mais na bigorna | forno a (-16; -6,1), mira (-12,6; -5,6) |
| Vendedor | **toldo de duas águas assimétrico** (a água de trás mais longa), mancha horizontal terra e vinho apagado (vinho com matiz 350 a 10 e saturação até 0,35: nunca o vermelho do perigo) | duas lanternas sob o toldo, #DCA36E; poça no balcão 1,8 vez a praça, abaixo da do Portal | mira (-10,6; 6,6) |
| Árvore | **maior volume orgânico**: tronco de pedra largo, copa em ouro velho | veios do tronco e copa em ouro velho #BEA66B, pé pouco emissivo; poça no estrado | mira (10,6; 6,4) |
| Livro | **retângulo claro das páginas** dentro de uma arcada escura | luz dourada suave #F0C98C de leitura no atril e uma larga no tapete (como hoje) | mira (13,0; -4,2) e (11,6; -4,8) |
| Alquimista | recipientes verticais sob o telheiro | 4 | sem entrada no `STY_POOLS` de estação; lamparina própria |
| Retorno | selo no chão e escada | 5 | lampião próprio |

Cores do pacote na tela (conferir com `frame_stats --hue`): entardecer #EBC9A0 (matiz 32, saturação 0,32); ambiente e
bruma petróleo #263E45 (193); forja #E8A15C (29, 0,60); livro #F0C98C (36, 0,42); vendedor #DCA36E (28, 0,50); árvore
#BEA66B (42, 0,44); Alquimista #9BAE83 (86, 0,25); fonte #5F8185 (186, 0,29); Retorno #BCA07B (34, 0,35). A água da
Fonte (186) fica perto do petróleo do herói (183): o valor da água fica no meio (luma 0,8 a 1,1 da praça) e a saturação
até 0,29, abaixo do cachecol.

**Luz de chave**: o pacote pede o entardecer do oeste a 15 a 25 graus. A essa altura as sombras longas da fachada e das
arcadas cobririam as estações do leste. Proposta: chave do oeste (vinda de -u, um pouco do sul), **35 graus** de
elevação, cor #EBC9A0, sem disco solar, sem raio desenhado; o resto do poente fica no céu, nas bordas e na copa. A captura
decide (se as sombras couberem, descer até 25).

### 6.3 Peças por estação (closes do pacote, seção 6)

- **Forja**: forno de 2,5 a 3,5 m com chaminé de 5,8 m (existe), bigorna 1,5 vez (existe), martelo e ferramentas
  penduradas num suporte de madeira, metal no cavalete; o Forjador entre a bigorna e o forno.
- **Vendedor**: balcão, bolsas, baús, um livro de encomendas fechado sobre o balcão (sem texto); estado fechado do HV-E
  E2: pano sobre as mercadorias e o toldo meio recolhido.
- **Árvore**: placas de Dom fincadas em volta do estrado (pedras baixas com um losango, opacas no começo, HV-E E3),
  caminhos radiais de lajes.
- **Livro**: atril diagonal com o livro de páginas grandes aberto (o `hub_page.gdshader`, nada legível), estantes, mapas
  enrolados, cadeira; prateleira vazia reservada para Ofícios (HV-E E4, escondida até existir).
- Nenhuma placa flutuando: a tecla vai no pé do objeto (`StationSign.under`), uma por vez.

## 7. O que nunca

Cruz, sol com raios, auréola, estrela como símbolo, divindade figurada; o leão é o único símbolo (portal, fonte, selo,
estandartes, medalhão). Nada copiado do Hades II, do SWORN, do Ravenswatch ou do Ember & Blade. Nada de chão neon nos
caminhos. Nenhum quebrável. Nada da gramática do perigo (SW-G7: divisa, fenda com brasa, âmbar no chão). Vasos e caixas
de clima maiores e mais assentados que os quebráveis da descida (acima de 1,0 m, ou em plinto, ou com arbusto dentro:
nunca um vaso solto de 0,5 m no chão).

## 8. Aceite de arte (HV-B a HV-D, somado ao AC-RS)

1. **Chegada** (`--hub`, Perto e Longe, 1920 x 1080, GPU, `--shot-at=1` e `3`): Portal (arco e verde), Fonte e duas
   estações (Livro e Árvore) na tela; verde 25% ou mais na caixa do Portal; o herói no selo legível (fora da poça mais
   clara da tela); nenhum pixel de chama com os três canais acima de 235.
2. **Hierarquia medida** (`frame_stats.py --hue --scene` e caixas): Portal a caixa mais clara e mais saturada; poça de
   cada estação 1,8 vez a praça ou mais; Retorno até 1,3; Alquimista até 1,2; cena matiz 25 a 46, saturação p50 0,25 a
   0,35, luma 50 a 65 (`hub_spec_art.md` 4.2); `g+c` fora do Portal até 0,8%; vermelho até 0,5%; violeta até 0,3%.
3. **Close de cada estação** na Perto (parado no uso) e de longe (do selo e do Portal): reconhecida pela silhueta sem a
   placa (o art-director registra em `visual_review.md`).
4. Volta do anel (vídeo de `tools/hub_walk.gd`): nenhuma peça de clima no caminho, placas, Portal e NPCs sem oclusão.
5. Compatibility a 1280 x 720: o verde do Portal ainda o maior verde da tela, chamas sem estouro, chão da praça a até
   15 de luma do Forward+.
6. iGPU 720 Baixa até o hub de hoje mais 0,5 ms; RTX 1080 Alta até 2,5 ms de GPU; clássico (F7) igual fora do que mudou
   de lugar; `fit_probe --arena=hub` sem subir.
