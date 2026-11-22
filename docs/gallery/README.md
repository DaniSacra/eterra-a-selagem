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
- Refeitas em 2026-11-15 com a pegada nova (a Emeth à frente do corpo, apontando para frente e um pouco para baixo,
  como no quadro do Ember & Blade do Daniel; antes a lâmina ia para trás). Comando: `tools/gpu.sh run --resolution
  960x540 -s tools/pose_lab.gd -- C:/<pasta>/p <clipes...>` e, para cada clipe e vista, os oito quadros reduzidos à
  metade, os 320 px do meio de cada um lado a lado: `ffmpeg -i p_<clipe>_<vista>_0.png ... -i ..._7.png
  -filter_complex "[0:v]scale=480:270,crop=320:270[v0];...;[v0]...[v7]hstack=8" -q:v 3 <clipe>_<vista>.jpg`.
- `grip/`: antes e depois da pegada. `antes_<clipe>_1` e `depois_<clipe>_1` do lado direito, `_2` do lado direito e
  30 graus de cima (a vista 2 do `pose_lab`, como a câmera do jogo o vê correndo pela tela), para `Idle`, `Run`,
  `Sprint` (corrida longa), `Dash` (avanço), `Slash_A` e `Slash_C`; `antes_jogo_*` e `depois_jogo_*` no jogo, na GPU
  a 1920 x 1080 com a câmera mais perto (`--bot --autopick --seed=5 --cam-dist=26`; correndo com `--shot-at=9`, no
  golpe com `--shot-at=6 --shot-on=swing --shot-after=0.05`, parado sem `--bot` com `--shot-at=4`).

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

## MORVATH: A LUTA EM QUATRO FASES

Pedido do Daniel de 2026-11-15, implementado logo depois do ciclo 8 (a proposta de três fases do documento de design foi
substituída por esta). Capturas reais da Godot na RTX 5060 (Forward+), feitas com `--start=boss --boss-only=<ataque>
--shot-on=boss:<momento>` (comandos em `CLAUDE.md`). Números da luta em `data/bosses/morvath.tres` (gerado por `_bosses`
em `tools/make_data.gd`); regras em `scripts/core/boss_rules.gd` e `boss_director.gd`; estados em `scripts/game/boss.gd`.

- **Fase 1, O Despertar (100 a 66%):** [Foice Sepulcral, aviso em arco de 180°](morvath/01_foice_aviso.jpg),
  [o golpe](morvath/02_foice_golpe.jpg), [Lâminas das Almas, duas meias-luas com abertura](morvath/03_laminas.jpg)
- **Fase 2, O Ritual dos Mortos (66 a 33%):** [escudo e erupções](morvath/04_ritual_escudo_erupcoes.jpg),
  [esqueletos guerreiros e magos invocados](morvath/05_ritual_invocados.jpg)
- **Fase 3, A Maldição dos Condenados (33 a 15%):** [o herói amaldiçoado, especial travado](morvath/06_maldicao_heroi.jpg)
- **Fase 4, O Último Suspiro (15 a 0%):** [Tempestade das Seis Almas, aviso](morvath/07_seis_almas_aviso.jpg),
  [as seis meias-luas](morvath/08_seis_almas.jpg), portal e luz verdes espectrais
- **Vitória:** [nada dele fica na sala](morvath/09_vitoria_limpa.jpg)
- **Design:** [`docs/design/morvath_boss_fight.md`](../design/morvath_boss_fight.md)

Pendências visuais: as erupções aparecem como círculos vermelhos, sem as runas verdes da referência; as meias-luas não têm
as caveiras; Morvath golpeia com a lâmina do modelo aprovado, não com uma foice; a maldição no herói é discreta. Na
dificuldade, o robô vence quase sempre: falta medir com gente.

## CICLO 9: MORVATH, A BATALHA DEFINITIVA

Capturas reais da Godot na placa de vídeo (RTX 5060, Forward+, 1920 x 1080) e dois vídeos gravados pela própria Godot
(1280 x 720, sem som), com o comando de cada um em [`cycle9/CAPTURAS.md`](cycle9/CAPTURAS.md). Antes = `3b22cea`
(começo do ciclo), depois = `b29e372` (o `147b481`, bloqueio de corpo, não tem captura). Nenhum dom de fogo nas capturas.

- **Relatório artístico:** [`cycle9/ART_REVIEW.md`](cycle9/ART_REVIEW.md) (mudanças por fase, comparação com a estrutura da
  Hécate sem as nove imagens dela, pendências com responsável e critério, critérios de aceite, veredito)
- **Simulações do robô:** [`cycle9/METRICAS.md`](cycle9/METRICAS.md) (80 lutas; simulação, não teste com gente).
  QA: [`docs/qa/latest_report.md`](../qa/latest_report.md)
- **Vídeos:** [luta inteira sem cortes, 2:13](cycle9/morvath_full_fight.mp4), [cada ataque com rótulo, 1:31](cycle9/morvath_attacks_showcase.mp4)
- **Antes e depois:** [foice](cycle9/before_after_foice.jpg), [ritual](cycle9/before_after_ritual.jpg),
  [maldição](cycle9/before_after_maldicao.jpg), [tempestade](cycle9/before_after_tempestade.jpg), [vitória](cycle9/before_after_vitoria.jpg);
  trabalho das frentes em [`cycle9/work/`](cycle9/work/) (`c9b_*` cenário, `c9c_*` maldição, HUD e vitória)
