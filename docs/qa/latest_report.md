# Relatório de QA e desempenho: C10 ("Limpar e medir") e C11 ("Câmara do Selo")

- **Data**: 2026-11-16, madrugada (cerca de 2 h de trabalho).
- **Branch**: `arpg-3d`, **commit testado `6bab080`** (HEAD; C10 = `dcf6632`, `196f33c`; C11 = `6b16045`, `482eb6f`,
  `6bab080`). Árvore limpa no começo; o QA não mudou código de jogo, arte, testes nem ferramentas do projeto.
- **Antes**: `2de07b0` (fim do ciclo 9, salão) e `196f33c` (fim do C10, salão), extraídos com `git archive` em
  `/home/dani/games/qa1011-before` e `/home/dani/games/qa1011-c10`, espelhos `C:/Users/danie/tools/eterra-gpu-qa1011b` e
  `-qa1011c` (todos apagados ao fim).
- **Ambiente**: WSL2 (Linux 6.18) para importação, testes, simulações e exportação (Godot 4.7.2 Linux). Capturas, vídeos e
  medidas de quadro na **placa de vídeo real** pela Godot 4.7.2 de Windows (`tools/gpu.sh`, Vulkan 1.4.357, Forward+, NVIDIA
  GeForce RTX 5060 Laptop GPU), **na tomada** (`BatteryStatus` 2, 100%, lido antes de cada medida). A folha de quadros do
  quadro de impacto foi gravada na Godot de Linux com OpenGL na mesma placa (D3D12 do Mesa, `xvfb-run`). **Sem som**.
  Nenhum teste com gente.

## Veredito

**Pronto para o Daniel testar** (C10 e C11 numa entrega), com duas ressalvas visuais de gravidade média que não impedem
jogar (M-1 Morvath quase branco quando queima; M-2 o herói desenhado em cima do sarcófago e das velas na borda leste e
sul). Evidência: 0 `SCRIPT ERROR` e 0 `Parse Error` em importação, `check.gd`, testes, 368 simulações, 9 partidas de
regressão, 45 capturas e 6 gravações; **413 testes, 413 passando, 0 falhando, 0 arriscados** (o `test_only_finishers_glint`
deixou de ser arriscado); fluxo do título ok; exportação de Windows sem erro; nenhuma luta da câmara com o robô preso; a
câmara vence mais que o salão com os mesmos kits (57 de 64 contra 43 de 64 com reação 0,25) e é cerca de 1 ms mais leve por
quadro (4,0 a 4,1 ms a 1080p, p90 até 4,78 ms). O julgamento visual é do `art-director` e do Daniel; o balanceamento, do
Gameplay Engineer e do Daniel.

## 1. Checagem, testes, regressões e versão

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | código 0, **0 SCRIPT ERROR, 0 Parse Error** |
| `godot --headless --path . -s tools/check.gd` | código 0, `CHECK ok`, **0 erros** |
| `tools/test.sh` | **39 arquivos, 413 testes, 413 passando, 0 falhando, 0 arriscados**, 67026 asserções, 32,5 s. Inclui `test_boss_exits.gd` (saída andando para foice 68 pares, lâminas 262, investida 89, e os demais padrões, 0 precisando da esquiva), `test_boss_chamber.gd`, `test_floor_shape.gd`, `test_impact_frame.gd`, `test_comfort_ui.gd` |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** |
| `godot --headless --path . --export-release "Windows Desktop" <scratch>/ASelagem.exe` | código 0, sem aviso nem erro, 197 MB (pacote embutido). Não copiado para lugar nenhum; apagado |

Partidas do robô (`tools/smoke.sh`, reação 0, HEAD):

