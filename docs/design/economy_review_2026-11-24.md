# Revisão da economia da meta, 2026-11-24 (balance-designer)

Escopo: quanto uma descida dá (Prata, Memória, Esmeralda) a um novato e a um evoluído, quanto custam os Dons, a Videira, a
Forja, o Vendedor e as Obras, e em quantas descidas o jogador compra o primeiro item visível. Nada aplicado; números para o
`tools/make_data.gd` abaixo.

## Como foi medido
- Registro real: `python3 -I tools/runs_report.py /mnt/c/Users/danie/AppData/Roaming/EterraASelagem/runs.jsonl` (47 partidas, 31
  reais; só as 12 do Guerreiro desde 2026-11-20 têm materiais). Os de antes dessa data valem 0 e não entram nas médias.
- Robô: `tools/smoke.sh 900 --seed=1..15 --bot-reaction=0.25 --ultimate=cleave`, sem Dons nem Forja, uma partida por vez
  (15 de 16 sementes terminaram a tempo). O robô não é gente: ele toma a porta de material em 1 de 15 descidas, o jogador
  humano em 20 Prata de porta em 31 partidas. Use para comparar, não como taxa real.
- Fontes e custos lidos em `tools/make_data.gd` (`_stage` 970 a 990, `_vine` 3015, `_forge` 3050, `_obras` 2975, `_oficios` 2995,
  `_talent` 1965) e em `scripts/core/run_map.gd` 639 a 641.

## Ganho por descida (média)
| Quem | Prata | Memória | Esmeralda | XP de Maestria |
|---|---|---|---|---|
| Criança, morre na sala 1 a 5 (real, 7 partidas) | **0,7** | **0** | 0 | 37 (Maestria 1 a 2) |
| Morre na sala 6 a 10 (real, 3) | 18 | 3,3 | 0,3 | 138 |
| Vitória (real, 2) | 37 | 6 | 2 | 320 |
| Robô, parou na sala 6 a 8 (6 de 15) | 6 | 2 | 0 | |
| Robô, chegou à sala 12 a 14 (9 de 15) | 28 (14 a 36) | 5,3 (4 a 7) | 0,5 | |

Prata vem de: guardião 6, elite 1 (robô 0 a 15 por descida, é a maior fonte dele), porta 10 (só da profundidade 4), Morvath
2 por fase e 10 na vitória. Memória: guardião 2, Provação 2, porta 3 (só depois do guardião), vitória 3.
O guardião é a sala 5 (`miniboss_depth_min/max = 5`), a sala onde 7 de 22 mortes reais acontecem.

## Custos
| Item | Custo | Moeda |
|---|---|---|
| Dons do Guerreiro (18 além do Quarto Corte, grátis) | 1 a 5 cada, soma **54**; os do nível 2 a 5: Ímpeto 2, Corte Crescente 3, Lâmina Faminta 2, Passo Encadeado 2 | Memória |
| Videira, Vida (3 nós, +5 de vida cada) | 5, 10, 20 = 35 | Prata |
| Videira, Provisão (Viajante, Estoque, Reserva) | 5, 10, 20 = 35 | **Memória** |
| Videira, Perseverança (+10% de Prata, de Memória, de materiais) | 5, 10, 20 = 35 | Prata |
| Forja Temperar I, II, III (+20% de dano cada nos dois primeiros) | 15, 35, 60 = 110 | Prata |
| Refinar (6 opções), Inscrever (3) | 25 cada, 20 cada | Prata |
| Despertar (3) | 2, 3, 4 | Esmeralda |
| Obras: Altar 40 e 4 Memória, Fonte 30 e 3, Banca 50 e 1 Esmeralda; Restaurar 20 Prata; encomenda 30 Prata e 2 Pedra | | |
| Troca do Vendedor | 10 Prata por 1 Memória; 2 Memória por 5 Prata; 40 Prata por 1 Esmeralda | |
| Discernimento I e II | 8 e 12 | Memória |
| **Total Prata** (Videira 70, Forja 110 mais Refinar 150 e Inscrever 60, Obras 120) | cerca de **510** | |
| **Total Memória** (Dons 54, Provisão 35, Obras 7, Discernimento 20) | cerca de **116** | |

