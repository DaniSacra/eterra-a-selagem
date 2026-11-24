# Revisão de arte, 2026-11-23 (Fase 4 do backlog)

Revisor: `art-director`. Só capturas reais da GPU (Forward+, estilizado, câmera Perto) que estão no repositório.
Escala: P0 atrapalha ler o jogo ou parece defeito; P1 destoa e deve entrar no próximo lote; P2 polimento.
Coordenadas em pixels da própria captura (x, y a partir do canto de cima à esquerda). A aprovação final é do Daniel.

## Capturas usadas
- `docs/gallery/review_2026-11-23/`: `encontro_dois_anjos.png`, `encanto.png`, `dicas.png`, `maga_bastao.png`,
  `comuns_trinca_varredor.png`, `porta_caixa.png` (1672 x 941).
- `docs/gallery/meta_2026-11-23/`: `videira_1080.png`, `forja_1080.png`, `vendedor_1080.png`, `dons_pedestal.png`.
- `docs/gallery/dons_2026-11-23/dons_clareza_1080.png` (depois da passada de clareza).
- `docs/gallery/morvath_light/morvath_hard_2026-11-23.png`, `docs/gallery/channeler/lab_game.png`.

## Resumo por prioridade
| # | Item | Veredito | Prio | Dono |
|---|------|----------|------|------|
| 1 | Laje armada como retângulo vermelho cheio (sala 2) | FEITO no código; `laje.png` não mostra laje, falta captura | P0 | `technical-artist` |
| 2 | Forja: disco preto no pomo e no guarda-mão | AJUSTAR | P0 | `ui-ux-designer` |
| 3 | Dons: nomes dos ramos longe dos nós | AJUSTAR | P1 | `ui-ux-designer` |
| 4 | Dons: número do nó escuro não diz "Maestria" | AJUSTAR | P1 | `ui-ux-designer` |
| 5 | Videira: broto comprado perde o nome | AJUSTAR | P1 | `ui-ux-designer` |
| 6 | Encanto: o mesmo ícone nas três cartas | AJUSTAR | P1 | `ui-ux-designer` |
| 7 | GR-8 raio-x de pontinhos | FEITO em parte; sem captura com o herói atrás de peça | P1 | `technical-artist` |
| 8 | Retrato da Maga no HUD fotográfico | AJUSTAR (asset) | P1 | `ui-ux-designer` + pedido ChatGPT |
| 9 | Legenda da última habilidade ao lado de "Espaço" | AJUSTAR | P2 | `ui-ux-designer` |
| 10 | Encontro dos anjos: HUD por cima | AJUSTAR | P2 | `ui-ux-designer` |
| 11 | Vendedor | FEITO (placeholder) | P2 | `ui-ux-designer` |
| 12 | Medalhão dos Dons no Santuário | FEITO | - | - |
| 13 | Dicas da primeira descida | FEITO | - | - |
| 14 | Maga com o bastão aceso | FEITO | - | - |
| 15 | Luz morna da Câmara de Morvath | FEITO | - | - |
| 16 | GR-17 letras do golpe de Morvath | SAI (Morvath sem marca no chão, `159f206`) | - | - |
| 17 | GR-19 fio da mira | SAI (`besteiro.png`: sem linha) | - | - |
| 18 | Faixa do Canalizador opaca e chapada | FEITO (falta captura) | P1 | `technical-artist` |
| 19 | Rastro de fogo da Bênção: discos laranja opacos | FEITO (falta captura) | P1 | `technical-artist` |
| 20 | GR-26 duas barras no guardião | AJUSTAR | P2 | `ui-ux-designer` |
| 21 | GR-27 dano por tempo pequeno e cinza | AJUSTAR | P2 | `combat-feel-director` |
| 22 | Portas: ponto preto no medalhão da recompensa | AJUSTAR | P2 | `ui-ux-designer` |
| 23 | Trinca: silhueta baixa não lê | FEITO (falta captura) | P2 | `technical-artist` |
| 24 | Varredor, Canalizador (modelo), portas (resto), Livro de Ahk | FEITO | - | - |
| 25 | GR-18 besta | SAI provisório (sem palitos em repouso) | - | - |
| 26 | Suspensão Absoluta, GR-20 arco do giro, laje armada, GR-8 | SEM CAPTURA útil | - | lista no fim |

