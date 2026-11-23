# Salas do capítulo 1 em 14 (C2, CB-5): proposta

Estado: só proposta, nada implementado. Salas: 1 a 4 luta, 5 minichefe, 6 a 9 luta, 10 minichefe, 11 e 12 luta, 13 loja, 14 Morvath.
`EncounterGen.progress = (profundidade-1)/(rooms-2)` com `rooms=13`: salas 1,2,3,4 = 0, .09, .18, .27; 6,7,8,9 = .45, .55, .64, .73; 11,12 = .91, 1.0.
Papéis: pressure esqueleto, react corredor (explode), control mago, flank besteiro (2 flechas), block guarda (Escudo), area sacerdote (blinda vizinhos).

## 1. Pools (substituem `st.pools`; trechos A = 0 a .30, B = .30 a .60, C = .60 a .80, D = .80 a 1.0)
Um inimigo novo por vez no trecho A, cortado por `until` (as faixas não se tocam, então a sala 1 só tem esqueleto):
- Sala 1 (0): só esqueleto, para aprender o golpe. Sala 2 (.09): esqueleto e corredor. Sala 3 (.18): esqueleto e besteiro. Sala 4 (.27): guarda e esqueleto.
- Faixas: sala 1 = 0 a .05; 2 = .05 a .13; 3 = .13 a .22; 4 = .22 a .30. A sala 6 (.45) apresenta o mago e a 8 (.64) o sacerdote, sempre com um papel já conhecido.
```
		_pool(Tier.COMMON, 0.0, 0.05, 1.0, [&"pressure"]),
		_pool(Tier.COMMON, 0.05, 0.13, 1.0, [&"pressure", &"react"]),
		_pool(Tier.COMMON, 0.13, 0.22, 1.0, [&"pressure", &"flank"]),
		_pool(Tier.COMMON, 0.22, 0.30, 1.0, [&"block", &"pressure"]),
		_pool(Tier.COMMON, 0.30, 0.60, 3.0, [&"block", &"pressure", &"control"]),
		_pool(Tier.COMMON, 0.30, 0.60, 2.0, [&"react", &"flank", &"pressure"]),
		_pool(Tier.COMMON, 0.40, 0.60, 2.0, [&"block", &"flank"]),
		_pool(Tier.HARD, 0.40, 0.60, 1.0, [&"pressure", &"react", &"control"], 0.5),
		_pool(Tier.COMMON, 0.60, 0.80, 2.0, [&"block", &"area", &"pressure"]),
		_pool(Tier.HARD, 0.60, 0.80, 3.0, [&"block", &"flank", &"control"], 0.5),
		_pool(Tier.HARD, 0.60, 0.80, 2.0, [&"react", &"area", &"flank"], 0.5),
		_pool(Tier.HARD, 0.80, 1.0, 3.0, [&"block", &"area", &"control"], 0.7),
		_pool(Tier.HARD, 0.80, 1.0, 3.0, [&"react", &"flank", &"area", &"pressure"], 0.7),
		_pool(Tier.SPECIAL, 0.80, 1.0, 1.0, [&"block", &"area", &"control", &"flank"], 0.7),
```
Por que obrigam a escolher: guarda com mago (o mago atira atrás do Escudo, e o Escudo só cai de lado ou pelas costas); guarda com sacerdote (matar o sacerdote primeiro, ou contornar o guarda blindado); corredor com sacerdote (a explosão fere o aliado, mas o blindado resiste); besteiro com corredor (esquivar da explosão e das 2 flechas ao mesmo tempo).

## 2. Elites (`elite_from_depth = 3` mantém; `max_elite_types` fica como está)
Trecho A: nenhum (chance 0). B: 0.5 só nos pools HARD, no máximo 1 tipo. C: 0.5 e D: 0.7, com 1 a 2 tipos (usar `max_elite_types = 2` só no D se o teste de cobertura pedir). Elite de guarda e de sacerdote só do trecho C em diante (o jogador já viu o papel). Silver_elite continua 1 por elite.

## 3. Vivos ao mesmo tempo (`tier_alive`, teto 20 intacto)
`cap = lerp(min, max, progress)` por tier: COMMON (3,6) em vez de (4,8): sala 1 com 3, sala 12 com 6; HARD (7,11); SPECIAL (11,15). Trecho A nunca passa de 4 vivos (sala 1 a 3 esqueletos, em ondas de 2 mais 1). Ondas que se sobrepõem só do trecho C em diante (`wave_remaining` 2 em vez de 1), com ceiling 20 sempre conferido por `room_for`. Dificuldade: manter `base_difficulty 70`, `depth_ramp` de 13 para 11 (sala 12 = 191, hoje 226) porque o herói é fraco e a sala 12 já é cheia de elite; ajustar em 1 rodada de robô.

## 4. Economia (3 salas de luta a mais e 2 guardiões)
- Ouro: `gold_cap` 10 a 15 mais 0.5 por profundidade já dá cerca de 11 a 21 por luta, 10 lutas, cerca de 160 no total, só 1 Bênção na loja (150). Proposta: `gold_per_depth` 0.8 (cerca de 190), `gold_reward` 100 fica, e o deck ganha 1 R.GOLD (3 no total). Com 2 portas de ouro, um jogador que cata tudo chega à loja com cerca de 400: 2 Bênçãos ou 1 Bênção e coração.
- Preços da loja: Bênção 150, cura 50, coração 125, tônico e romã 100, fatia 50, Encanto 200 ficam (referência Hades II). Só `altar_gold_cost` fica 75.
- Deck de portas (21 cartas, 12 portas de escolha em 14 salas, menos guardiões e loja): sobem para 23 com 1 R.GOLD e 1 R.HEART (vida mais barata para o herói fraco); R.MEMORY e R.SILVER ficam 1 (raras).
- Prata: `silver_door` 10, `silver_elite` 1, `silver_guardian` 6 e agora são 2 guardiões, logo 12 por descida; Morvath e vitória iguais. Ganho médio por descida sobe cerca de 15 a 20, ok porque a descida é mais longa.
- Memória: `memory_door` 3, `memory_guardian` 2 (2 guardiões = 4), `memory_trial` 2, `memory_victory` 3: sem mudança; o ganho sobe sozinho com os guardiões.

## 5. Tempo de partida
Hoje o robô evoluído faz 430 s em 10 salas, ou seja, cerca de 43 s por sala. Com 14 salas e Morvath: alvo do robô 600 a 660 s (10 a 11 min), humano 12 a 15 min. Orçamento: salas A 25 a 35 s, B 40 s, C 50 s, D 55 s, minichefes 60 s cada, loja 20 s, Morvath 120 s. Como medir: `tools/smoke.sh 900 --seed=N --bot-reaction=0.25` em 12 sementes, ler `rooms[].time`; se passar de 700 s cortar `depth_ramp` ou 1 onda das salas C e D, se ficar abaixo de 560 s subir `tier_alive` do COMMON em 1.
Riscos: pool de 1 papel depende de `pick_kinds` aceitar lista de 1 (confirmar no teste); sala 6 e 8 apresentam mago e sacerdote só por sorteio (se quiser garantir, `_pool` com faixa estreita 0.42 a 0.50 e 0.60 a 0.66 como nos trechos A).
