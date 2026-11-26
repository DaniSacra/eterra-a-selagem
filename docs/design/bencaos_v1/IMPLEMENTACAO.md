# Bênçãos V1: implementação

Feito em 2026-11-26 pelo engenheiro de gameplay, na branch do worktree (sem push). Especificação em `00_LEIA_PRIMEIRO.md` a
`05_REFERENCIAS.md` e `BALANCEAMENTO.csv`. Resumo do sistema em `docs/reference/gameplay.md` (item "Bênçãos V1").

## O que existe agora

- Sete anjos, nove poderes cada: 63 Resources `data/boons/v1_NN_<id>.tres`, gerados por `tools/make_data.gd` (`boons`). 35
  principais (um por botão: ataque, especial, Brado, esquiva, Golpe Supremo) e 28 complementares. O E (Investida) não tem Bênção.
- Maré aparece como "Vento" e Marca como "Penumbra" nos textos; os ids de família (`MARE`, `MARCA`) não mudaram.
- Sorteio sem substituição: botão ocupado sai do baralho antes de sortear; complementar espera a capacidade que pede; principal
  pesa o dobro; 0, 1, 2 ou 3 cartas (um anjo sem nenhuma sai antes da porta e a carta de descanso de sempre é a resposta).
  Elo (duo) e Encantos ficam fora do sorteio dos anjos; os recursos continuam.
- Camada nova `Celestial` (`scripts/game/celestial.gd`), com regras puras em `scripts/core/cel_rules.gd` e estado por inimigo em
  `scripts/core/cel_state.gd`. Servem ao Guerreiro e à Maga; a Maga mantém o `Arcane` dela (queima e frio nativos) à parte.

## Arquivos

Novos: `scripts/core/cel_rules.gd`, `scripts/core/cel_state.gd`, `scripts/game/celestial.gd`, 63 `data/boons/v1_*.tres`,
`tests/test_blessings_v1_catalog.gd`, `test_blessings_v1_draw.gd`, `test_blessings_v1_rules.gd`, `test_blessings_v1_combat.gd`.

Alterados:
- Núcleo: `scripts/core/boon.gd` (`grants`, `needs_all`, fatias), `boon_mod.gd` (`PERCENT`, `WHOLE` dos números `cel_*`),
  `boon_needs.gd` (linhas de "Pede ..."), `boon_state.gd` (`offerable`, `still_free`, `draw`, `celestial_held`, `slot_stat`),
  `encounter.gd` (`supply`, `MIN_CARDS`, `CARDS`), `skill_def.gd` (estado aplicado por habilidade, `status_gap`).
- Jogo: `combat.gd` (`hit_enemy` chama a camada; `skill_hit` com estado), `horde.gd`, `enemy.gd` (campo `cel`, lentidão de Frio),
  `skills.gd` (poderes dos botões), `arcane.gd`, `hero_gifts.gd`, `game.gd` (revalidação ao abrir e ao pegar a carta).
- UI: `scripts/ui/boon_choice.gd` (frase com marcadores, números fixos de `CelRules.text_args()`, fatos `cel_*`),
  `scripts/ui/build_column.gd` (principais e complementares separados).
- Dados e textos: `tools/make_data.gd`, `data/text_pt.tres` (nomes, frases, `fact_cel_*`, glossário, "Pede ...").
- Docs: `docs/reference/gameplay.md`.
- Testes adaptados (não afrouxados, só o que a V1 aposenta saiu ou passou a ler o comportamento novo): `test_an2`,
  `test_angel_cards`, `test_bench_ui`, `test_blessing_draw`, `test_blessing_screen`, `test_boon_needs_tag`,
  `test_boon_warrior_reads`, `test_boons`, `test_c4_buttons`, `test_e3_ui`, `test_elo`, `test_end_screen_run`, `test_fatia2`,
  `test_menus_1b`, `test_painted_medallions`, `test_rarity`, `test_rejogabilidade`, `test_talents`.
  Removidos por testar o que a V1 proíbe: o card de troca com "Substitui:" (`test_bench_ui`, `test_e3_ui`), a troca sorteada
  (`test_rarity`, `test_rejogabilidade`) e o Elo na carta (`test_elo`, `test_rejogabilidade`); o `test_blessings_v1_draw`
  garante o contrário.

## Ids: tabela do antigo para o novo

Regra: o id fica quando a família, o botão e o tipo de efeito são compatíveis. Todo id antigo continua carregando (um save, o
registro de partidas e os testes os resolvem); os que saíram do jogo estão em reserva (`reserve`: fora do sorteio, ainda
pegáveis à mão).

Mesmo id, agora poder V1 (31): `golpe_brasa`, `pesado_brasa`, `circulo_brasa`, `passo_brasa`, `chuva_brasas`, `golpe_geada`,
`toque_geada`, `circulo_geada`, `floco_errante`, `peso_inverno`, `estilhaco`, `golpe_radiante`, `pesado_radiante`,
`circulo_radiante`, `ultimo_radiante`, `golpe_firme`, `pesado_firme`, `circulo_firme`, `ultimo_firme`, `golpe_veu`, `pesado_veu`,
`circulo_veu`, `fios_cinza`, `entardecer` (aparece como "Névoa Profunda"), `golpe_mare`, `pesado_mare`, `circulo_mare`,
`golpe_marca`, `pesado_marca`, `circulo_marca`.