## Itens

### 1. Laje armada vira tapete vermelho (P0, `technical-artist`)
**Causa real do retângulo que sobrou (2026-11-24):** não era laje. Semente 5, sala 2 (Salão das Fendas): `BandFloor` da respiração da fenda (`band_source` `breath`, banda 2,3 x 6 m em (2,9; -4)) desenhada pelo `Ground.add_band` com o vermelho de perigo (`HAZARD_COLOR`) apesar de empurrar com dano 0. Corrigido com `GroundLook.gust`: bruma azul acinzentada, aro de 0,08 m, preenchimento até 0,12.
**FEITO (2026-11-23, falta captura GPU):** `GroundLook.set_plate` mantém a pedra, a fissura acende âmbar (1,0; 0,62; 0,25, preenchimento até 0,25) e o vermelho é só um aro de 0,12 m (uniform `plate_red` em `ground.gdshaderinc`) nos últimos `Feel.bang_lead` do preparo e no golpe.
`porta_caixa.png` (1410..1580, 200..330): retângulo vermelho saturado e opaco, com chevrons ">>" ao lado, perto da saída.
Pela posição e pelos chevrons é a laje que empurra (RP-13): `GroundLook.set_plate` leva `PLATE_REST_COLOR` até
`HAZARD_COLOR` (o vermelho de aviso) já em `hot` 0,25 e com `HAZARD_STRENGTH`, então a laje fica vermelha cheia quase o
preparo inteiro. É perigo de sala (o PT-1 o deixa marcado), mas lê como tapete ou caixa de interface e é a maior mancha
vermelha da sala.
Pedido: o preparo da laje é brasa, não aviso. Corpo da laje fica na pedra (`PLATE_REST_COLOR`); o `HazardPiece` da
fissura acende em âmbar (1,0; 0,62; 0,25) de fora para dentro durante o preparo; o vermelho de aviso só como aro de
0,12 m nos últimos 0,35 s (o mesmo `Feel.bang_lead` do "!"), preenchimento com alfa até 0,25. Aceite: captura GPU com
a laje armada em que não há área vermelha cheia maior que o aro; o chão da laje ainda lê como pedra.

### 2. Forja: disco preto no pomo (P0, `ui-ux-designer`)
`forja_1080.png` (285..340, 365..420) e (712..758, 458..505): `ForgeBench._gem` desenha um círculo quase preto
(0,03; 0,025; 0,03) de 19 px quando o Despertar não tem gema, e `_rings` faz o mesmo no anel do especial vazio. Leem
como furo ou defeito sobre o bronze.
Pedido: engaste vazio = cavidade de bronze. Fundo (0,20; 0,13; 0,07), sombra interna de 3 px mais escura só na
metade de cima, aro `UiKit.OLD_GOLD` 2 px a 70%, e dentro a silhueta da gema (ou do "F" no anel) em pergaminho a 18%.
Mesmo tratamento no anel do especial vazio. Aceite: na captura nenhum ponto da espada tem luma abaixo de 25 dentro dos
engastes; o pomo ainda lê como "aqui entra algo".

### 3. Dons: nomes dos ramos soltos sobre a figura (P1, `ui-ux-designer`)
`dons_clareza_1080.png`: "Combo" (730, 509), "Sustento" (1113, 473), "Emeth" (1115, 659), "Fúria" (775, 705),
"Magia" (955, 773) estão em `MedallionView.LABEL_R` 138 (palco 1280 x 720), enquanto os nós ficam a cerca de 230..330
do centro. A etiqueta fica no peito do herói, a 100 px ou mais do próprio ramo; "Fúria" e "Magia" quase se tocam e
"Faltam 2 de Memória" (690..885, 760) cobre a de Fúria.
Pedido: raio por ramo = menor raio dos nós do ramo menos 42 (palco), no ângulo médio do ramo como hoje; um traço de
1 px na tinta do ramo (`ink` a 50%) da etiqueta até o primeiro nó. Se duas etiquetas ficarem a menos de 24 px, empurrar
a de ângulo maior pelo arco. A dica do nó em foco nunca por cima de etiqueta (deslocar para o lado de dentro oposto).
Aceite: cada etiqueta a no máximo 50 px (1080p) do nó mais interno do seu ramo, nenhuma sobreposição.

