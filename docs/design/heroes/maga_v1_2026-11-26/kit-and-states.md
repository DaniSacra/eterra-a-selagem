> Índice: [maga_v1_2026-11-26.md](../maga_v1_2026-11-26.md)

# Maga V1 (GP-5): especificação de implementação

- **Data**: 2026-11-26. **Autor**: `hero-designer`. **Só documento**: nada foi implementado. Dono da execução: `gameplay-engineer` (núcleo, jogo, dados) e
  `ui-ux-designer` (HUD, textos, telas). Números de protótipo para o `balance-designer` e o `combat-feel-director`.
- **Fontes lidas**: pacote `docs/design/packs_2026-11-26/herois_v1/` (00, 01, 03, 04), backlog (GP-5 e seção 6), `warrior_v1_2026-11-26.md` (contrato de
  botões, que esta spec reaproveita sem repetir), `bencaos_v2/IMPLEMENTACAO_V2.md` (estados celestiais) e o código do HEAD (`data/heroes/maga.tres`,
  `scripts/core/arcane_kit.gd`, `element_book.gd`, `converge_plan.gd`, `scripts/game/arcane.gd`, `ultimates.gd`, `tools/make_data.gd` `_maga*`,
  `save_data.gd`, `cel_rules.gd`, `dealt_by.gd`, `skills.gd`, `data/text_pt.tres`).
- **Decisões do Daniel (não reabertas)**: Maga com o kit do pacote, depois do Guerreiro e das Bênçãos V2; 30 de vida, 50 de Magia, regeneração natural
  2 por segundo (inclusive andando e esquivando), duas esquivas com recarga de 1 s e teleporte; esquerdo toque Centelha, esquerdo segurar Arco Voltaico,
  direito toque Estilhaço, direito segurar Geada, Shift Convergência Elemental (um Supremo, terceira fase útil); três reações; saem Combustão e Suspensão
  Arcana do kit básico; 12 Dons novos (Elementalismo, Conjuração, Feitiçaria) que substituem os 12 provisórios de 2026-11-24, com migração de save que
  devolve a Memória; no jogo o recurso é "Magia".
- **Regra desta especificação**: onde faltou decisão, escolhi o mais simples e registrei na seção 12 (D-1 a D-20). Sem perguntas ao Daniel.
- **Legenda de custo de código**: **D** só dado; **L** estatística nova lida por `Arcane` (uma a três linhas e teste); **N** comportamento novo.

## 0. O que o HEAD já tem (a maior parte do kit está pronta)

O redesenho de 2026-11-24 já pôs a Maga elemental no código. O GP-5 **não reescreve** a Maga: reposiciona botões, tira a Combustão e a Suspensão do kit,
troca custos e recargas, põe regeneração, e troca os 12 Dons. Já existem e ficam: `ElementBook` (estados e reações puras), `ConvergePlan`, `Arcane`
(Centelha, Geada, Arco, Estilhaço, pips), Passo Etéreo (2 cargas, 1 s, 4,5 m), `StatePips`, o modelo, o bastão e as animações.

| Item | HEAD | GP-5 |
|---|---|---|
| Vida, esquiva | 30; 2 cargas, 1,0 s, 4,5 m, 14 quadros protegidos | igual (confere com o pacote) |
| Magia máxima | 50 | igual |
| Regeneração natural | **não existe** (`Magick` não enche sozinha) | **2 por segundo**, sempre (novo, seção 3) |
| Esquerdo toque | Centelha 8, dá 1 de Magia por acerto | Centelha 8, **não gera Magia** |
| Esquerdo segurar | **Combustão** 35, explode em 2 m, 15 de Magia | **Arco Voltaico** 12 por alvo até 3, 10 de Magia |
| Direito toque | Estilhaço 6, **recarga 4 s**, sem custo | Estilhaço 6, **5 de Magia, sem recarga** |
| Direito segurar | Geada 20 de Magia | igual |
| Q | Arco Voltaico, recarga 8 s | **sem ação** |
| E | Suspensão Arcana, recarga 14 s | **só interagir** |
| Shift | Convergência 90 direto, carga 75 | igual, carga muda (seção 7) |
| Reações | Térmico 35, Sobrecarga 25 (1,8 m), Cristalização (0,8 s; Quebra 25 em resistente) | **iguais** (já batem com o pacote) |
| Dons | 12 provisórios (Faísca Persistente, Orvalho Gélido, ...) | **12 do pacote** (seção 8) |
| Magia por finalizador e por Quebra | `magick_on_finisher 1`, `magick_on_break 3` | **zerados** (pacote: não duplicar a recuperação antiga) |

