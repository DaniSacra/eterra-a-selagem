# O Guardião: auditoria e especificação do herói definitivo

> **2026-11-16, correção do PO**: o primeiro herói é **o Guerreiro** (não o Explorador nem o Guardião). Especificação canônica: `docs/design/warrior_spec.md`; onde este arquivo diz Explorador/Guardião para o herói, vale o Guerreiro (o texto abaixo fica como histórico).


> **Decisões do Daniel (2026-11-16, depois desta spec)**: `docs/design/po_directive_guardian.md`. Mudam esta spec:
> D-50 só texto; D-54 com as **duas ultimates ofensivas** (a U-2 defensiva da seção 6.2 foi recusada; propostas novas em
> `docs/design/ultimate_u2_proposals.md`); D-56 P-A provisória; D-57 desbloqueios que transformam o jogo primeiro; D-58
> começa por cerca de **6 Dons** (os 20 da seção 8.2 são planejamento); D-59 e D-60 começam por **um Salmo** completo. Os
> nomes e os demais pontos de cânone continuam pendentes. Regra central: **Dom define o herói, Bênção define a partida,
> Salmo transforma o poder.**

- **Data**: 2026-11-16 (noite). **Autor**: game-director. **Commit lido**: `19af96b` (HEAD de `arpg-3d`).
- **Pedido**: `docs/design/one_hero_directive.md` (decisões 1 a 12 do Daniel e a missão desta rodada). Nesta rodada só
  auditoria, especificação e backlog: nada implementado.
- **Fontes lidas**: `CLAUDE.md`, `docs/backlog.md`, `docs/design/roadmap_plan.md`, `benchmark_ravenswatch.md`,
  `game_feel_review.md`, `game_feel_directive.md`, `comparativo.md`, `hades2_sistemas.md`; o código de dons, Elo, cartas,
  save, registro, combos, Magia e herói (arquivos citados em cada linha); o cânone em
  `../dungeon-rpg/docs/mundo/canone.md` (seções de 12/11: paladinos, guardiões, fontes de luz, princípios de narrativa).
- **Rodado por mim**: `tools/test.sh` no `19af96b`: **541 de 541** passando (104071 asserções, 112 s). Nada mudado.
- **Regras que valem aqui**: D-39 (mecânicas e números do Hades II fielmente, nomes e arte de Eterra); nunca inventar
  cânone; texto do jogador só em `data/text_pt.tres`, pt-BR sem travessão; conteúdo é dado (`tools/make_data.gd`).
- **Como ler**: todo nome e todo poder abaixo é **proposta** para o Daniel aprovar, com 2 ou 3 opções de nome. "Hades II"
  quer dizer regra ou número lido no estudo de 2026-11-14 (`hades2_sistemas.md`); "a confirmar" é o que o estudo não
  tem; "nosso" é desenho da casa sem base no Hades; "opinião" é minha. As decisões estão numeradas de D-48 em diante
  (seção 15 e `docs/backlog.md` seção 7).

---

## 1. Terminologia: o que muda de nome e onde

A diretriz troca o sentido de uma palavra que já está em todo o jogo. Hoje "dom" é a carta escolhida durante a descida.
Na decisão nova:

| Termo para o jogador (novo) | O que é | Hoje no jogo | No código (proposta) | Equivalente no Hades II | No Ravenswatch |
|---|---|---|---|---|---|
| **Bênção** | uma das três cartas oferecidas na descida; comum, rara, épica ou lendária | "dom" (`Boon`, `data/boons/`, chaves `boon_*`) | continua `Boon` (em inglês "boon" já é bênção); só o texto muda | dom (boon) dos deuses | objeto mágico (só o princípio) |
| **Dom** | talento permanente do herói, destravado pela Maestria, levado para dentro da partida | não existe | `Talent` (`TalentDef`, `data/talents/explorer/`) | carta de Arcana e espelho do Hades I (só a regra de capacidade e custo) | talento por herói |
| **Maestria** | progressão permanente do herói, por partida jogada | não existe (o `Leveling` é da horda antiga e não serve) | `Mastery` (`MasteryCurve`, puro em `core/`) | Fôlego e cinzas das Arcana (só o princípio) | posto do herói |
| **Elo** | Bênção dupla, de duas famílias | igual (`Family.DUO`, `requires`) | igual, com `requires_sets` | dom duplo | não tem |
| **Salmo** | descoberta especial que transforma um Dom, uma Bênção ou uma combinação | não existe | `Psalm` (`PsalmDef`, `data/psalms/`) | dom lendário (regra de três grupos e chance de 10%) | não tem |
| **Compêndio** | registro do que já foi visto e descoberto | só "Golpes" (`MovesScreen`, `Save.data.moves`) | `Codex` (`CodexState` puro, tela `CodexScreen`) | Códice e o Inventário de Dons do Hades | não tem |
| **Fortalecer bênção** | subir um nível de uma Bênção | "Fortalecer dom" (`Reward.POM`) | igual | romã | não tem |

### 1.1 Renomear: três caminhos e o custo de cada um (D-50)

| Opção | O que muda | Custo | Risco |
|---|---|---|---|
| **(a) Só o texto** (recomendada) | valores de cerca de 15 chaves em `text_pt.tres` ("Um dom chega até você", "Escolha um dom", "Dom", "Fortalecer dom", "Dons", "Seus dons", "Nenhum dom ainda.", "Dons levados", "Os dons de luz...", "Todos os dons...", a ajuda da pausa) e o gênero das raridades ("Raro, Épico, Heroico" viram "Rara, Épica, Lendária"); as chaves (`boon_*`) e os ids dos dados ficam | **P** (1 a 2 horas, `ui-ux-designer`, com teste que procura "dom" em toda chave de tela que não seja de Dom) | nenhum no save nem no registro |
| (b) Texto e nomes de classe (`Boon` para `Blessing`, `BoonState`, `BoonCard`, `BoonChoice`, `BoonsScreen`, `BoonArt`, `BoonIcon`, pastas) | cerca de 40 arquivos de código e teste, os `.tres` regerados (o caminho do script muda dentro de cada um), `.uid`, `tools/ui_lab.gd`, `boon_card_view.gd` | **M** (1 dia) e nenhum ganho para o jogador | conflito com qualquer trabalho em paralelo; os `.tres` antigos do histórico deixam de abrir |
| (c) Tudo, inclusive chaves de texto e campos do registro (`gifts` para `blessings`) | (b) mais as chaves de texto e o leitor do `runs.jsonl` | **G** | o `runs.jsonl` do Daniel e as ferramentas do QA quebram, ou precisam ler as duas versões |

