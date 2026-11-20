# Ofícios e Descobertas: propostas (crítica ao pedido incluída)

- 2026-11-20, `game-director`. Só planejamento. Legenda no `README.md`.
- O pedido (seção 14) pede 5 interações, 5 cadeias, 5 descobertas de revisita, 3 fontes alternativas, 3 anti-grind, 3
  horizontais e 3 riscos. Cada uma traz: **P** problema, **F** funcionamento, **S** sistemas, **D** diversão, **C**
  custo (P, M, G), **R** rejogabilidade, **Dep** dependências, **Ri** riscos, **Rec** recomendação (implementar,
  testar, descartar).
- "Implementar" = entra no roteiro recomendado. "Testar" = protótipo ou medição antes de decidir. "Descartar" = não
  agora, com o motivo.

## 0. O que do pedido do Daniel não funciona como está

| Ideia do pedido | Por que não funciona assim | O que é melhor |
|---|---|---|
| Óleo do Alquimista que o Forjador usa | NPC e estação novos (custo G de várias frentes) para uma relação que dois NPCs que já existem fazem; o óleo seria consumível de combate (Bênção fabricada, proibido pelo próprio pedido) | a encomenda do Vendedor pede o que só a ferramenta do Forjador colhe (C2) |
| Recurso por região (minério, ervas, madeira, óleo...) | 5 a 6 contáveis sobre 3 moedas viram planilha; madeira não existe no bioma; a Q-RJ2 a cortou a 4ª moeda | uma região se distingue pelo que **esconde** (veio, achado marcado), não por uma moeda própria |
| Manuscritos ligados aos Dons | terceiro portão dos Dons (contra D-57); o que é um manuscrito é cânone (Ahk) | manuscrito como pista e Compêndio, se o Daniel definir o que ele é |
| Guardião dos Manuscritos (NPC) | duplicaria a estação do Livro e criaria lore sobre Ahk | o próprio Livro é o guardião |
| Coleta física como sistema | durante a luta é armadilha, depois dela é rotina sem decisão; "simulador de mineração" com mais de um ponto por sala | um veio por descida, um aperto, depois da luta, só onde a ferramenta faz diferença |
| Artesão separado do Forjador | divide a mesma Prata em duas estações sem decisão nova | aba Oficina no Forjador |
| Primeira Picareta de madeira e ferro | cria duas moedas e o risco de ciclo | Picareta achada partida e restaurada (`15_prototipo.md`) |
| Mercador | já é o Vendedor (D-H1) | o Vendedor abre pela encomenda |

O que do pedido funciona muito bem e entra: ferramentas que abrem possibilidades, relação entre NPCs pelo produto, o
mapa mostrando oportunidade, garantias contra sorte ruim, progressão horizontal, Livro e Compêndio como consulta, a
Jornada da Primeira Picareta (revista).

## 1. Cinco interações entre sistemas

**I1. Veio e ferramenta (Salas, Forja, Mapa)**
P: as arenas são "mais uma luta"; a ferramenta do Refinar é invisível antes de achada. F: o veio aparece preso, anota no
Livro; restaurada a Picareta, ele dá Pedra Funda. S: `RunMap`, `Rooms.usable`, `Forge`, Livro. D: "vi antes, agora
posso". C: M. R: alta nas 3 a 6 primeiras descidas, depois rotina pequena. Dep: OF-01, OF-07, OF-08. Ri: virar rotina
(medir se gente pula o veio). **Rec: implementar (A).**

**I2. Provação e Inscrever (Provação, Forja, Encantos, Esmeralda)**
P: a Provação só dá a Bênção; a Esmeralda não tem gasto. F: a 1ª Provação vencida dá a ferramenta do Inscritor partida;
restaurar pede Esmeralda; Encantos 4 a 6 entram no sorteio. S: `Trials`, `Forge`, `Enchants`. D: risco com prêmio
duradouro. C: M (mais os Encantos novos). R: alta (Encantos novos). Dep: Encantos 4 a 6 desenhados. Ri: Encanto fraco
ou dominante. **Rec: implementar (B).**

**I3. Obra e mapa (Vendedor, Mapa, Anjos)**
P: a escolha da porta é curta de informação. F: a Obra 1 mostra o anjo das salas de Bênção da camada seguinte. S:
`RunMap`, `MapScreen`, `Encounters`. D: planejar um passo a mais. C: P. R: média. Dep: C2. Ri: prever demais tira a
surpresa; ficar em uma camada. **Rec: implementar (A).**

