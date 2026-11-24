# Identidade das telas de meta (art-director, 2026-11-23)

Pedido do Daniel (2026-11-23): "eu não gosto de nenhuma árvore, acho que o livro do Ahk pode se parecer com um livro
pergaminho, as demais mecânicas têm que ter uma identidade própria como no Hades 2 ou SWORN". Autorizou seguir as
recomendações. Este documento é a especificação para o `ui-ux-designer` (telas) e o `environment-artist` (peças do
Santuário). Hades II e SWORN só como princípio: **cada sistema é um objeto do mundo, com verbo próprio**. Nada copiado
(nem forma de tela, nem cartas de tarô, nem caldeirão, nem poço).

Regras que valem para tudo abaixo:
- Paleta de `docs/art/art_direction.md` 2: pergaminho `UiKit.PARCHMENT`, tintas `Book.INK`, `FADED`, `RUBRIC`, `GILT`;
  esmeralda viva só da Emeth; petróleo só do herói; violeta nunca (é de Morvath); vermelho vivo só no que fere.
- Leitura antes de metáfora: todo estado tem **número escrito** além do desenho (custo, saldo, "7 de 12").
- Cada tela cabe a 1280x720 com corpo de 14 px ou mais (C17); a 1920x1080 é a mesma tela escalada (`canvas_items`).
- Teclado, mouse e controle em todas: setas/direcional andam, Enter/A faz o verbo, Esc/B volta (pergunta aberta fecha
  primeiro), PageUp/PageDown (LB/RB) trocam capítulo ou aba; o mouse toma o foco ao passar, clique faz o verbo.
- **"Selo" não se usa para lacre de cera**: os Selos são as fechaduras do Abismo no cânone e um ramo da Maga. A peça de
  cera chama-se **lacre** no código e no texto.
- Ahk segue sem rosto (Q-03): a voz dele são os objetos (papiros, pena, tinteiro, velas). Nada de lore nova.

---

## 1. O Livro de Ahk: os Dons como códice iluminado (prioridade 1)

O grafo some (losango do Guerreiro e triângulo da Maga). Ahk é o escriba que anotava em papiros (cânone,
`canone.md` "Ahk e o Livro Sagrado de Yah"); o capítulo Dons vira **páginas escritas**: cada ramo é um capítulo marcado por
uma **fita**, cada Dom é uma **entrada** (parágrafo com capitular), o custo em Devoção são **velas**, abrir com Memória é
**romper o lacre**.

### 1.1 Forma

- **Fitas de marcador** saem da borda de cima do livro, uma por capítulo, na tinta do ramo. Guerreiro: Combo, Fúria,
  Emeth, Magia, Pontes, Sustento (6). Maga: Piromancia, Arcanismo, Selos, Pontes, Sustento (5). A fita aberta desce mais
  (12 px) e fica acesa; cada fita mostra na ponta um ponto de ouro por Dom equipado naquele capítulo (até 3, depois "+N").
  Abas do livro (Abertura, herói, Dons, Ofícios) seguem como hoje no alto, acima das fitas.
- **Página da esquerda = o capítulo**: cabeça com o nome do ramo em Cinzel 30 na tinta do ramo, uma **miniatura** (faixa
  de 110 px de altura, ilustração do ramo em sépia com uma cor) e, embaixo, as **entradas em ordem de leitura**: Entrada,
  Meio, Ápice de cima para baixo (degrau = ordem na página, como versículos). Entrada: 64 px de altura, capitular +
  nome (Alegreya Sans Bold 18) + uma linha curta do efeito (15, tinta) + custo em velas à direita. No pé da página, em
  rubrica: "O nível N revela: X" (a linha que hoje fica no topo).
- **A capitular diz o degrau**: Entrada = letra simples de 28 px na tinta do ramo; Meio = letra de 34 px com filigrana;
  Ápice = letra de 44 px iluminada (campo de cor do ramo + ouro `GILT`), ocupando duas linhas. Reaproveita `DropCap`.
