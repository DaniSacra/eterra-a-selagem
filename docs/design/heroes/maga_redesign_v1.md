# Maga Redesign V1: o que foi implementado

- **Data**: 2026-11-28. **Pacote do Daniel**: `maga_redesign_v1_pack/` (00 a 04 e `arte/01_geometria_vfx.svg`). **Testes**: `tests/test_maga_redesign.gd` (35), mais os ajustados em `test_maga_kit.gd`, `test_maga_v1.gd`, `test_lote_c.gd` e `test_lote_d.gd`.
- Substitui o kit da V1 e da V2 da Maga (`maga_v1_2026-11-26.md`, `maga_v2_2026-11-27.md`). O Guerreiro não mudou (o `RESULT` do `--smoke 180 --seed=5` é o mesmo, byte a byte, fora os tempos).
- **Decisões do Daniel e da sessão principal** (não perguntar de novo): HUD com a coluna de Bênçãos à ESQUERDA como hoje (a opção A), ignorando os "losangos" do pacote; a linha de ações usa os quatro quadrados de golpe que o Guerreiro já tem (toque e segurar de cada botão), Supremo e esquiva; a Maga perde Arco Voltaico, Estilhaço, Geada e Convergência do kit ativo, com um Supremo por arma; os 12 Dons novos NÃO foram feitos; números "experimentais" do pacote como ponto de partida; Mana de volta por reação configurável e desligada.

## 1. Botões e custos

| Comando | Habilidade (id) | O que faz | Mana |
|---|---|---|---|
| M1 toque | Centelha (`spark`) | 3 projéteis de 8 ao mesmo tempo, leque de 24 graus, alcance 11 m, uma só conjuração; cada acerto incendeia | 0 |
| M2 toque | Sopro Glacial (`breath`) | cone de 90 graus, 5 m, 12 de dano, Frio e 30% de lentidão por 2 s | 0 |
| M1 segurar | Combustão (`combust`) | bola de fogo que cresce com a carga e explode onde acerta: 50 a 150 de dano, raio 1,5 a 3,5 m, carga 0,6 a 1,5 s | 15 a 25, ao soltar |
| M2 segurar | Inverno Eterno (`winter`) | chão congelado na mira (até 8 m): raio 2 a 6 m, carga 0,6 a 1,8 s, 5 s, 6 de dano por segundo, Frio a cada 1 s | 10 a 30, ao soltar |
| Shift | Tempestade Celestial (`storm`, `UltDef.Kind.CHAIN`) | raio de 90 que salta entre até 6 corpos distintos (5 m entre eles), 10% a menos por salto, Eletrização; a primeira vítima é a mais perto da mira (até 9 m). Alvo isolado: 3 golpes (90, 81, 72) | carga própria (regra atual: 50, Magia gasta, dano, vida perdida e reações) |
| Espaço | Passo Etéreo | 4,5 m, duas cargas de 1 s | 0 |

Vida 30, Mana 50, regeneração 3 por segundo, também andando (`HeroDef.magick_regen`, somada em `Player.step`). Nenhum ataque devolve Mana. A Mana de volta por reação é `ArcaneKit.reaction_magick`, **0 por padrão** (liga-se com um número).

## 2. Segurar e soltar (`ComboNode`, `Player._step_release_charge`)

