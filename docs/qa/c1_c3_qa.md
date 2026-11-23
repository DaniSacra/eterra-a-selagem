# QA C1+C2+C3 + 4 Dons novos (cópia eterra-work-qa, snapshot "base", 2026-11-22)
Só --headless; um Godot por vez; máquina com outros agentes (load 1.5 a 3). Nada foi consertado.

## 1. Importação e suíte
- `--import` ok. `check.gd`: 0 `Parse Error`, 0 `SCRIPT ERROR` (só no GUT, abaixo).
- `tools/test.sh`: 176 scripts, 1685 testes, 1681 passando, 4 falhando, 722,7 s. Arriscados: não listados na saída do GUT desta versão (não medido).
- 3x `SCRIPT ERROR: Attempted to free a RefCounted object` (after_each de `tests/test_blow_family.gd:15` e do teste em `tests/test_bench_ui.gd:423`): `_combat.free()` em `Combat` (RefCounted). O código é igual ao do commit base (`Combat extends RefCounted` no HEAD): não é do lote. P2, limpar com `_combat = null`.

## Falhas (todas nos 4 Dons novos: voz_larga, escudo_de_guerra, folego_de_guerra, ferro_na_investida)
| P | Teste | Causa provável |
|---|---|---|
| P1 | `tests/test_book.gd:160` `test_every_gift_has_its_own_glyph` (4 falhas, uma por Dom) | REGRESSÃO DE VERDADE (falta de arte/UI): `TalentGlyph.IDS` (`scripts/ui/talent_glyph.gd`) não tem os 4 ids; a árvore cai no ícone do ramo. Dono: ui-ux/art. |
| P2 | `tests/test_book.gd:168` `test_path_of_lights...` apex.size() 3, esperado 2 | número velho OU mudança de árvore: um Dom novo entrou no caminho de `golpe_sem_fim` (`tools/make_data.gd:1670`). Confirmar com o designer se o apex deve exigir 3 Dons; se sim, atualizar o teste. |
| P2 | `tests/test_hero_def.gd:82` catálogo 23, esperado 19 | número velho (19 + 4 Dons). |
| P2 | `tests/test_hub_evolution.gd:44` `tree_total` 22, esperado 18 | número velho (idem). |

## 2. Robô evoluído (`tools/smoke.sh 900 --seed=N --talents=quarto_corte,impeto,corte_crescente,lamina_faminta --forge=2 --account=6`, --fixed-fps 60)
Saídas: /tmp/claude-1000/sm/s*.txt (resumo por `RESULT`).
| Semente | Fim | Sala | Tempo | Chefe |
|---|---|---|---|---|
| 1 | morreu (OVER) | 10 | 444,9 s | não chegou |
| 2 | ENDING (Morvath derrotado) | 14 | 629,4 s | boss_at 518,5, 107 s de luta |
| 3 (x2) | morreu | 12 | 476,1 s | não chegou |
| 4 | ENDING | 14 | 722,4 s | boss_at 587,8 |
| 5 | ENDING | 14 | 617,6 s | boss_at 498,2 |
| 6 | morreu | 8 | 310,9 s | não chegou |
- 0 `SCRIPT ERROR`, 0 WARNING, `stuck` 0 e `died_stuck` false nas 7 partidas; nenhuma travada; `max_alive` 6 a 8.
- Determinismo: semente 3 duas vezes, RESULT igual em tudo exceto `fps`/`step_ms` (damage 17727, kills 110, sala 12, 476,1 s). OK.
- "Sala X de 14": `catacombs.tres rooms=13`, HUD e tela final somam +1 = 14; a sala do chefe é a 14 nas 3 vitórias. OK. Profundidades sem repetição indevida (a Provação divide o número com a sala da porta, esperado).
- Fonte antes do minichefe: a sala 3 de TODAS as sementes oferece `fountain` na porta (e o minichefe vem na 4 com `priest_elder`/`knight` em portas). O robô só entrou nela em parte (`fountain_used` true em 3,4,5,6). É opção, não obrigatória; confirmar se era a intenção ("sempre antes de cada minichefe" não está garantido: em 1 e 2 a fonte oferecida não foi a escolhida e não há outra).
- Brado: `dealt_by.shout` 586 a 918 por partida (15 de dano por uso): volta a ser usado a cada ~12 s. Sem evidência de Brado que não volta.
- Não medido diretamente pelo RESULT (sem log por inimigo): inimigos fora da arena, blindagem do sacerdote após a morte, corredor explodindo duas vezes. Cobertura por teste: `tests/test_combat_c1.gd` (burst do corredor, `_end_wards`) passou. Revisão de código: `damage()` sai se `not e.alive`, então o burst é único; `_end_wards` só roda em `damage()`; `clear_crowd()` (horde.gd ~1613) mata sem passar por ela, mas mata junto o sacerdote e quem ele blindava (os elites ficam, e não recebem blindagem: `_step_ward` os exclui), sem resíduo.
- Mortes em 3/6 sementes antes do chefe com o robô evoluído: dificuldade, não bug; sinalizo ao balance-designer (sementes 1, 3, 6).