- **Fio do pré-requisito na margem**: uma linha fina vertical na margem esquerda liga Entrada, Meio e Ápice do capítulo.
  Trecho cujo pré-requisito está equipado fica em ouro; o que falta, tracejado em `FADED`. O Ápice leva uma **nota de
  margem** em rubrica, "com um Dom de Fúria", com um pedacinho da fita do ramo parceiro. Pontes: a capitular é partida na
  diagonal nas duas tintas dos ramos que une, e a nota diz "pede as duas entradas: Combo e Fúria".
- **Escolha no mesmo botão** (Pavio Longo ou Cadeia Curta; um Dom por ação): as duas entradas lado a lado com "ou" em
  rubrica no meio; equipar uma apaga a outra para `FADED`. O glifo da ação (`ActionSlot.mark`, 18 px) fica na margem
  direita de toda entrada que troca um botão.
- **Página da direita = a leitura**: como hoje (`_gifts_right`): Maestria, nome em Cinzel, ramo e degrau, Efeito, Custo,
  Pré-requisito, Estado. Muda a cabeça: **Devoção são velas** numa fileira (uma vela por ponto, até 25, 16 px cada, 450 px
  no máximo) com "7 de 12" escrito ao lado; vela acesa = livre, vela apagada com fio de fumaça = gasta. Ao pôr o foco
  numa entrada, as velas que ela custaria tremulam (0,6 s em laço). O custo da entrada também é desenhado como N velas
  pequenas (10 px).
- **Ultimates = iluminuras de página inteira**: o último capítulo (fita de ouro, "Poder maior") mostra cada ultimate como
  miniatura grande na página da esquerda (uma por página, PageDown passa) e a leitura na direita. Travada = só o
  **desenho de base** (traço sépia a lápis, sem cor) e "Maestria 6"; aberta = colorida; escolhida = moldura de ouro.

### 1.2 Estados de uma entrada (`HeroLoadout.State`)

| Estado | O que se vê | Texto |
|---|---|---|
| `LOCKED` (Maestria ainda não chegou) | pautas vazias a lápis, capitular só em contorno, nome em `FADED` 50% | "Maestria N" |
| `SEALED` (revelado, falta abrir com Memória) | texto escrito, mas a entrada está presa por um **lacre de cera** (`talent_node.gd` `SEAL_WAX` 7a3a34) sobre um cordão que atravessa o parágrafo; o custo em Memória gravado no lacre | "Romper o lacre: N de Memória" |
| `OPEN` (aberto, não equipado) | tinta cheia, capitular só a traço (sem cor) | "Pode equipar" |
| `EQUIPPED` | capitular iluminada na cor do ramo e ouro, folha de ouro na margem direita, velas gastas na cabeça | "Equipado" |
| `BLOCKED` (pré-requisito, botão ocupado, Devoção curta) | tinta `FADED`, uma **mãozinha de margem** (manícula) em rubrica apontando o motivo | "Pede: X" / "Já há um Dom no Brado: X" / "Faltam 2 velas" |

Animações (curtas, 0,2 a 0,4 s): romper o lacre (racha, duas metades caem, cordão se solta, som de cera); equipar (a
capitular se enche de cor de baixo para cima, uma vela por ponto se apaga da direita para a esquerda); tirar (o inverso).
Trocar de fita: página vira por troca de opacidade de 0,15 s e som de papel (sem animação de dobra por enquanto).

### 1.3 Mesmo livro, mão de cada herói

- **Guerreiro**: tinta ferro-gálica castanha (`Book.INK`), capitulares de traço largo, filigrana com folhas e o leão
  rampante pequeno nas cantoneiras das páginas de capítulo. Tintas dos ramos (no papel, abaixadas): Combo `RUBRIC`
  783222, Fúria ocre 9a5a2a, Emeth verdete 2f7a58 (não o esmeralda vivo), Magia lápis 3d6a8c. Miniaturas: os três arcos do
  combo; o herói em fúria (cargas como três chamas pequenas); a lâmina verde de perfil; a onda do especial.
- **Maga**: mesmo papel, tinta âmbar-escura 6a3a14 nos títulos, capitulares de traço fino e geométrico, a estrela de 8
  pontas do estandarte dela nas cantoneiras. Tintas: Piromancia âmbar 9a4a1c, Arcanismo ouro em folha (`GILT` com contorno
  de tinta, o marfim não lê no papel), Selos ardósia 4a5560. Miniaturas: a brasa sobre a mão; o cajado de duas pontas
  traçando o arco; o Selo posto no inimigo.