- Campos novos no `ComboNode`: `charge_max` (segundos até a carga cheia; `charge_time` vira a carga mínima), `magick_cost_max`, `power_max`, `area`, `area_max`, `effect_fan`, `effect_fan_deg`; `is_release`, `charge_share`, `power_at`, `area_at`, `cost_at`, `afford_share` (lógica pura, testada).
- Toque e segurar são exclusivos (o `ButtonIntent` do Guerreiro, sem mudança). Segurar além do limiar começa a carga (ela anda a 50% e gira 90 graus por segundo, como antes). **Soltar** antes da carga mínima: nada, nada pago. Soltar depois: o `Player` guarda `strike_share` (a fração da carga, já limitada pelo que a Mana paga) e começa o preparo do feitiço; a Mana é cobrada quando ele **cai** (`_on_move_hit`), então a esquiva no preparo ou durante a carga não custa nada. A carga cheia espera cheia, não cresce mais.
- Sem Mana para a carga mínima: o segurar é recusado (a barra de Mana pisca) e nada executa nem vira clique em silêncio. Com pouca Mana a área para de crescer no que ela paga (`charge_share_now`).
- Pré-visualização: um disco no chão (`Arcane._step_preview`), âmbar para a Combustão e azul gelo para o Inverno, do tamanho que o feitiço teria se fosse solto agora; some quando não há carga. O quadrado do HUD mostra o custo atual (`Player.charge_cost_now`) e o anel de carga cheia.
- Transcendência (Dom já existente): a próxima magia segurada fica de graça e com carga mínima do limiar; a fração ainda cresce com o segurar.

## 3. Reações (`Arcane`, `ElementBook`, sem mudança de regra)

Fogo e Frio: Choque Térmico (45, parada de 50 ms). Fogo e Eletrização: Sobrecarga (30 em 1,8 m). Frio e Eletrização: Cristalização (congela 0,8 s um comum; no chefe e no blindado vira Quebra de 25). Ordem indiferente, os dois estados são consumidos, sem reação tripla no kit básico (a eletricidade precisa de um estado novo), chefe nunca congela nem é atrasado pelo Frio. Limites: `react_gap` 0,5 s por alvo, uma conjuração é uma conjuração (os três tiros da Centelha compartilham `Shot.group`: uma Reciprocidade, no máximo 10 de carga do Supremo), áreas contam uma vez por conjuração. O Frio do chão é reaplicado a cada 1 s (o terceiro congela um comum). Toques preparam, segurados resolvem: Fogo e depois Sopro, Sopro e depois bola, chão e depois bola, bola e depois Tempestade (Sobrecarga), chão e depois Tempestade (Cristalização).

- A lentidão do Frio agora é a pedida pelo pacote: 30% (`Enemy.slow_keep` 0,7) por 2 s, em vez dos 55% genéricos de `slow_t`; o resto do jogo continua com 0,45 (`Enemy.SLOW_KEEP`, `Enemy.slow_for`).

## 4. Dados, saves e migração

- Fonte: `tools/make_data.gd` (`_maga_tree`, `_maga`, `ArcaneKit`); `data/combos/maga.tres`, `data/heroes/maga.tres` e `data/ultimates/maga/00_storm.tres` regerados (o `00_converge.tres` saiu).
- Ids antigos legíveis: os movimentos descobertos (`arc`, `shard`, `frost`, `spark2`, `spark3`) são strings do save e continuam lidos; os textos `move_arc`, `move_shard`, `move_frost`, `ult_converge` ficam na tabela; o campo `ultimate: "converge"` do save do herói não é lido há tempos. Nenhuma migração de dados foi necessária (`SaveData.VERSION` continua 19); o teste `test_an_old_save_...` trava que um save antigo carrega e que o `merged` é idempotente. O código de `Arcane._arc`, `Arcane._combust` fixa, a Suspensão e a Convergência fica (como reserva, com testes que montam o nó à mão).
- Dica de primeira vez: `maga_rd` (`tip_maga_rd`), uma vez por save, mesmo antigo; `maga_v1` continua na lista de ids por causa dos saves.

## 5. Dons existentes que mudaram de sentido (NÃO foram refeitos; os 12 novos esperam o "pode fazer")

Os ids e a Memória gasta ficam. O que quebrou ou mudou:

