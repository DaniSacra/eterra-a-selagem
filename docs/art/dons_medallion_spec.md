# Tela dos Dons: o medalhão do herói (especificação, art-director, 2026-11-23)

Para o `ui-ux-designer` (tela) com o `technical-artist` (brilho e partículas). Identidade em `meta_identities.md` 1.
Alvos, na ordem: (1) a **maquete do Daniel feita para o nosso jogo** (`docs/art/ref/points_screen/dons_mockup_chatgpt.png`,
1325 x 753, só local), de onde saem as posições e proporções abaixo; (2) o princípio da referência de outro jogo
(`medallion_tree_ref.png`: medalhão redondo, nós no aro, faixa com o nome no alto). Nada copiado dela.

## 0. O que muda em relação à maquete (e por quê)

A maquete é o alvo de composição. Seis coisas dela não entram como estão:
1. **A figura não é o Guerreiro canônico.** Bate o cabelo vermelho, o cachecol petróleo e a Emeth verde; não batem o rosto
   (lê feminino, traços suaves; o da prancha `warrior_art_bible.png` e de `assets/ui/hero/warrior_page.png` é um homem
   jovem de rosto anguloso), o cabelo (ondulado até o ombro contra o vermelho repicado da prancha) e a armadura (aço claro
   e couro marrom contra o aço escuro com filetes de ouro velho, `warrior_spec.md` "Leitura visual"). O pedido ao ChatGPT
   pede o Guerreiro da prancha.
2. **A moeda está errada.** A maquete mostra um cristal verde (lê como a Esmeralda, que é material da Forja) com 283.
   Nos Dons há duas contas (`meta.md`, "Dons abertos com Memória"): **Devoção** (orçamento para equipar, 5 + nível de
   Maestria, não se gasta: equipar ocupa, tirar devolve) e **Memória** (Fragmento de Memória, gasta uma vez para abrir um
   Dom selado, `TalentDef.memory_cost` 1 a 5). O canto superior direito leva as duas, com os ícones nossos: Memória =
   `assets/ui/rewards/memory.png` (cristal azul no aro de ouro); Devoção = disco de ouro pequeno (peça nova do pedido).
3. **O céu violeta sai** (violeta é de Morvath): entardecer âmbar, rosa ocre e azul ardósia.
4. **Ícones**: o machado (o Guerreiro só tem espada) e o braço musculoso saem; cada Dom tem o motivo dele (o de
   `TalentGlyph`, que já existe para os 23 do Guerreiro).
5. **Textos**: "Don" é erro (é "Dom"); "Tenacidade de Eterra" não é um Dom nosso; números da maquete são de enfeite.
6. **O estandarte vermelho do fundo** fica sem emblema inventado (liso ou com o leão, o símbolo decidido do herói).

## 1. Composição medida na maquete

A base de trabalho é 1280 x 720 (`project.godot`, `canvas_items`, `expand`); a 1920 x 1080 tudo é x1,5. A maquete foi
medida e escalada por 720/753 (0,956) com 6 px de margem lateral. Ângulos no sentido do relógio a partir do meio-dia.

| Peça | Maquete (px) | 1280 x 720 | 1920 x 1080 |
|---|---|---|---|
| Centro do medalhão | (641, 391) | **(620, 378)** | (930, 567) |
| Anel dos nós (linha fina onde os nós se apoiam) | raio 265 | **raio 254** | 381 |
| Anel de fora (moldura com estrelas de 4 pontas) | raio 390 nos lados | **raio 340** (no pé passa da borda: corta) | 510 |
| Halo atrás da cabeça (gradiente radial claro) | centro (650, 230), 200 | centro (620, 222), raio 150, âmbar f5cc73 a 35% até 0 | x1,5 |
| Figura do herói (recorte) | cabeça no y 150, cortada embaixo | topo da cabeça y 140, centro x 620, altura visível 580 (corta na borda de baixo) | topo 210, 870 |
| Faixa do nome | x 482..818, y 50..100 | centro (620, 72), **320 x 48**; texto Cinzel 25 | 480 x 72, Cinzel 37 |
| Enfeite sobre a faixa (espada do Guerreiro; cajado da Maga) | y 20..55 | centro (620, 36), 34 x 34 | 51 |
| Nó da coroa (leão; estrela de 8 pontas da Maga) | (650, 133), 66 | (620, 124), **64** | 96 |
| Nó grande (Ápice) | 70 | **64** | 96 |
| Nó pequeno (Entrada, Meio, ponte, sustento, ultimate) | 44 | **42** | 63 |
| Ponto de junção (onde um nó alimenta dois) | 10 | 10 | 15 |
| Linha entre nós | 3 + brilho | **3 px**, brilho 8 px na tinta do ramo | 4,5 / 12 |
| Logo do jogo | x 49..285, y 35..100 | x 50..273, y 33..92 | x1,5 |
| Contadores (alto à direita) | x 1195..1312, y 38..72 | Devoção x 1018..1140, Memória x 1150..1264; y 36..70 | x1,5 |
| Painel de detalhe | x 1003..1322, y 183..515 | **x 962..1264, y 175..492** (302 x 317) | 1443..1896, 263..738 |
| Traço do nó ao painel | do nó focado à borda do painel | 2 px ouro, do aro do nó à borda esquerda do painel na altura do nó (preso entre y 190 e 470) | 3 px |

