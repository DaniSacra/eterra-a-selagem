# Os quatro heróis de lançamento: comparação e perguntas

- **Data**: 2026-11-21. **Autor**: `hero-designer`. **Estado**: proposta para o Daniel decidir; nada implementado.
- **Arquivos**: `guerreiro.md`, `maga.md`, `ladina.md`, `paladino.md` (kit completo de cada um, com o que reaproveita e o que pede código).
- **Regra central** (`docs/design/po_directive_guardian.md`): o Dom define o herói, a Bênção define a partida, o Salmo transforma o poder.
- **Nomes**: nenhum nome próprio nem origem foi inventado. Os heróis são "A Maga", "A Ladina", "O Paladino" e "O Guerreiro" (nomes de função). Marcadores `PALADIN_1` a `PALADIN_4` ficam até o Daniel decidir. Números são ponto de partida, a medir com o `balance-designer`.

## 1. A regra dos botões (a única regra comum)

**5 habilidades ativas, nos botões esquerdo, direito, Q, E e Shift, mais a travessia no Espaço.** Nada mais é igual entre os heróis: cada kit
distribui ataque, especial, poder, defesa, invocação, ultimate e postura nos 5 botões como a fantasia pede (decisão do Daniel, 2026-11-21).
A Travessia também é do herói (a Maga pode ter um blink, a Ladina um mergulho).

O código de hoje (`scripts/controls.gd`): botão esquerdo `light_attack`, direito `heavy_attack`, `cast` em Q e Shift, `dodge` no Espaço,
`ultimate` no R, `interact` no E. Pad: X, Y, RB (cast), B (esquiva), LB (ultimate), A (interagir).

### 1.1 Mapa por herói (proposta)

| Botão | Guerreiro | Maga | Ladina | Paladino |
|---|---|---|---|---|
| Esquerdo | Ataque: combo de espada | Ataque: rajada de orbes | Ataque: adagas rápidas | Ataque: combo de maça |
| Direito | Especial: onda (Ômega segurando) | Especial: lança de luz que atravessa | Especial: adaga de Marca | Especial: golpe de escudo |
| Q | Poder: círculo de luz (prende) | Poder: zona no cursor | Defesa: fumaça | Poder: Chão Consagrado |
| E | **Brado** (falta hoje) | Invocação: pilar de luz | Travessia tática: Pulo de Sombra | **Ultimate** |
| Shift | **Ultimate** | **Ultimate** | **Ultimate** | **Guarda** (segurar) |
| Espaço | esquiva e Corte Veloz | **Blink** | Mergulho | Avanço de Escudo |

**Recomendação para a ultimate**: Shift quando o herói não tem outra habilidade de "segurar" (Guerreiro, Maga, Ladina); E no Paladino, porque Shift é a
Guarda dele (segurar o botão com o dedo menor, natural). Justificativas: Shift está livre (hoje é só segundo atalho do `cast`); o R conflita com
`menu_reroll`; no pad a ultimate já é LB. Alternativa: manter a ultimate no R como 6º botão de todos (menos mudança, mas vira 6 botões).
O custo de dar a cada herói seu mapa é um `HeroDef.buttons` (botão para habilidade), ver custo no item 3.

### 1.2 Mudanças comuns (custo de código)
- **Interagir sai do E** (a `SPARE_KEYS` já oferece F). Pad continua A. **P.**
- `Boon.Slot` hoje `NONE, ATTACK, SPECIAL, CAST, DASH`. Para Q, E e Shift valerem como "ação do herói" o slot passa a ser por **habilidade** (`SKILL_Q`, `SKILL_E`, `SKILL_SHIFT`)
  ou por papel (`TECH`, `ULT`, `GUARD`). Recomendo por papel, que casa com o texto das Bênçãos. **P.**
- Ação `skill_e` no `Controls` e no pad (RT é eixo, pede código). **P a M.**
- Preparação, impacto e recuperação de cada golpe ficam com o `combat-feel-director`; esquiva e ultimate cortam qualquer golpe (já é assim).

## 2. Tabela comparativa

| | **Guerreiro** | **Maga** | **Ladina** | **Paladino** |
|---|---|---|---|---|
| Fantasia | pressão em cima do inimigo, combos e giros | a sala resolvida de longe, antes de chegar | assassina de uma pessoa só, entra e sai | muralha de luz: segura, protege e responde |
| Distância | curta (espada, 3 m) | longa (8 a 14 m) | curta e rápida (adagas, 2 m), vem por trás | média (maça e escudo de luz, 2,5 m, área em volta) |
| Ritmo | constante, 3 golpes em cadeia, o giro abre | ritmo de "carrega, solta, posiciona": rajadas curtas e uma explosão de recarga | explosivo: janelas de 2 a 3 s de pico e depois some | ritmo de ciclo: aguenta, abre guarda, devolve |
| Recurso próprio | Fúria em cargas (3, somem em 3 s sem abate), sem barra | **Cargas de Brilho** (0 a 3): cada magia que acerta dá uma, a próxima magia grande as gasta | **Pontos de Combo (Marca)**: o primeiro golpe marca; o finalizador gasta os pontos, mais dano por ponto | **Fé em cargas de escudo** (até 3 camadas de proteção que absorvem um golpe cada, nunca barra) |
| Espaço (travessia) | corta o golpe e vira Corte Veloz (estocada) | **Blink**: teletransporte curto (4 m), deixa um brilho que explode ao reaparecer | **Mergulho**: longo (7 m), atravessa inimigos, deixa uma esquiva extra | **Avanço de Escudo**: curto e pesado, empurra quem está na frente, 1 só carga e 19 quadros |
| Sala cheia | giro do 3º golpe (60 em volta) e a onda do Especial | Poder de área (Q) e Especial que atravessa; mantém todos à distância | pica o mais fraco, esquiva por dentro e some; poucos alvos por vez | a sala vem a ele: provoca, absorve, ecoa o dano em área |
| Chefe | combos longos de perto; Ômega em janela | dano à distância seguro; punição se erra o passo | pico de dano nas costas após a esquiva, janelas curtas | resiste ao chão que dói, devolve em onda; vence mais devagar e quase sem risco |
| Nota de risco | já aprovado, sem bloqueio nem aparo | fica forte demais se a distância sempre salva | pode quebrar em chefe com a Marca | não pode lembrar o aparo do Guerreiro nem virar parede passiva |