- **Fase 1, O Despertar:** [Morvath](cycle9/01_morvath_fase1.jpg), [foice, preparo](cycle9/02_foice_preparacao.jpg),
  [foice, golpe](cycle9/03_foice_ataque.jpg), [Lâminas das Almas](cycle9/04_laminas_almas.jpg), [investida](cycle9/05_investida.jpg)
- **Fase 2, O Ritual dos Mortos:** [transição](cycle9/06_transicao_fase2.jpg), [escudo](cycle9/07_ritual_escudo.jpg),
  [invocação](cycle9/08_ritual_invocacao.jpg), [erupções](cycle9/09_erupcoes.jpg)
- **Fase 3, A Maldição dos Condenados:** [transição](cycle9/10_transicao_fase3.jpg), [a maldição pegando](cycle9/11_maldicao_aplicacao.jpg),
  [o Explorador amaldiçoado](cycle9/12_explorador_amaldicoado.jpg)
- **Fase 4, O Último Suspiro:** [transição](cycle9/13_transicao_fase4.jpg), [Tempestade das Seis Almas](cycle9/14_tempestade_seis_almas.jpg),
  [combinação](cycle9/15_combate_final.jpg)
- **Vitória:** [golpe final](cycle9/16_morvath_derrota.jpg), [selagem do portal](cycle9/17_portal_selagem.jpg), [tela "Morvath foi selado"](cycle9/18_tela_vitoria.jpg)
- **Explorador e Emeth:** pegada nova em [`hero/grip/`](hero/grip/)

Pendências visuais principais (detalhes no relatório): Morvath quase branco no golpe final; pontos brancos estourados
girando no escudo; quadros de impacto em preto e branco dos finalizadores a cada 5 s na luta; avisos da foice, da
maldição e da tempestade no vermelho comum; tingido vermelho repetido a cada golpe amaldiçoado; portal vermelho nas fases
1 a 3 (pergunta ao Daniel). A aprovação artística final é do Daniel.

## CICLO 10: LIMPAR E MEDIR

Capturas reais da Godot na placa de vídeo (RTX 5060, Forward+, 1920 x 1080), comandos em
[`cycle10/CAPTURAS.md`](cycle10/CAPTURAS.md). Commits `8a8fed2` (arte), `dcf6632` (jogo) e `196f33c` (interface). Revisão
de arte na seção "C10" de [`boss_arena/ART_REVIEW.md`](boss_arena/ART_REVIEW.md); QA em
[`docs/qa/latest_report.md`](../qa/latest_report.md).

- **Sem branco:** [golpe final, Morvath escurece](cycle10/golpe_final_sem_branco.jpg), [escudo do ritual](cycle10/escudo_ritual.jpg)
  ([recorte](cycle10/escudo_ritual_zoom.jpg)), [orbe do feiticeiro](cycle10/orbe_feiticeiro.jpg) ([recorte](cycle10/orbe_feiticeiro_zoom.jpg))
- **Queimadura:** [na câmara](cycle10/queimadura_fogo.jpg) (aos [7 s](cycle10/queimadura_fogo_t7.jpg) e [12 s](cycle10/queimadura_fogo_t12.jpg);
  [no `196f33c`](cycle10/queimadura_fogo_196f33c.jpg)), [no salão comum](cycle10/queimadura_salao_comum.jpg). O branco que ainda
  aparecia nessas capturas foi corrigido no `00dd13b`: ver [`boss_arena/work/fix_m1_*`](boss_arena/work/)
- **Fase 4:** [clima violeta, fogo mais frio, veios](cycle10/fase4_clima.jpg)
- **Quadro de impacto P&B:** [folha de 2 min](cycle10/folha_quadros_2min.jpg) (4 quadros), [ligado e desligado](cycle10/folha_quadros_pb_ligado_desligado.jpg)
- **Interface:** [opções de conforto](cycle10/opcoes.jpg), [contador do ritual](cycle10/contador_ritual.jpg),
  [golpe sofrido](cycle10/golpe_sofrido_comum.jpg), [amaldiçoado](cycle10/golpe_sofrido_amaldicoado.jpg), ["Derrotado por"](cycle10/derrotado_por.jpg)
- **Outros:** [vídeo do bloqueio de corpo](cycle10/bloqueio_de_corpo.mp4) (o robô lutando cercado, não um andar dirigido),
  [registro de partidas](cycle10/runs_exemplo.jsonl); antes e depois das frentes em [`cycle10/work/`](cycle10/work/)

Pendências visuais: Morvath branco por um quadro com o kit de geada (no vídeo, antes do `00dd13b`, sem captura depois) e a
coluna de geada quase branca sobre ele.

## CICLO 11: A CÂMARA DO SELO

