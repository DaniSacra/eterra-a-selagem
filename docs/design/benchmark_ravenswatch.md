# Benchmarking: Ravenswatch (Passtech Games, 2023)

> **2026-11-16, correção do PO**: o primeiro herói é **o Guerreiro** (não o Explorador nem o Guardião). Especificação canônica: `docs/design/warrior_spec.md`; onde este arquivo diz Explorador/Guardião para o herói, vale o Guerreiro (o texto abaixo fica como histórico).


Pedido do Daniel em 2026-11-16: "gostei da ideia dos heróis, talentos, de não ter armas como o nosso jogo". Ravenswatch
entra como terceira referência, ao lado do Hades II (mecânicas e números, D-39) e do Ember & Blade (sensação visual).
**Dele estudamos princípios de design**, não copiamos números, nomes, heróis, arte, texto nem som.

**Fonte e limite**: análises e wikis públicas (lista no fim), lidas em 2026-11-16. Ninguém da equipe jogou; o jogo não
está instalado na Steam do Daniel, então não há números lidos de arquivo. O que está abaixo é entendimento de
segunda mão e deve ser conferido jogando antes de virar decisão.

## Decisões do Daniel (2026-11-16, noite: diretriz "um herói definitivo")

Fonte: `docs/design/one_hero_directive.md`. Especificação que aplica isto: `docs/design/guardian_spec.md`. O que o
Ravenswatch inspirou e como ficou em Eterra:

| Princípio do Ravenswatch | Decisão de Eterra | Onde está |
|---|---|---|
| O herói é a arma; kit de 4 ações e um traço | **Um herói só agora**, o Explorador/Guardião (nome final do Daniel, D-48), até a qualidade desejada; os outros três não entram (decisões 1 e 2). A Emeth continua a arma dele; sem equipamento nem troca de arma (9 e 10). Kit: as 4 ações de hoje, mais uma **passiva** e uma **ultimate** (duas opções) | `guardian_spec.md` seções 3 a 6 |
| Talentos por herói que mudam as 4 ações | **Dons**: talentos permanentes e exclusivos do herói, destravados pela Maestria, equipados antes de descer com uma capacidade (Devoção) no molde das Arcana do Hades II (custo e capacidade), um Dom de ação por ação | seção 8 |
| Progressão por herói fora da partida (posto) | **Maestria**: progressão permanente individual do herói, por XP de partida, que destrava Dons, capacidade e a 2ª ultimate (decisão 4) | seção 7 |
| Objetos com raridade e custo | **Bênçãos**: as três cartas da descida (o que o jogo chamava de "dom"), com raridades comum, rara, épica e lendária (decisão 6), nas regras e números do Hades II (D-39). O "objeto amaldiçoado" fica para a Provação (o Caos do Hades II), na entrega de eventos | seções 9 e 10; roadmap E5 |
| (sem equivalente) | **Salmos**: descobertas especiais que transformam Dons, Bênçãos ou combinações (decisão 7), com temas dos Salmos bíblicos, música e efeitos originais (8); regra do dom lendário do Hades II | seção 11 |
| (sem equivalente) | **Compêndio**: registro do que foi visto e descoberto | seção 12 |
| Dia e noite, mapa aberto, cooperativo | **não** (como antes): salas do Hades II; a Câmara do Selo e Morvath fecham a primeira região (11); a Fase 2 não entra agora (12) | |

### O que fica para quando houver outros heróis
- Escolha do herói no título, Maestria e Compêndio por herói (a estrutura `HeroDef` já nasce por herói na E2).
- Bênçãos exclusivas de um herói (`heroes` na Bênção) e Salmos que pedem Dom de um herói.
- Progressão de posto com "memórias" e o cooperativo: não planejados.
- Responder no tempo certo: os kits dos outros três paladinos, quem concede as Bênçãos se eles forem jogáveis (D-51), e
  se o cânone tem algo que mude o herói durante a partida.

## Como o jogo funciona (resumo)
- Roguelite de ação visto de cima, solo ou cooperativo até 4. Heróis de contos e lendas reinterpretados (Chapeuzinho,
  o Flautista, Aladim, Julieta, Sun Wukong, Merlin e outros; 12 hoje).
- **Cada herói é o próprio kit**: 4 habilidades fixas (ataque, poder, defensiva ou movimento, e um poder maior), um
  traço passivo e uma identidade de jogo. Não se troca de arma: a arma faz parte do herói.
- **Talentos por herói**: ao subir de nível na partida, o jogador escolhe um talento entre poucos, todos do próprio
  herói e feitos para mudar as 4 habilidades dele. Mais de 200 no total. O que vem de fora do herói são os
  **Objetos Mágicos**, achados no mapa, com raridades (de comum a amaldiçoado, com custo).
