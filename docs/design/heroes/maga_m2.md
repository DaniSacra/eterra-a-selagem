# A Maga, M2: Maestria, Dons, segunda ultimate e Bênçãos por botão (proposta no papel)

- **Data**: 2026-11-23. **Autor**: `hero-designer`. **Estado**: implementada em 2026-11-23 seguindo as recomendações do próprio plano (ver `docs/reference/meta.md`, "A Maga, M2"); o Daniel ainda não testou. Faltam as Bênçãos de escudo e cura do domo e a tela da árvore em triângulo. Continua `maga.md` (v2, seções 1 a 15)
  e segue o molde de `guerreiro.md` e de `docs/reference/meta.md` (HeroDef, Maestria, Dons, ultimates).
- **Ponto de partida (números de hoje, depois do equilíbrio de 2026-11-23)**: tiros 10/10/15 (a cadeia dá 35 em ~0,95 s), Selo vive 8 s e cabe 1 por
  inimigo, Explosão Rúnica 32 + 44 por Selo (raio 3,2 m, 10 de Magia), amplificada x1,5 e raio 4,5 m sem custo, Círculo 3,2 m por 4 s (recarga 10 s),
  Suspensão 2,6 m por 2,5 s (recarga 14 s), Passo 4,5 m com 2 cargas, Tempestade 6 m por 4 s (8 por 0,5 s e 110 de detonação), vida 30, Magia 50.
- **Regras que valem aqui**: nomes e textos de jogador abaixo são proposta (vão para `data/text_pt.tres` só depois do aval); paleta âmbar e marfim (violeta é
  de Morvath, as imagens do pacote com roxo não valem); "Selo" é a marca dela e "Marca" é do anjo Qeshael; **nenhum lore novo** (origem: norte do mundo,
  estudiosa, e nada além); gelo é só ramo secundário futuro (M3), então até lá o frio vem das Bênçãos de Nivael.
- **Legenda de custo de código**: **D** = só dado (estatística, tag e comportamento que já existem); **L** = estatística nova que `Arcane` ou `Combat` passam a
  ler (cerca de uma linha por estatística, mais teste; **P**); **N** = comportamento novo (**M**).

## 1. Maestria da Maga

Mesma estrutura do Guerreiro (`MasteryCurve`, `core/mastery.gd`): **20 níveis**, do nível n para o n+1 custam `40 + 10 (n - 1)` de XP (2470 no todo), **Devoção
(pontos para equipar Dons) = 5 + nível** (11 no nível 6, 25 no nível 20), XP por sala de luta 10, guardião 25, fase de Morvath alcançada 10 (até 40),
vitória 50, primeiras vezes (Bênção vista 2, Elo 10, Salmo 25, guardião 25, vitória 100). Cada Dom abre com **Memória** igual ao seu custo (o do nível 1 vem
aberto), como no Guerreiro. A Maestria é **por herói** (`heroes.maga` no save, que já existe); a Maga começa no nível 0, sem o retroativo.

- **Dado**: hoje a Maga lê o `warrior_mastery.tres`. M2 gera `maga_mastery.tres` (cópia dos mesmos números, parte `mastery`, só dado) para os dois poderem divergir
  no equilíbrio sem tocar um no outro. O XP por "primeira vez" soma ao Compêndio dela (Selo detonado pela primeira vez entra como primeira vez nova: **L**, P).
- **Tempo para o 20**: igual ao Guerreiro (2470 XP, cerca de 25 partidas completas). Nada de curva própria na primeira versão.

### 1.1 O que abre em cada nível

A ordem segue a do Guerreiro: **o que transforma um botão vem primeiro**, as pontes no meio, os ápices no fim (dois no 20 no Guerreiro; aqui um por ramo
nos níveis 16, 18 e 20, porque são três ramos). Os dois níveis das ultimates são os mesmos do kit (2 e 6).