## Descidas até o primeiro item (criança que morre nas salas 5 a 8)
Premissa: o que o registro real mostra. Sala 1 a 5 rende 0,7 Prata e 0 Memória; sala 6 a 10 rende 18 e 3,3.
| Primeira compra | Custo | Hoje, criança que morre na sala 5 | Hoje, se passa o guardião | Com as propostas |
|---|---|---|---|---|
| Nó de Vida da Videira (+5 de vida) | 5 Prata | **nunca** (0,7 por descida: cerca de 7 descidas só de elites) | 1 descida | 1 descida |
| Temperar I da Forja (+20% de dano no ataque) | 15 Prata | nunca | 1 descida (18) | 2 descidas |
| Primeiro Dom a abrir (Ímpeto, 2 Memória) | 2 Memória | **nunca** | 1 descida (2 do guardião) | 1 a 2 descidas |
| Provisão, Viajante | 5 Memória | nunca | 2 descidas | 2 descidas |
| Despertar (2 Esmeralda) | 2 Esmeralda | só vencendo | 1 vitória | 1 vitória |
Conclusão observada: **tudo o que a economia vende exige passar do guardião da sala 5, e a criança morre justamente nele**
(7 de 22 mortes reais, 11 de 22 antes da sala 6). O desenho original (`sistemas.md` 1.2 e A5) previa 6 a 18 Prata e 1 a 4
Memória mesmo na derrota; a OF-05 (Prata só da profundidade 4 e Memória só depois do guardião) tirou isso de quem morre cedo.

## Achados (priorizados, 10)
1. **P1 A criança que morre até a sala 5 volta de mãos vazias** (observado: 7 de 7 partidas reais com 0,7 Prata e 0 Memória;
   medido: robô parado na sala 6 a 8 traz só 6 Prata e 2 Memória, tudo do guardião). Nada visível em 1 a 2 descidas, a
   promessa do Livro, da Videira e da Forja fica fechada. Proposta: **Prata por sala vencida**, campo novo `silver_room` no
   `StageDef` (1 de Prata por sala de luta limpa, soma 4 a 5 na sala 5 e cerca de 12 no guardião), e `silver_elite` 1 para 2.
   Dono: gameplay-engineer (10 linhas em `Rooms._room_cleared`) mais `make_data.gd` (`st.silver_room = 1`). Efeito: Vida 1 em
   uma descida de 5 salas, Temperar I em 3 (hoje nunca). Medir: mesma régua, `materials.total.silver` na derrota p50 de 5 a 15.
2. **P1 Memória só existe depois do guardião**, e o primeiro Dom (Ímpeto, 2) só vem de matar o guardião. Proposta: **1 Memória ao
   entrar na sala do guardião** (campo novo `memory_guardian_reach` 1, ou, sem código, `st.memory_trial 2 para 3` e
   `st.trial_depth_min 2 para 1`) mais `memory_after_guardian` continuar `true`. Efeito: quem chega ao guardião e morre
   junta 1 por descida, 2 descidas abrem o primeiro Dom. Dono: gameplay-engineer + make_data.
3. **P1 Os 4 primeiros Dons custam o mesmo que dão de Devoção, sem ninguém para pagá-los** (Maestria 2 a 5 chega em 1 a 3
   descidas: 40, 90, 150, 220 de XP; a criança tem 37 de XP por descida; a Memória vem 0). A Maestria cresce e os Dons ficam
   fechados, o contrário do que o PO quer ("o herói cresce com a Maestria, os Dons"). Proposta em `_talent`: `memory_cost`
   `= 1` para os Dons de `unlock` 2 a 5 (Ímpeto, Corte Crescente, Lâmina Faminta, Passo Encadeado); o resto como está
   (soma de 54 para 49, e os primeiros 4 custam 4 em vez de 9). Dono: make_data (uma linha) + teste `test_rejogabilidade`
   se checar o custo.
4. **P1 O desequilíbrio entre os dois materiais**: ganho 5 Prata para cada Memória (robô 28 e 5,3; real 37 e 6), custo 4,4
   Prata para cada Memória (510 e 116). A Memória é o gargalo, a Prata sobra. Hoje o Vendedor troca 10 Prata por 1
   Memória, taxa de 1 para 10 contra o ganho de 5 para 1. Proposta: `OficiosDef.trades` 10 Prata por 1 Memória para **5 Prata por
   1 Memória**; manter 2 Memória por 5 Prata (agora uma troca ruim de propósito) e 40 Prata por 1 Esmeralda (ok). Dono:
   make_data `_oficios`.