### 4. Dons: número grande nos nós escuros (P1, `ui-ux-designer`)
Mesma captura: "16" (603, 372), "18" (590, 740), "20" (1217, 820) e (889, 946) em fonte maior que os ícones e
maior que tudo no anel; não dizem o que medem. A legenda (1450, 975) diz "Escuro: falta Maestria ou outro Dom", sem
ligar ao número.
Pedido: no nó escuro, o leão pequeno da Maestria (o mesmo glifo da coroa) em cima, a 35% da altura do nó, e o número
embaixo com no máximo 60% do tamanho atual, em pergaminho a 70%. Nós escuros todos do mesmo tamanho dos nós abertos
do mesmo nível (hoje 16, 18 e 20 são maiores e puxam o olho para o que não se pode usar). Legenda: "Escuro: o número é
a Maestria que falta" (texto novo em `text_pt.tres`). Aceite: o maior elemento do anel é um nó aceso ou o em foco,
nunca um escuro.

### 5. Videira: broto comprado só com o visto (P1, `ui-ux-designer`)
`videira_1080.png` (360..550, 640..710) e (768..960, 550..620): a etiqueta virada mostra só o ✓ verde, e o jogador não
sabe o que comprou (`VineTag`, "blank back with a green check").
Pedido: verso com o nome (mesma fonte, pergaminho escuro) e o visto pequeno (18 px) à esquerda do nome, sem preço;
fundo da etiqueta um tom mais verde (0,36; 0,42; 0,26) para separar de "à venda". Junto: preço fora de alcance em
rubrica sobre barro tem pouco contraste ("10" em (320, 505)); rubrica mais escura (0,55; 0,10; 0,08) com contorno
pergaminho de 1 px. Aceite: nas 9 etiquetas o nome é lido em todas as situações.
Placeholder: vaso retangular (620..845, 905..1070) e treliça; esperam a arte do ChatGPT.

### 6. Encanto: três ichthys iguais (P1, `ui-ux-designer`)
`encanto.png`: o medalhão de cada carta (470..600, 270..400 e os outros dois) é o mesmo peixe; o que muda entre as
cartas só aparece na linha pequena "Muda: Ataque/Esquiva".
Pedido: o medalhão mostra o glifo do golpe que muda (os mesmos da barra de ações), a 70% do diâmetro; o ichthys vira
selo pequeno (28 px) no canto inferior direito do medalhão. Aceite: cartas que mudam golpes diferentes têm medalhões
diferentes à primeira vista. Placeholder: a espada na pedra à esquerda (20..315, 245..770) é vetor chapado e destoa dos
anjos pintados; espera arte.

### 7. GR-8 raio-x de pontinhos (P1, `technical-artist`)
**FEITO em parte (2026-11-23, falta captura GPU):** o include já não usava `bayer4` (código morto, removido). No Forward+ o limiar é a média de dois ruídos por pixel (sem grade) e a borda suave vai por todo o raio; no Compatibility segue o ruído simples. Esmaecimento realmente contínuo exigiria trocar os 8 shaders opacos por transparentes; não feito. Se a captura ainda mostrar pontos, é esse o próximo passo.
`dicas.png` (480..690, 430..640): o bloco ao lado do herói mostra pontos (correção: o `bayer4` era código morto; os pontos vêm do ruído). Pedido: no Forward+ o esmaecimento contínuo (alfa até 0,35 com borda suave de 0,6 m ao redor do
herói); o pontilhado fica só no Compatibility. Aceite: captura GPU 1080p com o herói atrás de pilar sem grade de pontos
visível.

### 8. Retrato da Maga no HUD (P1, asset)
`maga_bastao.png` (30..125, 815..910): rosto de aspecto fotográfico ao lado do retrato pintado do Guerreiro; quebra a
identidade. Pedido: retrato pintado no mesmo traço do Guerreiro (pedido ao ChatGPT pelo Daniel; ela é do norte, traços
orientais, âmbar). Até lá, recorte do modelo dela no jogo. Dono: `ui-ux-designer` troca o arquivo.

