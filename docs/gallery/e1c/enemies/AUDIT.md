# Auditoria dos inimigos comuns depois da E1b (qa-performance, 2026-11-16)

Queixa do Daniel: "todos estranhos agora", depois da E1b (atordoamento por golpe, andares com pé travado, passos por
minuto novos, recuo ao levar golpe, armas repintadas). Commit testado: `33f3d58` com a árvore de trabalho de hoje
(os gameplay-engineers estão mexendo no herói, no som e em Morvath; nada disso toca `horde.gd` nem os assados dos
inimigos comuns). Nenhum código de jogo foi alterado por esta auditoria.

## Como foi medido

1. **Sonda por tipo de inimigo** (fora do repositório, `data/enemy_audit.gd.txt` aqui é a cópia): roda o jogo real sem
   tela com o robô e, a cada passo da `Horde`, anota por tipo: tempo vivo, tempo atordoado por golpe (separado do
   círculo de luz, que prende 3 s por desenho), sequências de atordoamento, preparações começadas, cortadas e que
   viraram ataque, preparação recomeçada menos de 0,15 s depois do fim do atordoamento ("reanúncio"), trocas de clipe
   desenhado por segundo (a mesma escolha do `Horde.render`) e, nos quadros em que o clipe de andar está na tela, a
   velocidade real do corpo contra a que o clipe toca (`_speed`) e o ângulo entre o movimento e para onde ele olha.
   Comando: `godot --headless --path . --fixed-fps 60 -s <enemy_audit.gd> -- --bot --nosave --smoke=300 --seed=N`
   (sementes 5, 1, 2, 3; `data/audit_s*.txt`) e uma luta por tipo, 3 inimigos, `--start=shop --stress=3
   --stress-ids=<id> --smoke=40` (`data/stress_*.txt`).
2. **Vídeos na GPU** (RTX 5060, Forward+, Movie Maker a 30 qps, 1920x1080, espelho `eterra-gpu-e1c-qa`, 300 quadros
   cada, um por vez): `bot_<id>` (o robô luta contra 3 do tipo), `idle_<id>` (o herói parado, `--feel=none`: o ciclo
   inteiro do inimigo sem ser cortado) e `e1a_bot_<id>` (o mesmo na E1a, commit `ec5d757`, do espelho intacto
   `eterra-gpu-head`). Cada um em `_1x.mp4` (inteiro, 1280x720) e `_025x.mp4` (0,3 a 3,3 s recortados na luta, 4 vezes
   mais lento). Tudo abaixo de 3 MB.
3. **De perto**: `tools/enemy_lab.gd` (tiras de clipe, `frames/lab_*.jpg`) e `tools/walk_probe.gd` (passos por minuto e
   escorregamento do pé no andar reto).
4. Quadros recortados dos vídeos a 15 qps: `frames/*_15.jpg`.

Limites: os vídeos foram vistos em quadros soltos (não há como assistir em tempo real aqui); o que é "observado" abaixo
foi visto nesses quadros ou medido pela sonda; "inferência" é leitura do código sem prova em imagem. Sem som nas
gravações avaliadas. A câmera do jogo mostra os inimigos pequenos (60 a 120 px de altura a 1080), então detalhes de pé
e joelho só foram vistos no laboratório.

## Números da sonda (4 descidas, seed 5, 1, 2, 3)