Distância mínima entre centros de nós: 52 px (pequeno com pequeno) e 60 px (com grande). A tabela da seção 3 respeita isso.
A pintura do herói **não** é cortada pelo círculo (na maquete o manto e o corpo passam do anel): o fundo pintado ocupa a
tela inteira, escurecido nas bordas (vinheta 0,55), e a figura recortada fica por cima do fundo e por baixo dos anéis.
Ordem das camadas: fundo, vinheta, halo, figura, anel de fora, linhas, nós, faixa, painel e contadores.

## 2. Setores: como cabem 23 Dons mais 2 ultimates

Os dois heróis têm 23 Dons (dados em `data/talents/<herói>/`) e 2 ultimates. Cinco setores no anel mais a coroa:

| Setor (ângulo) | Guerreiro | Maga |
|---|---|---|
| Coroa (0; ultimates a 331 e 29) | leão (Maestria e Poder maior); Corte do Juízo, Voragem | estrela de 8 pontas; Tempestade dos Selos, Suspensão Absoluta |
| Alto à direita (45 a 90) | Sustento (3) e a ponte Fio do Passo | Sustento (5) |
| Direita (95 a 135) | Emeth (3), verde 2f7a58 | Selos (4), ardósia 4a5560 |
| Baixo (155 a 190) | Magia (3), azul 3d6a8c | Arcanismo (4), ouro 86601a |
| Esquerda (210 a 245) | Fúria (5), ocre 9a5a2a | Piromancia (4), âmbar 9a4a1c |
| Alto à esquerda (255 a 305) | Combo (4), vermelho 783222 | as 2 pontes Piromancia e Selos |

Regras de posição (para valer a qualquer herói novo):
- **Ramo**: a Entrada fica no anel do lado da coroa; os Meios seguem no anel; o Ápice é o **nó grande** no fim do setor.
  Mais de um Meio no mesmo degrau: um no anel, os outros em **espora** (o mesmo ângulo, raio 254 + 54 para fora ou 254 - 54
  para dentro), ligados ao anel por um traço reto curto (como na maquete).
- **Ponte**: fica na divisa entre os dois ramos que une, quando são vizinhos no anel; quando não são (Fio do Passo, as duas
  de Piromancia e Selos), fica no setor livre mais perto do primeiro ramo. O aro da ponte é **partido ao meio nas duas
  tintas**, e o painel diz quais ramos ela une.
- **Sustento**: tinta 7a4e3a, nós pequenos, sem Ápice.
- **Ultimates**: na coroa, aro duplo de ouro; a escolhida fica cheia de ouro.
- Os ângulos e raios são **dado**, não código: um recurso por herói (sugestão `data/heroes/<id>_medallion.tres`, escrito
  pelo `make_data.gd`, id do Dom para ângulo e raio), para um Dom novo não pedir código.

## 3. Posição de cada nó (centro; A = grande, C = coroa, s = pequeno)

### Guerreiro

