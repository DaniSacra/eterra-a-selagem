> Índice: [combat_cadence.md](../combat_cadence.md)

## 8. Lote 1C de 2026-11-19 noite: aprovações pendentes, LC-P1 e critérios do C19 (HEAD `c3011c0`)

Medido numa cópia isolada do `c3011c0` (`git archive`; outros agentes mexiam no repositório). CPU sem tela a 60 f/s
fixos: `tools/enemy_motion_probe.gd` sementes 1 a 3 (40 s, `--play --hero-hp=9999`); 8 descidas do robô
(`tools/smoke.sh 900 --seed=1..8 --bot-reaction=0.25 --ultimate=cleave --runlog`), 7 vitórias e 1 morte; GUT
`test_enemy_windup` 16/16, `test_special_wave` 5/5, `test_indicators` 17/17, `test_rune_sounds` 3/3,
`test_runes_compat` 2/2. Capturas medidas com `tools/frame_stats.py --hue`.

### 8.1 Pareceres

| Item | Veredito | Classe do que sobra |
|---|---|---|
| QW-104 corpo que acende no "vai bater" | **Aprovado** na cadência (a aprovação visual é do art-director) | P2 |
| QW-107 mira em fio do besteiro e do bote | **Aprovado** | nenhum |
| QW-111 onda do especial 25% maior no desenho | **Aprovado** (desenho dentro do acerto real) | nenhum |
| RP-03 Runas 7 no herói e 60 nos inimigos | **Aprovado sem ressalva** (as duas P1 da seção 7 resolvidas) | passo 2 (10) segue esperando o Daniel |
| LC-P1 preparo mais longo de algum atirador | **Não recomendado** (arquivar; reabrir só pelo critério abaixo) | |

**QW-104.** [D] `crowd.gdshader` 276: `ready = smoothstep(1 - tell_hold, 1, tell) * tell_light` (estilizado vezes
`STYLE_TELL` 1,6), somado só até `flash_cap` 1,0; `tell_hold` = `EnemyDef.windup_hold` 0,3 de todos. Rampa por tipo
[D]: besteiro e sacerdote 0,24 s (preparo 0,8), esqueleto 0,27 (0,9), mago, corredor e ancião 0,30 (1,0), Escudo 0,35
(1,15). [M] o corpo chega ao máximo no quadro do golpe e o golpe sai com o aviso cheio: esqueleto 0 f em 50 de 50
botes (sementes 1 e 3), corredor 0 f em 24 de 24, Escudo 0 f em 22 de 23 e +3 f em 1 (o caso conhecido do herói
empurrado, P2 da 6.7); `test_the_body_clears_in_the_hold` passa. Visto: no `archer_aim_strip_before_after.jpg` do LC
(`docs/gallery/lc/windup/after2/`) o besteiro clareia morno só no último quadro antes do tiro, sem virar silhueta
branca. **P2-QW104**: o Hades acende nos últimos `min(0,5 s, preparo)` [H] (seção 4.1 do estudo); nossa rampa dura
metade (0,24 a 0,35 s), presa ao `windup_hold`, que também é a pose segurada. Recomendação para o C19 (2B), sem
urgência: campo próprio `EnemyDef.tell_time` 0,5 s (rampa = `min(tell_time, preparo)`), soltando o brilho do corpo da
pose segurada. Aceite: rampa medida de 0,5 s em todo tipo com preparo de 0,5 s ou mais, pico ainda no quadro do golpe
(0 a 1 f), nenhum canal acima de 1,0.

**QW-107.** [D] `GroundLook.AIM_PX` 6 px de tela (o mesmo em 720 e 1080, pela derivada do pixel), `AIM_LIGHT` 0,5,
ponta até 1, faixa só nos últimos 30% até `AIM_FILL` 0,22; no estilizado o fio soma `style_rim_gain` 2,0 sobre o chão
escurecido a 0,8. Aceite do item: largura até 10 px (passa: 6), nenhum trecho acima de 0,6 fora da ponta (passa: fio
0,5, faixa 0,22), aviso x dano 0 a 1 f (passa: 0 f em todos os 50 botes do esqueleto, que usam o fio; o virote sai no
último quadro dos 0,8 s da mira, que é a vida do aviso, `Horde` 571). [M] `warn_s` do besteiro nas 8 descidas: 6
golpes, mínimo 1,15 s. [M] GPU (RTX, Forward+ estilizado, 1920 x 1080, `--stress=4 --stress-ids=archer,skeleton
--seed=5 --hero-at=0,0 --shot-at=3`, e o salão da semente 5 com o robô): o fio vermelho tem 7 px de altura por coluna
num fio quase deitado e 9 a 10 px num fio a 25 graus (cerca de 9 px na perpendicular, com o anti-serrilhado e a faixa
dos últimos 30%), sempre até 10; lê como fio, não como faixa, também passando sob o herói. Capturas em `docs/gallery/lote1c/cadence/`.

