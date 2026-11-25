# Fase 3 do Plano SWORN: a primeira vez e a descida-tutorial (SW-O1 a SW-O6)

Especificação de implementação (game-director, 2026-11-25, commit lido `182bd6b`). Plano de origem: topo de `docs/backlog.md`,
"Fase 3, a primeira vez e a descida-tutorial (SW-O)". Começa **depois que a Fase 2 (SW-R: orçamento, âncoras, zonas mortas) entrar**,
porque a descida-tutorial passa por fora do orçamento e das âncoras e precisa do `RunMap` já mexido.

Fontes: `docs/design/sworn_rea_kingswood_2026-11-25.md` 3.4 e 5 (tutorial "Wirral Forest": salas fixas e ondas escritas à mão,
um inimigo sozinho ou em dupla antes da mistura, minichefe na 5, Ultimate depois de 6 partidas e Companheiro depois de 4),
`docs/design/sworn_research_2026-11-25.md` 1 (primeira partida curta, chefe que não conta como vitória plena, três escolhas cedo),
a memória do vídeo "Primeira Vez Antessala" que o Daniel separou (tela escura, invocação com cristais, o herói se formando, uma fala
com legenda, objetivo no canto superior esquerdo "Explore a área" / "Encontre um caminho", sala calma sem inimigos) e o cânone
(`../dungeon-rpg/docs/mundo/canone.md`).

**Regra de lore desta fase.** Nada aqui cria lore. Toda frase para o jogador está marcada **(a aprovar pelo Daniel)** e usa só o que
já está no cânone ou já está no jogo (`premise`, `ending_3`, `book_epigraph` em `data/text_pt.tres`). Do SWORN copiamos a estrutura e os
tempos; nenhum texto, nome, personagem ou mapa.

O que existe hoje e que esta fase muda:
- Save novo vai direto para a partida (`Boot.first_scene`: `runs == 0` vai para `GAME`) e a primeira descida é uma descida normal de 14
  salas, com o grafo sorteado. Ao fim, a tela de fim só oferece o Santuário (`EndScreen.home_only`, `Game._open_end`).
- O Santuário abre aos poucos (`HubGate`, `scripts/core/hub_gate.gd`), com guia na primeira vez (`HubGuide`, dados em `data/hub_guide/`).
- Dicas da primeira descida (`FirstTips`, `TipToast`): quatro dicas, uma por vez, nas 2 primeiras descidas.
- Coragem (`scripts/core/courage.gd`): morte até a sala 5 dá +3 de vida e 1 romã na descida seguinte, até 3 pilhas. **Fica como está.**

---

## SW-O1 Chegada

### O que o jogador vê, segundo a segundo (só na descida-tutorial)
| t (s) | Tela | Som | Controle |
|---|---|---|---|
| 0,0 | Preto total (o mesmo `ColorRect` de `Rooms._fade`, que já monta a sala no preto). | Silêncio; um tom grave de órgão ou corda sobe devagar (peça existente do catálogo, sem música nova). | nenhum |
| 0,6 | Uma estrela pequena de luz aparece no meio da tela: ponto marfim quente com halo esmeralda fraco, 6 a 10 px, pulsando devagar. | um sino fino, uma vez (som existente). | nenhum |
| 1,6 | O preto vai abrindo em 0,8 s e mostra o Salão em penumbra (luz da sala a 25%). A estrela desce até o ponto de nascimento do herói (borda sul, `arena.start`) e vira um **feixe de luz de Elun** (o `RewardShaft`, a mesma "luz de Elun" das recompensas, maior: 2,4 m no chão). | | nenhum |
| 2,4 | No chão, sob o feixe, um anel fino de runas em ouro velho se acende do centro para fora (o selo se abrindo). Três a cinco **cristais de Emeth** (esmeralda cristalina) sobem do chão em volta, a 2,5 m do centro, e ficam presos ao chão. | um acorde baixo crescendo. | nenhum |
| 3,0 | Fagulhas esmeralda (as `SpectralMotes` em modo GATHER, recoloridas) correm dos cristais para o centro do feixe. | | nenhum |
| 3,6 | O Guerreiro aparece no feixe, de pé, olhando para o norte: a silhueta se forma de baixo para cima em 0,4 s. Um único brilho marfim **contido no feixe** (nunca na tela inteira, nunca branco puro; teto de cor de `ScreenTone`). As fagulhas acabam **antes** de ele aparecer (nada de partícula sobre o herói). | golpe surdo de chegada. | nenhum |
| 4,0 | O feixe apaga em 0,8 s; os cristais ficam acesos baixo e viram cenário da Antessala; a luz da sala sobe a 100% em 1,0 s. | | **o herói anda** |
| 4,2 | Legenda na base da tela (Alegreya, marfim, sombra, sem caixa, centrada, 30 px acima da fileira de ações): a fala única (opções abaixo). Entra em 0,5 s, fica 4,0 s, sai em 0,6 s. Sem voz gravada: legenda só. | | anda |
| 8,8 | Objetivo no canto superior esquerdo: "Explore a área" (SW-O2). | | anda |

- **Pular**: qualquer tecla, botão ou clique depois de 1,0 s pula para o estado de t = 4,0 (herói visível, feixe apagando) e a legenda
  aparece mesmo assim (curta, 2,5 s). Nunca pausa a partida depois de t = 4,0.
- **Só uma vez por save.** As descidas seguintes começam como hoje (fade do preto). Se a chegada curta em toda descida vale a pena é
  pergunta para o Daniel (D-O4).
- Paleta: marfim quente e esmeralda com ouro velho. Nada de sol (D-64 a D-68), nada de amarelo saturado, nada de clarão branco.

### Opções da fala única (todas **a aprovar pelo Daniel**)
1. **O Guerreiro fala, uma oração curta.** "Pela luz de Elun. Morvath ergueu os mortos, e eu desço para selá-lo."
   Base: o cânone diz que os heróis falam de fé de forma boa ("pela luz de Elun"); o resto é a `premise` do jogo. Dá o objetivo da
   partida na primeira frase.
