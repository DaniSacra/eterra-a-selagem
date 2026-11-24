# Plano de implementação do redesign (Guerreiro e Maga)

Lido contra o HEAD 669153c. Pacote 00 a 03 mais as decisões do topo de `docs/backlog.md` (reembolso de Memória e Vagas, "Golpe Carregado",
recurso "Magia", Corte do Juízo único, Convergência reaplica fogo e frio nos ticks finais). Números são baselines de protótipo, o
`balance-designer` valida depois. Fonte da verdade dos dados: `tools/make_data.gd`; nada de editar `.tres` à mão.

## 0. Reconciliação do pacote com o código (o que o pacote não sabia)

| Pacote | Realidade no HEAD | Consequência |
|---|---|---|
| "Vida/Mana 40/50 e 30/50" | `warrior.tres` 40 (commit 79fe4ec), Maga 30, `magick_max` 50 nos dois, Maga 2 cargas de Passo, recarga 1 s | Confere. Não mexer. |
| "Mana" | O jogo diz **Magia** (`HeroDef.magick_max`, `Magick`, textos) | Manter Magia em tudo; só o doc usa Mana. |
| Guerreiro "Fúria" | Existe como Dom Ímpeto + Fúria Plena + Sangue Quente + Brado (`GiftState.fury*`, `rally(...charges)`, `Player.show_fury`, shader `fury_ember`, `gloss_fury`) | Sai tudo (seção B.5). |
| Guerreiro "ramo Guerra" | Não existe ramo "Guerra". Existem os ramos COMBO, FURIA, EMETH, MAGIA, 6 pontes e 3 de sustento; os Dons `voz_larga`, `escudo_de_guerra`, `folego_de_guerra` (C2) são o que o pacote chama de Guerra | Os 23 Dons do Guerreiro saem. Os números de Voz Larga viram base da Voz do Leão. |
| "Emeth é nome da espada, não de ramo" | O ramo EMETH existe (ondas verdes) | Ramo sai; a espada continua `Emeth`. |
| "Ômega" | Termo técnico em `ComboNode.In.CHARGE`, tag `&"omega"`, `Player.omega_cost`, `omega_discount`, `DealtBy` fontes `omega_attack/omega_special`, 230 ocorrências em scripts, 23 linhas de texto, 5 Bênçãos `omega_*` | Só texto muda (decisão 2). Nomes técnicos ficam. |
| "Selos e Ressonância da Maga" | `SealBook`, `Resonance`, `ArcaneKit` (grupos Selo, Explosão, Ressonância, Círculo), `Arcane` (711 linhas), `UltDef.Kind.STORM/DOME`, HUD (`hud.gd:836` losangos), `bot.gd:488`, `run_report.gd:35`, 25 linhas de texto | Sai (seção C.6). Os "selos" de `angel_seal`, `seal_emblem`, `hud_bar` (ritual) e `seal_look` são outra coisa: **não tocar**. |
| "Marca de Qeshael" | É a família de Bênçãos `Marca` (`Enemy.mark_t`, stat `mark_time`, `Combat._mark`, `DamageCalc.marked`) | Não tocar. Estados elementais ficam em estrutura própria. |
| "Dons: 3 ramos x 4" | `TalentDef` modela diamante de 4 ramos + pontes + sustento; `needs_met` por tier/partner/joins; Maga é triângulo PIRO/ARCA/CTRL; 23 Dons por herói | Esquema novo com `needs` explícito (A.2). |
| "Supremo por arma; remover seleção da árvore" | `HeroDef.ultimates` (2 por herói), `UltDef.mastery_level`, `block.ultimate`, nós `Kind.ULT` no medalhão, `HeroLoadout.choose_ult`, `HeroDef.ult_for` | A.3. |
| "Sustento para a Videira" | Videira = 3 ramos x 3 nós (Vida +5 PV x3, Provisão, Perseverança), só 3x3 no `VineLayout` | A.5. |
| "Disciplina preserva sequência após esquiva por 2 s" | `ComboTree.dodge_window` 0,3 s e `ComboRunner._dodge_left` já existem | Só um stat novo somado à janela. |

## PARTE A. Infraestrutura comum

### A.1 Forma dos dados (3 ramos x 4 Dons por herói, um Supremo por arma)

- `TalentDef` (`scripts/core/talent_def.gd`):
  - `enum Branch { COMBO, IMPETO, DOMINIO, ELEMENTALISMO, CONJURACAO, FEITICARIA }` (o número não é salvo; só ids de Dons vão para o save). Somem `FURIA, EMETH, MAGIA, BRIDGE, SUSTAIN, PIRO, ARCA, CTRL`, `NEIGHBOURS`, `partner`, `joins`.
  - `enum Tier { ENTRY, MIDDLE, APEX }` (somem BRIDGE e SUSTAIN). Cada ramo: 1 ENTRY, 2 MIDDLE, 1 APEX.
  - Campo novo `needs: StringName` (id do Dom que precisa estar equipado; vazio no ENTRY). `Talents.needs_met` vira "se `needs` != vazio, o Dom `needs` está equipado". Pacote 01: Apogeu `needs = maestria_marcial`. Padrão para os outros: MIDDLE `needs = entrada do ramo`; APEX `needs = o MIDDLE que o pacote ou a proposta indica`. Sem pontes (03).
  - `slot: Boon.Slot` continua (um Dom por botão), mas o plano evita usá-lo: Dons desta rodada reforçam, não competem.
- `HeroLoadout`: `BRANCH_KEY` e `TIER_KEY` reduzidos aos novos; sai `place_text` de ponte/sustento; `needs`/`short_why` simplificados (um texto "Pede: X" a partir de `t.needs`); sai `choose_ult`, `ult_open`, `ultimate()` vira "o Supremo fixo da arma" (A.3). `hero_why_apex`, `hero_why_bridge`, `codex_block_apex`, `codex_block_bridge`, `hero_tier_bridge/sustain`, `hero_branch_bridge/sustain` somem do texto.
- Medalhão: `tools/make_data.gd` `MEDALLION_WARRIOR`/`MEDALLION_MAGA` passam a 1 coroa + 12 nós (3 setores de 4, sem nós ULT). `_medallion` perde o parâmetro de ids ULT. `MedallionNodeDef.Kind.ULT` é removido (ou mantido sem uso: preferir remover junto com os ramos de código em `dons_screen.gd:241,372,461` e `medallion_view.gd:140,316,330,360`). A arte pintada do medalhão (`test_painted_medallions`, `cut_medallions.gd`) foi cortada para 24 nós: pedir ao `art-director` o novo fundo; até lá o `MedallionView` usa o desenho procedural (risco R3).
- Supremo por arma (A.3). Dom independente da arma: nenhum Dom novo usa tag de golpe exclusivo da Emeth (`spin`, `wave`, `thrust`); só tags genéricas (`light`, `heavy`, `omega`, `finisher`, `dash`, `shout`) que qualquer arma carrega.

