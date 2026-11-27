> Índice: [maga_v1_2026-11-26.md](../maga_v1_2026-11-26.md)

## 12. Divergências entre pacote e código, e decisões registradas

| # | Pacote | Código (HEAD) | Decisão |
|---|---|---|---|
| D-1 | "Mana", "Ataque Potente", "Poder", "Especial" | "Magia"; slots ATTACK, CAST (Poder), SPECIAL | jogo diz "Magia"; Poder é o Estilhaço (CAST), Especial é a Geada (SPECIAL), Ataque Potente é o Arco (omega do ATTACK) |
| D-2 | Centelha "grátis, não gera" | `shot_magick 1.0` | zero |
| D-3 | Arco e Estilhaço: "revisar recargas antigas, medir antes" | Arco 8 s, Estilhaço 4 s | **zero** nas duas (o custo de Magia as regula); plano B documentado no balance: Arco 1,5 s e Estilhaço 0,8 s se o robô passar do limite |
| D-4 | movimento na carga não dito | `charge_move_light 0.03` e virada travada | Maga 0,5 de velocidade e 90 graus por segundo de virada, só dado |
| D-5 | "Centelha aplica Queimadura após três acertos (janela 4 s)" | `spark_hits 3`, `spark_window 4` | confere |
| D-6 | silêncio sobre a Magia na entrada de sala | enche em toda sala | preservada |
| D-7 | silêncio sobre a Magia por morte e por elite | +1 e +40 sobre 50 | preservados (o Guerreiro baixa a elite a 24 porque a barra dele é 30; a da Maga é 50) |
| D-8 | regeneração "proposta 2 por segundo, inclusive movimento e esquiva" | não existe | `HeroDef.magick_regen 2.0` (novo), soma o Dom Fluxo Arcano |
| D-9 | "Supremo carrega por reações efetivas, limitar por conjuração" | carga 75 por Magia gasta, dano e vida | acrescenta reação com teto de 10 por conjuração; a Magia que regenera não conta |
| D-10 | "calibrar o limiar" | `UltDef.charge 75` | **60**, o balance confirma |
| D-11 | "evitar duplicação Arcane/Celestial, contrato explícito" | dois livros separados | R-1 a R-9 (seção 5) |
| D-12 | idem | `CelState.diversity` só conta celestial | continua; contar os do Arcane é pós-V1 |
| D-13 | Arco aplica "Eletrificação" | o estado se chama Eletrizado; "Eletrificação" é o da V2 (Saarael, anjo) | texto: Eletrizado (Arco da Maga), Carga (Saarael) |
| D-14 | silêncio sobre as Bênçãos de Poder (antigo CAST) | o Q da Maga era o Arco, o gatilho do Brado | o Poder é o Estilhaço: as Bênçãos de CAST disparam no ponto de impacto; avisar no Livro |
| D-15 | "Permanência: áreas; Expansão: tamanho" | só existe Geada e brasa como áreas | só essas duas; a Convergência e a Sobrecarga ficam fora |
| D-16 | "limpar estado nas transições" | | resíduo da Trindade, contagem e brasas limpam em sala, morte da Maga e morte do alvo; a Transcendência pronta limpa só em sala e morte (D-19) |
| D-17 | "Transcendência: carregada instantânea" | o toque e o segurar se decidem num limiar de 0,20 s | carga mínima = o limiar (0,20 s); não há como ser menor sem quebrar o `ButtonIntent` |
| D-18 | "Combustão pode voltar via Dom" | `_combust` e `combust_*` no código | ficam sem nó; nenhum Dom os liga nesta versão |
| D-19 | a Transcendência e o Supremo | | a Transcendência pronta **fica** através do Supremo (usar o Supremo não a gasta) e limpa em sala e morte |
| D-20 | "Maga com Magia gasta pouca" | | o `damage_charge 0,03` e o `hurt_charge 1,0` ficam; o balance mede o tempo até o 1o Supremo (meta: sala 3 a 4 de uma descida) |

## 13. Arquivos a mudar por dono

**gameplay-engineer**

