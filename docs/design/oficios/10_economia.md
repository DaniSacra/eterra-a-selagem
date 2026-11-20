# Ofícios e Descobertas: economia, progressão e métricas (balance-designer, 2026-11-20)

Seções 10, 12, 13 e 20 do pedido (`00_pedido_po.md`). **Só estudo**: nenhum número, dado ou código mudou. Medido no
HEAD `9271e95` (Fatia 2, DV-2, C19) numa cópia isolada (`git archive`), sem GPU. Vale junto com `01_diagnostico.md`,
`05_coleta_e_regioes.md` (room-designer) e `16_arquitetura.md`. Todo número de meta é **proposta para o Daniel**.

## 0. Resumo crítico

1. **O problema de hoje não é falta de recurso, é falta de gasto.** A Prata acaba (toda a Forja comprada) na 12ª a 14ª
   descida do robô-gente e na 7ª a 8ª do Daniel; a Maestria 20 só chega na 25ª a 30ª. A **Esmeralda não tem gasto
   nenhum** e já se acumula (1 a 2 por descida que chega na fase 3). Uma camada de ofícios deve **gastar** o que já
   existe antes de criar coisa nova para juntar.
2. **Não criar moeda.** O pedido fala em minérios, madeira, óleo, ervas, manuscritos. Cada um pede um NPC, uma tela e
   um número na HUD. Proposta: zero moeda nova; **achados únicos** (ferramentas e manuscritos, não contáveis) e no
   máximo **um** componente contável novo no capítulo 1, o que a primeira ferramenta abre (Pedra Funda, do
   `05_coleta_e_regioes.md`). O Ferro de Corrente proposto lá é redundante com a Prata (os dois são "metal do Forjador").
3. **Ferramenta achada e restaurada** é o melhor jeito de pagar: a descoberta é o momento bom, a Prata é o gasto, o
   ouro fica na descida. Madeira + Prata cria moeda; encomenda com espera é relógio; componente da descida pede o que a
   ferramenta ainda não abriu (risco de ciclo).
4. **Já existe um laço de farming**: a porta de Memória e a de Prata podem aparecer na sala 2 (75% das descidas têm
   uma delas na primeira escolha, aos 26 s) e sair no meio guarda tudo. Sair logo depois rende 3 a 3,5 vezes a Memória
   por minuto de uma descida inteira. Corrigir antes de qualquer fonte nova (6.2).
5. **Ofícios horizontais, não verticais.** A Forja já soma força permanente (medida em 4.1). A primeira descida tem de
   ser muito difícil: o que a camada nova abre são **opções** (portas, informação no mapa, escolhas no Livro), nunca
   dano ou vida. Se algum ofício der força, entra no mesmo teto da Forja.

## 1. Economia de hoje, medida

### 1.1 Como

- `godot --headless --fixed-fps 60 -- --bot --nosave --smoke=900 --seed=N --bot-reaction=R --ultimate=cleave` (o
  `tools/smoke.sh 900`), cópia isolada fora do repositório, 6 processos.
- **r25**: régua 0,25, sementes 1 a 48. **r45**: robô-gente 0,45, sementes 1 a 32. **f25/f45**: as mesmas com toda a
  Forja (`--forge=3 --refine=refine_pressa,refine_onda_pronta`). Sem Dons (o robô não lê o save).
- Gente: `runs.jsonl` do Daniel (34 linhas; 3 descidas completas depois da Fatia 1, as únicas com materiais; as saídas
  de 7 s são testes dele). Três partidas não são régua: só ordem de grandeza.

### 1.2 Renda por descida