| Nível | Devoção | Abre | Tipo |
|---|---|---|---|
| 1 | 6 | **Brasa Viva** (Dom aberto, Memória 0) | Piromancia, entrada |
| 2 | 7 | **Tempestade dos Selos** (ultimate 1) e **Eco Arcano** | ultimate; Arcanismo, entrada |
| 3 | 8 | **Círculo Expandido** | Controle, entrada |
| 4 | 9 | **Cadeia Curta** | Arcanismo, meio (ataque) |
| 5 | 10 | **Pavio Longo** | Piromancia, meio (ataque) |
| 6 | 11 | **Segunda ultimate** (seção 3) e **Prisão Sigilada** | ultimate; Controle, meio (Q) |
| 7 | 12 | **Combustão** | Piromancia, meio (direito) |
| 8 | 13 | **Selo Duplo** | Arcanismo, meio |
| 9 | 14 | **Suspensão Larga** | Controle, meio (E) |
| 10 | 15 | **Firmeza** | sustento |
| 11 | 16 | **Chama que Marca** | ponte Piromancia e Arcanismo |
| 12 | 17 | **Selo no Chão** e **Reserva** | ponte Arcanismo e Controle; sustento |
| 13 | 18 | **Brasa que Prende** e **Respiro** | ponte Piromancia e Controle; sustento |
| 14 | 19 | **Leitura Rápida** | ponte Arcanismo e Controle |
| 15 | 20 | **Passo de Brasa** | ponte Piromancia e Controle (Passo) |
| 16 | 21 | **Inferno Rúnico** | Piromancia, ápice |
| 17 | 22 | **Ainda de Pé** e **Passo Longo** | sustento |
| 18 | 23 | **Ruptura** | Arcanismo, ápice |
| 19 | 24 | **Brasa Gêmea** | ponte Piromancia e Arcanismo |
| 20 | 25 | **Contenção Perfeita** | Controle, ápice |

**Total: 23 Dons**, o mesmo número do Guerreiro (19 da árvore e 4 do C2). Custo somado **67 de Devoção** contra 68 do Guerreiro: ninguém equipa tudo
(com 25 de Devoção cabe cerca de um terço), então a escolha de montagem existe desde o nível 6.

## 2. Dons: árvore, números e o que muda de verdade

### 2.1 Regras da árvore (iguais às do Guerreiro)
- **Entrada** pede só o centro (a passiva, sempre ligada); **meio** pede a entrada do ramo; **ápice** pede o meio do ramo mais **um Dom do ramo vizinho**;
  **ponte** pede as entradas dos dois ramos que une; **um Dom por ação** (`slot`); pré-requisito só vale equipado (`Talents`).
- **Custos**: entrada 2, meio 2 a 3, ápice 4, ponte 3, sustento 2, 3 e 5; os mesmos faixas do Guerreiro.
- **Três ramos formam um triângulo**: todos são vizinhos de todos (no Guerreiro eram quatro em losango). Então qualquer ápice aceita Dom de qualquer outro ramo
  como parceiro; fixei **Inferno Rúnico com Arcanismo, Ruptura com Controle, Contenção Perfeita com Piromancia** (ciclo, para as três escolhas se cruzarem).
- **Slots**: ataque (esquerdo), especial (direito), Q (`CAST`), E (`RUSH`, a Suspensão), Passo (`DASH`). Dois Dons no mesmo botão se excluem, e isso é de
  propósito: **Cadeia Curta ou Pavio Longo** no ataque.
- **Sem código para estes**: cada efeito é uma estatística dos `mods` (`BoonState.stat`, com tag do golpe). Os tipos L estão marcados; **só o Selo Duplo e a
  Ruptura pedem N** (seção 2.6).

### 2.2 Piromancia (dano, queimadura, explosão)

| Dom | Camada, custo, nível | Efeito e números | O que muda de verdade | Tipo |
|---|---|---|---|---|
| **Brasa Viva** | entrada, 2, nível 1 | O Selo detonado deixa **3 s de queimadura de 4 por segundo** no alvo e em quem está a 1,5 m. | A Explosão passa a valer depois do clarão: o grupo queima enquanto ela recua. Dá dano em chefe também (sem o bônus do Selo). | L (`seal_burn`, `seal_burn_time`) |
| **Pavio Longo** | meio, 2, nível 5, **ataque** | Os tiros queimam: 2 por segundo por 2 s; o 3º, 5 por segundo por 3 s. | O ataque deixa de ser só "marcar": vira dano em fio, que ajuda sem Selo (a Maga sem preparo é mais fraca; aqui ela se vira). Exclui Cadeia Curta. | **D** (`burn_dps`, tag `light`) |
| **Combustão** | meio, 3, nível 7, **direito** | A Explosão queima quem o Selo não pegou (4 por segundo, 3 s) e o raio cresce 25% (3,2 vira 4,0 m). | A Explosão cobre mais gente com menos preparo: sem Selo ela já limpa o resto do grupo. | **D** (`burn_dps`, tag `heavy`; o raio já lê `cast_size_pct`) |
| **Inferno Rúnico** | ápice, 4, nível 16, parceiro Arcanismo | A Explosão **amplificada** deixa **4 s de brasa no chão**: 10 por segundo em 3,2 m. | O pico do laço passa a controlar espaço por 4 s: a sala "queima" onde ela detonou. | L (gatilho "amplificada" para a brasa; reaproveita `Ground.Zone`) |

