# T5, P0: "a ultimate não funciona"

Relato do PO jogando o exe de Windows (teclado e mouse, save real). Investigação da cadeia inteira das duas ultimates
(Corte do Juízo, Voragem), causas, números e decisão.

## O que foi conferido

| Elo da cadeia | Resultado |
| --- | --- |
| Ação `ultimate` (R, LB) no mapa de entrada | Funciona. `Controls.apply_bindings` monta o InputMap em tempo de execução, igual no export. Teste com a tecla R de verdade (`Input.parse_input_event`) solta a ultimate no quadro seguinte. Sem remapeamento salvo no save do PO. |
| Estado `Player.ULT`, efeitos em `ultimates.gd`, som | Funcionam (18 testes de `test_ultimate.gd`; o robô solta 5 por descida desde a E2). |
| Destrave pela Maestria e escolha na tela do herói | Funcionam, mas **um save que chega à Maestria 2 sem abrir a tela do herói desce sem ultimate**: `Game._equip_talents` só lia `heroes.warrior.ultimate`, que começa vazio. |
| Carga (`UltCharge`) | **Só pela Magia gasta em Ômegas.** O registro do PO (`runs.jsonl`, partidas de gente com o campo `ult`): 19:05, morte na sala 5, 0 Ômegas, carga 0; 19:16, vitória em 537 s, 5 Ômegas, carga chegou a 60 e **nunca foi usada**; 19:18, 0 Ômegas, carga 0. As partidas anteriores (sem o campo) têm de 0 a 9 Ômegas. |
| HUD (5º losango) | **Escondido sem ultimate** (nenhuma pista de que ela existe nem de quando abre); carregando, igual a uma recarga comum; **cheio, igual a qualquer ação parada** (sem sinal de "pronta"); apertar R sem carga não fazia nada nem dizia nada. |

## Causas confirmadas

1. **Carga quase nunca enche para quem não segura Ômegas.** O PO usa poucos Ômegas (0 a 9 por partida); em duas das três
   partidas com ultimate a carga ficou em 0. Para ele, R "não faz nada".
2. **Nenhum retorno**: apertar R sem carga era silencioso; o losango cheio não se distinguia de uma ação parada (na vitória
   a carga encheu e ele não percebeu). Sem ultimate, o losango nem aparecia.
3. **Maestria 2 sem escolha = sem ultimate** (save novo que sobe de nível e nunca abre a tela do herói).

## Decisão

**Carga também por dano causado e por vida perdida**, além da Magia dos Ômegas (que segue valendo 1 por 1):

- `UltDef.damage_charge` 0,02 por ponto de dano que o herói causa (os acertos da própria ultimate não contam);
- `UltDef.hurt_charge` 1,0 por ponto de vida perdida;
- carga cheia continua 60 (Corte do Juízo) e 70 (Voragem); o `ult_charge_pct` do Coração da Emeth acelera tudo.

No Hades II o Hex carrega só por Magia gasta, mas lá o jogador gasta Magia o tempo todo (o Ômega é o centro do kit). Aqui
o Guerreiro ataca por combos e gente usa poucos Ômegas; o dano é o que todo jogador faz. É o caminho do Ravenswatch (a
ultimate carrega com o combate). Números na fonte: `ULT_DAMAGE_CHARGE` e `ULT_HURT_CHARGE` no `_ultimates` do
`tools/make_data.gd`.

Contas com as partidas do PO (regra nova, sem mudar o jeito dele de jogar):

| Partida | Dano causado | Vida perdida | Ômegas | Carga da regra nova | Cortes do Juízo |
| --- | --- | --- | --- | --- | --- |
| 19:05, morte na sala 5 (194 s) | 3918 | 30 | 0 | 78 + 30 = 108 | 1 |
| 19:16, vitória (537 s) | 19531 | 66 | 5 | 391 + 66 + Magia | cerca de 8 (uma por minuto) |

Sem nenhum Ômega, uma sala de luta média (cerca de 1350 de dano, 5 de vida) enche metade de um Corte do Juízo: um a cada
duas salas. A Voragem (70) precisa de 3500 de dano sozinha: nunca uma por sala só de dano.

Robô (`--bot-reaction=0.25 --ultimate=cleave`, 900 s): antes 5 usos por descida (semente 5, só Magia); com a regra nova
(0,02), semente 5: 12 usos, 4 em Morvath (1136 de dano nele, 19% da vida), carga de Magia 389, de dano 341, de vida
perdida 37 (`ult.charged` do `RESULT`). O robô gasta muito mais Magia que gente; para gente a parte do dano é a que importa. O balanceamento da E6 não muda: o
robô sem `--ultimate` não tem ultimate (não lê o save).

## Correções no jogo

- `HeroDef.ult_for(escolhida, nível)`: a escolhida se destravada, senão a primeira que o nível abre. `Game._equip_talents`
  usa e grava a escolha no save; `HeroLoadout.ultimate()` mostra a mesma na tela do herói.
- HUD (`Hud._update_ult`, `ActionSlot.sealed`, `caption`, `pulse`): o 5º losango aparece sempre para gente; antes da
  Maestria 2, trancado com cadeado de ouro velho e "Maestria 2" em cima; cheio, pulsa e diz "Pronta" por 1,8 s;
  apertar R sem poder (`Player.ult_refused`) mostra "Carga N%" (ou "Maestria N") e, na primeira vez da partida, o aviso
  "A ultimate enche com Ômegas e com o dano que você causa e sofre" (ou "A ultimate abre na Maestria N").
- `RESULT` `ult.charged`: quanto da carga veio de Magia, dano e vida perdida.

Testes: `tests/test_t5_ultimate.gd`.
