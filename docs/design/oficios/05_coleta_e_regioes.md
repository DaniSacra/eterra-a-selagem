# Ofícios e Descobertas: coleta, regiões, distribuição e mapa (room-designer, 2026-11-20)

Parte do estudo do pedido `00_pedido_po.md`: seções 5 (coleta), 6 (identidade por região) e o mapa da 11. Só estudo,
nada implementado. Todo nome de recurso, ferramenta ou descoberta aqui é **provisório (para o Daniel)**; nada disso toca
o cânone sem ele. Números medidos estão marcados como **medido**; o resto é **meta** ou **estimativa**.

## 0. O que já existe e pesa na decisão (medido)

- Descida de 11 salas (10 + Morvath). Robô com reação 0,25 chega a Morvath em **233 s** de mediana (`docs/qa/dv1_metrics.md`,
  72 sementes) e a partida inteira dura 5 min 40 s a 7 min 10 s (`e3_metrics.md`). Meta para gente: 10 a 13 min, **não medida**.
- Sala de luta do robô: **23 a 32 s** de mediana (Cripta, Fendas e Jardim 23 a 24 s; Santuário 32 s; Ponte e Runas 27 a
  30 s; `rooms_progression.md` 2.1). Depois da luta existe uma fase calma: recompensa no relicário, portas abrindo, herói
  andando até a porta escolhida. É ali que cabe qualquer coleta.
- A tecla de usar já existe (`interact`, E no teclado, A no controle; `Rooms.usable`, `use_kind`, placa `StationSign.under`
  pendurada embaixo do que se usa). O ataque fica no mouse e no X do controle: não há conflito de tecla, mas há conflito
  de **atenção** se a coleta valer durante a luta.
- Materiais que já voltam para casa: Prata, Memória, Esmeralda (`MaterialPurse`), com portas próprias no grupo `HOME` do
  `RunMap.Group`. Ferramenta já existe como achado único (`tool_refine`, primeiro guardião). Já são três moedas e o
  `sistemas.md` 1.2 cortou a quarta de propósito. **Todo recurso novo daqui compete com essa decisão.**
- Saltos de dado próprios já usados: `MAP_SALT` 7411, `ANGEL_SALT` 3307, `Encounter.SALT` 9241, `ENCHANT_SALT` 5813.

## 1. Coleta: física (A), recompensa de sala (B) ou híbrida (C)

### 1.1 Comparação

| Critério | A, física (ponto no chão, aperta usar) | B, recompensa de sala (porta, guardião, drop) | C, híbrida |
|---|---|---|---|
| Ritmo do combate | quebra se valer durante a luta (andar até o ponto com inimigos de pé é armadilha ou trapaça de esconder); neutro se só depois | nenhum impacto | igual à A se a parte física for só depois da sala |
| Tempo da descida | +1 a 4 s por ponto (andar e golpear); 3 pontos dão +3 a 12 s, 1 a 2% de 10 min | zero | +3 a 8 s por descida (meta) |
| Teclado e controle | `interact` já resolve; pede só "parado e perto", como a recompensa | nada novo | `interact` |
| Clareza visual | precisa de um estado novo no chão que não confunda com perigo (âmbar), Morvath (violeta), Emeth (esmeralda) nem aviso (vermelho) | já lida (placa, medalhão) | um estado novo, pequeno |
| Frequência | controlável por nó (dado e semente) | a porta compete com Bênção: cada porta de recurso é uma Bênção a menos | o ponto não ocupa porta |
| Coleta automática | possível ao passar, mas então some a "ação"; o resultado (o que cai) deve ser automático | já é | o que cai, automático |
| Ferramenta | é onde a ferramenta faz sentido (o ponto existe, você vê, mas não abre) | ferramenta numa porta é só um número | ferramenta só na parte física |
| Risco de "simulador de mineração" | alto se houver muitos pontos, vários golpes, inventário ou recurso por toda sala | baixo | baixo se o teto for 1 por sala e 3 por descida |

Leitura crítica:
- **A pura não serve.** O que torna uma sala do Hades II boa é a decisão de posição sob pressão; um ponto de coleta no
  meio da luta ou vira chamariz (o herói vai lá, apanha) ou vira lugar morto. Depois da luta não há tensão nenhuma: a
  coleta física pós-sala é um pequeno ritual de recompensa, não uma decisão. Dizer isso ao Daniel sem enfeite: o valor
  dela é **ver o mundo dar coisas e ver a ferramenta que falta**, não jogabilidade.