| Arquivo | Mudança |
|---|---|
| `tools/make_data.gd` | `_maga_tree`: `arc` vira o segurar do esquerdo (`CHARGE_LIGHT`, tags `omega light arcane volt`, custo 10, carga 0,6, sem recarga); `combust` sai; `shard` (tags `shout cast bolt arcane ice`, custo 5, sem `cooldown`); `dome` sai; `tree.neutral = [spark, arc, shard, frost]`. `_maga_talents`: os 12 novos (a tabela da seção 8, estatísticas por `_raw`), os 12 antigos saem. `_maga`: `magick_on_finisher 0`, `magick_on_break 0`, `cd_floor 0`, `passive_tags []`, `charge_move_light 0.5`, `charge_move_heavy 0.5`, `charge_turn_light 90`, `magick_regen 2.0`; `UltDef.charge 60`. `POISE_WEIGHTS` não muda. Regerar `data/` |
| `scripts/core/hero_def.gd` | `@export var magick_regen := 0.0` (grupo "Magia") |
| `scripts/core/arcane_kit.gd` | `shot_magick 0.0`; `ember_radius 2.0`; `react_charge 5.0`, `react_charge_cap 10.0`; os `combust_*` e `dome_*` ficam (sem nó) |
| `scripts/core/element_book.gd` | `residue` por alvo (Trindade), `spread_*` por origem, `source` em `apply`, tempos `element_time_pct`; a reação tripla devolve duas `Reaction`; `thermal` e `overload` padrão sobem a 35 e 25 (hoje 20 e 15 só nos testes, o kit os sobrescreve) |
| `scripts/game/arcane.gd` | `_serial` por conjuração; `apply_element(..., source)`; `_spread`; Manifestação (`_lay_embers` chamado pela reação); `_step_confluence`; `Reciprocidade`; `_transcend_*`; `react_charge`; `_configure` com `element_time_pct`, `area_*`; as estatísticas antigas (`geada_*_add`, `dome_*`, `react_splash`, `shard_charges`, `arc_targets`, `shot_magick_add`, `ult_charge_pct`) deixam de ser lidas pelos Dons mas o código fica |
| `scripts/game/player.gd` | `magick.gain` da regeneração; `cost_of` e carga perguntam `arcane.transcend_ready()`; gasto no `move_hit` (o do GP-1); consome a Transcendência no `move_hit`; `Skills.trigger_of` não muda |
| `scripts/game/ultimates.gd` | `charge.feed_from(&"react", ...)`; `Arcane` não soma enquanto `vortex != null` |
| `scripts/game/combat.gd` | `on_shot_hit`: não aplica elemento se o golpe foi anulado (4.2) |
| `scripts/game/bot.gd` | a Maga usa toque e segurar do esquerdo e do direito; decide Arco quando há 2 ou mais perto, Geada quando o grupo está parado, Estilhaço na fila; `skip` de `shout_worth`/`rush_worth` |
| `scripts/core/save_data.gd` | `VERSION 18`, `GP5_REMOVED_DONS`, passo `< 18` |
| `scripts/core/ante_lesson.gd`, `scripts/core/first_tips.gd` | degraus e dicas da Maga |

**ui-ux-designer**: `hud.gd`, `action_slot.gd`, `hud_bar.gd` (marcas 5, 10, 20, dois pontos de esquiva, anel da carga), `state_pips.gd` (resíduo), `talent_glyph.gd` (12 glifos), tela de Dons, Livro e Compêndio
(capítulo da Maga), Estandarte dos Heróis (tirar "em prova"), `data/text_pt.tres` (seção 11), `docs/reference/meta.md`, `gameplay.md`, `ui.md` (só a seção que mudou, por grep).

**combat-feel-director**: preparo e recuperação da Centelha (0,25 s cadência), do Arco com carga, do Estilhaço e da Geada; o limiar de 0,20 s com a carga de 0,6 s (um Arco carregado deve sentir-se responsivo);
a leitura das reações (um anel e um som por reação, `react_gap` do som). **art-director**: gesto de conjuração próprio para o Arco e a Geada, cor das brasas (âmbar, não violeta), pips do resíduo.
**balance-designer**: seção 15.

## 14. Testes GUT a escrever (e os que quebram)

Novos (`tests/test_maga_v1.gd` e vizinhos; rodar com `-gselect`):