### 9. Legenda da habilidade ao lado de "Espaço" (P2, `ui-ux-designer`)
`dicas.png` (1015, 893): "Brado de Guerra" aparece colado ao losango Espaço (a esquiva), e o Brado é o E. Pedido: a
legenda sobe acima do losango que foi usado, ou some. Aceite: nome e tecla sempre do mesmo losango.

### 10. Encontro dos anjos (P2, `ui-ux-designer`)
`encontro_dois_anjos.png`: composição boa (anjos nas laterais, painel embaixo, título no alto). Por cima ficam
"Sala 1 de 14" (30, 31), o relógio "0:00" (835, 27) e a coluna de Dons atravessando a asa do anjo da direita
(1620..1660, 260..600). Pedido: durante o encontro esconder relógio, contador de sala e coluna da direita (como já se
faz com a barra de ações). FEITO no resto.

### 11. Vendedor (FEITO como placeholder, P2)
`vendedor_1080.png`: a balança lê bem, a troca está clara, "Erguida" funciona. Faixa vazia de 900 a 1080 e toldo
chapado; esperam a arte do ChatGPT (`assets/ui/shop/`).

### 12 a 15. FEITOS
- Medalhão dos Dons (`dons_pedestal.png`): lê como peça própria, o leão aparece, o halo marca a estação. O rótulo da
  captura ainda diz "Árvore de Dons"; o texto já é "Medalhão dos Dons" (`f942580`), a captura é anterior. A Videira no
  Santuário (1350..1430, 440..520) é um vasinho pequeno demais para a estação; fica para a arte da Videira (P2,
  `environment-artist`).
- Dicas (`dicas.png`): caixa escura com borda fina, centro baixo, não cobre o herói. Bom.
- Maga com o bastão aceso (`maga_bastao.png`): a esfera âmbar marca a arma; silhueta lê sobre o chão.
- Luz morna de Morvath (`morvath_hard_2026-11-23.png`): chão quente com borda violeta, Morvath escuro e herói legíveis,
  sem marca no chão fora do selo.

### 16 e 17. SAI
- GR-17: desde `159f206` Morvath não desenha fita no chão (só erupções e o "!"); a captura de Morvath não mostra fita.
- GR-19: o besteiro não tem `ground_warning` (PT-1), então a mira não é desenhada. Confirmar com a captura 6 abaixo; se a
  linha ainda aparecer, volta como AJUSTAR (`technical-artist`, proposta original da revisão 2026-11-21b).

  Confirmado em `besteiro.png`: dois besteiros de pé, nenhuma linha no chão.

## Segunda rodada (capturas GPU de 2026-11-23, `docs/gallery/review_2026-11-23/`)

### 18. Faixa do Canalizador opaca (P1, `technical-artist`)
**FEITO (2026-11-24, falta captura GPU; 2ª tentativa depois de `canalizador2.png`):** o feixe ativo (zona com tag `beam`, `Horde._behave_beam`) agora é `GroundLook.beam`: núcleo de 0,12 m (uniform `beam_core` no `ground.gdshaderinc`, luz em `extra`) e halo transparente que se apaga para os lados, sem aro nem preenchimento. O preparo continua o fio do aim com preenchimento até `AIM_FILL` (0,33 no estilizado). A primeira versão (aro 0,08 + preenchimento 0,2) ainda lia como faixa cheia porque o aro, com ganho 2,5, saturava.
`canalizador.png` (570..1130, 485..800): faixa magenta-vermelha de cerca de 1 m, opaca, sem borda nem textura, do
Canalizador até atrás do herói. Tem `ground_warning` (o PT-1 permite), mas lê como fita adesiva sobre o chão e é a
coisa mais saturada da tela, acima do herói. Pedido: estilo de aviso da casa (preenchimento com alfa até 0,3, aro de
0,08 m no vermelho de aviso, enchimento de trás para a frente durante o preparo); magenta só no orbe do punho. Aceite:
o chão aparece sob a faixa (luma do chão visível, juntas de pedra legíveis) e o herói continua o ponto mais claro.
O modelo (orbes nos punhos, capuz) está FEITO: lê diferente do feiticeiro.