- **B pura empobrece as portas.** O `RunMap` já luta para que duas portas mostrem dois grupos (77,8% para 92% com o
  `draw_prefer`). Mais um tipo de recompensa no baralho dilui Bênção e HOME e não mostra ferramenta nenhuma.
- **C é a recomendação**: o recurso **secundário** (de ofício) aparece num ponto físico que **só acorda quando a sala é
  vencida**; os materiais de hoje (Prata, Memória, Esmeralda) seguem como estão (porta, guardião, Morvath). O guardião e
  a recompensa de evento dão componente por drop automático, sem ponto.

### 1.2 Números recomendados (meta, para medir com o robô)

| Regra | Valor | Por quê |
|---|---|---|
| Pontos por sala | **0 ou 1**, nunca 2 | um por sala é um gesto; dois já é tarefa |
| Salas que podem ter ponto | luta comum das profundidades **3 a 9** | a 1 é a abertura, a 2 é a primeira lição de luta; 10 e 11 são loja e Morvath |
| Chance por nó elegível | 20% nas profundidades 3 a 5, 35% nas 6 a 9 | puxa o achado para o fundo: sair cedo rende menos (anti-farming, 3.4) |
| Pontos por rota | esperado **cerca de 1,8**, teto **3**, mínimo **1** no pior caminho (só com uma encomenda ativa, 3.3) | 3 gestos em 10 a 13 min |
| Quando aparece | desenhado desde a entrada como cenário dormente; **acorda no último abate**, junto com a recompensa | ninguém corre para ele com inimigos de pé; lê como "a sala te deu isso" |
| Ação | um aperto de `interact`, parado a até 1,2 m; **1,0 s** de gesto (3 batidas de 0,33 s com a ferramenta, 1 puxada sem ela) | o Hades II pede vários golpes; aqui menos, porque não há tensão a pagar |
| Cancelar | andar ou esquivar corta; o progresso fica por 3 s | nada de começar de novo por um esbarrão |
| O que cai | sai do ponto e vem sozinho ao herói (imã de 2 m, como o ouro); "+1 Pedra Funda" na palavra do `Rooms.found` | só um aperto por ponto, nunca dois |
| Desvio | o ponto fica a no máximo **6 m** da linha entre o relicário da recompensa e a porta mais distante | cerca de 2 s andando; nada de "ir buscar do outro lado da sala" |
| Custo de tempo | **meta**: até 4 s por ponto, até 8 s por descida no robô, até 2% de uma descida de gente | medir com `rooms[].gather_s` (4.2) |
| Coleta automática ao passar | **não** por padrão; opção de Conforto "Coletar ao passar perto" (ligar faz o gesto ao parar a 1,2 m por 0,3 s) | acessibilidade sem tirar a ação de quem quer |

### 1.3 Leitura visual (spec para o art-director e o environment-artist)

Três estados por ponto (forma, tempo e estado meus; aparência deles, como o `RunesLook.set_tile`):
1. **Dormente** (sala com inimigos): cenário; sem fio, sem brilho, sem placa. Lê como pedra, raiz, cera.
2. **Pronto** (sala vencida, ferramenta em mãos ou não pedida): fio de ouro velho fino em volta da peça, o mesmo da
   recompensa, e a placa da tecla pendurada embaixo (`StationSign.under`, verbo "Quebrar", "Colher", "Raspar").
3. **Preso** (pede ferramenta que não se tem): fio cinza-pedra e a placa com o glifo da ferramenta e "Precisa de
   Picareta"; aperta e nada acontece além de anotar no Compêndio (a primeira vez dá a descoberta "Veio preso", 5.1).

Proibido: âmbar (perigo de sala), vermelho (aviso de inimigo), violeta (Morvath), esmeralda (Emeth), coluna de luz. O
ponto nunca fica sobre laje que fere (`RuneFloor`, `PlateFloor`), em boca de porta, a menos de 6 m da entrada nem a menos
de 0,6 m de uma peça que bloqueia (a mesma regra do `ArenaRoom.clear_of_plates`).

### 1.4 Robô e métricas