2. **A inscrição do selo, lida na tela.** "Que nenhuma mão abra o que a luz fechou."
   Base: é a lápide do fim (`ending_3`), palavra por palavra. A primeira e a última frase do jogo viram a mesma: a chegada abre o livro e
   a selagem o fecha. Zero texto novo; não diz quem fala.
3. **Uma voz sem nome, de narrador.** "Sob a igreja velha de Valmor, os mortos se levantaram. Desça e sele o rei que traiu a luz."
   Base: a `premise` e o nome de Morvath que o jogo já usa ("o rei que traiu a luz"). Explica mais, mas soa como tutorial.

Recomendação (opinião minha): **a 1**, porque o vídeo que o Daniel gostou tem o herói falando e porque dá ao jogador o "por quê" sem tela
de texto. A 2 é a mais segura em lore e pode virar a inscrição gravada no anel de runas da chegada (sem legenda).

### O que já existe e será reaproveitado
- `Rooms._fade` e a montagem da sala no preto (`Rooms._enter_first`, `_frame_drawn`, `hold_frames`): o preto inicial.
- `RewardShaft` (`scripts/game/reward_shaft.gd`): o feixe da "luz de Elun", com a regra de não pesar sobre o herói.
- `SpectralMotes` (`scripts/game/spectral_motes.gd`, modo `GATHER`): as fagulhas que convergem.
- `CrystalHazard` e as peças de cristal das salas (`scripts/core/crystal_hazard.gd`, `docs/reference/art_rooms.md`): o modelo dos cristais.
- `ShockRing` / `DoorRing` (anel aditivo): o anel de runas no chão.
- `TipToast` (`scripts/ui/tip_toast.gd`): o estilo da caixa; a legenda é mais simples (sem caixa).
- `Warmup` (`scripts/render/warmup.gd`): os shaders novos entram na lista de aquecimento.

### O que é novo
- Código: `ArrivalScene` (`scripts/game/arrival_scene.gd`, `Node3D`): `play(game: Game, at: Vector2) -> void` com sinal `finished`;
  `skip()`; esconde o corpo do herói até t = 3,6 (o `Player` fica parado e invisível, sem tomar dano, sem inimigos na sala).
  Linha do tempo pura em `ArrivalTimeline` (`scripts/core/arrival_timeline.gd`): `state_at(t) -> Dictionary` (preto, estrela, feixe,
  anel, cristais, herói visível, controle), testável sem tela. Shader do herói se formando, se o `HeroBody` não tiver um corte por
  altura: `assets/shaders/arrival_form.gdshader` (corte por altura com borda esmeralda fina).
- Código de legenda: `ArrivalCaption` (`scripts/ui/arrival_caption.gd`, filho do `Hud`): `show(key, seconds)`.
- Dado: em `tools/make_data.gd`, parte `first` (abaixo, SW-O4): `FirstDescentDef.arrival_line` (a chave do texto) e os tempos da
  linha do tempo (para afinar sem código).
- Texto: `arrival_line` em `data/text_pt.tres` (a opção escolhida pelo Daniel).

### Donos
- `environment-artist`: `scripts/game/arrival_scene.gd`, `scripts/core/arrival_timeline.gd`, `assets/shaders/arrival_form.gdshader`,
  a entrada nova em `scripts/render/warmup.gd`, `docs/reference/art_fx.md` (seção nova).
- `ui-ux-designer`: `scripts/ui/arrival_caption.gd` e a chave em `data/text_pt.tres`.
- A chamada (`ArrivalScene.play`) entra em `scripts/game/rooms.gd` pelo dono dele (`gameplay-engineer`, lote 3A1).

### Teste GUT (`tests/test_arrival.gd`)
- `ArrivalTimeline.state_at`: preto em 0; estrela em 0,6; herói invisível antes de 3,6 e visível depois; controle só a partir de 4,0;
  fagulhas zeradas antes de o herói aparecer; tudo apagado em 5,0.
- `skip()` depois de 1,0 s leva ao estado de 4,0; antes de 1,0 s não faz nada.
- Nenhuma cor da cena passa do teto de `ScreenTone` (o teste de cor que os efeitos já usam).

### Critério de aceite
- Captura GPU (só a sessão principal) em t = 1,0 / 2,6 / 3,6 / 4,5 / 6,0 com `--first --nosave --look=stylized --cam=near`; o
  `art-director` aprova a leitura: estrela, feixe, selo, herói, legenda.
- Do preto ao controle em no máximo 4,0 s; pular funciona desde 1,0 s; a legenda nunca cobre o herói nem a fileira de ações.
- Sem queda de quadro na RTX 5060: a cena dentro do orçamento da sala (medir `frame_ms` no `--first`).

---

## SW-O2 Objetivo no canto superior esquerdo

### O que o jogador vê
- Uma linha só, no canto superior esquerdo, **abaixo** de "Sala N de M" (`Hud` `top_left`), com um losango pequeno de ouro velho à
  esquerda: Alegreya 18 px, marfim com sombra. Quando o objetivo muda, a linha antiga some em 0,2 s, a nova entra em 0,3 s e um filete
  de ouro corre por baixo dela uma vez (0,5 s). Nunca aparece sobre telas (Bênção, loja, pausa).
- Frases (todas **a aprovar pelo Daniel**; as teclas são as reais, por `UiKit.action_label`):