**QW-111.** [D] `emeth_wave.gdshader`: `look_scale` 1,25 em ondas abaixo de 3 m (só a do especial comum), 1,6 m
desenhada vira 2,0 m; o acerto não muda (`test_special_wave`: dano 40, alcance 11 m, círculo 0,7 m, 62,5 m/s, pernas
0,71 s). Sincronia desenho x lógica [D, conta]: o acerto pega quem tem o centro a até 0,7 + raio do corpo
(`Horde.in_circle`: 0,5 esqueleto, mago, besteiro, sacerdote; 0,55 Escudo; 0,75 corredor) do centro da onda, isto é
1,2 a 1,45 m de lado; a ponta desenhada vai a 1,0 m. Antes a onda desenhada (0,8 m de lado) ficava bem mais estreita que
o que acertava; agora fica dentro e mais perto dele, e nenhum inimigo tocado só pela ponta desenhada escapa do acerto
(corpo tocando a ponta = centro a até 1,5 m; acerto a até 1,2 m: a sobra de 0,3 m é o corpo do lado de fora da ponta).
Tamanho na tela [I, pela câmera: 54 m, campo 24, inclinação 30]: cerca de 47 px por metro no meio da tela a 1080, a
onda de 2,0 m dá cerca de 94 px quando voa para cima ou para baixo na tela e cerca de 47 quando voa de lado (era 75 e
38); na câmera Perto (37 m) cerca de 137 e 69 (a captura na GPU do salão pegou a onda já no acerto, a 1,6 m, atrás do inimigo: o tamanho fica como conta, não medida). Sem efeito na cadência (o golpe e as travas são os mesmos).

**RP-03.** As duas ressalvas da seção 7 foram resolvidas:
- **Som** (`c79802f`): `RuneFloor` toca `rune_arm` no `ARMED` (começo do aviso de 1,2 s) e `rune_crack` no `FIRED`
  (quadro do golpe), um por padrão, nunca por ladrilho, fora de `Audio.WARN_CUES` (sem ducking). [M] amostras: pico
  -14,1 dBFS (armar) e -8,3 dBFS (estalo), abaixo dos avisos de Morvath. `test_rune_sounds` 3/3.
- **Compatibility** (`c6d6aab`): [M] nas capturas de `docs/gallery/rooms_rp/cadence/` (1672 x 941, Runas A, 0,9 s
  do aviso = 0,75 dele): laje armada luma p50 135 a 145 e saturação 0,39 a 0,42, matiz 30 (âmbar); antes 91 a 105 e
  0,04. Vizinhas apagadas 74 a 137 (p50 típico 110 a 119, saturação 0,04 a 0,09, matiz 220 a 230). Aceite (+25 de luma
  p50 e +0,15 de saturação): saturação passa com folga (+0,30 ou mais); luma +25 a +26 sobre a vizinha típica e +53 a
  +71 sobre as do canto escuro, e só empata com a laje que está na poça da luz de cima (137), onde o âmbar contra o
  cinza-azulado (matiz 30 contra 220) separa sozinho. Forward+ da mesma tomada: armada 100 a 116 contra 65 a 102,
  saturação 0,21 a 0,29: o Compatibility agora lê **mais** que o desktop. O golpe (`runes_a_strike_compat_sty_after.jpg`)
  enche a laje de marfim-âmbar por cerca de 0,1 s e a brasa esfria em degraus, sem flash branco.
- [M] Robô nas 8 descidas: runas 2 golpes, `warn_s` 1,2 nos dois. O veredito da seção 7 sobe para **aprovado**; o
  passo 2 (10) continua esperando o teste do Daniel.