### A.2 `TalentDef.needs` e Dons por herói

Os 12 Dons de cada herói ficam em `data/talents/<hero>/NN_<id>.tres` (`_talent` e `_maga_talents` reescritos; a flag `NEW_GIFTS_IN_TREE` sai). Memória e nível: regra existente `memory_cost = 0 se unlock<=1, 1 se <=5, senão custo` (`make_data.gd:1980`); sugestão de níveis em B.1 e C.4. Cada ramo tem o ENTRY aberto cedo para que a primeira descida não fique mais pobre.

### A.3 Um Supremo por arma

- `UltDef` ganha `weapon: StringName` (`&"emeth"`, `&"bastao"`) e `reserve := false`.
- `HeroDef` ganha `weapon: StringName` e `ult_for_weapon()`: devolve o primeiro `UltDef` com `weapon == hero.weapon` e `reserve == false`, ou null abaixo do nível `mastery_level`. `HeroDef.ult_for(chosen, level)` é removido; os consumidores trocam (`Game` linha 353 `ults.equip(hero.ultimate(StringName(ultimate)))`, `HeroLoadout.ultimate`, `hero_screen.gd:562`, `Save` `block.ultimate`/`--hero-ult` em `save.gd:103`, `Dev.put("ultimate")` em `test_maga_m2`).
- Guerreiro: `cleave` (Corte do Juízo, Maestria 3, carga 75) `weapon=emeth`; `vortex` (Voragem) fica no `.tres` com `weapon=&"" reserve=true` e **não entra** em `hero.ultimates` selecionável; manter `ult_vortex*` no texto, `Ultimates` e os testes de forma (`test_ultimate.gd` continua testando `UltDef` direto).
- Maga: `converge` (Convergência Elemental, `UltDef.Kind.CONVERGE`, Maestria 2) é o único. `storm` e `dome_abs` são apagados (código `Kind.STORM/DOME`, `Arcane.open_absolute`, `_step_ultra`, `ultra`, `ultra_def`, `dome_shot_pct/dome_blast_cost`, `storm_share`).
- `block.ultimate` continua no esquema do save por compatibilidade; deixa de ser lido (a migração o zera). `UltCharge`/`Ultimates` não mudam (carga por Magia gasta, dano e vida perdida): a "carga por Mana gasta" da Convergência é o que já existe.
- Desbloqueio: pelo `mastery_level` do `UltDef` (Guerreiro 3, Maga 2, como hoje); `HeroLoadout.unlocks_at` continua listando-o.

### A.4 Migração de save (versão 13)

`SaveData.VERSION = 13`; em `merged`, `if version < 13: migrate_redesign(out)` (função estática pura, testável, como `refund_preparo`).

1. Tabela congelada `LEGACY_DONS := {"warrior": {id: memoria}, "maga": {id: memoria}}` copiada do que o gerador hoje produz (valores abaixo). Não ler do catálogo novo.
2. Para cada herói no save: `refund = soma de LEGACY_DONS[hero][id] para id em block.opened` (só o que está em `opened`; Dom aberto gratuito, memória 0, não devolve). `MaterialPurse.refund(out, MEMORY, refund)` (não conta em `materials_total`, como `refund_preparo`). Depois: `block.opened`, `block.unlocked` perdem os ids legados; `block.equipped = []` (libera as Vagas: Vagas = 5 + nível, derivadas, só `equipped` as ocupa); `block.ultimate = ""`.
3. Idempotência: guarda por versão (`< 13`) e, dentro, por remoção do id (uma segunda execução manual não acha ids em `opened` e devolve 0). Teste chama duas vezes. Um id legado reusado por Dom novo é impossível por regra (A.4.5).
4. Reembolso por herói (Memória, da regra atual): Guerreiro = passo_encadeado 1, golpe_sem_fim 4, impeto 1, avanco_feroz 3, furia_plena 4, corte_crescente 1, fio_longo 1, onda_atravessante 4, lamina_faminta 1, reserva 3, coracao_da_emeth 4, investida 3, sangue_quente 3, onda_carregada 3, fio_do_passo 3, firmeza 2, respiro 3, ainda_de_pe 5, voz_larga 2, escudo_de_guerra 3, folego_de_guerra 3, ferro_na_investida 3, quarto_corte 0 (**máximo 60**). Maga = pavio_longo 1, combustao 3, inferno_runico 4, eco_arcano 1, cadeia_curta 1, selo_duplo 3, ruptura 4, circulo_expandido 1, prisao_sigilada 3, suspensao_larga 3, contencao_perfeita 4, chama_que_marca 3, brasa_gemea 3, selo_no_chao 3, leitura_rapida 3, brasa_que_prende 3, passo_de_brasa 3, firmeza 2, reserva 3, respiro 3, passo_longo 2, ainda_de_pe 5, brasa_viva 0 (**máximo 61**). Conferir de novo com um teste que lê `git show HEAD:data/talents/...` não é viável; o teste usa a tabela e a soma esperada 60 e 61.
5. Ids novos nunca reusam um id legado (Guerreiro novo: `disciplina, cadencia, maestria_marcial, apogeu, forca_concentrada, determinacao, concentracao, forca_titanica, ruptura, voz_do_leao, imposicao, investida_implacavel`; `ruptura` e `investida` existiam, mas `ruptura` do Guerreiro é novo id **do Guerreiro** e o legado do Guerreiro não o tem; o legado da Maga tem `ruptura`: tabelas são por herói, sem choque. Proposta da Maga abaixo evita `ruptura`, `combustao`, `reserva`, `respiro`, `firmeza`).
6. Não apagar: `mastery_xp`, `firsts`, `forge`, `tools`, `discern`, materiais, `vine`, codex (`codex.talents` guarda ids antigos; inofensivo, o Compêndio só lista o catálogo atual: conferir `codex_screen.gd`).
7. Saves de Videira: nenhum nó comprado muda de id; os nós novos (A.5) são acrescentados, nada é concedido de graça.
8. Compensação do "Dom perdido por Memória": o jogador que tinha 60 ou 61 em Dons recebe o mesmo valor; os 12 Dons novos custam no total menos que isso (B.1: soma 27; C.4: 27), então ninguém fica mais pobre.

### A.5 Sustento para a Videira (sem duplicar)