- **Ciclo de dia e noite**: cada capítulo tem 3 dias e 3 noites antes do chefe. Alguns heróis mudam de forma ou de
  força à noite (a Chapeuzinho vira lobisomem); a noite traz inimigos mais fortes.
- **Mapa aberto por capítulo**, gerado a cada partida, explorado contra o relógio, com objetivos, baús e encontros
  espalhados; capítulos em ordem fixa, chefe no fim de cada um.
- **Progressão fora da partida por herói**: jogar sobe o posto do herói, que destrava talentos novos e "memórias".

## O que serve para Eterra (princípios, por pilar)

### Heróis e identidade (o que o Daniel gostou)
- **O herói é a arma.** Eterra já é assim: o Explorador com a Emeth, sem troca de arma, e quatro paladinos no
  cânone (`PALADIN_1` a `PALADIN_4`, nomes do Daniel). Ravenswatch mostra que dá para ter heróis muito diferentes com
  o mesmo esqueleto de 4 ações (no nosso caso: ataque, especial, círculo, esquiva). Cada paladino pode ser um kit
  próprio nessas 4 ações, com uma passiva.
- **Talentos que mexem nas ações do próprio herói.** Hoje nossos dons são do molde do Hades (famílias de dons,
  `BoonMod` por `tag`, Elo para o duplo). Ravenswatch sugere uma camada a mais por herói: talentos só daquele paladino.
  O sistema atual já comporta isso como dado (um `Boon` com `requires` ou um conjunto por herói).
- **Transformação por estado** (dia e noite). Em Eterra o equivalente com cânone seria a luz de Elun, não um ciclo
  inventado; qualquer coisa assim é pergunta ao Daniel (nunca inventar lore).

### Progressão roguelite
- **Escolha frequente e pequena** (um talento por nível) dá sensação de evolução constante. É o mesmo problema
  medido aqui: chegamos a Morvath com 2 a 4 dons (C13). Vale comparar a frequência de escolhas do Ravenswatch com a
  do Hades quando o C13 for planejado.
- **Objetos com custo** (o amaldiçoado): uma recompensa que ajuda e atrapalha cria escolha de risco; liga com a
  loja e a fonte do C13.
- **Progressão por herói fora da partida** (posto): só faz sentido quando houver mais de um herói jogável.

### Exploração
- O mapa aberto com relógio é outra estrutura, oposta às salas do Hades que adotamos (D-39). Não trocar. O princípio
  útil é a **sensação de atravessar um lugar**, que a revisão externa apontou como hipótese A: portas que mostram o
  caminho, salas que se ligam visualmente, o nome do lugar.

### Cooperativo
- O cooperativo é o maior atrativo comercial dele. Para Eterra é decisão de produto grande (rede, câmera, leitura de
  4 heróis), fora da Fase 1.

## O que **não** levar
- Números do Ravenswatch no lugar dos do Hades II (D-39 continua).
- Os heróis de contos, os nomes, a arte de quadrinho, o dia e noite como mecânica sem cânone.
- Mapa aberto no lugar das salas.

## Perguntas para o Daniel (estado em 2026-11-16, noite)
- ~~Os quatro paladinos serão jogáveis, cada um com um kit próprio nas 4 ações? Em que fase?~~ Respondida: só o
  Explorador/Guardião agora (decisões 1 e 2); os outros depois, sobre a arquitetura validada.
- ~~Talentos por herói além dos dons?~~ Respondida: sim, os **Dons** (talentos permanentes pela Maestria); as cartas da
  descida passam a se chamar **Bênçãos**.
- Existe no cânone algo que mude o herói durante a partida (como o dia e noite muda a Chapeuzinho)? Segue aberta.

## Fontes
- Game Rant, análise: https://gamerant.com/ravenswatch-review/
- Pure Nintendo, análise: https://purenintendo.com/review-ravenswatch-nintendo-switch/
- TheGamer, heróis: https://www.thegamer.com/ravenswatch-all-playable-characters-ranked-best/
- Game Rant, talentos: https://gamerant.com/ravenswatch-best-character-upgrades/
- Ravenswatch.Pro, objetos: https://ravenswatch.pro/Items
- Playnews, revisão dos talentos: https://www.playnews.gg/en/updates/ravenswatch-what-does-the-talent-rework-change-for-your-hero-builds
- Prima Games, heróis na versão 1.0: https://primagames.com/tips/how-to-unlock-each-hero-in-ravenswatch-1-0
- GamingBolt, terceiro capítulo: https://gamingbolt.com/ravenswatch-gets-its-third-chapter-challenge-mode-in-latest-update