| Opções | Resultado |
|---|---|
| `300 --seed=5` | **venceu** (`ENDING`), 170,5 s, Morvath aos 59,2 s (sala 5), luta 107,7 s |
| `300 --seed=1` | **venceu**, 169,0 s, Morvath aos 60,6 s |
| `300 --seed=3` | **venceu**, 180,6 s, Morvath aos 74,7 s |
| `120 --start=boss --boons=25 --seed=5` | **venceu**, 88,9 s, 8 dons, luta 85,3 s |
| `120 --start=miniboss --seed=5` | `PLAY` aos 116,5 s, Morvath na fase 3 |
| `60 --start=fountain --seed=5` | `PLAY`, `max_alive` 8 |
| `60 --start=shop --seed=5` | `PLAY`, Morvath na fase 2 |
| `120 --stress=300 --seed=5` | 309 abates, `max_alive` 300, sem erro; `step_ms` ver seção 3 |

Em todas, só o `ERROR: ... resources still in use at exit` de sempre.

## 2. Métricas da luta (simulações do robô)

Tabelas completas, kits e comandos em `docs/gallery/boss_arena/METRICAS.md`. 4 kits de 6 dons com `firmeza` em cada
(fogo, geada, luz, sorteados), reação 0 e 0,25, 8 sementes, com e sem `--bot-kite=0.2`, em três versões; mais 8 partidas
inteiras com reação 0,25 por versão e arena. **368 partidas, 0 com erro de script.**

| Vitórias | Câmara `6bab080` | Salão C10 `196f33c` | Salão C9 `2de07b0` |
|---|---|---|---|
| reação 0, sem / com afastamento | 32/32, 32/32 | 32/32, 31/32 | 31/32, - |
| reação 0,25, sem / com afastamento | **29/32, 28/32** | 22/32, 21/32 | 25/32, - |
| partidas inteiras (0,25), sem / com afastamento | **4/8, 4/8** | 1/8, 1/8 | 1/8, - |

- Investida com afastamento na câmara: **pelo menos 1 em todas as 72 lutas** (média 1,6 a 3,2); ela nunca acertou o robô.
- Preso: **0** em todas as 136 lutas da câmara; nenhuma morte presa.
- Ritual, mediana: 6,2 a 15,6 s por configuração na câmara; **10,8 e 11,8 s nas partidas inteiras com reação 0,25**.
- Duração nas vitórias, medianas: 92 a 128 s sem afastamento, 113 a 162 s com.
- Mortes da câmara com reação 0,25: sem afastamento 3, todas na fase 4; com afastamento 4 (fases 2, 3, 3, 4). Dano por
  ataque: mortos, maldição e tempestade dominam sem afastamento; com afastamento as lâminas sobem (100 de dano na geada).

## 3. Desempenho

**Na placa de vídeo, 1920 x 1080, na tomada** (sonda `gpuperf9.gd`, 300 quadros por medida, 3 rodadas por cena e versão,
27 medidas; comando e tabela completa no `METRICAS.md`):

| Cena | Câmara `6bab080` (p90) | Salão C10 `196f33c` (p90) | Salão C9 `2de07b0` (p90) |
|---|---|---|---|
| fase 1 | **3,99 ms** (4,25 a 4,47) | 4,92 ms (5,25 a 5,31) | 4,97 ms (5,20 a 5,38) |
| ritual | **4,07 ms** (4,47 a 4,65) | 5,21 ms (5,79 a 5,83) | 5,15 ms (5,72 a 5,77) |
| fase 4 | **4,11 ms** (4,24 a 4,78) | 4,93 ms (5,37 a 5,60) | 4,86 ms (5,23 a 5,47) |

- C11: meta p90 até 6,5 ms **cumprida** (máximo 4,78); a câmara é 0,8 a 1,1 ms mais leve que o salão (cerca de 245 FPS).
- C10: C10 contra C9 no salão, +0,06 (ritual), +0,07 (fase 4), -0,05 (fase 1) ms: meta de no máximo +0,2 ms **cumprida**.
- Simulação sem tela com 300 inimigos (`tools/smoke.sh 30 --stress=300 --seed=5`, 185 a 212 de pé): `step_ms` 1,74 (HEAD),
  1,47 (C10), 1,79 (C9); aos 10 s com 243 de pé, 2,31 / 2,27 / 2,15. Sem regressão clara (uma medida por versão).
  O `step_ms` do `--smoke=120` deu 0,17 no HEAD contra 0,05 no C10 nas duas repetições, mas ele é uma média móvel lida no
  fim, com a sala já limpa e o jogo na escolha de dom: não mede a multidão. Fica como observação (B-3).
