# A Selagem comparada com Hades, Hades II e Ember & Blade

Para que serve: deixar claro o que cada referência nos dá e onde A Selagem está. Atualizar a cada sistema novo.

## A regra (decisão do Daniel, 2026-11-14 e 2026-11-15)

- **Hades II: copiamos as mecânicas e os números**, fielmente, para ter uma base boa para construir e evoluir em
  cima. Nomes, personagens, história, interface, sons e arte são sempre nossos.
- **Ember & Blade: copiamos a sensação visual** (cenário escuro e calmo, efeitos que estouram, tinta e meia-lua dos
  cortes), com arte toda nossa (`docs/arte/estetica.md`).
- **Hades (o primeiro)**: só como referência de onde vieram os sistemas do Hades II.
- **Eterra manda no tema**: só Yah e Elun (sem deuses). As famílias de dons são dos quatro paladinos
  (`PALADIN_1` a `PALADIN_4`). Lore só do cânone (`../dungeon-rpg/docs/mundo/canone.md`) ou do Daniel.

## Visão geral

| | Hades | Hades II | Ember & Blade | A Selagem |
|---|---|---|---|---|
| Gênero | roguelite de ação, salas | roguelite de ação, salas | ação em horda, combos | roguelite de ação em salas, com horda |
| Herói | Zagreus foge do submundo | Melinoë desce (ou sobe) para derrotar Cronos | (não estudado) | um paladino (o Explorador) desce às catacumbas de Valmor para selar Morvath |
| Câmera | isométrica | isométrica | alta e inclinada | inclinada 30°, girada 35°, campo de visão 24, distância 54 (`Feel`) |
| Visual | pintado, colorido | pintado, colorido | escuro, frio, efeitos brancos | o do Ember & Blade, com a arena da pintura do Daniel |

## Estrutura da partida

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Regiões | 4 em sequência (Tártaro, Asfódelos, Elísio, Templo do Estige) | duas rotas de 4 regiões (Submundo e Superfície) | 1 região (as catacumbas); a fase 2 seria a próxima |
| Salas | combate em ondas; a porta mostra a recompensa | igual | igual (`RunMap`, `EncounterGen`) |
| Minichefe | guardiões no meio da região | igual | guardião entre as salas 4 e 6 (Cavaleiro ou Ancião) |
| Fonte, loja | fonte de cura, loja do Caronte | igual | fonte entre 5 e 8, loja na 10 (pisar compra) |
| Chefe | fim de cada região, com fases | igual | Morvath na sala 11, três fases (vida 6050 e dano na escala da 1ª chefe do Hades II; ataques próprios) |
| Teste | | | **encurtado**: fonte na 2, guardião na 3, loja na 4, Morvath na 5 |
| Entre partidas | casa de Hades: espelho, contratos, Pacto | Encruzilhada: cartas de Arcana, encantamentos, Votos | **ainda não existe**: cada partida começa do zero |
| Dificuldade extra | Pacto de Punição (Calor) | Votos da Noite (Medo) | não existe |

## Combate

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Ações | ataque, especial, conjurar (pedras de sangue), avanço, chamado | ataque, especial, conjurar (círculo que prende), avanço e corrida | ataque (E), especial (D), círculo de luz (Q), avanço e corrida (segurar) |
| Recurso | barra de chamado | Magia, que paga as versões Ômega | Magia (`Magick`), enche em toda sala e por abate |
| Versões carregadas | não | Ômega: segurar o botão | Ômega de ataque (0,8 s, 20 Magia), especial (0,65 s, 10) e círculo |
| Números | | ataque em 3 (20, 25, 60), especial 40, avanço 0,2 s, vida 30 | os mesmos, convertidos (80 unidades do Hades = 1 m) |
| Inimigos | por região | por região, com elites com armadura | nove mortos-vivos nossos com os números do Érebo; elites com armadura (barra amarela) que atordoa ao quebrar |
| Avisos | no chão | no chão | todo ataque inimigo tem aviso no chão |
| Impacto | pausa curta, tremor | pausa curta, câmera lenta no último abate e no chefe | sem pausa (medido no Ember & Blade), meia-lua de tinta, quadro de impacto, câmera lenta como no Hades II |
| Combos | sequência fixa por arma | sequência fixa por arma | árvore no molde do Ember & Blade (pesado depois de 1 a 4 leves muda o finalizador) |
| Armas | 6, com aspectos | 5 ou mais, com aspectos | uma espada (a Emeth) |

## Dons

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Quem dá | deuses do Olimpo | deuses do Olimpo | quatro famílias, uma por paladino: Chama, Geada, Luz, Vigília |
| Um por ação | sim | sim (mais o ganho de Magia) | sim: ataque, especial, círculo, esquiva; o novo substitui o antigo |
| Passivos | sim | sim | sim (brasas, redemoinho, onda, meteoro, escudo etc.) |
| Raridade | comum a heroica | comum a heroica | três níveis que multiplicam os números |
| Duplos | dons duplos (dois deuses) | dons duplos | **Elo** (mecânica das Crônicas de Eterra): 6 hoje, com a corrente ligando os dois dons na carta e no painel "Dons" da pausa, e o aviso "Elo formado" |
| Lendários | sim | sim | falta |
| Subir o nível de um dom | romã | romã | falta |
| Infusões (exigem X de um elemento) | não | sim | falta |
| Mudar a arma | martelo de Dédalo | martelo de Dédalo | falta |
| Bênção com maldição | Caos | Caos | falta |
| Feitiços de caminho | não | Selene | falta |
| Bônus de sequência de golpes | não | não | **temos** (`DamageCalc.combo_bonus`), herança das versões antigas |

## Próximos passos (na ordem)

1. **Elo**: feito em 2026-11-15 (nome, corrente na carta e no painel, aviso "Elo formado"); falta o teste do Daniel.
2. Levantar com cuidado as regras e os números dos sistemas que faltam no Hades II (romã, lendários, infusões,
   martelo, Caos, feitiços, progressão entre partidas, Votos) e propor ao Daniel a versão de Eterra antes de
   implementar.
3. Fase 2: próxima região, inimigos novos (as criaturas aberrantes estudadas ficaram reservadas para ela), chefe novo.