| Nó | Ângulo | Raio | Tipo | 1280 x 720 | 1920 x 1080 |
|---|---|---|---|---|---|
| Leão (Maestria, Poder maior) | 0 | 254 | C | 620, 124 | 930, 186 |
| Corte do Juízo (ult) | 331 | 254 | s | 497, 156 | 746, 234 |
| Voragem (ult) | 29 | 254 | s | 743, 156 | 1114, 234 |
| Firmeza | 50 | 254 | s | 815, 215 | 1222, 322 |
| Respiro | 63 | 254 | s | 846, 263 | 1269, 394 |
| Ainda de Pé | 76 | 254 | s | 866, 317 | 1299, 476 |
| Fio do Passo (ponte Emeth+Combo) | 89 | 254 | s | 874, 374 | 1311, 561 |
| Corte Crescente | 102 | 254 | s | 868, 431 | 1302, 646 |
| Fio Longo | 116 | 254 | s | 848, 489 | 1272, 734 |
| Onda Atravessante | 131 | 254 | A | 812, 545 | 1218, 818 |
| Onda Carregada (ponte Magia+Emeth) | 147 | 254 | s | 758, 591 | 1137, 886 |
| Lâmina Faminta | 160 | 254 | s | 707, 617 | 1060, 926 |
| Reserva | 172 | 254 | s | 655, 630 | 982, 945 |
| Coração da Emeth | 186 | 254 | A | 593, 631 | 890, 946 |
| Sangue Quente (ponte Fúria+Magia) | 202 | 254 | s | 525, 614 | 788, 921 |
| Ímpeto | 215 | 254 | s | 474, 586 | 711, 879 |
| Avanço Feroz | 228 | 254 | s | 431, 548 | 646, 822 |
| Voz Larga | 228 | 308 | s | 391, 584 | 586, 876 |
| Escudo de Guerra | 228 | 200 | s | 471, 512 | 706, 768 |
| Fúria Plena | 243 | 254 | A | 394, 493 | 591, 740 |
| Investida (ponte Combo+Fúria) | 258 | 254 | s | 372, 431 | 558, 646 |
| Fôlego de Guerra (ponte Combo+Fúria) | 258 | 308 | s | 319, 442 | 478, 663 |
| Quarto Corte | 272 | 254 | s | 366, 369 | 549, 554 |
| Passo Encadeado | 286 | 254 | s | 376, 308 | 564, 462 |
| Ferro na Investida | 286 | 308 | s | 324, 293 | 486, 440 |
| Golpe sem Fim | 301 | 254 | A | 402, 247 | 603, 370 |
### Maga

| Nó | Ângulo | Raio | Tipo | 1280 x 720 | 1920 x 1080 |
|---|---|---|---|---|---|
| Estrela (Maestria, Poder maior) | 0 | 254 | C | 620, 124 | 930, 186 |
| Tempestade dos Selos (ult) | 331 | 254 | s | 497, 156 | 746, 234 |
| Suspensão Absoluta (ult) | 29 | 254 | s | 743, 156 | 1114, 234 |
| Firmeza | 46 | 254 | s | 803, 202 | 1204, 303 |
| Reserva | 59 | 254 | s | 838, 247 | 1257, 370 |
| Respiro | 72 | 254 | s | 862, 300 | 1293, 450 |
| Passo Longo | 85 | 254 | s | 873, 356 | 1310, 534 |
| Ainda de Pé | 65 | 308 | s | 899, 248 | 1348, 372 |
| Círculo Expandido | 100 | 254 | s | 870, 422 | 1305, 633 |
| Prisão Sigilada | 113 | 254 | s | 854, 477 | 1281, 716 |
| Suspensão Larga | 113 | 308 | s | 904, 498 | 1356, 747 |
| Contenção Perfeita | 128 | 254 | A | 820, 534 | 1230, 801 |
| Selo no Chão (ponte Arca+Selos) | 144 | 254 | s | 769, 583 | 1154, 874 |
| Leitura Rápida (ponte Arca+Selos) | 144 | 308 | s | 801, 627 | 1202, 940 |
| Eco Arcano | 158 | 254 | s | 715, 614 | 1072, 921 |
| Cadeia Curta | 170 | 254 | s | 664, 628 | 996, 942 |
| Selo Duplo | 170 | 200 | s | 655, 575 | 982, 862 |
| Ruptura | 184 | 254 | A | 602, 631 | 903, 946 |
| Chama que Marca (ponte Piro+Arca) | 200 | 254 | s | 533, 617 | 800, 926 |
| Brasa Gêmea (ponte Piro+Arca) | 200 | 308 | s | 515, 667 | 772, 1000 |
| Brasa Viva | 214 | 254 | s | 478, 589 | 717, 884 |
| Pavio Longo | 227 | 254 | s | 434, 551 | 651, 826 |
| Combustão | 227 | 308 | s | 395, 588 | 592, 882 |
| Inferno Rúnico | 242 | 254 | A | 396, 497 | 594, 746 |
| Brasa que Prende (ponte Piro+Selos) | 280 | 254 | s | 370, 334 | 555, 501 |
| Passo de Brasa (ponte Piro+Selos) | 295 | 254 | s | 390, 271 | 585, 406 |
Pavio Longo e Cadeia Curta são o mesmo botão (`slot`): equipar um deixa o outro em BLOQUEADO com o motivo.