## 1. Tabela slot, ação, números

Números do HEAD vêm de `tools/make_data.gd` (`_maga_tree`, `_maga`) e de `ArcaneKit`. "Pacote" é o baseline do `03_MAGA.md`. Tempos em segundos, distâncias em metros.
Toque e segurar seguem o `ButtonIntent` do Guerreiro V1 (limiar 0,20 s, a carga conta desde o aperto, esquiva cancela, custo só na execução, recusa com
`magick_refused`, sem queda silenciosa de segurar para toque).

| Slot | Gesto | Ação | Elemento | Dano | Custo (Magia) | Carga | Preparo | Recuperação | Alcance e forma | Origem |
|---|---|---|---|---|---|---|---|---|---|---|
| Esquerdo | toque | **Centelha** | fogo | 8 | 0 (não gera) | nenhuma | 0,10 | 0,15, pernas presas 0,20 | projétil de 30 m/s, até 11 m, para no primeiro inimigo | HEAD (só tira a Magia por acerto) |
| Esquerdo | segurar | **Arco Voltaico** | eletricidade | 12 por alvo, até 3 | 10 | 0,60 desde o aperto | 0,20 | 0,15, pernas presas 0,25 | o mais perto de 9 m, salta 5 m para o seguinte ainda não atingido | HEAD, passa do Q para o segurar |
| Direito | toque | **Estilhaço** | gelo | 6 | 5 | nenhuma | 0,16 | 0,22, pernas presas 0,30 | projétil de 26 m/s, **atravessa** todos, até 11 m | HEAD, ganha custo e perde a recarga de 4 s |
| Direito | segurar | **Geada** | gelo | 5 por segundo, 4 s (20 por alvo) | 20 | 0,60 desde o aperto | 0,18 | 0,25, pernas presas 0,35 | disco de 2,5 m no cursor (até 8 m da Maga), 4 s | HEAD |
| Espaço | toque | **Passo Etéreo** | | 0 | 0 | | | | teleporte de 4,5 m atravessando corpos, 0,233 s protegida, 2 cargas, cada uma volta em 1,0 s | HEAD |
| Shift | toque | **Convergência Elemental** | gelo, fogo, eletricidade | 90 no total | carga própria (seção 7) | | gesto protegido 0,3 | | 5 m (até 6,5) no cursor (até 9 m), 4,5 s | HEAD |
| E | toque | Interagir | | | | | | | | decisão |
| Q | | sem ação | | | | | | | | decisão |

Detalhes que a implementação não pode perder:

1. **Centelha** não dá Magia (`ArcaneKit.shot_magick` 1,0 vira **0,0**) e continua contando 3 acertos no mesmo alvo em 4 s para a Queimadura
   (`spark_hits 3`, `spark_window 4`, `ElementBook.count_hit`). O Dom Fluxo de Magia antigo (`shot_magick_add`) sai com os 12 provisórios.
2. **Arco Voltaico** deixa de ser o nó `arc` (entrada `SHOUT`, recarga 8 s) e passa a ser o nó do **segurar do esquerdo** (`In.CHARGE_LIGHT`, no lugar da
   Combustão). A Combustão **sai da árvore** mas o código dela (`Arcane._combust`, `combust_*` do `ArcaneKit`) **fica**, sem nó, para um Dom futuro, como pede o pacote.
3. **Estilhaço** perde `cooldown 4.0` e ganha `magick_cost 5.0` (D-3). O `Arcane.thrown`/`_step_shard` (duas cargas do Dom Estilhaço Gêmeo) fica sem uso até um Dom
   voltar a pedir. Nada a apagar.
4. **Geada**: o Frio é aplicado a cada `frost_step` (1 s), começando no instante da conjuração; no terceiro Frio seguido (`cold_freeze_at 3`) o comum congela 0,8 s.
   Isso é "Frio progressivo". Nada muda.
