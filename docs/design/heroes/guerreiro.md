# O Guerreiro nos 5 botões + Espaço

> **ESTADO ATUAL (kit novo, aprovado pelo Daniel em 2026-11-21, Lote 1; ver `guerreiro_revisao.md` seção 6)**. As seções 2 a 4
> abaixo são o histórico da proposta; vale esta tabela:
>
> | Botão | Faz | Números | Dado / código |
> |---|---|---|---|
> | **Esquerdo** | combo de 3 (20, 25, giro 60); segurar é o Ômega do ataque (Lança de Luz 160, 20 de Magia) | igual | `cut1..3`, `lance` |
> | **Direito (toque)** | rajada da espada: onda que atravessa os inimigos | 60 de dano, 6 m, **8 de Magia**, 0,5 s entre disparos; sem Magia não sai (aviso "Sem Magia"); **segurar saiu** (sem Ômega do especial) | `bolt` (`magick_cost`, `effect_power`, `effect_radius`); `Player._press_special`, sinal `magick_refused` |
> | **Q** | **Brado de Guerra** (era do E) | 15 de dano em 4 m, empurra 1,5 m (`knockback` 10,5), **sem atordoar**; buff de 5 s: +20% de velocidade de golpe, +1 carga de Fúria (só com o Dom Ímpeto), -15% de dano recebido; recarga 12 s | `shout` (`Effect.SHOUT`, `buff_speed`, `buff_guard`, `effect_time`); `GiftState.rally`, `Player.hurt` |
> | **E** | **Investida** (era o Corte Veloz da esquiva) | estocada de 35 em linha de 4 m que leva o corpo (`lunge` 4), recarga 5 s, **+3 de Magia por inimigo atingido** (`magick_per_hit`), finalizador da passiva como antes (tag `dash`) | `dash_cut` com `ComboNode.In.RUSH`, ação `rush` |
> | **Shift** | ultimate | 90 / 105 de Magia, igual | |
> | **Espaço** | só esquiva (5,6 m, 1,1 s); **atacar na esquiva não vira mais Corte Veloz** | `tree.dodge` vazio, `dodge_window` 0 | |
>
> **Círculo de Luz** saiu do Guerreiro (`HeroDef.circle = false`; código e dado ficam para o Paladino; sem tecla; `Psalms.circle` desliga o
> Salmo da Sentinela). **Bênçãos do slot `CAST`** valem para o Brado (tag `cast` no `shout`): Brado em Brasa (queima), de Geada (congela),
> Radiante (+dano; o dano por segundo do círculo saiu), Firme (+alcance; ainda aumenta a Voragem). **Dons**: Passo Encadeado, Estocada
> Certeira (a antiga Investida, devolve a esquiva), Fio do Passo, Retorno do Corte e Eco do Passo agora seguem a Investida (tag `dash`);
> Onda Carregada (ponte) solta a onda do giro **na rajada** (tag `heavy`, antes do Ômega do especial). Controles: **Q** Brado (RB), **E**
> Investida (R3), Shift ultimate, F interagir. Robô: rajada com Magia, Brado com 3+ perto, Investida para entrar (3,5 a 8 m) e para Magia.
> Testes: `tests/test_shout.gd`, `tests/test_warrior_kit.gd`.
>
> **Antes (2026-11-21, tarde)**: Shift = ultimate, F = interagir, E = Brado (atordoava comuns 0,5 s, recarga 14 s depois do ajuste de recargas).
> Ainda não: slots `TECH`/`ULT`, as Bênçãos por família do E e do Shift, os Dons do Brado.

- **Data**: 2026-11-21. **Autor**: `hero-designer`. **Base**: `docs/design/warrior_spec.md` (aprovada), `docs/reference/meta.md` e `gameplay.md`.
- **Não muda** (aprovado pelo Daniel): guerreiro ofensivo de espada (a Emeth), sem bloqueio nem aparo, golpe parado, Fúria em cargas sem barra,
  especial como onda, símbolo do leão, nome do jogo "O Guerreiro" (D-64 a D-71), primeiro Salmo o da Sentinela.
