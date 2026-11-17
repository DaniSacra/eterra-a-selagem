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
| Fonte, loja | fonte de cura, loja do Caronte | igual; loja com um item de cada grupo (Bênção; cura e vida; crescimento), 5 itens na última antes do chefe final | fonte entre 5 e 8, loja na 10 (pisar compra) com 5 itens de 3 grupos desde a E3 (Bênção 150; cura 50 e coração 125; dois de Magia 100, romã 100, fatia de romã 50) |
| Recompensas das portas | | baralho sem repor que volta inteiro (`RunProgress`) | igual desde a E3 (`RewardDeck`: 6 Bênçãos, 2 romãs, 2 corações, 2 Magia, 2 ouro; sem martelo, Selene e caminho das estrelas) |
| Ouro | | 10 a 15 por encontro + 0,5 por profundidade, 70% por inimigo da parte dele; recompensa 100 | igual desde a E3 (`GoldPurse`) |
| Chefe | fim de cada região, com fases | igual | Morvath na sala 11, quatro fases em 66, 33 e 15% (pedido do Daniel de 2026-11-15; vida 6050 e dano de 6 a 12, na escala da 1ª chefe do Hades II; ataques próprios: foice, lâminas das almas, ritual com escudo e invocados (o escudo cai quando os 4 primeiros mortos caem; os reforços pressionam sem contar, ciclo 10; na barra dele um losango por morto que falta e "Derrube os mortos" embaixo), erupções, maldição, tempestade das seis almas; diretor de ataques; números em `data/bosses/morvath.tres`) |
| Arena do chefe | sala própria de cada chefe | arena própria, redonda nos chefes de região | ciclo C11: Morvath luta na Câmara do Selo, um círculo de 12,5 m (o centro do herói anda até 12 m do selo; raio calculado pela mecânica em `docs/design/boss_arena.md`); a borda é a única colisão, os avisos dele param nela, as meias-luas se desfazem logo depois dela, a investida só com 8 m livres, ritual, maldição e tempestade abertos do meio, câmera com alvo fixo e no máximo 3 m de desvio; as salas comuns seguem no salão retangular |
| Salas de luta | cada bioma com várias salas desenhadas à mão, com buracos, pontes e cobertura; a mesma sala com arrumações diferentes | igual | ciclo C12 (Arenas I): o Salão das Catacumbas abre a partida e recebe a fonte e a loja; as lutas depois dele são sorteadas entre a Cripta dos Esquecidos (pequena, colunas e sarcófagos como cobertura, 4 a 6 inimigos, no máximo 2 atiradores, sem sacerdote), o Salão das Fendas (grande, fenda com duas pontes de 5 m, câmera que anda) e o Jardim das Raízes Mortas (tronco de pedra que barra corpo e tiro, raízes baixas), nunca a mesma duas vezes seguidas nem mais de 3 vezes na descida (E3), cada uma com 2 variantes. Desde a E5 mais três: o Santuário Desmoronado (grande, casa do guardião, nave com colunas e corredores laterais), a Ponte dos Condenados (longa, três plataformas ligadas por pontes de 5 m, portas só na plataforma de longe, sem sacerdote) e a Câmara das Runas Instáveis (chão que fere em faixas, 4 a 6 inimigos, câmera fixa); visual provisório até o artista de cenário. Tudo em dado (`RoomLayout`: chão com buracos, obstáculos, zonas de nascimento, saídas, caixa da câmera); peça com topo acima de 1,25 m para o tiro, até 1,0 m o tiro passa por cima; inimigos andam pela grade `NavGrid` e um campo de fluxo; nada cai no abismo ainda (D-28). Descida de 10 salas desde a E3 (a de 7 do D-27 é `--medium`); o visual das três é provisório (cinza) |
| Teste | | | descida inteira de 10 salas e Morvath na 11 desde a E3; `--medium` a de 7 (C12), `--short` a de 5 |
| Entre partidas | casa de Hades: espelho, contratos, Pacto | Encruzilhada: cartas de Arcana, encantamentos, Votos | **fundação feita (E2a)**: a Maestria do Guerreiro soma XP no fim de toda partida (vitória, morte, saída) e fica no save (versão 3); árvore de 19 Dons com Devoção (5 + nível) no molde das Arcana, regras testadas; os 19 Dons e a passiva (2 de Magia por finalizador que acerta) agem desde a E2-07/E2-09 (`GiftState`, `HeroGifts`), ainda sem tela para equipar (`docs/design/warrior_spec.md` 4.5). E6: o Ainda de Pé (o desafio à morte, que no Hades II vale também no chefe) não levanta na sala de Morvath, para a Maestria 20 ficar até 25 pontos acima da 1 (`docs/design/e6_balance.md`) |
| Salas de evento | fontes, Caronte, Caos, poço | idem, mais Arachne, Narciso, Eco, Medeia, Ícaro | E5: Provação (o Caos), Altar Esquecido (sala curta sem luta, uma troca: 10 de vida máxima por uma romã ou 75 de ouro por 25 de Magia máxima; uma vez por descida, profundidades 2 a 8, 20%); portas que mostram o caminho: a luta atrás de cada porta é sorteada antes de abrir e a placa diz "Difícil" (elite) ou "Guardião" (`Rooms.door_info`) |
| Armadilhas de sala | espinhos, barris, armadilhas de dardo | idem, pisos que se acendem | E5: Câmara das Runas Instáveis, ladrilhos de 3 m em faixas e blocos (nunca círculos) que avisam 1,2 s em âmbar, ferem 0,25 s e descansam 2,4 s; no máximo 35% aceso, sempre um ladrilho apagado vizinho; fere herói (4) e inimigos (35) (`ArenaHazard`) |
| Dificuldade extra | Pacto de Punição (Calor) | Votos da Noite (Medo) | não existe |