## 4. Linhas

- O anel dos nós é uma linha base contínua de 2 px em bronze apagado (8e7444 a 45%), desenhada na Godot (não na arte).
- Ligação de pré-requisito (`Talents`: Meio pede a Entrada, Ápice pede o Meio e um Dom do ramo parceiro, ponte pede as
  duas Entradas): arco pelo anel entre nós do anel, traço reto curto para esporas, ponto de junção onde um nó alimenta dois.
- Trecho **aceso** (os dois lados equipados): 3 px na tinta do ramo clareada (mistura 50% com f5cc73) e brilho aditivo de 8
  px. Trecho com um lado só aberto: 2 px na tinta do ramo a 50%. Resto: só a linha base.
- Nunca uma linha cruzando a figura de um lado ao outro; as pontes não puxam traço até o ramo distante (o aro partido diz).

## 5. Estados do nó (`HeroLoadout.State`), por desenho e por palavra (no painel)

| Estado | Nó | Linha | Painel |
|---|---|---|---|
| `LOCKED` (falta nível) | metal escuro 2a2620, aro de ferro cinza, **cadeado** no meio (como a maquete), sem cor | base | "Maestria N" |
| `SEALED` (revelado, fechado) | ícone do Dom em cinza claro sobre esmalte apagado da tinta; aro de bronze; **cristal de Memória** de 16 px no canto de baixo à direita com o custo | base | custo em Memória, "Segure para abrir" |
| `OPEN` | esmalte na tinta do ramo, ícone marfim, aro de bronze, sem brilho | metade | "Equipar", custo em Devoção |
| `EQUIPPED` | esmalte cheio, aro de **ouro**, halo na tinta do ramo (raio 1,5 do nó, 40%) que respira (0,9 a 1,0 em 2 s) | acesa | "Tirar" |
| `BLOCKED` | como OPEN a 55% de brilho, aro tracejado | metade | o motivo (`HeroLoadout.short_why`: "Pede: X", "Já há um Dom no botão Y", "Falta 1 de Devoção") |
| Foco | anel branco ouro de 3 px a 4 px do nó, pulso 0,6 s; traço até o painel | igual | o painel mostra o nó |