5. **P2 Provisão da Videira (35 Memória) é o item mais caro da economia para o que dá** (Viajante, Estoque e Reserva só mexem
   na loja) e compete com os Dons. Proposta: custos 5, 10, 20 para **3, 6, 10** (19) na linha de Provisão (`_vine`, o
   `costs` vira por ramo). Medir: descidas até o Viajante cai de 3 para 2 no robô de 5 Memória por descida.
6. **P2 Perseverança não vende nada ao comprar**: +10% de 6 Prata é 0,6 e +10% de 1,2 Memória é 0,12 por descida; o jogador
   que paga 5, 10 e 20 de Prata nunca nota. Proposta: `silver_pct`, `memory_pct`, `material_pct` de 0,1 para **0,25** (o
   `carry` de `MaterialPurse.bonus` já guarda a fração). Efeito esperado: +1,5 Prata ou +0,3 Memória por descida de criança,
   +7 Prata ou +1,3 Memória por vitória.
7. **P2 O robô quase nunca pega a porta de material** (1 de 15 descidas), e o humano também pouco (20 Prata de porta em 31
   partidas): a porta de 10 Prata ou de 3 Memória compete com Bênção, romã e coração e perde. É certo que perca para a
   descida difícil. Mas hoje o baralho tem 16 a 21 cartas com uma Prata e uma Memória. Proposta: não mexer no baralho; deixar
   a porta como a escolha de "força agora ou casa depois" e dar o consolo no achado 1. Rever depois do teste do Daniel.
8. **P2 Forja Temperar I, II e III dão +20%, +20%, +10% de dano** (o relatório fala de 10%; o dado é 0,2), e a Forja sozinha
   levou a Maestria 1 de 48% para 71% de vitória no `balance.md`. A criança comprando Temperar I com 15 Prata pelo achado 1
   perde a "primeira descida muito difícil". Proposta: com o achado 1 no ar, **Temperar I de 15 para 20 Prata** e II de 35
   para 45, para que o primeiro dano de Forja chegue na 3ª ou 4ª descida de quem passa do guardião, não na 2ª. Re-medir a
   régua M1 sem Forja e com Forja I depois do achado 1.
9. **P2 Esmeralda é 0,2 por partida real** (0,5 no robô): só vem de Morvath fase 3, da vitória e do recorde de Peso. Despertar
   2, 3 e 4, Banca 1: o primeiro Despertar precisa de 1 vitória. Está no ponto, **não mexer**; o trabalho é de Juramentos. A
   troca de 40 Prata por 1 Esmeralda dá a quem não vence um caminho: com o achado 1 (Prata 12 por descida de sala 5) são 3 a 4
   descidas por Esmeralda, o que é bom.
10. **Quickwin**: as moedas gastas e a promessa. Dizer no fim de uma descida sem material (0 Prata, 0 Memória) o que a próxima
    sala trará ("Chegue ao guardião para trazer Memória") em vez de deixar vazio. Texto em `data/text_pt.tres`, dono
    ui-ux-designer; sem número.

(Ficaram 10 achados. O 11 e o 12 ficam para depois do teste do Daniel: Maga e Cavaleiro compartilham a Videira e a
Prata mas têm Dons próprios (58 Memória no total para a Maga), então a Memória por descida precisa cobrir dois heróis;
e o `RESULT.materials` por herói para acompanhar.)

## Resumo dos números para o `make_data.gd`
| Onde | Antes | Depois |
|---|---|---|
| `StageDef` `silver_room` (novo) | 0 | 1 |
| `st.silver_elite` | 1 | 2 |
| `st.memory_trial` | 2 | 3 (ou `memory_guardian_reach` 1, novo) |
| `_talent`, Dons de `unlock` 2 a 5 | `memory_cost = cost` | `1` |
| `OficiosDef.trades` Prata por Memória | 10 | 5 |
| `_vine` Provisão `costs` | 5, 10, 20 | 3, 6, 10 |
| `_vine` Perseverança `silver_pct`, `memory_pct`, `material_pct` | 0,1 | 0,25 |
| `_forge` Temperar I e II | 15, 35 | 20, 45 |

Para o Daniel: o que ele quer da primeira descida difícil não muda (nada acima mexe na vida nem no dano); o que muda é que a
morte na sala 5 deixa de custar tudo. Depois da próxima versão: rodar a régua de 15 sementes, ver `materials.total` na
derrota p50 (alvo 6 a 15 Prata e 1 Memória), e pedir 5 partidas do Daniel para ler o registro com `runs_report.py`
("Memória, Prata e ouro").
