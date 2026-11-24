# A Maga, M3: armas, frio e o capítulo no Livro de Ahk (proposta no papel)

- **Data**: 2026-11-23. **Autor**: `hero-designer`. **Estado**: só documento, nada implementado; espera as respostas da seção 5. Continua `maga.md` (seção 10: "M3: armas, frio, Livro de Ahk") e `maga_m2.md`.
- **Regras**: nomes e textos abaixo são proposta e nomes de trabalho do pacote (vão para `data/text_pt.tres` só com o aval); nenhum lore novo (a Maga é "do norte", estudiosa, registrada no Livro de Ahk, e nada além; o cânone só dá Formeth como reino de magos do norte, e o Daniel não ligou isso a ela); sem travessão; paleta âmbar e marfim, o gelo é azul pálido apagado e nunca violeta.
- **Legenda de custo**: **P** pequeno (menos de 1 dia), **M** médio (2 a 4 dias), **G** grande (uma semana ou mais). **D** = só dado.

## 1. Proposta curta da M3

A M3 fecha a Maga com três coisas, nesta ordem de importância:

1. **O frio como quarto ramo de Dons (Criomancia)**, curto: 1 entrada, 1 meio, 1 ápice e 1 ponte, tudo com estatísticas que já existem (`freeze_time`, `slow`, dano em congelado). Hoje o frio só vem das Bênçãos de Nivael; o ramo faz do frio uma escolha de montagem do herói, não só de sorte da partida.
2. **Armas ("focos")**, na forma que o Daniel escolher (seção 3). A fantasia do pacote: o Bastão Rúnico é o padrão e o Grimório das Cinzas, o Orbe do Inverno e os Anéis de Ressonância mudam **como ela joga**, não só os números.
3. **O capítulo da Maga no Livro de Ahk**, sem árvore (seção 4): a mesma tela do herói em páginas, com os Dons em lista por ramo, como o Compêndio.

Fora da M3: segundo herói jogável de verdade no hub, Ladina e Paladino, lore da Maga, modelo final do Meshy.

## 2. O frio como ramo (D, com **P** de leitura)

Ramo **Criomancia** (nome de trabalho; "Frio" no texto do jogador, pois o jogo diz "Geada" nas Bênçãos de Nivael e as duas coisas se misturam sem atrito). Fica **opcional**: com o Orbe do Inverno equipado os Dons do ramo ficam equipáveis; sem ele, ficam abertos mas "dormindo" (decisão da pergunta 3).

| Dom | Camada, custo | Efeito (números de partida) | Tipo |
|---|---|---|---|
| **Sopro Frio** | entrada, 2 | Os tiros deixam **lentidão de 25% por 2 s**; o 3º congela 0,4 s (só comuns; elite lentidão, guardião e chefe só a lentidão; a regra F8 vale). | **D** (`slow_pct`, `freeze_time`, tag `light` e `finisher`) |
| **Quebra-Gelo** | meio, 3, **direito** | A Explosão faz **+35% de dano em quem está lento ou congelado** e congela 0,5 s no raio. | **D** (dano condicional por status, mesmo canal do estilhaço de Nivael) |
| **Círculo Gélido** | meio, 3, **Q** | O Círculo deixa quem fica dentro lento por mais 1 s ao fechar e o anel vira de gelo (leitura). | L (`circle_slow_time`), ou **N** se o status no Círculo (M2, 4.1) ainda não existir |
| **Inverno Fechado** | ápice, 4 | A Suspensão Absoluta e a Tempestade **congelam por 1,5 s** quem está dentro no primeiro tique (comuns), e a Explosão dentro do domo estilhaça (+25%). | L (gatilho por ultimate) |
| **Geada que Marca** | ponte Frio e Arcanismo, 3 | Inimigo congelado **recebe o Selo na hora**. | L (aplicar `SealBook` ao congelar) |

Cinco Dons novos, o mesmo tamanho de uma ponte mais um ramo. **Risco**: congelar é o status mais forte contra horda; mantenha curto (0,3 a 0,5 s no tiro) e nada de congelar chefe e guardião.

## 3. Armas: as opções

**O que o código tem hoje**: nenhum sistema de armas. O Guerreiro tem espada fixa (a `warrior_spec`) e a Maga o bastão fixo (`MagaStaff`, `HeroBody.BODIES`). A Maestria e os Dons são por herói (`heroes.<id>` no save); a escolha de ultimate já grava por herói (`HeroDef.ult_for`, `heroes.maga.ultimate`), e é o **molde mais barato** para qualquer escolha "antes da descida". Uma arma, em dado, é um **pacote de `mods`** (estatísticas com tag de golpe, igual a um Dom) mais, se preciso, um comportamento novo no botão.

