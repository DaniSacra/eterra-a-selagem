# Relatório de QA e desempenho: ciclo 9 (luta de Morvath)

- **Data**: 2026-11-15, 21:25 a 22:15
- **Branch**: `arpg-3d`, **commit testado `b29e372`** (ciclo 9 completo: `3b22cea`, `ca7e97b`, `9aff1fc`, `579ce02`,
  `b29e372`). Durante o trabalho entrou o `1f9d49c`, que só muda `.claude/agents/game-director.md` e `CLAUDE.md`
  (`git diff b29e372 1f9d49c -- scripts data assets tools` vazio): o jogo testado é o mesmo do HEAD atual.
- **Antes**: `3b22cea`, extraído por `git archive` em `/home/dani/games/c9-before`, espelho
  `C:/Users/danie/tools/eterra-gpu-c9before` (os dois apagados ao fim).
- **Ambiente**: WSL2 (Linux 6.18) para testes e simulações sem tela (Godot 4.7.2 Linux). Capturas, vídeos e medidas de
  quadro na **placa de vídeo real** pela Godot 4.7.2 de Windows (`tools/gpu.sh`, Vulkan 1.4.357, Forward+, NVIDIA
  GeForce RTX 5060 Laptop GPU). **Sem som** (o WSL não toca áudio e as gravações saíram mudas, ver 4). Nenhum teste com
  gente: tudo abaixo é robô, captura ou medida.
- O QA não mudou código de jogo nem ferramenta do projeto. Arquivos novos: `docs/gallery/cycle9/` (18 capturas, 5
  montagens, 2 vídeos, `CAPTURAS.md`, `METRICAS.md`) e este relatório. Ferramentas temporárias fora do projeto
  (`/home/dani/games/c9qa/`, apagada ao fim) e a sonda `C:/Users/danie/tools/qa/gpuperf9.gd` (mantida, ao lado da
  `gpuperf8.gd`).

## Veredito

**Pronto para o Daniel testar**, com uma ressalva de medida: o desempenho tem 2 rodadas válidas por cena em vez de 3,
porque o notebook passou para a bateria no meio da medição (seção 3). Evidência: 0 `SCRIPT ERROR` e 0 `Parse Error` na
importação, no `check.gd`, nos testes, em 80 simulações, 36 capturas, 9 gravações e 18 medidas; 323 testes, 322
passando, 0 falhando, 1 arriscado (o conhecido); fluxo do título ok; as cinco partidas inteiras de regressão vencem
Morvath; as 18 capturas pedidas existem e mostram o que o nome diz; a luta inteira gravada termina na tela "Morvath foi
selado". A 1920 x 1080 na RTX 5060, na tomada, a luta fica em 5,4 a 5,5 ms por quadro (cerca de 180 FPS); o ciclo 9
custa +0,1 a +0,3 ms. Nenhuma falha crítica ou alta. O julgamento visual é do `art-director` e do Daniel; o
balanceamento é do Gameplay Engineer e do Daniel (as simulações mostram uma fase 4 dura com reação humana, seção 2).

## 1. Checagem, testes e partidas do robô

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | código 0, **0 SCRIPT ERROR, 0 Parse Error** |
| `godot --headless --path . -s tools/check.gd` | código 0, **0 SCRIPT ERROR, 0 Parse Error** |
| `tools/test.sh` | **27 arquivos, 323 testes, 322 passando, 0 falhando, 1 arriscado** (`test_only_finishers_glint`, "Did not assert", o conhecido), 35220 asserções, 12,5 s |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** |

Partidas do robô (`tools/smoke.sh`, reação 0), as mesmas no `3b22cea` para comparar:

| Opções | `b29e372` | `3b22cea` |
|---|---|---|
| `300 --seed=1` | **venceu** (`ENDING`), 194,0 s, Morvath aos 61,8 s, 2 dons | venceu, 175,4 s |
| `300 --seed=2` | **venceu**, 199,4 s, Morvath aos 73,9 s | venceu, 187,0 s |
| `300 --seed=3` | **venceu**, 182,1 s, Morvath aos 66,2 s | perdeu na fase 3 (Morvath com 1888), 137,9 s |
| `300 --seed=5` | **venceu**, 206,2 s, Morvath aos 62,9 s (sala 5) | venceu, 202,2 s |
| `300 --seed=7` | **venceu**, 207,9 s, Morvath aos 72,4 s | venceu, 193,2 s |
| `120 --start=boss --boons=25 --seed=5` | **venceu**, 95,6 s, 8 dons | venceu, 92,3 s |
| `120 --start=miniboss --seed=5` | `PLAY` aos 116,8 s, sala 5 | |
| `60 --start=fountain --seed=5` | `PLAY`, `max_alive` 8 | |
| `60 --start=shop --seed=5` | `PLAY`, Morvath na fase 2 | |
| `120 --stress=300 --seed=5` | `step_ms` 0,08, 308 abates (na bateria, ver 3) | `step_ms` 0,10 |