| chave | texto | quando |
|---|---|---|
| `obj_explore` | Explore a área | Antessala, ao ganhar o controle |
| `obj_dodge` | Atravesse as lajes com {dodge} | Antessala, a 6 m das lajes |
| `obj_break` | Quebre um vaso com {attack} | Antessala, a 5 m de um quebrável (se ainda não quebrou) |
| `obj_find_way` | Encontre um caminho | Antessala, lajes passadas; e toda sala vencida com portas abertas |
| `obj_win` | Vença a sala | luta começou |
| `obj_take` | Pegue a recompensa com {interact} | sala vencida, recompensa no chão |
| `obj_bless` | Escolha uma Bênção | tela de Bênção aberta (a linha fica escondida, volta depois) |
| `obj_door` | Escolha uma porta | duas portas abertas pela primeira vez |
| `obj_guardian` | Vença o guardião | sala do guardião |
| `obj_shop` | Compre o que quiser e siga | loja |
| `obj_morvath` | Enfrente Morvath | sala de Morvath |
| `obj_hub_tree` | Visite a Árvore de Dons | Santuário, depois da descida-tutorial, até abrir a tela |
| `obj_hub_portal` | Volte às catacumbas pelo Portal | Santuário, quando nada novo espera |

- Na descida-tutorial a linha está sempre ligada. Nas descidas normais: recomendo ligada nas **2 descidas seguintes** e depois desligada,
  com opção "Mostrar objetivo" em Configurações (D-O3).

### O que já existe e será reaproveitado
- `Hud._build_top` (`scripts/ui/hud.gd`): o `HBoxContainer` `top_left` com `_room` e `ahead`; a linha nova vai num `VBoxContainer` sob ele.
- `UiKit.label`, `UiKit.shadow`, `GoldRule` (o filete da cartela da sala), `UiKit.action_label` (teclas reais).
- `FirstTips` (`scripts/core/first_tips.gd`) e `TipToast`: continuam, mas na descida-tutorial a dica `fight` não aparece (o objetivo e as
  dicas por sala já ensinam); `hold`, `armor` e `elo` seguem.
- Estados que a regra lê, todos já públicos: `Rooms.room.kind`, `Rooms.usable()`/`use_kind()`, portas abertas (`next_rooms`, `_open_doors`),
  `Game.mode`, a tela aberta (`Game._screen`).

### O que é novo
- Código puro: `Objective` (`scripts/core/objective.gd`): `pick(ctx: Dictionary) -> StringName`, com `ctx` = `{place: &"run"|&"hub",
  kind, fighting, reward_waiting, doors_open, first_choice, screen, near_plates, near_breakable, crossed_plates, broke_one,
  hub_new_station}`. Sem nó, sem save. `enabled(data, tutorial: bool) -> bool` (tutorial, ou `runs <= OBJ_RUNS` (3) e a opção ligada).
- Código de tela: `ObjectiveLine` (`scripts/ui/objective_line.gd`): `set_key(key)` faz a troca animada; `Hud` monta o `ctx` a cada 0,2 s.
- Dado: a ordem e as distâncias (`obj_dodge_near` 6 m, `obj_break_near` 5 m) em `FirstDescentDef` (parte `first`).
- Texto: as 13 chaves `obj_*` em `data/text_pt.tres`; `opt_objective` para a opção.
- Opção: `options.objective` no save (padrão `true`), na tela de Configurações.

### Donos
- `ui-ux-designer`: `scripts/core/objective.gd`, `scripts/ui/objective_line.gd`, `scripts/ui/hud.gd`, `scripts/core/first_tips.gd`,
  `scripts/ui/options_screen.gd`, `data/text_pt.tres`, `docs/reference/ui.md` (seção nova).
- A opção no save (`options.objective` em `SaveData.defaults`) entra pelo dono do `save_data.gd` (lote 3A1).

### Teste GUT (`tests/test_objective.gd`)
- `Objective.pick` para cada linha da tabela (um caso por chave), e a precedência: tela aberta esconde; luta vence explorar; recompensa no
  chão vence portas.
- `enabled`: ligado no tutorial; ligado em `runs` 1 a 3 com a opção ligada; desligado em `runs` 4; desligado com a opção desligada.
- Toda chave `obj_*` existe em `text_pt.tres`, sem travessão; `{dodge}`, `{attack}`, `{interact}` trocados pela tecla de teclado e de
  controle (dois casos).

### Critério de aceite
- Captura (sessão principal) na Antessala e numa sala vencida, a 1080 e a 720: a linha lê, não encosta no "Sala N de M" nem na barra de
  chefe.
- `--smoke` sem mudança no `RESULT` (só interface).

---

## SW-O3 Antessala

### O que o jogador vê (continua da chegada, cerca de 40 s)
- O Salão (`hall`, a sala da imagem de referência) **sem inimigos e sem a Fonte acesa**, com os cristais da chegada ainda acesos ao sul.
- t 4 a 12 s: "Explore a área". O herói anda; a câmera Perto. Os quebráveis do Salão (`_place_breakables`, grupos já posicionados) estão
  lá; o mais perto do caminho tem um brilho fraco de ouro (o mesmo realce das recompensas, sem feixe).
- Ao chegar a 5 m de um vaso: "Quebre um vaso com {attack}". Quebrou: cai um pouco de ouro (o quebrável já dá ouro), o objetivo volta.
- Faixa de **3 lajes de aprender** atravessando o caminho entre o sul e as portas do canto nordeste: armam sozinhas em ciclo (aviso
  vermelho translúcido de 1,0 s, pancada, 1,5 s de calma), **dano 0** nesta sala (só empurrão curto e o som), para ensinar sem punir.
  A 6 m: "Atravesse as lajes com {dodge}". Passou a faixa (de qualquer jeito, mas a dica fala da esquiva): "Encontre um caminho".
- **Uma porta só** no canto nordeste, com o medalhão da Bênção (o anjo da primeira Bênção) e a placa de usar. Entra: sala 1.
- Nada de tempo limite; se o herói ficar 25 s parado, o objetivo pisca uma vez.

### O que já existe e será reaproveitado
- `CatacombHall` (`scripts/game/catacomb_hall.gd`) e o layout `hall` de `tools/make_data.gd` (portas no canto nordeste desde o PT-6b,
  quebráveis do AT-Q4, entrada sul do PT-6).
