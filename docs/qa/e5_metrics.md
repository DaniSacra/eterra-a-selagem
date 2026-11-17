# E5, eventos e exploração: métricas e decisões

Medido em 2026-11-17 com `tools/smoke.sh 600 --seed=N --bot-reaction=0.25` (robô com reação humana), descida de 10
salas e Morvath na 11. Saídas completas em `/home/dani/tools/e5/seed_N.txt` (fora do repositório).

| Semente | Resultado | Morvath em (s) | Tempo total (s) | Vida ao chegar | Bênçãos | Laje vista | Provação paga | Maldição virou Bênção | Altar | Arenas novas na descida |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | vitória | 196 | 300 | 30 | 6 | 1 | recusada (vida) | | | santuário, ponte, runas |
| 2 | vitória | 247 | 349 | 50 | 6 | 0 | | | porta vista, não escolhida | santuário, runas, ponte |
| 3 | vitória | 266 | 387 | 30 | 7 | 1 | recusada (vida) | | porta vista, não escolhida | ponte, santuário, runas, santuário |
| 4 | derrota (fase 3) | 276 | 353 | 33 | 8 | 1 | sim | sim | | santuário, runas, ponte, runas |
| 5 | derrota (fase 2) | 251 | 294 | 15 | 7 | 0 | | | porta vista, não escolhida | santuário, ponte, runas, ponte |
| 6 | vitória | 289 | 410 | 55 | 7 | 0 | | | | ponte, santuário, runas |
| 7 | derrota (fase 4) | 246 | 329 | 49 | 5 | 1 | sim | sim | porta vista, não escolhida | ponte, santuário, runas, ponte |
| 8 | vitória | 258 | 356 | 65 | 3 | 1 | recusada (vida) | | | runas, santuário, ponte, ponte |

- Vitórias: 5 de 8. Todas chegaram a Morvath (196 a 289 s).
- Provação: laje em 5 de 8 descidas, paga em 2 (as duas maldições viraram Bênção antes de Morvath), recusada em 3 (o robô só
  paga se sobrar 60% da vida máxima).
- Altar: a porta apareceu em 4 descidas; o robô prefere Bênção e romã (`Rooms.BOT_ALTAR_RANK` 1,5) e não entrou. O uso foi
  conferido com `--start=altar` e em `tests/test_altar.gd`.
- Runas: dano nos inimigos de 35 a 277 por descida; o robô levou 4 de dano das runas em uma descida (seed 3).
- Captura na GPU da Câmara das Runas (faixas âmbar sob os avisos vermelhos): `/home/dani/tools/e5/runes.png`, 53 FPS.

## Decisões (E5-D, tomadas pelo gameplay-engineer sem consulta, autorizadas pelo Game Director)

1. **E5-D1, visual provisório**: `PlainLook` (base do `ArenaRoom` com uma luz de cima) para `sanctuary`, `bridge`, `runes`,
   `trial` e `altar`, sem mexer no `arena_room.gd`. O look do environment-artist entra registrando o id em `ArenaRoom.LOOKS`.
2. **E5-D2, casa do guardião**: o guardião sempre luta no Santuário, em qualquer profundidade, menos quando o Santuário
   foi a sala anterior ou já gastou os usos.
3. **E5-D3, runas ferem todos**: herói 4 por golpe (como aviso), inimigo comum 35. Guardiões e Morvath nunca lutam lá.
4. **E5-D4, padrões densos**: `comb` e `checker` acendem até 50% e só saem com 3 inimigos ou menos de pé. `frame` é aparado
   a 35%.
5. **E5-D5, ponte**: todas as portas ficam na plataforma leste, e ninguém nasce numa ponte.
6. **E5-D6, Provação**:
   - É uma sala ao lado, na mesma profundidade, com as portas da sala de antes. A câmara tem três saídas para não perder a
     escolha de recompensa (a spec pede uma só).
   - As cartas são pedestais no chão até a tela da carta dividida existir.
   - A raridade segue o Caos do Hades II: rara 40% e épica 10%, sorteando primeiro a mais rara, então rara sai 36%.
   - A maldição conta como encontro qualquer luta vencida, guardião incluído.
7. **E5-D7, Altar**:
   - É uma porta por descida, nas profundidades 2 a 8, com 20% de chance.
   - Troca 10 de vida máxima por uma romã ou 75 de ouro por 25 de Magia máxima.
   - Dá para sair sem trocar, e isso fica no registro.
8. **E5-D8, portas**: a luta atrás de cada porta é sorteada quando a porta aparece. A placa diz "Difícil" quando a luta tem
   elite e "Guardião" na porta do guardião. A dificuldade em número ainda não aparece na placa: está no `door_info` para a UI.

## Pendências

- Ponte: "no máximo 5 por plataforma" e "tiros de outra plataforma" ainda não são regras.
- Santuário: "investida parada pela coluna" ainda não é regra.
- O desenho das runas soma (blend_add) onde o âmbar e o vermelho se cruzam. A prioridade de desenho o põe embaixo, mas o
  vermelho não "vence" à risca.
- As telas não foram feitas: carta dividida, selo da maldição no HUD e pictogramas das placas.