- Pontes e Sustento: tinta neutra (Pontes `GILT`, Sustento castanho 7a4e3a) nos dois heróis.
- O ciclo dos ápices da Maga (Piromancia, Arcanismo, Selos) vira só a nota de margem do Ápice, como no Guerreiro.

### 1.4 Esboço (1280x720; a 1920x1080 igual, escalado)

```
 [Abertura][O Guerreiro][ DONS ][Ofícios]                                      (abas de hoje)
 +-----|Co|-|Fú|-|Em|-|Ma|-|Po|-|Su|-|Ult|--------------------------------------------------+
 |      ‾‾   ‾‾  [Em]  ‾‾   ‾‾   ‾‾   ‾‾      (fitas; a aberta desce e mostra .. pontos)    |
 |  EMETH                          ||  (o) Maestria 4  [====------] 120 de 200             |
 |  +--------------------------+   ||  Devoção  i i i i i i i ı ı ı ı ı   7 de 12           |
 |  | miniatura sépia+verdete  |   ||  ------------------------------------------------     |
 |  +--------------------------+   ||  FIO LONGO                                           |
 |  |  (F) Corte Crescente     iii ||  Emeth, meio                                         |
 |  |      ...                    ||  EFEITO   O ataque alcança 15% mais longe.             |
 |  |  [M] Fio Longo            ii ||  CUSTO    2 de Devoção (ii)                           |
 |  :      +15% de alcance        ||  PRÉ-REQ. Corte Crescente                             |
 |  :  [A] Onda Atravessante iiii ||  ESTADO   Equipado                                    |
 |  :      ==(cera 3)==           ||                                                      |
 |  :   ^"com um Dom de Magia"    ||                                                      |
 |  O nível 5 revela: Reserva     ||               [ Tirar ]   [ Compêndio ]  [ Voltar ]   |
 +----------------------------------------------------------------------------------------+
  PageUp/PageDown capítulo do livro   ←/→ fita   ↑/↓ entrada   Enter equipar   Esc voltar
  legenda: i vela acesa, ı vela apagada; (F) capitular simples, [M] com filigrana, [A] iluminada;
  '|' fio do pré-requisito cumprido (ouro), ':' o que falta (tracejado); ==(cera 3)== lacre com 3 de Memória
```

### 1.5 Entrada (teclado, mouse, controle)

- ↑/↓ (direcional, analógico) andam nas entradas e descem para os botões do pé; ←/→ trocam de fita (passam por Pontes,
  Sustento e Poder maior). Mouse: clique na fita, clique na entrada para ler, clique de novo (ou no botão do pé) para
  equipar/tirar; rodinha anda entre entradas. Enter/A numa entrada `SEALED` abre a pergunta no pé "Romper o lacre de X
  por N de Memória?" (Romper, Cancelar), como a Videira faz hoje; nada se gasta antes de Romper.
- Verbos na tela: **Equipar**, **Tirar**, **Romper o lacre**. Não usar "Inscrever" (é da Forja).

### 1.6 Reaproveitamento

`HeroScreen` (capítulos, `_gifts_right`, `_tell_gift`, `_pick`, `_open_sealed`), `HeroLoadout` (estados, `toggle`,
`open`), `Talents.check`, `BookSpread`, `Book`, `DropCap`, `SealedMark`, `TalentGlyph` (glifo na capitular do Ápice).
Saem da tela dos Dons: `TalentTree` e `TalentNode` (o desenho do lacre e as cores do nó podem migrar para a entrada
nova, `GiftEntry`). Testes de hoje sobre foco e estado continuam válidos; os de geometria do losango/triângulo saem.

---

## 2. Uma metáfora por sistema