- `PlateHazard` com o ciclo sozinho do Lote S (`HazardDef.auto_cycle`, `auto_near` 0 = sempre, `PlateHazard.auto`).
- `Breakables` e `BreakablePiece` (ouro do quebrável), `DoorRing`, `DoorSign`, `StationSign` (placa de usar), `Rooms.usable`.

### O que é novo
- Dado: uma variante do `hall` só para a Antessala (`hall` com `variants` nova, id `ante`), com a faixa de lajes: 3 lajes de 2,4 m lado a
  lado em z = 0, x de 3 a 10,5 (no caminho natural do sul para o canto nordeste); posição final do `room-designer` em
  `docs/design/rooms_progression.md`, conferida pelo teste de alcance; `HazardDef` próprio `plates_teach0` (dano 0, `auto_cycle` 2,5,
  `auto_near` 0, `auto_until` 1,0).
- Código: `RunMap.Kind.ANTE` (sala sem luta: portas abertas desde a entrada, sem recompensa, sem cura de sala, sem Prata) e o caso dele em
  `Rooms._enter_with` (sem `_step_fight`; `_open_doors` logo depois da chegada) e em `Rooms.is_fight_room` (falso).
- Código: o sinal `Rooms.plates_crossed` e `Rooms.broke_one` para o `Objective` (contados pela posição do herói passando z da faixa e pelo
  `Breakables.broken`).

### Donos
- `gameplay-engineer` (3A1): `scripts/core/run_map.gd` (o `Kind.ANTE`), `scripts/game/rooms.gd`, `tools/make_data.gd` (variante e
  `HazardDef`).
- `room-designer`: só a posição da faixa e dos realces, escrita em `docs/design/rooms_progression.md` (seção "Antessala"), antes do 3A1
  fechar os dados.

### Teste GUT (em `tests/test_first_descent.gd`)
- A variante `ante` existe; a entrada alcança a porta (`nav.reachable`) passando pela faixa ou pelos lados; as lajes estão a 6 m ou mais
  da entrada e da porta (regra do PT-6); nenhum quebrável a menos de 3 m das lajes.
- Sala `ANTE`: zero inimigos, portas abertas em até 0,5 s depois da chegada, nenhuma recompensa, `room_heal` 0.
- Laje `plates_teach0` acerta o herói com dano 0.

### Critério de aceite
- Uma pessoa que nunca jogou atravessa a Antessala em menos de 60 s (só o Daniel e as crianças podem dizer; o robô com `--first` em menos
  de 30 s, `RESULT` `ante_s`).
- Captura do topo da faixa armando, com o herói ao sul (sessão principal).

---

## SW-O4 Primeira descida fixa em dado

### Como o jogo sabe que é a primeira vez (save)
- Campo novo no save: `first` = `0` (pendente), `1` (feita), `2` (pulada). `SaveData.VERSION` 16. Migração em `SaveData.merged`: save de
  versão menor com `runs > 0` vira `1`; com `runs == 0` fica `0`.
- Regra pura `FirstDescent.active(data: Dictionary, flags: Dictionary) -> bool` (`scripts/core/first_descent.gd`):
  - verdadeiro com `--first` (sempre, mesmo com robô e sem save: é como se testa);
  - senão, falso com `--bot`, `--smoke`, `--start`, `--horde`, `--stress`, `--arena`, `--short`, `--medium`, `--nosave` ou `Save.enabled` falso;
  - senão, verdadeiro se `data.first == 0`.
- Fim da descida-tutorial (morte, Morvath curto vencido ou "Sair para o Santuário" na pausa): `first = 1`, `runs += 1` (como hoje), **sem**
  `wins`, sem `firsts.guardian`/`firsts.victory` (para não abrir a Forja, a Videira, os Juramentos nem a Maga por ela), Maestria e Memória
  contam normalmente. Fechar o jogo no meio deixa `first = 0` (recomeça do começo).
- **Pular** (quem já jogou): na pausa da descida-tutorial, "Pular a primeira descida" (pede confirmação) grava `first = 2`, conta como
  feita para os marcos (o marco 0 abre) e vai ao Santuário. Na tela de escolha de save, ao criar um save novo quando outro espaço já tem
  `runs > 0`, a pergunta "Fazer a primeira descida guiada?" (Sim / Ir direto ao Santuário). Recomendação na D-O2.

### O que o jogador vê, sala por sala
"Sala N de 8" no topo. Sem grafo sorteado: uma porta por sala, exceto onde está escrito "duas portas". Todas as lutas em ondas fixas, em
dado; **sem** inimigo maior, modificador, elite, Provação, Altar, maldição, achado de Ofício nem salas longas.

| # | Sala (layout) | Ondas (ids de `data/enemies/`) | Objetivo e dica | Recompensa e portas |
|---|---|---|---|---|
| 0 | Antessala (`hall`, variante `ante`) | nenhuma | chegada; explorar, quebrar, atravessar lajes | 1 porta: Bênção |
| 1 | Cripta A (`crypt`, var. 0, sem lajes) | `[skeleton]`; `[skeleton, skeleton]` | "Vença a sala"; dica `fight` própria do tutorial: "Ataque com {attack}. O terceiro golpe empurra." | **primeira Bênção, 3 opções, anjo fixo** (hoje Sarael); 1 porta: Ouro |
| 2 | Fendas A (`rift`, sem quedas armadas) | `[archer]`; `[archer, archer, skeleton]` | dica: "Os virotes avisam antes. Saia da linha com {dodge}." | Ouro; **duas portas** (primeira escolha): Bênção (2º anjo, Nivael) ou Romã |
| 3 | Jardim A (`garden`) | `[bone_rat x5]`; `[runner, runner]` | dica `hold` (Golpe Carregado) antecipada: "Segure {attack} para girar a espada no bando." | a escolhida; duas portas: Fonte ou Bênção |
| 4 | Cripta B (`crypt`, var. 1, lajes de aprender ligadas) | `[skeleton, archer, bone_rat x3]`; `[guard, skeleton, archer]` | primeira mistura; dica `armor` (a do escudo) se for a 1ª vez | a escolhida; 1 porta: o guardião |
| 5 | Casa do Cavaleiro (`knight_hall`) | `[knight]`, vida x0,7, **sem escolta** | "Vença o guardião"; dica: "A investida do Cavaleiro avisa. Esquive para o lado com {dodge}." | Bênção do anjo do guardião, Prata e Memória como sempre; 1 porta |
| 6 | Santuário (`sanctuary`) | `[skeleton, skeleton, archer]`; `[mage, runner, bone_rat x4]` | o respiro depois do guardião é a Fonte da sala 3 ou 4; aqui a mistura completa | Ouro; 1 porta: loja |
| 7 | Salão (`hall`, loja) | nenhuma | "Compre o que quiser e siga" | loja normal (3 itens); 1 porta: Morvath |
| 8 | Câmara do Selo (`boss_layout`) | Morvath **curto**: só a fase 1, vida da fase 1 x0,6 | "Enfrente Morvath" | fim da descida-tutorial |