### 19. Rastro de fogo da Bênção (P1, `technical-artist`)
**FEITO (2026-11-24, falta captura GPU):** `GroundLook.Style.EMBERS` (estilo 4 do `ground.gdshaderinc`) para toda zona `Kind.EMBER`: brilho aditivo de no máximo 0,35 que se apaga antes da borda, com brasas subindo; sem aro.
`numeros_dot.png` (850..1280, 470..900): sete discos laranja opacos em fila, cada um com cerca de 2,5 m. Efeito do
herói com a cara de área de perigo inimiga e cobrindo inimigos e o chão. Pedido: efeito do herói em modo aditivo,
alfa até 0,35 no miolo, borda que se desfaz (sem aro duro), labaredas ou brasas pequenas em vez de disco liso, na cor
da família Chama; o vermelho e o laranja chapados ficam só para o que machuca o herói. Aceite: na mesma captura o
inimigo dentro do rastro é legível e o rastro não se confunde com aviso.

### 20. GR-26 duas barras no guardião (P2, `ui-ux-designer`)
`guardiao.png`: barra do alto "Sacerdote Ancião" (520..1150, 60) e barra na cabeça (1085..1240, 152..165) dizem o
mesmo. Pedido mantido: esconder a da cabeça quando há a barra do alto (a armadura dourada passa para a barra do alto).

### 21. GR-27 dano por tempo (P2, `combat-feel-director`)
`numeros_dot.png`: o dano direto "55" lê bem; os tiques "8" (842, 417, laranja) e "4" (771, 383, cinza) têm metade da
altura e o cinza some no chão. Pedido: altura mínima 70% do número direto, sempre na cor da família com valor mínimo
0,75 e contorno de 3 px; nunca cinza.

### 22. Portas (FEITO, um ajuste P2, `ui-ux-designer`)
`portas.png`: os medalhões de recompensa sobre as saídas leem (Bênção com cristal, Ouro com moedas), etiqueta "Bênção /
Dois anjos" clara. Ajuste: o disco preto no canto do medalhão da Bênção (1072..1095, 178..200), o mesmo defeito da
Forja (engaste vazio deve ser bronze, não preto). O medalhão do Ouro (1430..1590, 515..660) passa por baixo da coluna
de Dons do HUD; aceitável, a câmera muda.

### 23. Trinca e Varredor
**FEITO (2026-11-24, falta captura GPU):** `CrowdRenderer.BUILD` da Trinca em 1,45 x 0,8 x 1,45.
`trinca_varredor.png`: o Varredor (as duas figuras altas de lâmina longa, 610..750, 520..840 e 790..930, 380..690) é
FEITO: silhueta própria e arma que diz "varre". A Trinca (a figura baixa ao lado do herói, 420..540, 600..720) não lê
como "baixa, larga, três corcundas": cola no herói e parece um esqueleto agachado. P2, `technical-artist`: aumentar a
largura do `CrowdRenderer.BUILD` da Trinca para 1,45 e baixar a altura para 0,8, para a forma de monte aparecer de
cima; captura com ela longe do herói.

### 24. Livro de Ahk, página do Guerreiro (FEITO)
`meta_2026-11-23/livro_guerreiro.png`: lê como livro, retrato pintado no pergaminho, hierarquia clara (Arma, Estilo,
Habilidades, Dons equipados), botões discretos. Polimento P2 (`ui-ux-designer`): a barra de Maestria vazia
(1192..1484, 168..185) é um bloco preto sobre o pergaminho; trocar por trilho em tinta (contorno 1,5 px, fundo
pergaminho escurecido 15%).

### 25. GR-18 besta (SAI provisório)
`besteiro.png`: em repouso não há os três palitos brancos. Só no preparo dá para confirmar; se o Daniel não reclamar,
fica fechado.

### 26. Ainda sem captura útil
- **Suspensão Absoluta**: `suspensao.png` (`--shot-at=7`) mostra a Maga com a ultimate pronta (Shift aceso), sem cúpula.
- **Laje armada**: `laje.png` é a sala 1, sem lajes. A correção está no código, não vista.
- **GR-8**: em nenhuma das capturas novas o herói está atrás de uma peça.
- **GR-20**: arco do giro não capturado.

