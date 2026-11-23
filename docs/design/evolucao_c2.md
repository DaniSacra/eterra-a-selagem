# CB-6 / C2: a evolução que se sente (proposta, nada aplicado)

Base: lote C1 no disco (ataque 15/15/20 = 50, Ômega 100, onda 35, Investida 35, Brado 15 com 1 golpe absorvido).
Fontes: `tools/make_data.gd` (`_talents`, `_forge`, `_account`), `scripts/game/combat.gd` (`hit_enemy`, `ARMOR_SPECIAL`),
`docs/design/director_review_2026-11-22.md` seções 2 e 9. Nomes novos: **(a aprovar)**. Nenhum lore novo.

## 0. Como somar (regra de leitura)
`damage_pct` soma sem multiplicar entre fontes (Forja, conta, Dom, Bênção); o golpe lê as de sua etiqueta (`light` = os três
cortes, o Corte Veloz e o Ômega do ataque; `heavy` = especial e seu Ômega). Combo sem Bênção = golpes x (1 + soma).
O Quarto Corte soma um golpe de 15 (combo 65 com a mesma soma). Hoje (herói fraco) a conta dá: Forja I 20% + Temperar III 5%
+ conta 12% = 37% e Quarto Corte, ou seja **65 x 1,37 = 89**: a curva sobe pouco no meio e **pára antes de 100**, e três
promessas de atordoar valem zero.

## 1. A curva (combo sem Bênção, só números de combo)
| Marco | O que está aberto | Soma `light` | Combo | Meta |
|---|---|---|---|---|
| Começo | nada | 0% | 15+15+20 = **50** | 50 |
| 1 | Forja I, conta `forca_1`, Ímpeto, Corte Crescente | 26% | **63** (a onda de 12 do giro é extra) | 65 |
| 2 | Forja I e II, 4 Dons com **Quarto Corte**, conta 6 | 26% | 15+15+15+20 = 65 x 1,26 = **82** | 80 |
| 3 | tudo: Temperar III, conta 12, Fúria Plena | 42% | 65 x 1,42 = 92 + Fúria Plena 11 = **104** | 100 a 105 |
Sem e com evolução: 50 contra 104 (dobra). A diferença vem de **três saltos que o jogador vê**: Forja I (+12 no combo), Quarto Corte
(+16, um golpe a mais), Fúria Plena e Forja III (+22 juntos). Especial no marco 3: 35 x 1,42 = 50; Ômega do especial 100 x 1,42 = 142.
Mudança só de números em 2 itens (Temperar III e Onda Crescente); o resto é troca de efeito. Medir com `--boons` e `--account`.

## 2. Dom por Dom
| Dom (chave) | Hoje com o herói fraco | Proposta |
|---|---|---|
| `quarto_corte` (Combo, entrada, 3) | +15 de golpe: +30% do combo; é o maior salto | manter 15; **é o marco 2** |
| `passo_encadeado` | `dash_chain` 1: a Investida (35) encadeia no combo | manter |
| `golpe_sem_fim` (ápice) | `spin_loop_hits` 3, o giro volta ao 2o golpe | manter |
| `impeto` (Fúria, entrada) | `fury_speed` 0,06 por carga, até 3 (+18% de velocidade) | manter |
| `avanco_feroz` | `dash_back_on_kill` 1 (tag `finisher`) | manter |
| **`furia_plena`** (ápice) | `fury_stun` 0,5: não atordoa, **vale zero** | trocar por `fury_full_pct` 0,40 (tag `finisher`): com 3 cargas o giro causa +40% (20 passa a 28 x soma). Stat novo, ver 4 |
| `corte_crescente` (Emeth, entrada) | `blow_wave` 16 em 6 m: 80% do giro, à distância, de graça | `blow_wave` **12** (6 m, 3 m), para o giro não virar o melhor golpe |
| `fio_longo` | `reach_pct` 0,15 `light` | manter |
| `onda_atravessante` | `wave_through` 1 | manter |
| `lamina_faminta` | `omega_discount` 0,5 em 1 s | manter (o Ômega de 100 compensa o custo) |
| `reserva` | `magick_max` +20 (50 para 70) | manter |
| `coracao_da_emeth` | `ult_charge_pct` 0,25, `finisher_magick` 1 | manter (ultimate a 60% já puxa a carga) |
| `onda_carregada` (ponte) | `blow_wave` 16 em `heavy`: 46% da onda de 35 | **12** (mesma razão do Corte Crescente) |
| `fio_do_passo` (ponte) | `blow_wave` 12 em `dash` | manter |
| `investida`, `sangue_quente` | `dash_back_on_kill`; carga por Ômega | manter |
| `firmeza`, `respiro`, `ainda_de_pe` | vida +10, cura 2 por sala, levantar com metade | manter (a vida 30 já é o piso) |