- **Ritmo esperado**: chegada e Antessala cerca de 1 min; primeira Bênção perto de 1:45; guardião perto de 6 min; fim em 8 a 11 min
  (o SWORN anda em 5 a 10). Alvo do backlog: **primeira Bênção antes de 2 min**.
- **Vida dos inimigos**: os valores do `EnemyDef` como na sala 1 de uma descida normal em todas as salas (sem a subida por profundidade);
  o `FirstRoomDef.hp_scale` (padrão 1,0) existe para afinar sem código. Coragem não se aplica (save novo não tem pilha).
- **Morvath curto**: quando a vida da fase 1 acaba ele não passa para a fase 2. Em vez disso, cena curta: ele cai de joelhos, o selo do
  chão acende (`SealLook`, estado de vitória sem o ritual), a tela escurece e duas legendas (texto a aprovar, D-O5). Depois a tela de fim
  com "Voltar ao Santuário" (`EndScreen.home_only`) e uma linha "A primeira descida terminou." **Não conta como vitória**: sem `wins`, sem
  tempo recorde, sem Juramentos nem Maga.
- **Se morrer** em qualquer sala: tela de fim normal com "Voltar ao Santuário" só; a descida-tutorial conta como feita (`first = 1`) e a
  Coragem vale para a próxima (morte até a sala 5). Não repetimos o tutorial: o SWORN também não.
- **Ao voltar ao Santuário**: abre o **marco 0** (SW-O5): a Árvore de Dons, com o guia `tree` que já existe, e o objetivo "Visite a Árvore
  de Dons".

### O que já existe e será reaproveitado
- `RunMap.Room` com `fight`, `kind`, `reward`, `layout`, `variant`, `guardian`, `angel`; `Rooms._prepare` **pula sala que já tem `fight`**,
  então a sala com a luta escrita no dado passa pelo mesmo caminho de sempre (`_step_fight`, `_next_wave`, `_spawn`).
- `EncounterGen.Fight` (`waves`, `kinds`, `cap`, `ceiling`): o formato das ondas.
- `Rooms.short_stage` (o jeito de duplicar o `StageDef` com menos salas), `--boss-hp` (o jeito de começar Morvath com menos vida).
- `BoonState.offers(rng, 3)`, `Encounters` (anjo da porta), `EndScreen.home_only`, `Game._on_player_died`, `Game._on_boss_defeated`.
- `RunLog` (registro de partidas) e `RunReport.line` (o `RESULT`).

### O que é novo
- Dado (`tools/make_data.gd`, parte nova `first`, gera `data/first_descent.tres`):
  - `FirstDescentDef` (`scripts/core/first_descent_def.gd`, `Resource`): `rooms: Array[FirstRoomDef]`, `arrival_line`, tempos da chegada,
    `boss_hp_scale` 0,6, `boss_last_phase` 1, `obj_*_near`.
  - `FirstRoomDef` (`scripts/core/first_room_def.gd`): `kind`, `layout_id`, `variant`, `waves: Array[PackedStringArray]`, `doors:
    Array[int]` (recompensas `RunMap.Reward`), `angel`, `guardian`, `hp_scale`, `hazards` (liga ou desliga os perigos da sala), `tip`
    (chave de texto), `objective` (chave opcional que força o objetivo de entrada).
- Código:
  - `FirstDescent` (`scripts/core/first_descent.gd`, puro): `active(data, flags)`, `finish(data, how)` (grava `first`), `map(stage, def,
    seed) -> RunMap`.
  - `RunMap.scripted(stage, def, seed)` (em `run_map.gd`): nós lineares a partir do dado, `layers` de uma ou duas salas, sem `_keeps_rules`
    (o grafo normal continua igual), `fight` já montado de cada sala, `fight_seed` fixo.
  - `Rooms.setup`: com `FirstDescent.active`, usa `FirstDescent.map` no lugar de `new_map`; liga ou desliga perigos por sala
    (`FirstRoomDef.hazards`); não aplica `long_depths`; "Sala N de 8".
  - `Boss` (`scripts/game/boss.gd`): `last_phase` (padrão 0 = todas) e o sinal `tutorial_end` no lugar da passagem de fase.
  - `Game`: fim da descida-tutorial (`FirstDescent.finish`), sem `wins`; o `RESULT` ganha `first=1` e `ante_s`, `first_boon_s`; o
    `RunLog` ganha `"first": true` (versão 5; `normalized` lê as antigas como `false`). Equilíbrio e QA **excluem** essas linhas.
  - Pausa: "Pular a primeira descida" (só na descida-tutorial).