### 2.3 Arcanismo (Selos, propagação, eficiência)

| Dom | Camada, custo, nível | Efeito e números | O que muda de verdade | Tipo |
|---|---|---|---|---|
| **Eco Arcano** | entrada, 2, nível 2 | Cada Selo detonado dá **+1 de Magia** (2 por Selo, teto de 6 Selos por Explosão). | A Explosão custa 10 e devolve 6 com 3 Selos (eram 3): quase se paga com 5 Selos. Mais Explosões, mais carga da Tempestade (a carga vem da Magia gasta). | L (`seal_magick`) |
| **Cadeia Curta** | meio, 2, nível 4, **ataque** | O Selo vem no **2º tiro** (já era assim dentro do Círculo) e no **1º** dentro do Círculo; o 3º tiro perde 5 de dano (10). | Marca mais cedo: a cadeia "pega" em 0,5 s em vez de 0,95 s. Em troca, bate menos. Exclui Pavio Longo. | L (`seal_at`) |
| **Selo Duplo** | meio, 3, nível 8 | Um inimigo guarda **2 Selos** (a 3ª cadeia dentro de 8 s põe o segundo). A Explosão consome os dois: o bônus de Selo vira **x1,4** (44 vira 61), dá **2 de Magia** e **2 pontos de Ressonância** de uma vez. | Recompensa insistir no mesmo alvo (elite, guardião): a Ressonância enche com 3 inimigos duplos em vez de 6 simples. | **N** (`SealBook` com teto 2 já previsto em `maga.md` 2.1; falta o 2º Selo e a regra) |
| **Ruptura** | ápice, 4, nível 18, parceiro Controle | O Selo detonado **salta** (1 vez) para o inimigo sem Selo mais próximo, num raio de 4 m, e fica 4 s. | A Explosão "se espalha" sozinha: um grupo grande vira Selos em cadeia e a Ressonância pode encher de outro jeito. | **N** (propagação no momento da detonação) |

### 2.4 Controle e Selos (lentidão, domínio, preparo)

| Dom | Camada, custo, nível | Efeito e números | O que muda de verdade | Tipo |
|---|---|---|---|---|
| **Círculo Expandido** | entrada, 2, nível 3 | O Círculo ganha **+0,8 m de raio** (3,2 vira 4,0 m). | Mais gente presa por conjuração; o puxão de 1,2 m também alcança mais longe. | **D** (`cast_size_pct` 0,25, tag `cast`; o Círculo já lê) |
| **Prisão Sigilada** | meio, 3, nível 6, **Q** | Ao fechar o puxão, os **comuns** ficam **presos no lugar por 0,6 s** (raiz, não atordoa: a regra F8 vale). Elites só a lentidão, guardiões e chefe nada. | O tempo da Explosão: quem está preso não escapa do ponto da mira. | L (`circle_root`; o `Ground.Kind.BIND` já tem raiz) |
| **Suspensão Larga** | meio, 3, nível 9, **E** | A Suspensão cresce **0,8 m de raio** (2,6 vira 3,4 m) e dura **+1 s** (3,5 s). | O domo cobre também quem está do lado dela: vira posição de tiro de verdade, não só um aparo. | L (`dome_size_pct`, `dome_time`) |
| **Contenção Perfeita** | ápice, 4, nível 20, parceiro Piromancia | O Círculo dura **+2 s** (6 s) e o Selo vem no **1º tiro** dentro dele. | Um tiro marca, uma Explosão detona: o laço inteiro em 1 s, do jeito mais direto que ela tem. | L (`circle_time`; `circle_seal_at` 1) |