| Tipo | Atordoado por golpe | Sequência (mediana / p90 / máx) | Prep. / cortadas / ataques | Ataques por min vivo | Andar ok | No lugar | De lado | De costas |
|---|---|---|---|---|---|---|---|---|
| esqueleto | 6 a 9% | 0,29 / 0,32 / 0,57 s | 87 / 32 / 23 | 1,9 a 4,0 | 78 a 89% | 0% | 6 a 21% | 1 a 2% |
| corredor | 4 a 5% | 0,29 / 0,30 / 0,32 s | 3 / 1 / 1 | 0 a 1,8 | 84 a 95% | 0% | 5 a 14% | 0% |
| mago | 1 a 7% | 0,29 / 0,42 / 0,42 s | 43 / 3 / 37 | 10 a 12 | 34 a 64% | 1% | **35 a 66%** | 0% |
| besteiro | 5 a 7% | 0,29 / 0,57 / 0,57 s | 52 / 5 / 46 | 13,6 a 15,3 | 55 a 63% | **31 a 38%** | 2 a 6% | 0% |
| Escudo | 12 a 22% | 0,22 / 0,62 a 1,27 / 1,27 s | 39 / 21 / 14 | 6,8 a 11 | 95 a 99% | 0 a 1% | 1 a 4% | 0% |
| sacerdote (só stress) | 15% | 0,29 / 0,32 / 0,32 s | 9 / **7** / **1** | **1,8** | 0% | **99%** | 0% | 0% |
| Cavaleiro | 13 a 20% (com a quebra da armadura, 2,5 s) | | 9 / 0 / 9 | 11 | 38 a 67% | **21 a 58%** | 4 a 10% | 1 a 2% |
| ancião | 12 a 14% (círculo e armadura) | | 21 / 1 / 20 | 11 a 12 | 9 a 20% | 1% | **41 a 44%** | **35 a 49%** |

Os 52 a 81 `flinches` por descida (`RESULT`) **não travam ninguém**: a sequência típica é um golpe só (0,29 s), o p90
fica em 0,3 a 0,6 s nos comuns. As travas de 2,5 a 3,2 s vistas no Cavaleiro e no ancião são o círculo de luz (3 s +
um tique) e a quebra da armadura (`armor_stagger` 2,5), ambos por desenho. O que trava de fato é o **sacerdote**:
de 9 preparações, 7 foram cortadas e 7 recomeçaram logo depois do atordoamento; 1 ataque em 33 s.

## Problemas, do mais grave ao menos

### P1. O andar toca parado, de lado e de costas (pé escorrega ou anda no lugar). Grave, todos.
- **Observado**: sacerdote 99% do tempo de andar sem sair do lugar (passos no lugar visíveis em
  `frames/bot_priest_15.jpg`, o da direita alterna os pés com o corpo fixo; `bot_priest_025x.mp4`); besteiro 31 a 38%
  no lugar; Cavaleiro 21 a 58% no lugar; mago 35 a 66% de lado; ancião 35 a 49% de costas e 41 a 51% de lado;
  esqueleto 6 a 22% de lado (tabela acima).
- **Causa** (código, `scripts/game/horde.gd`): o `render` escolhe o clipe pelo estado (`WALK` = andar) e a cadência
  pela velocidade pretendida (`walk_rate(_speed(e), ...)`), nunca pelo que o corpo andou nem para onde. Casos:
  sacerdote com `speed` 0 cai no ritmo de reserva 0,6 (`walk_rate`: `clampf(speed / 2.3, 0.6, 1.6)`) e anda no lugar
  para sempre; besteiro em `retreat_t` já além de `retreat_far` (8,75 m) fica parado no `return` do `_behave_ranged`;
  Cavaleiro (`_behave_melee_walk`) para a menos de `radius + R + 0,5` e segue no andar; mago, ancião, esqueleto e
  corredor andam de lado (`toward.rotated(side * PI/2) * 0.35` no mago, `* 0.5` no ancião e no corredor, o círculo a
  0,8 do esqueleto) e de costas (ancião `pos -= toward`, esqueleto `-0.5`) olhando para o herói, com o clipe de andar
  para frente a toda velocidade: a 0,35 da velocidade o pé do mago corre 2,3 m/s mais rápido que o chão.
- **Inferência sobre o "agora"**: esse código é o mesmo da E1a (o diff `ec5d757..HEAD` em `horde.gd` só acrescentou o
  atordoamento). O que mudou foi o andar: com o pé travado no assado (E1b-A1 a A3, `_foot_lock`) o pé fica cravado no
  chão no andar reto, então qualquer andar de lado, de costas ou parado agora lê como patinação (antes o pé já
  escorregava um pouco em tudo e disfarçava). Comparar `e1a_bot_mage_025x.mp4` com `bot_mage_025x.mp4`.
