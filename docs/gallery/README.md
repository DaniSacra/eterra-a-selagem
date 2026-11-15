# Galeria: inimigos, herói e jogo

Capturas reais da Godot na placa de vídeo (Vulkan Forward+, RTX 5060), do commit 963e16b em diante, para quem não
roda o jogo (outro assistente, revisão de arte). Imagens em JPG. Nada aqui é a imagem de referência do Daniel (essas
ficam só no PC dele).

## `enemies/`: os nove inimigos da Fase 1 e todas as animações
- `_todos_game.jpg` (câmera do jogo), `_todos_front.jpg`, `_todos_back.jpg`, `_todos_side.jpg`: o herói à esquerda para
  a escala; na fila da frente Esqueleto, Corredor, Feiticeiro, Arqueiro, Escudo, Sacerdote, Cavaleiro, Ancião e
  Morvath; atrás, as elites (as seis primeiras, em ouro velho). `_todos_walk_front.jpg`: andando.
- `<id>_<animação>_front.jpg` e `_side.jpg`: o mesmo inimigo seis vezes, do começo ao fim da animação, com o herói ao
  lado. Ids: `skeleton` (Esqueleto), `runner` (Corredor), `mage` (Feiticeiro), `archer` (Arqueiro), `guard`
  (Esqueleto de Escudo), `priest` (Sacerdote dos Mortos), `knight` (Cavaleiro, guardião), `priest_elder` (Ancião,
  guardião), `morvath` (chefe).
- Animações: `idle` (parado), `walk`, `attack`, `hit` (levando golpe), `death`, `rise` (saindo do chão); `cast`
  (feiticeiros e sacerdotes), `aim` (arqueiro), `windup` (corredor); Morvath também `slash1` a `slash3`, `dash_windup`,
  `dash`, `summon`, `rain`, `volley`, `roar`, `stunned`.
- Modelos do Meshy (malha reduzida a cerca de 4 mil triângulos), animações da Quaternius e do KayKit transferidas
  para o esqueleto deles. Armas do KayKit presas na mão (lâmina, cajado, besta, escudo do Cavaleiro).

## `hero/`: o herói (o Explorador) com a Emeth
- `<clipe>_0.jpg` de frente e `<clipe>_1.jpg` do lado direito, oito quadros do começo ao fim.
- Clipes: `Idle`, `Run`, `Sprint`, `Roll`, `Dash`, `Slash_A`, `Slash_B`, `Slash_C` (os três golpes do ataque) e seus
  `_Rec` (volta à guarda), `Slash_Combo`, `Sword_Attack`, `Cast` (círculo de luz), `Throw` (especial), `Hit`,
  `Knockback`, `Death`.

## `jogo/`: o jogo rodando
- `1_arena` a `7_morvath`: as sete cenas do QA final (arena vazia, combate, sacerdote, elite, medalhão, horda,
  Morvath), do commit 78b0642, antes das correções de arte do ciclo 6.
- `final_vitrine`, `final_luta`, `final_boss`: as mesmas cenas depois das correções (vinheta, estátuas, estandartes).
- `8_horda90`, `9_cercado40`: o herói no meio de 90 e de 40 inimigos (silhueta e anel no chão).
- `10_combate_1920`: 1920 x 1080. `11_titulo`: tela de título. `12_exe_windows`: o .exe exportado.
  `13_combate_opengl3_gpu`: o renderizador do navegador.
- `elo_card`, `elo_formed`, `elo_formed_late`, `elo_panel`: a carta do Elo, o aviso "Elo formado" e o painel "Dons".

Refazer: `tools/enemy_lab.gd` (o argumento `clip` espalha a fila pelo clipe inteiro) e `tools/pose_lab.gd`, pela
`tools/gpu.sh run`.