### 2.5 Pontes (seis, custo 3)

| Dom | Une, nível | Efeito e números | O que muda de verdade | Tipo |
|---|---|---|---|---|
| **Chama que Marca** | Piromancia e Arcanismo, 11 | O **3º tiro** (o que põe o Selo) queima: 5 por segundo por 3 s. | Cada cadeia deixa fogo no alvo marcado, mesmo se a Explosão demorar. | **D** (`burn_dps`, tag `finisher` do 3º tiro) |
| **Brasa Gêmea** | Piromancia e Arcanismo, 19 | A Explosão que detona **3 ou mais Selos** solta uma segunda, **50%** do dano, **0,5 s depois**, no mesmo ponto. | Premia o grupo marcado grande e dá o "estouro duplo"; não gasta Magia nem dá Ressonância. | **N** (disparo atrasado, reaproveita `Combat.cast_burst`) |
| **Selo no Chão** | Arcanismo e Controle, 12 | Ao fechar o puxão, o Círculo aplica **1 Selo a todos** os comuns e elites dentro (já com 3 tiros em 0 s). | A abertura "Círculo, Explosão" sem tiro nenhum: o ritmo vira posicionar e detonar. | L (aplicar `SealBook` no conjurar) |
| **Leitura Rápida** | Arcanismo e Controle, 14 | A recarga do **Círculo** e da **Suspensão** cai 25% (10 s vira 7,5 s; 14 s vira 10,5 s). | Mais domínio de área, menos esperar; o piso `cd_floor` 6 s continua valendo. | **D** (`cooldown_pct` -0,25, tags `cast` e `dome`, como o Fôlego de Guerra) |
| **Brasa que Prende** | Piromancia e Controle, 13 | O Círculo **queima ao fechar**: 12 de dano e 4 por segundo por 3 s em todos dentro. | Dá dano ao Q, que hoje não dá nenhum; combina com o puxão. | L (o Círculo aplica status das Bênçãos e dos Dons; ver 4.2) |
| **Passo de Brasa** | Piromancia e Controle, 15, **Passo** | O Passo solta um **clarão onde ela estava** (12 de dano, 2,2 m, queima 2 s) e deixa brasa no ponto de chegada. | Sair vira dano: o Passo ganha papel ofensivo sem virar spam (gap de 1,5 s). | L (gatilho de esquiva no Passo, ver 4.2) |

### 2.6 Sustento (cinco, fora dos ramos)
**Firmeza** (nível 10, custo 2): +10 de vida e +10 de Magia (igual ao Guerreiro). **Reserva** (12, 3): +20 de Magia máxima. **Respiro** (13, 3): cada sala vencida cura 2.
**Passo Longo** (17, 2): +0,8 m no Passo (4,5 vira 5,3 m). **Ainda de Pé** (17, 5): uma vez por descida levanta com metade da vida, nunca na sala de Morvath.
Todos **D**, salvo Passo Longo (**L**, `blink_pct`).

### 2.7 O que pede N (comportamento novo)
Só dois Dons e meio: **Selo Duplo** (2º Selo e consumo duplo em `SealBook`/`Arcane`, **P a M**), **Ruptura** (propagação no detonar, **P a M**) e **Brasa Gêmea**
(disparo atrasado da Explosão, **P**). Os outros são dado, com cerca de dez estatísticas lidas por `Arcane` (`seal_burn`, `seal_magick`, `seal_at`,
`circle_root`, `circle_time`, `dome_size_pct`, `dome_time`, `blink_pct`, brasa da amplificada, Selo no puxão). **Estimativa de M2 inteira: M** (3 a 4 dias), mais a
tela da árvore em triângulo (seção 6).

### 2.8 Montagens de exemplo (Devoção do nível)
- **Nível 6, Devoção 11 ("a estudiosa")**: Brasa Viva 2, Eco Arcano 2, Círculo Expandido 2, Cadeia Curta 2, Prisão Sigilada 3 = 11. Marca cedo, prende e detona; sem fogo de verdade.
- **Nível 12, Devoção 17 ("a incendiária")**: Brasa Viva 2, Pavio Longo 2, Combustão 3, Eco Arcano 2, Chama que Marca 3, Firmeza 2, Respiro 3 = 17. Menos Selo, mais fogo.
- **Nível 20, Devoção 25 ("a carcereira")**: Círculo Expandido 2, Prisão Sigilada 3, Suspensão Larga 3, Contenção Perfeita 4, Selo no Chão 3, Leitura Rápida 3, Eco Arcano 2, Brasa Viva 2, Firmeza 2 = 24. Prende, marca de graça e detona; quase sem tiros.