- O robô coleta se o ponto está pronto e o desvio cabe na regra de 6 m (`Rooms.usable` estendido para `use_kind`
  `gather`). Sem isso a régua do equilíbrio mede uma descida que gente não joga.
- `RESULT`: `rooms[].gather` (`res`, `tool`, `got`, `locked`, `gather_s` = do acordar até o último item recolhido) e
  `gathered` por recurso. Aceite: robô com mediana de chegada a Morvath **no máximo 8 s** acima da régua de hoje (233 s).

## 2. Identidade econômica por bioma real

Princípio: cada arena tem **no máximo um** recurso secundário, tirado do que a arte já mostra (nada de peça nova só para
justificar o recurso), e o recurso conversa com a ideia de jogo da sala quando dá. Nada de osso, corpo nem túmulo aberto
como recurso: o tom é de aventura e a cripta é de mortos cristãos de Valmor (alegoria de Elun). Nada da Lâmpada, do leão
nem do sangue de Hanokh como item (cânone: `canone.md`, "A espinha da história"). Nada de "minério corrompido" nem
"esmeralda" vinda do cenário: os cristais do Jardim são esmeralda corrompido e brigam com a Esmeralda da Emeth.

| Lugar | O que a arte já tem | Recurso secundário (provisório) | Ferramenta | Papel |
|---|---|---|---|---|
| Salão das Catacumbas (abertura, fonte, loja) | velas apagadas (VX-13), potes, balaustradas | **nenhum** | | é o lugar de passagem; a loja é o Mercador da descida |
| Cripta dos Esquecidos (A e B) | metade das velas apagadas, nichos, urnas, coroa de velas (RS-C1) | **Cera Velha** (das velas apagadas dos nichos) | nenhuma | componente do óleo do Alquimista; comum |
| Salão das Fendas | pedra das profundezas escura nos lábios, lascas penduradas, coluna tombada | **Pedra Funda** (veio escuro no lábio da fenda) | **Picareta** | metal do Forjador e do Artesão; raro |
| Jardim das Raízes Mortas | fungos pálidos (`Masonry.fungus`), musgo, raízes, lago escuro na B | **Fungo Pálido** | nenhuma | ervas do Ervanário; comum |
| Santuário Desmoronado | presbitério com oferendas, colunas quebradas, calcário | nenhum ponto; casa do guardião (abaixo) e de uma descoberta (5.4) | | o guardião dá o componente |
| Ponte dos Condenados | correntes, pilones, ferro | **Ferro de Corrente** (elo partido no pilone) | nenhuma | o metal comum que faz a Picareta |
| Câmara das Runas Instáveis | lajes âmbar, pilares de runa com sulcos | **Pó de Runa** (só nasce de laje que disparou e matou; 5.2) | nenhuma | componente raro de Encanto ou Discernimento; liga ao perigo |
| Provação | estela rachada, veias lilás | **nenhum** | | evento: a decisão já é a carta |
| Altar Esquecido | velas, oferendas | **nenhum** | | evento de troca: um ponto ali dilui a troca |
| Câmara do Selo | selo, leão, porta selada | **nenhum** | | cânone sensível; a vitória já dá Prata, Memória e Esmeralda |
| Guardião Cavaleiro | armadura | drop garantido **Placa Amassada** (2 de Ferro de Corrente, para simplificar: o mesmo recurso) | | ninguém fica sem o metal da Picareta |
| Guardião Ancião | cajado, rito | drop garantido **1 Cera Velha** e 1 Fungo Pálido | | |

Crítica do próprio quadro: são **cinco recursos novos** (Cera, Pedra Funda, Fungo, Ferro, Pó de Runa) sobre três moedas.
É demais para o primeiro capítulo. Recomendo o protótipo com **dois**: **Ferro de Corrente** (comum, sem ferramenta, Ponte e
Cavaleiro) e **Pedra Funda** (raro, com Picareta, Fendas). É o menor laço que prova a ideia "achar, fabricar a ferramenta,
voltar e abrir o que estava preso" (a "Jornada da Primeira Picareta"). Cera e Fungo entram só se o NPC Alquimista ou
Ervanário for aprovado; Pó de Runa só depois que as Runas forem um perigo de verdade (RP-03 em medição).