1. **Dados**: `max_hp 30`, `magick_max 50`, `dodge_charges 2`, `dodge_recharge 1.0`, `blink_distance 4.5`, `magick_regen 2.0`, `charge_move_* 0.5`; a árvore tem exatamente `spark arc shard frost` (sem `combust` nem `dome`);
   `spark` custo 0, `arc` custo 10, `shard` custo 5, `frost` custo 20; nenhum com `cooldown`; entradas `LIGHT, CHARGE_LIGHT, HEAVY, CHARGE`; dano 8, 12 (3 alvos), 6, 5 por segundo por 4 s.
2. **Tags e slots**: Estilhaço cai em CAST e source `shout`; Arco em ATTACK e `omega_attack`; Geada em SPECIAL e `omega_special`; os tiques da Geada e da Queimadura em NONE.
3. **Regeneração**: 5 s parada, andando e esquivando dão +10; nunca passa de 50; morta não regenera; pausa não regenera; Fluxo Arcano dá 3 por segundo; Centelha não dá Magia; Quebra não dá Magia.
4. **Controles**: Q e E não geram golpe da Maga; toque e segurar sem disparo duplo; Magia insuficiente recusa com `magick_refused`; esquiva cancela a carga sem custo (a mesma suíte do `ButtonIntent`).
5. **Estados e reações**: seis ordens de pares (FG, GF, FE, EF, GE, EG), cada uma gera uma só reação e consome só o par; terceiro estado fica; `react_gap 0,5` por alvo; chefe e blindado levam Quebra em vez de congelar;
   reação não aplica estado; limpa em sala e morte; **sem cadeia**: nenhuma reação provoca outra reação, nem brasa que provoca brasa (laço de 10 s sem passar de 3 brasas).
6. **Convergência**: a sequência `[THERMAL, OVERLOAD, OVERLOAD, CRYSTAL]` nos tiques 3, 6, 7, 8; `burn_time >= converge_phase + converge_tick`; chefe sem reação, com 25 por cento do dano; a Convergência não carrega o próximo Supremo.
7. **Supremo**: reação soma 5, cap 10 por conjuração, área uma vez por conjuração; regenerar não carrega; 60 de carga (o `UltDef`).
8. **Dons**: os 12 existem com Vagas, Maestria e Memória da seção 8; os 12 antigos não existem; Afinidade 4,5 s; Catalisador 45,5 e 32,5 e Quebra x1,3; Propagação no mais perto e uma por conjuração, sem propagar o propagado;
   Trindade nas seis ordens (a tripla dá as duas outras e some o resíduo, sem resíduo novo, `react_gap` respeitado); Permanência e Expansão só na Geada e na brasa; Manifestação com máximo de 3 brasas e nenhuma de tique de área;
   Confluência a cada 2 s e só com Geada e brasa juntas; Fluxo Arcano; Agilidade Arcana (0,42 s); Reciprocidade 2 uma vez por conjuração (Geada, que tica 4 vezes, dá 2 só); Transcendência: conta 3 reações efetivas,
   liga, **não** gasta no cancelamento, gasta no `move_hit`, não se recarrega com as reações da conjuração grátis, limpa em sala e morte.
9. **Bênçãos**: o contrato R-1 a R-9: Maga com Sarael e Estilhaço não faz Choque Térmico; 100 reações não geram um estado celestial; Frio dela não soma no medidor do chefe; congelamento da Cristalização é estilhaçado uma vez
   por `cel_shatter_pct`; `CelState.diversity` ignora o Arcane; projétil absorvido não aplica elemento; as Bênçãos de CAST disparam no ponto do Estilhaço; Arco x2 de contagem (ou a exclusão de `arcane`, se o balance decidir).
10. **Save**: migração para 18 (Memória devolvida por id, Vagas livres, ids fora de `opened` `unlocked` `equipped`), idempotente, em save vazio, com 1 id só aberto, aberto mais equipado, em três espaços; os Dons do
    Guerreiro e o Supremo intactos; versão antiga (13) passa por `migrate_redesign(maga)` e depois por 18 sem erro.