O registro guarda `gifts` (lista de Bênçãos tomadas, `Game.run_entry`, `game.gd` linha 1257). Na opção (a) o campo fica
com o nome e o `RunLog.VERSION` sobe para 3 com os campos novos do herói (seção 2.3); o significado fica escrito no
comentário do `RunLog`. Nenhuma linha antiga do `runs.jsonl` precisa de conversão.

### 1.2 O nome do herói (D-48, D-49)
O Daniel chama o herói de "Explorador" e de "Guardião". Os dois têm consequência:
- "Explorador" é o nome do modelo (`hero_explorer`, `HeroCrest`, a folha aprovada) e não diz nada sobre o cânone.
- "Guardião" tem sentido no cânone de 12/11: os **guardiões** são os quatro Juramentados, sem o sangue do leão, que deram
  a vida nos quatro cantos de cada selo e o **seguram**; o sinal deles é a **espada erguida**; "os quatro de Valmor" do
  Prólogo são esses guardiões. Chamar o herói de Guardião diz que ele é desse grupo (ou herdeiro dele). Isso é cânone e
  só o Daniel decide. Também colide com o jogo de hoje: a sala do minichefe se chama "Guardião" (`room_miniboss`) e o
  Cavaleiro e o Ancião são "guardiões" em todo o texto e no código (`miniboss`, `Game.boss_enemy`).
- No código o id fica `explorer` (o nome do modelo) seja qual for o nome final: trocar o nome é só uma chave de texto.
  Neste documento chamo o herói de **Guardião** porque é o nome da diretriz.

---

## 2. Auditoria

### 2.1 O que se reutiliza como está

| Peça | Onde | Para quê no sistema novo |
|---|---|---|
| `BoonMod` (`stat`, `tag`, `values`, `by_rarity`) | `scripts/core/boon_mod.gd` | é o efeito de um Dom: os Dons que só mudam números são `BoonMod` com as estatísticas que o combate já lê (`damage_pct`, `reach_pct`, `cast_size_pct`, `cast_dps`, `burn_dps`, `freeze_time`, `dodge_charges`, `move_speed_pct`, `max_hp`, `shield_cooldown`, `heal_on_kill` e as outras de `combat.gd` e `game.gd`) |
| `Boon.Slot` (um por ação, o novo troca o antigo) | `scripts/core/boon.gd` | a regra "um Dom de ação por ação" usa o mesmo enum |
| `BoonState.stat` (soma por estatística e por tag) | `scripts/core/boon_state.gd` | os Dons equipados entram como uma segunda fonte de `BoonMod` somada na mesma função: todo golpe, círculo e esquiva passa a ler Dom e Bênção sem mudar o combate |
| `SkillDef` (STRIKES, NOVA, ORBIT, FAN, METEOR, CONSECRATE) | `scripts/core/skill_def.gd`, `scripts/game/skills.gd` | os efeitos de área das ultimates e de alguns Salmos (NOVA, CONSECRATE, METEOR) |
| `Magick` (`spend`, `gain`) | `scripts/core/magick.gd` | a carga da ultimate pela regra do Hex conta a Magia gasta: um contador ao lado do `spend` |
| `ComboTree`/`ComboNode` e `tags` | `data/combos/paladin.tres`, `make_data.gd` `_combos` | os Dons que mudam uma ação acrescentam ou trocam nós; as tags continuam sendo o que as Bênçãos enxergam |
| `BoonCard`, `EloLink`, `EloBanner`, `BoonArt` | `scripts/ui/` | a carta do Salmo (moldura própria), a corrente que mostra o que ele transforma, o aviso "Salmo descoberto" e os medalhões pintados |
| `MovesScreen` (lista com "???" para o que não foi achado) e `SaveData.discover_move` | `scripts/ui/moves_screen.gd`, `core/save_data.gd` | o molde do Compêndio: já é um registro de descoberta salvo |
| `SaveData.merged` e `version` | `core/save_data.gd` | migração do save para a versão 3 |
| `RunLog` (`VERSION`, `FIELDS`, `entry`) | `core/run_log.gd` | campos novos do herói no registro |
| `ActionSlot` (losango com tecla e recarga) | `scripts/ui/action_slot.gd` | o 5º losango da ultimate, com o nível de carga no lugar da recarga |
| `Controls` (ações e remapeamento) | `scripts/controls.gd` | a ação nova `ultimate` (teclado R e controle LB livres hoje; o `ui-ux-designer` confirma) |
| `RunMap.Reward`, `Rooms` | `core/run_map.gd`, `game/rooms.gd` | as Bênçãos continuam saindo das portas, do guardião e da loja |

### 2.2 O que se adapta

| Peça | Hoje | Mudança | Por quê |
|---|---|---|---|
| Herói | `Player` com tudo em constantes: `MAX_HP` 30, `MAGICK_MAX` 50, `CAST_*`, `COMBOS` fixo em `paladin.tres` (`player.gd` linhas 19 a 118); `Combat.CAST_RADIUS` 5,4, `CAST_TIME` 3, `CAST_BURST` 150 | `HeroDef` (Resource): id, chave do nome, combos, vida, Magia, números do círculo, corpo (`HeroBody`), espada (`EmethSword`), passiva, ultimates, pasta de Dons, curva de Maestria. Os números atuais viram os do Guardião sem mudar nenhum | é a "arquitetura validada" da diretriz: o próximo herói é outro `HeroDef`, não um `if` |
| Raridade | `Boon.Rarity` COMMON, RARE, EPIC, HEROIC; pesos 85/10/5/0; guardião 0/90/7/5 com o 5 em HEROIC | quatro raridades com os nomes do Daniel e o sorteio em sequência do Hades II (seção 9.3) | a diretriz pede comum, rara, épica e lendária; o guardião do Hades II dá lendário, não heroico (`hades2_sistemas.md` seção 2) |
| Níveis das Bênçãos | `values` com 3 entradas, `max_level` 3, a raridade multiplica tudo | `base` e `per_level` do Hades II, sem teto (C13-05 antigo) | D-39 |
| Elo | `requires` com dois ids exatos, peso 3 na oferta, sobe de nível e tem raridade (a carta mostra "Vapor, Épico", `docs/gallery/boon_cards/ill_1080.jpg`) | `requires_sets` (um de cada lista), 12% por carta, não sobe com romã, sem multiplicador de raridade | D-39: no Hades II o duplo não sobe e tem raridade própria. Hoje é cópia errada |
| Texto das famílias | "Chama, dom de {P2}", "Vigília, voto de {P1}" (o trecho some enquanto o nome não existe) | depende de quem concede as Bênçãos (D-51) | com um herói só, o "voto de PALADIN_1" pode ser o próprio Guardião |
| Save | versão 2; `merged` só copia as subchaves que existem em `defaults()` | versão 3 com `heroes` e `codex`; `merged` precisa de um caso para dicionário com chaves livres | ver 2.3: sem isso o save perde a Maestria ao abrir |
| Registro | versão 2, `gifts` | versão 3 com `hero`, `mastery`, `talents`, `ultimate`, `psalms`, `discoveries` | ler com gente o efeito de cada Dom |
| Texto "Guardião" | sala do minichefe e inimigos | outro nome se o herói for o Guardião (D-49) | dois sentidos para a mesma palavra na mesma tela |
| Premissa | "Quatro paladinos descem às catacumbas" (`premise`) | segue valendo se os outros três estiverem na história e não no controle (D-51) | decisão 2 do Daniel: os outros três não são jogáveis agora |