Problema de exposição (medido, `rooms_progression.md` 2.3): Cripta, Fendas e Jardim caem 74% das vezes nas salas 2 a 4;
Ponte e Runas só de 5 a 9. Com a regra "pontos só da profundidade 3", a Pedra Funda das Fendas aparece pouco e cedo. Duas
saídas, escolher uma: (a) as Fendas também com ponto na profundidade 2 só para o recurso raro; (b) melhor, deixar como
está e pôr a Pedra Funda **também nas Runas** (pilar de runa, mesmo veio), que caem de 5 a 9. Recomendo (b).

## 3. Distribuição pela semente

### 3.1 Dado

- Sal próprio `GATHER_SALT` (proposto 6947; nenhum script usa esse número hoje): `RandomNumberGenerator` com `hash([map_seed,
  GATHER_SALT])`, criado **depois** que o grafo e as arenas estão prontos e conferidos (`_keeps_rules`), percorrendo os
  nós em ordem de `id`. O dado do mapa, dos anjos, dos encantos e das lutas não muda: mesma `--seed`, mesmo mapa e mesmo
  `RESULT` com a camada desligada. Teste: 1000 sementes com e sem a camada, grafo idêntico.
- Cada nó ganha `gather` (`res`, `tool`, `amount`, `spot`) ou nada. O lugar exato vem de uma lista de pontos possíveis da
  arena e variante no dado (`RoomLayout.gather_spots`, como `spawns`), sorteado no mesmo dado.

### 3.2 Elegibilidade, raridade e quantidade

- Elegível: nó `COMBAT` não `hidden`, profundidade 3 a 9, arena com recurso na tabela 2 e com `gather_spots` válidos.
  Nunca guardião (tem o drop), evento, fonte, loja, Morvath.
- Recurso de ferramenta (Pedra Funda): no máximo 1 por rota. Comum: no máximo 2 por rota. Teto da rota 3, contado por
  programação dinâmica sobre as rotas como o `uses` das arenas.
- Quantidade: 1; 2 com 15% desde a profundidade 6. Pedra Funda sempre 1.
- Peso no grupo `HOME`: um nó cuja recompensa é Prata ou Memória recebe ponto com metade da chance. Senão a porta HOME com
  ponto vira a escolha óbvia de quem está jogando para o hub.

### 3.3 Garantias mínimas (pior caminho)

- `gather_min(res)`: o menor número de pontos de `res` em qualquer rota do nó atual à loja (o molde do `fights_left`).
- **Só com uma encomenda ativa** que pede `res`: se `gather_min(res)` dá 0 na geração, o gerador troca o nó elegível da
  camada mais estreita (menos salas) para `res`. Sem encomenda, nenhuma garantia: garantir sempre torna a rota previsível.
- Ferramenta nunca é garantida por ponto: a Picareta vem da oficina (Ferro + Prata), e o Ferro tem duas fontes que não
  dependem dela (Ponte e Cavaleiro) mais a loja do Mercador do hub como terceira (ver outros arquivos da pasta).

### 3.4 Farming e softlock

- **Farming por sair cedo**: com a chance subindo com a profundidade, a esperança é cerca de 0,6 ponto nas salas 3 a 5 e
  1,2 nas 6 a 9. Sair depois da sala 4 (cerca de 3 min de gente) rende uns 0,4; a descida inteira (10 a 13 min) uns 1,8.
  A taxa por minuto fica igual ou menor saindo cedo: sair cedo não compensa. **Meta**, medir com `--materials-keep`.
- Teto no save por recurso secundário (proposta: 20; Pedra Funda 10). Achado acima do teto vira 2 de Prata na hora, com
  a palavra "+2 Prata" (nada se perde, nada acumula).
- Sem renovar o mapa: a semente é da partida, o jogador não escolhe; refazer a mesma semente só existe em ferramenta.
- **Softlock**: nenhuma receita pede recurso que só se colhe com a ferramenta que essa receita faz; nenhuma ferramenta
  é pedida para andar, abrir porta, pegar recompensa ou vencer sala; ponto preso nunca tranca nada além dele mesmo.
  Grafo de receitas conferido sem ciclo por teste (como os `requires` dos Dons).
- **Saída livre**: o ponto é peça sem colisão nova ou com colisão que já existe no dado (veio no lábio, que é borda; elo
  no pilone, que já bloqueia). Testar como o `test_boss_exits.gd`: 12 x 12 posições, nenhuma sem saída andando, e o
  `NavGrid`/`FlowField` iguais com e sem o ponto.