## 3. O que cada herói aproveita e o que pede código

Estimativa: P menos de 1 dia, M 2 a 4 dias, G mais de 4 dias de `gameplay-engineer` (inclui teste GUT, não inclui arte).

| Herói | Reaproveita como dado | Pede código novo | Total |
|---|---|---|---|
| Guerreiro | tudo; E nova pode ser **Grito de Guerra** (já existe `Effect.STUN`, `Ground.Kind.HOLY`, cargas de Ímpeto, `HeroGifts`) | slot `TECH` e a nova ação no `Player` | **P a M** |
| Maga | projéteis `Projectiles.Kind.ORB/BOLT`, `Combat.throw_wave`, `Ground.Zone` (zonas de dano e controle), status (queimar, gelar, vapor, atordoar), `Magick`, `UltDef`/`Ultimates` | arma de disparo (ataque que não é golpe de arco), carga de Brilho (recurso novo), eco do Passo de Luz, `HeroDef` próprio com combos e animação | **G** |
| Ladina | `ComboNode` (golpes curtos e rápidos, `both_ways`, `LINE`), esquiva como dado (`DashDef`/`Feel`), status | Marca e pontos de combo (recurso novo), esquiva atravessando inimigos, ataque pelas costas (ângulo no `Combat.hit_enemy`), reposicionar-se (Pulo de Sombra) | **G** |
| Paladino | `Ground.Kind.SHELTER`, `Kind.HOLY`, `Kind.STONE`, escudo do Salmo do Abrigo, atordoamento, `Combat.cast_burst`, `Ground.Zone.follow` (zona que anda com ele) | camadas de proteção (recurso novo, `Player` absorve), provocar (inimigos mudam de alvo: só há um alvo, então vira "atrair o ataque"), reflexo de dano | **M a G** |
| Compartilhado | | seletor de herói na descida, `HeroDef` por herói (com `buttons`), HUD por herói, Maestria por herói (já é `heroes.<id>` no save), slots de Bênção por papel, ação E e Shift no `Controls` | **M** |

## 4. Perguntas ao Daniel (no máximo 8)

1. **Mapa de botões por herói** (seção 1.1): ultimate no Shift (E no Paladino) e interagir passa ao F, ou a ultimate no R como 6º botão de todos? *Recomendo o mapa por herói.*
2. **A Maga e a Ladina são paladinas?** A premissa do jogo e o cânone dizem "paladinos do leão" (um por selo, do sangue de Hanokh, Ordem de Erukh). Elas serão paladinas de outras ordens (a Ordem tem "magias divinas"), companheiras ou aliadas? Não inventei nada. *Recomendo tratar os quatro como paladinos da Ordem e só variar a escola de treino (arma, luz, furtividade, escudo), sem texto até você decidir.*
3. **A Ladina** tem a "Andilla" no cânone (nome guardado, `canone.md`, linha 169). A Ladina de A Selagem é ela? *Recomendo perguntar antes de usar o nome; por enquanto "A Ladina".*
4. **Paladino e Guerreiro** são ambos de espada: o Paladino usa **maça e escudo de luz** em vez de espada, para a silhueta se separar do Guerreiro. Aprova? *Recomendo sim; o símbolo do Paladino também é o leão, o que sinaliza a ordem, e o escudo não é cruz.*
5. **Recurso do Guerreiro sem barra** (Fúria em cargas) vale para os outros? Maga com cargas de Brilho e Ladina com pontos de Marca são recursos próprios, pequenos, em losangos. *Recomendo sim: nenhum herói com segunda barra, todos com cargas visíveis.*
6. **Ordem de produção**: Paladino primeiro (reusa mais), depois Maga, depois Ladina? *Recomendo Paladino, Maga, Ladina: contrasta com o Guerreiro e deixa a Ladina, a de mais código, por último.*
7. **A Maga lança magia "de luz"** (alegoria: a luz vem de Elun, sem nome de poder com Elun). Chama, Geada e Luz são as famílias que já existem; a Maga usa as três. A fonte do poder dela fica sem explicação até você decidir? *Recomendo sim.*
8. **Equilíbrio entre heróis**: um mesmo mapa, os mesmos inimigos e chefe para os 4, ou um ajuste por herói (vida e dano)? *Recomendo o mesmo mapa e ajuste só de vida e dano por herói (campo da `HeroDef`).*