### 2.3 Migração de dados

**Save (`user://save.json`, `SaveData`, versão 2 para 3).**
- Chaves novas em `defaults()`:
  - `heroes`: `{"explorer": {"mastery_xp": 0, "loadout": [], "ultimate": ""}}`. O nível sai do XP (função pura), não
    se guarda; os Dons destravados saem do nível; só se guarda o que foi escolhido.
  - `codex`: `{"boons": {}, "elos": {}, "psalms": {}, "talents": {}, "enemies": {}}` (id para um pequeno dicionário de
    contagem e primeira vez).
- **Bug latente, tem de ser corrigido antes**: `SaveData.merged` (linhas 24 a 31) percorre só as subchaves de
  `defaults()`. Um dicionário de chaves livres (`heroes.explorer`, `codex.boons.<id>`) é jogado fora a cada leitura. O
  `moves` sobrevive porque é lista. Correção: `merged` copia dicionários de chaves livres inteiros (com o tipo de cada
  valor conferido) e o teste carrega um save com Maestria e Compêndio e confere que nada some.
- Migração do save antigo (versão 1 ou 2): já tem `runs` e `wins`. Proposta (D-57): Maestria retroativa de 40 XP por
  partida e 60 por vitória, no máximo o nível 5, uma vez; quem jogou não começa do zero e não pula a curva.
- Testes: `tests/test_save.gd` com arquivos fixos da versão 1, 2 e 3 (todos abrem, nada válido some, a versão 3 sai).

**Registro (`user://runs.jsonl`, `RunLog`, versão 2 para 3).** Campos novos por partida: `hero` (`explorer`),
`mastery_level`, `talents` (Dons equipados), `ultimate`, `psalms` (Salmos tomados, sala), `discoveries` (o que foi visto
pela primeira vez). `gifts` continua sendo a lista de Bênçãos. Linhas antigas continuam válidas; quem lê confere
`version`.

**Dados (`tools/make_data.gd`).** Partes novas: `_hero` (o `HeroDef` do Guardião), `_talents`, `_mastery` (curva),
`_psalms`. `_boons` muda para `base`/`per_level`, `requires_sets` e as chances; os ids das 32 Bênçãos não mudam (o
registro e os medalhões pintados em `assets/ui/boons/<id>.png` dependem deles).

**Texto (`data/text_pt.tres`).** Opção (a) da seção 1.1, mais as chaves novas (`talent_*`, `psalm_*`, `mastery_*`,
`codex_*`, `ult_*`, `hero_explorer_name`).

### 2.4 O que afeta o balanceamento

| Mudança | Efeito esperado | Como medir |
|---|---|---|
| Dons permanentes | o herói começa a partida mais forte com a Maestria alta; Morvath (6050 de vida) foi medido sem nada disso | robô 0,25 com o conjunto de Dons "Maestria 1" e "Maestria 20" nas mesmas 8 sementes; a meta é a de 2.5 |
| Elo sem nível e sem raridade | Elos mais fracos do que hoje (o Vapor épico de nível 3 vira o número fixo do nível 1) | teste de valor; 8 descidas |
| Bônus de sequência fora (D-10, decidido) | menos dano em todo combo longo | `DamageCalc` testado; 8 descidas |
| Atordoamento dos comuns (D-42, decidido, C12f) | luta mais fácil | 8 descidas antes e depois, já no C12f |
| Descida de 10 salas e economia do Hades II (C13 antigo) | 5 a 8 Bênçãos em Morvath no lugar de 2 a 3 (QA do C12d: `boons_at_boss` 2 a 3) | robô e registro de gente |
| Ultimate | um golpe grande a cada 1 ou 2 salas | dano por fonte no `RESULT` (`hurt_by` já existe para o lado do herói; falta o lado do dano feito por fonte) |
| Lendária (2,5 vezes) | rara; só por troca | contagem no registro |

**Regra proposta (opinião)**: o número de base da luta (vida e dano dos inimigos e de Morvath) é medido sempre com o
herói em **Maestria 1** (sem Dons além do inicial). Dons devem ser na maior parte **escolhas de lado** (mudam como a ação
funciona) e os de poder puro custam caro na capacidade. Meta para a E6: com Maestria 20 a taxa de vitória do robô 0,25
sobe no máximo 25 pontos sobre a Maestria 1 (simulação; a diversão pede teste humano).

### 2.5 Dependências

- E1 (game feel e visual: T3, C12e, C12f, T4) vem antes de tudo.
- E2 (Maestria e Dons) depende de E1 e da DT-012 (save versão 3).
- E3 (Bênçãos e combinações) depende de E2 só para a soma Dom mais Bênção; o resto pode correr junto.
- E4 (Salmos e Compêndio) depende de E3 (requisitos em grupos e sorteio em sequência); a música dos Salmos depende da
  D-12b (decidida) e da D-59.
- E5 (eventos e exploração: Provação, salas de evento, Arenas II) depende de E3 (economia e baralho de recompensas).
- E6 (balanceamento da região) depende de E2 a E5 e dos testes humanos (T5, T6).
- A ultimate precisa de ação nova (`Controls`), losango novo (`ActionSlot`), opção de remapear, efeito e som: é a peça mais
  cara da E2 e a que mais mexe no game feel; entra depois do T4, nunca antes.
- Os Salmos usam as regras de requisito da E3 (`requires_sets`, sorteio em sequência); sem a E3 não há como oferecê-los.
- O Compêndio nasce pequeno na E2 (Dons e Golpes) e cresce na E3 (Bênçãos e Elos) e na E4 (Salmos e inimigos).