## Capturas que faltam (segunda rodada, uma por vez)
1. Suspensão: `tools/gpu.sh shot docs/gallery/review_2026-11-23/suspensao.png --bot --autopick --seed=5 --hero=maga --ultimate=dome_abs --ult-full --frames=docs/gallery/review_2026-11-23/suspensao --count=6 --every=1 --shot-at=2` (escolher o quadro com a cúpula).
2. Laje armada: o comando que gerou `porta_caixa.png` (sala 2 da semente 5), no mesmo segundo.
3. GR-8: `tools/gpu.sh shot docs/gallery/review_2026-11-23/raiox.png --bot --autopick --seed=5 --shot-at=3` (é o enquadramento de `dicas.png`, com o herói junto do bloco; se não ficar atrás, `--shot-at=4`).
4. GR-20: `tools/gpu.sh shot docs/gallery/review_2026-11-23/giro.png --bot --autopick --seed=5 --shot-on=spin --shot-after=0.1`.

Se `--shot-on=spin` ou `--shot-on=reward` não existirem com esse nome, `--shot-at` no segundo certo serve.

## Andamento do `ui-ux-designer` (2026-11-24, sem captura GPU ainda; o Game Director captura)
- **2 FEITO** `ForgeBench._socket`: engaste vazio de bronze (fundo 0,20/0,13/0,07, sombra interna na metade de cima, aro OLD_GOLD 2 px a 70%, silhueta da gema ou do "F" a 18%), no pomo e no anel vazio.
- **3 FEITO** `MedallionView`: etiqueta de cada ramo logo por dentro do nó mais interno (raio menos `LABEL_GAP`), traço fino na tinta a 50%, empurra pelo arco se ficar a menos de 24 px; etiquetas desenhadas por cima dos nós.
- **4 FEITO** nó escuro: leão pequeno em cima, número a 57% do tamanho e pergaminho a 70%, nunca maior que 48 de diâmetro (os de 72 desenham a 48 enquanto escuros); legenda "Escuro: o número é a Maestria que falta".
- **5 FEITO** `VineTag`: verso com o nome e visto pequeno à esquerda, fundo mais verde; preço sem alcance em rubrica (0,55/0,10/0,08) com contorno pergaminho de 1 px.
- **6 FEITO** `BoonCard.setup_enchant`: medalhão com o glifo do golpe que muda a 62% do raio, ichthys como selo de 28 px no canto inferior direito.
- **9 FEITO** `Hud._follow_row`: o nome do golpe fica acima do losango de onde ele veio (acima do aviso do Brado quando é o Brado).
- **10 FEITO** `Hud`: relógio, contador de sala e coluna de Bênçãos somem enquanto o `EncounterScreen` está aberto.
- **11 FEITO (placeholder melhorado)** `ShopArt`: toldo com dobras e sombra, frente do balcão com tábuas, trilho de bronze e rebites na faixa de baixo. A arte do ChatGPT ainda substitui.
- **20 FEITO** (GR-26) `Horde.top_bar_for`: o guardião que tem a barra do alto não desenha a da cabeça.
- **22 FEITO (ajuste)** `RewardGem._bronze`: haste e pino da porta em bronze aceso, não metal espelhado (era o disco preto onde a ponta da haste encara a câmera). Conferir na captura GPU.
- **21 FEITO** (GR-27) `Fx.number(tick)`: dano por tempo com altura mínima de 70% do direto, cor de família com valor mínimo 0,75 (cinza vira o verde da Emeth) e contorno de 3 px.
- **24 FEITO** `MasteryBar` sobre pergaminho: trilho de tinta (contorno 1,5 px, fundo do papel 15% mais escuro).
- **8** (retrato da Maga) fica para a arte do ChatGPT.

## Revisão de 2026-11-24 (build 1342184)
Capturas GPU (Forward+, estilizado, Perto, 1672 x 941): `docs/gallery/round_2026-11-24/` (`raiox.png`, `giro.png`,
`sala1_portal.png`, `ult_ring_hud.png`, `shop_wall.png`, `forge.png`, `dons.png`, `vine.png`, `vendor.png`, `book.png`,
`end_none.png`) e as posteriores às correções em `review_2026-11-23/` (`canalizador3.png`, `sala2_bruma.png`). Texto e
layout de interface ficam na `docs/qa/ui_review_2026-11-24b.md` (não repetidos aqui).

