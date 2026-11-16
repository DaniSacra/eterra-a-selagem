# Benchmarking: Ravenswatch (Passtech Games, 2023)

Pedido do Daniel em 2026-11-16: "gostei da ideia dos heróis, talentos, de não ter armas como o nosso jogo". Ravenswatch
entra como terceira referência, ao lado do Hades II (mecânicas e números, D-39) e do Ember & Blade (sensação visual).
**Dele estudamos princípios de design**, não copiamos números, nomes, heróis, arte, texto nem som.

**Fonte e limite**: análises e wikis públicas (lista no fim), lidas em 2026-11-16. Ninguém da equipe jogou; o jogo não
está instalado na Steam do Daniel, então não há números lidos de arquivo. O que está abaixo é entendimento de
segunda mão e deve ser conferido jogando antes de virar decisão.

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

## Perguntas para o Daniel (entram como decisão quando o tema chegar)
- Os quatro paladinos serão jogáveis, cada um com um kit próprio nas 4 ações? Em que fase?
- Talentos por herói além dos dons? Ou os dons já bastam na Fase 1?
- Existe no cânone algo que mude o herói durante a partida (como o dia e noite muda a Chapeuzinho)?

## Fontes
- Game Rant, análise: https://gamerant.com/ravenswatch-review/
- Pure Nintendo, análise: https://purenintendo.com/review-ravenswatch-nintendo-switch/
- TheGamer, heróis: https://www.thegamer.com/ravenswatch-all-playable-characters-ranked-best/
- Game Rant, talentos: https://gamerant.com/ravenswatch-best-character-upgrades/
- Ravenswatch.Pro, objetos: https://ravenswatch.pro/Items
- Playnews, revisão dos talentos: https://www.playnews.gg/en/updates/ravenswatch-what-does-the-talent-rework-change-for-your-hero-builds
- Prima Games, heróis na versão 1.0: https://primagames.com/tips/how-to-unlock-each-hero-in-ravenswatch-1-0
- GamingBolt, terceiro capítulo: https://gamingbolt.com/ravenswatch-gets-its-third-chapter-challenge-mode-in-latest-update