| Sistema | Objeto do mundo | Verbo |
|---|---|---|
| Forja | a arma do herói deitada no pano, sobre a bancada do Forjador | Temperar, Refinar, Despertar, Inscrever (o que a tela de hoje já diz) |
| Encantos | estojo de ourives com 3 pedras lapidadas; a guarda da Emeth tem 2 engastes | Engastar |
| A Videira | a própria videira do arco de pedra, com etiquetas de barro nos brotos | Fazer crescer |
| Altar Esquecido | a laje do altar com dois nichos de oferta e a lamparina | Ofertar / Seguir em frente |
| Ofícios | o quadro de ferramentas do Forjador: ganchos com sombras pintadas, tábuas de encomenda | Restaurar, Entregar |
| Vendedor (trocas, Obras) | o balcão com uma balança de pratos | Trocar, Encomendar |
| Salmos | vitral em arco ogival com três painéis (os três requisitos) | Tomar |
| Escolha de herói | os estandartes na travessa de ferro (os mesmos do Santuário) | Levar este estandarte |
| Loja da descida | a banca do mercador: pano no chão, etiquetas de couro penduradas | Comprar (no mundo, sem tela) |
| Juramentos (extra, se o GD quiser) | pesos de bronze pendurados na travessa sobre o Portal | Pendurar / Tirar |

### 2.1 Forja: a arma na bancada

- **Vê**: tela sem livro. Fundo escuro de oficina (tinta `UiKit.INK` com brilho âmbar de brasa embaixo); a Emeth
  deitada na horizontal sobre pano, ocupando 70% da largura. Quatro pontos de toque na própria arma, cada um com placa
  pequena (nome da trilha, custo, saldo): **Temperar** no fio (três entalhes ao longo do gume, um aceso por posto),
  **Refinar** na guarda (as escolhas Fio, Peso, Pressa, Onda Larga, Onda Pesada, Onda Pronta como anéis na guarda),
  **Despertar** no pomo (um engaste; a pedra desperta brilha, as outras ficam numa bandeja ao lado), **Inscrever** no
  plano da lâmina (letras gravadas em ouro velho, nunca runas, que são de Morvath). Trilha sem a ferramenta achada: o
  ponto fica coberto por um pano com a silhueta da ferramenta (liga ao quadro dos Ofícios). Pergunta no pé antes de gastar.
- **Maga**: o cajado de duas pontas no lugar da Emeth quando ela tiver trilhas (hoje as trilhas são só da Emeth: a tela
  mostra a Emeth e diz "A Forja trabalha a Emeth").
- **Entrada**: ←/→ andam pelos quatro pontos, ↑/↓ pelas opções do ponto, Enter compra (com pergunta).
- **Reaproveita**: `ForgeScreen` inteira (trilhas, compras, `Forge`, sinais), muda só a disposição e o fundo.

```
 +------------------------------------------------------------------------------------+
 |  A FORJA                                         Prata 85  Memória 4  Esmeralda 1 |
 |                                                                                    |
 |     [Despertar]          [Refinar]               [Inscrever]          [Temperar]   |
 |         |                    |                        |                    |       |
 |      (O)==========[]=|=|=|===<=======  A U R E A   L E T R A  ========|>|>|>>      |
 |      pomo         guarda (anéis)      plano da lâmina (gravado)     fio, 3 entalhes|
 |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ pano sobre a bancada ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |
 |  TEMPERAR II   +10% no especial          35 de Prata          [ Temperar ]          |
 +------------------------------------------------------------------------------------+
```

### 2.2 Encantos: o estojo de ourives

- **Vê**: na descida, a escolha (`EnchantChoice`) vira um estojo aberto de couro com veludo escuro e **três pedras
  lapidadas** (marfim, âmbar, ouro velho; nada de esmeralda nem violeta), cada uma com um entalhe do golpe que muda
  (leque de três ondas, eco duplo, seta de volta). Sob cada pedra, nome e uma linha. Em cima, a guarda da Emeth em
  detalhe com os **dois engastes** (`StageDef.enchant_max` 2): o vazio, ou a pedra já engastada nesta descida.
  Encantos da Forja (Inscrever) aparecem no mesmo estojo com uma letra gravada na pedra.
- **Maga**: os dois engastes são as duas pontas do cajado.
- **Entrada**: ←/→ pedra, Enter engasta (a pedra voa para o engaste, 0,3 s).
- **Reaproveita**: `EnchantChoice`, `Enchants`, `Game.take_enchant`.

```
          guarda:  [ pedra âmbar ]  [  vazio  ]
   +-----------------------------------------------------+
   |  veludo    <>          <>           <>              |
   |         (leque)     (eco)       (volta)             |
   |     Lâmina Tríplice  Eco da Verdade  Retorno do Corte |
   +-----------------------------------------------------+
```