### Itens anteriores
| # | Estado | Evidência / nota |
|---|--------|------------------|
| 1 Laje / faixa vermelha da sala 2 | FEITO | `sala2_bruma.png` (1390..1560, 195..320): a respiração da fenda virou bruma azul, nenhum vermelho cheio. Laje de verdade armada ainda não capturada; ver N5 para a bruma. |
| 2 Forja, disco preto | FEITO | `forge.png`: pomo (235..305, 305..380) e anel "F" (610..670, 240..300 e 395..440) são cavidade de bronze com a silhueta escura dentro; não leem como furo. |
| 3 Dons, etiqueta dos ramos | FEITO | `dons.png`: Sustento, Emeth, Fúria e Magia junto do próprio ramo. Distância das etiquetas ao aro é a B14 da revisão de UI. |
| 4 Dons, nó escuro | FEITO | Nós escuros do mesmo tamanho dos abertos; o maior elemento do anel é o leão aceso no topo. Tamanho do número é a B3 da UI. |
| 5 Videira, broto comprado | SEM CAPTURA | `vine.png` mostra 0 de 9. Vaso e treliça seguem placeholder (540..740, 790..935). |
| 6 Encanto, glifo por carta | SEM CAPTURA | |
| 7 GR-8 raio-x | ABERTO, P1, `technical-artist` | Ver N1. |
| 8 Retrato da Maga | ABERTO, P1, asset | `suspensao.png` (30..125, 815..910) ainda fotográfico. Espera pedido ao ChatGPT. |
| 9 Nome do golpe no losango | FEITO | `giro.png` (Giro da Alvorada), `sala1_portal.png` (Investida). |
| 10 HUD no encontro dos anjos | SEM CAPTURA | |
| 11 Vendedor | FEITO (placeholder) | `vendor.png`: toldo listrado com dobras, balcão de tábuas, trilho com rebites. Coerente com o Santuário; espera arte final. |
| 18 Canalizador | FEITO | `canalizador3.png` (580..1120, 490..795): núcleo fino com halo, o chão aparece, herói segue o ponto mais claro. Ver N6. |
| 19 Rastro de fogo | SEM CAPTURA | |
| 20 GR-26 barra dupla do guardião | SEM CAPTURA | |
| 21 GR-27 dano por tempo | SEM CAPTURA | O "5" vermelho de `ult_ring_hud.png` é a B15 da UI. |
| 22 Ponto preto na porta | SEM CAPTURA | |
| 23 Trinca | SEM CAPTURA | |
| 24 Barra de Maestria do Livro | FEITO | `book.png` (1037..1292, 145..162): trilho de tinta sobre o papel, sem bloco preto. |
| 26 Suspensão Absoluta | SEM CAPTURA | Nenhum quadro com a cúpula. |
| GR-20 arco do giro | FEITO | `giro.png` (425..955, 410..620): arco de quase uma volta, lê como giro em volta do herói. Cor na N4. |

### Problemas novos

**N1. GR-8 continua pontilhado, e aparece com o herói ao lado da peça (P1, `technical-artist`).**
`raiox.png` (695..745, 480..520) e `giro.png` (ampliado: 470..640, 430..520): o topo do bloco ao sul se desfaz em
pontos grossos e quadrados, de 1 a 2 px, bem visíveis no Forward+. Em `raiox.png` o herói está ao lado do bloco, não
atrás, e mesmo assim o pé dele abre um buraco pontilhado na peça. O ruído médio não resolveu: é o passo seguinte que a
própria nota do item 7 previa. Pedido: (a) no Forward+ trocar o descarte por esmaecimento real (alfa até 0,35 no
miolo, borda suave de 0,6 m), nem que seja só nas peças altas que podem cobrir o herói (bloco do sul, balaustrada, pilar),
com um segundo material transparente trocado por proximidade; (b) só abrir a peça quando ela está entre a câmera e o
herói (teste de profundidade do herói na tela), não por distância no plano. Aceite: captura GPU com o herói atrás
(ao norte) do bloco, sem grade de pontos, e `raiox.png` repetida sem buraco nenhum no bloco.