5. **Passo Etéreo**: só o nome no Livro (já é). A regeneração de Magia corre durante ele (seção 3).
6. **Movimento durante a carga**: a Maga é de longe e precisa andar enquanto carrega. `charge_move_light` e `charge_move_heavy` da Maga passam a **0,5** (dado em `_maga`,
   o padrão do Guerreiro fica 0,03 e 0,03). A trava de virada de carga do Guerreiro V1 vale para quem tem `charge_turn_light 0`; o da Maga fica **90 graus por segundo**
   (dado), porque a Geada mira no cursor e o Arco escolhe o alvo sem olhar a direção (D-4).
7. **Mira**: o Arco e a Geada continuam por `Arcane.cursor` (mouse no chão; com controle ou robô, o inimigo mais perto no cone de 65 graus, senão à frente a 60 por cento do alcance).
8. **Animações**: tudo usa `Cast` (já é). Nenhum clipe novo. O `art-director` pode dar ao Arco e à Geada um gesto próprio depois.

### 1.1 Tags e como cada ação entra nos sistemas existentes (dado, sem código novo)

`DealtBy.source` lê as tags na ordem **eco, salmo, habilidade, supremo, omega (heavy: especial, senão ataque), shout, dash, heavy, light, cast**.
Para o Poder cair no slot CAST da Bênção (como o Corte Circular do Guerreiro) o Estilhaço tem de levar `shout` e **não** `heavy`.

| Nó | `input` | Tags (do HEAD para o GP-5) | `DealtBy.source` | Slot de Bênção (`CelRules.slot_of`) | Gatilho (`Skills.trigger_of`) | Peso de Quebra |
|---|---|---|---|---|---|---|
| `spark` Centelha | LIGHT | `light bolt arcane fire` (igual) | attack | ATTACK | nenhum | 0,15 |
| `arc` Arco Voltaico | **CHARGE_LIGHT** | de `shout cast arcane volt` para **`omega light arcane volt`** | omega_attack | ATTACK | OMEGA | 1,0 |
| `shard` Estilhaço | HEAVY | de `heavy bolt arcane ice` para **`shout cast bolt arcane ice`** | shout | CAST (rótulo **Poder**) | SHOUT | 0,6 |
| `frost` Geada | CHARGE | `omega heavy cast arcane ice` (igual) | omega_special | SPECIAL (**Especial**) | OMEGA | 0,7 |
| Passo Etéreo | (esquiva) | | | DASH | DODGE | |
| Convergência | (Shift) | `ultimate cast` (igual) | ultimate | ULT | ULT | 1,0 |

- Os ticks da Geada e da Queimadura (tags `cast arcane ice`, `dealing elemental`) **não** entram em `slot_of`: Bênção não dispara por tique (conferido, seção 5).
- `Skills.trigger_of` lê `omega` primeiro: o Arco e a Geada disparam as habilidades de OMEGA; o Estilhaço dispara as de SHOUT (Poder). A tag `lance` do Guerreiro não vale aqui.
- A Bênção `needs_tag` (`spin`, `finisher`) segue sem ser oferecida à Maga (a Centelha não tem finalizador). Os poderes de ATTACK, CAST (Poder) e SPECIAL entram normalmente.
- **Sinal para o balance**: o Arco leva `omega_attack`, e o `Celestial` aplica ao Esmagador o coeficiente de contagem x2 e de taxa x1,5 (V2 2.1, item 3) por **fonte**
  `omega_attack`. Como o Arco acerta até 3 alvos, as Bênçãos de ATTACK do Frio, Veneno e Carga valem x2 em cada um dos 3. É forte, mas custa 10 de Magia; medir (seção 15).
  Alternativa de uma linha se passar do ponto: o coeficiente exclui nós com a tag `arcane`.

## 2. Ritmo de jogo, em segundos (medida de partida para o `combat-feel-director`)

| Ação | Tempo da ação | Magia | Magia por segundo de uso contínuo |
|---|---|---|---|
| Centelha | 0,25 (preparo 0,10 mais recuperação 0,15) | 0 | 0 (cerca de 32 de dano por segundo, só ela) |
| Estilhaço | 0,38 | 5 | 13 (a barra de 50 dá 10 tiros em 3,8 s; a regeneração dá 1 tiro a cada 2,5 s) |
| Arco Voltaico | 0,60 mais 0,35 = 0,95 | 10 | 10,5 (5 em 4,8 s; sustentado com a regeneração, 1 a cada 5 s) |
| Geada | 0,60 mais 0,43 = 1,03 | 20 | 19 (2 de barra; sustentado, 1 a cada 10 s) |