- Texto: o contador reaproveita `end_room` ("Sala {n} de {of}", com `of` = 8); novos: `first_tip_*` (5 dicas), `first_end_1`, `first_end_2`, `first_done`,
  `pause_skip_first`, `pause_skip_confirm`, `slot_first_ask`, `slot_first_yes`, `slot_first_skip` (todas a aprovar).

### Donos
- `gameplay-engineer` (3A1): `scripts/core/first_descent.gd`, `first_descent_def.gd`, `first_room_def.gd`, `scripts/core/run_map.gd`,
  `scripts/game/rooms.gd`, `scripts/game/game.gd`, `scripts/core/save_data.gd`, `scripts/core/run_log.gd`, `scripts/game/run_report.gd`,
  `scripts/game/bot.gd`, `scripts/boot.gd`, `tools/make_data.gd`, `docs/reference/rooms.md` (seção nova).
- `gameplay-engineer` (3A2, outra instância, outros arquivos): `scripts/game/boss.gd` (Morvath curto) e o resto do SW-O5 (abaixo).
- `ui-ux-designer` (3A3): a entrada da pausa (`scripts/ui/pause_menu.gd`), a pergunta na escolha de save (`scripts/ui/save_slot_screen.gd`)
  e todos os textos.

### Teste GUT (`tests/test_first_descent.gd`)
- O dado carrega; 9 salas (0 a 8); todo id de inimigo existe em `stage.enemies`; tipos novos por sala: sala 1 só `skeleton`, sala 2 só
  `archer` e `skeleton`, sala 3 só `bone_rat` e `runner`, mistura só da 4 em diante; primeira Bênção na sala 1 com 3 opções; guardião na 5
  sem escolta; loja na 7; Morvath na 8 com `boss_last_phase` 1.
- `FirstDescent.active`: a matriz inteira (cada bandeira, save `0`/`1`/`2`, `Save.enabled` falso).
- `RunMap.scripted`: lineares, portas iguais ao dado, `_keeps_rules` não roda, mesma semente dá o mesmo mapa.
- `SaveData.merged`: versão 15 com `runs` 3 vira `first = 1`; com `runs` 0 vira `0`.
- Fim: morte grava `first = 1` sem `wins`; Morvath curto grava `first = 1` sem `wins` nem `firsts.victory`; pular grava `2`.
- Robô: `--first --bot --nosave --seed=5` termina a descida-tutorial sem `stuck` (teste de fumaça curto em `--fast`).

### Critério de aceite
- `--smoke` normal: **o mesmo `RESULT` das sementes de controle de antes da fase** (5 e mais 11 das 12 de QA), linha por linha.
- `tools/smoke.sh 900 --first --seed=5`: termina com `first=1`, `stuck` 0, `first_boon_s` < 120, fim entre 480 e 700 s de jogo.
- Daniel ou as crianças: chegam à primeira Bênção em menos de 2 min sem ler nada fora da tela (só jogando se mede).

---

## SW-O5 Destravar aos poucos

### Regra
**Uma estação nova por marco**, apresentada com o guia que já existe (`HubGuide`) na volta ao Santuário, **no máximo uma por visita** (se
dois marcos caem juntos, a segunda espera a próxima volta). Nada que já esteja aberto num save fecha: estação já apresentada
(`hub.presented`) ou já usada continua aberta mesmo que a regra nova peça mais. A Coragem fica exatamente como está.

### A ordem proposta (a aprovar pelo Daniel, D-O1)
| Marco | Condição | Abre | Hoje |
|---|---|---|---|
| 0 | descida-tutorial feita ou pulada (`first >= 1`) | **Árvore de Dons** (guia `tree`) | `runs >= 1`, junto com o Livro |
| 1 | primeiro guardião vencido **fora** da descida-tutorial, ou `runs >= 3` | **Forja** (guia `forge`) | 1º guardião ou Prata para o Temperar I |
| 2 | `runs >= 3` | **Livro de Ahk** e Compêndio (guia `book`) | `runs >= 1` |
| 3 | `runs >= 4` (o Companheiro do SWORN vem em 4) | **Videira** (guia `account`) | o mesmo que abria O Preparo |
| 4 | `runs >= 5` ou a primeira Pedra Funda | **Vendedor** e Ofícios (guia `vendor`) | `runs >= 3` ou Pedra Funda |
| 5 | `runs >= 6` (a Ultimate do SWORN vem em 6) **e** Maestria 2 | **Ultimate** (Shift): o 5º losango do HUD só aparece aqui; guia novo `ult` na Árvore de Dons | Maestria 2 (o losango aparece trancado antes) |
| 6 | primeira vitória (`wins > 0`) | **Juramentos** (guia `sworn`) e **Estandarte dos Heróis** (guia `maga`) | Juramentos igual; Estandarte com o Vendedor |

Por que essa ordem (opinião minha): primeiro o que muda o herói (Dons, Forja), depois o que explica (Livro), depois o que planta
(Videira), depois o que pede outra camada de jogo (Vendedor e Ofícios), depois o golpe que mais muda a luta (Ultimate) e por fim o que é
de quem já venceu. Com as crianças morrendo cedo, `runs` sobe rápido: na prática a Ultimate chega entre a 1ª e a 2ª hora de jogo.

### O que já existe e será reaproveitado
- `HubGate` (`scripts/core/hub_gate.gd`): `GATED`, `is_open`, `to_present`, `mark_presented`; constantes `TREE_BOOK_RUNS`, `VENDOR_RUNS`.
- `HubGuide`, `HubGuideDef`, `data/hub_guide/` (gerado por `_hub_guide` em `tools/make_data.gd`), `HubGuideOverlay`, `hub.guided`.
- `HubLabels.announce`, `HubLook.set_closed` (estação fechada apagada).
- `HeroDef.ult_for_weapon`, `HeroLoadout` (`scripts/core/hero_loadout.gd` linha 138), `Hud` (o 5º losango, `Hud._charge`).
- `Juramentos.unlocked`, `SaveData.hero_open`, `Vine.open`, `Courage` (sem mudança).

