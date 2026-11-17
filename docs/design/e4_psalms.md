# E4 "Salmos e descobertas": regras e efeitos (E4-01, E4-02)

- **Data**: 2026-11-17. **Autor**: `gameplay-engineer` (autorizado a decidir pelas recomendações, E2 a E6).
- **Base**: `warrior_spec.md` seção 6, `guardian_spec.md` 11.1, D-59 (a) e (c), D-60 (Sentinela, Abrigo, Pastor, Rocha),
  regra central "Dom define o herói, Bênção define a partida, Salmo transforma o poder".
- **Cânone**: nada de lore nova. Os Salmos são **temas** (vigiar, abrigar, guiar, firmeza), não personagens nem
  eventos; o jogo mostra só o nome por tema, sem número e sem citar nenhum texto bíblico (o cânone: "ninguém cita
  versículo"). A ligação com cada salmo fica só nos documentos de design.

## 1. Regras (E4-01; `PsalmDef`, `Psalms`)

| Regra | Como ficou | Onde |
|---|---|---|
| Três grupos | cada grupo é uma lista; vale se uma coisa da lista estiver na mão: Bênção ou Elo (id do `Boon`) ou Dom equipado (`dom:` antes do id do `TalentDef`). **Uma coisa nunca responde por dois grupos** (casamento com volta atrás) | `PsalmDef.requires`, `Psalms.met` |
| Chance | cada carta de um sorteio vira Salmo com 10% quando algum pode vir (5% na recompensa do guardião); o dado só é lido quando algum pode vir, então partidas sem Salmo sorteiam igual a antes | `StageDef.psalm_chance`, `guardian_psalm_chance`, `Psalms.fill` |
| Um por tema | um Salmo tomado tira da mesa todo outro do mesmo `theme` | `Psalms.eligible`, `take` |
| Dois por partida | depois do segundo, nenhum aparece | `Psalms.MAX_PER_RUN` |
| Sem nível nem raridade | não cresce, não troca | carta `BoonState.Card.psalm` (sem `boon`) |
| Descoberta | ver a carta = descoberto (sinal `Game.psalm_offered(psalm, first)`, `first` quando o Compêndio não o tinha); tomar = `Game.psalm_taken(psalm, first)` | `Game._saw_psalm`, `take_psalm` |
| Compêndio | no fim da partida, `codex.psalms.<id>` ganha `seen` e `taken`; Maestria: 25 por Salmo novo visto (`first_psalm_xp`, já existia) | `Game.award_mastery`, `mastery_gain` |
| Registro | `RESULT` e o registro trazem `psalms` (ids tomados, em ordem). Sem mudar a versão do registro: linhas antigas não têm a chave | `Game.result` |
| Robô | pega o Salmo quando vem (e `--autopick` também) | `Game._open_choice` |
| Teste | `--psalm=a,b` toma esses Salmos no começo | `Game._ready` |

**Gente e a tela**: a carta do Salmo é tarefa do `ui-ux-designer` (E4-03). Até a tela existir, uma pessoa não recebe
carta de Salmo (`Game.psalm_cards` falso), para a tela de Bênçãos nunca mostrar uma carta vazia. Contrato para a tela:
`BoonChoice.open_cards(cards: Array[BoonState.Card], state: BoonState, game: Game)` e o sinal `card_chosen(card)`; quando
o método existe, `Game.screen_shows_psalms()` liga as cartas e o `Game` chama `open_cards` e liga `card_chosen` a
`Game.choose_card`. Para desenhar: `card.psalm` (`PsalmDef`): `name_key`, `desc_key` com `text_args()`, `hint_key` (pista
do Compêndio antes de descobrir), `line_key` (frase curta ao tomar), `slot` (a ação que transforma, `Boon.SLOT_KEY`),
`color`; textos fixos `psalm_card` ("Salmo"), `psalm_discovered` ("Salmo descoberto"), `psalm_transforms`,
`psalm_unknown`. A luz do Pastor: `Game.psalms.lights`.

## 2. Os quatro Salmos (E4-02; `data/psalms/`, parte `psalms` do `make_data.gd`)

Cada um muda **como uma ação funciona**, reusando um sistema que já existe. Números de partida, a medir na E6.

| Salmo (tema) | Transforma | Efeito | Números | Grupos (um de cada) |
|---|---|---|---|---|
| **Sentinela** (vigiar; o primeiro, D-71) | o círculo de luz | o círculo não fica onde caiu: anda com o Guerreiro e golpeia cada inimigo que entra nele, uma vez por círculo (e continua prendendo como antes) | golpe de 30 (o do Corte Veloz), atordoamento comum do golpe | Bênção do círculo; Bênção da Vigília (`escudo`, `passos`, `firmeza`, `golpe_firme`, `pesado_firme`); Elo (`bastiao`, `rastro`, `passo_frio`) ou Dom da Magia (`reserva`, `lamina_faminta`, `coracao_da_emeth`) |
| **Abrigo** (abrigar) | a esquiva | onde a esquiva termina fica um abrigo de luz que desfaz os tiros inimigos que o tocam (como a pedra: as meias-luas de Morvath passam) | raio 2,6 m, 3 s, no máximo 2 de pé | Bênção da esquiva; `escudo`, `firmeza`, `consolo` ou `circulo_firme`; Elo (`rastro`, `passo_frio`, `bastiao`) ou Dom da esquiva (`passo_encadeado`, `fio_do_passo`, `investida`) |
| **Pastor** (guiar, reunir) | o especial | cada abate reúne uma luz (uma partícula voa até ele); o especial (e o Ômega do especial) solta uma onda a mais por luz, em leque, e gasta as luzes | até 3 luzes, 14 graus entre as ondas, cada onda igual à do golpe (40 ou 80) | Bênção do especial; Bênção de Luz; Elo (`aurora`, `chama_viva`) ou Dom das ondas (`corte_crescente`, `onda_carregada`, `onda_atravessante`) |
| **Rocha** (firmeza) | o giro (o terceiro golpe) | o giro planta uma pedra de luz: um golpe em volta que atordoa os comuns (armadura absorve; guardião e Morvath nunca) e a pedra fica no chão deixando lento quem pisa nela; outra só quando ela some | 30 em 4 m, atordoa 1 s, fica 3 s | Bênção do ataque; `firmeza`, `escudo`, `pesado_firme`, `estilhaco` ou `peso_inverno`; Elo (`vapor`, `bastiao`) ou Dom do ataque (`quarto_corte`, `golpe_sem_fim`, `furia_plena`, `fio_longo`) |

Por que estes e não os da `warrior_spec.md` 6 (que eram propostas a validar):
- **Sentinela**: a proposta da spec (esquivar através de um aviso deixa o Ômega sem custo) pede esperar o golpe do
  inimigo, o que a identidade do Guerreiro evita ("nada que peça esperar o golpe"), e quase não se vê. O círculo que anda
  com ele e golpeia quem chega é vigiar de verdade, ofensivo e visível.
- **Abrigo** no lugar do Refúgio da spec: o mesmo tema (abrigo), na esquiva que todo jogador usa; é o Salmo de sustento
  que fica como opção de build (a spec deixa os de sustento como opção).
- **Pastor**: a cura por abate da spec é só um número; reunir luz pelos abates e devolver no especial muda a ação.
- **Rocha**: a pedra que atordoa é a "onda de pedra que derruba os comuns" da spec, plantada no chão. O "não ser
  empurrado" ficou de fora: o Guerreiro já não é empurrado pelos corpos (`BodyBlock`).

Leitura visual (provisória, para o `art-director` revisar; só a paleta que já existe, nada acima do glow): o círculo da
Sentinela é o mesmo aro do círculo, andando; o abrigo e a pedra são áreas no chão (`Ground.Kind.SHELTER` em marfim
sobre ouro velho, `STONE` em ouro velho) com um anel ao surgir; o tiro desfeito faísca como na pedra; as luzes do Pastor
são lascas de ouro velho que voam do abatido até ele. Todo dano de Salmo conta como `psalm` no `dealt_by`.

## 3. Pendências
- Carta, moldura, aviso "Salmo descoberto", Compêndio com pista (E4-03 a E4-05: `ui-ux-designer`, `art-director`).
- Tema musical por Salmo (E4-06, D-59 (c)).
- Contador das luzes do Pastor no HUD (`Game.psalms.lights`).
- Balanceamento (E6): chance real de um Salmo numa partida de 7 salas (os grupos com Elo ou Dom são o portão).