- **Correção recomendada** (dono: gameplay-engineer, `horde.gd`): o desenho segue o corpo. Velocidade real
  `v = (pos - last_pos) / dt` suavizada (0,1 s); abaixo de 0,3 m/s toca `idle`; acima, o andar no `walk_rate(|v|, ...)`
  (não no `_speed`); se o ângulo entre `v` e o rosto passar de 60 graus, o corpo vira para onde anda (giro de 1200
  graus/s, o do Hades) e só volta a mirar o herói na preparação. Sacerdote com `speed` 0: sempre `idle` fora do
  ataque. Teste para o dono: nenhuma figura com o clipe de andar a menos de 0,3 m/s nem com mais de 60 graus entre
  movimento e rosto (a sonda dá as duas contas por tipo).

### P2. Nenhuma recuperação depois do golpe: o esqueleto dá o bote e já sai correndo. Grave, esqueleto e corredor.
- **Observado**: `frames/idle_skel_15.jpg` (herói parado): o esqueleto termina o bote dentro do corpo do herói e no
  quadro seguinte está de novo no clipe de correr em volta dele; o outro já brilha a lâmina da próxima preparação
  0,3 a 0,5 s depois (`idle_skeleton_025x.mp4`).
- **Causa**: `_behave_runner` (esqueleto) volta a `WALK` assim que acaba `lunge_time` 0,3 s; `_behave_pulse`
  (corredor) depois de 0,4 s. A espera (`attack_cooldown` 1,4 vezes 0,8 a 1,3) é gasta andando em círculo, não parada.
  No Hades a janela é parada: Guard **2,1 s** (elite 1,5), Radiator 1,35 s, Mage 0,7 a 0,9 s (estudo, seção 4.2).
  É a janela de punição; sem ela o inimigo parece não ter peso e o golpe parece não ter custo para ele.
- **Correção** (dado novo `EnemyDef.recover_time`, no `_enemies` do `make_data.gd`; estado `RECOVER` como o de Morvath
  ou o fim do clipe `attack` segurado): esqueleto 2,1 s (elite 1,5) como o Hades, ou 1,5 s se o Game Director quiser
  manter o ritmo mais rápido; corredor 1,35 s; Escudo depois do golpe curto 1,1 s (a investida já para 0,8 s, subir
  para 1,1); besteiro 0,6 s antes de fugir; mago 0,8 s. Golpe sofrido na recuperação não corta nada (ela já é a
  janela).

### P3. O golpe do esqueleto não aparece: a lâmina salta do alto para o fim do corte. Grave, esqueleto (e elite).
- **Observado no laboratório**: `frames/lab_skel_wind_side.jpg` (preparação de 0 a 0,9 s: a lâmina vai para trás e
  para cima) e `frames/lab_skel_atk_side.jpg` (o clipe de ataque de 0 a 1,1 s): no ponto onde o jogo começa o ataque
  (0,605 s) o corpo já está agachado com a lâmina embaixo.
- **Causa** (inferência do código, confirmada pelas poses): a preparação é o `Sword_Attack` de 0,1 a 0,3 s esticado
  (`tools/bake.gd`, `"windup"` do esqueleto); o ataque começa em `kind.attack_time * IMPACT_SHARE` (0,55 de 1,1 s:
  `Sword_Attack` a 0,705 s) no `Horde.render`. Os 0,4 s do meio, a descida da lâmina, nunca são desenhados; o ataque
  dura só 0,3 s (`lunge_time`) e corta para o andar no meio do clipe.
- **Correção**: no `render`, quando o tipo tem clipe `windup` próprio, o `attack` começa onde a preparação parou
  (assar o `attack` do esqueleto de 0,3 a 1,2 s do `Sword_Attack` e tocar do 0, com a descida nos primeiros 0,12 s);
  o resto do clipe vira a recuperação do P2.