### 2.6 Compatibilidade de saves (resumo)
Save da versão 1 ou 2 abre na 3 com Maestria retroativa (D-57), opções e recordes intactos. Save da 3 aberto por uma
versão velha do jogo: as chaves novas são ignoradas e preservadas? **Não**: o `merged` antigo apaga o que não conhece ao
gravar. Isso só importa se o Daniel alternar versões; a regra para os testes é não abrir uma versão mais velha com o save
novo (o QA guarda uma cópia do save antes de cada versão de teste, como já faz com o `runs.jsonl`).

---

## 3. Identidade de combate do Guardião

Uma frase (proposta): **o Guardião segura o chão**. Ele planta os pés para cortar, controla o espaço com o círculo de luz,
pune de longe com a seta e transforma golpes completos em Magia e a Magia em golpes maiores. Não é o herói que foge: é o
que fica, escolhe onde ficar e sai pela esquiva no último instante.

Do kit de hoje, sem mudar número:
- **Plantado**: o golpe não anda (`move_scale` 0), só o avanço do golpe leva até o inimigo (`lunge_toward`). Ler o espaço
  antes de apertar é a habilidade.
- **Alcance médio**: os golpes 1 e 2 alcançam 5,4 m num arco de 150 graus, o giro 3 m em volta. Mais longe que uma faca,
  mais perto que um cajado.
- **Controle**: o círculo prende por 3 s (o chefe só fica lento): é a ferramenta de "segurar".
- **Ômega como recompensa**: os golpes grandes (lança de 160 para frente e para trás, seta de 80) pagam Magia.
- **A Emeth é a arma e o herói**: sem troca de arma (decisões 9 e 10). Toda progressão muda o que a Emeth e as quatro
  ações fazem, nunca troca a Emeth.

Leitura visual (art-director, depois): esmeralda cristalina com ouro em tudo que é dele; o Dom e a Bênção nunca trocam a
cor do herói, só a do golpe (regra que já existe: dons mudam a cor do corte).

---

## 4. Kit inicial (o que já existe, números de hoje)

| Ação | Entrada | O que faz | Números (fonte) |
|---|---|---|---|
| Ataque | E ou clique esquerdo | três golpes: 20, 25 e o giro de 60 em volta | alcance 430/80 = 5,4 m, arco 150 graus, giro 3 m; esperas de hit stop 25, 65, 70 ms (`_combos`) |
| Especial | D ou clique direito | seta de luz | 40 de dano, 62,5 m/s, 11 m; ataque livre 18 quadros depois, especial de novo em 0,7 s, pernas presas 0,71 s (D-44) |
| Círculo de luz | Q | prende os inimigos dentro, um por vez | raio 5,4 m, 3 s, sem proteção, 8 quadros sem atacar (D-44) |
| Esquiva | Espaço | avanço; segurar corre | 0,2 s, 5,6 m, 19 quadros protegido, 1 carga; corrida 11,13 m/s |
| Corte Veloz | ataque logo depois da esquiva | estocada no caminho | 30 de dano, 8 m |
| Ômega do ataque | segurar o ataque 0,8 s | lança para frente e para trás | 160, 13,5 m, 20 de Magia |
| Ômega do especial | segurar o especial 0,65 s | seta larga que atravessa | 80, 10 de Magia |
| Ômega do círculo | segurar o círculo 0,6 s | o círculo explode no fim | 150, 20 de Magia |
| Vida, Magia | | | 30 de vida, 1,3 s de proteção depois de um golpe; 50 de Magia, que enche em toda sala |

**Proposta**: o kit inicial é exatamente esse, mais a **passiva** (seção 5) a partir da Maestria 1 e a **ultimate** da
Maestria 2 (a primeira partida ensina as quatro ações sem uma quinta tecla; opinião, D-54).

---

## 5. Passiva (D-56)

O Hades II não dá passiva à heroína (os aspectos das armas fazem esse papel); a passiva é o princípio do Ravenswatch
("um traço por herói"). Números nossos, a medir.

| # | Nome (opções) | Regra | Por que serve ao Guardião | Custo de código |
|---|---|---|---|---|
| **P-A** | Brilho da Emeth / Lâmina que Responde / Eco da Emeth | cada finalizador (giro, Corte Veloz que acerta, Ômega) que acerta pelo menos um inimigo devolve 2 de Magia, no máximo uma vez por golpe | premia o combo inteiro (o "golpe que pesa") e alimenta o Ômega e a ultimate pela Magia (seção 6, opção de carga A); 10 giros pagam um Ômega do ataque | pequeno: um `stat` novo `magick_on_finisher` lido onde o finalizador acerta |
| P-B | Postura do Guardião / Pé Firme | parado ou golpeando, o golpe que vem pela frente (dentro da cunha do anel) tira 20% menos | lê "segurar o chão" e usa a cunha do anel que já existe (`hero_ring.gdshader`) | médio: direção do golpe recebido em todas as fontes |
| P-C | Vigília / Sentinela | o primeiro golpe de cada sala é anulado (um pulso fino de ouro velho) | defensivo e fácil de ler | pequeno, mas se cruza com a Bênção Escudo da Vigília (mesma regra) |

**Recomendação: P-A.** É a única que muda o jeito de jogar sem mexer na dificuldade de forma direta, casa com a ultimate
pela Magia e é dado quase todo. A P-C duplica uma Bênção que já existe.

---

## 6. Ultimate (D-54, D-55)

### 6.1 A regra de carga (vale para as duas ultimates)

| Opção | Regra | Fonte | A favor | Contra |
|---|---|---|---|---|
| **A, Hex** (recomendada) | fica pronta depois de **gastar** uma quantidade de Magia nos Ômegas (e no Ômega do círculo); usar zera a conta | Hades II: o feitiço de Selene carrega gastando Magia, de 30 a 130 conforme o feitiço (Lunar Ray 30, Twilight Curse 40, Wolf Howl 50, Night Bloom 60, Sky Fall 60, Moon Water 70, Total Eclipse 90, Dark Side 110, Phase Shift 130; `hades2_sistemas.md` seção 8) | D-39 fiel; usa a Magia que já existe; com a passiva P-A forma um laço só: combo, Magia, Ômega, ultimate | no Hades é uma recompensa da partida, não do herói (aqui vira do herói, princípio do Ravenswatch) |
| B, Chamado | barra que enche causando e levando dano; com a barra cheia, a versão inteira; com uma parte, uma versão menor | Hades I (o Chamado dos deuses); números **a confirmar**: a cópia do Daniel é do Hades II e o estudo não leu o Hades I | premia agressão e pune menos quem apanha | sistema novo inteiro; fora da D-39 (Hades II) |
| C, Tempo | recarga fixa | princípio do Ravenswatch (sem números dele) | simples | não conversa com nada do kit |

