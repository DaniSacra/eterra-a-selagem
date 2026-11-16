# Relatório de QA e desempenho: E1a "Inimigos vivos"

- **Data**: 2026-11-16.
- **Testado**: a cópia de trabalho de `arpg-3d` com a E1a inteira **não commitada** sobre o `10944b1` (animação por textura
  de poses com mistura, 20 poses no andar, recuo ao levar golpe, passo medido, `RESULT` em JSON, armas repintadas, pé do
  Escudo). **Antes**: `10944b1` (`docs/gallery/e1a/before/BEFORE.md`) e, para as comparações que dependem da sessão, o
  mesmo commit rodado de novo hoje (cópia por `git archive` e espelho `eterra-gpu-head`). O QA não mudou código, arte nem
  testes; acrescentou `docs/gallery/e1a/after/` (detalhes, tabelas e comandos em `after/AFTER.md`) e este relatório.
- **Ambiente**: WSL2 (Godot 4.7.2 Linux, sem tela) para importação, testes, sonda e robô. Placa real pela Godot 4.7.2 de
  Windows (Vulkan 1.4.357, Forward+, RTX 5060 Laptop), espelho próprio `C:/Users/danie/tools/eterra-gpu-e1a`. **Notebook na
  tomada** em todas as medidas de quadro (`BatteryStatus=2`, `PowerOnline=True`, 87% a 92%, lido antes e depois). Som
  gravado pelo Movie Maker e descartado nos mp4; ninguém ouviu. Sem controle, sem celular, nenhum teste com gente.

## Veredito

**Pronto para o Daniel testar, com duas ressalvas escritas.** A E1a entrega o principal: a multidão e Morvath não repetem
mais pose em quadros seguidos (0 de 23 pares no andar, antes 43% a 65%; morte 0 de 39, antes 82%), todos os clipes têm o
número de poses pedido, o recuo aparece, os assados encolheram de 45 para 38 MB, a simulação ficou idêntica (mesma semente,
`RESULT` igual campo a campo) e nada regrediu (557/557, sonda 31/31, 8/8 descidas, 0 preso). Ressalvas:
1. **E1a-2 não passa para três figuras**: o pé de apoio do Escudo (10,7 cm), do Cavaleiro (10,2) e de Morvath (5,8) ainda
   desliza mais de 5 cm por passo. Está declarado no próprio teste (`STRIDE_PENDING`) e marcado para a E1b.
2. **Tempo só da GPU no limite**: +0,30 ms em média (0,20 a 0,41 por par) com 150 inimigos, medido intercalado com a base;
   o tempo de quadro total caiu 0,18 ms. Não piora o que o jogador vê, mas está exatamente no teto do aceite.