- **Regra dos botões**: ver `README.md`; cada herói distribui as 5 ativas como a fantasia pede.

## 1. Fantasia, papel, arma

- **Em uma frase**: toma a iniciativa, corre até o grupo, planta os pés e o abre com combos, e sai pela esquiva só para entrar de novo.
- **Papel**: corpo a corpo ofensivo, pressão contínua, controla pelo ritmo e não pelo escudo. **Distância**: curta (golpes de 3 m; o giro, 60 em volta).
- **Arma**: Emeth (espada), sem troca. **Silhueta**: cabelo vermelho, manto azul-petróleo, leão como símbolo.
- **Ritmo**: constante. Três golpes (rápido, mais lento, giro pesado), esquiva para dentro, Ômega grande em janela, volta ao começo.

## 2. O que existe hoje e onde cai nos botões

| Botão | Hoje no jogo | Fica como | Tags e Bênção (slot) |
|---|---|---|---|
| **Esquerdo** | Ataque em 3: 20, 25, giro 60 (tempos do Hades II; golpe parado, 5 m de mira) | **Ataque**: combo | `light`, `finisher` (giro); slot `ATTACK` |
| **Direito** | Especial: onda esmeralda 40 (W-1); segurar 0,65 s é Ômega 80 (10 de Magia); segurar o ataque 0,8 s é Ômega do ataque 160 (20 de Magia) | **Especial**: onda de alcance | `heavy`, `cast`?, `omega`; slot `SPECIAL` |
| **Q** | Círculo de luz: 5,4 m, prende 3 s, um por vez (`cast`, Q e Shift) | **Poder**: prender para golpear | `cast`; slot `CAST` |
| **E** | interagir (hub, recompensa, porta, loja) | **Falta** (seção 4.1); interagir vai para F | slot novo |
| **Shift** | segundo atalho do `cast` | **Ultimate** (seção 4.2) | slot novo |
| **R** (hoje) | ultimate (U-1 Corte do Juízo, U-2 Voragem; `UltCharge`) | sai do R | |
| **Espaço** | esquiva 5,6 m, 19 quadros protegidos, 1 carga (0,74 s), golpe na esquiva vira **Corte Veloz** 30 (estocada que leva o corpo) | **Travessia** | `dash`; slot `DASH` |

**Passiva**: cada finalizador (giro, Corte Veloz que acerta, Ômega) que acerta devolve 2 de Magia (D-56, nome pendente: Ímpeto da Emeth / Fio que Responde).
**Recurso próprio**: Fúria em cargas (Dom Ímpeto: cada abate dá uma carga até 3, somem em 3 s sem abate, +6% de velocidade de golpe por carga), sem barra nova.
**Magia** (50) existe e paga os Ômegas. **Salmo da Sentinela** (transforma a esquiva, `PsalmPlay`): esquivar através de um aviso deixa o próximo Ômega sem custo e o Corte Veloz seguinte é finalizador.

## 3. As 5 habilidades e a travessia (estado final proposto)

### 3.1 Esquerdo, Ataque (existe)
Combo 1 < 2 < 3 com giro final. Já definido no `combat_cadence.md` e `warrior_spec.md` 2.2 (preparação, impacto, retorno por golpe). Cancela: esquiva, ultimate; o Brado corta o fim da recuperação.
Lê na tela: o corte gira no chão, o giro final mostra o arco inteiro, número esmeralda de finalizador.

### 3.2 Direito, Especial (existe)
Onda esmeralda curta saindo do corte, 40; pernas presas 0,71 s (só a esquiva corta); segurar vira Ômega do especial. Sem mudança. O Dom Corte Crescente dá onda ao giro.