### O que é novo
- Dado: os marcos saem das constantes e viram dado: `MilestoneDef` (`scripts/core/milestone_def.gd`: `id`, `order`, `opens`
  (estação ou `&"ult"`), `runs_min`, `needs` (`&"first"`, `&"guardian"`, `&"win"`, `&"stone"`, `&"mastery2"`), `any_of`), gerados em
  `data/milestones/NN_id.tres` pela parte `milestones` de `tools/make_data.gd`; guia novo `ult` na parte `_hub_guide`.
- Código: `Milestones` (`scripts/core/milestones.gd`, puro): `reached(data) -> Array[StringName]`, `open(data, id) -> bool`,
  `ult_open(data) -> bool`, `next_to_present(data) -> StringName` (no máximo um por visita). `HubGate.is_open` passa a perguntar a
  `Milestones` (a regra "já usou, está aberta" e "já apresentada, está aberta" continua no `HubGate`).
- `firsts.guardian` ganha o par `firsts.guardian_run` (vencido fora da descida-tutorial); o tutorial não grava `firsts.guardian`.
- Ultimate: `HeroLoadout` só devolve uma ultimate com `Milestones.ult_open(Save.data)`; o `Hud` esconde o 5º losango quando não há
  (o `Game` faz a mesma pergunta onde chama `ult_for_weapon`, linha perto de 1903: uma linha, pelo dono do `game.gd` no 3A1).
- Texto: `hub_open_ult`, `guide_ult` (a aprovar).

### Donos
- `gameplay-engineer` (3A2): `scripts/core/milestone_def.gd`, `scripts/core/milestones.gd`, `scripts/core/hub_gate.gd`,
  `scripts/core/hub_guide.gd`, `scripts/core/hero_loadout.gd`, `scripts/game/hub.gd` (um guia por visita), `scripts/game/boss.gd`
  (Morvath curto, SW-O4), os testes antigos que leem os limiares (`tests/test_hub_gate.gd`, `tests/test_pt5_unlock_guide.gd`,
  `tests/test_hub_evolution.gd`), `docs/reference/hub.md` e `docs/reference/meta.md` (seções).
- As linhas de dado (`milestones`, guia `ult`) entram em `tools/make_data.gd` pelo dono dele (3A1), copiadas da tabela acima.
- O 5º losango escondido no `Hud`: `ui-ux-designer` (3A3), lendo `Milestones.ult_open`.

### Teste GUT (`tests/test_milestones.gd`)
- Save novo: só o Portal. `first = 1`: Árvore. `runs` 3: Forja e Livro abertos, **só um** apresentado por visita. `runs` 4: Videira.
  `runs` 5 ou Pedra Funda: Vendedor. `runs` 6 com Maestria 2: Ultimate; `runs` 6 com Maestria 1: não. `wins` 1: Juramentos e Estandarte.
- Save antigo (versão 15) com Vendedor apresentado e `runs` 3: Vendedor continua aberto. Save com Temperar comprado: Forja aberta.
- O guardião vencido na descida-tutorial não abre a Forja.
- Coragem: os testes de `tests/test_courage*` continuam passando sem mudança.

### Critério de aceite
- `tools/test.sh -gselect=test_milestones` e os três testes antigos verdes.
- Na mão (Daniel): cada volta ao Santuário mostra no máximo uma estação nova, com o guia; nada que ele já tinha some.

---

## SW-O6 Robô, `--smoke` e medições (o que não pode quebrar)

### Riscos e a regra
1. **Semente e `RESULT`**: a descida-tutorial só existe com `FirstDescent.active`. O padrão do robô, do `--smoke`, das capturas e da suíte
   **continua a descida normal**. Nada da fase toca no `_rng` da partida quando está desligada. Aceite: o `RESULT` das 12 sementes de QA é o
   mesmo antes e depois, linha por linha (a sessão principal confere).
2. **Parâmetro `--first`**: liga a descida-tutorial em qualquer modo (robô, sem save, captura); `--first --nosave` nunca grava `first`.
   `--first=arrival` para só na chegada e na Antessala (capturas da chegada). Sem `--first`, um save novo de jogador (não robô) entra no
   tutorial; os testes nunca (o gancho `tests/hooks/pre_run.gd` deixa `Save.enabled` falso).
3. **Robô na descida-tutorial**: o `Bot` precisa de duas coisas novas: sair de sala sem luta (`ANTE`: vai à porta) e atravessar as lajes
   (já desvia de laje armada). Uma porta só por sala já funciona (`Rooms.bot_door`).
4. **Medições**: `RunLog` com `"first": true`; `tools/` de equilíbrio (`balance`, QA de 12 sementes) filtram fora essas linhas; o registro
   das partidas do Daniel vai ter uma descida-tutorial por save novo e não pode entrar nas médias de sala.
5. **Testes que travam o grafo** (`tests/test_descent.gd`: toda sala com 2 portas, regras do `_keeps_rules`): o caminho
   `RunMap.scripted` é separado e não muda esses testes.
6. **Exe**: o dado novo é `.tres` de texto (a exportação não converte para binário, `test_export_settings.gd`); conferir o exe com
   `build/linux/ASelagem.x86_64 --headless -- --smoke=30 --seed=5 --nosave` (igual ao editor) e com `--first --smoke=120 --seed=5 --nosave`.
7. **Fase 2 antes**: o SW-R mexe em `RunMap` e no orçamento; o 3A1 começa a partir do commit em que o SW-R entrou, para não brigar no
   `run_map.gd`.

### Dono
- `qa-performance`, no fim da fase (uma vez): 12 sementes normais antes e depois (comparar `RESULT`), 3 sementes com `--first`, e
  `docs/qa/latest_report.md`. Não captura (capturas só a sessão principal).

### Teste GUT
- `tests/test_first_descent.gd` (acima) inclui: sem `--first` e com `Save.enabled` falso, `Rooms.map` é o mesmo grafo de `new_map` para a
  semente 1 (o tutorial não vaza).

