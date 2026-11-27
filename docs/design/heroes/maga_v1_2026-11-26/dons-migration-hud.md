> Índice: [maga_v1_2026-11-26.md](../maga_v1_2026-11-26.md)

## 8. Os 12 Dons (3 ramos x 4)

Mesma estrutura do HEAD (ids 0 a 11 na mesma ordem, mesma Maestria, mesmos custos de Vagas e Memória, assim a migração é a mesma conta por posição). Dom não tem níveis de aprimoramento; é comprado e
equipado. Vagas = `cost`; Maestria = nível que revela; Memória = 0 no nível 1, 1 do 2 ao 5, igual às Vagas acima de 5 (`_talent`). Nenhum Dom ganha botão (slot `NONE`), nenhum soma um comando.
O pacote chama os números de "propostas de protótipo": **são baseline, o balance mede**. `needs` é o Dom que precisa estar equipado.

| # | Ramo | Dom | Camada | Vagas | Maestria | Memória | Exige | Efeito V1 (números de protótipo) | Estatística (`BoonState.stat`) | Tipo |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | Elementalismo | **Afinidade** | entrada | 2 | 1 | 0 | | Queimadura, Frio e Eletrizado duram **50 por cento mais** (3 s vira 4,5 s) | `element_time_pct 0.5` | L |
| 1 | Elementalismo | **Catalisador** | meio | 2 | 5 | 1 | Afinidade | As reações causam **30 por cento mais dano** (Térmico 45,5, Sobrecarga 32,5) e a Quebra da Cristalização sobe 30 por cento | `react_pct 0.3` (já existe) | D |
| 2 | Elementalismo | **Propagação** | meio | 3 | 10 | 3 | Afinidade | Um elemento aplicado por golpe direto **se espalha** para o inimigo sem ele mais perto, a até 3 m, **uma vez por conjuração** e por origem; o espalhado não propaga de novo e pode, ele sim, provocar reação | `spread_range 3.0` | N |
| 3 | Elementalismo | **Trindade** (ápice) | ápice | 4 | 17 | 4 | Catalisador | Toda reação deixa um **resíduo de 3 s** no alvo. Se o **terceiro elemento** (o que não fez parte da reação) chegar nesse prazo, as **duas outras reações** acontecem juntas (soma dos danos e dos efeitos) e o resíduo some | `trinity 1`, `trinity_time 3.0` | N |
| 4 | Conjuração | **Permanência** | entrada | 2 | 2 | 1 | | A **Geada** e a brasa da Manifestação duram **30 por cento mais** (4 s vira 5,2 s) | `area_time_pct 0.3` | L |
| 5 | Conjuração | **Expansão** | meio | 2 | 7 | 3 | Permanência | O raio da **Geada** e da brasa cresce **25 por cento** (2,5 m vira 3,1 m) | `area_size_pct 0.25` | L |
| 6 | Conjuração | **Manifestação** | meio | 3 | 12 | 3 | Permanência | Choque Térmico e Sobrecarga deixam **brasa** no chão por 3 s (raio 2,0 m): quem pisa recebe Queimadura a cada 0,5 s | `ember_floor 1` (já existe), `ember_radius` no kit | L |
| 7 | Conjuração | **Confluência** (ápice) | ápice | 4 | 18 | 4 | Manifestação | Quem está **dentro da Geada e de uma brasa ao mesmo tempo** sofre um Choque Térmico a cada 2 s, sem precisar dos estados e sem consumi-los | `confluence 1`, `confluence_gap 2.0` | N |
| 8 | Feitiçaria | **Fluxo Arcano** | entrada | 2 | 3 | 1 | | A regeneração de Magia sobe **1 por segundo** (2 vira 3) | `regen_add 1.0` | L |
| 9 | Feitiçaria | **Agilidade Arcana** | meio | 2 | 8 | 2 | Fluxo Arcano | Os golpes **segurados** (Arco e Geada) carregam **30 por cento mais rápido** (0,60 s vira 0,42 s) | `charge_time_pct -0.3` (tag `omega`, já existe) | D |
| 10 | Feitiçaria | **Reciprocidade** | meio | 3 | 13 | 3 | Fluxo Arcano | Cada **conjuração** que provoca reação devolve **2 de Magia, uma vez** (não por reação nem por tique) | `reaction_magick 2.0` | L |
| 11 | Feitiçaria | **Transcendência** (ápice) | ápice | 4 | 19 | 4 | Reciprocidade | **Três reações** tornam o **próximo golpe segurado** (Arco ou Geada) **grátis e com carga mínima** (só o limiar de 0,20 s). O benefício se gasta **na execução**, não no cancelamento | `transcend_at 3` | N |