## 1. Checagem e testes

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | 0 `SCRIPT ERROR`, 0 `Parse Error` |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok` |
| `tools/test.sh` | **58 scripts, 557 testes, 557 passando, 0 falhando, 0 arriscados**, 104 890 asserções, 124,4 s (antes 541) |
| `godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain` | **`FEEL_SUMMARY 31/31 ok`**, 0 `LOST` |

Exportação de Windows e Web: não pedida, não feita.

## 2. Robô e números de combate

| Comando | Antes | Depois |
|---|---|---|
| `tools/smoke.sh 300` (sem semente) | Morvath aos 122,6 s, vence | Morvath (sala 7) aos 135,4 s, **vence**, `max_alive` 7, `step_ms_avg` 0,18 |
| `tools/smoke.sh 120 --start=boss --boons=25` (sem semente) | vence em 52,8 s | **vence** em 69,2 s (outros dons sorteados; sem semente não se compara) |
| `tools/smoke.sh 300 --seed=1..8` | 8/8 vencem | **8/8 vencem, `stuck` 0, `bot.stuck` 0; tempo, hp, abates e `max_alive` idênticos nas 8** |
| `--seed=5` 300 s e `--start=boss --boons=25 --seed=5`, base e depois rodados agora | | **0 diferenças** no `RESULT` fora de `step_ms*` e `fps` (dano 12 789 e 5 939 nos dois) |
| `--stress=150 --seed=5` | avg 1,28, pico 11,18 | **avg 1,02**, pico 12,66; 160 abates e dano 19 692 iguais |

Conclusão: o recuo é só desenho (o aceite do E1a-3 pede "nenhum número de combate muda": confirmado).

## 3. Desempenho

| Medida | Antes | Depois |
|---|---|---|
| `step_ms_avg` descidas | 0,18 a 0,22 | 0,18 a 0,20 |
| `step_ms_avg` estresse 150 | 1,28 | 1,02 |
| Quadro na GPU, 150 inimigos, 1080 sem vsync, **intercalado na mesma sessão** (3 + 3) | frame mediana 7,60 / 7,09 / 7,79 (7,49); gpu 6,31 / 6,36 / 6,31 (6,33); 1032 chamadas | frame 7,25 / 6,86 / 7,82 (**7,31**); gpu 6,72 / 6,56 / 6,60 (**6,63**); 995 chamadas |
| Os 3 do depois pedidos (`gpuperf9`, antes do intercalado) | (sessão do antes: frame 8,77 a 9,41, gpu 5,63 a 5,87) | frame 6,76 / 7,50 / 7,11; gpu 6,55 / 6,68 / 6,34 |
| `gpu.sh shot`, vsync, só referência | fps 128 / 115 / 120 | fps 117 / 127 / 132 |
| `du -sh assets/baked` | 45 MB | **38 MB** (teto 70) |

A sessão do antes e a base de hoje diferem em 1 a 2 ms no quadro: comparar o depois com os números do `BEFORE.md`
mostraria uma melhora falsa no quadro e uma piora exagerada na GPU. O que vale é o intercalado (`after/logs/gpu_perf_interleaved.log`).
Leitura: a mistura de poses no vértice custa cerca de 0,3 ms de GPU com 150 figuras (duas leituras de textura por vértice
mais a passada do contorno) e economiza CPU de render (1 lote por clipe em vez de 1 por pose: 37 chamadas a menos).
Não medido: placa fraca, Compatibility na GPU, celular.

## 4. Aceite item a item

| Item | Resultado | Evidência |
|---|---|---|
| E1a-1: pose repetida a 30 qps no andar = 0 | **passa** (0 de 23 nos quatro; golpe 0 de 9; morte 0 de 39) | `after/pose_repeats.txt`, `strip_blend_index.txt`, `pose_psnr_walk.txt`, `skeleton_walk_contact_12.png` |
| E1a-1: 20 poses no andar, golpe 8, parado 12, morte 16 | **passa** nos nove | `after/baked_poses.txt` |
| E1a-1: assados até 70 MB | **passa**, 38 MB | `after/baked_sizes.txt` |
| E1a-1: `step_ms` sem piora | **passa** | seção 3 |
| E1a-1: GPU sem piora acima de 0,3 ms | **no limite** (+0,30 GPU, -0,18 quadro) | `after/logs/gpu_perf_interleaved.log` |
| E1a-2: pé de apoio menos de 5 cm | **falha para 3 de 8 que andam** (Escudo 10,7, Cavaleiro 10,2, Morvath 5,8); esqueleto 2,4, mago 1,8, corredor 1,1, besteiro 1,7, ancião 4,5 | `after/baked_poses.txt` (`BakedModel.slide_per_step`) |
| E1a-3: recuo de 0,15 a 0,3 m em 3 quadros, que volta | **passa** na medida (0,24 m leve, 0,15 m pesado, pico no 3º quadro a 30 qps, volta em 0,3 s) | `after/compare/skeleton_hit_recoil_after.jpg`, `strip_blend_index.txt` |
| E1a-3: números de combate iguais | **passa** (0 diferenças) | seção 2 |
| E1a-4: armas | não refeito aqui (`after/weapons/`, revisão do `art-director`) | |
| E1a-5: `RESULT` em JSON | **passa** (13 de 13 linhas desta sessão lidas por `json.loads`; `test_result_json.gd`) | `after/logs/*.log` |
| E1a-QA | **passa** | `docs/gallery/e1a/after/` |

## 5. Falhas e regressões, por gravidade

Nenhuma falha crítica nem alta. Nenhuma regressão em teste, sonda, robô ou números de combate.

- **Média, E1a-2 incompleto (pés deslizando em 3 figuras)**. Reproduzir:
  `~/tools/godot/godot --headless --path . -s docs/gallery/e1a/after/tools/qa_e1a_poses.gd` (coluna `slide`), ou
  `tools/test.sh -gtest=res://tests/test_living_crowd.gd` (o `gut.p` imprime por figura). O teste passa porque tem a
  exceção `STRIDE_PENDING` (guard 0,12, knight 0,11, morvath 0,065). Responsável: `gameplay-engineer` (travar o pé no
  assado, E1b). Efeito colateral a revisar: para casar o passo, o Escudo anda a **2,01x** a velocidade do clipe (antes 1,41x)
  e o esqueleto a 0,85x (antes 1,6x), o mago a 0,74x (antes 1,52x); a cadência mudou bastante (`after/guard_walk_contact_12.png`,
  vídeos 0,25x). Decisão de aparência para o `art-director`.
- **Média, GPU no teto do aceite (+0,30 ms com 150)**. Reproduzir: o bloco intercalado de `after/AFTER.md` seção 3.
  Responsável: `gameplay-engineer` (`crowd_pose.gdshaderinc`; o contorno também lê as duas poses). Não passa de 0,3 na
  média; um par passou (+0,41).
- **Baixa, recuo pouco visível na câmera do jogo**: a 1080 o 0,24 m são uns 11 px e coincide com o achatamento e o clarão;
  no recorte da luta (`after/compare/fight_f90_101_before_after.jpg`) não se distingue com clareza do antes. O aceite
  pedia `--shot-on=hit` com os quadros seguintes: **não rodado** (medi pelas tiras com o `HitRecoil` do jogo e pelo
  vídeo). Responsável: `art-director` (decidir se basta) e `gameplay-engineer`.
- **Baixa, ferramenta**: o achado do `BEFORE.md` (`tools/enemy_lab.gd` não compila com `-s`) não foi reverificado nesta
  rodada; as tiras continuam usando `load()` do `crowd_renderer.gd`.

## 6. Avaliação pelas perguntas da diretriz (`docs/design/po_directive_guardian.md`)

Sem teste humano: nada aqui diz que o jogo é divertido.

**Game feel**
- *Comandos respondem na hora? Dá para encadear?* A E1a não mexe na mão: sonda 31/31, 0 apertos perdidos, igual ao C12d.
- *Ataques têm impacto?* O golpe agora desloca o corpo (0,24 m em 3 quadros a 60 qps) além do clarão e do achatamento.
  Nas tiras se vê; na câmera do jogo é discreto. Se o impacto "chega" no inimigo, só o teste com gente dirá.
- *Alguma animação ou pausa atrapalha?* O andar e a morte deixaram de engasgar. Ponto a observar no teste: a cadência nova
  (Escudo bem mais rápido, esqueleto e mago mais lentos que antes) e o deslize que resta em Escudo, Cavaleiro e Morvath.

**Visual**
- *Animação adequada?* Muito melhor que o antes: nenhum quadro repetido, transições regulares (PSNR 25 a 35 dB entre
  quadros em vez de alternar igual e salto), morte em 16 poses contínuas (`after/compare/strip_before_after_025x.mp4`). O
  esqueleto anda ereto, com a cabeça visível (antes curvado com a cabeça atrás da ombreira; `compare/skeleton_walk_contact_before_after.png`).
  A reação de golpe do esqueleto é pequena no corpo (quase a pose de parado; o deslocamento é que lê).
- *Inimigos legíveis?* Iguais ou melhores: mesma silhueta, armas sem as faixas chapadas (`stills/fight_f100.jpg`), a
  simulação é a mesma quadro a quadro.
- *O poder impressiona? Efeitos na direção de arte?* Fora do escopo da E1a; nada mudou nos efeitos do herói.
- *Parece jogo comercial?* A multidão em movimento deixou de denunciar o protótipo pela cadência; o deslize de pés nas
  três figuras pesadas e a reação de golpe ainda curta são o que resta. O julgamento final é do `art-director`.

## 7. Limitações

- Robô, não gente. Smokes sem semente não são comparáveis entre versões (só os com semente).
- Quadro na GPU: um notebook (RTX 5060 Laptop, escala 1,5 do Windows, render 2880x1620), na tomada; variação entre sessões
  de 1 a 2 ms, por isso o intercalado. Compatibility na GPU, placa fraca e celular não medidos.
- As tiras são o renderizador da multidão numa cena de laboratório (fundo liso), não a sala. Os vídeos da partida mostram o resto.
- Som não ouvido.