**I4. Juramentos e Despertar (Juramentos, Esmeralda, Forja)**
P: o Peso só dá XP. F: recorde de Peso dá Esmeralda (já documentado), que paga o Despertar. S: `Juramentos`, `Forge`.
D: o fim de jogo alimenta a lâmina. C: P. R: alta para quem joga Juramentos. Dep: C5. Ri: Esmeralda demais; um por
patamar. **Rec: implementar (B).**

**I5. Runas e coleta (Perigo de sala, coleta)**
P: as Runas ferem mais os inimigos que o herói e ninguém as usa de propósito. F: laje que mata deixa Pó de Runa. S:
`ArenaHazard`, `RuneFloor`. D: posição na luta vira recompensa. C: P depois do veio. R: média. Dep: um uso do Pó (não há
no A nem no B); RP-03 medido. Ri: 5º contável; o robô não sabe puxar inimigos. **Rec: testar no C** (é a melhor ligação
entre coleta e luta, mas não tem uso sem NPC novo).

## 2. Cinco cadeias

Detalhadas em `07_npcs_e_encomendas.md` 3.

| Cadeia | P | F | S | D | C | R | Dep | Ri | Rec |
|---|---|---|---|---|---|---|---|---|---|
| C1 Primeira Picareta | ferramenta sem história | ver, achar, restaurar | mapa, sala, Forja, Livro | descoberta e escolha de Prata | M | alta no começo | fundação OF-01 a OF-04 | cabeça que nunca cai (piedade) | **implementar (A)** |
| C2 Balcão do Vendedor | Vendedor vazio | 2 Pedra e 30 Prata abrem as Obras | Vendedor, mapa | o hub cresce pelo que eu trouxe | M | média | C1 | Pedra pouca (medir) | **implementar (A)** |
| C3 Obras 2 e 3 | Prata sem gasto no meio | regras de porta | Vendedor, `RunMap` | variedade de descida | P | média | C2 | Obra que vira obrigatória | **implementar (B)** |
| C4 Inscritor | Esmeralda sem gasto, Encantos fixos | Provação dá ferramenta; Inscrever | Forja, Encantos | sorteio maior | M a G | alta | Encantos 4 a 6 | Encanto ruim | **implementar (B)** |
| C5 Despertar | Esmeralda; lâmina igual sempre | fase 3 dá ferramenta; uma propriedade por vez | Forja, combate | a Emeth muda o jeito | G | alta | combat-feel | força escondida | **testar (B, depois de C1 a C4)** |

## 3. Cinco descobertas que puxam a voltar a uma região

**R1. Veio preso (Fendas e Runas)**: P: nenhuma razão para preferir uma arena. F: preso até a Picareta. S: sala, Livro,
mapa. D: volta com a ferramenta. C: M. R: alta no começo. Dep: C1. Ri: exposição das Fendas (74% nas salas 2 a 4) e o veio
só depois do guardião: por isso também nas Runas. **Rec: implementar (A).**

**R2. Estante do presbitério (Santuário)**: P: o Santuário é só a casa do guardião. F: vencer o guardião ali dá um
manuscrito, uma vez por descida, 3 no capítulo. S: `guardian_home`, Livro. D: razão para a porta do guardião. C: P no
jogo, M no texto. R: média. Dep: cânone do manuscrito. Ri: lore inventada; quase sempre garantido. **Rec: testar (B),
só com Q-OF8 aprovada.**

**R3. Decalque da laje do leão (Cripta)**: P: as lajes tumulares são só arte. F: decalque com cera. S: `CryptLook`,
Compêndio. D: colecionar. C: M. R: baixa. Dep: o texto das lajes. Ri: o leão é [CÂNONE] (Hanokh e Elun), mexer em túmulo
muda o tom. **Rec: descartar.**

**R4. Ponte partida (Ponte B)**: P: variantes não se notam. F: Ponte B dá mais. S: `ArenaVariant`. D: pouca. C: P. R:
baixa. Dep: um contável da Ponte (rejeitado). Ri: porta óbvia. **Rec: descartar** (o próprio room-designer concorda).

**R5. A pedra quieta das Runas B, lida pelo Inscritor**: P: a laje quieta é só regra de perigo. F: com a ferramenta do
Inscritor, a primeira vez que se vence as Runas B ela revela uma linha do Compêndio e a pista de um Encanto ainda não
inscrito (onde ele "foi visto"). S: `RunesLook`, Compêndio, Forja. D: a ferramenta lê o mundo. C: P. R: média. Dep: C4.
Ri: texto que precisa ser neutro. **Rec: testar (B).**