### P4. Troca de clipe seca, sem mistura; golpe sofrido emenda direto na corrida. Média, todos (pior nos pesados).
- **Observado (sonda)**: 0,6 a 1,7 trocas de clipe por segundo de vida; do golpe sofrido direto para a corrida 25 a 34
  vezes por descida nos esqueletos; no Escudo e no sacerdote o golpe sofrido vira parado e depois andar em 0,23 s
  (7 quadros a 30 qps: três clipes; `hit_idle` 12 a 25 e `idle_walk` 4 a 15 por descida no Escudo).
- **Causa**: o `CrowdRenderer` mistura só poses do mesmo clipe (pose e próxima pose); entre clipes é corte seco. Nos
  pesados `HEAVY_HURT` 0,12 s mostra o golpe sofrido e o resto do atordoamento (`stun_time` 0,23 s do Escudo) é `idle`.
  A E1b dobrou a frequência disso: todo golpe agora atordoa e reinicia o golpe sofrido (`Horde.flinch`, `hurt_t`).
- **Correção** (gameplay-engineer, `horde.gd` e `crowd_renderer.gd`): mistura de 0,1 s entre clipes (a pose de
  saída do clipe velho como `pose`, a primeira do novo como `next`, fração subindo em 0,1 s; as duas estão na mesma
  textura de poses, nada a assar); golpe sofrido dos pesados do tamanho do atordoamento (sem o `idle` de 0,1 s no meio).

### P5. Sacerdote preso no ciclo "prepara, apanha, prepara de novo". Média, sacerdote (e reanúncios em todos).
- **Observado (sonda)**: sacerdote 9 preparações, 7 cortadas, 7 recomeçadas menos de 0,15 s depois do atordoamento,
  1 ataque em 33 s; reanúncios em todas as descidas (esqueleto 3 a 8, Escudo 2 a 11). Cada reanúncio toca de novo o
  som de preparação e, cortado, o `interrupt` (inferência: `Horde._set_state` toca o som a cada `WINDUP`).
- **Causa**: `Horde.interrupt` deixa a preparação cortada pronta ("anunciada de novo inteira"); o sacerdote parado
  (velocidade 0) e o esqueleto a menos do alcance recomeçam no primeiro quadro livre. Atordoamento curto: `STUN` 0,3 s
  contra 0,5 s (golpes 1 e 2) e 1,1 s (giro) do Hades (`make_data.gd` linha 166; estudo, seção 1.1 e 4.1).
- **Correção**: depois de uma preparação cortada, espera de 0,5 s antes de outra (`e.cooldown = max(e.cooldown,
  0.5)` no `interrupt`); `STUN` 0,5 e `stun_heavy_time` 1,1 se o Game Director quiser o número do Hades (aumenta o
  tempo atordoado por golpe de 6 a 9% para perto de 15%; não cria travas: a sequência típica é um golpe só).

### P6. Esqueleto corre devagar demais para o corpo (passo flutuante). Média, esqueleto.
- **Observado**: `tools/walk_probe.gd`: esqueleto 96 passos por minuto no `Running_B` a 0,85x, escorregando 2,8 cm;
  a tira `frames/lab_skel_walk_side.jpg` mostra 3 de 5 quadros com os dois pés no ar. Corrida a 96 passos por
  minuto com fase de voo lê como câmera lenta (uma corrida de verdade fica entre 150 e 180).
- **Causa**: velocidade 3,75 m/s (`300 / U`; o Guard do Hades anda a 1,6 m/s), um clipe de corrida longa, sem
  `"stride"` (ele não ganhou a trava de pé da E1b).