Leitura: a Maga **abre a sala** com a barra cheia (a Magia enche em toda sala, `rooms.gd`, Hades II; D-6) e gasta como quer; depois o piso é a Centelha (livre) mais 2 de Magia
por segundo, que paga um Estilhaço a cada 2,5 s. Para jogar rápido ela precisa **reações** (que o jogo recompensa com dano, Supremo e Dons de Magia), não só esperar a regeneração.
Esta é a leitura que a seção 15 mede ("a Maga é incentivada a jogar e não só esperar").

## 3. Economia de Magia

**Fontes** (valores do HEAD, salvo as marcadas):

| Fonte | Valor | Onde | Limite |
|---|---|---|---|
| **Regeneração natural** (nova) | **2 por segundo** | `HeroDef.magick_regen` (novo), somada em `Player` a cada passo | corre sempre com o jogo rodando: parada, andando, esquivando, conjurando; **não** corre com o herói morto nem na pausa |
| Inimigo comum derrotado | +1 | `MAGICK_PER_KILL` (`game.gd`) | nenhum (regra do jogo, vale para todo herói, D-7) |
| Elite derrotada | +40 | `MAGICK_PER_ELITE` | cabe na barra de 50 (a regra do Guerreiro que baixa a 24 é por herói; aqui fica 40, D-7) |
| Entrada de sala | enche tudo | `rooms.gd:526` | preservada (D-6) |
| Bênção Véu `essencia_restauradora`, Altar, Provação, `vigilia_longa` | como estão | | |
| **Centelha** | **0** (era 1 por acerto) | `ArcaneKit.shot_magick` | |
| **Quebra de postura e finalizador** | **0** (eram 3 e 1) | `HeroDef.magick_on_break`, `magick_on_finisher`, `passive_tags` vazio | pacote: não duplicar sem decisão |
| Reação (Dom Reciprocidade) | +2 por conjuração, uma vez | seção 8 | só com o Dom |

**O que sai**: `shot_magick` (vira 0), `magick_on_finisher`, `magick_on_break`, `passive_tags [finisher]`, `cd_floor` (piso de recarga de 6 s, sem recarga de Brado), os
dois `cooldown` (Estilhaço 4 s, Arco 8 s). `gain_cap` e `gain_window` ficam (ainda valem para Dons e Bênçãos que dão Magia).

**Código (L, núcleo)**: `HeroDef.magick_regen := 0.0` (grupo "Magia"), valor 2,0 em `_maga`. `Player.step` soma `magick.gain((hero.magick_regen + gifts.value(&"regen_add")) * dt)`,
**sem** passar por `KitFeed` (a regeneração não é "acerto", não tem teto de 3 por segundo). Teste: 5 s andando dão +10; 5 s esquivando dão +10; parada, +10; barra cheia não passa de 50;
morta não regenera. A Magia que **regenera não conta** para a carga do Supremo (a carga lê `Magick.spent`, só o que se gasta; D-9).

## 4. Os três estados e as três reações (o que o HEAD já faz e o que a spec trava)

`ElementBook` (puro, `scripts/core/element_book.gd`): por inimigo, `burn` (Queimadura 3 s, 4 por segundo), `cold` (Frio 3 s, 30 por cento de lentidão, `hits` até 3 congela comuns),
`volt` (Eletrizado 3 s). Aplicar um estado já presente **renova** (não soma). Duas condições no mesmo inimigo fazem **uma** reação, escolhida na ordem Térmico, Sobrecarga, Cristalização,
**consumindo só o par** dela, com intervalo `react_gap 0,5 s` por alvo. Reações não aplicam estado.

| Reação | Par | Efeito | Chefe, guardião, blindado |
|---|---|---|---|
| **Choque Térmico** | Fogo e Gelo | 35 de dano adicional | dano igual; chefe só leva a parte `converge_boss_share` na Convergência |
| **Sobrecarga** | Fogo e Elétrico | 25 de dano em área de 1,8 m (o alvo e quem está em volta; sem estado) | igual |
| **Cristalização** | Gelo e Elétrico | congela 0,8 s os comuns (0,32 s nos pesados, com o descongelar `THAW` de 1 s) | resistentes (chefe e armadura) recebem **Quebra** (`crystal_boss_poise 25`, peso 0,25 da fonte `crystal`) e não congelam |

