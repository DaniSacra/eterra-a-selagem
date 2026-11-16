# C12d: sonda de game feel com metas (GF-14)

A sonda joga entradas roteirizadas na cena real do jogo, um passo por quadro a 60 Hz, e diz por meta se o C12d
passou. Só mede; não muda nada do jogo. Código: `tools/feel_probe.gd` (cenários e metas, lista no topo) e
`tools/feel_probe_run.gd` (lançador).

## Comando (cerca de 5 s)

```
~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain
```

- Só os vereditos: `... | grep '^FEEL'`. Só alguns cenários: `PROBE=_s_dodge_cancel,_s_buffer` antes do comando
  (a meta `ALL` só sai na rodada inteira).
- Saída: uma linha `FEEL ok <id> <nome> | alvo: ... | medido: ...` ou `FEEL falha ...` por meta, depois
  `FEEL_SUMMARY n/m ok`, uma linha `FEEL_FAIL` por meta que falhou e o código de saída 1 se alguma falhou (0 se todas ok).
- Determinística: duas rodadas seguidas dão as mesmas linhas `FEEL` (só o arremesso aleatório do corpo muda no log).
- Quadro 0 é o quadro em que o jogo lê o aperto. "Ritmo" de um quadro = segundos de jogo que ele andou x 60
  (1 = velocidade cheia, 0 = parado por hit stop, 0,06 = a lentidão do Hades).
- **Aceite do C12d**: `FEEL_SUMMARY 31/31 ok`, saída 0.

## Metas

| Id | Nome | Alvo | De onde vem o número |
|---|---|---|---|
| GF-01a | hit_stop_shape_cut1 | golpe 1 num alvo: 0 quadros parados; o mundo anda 1+ quadro depois do acerto (espera de 25 ms); depois 1 a 3 quadros com ritmo até 0,1; velocidade cheia em até 2 quadros (20 ms) | medidas tabela 7, problema 1; GF-01 |
| GF-01b | no_freeze_combo | combo de 3 batendo sem parar num alvo: 0 quadros parados | GF-01 (`frozen_frames=6` hoje) |
| GF-01c | hit_stop_shape_spin | giro num alvo: como o 01a, com 3+ quadros de espera (70 ms) | GF-01 |
| GF-01d | hit_stop_shape_kill | golpe 1 que mata: como o 01a, com 2 a 4 quadros lentos (10 + 40 ms) | GF-01 |
| GF-02a | dodge_in_windup | esquiva apertada em qualquer quadro 0 a 40 do golpe 1 ou da seta sai no quadro do aperto (ou no seguinte), nunca LOST | GF-02 |
| GF-02b | cut_blow_no_damage | golpe cortado pela esquiva não acerta depois que ela sai | GF-02 ("golpe cortado não dá dano") |
| GF-02c | dodge_cuts_spin | esquiva apertada todo quadro desde f1 do giro sai em f1 | GF-02 |
| GF-03a | attack_in_dodge | ataque nos quadros 1 a 13 da esquiva (esquiva em f0) vira `dash_cut` em f13 ou f14; de f16 em diante, no quadro do aperto | GF-03 |
| GF-03b | attack_at_dodge_end | ataque em f11 a f15 sai até max(aperto, 14), nunca LOST | GF-03 ("aperto no último quadro vale") |
| GF-03c | attack_while_hurt | ferido em f0, um toque de ataque (f3) ou de especial (f5) sai em f11 (10 a 12) | GF-03 (`HURT_TIME` 0,18 s) |
| GF-04a | buffer_cut1 | 2º aperto em qualquer quadro 1 a 36 do golpe 1: golpe 2 em max(aperto, fim do golpe 1) (ou 1 depois) | GF-04 |
| GF-04b | buffer_spin | aperto em qualquer quadro 1 a 39 do giro: golpe 1 em max(aperto, fim do giro) (ou 1 depois) | GF-04 |
| GF-05 | slow_mo_visible | giro que mata 3: até 3 quadros parados no total e 5 ou mais quadros andando com ritmo 0,15 a 0,25 | GF-05 |
| GF-06 | pad_in_hit_stop | esquiva apertada em f6 de um acerto: o controle virtual sai no mesmo quadro que o teclado, nenhum LOST | GF-06 |
| GF-07a | bolt_attack_lock | seta e ataque apertado todo quadro: golpe 1 em f25 (24 a 26; 18 depois do dardo em f7) | GF-07 |
| GF-07b | bolt_recharge | seta e especial todo quadro: 2ª seta em f48 (47 a 49; recarga 0,7 s) | GF-07 |
| GF-07c | bolt_speed | dardo a 62,5 m/s (61,5 a 63,5) | GF-07 (`ProjectileStaffBall` 5000) |
| GF-07d | bolt_holds_legs | andar segurado: nenhum passo de f1 a f48 depois da seta, volta a andar até f53 | D-44 (3), decidida pelo Daniel: pernas presas 0,71 s |
| GF-07e | dodge_cuts_bolt | esquiva apertada em f20 da seta sai em f20 | D-44 (3): só a esquiva corta |
| GF-08 | omega_when_full | segurando o ataque: a lança acerta em f48 (47 a 49; carga de 0,8 s) | GF-08 |
| GF-09a | turn_facing | direção a 5 graus da nova até f1 | GF-09 (direção instantânea) |
| GF-09b | turn_body | corpo desenhado a 5 graus do ângulo final até f7 (8 quadros, 1340 graus/s) | GF-09 |
| GF-09c | plant_on_press | 0,00 m andados no quadro do aperto do golpe 1 e da seta | GF-09 |
| GF-09d | dodge_safety_19 | proteção de 19 a 20 quadros contados desde o aperto | GF-09 |
| GF-10a | kick_cut1 | tranco de câmera do golpe 1 até 0,10 m | GF-10 (comuns na escala do Hades) |
| GF-10b | shake_cut1 | tremor do golpe 1 até 0,10 m | GF-10 |
| GF-10c | flash_cut1 | clarão do inimigo 0,05 s: 2 a 4 quadros com `flash_t` acima de 0 | GF-10 |
| D-44a | dodge_frame_0 | esquiva parada sai no quadro do aperto (f0) | D-44 (1): fica |
| D-44b | cast_no_safety | nenhum quadro protegido depois de soltar o círculo (toque e Ômega) | D-44 (2): a proteção de 0,2 s sai |
| D-44c | cast_attack_lock | ataque apertado todo quadro desde a soltura do círculo: golpe 8 quadros ou mais depois | D-44 (2): os 8 quadros do Hades |
| ALL | no_lost_press | nenhuma linha da rodada com LOST | regra do ciclo: nenhum aperto perdido |