## 3. Forja, rank a rank (`_forge`)
| Rank | Hoje | Proposta |
|---|---|---|
| Temperar I (15 Prata) | `damage_pct` 0,20 `light` | manter: é o primeiro salto (+10 no combo) |
| Temperar II (35) | `damage_pct` 0,20 `heavy` | manter (especial 35 para 42; Ômega do especial 100 para 120) |
| Temperar III (60) | 0,05 `light` e 0,05 `heavy` | **0,10 em cada**: é o salto que leva o marco 3 a 100 |
| Refinar Fio | `reach_pct` 0,10 `light` | manter |
| **Refinar Peso** (25) | `stun_pct` 0,5: **não faz nada** | `armor_pct` **0,20** `light`: o ataque tira +20% da blindagem (stat novo) |
| Refinar Pressa | `blow_speed` 0,08 `light` | manter |
| Refinar Onda Larga | `wave_size_pct` 0,2 `heavy` | manter |
| **Refinar Onda Pesada** (25) | `stun_pct` 0,5: **não faz nada** | `armor_pct` **0,30** `heavy`: a onda tira +30% sobre o +50% de hoje (80% no total) |
| Refinar Onda Pronta | `blow_speed` 0,08 `heavy` | manter |
| Despertar Sede, Ímpeto, Eco Longo | 0,5 de vida por abate; +3 Magia; eco de 33% | manter (Sede pesa mais com vida 30) |
| Inscrever (20 Prata cada) | Encantos | manter |
| (vazio) Refinar do Brado e da Investida | não existe | opcional, ver 5 |

## 4. A troca dos itens que prometem atordoar (seção 9 do director_review)
Regra do F8 mantida: nenhum golpe do herói atordoa. A blindagem é a barra amarela dos elites: ao quebrar, abre 2,5 s de janela.
| Item | Era | Passa a ser | Stat |
|---|---|---|---|
| Refinar Peso | atordoar 50% mais | ataque tira +20% da blindagem | `armor_pct` 0,20 `light` |
| Refinar Onda Pesada | atordoar 50% mais | especial tira +30% da blindagem | `armor_pct` 0,30 `heavy` |
| Dom Fúria Plena | finalizador atordoa +0,5 s | finalizador com 3 cargas causa +40% | `fury_full_pct` 0,40 `finisher` |
| Bênção Vigia Firme | atordoar mais | sai com o Lote 8 | nenhum |
**Stat novo `armor_pct`** (lido por etiqueta, soma): em `Combat.hit_enemy`, a linha
`dmg *= 1.0 + (ARMOR_SPECIAL if heavy else 0.0)` passa a `dmg *= 1.0 + (ARMOR_SPECIAL if heavy else 0.0) + boons.stat(&"armor_pct", tags)`
(só com `e.armor > 0`). Custo: 1 linha, 1 teste GUT, 0 mudança de estrutura; `armor_pct` entra em `BoonMod` como inteiro sem arredondar.
A Investida e o Ômega ficam com a base 0 (a Investida ganha +25% pelo Dom do item 5, não por constante). O `stun_pct` continua
existindo só para as Bênçãos que o usarem; confirmar com o balance-designer que nenhuma das 42 o promete (Vigia Firme sai).
**Stat novo `fury_full_pct`**: em `Combat`, se as cargas de Fúria estão no máximo, o golpe `finisher` multiplica por (1 + valor).
Custo: cerca de 4 linhas e 1 teste. Se o Daniel preferir zero código: `damage_pct` 0,25 `finisher` sem condição (menos fiel ao nome).