- **Correção** (gameplay-engineer com o art-director): manter a velocidade (decisão do Daniel de inimigos mais rápidos)
  e dar ao esqueleto o tratamento do mago, `"lock": true, "stride": 0,6, "lift": 0,5` (cerca de 150 passos por minuto,
  medir com `walk_probe.gd -- skeleton=kaykit:Running_B:0.6`), ou voltar a 1,6 a 2,0 m/s com um andar. O ancião anda
  com o clipe a 0,74x (67 passos por minuto), também em câmera lenta: `ELDER_STRIDE` 1,2 para 0,9.

### P7. Besteiro com a besta sobre a cabeça. Média, besteiro (existia na E1a).
- **Observado**: `frames/lab_archer_states_game.jpg` e `lab_walks_runner_mage_archer_guard.jpg` (3ª linha): braço
  direito erguido e a besta deitada sobre a cabeça como um chapéu, andando e parado.
- **Causa**: `CROSSBOW_GUARD`/`CROSSBOW_TROT` usam o braço do `Pistol_Idle` (arma erguida ao lado da cabeça) com a besta
  a `CROSSBOW_SCALE` 0,5 (`tools/bake.gd`). A mira (`"aim"`) é o mesmo `Pistol_Idle`: a preparação não muda a pose.
- **Correção** (art-director decide a pose; gameplay-engineer assa): braço baixo segurando a besta à frente da cintura
  no andar e no parado (guarda do `Idle` ou `Sword_Idle` no braço direito) e a besta subindo ao ombro só no `aim`.

### P8. O bote do esqueleto atravessa o herói. Baixa a média.
- **Observado**: `frames/idle_skel_15.jpg`, linhas 4 a 6: esqueletos dentro do corpo do herói depois do bote.
- **Causa**: o `ATTACK` não passa por `keep_off_target` e anda `lunge_speed * lunge_time` = 8,75 x 0,3 = 2,6 m
  (o do Hades, estimado, 1,2 m).
- **Correção**: o bote para no contorno do herói (como a esquiva do Hades não, como o corpo sólido do resto do jogo)
  ou `lunge_time` 0,15 (1,3 m).

### P9. Avisos. Baixa.
- O aviso no chão some na hora quando o golpe corta a preparação (`Horde.interrupt`, por desenho do GF-12): correto.
- Várias linhas vermelhas de esqueletos se sobrepõem num bloco só quando dois preparam juntos (`frames/idle_skel_15.jpg`):
  sem atraso entre os botes dos esqueletos (o besteiro tem `max_attackers` 2; o esqueleto não). Sugestão: no máximo 2
  esqueletos preparando ao mesmo tempo (`max_attackers` 2 no `_enemies`).
- O golpe curto do Escudo começa o aviso já em 43% do preparo (`state_t = attack_windup - close_windup`), então o
  brilho do escudo sai pela metade (inferência pelo código; não visto em quadro).

### P10. O corredor quase nunca ataca. Baixa (não é "estranho", é papel vazio).
- 0 a 2 preparações por descida, 0 a 1,8 ataques por minuto vivo: morre antes (45 de vida, alcance 1,6 m).
  Decisão de design (Game Director), não de animação.

## O que não está estranho
- Atordoamento em cadeia: não há (ver os números). Os `flinches` altos vêm de muitos golpes curtos em alvos que
  morrem em 2 ou 3.
- O escorregamento do andar reto está abaixo de 3 cm em todos (`walk_probe.gd`): o pé travado funciona; o problema é
  o andar tocado onde o corpo não anda para frente (P1).
- Mago e besteiro atacam no ritmo do Hades (10 a 15 por minuto vivos).

## Arquivos
- Vídeos: `bot_<id>_1x.mp4` e `_025x.mp4` (skeleton, runner, mage, archer, guard, priest, knight, priest_elder,
  elites), `idle_skeleton|guard|runner_*` (herói parado), `e1a_bot_skeleton|mage|guard_*` (E1a).
- Quadros: `frames/`. Dados da sonda: `data/`.
- AVIs originais (80 MB cada): `C:\Users\danie\tools\qa\e1c_enemies\`.