| | r25 (66% vitórias) | r45 (25% vitórias) | Daniel (3 descidas) |
|---|---|---|---|
| Tempo da descida (mediana) | 5 min 33 s | 4 min 40 s (morre antes) | 3 min 29 s a 8 min 51 s |
| **Prata** p10 / p50 / p90 | 11 / **30** / 46 | 0 / **17** / 43 | 16, 32, **54** (vitória) |
| Prata, vitória / morte em Morvath / morte antes | 33,5 / 24,5 / 0 | 41 / 24 / 6 | 54 / 32 / 16 |
| **Memória** p10 / p50 / p90 | 2 / **5** / 7 | 0 / **2** / 7 | 4, 5, 11 |
| **Esmeralda** média | 1,5 | 0,8 | 0 a 1 |
| Prata por minuto | 5,5 | 4,7 | 4,6 a 6,1 |
| Memória por minuto | 0,91 | 0,74 | 0,6 a 1,4 |

De onde vem a Prata (média por descida, r25): Morvath 13,4 (fases e vitória), **elites 8,7**, guardião 5,5, porta 1,9.
A Memória: guardião 1,8, Morvath 2,0, Provação 0,6, porta 0,4. O robô quase nunca pega porta de material (a de Prata
aparece 0,6 vez por descida, ele pega 0,1). O Daniel pega: 2 de 3 descidas com porta de material e ainda prefere a
porta Difícil, por isso tira 18 a 20 de Prata só de elites. **Gente rende 1,5 a 2 vezes o robô.**

### 1.3 Ouro (só da descida)

| | r25 | r45 | Daniel |
|---|---|---|---|
| Ouro ao entrar na loja da sala 10 (p10 / p50 / p90) | 66 / **82** / 188 | 66 / **74** / 88 | 71, 97 |
| Compras | cura 32, Bênção 10, fatia 2 | cura 16 | cura 2 |
| Ouro que sobra no fim (p50) | 31 | 36 | |
| Loja de rota visitada (camadas 6 a 8) | 5 de 48 (ouro 38 a 162) | 3 de 32 | |

O ouro está como no Q-15: dois montes (60 a 90 sem a porta de ouro, 160 a 190 com ela), a loja de rota quase sempre
encontra o herói com menos de 60. O ouro não precisa de nada desta camada; ele **não** deve pagar ofício (fica da
descida, como no Hades II).

### 1.4 Gastos que existem e quando acabam

| Material | Gasto | Total |
|---|---|---|
| Prata | Temperar I 15, II 35, III 60; Refinar 6 x 25 (3 por ação, só uma ativa) | **260** |
| Memória | abrir os 18 Dons fechados (custo = Devoção; o Quarto Corte vem aberto) | **54** |
| Esmeralda | nada (o Despertar é Fatia 3) | **0** |

Descidas até cada marco, somando a renda das sementes em sequência (três pontos de partida diferentes):

| Marco | r25 | r45 | Daniel (estimativa: 1,7 vez o r45) |
|---|---|---|---|
| Temperar I (15) | 1 | 1 a 3 | 1 |
| Temperar II (50 somados) | 2 a 3 | 2 a 3 | 2 |
| Temperar III (110) | 3 a 6 | 4 a 7 | 3 a 4 |
| Forja inteira (260) | 8 a 10 | **12 a 14** | 7 a 8 |
| Memória 20 | 4 a 6 | 6 a 10 | |
| Todos os Dons abertos (54) | 11 a 13 | **14 a 21** | |
| Maestria 20 (do `balance.md` 4) | | 25 a 30 | |
| Esmeralda juntada em 32 descidas | 49 | **24** | |

Leitura: a Memória anda junto da Maestria (a Maestria revela um Dom a cada 1,3 descida; a Memória abre perto disso).
A Prata termina **no meio** do caminho e depois sobra 15 a 40 por descida sem destino até a Maestria 20. A Esmeralda
sobra desde a primeira fase 3. **É aqui que os ofícios cabem: 150 a 250 de Prata e 10 a 20 de Esmeralda de gasto novo
estendem a Forja até a 20ª descida sem criar renda nova.**

## 2. Catálogo mínimo e matriz