Ids novos (32): `combustao`, `chama_contagiosa`, `brasa_persistente`, `fogo_crescente`, `inverno_prolongado`, `geada_profunda`,
`cristais_errantes`, `clarao`, `luz_crescente`, `prosperidade`, `fortuna_celestial`, `esplendor`, `passo_firme`, `ruptura`,
`forca_inabalavel`, `peso_vigilia`, `amparo`, `crepusculo`, `vulnerabilidade`, `essencia_restauradora`, `veu_persistente`,
`passos_leves`, `vendaval`, `cadencia`, `turbilhao`, `brisa_favoravel`, `fluxo_continuo`, `olhar_rapido`, `exercito_ecos`,
`eco_crescente`, `marca_persistente`, `sombra_revelada`, `ressonancia`.

Antigo que saiu do sorteio e ficou em reserva (50): o que era do E (`redemoinho`, `investida_firme`, `passo_claro`,
`passo_geada`, `passo_marca`, `passo_mare`, `passo_radiante`, `passo_veu`, `passos`), os Ômegas (`omega_brasa`, `omega_geada`,
`omega_marca`, `omega_mare`, `omega_veu`), os Supremos antigos (`ultimo_brasa`, `ultimo_geada`, `geada_final`, `final_radiante`,
`final_veu`), os automáticos (`brasas`, `lamina_ardente`, `chama_viva`, `cinza_viva`, `aurora`, `bastiao`, `escudo`, `consolo`,
`firmeza`, `flagelo`, `onda_maior`, `onda_clara`, `rastro`, `vapor`, `vaga`, `espuma`, `correnteza`, `mare_ardente`,
`mare_cheia`, `mira_clara`, `nevoa`, `nevoa_gelida`, `olho_atento`, `olho_firme`, `golpe_certeiro`, `flechas`,
`chuva_flechas`, `guarda_atenta`, `vigia_firme`, `vigilia_longa`, `arrebentacao`).

## Interpretações e limites que a especificação não fecha

- Chuva de Brasas (Supremo de Sarael) aplica Queimadura 4 nos atingidos (a frase não dava o número).
- Passo Firme usa o escudo de um golpe que já existe (`player.shield_ready`) emprestado pelo tempo da Bênção, com a recarga de 8 s.
- Chefes nunca congelam, atrasam nem atordoam; o Impacto só conta em inimigo comum.
- Rarity multiplica só dano extra direto, dano por segundo e bônus relativo de dano (`by_rarity`); durações, contagens, raios,
  chances e recargas ficam fixas.
- O botão de uma Bênção é decidido pela fonte do golpe (`DealtBy.source`), não pela etiqueta: a Investida leva `light` e `dash`
  e nunca recebe uma Bênção de ataque. O Ômega do ataque é do ataque, o do especial é do especial.
- O Brado Ômega da Maga (especial segurado) é o especial dela, não o Brado.
- Salmos que pedem ids antigos continuam como estavam; nenhum foi mexido.
- A porta de Encantos continua igual (fora do sorteio dos anjos).
- Medalhões: as Bênçãos novas sem pintura usam o glifo desenhado (`BoonIcon`), como `BoonArt` já fazia; nenhuma arte nova.
- `error: Rect2 size is negative` em `fx.gd:1950` aparece no smoke da Maga em modo sem tela; existia antes e não é desta mudança.

## Resultados reais

- `tools/check.gd`: `CHECK ok`.
- Testes novos: `test_blessings_v1_catalog` 7/7, `test_blessings_v1_draw` 13/13, `test_blessings_v1_rules` 8/8,
  `test_blessings_v1_combat` 30/30 (inclui o Guerreiro e a Maga, o Investida sem Bênção de ataque, tetos, chefes imunes,
  eco e propagação sem recursão, queimadura que nunca soma).
- Testes de Bênção existentes, um arquivo por vez: todos passando depois da adaptação (lista acima, mais `test_psalms`,
  `test_run_log`, `test_save`, `test_ultimate`).
- Suíte inteira: não rodada (regra desta tarefa); fica para a integração.
- Smoke (`tools/smoke.sh 300 --seed=N`), sem erro de script: semente 1 sala 7, 2 sala 10, 3 sala 9, 4 sala 8, 5 sala 8, 6 sala 8.
  Os 300 s não chegam a Morvath (o chefe nasce perto de 480 a 500 s): `tools/smoke.sh 600 --seed=5` chegou a Morvath aos 501,8 s
  (sala 14, 8 Bênçãos); `--seed=7` aos 482,9 s (sala 14, 7 Bênçãos). Maga, `--hero=maga --seed=5` e `--seed=7`, 300 s: salas 8 e
  9, sem erro de script.

## Pendente ou fora do escopo

- Balanceamento: os números são os do `BALANCEAMENTO.csv`; nenhuma partida de equilíbrio foi rodada (pedido de QA à parte).
- Pintura própria para as 32 Bênçãos novas e o texto final do glossário: aguardam o `art-director` e o Daniel.
- A tela "Suas Bênçãos" ainda agrupa por ação, automática e Elo; a coluna do HUD já separa principais de complementares.
