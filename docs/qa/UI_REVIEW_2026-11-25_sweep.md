# Revisão de UI/UX, pente fino de 2026-11-25 (fases 1 a 5 do Plano SWORN)

Só revisão de código e capturas (`docs/gallery/cycle_2026-11-25_sweep/`, `.../cycle_2026-11-25_sworn4/`). Nada foi alterado
no código, nada rodou na GPU. Itens marcados "confirmar" saem da leitura do código e pedem um teste antes de corrigir.
Textos: todas as chaves usadas em `scripts/ui/` existem em `data/text_pt.tres` (as "faltando" do grep são prefixos montados,
`boon_`, `howto_`...) e não há travessão (`—` ou `–`) no arquivo.

## P0 (quebra o uso)

### P0-1. Esc na Videira com figura aberta fecha a Videira inteira (confirmar)
- `scripts/ui/vine_screen.gd:524` (`_unhandled_input`) só trata Esc quando `water_button.has_focus()` ou há `pending`;
  `_back()` (linha 515, que sabe fazer `zoom_out()`) só é chamado pelo clique na barra de ações.
  Com a figura aberta, o Esc passa para `ScreenHost._unhandled_input` (`screen_host.gd:59`), que chama `close()`.
- A barra mostra "Esc VOLTAR" (`vine_zoom.png`), então o teclado e o controle (B) saem do Santuário em vez de voltar ao céu.
- Reproduzir: Santuário, Videira, Enter numa figura, Esc.
- Correção: em `_unhandled_input`, se `event.is_action_pressed(&"ui_cancel")` e `zoomed != &""`, marcar como tratado e
  chamar `_back()`. Cobrir com teste (`zoomed` volta a `&""` e `closed` não é emitido).

## P1 (confunde ou diz a coisa errada)

### P1-1. A linha de objetivo nunca aparece no Santuário nem na tela de Bênção (chaves mortas)
- `scripts/core/objective.gd:27-34` tem `obj_hub_tree`, `obj_hub_portal` e `obj_bless`, mas ninguém monta o contexto
  `place: &"hub"` (só `hud.gd:877` monta, sempre `place: &"run"`, `screen: &""`), e `hud.gd:857-860` esconde a linha quando
  `game.mode != PLAY` (a escolha de Bênção é `Mode.CHOICE`). `ObjectiveLine` só é instanciado no `Hud`.
- Resultado: duas das 13 frases e a pista "Visite a Árvore de Dons" não existem para o jogador.
- Correção: ou ligar o Santuário (instanciar `ObjectiveLine` no hub com `place: &"hub"`) ou apagar as chaves e o teste;
  decidir com o game-director. `obj_bless` pode sair (a tela já tem o título "Escolha uma Bênção").

### P1-2. Linha "Enfrente Morvath" sobra depois da vitória
- `objective.gd:37`: `kind == &"boss"` devolve `obj_morvath` antes de olhar `fighting`, `reward_waiting` e `doors_open`.
  Com Morvath caído (fase de recompensa ou final), a linha segue dizendo "Enfrente Morvath".
- Reproduzir: `--start=boss --boss-hp=0.05` sem robô, matar e olhar o canto superior esquerdo.
- Correção: `if kind == &"boss" and not reward_waiting and doors_open == 0: return &"obj_morvath"` (ou ctx `boss_dead`).

### P1-3. A linha de objetivo some para o robô, então nenhuma captura prova o texto
- `hud.gd:858` exige `game.bot == null`. `first_*.png` e `run_*.png` (varredura com `--bot`) nunca mostram a linha
  (`first_03.png`, `first_08.png`: só "Antessala").
- Correção: bandeira `--showobj` (ou `Dev.has("shot")`) que ignora o robô, e uma captura da Antessala nas lajes e
  uma de sala de luta, em 1280x720, para olhar a colisão com "Sala N de M" e com marcadores do canto.

### P1-4. A Ultimate aparece com o marco fechado
- `scripts/ui/hero_screen.gd:561-566` (`_skills`): sem Ultimate escolhida, mostra a primeira com o texto "Libera na Maestria N";
  `_fixed_ult_row` (linha 569-575) mostra o Supremo com a linha trancada. O mesmo acontece na coluna dos 6 botões da tela de
  Bênção (`bless_1280x720.png`: "Golpe Supremo Shift" apagado, 5º losango do HUD escondido).
- O HUD esconde o 5º losango até abrir, mas a tela do herói e a coluna da Bênção anunciam o botão. Para a criança, é uma tecla
  que "não funciona".
- Correção: com `mastery_level > loadout.level()` pular a linha (ou deixá-la só na tela do herói, com cadeado e sem tecla) e
  tirar "Shift" da coluna da Bênção enquanto fechado. Teste: Maestria 1 não lista `howto_ultimate` na coluna.