Sustento antigo, hoje em Guerreiro e Maga: Firmeza (+10 PV +10 Magia), Respiro (cura 2 por sala vencida, `room_heal`), Ainda de Pé (`rise_share` 0,5, uma vez por descida, não no Morvath), mais Reserva (+20 Magia, Maga e Guerreiro) e Passo Longo (`blink_pct`, Maga).
- **Firmeza (PV)**: já existe como `vida_1..3` (+5 PV cada, +15). **Não criar nó**. O +10 Magia não migra (03: "não transferir automaticamente Mana ou mobilidade"). Reserva e Passo Longo também não migram; o reembolso as compensa.
- **Respiro** e **Ainda de Pé**: dois nós novos. Como a Videira tem 3 ramos de 3 e o `VineLayout` tem 3 posições por ramo (`BUD`/`TAG`), acrescentar um **4º ramo `recuperacao`** ("Regeneração", pacote 03: vida, regeneração, provisão, perseverança) com 2 nós: `respiro` (stat `room_heal` 2, Prata 8) e `ainda_de_pe` (stat `rise_share` 0.5, Memória 12; `requires = respiro`). Custos são provisórios (equivalem a ~10 e ~12 Memória de hoje).
- Código: `Vine.BRANCHES` ganha `&"recuperacao"`; `VineLayout.BUD/TAG/NAME_AT` ganham a linha do 4º ramo (o comentário do arquivo já diz que é dado); `_vine` ganha o ramo. `Game._equip_vine` já faz `boons.grant(...)` antes de `HeroGifts.new`, e `GiftState._init` lê `rise_share` e `room_heal`, então **não pede código de jogo**. `rise_boss_share` (Morvath) continua 0. A tela `vine_screen.gd` e a arte do tronco (`docs/art/vine_spec.md`) precisam de um 4º ramo: tarefa de `ui-ux-designer` com recorte do `art-director` (risco R3). Alternativa se a arte não vier: pôr os dois nós como passos 4 e 5 do ramo Vida (o layout comenta que "um ramo com quatro nós pede uma linha a mais em BUD"); preferir o 4º ramo.
- `Vine.first(n)` (robô `--vine=N`) deve ficar determinístico: testar a ordem.

### A.6 Terminologia e chaves de texto (`data/text_pt.tres`, dono: ui-ux-designer; sem travessão)

- **Ômega vira Golpe Carregado** (somente texto): `gloss_omega` ("Golpe Carregado"), `gloss_magick_text`, `gloss_armor_text`, `tip_hold`, `moves_legend`, `opt_impact_frames_tip`, `howto_*`, `hero_ult_charge` ("Carga {n}: Magia dos golpes carregados e dano"), `hud_ult_charge_tip`, `forge_temper_2_desc`, as 5 Bênçãos (`boon_omega_geada` "Golpe Carregado de Gelo", `_brasa`, `_veu`, `_mare`, `_marca` e `_desc`), `talent_lamina_faminta_desc`/`sangue_quente` saem com os Dons. `glossary.gd` TERMS `&"omega"` mantém o id, muda a palavra.
- Sai Fúria: `talent_furia_plena`, `hero_branch_furia`, `gloss_fury*` (3 chaves), `TERMS &"fury"` em `glossary.gd`, `hud_bar`/HUD não tem cargas (conferir `hud.gd` e `hud_bar.gd` buscando `fury`: só `Player.show_fury` desenha brasas na lâmina).
- Sai Selo/Ressonância da Maga: `ult_storm*`, `ult_dome_abs*`, `talent_*` da Maga antiga (23 pares), `hero_branch_piro/arca/ctrl`, `gloss_*` de Selo, textos de ação `*_maga`, dicas `tip_*` que falam de Selo e Explosão. Antes de apagar: `grep -n "Selo\|Ressonância\|Explosão" data/text_pt.tres` e separar o que é **Selo de anjo** (fica).
- Chaves novas: ramos (`hero_branch_impeto` "Ímpeto", `_dominio` "Domínio", `_elementalismo`, `_conjuracao`, `_feiticaria`; `hero_branch_combo` fica); 12+12 `talent_<id>` e `talent_<id>_desc`; `ult_converge`/`_desc`; estados (`elem_burn` "Queimadura", `elem_cold` "Frio", `elem_volt` "Eletrizado"); reações (`react_thermal` "Choque Térmico", `react_overload` "Sobrecarga", `react_crystal` "Cristalização"); habilidades da Maga nos botões (`move_centelha`, `move_combustao`, `move_estilhaco`, `move_geada`, `move_arco_voltaico`, `move_suspensao`, `move_passo`) e as descrições do Livro/Como jogar; `vine_respiro`, `vine_ainda_de_pe` (+ `_desc`), `vine_branch_recuperacao`; glossário `gloss_burn_elem`, `gloss_cold`, `gloss_volt`. A sessão principal cola as chaves enviadas pelo engenheiro (regra dos lotes), exceto o lote de UI que é dono do arquivo.

### A.7 Outros consumidores dos ids de Dons antigos (atualizar)

`make_data.gd` `_psalms` referencia Dons (`G + "furia_plena"`, `"golpe_sem_fim"`, `"quarto_corte"`, `"fio_longo"`, `"passo_encadeado"`, `"fio_do_passo"`, `"investida"`, `"corte_crescente"`, `"onda_carregada"`, `"onda_atravessante"`, `"reserva"`, `"lamina_faminta"`, `"coracao_da_emeth"`): trocar pelos Dons novos do Guerreiro e deixar o robô alcançar (as listas são largas de propósito). Outros: `scripts/ui/forge_bench.gd`, `scripts/ui/talent_glyph.gd`, `talent_motif.gd`, `gift_art.gd`, `talent_node.gd` (glifos por Dom e por ramo, `Glyph.FURIA/PIRO/...`: reescrever para 6 ramos e 24 Dons, tarefa de UI com `art-director`), `scripts/audio.gd`, `scripts/core/combat_sounds.gd` (grep dos ids), `tools/book_lab.gd`, `tools/fatia3_lab.gd`, `tools/menu_lab.gd`, `run_log.gd`/`run_report.gd` (campo `talents` é lista de ids: aceita qualquer).

## PARTE B. Guerreiro

Hoje: vida 40, Magia 50, 1 esquiva (0,8 s), invuln. 0,7 s, +2 Magia por finalizador, +3 por Quebra (`KitFeed`), Brado Q (14 s), Investida E, Corte do Juízo Shift. **Mantidos.** Dom nenhum encosta no Brado e na Investida além do que a tabela diz.

### B.1 Os 12 Dons (existente x novo; sugestão de nível/custo)