11. **HUD**: quatro grupos da Maga, custos 10, 5 e 20, dois pontos de esquiva, marcas da barra, resíduo da Trindade, contador da Transcendência só com o Dom.
12. **Fumaça com a mesma semente**: `tools/smoke.sh 180 --seed=5 --hero=maga` (confirmar a opção de herói) antes e depois dos dados; registrar o novo `RESULT` (a regressão muda de propósito).

**Existentes que quebram e precisam de ajuste** (atualizar, não apagar): `test_maga_kit.gd`, `test_lote_r1_maga.gd`, `test_maga_body.gd`, `test_element_book.gd`, `test_converge.gd`, `test_migrate_redesign.gd`,
`test_dons_medallion.gd`, `test_hero_pick.gd`, `test_hero_station.gd`, `test_hud_lote_b.gd`, `test_boon_needs_tag.gd`, `test_book.gd`, `test_lote_c.gd`, `test_lote_d.gd`, `test_ge1_infra.gd`, `test_courage.gd`
(os que mencionam a Maga ou os ids dos Dons velhos; os que usam `shout`/`rush` do Q e do E caem junto com os do GP-1).

## 15. Para o balance-designer (uma rodada, 12 sementes, depois de implementado)

Medidas com as mesmas sementes e builds sem meta e com cada ápice (Trindade, Confluência, Transcendência, Propagação):

- DPS sustentado (só Centelha), burst (Arco mais Estilhaço mais Geada), **tempo sem Magia** (meta: nunca mais de 4 s no robô), **proporção de golpes pagos contra Centelha** (a Maga não deve só esperar),
  tempo por sala (meta: no máximo 1,15 x o do Guerreiro), sobrevivência (30 de vida, com Passo), e Morvath.
- Quatro números em ordem: (1) custo e recarga do Arco e do Estilhaço (D-3); (2) `UltDef.charge` 60 ou 75 e `react_charge` 5 e cap 10 (tempo até o primeiro Supremo); (3) regeneração 2 por segundo
  (Fluxo Arcano dá +50 por cento: não deve virar o Dom obrigatório); (4) o coeficiente do Arco em `omega_attack` (item da seção 1.1).
- Confirmar que nenhuma build desbloqueada fica inutilizável: a Transcendência com Reciprocidade não se alimenta sozinha (teste de laço fechado), a Confluência não mata chefe sozinha (35 a cada 2 s).

## 16. Riscos

| Risco | Onde | Plano |
|---|---|---|
| Maga fraca em sala vazia (só Centelha) | Estilhaço e Arco sem recarga, mas a Magia vem a 2 por segundo | medir tempo sem Magia; se passar de 4 s, subir a regeneração a 2,5 ou dar 1 de Magia na Quebra |
| Maga forte contra horda | Arco x2 de contagem das Bênçãos em 3 alvos, Propagação mais Trindade mais Confluência | exclusão de `arcane` do coeficiente (seção 1.1), baixar `spread_range` a 2,5 |
| Transcendência encadeia | três reações ligam um golpe grátis que provoca mais três | as reações da conjuração grátis não contam (8) |
| Supremo cedo demais | reação carrega 5 com cap 10 | `UltDef.charge` volta a 75 |
| Brasas e Geada cobrindo a sala (FPS) | até 3 brasas e 1 Geada, cada uma varre `horde.in_circle` | o custo é o mesmo de hoje (brasa e Geada existem); medir no `--stress=300` |
| Clareza visual (fogo, gelo e eletricidade em tela) | pips, anéis, brasas | `WordBudget` e `react_gap` do som já limitam; o `art-director` confere a leitura |
| Dois livros de estado (Arcane e Celestial) confundem | o jogador vê Queimadura de dois jeitos | texto do Livro e o contrato da seção 5; a cor do pip do Arcane é a do `ElementLook` |

## 17. O bug do `Rect2` negativo na Maga (BG-3): não reproduzido sem tela, onde olhar

Sintoma registrado: `error: Rect2 size is negative` no `--smoke` da Maga em modo sem tela (visto em `bencaos_v1/IMPLEMENTACAO.md` e V2 como `fx.gd:1950`); existia antes das Bênçãos V1.
O Godot só emite essa mensagem em `Rect2.intersects`, `has_point`, `merge`, `encloses` e `intersection` (compilação com verificação matemática) quando o tamanho tem componente negativo.