### Critério de aceite
- 12 sementes: `RESULT` idêntico; `stuck` 0. 3 sementes `--first`: `first=1`, `stuck` 0, `first_boon_s` < 120.

---

## Plano de lotes (até 4 agentes em paralelo, um dono por arquivo)

Pré-requisito: Fase 2 (SW-R) integrada. Todos partem do mesmo commit, cada um no seu worktree; a API entre eles está fixada neste
documento (`FirstDescent.active`, `Milestones.ult_open`, `ArrivalScene.play`/`finished`/`skip`, `Objective.pick`), então ninguém espera
ninguém: quem chama uma API de outro lote escreve contra a assinatura daqui e, se o outro ainda não entrou, usa um teste com dublê.

| Lote | Agente | Arquivos (só ele mexe) | Entrega | Testes (`-gselect`) |
|---|---|---|---|---|
| 3A1 | `gameplay-engineer` | `first_descent.gd`, `first_descent_def.gd`, `first_room_def.gd`, `run_map.gd`, `rooms.gd`, `game.gd`, `save_data.gd`, `run_log.gd`, `run_report.gd`, `bot.gd`, `boot.gd`, `tools/make_data.gd` (partes `first`, `milestones`, guia `ult`, variante `ante`), `data/` regerado, `docs/reference/rooms.md` | SW-O3 e SW-O4 (descida, Antessala, save, robô, `--first`), as linhas de dado do SW-O5 | `test_first_descent` |
| 3A2 | `gameplay-engineer` (2ª instância) | `milestone_def.gd`, `milestones.gd`, `hub_gate.gd`, `hub_guide.gd`, `hero_loadout.gd`, `scripts/game/hub.gd`, `scripts/game/boss.gd`, `test_hub_gate.gd`, `test_pt5_unlock_guide.gd`, `test_hub_evolution.gd`, `docs/reference/hub.md`, `docs/reference/meta.md` | SW-O5 e o Morvath curto | `test_milestones`, `test_hub_gate`, `test_pt5_unlock_guide` |
| 3A3 | `ui-ux-designer` | `objective.gd`, `objective_line.gd`, `arrival_caption.gd`, `hud.gd`, `first_tips.gd`, `options_screen.gd`, `pause_menu.gd`, `save_slot_screen.gd`, `data/text_pt.tres`, `docs/reference/ui.md` | SW-O2, a legenda do SW-O1, pausa e escolha de save, 5º losango escondido, todos os textos | `test_objective` |
| 3A4 | `environment-artist` | `arrival_scene.gd`, `arrival_timeline.gd`, `assets/shaders/arrival_form.gdshader`, `scripts/render/warmup.gd`, `docs/reference/art_fx.md` | SW-O1 (a cena) | `test_arrival`, `test_warmup` |

Depois, em série:
- **3B integração** (sessão principal): merge na ordem 3A1, 3A2, 3A3, 3A4; `--import`; suíte inteira uma vez; regerar dados; capturas GPU
  uma por vez (chegada em 5 tempos, Antessala, objetivo a 720 e 1080, Morvath curto), cópia em Downloads.
- **3C medida** (`qa-performance`, uma vez): SW-O6; `art-director` revisa as capturas da chegada.
- **3D exe** e o pedido de teste ao Daniel (com as crianças, se ele puder): uma pessoa nova, save novo, cronômetro até a primeira Bênção.
- `disk-janitor` no fim da rodada.

O `room-designer` escreve a posição da faixa de lajes na seção "Antessala" de `docs/design/rooms_progression.md` **antes** de o 3A1 fechar
os dados (meia hora; ele não mexe em código). O `game-director` (este documento) não mexe em arquivo de jogo.

---

## Decisões que só o Daniel pode tomar
- **D-O1 Ordem dos marcos** (SW-O5). Opções: (a) a tabela acima (uma estação por marco, Ultimate em 6 descidas como no SWORN);
  (b) a de hoje, só com a Árvore no marco 0; (c) mais rápida (Ultimate em 3). Recomendo **(a)**.
- **D-O2 Como pula quem já jogou.** (a) só pela pausa ("Pular a primeira descida"); (b) pela pausa e pela pergunta ao criar save quando outro
  espaço já jogou; (c) sem pular. Recomendo **(b)**.
- **D-O3 Objetivo fora do tutorial.** (a) só no tutorial; (b) tutorial e mais 2 descidas, com opção em Configurações; (c) sempre. Recomendo
  **(b)**.
- **D-O4 Chegada nas outras descidas.** (a) só a primeira vez; (b) uma versão curta (feixe e herói, 1,5 s) em toda descida. Recomendo **(a)**
  agora e (b) depois de ver a captura.
- **D-O5 Fala da chegada** (as 3 opções do SW-O1) e **as duas legendas do fim do Morvath curto** (proposta a aprovar: "Morvath recua para o
  fundo das catacumbas." / "O selo ainda não está fechado."). Recomendo a opção 1 para a chegada.
- **D-O6 Morvath curto ou guardião como último.** (a) Morvath só na fase 1 (tabela); (b) a descida-tutorial acaba no Cavaleiro, sem
  Morvath. Recomendo **(a)**: o SWORN mostra o chefe da região já no tutorial, e ver Morvath cedo dá o objetivo das próximas descidas.
- **D-O7 A descida-tutorial conta como vitória?** (decisão 6 do plano SWORN.) Recomendo **não** (como no SWORN depois do patch).
- **D-O8 Lore da cena (pergunta de cânone).** A `premise` diz "quatro paladinos descem"; o `canone.md` diz um paladino do sangue do leão
  por selo e quatro guardiões Juramentados em volta. A cena mostra um herói só surgindo na luz. Está certo mostrar um só (o Guerreiro) e
  deixar os quatro para quando houver os outros heróis? Recomendo **sim**, sem citar números na fala.
