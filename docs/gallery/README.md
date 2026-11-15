# Galeria: inimigos, herói e jogo

Capturas reais da Godot na placa de vídeo (Vulkan Forward+, RTX 5060), do commit 963e16b em diante, para quem não
roda o jogo (outro assistente, revisão de arte). Imagens em JPG.

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
- `referencia_arena`: a imagem de referência do Daniel ("Arena das Catacumbas", feita com IA), o objetivo da arena;
  comparar com `final_vitrine` (mesmo enquadramento, `--showcase`).
- `1_arena` a `7_morvath`: as sete cenas do QA final (arena vazia, combate, sacerdote, elite, medalhão, horda,
  Morvath), do commit 78b0642, antes das correções de arte do ciclo 6.
- `final_vitrine`, `final_luta`, `final_boss`: as mesmas cenas depois das correções (vinheta, estátuas, estandartes).
- `8_horda90`, `9_cercado40`: o herói no meio de 90 e de 40 inimigos (silhueta e anel no chão).
- `10_combate_1920`: 1920 x 1080. `11_titulo`: tela de título. `12_exe_windows`: o .exe exportado.
  `13_combate_opengl3_gpu`: o renderizador do navegador.
- `elo_card`, `elo_formed`, `elo_formed_late`, `elo_panel`: a carta do Elo, o aviso "Elo formado" e o painel "Dons".

Refazer: `tools/enemy_lab.gd` (o argumento `clip` espalha a fila pelo clipe inteiro) e `tools/pose_lab.gd`, pela
`tools/gpu.sh run`.

## CICLO 7: IDENTIDADE VISUAL E COMBATE

Capturas reais da Godot na placa de vídeo (RTX 5060, Forward+), com o comando de cada uma em
[`cycle7/CAPTURAS.md`](cycle7/CAPTURAS.md). As pastas acima (`jogo/`, `enemies/`, `hero/`) ficam como o ANTES.

- **Relatório artístico:** [`cycle7/ART_REVIEW.md`](cycle7/ART_REVIEW.md) (comparação por área, critérios, desempenho, testes)
- **Antes e depois:** [título](cycle7/before_after_titulo.jpg), [arena](cycle7/before_after_arena.jpg),
  [combate](cycle7/before_after_combate.jpg), [inimigos](cycle7/before_after_inimigos.jpg)
- **Tela inicial:** [1280](cycle7/01_titulo_1280.jpg), [1920](cycle7/02_titulo_1920.jpg), [mouse sobre Como Jogar](cycle7/03_titulo_hover.jpg)
- **Explorador:** [parado](cycle7/04_explorador_idle.jpg), [correndo](cycle7/05_explorador_corrida.jpg)
- **Emeth:** [ataque](cycle7/06_emeth_ataque.jpg), [Ômega](cycle7/06b_emeth_omega.jpg), [impacto](cycle7/07_emeth_impacto.jpg), [especial](cycle7/08_emeth_especial.jpg)
- **Inimigos:** [comparativo](cycle7/09_inimigos_comparativo.jpg), [em combate](cycle7/10_inimigos_em_combate.jpg),
  [elite](cycle7/11_inimigo_elite.jpg), [guardião](cycle7/12_guardiao.jpg), [Ancião](cycle7/12b_guardiao_anciao.jpg), [Morvath](cycle7/13_morvath.jpg)
- **Arena:** [geral](cycle7/14_arena_geral.jpg), [portal](cycle7/15_portal.jpg), [estátuas](cycle7/16_estatuas.jpg),
  [abismo](cycle7/17_abismo.jpg), [medalhão](cycle7/18_medalhao.jpg)
- **Combate:** [40 inimigos](cycle7/19_combate_40_inimigos.jpg), [90 inimigos](cycle7/20_combate_90_inimigos.jpg)
- **HUD:** [1280](cycle7/21_hud_1280.jpg), [1920](cycle7/22_hud_1920.jpg)

## CICLO 8: COMBATE TÁTICO, LEGIBILIDADE E POLIMENTO

Capturas reais da Godot na placa de vídeo (RTX 5060, Forward+, 1920 x 1080), com o comando de cada uma em
[`cycle8/CAPTURAS.md`](cycle8/CAPTURAS.md). Antes = `eb1e9d7` (fim do ciclo 7), depois = `84285e8`.

- **Relatório artístico:** [`cycle8/ART_REVIEW.md`](cycle8/ART_REVIEW.md) (critérios do ciclo, problemas, pendências, testes, desempenho a 1080p)
- **Proposta da luta de Morvath (ciclo 9, sem implementação):** [`docs/design/morvath_boss_fight.md`](../design/morvath_boss_fight.md)
- **Antes e depois:** [combate](cycle8/before_after_combate.jpg), [Emeth](cycle8/before_after_emeth.jpg),
  [obstáculo](cycle8/before_after_obstaculo.jpg), [HUD](cycle8/before_after_hud.jpg); trabalho das frentes em [`cycle8/work/`](cycle8/work/)
- **Combate:** [4 inimigos](cycle8/01_combate_4_inimigos.jpg), [8](cycle8/02_combate_8_inimigos.jpg),
  [12](cycle8/03_combate_12_inimigos.jpg), [16](cycle8/04_combate_16_inimigos.jpg), [20](cycle8/05_combate_20_inimigos.jpg)
- **Explorador:** [em combate](cycle8/06_explorador_em_combate.jpg), [atrás do obelisco](cycle8/12_obstaculo_transparencia.jpg)
- **Emeth:** [ataque](cycle8/07_emeth_ataque.jpg), [impacto (Ômega)](cycle8/08_emeth_impacto.jpg), [especial](cycle8/09_emeth_especial.jpg)
- **Inimigos:** [preparando ataque](cycle8/10_inimigos_preparando_ataque.jpg), [preparo no laboratório](cycle8/10b_preparo_laboratorio.jpg),
  [elite](cycle8/11_elite.jpg), [Morvath e o portal vermelho](cycle8/14_morvath_atual.jpg)
- **HUD:** [1920](cycle8/13_hud.jpg)