### 3.3 Q, Poder (existe): Círculo de Luz
Mantém: o círculo prende para golpear (texto "prender para golpear"). Recarga e custo de hoje (5,4 m, 3 s). **Alternativa para o Q** (se o Daniel achar o círculo defensivo demais):
- **(a) Manter o Círculo de Luz**. Zero código, os Dons de círculo ficam fora do catálogo inicial. *Recomendo*: já aprovado, serve ao combo (quem está preso acerta o giro).
- **(b) Trocar por Salto da Emeth**: um salto curto (4 m) que cai com dano em área 30 e deixa o chão marcado (`Ground.Kind.MARK`); reforça "entrar". Pede animação e movimento de ataque (M) e quebra "só a esquiva leva o corpo" (decisão E1c).

### 3.4 E, a habilidade que falta: **Brado** (proposta) e alternativas
Regras gerais: sem bloqueio, sem aparo, sem esperar golpe; o Guerreiro **entra**. Recarga 10 s, janela de preparação 0,25 s, impacto no 0,10 s, recuperação 0,25 s (valores para o `combat-feel-director`), pés plantados como todo golpe, esquiva corta.

| | **A: Brado de Guerra** (recomendado) | **B: Investida do Leão** | C (reserva): Lâmina Lançada |
|---|---|---|---|
| O que faz | grito curto em volta (4 m): atordoa os comuns 0,5 s (guardiões, só empurra), dá 1 carga de Fúria por inimigo atingido (até 2), 15 de dano | corrida de 6 m com a espada à frente que empurra o grupo e acerta 25 em tudo na linha; termina com um golpe de giro curto | arremessa a Emeth em linha de 8 m: 35 em quem atravessa e volta |
| Papel | abre sala cheia e liga a Fúria sem esperar abate; dá o 1º golpe de graça | travessia ofensiva: agrupa e entra | alcance contra atiradores |
| Por que combina | reforça a fantasia de iniciativa, não defende, vira o gatilho do combo | chega no atirador | só alcance |
| Risco | forte demais se as cargas valerem muito (o Ímpeto vira infinito); atordoar chefe | lembra a esquiva e a quebra a regra "pés plantados" (E1c) | arma sumindo some a fantasia da arma única |
| Reuso | `ComboNode` (`Shape.CIRCLE`, `Effect.STUN`), `GiftState` das cargas de Ímpeto | `Effect.LAUNCH`, `Shape.LINE` | `Projectiles` |
| Código | **P a M**: cargas por acerto de habilidade (hoje só por abate), slot `TECH` | M: o corpo anda no golpe | M a G |

**Recomendação: A, Brado de Guerra.** Número de partida: recarga 10 s; **cargas só por inimigo comum atingido, no máximo 2 por Brado** (travado em teste), e **nunca** em chefe.

### 3.5 Shift, **Ultimate** (existe, muda de botão) e alternativa
Hoje `ultimate` no R. U-1 Corte do Juízo (faixa 12 x 4 m, 300 e 200) ou U-2 Voragem (6 m, 4 s, implosão 120); gesto de 0,3 s protegido; carga por Magia gasta, dano causado (0,02 por ponto) e vida perdida; destrava Maestria 2 e 6.
- **(a) Shift** *(recomendo)*: o dedo já fica perto do WASD, o R libera `menu_reroll`; custo **P** (mudança de ação e de texto, HUD).
- **(b) Ultimate no E e Brado no Shift**: o Brado é frequente (10 s) e o Shift é fácil de apertar; a ultimate no E. Custo igual, mas o Shift é um botão de "esquiva extra" em muitos jogos. Não recomendo.

### 3.6 Espaço, Travessia (existe)
Esquiva 5,6 m, 19 quadros protegidos, 1 carga, ataque na esquiva vira **Corte Veloz** (estocada 30, finalizador se acerta). É o "esquivar para dentro". Sem mudança. O Salmo da Sentinela transforma esta ação.

## 4. Como cada Bênção muda cada botão