- Não medido: celular, placa de vídeo fraca, navegador (Compatibility) com números.

## 4. Capturas e vídeos

- `docs/gallery/boss_arena/` (C11): as dez pedidas (`01_arena_vazia` a `10_vitoria_selagem`) mais oito variantes (`03b`,
  `04b`, `05a`, `07b`, `08b`, `09b`, `10a`, `10b`), `selo_estados.jpg`, `borda_e_camera.jpg`, cinco antes e depois
  (`before_after_arena`, `_investida`, `_ritual`, `_tempestade`, `_vitoria`), `lado_a_lado_referencia.jpg` (cópia do
  `work/`; a metade esquerda é a pintura de IA), `boss_arena_full_fight.mp4` (vitória, semente 4, 2:07) e
  `boss_arena_full_fight_semente1_derrota.mp4` (a semente do vídeo do ciclo 9, derrota na fase 4 com Morvath a 51),
  `CAPTURAS.md`, `METRICAS.md`. Olhei todas; comandos, momentos e descartadas no `CAPTURAS.md`.
- `docs/gallery/cycle10/` (C10): golpe final sem branco, escudo do ritual (e recorte), orbe do feiticeiro (e recorte),
  contador do ritual, opções, "Derrotado por", golpe sofrido comum e amaldiçoado, queimadura (três momentos, o salão comum e
  o `196f33c`), fase 4, `folha_quadros_2min.jpg`, `folha_quadros_pb_ligado_desligado.jpg`, `bloqueio_de_corpo.mp4` (27,5 s),
  `runs_exemplo.jsonl` (3 partidas), `CAPTURAS.md`.
- Gravações: **1280 x 720** apesar do `--resolution 1920x1080` (tamanho do projeto), sem som. As capturas são 1920 x 1080.

## 5. Critérios de aceite

### C10

| Critério | Estado | Evidência |
|---|---|---|
| 0 erros de script | **SIM** | seção 1; 368 simulações sem `SCRIPT ERROR` |
| `tools/test.sh` sem arriscados | **SIM** | 413/413, 0 arriscados |
| Folha de quadros: no máximo 12 P&B em 2 min | **SIM** | 4 quadros de impacto em 125 s (SATAVG 2,6 a 3,1 contra mediana 23,2), `cycle10/folha_quadros_*` |
| 0 P&B com a opção desligada | **SIM** (116 s, não 120) | 0 em 6979 quadros e 0 em 6087 (as duas gravações caíram com o driver D3D12 do WSL perto do fim) |
| Ritual com mediana abaixo de 15 s, partidas inteiras, robô 0,25 | **SIM** | 10,8 s (câmara), 10,3 s (`196f33c`) |
| Pelo menos 1 investida por luta com `--bot-kite` | **SIM** na câmara (72 de 72); **PARCIAL** no salão do C10 (64 de 64 começando no chefe, mas 2 de 8 partidas inteiras sem nenhuma) | `METRICAS.md` |
| `user://runs.jsonl` com 3 partidas | **SIM** | `cycle10/runs_exemplo.jsonl` (`--runlog`) |
| `victory` + 0,4 s sem Morvath branco | **SIM** | `cycle10/golpe_final_sem_branco.jpg` |
| Quadro a 1080p sem piora acima de 0,2 ms | **SIM** | +0,07 ms no pior caso (seção 3) |
| Evidências: vídeo do bloqueio de corpo | **PARCIAL** | `bloqueio_de_corpo.mp4` é o robô lutando cercado de corpos sólidos, não um andar dirigido contra eles (falta opção, B-4) |
| Evidências: B1, B2, N3, contador | **SIM** | `golpe_final_sem_branco`, `escudo_ritual`, `orbe_feiticeiro`, `contador_ritual` |
| Clarões brancos fora da luta (o que a direção proíbe) | **PARCIAL** | Morvath queimando fica quase branco em parte dos quadros (M-1), já no `196f33c` |