Mapeamento aos stats existentes (`BoonState.stat`, tags `light`, `heavy`, `omega`, `finisher`, `shout`, `dash`). "Omega" nesta tabela é a tag técnica do Golpe Carregado (o ataque segurado, `ComboNode.In.CHARGE`, gasta Magia).

| Ramo | Dom (nível, custo) | Implementação | Código novo |
|---|---|---|---|
| Combo | Disciplina (L1, 2, entrada) | stat novo `dodge_window_add` = 2.0 somado em `ComboRunner.on_dodge/on_dodge_end` (`_dodge_left = tree.dodge_window + extra`) | 2 linhas + stat lido por `HeroGifts.step` (`runner.dodge_window_add`) |
| Combo | Cadência (L4, 2) | stat `cadence_pct` 0.08: `GiftState.attack_speed` soma `cadence_pct * golpes_sucessivos` (contador no `GiftState`, `chain` de `Combat.swung` do ataque; zera em fim de sequência, esquiva que expirou a janela, dano sofrido, `ComboRunner.reset`) | contador `chain_n` (cerca de 15 linhas) no lugar de `fury` |
| Combo | Maestria Marcial (L9, 3) | `TalentDef.combos` = `paladin_fifth.tres` (árvore de 5 golpes, gerada por `_tree(...)` como o `FOURTH_TREE`); golpes 4 e 5 com as tags do ataque (mesmo `light`/`finisher`, para Bênçãos contarem); o giro continua o último (finalizador) | só dado (`_tree` parametrizado) |
| Combo | Apogeu (L16, 4, ápice, `needs maestria_marcial`) | último golpe (o 5º) causa 150% da soma do dano efetivo anterior da sequência, **por alvo** (B.2) | `ApogeeLedger` puro (30 linhas) + 1 gancho em `Combat` |
| Ímpeto | Força Concentrada (L2, 2, entrada) | `damage_pct` 0.4 tag `omega` (já existe) | nenhum |
| Ímpeto | Determinação (L6, 2) | stat `attack_magick_pct` 1.0: `KitFeed.hit_magick(per_hit * (1 + pct))` e a recuperação do ataque básico (`magick_per_hit`) | 1 linha em `HeroGifts._on_landed` |
| Ímpeto | Concentração (L11, 3) | stat `charge_time_pct` -0.3, lido onde `charge_t` é comparado a `node.charge_time` (`Player`, `ComboRunner.charge_available`) | 3 linhas |
| Ímpeto | Força Titânica (L17, 4, ápice, `needs forca_concentrada`) | `omega_cost_pct` 1.0 (custo x2) e `damage_pct` 2.0 (x3) tag `omega`; custo = `base * (1 + omega_cost_pct) * (1 - omega_discount)` com `maxf(0, ...)` | stat `omega_cost_pct` em `Player.omega_cost` (callers: `player.gd:801,818,842,932,1074`) |
| Domínio | Ruptura (L3, 2, entrada) | `armor_pct` 0.5 tag `finisher` (já existe; soma ao dano de armadura/Quebra) | nenhum |
| Domínio | Voz do Leão (L8, 3) | dados do antigo Voz Larga: `reach_pct` 0.35, `damage_pct` 0.5, `push_pct` 0.3 tag `shout`, mais `stun_pct` 0.5 tag `shout` (interrupção) | nenhum |
| Domínio | Imposição (L13, 3) | `stun_pct` 0.5 sem tag (já existe; `Combat` linha 722 multiplica `horde.stun_scale`); chefes e golpes comuns sem stun seguem `StunRule` | nenhum |
| Domínio | Investida Implacável (L18, 4, ápice, `needs imposicao`) | Investida atravessa e atordoa 2 s todo alvo atingido. Ver B.4 | stat `dash_pierce` + `dash_stun` e exceção em `StunRule` |

Memória total sugerida: entradas 1, meios 1 a 3, ápices 4 (cada) = soma 27, abaixo do reembolso máximo 60. Cada ramo tem níveis espaçados; o `balance-designer` ajusta. `slot` fica NONE em todos (nenhum disputa botão), exceto Disciplina, Maestria Marcial e Investida Implacável se o robô precisar de exclusividade: não precisa, deixar NONE.

### B.2 Apogeu (regras)

- `ApogeeLedger` (puro, `scripts/core/apogee_ledger.gd`): `add(target_id, dmg)`, `finisher(target_id) -> float`, `reset(target_id)`, `clear()`. Mapa `target_id -> soma`.
- Soma só o dano efetivo (depois de armadura, resistências e multiplicadores) de golpes do **ataque** do combo (`DealtBy.source == &"attack"`, nós 1 a 4 da sequência); **nunca** conta reação, dano periódico (queima, ecos de Encanto `echo`), onda de golpe, Brado, Investida, Golpe Carregado nem o próprio Apogeu.
- O 5º golpe aplica `soma * 1.5` como dano **aditivo** (não passa de novo pelo registro, sem recursão) e ele mesmo não é adicionado. Ordem de multiplicadores: o bônus é calculado **depois** dos multiplicadores do golpe (o acumulado já os traz); sobre ele valem `damage_pct` do `finisher` e chefes' resistências uma única vez.
- Por alvo: dois inimigos atingidos pelo mesmo giro acumulam cada um o seu; não soma de alvos diferentes.
- Reset do alvo: morte, fim da sequência (último golpe, sequência interrompida por `runner.reset`, esquiva além da janela de Disciplina, dano sofrido), expiração por 4 s sem golpe, mudança de sala (`clear()` em `Game` na troca de sala).
- Imunidades de chefes e golpe comum sem stun: Apogeu é dano, não stun; nada muda no `StunRule`.

### B.3 Ímpeto e Magia

- Sem Magia suficiente, o Golpe Carregado não começa (`Player._affordable`) e o ataque normal sai; **Magia nunca fica negativa** (`Magick.spend` já recusa; `omega_cost` ganha `maxf(0.0, ...)`).
- Força Titânica: com custo duplicado e Magia 50, 20 de custo base vira 40; se `can_pay` falha, cai no golpe normal sem consumo. `omega_discount` (Lâmina Faminta) **deixa de ser alimentado** (o Dom some); o parâmetro fica na fórmula porque Encantos/Bênção podem usá-lo (grep antes de remover).
- Determinação dobra a Magia por golpe do ataque básico (mesmo teto `gain_cap` por `gain_window`; **o teto continua**, para o ganho não explodir).
- Concentração reduz o carregamento sem baixar o custo.
- Ordem testada: `custo = base * (1 + omega_cost_pct) * (1 - omega_discount)`; `dano = base * (1 + soma damage_pct omega)` com Força Concentrada +0,4 e Força Titânica +2,0 somados (x3,4 no total quando os dois estão equipados). Se o Daniel quiser x3 final (não 3,4), fixar multiplicação em vez de soma: **decisão de balanceamento, não bloqueia** (padrão: soma, já é como `damage_pct` funciona).