| Dom | Antes | Agora |
|---|---|---|
| Agilidade Arcana | Arco e Geada carregam 30% mais rápido | Combustão e Inverno Eterno: 30% sobre a carga mínima (0,6 vira 0,42) |
| Transcendência | 3 reações: próxima magia segurada de graça | igual (Combustão ou Inverno Eterno) |
| Permanência, Expansão | Geada e brasas | Inverno Eterno e brasas (a Expansão soma ao raio da carga) |
| Confluência | Geada + brasa = Choque Térmico a cada 2 s | Inverno Eterno + brasa |
| Reciprocidade | +3 Mana a mais além da Ressonância | +3 Mana por conjuração com reação, já que a Ressonância base está desligada |
| Fluxo Arcano | regeneração +1 | igual |
| Dons antigos (`GP5_REMOVED_DONS`, `estilhaco_gemeo`, `eco_eletrico`, `tempestade_contida`) | já removidos pela V1 | sem mudança |

Referências quebradas que ficaram só como código morto: `Arcane.thrown` (cargas do Estilhaço Gêmeo), `shard_charges`, `arc_targets`; os textos de `talent_*` dos Dons removidos. As Bênçãos que leem `shout cast bolt arcane ice` ainda enxergam o Sopro (`shout`, `cast`, `arcane`, `ice`); as de "finalizador" não enxergam mais a Centelha (a cadeia de três acabou).

## 6. HUD

- A linha de ações da Maga é a do Guerreiro: M1, M2, segurar M1, segurar M2, Supremo (Shift), divisor, esquiva (Espaço). Os ícones de mouse (esquerdo branco, direito branco, esquerdo amarelo, direito amarelo) e a barra de espaço já vêm do `ActionSlot`. Cada quadrado tem a marca da Maga (`MAGA_BLOW_GLYPHS`: leque de balas, explosão, cone, chão congelado) quando não há Bênção no botão; o Supremo usa o glifo novo da Tempestade (`ULT_GLYPH + Kind.CHAIN`, 113).
- O custo dos segurados aparece no quadrado (15 e 10 parados; sobe ao carregar). A coluna de Bênçãos à esquerda e a barra de Mana não mudaram. O Guerreiro: sem mudança.
- **Não feito** (fora do que a linha atual suporta): o "pino" de três pontos da Centelha saiu (não há mais cadeia); a ordem "Supremo amarelo acima, Mana no meio, vida abaixo" e os losangos de Bênção do pacote não foram aplicados (decisão da sessão principal).

## 7. Arte e efeitos (com as ferramentas de `Fx` que já existem)

Centelha: três chispas âmbar em leque (`Combat.throw_wave`, nenhum efeito novo). Sopro: fita pálida do cone (`Fx.slash`), cristais nas bordas (`Fx.chips`), névoa (`burst frost`). Combustão: a bola cresce com a carga (largura até 1,7 vezes), o aro e a chama do estouro seguem o raio da carga, tremor leve só para raio de 2,5 m ou mais, parada de 60 ms. Inverno: disco de prévia que cresce, depois o disco de gelo de sempre e a lentidão, sem tapar avisos (alfa baixo). Tempestade: `Fx.arc_leap` por salto, 0,1 s entre saltos, faísca e anel dourado em cada corpo. Reações: as de sempre (vapor âmbar, pulso dourado, cristais). Sem som novo (reaproveita `circle`, `wave_omega`, `ult_implode`, `charged`). Pendente para o `technical-artist` e o `art-director`: textura pintada própria do cone, do chão de gelo rachado e do arco da Tempestade; som de carga ascendente específico da Combustão (hoje `charge_up`).

## 8. Medido (2026-11-28, dummies parados e robô; nada disto é balanceamento final)