Estas contas **já batem com o pacote** (35, 25 em 1,8 m, 0,8 s, Quebra 25, estados de 3 s, Queimadura 4, lentidão 30 por cento, congelar no terceiro Frio, intervalo 0,5 s). Nada de número novo.
O que a spec acrescenta é a **trava de recursão** e o contrato com as Bênçãos, abaixo.

### 4.1 Origem de uma aplicação (trava de recursão, código N pequeno)

`Arcane.apply_element(e, element, source := &"direct")`, `source` em `direct` (golpe do herói), `area` (tique da Geada, brasa, Confluência), `spread` (Propagação), `ult` (tique da Convergência).
Regras, todas por dado do estado, **sem laço**:

1. Uma reação provocada por `area`, `spread` ou `ult` **não** deixa brasa (Manifestação), **não** propaga (Propagação), **não** abre resíduo (Trindade) e **não** conta para a Transcendência
   nem para a carga do Supremo, salvo "uma vez por conjuração" na seção 7 e 8.
2. Uma aplicação `spread` nunca propaga de novo.
3. Brasa de Manifestação: no máximo **3** vivas (a mais velha sai), nunca nasce de uma reação `area`.
4. Intervalo `react_gap` (0,5 s) por alvo vale para tudo, inclusive reação tripla.
5. Todo estado e toda reação **limpam** na troca de sala, na morte do alvo e na morte da Maga (`ElementBook.clear`, `clear_all`, já existem; teste prova).

### 4.2 Ordem de aplicação em um golpe

Um golpe da Maga que acerta e **causa dano** (`Combat.hit_enemy` devolve falso, ou seja, não foi anulado nem bloqueado) faz, **nesta ordem**: dano do golpe, estados das Bênçãos (`Celestial.after_hit`),
elemento do golpe (`Arcane.apply_element`), reação. A recusa do Arcane usa o mesmo predicado que a V2 (decisão 11 do Daniel: só golpe que causa dano). O projétil (`shot_landed`) segue o mesmo
caminho; **teste obrigatório** de que um projétil absorvido pela guarda de um inimigo não aplica Frio nem Queimadura (hoje `shot_landed` só checa `alive` e `invulnerable`; conferir `Combat.on_shot_hit`).

## 5. Contrato com os estados das Bênçãos V2 (fonte única, sem dano em dobro)

**Princípio**: a Maga tem **dois livros de estados que não se leem**. O `Arcane` (`ElementBook`) guarda Queimadura, Frio e Eletrizado **dela**. O `Celestial` (`CelState` e os relógios do
`Enemy`: `burn_t`, `frozen_t`, `weak_t`, mais Veneno, Sangramento, Carga, medidor do chefe da V2) guarda os **das Bênçãos**. A V2 já diz "a Maga não muda" e "estados celestiais continuam separados do `Arcane`".
O pacote (04) pede "não duplicar estados Arcane/Celestial". As regras abaixo tornam isso **testável**.