### B.4 Investida Implacável (exceção explícita)

A Investida (E, `rush`) hoje é um golpe `dash` com `magick_per_hit` e dano. Com o Dom: o movimento atravessa corpos (`Combat` não detém a Investida em alvos; stat `dash_pierce` > 0 desliga a parada), e cada alvo atingido recebe `stun_t` 2,0 s **uma vez por Investida** (conjunto de ids já atordoados na passagem, sem duplicar por quadro). Exceção: `StunRule` permite stun em golpes comuns só se a Investida Implacável está equipada (`hero_gifts` informa); inimigos blindados (elites, guardiões) não entram em stun: recebem `armor_pct`/Quebra (contribuição fixa: dano de armadura x1,5). Morvath e chefes ressonantes: nunca atordoados (imunidade preservada), recebem só a contribuição de Quebra (alcance e valor: pendente de balanceamento). O Dom antigo `investida` (volta da esquiva) some.

### B.5 O que apagar (Fúria e afins)

- `GiftState`: `fury`, `fury_left`, `fury_max()`, `on_kill`, `rally(...)` (o argumento `charges`; o Brado continua com `rally_left/speed/guard`), `fury_full_pct`, `attack_speed` sem o termo `fury`; `lamina_faminta` (`hungry_left`, `on_landed`, `omega_discount` ligado à janela), `chains_on` e stats `dash_chain`, `spin_loop_hits` (Passo Encadeado e Golpe sem Fim), `dash_back_on_kill`/`dash_back` (Avanço Feroz, Investida): **grep antes**; só sai o que não tem consumidor fora dos Dons removidos (Encantos da Fatia 2 usam `blow_wave_fan`, `echo`, `return_*`, `blow_speed`, `armor_pct`: ficam).
- `HeroGifts`: `p.show_fury(state.fury)`, `_dash_back_blow`, `_on_killed` charges; `Player.show_fury`, `EMBER_SHADER`, shader `fury_ember.gdshader` (arquivo pode ficar sem uso; apagar o `preload`).
- `Combat.gd:254` `fury_full_pct`; `Combat._gift_wave` fica (Encantos).
- Dons removidos: os 23 `.tres` do Guerreiro e os 23 da Maga, `make_data.gd` `_talents`/`_maga_talents` reescritos; `HeroDef.passive_tags` mantém `omega` (ainda é finalizador) e `dash`.
- HUD/Livro: `glossary.gd` termo `fury`; textos acima. O HUD do Guerreiro **não** mostra cargas de Fúria hoje (só brasas na lâmina), então "remover cargas do HUD" = brasas.
- Brado: sem Fúria o Brado perde a recompensa de 1 carga e fica com buff de velocidade e guarda (`rally_*`); revisar `docs/design/warrior_spec.md` e o texto `gloss_*` do Brado. O Daniel decidiu (B2) que a Fúria sai; **nada a perguntar**.

### B.6 O que o Guerreiro pede de código novo (resumo)

`dodge_window_add` (2 linhas), `chain_n` e `cadence_pct` (15), `attack_magick_pct` (1), `charge_time_pct` (3), `omega_cost_pct` (cerca de 6 nos chamadores), `ApogeeLedger` (30 mais gancho 10), `dash_pierce` e `dash_stun` (cerca de 25 em `Combat`/`Horde`/`StunRule`), `paladin_fifth.tres` (dado). Tudo o mais é dado.

## PARTE C. Maga elemental

### C.1 O kit mapeado ao código

Árvore de combo `_maga_tree` hoje: `neutral = [shot1(light) -> shot2 -> shot3, blast(heavy), circle(shout), dome(rush)]`, `tree.dodge_window = 0`. Passa a:

| Botão | Habilidade | Nó em `_maga_tree` | Reuso | Número base |
|---|---|---|---|---|
| Esquerdo | Centelha | `shot` único (sem cadeia de 3), tags `light,bolt,arcane,fire` | `Projectiles` bolt, `wave_bolt`, `Arcane.shot_landed` | 8 dano, alcance 11 m, custo 0, +1 Magia por acerto (via `magick_per_hit`, sujeito a `gain_cap`); 3 acertos no mesmo alvo em 4 s aplicam Queimadura |
| Esquerdo segurado | Combustão | `In.CHARGE` do light, tags `omega,fire`, `charge_time` 0,6, `magick_cost` 15 | mecanismo omega do `Player`; explosão = `Arcane._blast` simplificada (para no 1º inimigo) | 35 dano, raio 2 m, Queimadura imediata |
| Direito | Estilhaço | `heavy` com `cooldown` 4,0, bolt `wave_through` (penetrante), tags `heavy,ice` | `blow_wave`/projétil penetrante (`wave_stops=false`) | 6 por alvo, 0 Magia, Frio e lentidão 30% por 2 s (`e.slow_t`) |
| Direito segurado | Geada | `In.CHARGE` do heavy, tags `omega,ice,cast`, 20 Magia | `Arcane._contain` (área no cursor) reaproveitado como `Zone` | raio 2,5 m, 3 dano/s por 4 s, Frio progressivo até congelar (limiar 4 s de exposição) |
| Q (`shout`) | Arco Voltaico | `shout` com `cooldown` 8, tags `shout,cast,volt` | `Combat` golpe em cadeia; novo `Arcane._arc` | 12 por alvo, até 3 alvos (nearest, sem repetir), 0 Magia, aplica Eletrizado |
| E (`rush`) | Suspensão Arcana | `dome` atual **sem Selo** | `Arcane._suspend/_step_dome` (preservar) | raio 2,6 m, 2,5 s, recarga 14, lentidão 40% (`dome_slow` 0.3 vira 0.4) |
| Espaço | Passo Etéreo | atual (`Arcane._on_dodged`, `blink_distance` 4.5, 2 cargas, 1 s) | preservar | sem dano; sai o `step_flash`/embers de Selo se dependiam de Selo |
| Shift | Convergência Elemental | `UltDef.Kind.CONVERGE` | `Ultimates` (carga por Magia, dano, vida) | C.3 |

Mudanças de dados: `ArcaneKit` perde grupos Selo, Explosão, Ressonância, Círculo e as constantes de Selo; ganha grupos `Centelha`, `Combustao`, `Estilhaco`, `Geada`, `Arco`, `Elementos` (C.2) e `Convergencia`. `HeroDef.arcane` continua o ponteiro. Os textos de ação `hero_action_*_maga` (`HeroLoadout.action_key`) são revistos.