1. **O ponto mais provável já tem correção no HEAD**: `scripts/game/fx.gd` linhas 1942 a 1964 (`_place_numbers`, a pilha de números de dano). O commit `2fc2e33e` (26/11 00:25) trocou a caixa do número por
   `Rect2(l.position, (l.size * pop).max(Vector2(4, 8))).grow_individual(-2, -4, -2, -4)`, com o comentário "an empty label shrunk below zero spammed 'Rect2 size is negative'". A Maga gera **muitos**
   números pequenos por segundo (Queimadura em pedaços de 2, reações, ticks da Geada), com rótulo vazio antes do primeiro layout, o que a faz ser a que mais aciona isso. **Primeiro passo: rodar o `--smoke`
   da Maga de novo no HEAD** (o aviso `fx.gd:1950` das specs de Bênçãos é de **antes** desse commit); se o erro sumiu, fechar o BG-3.
2. **Se ainda aparece**, o suspeito seguinte é **`Hud._update_pointers`** (`scripts/ui/hud.gd` 1337 a 1378) e o que ele chama: `frame := Rect2(view.position + EDGE_INSET, view.size - Vector2(EDGE_INSET.x + EDGE_INSET.z, EDGE_INSET.y + bottom))`
   fica **negativo** quando a janela do `--smoke` é menor que as margens somadas (viewport sem tela de poucos pixels), e `edge_point` chama `view.has_point(sp)` com `view.grow(-VIEW_INSET)` (negativo no mesmo caso) em `_edge`. A
   Maga mostra mais ponteiros e setas de atiradores (`_update_shooters`) por jogar de longe e demorar mais com inimigos fora da tela. A correção é `frame = frame.abs()` ou prender o tamanho a `Vector2.ZERO`
   com `size.max(Vector2.ZERO)` antes do `has_point`, e o mesmo em `view.grow(-VIEW_INSET)`.
3. **Outros candidatos pela busca** (`intersects`, `merge`, `has_point` com `Rect2` calculado): `hud.gd` `_passives_rect` e `_someone_behind` (`body_rect(feet, tall)` com `tall` negativo se `unproject_position` inverter a altura,
   o que acontece com a câmera sem tela), e `hud.gd:1429` `edge_point`. `hub_scenery.gd` e `arena_hazard.gd` não são da partida da Maga.
4. **Como achar em um passo**: rodar `tools/smoke.sh 60 --seed=5 --hero=maga 2>&1 | grep -B2 -A6 "Rect2 size"`; a linha `at:` do erro do Godot dá o arquivo e a linha exatos. Sem isso, pôr um `assert(r.size.x >= 0.0 and r.size.y >= 0.0)` temporário antes de cada
   `has_point` e `intersects` do `hud.gd` e do `fx.gd` e ler o `get_stack()`. Um teste de regressão: criar o HUD com viewport 64 por 64 e chamar `_update_pointers` (não deve imprimir erro).

## 18. O que pede código novo e quanto custa

| Item | Custo | Onde |
|---|---|---|
| Regeneração natural | **L** (uma estatística e um passo) | `HeroDef`, `Player` |
| Trocar botões, custos, recargas e tags da Maga | **D** | `make_data.gd` |
| `ButtonIntent` (toque e segurar), gasto no `move_hit`, Controles | **GP-1** (a Maga reaproveita; zero a mais) | |
| 12 Dons: 6 por dado ou uma linha (Afinidade, Catalisador, Permanência, Expansão, Manifestação, Fluxo Arcano, Agilidade Arcana, Reciprocidade) | **L** | `arcane.gd` |
| Propagação, Trindade, Confluência, Transcendência | **N pequeno** cada (cerca de 40 a 60 linhas e testes) | `element_book.gd`, `arcane.gd` |
| Carga do Supremo por reação com teto | **L** | `arcane.gd`, `ultimates.gd` |
| Origem da aplicação (`source`) e trava de recursão | **N pequeno** | `arcane.gd`, `element_book.gd` |
| Migração de save | **D** (tabela e uma chamada) | `save_data.gd` |
| HUD, glifos, textos, antessala | **UI** | ver seção 13 |
| Estimativa total | **M** (3 a 4 dias de engenharia, um dia de UI, um dia de balance) | |
