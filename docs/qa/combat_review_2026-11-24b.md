# Revisão de combate, build 1342184 (2026-11-24, segunda passada)

Fontes: sonda `tools/feel_probe_run.gd --fixed-fps 60 -- --nosave --start=fountain` (headless, **42/42 ok**; sem as opções ela dá 16/42, não é regressão),
leitura de `combat.gd`, `make_data.gd`, e duas partidas do robô (`tools/smoke.sh 600 --seed=5`, Guerreiro e `--hero=maga`). Sem GPU, nada implementado.
"Confirmado" = visto no código ou na sonda; "Hipótese" = falta captura ou robô com mais sementes.

## Estado dos itens da revisão anterior (`combat_review_2026-11-24.md`)
| # | Item | Estado | Evidência |
|---|------|--------|-----------|
| 1 | Hit stop do golpe 2 | **FEITO** (confirmado) | `HIT_SLOW_COOLDOWN` 0,15 (`combat.gd:31`); GF-01e passou a exigir golpe 2 com hit stop próprio e intervalo mínimo de 9 quadros; 42/42 |
| 2 | Hit stop e tranco em projétil | **FEITO** (confirmado no código; sem captura) | `SHOT_STOP_MS` 25, `SHOT_KICK` 0,6, `Shot.stop_ms` (`combat.gd:34-36, 382, 598`), só para `heavy` (especial, Explosão); tiros leves da Maga ficam em 0 |
| 3 | Terceiro tiro da Maga | **PARCIAL** | `shot3.glint = 0,12` feito (`make_data.gd:2117`); o 3º ainda usa o som `dart` herdado de `shot.merged` (l.2109/2114): **o som próprio não existe**. Recuo da mão e dardo maior: só em captura |
| 4 | `bang_lead` | **FEITO** 0,45 (`make_data.gd:1850`); efeito no robô R 0,6 não medido |
| 5 | Esquiva 1 carga / 0,8 s | **ABERTO** (sem instrumentação no RunLog; `make_data.gd:2065` igual) |
| 6 | 2º avanço do Cavaleiro 0,45 | **FEITO** 0,55 (`recharge_windup`, `make_data.gd:401`); mortes na 2ª investida não medidas |
| 7 | Teste da regra "ninguém é interrompido" (GF-12) | **FEITO** (a sonda está verde; GF-12 agora passa) |
| 8 | Disco do Armadilheiro | **ABERTO** (sem mudança; nas duas partidas `trap` deu 60 e 180 de dano a inimigos, 0 ao herói: baixo risco) |
| 9 | Alvos velhos da sonda | **FEITO** (42/42) |
| 10 | Capturas com 30/30 | **ABERTO** até o Lote F recapturar; o HUD já lê 40 |
| 11 | Maga 30 vida vs Guerreiro 40 | **ABERTO** (ver N2) |

## Novos achados
### P1
- **N1. Robô da Maga fica 298 s (de 594 s) na sala 5 (Anciã), 290 s "nas paredes" (confirmado no RESULT, 1 semente; hipótese de que seja só o robô).**
  `elder_hall`: `zones.walls 289.8`, `dodges 81`, 134 flechas do arqueiro com 58 bloqueadas por coluna, só 2 acertos; a partida acabou no limite de 600 s na sala 11
  sem chegar ao chefe. O Guerreiro (mesma semente) passou a sala 5 em 60 s com 5 de dano. Duas leituras: (a) o robô da Maga não sabe fechar distância e fica
  fugindo (então só afeta medição, e os números de equilíbrio da Maga estão contaminados); (b) a Maga real tem dificuldade de acertar a Anciã em salão de
  colunas (arqueiros cobrem). Como as crianças morreram na sala 5, vale testar (b) com `--hero=maga` e 12 sementes só nesta sala (`--start`) antes de mexer.
  Dono: `balance-designer` mede; `gameplay-engineer` se for o robô (`scripts/game/bot.gd`).
- **N2. Sala 5 é onde o dano chega mesmo com os ajustes (hipótese forte).** Guerreiro: `hurt_by priest_elder 5`; Maga: arqueiro 10 de 30 de vida. A sala dura 60 a 300 s,
  muito mais que as vizinhas (18 a 40 s). Tempo longo com 2 a 3 arqueiros e a Anciã é o que mata criança, não o dano por golpe. Reduzir o tempo (menos escudo da Anciã
  ou arqueiros que expõem a vez) vale mais que cortar dano. Dono: `balance-designer`.

### P2
- **N3. Contador de som do `ult_ready`:** `audio.gd:32` existe e o gatilho aparece em `bot.gd` e `ultimates.gd`, mas não há teste de que toque uma vez só ao encher (a ultimate
  caiu para 75, `make_data.gd:1954`, enche mais depressa e pode repetir). Pedir teste simples de "uma vez por enchimento". Dono: `gameplay-engineer`.
- **N4. Dois hit stops a 9 quadros (0,15 s) no mesmo golpe giratório** (GF-01e passa, mas só valida a corrente de 3). Sem evidência de problema; olhar na captura do giro.
- **N5. A sonda sem opções dá 16/42** e parece regressão a quem a roda. Escrever as opções no topo de `tools/feel_probe.gd` ou falhar cedo (dono: `gameplay-engineer`, quickwin).

## Capturas pedidas (só sessão principal)
`tools/gpu.sh shot cadence_maga3.png --bot --hero=maga --shot-at=9 --look=stylized --cam=near` (3 tiros e a Explosão), e uma do especial do Guerreiro acertando
(`--bot --shot-at=9`), para o art-director ver o tranco de 25 ms e o brilho do 3º tiro.

## Resumo
P0: nenhum. P1: N1 e N2 (sala 5). Critério de aceite: robô da Maga conclui a sala 5 em menos de 90 s em 10 de 12 sementes; sonda segue 42/42.