### C.2 Estados elementais como dado

- `ElementBook` (puro, `scripts/core/element_book.gd`, substitui `SealBook`): por inimigo (`Enemy` como chave, ids estáveis) guarda `burn_t`, `cold` (0 a `cold_max`, decai), `volt_t`, `last_reaction_t`. Não toca em `Enemy.burn_t/burn_dps/mark_t/frozen_t/slow_t` das Bênçãos nem na Marca de Qeshael. A **Queimadura nativa** causa dano por `Horde.damage` com tag `&"elemental"`; **não conta** como a queimadura da Bênção (`e.burn_t`) e vice-versa (`ArcaneKit.bless_cross := false`; compatibilidade cruzada é decisão futura).
- `ElementKit` (grupo `Elementos` do `ArcaneKit`): `burn_time 3.0`, `burn_dps 4.0`, `volt_time 3.0`, `cold_time 3.0`, `cold_freeze_at 3` (acertos de Frio), `slow_pct 0.3`, `centelha_hits 3`, `centelha_window 4.0`, `react_gap 0.5` (intervalo mínimo por alvo entre reações), `thermal 20`, `overload 15`, `overload_radius 1.8`, `crystal_freeze 0.8`, `crystal_boss_poise 25`.
- API pura: `apply(e, element, now) -> Array[Reaction]`; `tick(dt)`; `clear(e)` (morte); `clear_all()` (troca de sala). Aplicar um elemento a quem já o tem **renova** a duração e não duplica; reação consome os dois estados e gera **uma** reação (`react_gap` impede repetição por quadro ou tick); a reação não aplica estados (sem cadeia por padrão).
- Prioridade quando os três estados coexistem: Choque Térmico (Queimadura+Frio) > Sobrecarga (Queimadura+Eletrizado) > Cristalização (Frio+Eletrizado); consome só o par escolhido. Determinístico. Seis ordens de par testadas (A depois B e B depois A para os três pares).
- Reações: Choque Térmico +20 no alvo; Sobrecarga 15 em área 1,8 m (alvos próximos **sem** aplicar estado); Cristalização congela comuns 0,8 s (`frozen_t`) e dá Quebra (`crystal_boss_poise`) em chefes e blindados. Dano das reações usa tag `elemental` e **não** gera Magia por tick/reação (só `shot_magick` por acerto do projétil, com `gain_cap`). Reações não passam pelo Apogeu (é do Guerreiro) e não recarregam recargas.
- Legibilidade: pequenos pips acima do inimigo (âmbar, ciano, branco-dourado) em `EnemyFx`/`CrowdRenderer` (formas diferentes do aviso vermelho: losango, floco, faísca); sem barra de recurso. Tarefa mista (engenheiro cria o estado na `Horde`, UI/arte desenha).

### C.3 Convergência Elemental (Supremo único do bastão)

`UltDef.Kind.CONVERGE`, Maestria 2, carga 75 (Magia gasta, dano e vida perdida como hoje, `UltCharge` intacto). Campos próprios: área `radius 5`, `duration 4.5`, `ahead/aim_max` como a Tempestade (no cursor, até 9 m), `tick 0.5`, `direct_damage 90` (somado dos ticks, não por tick), `phase_split` 3 fases iguais de 1,5 s: **gelo** (aplica Frio e lentidão), **fogo** (aplica Queimadura; dispara Choque Térmico se Frio ainda vale), **eletricidade** (aplica Eletrizado). Decisão do Daniel: nos **dois últimos ticks** da fase elétrica o supremo **reaplica Queimadura no penúltimo e Frio no último**, para que Sobrecarga e depois Cristalização aconteçam sempre. Cada reação respeita `react_gap` e o limite de uma por par por alvo por fase. Chefes tomam 25% do dano direto e Quebra em vez de congelar (regra da Cristalização); guardiões e elites seguem `elite_share`/`guardian_share`. Visual: reaproveita o disco/âmbar do domo e as cores do pacote (âmbar, ciano, branco-dourado; sem violeta e sem esmeralda).

### C.4 Proposta dos 12 Dons da Maga (**proposta, aguarda o Daniel**; podem entrar como dado provisório com `desc` marcada)

Ramos: Elementalismo (reações), Conjuração (persistência e território), Feitiçaria (encadeamento e Magia). Sem sustento, sem pontes. Níveis e custos sugeridos; ids novos evitam colisão com os legados.

| Ramo | Dom (nível, custo) | Efeito proposto | Stat |
|---|---|---|---|
| Elementalismo | Faísca Persistente (L1, 2, entrada) | Queimadura dura +2 s e causa +25% | `burn_time_add` 2, `burn_dps_pct` 0.25 |
| Elementalismo | Orvalho Gélido (L5, 2) | Frio congela com um acerto a menos; lentidão +15% | `cold_freeze_at` -1, `slow_pct` +0.15 |
| Elementalismo | Reação Amplificada (L10, 3) | Choque Térmico e Sobrecarga +50% | `react_pct` 0.5 |
| Elementalismo | Fissão Térmica (L17, 4, apex, needs Reação Amplificada) | Choque Térmico e Sobrecarga também atingem 2 m em volta a 50% (sem estados novos, sem cadeia) | `react_splash` 0.5 |
| Conjuração | Geada Demorada (L2, 2, entrada) | Geada dura +2 s e +0,5 m de raio | `geada_time_add`, `geada_radius_add` |
| Conjuração | Chão Ardente (L7, 3) | Combustão deixa o chão em chamas por 3 s (4 por s, aplica Queimadura, sem renovar sozinha) | `ember_floor` |
| Conjuração | Suspensão Larga (L12, 3) | domo +0,6 m e +1 s | `dome_size_pct`, `dome_time` (já existem) |
| Conjuração | Campo Elementar (L18, 4, apex, needs Suspensão Larga) | dentro do domo seus tiros e áreas causam +30% | `dome_shot_pct` 0.3 (já existe) |
| Feitiçaria | Eco Elétrico (L3, 2, entrada) | Arco Voltaico atinge +1 alvo (4) | `arc_targets` 1 |
| Feitiçaria | Fluxo de Magia (L8, 2) | +0,5 Magia por acerto da Centelha e Estilhaço (teto `gain_cap`) | `shot_magick_add` 0.5 |
| Feitiçaria | Estilhaço Gêmeo (L13, 3) | Estilhaço com 2 cargas, recarga 4 s para 3 s | `shard_charges` 1, `cooldown_pct` -0.25 tag `ice` |
| Feitiçaria | Tempestade Contida (L19, 4, apex, needs Eco Elétrico) | Arco salta +2 alvos (cada alvo uma vez) e a Convergência carrega 25% mais rápido | `arc_targets` 2, `ult_charge_pct` 0.25 |