Regra: um recurso entra só se tiver **um uso que nenhum outro faz** e se a fonte for uma **decisão** (porta, risco,
ferramenta), não tempo de jogo. Contável = moeda ou componente; único = achado (sim ou não no save).

### 2.1 O que reaproveitar (recomendado)

| Recurso | Papel na camada nova | Por que não moeda nova |
|---|---|---|
| **Prata** | "metal": restaurar ferramentas, obras do hub, o resto da Forja | já é o metal do Forjador; sobra desde a 12ª descida |
| **Memória** | "conhecimento": ler e decifrar manuscritos no Livro de Ahk | já é o recurso dos Dons; manuscrito ligado a Dom é Memória com nome. **Cuidado**: não competir com abrir Dons antes da 10ª descida (custos só depois) |
| **Esmeralda** | "raro": o último passo de uma ferramenta de segundo nível; o Despertar | é o único material sem gasto; vem de risco (fase 3 de Morvath) |
| **Achados únicos** | a ferramenta partida, o manuscrito, a peça que uma encomenda pede | não contam, não inflam, não pedem número na HUD; o save já guarda `tools` assim |

### 2.2 Matriz (existentes e propostos)

| Nome | Fonte | Raridade | Persiste | Uso | Depende de | Relevância | Excedente | Risco |
|---|---|---|---|---|---|---|---|---|
| Ouro (existe) | inimigos, porta 100 | comum | não | loja, Altar, Provação não | nada | toda descida | some ao voltar | nenhum; não tocar |
| Prata (existe) | elite 1, porta 10, guardião 6, Morvath 2 por fase e 10 na vitória | comum | sim, também na morte | Forja; **proposto**: restaurar ferramentas e obras | Forjador | começo e meio | hoje sobra da 12ª descida; com 2.3 vai até a 20ª | **inflação** depois de tudo comprado; farming pela porta da sala 2 (6.2) |
| Memória (existe) | porta 3, guardião 2, Provação 2, vitória 3 | incomum | sim | abrir Dons; **proposto**: decifrar manuscritos | Livro | começo ao fim | acaba perto da Maestria 20 | **farming** (porta na sala 2 e sair: 3 a 4 vezes a taxa); competir com os Dons |
| Esmeralda (existe) | fase 3 de Morvath 1, vitória 1 | rara | sim | **proposto**: último passo das ferramentas de 2º nível; Despertar | chegar à fase 3 | meio e fim | hoje 100% excedente | ficar exclusiva de quem vence (quem morre cedo nunca vê); ok para coisa de fim |
| Achado: ferramenta partida (Picareta, depois outras) | sala elegível da descida, com piedade (6.1) | 1 por ferramenta | sim (único) | restaurar no Forjador | nada | começo (1ª), meio (2ª) | não existe | **softlock** se a fonte depender da própria ferramenta (proibido); "simulador de coleta" se forem muitas |
| Achado: manuscrito (3 a 5 no capítulo) | Santuário, Provação vencida, guardião (fontes de risco) | 1 cada | sim | decifrar no Livro com Memória: revela a receita de uma Obra, a pista de um Salmo, uma linha do Compêndio | Livro | meio | não existe | virar coleção sem uso (cada um precisa abrir algo) |
| **Pedra Funda** (proposto, o único contável novo) | veio nas Fendas e nas Runas, só com a Picareta, 0 a 1 por descida | incomum | sim, teto 10 | obras do hub (2.3) e Refinar de 2º nível | Picareta | meio | acima do teto vira 2 de Prata na hora | **redundância** com a Prata se o uso não for exclusivo; um número a mais na Bolsa |
| Ferro de Corrente (do `05`) | Ponte, Cavaleiro | comum | sim | fazer a Picareta | | começo | | **rejeitado**: é Prata com outro nome |
| Cera, Fungo, Pó de Runa (do `05`) | Cripta, Jardim, Runas | comum | sim | óleo, ervas, consumíveis | Alquimista | | | **rejeitados no capítulo 1**: pedem um NPC novo e o consumível de combate vira Bênção fabricada (proibido); Pó de Runa só se as Runas forem perigo medido |
| Madeira | | | | | | | | **rejeitada**: não há madeira nas catacumbas e seria a 4ª moeda |