## 3. As duas ultimates

Estrutura do Guerreiro: duas `UltDef` em `data/ultimates/maga/`, a primeira abre na **Maestria 2** e a segunda na **Maestria 6**. Carga: Magia gasta, dano causado e vida
perdida (`UltCharge`), com `passive_never` ultimate, igual ao Guerreiro. Regra comum: gesto `ULT` de 0,3 s protegido, esquiva corta o gesto e nunca o efeito já solto.

### 3.1 Primeira: Tempestade dos Selos (já existe)
Área de 6 m no cursor (até 9 m) por 4 s: **todo inimigo** dentro leva 1 Selo no primeiro tique, tiques de 8 a cada 0,5 s e detonação final de **110**; elites 50%,
guardiões 25%, Morvath só os tiques e o Selo. Carga 90. **Papel: fechar a sala** (ela fica fora, o campo no chão faz o trabalho).

### 3.2 Segunda, recomendada: **Suspensão Absoluta** (a "habilidade suprema" do pacote, que virou a E)
- **O que faz**: um domo grande **em volta dela e que anda com ela** (`Ground.Zone.follow`), **5,5 m de raio por 8 s**. Dentro dele: projéteis inimigos de comuns e elites
  **param no ar** e somem no fim; inimigos ficam **50% mais lentos** e os avisos deles andam 50% mais devagar; ela anda a 100%. **O que muda no kit dentro dele**:
  todo tiro que acerta põe **Selo** (não só o 3º), os tiros dão **+30%**, e a Explosão custa **5** de Magia (metade).
- **O que lê na tela**: película marfim com hexágonos dourados e borda âmbar (a mesma da E, maior), o relógio dos 8 s no aro do domo, que pisca nos 2 últimos.
- **Chefe e guardiões**: projéteis do chefe e de guardião **não param** (só ficam 50% mais lentos, como `UltDef.guardian_pull`); Morvath só lentidão.
- **Carga 100** (um pouco mais que a Tempestade, para a segunda pesar), recarga por carga como a primeira; **`Maestria 6`**.
- **Papel**: **segurar posição e atirar**. É a ultimate de quem quer ficar no meio da sala e jogar o laço inteiro (marcar, Círculo, Explosão) sem ser pressionada.
  Contrasta com a Tempestade (fechar a sala de longe) do jeito que a Voragem contrasta com o Corte do Juízo no Guerreiro.
- **Tipo**: **M**. `UltDef.Kind.DOME` novo (domo que segue, reaproveita a E: parar projétil, lentidão, `Ground.Zone.follow`), e ler "dentro do domo" nos tiros e na
  Explosão (**L**: multiplicador e custo por estado, mesmo canal do "dentro do Círculo").

**Alternativa B (se a A parecer defensiva demais)**: **Detonação Geral**, que detona **todos os Selos da sala de uma vez** (140 cada, elites 50%, guardiões 25%) depois de
um gesto de 0,6 s e enche a Ressonância. Mais curta, mais barata em código (**P a M**), mas se parece com o fim da Tempestade, então dá menos escolha. Não recomendo.

### 3.3 Como se escolhe
Igual ao Guerreiro (`HeroDef.ult_for`, `heroes.maga.ultimate` no save): **a tela do herói no Livro mostra as duas** (a segunda trancada com "Maestria 6" até abrir) e a
escolha grava no save na hora; a descida joga a escolhida, e sem escolha joga a primeira que a Maestria abriu. O 5º losango do HUD mostra o glifo da escolhida (Tempestade
112, a segunda um glifo de domo). Nenhum código novo para escolher (só o glifo e o texto). **Dons que mexem nas ultimates**: nenhum direto, como no Guerreiro. Efeitos
indiretos: Selo Duplo faz a Tempestade deixar 2 Selos (detonação x1,4, ver risco), e a Eco Arcano não vale na Tempestade (a regra de `passive_never`).