Soma de Memória: 2+2+3+4+2+3+3+4+2+2+3+4, ou pela regra de custo atual abaixo do reembolso máximo 61. Marcar `desc` com "(provisório)" no gerador e no relatório; o Daniel aprova antes de remover o rótulo. Nenhum Dom da Maga fecha como definitivo.

### C.5 Bênçãos (sete famílias compartilhadas) e a Maga

Tags: Centelha `light,fire` (golpe), Combustão `omega,fire`, Estilhaço `heavy,ice`, Geada `omega,ice,cast`, Arco `shout,cast,volt`, domo `dash,dome` (como hoje), Passo `dash,blink`. Famílias seguem lendo `damage_pct`, `freeze_time`, `burn_dps` etc. sobre essas tags; **nenhuma Bênção aplica estado elemental nativo** nesta rodada. Famílias `chama` e `geada` continuam aplicando a queimadura/congelamento das Bênçãos (`e.burn_t`, `frozen_t`), separados dos estados nativos (`bless_cross false`). Marca de Qeshael: intacta, só `mark_t`.

### C.6 O que apagar da Maga

`SealBook`, `Resonance`, `Arcane` blocos `_blast`, `_burn_near`, `_leap`, `_step_twins/_twin_blast`, `_refund_circle`, `_contain/_step_circle/_close_circle/_end_circle/_in_circle` (o que a Geada reaproveita é a zona, não o Círculo), `ultra*`, `open_absolute`, `last_blast`, glifos de Selo (`_step_glyphs`, `_drop_glyph`, `SIGILS`); `ArcaneKit` grupos antigos; stats `seal_*`, `burn_dps` com tag `seal/blast`, `twin_blast`, `step_flash` (se não mais usado), `inferno_*`, `circle_*`; `UltDef` grupos `Storm`/`Dome` e `Kind.STORM/DOME`; `hud.gd:836` (losangos de Ressonância), `bot.gd:488` (laço do robô da Maga: reescrever para o novo kit: Centelha até 3 acertos, Combustão com Magia, Estilhaço, Arco com 2 alvos, domo, Convergência), `run_report.gd:35` (`resonance`), `ultimates.gd:516,535`. Texto e testes conforme A.6 e D.

### C.7 O que a Maga pede de código novo

`ElementBook` e `Reaction` (puros, cerca de 150 linhas), `Arcane._arc` (Arco, 60), `Arcane.centelha/_combust/_shard/_frost` (200, reaproveitando `_blast`, `_contain`), `UltDef.Kind.CONVERGE` e `Ultimates._converge` (140), pips de estado (`EnemyFx`, 60), bot novo (80). **Todo o resto é dado** (`ArcaneKit`, `_maga_tree`, `_maga_talents`).

## D. Testes (GUT) mapeados ao aceite de 03

Rodar só `-gselect` dos próprios; suíte inteira uma vez no fim (regras do projeto).

| Aceite (03) | Teste | Novo ou ajustado |
|---|---|---|
| Ambos jogáveis; controles preservados | `test_hero_pick`, `test_controls*` | ajustar ids |
| Vida/Mana iniciais 40/50 e 30/50 | `test_hero_def` | + asserts de `max_hp` e `magick_max` |
| 12 Dons, três ramos, `needs` | `test_talents` (reescrever), `test_warrior_talents` (reescrever), `test_dons_medallion` (12 nós + coroa), `test_c2`, `test_hero_screen` | novo `test_talents_redesign` |
| Sem Fúria ativa | `test_warrior_talents`: nenhuma stat `fury_*` no catálogo; `GiftState` sem `fury` | novo |
| Combo continua após esquiva (Disciplina) | `ComboRunner` janela 0,3 vs 2,3 s | novo |
| Apogeu sem recursão | `test_apogee_ledger`: por alvo, não soma reação/queima/Apogeu, reseta em morte, fim, sala; 5º golpe = 1,5 x soma | novo |
| Ímpeto consome Magia certo | `test_impeto`: custo x2, `maxf(0)`, sem Magia cai no golpe normal, cancelar carga não gasta, Concentração -30% | novo |
| Investida aplica CC a cada alvo | `test_charge_pierce`: 3 alvos, stun 2 s cada, uma vez por passagem; blindado e chefe só Quebra | novo |
| Maga com 3 elementos na mesma arma, kit acessível | `test_maga_kit`: botões do `_maga_tree`; toque vs segurar (Centelha/Combustão, Estilhaço/Geada); Magia insuficiente; cancelar carga | novo |
| Sem Selos/Ressonância | `test_maga_seal`, `test_maga_loop`, `test_maga_m2` apagados ou reescritos; `grep` de classes removidas | remover |
| 6 ordens de par; consumo; expiração; sem reação duplicada | `test_element_book` | novo |
| Múltiplos alvos, elites, chefes, áreas persistentes, mortos, troca de sala | `test_element_book` + `test_maga_kit` (clear em morte e sala; Geada sobre alvo morto) | novo |
| Supremo único, carga e desbloqueio; fases | `test_ultimate`, `test_t5_ultimate`, `test_ult_ring`, novo `test_converge`: fases gelo, fogo, elétrica, reaplica fogo e frio nos 2 últimos ticks, chefe sem congelar | ajustar e novo |
| Bênçãos sem regressão; Marca de Qeshael; sem cadeia infinita | `test_boon*`, novo caso: Bênção de Marca ainda marca; `bless_cross` falso; reação não gera reação | ajustar |
| Migração e Videira | `test_save`, novo `test_migrate_redesign`: ids legados, reembolso 60 e 61, Vagas livres, 2 execuções = mesmo resultado, saves sem Dons, `mastery_xp`/`forge`/`vine` intactos; `test_vine` com `respiro` e `ainda_de_pe`, `Vine.first` e `VineLayout` com 4 ramos | novo |
| Terminologia | `test_text`: nenhuma chave de texto com "Ômega", "Fúria", "Ressonância" ou "Selo" de Maga; chaves de Dons existem; sem travessão | novo |
| Smoke | `tools/smoke.sh 600` Guerreiro e Maga, 12 sementes; RESULT muda (esperado) | manual |

## E. Divisão de trabalho (até 2 engenheiros em paralelo; cada passo mergeável e jogável)