### C11

| Critério | Estado | Evidência |
|---|---|---|
| Chão circular de 11 a 13 m, em dado, contas documentadas | **SIM** | `test_the_floor_is_a_circle_of_eleven_to_thirteen_meters`; `docs/design/boss_arena.md` |
| Teste de saída para cada padrão nas 12 x 12 posições | **SIM** | `test_boss_exits.gd`, 7 testes passando |
| 64 lutas (4 kits com defesa, reação 0 e 0,25): 0 erros | **SIM** | 128 lutas na câmara (com e sem afastamento), 0 erros |
| Investida pelo menos 1 por luta com `--bot-kite` | **SIM** | 72 de 72 |
| Robô 0,25 vence igual ou mais que no salão com os mesmos kits | **SIM** no total (57/64 contra 43/64); por kit, 7 de 8 linhas (sorteados sem afastamento: 7/8 contra 8/8) | `METRICAS.md` |
| Nenhuma morte "presa" | **SIM** | `bot.stuck` 0 e `died_stuck` false em 136 lutas |
| Herói a mais de 18% da borda; Morvath e avisos dentro do quadro | **SIM** nas capturas olhadas (medido a olho; menor folga 21%, `borda_e_camera` com `12,0`) | `borda_e_camera.jpg`, `01` a `10` |
| Quadro a 1080p na tomada até 6,5 ms no p90, três cenas | **SIM** | p90 máximo 4,78 ms |
| Revisão do `art-director` sem clarão branco e com o selo nos cinco estados | **NÃO avaliado pelo QA** (cabe ao `art-director`); material pronto em `selo_estados.jpg`; ver M-1 e as observações O-1 a O-3 | |
| As quatro fases funcionam, centro usado, tempestade sem ataque inevitável | **SIM** (robô e testes) | vídeo da vitória, `05`, `09`, `test_the_storm_has_a_way_out_of_both_waves` |
| Evidências do brief (pasta, antes e depois, vídeo, condições) | **SIM**, com o antes e depois da investida em comandos diferentes (explicado no `CAPTURAS.md`) e o vídeo em 720p | `docs/gallery/boss_arena/` |

## 6. Falhas e observações por gravidade

**Nada impede o Daniel de jogar**: nenhuma falha crítica ou alta.

### Média
- **M-1. Morvath fica quase branco quando queima** (dom de fogo). Responsável sugerido: `environment-artist` (corpo no
  `crowd.gdshader`: soma de `burn`, `flash` e `white_from`) com o `gameplay-engineer`. Passos: `RES=1920x1080 tools/gpu.sh
  shot x.png --nosave --seed=5 --start=boss --bot --boon-ids=golpe_brasa,pesado_brasa,circulo_brasa,brasas --shot-at=10`
  (também `--shot-at=12`). Aos 6,8 s o corpo está na cor dele com a brasa; aos 9,8 e 11,7 s fica quase todo branco, com as
  bordas do manto acesas (`cycle10/queimadura_fogo.jpg`, `_t12`). **Já acontece no `196f33c`** (`queimadura_fogo_196f33c.jpg`):
  não é regressão da câmara; a correção do C10 (ART-007) vale para parte dos quadros. Fere a regra de "nada de branco no corpo".
- **M-2. Na borda leste e sul o herói aparece em pé sobre o sarcófago e sobre as velas da balaustrada.** Responsável
  sugerido: `environment-artist` (`boss_chamber.gd`, posição e tamanho dos sarcófagos e das velas, que cresceram no
  `6bab080`). Passos: `RES=1920x1080 tools/gpu.sh shot x.png --nosave --seed=5 --start=boss --no-boss --hero-at=12,0
  --shot-at=2` (o herói desenhado em cima da tampa do sarcófago sudeste, com o raio-x de "atrás"); com `--hero-at=8.5,8.5`
  ele fica sobre as velas (`borda_e_camera.jpg`). Não prende (a colisão é o círculo), mas lê como se ele subisse no
  cenário. Teste sugerido para o dono: nenhuma malha de cenário acima do chão a menos de 12,5 m + raio do herói do centro.