### 6.2 As duas ultimates (efeitos nossos, carga pela opção escolhida)

| | **U-1** | **U-2** |
|---|---|---|
| Nome (opções) | Lâmina Erguida / Juízo da Emeth / Clarão da Emeth | Muralha de Luz / Cerco de Luz / Bastião |
| Papel | ofensiva: abrir um grupo | defensiva e de controle: segurar um lugar |
| O que faz | o Guardião ergue a Emeth (0,35 s, protegido) e a luz desce num círculo de 6 m em volta dele: 240 de dano (1,5 vez o Ômega do ataque), atordoa os comuns sem armadura por 1 s, tira o dobro da armadura das elites; em Morvath só o dano | por 5 s um anel de luz de 7 m em volta do ponto onde ele está: inimigos dentro ficam 40% mais lentos, tiros inimigos que cruzam o anel se desfazem, o Guardião dentro dele leva 30% menos dano |
| Carga pela regra A | 60 de Magia gasta (o Sky Fall e o Night Bloom do Hades II) | 90 de Magia gasta (o Total Eclipse) |
| Base no Hades II | a regra de carga; o dano e a área são nossos e se medem contra o Ômega | a regra de carga; o efeito é nosso |
| Aviso e leitura | a coluna desce só dentro do círculo (sem clarão branco; molde do `Fx.beam` com teto, ART da E2) | aro fino de ouro velho no chão, sem cobrir os pés dos inimigos (molde do VX-09) |
| Código | NOVA do `SkillDef` com atordoamento (já existe `stun`), entrada nova, losango novo | zona nova no `Ground` (lentidão já existe; apagar tiros e reduzir dano são código novo) |
| Destrava | Maestria 2 | Maestria 10 |

Escolha antes de descer (tela do herói) e fica a partida inteira, como o feitiço do Hades II (um por partida).