Coroa (leão ou estrela): sempre acesa; no foco o painel mostra o herói (nome, nível de Maestria, barra de XP, "o nível N
revela: X" e **a frase do herói** em itálico). A frase entra no painel, não na pintura (a maquete não tem lugar para ela).

## 6. Painel de detalhe (302 x 317 a 1280 x 720; moldura escura com cantos de ouro, como a maquete)

De cima para baixo, margem 16: ícone do Dom num disco de 56 px (o mesmo do nó, maior); ao lado o **nome** (Cinzel 20,
`UiKit.STRONG`) e embaixo "Dom · Fúria · Meio" (Alegreya Sans Italic 14, `UiKit.DIM`; ponte: "Dom · ponte Combo e
Fúria"); a **descrição** (Alegreya Sans 15, até 5 linhas, `UiKit.PALE`); um filete; a linha de **custo** ("Devoção" com o
disco e "3", à direita "livre 5 de 12"; selado: "Memória" com o cristal e "3", à direita "você tem 7"); o **botão** (270 x
46) com o glifo do controle ou da tecla tirado das ligações (`Controls`) e o verbo: "Equipar", "Tirar", "Segure para abrir"
(com a barra de 6 px que enche, ouro f5cc73), ou desligado com o motivo. Se o Dom troca um botão, o glifo da ação
(`ActionSlot.mark`, 18 px) fica à direita do nome. O painel nunca cobre um nó (a 1280 x 720 o nó mais à direita acaba em x 925; o painel começa em 962).

Contadores no alto à direita (placas de 33 px de altura, Alegreya Sans Bold 18): "Devoção 5 de 12" com o disco de ouro e
"Memória 7" com `memory.png` a 24 px. Ao abrir um Dom, o número da Memória desce contando (0,3 s).

## 7. Entrada

- **Direcional e setas**: o foco vai ao nó mais perto na direção apertada (cone de 60 graus, menor distância); se não houver,
  o mais perto no anel. **LB/RB e PageUp/PageDown**: salta ao primeiro nó do setor anterior ou seguinte (ordem do relógio).
- **A / Enter / clique**: equipa ou tira. **Segurar A / Enter / botão do mouse 1,0 s**: abre um Dom selado (soltar antes
  cancela e a barra volta em 0,2 s). Substitui os dois apertos do `arming` de hoje.
- **Y / Tab**: troca o herói mostrado (só heróis liberados; cada um tem o seu medalhão). **B / Esc**: fecha.
- Mouse: passar dá o foco; rodinha faz o mesmo que LB/RB.
- Abre com o foco na coroa.

## 8. Animações

- **Abrir (segurar)**: um anel de luz enche em volta do nó junto com a barra do painel (1,0 s). No fim: clarão branco 0,12 s
  no nó, 12 faíscas na tinta do ramo saindo em círculo (0,4 s), o ícone passa de cinza a marfim e o esmalte se enche (0,3 s),
  o cristal de Memória do canto some voando para o contador (0,3 s), som de bronze.
- **Equipar**: aro de bronze para ouro (0,2 s), o nó cresce a 1,12 e volta (0,2 s), o halo entra (0,3 s), a luz corre pela
  linha do pré-requisito até ele (0,25 s); som de sino pequeno. **Tirar**: o inverso em 0,15 s, sem faísca.
- **Abrir a tela**: o fundo entra (0,2 s), o medalhão gira de -8 graus a 0 e os nós aparecem do topo descendo pelos dois
  lados, 20 ms de um para o outro (0,5 s no todo). Trocar de herói: a figura cruza com a outra (0,3 s), os nós refazem a
  entrada.
- Compatibility (navegador): sem brilho aditivo nem faíscas; o resto igual.

## 9. Até a arte chegar (só peças que já existem no repositório)

| Peça | Provisório |
|---|---|
| Fundo | `assets/ui/title/title_bg.png`, só a parte sem o logo (x 0..1100), desfocado e escurecido a 45% |
| Guerreiro | `assets/ui/hero/warrior_page.png` (330 x 400, meio corpo, fundo de pergaminho) com máscara de borda suave, escalado a 560 px de altura, centro (620, 360). Fica borrado: é provisório |
| Maga | `assets/models/meshy/hero_maga_img/hero_maga_img.png` (512 x 512, recorte com fundo transparente, de pé), escalado a 600 px. O manto tem violeta: provisório |
| Ícones dos Dons | `TalentGlyph` (Guerreiro); a Maga usa o glifo do ramo enquanto não tiver o dela |
| Leão, estrela | o leão e a estrela de 8 pontas desenhados de `HeroStation` / `GiftArt.corner` |
| Moldura, faixa, nós, painel | desenho na Godot (`_draw`): círculos e arcos de ouro, `UiKit.PANEL` com filete `UiKit.EDGE` |
| Logo | o texto em Cinzel com a cor do título (não há logo recortado limpo) |
| Memória | `assets/ui/rewards/memory.png` (fica; é o ícone certo) |

## 10. Substitui o capítulo Dons do códice? Sim (recomendação)

- A tela nova abre pela estação dos Dons no Santuário e substitui o capítulo Dons do `HeroScreen`/`CodexBook`. Duas telas
  para a mesma coisa confundem, e o pedido do Daniel é identidade própria para cada sistema.
- O Livro de Ahk perde a aba Dons; a página do herói no Livro ganha uma lista só de leitura dos Dons equipados.
- Reaproveitar: `HeroLoadout` (estados, `toggle`, `open`, `short_why`), `Talents`, `TalentGlyph`, `GiftArt.INK`,
  `ActionSlot.mark`, os ganchos de captura `--title --screen=gifts [--hero=maga] --hero-xp=N --hero-opened=a,b
  --hero-equip=a,b` (a tela nova responde a eles). `CodexBook`, `GiftEntry`, `GiftRibbon` e `Candles` saem depois que a
  tela nova passar na revisão (não antes).

## 11. Critério de aprovação (captura real, Forward+, 1280 x 720 e 1920 x 1080, Guerreiro e Maga)

1. Medalhão com centro a 5 px de (620, 378) e anel dos nós de raio 254 (x1,5 a 1080); faixa no alto com o nome do herói;
   coroa com o símbolo do herói; painel à direita com o traço até o nó em foco.
2. Os 25 nós de cada herói visíveis, nenhum sobre outro, nenhum sob o painel; nenhuma linha cruzando a figura.
3. Os cinco estados legíveis pela cor **e** pela palavra no painel; ponte com o aro nas duas tintas.
4. Contadores certos: Devoção "livre N de M" e Memória com o cristal azul (nunca a Esmeralda verde).
5. Teclado, mouse e controle andam por todos os nós; segurar abre; soltar cancela.
6. Corpo de texto de 14 px ou mais a 720; nada de violeta; esmeralda só na lâmina da Emeth.