| # | Regra | Como se garante |
|---|---|---|
| R-1 | Uma ação aplica **no máximo um** estado de cada livro por alvo: o elemento do nó (Arcane) e os estados do slot (Celestial). Nunca o Arcane aplica um estado "celestial" nem o contrário | `Arcane` só chama `ElementBook.apply`; `Celestial` só chama `apply_*` e `burn_for` de si. Teste de leitura por nome |
| R-2 | **Nenhuma conversão**: Queimadura do Arcane não conta como `burn_t`, Frio do Arcane não soma no medidor de Frio do chefe, Eletrizado do Arcane não é Carga de Saarael. Reação do Arcane **não** consome estado celestial e a Descarga/Saturação do Celestial **não** consome estado do Arcane | os campos são distintos; teste: Maga com Sarael (Queimadura celestial) e Estilhaço (Frio dela) **não** faz Choque Térmico |
| R-3 | **Dano**: a Queimadura e as reações do Arcane saem por `horde.dealing = &"elemental"`, que **não é golpe direto** (`CelRules.slot_of` dá NONE, `is_direct` falso). Logo **não** disparam `Celestial.after_hit`, crítico, Eco, Marca, antecipação, nem Eletrificação. O dano do `Celestial` (tiques de 0,5 s, `dealing` próprio) **não** passa pelo `ElementBook` | já assim no HEAD; teste: 100 reações não geram um único estado celestial |
| R-4 | **Golpe direto aplica uma vez**: o Arco acerta 3 alvos, cada um por `hit_enemy` com **seu** `once(...)` por ação e alvo (V2 2.1, dedupe). A Geada aplica o Frio dela por tique (tags `cast arcane ice`, não direto); as Bênçãos do slot SPECIAL aplicam **na conjuração**, uma vez, e não a cada tique | `slot_of` dos tiques é NONE |
| R-5 | **Congelamento é um relógio só**: o Frio cheio e a Cristalização do Arcane escrevem `Enemy.frozen_t` (e `thaw_t`), o mesmo que a Nivael já escreve. Isso é **sinergia desejada**: o Estilhaçamento da Nivael (`cel_shatter_pct`) estilhaça um alvo congelado pela Maga, **uma vez por congelamento** (o `frozen_t` zera e o `thaw_t` impede o ciclo, como a V2 já exige). Mas o Frio dela **não soma** no medidor de Frio do chefe (R-2) e **nunca** congela chefe (`resists`) | teste |
| R-6 | **Condições distintas contam em dois lugares sem se tocar**: `CelState.diversity` (Fogo Crescente, Vulnerabilidade, Essência Restauradora) **não conta** os estados do Arcane. Contá-los seria pós-V1 (D-12) | teste de leitura |
| R-7 | **Mesma cor, não confundir**: Queimadura, Frio e Eletrizado do Arcane usam os pips do `StatePips` com as cores `ElementLook`; as do Celestial usam os ícones da V2. A Eletrificação de Saarael (V2) chama-se **Carga** na tela da Maga e **Eletrizado** é só o do Arco dela, para os dois nomes não colidirem no texto (o pacote chama o do Arco de "Eletrificação": D-13) | `data/text_pt.tres` |
| R-8 | **Chefes e guardiões**: o Arcane segue como hoje (Queimadura e Eletrizado aplicam, Frio só lentidão, Cristalização vira Quebra com peso 0,25, a Convergência dá `converge_boss_share` 0,25). O medidor de Abertura da V2 **só** soma Frio e Impacto celestiais | sem mudança de código |
| R-9 | **Quem dá o dano de reação soma o Dom Catalisador (+30 por cento) uma vez**, nunca duas: o fator entra no `Reaction.damage` na criação (`react_pct`), não de novo no `_elemental_hit` | teste |

**Bênçãos por botão na Maga** (o mapeamento da V2, sem mudança de dado; cada uma já lê a **fonte** da ação, nunca uma tag ambígua):

| Botão | Gesto | Slot de Bênção | Exemplo do que a Bênção faz |
|---|---|---|---|
| Esquerdo | toque (Centelha) | Ataque | Sarael: a Centelha queima (Queimadura celestial **separada** da dela); Zerael: Veneno por acúmulo; Saarael: Carga |
| Esquerdo | segurar (Arco) | Ataque (coeficiente x2 de contagem, ver sinal na 1.1) | idem, em cada um dos 3 alvos |
| Direito | toque (Estilhaço) | Poder | Nivael `circulo_geada`: gelo em 3 m ao redor do ponto que o projétil atinge |
| Direito | segurar (Geada) | Especial | Nivael `toque_geada`: 2 de Frio na conjuração; Galael `pesado_mare`: leque na conjuração |
| Espaço | Passo Etéreo | Esquiva | `clarao`, `passo_*` agem no teleporte |
| Shift | Convergência | Supremo | Nivael `peso_inverno` etc.: aplicam **uma vez** na conjuração, nunca por tique (`slot_of` do tique é NONE) |

**Duas casas a conferir na integração** (não bloqueiam): (a) o `CAST` da Maga era o Arco; as Bênçãos de CAST que miram "no meio do herói" (`circulo_*`) agora disparam no ponto de **impacto do Estilhaço**,
não em volta da Maga (o gatilho `SHOUT` da Maga muda de lugar: dizer no texto do Livro, D-14); (b) as Bênçãos `RUSH` do catálogo antigo seguem `reserve`.

## 6. Passiva e leitura na tela

A passiva da Maga é **Reações** (sempre ligada, sem botão): `hero_passive_maga` já existe. Texto e HUD abaixo (seção 10). Não há Ritmo de Batalha nem Fúria. Não existe postura.

## 7. Supremo: Convergência Elemental por fases