- **Dano grátis (10 s de toques seguidos, alvo de 100000 de vida parado)**: Centelha em esqueleto: 48 de dano por segundo a 2,5 m, 33 a 4 m, 26 a 6 m, 15 a 9 m (o leque de 24 graus abre e só o tiro do meio acerta de longe); em Guarda e Ancião (corpo maior): 91, 76 a 84, 35 a 44 e 35. Sopro Glacial: 14 por segundo a 2,5 m no esqueleto, 35 no Guarda e no Ancião a até 4 m, nada além de 5 m. Ou seja, o grátis só rende a menos de 4 m (a posição é a decisão), e o Sopro prepara o Frio mais que causa dano.
- **Segurado**: a Combustão cheia (1,5 s, 25 de Mana) dá 150 no primeiro e 150 em área de 3,5 m, cerca de 94 de dano por segundo de ação mais a área, contra os 33 a 84 do grátis; o Inverno cheio (1,8 s, 30 de Mana) deixa 6 por segundo por 5 s em 6 m de raio e congela um comum no terceiro segundo. Com a regeneração de 3 por segundo os 50 de Mana pagam uma Combustão cheia e um Inverno cheio (55) quase de uma vez e voltam em cerca de 17 s; uma Combustão cheia a cada 8,3 s se sustenta sozinha.
- **Robô** (`tools/smoke.sh 600 --hero=maga --seed=N`, depois de ajustar o robô a ficar a 3,5 a 5 m, soltar a Combustão cheia com 25 de Mana ou mais e dar o Sopro a menos de 5 m): semente 7 chegou em Morvath aos 495 s (14 salas, 4861 de vida do chefe restantes aos 594 s); sementes 5 e 6 não chegaram em 600 s (12 e 11 salas). Na rodada anterior do robô (afastado, 5,5 a 9 m) as sementes 5 e 6 chegaram aos 559 e 584 s. Com 900 s a semente 6 chegou em Morvath aos 669 s e venceu aos 890 s. Referência da V2: 5 de 6 sementes venciam em 443 a 511 s. Leitura: o kit novo é cerca de 25% mais lento para o robô, que não sabe pisar fora do leque nem escolher alvo; os dois pontos lentos foram o Ancião (`elder_hall`, 100 a 280 s) e o santuário de elites (até 375 s), onde o dano grátis de longe quase não acerta. O jogador humano que se aproxima rende bem mais.
- **Chefe** (`--start=boss --boons=25 --seed=5 --hero=maga`, 180 s): o robô deixou o Morvath com 14 de vida e terminou com 17 de vida; nenhum erro.
- **Desempenho**: o `RESULT` mostra `step_ms` médio 0,3 a 0,5 e pico de 11 a 12 ms (igual ao Guerreiro); o leque são três tiros e a prévia do chão é um disco só (reutilizado), então nada de partículas novas; não houve teste de salas cheias a 1280x720 com GPU.

## 9. Perguntas abertas e riscos

1. Combustão só explode ao acertar um corpo: errar o alcance (11 m) não faz nada. Decidir se explode no fim do alcance ou na parede.
2. Reação devolvendo Mana está desligada (`ArcaneKit.reaction_magick`); o spam grátis rende bem a menos de 4 m e o pacote pede medir "grátis contra Mana" com gente de verdade antes de mexer na regeneração.
3. Alvo isolado e Supremo: 3 golpes a 90, 81 e 72 (ou metade no chefe). Valor experimental.
4. Arte pintada própria (cone, chão rachado, arco da Tempestade), som de carga da Combustão e o shake opcional de acessibilidade pedem o `technical-artist`/`art-director`; usei as peças existentes de `Fx`.
5. Os 12 Dons novos (Elementalismo, Conjuração, Feitiçaria) continuam à espera do "pode fazer"; os atuais seguem funcionando (tabela da seção 5).
6. A tela do herói usa os rótulos antigos de slot (`cast`, `rush`) para mostrar Combustão e Inverno Eterno; funciona, mas a ordem Q/E dessa tela merece ser refeita pelo `ui-ux-designer`.
7. `omega_charges_started` e `omega_charges_cancelled` do `RESULT` já saíam estranhos (o limiar de segurar passa do som de carga) e continuam assim.