| Família | Esquerdo | Direito | Q (círculo) | E (Brado) | Shift (ultimate) | Espaço |
|---|---|---|---|---|---|---|
| **Chama** | golpes queimam (`golpe_brasa`) | onda que deixa brasas (`brasas`) | círculo queima quem fica (`circulo_brasa`) | o grito deixa brasas em volta | o corte deixa chão em chamas | rastro de fogo (`passo_brasa`) |
| **Geada** | golpes gelam (`golpe_geada`) | onda lenta e gelada | círculo gela (`circulo_geada`) | o Brado gela por 1 s em vez de atordoar | a Voragem congela no fim | o Corte Veloz congela o ponto (`passo_geada`) |
| **Luz** | giro radiante (`golpe_radiante`) | onda mais larga (`onda_maior`) | círculo cura 1 por abate dentro | o Brado dá +1 carga de Fúria | ult +25% de carga | passos sem custo (`passos`) |
| **Vigília** | `golpe_firme`: golpes reduzem dano recebido | onda atordoa comuns | círculo dá 10% de proteção a quem está dentro | o Brado dá 1,3 s de proteção ao acertar 3 | ult dá 3 s de proteção | esquiva dá +0,3 s protegido (`passo_firme`) |

Os nomes são Bênçãos existentes em `data/boons/`; as colunas E e Shift são **texto novo** de Bênção (efeito por estatística `BoonState.stat` com tag da ação; só o slot `TECH`/`ULT` pede código).

## 5. Dons (árvore, já feita) e o que muda com o E

Árvore atual: Combo, Fúria, Emeth, Magia (19 Dons em `data/talents/warrior/`). **Dons novos para o Brado** (cada um troca ou reforça, um por botão):
- Entrada de Fúria, **Brado Longo**: +1 m de raio e +1 carga de Fúria.
- Meio de Fúria, **Arranque**: com 3 cargas, o Brado não gasta recarga uma vez por sala.
- Ponte Combo e Fúria, **Brado Aberto**: o Brado conta como o 1º golpe do combo (o próximo ataque é o 2º, como Passo Encadeado).

## 6. Três combinações só dele
1. **Brado, giro, Ômega**: o Brado dá 2 cargas, o giro com 3 cargas atordoa (Fúria Plena) e o Ômega pago pela passiva fecha o grupo.
2. **Círculo, Brado dentro, giro**: o círculo prende, o Brado dá cargas sem perder o grupo, o giro finaliza todos de uma vez.
3. **Esquiva na Sentinela, Corte Veloz finalizador, Ômega sem custo**: atravessa um aviso, o Corte Veloz conta como finalizador e o Ômega sai de graça.

## 7. Riscos
- **Cargas de Fúria infinitas** via Brado: limite de 2 por uso e só em comuns; medir com o `balance-designer` (carga média por sala).
- **Brado atordoa tudo**: o atordoamento de 0,5 s e a recarga de 10 s limitam; guardiões e chefes só empurram.
- **Perda de identidade**: o Brado não pode virar defesa (sem proteção no padrão; só a Bênção de Vigília dá).
- **Shift errado**: aperto de hábito sem carga só diz "Falta carga".

## 8. Código novo
| Item | Estimativa |
|---|---|
| Mapa de botões, E e Shift no `Controls` e `HeroDef.buttons`; interagir no F | P |
| Slots `TECH` e `ULT` em `Boon.Slot` e textos de Bênção | P |
| Brado: golpe de dado (`CIRCLE`, `STUN`), carga por acerto de habilidade (hoje só por abate) | P a M |
| HUD: 5 losangos na ordem esquerdo, direito, Q, E, Shift + Espaço | P |
| Dons do Brado (3 em `make_data.gd`) | P |
| **Total** | **P a M** |

## 9. Perguntas ao Daniel
1. Brado de Guerra como o E (recomendado) ou Investida do Leão?
2. Manter o Círculo de Luz no Q (recomendado) ou Salto da Emeth?
3. O nome "Brado" é aceito? (não usa nome de Elun.)