### Baixa
- **B-1. A investida não acontece com o herói parado na entrada** (é a regra: 9 m e 8 m livres). O comando do antes e depois
  da especificação (`--boss-only=dash` sem robô) espera para sempre na câmara. Capturas usam `--bot --bot-kite=1`.
  Responsável: `art-director` (ajustar o comando na `boss_chamber_spec.md`, seção 9).
- **B-2. Gravação em 1280 x 720** (tamanho do projeto). Para 1080p, uma opção de teste (dono `gameplay-engineer`) que mude o
  tamanho do viewport só na gravação, ou um `override.cfg` só no espelho de gravação (a HUD ficaria menor).
- **B-3. `step_ms` no `RESULT` do `--stress` é lido no fim**, com a sala limpa: 0,17 (HEAD) contra 0,05 (C10) não diz nada
  da multidão. Sugestão ao `gameplay-engineer`: guardar o pico ou a média enquanto há inimigos de pé.
- **B-4. Falta uma opção para o vídeo dirigido do bloqueio de corpo** (REG-001): por exemplo `--walk-to=x,z` (anda reto,
  sem atacar), `--dash-at=s` e uma fila de inimigos parados (`--stress-line`). Dono `gameplay-engineer`.
- **B-5. No Compatibility (Linux, OpenGL) o jogo liga névoa volumétrica e SSR mesmo assim**, e a Godot avisa no log
  (`game.gd:244` e `:255`, `_build_world`). Sem efeito na tela; dono `environment-artist`.
- **B-6. Tela de derrota mostra "Nível 1"**, e o modo por salas não tem níveis. Dono `ui-ux-designer`.

### Observações para o `art-director`
- **O-1.** Na câmera do jogo a espada gravada na tampa dos sarcófagos e o emblema dos estandartes leem como cruz
  (`01_arena_vazia.jpg`, sarcófagos à direita; `fase4_clima.jpg`). Critério 4 da especificação.
- **O-2.** Na vitória + 3,3 s (`10_vitoria_selagem.jpg`, `selo_estados.jpg` quadro 5) a linha da rachadura sobre o leão
  ainda é escura e arroxeada (pode ser a "cicatriz" pedida; critério 8).
- **O-3.** Com `--hero-at=9.7,5.7` o herói fica na frente do pilarete, não atrás: o pontilhado de transparência não aparece
  naquele quadro (o ponto da especificação talvez precise de outro valor).
- **O-4.** A faixa de entrada na câmara diz "A Cripta" (nome da sala), não "Câmara do Selo"; decidir se é o desejado.

## 7. Limitações do ambiente

- WSL2: testes e simulações sem tela no Linux; a GPU só pela Godot de Windows (`gpu.sh`, uma por vez, janela na tela) ou
  pelo OpenGL sobre D3D12 do Mesa, que caiu duas vezes ("D3D12: Removing Device") em gravações longas, por isso a gravação
  com o quadro de impacto desligado tem 116 s.
- Sem som em tudo (WSL sem áudio; o `--shot` silencia as gravações).
- Gravações em 720p (B-2). Nenhum teste com gente, nem em celular, placa fraca ou navegador com números.
- O desligar do quadro de impacto foi testado pelo save do Linux (copiado e restaurado); o save do Windows do Daniel não foi
  tocado. Não há opção de linha de comando para isso.
- A posição do herói na tela (regra dos 18%) foi medida a olho nas capturas, não por ferramenta.

## 8. O que ficou fora do repositório

Dados crus em `/home/dani/games/qa1011-out/` (linhas `RESULT` de cada simulação em `sim/`, `perf.txt`, `caps.log`, os
PNG originais, os scripts `run1.sh`, `an.py`, `cap.sh`, `perf.sh`, `mont.sh`); as gravações AVI e as cópias do projeto
foram apagadas.