## 4. As Bênçãos dos 7 anjos nos botões da Maga

As 42 Bênçãos de `bencaos_por_anjo.md` são **compartilhadas** (mesmo texto e número do Guerreiro; mudam de botão como na tabela de `maga.md` seção 4). Esta seção diz **o que cada
uma faz quando é a Maga quem pega** e o custo.

### 4.1 O que o código de hoje já cobre (conferido em `arcane.gd`, `skills.gd` e `game.gd`)
- A Explosão passa por `Combat.hit_enemy` com as tags do golpe (`heavy`, `blast`, `arcane`, `finisher`), então **queimar, congelar, enfraquecer, marcar, empurrar e dano
  percentual** (as Bênçãos de ataque e de especial) **já agem** nela. Os tiros também (`light`, e o 3º `finisher`).
- Os gatilhos de skill saem das tags: `heavy` é o especial, `shout` é o Brado (o Círculo da Maga tem a tag), `finisher` o 3º tiro, e a ultimate dispara no fim do gesto.
- **Lacunas** (nada que um herói sem código novo cubra):
  1. **Q**: o Círculo não dá dano, então a Bênção que "queima, congela, enfraquece, marca, empurra" quem o Círculo atinge não tem onde agir. Precisa de **status das Bênçãos no
     conjurar** (e, no máximo, 1 vez a cada 1 s a quem fica). **M**.
  2. **E**: a Suspensão tem as tags `cast`, `arcane`, `dome`, e nenhuma delas vira gatilho (`dash` é a Investida do Guerreiro). As Bênçãos de E (gatilho `rush`) pedem que `dome` mande o gatilho.
     **P** (uma linha em `Skills.trigger_of`), mais as de **escudo** e **cura** do domo, que são comportamento: **M**.
  3. **Espaço**: o Passo é um teletransporte. O gatilho `dodge` sai do `_on_dodged` do `Game`; é preciso conferir que o Passo o emite (**P**), e o rastro de brasa/poça/flocos
     passa a sair do ponto de partida e do de chegada em vez de um caminho (**P**).
  4. **Leitura de estatística**: `reach_pct` nos tiros (alcance 11 m), `wave_size_pct` na Explosão (hoje lê só `cast_size_pct`) e `push_pct` no puxão do Círculo.
     **L**, uma linha cada, mais teste.
  5. **Skill no ponto da Explosão**: `Skills` solta a skill do especial à frente do herói; para a Maga o certo é o ponto da Explosão (chão em brasa, onda). **P**.

### 4.2 As 7 famílias, botão a botão

Tipo: **D** só dado, **L** leitura de estatística (P), **T** gatilho ou ponto de saída (P), **N** comportamento novo (M). Os textos de jogador ficam os do catálogo.