Donos de arquivo: **gameplay-engineer (GE)**: `scripts/core/*`, `scripts/game/*`, `tools/make_data.gd`, `data/` gerado, `tests/` de lógica, `scripts/save.gd`. **ui-ux-designer (UI)**: `data/text_pt.tres`, `scripts/ui/*`, `scripts/core/vine_layout.gd`, testes de UI. A sessão principal cola chaves de texto novas se um passo de GE precisar delas antes do passo UI.

1. **GE-1 (infra, invisível)**: `TalentDef.needs` + `Branch/Tier` novos + `Talents.needs_met`; `UltDef.weapon/reserve`, `HeroDef.weapon/ult_for_weapon`; `SaveData` v13 `migrate_redesign` (ainda sem catálogo novo: tabela `LEGACY_DONS` e testes). Os catálogos antigos continuam carregando com as definições antigas convertidas em `needs` (apenas para os testes antigos não quebrarem): **não ativar a migração até o passo 4**. Em paralelo **UI-1**: textos (A.6, termos "Golpe Carregado", ramos, Vine novas chaves), `glossary.gd`, sem tirar nada que o jogo ainda usa; `MedallionView` sem `Kind.ULT` (nós ULT escondidos quando o herói tem Supremo fixo). Sem conflito: GE em core, UI em ui e texto.
2. **GE-2 (Videira + Supremo fixo, ainda com os Dons antigos)**: 4º ramo da Videira em `_vine`, `Vine.BRANCHES`; `HeroLoadout.ultimate()` fixo; `Game` equipa o Supremo da arma; Voragem em reserva. **UI-2** em paralelo: `vine_screen.gd` e `VineLayout` com 4 ramos (arte do tronco do `art-director`), `hero_screen.gd` sem escolha de Supremo (mostra o fixo e a carga), `dons_screen.gd` sem ULT.
3. **GE-3 (Guerreiro novo, passo B)**: 12 Dons (`_talents` reescrito), stats e códigos B.6, `paladin_fifth.tres`, remoção da Fúria (B.5), `_psalms` com ids novos, `bot` do Guerreiro revisado. Mesmo PR **liga a migração** (v13) para que ninguém fique sem Dons: o save antigo recebe a Memória e as Vagas livres na mesma versão. **UI-3** em paralelo: medalhão do Guerreiro (12 nós, `MEDALLION_WARRIOR` é dado em `make_data.gd`: pedir ao GE as 12 posições; ou UI propõe e GE cola), glifos dos 12 Dons (`talent_glyph/motif/node/gift_art`), textos dos 12 Dons. **Exe** e playtest do Guerreiro.
4. **GE-4 (Maga elemental, passo C)**: `ElementBook`, kit novo em `_maga_tree` e `ArcaneKit`, `Arcane` enxuto, Convergência, bot da Maga, remoção de Selo/Ressonância (C.6), os 12 Dons propostos como provisórios (C.4). **UI-4** em paralelo: medalhão da Maga (12 nós), pips elementais (com `art-director`), HUD sem Ressonância, textos do kit, glifos. **Exe**.
5. **Fechamento (GE e UI)**: documentação (`docs/design/heroes/maga.md`, `warrior_spec.md`, `docs/art/dons_medallion_spec.md`, `docs/reference/meta.md`, `gameplay.md`, `ui.md`), suíte inteira, smoke de 12 sementes por herói, `balance-designer` mede DPS, consumo de Magia e CC (sem declarar final).

Passos 1 e 2 podem rodar um depois do outro em paralelo com seu par de UI; 3 e 4 só se não editarem os mesmos arquivos (`tools/make_data.gd`, `Combat`, `Player`): fazer **3 antes de 4**, nunca juntos.

## F. Riscos e o que é indecidível

- **R1** Migração: o Daniel decidiu reembolso total. Risco: o jogador que equipou 5 ou 6 Dons perde o loadout (Vagas livres, esperado). O reembolso é de Memória, não de Maestria (nada de XP muda).
- **R2** Apogeu com Maestria Marcial: sequência de 5 golpes e `chain_window` curto pode ser difícil de completar sob pressão; Disciplina (2 s) compensa. Pode ficar forte demais em alvos únicos (chefes): considerar teto de 400% do último golpe. Força Titânica x3,4 de dano com custo x2 pode quebrar o carregado: teste de DPS por Magia antes do exe.
- **R3** Arte: medalhão pintado (24 nós) e o tronco da Videira (3 ramos) precisam de nova versão; o plano usa o desenho procedural até lá, o que parece provisório.
- **R4** Os estados nativos dividem o inimigo com as Bênçãos (`burn_t`, `frozen_t`, `slow_t`); sem `bless_cross` pode parecer que "Bênção de Chama não combina" com a Maga. É a decisão segura do pacote; revisar em playtest.
- **R5** Dois Supremos que sumiram (Voragem do Guerreiro; Tempestade e Suspensão Absoluta da Maga): Maestria 10 e 6 deixam de entregar item novo; a curva de Maestria fica com buracos de recompensa (resolvido com Dons novos nesses níveis: sugestão B.1 e C.4).
- **R6** `bot.gd` joga a Maga pelo laço de Selos; sem reescrita, o robô e o `--smoke` falham. Faz parte do passo GE-4.
- **Indecidível sem o Daniel (curtas)**: (a) nomes e efeitos finais dos 12 Dons da Maga (C.4); (b) multiplicador final da Força Titânica (x3 contra x3,4) e a contribuição de Quebra da Investida em chefes (valores); (c) se o novo 4º ramo da Videira se chama "Regeneração" (nome) ou entra como passos 4 e 5 do ramo Vida; (d) nomes dos paladinos continuam `PALADIN_1..4`, sem mexer.

## G. Decisões da sessão principal (2026-11-24, o Daniel pediu "pode fazer todo o redesign"; revisar no playtest)
- **Força Titânica**: x3 **final** sobre o dano do golpe carregado (o pacote diz "triplo"), aplicado depois de Força Concentrada, que soma no `damage_pct`; custo x2 de Magia, nunca negativa. Teto do Apogeu: 400% do último golpe.
- **Quebra da Investida Implacável em chefes**: o mesmo valor de Quebra de um finalizador do combo (sem número novo).
- **Videira**: Respiro e Ainda de Pé entram como **passos 4 e 5 do ramo Vida** (sem 4º ramo, sem arte nova de tronco). Ajustar GE-2/UI-2 a isso.
- **Dons da Maga**: a proposta C.4 entra como dado provisório (marcada no `docs/backlog.md` para o Daniel aprovar); nomes só em `text_pt.tres`.
- Passos em série: 1, 2, 3, 4, 5; GE e UI em paralelo dentro de cada passo; um exe só no fim (o Daniel pediu).
