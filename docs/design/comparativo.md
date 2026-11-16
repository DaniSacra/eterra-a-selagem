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
| Gênero | roguelite de ação, salas | roguelite de ação, salas | ação em horda, combos | roguelite de ação em salas, com poucos inimigos de papel claro (não é survivor de horda; o Daniel, 2026-11-15) |
| Herói | Zagreus foge do submundo | Melinoë desce (ou sobe) para derrotar Cronos | (não estudado) | o Guerreiro (modelo `hero_explorer`; título pendente, D-64) desce às catacumbas de Valmor para selar Morvath |
| Câmera | isométrica | isométrica | alta e inclinada | inclinada 30°, girada 35°, campo de visão 24, distância 54 (`Feel`) |
| Visual | pintado, colorido | pintado, colorido | escuro, frio, efeitos brancos | o do Ember & Blade, com a arena da pintura do Daniel |

## Estrutura da partida

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Regiões | 4 em sequência (Tártaro, Asfódelos, Elísio, Templo do Estige) | duas rotas de 4 regiões (Submundo e Superfície) | 1 região (as catacumbas); a fase 2 seria a próxima |
| Salas | combate em ondas; a porta mostra a recompensa | igual | igual (`RunMap`, `EncounterGen`) |
| Inimigos de pé ao mesmo tempo | poucos, em ondas | poucos, em ondas | ciclo 8: comum 4 a 8, difícil 8 a 12 (guardião, elites), especial 12 a 16, nunca mais de 20 contando invocações; Morvath com até 4 invocados fora do ritual e 6 no ritual (`BossDef.adds_cap`, `ritual_cap`). O teto de cada sala sobe do mínimo ao máximo da faixa ao longo da região; cada onda cabe na faixa e a próxima vem quando resta 1 (`StageDef.tier_alive`, `alive_cap`) |
| Composição | tipos por região | tipos por região, sorteados pela dificuldade | por papel (`EnemyDef.role`: esqueleto pressiona, corredor pede reação, feiticeiro controla espaço, besteiro força andar de lado, Escudo bloqueia a frente, sacerdote ameaça áreas) em conjuntos de dado (`EncounterPool`): no começo da região 2 papéis simples, no meio 3 que se completam, no fim misturas exigentes com elites e uma sala especial rara de 4 papéis |
| Minichefe | guardiões no meio da região | igual | guardião entre as salas 4 e 6 (Cavaleiro ou Ancião) |
| Fonte, loja | fonte de cura, loja do Caronte | igual | fonte entre 5 e 8, loja na 10 (pisar compra) |
| Chefe | fim de cada região, com fases | igual | Morvath na sala 11, quatro fases em 66, 33 e 15% (pedido do Daniel de 2026-11-15; vida 6050 e dano de 6 a 12, na escala da 1ª chefe do Hades II; ataques próprios: foice, lâminas das almas, ritual com escudo e invocados (o escudo cai quando os 4 primeiros mortos caem; os reforços pressionam sem contar, ciclo 10; na barra dele um losango por morto que falta e "Derrube os mortos" embaixo), erupções, maldição, tempestade das seis almas; diretor de ataques; números em `data/bosses/morvath.tres`) |
| Arena do chefe | sala própria de cada chefe | arena própria, redonda nos chefes de região | ciclo C11: Morvath luta na Câmara do Selo, um círculo de 12,5 m (o centro do herói anda até 12 m do selo; raio calculado pela mecânica em `docs/design/boss_arena.md`); a borda é a única colisão, os avisos dele param nela, as meias-luas se desfazem logo depois dela, a investida só com 8 m livres, ritual, maldição e tempestade abertos do meio, câmera com alvo fixo e no máximo 3 m de desvio; as salas comuns seguem no salão retangular |
| Salas de luta | cada bioma com várias salas desenhadas à mão, com buracos, pontes e cobertura; a mesma sala com arrumações diferentes | igual | ciclo C12 (Arenas I): o Salão das Catacumbas abre a partida e recebe a fonte e a loja; as lutas depois dele são sorteadas entre a Cripta dos Esquecidos (pequena, colunas e sarcófagos como cobertura, 4 a 6 inimigos, no máximo 2 atiradores, sem sacerdote), o Salão das Fendas (grande, fenda com duas pontes de 5 m, câmera que anda) e o Jardim das Raízes Mortas (tronco de pedra que barra corpo e tiro, raízes baixas), nunca a mesma duas vezes seguidas, cada uma com 2 variantes. Tudo em dado (`RoomLayout`: chão com buracos, obstáculos, zonas de nascimento, saídas, caixa da câmera); peça com topo acima de 1,25 m para o tiro, até 1,0 m o tiro passa por cima; inimigos andam pela grade `NavGrid` e um campo de fluxo; nada cai no abismo ainda (D-28). Descida de teste com 7 salas (D-27); o visual das três é provisório (cinza) |
| Teste | | | **encurtado**: fonte na 2, guardião na 3, loja na 4, Morvath na 5 |
| Entre partidas | casa de Hades: espelho, contratos, Pacto | Encruzilhada: cartas de Arcana, encantamentos, Votos | **ainda não existe**: cada partida começa do zero. Planejado (diretriz de 2026-11-16, entrega E2): Maestria do herói que destrava Dons permanentes, equipados com capacidade e custo no molde das Arcana (`docs/design/guardian_spec.md`) |
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
| Hit stop | (não estudado) | o mundo segue 25 a 70 ms depois do acerto (`ScreenPreWait`), cai a 6% por 10 ms (50 com abate) e volta em 20 ms; recarga 0,3 s | igual desde o C12d (`HitStop`, `ComboNode.hit_stop_ms`, `hit_slow_ms`, `hit_slow_scale`); antes era congelamento |
| Entrada | (não estudado) | a esquiva corta a carga do golpe; o golpe apertado na esquiva vira o golpe da esquiva; a trava de gatilho guarda o aperto até o golpe poder sair | igual desde o C12d: esquiva corta a preparação (golpe cortado não acerta), ataque e especial apertados na esquiva ou ferido saem no fim, o buffer só conta quando o golpe pode sair; o controle virtual guarda o toque como o teclado. Nosso: a esquiva sai no quadro do aperto (D-44), protege 19 quadros como lá |
| Especial (seta) | | dardo a 62,5 m/s; ataque livre 18 quadros depois, especial 0,7 s; pernas presas 0,71 s, só a esquiva corta | igual desde o C12d (`ComboNode.cooldown`, `root_time`, D-44) |
| Círculo | | sem proteção, 8 quadros sem atacar | igual desde o C12d (`Player.CAST_ATTACK_LOCK`, D-44) |
| Ômega do ataque | | dispara ao encher (0,8 s) | igual desde o C12d: preparação e brilho dentro da carga |
| Impacto | | tremor de 0,05 m; clarão 0,03 s vermelho; vibração por golpe | nosso (D-43): tranco 0,09 m no golpe comum, maior no finalizador (0,32) e no Ômega (0,56); clarão morno 0,05 s; câmera lenta rara de vários abates depois do hit stop; vibração por golpe (opção `rumble`); som de lâmina no começo de cada golpe e de carga no Ômega |
| Virar | | direção na hora, corpo a 1340 graus/s | igual desde o C12d |
| Corpos | sólidos | sólidos (`StopsUnits`; inimigo comum em losango de 1,6 x 0,8 m); andando ela para ao encostar e não empurra, o avanço (BLINK) atravessa; alguns tipos são atravessáveis | os mesmos: sólidos (círculos de `EnemyDef.radius`), o paladino para e desliza no contorno, os inimigos param no corpo dele, só a esquiva atravessa (`BodyBlock`); `EnemyDef.blocks_body` para tipos atravessáveis (nenhum ainda) |
| Inimigos de longe | ficam longe e atiram | Mage: rajada de 3 orbes que perseguem (7 m/s, 13,1 m), recua com o tranco e se esconde atrás de colunas 1,5 a 2,2 s; Screamer: cone de perto e foge 8,75 m; SiegeVine: parada, trepadeira que rasteja atrás dela por 12 s | os números do Mage no mago e da SiegeVine no sacerdote; o besteiro atira um virote (pedido do Daniel) e do Screamer leva a fuga depois do ataque e o limite de 2; todos fogem quando o paladino chega (nosso). Círculos no chão só de Morvath (2026-11-16) |
| Impacto | pausa curta, tremor | pausa curta, câmera lenta no último abate e no chefe | sem pausa (medido no Ember & Blade), meia-lua de tinta, brilho de 0,08 s na lâmina antes de cada finalizador, câmera lenta como no Hades II; quadro de impacto em preto e branco só no Ômega que acerta e no golpe que derruba uma fase do chefe, no máximo um a cada 10 s, com opção para desligar (ciclo 10, decisão D-08). Golpe sofrido: só as bordas da tela avermelham por 0,22 s (alfa até 0,42 nos cantos, metade abaixo de 10 de dano; separação de cores pequena só nos fortes); amaldiçoado, borda violeta (alfa 0,2 por 0,2 s) sem separação (`HurtTint`, números em `Feel`) |
| Opções de conforto | tremor | tremor, clarões | Configurações (ciclo 10): tremor de câmera, clarões de impacto, câmera lenta (com o zoom e o desfoque dela) e separação de cores, todas ligadas por padrão e salvas (`OptionsScreen.COMFORT`, `Game.apply_options`) |
| Combos | sequência fixa por arma | sequência fixa por arma | árvore no molde do Ember & Blade (pesado depois de 1 a 4 leves muda o finalizador) |
| Armas | 6, com aspectos | 5 ou mais, com aspectos | uma espada (a Emeth) |