Em todas, só o `ERROR: 1 resources still in use at exit` com `2 ObjectDB instances were leaked` de sempre.

### O que foi automatizado e o que não

- Automatizado: os 323 testes GUT (inclui as regras de Morvath, fases, padrões com saída segura, diretor de ataques,
  maldição), o fluxo do título por teclado, 80 lutas do robô com métricas (seção 2), as regressões acima, 36 capturas e
  9 gravações na GPU, 18 medidas de quadro.
- **Não automatizado e não feito**: nenhum teste com gente (dificuldade real, leitura dos avisos por um jogador,
  controle). Som (não há saída de áudio no WSL e as gravações saíram mudas). Controle e teclado físicos. Navegador
  (`DRIVER=opengl3`) e versões exportadas (Windows e Web) não foram pedidos nesta rodada e não foram gerados. Celular
  e placa fraca: não medidos.

## 2. Métricas da luta (simulações do robô)

Detalhes, comandos e todas as tabelas em `docs/gallery/cycle9/METRICAS.md`. 64 lutas começando no chefe (fogo, geada,
luz com 6 dons cada, e 6 sorteios; reação 0 e 0,25 s; sementes 1 a 8) e 16 partidas inteiras. **São simulações**: o
robô não erra mira e lê o próximo aviso; a reação de 0,25 s só atrasa o que ele vê.

| Configuração | Reação 0 | Reação 0,25 | Tempo da luta nas vitórias (mediana) | Mortes com reação 0,25 (fase) |
|---|---|---|---|---|
| fogo | 8 de 8 | 2 de 8 | 99,7 s | 4: 4, 3: 1, 2: 1 |
| geada | 8 de 8 | 3 de 8 | 127,6 s | 4: 4, 3: 1 |
| luz | 8 de 8 | 1 de 8 | 97,8 s | 4: 7 |
| sorteados | 8 de 8 | 8 de 8 | 109,0 s | nenhuma |
| partida inteira (1 ou 2 dons) | 7 de 8 | 1 de 8 | 128,7 s | 2: 4, 3: 2, 4: 1 |

- Fases nas vitórias (mediana): 26 a 35 s, 40 a 56 s (com o ritual), 15 a 20 s, 15 a 20 s.
- Com reação 0,25, o que mais fere: os mortos invocados (16 a 26 golpes de 4 por configuração), a Tempestade (6 a 12
  golpes de 10) e a maldição (7 a 9 golpes de 6). A foice não acertou nenhuma vez nas lutas a partir do chefe.
- Ataques mais usados: foice (84 a 121 por 8 lutas), erupções (13 a 30), lâminas (18 a 36), maldição, tempestade,
  invocação. **A investida nunca saiu em 80 lutas** (ver M1).
- Janelas punidas: 79 a 90% com reação 0, 65 a 88% com 0,25. Reforços por luta: 10 a 12 (mediana), pico de 4 de pé (6
  numa partida inteira). Ritual: 20 s (o limite) na mediana das partidas inteiras.

## 3. Desempenho na placa de vídeo, 1920 x 1080, durante a luta

Sonda `C:/Users/danie/tools/qa/gpuperf9.gd` (nova, derivada da `gpuperf8.gd`): espera o momento pedido
(`--probe-wait=ritual`: Morvath no estado `RITUAL`; `phase4`: fase 4), descarta `--probe-settle` quadros e mede os 300
seguintes (5 s): mediana, média e p90 do quadro (relógio), tempo de GPU e de CPU de desenho, chamadas, primitivas, quantos
de pé e em que estado Morvath estava em cada quadro. Comando: `tools/gpu.sh run --rendering-driver vulkan --resolution
1920x1080 --fixed-fps 60 --disable-vsync -s C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave
--seed=5 --start=boss --bot <cena>`; fase 1: sem mais nada (3 s de partida descartados); ritual: `--boss-hp=0.67
--probe-wait=ritual --probe-settle=30`; fase 4: `--boss-hp=0.14 --probe-wait=phase4`. Resolução conferida em cada
rodada pela imagem do viewport (`image (1920, 1080)` na linha `PROBE`). Ordem alternada (r1 antes primeiro, r2 depois
primeiro, r3 antes primeiro).