| Anjo | Atq (Chama Sigilada) | Esp (Explosão Rúnica) | Q (Círculo) | E (Suspensão) | Sh (ultimate) | Espaço (Passo) |
|---|---|---|---|---|---|---|
| **Sarael** (Chama): "continua queimando" | tiros queimam 4/s: **D** | brasa onde a Explosão caiu, 3 s: **T** (ponto da Explosão) | o Círculo queima quem fica: **N** (status no Círculo) | 2 a 4 chamas giram em volta dela por 4 s: **T** (gatilho `dome`) | chuva de 8 a 12 brasas (Tempestade ou Suspensão Absoluta): **D** | rastro de brasa na saída e na chegada: **T** |
| **Nivael** (Geada): "o que para, quebra" | tiro congela 0,3 s, quem está congelado leva +25% da Explosão (estilhaça): **D** | congela no raio: **D** (a onda larga é **L**) | anel de gelo na conjuração: **D** (skill no gatilho `shout`); congelar quem fica: **N** | lâminas de gelo à frente ao abrir o domo: **T** | bloco de gelo no centro (Tempestade): **D**; congela por 2 s mas só 25% nos guardiões | flocos onde aparece: **T** |
| **Lumael** (Luz): "dano limpo, vida de volta" | +25% de dano nos tiros: **D** | +20% de dano e raio: **D** + **L** | 3 a 5 raios nos mais próximos ao conjurar: **D** | cura 1 por inimigo preso ao fim: **N** (a Investida do catálogo vira "domo que cura") | chão aceso 6 s, +40% de dano da ultimate: **D** | clarão onde sai: **T** |
| **Shomael** (Vigília): "um golpe a menos" | +12% de alcance e +10% de dano: **L** + **D** | +15% de alcance e escudo 1,5 s ao lançar: **D** + **L** | chão pesado, +25% de raio, lentidão: **D** | domo abre escudo (absorve 1 golpe): **N** (escudo por botão `rush`) | muralha de 6 a 10 s e +20 de vida máxima: **D** | +1 carga do Passo (3 no total) e +8% de velocidade: **D** |
| **Velael** (Véu): "bate menos quem foi enfraquecido" | enfraquece 2 a 3 s: **D** | enfraquece em raio: **D** (onda larga **L**) | enfraquece todos dentro ao conjurar: **N** (status no Círculo) | névoa onde o domo abriu, 3 s: **T** | enfraquece tudo em 7 a 9 m: **D** | fios de cinza giram 3 s: **T** |
| **Galael** (Maré): "empurrar e bater no que desliza" | +40% de empurrão, quem desliza leva +20%: **D** | onda maior e empurra mais: **D** + **L** | puxa mais 0,6 m: **L** (`push_pct` no puxão) | domo empurra a borda: **T** + **L** | onda de 7 a 9 m com lentidão: **D** | bolhas que atrasam: **T** |
| **Qeshael** (Marca): "um alvo de cada vez" | marca 3 s e o 3º tiro crítico +15%: **D** | marca 4 s e crítico +10%: **D** | marca todos ao conjurar: **N** (status no Círculo) | marca quem entra: **T** | marca e fere 6 a 10: **D** | marca quem está perto: **T** |

**Contagem**: das 42, **cerca de 17 são só dado** (**D**), **cerca de 17 pedem gatilho, ponto de saída ou leitura de estatística** (P, em lote: itens 4.1.2, 4.1.3, 4.1.4 e 4.1.5), e **8
pedem comportamento novo** (todas no Q e no E: status no Círculo e escudo ou cura no domo; **M** no conjunto, um trabalho só, que também serve ao Dom Brasa que Prende e à
Suspensão Absoluta).

### 4.3 Como ficam as famílias que mexem no laço
- **Qeshael (Marca) e o Selo**: ficam compatíveis (um inimigo pode ter Selo e Marca) e a Explosão acerta **crítico em quem tem os dois**: a combinação mais forte, e a que mais precisa
  de medida (seção 5). O texto diz "Marca" e "Selo" em palavras diferentes, como decidido.
- **Nivael e o Selo**: o estilhaço (+25% em quem está congelado) soma com o bônus do Selo (+44): a Maga com Geada deixa de depender de Selo para a Explosão grande. Isso é uma
  escolha (gelo antes do fogo), não um defeito, se o gelo for curto (0,3 s no tiro).
- **Sarael e Brasa Viva**: dois "dano em fio" do mesmo tipo; empilham (as estatísticas somam), e o teto é o do `gain_cap` e o do tempo do status, não um limite novo.
- **Elos entre famílias** (Vapor, Aurora etc.) valem sem mudança (são `requires_sets` das ids).

## 5. Riscos de equilíbrio e o que medir