### Opção A: aspectos no molde do Hades II, para os dois heróis (sistema geral)
Cada herói ganha **3 aspectos** por arma (a Maga: Bastão, Grimório, Orbe, Anéis; o Guerreiro: a espada em 3 aspectos, ex.: Leão da Vanguarda, Leão do Muro, Leão da Caçada, nomes de trabalho). Cada aspecto é uma **tabela de dados** (`AspectDef`): troca 1 a 2 comportamentos do ataque e do especial (ex.: Grimório: o ataque vira rajada de 5 brasas curtas e o Selo vem no 2º), muda a passiva e a cor dos efeitos. Desbloqueio por Emeth (moeda de meta que já existe, ver `docs/reference/meta.md`) e por Maestria. Escolha numa lousa do Livro, antes da descida, como a ultimate.
- **Custo**: **G**. Um `AspectDef` e a escolha no save (**P**), mas cada aspecto de verdade pede comportamento de botão novo (**M** por arma), mais arte por arma (modelo e efeito: Meshy, ~20 créditos por arma, só com o aval) e equilíbrio dobrado (12 sementes por aspecto).
- **Bom**: é o que o Daniel viu nos dois referenciais (Hades II com aspectos, SWORN com armas); dá rejogabilidade grande e o mesmo sistema serve aos quatro heróis.
- **Risco**: 8 aspectos para equilibrar e animar no lançamento; o Guerreiro ainda tem poucos Dons; pode roubar tempo do combate, que o Daniel pôs em primeiro.

### Opção B: "focos" só da Maga (variações do bastão, sem sistema geral)
O Bastão continua o padrão. Os outros três são **focos** escolhidos antes da descida, cada um com **um ramo de Dons ao lado**: **Grimório das Cinzas** (Piromancia: os tiros queimam e a Explosão deixa brasa; perde 15% do alcance), **Orbe do Inverno** (Frio, seção 2: tiros lentos e mais pesados, o 3º congela), **Anéis de Ressonância** (Arcanismo: o Selo vem no 2º tiro, a Ressonância enche com 5 pontos em vez de 6; perde o dano do 3º). Cada foco é um pacote de `mods` e uma troca de skin do bastão e da cor dos tiros; **nenhum comportamento novo**.
- **Custo**: **M** (escolha no save e na lousa **P**; pacotes em `make_data.gd` **D**; skin por foco **P** de arte com o `technical-artist`; testes). Sem Meshy se os focos forem o mesmo bastão com a ponta recolorida (cada um com 2 formas de ponta), ou ~60 créditos para as 3 peças.
- **Bom**: entrega "armas da Maga" sem inventar um sistema que ainda não serve ao Guerreiro; cada foco reforça um ramo e a decisão antes da descida é clara; dá o papel do Orbe no frio.
- **Risco**: é só um "estilo" por herói, menos profundo que um aspecto; o Guerreiro fica sem equivalente (o Daniel pode achar assimétrico, mas o decidido é que os kits não precisam se espelhar).

### Opção C: arma como Dom de espaço "arma" (nenhum sistema novo)
O foco entra como um **Dom do ramo com slot `arma`**: dois Dons no mesmo botão já se excluem (`Talents`), então "Grimório ou Orbe ou Anéis" é só um quarto slot, exclusivo, equipado com Devoção, aberto por nível (ex.: Maestria 4, 8 e 12). Sem lousa nova: aparece como mais um Dom na lista do Livro.
- **Custo**: **P a M** (um slot a mais em `TalentDef`; três Dons; skin do bastão como na B).
- **Bom**: o mais barato; usa a Devoção, então a arma "custa" algo e compete com outros Dons.
- **Risco**: some a fantasia de "trocar de arma"; com Devoção apertada (11 no nível 6) a arma nunca é a escolha; o Dom-arma ocupa o lugar de um Dom de verdade.

### Comparação

| | A aspectos, 2 heróis | B focos da Maga | C Dom-arma |
|---|---|---|---|
| Custo | **G** | **M** | **P a M** |
| Muda o jeito de jogar | muito | médio | pouco |
| Serve ao Guerreiro | sim | não | sim (como slot) |
| Arte nova | alta | baixa a média | baixa |
| Risco de equilíbrio | alto | médio | baixo |
| Toca o combate de agora | sim | pouco | não |

**Recomendação**: **B agora, desenhada para virar A depois.** Os focos entram como pacote de `mods` selecionado antes da descida (o mesmo caminho da ultimate), e o formato do dado já nasce com o que o `AspectDef` teria (id, pacote de estatísticas, troca de skin, desbloqueio). Se o Daniel gostar, o Guerreiro ganha os aspectos dele depois sem refazer a escolha, a lousa nem o save. Razões: o combate é a prioridade (`focus-combat`), o Guerreiro ainda não tem Dons suficientes para sustentar aspectos, e B é a única que dá ao Orbe do Inverno um papel claro (abre o ramo do frio).

## 4. O capítulo da Maga no Livro de Ahk (sem árvore)