## 3. Desempenho (`tools/smoke.sh 120 --stress=300`, semente 5 e 1)
- seed 5: `step_ms_avg` 7,37, `peak` 44,72; seed 1: 7,36 / 44,31; `max_alive` 300.
- Referência `docs/qa/bug_hunt_2026-11-21.md`: 5,21 / 33,46 (seed 5). Hoje +41% na média e +33% no pico; `engine.md:303` cita 13 ms por passo no Windows (outra máquina, não comparável). Máquina com 2 a 3 de load de outros agentes: INCONCLUSIVO. Para afirmar regressão, rodar o commit base nas mesmas condições (não feito: não há cópia base). Suspeitas: `_just_began` (O(n) por inimigo pronto a atacar, horde.gd ~627), `_step_ward` e laço de `guard_marks`/`_palms` por quadro. Partidas normais: `step_ms_avg` 0,39 a 0,48 (antes 0,33 a 0,66), `peak` 7 a 12 ms, sem preocupação.
- FPS em GPU: não medido (proibido janela).

## 4. Revisão de código (diff contra o HEAD do repositório principal, lido sem alterar)
- combat.gd: sem erro de lógica encontrado no fluxo. Observações:
  - P2 `hit_enemy` (~666): `dmg = maxf(1.0, roundf(dmg))` agora arredonda e piso 1 para TODO golpe, inclusive o de Brado/zonas de dano baixo; antes ficava fracionário. Muda números e RESULT de balanço (intencional?). Conferir se nenhum teste/zona espera dano 0,x.
  - P2 `_freeze` sob `StunRule.NONE`: recebe `tags` só dos 2 chamadores acima; o terceiro (`_gift_skill`, ~621 `&"freeze"`) chama `_freeze(e, power)` sem tags, então no modo F8 NONE a habilidade de gelo de um Dom nunca congela (só reduz velocidade). Pode ser intencional; confirmar.
  - `gifts.ward` zera? Não: fica > 0 depois do buff acabar, mas `take_ward` exige `rally_left > 0`, e `player.gd:1073` também. OK.
- gift_state.gd: `cooldown_cut` clamp 0..0.5 correto; combo_runner.gd:203 usa o corte do nó em curso (tags do `runner.node` lido em `HeroGifts.step`): o corte vale pelo nó que acaba de rodar, não do que será armado; um Dom `dash` só corta o cooldown quando o nó é o dash. Correto para o desenho.
- hero_loadout.gd (`all_of`, `same_place`): sem erro. `same_place` compara `joins` só para BRIDGE: ok. `all_of` sem uso no jogo além de testes? (não verifiquei).
- boon.gd `button()`: slot DASH distingue `rush` por tag `dash`; um Elo sem modificadores com tag devolve `&""` por definição. OK.
- horde.gd: `e.rows = d.raise_every` em TODO nascimento (spawn): inofensivo só se `raise_every` 0 nos demais; cavaleiro nasce pronto a chamar (intencional, CV-2). `_calls()` não poda `e.raised` (lista cresce, mortos acumulam; inofensivo na escala de uma sala).

## Limitações
WSL, sem tela, sem GPU, sem som; CPU compartilhada com outros agentes distorce `step_ms`; arriscados do GUT não aparecem na saída; Brado/sacerdote/corredor verificados por teste e código, não por log por evento.

## Veredito
Não bloqueia por gameplay (3 vitórias, 0 erros, determinístico). Pendências antes do Daniel: glifos dos 4 Dons (P1) e atualizar os 3 testes de número/árvore (P2) após confirmar o desenho; checar o custo do stress com a máquina livre.
