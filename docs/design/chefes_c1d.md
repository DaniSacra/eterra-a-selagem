# C1d: lutas de chefe que usam as seis teclas (2026-11-22, só mecânica, nada de história)

Princípio de SWORN (`sworn_numeros.md`), nunca cópia: cada padrão pede **uma resposta certa**, e a resposta muda de padrão para padrão. Teclas:
ataque (esq.), onda (dir.), Q Brado (aguenta 1 golpe de 4 ou mais, volta em 12 s), E Investida (recarga 5 s), Espaço esquiva (recarga 1,1 s,
18 quadros), Shift ultimate. Regras fixas: golpe comum não atordoa (F8); só blindagem quebrada e Quebra atordoam; círculos no chão só de Morvath.
Medidas [M] vêm de `combat_cadence.md` 1.3/1.4 e `gameplay.md`; o resto é **proposta de partida** (ajustar com o robô). Dano no herói de 30 vida.

## Regras de leitura que valem para todos
- Todo padrão novo tem aviso de 0,85 s ou mais (piso do C17), mira que trava nos últimos 0,3 s (`aim_lock`), e recuperação visível de 0,8 s ou mais.
- **Teto de pressão**: no máximo 1 padrão "só o Brado" (ou esquiva no tempo) a cada 12 s, para o Q estar de volta; no máximo 2 corpos preparando juntos.
- **Cota de teclas por luta**: Cavaleiro e Ancião 4 de 6 (sem ultimate obrigatória); Morvath 5 de 6 (ultimate vale ouro na fase 2 e 4).
- Em toda janela de punição o ataque comum sozinho tira no máximo 40% do que um botão certo tira (blindagem: ataque 1, onda 1,5, Brado e Quebra em área).

## O Cavaleiro (guardião 1; 450 de vida, armadura 1220, quebra atordoa 2,5 s)
**K1 Investida rastreada** (existe: aviso 1,0 s, trava em 0,3 s, 18 m/s por 0,7 s, dano 18, duas seguidas, recuperação 0,8 s).
1) corpo braceado, faixa no chão; 2) esquiva no último 0,3 s (de lado); Brado também serve; 3) 0,8 s depois da segunda investida ele está parado;
4) distância mínima de rastreio 5 m, sem mudança; 5) tudo existe (`charges`, `aim_lock`, `CHARGE_FOLLOW_FROM`). **Novo (dado `wall_stun`, comportamento pequeno):**
se a investida termina na parede da arena ele fica 1,5 s tonto de costas, sem a regra do F8 (é colisão dele, não golpe do herói); a janela é a recompensa de esquivar para o lado certo.
**K2 Pancada de perto** (existe: 3,2 m, aviso 0,8 s, dano 18). 1) escudo recua e cai; 2) **Brado** (aguenta, e a onda do Brado tira poise em área e abre a janela);
esquiva é a segunda opção; 3) 0,8 s de recuperação, 1,0 s se o Brado absorveu (tempo de tontura nova, dado `ward_open`); 4) alcance 3,2 m, dano 18; 5) tudo existe, `ward_open` é dado novo lido pelo Brado.
**K3 Guarda erguida** (novo na prática, reaproveita `front_block` 70% em 75 graus e `front_open` 4 s do Escudo). 1) escudo à frente por 4 s, aviso de 0,6 s ao erguer (som e brilho);
2) **onda** abre a guarda; **Investida** cruza para as costas (ela passa) e o ataque ali tem x1,5; 3) enquanto ergue ele anda devagar (60%) e bate a cada 1,6 s a 1,6 m; ou a guarda cai sozinha em 4 s;
4) a cada 14 s, só com a armadura acima de 50%; 5) dado: `guard_up` (tempo, recarga) no `EnemyDef`; comportamento: ligar `front_block` por tempo (existe no Escudo).
**K4 Chamado** (existe: 3 esqueletos, 6 no máximo, mais 2 feiticeiros de escolta). 1) braço ao alto, 1,1 s, runas no chão perto dele; 2) **ultimate ou onda em linha** nos mortos, ataque na janela;
3) 1,2 s parado chamando (hoje a janela existe como invocação), esqueletos nascem a 0,45 s um do outro; 4) a cada par de investidas; 5) tudo existe.
**Duração alvo 60 s.** Ciclo: K1, K2, K3, K1, K4 em loop com descanso 1,0 s. Teclas: esquiva, Brado, onda, Investida, ataque (5 de 6). Quebrar a armadura (1220) pede onda ou Brado; ele não passa de 2 quebras na luta.