O Daniel não gosta das duas árvores (`no-tree-screens`), e a pergunta da M2 sobre desenhar o triângulo fica sem efeito se esta proposta valer. A proposta usa o que o livro já tem: `BookSpread` (duas páginas), `Book` (tinta, `INK`, `FADED`, `RUBRIC`, `heading`, `section`, `index_entry`) e o `CodexScreen` (índice na esquerda, detalhe na direita). **O nome do capítulo na marca é "A Maga"** (como o do Guerreiro é "O Guerreiro"); o Guerreiro ganha o mesmo desenho se o Daniel aprovar.

**Capítulo "A Maga" (marcadores: Abertura, A Maga, Dons)**:
- **Página esquerda (A Maga)**: o retrato pintado (a arte 01 aprovada, recorte como o do Guerreiro), "do norte" e a frase do pacote sobre a estudiosa registrada no Livro (sem nome nem origem além disso), a **arma em uso** (o foco, com o desenho da ponta) e a passiva (o laço Selo, Explosão, Ressonância) em três linhas.
- **Página direita (Habilidades)**: as 5 marcas do HUD (`ActionSlot.mark`) com nome, recarga e uma frase, e o glifo da ultimate escolhida.
- **Dons, como lista por ramo em vez de árvore**: três cadernos (Piromancia, Arcanismo, Controle e Selos) mais o do Frio quando o Orbe estiver aberto. No índice da esquerda, cada Dom é uma linha (`index_entry`) com o glifo (`TalentGlyph`), o custo de Devoção e o estado (equipado: selo esmeralda; aberto; trancado com o nível). Na direita, o detalhe: Efeito, Custo, **"Pede"** (as pontes dizem "Pede Brasa Viva e Eco Arcano" em palavras, sem linhas), Estado e Próximo passo (`next_step`). A **ponte** aparece no caderno do primeiro ramo que ela une, com uma fita "liga com o Arcanismo". Sem nós, sem linhas, sem losango nem triângulo.
- **Armas**: uma página "Focos" depois dos Dons: os quatro (Bastão, Grimório, Orbe, Anéis) como entradas de índice, o detalhe com o que ganha, o que perde e o ramo que abre; trancados em silhueta `FADED` com a pista ("Maestria 4"). A escolha grava na hora (`heroes.maga.weapon`).
- **Compêndio**: uma aba Selos (nome de trabalho): o laço da Maga, os estados do Selo, a Ressonância; só o que o jogador já viu.
- **Custo**: **M** (a lista por ramo reaproveita `CodexScreen` e `HeroLoadout`; o `HeroScreen` hoje é só do Guerreiro e precisa aceitar um herói, o que já se desenhou na M2). Sem arte nova além do retrato recortado e dos desenhos das pontas dos focos; **o `art-director` revê o desenho das páginas, e o texto fica em `data/text_pt.tres`**.

## 5. Perguntas ao Daniel (com a minha recomendação)

1. **Armas, qual das três?** A (aspectos para os dois heróis, G), B (focos só da Maga, M) ou C (Dom-arma, P a M). **Recomendo B, com o dado já no formato de aspecto para virar A depois.**
2. **O Guerreiro também troca de arma?** Se sim agora, é a opção A. **Recomendo deixar o Guerreiro para depois da B**; o jogo tem outros 3 heróis para fazer e o Guerreiro tem poucos Dons.
3. **O ramo do frio precisa do Orbe do Inverno equipado?** Sim (Dom "dorme" sem ele) ou não (qualquer foco usa o Frio)? **Recomendo sim**: dá sentido ao Orbe e mantém a escolha de arma pesando.
4. **Como se destrava cada foco?** Por Maestria (4, 8 e 12), por Emeth, ou por um feito (matar um guardião com a Maga)? **Recomendo Maestria 4, 8 e 12**, igual aos Dons.
5. **Trocar o foco no meio da descida?** **Recomendo não**: só no Livro, antes de descer, como a ultimate.
6. **Os nomes** Grimório das Cinzas, Orbe do Inverno e Anéis de Ressonância (do pacote) ficam como nomes de trabalho, com o Bastão Rúnico padrão. Aprova? **Recomendo sim; nada de lore novo sobre eles** (de onde vêm, quem os fez).
7. **Dons em lista por ramo, sem árvore** (seção 4), para a Maga e depois para o Guerreiro? **Recomendo sim**: respeita o que o Daniel disse sobre as árvores e custa menos. Isso substitui a pergunta 2 da M2 (o triângulo).
8. **Meshy**: os focos usam só o bastão com a ponta recolorida (sem crédito) ou peças novas (cerca de 60 créditos, prévia primeiro)? **Recomendo recolorir agora e gerar peças novas só depois do aval**.
9. **Tamanho do ramo do frio**: os 5 Dons da seção 2 ou só 3 (entrada, meio, ápice)? **Recomendo os 5**: o frio só vale como ramo se tiver uma ponte com o Arcanismo.