## Combate

| | Hades | Hades II | A Selagem |
|---|---|---|---|
| Ações | ataque, especial, conjurar (pedras de sangue), avanço, chamado | ataque, especial, conjurar (círculo que prende), avanço e corrida | ataque (E), especial (D), círculo de luz (Q), avanço e corrida (segurar) |
| Recurso | barra de chamado | Magia, que paga as versões Ômega | Magia (`Magick`), enche em toda sala e por abate |
| Versões carregadas | não | Ômega: segurar o botão | Ômega de ataque (0,8 s, 20 Magia), especial (0,65 s, 10) e círculo |
| Números | | ataque em 3 (20, 25, 60), especial 40, avanço 0,2 s, vida 30 | os mesmos, convertidos (80 unidades do Hades = 1 m) |
| Inimigos | por região | por região, com elites com armadura | nove mortos-vivos nossos com os números do Érebo; elites com armadura (barra amarela) que atordoa ao quebrar; atordoamento 0,5 e 1,1 s, janela parada depois do golpe (`recover_time`, Guard 2,1 s) e corpo virado para onde anda, como no Hades (E1c); T5: preparação em três tempos com o corpo (assentar, armar, segurar com tremor), dano do corpo nas investidas e no bote, recuperação viva e o esqueleto esperando em anel |
| Avisos | no chão | no chão | todo ataque inimigo tem aviso no chão |
| Hit stop | (não estudado) | o mundo segue 25 a 70 ms depois do acerto (`ScreenPreWait`), cai a 6% por 10 ms (50 com abate) e volta em 20 ms; recarga 0,3 s | igual desde o C12d (`HitStop`, `ComboNode.hit_stop_ms`, `hit_slow_ms`, `hit_slow_scale`); antes era congelamento |
| Entrada | (não estudado) | a esquiva corta a carga do golpe; o golpe apertado na esquiva vira o golpe da esquiva; a trava de gatilho guarda o aperto até o golpe poder sair | igual desde o C12d: esquiva corta a preparação (golpe cortado não acerta), ataque e especial apertados na esquiva ou ferido saem no fim, o buffer só conta quando o golpe pode sair; o controle virtual guarda o toque como o teclado. Nosso: a esquiva sai no quadro do aperto (D-44), protege 19 quadros como lá |
| Golpe parado | | cajado: nenhum avanço; carga 0,06 / 0,11 / 0,36 s, ataque livre 8 / 13 / 18 quadros, pernas presas 11 / 19 / 30 quadros que só a esquiva corta; andar só corta o clipe de retorno; gira para o inimigo mais perto (4,9 a 6,1 m, arco de 130 graus) | igual desde a E1c (preparação 0,08 / 0,13 / 0,36, `recovery`, `move_hold`); antes avançava até 2,5 m além do passo e andar cortava o golpe depois do acerto |
| Especial (seta) | | dardo a 62,5 m/s; ataque livre 18 quadros depois, especial 0,7 s; pernas presas 0,71 s, só a esquiva corta | igual desde o C12d (`ComboNode.cooldown`, `move_hold`, D-44); na E1c, preso na pose do disparo, nunca correndo |
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
| Raridade | comum a heroica | rara 10%, épica 5% em sequência; heroica só pela troca (10% por carta numa ação ocupada, +1 de raridade, mesmo nível); guardião rara 90%, épica 7%, lendário 5% | igual desde a E3: comum, rara, épica e lendária (a heroica do Hades II; D-52), multiplicadores fixos 1,5, 2, 2,5 do nível 1 (D-53); guardião sem lendária (o lendário do Hades II será o Salmo) |
| Duplos | dons duplos (dois deuses) | dons duplos: um de cada lista de dois deuses, 12% por carta, sem raridade e sem romã | **Elo** (mecânica das Crônicas de Eterra): 6 hoje, com a corrente ligando os dois dons na carta e no painel "Dons" da pausa, e o aviso "Elo formado"; desde a E3 com as regras do Hades II (`requires_sets`, 12%, sem raridade nem nível) |
| Lendários | sim | sim | **Salmos** desde a E4 (`docs/design/e4_psalms.md`): três grupos (Bênção, Elo ou Dom equipado, uma coisa por grupo), 10% por carta quando a condição vale, 5% no guardião, um por tema, dois por partida, sem nível; quatro (Sentinela, Abrigo, Pastor, Rocha) que mudam como uma ação funciona (círculo, esquiva, especial, giro); carta e Compêndio na tela ainda faltam (E4-03 a E4-05) |
| Subir o nível de um dom | romã | romã: nível 1 vezes a raridade, ganho fixo por nível sem raridade; fatia na loja | igual desde a E3 (`BoonMod.base`, `per_level`; romã nas portas e na loja, fatia na loja); teto de nível 3 por enquanto (E3-D1); Bênção já tida não volta nas cartas |
| Infusões (exigem X de um elemento) | não | sim | falta |
| Mudar a arma | martelo de Dédalo | martelo de Dédalo | falta |
| Bênção com maldição | Caos | Caos | **Provação** desde a E5 (`Trials`, `data/trials/`): laje rachada numa sala vencida (20%, profundidades 2 a 7, uma a cada 10 salas, nunca com maldição em curso), custa `ceil(10 + 0,5 x profundidade)` de vida (só com mais vida que isso), leva a uma câmara com 3 cartas divididas (Bênção forte com raridade do Caos, rara 40% e épica 10%; maldição por 3 a 5 encontros que depois vira a Bênção); 5 Bênçãos e 5 maldições em dado (inimigos mais rápidos, cura menor, um inimigo a mais por onda, golpes recebidos maiores, sem ouro); sem deus novo; tela da carta ainda provisória (pisar) |
| Feitiços de caminho | não | Selene | falta |
| Bônus de sequência de golpes | não | não | não desde a E3 (D-10; o contador continua no HUD) |

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