### 2.3 A Videira: a planta, não um diagrama

- **Vê**: a mesma videira do Santuário (V3): vaso embaixo, tronco retorcido, três ramos curvos (Vida à esquerda,
  Provisão no meio, Perseverança à direita) subindo por uma latada de ferro presa no arco de pedra. Os nós são
  **brotos** com uma **etiqueta de barro** pendurada (nome e custo); comprado = folha aberta e cacho com flor âmbar
  (as flores emissivas da V3); comprável = broto inchado com leve brilho; sem material = broto fechado e etiqueta com o
  número em rubrica; pede o anterior = broto seco, etiqueta "Depois de: Seiva". Hastes curvas (nunca linhas retas de
  grafo). Saldo no canto como hoje.
- **Entrada**: igual à `VineScreen` de hoje (colunas, foco, pergunta antes de comprar); verbo "Fazer crescer".
- **Reaproveita**: `VineScreen` (lógica, pergunta, foco), `Vine`; desenho dos ramos por `Line2D` com Catmull-Rom (as
  mesmas `PATHS` da `VineStation`, projetadas) ou a própria `VineStation` num `SubViewport` com câmera frontal.

```
      Vida              Provisão            Perseverança         Prata 40  Memória 6
       @ [Raiz Funda 20]   o [Reserva 20]      . [Farta 20]       @ cacho  o broto  . seco
        )                 (                    )
       @ [Caule 10]        @ [Estoque 10]      o [Memória 10]
        (                  )                  (
       @ [Seiva 5]          @ [Viajante 5]      @ [Prata 5]
         \_______________   |   _______________/
                         \__|__/     latada de ferro sob o arco de pedra
                          [vaso]
```

### 2.4 Altar Esquecido: os nichos e a lamparina

- **Vê**: a tela do evento (`EventChoice` do Altar) mostra a face da laje com **dois nichos de oferta**: em cada um, o que
  se dá (à esquerda, entalhado: o coração com "10 de vida máxima"; a bolsa com "75 de ouro") e o que se recebe (à direita
  do nicho: a romã; "25 de Magia máxima"). No alto, a **lamparina apagada**; escolhida a troca, ela acende (já existe no
  mundo: `AltarLook.kindle`). "Seguir em frente" é um terceiro botão baixo, sem nicho, sempre presente.
- **Entrada**: ←/→ nicho, Enter oferta (pergunta "Dar 10 de vida máxima por uma romã?"), Esc segue em frente.
- **Reaproveita**: `EventChoice`, `Altar`, `AltarLook.kindle`.

```
                     ( lamparina )
   +-------------------+   +-------------------+
   | [coração] -> [romã]|   | [bolsa] -> [Magia]|
   | 10 de vida máxima  |   | 75 de ouro        |
   | por uma romã       |   | por 25 de Magia   |
   +-------------------+   +-------------------+
                 [ Seguir em frente ]
```

### 2.5 Ofícios: o quadro de ferramentas

- **Vê**: uma parede de tábuas com ganchos (o "quadro de sombras" de oficina): cada ferramenta tem a **silhueta pintada**
  em ocre no lugar dela; achada, a ferramenta pendura por cima da sombra (Picareta, e as três da Forja: Refinar, Despertar,
  Inscrever). A Picareta sem cabeça aparece pendurada quebrada até ser restaurada. À direita, **tábuas de encomenda**
  presas por barbante, com marcas de giz para o que falta ("Pedra Funda 1 de 2", "Prata 30"). A Pedra Funda guardada fica
  num caixote embaixo com o número. Obra pronta: a tábua ganha um prego de ferro e vai para uma fileira "Feitas".