| Risco | Por quê | O que medir (robô, **12 sementes**, `--seed=N --bot-reaction=0.25`) |
|---|---|---|
| **Selo Duplo e Tempestade** | a Tempestade põe 2 Selos nos quatro segundos e detona com x1,4: 110 vira 154 de detonação, total ~ 218 por alvo (hoje 174) | dano por alvo da Tempestade com e sem o Dom; teto de 154 de detonação ou só 1 Selo na Tempestade se passar de 25% |
| **Eco Arcano com Selo Duplo** | 2 Selos de graça, +2 Magia por Selo, Explosão com 3 inimigos duplos devolve 12 de 10 | Magia média por Explosão; se passar de 100% de retorno cortar `seal_magick_cap` para 4 |
| **Ressonância sem fim com Selo Duplo e Ruptura** | cada Selo é 1 ponto e a Ruptura cria Selos de graça | Explosões amplificadas por sala (alvo: no máximo 1 a cada 3 Explosões normais); teto de pontos por Explosão em 4 |
| **Inferno Rúnico e Combustão** | queimar a sala toda: a Explosão amplificada vira dano de zona de 40/s + 10/s por 4 s | dano médio por sala em salas de horda; comparar com o Guerreiro com Sarael |
| **Suspensão Absoluta** | 8 s de tiros com Selo em todo acerto e Explosão a 5 de Magia | dano em 8 s, mortes por minuto de Morvath com e sem; a vitória do robô no chefe (teto de diferença como no Guerreiro: 25 pontos entre Maestria 1 e 20) |
| **Qeshael + Selo + Explosão** | crítico em quem tem Marca e Selo sobre o 76 da Explosão | dano por Explosão com os dois, chefe e comuns |
| **Prisão Sigilada + Círculo Expandido** | a sala presa 4 s com 0,6 s de raiz: ela nunca é tocada | quanto dano ela leva em salas de corpo a corpo (cai muito?); se cair demais, raiz só 0,4 s |
| **Fraca demais cedo** | níveis 1 a 5 só têm entradas e o ataque 10/10/15 | taxa de vitória do robô na Maestria 1 contra o Guerreiro na 1 (alvo: dentro de 10 pontos); Brasa Viva e Cadeia Curta são o piso |
| **Passo com 3 cargas (Shomael) e Passo Longo** | esquiva demais, sem dano | mortes em salas de projéteis; cargas gastas por sala |
| **Leitura** | Selo no ar, Marca, aviso vermelho, brasas de Inferno Rúnico e Sarael | captura lado a lado com o Guerreiro (uma, a sessão principal); brasa âmbar nunca vermelha |

Curva geral: robô Maestria 1 contra Maestria 20 no Guerreiro vence 72% e 90% (diferença 18, teto 25); a Maga deve cair na mesma faixa (a montagem mais forte da Maga, não a média).

## 6. O que pede código (resumo)

| Item | Estimativa |
|---|---|
| `maga_mastery.tres` e os 23 Dons em `data/talents/maga/` (parte `talents` do `make_data.gd`), textos | **P** |
| Ramos novos no `TalentDef.Branch` (`PIRO`, `ARCA`, `CTRL`), **três vizinhos entre si** em vez do losango fixo, apex e ponte sobre triângulo, `Talents` e testes | **P a M** |
| Tela da árvore (`TalentTree`, `HeroScreen`) em **triângulo** com os 3 ramos e as 6 pontes: pede o `art-director` desenhar os lugares | **M** (arte) |
| ~10 estatísticas lidas por `Arcane` (seção 2.7) | **P** |
| Selo Duplo, Ruptura, Brasa Gêmea | **P a M** |
| `UltDef.Kind.DOME` (Suspensão Absoluta) e seu shader, glifo do HUD | **M** |
| Bênçãos: gatilho `dome` e Passo emite `dodge`, skill no ponto da Explosão, 4 leituras (4.1), status no Círculo e escudo/cura no domo | **P** em lote e **M** (Q e E) |
| **Total M2** | **M a G** (cerca de 4 a 6 dias de `gameplay-engineer`; a tela do triângulo é arte) |

## 7. Perguntas ao Daniel

1. **Segunda ultimate**: **Suspensão Absoluta** (um domo grande que segue a Maga por 8 s, todo tiro marca) como recomendo, ou a **Detonação Geral** (todos os Selos da sala explodem)?
2. **Três ramos no triângulo** (Piromancia, Arcanismo, Controle, com seis pontes) como o Guerreiro tem quatro no losango: aprova que a tela da árvore ganhe esse desenho e que o
   `art-director` o faça?
3. **Selo Duplo** na Tempestade: pode a Tempestade deixar 2 Selos com o Dom (mais dano, ~218 por alvo), ou limito a 1 Selo na ultimate para ela ficar como é hoje?
4. **Brasa que Prende e as Bênçãos no Círculo** (queimar, congelar, marcar quem está dentro) pedem um trabalho de código maior (M): aprova fazer agora, ou só as 17 Bênçãos de dado
   e deixar Q e E para depois?
5. **Um terceiro nome do ramo**: "Controle" ou "Selos" como título do terceiro ramo na tela (o pacote diz "Controle / Selos")? *Recomendo "Selos", que é a marca dela.*