## 4. Três fontes alternativas

**A1. O guardião entrega o achado (piedade)**: P: a sala marcada pode não cair no caminho. F: 2 descidas passando do
guardião sem a cabeça, o guardião a dá. S: `Rooms._room_cleared`, `oficios.pity`. D: nunca fica preso. C: P. R: neutra.
Dep: C1. Ri: virar a fonte comum; contar só descidas que passaram pela sala marcada sem pegar. **Rec: implementar (A).**

**A2. Pedra Funda do Cavaleiro**: P: Fendas e Runas podem faltar. F: com a Picareta, o guardião Cavaleiro deixa cair 1 Pedra
Funda (só o achado, sem explicar de onde: explicar seria lore). S: drop do guardião. D: pouca. C: P. R:
baixa. Dep: C1. Ri: guardião sempre dá virar a fonte principal. **Rec: testar** (só se a medida E1 mostrar Pedra pouca).

**A3. Troca com perda no Vendedor**: P: sobra Prata no fim, falta Pedra. F: Obra "balança": 15 Prata por 1 Pedra Funda,
uma vez por volta ao hub. S: Vendedor. D: pouca, alivia. C: P. R: baixa. Dep: C2. Ri: troca que dá lucro ou laço de
farming; nunca o contrário (Pedra por Prata acima do teto já existe). **Rec: testar no fim do B.**

## 5. Três anti-grind

**G1. Portas de material mais fundas**: P: farming medido (porta de Memória na sala 2 e sair: 3 a 3,5 vezes a taxa). F:
Prata desde a profundidade 4; Memória depois da camada do guardião. S: `_stage`, `RunMap.settle`. D: a escolha "agora
ou depois" vem no meio da descida. C: P. R: neutra. Dep: nenhuma. Ri: Memória mais lenta no começo (D-57): medir os
Dons abertos nas 10 primeiras descidas. **Rec: implementar (já, OF-05).**

**G2. Objetivo fixado e "onde achar" em toda falta**: P: decorar qual bioma tem o quê. F: um objetivo fixado, marca no
mapa, contagem na saudação; toda falta diz onde achar. S: Livro, mapa, `EloBanner`. D: menos atrito. C: M. R: neutra.
Dep: capítulo Ofícios. Ri: o mapa poluído; um objetivo só. **Rec: implementar (B; o "onde achar" já no A).**

**G3. A porta de material muda quando não há onde gastar**: P: renda morta depois de tudo comprado. F: sem gasto
pendente, a porta de Prata vira ouro ou Bênção (`RunMap.settle`). S: `RunMap`, save. D: a escolha nunca é falsa. C: P.
R: positiva no fim. Dep: saber "gasto pendente" pelo catálogo. Ri: o jogador não entender por que a porta sumiu; a
página da Forja diz "Tudo forjado". **Rec: implementar (B).**

## 6. Três horizontais

**H1. Prévia dos anjos (Obra 1)**: informação, uma camada a mais. C: P. **Rec: implementar (A).**
**H2. Inscrever (Encantos no sorteio)**: variedade sem força; o pool decide o que pode vir. C: M. **Rec: implementar (B).**
**H3. Despertar como troca**: uma propriedade ativa, troca grátis; nenhuma soma. C: G. **Rec: testar (B)**, aceite de
força dentro do ruído (`20_metricas.md`).

Para todos: P (problema comum) a Forja já usa quase todo o espaço vertical (+4 a +9 pontos de vitória). D: escolha.
Ri: uma horizontal mal medida vira vertical (a Obra que dá a 2ª romã na loja foi **descartada** por isso).

## 7. Três riscos (de produto)

**K1. Planilha e simulador**: mais de 8 coisas no capítulo, coleta repetida, hub demorado. Mitigação: orçamento de
`02_visao_e_grafo.md` 5, menos de 10 s de coleta, 90 s no hub. Rec: medir E2 e E6 em toda entrega.
**K2. Força escondida**: Obras, Despertar ou Encantos somando vitória além da Forja. Mitigação: teto de +5 pontos para
todos os ofícios juntos (alvo 0). Rec: 32 sementes r45 em todo marco.
**K3. Lore inventada**: manuscrito, nome, NPC, símbolo. Mitigação: nomes de trabalho, voz neutra, perguntas Q-OF5,
Q-OF8, Q-OF9, Q-OF10. Rec: nada de texto com Ahk ou com o leão sem o Daniel.

Detalhe de todos os riscos em `21_riscos.md`.