## 5. Dons para o Brado (Q) e a Investida (E)
Hoje o Brado só tem Ímpeto (carga de Fúria) e a Investida tem Passo Encadeado, Fio do Passo e Investida (ponte). Os dois botões
rendem pouco porque nenhum Dom os faz melhores. Propostas (4 Dons novos, nomes a aprovar):
| Dom (a aprovar) | Botão | O que faz | Stat | Código |
|---|---|---|---|---|
| **Voz Larga** | Q | o grito alcança 35% mais e causa 50% mais (15 para 22 x soma); empurra mais longe | `reach_pct` 0,35, `damage_pct` 0,5, `push_pct` 0,3, todos tag `shout` | nenhum (a etiqueta `shout` já existe) |
| **Escudo de Guerra** | Q | o Brado absorve **2** golpes (a carta já absorve 1, `buff_ward`) | `shout_ward` 1 | 1 linha em `Combat` (`gifts.ward = buff_ward + stat`) |
| **Fôlego de Guerra** | Q e E | recarga do Brado 12 s para 9 s; da Investida 5 s para 3,75 s | `cooldown_pct` -0,25 (tags `shout` e `dash`) | 1 leitura onde `Player` arma a recarga do golpe (2 linhas, 1 teste) |
| **Ferro na Investida** | E | a Investida causa +50% (35 para 52) e tira +25% da blindagem; assim fura o Escudo e abre o elite, que é a "razão" do botão | `damage_pct` 0,5 `dash` e `armor_pct` 0,25 `dash` | só o `armor_pct` (item 4) |
Onde moram na árvore: Voz Larga e Escudo de Guerra no ramo Fúria (meio, nível 7 e 12); Ferro na Investida no ramo Combo (meio, nível 6);
Fôlego de Guerra como ponte Combo/Fúria (nível 13). **A ver**: a árvore do Santuário tem posições fixas (3 por ramo); 4 Dons a mais pedem
conferir a tela (`ui.md`), custo de Memória 2, 3, 3, 3 (a aprovar). Com esses Dons o Brado deixa de ser "um golpe de graça" e vira o
botão da defesa (2 golpes por 12 s ou 9 s), e a Investida o botão de abrir elite e atravessar o Escudo.
Forja opcional (para encher a coluna vazia): Refinar Grito (`cooldown_pct` -0,15 `shout`) e Refinar Passo (`cooldown_pct` -0,15 `dash`),
25 Prata, ainda **dependem da tela da Forja** ter um 3o e 4o botão (hoje só Ataque e Especial); deixar para depois.

## 6. Conta ("O Preparo"), nó a nó (`_account`)
| Nó | Hoje | Proposta |
|---|---|---|
| `vida_1`, `vida_2`, `vida_3` | `max_hp` +8, +8, +9 (30 para 55) | manter |
| `cura_1`, `cura_2` | cura da sala +12%, fonte +15% | manter |
| `forca_1` | `damage_pct` 0,06 (Prata 30) | manter: sozinho dá +3 no combo |
| `forca_2` | `damage_pct` 0,06 (Prata 60) | manter: soma 12%; **não subir**, ou o marco 3 passa de 105 |
| `bencao_1`, `bencao_2` | raridade +8%, +10% | manter |
| `ouro_1`, `ouro_2` | ouro +15%, +20% | manter |
| `renascer` | `revive` 1 (Memória 20) | manter |
A conta é de todos os heróis (futuros): não pôr Dom de Guerreiro nela. Conta 6 = `vida_1`, `cura_1`, `vida_2`, `forca_1`, `bencao_1`, `ouro_1`:
só `forca_1` mexe no dano, por isso a curva usa 6%.

## 7. Resumo de dados e de código
Dados (só `tools/make_data.gd` e regerar): Temperar III 0,10 + 0,10; Corte Crescente e Onda Carregada 16 para 12; Peso e Onda Pesada
trocados; Fúria Plena trocada; 4 Dons novos; textos em `data/text_pt.tres` sem travessão (Peso, Onda Pesada e Fúria Plena precisam do texto novo).
Código: 3 stats (`armor_pct`, `fury_full_pct`, `shout_ward`) e 1 de recarga (`cooldown_pct`), cada um com 1 a 4 linhas e 1 teste GUT.
Riscos: (1) Quarto Corte sozinho vale +30% e a Forja soma por cima: se o marco 2 passar de 85, baixar Temperar I para 0,15;
(2) `cooldown_pct` com Bênçãos de recarga pode abrir o Brado 100% do tempo (teto -0,5); (3) Escudo de Guerra + Maré Ardente: Brado
quase sem pausa; (4) o robô não usa Brado antes do golpe (CB-0): sem ele, nada disto se mede.

## 8. Perguntas ao Daniel
1. Aceita o marco 3 em 104 (dobro do começo), ou prefere um teto de 95?
2. Os 4 Dons novos (e a tela da árvore ganhar posições)? Os nomes são marcadores.
3. Fúria Plena com +40% condicionado a 3 cargas (4 linhas de código) ou +25% simples (sem código)?
4. Refinar do Brado e da Investida entram na Forja agora ou só quando a tela ganhar botões?