- **Entrada**: ↑/↓/←/→ entre ganchos e tábuas, Enter no gancho mostra onde achar ("atrás de uma porta da descida, com o
  nome na placa"), Enter na tábua entrega (pergunta).
- **Reaproveita**: capítulo Ofícios do `HeroScreen` (`_oficios_left`, `_oficio_row`) e `OficioSheets`; dados de
  `Oficios`. O capítulo do Livro passa a ser o registro (lista curta); a tela do quadro abre no Forjador.

```
 +--------------------------------------------+----------------------------+
 |   o        o         o          o          |  ENCOMENDAS                |
 |  /|\      [=]       (*)        /_\         |  +----------------------+  |
 | Picareta  Refinar  Despertar  Inscrever    |  | Ao Vendedor          |  |
 | (quebrada) (sombra) (achada)   (sombra)     |  | Pedra Funda  1 de 2  |  |
 |                                            |  | Prata        30      |  |
 |  [caixote: Pedra Funda 3 de 10]             |  +----------------------+  |
 +--------------------------------------------+----------------------------+
```

### 2.6 Vendedor: a balança

- **Vê**: o balcão de madeira visto de frente; no meio, uma **balança de pratos**. Cada troca (`OficiosDef.trades`) é uma
  linha à esquerda; com o foco, o prato da esquerda recebe o que se dá e o da direita o que se recebe, e **a balança pende
  para o lado do que se dá** (a troca com perda fica visível). Obras abertas como encomendas (tábuas, mesmo desenho do
  quadro) à direita.
- **Reaproveita**: `VendorScreen`, `Vendor.trade`.

```
   TROCAS                         ___|___                 OBRAS
   10 Prata -> 1 Memória         /       \               [Altar Restaurado]
   2 Memória -> 5 Prata       [10 Prata]   \             [Fonte Viva]
   40 Prata -> 1 Esmeralda                 [1 Memória]   [Banca da Rota]
```

### 2.7 Salmos: o vitral

- **Vê**: o medalhão de Salmo já é ogival (`art_direction.md` 7). A carta de Salmo na `BoonChoice` vira um **vitral em
  arco ogival**, mais alta que as cartas de Bênção (sobe 40 px acima da linha delas), com **três lancetas** = os três
  grupos `requires`. Cada lanceta acende (vidro âmbar, marfim ou ouro, chumbo escuro entre os painéis) com o nome da
  coisa que cumpriu ("Brado em Brasa", "Dom: Fio Longo"); quando as três acendem a rosácea do alto brilha. No "Suas
  Bênçãos" e no Compêndio, cada Salmo é o mesmo vitral pequeno. Sem cruz, sem sol (`art_direction.md` 7).
- **Reaproveita**: `BoonChoice.open_cards`, `PsalmIcon`, `Psalms.met` (que já diz o que cumpriu cada grupo). Vitral
  em shader de 2D (painéis por máscara, linhas de chumbo), na Godot.

```
        /\
       /  \      <- rosácea
      |·|·|·|
      |A|B|C|    A = Brado em Brasa  B = Elo: X  C = Dom: Fio Longo
      |_|_|_|
     SALMO DA SENTINELA
```

### 2.8 Escolha de herói: os estandartes

- **Vê**: tela larga com a travessa de ferro dos estandartes do Santuário (`HeroStation`): um estandarte por herói que
  existe (hoje dois; sem ganchos vazios prometendo heróis). O focado desenrola até o chão e à frente dele aparece a arte
  do herói (a da prancha; Maga, a arte 01 aprovada) com nome, uma frase e os botões dele. Travado = pano cinza enrolado
  com cordão, sem emblema, e a frase de hoje ("Ela é liberada quando você selar Morvath pela primeira vez.").
- **Entrada**: ←/→ estandarte, Enter "Levar este estandarte" (grava como hoje).
- **Reaproveita**: `HeroPickScreen` (dados, sinal `picked`), `HeroStation` (pano, leão, estrela de 8 pontas, `ROLLED`)
  renderizada num `SubViewport`, ou os estandartes desenhados em 2D com as mesmas cores.

```
   ===o===================o===================o===    travessa de ferro
      |  pano vermelho    |   pano âmbar      |
      |     (leão)        |   (estrela 8)     |
      |  [arte do         |                   |
      |   Guerreiro]      |                   |
      |  O GUERREIRO      |    A MAGA         |
      |  Golpes e avanço  |    Selos e fogo   |
      \_________/         \_______/
           [ Levar este estandarte ]
```

### 2.9 Loja da descida: a banca

- Fica no mundo (sem tela). O mercador de rota e a loja de fim de descida ganham um **pano estendido** no chão sob os
  itens e **etiquetas de couro** penduradas em pequenos postes com o preço (a `DoorSign` de hoje vira etiqueta: mesmo
  texto, moldura de couro com costura em vez do filete). Sem ouro, o preço em rubrica e "Faltam N de ouro", como hoje.
- **Reaproveita**: `Rooms._build_shop`, `DoorSign.set_gold`, `StationSign`; peça nova do `environment-artist`.

```
        |N|         |N|         |N|        |N| etiqueta de couro, preço
     (romã)     (coração)   (Encanto)
   ~~~~~~~~~~~~~~ pano do mercador ~~~~~~~~~~~~~~
```

### 2.10 Juramentos (fora da lista pedida; aplicar se o GD quiser)

Pesos de bronze com a marca de cada Juramento pendurados numa travessa; o Peso total escrito na travessa. Reaproveita
`JuramentoScreen` inteira. Prioridade baixa.

---

## 3. Ordem, peças e pedidos

### 3.1 Ordem de implementação

1. **Livro de Ahk, capítulo Dons** (`ui-ux-designer`): fitas, página de capítulo, entradas, velas, lacre, ultimates.
   Guerreiro e Maga juntos (mesma tela, tinta e cantoneira por herói). Tudo desenhado na Godot; as miniaturas entram
   primeiro como placeholder (a capitular grande do ramo no lugar) e depois pintadas.
2. **Salmos (vitral)** e **Encantos (estojo)**: telas da descida que o Daniel vê em toda partida. Só Godot.
3. **Escolha de herói (estandartes)**: barato, reaproveita a `HeroStation`.
4. **Forja (arma na bancada)**: precisa da pintura da Emeth.
5. **Videira (planta)**: reaproveita a V3; etiquetas de barro na Godot.
6. **Altar (nichos)**, **Ofícios (quadro)** e **Vendedor (balança)**.
7. **Loja (banca)** e **Juramentos**: peças de cenário, por último.

Critério de aprovação de cada tela (captura real 1280x720 e 1920x1080, Forward+): sem nó nem linha de grafo; o estado
de cada item lê pelo desenho **e** pelo texto; corpo de 14 px ou mais a 720; foco visível com teclado e controle; o
objeto é reconhecível sem legenda (velas, lacre, fita, pedras, broto, nicho, ganchos, vitral, estandarte).

### 3.2 Peças de arte

| Peça | Como | Quem |
|---|---|---|
| Fitas, pautas, fio de margem, manícula, folha de ouro, velas (com chama em shader), lacre e a racha | desenho 2D na Godot (`_draw`, shader pequeno) | ui-ux-designer |
| Capitulares iluminadas por degrau | `DropCap` estendida (campo de cor, filigrana, ouro) | ui-ux-designer |
| Miniaturas dos capítulos (Guerreiro 4, Maga 3) e das ultimates (4) | pintura (ChatGPT, pedido abaixo) | Daniel pede; art-director recorta e revisa |
| Emeth deitada na bancada; cajado da Maga | pintura (ChatGPT) | idem |
| Estojo com pedras, vitral, etiquetas de barro, balança | Godot (shader e desenho) | ui-ux-designer |
| Quadro de ferramentas com sombras; face do altar com nichos | pintura (ChatGPT) | idem |
| Estandartes | `HeroStation` em `SubViewport` | ui-ux-designer |
| Banca do mercador (pano, etiquetas) | peça 3D | environment-artist |

Tudo que vier do ChatGPT entra em `docs/steam-ia.md` antes de ir para o jogo. O pedido pronto está em
`C:\Users\danie\Downloads\Pedido-ChatGPT-telas-de-meta.txt`.

### 3.3 Para o Game Director

- **Árvore do Santuário**: a estação "Árvore de Dons" (`StoneTree`, placas dos Dons em volta) contradiz "não gosto de
  nenhuma árvore". Recomendação: depois do Livro, a estação vira uma estante de papiros (o Livro abre direto no capítulo
  Dons), peça do `environment-artist`; a pedra e as placas acesas (HV-E) podem virar papiros na estante. Não bloqueia o lote.
- Nomes "Poder maior" (capítulo das ultimates) e os verbos ("Romper o lacre", "Engastar", "Fazer crescer", "Levar este
  estandarte") são de trabalho; o Daniel valida no teste.