**N2. Bloco do sul com vão preto no meio da tela (P1, `environment-artist`).**
A peça alta ao sul do centro da sala 1 (`raiox.png` 600..830, 490..740; mesma peça em `ult_ring_hud.png`
980..1240, 600..850, `shop_wall.png` 900..1160, 600..830 e `suspensao.png`) tem um vão triangular de luma perto de 0
(`raiox.png` 680..720, 580..615; `shop_wall.png` 1020..1090, 720..760). É o ponto mais escuro perto do centro, lê como
furo na malha, e a peça, alta e em primeiro plano, esconde o herói (`giro.png`) e encosta na barra de ações. Pedido:
fundo do vão em pedra recuada com luma de pelo menos 35, com uma vela ou brasa fraca dentro (1,0; 0,62; 0,25, energia
baixa) se for nicho; e baixar a peça para o topo ficar abaixo do peito do herói na câmera Perto (ou recuar 1 m para o
sul). Aceite: na captura `raiox.png` repetida, nenhum pixel do vão abaixo de luma 30 e o herói inteiro visível
quando passa ao lado.

**N3. Fundo do oeste mais claro que a luta (P2, `environment-artist`).**
`ult_ring_hud.png` (0..300, 100..760) e `raiox.png` (0..330, 80..420): a luz fria além dos arcos do oeste é a maior
área clara da tela; quando a luta encosta na balaustrada oeste (`ult_ring_hud.png`, herói e três inimigos em
260..560, 500..710) o grupo fica contra esse fundo e perde contraste. Pedido: baixar cerca de 25% a luma do brilho
além dos arcos e escurecer em gradiente nos 2 m mais perto da balaustrada (bruma escura), para o fundo nunca passar o
chão iluminado em volta do herói. Aceite: no mesmo quadro, a média de luma do fundo oeste abaixo da do chão sob o herói.

**N4. Arco do giro quase branco e chapado (P2, `technical-artist`).**
`giro.png` (425..955, 410..620): o arco é verde-limão muito claro, opaco, e é a coisa mais clara da tela, mais que o
herói; o contorno escuro da peça desenha uma linha poligonal por cima dele (440..620, 435..520). Pedido: cor da Emeth
(0,30; 0,85; 0,55) em modo aditivo, alfa até 0,6 no miolo, pontas que se desfazem em vez de corte reto; o arco desenha
por cima do contorno das peças. Aceite: herói ainda o ponto mais claro durante o giro e o arco lido como verde da Emeth.

**N5. Bruma da fenda como placa retangular (P2, `technical-artist`).**
`sala2_bruma.png` (1390..1560, 195..320): sem vermelho, mas um retângulo azul-claro de borda dura com chevrons, que lê
como painel ou tapete. Pedido: bordas que se desfazem em 0,4 m, preenchimento até 0,08, os chevrons andando no
sentido do empurrão. Aceite: na mesma captura não há quina reta visível na bruma.

**N6. Feixe do Canalizador fino demais para a área de dano? (P2, `technical-artist`, conferir)**
`canalizador3.png`: o núcleo tem 0,12 m e o halo some rápido. Se a área que machuca tem cerca de 1 m de largura, o
desenho subestima o perigo. Pedido: o halo vai até a largura real do dano, com alfa baixo; se a largura do dano já é
fina, fica como está.

### Capturas que faltam (só a sessão principal, uma por vez)
1. GR-8 com o herói atrás do bloco: `tools/gpu.sh shot docs/gallery/round_2026-11-24/raiox2.png --bot --autopick --seed=5 --frames=docs/gallery/round_2026-11-24/raiox2 --count=8 --every=0.5 --shot-at=1` (escolher o quadro com o herói ao norte do bloco).
2. Suspensão, Trinca, rastro de fogo, portas, guardião, encanto: os comandos da lista "Capturas que faltam" acima continuam valendo.

### Veredito
Nenhum P0 aberto. Do lado da arte, o build pode ir para o teste do Daniel; ficam abertos N1 (pontilhado do raio-x) e
N2 (vão preto do bloco do sul) como P1 do próximo lote. Retrato da Maga, vaso da Videira e vendedor seguem
provisórios.
