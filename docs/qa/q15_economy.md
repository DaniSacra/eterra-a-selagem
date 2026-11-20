# Q-15: renda da loja e chances de Elo e Salmo (medição, 2026-11-20)

Medição pedida no C19 (backlog Q-15, `docs/backlog.md`): só número, nada mudado. Base para o `balance-designer`
(ver o bloco "Para o equilíbrio" em `docs/design/balance.md`) e para a loja de rota do DV-2 (MAP-09).

## Como

- `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 72, Maestria 1 (o robô não lê o
  save: sem Dons, sem Forja), código do HEAD `8dc0fea` com o C19 e a Fatia 1 (encontro com dois anjos em toda Bênção).
- Ouro "na loja" = `RESULT.shop.gold` (o ouro ao entrar na loja da sala 10); compras em `RESULT.shop.bought`.
- O robô compra o primeiro item que o ouro paga, na ordem das prateleiras (Bênção 150, cura 50 e coração 125, Magia,
  romã e fatia), um de cada vez enquanto houver ouro (`Rooms.bot_goal`).

## Resultado (72 descidas; 70 chegaram à loja; 58 vitórias, 14 derrotas; nenhum `stuck`)

| Medida | Meta da Q-15 | Medido |
|---|---|---|
| Ouro ao entrar na loja, mediana | 150 a 220 | **81,5** (p10 68, p25 72, p75 166, p90 186; mínimo 60, máximo 275) |
| Descidas que chegam à loja com 150 ou mais (o preço da Bênção) | | 20 de 70 (29%) |
| Descidas que compram algo além da cura | 1 em 3 | 20 de 70 (29%) |
| Itens comprados | | cura 52, Bênção 20, fatia de romã 2 |
| Descidas com pelo menos um Elo | 35% | **17 de 72 (24%)**, 17 Elos no todo |
| Descidas com um Salmo visto (o robô toma todo Salmo que vem) | 15% | **4 de 72 (5,6%)**: Sentinela 2, Abrigo 1, Rocha 1 |
| Bênçãos ao chegar em Morvath, mediana | | 6 |
| Encontros com anjos | | 402, nenhum com um anjo só nem sem anjo; 4 (1%) com menos de 3 cartas |

## Leitura

- A renda dobra só nas descidas que pegam a porta de ouro (100): a distribuição tem dois montes, 60 a 90 sem ela e
  160 a 190 com ela. Sem a porta, o ouro dos inimigos (`GoldPurse`) leva a uns 70 na sala 10.
- O Elo subiu de 1 em 12 (Q-15 original, antes da E3 e dos anjos) para 24% das descidas, ainda abaixo dos 35%. O
  encontro filtra pela família do anjo escolhido e o robô escolhe por afinidade (a família de que mais tem): a mão do
  robô se concentra em uma família, o que deixa menos Elos possíveis.
- O Salmo fica em 5,6%: pede três coisas de listas diferentes (`Psalms.met`) e 10% por carta; com a mão concentrada
  numa família, raramente as três batem. A porta de Salmo da Fatia 2 (`sistemas.md` 1.7) é a resposta de desenho.
- A loja de rota do DV-2 (3 itens nas camadas 6 a 8) hoje encontraria o robô com 30 a 60 de ouro na maioria das
  descidas: só a cura (50) e a fatia de romã (50) caberiam.

Arquivos das 72 partidas: scratchpad da sessão (não versionados); refazer com o comando acima.