### P1-5. O medalhão de porta encosta e corta na borda direita
- `first_03.png`/`first_08.png` (1672 de largura): "Bênção ◂ / Sarael" termina colado na borda, a seta da direita
  fica cortada. Marcador de `rooms.gd _marker`/`door_sign.gd`.
- Correção: limitar o x do rótulo a `viewport_largura - margem` (a mesma `MARGIN` do HUD, 22) ou virar o rótulo para dentro
  quando a porta está no canto. Conferir em 1280x720.

### P1-6. A coluna de habilidades e o glossário da Bênção cobrem o medalhão da direita
- `bless_1280x720.png`: a coluna "Habilidades" e o glossário "Congelar" ficam sobre o medalhão "Nv.1" da pilha de Bênçãos
  (canto direito, atrás do painel) e a escolha de teclas fica 0 px da borda no 1280 (largura 240).
- Correção: o painel direito pode esconder a pilha de Bênçãos do HUD enquanto a tela está aberta, ou o HUD sai de baixo
  da tela (`Hud.veil`). Medir também em 1920x1080 (`bless_1920x1080.png`).

## P2 (polimento)

- P2-1. `vine_zoom.png`: o painel de dica tem um vão grande entre o texto e o preço (altura fixa); a linha "Total agora e
  depois: +0% → +25%" mostra "+0%" para quem ainda não tem nada, o que lê como bônus nulo. Sugestão: "Hoje nada → +25%"
  ou esconder o "agora" quando `now == 0`. Número em si está certo (`NodeTip.fmt`).
- P2-2. `vine.png`: "Raízes crescidas: 4 de 11" flutua no canto inferior direito, sem relação com as figuras, e na figura
  aberta cai sob o painel; alinhar ao rodapé esquerdo, ao lado de "Esc VOLTAR", ou dentro do painel.
- P2-3. `pause_menu.gd:269-271`: o ramo `_sub.emit_signal(&"closed")` não serve para o `AskPage` (que tem `answered` e
  `cancelled`, sem `closed`); funciona porque o `AskPage` consome o Esc antes (`esc_is_no = true`). Frágil: remover o ramo
  para a pergunta ou testar com `_sub is AskPage`.
- P2-4. `save_slot_screen.gd:267`: nessa pergunta o Esc volta aos cartões sem criar o save (`_close_first(n)`), mas o rodapé
  pode prometer outra coisa; conferir a barra de ações da pergunta ("Voltar").
- P2-5. `Objective.tutorial()` (`objective.gd:86`) faz `load()` e monta um dicionário a cada 0,2 s (`hud.gd:859`); guardar
  o resultado por sala.
- P2-6. `dons.png`: a etiqueta "Maestria 11" cobre o nó 2 (selo), e a coluna de legenda se repete (Equipado, Aberto, Selado,
  Escuro) com a dica "Vagas:... Memória:..." no topo; ficam dois blocos de ajuda. Cortar um.
- P2-7. `book.png`: a carteira (Prata, Memória, Esmeralda) está sobre a moldura do livro, tocando a borda superior; descer 8 px
  ou ancorar na barra superior.
- P2-8. Compêndio com pré-requisitos (`boon_needs.gd`): `need_ult` aparece para toda Bênção do slot ULT, mesmo com o marco
  aberto; trocar por "Pede o Golpe Supremo liberado" só se `loadout.level() < mastery` (hoje a mesma frase sai sempre).
  Sem captura do Compêndio nas galerias: pedir uma (`--title --screen=moves`).
- P2-9. `arrival_caption.gd` (BOTTOM 190 px): a legenda de 26 px com 70% da largura quebra em 3 linhas a 1280x720 e chega à
  fileira de losangos (que começa em ~y 850 de 941). Testar `BOTTOM` proporcional ou fonte 22 em telas baixas.

## Top 10
1. P0-1 Esc na Videira fechada fecha tudo.
2. P1-4 Ultimate anunciada com o marco fechado (hero_screen e coluna da Bênção).
3. P1-1 Frases `obj_hub_*` e `obj_bless` mortas.
4. P1-2 "Enfrente Morvath" depois da vitória.
5. P1-3 Linha de objetivo nunca capturada (robô).
6. P1-5 Medalhão da porta corta na borda direita.
7. P1-6 Painel da Bênção sobre a pilha de Bênçãos.
8. P2-8 `need_ult` sempre aparece.
9. P2-9 Legenda da chegada em 1280x720.
10. P2-1 "+0% -> +25%" na dica da Videira.

Não rodei testes nem capturas; os itens confirmar (P0-1, P1-2) pedem um teste curto antes da correção.