**Limitação**: no meio da rodada 2 o notebook saiu da tomada (`Win32_Battery.BatteryStatus` = 1, descarregando, 92% e
depois 85%). Daí em diante todo quadro ficou preso em 16,7 ms (60 FPS, o limite do driver na bateria) com a GPU em 8 a 9 ms.
Essas rodadas não servem para comparar e ficaram fora da tabela; a tomada não voltou até o fim do trabalho. Valem 2
rodadas por cena no depois e 2 (fase 1) ou 1 (ritual, fase 4) no antes. A mediana de 3 pedida **não foi possível**;
repetir na tomada com o comando acima (3 cenas x 2 versões x 3 rodadas).

| Cena | Quadro antes (`3b22cea`) | Quadro depois (`b29e372`) | Diferença | FPS depois | p90 depois | GPU antes / depois | CPU de desenho depois | Chamadas antes / depois | Primitivas antes / depois | O que acontecia (estados) |
|---|---|---|---|---|---|---|---|---|---|---|
| fase 1 | 5,16 ms (5,45; 4,87) | 5,50 ms (5,58; 5,42) | +0,34 | cerca de 182 | 6,08 a 6,35 | 5,08 / 5,44 | 1,03 a 1,16 | 936 / 936 | 738 mil / 737 mil | perseguição, foice, recuperação; 1 de pé |
| ritual | 5,44 ms (1 rodada) | 5,53 ms (5,56; 5,49) | +0,09 | cerca de 181 | 6,14 a 6,42 | 5,33 / 5,42 | 1,10 a 1,29 | 886 / 1039 | 872 mil / **1,155 milhão** | `RITUAL` em todos os 300 quadros; 1 a 4 de pé |
| fase 4 | 5,28 ms (1 rodada) | 5,42 ms (5,48; 5,35) | +0,14 | cerca de 185 | 5,89 a 6,26 | 5,19 / 5,34 | 1,05 a 1,26 | 943 / 967 | 729 mil / 732 mil | perseguição, foice, tempestade; 1 de pé |

- O ritual novo desenha 32% mais primitivas (escudo com runas, círculos, colunas) e custa cerca de 0,1 ms. Em
  nenhuma cena o quadro passa de 6,5 ms no p90; a meta de 60 FPS (16,7 ms) tem folga de três vezes.
- Na bateria (rodadas descartadas) o jogo manteve os 60 FPS do limite em todas as cenas (GPU 7,6 a 8,7 ms).
- `step_ms` da simulação: 0,06 a 0,29 nas capturas e gravações; no `--stress=300` sem tela, 0,08 contra 0,10 no antes
  (na bateria; serve de regressão, não de número absoluto).
- Saídas cruas: `/home/dani/games/c9qa/out/gpu_perf.txt` (apagado ao fim com a pasta; os números estão aqui).

## 4. Capturas e vídeos

Tudo em `docs/gallery/cycle9/`, com o comando de cada arquivo em `docs/gallery/cycle9/CAPTURAS.md`. Olhei cada imagem e
cada montagem e troquei as que não mostravam o pedido (lista das descartadas no `CAPTURAS.md`).

- 18 capturas 1920 x 1080, JPG 85: `01_morvath_fase1` a `18_tela_vitoria`, nenhuma com dom de fogo.
- 5 montagens antes e depois: `before_after_foice`, `_ritual`, `_maldicao`, `_tempestade`, `_vitoria` (`docs/gallery/morvath/`
  intocado).
- Vídeos (`--write-movie` da Godot na GPU, H.264): `morvath_full_fight.mp4` **34,0 MB**, 2:13, 1280 x 720, a luta
  inteira do robô com reação 0,25 (geada, semente 1) do começo à tela de vitória, sem cortes, venceu com 14 de vida;
  `morvath_attacks_showcase.mp4` **29,9 MB**, 1:31, 1280 x 720, oito trechos de `--boss-only` com rótulo. Conferidos por
  folhas de quadros extraídos.