Folgas: 1 quadro nos alvos de quadro do Hades (o acumulado de 1/60 s arredonda), as faixas da lentidão do GF-01
(10 ms cabem em menos de um quadro). São escolhas do QA para o teste não depender de arredondamento; o número do Hades
está ao lado de cada uma.

Fora da sonda: GF-11 (som no disparo e vibração: teste GUT do `Audio` e vídeo com som), GF-12 (reação do inimigo, C12f;
o cenário `ENEMY` só imprime), GF-13 (latência na placa), a tabela do Ômega do especial do GF-09 (documento), as
metas visuais VX (capturas e o `art-director`).

## Rodada antes (HEAD `1e25f21`, 2026-11-16)

Arquivo: `docs/gallery/c12d/before/feel_probe.txt` (saída 1). **4 de 31 ok**: as que passam são as guardas
(GF-02b, GF-07e, GF-10b, D-44a). Todas as metas de GF-01 a GF-08 falham, como o backlog previa.

| Meta | Medido antes | Veredito |
|---|---|---|
| GF-01a hit_stop_shape_cut1 | 1 quadro parado (f5), sem espera | falha |
| GF-01b no_freeze_combo | 6 quadros parados | falha |
| GF-01c hit_stop_shape_spin | 4 quadros parados, sem espera | falha |
| GF-01d hit_stop_shape_kill | 3 quadros parados, sem espera | falha |
| GF-02a dodge_in_windup | LOST no golpe 1 em d1 a d4, na seta em d1 a d7 | falha |
| GF-02b cut_blow_no_damage | nenhum | ok |
| GF-02c dodge_cuts_spin | f23 | falha |
| GF-03a attack_in_dodge | LOST em d1 a d13 | falha |
| GF-03b attack_at_dodge_end | LOST em d11 a d13 | falha |
| GF-03c attack_while_hurt | ataque e especial LOST | falha |
| GF-04a buffer_cut1 | LOST em d1 a d3 | falha |
| GF-04b buffer_spin | LOST em d1 a d31 do giro | falha |
| GF-05 slow_mo_visible | 17 parados, 0 lentos andando | falha |
| GF-06 pad_in_hit_stop | teclado f8, controle virtual LOST | falha |
| GF-07a bolt_attack_lock | f42 | falha |
| GF-07b bolt_recharge | f42 | falha |
| GF-07c bolt_speed | 30,0 m/s | falha |
| GF-07d bolt_holds_legs | anda em f8 | falha |
| GF-07e dodge_cuts_bolt | f20 | ok |
| GF-08 omega_when_full | f56 | falha |
| GF-09a turn_facing | f10 | falha |
| GF-09b turn_body | f14 | falha |
| GF-09c plant_on_press | 0,11 m no golpe 1 e na seta | falha |
| GF-09d dodge_safety_19 | 17 quadros | falha |
| GF-10a kick_cut1 | 0,315 m | falha |
| GF-10b shake_cut1 | 0,076 m | ok |
| GF-10c flash_cut1 | 9 quadros (0,15 s) | falha |
| D-44a dodge_frame_0 | f0 | ok |
| D-44b cast_no_safety | 26 quadros protegidos (toque e Ômega) | falha |
| D-44c cast_attack_lock | golpe 1 quadro depois | falha |
| ALL no_lost_press | 28 linhas com LOST | falha |