### 2.3 Gastos novos propostos (os que fecham a conta)

| Gasto | Custo (ponto de partida) | O que dá | Tipo |
|---|---|---|---|
| Restaurar a Picareta | achado + 20 Prata | veios de Pedra Funda nas Fendas e Runas | horizontal (nova fonte) |
| Restaurar a 2ª ferramenta (ex.: cinzel) | achado + 40 Prata + 2 Esmeralda | lê as inscrições: manuscritos aparecem nas salas | horizontal |
| Obras do hub (3 a 4, Vendedor) | 30 a 60 Prata + 2 a 4 Pedra Funda cada | **opções na descida**: o mapa mostra o anjo de uma camada a mais, a 2ª romã na loja, porta de Salmo mais cedo, o Altar mais frequente | horizontal |
| Decifrar manuscrito | 4 a 8 Memória cada, desde a 8ª descida | uma receita de Obra, uma pista de Salmo, Compêndio | horizontal |
| Despertar (Fatia 3, já planejado) | 2 a 4 Esmeralda | propriedade da lâmina, uma por vez (troca) | lateral (troca, não soma) |

Soma: Prata 200 a 300, Memória 15 a 30, Esmeralda 10 a 16, Pedra Funda 10 a 15. Com a renda medida, a Prata vai da
12ª à 18ª a 22ª descida do robô-gente, a Esmeralda é gasta à medida que chega. Não precisa de fonte nova de Prata.

## 3. Como pagar uma ferramenta

| Modelo | Bom | Ruim | Veredito |
|---|---|---|---|
| Madeira + Prata | simples de ler | moeda nova sem outro uso; não há madeira no bioma | não |
| Componente da descida (ex.: Ferro de Corrente) | identidade por bioma | redundante com a Prata; se o componente vier de onde a ferramenta abre, ciclo | não no capítulo 1 |
| Serviço de encomenda (paga e espera N descidas) | dá motivo para voltar ao NPC | espera por relógio ou por descidas é *grind* puro, e o Daniel quer dificuldade, não paciência | não com espera; sim como "traga X" (o achado) |
| **Ferramenta achada e restaurada** | a descoberta é o momento; a Prata ganha gasto; o ouro fica na descida; um passo só no hub | precisa de piedade para não depender da sorte | **sim** |

**Recomendação**: a ferramenta cai **partida** numa sala da descida (achado único, como a `tool_refine` de hoje no 1º
guardião vencido), aparece no Forjador como encomenda ("traga a cabeça da picareta") e se restaura com Prata (a 1ª com
20, a 2ª com 40 e 2 Esmeralda). Por quê: (1) não cria moeda; (2) o laço "achei, levei, abri" fecha em uma ou duas
descidas, que é o tamanho certo para o protótipo; (3) o custo em Prata é decisão (Temperar III ou a Picareta?) num
momento em que a Prata ainda é escassa (descidas 3 a 6); (4) a 2ª ferramenta pede Esmeralda e com isso dá destino ao
material sobrando. O ouro continua só da descida.

## 4. Vertical contra horizontal

### 4.1 Medido: quanto a Forja já vale

| Régua | Sem Forja | Forja inteira (Temperar III, Refinar Pressa e Onda Pronta) | Diferença |
|---|---|---|---|
| r25 (48 sementes) | 32 de 48 (66%) | 34 de 48 (70%) | **+4** (ruído de uns 7) |
| r45 (32 sementes) | 8 de 32 (25%) | 11 de 32 (34%) | **+9** (ruído de uns 10) |