## O Ancião (guardião 2; 510 de vida, armadura 1450, escolta 1 Guarda)
**A1 Leque de 5 orbes** (existe: aviso 1,0 s, 84 graus, dano 10, 6 m/s, trava em 0,35 s, 5 fios). 1) cajado sobe, 5 fios nascem e enchem juntos; 2) esquiva entre fios; **Brado** se o herói está de frente
(aguenta 1 orbe de 10); 3) descanso 3,9 s do ciclo, janela de 1,2 s logo após; 4) 5 m a 9 m; 5) existe tudo.
**A2 Recuo e salva** (novo, reaproveita a fuga do besteiro `retreat_far` 8,75 m por 1,5 s): depois do leque ele foge 8 m e solta 3 orbes lentos (4 m/s, giram 60 graus/s, 5 s). 1) passo atrás de 0,5 s, cajado em 3 pontos;
2) **Investida** (fecha a distância e cruza os orbes) ou esquiva; 3) quando ele chega na parede ou para: 1,5 s; 4) uma vez a cada 12 s; 5) dados (`retreat_far`, `shot_count`, `shot_turn`), sem comportamento novo se o PRIEST aceitar `retreat`.
**A3 Escudo nos servos** (existe no sacerdote: blinda 3 vizinhos a 40, a cada 5 s, `ward_*`). 1) arco de luz ligando ele aos servos; 2) **onda** em linha (tira poise de todos) ou ataque no Ancião para a blindagem cair junto (a blindagem some com ele);
3) 2 s; 4) 3 servos, 40 de blindagem; 5) dado: ligar `ward_*` no `priest_elder`.
**A4 Levantar mortos** (existe: invocação com `raise_spot`, teto `alive_cap`). 1) runas 1,1 s; 2) **ultimate** ou Brado em área (quebra poise dos servos); 3) 1,5 s parado; 4) a cada 14 s, no máximo 3 mortos; 5) existe.
**Duração alvo 60 s.** Teclas: esquiva, Brado, Investida, onda, ataque (5 de 6). O Ancião fica longe, então ataque sozinho nunca resolve A2 ou A3.