**LC-P1 (preparo mais longo de algum atirador).** O problema do LC era **quem** mira e **por onde**, não quanto tempo:
[M] `warn_s` dos atiradores nas 8 descidas, todos com aviso: mago 20 golpes, mínimo 1,07 s, p10 1,45; besteiro 6,
mínimo 1,15; ancião 5, mínimo 1,21; sacerdote 2, mínimo 0,83 (a trepadeira, lenta). Nenhum abaixo de 0,8 s; a regra
do C19 pede 0,4. Os tempos já são os do Hades [H]: mago 1,0 s (Mage), sacerdote 0,8 (SiegeVine), besteiro 0,8 mais
0,6 s médios de voo. Depois do LC-1b e do LC-3b [M, `docs/gallery/lc/windup/after2/`]: besta de 64 a 70 px a 1080 com
a linha de mira descendo da ponta ao fio do chão, orbe crescendo no cajado (LC-2 passou), V do Sacerdote lido de costas
(cerca de 80 px). Esticar a preparação deixaria o mago, que já é a maior fonte de dano nas salas, mais fácil sem tornar
a leitura mais clara. **Reabrir** só se o registro do Daniel (`runs.jsonl`, `hurt_ctx`) mostrar um atirador com mais de
30% dos golpes com `offscreen` verdadeiro ou com o herói de costas para ele; aí o remédio é tempo (0,2 s a mais só no
preparo daquele tipo, com a mesma pose segurada) e o critério é o mesmo `warn_s`.

Observado de passagem (sem ação): na semente 2 da sonda um corredor encostado na borda norte (z 18,85) soma 98 giros
acima de 8 graus em 10 s; são giros contínuos de 20 graus por quadro (o `TURN_RATE` de 1200 graus/s) seguindo o herói
preso na parede, não tremor de vai e volta (0,8 inversões/s, nenhuma de 2 quadros).

### 8.2 Critérios de aceite de cadência do C19 (para o gameplay-engineer, antes do Lote 2)

Valem junto dos números da seção 3 do backlog (fase 1 de Morvath, `warn_s`). Medição: sonda e
`enemy_motion_probe` a 60 f/s fixos, `tools/boss_cadence.gd --cadence-log` para Morvath, 24 descidas do robô
(`--bot-reaction=0.25 --ultimate=cleave`) e um vídeo na GPU a 0,25x de cada golpe novo. Todo golpe novo: preparação
com o corpo (pico de movimento 1,0 ou mais, 6.1), aviso cheio no quadro do dano (0 a 1 f), dano saindo do corpo ou da
arma desenhada, recuperação viva (pose parada até 0,3 s), troca de clipe com mistura (nenhum salto do centro acima de
0,3 m entre quadros), sonda 40/40 e `boss_probe`/`enemy_motion_probe` sem regressão.

**C19-1 Esqueleto elite, dois golpes (Q-11, [H] Guard elite: dois golpes a 0,2 s, não para, recuperação 1,5 s).**
- Os dois golpes em dado (`strikes` 2, `strike_gap` 0,2 s), o segundo sem nova preparação longa: o corpo emenda
  (pose do fim do 1º para a subida do 2º em até 0,2 s), sem `idle` no meio.
- Os dois avisos visíveis antes do 1º golpe: o 2º fio aparece já na preparação (fraco, enchendo nos últimos 30% do
  intervalo), porque 0,2 s (12 f) não dá para reagir a um aviso que só nasce depois do 1º golpe. Cada aviso cheio no
  quadro do próprio golpe (0 a 1 f, os dois contados na sonda).
- O 2º golpe mira onde o herói estava no fim da preparação (não persegue): quem esquivou do 1º para o lado sai dos dois.
- Atordoar no 1º golpe corta o 2º (o aviso some no mesmo quadro, `Ground.end_zone`); a armadura segue absorvendo antes.
- Recuperação depois do 2º: 1,5 s (a do Hades para a elite), parado, com o clipe seguindo; janela de punição medida
  (`windups` com `struck` e um campo novo de golpes recebidos na recuperação).
- Aceite no robô: dano por esqueleto elite por sala no máximo 1,5 vez o de hoje (a dobra vem do 2º golpe); nenhum dano
  com `warn_s` abaixo de 0,4.