## Dons (para o jogador, desde a diretriz de 2026-11-16: **Bênçãos**; "Dom" passa a ser o talento permanente do herói)

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

## Medir com gente

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Registro das partidas | (interno, não publicado) | (interno, não publicado) | ciclo 10: `user://runs.jsonl`, uma linha por partida de gente (vitória, morte ou saída) com o RESULT, os dons, o controle, Ômegas, esquivas e o que feriu por último; nada sai do computador (`RunLog`) |
| O que matou | tela de morte com o nome do inimigo | igual | ciclo 10: a lógica guarda o ataque de Morvath ou o tipo de inimigo (`Game.defeated_by`, chaves `killer_*`) e a tela de derrota mostra "Derrotado por: Foice Sepulcral" logo abaixo do título (`EndScreen`) |

## Próximos passos (na ordem)

1. **Elo**: feito em 2026-11-15 (nome, corrente na carta e no painel, aviso "Elo formado"); falta o teste do Daniel.
2. Levantar com cuidado as regras e os números dos sistemas que faltam no Hades II (romã, lendários, infusões,
   martelo, Caos, feitiços, progressão entre partidas, Votos) e propor ao Daniel a versão de Eterra antes de
   implementar.
3. Fase 2: próxima região, inimigos novos (as criaturas aberrantes estudadas ficaram reservadas para ela), chefe novo.