## Morvath (6050 de vida; 4 fases; alvo 2 a 3 min; fases trazem **regra**, não só dano)
**Fase 1, O Despertar (100 a 66%). Regra nova: Postura.** Barra de blindagem sobre a vida (valor de partida 900); só com ela quebrada ele fica 2,6 s atordoado e leva x1,4. Reaproveita `stagger_hits` e `stagger_time` (hoje só da fase 3 em diante, ligar desde a 1).
- **Foice** (aviso 0,8 s, 5 m, 19): esquiva e punir 1,0 s; ataque; é o ritmo.
- **Ceifa Dupla** (0,85 s e 0,5 s, 4,5 m, 16, recuperação 2,2 s): **esquiva duas vezes** ou Investida por trás no intervalo de 0,35 s; punição longa de 2,2 s com onda para quebrar a Postura.
- **Lâminas das Almas** (0,7 s, 26 m, 16): **Brado** absorve uma das duas meias-luas; 0,8 s de janela.
- **Investida** (0,8 s, 16 m em 0,42 s, 19, a mais de 9 m): esquiva lateral; recuperação 1,1 s.
Teclas: esquiva, ataque, onda (Postura), Investida, Brado (5 de 6 sem ultimate). Tudo existe; novo: Postura como dado (`BossDef.posture`) e `Boss` lendo `armor` no estado de ataque.
**Fase 2, O Ritual (66%). Regra nova: Condutores.** O ritual (20 s, escudo invulnerável) dura menos por condutor morto: cada feiticeiro de `ritual_raise` derrubado corta 5 s; com os 2 mortos o escudo abre aos 10 s, atordoado 2,0 s mais. Reaproveita `ritual_time`, `ritual_stun`, `adds_cap` (6).
- **Ondas de mortos** (reforço a cada 6 s, erupção a cada 2,8 s, aviso 1,2 s, círculo de 4 m, dano 16): esquiva nas erupções, **onda** em linha nos mortos, Investida até o condutor.
- **Ultimate** é a resposta em campo cheio (limpa 6 corpos); não fura o escudo (continua invulnerável), só limpa os mortos.
Teclas: esquiva, onda, Investida, ultimate, ataque (5 de 6). Novo: `ritual_shorten` por condutor (dado) e a regra no `BossRules`.
**Fase 3, A Maldição (33%). Regra nova: Corte do rastro.** O projétil (7 m/s, 55 graus/s por 0,9 s, 10 de dano, 4 s de vida) é **cortado pela onda** do herói (sem dano e sem ficar lento) e **absorvido pelo Brado** (imunidade de 2 s à maldição já existe, `curse_immunity`).
- **Maldição**: 0,8 s de aviso; esquiva é a resposta ruim (o projétil segue); onda ou Brado, certos; 3,1 a 3,4 s de espera dele hoje (cheia de erupções e mortos).
- **Foice com erupções** (a camada E2): esquiva da foice e saída lateral do círculo; Investida cruza a faixa livre.
Teclas: onda, Brado, esquiva, Investida, ataque (5 de 6). Reaproveita tudo; novo: `curse_cut_by_heavy` (dado) e a regra de destruir o projétil no `Combat`.
**Fase 4, A Tempestade (15%). Regra nova: Ruptura.** A cada 25 s, aviso de 1,5 s de um pulso que cobre o salão (16 de dano, sem faixa livre) e deixa Morvath 3 s exposto, sem Postura e x1,4. Só o **Brado** o aguenta; quem estiver com Q em recarga tem a esquiva no tempo certo (18 quadros) ou perde 16.
- **Tempestade** (0,9 s por onda, 3 ondas, 6 meias-luas, 15): esquiva entre meias-luas; **Investida** atravessa a faixa.
- **Ruptura**: ataque, onda e **ultimate** na janela de 3 s, que é a única hora segura para gastar a ultimate inteira.
Teclas: Brado, esquiva, Investida, ultimate, ataque, onda (6 de 6). Novo: `rupture_every` e `rupture_window` (dado) e o estado `RUPTURE` no `Boss` (pulso global, reaproveitando as `eruptions`).
**Medida de alvo**: fase 1 40 a 50 s, fase 2 40 s, fase 3 40 s, fase 4 40 a 50 s (total 2:40 a 3:00); descanso entre padrões 1,1 / 1,0 / 0,6 / 0,5 s (não menos que a E2).

## Lotes de implementação (pequenos, nesta ordem; cada um com teste GUT e medida do robô, 12 sementes, `--bot-reaction=0.25`)
1. **Dado e leitura** (`BossDef.posture`, `EnemyDef.guard_up`, `ward_open`, `wall_stun`): teste que cada dado carrega e que a regra do F8 não muda. Sem robô.
2. **Cavaleiro K2, K3, K4** (guarda por tempo, Brado abre, `wall_stun`): teste de bloqueio, de `ward_open` e de aviso de 0,85 s ou mais. Robô: duração 50 a 70 s, novato morre no máximo 3 de 12.
3. **Ancião A2 e A3** (recuo com salva, blindagem nos servos): teste de recuo e de sumir a blindagem. Robô: dano do Ancião não passa de 1,5 vez o de hoje (68 nas 24 descidas).
4. **Morvath fase 1** (Postura): teste de quebrar e de x1,4. Robô: fase 1 de 40 a 50 s, `all keys` ao menos 6 de 12 passam.
5. **Fase 2 Condutores**: teste do corte de 5 s por condutor. Robô: ritual de 10 a 20 s, sem dois estados que trancam.
6. **Fase 3 Corte do rastro** (onda destrói o projétil): teste do projétil e da imunidade do Brado. Robô: o bot corta com onda, mortes por maldição não sobem.
7. **Fase 4 Ruptura**: teste do pulso (aviso 1,5 s, 16, janela de 3 s). Robô e **câmera**: o pulso não esconde o chefe; no máximo 1 por 25 s.
8. **Ajuste da duração e das teclas**: robô só mouse (`--bot-mouse`) contra todas as teclas, 12 sementes, novato e evoluído: só mouse chega a Morvath em no máximo metade das vezes de todas as teclas; Morvath de 2:40 a 3:00.
9. **Avaliação do combat-feel-director e captura** (uma por vez, só a que alguém vai olhar): preparação, impacto, recuperação, aviso no chão sincronizado, nenhum teleporte.
Cada lote entra em `gameplay.md` e `combat_cadence.md`. Nenhuma tecla é obrigatória por texto; o aviso na tela mostra o botão só quando o herói o tem.