`ConvergePlan` e `Ultimates._step_converge` já fazem: **3 fases de 1,5 s** (gelo, fogo, eletricidade), tique a cada 0,5 s (9 tiques), 90 de dano direto no total (10 por tique), 5 m de raio
(até 6,5 se o Dom aumentar), 4,5 s, no cursor até 9 m; chefe leva 25 por cento (`converge_boss_share`), elite metade, guardião 25 por cento (`def.converge_share`); o chefe não recebe elemento
(CF-07, sem rajada de reação sobre ele). No fim, no 8º tique o fogo e no 9º o gelo são reaplicados.

**Pergunta do pacote: o consumo de estados nas fases anteriores torna a terceira fase inútil?** Não, com o `react_gap` de 0,5 s do HEAD e a duração de 3 s dos estados. A conta tique a tique
(`i` de 0 a 8, tique em `0,5 i` segundos):

| Tique `i` | Fase | Elemento aplicado | Estado do alvo (ordem do `ElementBook`) | Reação |
|---|---|---|---|---|
| 0, 1, 2 | gelo | Frio | Frio com 1, 2 e 3 acertos | congela no 3º (comuns) |
| **3** | fogo | Fogo | Fogo e Frio | **Choque Térmico** (35), consome os dois |
| 4, 5 | fogo | Fogo | só Fogo (renova 3 s) | nenhuma |
| **6** | eletricidade | Eletrizado | Fogo ainda vivo (renovado no tique 5) | **Sobrecarga** (25, 1,8 m), consome Fogo e Eletrizado |
| **7** | eletricidade e fogo | Eletrizado, depois Fogo | Eletrizado, depois Fogo | **Sobrecarga** de novo (intervalo 0,5 s respeitado) |
| **8** | eletricidade e gelo | Eletrizado, depois Gelo | Eletrizado, depois Gelo | **Cristalização** (congela 0,8 s ou Quebra) |

A terceira fase produz **3 reações** (Sobrecarga, Sobrecarga, Cristalização). A solução é a **sobra de Fogo** da fase dois (a Queimadura dura 3 s, mais que a fase de 1,5 s). **Registrar em
teste** (`test_converge`: reações em ordem `[THERMAL em 3, OVERLOAD em 6, OVERLOAD em 7, CRYSTAL em 8]` sobre um alvo comum) e **travar** os números `converge_phase 1.5`, `converge_tick 0.5`,
`react_gap 0.5`, `burn_time 3.0` com um teste de relação: `burn_time >= converge_phase + converge_tick` (se alguém baixar a Queimadura para 1,5 s a terceira fase perde a Sobrecarga e o teste reprova).
Efeito dos Dons: Afinidade só alonga os estados (melhora); Catalisador soma dano; Trindade troca o tique 6 pela reação tripla (Sobrecarga mais Cristalização de uma vez) sem perder os tiques 7 e 8 (testado).

**Carga do Supremo** (pacote: "carga própria por reações efetivas, limitar por conjuração, nunca recarregar com as próprias reações"):

| Fonte | Peso | Limite |
|---|---|---|
| Magia gasta (`Magick.spent`) | 1 de carga por 1 de Magia (HEAD) | |
| Dano causado (`damage_charge 0,03`) e vida perdida (`hurt_charge 1,0`) | HEAD | |
| **Reação efetiva** (nova) | **5** por reação | **no máximo 10 por conjuração** (`react_charge_cap`), contando só reações com `source direct` e `spread`; reações de `area` valem **uma vez por conjuração de área** (a Geada dá no máximo 5 de uma vez); **nenhuma carga** enquanto a Convergência roda (as reações dela, do tique 3 em diante, não carregam o próximo Supremo) |

`UltDef.charge` passa de 75 para **60** (D-10; a Maga gasta pouca Magia por segundo, e o pacote pede que as reações encham o Supremo). O balance decide entre 60 e 75 com o medidor da seção 13.
Código **L**: `Arcane` guarda `react_charge` (total corrente) e a trava; `Ultimates.step` soma `charge.feed_from(&"react", game.arcane.react_charge, 1.0, rate)` ao lado da Magia e do dano, e
`Arcane` não incrementa o total quando `game.ultimates.vortex != null` (a Convergência rodando). Conjuração é o `Arcane._serial` (inteiro que sobe a cada projétil lançado, Arco, Geada;
fica fixo para os ticks da Geada, que são uma conjuração só).

**Um Supremo por bastão**: o `HeroDef.ultimates` da Maga tem um só (`00_converge`); nenhum seletor.