Leitura: a Forja inteira já vale **+4 a +9 pontos** de vitória, na faixa de "5 a 10 por coisa permanente" do
`balance.md` 7.4, e sozinha já gasta quase todo o teto do hub. Onde mais pesa é antes de Morvath: as mortes antes da
sala 11 caem de 15 para 8 em 32 (r45) e de 6 para 3 em 48 (r25); a vitória fica 9% mais curta (r25, 350 s para 319 s).
Pareando sementes, 8 viram vitória e 5 viram derrota (r45): é força pequena e real, não ruído só. Conclusão: **não
sobra espaço vertical para os ofícios**; se algum der força, a Forja tem de ceder (ex.: Temperar III vira troca).

### 4.2 Proposta de equilíbrio

- **Teto do hub inteiro** (Forja, ofícios, obras) na régua r45: **+10 a +15 pontos de vitória** sobre a mesma Maestria,
  como no `balance.md` 7.4 ("cada coisa permanente vale no máximo 5 a 10 pontos"). A Forja já usa +9 (4.1): **sobram
  no máximo +5 para todos os ofícios juntos**, e o alvo é 0. A Maestria, os Dons e a mão do
  jogador ficam com o resto da curva (Maestria 1 a 20: 40 a 60 pontos na r25).
- **Ofícios dão opção, não número**: nova fonte (veio), informação (o anjo de mais uma camada no mapa), regra de
  porta (Salmo mais cedo, Altar mais vezes), Compêndio, um posto de Refinar **que troca** (escolha exclusiva, como hoje).
  Nada de vida, dano, cura ou Magia vindo de ofício. Teste de aceite: com todos os ofícios e a mesma Forja, a vitória
  da r45 dentro do ruído (diferença menor que 10 pontos em 32 sementes).
- **Lateral conta como horizontal só se for troca**: Refinar e Despertar são uma escolha ativa por ação; comprar
  mais escolhas não soma força. Manter assim.
- **Nada de força antes da 3ª descida vinda do hub** além do Temperar I. A primeira descida muito difícil continua
  sendo a da Maestria 1, sem ultimate (B-2 do `balance.md`), com no máximo Temperar I.
- As obras que mexem no baralho (porta de Salmo mais cedo, Altar mais vezes) mexem em Elo e Salmo, que hoje **não
  pesam** na vitória (`balance.md` 3.6): são seguras. As que mexem na loja (2ª romã) dão força: só depois de medir.

## 5. Orçamento de complexidade do primeiro capítulo

| Item | Hoje | Teto proposto no capítulo 1 |
|---|---|---|
| Materiais contáveis | 3 (Prata, Memória, Esmeralda) | **4** (mais a Pedra Funda) |
| Achados únicos | 1 (`tool_refine`) | **5** (2 ferramentas partidas e 3 manuscritos) |
| Receitas (tudo que se compra no hub com material) | 9 (3 Temperar, 6 Refinar) | **16** (restaurar 2, obras 3 ou 4, decifrar 3) |
| NPCs com loja | Forjador (Vendedor fechado) | **2**: Forjador e Vendedor (obras). Nenhum NPC novo: Artesão é o Forjador, Mercador é o Vendedor, Guardião dos Manuscritos é o Livro de Ahk |
| Etapas por encomenda | | **no máximo 2** (achar e entregar) |
| Cadeia mais longa | Forja 3 postos | **3 elos** (achar, restaurar, colher); nada de 4 |
| Tempo de coleta por descida | 0 | **no máximo 10 s** (até 3 pontos, menos de 2 s cada com o desvio; abaixo de 4% de uma descida de 4 a 5 min) |
| Visitas ao hub entre descidas | Forjador, Livro, Portal | **até 2 estações com novidade por volta**, 90 s ou menos no hub (mediana) |
| Números na Bolsa | 2 (Prata e Memória; a Esmeralda não aparece) | 4, nunca na HUD da luta |

## 6. Anti-grind, piedade e o que sobra no fim

### 6.1 Garantias (piedade)