Total de Vagas: 2+2+3+4+2+2+3+4+2+2+3+4 = **33**. A Maestria 20 dá 25 de Devoção: ninguém equipa tudo (decisão como a do Guerreiro).

Regras de cada Dom (limites de recursão e de procs, como pede o pacote):

- **Afinidade** altera `ElementBook.burn_time`, `cold_time`, `volt_time` (e o `burn_dps` não muda). Mais tempo de Frio ajuda a congelar (`cold_hits` expira com o Frio), efeito desejado.
  `Arcane._configure` já reescreve o livro todo quadro, então a mudança sobe com uma linha por estatística.
- **Catalisador**: já existe `react_pct` no `ElementBook` e em `_configure`. A Cristalização não tem dano; o fator entra em `crystal_boss_poise` (Quebra) e não no congelamento (0,8 s fica).
- **Propagação**: fica em `Arcane` (`_spread`). Gatilho: um elemento aplicado com `source direct` e "o alvo ganhou o estado agora" (não renovação). Escolhe o inimigo vivo mais perto, a até
  `spread_range`, que **não** tenha esse estado. Aplica com `source spread` (4.1). Limite: **uma propagação por conjuração** (`_serial`) por elemento, e `react_gap`. O espalhado pode provocar reação
  (isso é o ganho), mas essa reação não propaga, não deixa brasa nem resíduo (regra 4.1).
- **Trindade**: o `ElementBook` guarda `residue_t` e `residue_pair` no dado do alvo. Ao reagir `A+B` abre o resíduo de 3 s (ou renova), exceto para reações de `source area`, `spread` e `ult`. Aplicar
  o elemento `C` (o terceiro) com o resíduo vivo devolve **as duas reações** `A+C` e `B+C` em uma `Array[Reaction]` (o `apply` já devolve um array), cada uma com o dano e o efeito normais, e **limpa o resíduo
  e os estados**. A tripla **não** abre resíduo novo. O `react_gap` vale (a tripla é um disparo). Exemplos: Térmico e depois Eletrizado dá Sobrecarga mais Cristalização; Sobrecarga e depois Gelo dá Térmico
  mais Cristalização; Cristalização e depois Fogo dá Térmico mais Sobrecarga. Seis ordens testadas (seção 11).
- **Permanência e Expansão** mexem só nas **áreas persistentes** da Maga: a Geada e a brasa. Não mexem na Sobrecarga (1,8 m), no Arco, na Convergência nem em projéteis (D-15).
- **Manifestação**: `_lay_embers(at)` (já existe do antigo Chão Ardente) é chamada no fim de uma reação Térmico ou Sobrecarga **que veio de golpe direto, de propagação ou da Trindade**, nunca de um tique
  de área nem da Convergência (4.1, regras 1 e 3). Máximo de 3 brasas vivas, as mais velhas saem. A brasa aplica Queimadura (`source area`) em quem está dentro a cada 0,5 s e não causa dano por si.
  **Raio da brasa**: hoje é `combust_radius` (2,0); como a Combustão sai do kit, o número fica no kit com o nome `ember_radius 2.0` (renomear a constante, sem mudar o valor).
- **Confluência**: `Arcane._step_confluence(dt)`: a cada `confluence_step` 0,5 s varre os inimigos dentro da Geada ativa e de **qualquer** brasa viva; para cada um cujo `confluence_t` já passou
  `confluence_gap`, causa o dano do Choque Térmico (`kit.thermal` mais `react_pct`) e a rajada normal, **sem** consumir estado e **sem** abrir resíduo, brasa nem propagação (`source area`). Chefe
  recebe o dano normal. É o único jeito de a Maga "cobrir" um chefe com reação contínua; por isso o intervalo de 2 s e o dano baixo (35).
- **Fluxo Arcano**: soma ao `magick_regen` (3,0 por segundo). Não afeta Magia ganha por outros meios.
- **Agilidade Arcana**: o `Player` já lê `charge_time_pct` por tag `omega` (o Guerreiro usa); a Geada e o Arco levam a tag. Nada mais.
- **Reciprocidade**: `Arcane` guarda `_recip_serial`; o primeiro `source direct, spread` ou `area` de uma conjuração (`_serial`) que provoca reação dá `magick.gain(2)`; as seguintes da mesma conjuração não.
  Não passa por `KitFeed` (não é acerto). Não carrega o Supremo (a carga lê Magia gasta).