**C19-2 Corredor elite, explosão dupla (Q-11).**
- Dois giros com `strike_at` cada, intervalo em dado; o 2º anel de aviso nasce no quadro da 1ª explosão e enche no
  quadro da 2ª (intervalo mínimo 0,5 s [I]: um anel novo precisa de tempo de leitura; com 0,2 s o 2º é invisível).
- O corpo não para entre as duas (giro contínuo, `2H_Melee_Attack_Spinning` em laço); o 2º anel no lugar do corpo no
  quadro da 2ª explosão, não no do 1º (se ele anda no giro, o anel anda com ele).
- Recuperação depois da 2ª: a do Hades para o Radiator elite, 0,5 s [H]; a janela vem do giro longo, não da espera.

**C19-3 Segundo golpe de Morvath de perto (Q-09 a; [H] Hécate: direita 0,85 / 0,4 / 0,35 s e logo esquerda
0,5 / 0,5 / 2,2 s).**
- Par: o 1º golpe com preparação de 0,85 s e o 2º emendado com 0,5 s; avisos dos dois no chão, o 2º nascendo no fim
  do 1º golpe (0,4 s ativos + 0,35 de recuperação curta antes dele: 0,85 s de leitura, mais que a preparação inteira
  do esqueleto), cada um cheio no quadro do próprio dano (0 a 1 f, `slash3:N` medido como na foice).
- Depois do 2º, recuperação de 2,2 s (janela longa, `State.RECOVER`, `stats.windows`/`punished`): é a razão do par.
- Clipe novo com `in_place` (centro de toda pose a no máximo 0,45 m, `tools/pose_drift.gd`), duas mãos como a foice,
  giro do corpo no limite `BODY_TURN` 720 graus/s entre os dois (não estala para o lado do 2º).
- Distribuição (aceite do backlog): fase 1 com o herói a menos de 4 m, nenhum ataque acima de 50% e nunca 3 iguais
  seguidos, em 3 sementes do `boss_cadence --cadence-log`.

**C19-4 Ômega carregando no número do Hades (Q-12).**
- Ômega do ataque: andar a 3% da velocidade enquanto carrega (0,2 m/s) e o giro do corpo quase travado [H, `Swing5`];
  a esquiva corta a carga no quadro do aperto (a Magia não é gasta); nenhum quadro de `Run` ou `Sprint` com a carga
  segurada.
- Ômega do especial: o número do Hades da ação, lido pelo gameplay-engineer em `WeaponData_Staff.lua` 474-501; se o
  dado não trouxer velocidade própria, a do especial comum na carga (60%, `InstantStop`, linha 1313) e marcar como
  inferência no documento. Ômega do círculo segue `cast_slow`.
- O corpo mostra a carga: pose de carga própria (ou a preparação do golpe segurada), não a corrida em câmera lenta;
  o andar desenhado no ritmo da velocidade real (o passo não escorrega, como os inimigos).
- O som `charge_up` segue o tempo da carga e corta com 0,2 s de fade ao soltar ou cancelar [H].
- Aceite no robô e na sonda: `omega_charges_cancelled` registrado; distância andada do aperto ao disparo no máximo
  0,2 m no Ômega do ataque; a sonda ganha a meta.

**C19-5 Linha da mira no orbe e no leque do Ancião (Q-14 a) e a regra da trepadeira (Q-14 b).**
- Orbe do mago: `add_aim_warning` do começo da preparação (1,0 s) até o 1º orbe, no rumo do tiro, com o comprimento
  do `arena.shot_reach` (para na pedra); fio na gramática do besteiro (até 10 px a 1080, faixa só nos últimos 30%).
  Como o orbe vira 20 graus/s nos primeiros 0,8 s, o fio marca o rumo da saída; a rajada (3 orbes a 0,17 s) usa um
  fio só.
- Leque do Ancião: cinco fios fracos ou só as duas bordas e o do meio (escolha do art-director pela SW-G7), todos
  nascendo e cheios juntos; aviso cheio no quadro do tiro (0 a 1 f).
- Trepadeira (b): a regra passa a "todo ataque tem aviso, no chão ou no corpo": o rito do sacerdote (V dos braços e
  chama, LC-3b) é o aviso; a trepadeira lenta (1,9 m/s) se lê no voo. Aceite: `warn_s` da trepadeira 0,8 ou mais em
  100% dos golpes.