- **Limitações dos vídeos**: a Godot gravou em 1280 x 720 (o tamanho do projeto) apesar do `--resolution 1920x1080`;
  saíram sem som (o `--shot`, usado para encerrar depois da vitória e manter a janela, silencia o jogo; trilha em -91 dB).

## 5. Falhas e observações por gravidade

Nenhuma crítica, alta ou média de funcionamento.

**Média (medida e cobertura)**

- **M1. A investida de Morvath nunca sai nas simulações** (0 em 80 lutas, `attacks.dash` = 0). Ela exige o paladino a 9 m
  ou mais (`min_dist` 9 em `data/bosses/morvath.tres`) e o robô fica sempre perto, então nenhuma métrica ou regressão
  automática passa por ela. Reproduzir: qualquer linha de `METRICAS.md`. Ela funciona com `--boss-only=dash` sem robô
  (`05_investida.jpg`, vídeo de ataques). Sugestão ao **Gameplay Engineer**: um modo do robô que se afaste às vezes, ou
  um teste da investida na luta. Não é falha do jogo.
- **M2. Desempenho com 2 rodadas e não 3** (seção 3): repetir na tomada. Responsável: **QA**.

**Baixa (para o `art-director`, `ui-ux-designer` e Gameplay Engineer; julgamento visual não é do QA)**

- **B1. Morvath quase branco no golpe final** (`16_morvath_derrota.jpg`, `before_after_vitoria.jpg`): 0,4 s depois do
  momento `victory`, o corpo dele está pálido, perto de uma silhueta branca, durante a câmera lenta. Pode ser o pisca de
  dano esticado pela câmera lenta. Reproduzir: o comando de `16`. Responsável: **art-director** decidir.
- **B2. Pontos brancos estourados no escudo do ritual** (`07_ritual_escudo.jpg`, e dois no vídeo de ataques, trecho
  do ritual): esferas brancas pequenas e muito claras em cima do escudo. Responsável: **art-director** e
  **environment-artist**.
- **B3. Tela tingida de vermelho por bastante tempo ao levar dano com a maldição** (`11_maldicao_aplicacao.jpg` e o trecho
  da maldição no vídeo: a sala inteira avermelhada). Responsável: **ui-ux-designer** ver se é o pretendido.
- **B4. O aviso da foice no chão é o vermelho comum dos avisos** (`02_foice_preparacao.jpg`); o arco violeta com borda
  verde-azulada só aparece no golpe (`03`). Só registro; se é o pedido, ok. Responsável: **art-director**.
- **B5. Dica do ritual sem ritual** com `--boss-hp=0.5` (`09_erupcoes.jpg`: "O Ritual dos Mortos" e "Derrube os mortos
  para quebrar o escudo!" sem escudo). Só acontece com a opção de teste que começa direto na fase 2; no jogo a fase 2
  sempre abre com o ritual. Responsável: **Gameplay Engineer**, se quiser.
- **B6. "Novo melhor tempo!" numa partida com `--nosave`** (`18_tela_vitoria.jpg`, 0:09 por começar com 2% de vida).
  Só em teste. Responsável: **ui-ux-designer**, se quiser.
- **B7. Métrica do ritual zerada se o paladino morre durante o ritual**: `boss.ritual` e `ritual_raised` só são escritos
  no fim do ritual (`boss.gd:801`); em 3 partidas inteiras com reação 0,25 (sementes 3, 4 e 5) ficaram 0. Responsável:
  **Gameplay Engineer** (gravar também em `record_death`).
- **B8. Balanceamento** (não é falha): com reação de 0,25 s e seis dons de um estilo, o robô morre sobretudo na fase 4
  (15 de 18 derrotas); nas partidas inteiras (1 ou 2 dons) morre sobretudo no ritual (4 de 7). Com reação 0 vence quase
  sempre. Decisão do **Gameplay Engineer** e do Daniel depois de um teste com gente.

## 6. Limitações do ambiente

- WSL sem Vulkan da GPU: testes e simulações em Linux sem tela; tudo o que é imagem, vídeo ou quadro foi na Godot de
  Windows pela `tools/gpu.sh` (abre uma janela na tela do Daniel).
- Sem som em lugar nenhum (WSL e gravações).
- O notebook saiu da tomada no meio da medição de quadro (seção 3).
- A Godot grava filmes no tamanho do projeto (1280 x 720), não no `--resolution`.
- Nenhum teste com gente, controle, navegador, celular ou placa fraca nesta rodada.