- **Transcendência**: `Arcane` conta reações **efetivas** (as que **contam para a carga do Supremo**, 4.1 e seção 7: direta e propagada, mais uma por conjuração de área). Ao chegar a 3 liga
  `_transcend_ready` (zera a contagem). O `Player`, ao decidir o custo e o tempo de carga do próximo **segurado**, pergunta `game.arcane.transcend_ready()`: custo 0 e carga igual ao limiar
  (0,20 s). O benefício é **consumido no `move_hit`** (a execução), não no aperto nem no cancelamento, e **as reações da conjuração grátis não contam** para a próxima (ela não se recarrega sozinha).
  Limpa na troca de sala e na morte, não no Supremo (D-19). Como o custo é 0, a Magia gasta é 0 e a carga do Supremo pela Magia não sobe; a ressalva do pacote ("sem carga de Supremo por ações gratuitas se a
  regra depender de custo") fica cumprida por construção.

**Sobre Dons que já existem no Guerreiro e a Maga**: Força Concentrada, Concentração, etc. são **do Guerreiro**; um Dom é do herói que o abre. Sustento (Firmeza, Reserva, Respiro, Ainda de Pé) segue
**fora dos 12**, na Videira, como já está.

## 9. Migração de save (versão 17 para 18, idempotente, nos 3 saves)

`SaveData.VERSION` passa a **18** (a 17 é do GP-1 do Guerreiro; se os dois saírem no mesmo exe, os dois degraus ficam na 17: o código não depende do número). Em `SaveData.load`:

```
# files before version 18 (GP-5): the Maga's twelve provisional Dons of 2026-11-24 are gone, their Memória comes back and the Vagas are free
if version < 18:
    migrate_removed_dons(out, GP5_REMOVED_DONS, ["maga"])
```

`migrate_removed_dons` é a função genérica que o GP-1 cria (refatora `migrate_redesign` para receber a tabela e **não** zerar o Supremo escolhido). Se o GP-1 ainda não entrou, o GP-5 a cria igual e o GP-1 a reaproveita.

| Id removido | Memória devolvida | Origem |
|---|---|---|
| `faisca_persistente` | 0 | Maestria 1, aberto de graça |
| `orvalho_gelido` | 1 | Maestria 5 |
| `reacao_amplificada` | 3 | 10 |
| `fissao_termica` | 4 | 17 |
| `geada_demorada` | 1 | 2 |
| `chao_ardente` | 3 | 7 |
| `suspensao_ampla` | 3 | 12 |
| `campo_elementar` | 4 | 18 |
| `eco_eletrico` | 1 | 3 |
| `fluxo_de_magia` | 2 | 8 |
| `estilhaco_gemeo` | 3 | 13 |
| `tempestade_contida` | 4 | 19 |
| **Total possível** | **29** | |

1. **`GP5_REMOVED_DONS := {"maga": {...a tabela acima...}}`**, o mesmo molde de `LEGACY_DONS` (estes 12 ids não repetem nenhum dos legados, conferido). Para cada id em `opened`: devolve a Memória
   (`MaterialPurse.refund(out, MEMORY, n)`, "reembolso, não conta como trazida para casa"), tira o id de `opened`, `unlocked` e `equipped` (a Vaga fica livre). Segunda execução acha zero e devolve 0.
2. **Os 12 novos** aparecem sozinhos pela Maestria (mesmas posições e níveis). **Afinidade** (Maestria 1, Memória 0) nasce aberta como a Faísca nascia. Quem tinha Dons caros recebe a Memória e re-compra.
3. **Maestria, XP, Ressonância, Forja, materiais, Compêndio, Encantos** ficam intactos; o Supremo escolhido **não** é zerado (a Maga só tem um).
4. **Teclas**: `drop_removed_bindings` do GP-1 já apaga `shout` e `rush`; a Maga não precisa de nada a mais.
5. **Aviso de primeira vez**: a dica `controls_v1` do GP-1 serve à Maga; acrescentar a dica única `tip_maga_v1` ("A Maga mudou...", seção 10) por herói em `FirstTips`, uma vez, marcada em `data.hub.tips`.
6. **Dons removidos que a Maga ainda esteja usando no meio de uma descida**: a migração roda só no carregar do arquivo, nunca no meio da partida.
7. **Teste** (seção 11): salvar com 3 ids abertos e 2 equipados, carregar nos 3 espaços, conferir Memória, Vagas, segunda carga sem efeito, Dons do Guerreiro intactos, Supremo intacto, e um save em versão 13 passando pelos degraus `migrate_redesign(maga)` e depois pelo 18 sem erro.

## 10. HUD, Antessala, dicas e Livro (ui-ux-designer)

- **Quatro grupos** (a regra do pacote e do GP-1): **M1** mostra Centelha (toque, "grátis") e Arco Voltaico (segurar, custo 10); **M2** mostra Estilhaço (toque, custo 5) e Geada (segurar, custo 20);
  **Espaço** mostra o Passo Etéreo com as **2 cargas** (pontos que enchem em 1 s cada); **Shift** mostra o losango da Convergência com o anel de carga. Cada metade apaga e mostra o custo em vermelho quando
  falta Magia; o anel de carga do segurado (`charge_progress`) enche do aperto ao golpe; cancelar apaga sem custo.
- **Barra de Magia** com marcas em 5, 10 e 20, máximo sempre `player.magick.max_value` (50 sem Dom que mexa), e **um pulso discreto** quando a regeneração a enche (nenhum número novo na tela).
- **Estados elementais**: `StatePips` já mostra Queimadura, Frio e Eletrizado sobre o inimigo; acrescentar o **resíduo da Trindade** como um anel fino (3 s) sobre o inimigo e, com a **Transcendência pronta**,
  um marcador "grátis" dourado sobre as metades segurar de M1 e M2 (Arco e Geada) até ela ser gasta. Contador de reações da Transcendência (0 a 3)
  em três pontinhos sob a barra de Magia, só com o Dom equipado.
- **Antessala** (`AnteLesson`): `ORDER` da Maga `[attack, power, dodge, special, blessing]` como o do Guerreiro: o degrau "attack" ensina a Centelha, "power" o Estilhaço, "special" a Geada (segure o direito).
  O Arco é ensinado pela dica `hold`. Eventos: `power` (Estilhaço acerta), `special` (Geada sai). Robô: `skip`.
- **Dicas** (`FirstTips`): `hold` (já do GP-1) ganha a variante da Maga ("Segure {attack} para o Arco Voltaico ou {special} para a Geada"); `tip_regen` (primeira vez com a barra vazia: "A Magia volta sozinha, 2 por segundo").
- **Livro de Ahk, Compêndio e tela de Dons**: capítulo da Maga com a tabela de golpes (6 linhas), as três reações com o par de cada uma, a Convergência por fases (a tabela da seção 7), e os 12 Dons nos 3 ramos
  (a árvore radial, 3 ramos a partir do herói, compra para fora, como já é). Glifos novos em `talent_glyph.gd` para os 12 ids (os antigos 12 saem). O Estandarte dos Heróis (`howto_maga`, `heroes_desc_maga`,
  `hub_descend_line_maga`) perde "Ainda em prova, sem Maestria nem Dons por ora": a Maestria e os Dons da Maga existem (a linha já estava desatualizada, `data/heroes/maga_mastery.tres` existe).
- **Ação no HUD** (`hud.gd` `ACTIONS`): a Maga usa os mesmos 4 grupos do Guerreiro; os rótulos dos slots vêm de `hero_action_*_maga` (seção 11). O losango do Q e do E não existe mais para ninguém (GP-1).

## 11. Textos novos e trocados em `data/text_pt.tres` (português do Brasil, sem travessão)

Chaves **novas ou trocadas** (a redação é proposta; o Daniel decide no exe):

| Chave | Texto |
|---|---|
| `hero_action_attack_maga` | Centelha |
| `hero_action_special_maga` | Estilhaço |
| `hero_action_cast_maga` | Arco |
| `hero_action_rush_maga` | (apagar o uso; sem Suspensão) |
| `hero_action_hold_attack_maga` | Arco Voltaico |
| `hero_action_hold_special_maga` | Geada |
| `hero_skill_attack_maga` (troca) | Projétil de fogo, de graça. Três acertos no mesmo inimigo em 4 segundos o incendeiam. Segure para o Arco Voltaico. |
| `hero_skill_special_maga` (troca) | Estilhaço de gelo que atravessa a fila e deixa Frio, 5 de Magia. Segure para a Geada. |
| `hero_skill_cast_maga` (troca, vira "Arco") | Raio que salta entre até 3 inimigos e os deixa Eletrizados. Gasta 10 de Magia. |
| `hero_skill_name_cast_maga` | Arco Voltaico |
| `hero_skill_name_hold_special_maga` | Geada |
| `hero_skill_rush_maga` | (apagar o uso) |
| `hero_passive_maga` | Reações |
| `hero_passive_desc_maga` (troca) | Dois elementos no mesmo inimigo fazem uma reação: Fogo e Gelo, Choque Térmico; Fogo e Eletricidade, Sobrecarga; Gelo e Eletricidade, Cristalização. A Magia volta sozinha, 2 por segundo. |
| `howto_light_attack_desc_maga` | Toque: a Centelha lança fogo, não gasta Magia, e três acertos no mesmo inimigo o incendeiam. Segure: o Arco Voltaico salta entre até 3 inimigos, 12 de dano em cada, e gasta 10 de Magia. |
| `howto_heavy_attack_desc_maga` | Toque: o Estilhaço atravessa a fila de inimigos, 6 de dano, deixa Frio e gasta 5 de Magia. Segure: a Geada cobre uma área do chão por 4 segundos e gasta 20 de Magia. |
| `howto_regen_maga` | A Magia volta sozinha, 2 por segundo, até andando ou esquivando. As reações enchem o Golpe Supremo. |
| `hero_style_desc_maga` | (mantém) |
| `ult_converge_desc` (troca) | Uma área no alvo por 4,5 segundos: primeiro gelo, depois fogo, depois eletricidade. As reações acontecem em cada fase. |
| `lesson_attack_maga` | Aperte {attack}: a Centelha lança fogo e não gasta Magia |
| `lesson_power_maga` | Aperte {power}: o Estilhaço de gelo atravessa os inimigos, 5 de Magia |
| `lesson_special_maga` | Segure {special}: a Geada cobre uma área do chão, 20 de Magia |
| `tip_hold_maga` | Segure {attack} para o Arco Voltaico ou {special} para a Geada. Os dois gastam Magia. |
| `tip_maga_v1` | A Maga mudou: o Arco Voltaico agora é segurar o esquerdo, a Geada é segurar o direito, e a Magia volta sozinha. |
| `tip_regen` | A Magia volta sozinha, 2 por segundo. |
| `gloss_react_thermal` | Choque Térmico: Fogo e Gelo no mesmo inimigo, 35 de dano. |
| `gloss_react_overload` | Sobrecarga: Fogo e Eletricidade, 25 de dano em 1,8 m. |
| `gloss_react_crystal` | Cristalização: Gelo e Eletricidade, congela os comuns por 0,8 s e abala a postura dos fortes. |
| `talent_afinidade` | Afinidade |
| `talent_afinidade_desc` | Queimadura, Frio e Eletrizado duram 50% mais. |
| `talent_catalisador` | Catalisador |
| `talent_catalisador_desc` | Reações: causam 30% a mais de dano. |
| `talent_propagacao` | Propagação |
| `talent_propagacao_desc` | O elemento do seu golpe passa ao inimigo mais perto, a até 3 m, uma vez por magia. |
| `talent_trindade` | Trindade |
| `talent_trindade_desc` | Uma reação deixa um resíduo por 3 s. Se o terceiro elemento chegar, as duas outras reações acontecem juntas. |
| `talent_permanencia` | Permanência |
| `talent_permanencia_desc` | Geada e brasas: duram 30% mais. |
| `talent_expansao` | Expansão |
| `talent_expansao_desc` | Geada e brasas: o raio cresce 25%. |
| `talent_manifestacao` | Manifestação |
| `talent_manifestacao_desc` | Choque Térmico e Sobrecarga deixam brasa no chão por 3 s, que incendeia quem pisa. |
| `talent_confluencia` | Confluência |
| `talent_confluencia_desc` | Quem está ao mesmo tempo na Geada e numa brasa sofre um Choque Térmico a cada 2 s. |
| `talent_fluxo_arcano` | Fluxo Arcano |
| `talent_fluxo_arcano_desc` | A Magia volta 1 por segundo mais rápido. |
| `talent_agilidade_arcana` | Agilidade Arcana |
| `talent_agilidade_arcana_desc` | Arco Voltaico e Geada: carregam 30% mais rápido. |
| `talent_reciprocidade` | Reciprocidade |
| `talent_reciprocidade_desc` | Uma magia que provoca reação devolve 2 de Magia, uma vez por magia. |
| `talent_transcendencia` | Transcendência |
| `talent_transcendencia_desc` | Três reações tornam a próxima magia segurada (Arco ou Geada) gratuita e quase instantânea. |
| `word_react_*` | (mantêm) |

Chaves a **aposentar** (ficam no arquivo, sem uso): `move_combust`, `talent_faisca_persistente*`, `talent_orvalho_gelido*`, `talent_reacao_amplificada*`, `talent_fissao_termica*`, `talent_geada_demorada*`,
`talent_chao_ardente*`, `talent_suspensao_ampla*`, `talent_campo_elementar*`, `talent_eco_eletrico*`, `talent_fluxo_de_magia*`, `talent_estilhaco_gemeo*`, `talent_tempestade_contida*`, `move_dome`, `hero_skill_rush_maga`.