- Aceite geral (backlog): todo tiro com `warn_s` de 0,4 ou mais nas 24 descidas; hoje [M] o menor é 0,83 s.

**C19-6 LC-P1:** não pedido (8.1).

### 8.3 Parecer do C19 (HEAD `8dc0fea`, 2026-11-20)

Medido numa cópia isolada do `8dc0fea` (`git archive`), CPU sem tela a 60 f/s fixos: sonda `feel_probe_run`;
`enemy_motion_probe` sementes 1 a 3 sem estresse e com `--stress=4 --stress-ids=skeleton_elite,runner_elite` (40 s),
mais `--stress=4` só de `runner` e só de `runner_elite` (sementes 1 e 3, 30 s); `boss_cadence --cadence-log` sementes 1,
2, 3 e 5 (reação 0,25, 5 Bênçãos); `boss_probe` sementes 5 e 1; `pose_drift` de Morvath. Vídeos e folhas de
`docs/gallery/c19/` lidos quadro a quadro com ffmpeg. As 24 descidas do robô não foram refeitas (outros agentes rodavam
`smoke` na mesma máquina): valem os números do gameplay-engineer no `CLAUDE.md`, seção C19.

**Veredito: aprovado** na cadência, com uma P2 do próprio C19 a resolver no AP-2 e uma P1 antiga que o C19 deixou
mais visível (fora do escopo, item próprio). Nenhum P0.

| Critério 8.2 | Medido | |
|---|---|---|
| Sonda | 41/41 [M] | passa |
| Aviso cheio no quadro do dano | [M] comuns 0 f em 94 golpes (sem estresse; Escudo +3 f em 1, o caso conhecido); elites: 1º golpe do esqueleto e 1ª explosão "-1 f" na sonda, que é sobra de 0,003 s de vida do aviso (0,2 ms, um arredondamento, não um quadro); 2º golpe 0 f (esqueleto) e +1 f (corredor). 270 golpes de elite nas 3 sementes, nenhum fora de -1 a +1 | passa |
| 2º golpe do esqueleto elite | [M] 0,2 s depois do 1º (12 f), a 0,93 a 1,97 m do herói (a lâmina alcança 2,21); o fio do 2º nasce com a preparação (vida 1,336 s contra 1,136 do 1º) | passa |
| Corpo emenda os dois golpes | [D] `Horde.render`: o clipe do golpe recomeça do alto com mistura de 0,1 s (`strike_gap` x 0,5) do fim do 1º, e desce no 0,1 s seguinte; nenhum `idle` entre eles [M] | passa |
| Pose parada | [M] recuperação até 0,22 s, preparo até 0,17 s (teto 0,3) | passa |
| Explosão dupla do corredor elite | [D] 2º anel nasce no quadro da 1ª onde o corpo está (ele não anda em ATTACK), vida 0,5 s + 1 f; giro em laço (`fposmod`); fim 0,3 s depois, recuperação 0,5 | passa, ver P2-C19a |
| Ceifa Dupla: tempos | [M] `boss_cadence`: ataque 2,59 a 3,33 s com a aproximação, recuperação 2,20 a 2,22 s (0,22 e 0,55 só quando a troca de fase corta); [D] o dano é a própria zona do aviso no chão, então o aviso está cheio por construção; o corte visual sai no mesmo `windup` (0 a 1 f) | passa |
| Ceifa: clipe e corpo | [M] `pose_drift`: `slash1` pior 0,34 m, `slash2` 0,43 m (teto 0,45); `boss_probe`: maior passo 0,258 m (teto 0,3), na Lâmina com o passo atrás do C17, não na Ceifa; na Ceifa `slash1`/`slash2` tocam 1045 e 1115 quadros e `idle` 1 quadro na entrada do estado (dentro da mistura de 0,18 s) | passa |
| Ceifa: direita e depois esquerda | [O] vídeo: o 1º corte varre de um lado, o 2º volta do outro; 2º aviso nasce depois do 1º corte e enche até o 2º | passa |
| Fase 1 perto | [M] maior parte 43 / 43 / 50 / 43% (Ceifa ou foice), nunca 3 iguais, 6 a 8 ataques por semente | passa (no limite em 1 de 4) |
| Janela de punição | [M] vida perdida por janela da Ceifa 62 a 188 contra 26 a 50 da foice: a janela longa existe e é usada | passa (o efeito no tempo da luta é do balance-designer) |