## 4. O mapa e a placa

### 4.1 O que mostrar

- Recurso secundário é **ortogonal** ao grupo da porta: a porta continua dizendo POWER, BODY ou HOME pela recompensa; o
  ponto é um sinal pequeno a mais, na segunda linha da `DoorSign` (onde já vai o pictograma da sala), à direita do
  "Difícil". Um sinal só por porta, nunca dois.
- **Só o que já foi visto**: o sinal só aparece para recurso que o jogador já colheu ou viu preso uma vez (Compêndio).
  Antes disso, nada. A primeira vez é surpresa no chão, não promessa na placa.
- **Neblina de duas camadas** no `MapScreen`: o sinal aparece nos nós das portas abertas e da camada seguinte; mais longe,
  nada. Assim dá para planejar um passo, não otimizar a rota inteira (o problema do "previsível").
- Ferramenta pedida: o mesmo sinal com o glifo da ferramenta cortado por um traço quando ela falta (nada de cadeado, que já
  é do Dom trancado). Com a ferramenta, só o sinal do recurso.
- Nó `hidden` ("?" da Provação) não mostra sinal até revelar.
- Sem números no mapa ("+1"): só o tipo. A quantidade é surpresa pequena.

### 4.2 O que o `RunMap.view()` e o registro ganham

- No nó: `gather` (`res`, `tool`) e `gather_seen` (se o sinal pode aparecer). `door_info` com `gather`.
- `RESULT`: `map` com o recurso por nó; evento `door` com `gather` oferecido; `rooms[].gather` (1.4).

## 5. Cinco descobertas que puxam a voltar a uma região

### 5.1 O Veio Preso das Fendas (e das Runas)
- **Problema**: o jogador não tem motivo para preferir uma arena; todas são "mais uma luta".
- **Funcionamento**: na primeira vez que vê a Pedra Funda sem Picareta, o ponto fica preso e o Compêndio anota "Veio
  preso" com a região. Feita a Picareta (Ferro e Prata, no Artesão ou no Forjador), o sinal no mapa passa a valer e o veio
  abre: a primeira Pedra Funda dá uma descoberta do Compêndio e destrava a receita que a pede.
- **Sistemas**: `RunMap` (sinal), `Rooms.usable`, Compêndio, oficina do hub, Forja.
- **Diversão**: "eu vi isso antes e agora posso". É o laço do Hades II das ferramentas de coleta, em pequeno.
- **Custo**: médio (ponto com três estados, ferramenta no save, receita). Arte: veio no lábio e pilar das Runas.
- **Rejogabilidade**: alta nas 3 a 6 primeiras descidas; depois vira rotina.
- **Dependências**: Ferro de Corrente, oficina aprovada.
- **Riscos**: a Pedra Funda aparecer pouco (exposição das Fendas, 2); resolver pondo nas Runas.
- **Recomendação**: **fazer**; é o núcleo do protótipo.

### 5.2 O Pó das Runas (o perigo vira recurso)
- **Problema**: as Runas são "arma de graça" (121 de dano nos inimigos contra 0,7 no herói por sala, medido) e ninguém
  usa o perigo de propósito.
- **Funcionamento**: laje que disparou e **matou** um inimigo deixa, depois da sala vencida, um punhado de Pó de Runa no
  ladrilho (até 2 por sala). Colhido com `interact`, sem ferramenta. Só nas Runas.
- **Sistemas**: `ArenaHazard` (`kills` por ladrilho, já contados no `rooms[].hazard`), `RuneFloor`, ponto de coleta.
- **Diversão**: pede posição durante a luta (puxar inimigos para a laje armando), que é a decisão que a sala quer.
- **Custo**: baixo depois do 5.1 (o ponto já existe; só nasce de um evento).
- **Rejogabilidade**: média; cria objetivo próprio na sala.
- **Dependências**: um uso do Pó (Encanto ou Discernimento); RP-03 medido.
- **Riscos**: o robô não sabe puxar inimigos para a laje: a métrica mostrará pouco Pó. Pode empurrar gente a arriscar
  ficar perto das lajes (o que é bom, se o aviso de 1,2 s segura).
- **Recomendação**: **fazer depois do protótipo**; é a melhor ligação entre coleta e jogo de sala.