- **Ferramenta**: cada descida que passa da camada do guardião sem achar a ferramenta partida soma 1 num contador no
  save; com 2, a próxima a garante (no guardião vencido, como a `tool_refine`). Meta: 1ª ferramenta na mão até a 3ª
  descida que chega ao guardião (p90). A morte guarda o achado, como os materiais.
- **Pedra Funda**: só com encomenda ativa que a pede, o gerador põe um veio no pior caminho (regra do `05` 3.3); sem
  encomenda, nada garantido.
- **Manuscrito**: nunca por sorte pura; vem de fontes de risco (Provação vencida, guardião, Santuário) com a mesma
  piedade de 2 descidas.
- **Derrota rende**: na r45 a morte antes de Morvath dá 6 de Prata e 1,4 de Memória (mediana). Meta: a descida que
  chega ao guardião e morre rende pelo menos 40% de uma vitória em Prata (hoje 24 contra 41 em Morvath, 6 antes:
  passa só em Morvath). Proposta para medir: elite e guardião ficam como estão; nada de prêmio de consolação novo,
  que premia morrer.

### 6.2 Proteção contra farming (achado medido)

- **Medido**: em 80 descidas (r25 e r45), a primeira escolha de porta (aos 26 s) tem Prata em 32% e Memória em 43%;
  a sala 2 termina aos 46 s. Sair logo depois guarda 10 de Prata ou 3 de Memória em cerca de 70 s contando a volta ao
  portal: **8,6 de Prata por minuto (1,6 a 1,8 vez a descida inteira) e 2,6 de Memória por minuto (3 a 3,5 vezes)**.
  O laço é "começa, olha a porta, pega ou sai, repete". Gente faz isso quando a próxima compra está perto.
- **Proposta** (dado, `_stage` do `make_data.gd`, no molde do `pom_from_depth`, aplicado pelo gerador e pelo
  `RunMap.settle`): **porta de Prata só da profundidade 4** e **porta de Memória só depois da camada do guardião
  (profundidade 7)**. Medido no robô: a sala 4 termina aos 98 s, a 5 aos 123 a 135 s. Com a Prata na 4, sair depois
  rende 10 em cerca de 2 min com a volta (5 por minuto, 0,9 a 1,1 vez a descida inteira). A Memória vale 3, mais da
  metade do que uma descida inteira dá; na 4 ainda renderia 1,6 a 2 vezes, na 7 (cerca de 3 min 30 s) fica perto de
  1,0. Regra geral: **nenhuma fonte pode render, saindo logo depois dela, mais que 1,2 vez a taxa por minuto da descida
  inteira**. Vale para veios e achados (o `05` os põe da profundidade 3: o veio de Pedra Funda é 1 por descida e não
  tem outra fonte, então o risco é o mesmo da Memória; medir com E3).
- Efeito colateral a medir: as salas 2 e 3 ficam só com portas de força e de corpo (a escolha "agora contra depois"
  começa no meio da descida, o que combina com a curva do `balance.md` 5: as primeiras salas não pedem nada).
- Teto por descida: no máximo 1 porta de material por caminho antes do guardião.
- Nada se repete em laço: encomendas entregues uma vez (como no `16`), sem receita que troca material por material
  com lucro.

### 6.3 Depois de tudo aberto

- **A porta de material vira outra coisa quando o save não tem mais onde gastar** (o mesmo `RunMap.settle` que troca a
  romã que não pode subir): sem gasto pendente de Prata, a porta de Prata vira ouro ou Bênção. A escolha "agora contra
  depois" some quando não há "depois", em vez de virar renda morta.
- Tetos que já existem (999, 99) seguram o resto. Acima do teto da Pedra Funda, 2 de Prata.
- Fim de jogo de verdade são os **Juramentos**: a Esmeralda por recorde de Peso (Fatia 3) e um gasto de prestígio
  (ex.: estandarte ou estátua no hub por Peso alcançado) se o Daniel quiser. Nada que dê força.

## 7. Métricas de sucesso

### 7.1 Medido hoje (base)