A arena circular de Morvath, pelo pedido do Daniel ([`docs/design/boss_arena_brief.md`](../design/boss_arena_brief.md)),
especificação em [`docs/art/boss_chamber_spec.md`](../art/boss_chamber_spec.md), conta do raio em
[`docs/design/boss_arena.md`](../design/boss_arena.md). Capturas reais na placa de vídeo (1920 x 1080) e dois vídeos
gravados pela Godot (1280 x 720, sem som); comandos em [`boss_arena/CAPTURAS.md`](boss_arena/CAPTURAS.md). Commits
`6b16045`, `482eb6f`, `6bab080`, `72285ab`, `6801e87` e `00dd13b`. **As oficiais `01` e `10` são do `00dd13b`; `02` a `09`,
as montagens e os vídeos são do `6bab080`** (sarcófagos leste e velas da frente um pouco antes do ajuste final; a luta é a
mesma).

- **Revisão de arte:** [`boss_arena/ART_REVIEW.md`](boss_arena/ART_REVIEW.md) (critérios, fidelidade à pintura peça por peça,
  identidade, legibilidade, estados do selo, C10, pendências com responsável, veredito)
- **Métricas:** [`boss_arena/METRICAS.md`](boss_arena/METRICAS.md) (368 lutas do robô; simulação, não teste com gente)
- **Vídeos:** [vitória, semente 4, 2:07](boss_arena/boss_arena_full_fight.mp4), [derrota na fase 4, semente 1, 2:10](boss_arena/boss_arena_full_fight_semente1_derrota.mp4)
- **A câmara:** [vazia](boss_arena/01_arena_vazia.jpg), [Explorador e Morvath](boss_arena/02_explorador_e_morvath.jpg),
  [lado a lado com a pintura](boss_arena/lado_a_lado_referencia.jpg) (a metade esquerda é a pintura de IA, não o jogo),
  [borda e câmera](boss_arena/borda_e_camera.jpg), [os cinco estados do selo](boss_arena/selo_estados.jpg)
- **Fase 1:** [foice, aviso](boss_arena/03_foice_sepulcral.jpg), [foice, golpe](boss_arena/03b_foice_golpe.jpg),
  [investida, aviso](boss_arena/04_investida.jpg), [investida, meio](boss_arena/04b_investida_meio.jpg)
- **Fase 2:** [preparo do ritual](boss_arena/05a_ritual_preparo.jpg), [ritual no centro](boss_arena/05_ritual_central.jpg),
  [reforços](boss_arena/06_invocacao_reforcos.jpg), [erupções](boss_arena/07_erupcoes.jpg), [colunas](boss_arena/07b_erupcoes_colunas.jpg)
- **Fase 3:** [maldição](boss_arena/08_maldicao.jpg), [herói amaldiçoado](boss_arena/08b_amaldicoado.jpg)
- **Fase 4:** [Tempestade das Seis Almas](boss_arena/09_tempestade_seis_almas.jpg), [disparo](boss_arena/09b_tempestade_disparo.jpg)
- **Vitória:** [selo restaurado](boss_arena/10_vitoria_selagem.jpg), [1,2 s](boss_arena/10a_vitoria_1s2.jpg), [2,5 s](boss_arena/10b_vitoria_2s5.jpg)
- **Antes (salão) e depois (câmara):** [arena](boss_arena/before_after_arena.jpg), [investida](boss_arena/before_after_investida.jpg)
  (comandos diferentes, ver `CAPTURAS.md`), [ritual](boss_arena/before_after_ritual.jpg), [tempestade](boss_arena/before_after_tempestade.jpg),
  [vitória](boss_arena/before_after_vitoria.jpg)
- **Trabalho:** [`boss_arena/work/`](boss_arena/work/): `chamber_*` (cenário, estados, navegador), `fix_*` (antes e depois
  das correções do `00dd13b`: queimadura, herói na borda, vitória, pilarete)

Pendências visuais principais (detalhes e pedidos no `ART_REVIEW.md`): chão da câmara muito mais escuro que a pintura;
centro da tempestade sobreposto em rosa quase branco; topo do quadro quase preto, sem o anel de arcadas e as agulhas em
azul; erupções sem o miolo vermelho; velas da frente por cima das pernas do herói; capturas `02` a `09` e vídeos a refazer
no `00dd13b`; peças procedurais e do KayKit provisórias. Os símbolos (leão de pé só no selo, espada erguida no lugar da
cruz) e o raio de 12 m são decisões da sessão a confirmar. A aprovação artística final é do Daniel.

## `lote_5/`: A Fonte, anjos 5 a 7, perigos novos (2026-11-21)
A conta (`f3_fonte`), o Encontro e as cartas de Velael e Galael (`ui_meeting`, `ui_meeting_cards`), a árvore do Jardim mais
escura (`garden`), a Fenda em índigo e a laje que cede (`rift`, `rift_sag`), a grade de espinhos (`crypt_spikes`) e o cabo
mais fino da foice de Morvath (`boss`). Salas com `--hazards` (perigos armados como no fundo da descida).

## `lote_visual/`: musgo, pó de osso, estações fechadas, leões (2026-11-21)
Capturas do lote visual com o Santuário de um save novo (estações fechadas).