**Recomendação**: regra **A**, U-1 primeiro (E2b) e U-2 depois (no fim da E2 ou na E3). Sobre o nome (D-55): "Lâmina
Erguida" ecoa a espada erguida, sinal dos guardiões no cânone; só serve se o Daniel confirmar que o herói é um guardião.
Nenhum nome de ultimate deve falar em Elun nem em Yah sem o Daniel (a pergunta "a Invocação pode ser a luz de Elun chamada
pelo paladino?" segue aberta desde o `hades2_sistemas.md`).

---

## 7. Maestria (D-57)

### 7.1 Regras
- Uma por herói (decisão 4), salva em `heroes.<id>.mastery_xp`. Nunca se perde: morrer guarda tudo o que a partida deu
  (como as cinzas e a psique do Hades II, que ficam ao voltar).
- 20 níveis nesta fase (só uma região). Cada nível destrava **um Dom** (seção 8) e dá **+1 de Devoção** (a capacidade de
  Dons, seção 8.1). Os níveis 2 e 10 destravam as ultimates.
- O XP aparece na tela de fim (barra que enche, nível novo com o Dom novo) e no título (tela do herói).

### 7.2 Como se ganha (números propostos)

| Fonte | XP | Por quê |
|---|---|---|
| Sala de luta vencida | 10 | o grosso vem de jogar, não de vencer |
| Guardião (minichefe) vencido | 25 | marco da região |
| Morvath: cada fase alcançada | 10 (até 40) | quem chega e perde ganha |
| Vitória (selagem) | 50 | |
| Primeira vez (Bênção vista 2, Elo formado 10, Salmo descoberto 25, primeiro guardião 25, primeira vitória 100) | | liga o Compêndio à progressão |

Conta típica (descida de 10 salas): morte na sala 5, cerca de 50; chegar a Morvath e perder na fase 3, cerca de 150;
vitória, cerca de 205.

### 7.3 Curva
XP do nível `n` para o `n+1`: **40 + 10 x (n - 1)**. Do 1 ao 20: 2470 de XP.
- Primeira partida (morte na sala 5): nível 2 (a ultimate). Primeiras cinco partidas: nível 4 a 6.
- Média de 90 por partida de quem está aprendendo: cerca de 27 partidas até o 20; a 12 min por partida, 5 a 6 horas.
- Justificativa (opinião): o Hades II espalha a progressão de Arcana por dezenas de partidas e quatro regiões; nós temos
  uma região de cerca de 12 min, então a meta é terminar a Maestria por volta da 25ª a 30ª partida, com um Dom novo por
  partida no começo e um a cada duas ou três no fim. A curva é dado (`_mastery`), fácil de mudar depois do T5.

---

## 8. Dons (D-58)

### 8.1 Regras
- **Catálogo**, não árvore: cada nível de Maestria destrava o Dom da sua linha (ordem abaixo). Árvore com vizinhança
  (como a grade das Arcana) fica para quando houver mais de 20 (opinião: mais leitura do que ganho agora).
- **Dons de ação** (A, S, C, D, O): mudam uma das ações; **um por ação** (o mesmo `Slot` das Bênçãos). Escolher o de
  ataque tira o outro de ataque.
- **Dons de sustento** (V): números do herói, sem limite por ação.
- **Devoção** (nome em aberto: Devoção / Fôlego / Vigor): capacidade para equipar. Cada Dom custa de 1 a 5; a Devoção é
  **5 + nível de Maestria** (6 no nível 1, 25 no 20). Base: as cartas de Arcana do Hades II custam de 0 a 5 de Fôlego,
  que vai de 10 a 30, e o total das 25 cartas é 56 (`hades2_sistemas.md` seção 9). O total abaixo é cerca de 52; no
  nível 20 cabe metade, como lá.
- Equipa-se antes de descer (tela do herói) e não se troca na partida.
- **Toda mudança de ação mantém as tags da ação** (`light`, `heavy`, `cast`, `dash`, `finisher`, `omega`): uma Bênção de
  ataque continua valendo para o ataque mudado. Regra testável (teste que monta cada Dom de ação e confere as tags).
- Um Dom não tem raridade nem nível (simples; as Arcana sobem com pó lunar, fica para depois).

### 8.2 Catálogo proposto (20 Dons)

"Dado" = só `BoonMod` com estatística que já existe; "código" = estatística ou comportamento novo.

| Nível | Linha | Nome (opções) | Efeito | Custo | Base | Dado ou código |
|---|---|---|---|---|---|---|
| 1 | V | Firmeza do Juramento / Persistência / Fôlego Longo | +10 de vida e +10 de Magia | 2 | Arcana Persistência (+20 a +50 de vida e Magia, custo 2); metade porque a nossa vida base é a mesma e há outros Dons de vida | vida dado; Magia máxima código pequeno |
| 2 | A | Fio Longo / Alcance da Emeth | golpes leves alcançam 15% mais | 1 | nosso (o martelo do cajado no Hades muda o alcance) | dado (`reach_pct` light) |
| 3 | C | Círculo Largo / Círculo Amplo | o círculo fica 25% maior | 1 | nosso | dado (`cast_size_pct`) |
| 4 | D | Corte Veloz Firme / Estocada do Passo | Corte Veloz causa 40% a mais | 1 | nosso | dado (`damage_pct` dash) |
| 5 | S | Seta Pesada / Dardo de Chumbo | a seta causa 50% a mais e a preparação dura 0,1 s a mais | 2 | martelo do Hades II (troca por tempo) | dano dado; preparação no nó (dado de combo) |
| 6 | V | Passo Ligeiro / Pés de Vigília | anda 8% mais rápido | 2 | Arcana do mensageiro (velocidade), a confirmar o número | dado (`move_speed_pct`) |
| 7 | A | Giro Pesado / Volta Completa | o giro (finalizador) causa 30% a mais e empurra mais | 2 | nosso | dado (`damage_pct` finisher; empurrão código pequeno) |
| 8 | O | Carga Breve / Fôlego da Lâmina | os Ômegas carregam 20% mais rápido | 3 | nosso, a conferir contra as Arcana | código (escala do `charge_time`) |
| 9 | C | Círculo que Fere / Chão Firme | o círculo fere 8 por segundo quem está dentro | 2 | nosso | dado (`cast_dps`) |
| 10 | D | Segundo Passo / Passo Duplo | +1 carga de esquiva | 4 | espelho do Hades I (+1 avanço); a confirmar no Hades II | dado (`dodge_charges`) |
| 11 | S | Seta Gêmea / Dardo Duplo | a seta sai em duas, cada uma com 40% menos alcance | 3 | martelo do cajado do Hades II ("dispara 2 projéteis com -40% de alcance") | código |
| 12 | V | Ainda de Pé / Segunda Vigília / Levanta-te | uma vez por partida, ao cair, levanta com metade da vida | 5 | Arcana Morte (desafio à morte, custo 4; a vida devolvida a confirmar) | código |
| 13 | A | Quarto Corte / Sequência do Guardião | o combo ganha um 4º golpe, estocada de 30 antes do giro | 3 | nosso (Ravenswatch: o talento muda a ação) | código pequeno e dado de combo |
| 14 | O | Lança Larga / Lança Dupla | o Ômega do ataque fica 50% mais largo | 2 | martelo do Hades II ("Ômega do ataque +50% e também para os lados", só a parte da largura) | código pequeno (`width` do nó) |
| 15 | C | Círculo que Segue / Círculo Vivo | o círculo acompanha o Guardião em vez de ficar no chão | 3 | nosso | código |
| 16 | D | Passo de Guarda / Esquiva Plantada | esquivar através de um aviso inimigo no último 0,2 s dá 1 s de golpes 30% mais fortes | 3 | nosso (o Hades não tem esquiva perfeita) | código (o aviso já conhece o tempo) |
| 17 | V | Consolo do Abate / Respiro | cada sala vencida cura 2 de vida | 3 | Arcana do filho pródigo (cura por sala), a confirmar | código pequeno |
| 18 | O | Reserva da Emeth / Poço de Magia | +20 de Magia máxima | 3 | Arcana (Magia), a confirmar | código pequeno |
| 19 | S | Seta que Atravessa / Dardo Perfurante | a seta atravessa até 2 inimigos | 3 | nosso | código (conferir o `wave_bolt`) |
| 20 | V | Juramento Cumprido / Lâmina Fiel | a ultimate carrega 25% mais rápido | 3 | nosso | código pequeno |

Na E2a entram os 10 de "dado" e "código pequeno" dos níveis 1 a 10 (exceto o 8); os de "código" maior vêm na E2c.

---

## 9. Bênçãos

### 9.1 O que vira Bênção
As 32 que existem (`data/boons/00` a `31`, `_boons` no `make_data.gd`), com os mesmos ids, famílias e efeitos:
- **Bênçãos de ação** (uma por ação, `Slot`): ataque 4 (`golpe_*`), especial 4 (`toque_geada`, `pesado_*`), círculo 4
  (`circulo_*`), esquiva 4 (`passos`, `passo_*`).
- **Bênçãos que agem sozinhas** (`Slot.NONE`): `brasas`, `redemoinho`, `lamina_ardente`, `estilhaco`, `peso_inverno`,
  `consolo`, `onda_maior`, `flagelo`, `escudo`, `firmeza`.
- **Elos** (6): `vapor`, `aurora`, `chama_viva`, `bastiao`, `rastro`, `passo_frio`.

Nenhuma Bênção depende de quem é o herói: as tags (`light`, `heavy`, `cast`, `dash`, `finisher`, `chama`...) são do kit,
então valem para o Guardião e para qualquer herói futuro que use as quatro ações. Uma Bênção que só faça sentido para um
herói leva `heroes: [id]` (campo novo, vazio = todos).

### 9.2 Famílias e quem concede (D-51)
Chama, Geada, Luz e Vigília. Hoje o texto diz "dom de PALADIN_2, 3, 4" e "voto de PALADIN_1" (escondido até os nomes
existirem). Com um herói só, as opções estão na D-51. O Hades II tem os deuses; nós não podemos ter outros deuses
(cânone: só Yah e Elun).

### 9.3 Raridades e as regras de cada uma (D-52)

O que o Hades II faz (estudo de 2026-11-14):
- Comum, rara, épica e **heroica** são multiplicadores do número do nível 1 (padrão 1 / 1,3 a 1,5 / 1,8 a 2 / 2,3 a 2,5;
  muitos dons com tabela própria, por exemplo 1 / 1,5 / 2 / 2,5).
- Sorteio **em sequência** por carta: começa comum, tenta rara (10%), épica (5%), duplo (12%), lendário (10%); vale o
  último que passar. **Heroica nunca sai no sorteio**: vem da troca (10% por carta, a oferta de outro deus para uma ação
  ocupada entra com +1 de raridade e o mesmo nível) e de efeitos que sobem raridade.
- **De onde vem o lendário no Hades II**: não é uma raridade de multiplicador, é um dom único por deus (11 ao todo: 10
  olímpicos e o Caos), que exige **um dom de cada um de três grupos daquele deus**; aparece com 10% por carta quando o
  requisito está cumprido (Hermes 1%, Caos 5%), 5% no guardião do Érebo e até 20% nas regiões finais; não sobe com romã;
  custa 120 para trocar.

Proposta recomendada (opção a da D-52), que dá os quatro nomes do Daniel e mantém cada regra do Hades II:

| Raridade (Eterra) | Regra | Multiplicador | Como sai | Equivalente no Hades II |
|---|---|---|---|---|
| Comum | o número base | 1,0 | o que sobra do sorteio (85,5%) | comum |
| Rara | | 1,5 (tabela do dom pode mudar) | 10% por carta, em sequência; 90% no guardião | rara |
| Épica | | 2,0 | 5% por carta; 7% no guardião | épica |
| **Lendária** | só sobe uma Bênção que você já tem ou que chega pela troca | 2,5 | troca com +1 de raridade (10% por carta numa ação ocupada) e Dons ou Salmos que sobem raridade; nunca no sorteio comum | heroica |

E o **lendário do Hades II vira o Salmo** (seção 11): mesma regra de três grupos, mesma chance, sem nível. O duplo vira o
Elo (seção 10). Assim cada sistema do Hades II tem o seu lugar e o nome do Daniel.

Detalhes que entram junto (C13-03 antigo): chances em sequência no lugar de pesos (`Boon.RARITY_CHANCE`); a tabela do
guardião com os 5% indo para o Salmo, não para a lendária; o multiplicador fixo 1,5 / 2 / 2,5 até a D-53 (faixa
sorteada ou fixa).

### 9.4 Níveis (romã)
`BoonMod.base` (multiplicado pela raridade) e `per_level` (ganhos do nível 2, 3...; o último se repete; não multiplicado),
sem teto, como o Hades II (C13-05 antigo). Elos e Salmos não sobem. "Fortalecer bênção" (romã) dá +1; a grande +2 na loja
da segunda metade.

### 9.5 Bênçãos e Dons juntos
- As Bênçãos de ação somam com o Dom de ação (os dois são `BoonMod` somados na mesma `stat`). Exemplo: Dom "Fio Longo"
  (+15% de alcance) e Bênção "Golpe Firme" (+12% a +25%) somam.
- Uma Bênção nunca troca um Dom e um Dom nunca troca uma Bênção: são camadas diferentes (o `Slot` vale dentro de cada
  camada).
- O que cruza as duas camadas é o Salmo.

---

## 10. Combinações e Elo

O Elo é o dom duplo do Hades II com nome de Eterra. Hoje: 6 Elos, um por par das 4 famílias (a proporção do Hades II, que
tem 37 para 9 deuses, um por par e mais um), `requires` com dois ids exatos, peso 3 na oferta, sobe de nível e tem raridade.

Proposta (E3, sem decisão porque é cópia errada pela D-39):
- `requires_sets`: um de cada lista, uma lista por família (ex.: Vapor = um de Chama em [brasas, golpe_brasa,
  pesado_brasa, circulo_brasa, passo_brasa] e um de Geada em [toque_geada, golpe_geada, circulo_geada, passo_geada]).
- 12% por carta quando o requisito está cumprido (no lugar do peso 3); 20% no guardião só quando houver mais regiões.
- Não sobe com romã; sem multiplicador de raridade; moldura e cor próprias de Elo na carta (já existe o roxo do Elo e a
  corrente `EloLink`).
- O 7º Elo (o "mais um" do Hades) só quando houver uma 5ª família.

Combinações com Dom: não viram Elo. O Elo é sempre entre duas famílias de Bênçãos. O que liga um Dom a Bênçãos é o Salmo.

---

## 11. Salmos e transformações (D-59, D-60)

### 11.1 Regras
- **O que é**: uma descoberta rara que **transforma** uma ação, um Dom, uma Bênção ou um Elo (não soma número: muda o que a
  coisa faz). É o lendário do Hades II em regra: requisito de três grupos, 10% por carta quando cumprido, 5% no guardião,
  não sobe de nível, no máximo **um por tema** e **dois por partida** (nosso: o Hades limita um lendário por deus).
- **Requisito**: três grupos, cada grupo pode ser um Dom equipado, uma Bênção de uma lista ou um Elo. Assim os Salmos ligam
  a progressão permanente (Dom) à da partida (Bênção).
- **Raridade**: não tem multiplicador; tem a moldura própria "Salmo" (ouro velho com veio esmeralda, nunca o amarelo vivo;
  o `art-director` especifica).
- **Descoberta**: o primeiro Salmo de cada tema aparece numa carta com o nome inteiro e, ao ser tomado, uma frase curta e
  um tema musical próprio (abaixo); fica no Compêndio. Antes disso o Compêndio mostra a entrada como "???" com uma pista do
  requisito ("Pede o círculo e a Vigília"). Um Salmo nunca descoberto pode aparecer (a descoberta é ao vê-lo).
- **Respeito ao cânone**: o cânone diz que "ninguém cita versículo no jogo" e que a fé aparece "no mundo e nas escolhas,
  nunca em sermão". Então: os Salmos usam **temas** dos Salmos bíblicos (pastor, refúgio, sentinela, rocha, cântico novo),
  sem citar texto de nenhuma tradução, sem número no nome mostrado ao jogador (a ligação com o salmo fica só neste
  documento) e sem Deus como personagem. Recomendação na D-59.
- **Música e efeitos**: originais. Cada Salmo tem um tema curto (4 a 8 s) que toca ao descobrir e uma camada leve sobre a
  música de combate enquanto ele está ativo; efeito visual próprio na paleta (esmeralda, ouro velho, marfim, nunca branco
  puro). Fonte da música na D-59 (síntese, CC0, CC-BY com crédito, ou compositor pago, que pede autorização).

### 11.2 Catálogo proposto (8 temas; a E4 entrega 4)

| # | Tema (salmo, só para nós) | Nome (opções) | Transforma | Requisito (três grupos) | Efeito proposto | Código |
|---|---|---|---|---|---|---|
| 1 | Sentinela que não dorme (Sl 121) | Salmo da Sentinela / Salmo dos Montes / Salmo do Guarda | a esquiva | Dom de esquiva; Bênção de esquiva; Bênção de Vigília | esquivar através de um aviso deixa o próximo Ômega sem custo de Magia | médio |
| 2 | Refúgio e asas, a seta que voa (Sl 91) | Salmo do Abrigo / Salmo das Asas / Salmo do Refúgio | o Escudo da Vigília | Bênção `escudo`; Dom ou Bênção de círculo; Bênção de Luz | com o escudo de pé, tiros inimigos que chegam a 3 m se desfazem | médio |
| 3 | O pastor e o vale da sombra (Sl 23) | Salmo do Pastor / Salmo do Vale | o círculo | Dom de círculo; Bênção de círculo; `consolo` ou `firmeza` | abaixo de um terço da vida, o círculo se ergue sozinho em volta do Guardião uma vez por sala e cura 1 por segundo dentro | médio |
| 4 | A rocha e a fortaleza (Sl 18 e 62) | Salmo da Rocha / Salmo da Fortaleza | a passiva e o golpe plantado | Dom de ataque; duas Bênçãos de Vigília | golpeando, o Guardião não é empurrado e o giro abre uma onda curta de pedra (empurra) | médio |
| 5 | Cântico novo (Sl 96 e 98) | Salmo do Cântico Novo / Salmo do Louvor | os Elos | dois Elos; uma Bênção de Luz | cada Elo que você tem soa ao finalizar: os finalizadores soltam uma onda fina (16 por Elo) | médio |
| 6 | Coração limpo (Sl 51) | Salmo da Purificação / Salmo do Coração Limpo | as condições sofridas | Bênção de Luz; Bênção de Vigília; Dom de sustento | maldição, lentidão e congelamento no herói duram metade; a Emeth queima os veios violeta (a maldição de Morvath vira dano em volta ao sair) | médio |
| 7 | A luz e a salvação, o exército acampado (Sl 27) | Salmo da Luz / Salmo do Acampamento | a ultimate | ultimate; duas Bênçãos de Luz | cercado por 4 ou mais inimigos, a ultimate carrega o dobro | pequeno |
| 8 | A árvore junto às águas (Sl 1) | Salmo da Árvore / Salmo das Águas | a fonte | ter usado a fonte; `consolo`; Dom de sustento | a fonte também enche a Magia e sobe um nível de uma Bênção | pequeno, mas a fonte é cânone (sinal do Sopro): D-60 |

Atenção de cânone (D-60): "Lâmpada" é um termo do cânone (a pedra que guarda a vida de um paladino), então nenhum Salmo se
chama "da Lâmpada" mesmo que o tema exista; a fonte de luz é sinal do Sopro e guarda a memória de quem passou por ela, então
o Salmo 8 mexe em algo com significado e precisa do sim do Daniel.

---

## 12. Descoberta e Compêndio

- **Registra** (salvo em `codex`): Bênçãos (vista, tomada, maior raridade, vezes), Elos (formados), Salmos (descobertos,
  com pista enquanto não), Dons (destravados, partidas e vitórias com cada um), Golpes (o que o `moves` já guarda),
  inimigos (vistos, derrotados, o que mais feriu o herói, lido do registro), Morvath (fases alcançadas, vitórias), arenas
  visitadas.
- **Onde aparece**: no título ("Compêndio", ao lado de "Como Jogar") e na pausa (onde hoje estão "Dons" e "Golpes"; o
  painel "Dons" da pausa vira "Bênçãos" e ganha uma aba "Compêndio"). Molde: a `MovesScreen` (lista com "???").
- **Descoberta na partida**: o aviso curto de "Elo formado" (`EloBanner`) vira o molde de "Bênção nova", "Elo novo",
  "Salmo descoberto", sem pausar; XP de primeira vez (seção 7.2).
- **Texto**: só descrição de jogo. Nenhuma entrada de lore (inimigos, Morvath, lugares) até o Daniel escrever ou aprovar a
  partir do cânone (D-62).
- Contador de completude por seção ("Salmos 2 de 8") como meta de longo prazo.

---

## 13. Progressão durante e entre partidas

| Quando | O que cresce | Sistema | Fica ao morrer? |
|---|---|---|---|
| Na partida, por sala | Bênçãos (3 cartas), nível de Bênção (romã), ouro, Magia (enche por sala), carga da ultimate | Bênçãos, `Rooms`, `Magick` | não |
| Na partida, raro | Elo (12%), lendária (troca), Salmo (10% com requisito) | Bênçãos, Salmos | não (o registro no Compêndio fica) |
| Na partida, loja e fonte | Bênção, romã, vida, cura | `Rooms` | não |
| Ao fim da partida | XP de Maestria, descobertas | Maestria, Compêndio | sim |
| Entre partidas | nível de Maestria, Dons destravados, Devoção, a escolha de Dons e da ultimate | tela do herói | sim |
| Depois da primeira vitória (E6, D-63) | Juramentos (os votos do Hades II: dificuldade por escolha) | | sim |

Sem equipamento e sem troca de arma (decisão 9). Ouro só da partida (Hades II).

---

## 14. O que fica para os outros heróis
- `HeroDef` por herói: kit (combos), números, passiva, ultimates, catálogo de Dons, curva de Maestria. Nada do Guardião
  vira regra global.
- Bênçãos e Elos são comuns a todos (dependem das tags das quatro ações), com `heroes` opcional para as exclusivas.
- Salmos podem pedir Dom de um herói (ficam desse herói) ou só Bênçãos (de todos).
- Compêndio e Maestria por herói; a escolha do herói no título só quando houver o segundo.
- O que ficou do Ravenswatch para depois: progressão de posto que destrava "memórias", cooperativo, troca de forma por
  estado (nada disso sem cânone e sem o Daniel).

---

## 15. Decisões do Daniel desta especificação
Numeradas no `docs/backlog.md`, seção 7: D-48 a D-63 (nome do herói, termo do minichefe, como renomear, quem concede as
Bênçãos, raridades, faixa do multiplicador, carga e nomes da ultimate, passiva, Maestria, Dons, Salmos e sua música,
temas, descida de 10 salas, texto do Compêndio, Juramentos).

## 16. Testes previstos (GUT, sem tela)
- `test_mastery.gd`: curva, XP por fonte, nível por XP, retroativo uma vez, morte guarda XP.
- `test_talents.gd`: Devoção e custo, um Dom por ação, Dom soma com Bênção na `stat`, todo Dom de ação mantém as tags.
- `test_save.gd` (estendido): arquivos fixos das versões 1, 2 e 3; `heroes` e `codex` sobrevivem a ler e gravar.
- `test_run_log.gd` (estendido): versão 3 com os campos novos; versão 2 continua lida.
- `test_rarity.gd`: 10 mil sorteios dentro de 1 ponto das chances; lendária nunca no sorteio comum; troca sobe +1.
- `test_elo.gd`: `requires_sets`, 12%, sem romã, sem raridade.
- `test_psalms.gd`: requisito de três grupos com Dom e Bênção, 10%, um por tema, dois por partida, descoberta salva.
- `test_codex.gd`: registra e mostra "???" com pista.
- `test_ultimate.gd`: carga pela Magia gasta, zera ao usar, protegido no gesto, não atravessa menus nem a vitória.
- `title_flow_check.gd`: tela do herói e Compêndio por teclado e controle.