| Medida | r25 | r45 | Fonte |
|---|---|---|---|
| Prata / Memória por descida (p50) | 30 / 5 | 17 / 2 | 1.2 |
| Descidas até a Forja inteira | 8 a 10 | 12 a 14 | 1.4 |
| Descidas até todos os Dons abertos | 11 a 13 | 14 a 21 | 1.4 |
| Esmeralda sem uso em 32 descidas | 49 | 24 | 1.4 |
| Taxa de Memória por minuto saindo na sala 2 contra a descida inteira | 3 vezes | 3,5 vezes | 6.2 |
| Força da Forja inteira (vitória) | +4 | +9 | 4.1 |

### 7.2 Hipóteses e metas propostas (não medidas)

| # | Hipótese | Meta | Como medir |
|---|---|---|---|
| E1 | a 1ª ferramenta chega cedo o bastante para ser a primeira história | restaurada entre a 3ª e a 5ª descida (p50), p90 até a 7ª | soma das sementes em sequência, r45 (como 1.4); depois, `runs.jsonl` de gente |
| E2 | coleta não vira simulador | menos de 10 s de coleta por descida, menos de 4% do tempo | `gather_s` no `RESULT` (campo novo) |
| E3 | sem farming | nenhuma fonte acima de 1,2 vez a taxa por minuto da descida inteira saindo logo depois dela | `--materials-keep` com `--smoke` curto (sair aos N s), r45, 32 sementes |
| E4 | os gastos duram a curva | Prata acaba entre a 18ª e a 22ª descida (r45); nenhum material com mais de 30% de excedente antes da Maestria 15 | soma em sequência |
| E5 | horizontal de verdade | todos os ofícios: vitória r45 dentro de 10 pontos da mesma Forja sem ofícios | 32 sementes, mesmas sementes |
| E6 | o hub não pesa | 90 s ou menos no hub entre descidas (mediana); 2 estações com novidade ou menos | linha `hub` no registro (campo novo) |
| E7 | a porta de material é decisão | gente pega porta de material em 20 a 40% das vezes que ela aparece (nem sempre, nem nunca) | `events` `door` do `runs.jsonl` (já existe) |
| E8 | a derrota rende | morte depois do guardião rende 40% de uma vitória em Prata | `RESULT.materials` |

### 7.3 O que o registro precisa ganhar

- `RESULT` e `RunLog`: `finds` (achados da descida, com sala), `gather` (pontos vistos, pegos, segundos), `pity` (o
  contador de cada garantia no começo), `quit_room` já sai como `room` com `outcome` quit.
- Uma linha de hub por volta (`source: hub`): segundos no hub, estações usadas, compras e gastos. Sem isso E6 é chute.
- Para o robô: uma opção de **campanha** (sementes em sequência com uma bolsa e as compras numa ordem fixa, lidas de um
  arquivo) para medir E1, E4 e a curva de vitória com a Forja crescendo, no lugar da soma feita à mão desta seção.

## 8. Decisões para o Daniel

1. Zero moeda nova e no máximo um componente contável (Pedra Funda) no capítulo 1; rejeitar Ferro, Cera, Fungo,
   Madeira e Pó de Runa por agora.
2. Ferramenta achada e restaurada com Prata (e Esmeralda na 2ª).
3. Ofícios só horizontais; o hub inteiro com no máximo +10 a +15 pontos de vitória na régua r45 (a Forja já dá +9).
4. Porta de Prata da profundidade 4 e de Memória da 7 (corrige o farming de hoje, independente da camada nova).
5. Porta de material vira ouro ou Bênção quando o save não tem mais onde gastar.

## 9. Medir depois

- Do teste do Daniel: `events` `door` (quantas portas de material ele pega), Prata e Memória por descida, saídas no
  começo (quantas e com que material).
- Depois da regra 6.2: E3 em 32 sementes.
- Depois do protótipo (a Picareta): E1, E2, E5 nas duas réguas, mesmas sementes desta medição.