### 5.3 O Decalque da Laje do Leão (Cripta)
- **Problema**: as lajes tumulares com o leão (SW-C1) são só arte.
- **Funcionamento**: com uma ferramenta de papel e carvão (Estojo de Decalque, provisório, feito de Cera Velha), a laje
  com o leão de uma sala vencida da Cripta dá uma vez um decalque; cada decalque diferente (há poucas variações por sala)
  completa uma página no Compêndio. Sem dano, sem poder.
- **Sistemas**: `CryptLook` (lajes `GRAVE` com leão já no dado), Compêndio, Livro de Ahk.
- **Diversão**: colecionar; lê o mundo.
- **Custo**: médio, quase tudo texto.
- **Rejogabilidade**: baixa a média.
- **Dependências**: **texto das inscrições é lore**: só com o Daniel (leão e paladinos são cânone).
- **Riscos**: tom (mexer em túmulo); inventar lore.
- **Recomendação**: **segurar** até o Daniel decidir o que as lajes dizem.

### 5.4 A Estante do Presbitério (Santuário)
- **Problema**: o Santuário é só a casa do guardião.
- **Funcionamento**: vencer o guardião **no Santuário** (não em outra arena) faz uma estante do presbitério se abrir
  uma vez por descida: um manuscrito que conta para um Dom (Discernimento no Livro de Ahk, a seção de outro agente).
- **Sistemas**: `RoomLayout.guardian_home`, `Rooms._room_cleared`, Livro de Ahk, Compêndio.
- **Diversão**: dá razão para escolher a porta "Guardião" que cai no Santuário.
- **Custo**: baixo no jogo, alto no texto.
- **Rejogabilidade**: média.
- **Dependências**: o que é o manuscrito (cópia do Livro Sagrado de Yah numa igreja de Valmor é plausível no cânone, mas
  é decisão do Daniel); Ahk não muda sem ele.
- **Riscos**: o guardião vai ao Santuário em quase toda descida (`guardian_home`), então vira garantido; limitar a um
  manuscrito por descida e a uma lista finita.
- **Recomendação**: **fazer se o Livro ganhar manuscritos**; senão não.

### 5.5 A Ponte Partida (variante como achado)
- **Problema**: as variantes A e B são sorteadas e ninguém nota.
- **Funcionamento**: só na Ponte B, o patamar tem um elo de corrente grosso preso no pilone: dá 3 de Ferro de uma vez
  (contra 1 na A). Mostrado no mapa só depois de visto uma vez.
- **Sistemas**: `ArenaVariant`, ponto de coleta.
- **Diversão**: pouca; é uma variação de quantidade.
- **Custo**: baixíssimo (dado).
- **Rejogabilidade**: baixa.
- **Dependências**: nenhuma além do ponto.
- **Riscos**: tornar a Ponte B a porta óbvia para quem quer Ferro.
- **Recomendação**: **não fazer como descoberta**; vale só como regra de quantidade. Fica para mostrar que nem toda ideia
  de revisita é boa.

## 6. Recomendação final

1. **Híbrido C**: recurso secundário só em ponto físico que acorda com a sala vencida; Prata, Memória e Esmeralda como
   hoje. 0 ou 1 ponto por sala de luta da 3 à 9, cerca de 1,8 por descida, teto 3, 1 s de gesto, desvio até 6 m, meta de
   no máximo 8 s a mais por descida no robô.
2. **Dois recursos no protótipo** (Ferro de Corrente comum, Pedra Funda com Picareta, nas Fendas e Runas); os outros três
   só com NPC aprovado.
3. **Sal próprio**, gerado depois do grafo; garantia de pior caminho só com encomenda ativa; teto no save com troca por
   Prata; nenhuma ferramenta tranca progresso.
4. **Mapa**: um sinal na segunda linha da placa, só de recurso já visto, só nas duas próximas camadas.
5. **Descobertas**: 5.1 agora, 5.2 depois, 5.3 e 5.4 dependem de lore do Daniel, 5.5 não.

Riscos principais: mais moedas que o `sistemas.md` aceitou (a decisão do corte da Brasa vale aqui também); coleta pós-sala
sem tensão vira rotina em poucas descidas (medir com gente se o gesto é pulado); exposição desigual das arenas por
profundidade; tudo que fala de túmulo, leão ou manuscrito passa pelo Daniel.