**Ancião 45 para 126 (C19-4): é equilíbrio, não cadência.** Os golpes do leque têm `warn_s` de 1,04 s ou mais, o aviso
nasce e enche junto do tiro e os orbes saem no quadro do fio cheio: nada na leitura piorou. O que mudou é o custo de
carregar o Ômega a 3% da velocidade (o número do Hades, de propósito: carregar é se comprometer). O robô começa o Ômega
com um atirador preparando por perto e, sem carga de esquiva, sai a pé soltando o botão, o que dispara ou encerra o
golpe plantado; gente pode cortar a carga na esquiva no quadro do aperto (meta `C19-4` da sonda). Recomendação: não
mexer nos 3%; o gameplay-engineer faz o robô não começar o Ômega do ataque com um tiro preparando a menos de 12 m
(`Bot`, mesma regra do `_danger`), e o balance-designer relê o dano do Ancião depois disso e no registro de gente
(`hurt_ctx` com `by: priest_elder`). Aceite: Ancião no robô até 1,5 vez o de antes (até 68 nas 24 descidas) com essa
regra; se continuar acima, é número do leque (balance), não tempo.

**P2-C19a, 2º anel do corredor elite tapado pela 1ª explosão.** [M] vídeo a 0,25x (`runner_elite_quarter_speed.mp4`,
1 quadro do vídeo = 1 quadro do jogo): a 1ª explosão sai no quadro 22 e o disco claro dela cobre a área até o 33; o aro
do 2º anel só se lê do 34 ao 54 (2ª explosão): 0,33 s de leitura dos 0,5 s pedidos. Pouco grave hoje (quem levou a 1ª
está protegido 1,3 s; o 2º só pega quem esquivou e voltou), mas é o tempo de leitura do critério. Correção
(gameplay-engineer com o art-director): o disco da explosão do corredor some em até 0,12 s ou o 2º anel desenha por
cima dele. Aceite: no vídeo a 0,25x, aro do 2º anel visível 0,4 s ou mais antes da 2ª explosão.

**P1 antiga, corredor elite tremendo encostado no herói (não é do C19).** [M] parado no `WALK` esperando a recarga, o
corredor elite é empurrado para fora pela separação (cerca de 1 m/s) e volta 0,12 m num quadro só quando a distância
passa de `attack_range` 1,6 (um quadro de andar a 7,375 m/s): dente de serra de 12 cm a uns 8 Hz. Inversões de lugar de
2 quadros: até 29/s num corredor elite (estresse de elites, sementes 1 e 3), até 11,7/s só de corredores elite, até
5,7/s nos corredores comuns (4,875 m/s, passo de 8 cm). [D] a lógica de andar do `_behave_pulse` não mudou desde o
`c3011c0`; o C19 só põe mais corredores elite na tela. Correção (gameplay-engineer): a mesma histerese do Cavaleiro e do
Escudo (`MELEE_WALK_BAND` 0,8 m, `Enemy.closing`) no `_behave_pulse`: parado dentro do alcance, só volta a andar acima
de 1,6 + 0,8 m. Aceite: até 2 inversões de lugar por segundo por corredor no mesmo estresse, golpes com aviso de -1 a
+1 f iguais.

**P2, evidência.** O `reap_quarter_speed.mp4` não está a 0,25x: os 0,85 s do preparo ocupam 12 quadros do vídeo a 15 f/s
(cerca de 0,07 s do jogo por quadro, uns 0,9x), e a recuperação de 2,2 s não aparece inteira. Os números do
`boss_cadence` cobrem a falta; na próxima captura de Morvath, a 0,25x de verdade e até o fim da janela.

**Observado, para o art-director (não é cadência do C19):** nos três vídeos, ao levar golpe o herói vira silhueta
marfim chapada por 2 quadros (esqueleto quadros 41 e 42, corredor 23 e 24, Ceifa 18), contra a regra do
`Player.HURT_*` (clarear morno 0,05 s, nunca silhueta branca). Conferir no estilizado.
