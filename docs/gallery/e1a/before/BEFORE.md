# E1a "Inimigos vivos": linha de base ANTES

- Data: 2026-11-16. Commit testado: `10944b1` (HEAD de `arpg-3d`, antes da E1a), numa worktree limpa (nada alterado).
- Máquina: notebook do Daniel, RTX 5060 Laptop, Godot 4.7.2 de Windows pelo `tools/gpu.sh` (Vulkan, Forward+),
  espelho próprio `MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-head` (não mexe no espelho dos outros agentes).
- Energia: **na tomada** durante as medidas de quadro na GPU (`PowerLineStatus: Online`, 54 a 57%, lido no Windows antes
  e depois). No começo da sessão (capturas de pose) o Windows dizia `BatteryStatus 1` (bateria, 30%); as capturas de pose
  não dependem de energia.

## 1. Números

| Medida | Valor |
|---|---|
| `tools/check.gd` | o projeto passa; nenhum `SCRIPT ERROR` nem `Parse Error` |
| `tools/test.sh` | 55 scripts, **541 testes, 541 passando**, 0 falhando, 0 arriscados (o `test_only_finishers_glint` não aparece mais como arriscado), 104068 asserções |
| Sonda de game feel | **FEEL_SUMMARY 31/31 ok** (`logs/feel_probe.log`) |
| `tools/smoke.sh 300` (sem semente) | chega em Morvath na sala 7 (`boss_at` 122,6 s), vence (`ENDING`, hp 70), 42 abates, `max_alive` 7, **`step_ms_avg` 0,22**, **`step_ms_peak` 8,49** |
| `tools/smoke.sh 120 --start=boss --boons=25` | vence em 52,8 s, `max_alive` 5, **`step_ms_avg` 0,20**, **`step_ms_peak` 4,91**, 12 dons |
| 8 descidas `tools/smoke.sh 300 --seed=1..8` (uma de cada vez) | 8 de 8 chegam e vencem Morvath (`ENDING`, hp 3 a 50), `stuck` 0, `max_alive` 7, `step_ms_avg` 0,18 a 0,22, `step_ms_peak` 4,56 a 10,14 (`logs/descents8.log`) |
| `tools/smoke.sh 120 --stress=150 --seed=5` (sem tela) | `step_ms_avg` **1,28**, `step_ms_peak` 11,18, `max_alive` 150 |
| Quadro na GPU, 150 inimigos, vsync desligado, 1920x1080 (render 2880x1620 pela escala 1,5 do Windows), 3 execuções | frame_ms mediana **9,41 / 8,88 / 8,77** (média 8,79 a 9,48, p90 9,67 a 10,34); **gpu_ms mediana 5,63 / 5,87 / 5,85**; cpu_render_ms 1,36 a 1,47; 1032 chamadas de desenho, 1,43 milhão de primitivas (`logs/gpu_perf_stress150.log`) |
| Mesmo cenário pelo `gpu.sh shot` (vsync ligado, 1672x941) | `fps` 128 / 115 / 120 (`logs/gpu_stress150.log`; só referência, o vsync mistura) |
| `du -sh assets/baked` | **45 MB** (46 714 106 bytes; teto da E1a: 70 MB). Por arquivo em `baked_sizes.txt`: morvath 10,3 MB, mage 5,9, priest_elder 5,3, skeleton 4,6, knight 4,5, archer 4,3, guard 3,9, runner 3,9, priest 3,9, statue 0,1 |

### Poses assadas (de `baked_poses.txt`, lidas do `BakedModel`)

| Inimigo | andar | golpe sofrido | parado | morte |
|---|---|---|---|---|
| esqueleto | 10 poses, 10,7 qps | 4, 12 qps | 4, 1,6 qps | 8, 4,2 qps |
| mago | 10, 10,7 | 4, 12 | 4, 3,2 | 8, 4,2 |
| Escudo (guard) | 10, 7,5 | 4, 12 | 4, 1,6 | 8, 4,2 |
| Morvath | 10, 7,5 | 4, 12 | 4, 1,6 | 8, 4,2 (mais 12 clipes próprios, de 4 a 12 poses) |

O jogo toca o andar a `Horde.clip_rate` (velocidade / 2,3, entre 0,6 e 1,6: esqueleto 1,6, mago 1,52, Escudo 1,41,
Morvath 1,6), o golpe sofrido a 1x e a morte a 1,3x, e escolhe a pose por `int(t * fps)` sem mistura
(`crowd_renderer.gd:242`).

### Pares de quadros seguidos (a 30 qps) com a mesma pose (meta depois da E1a: zero no andar)

Medido de dois jeitos que batem: o índice da pose (`BakedModel.frame_at`, `strip_frame_index.txt`) e a imagem
(hash dos pixels de quadros vizinhos renderizados na GPU, `pose_repeats.txt`; `=` repete, `|` muda):

| Inimigo | andar (23 pares) | golpe sofrido (9 pares) | morte (39 pares) |
|---|---|---|---|
| esqueleto | **10 de 23** (43%) | 6 de 9 | 32 de 39 (82%) |
| mago | **11 de 23** (48%) | 6 de 9 | 32 de 39 |
| Escudo | **15 de 23** (65%) | 6 de 9 | 32 de 39 |
| Morvath | **14 de 23** (61%) | 6 de 9 | 32 de 39 |

Folha de contato (`skeleton_walk_contact_12.png`, quadros 0 a 11 do esqueleto andando a 30 qps): pares iguais 0-1, 2-3,
4-5, 6-7, 9-10 (5 de 11).

## 2. Arquivos

- `skeleton_walk_contact_12.png`: 12 quadros seguidos do esqueleto andando.
- `strips/poses_walk_hit_death_1x.mp4` e `_025x.mp4` (1280x800, 30 qps): esqueleto, mago, Escudo e Morvath lado a lado,
  sozinhos e de perto, na sequência andar (24 quadros), golpe sofrido (10) e morte (40), exatamente as poses que o jogo
  mostraria em quadros seguidos a 30 qps. PNGs não guardados (regerar pelo comando de poses abaixo).
- `video/fight_skeleton_mage_guard_1x.mp4` e `_025x.mp4` (1280x720 a partir de 1920x1080, 30 qps, 14 s): partida real,
  robô contra 9 inimigos (esqueleto, mago, Escudo) andando, levando golpe e morrendo no Salão.
- `video/morvath_fight_1x.mp4` e `_025x.mp4` (30 s): Morvath andando, atacando e levando golpe (5 dons).
- `video/morvath_death_bosshp02_1x.mp4` e `_025x.mp4` (24 s): Morvath com 20% da vida, as fases, a morte e a selagem.
- `stills/*.jpg`: quadros em 1920x1080 tirados dos AVIs (luta e Morvath).
- `weapons/weapons_all_{front,side,game}.jpg` e `weapons/weapon_<id>_<vista>.jpg`: os nove inimigos de perto, parados,
  de frente, de lado e no ângulo do jogo, para o VX-07.
- `logs/`: saídas brutas de todos os comandos. `tools/`: os dois scripts de captura usados (cópias; não estão no projeto).
- AVIs brutos (1920x1080, 110 a 300 MB cada) em `C:/Users/danie/tools/e1a_lab/` (fora do repositório).

## 3. Comandos (repetir idênticos no "depois", trocando o espelho e a pasta de saída)

```sh
cd <worktree>
~/tools/godot/godot --headless --path . --import
~/tools/godot/godot --headless --path . -s tools/check.gd          # nenhum SCRIPT ERROR / Parse Error
tools/test.sh
tools/smoke.sh 300
tools/smoke.sh 120 --start=boss --boons=25
for s in 1 2 3 4 5 6 7 8; do tools/smoke.sh 300 --seed=$s; done
tools/smoke.sh 120 --stress=150 --seed=5
~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain
du -sb assets/baked/* ; du -sh assets/baked
```

Poses e armas (scripts guardados em `before/tools/`; rodam dentro do espelho, pelo `res://`):

```sh
M=/mnt/c/Users/danie/tools/eterra-gpu-head
MIRROR=$M tools/gpu.sh sync
cp docs/gallery/e1a/before/tools/qa_e1a_strip.gd docs/gallery/e1a/before/tools/qa_e1a_weapons.gd $M/tools/
G=/mnt/c/Users/danie/tools/godot/Godot_v4.7.2-stable_win64_console.exe
flock /tmp/eterra-gpu.lock $G --path 'C:\Users\danie\tools\eterra-gpu-head' --rendering-driver vulkan --resolution 640x720 \
  -s res://tools/qa_e1a_strip.gd -- C:/Users/danie/tools/e1a_lab/out        # <id>_<anim>_NN.png + strip_index.txt
flock /tmp/eterra-gpu.lock $G --path 'C:\Users\danie\tools\eterra-gpu-head' --rendering-driver vulkan --resolution 900x1000 \
  -s res://tools/qa_e1a_weapons.gd -- C:/Users/danie/tools/e1a_lab/wpn      # weapon_<id>_<front|side|game>.png
```

Atenção para o depois: o `qa_e1a_strip.gd` escolhe o tempo do clipe com as taxas de hoje (`clip_rate` 1,6 / 1,5217 /
1,413 / 1,6; golpe 1; morte 1,3) e chama `CrowdRenderer.add` sem estado de golpe. Se a E1a mudar a taxa (VX-05, passo
medido) ou a assinatura do `add` (mistura), ajustar `JOBS` e a chamada para continuar sendo o que o jogo mostra; o
recuo do golpe sofrido (VX-06) só aparece no vídeo da partida. Contagem de pares iguais: hash dos pixels de cada
`*_NN.png` contra o anterior (`ffmpeg -v error -i f.png -f rawvideo -pix_fmt rgb24 - | md5sum`). Folha:
`ffmpeg -framerate 30 -i skeleton_walk_%02d.png -vf "crop=300:340:170:190,drawtext=text='%{n}':x=8:y=8:fontsize=22:fontcolor=white,tile=6x2" -frames:v 1 out.png`.
Tiras: as três sequências de cada inimigo renumeradas e juntas por `xstack` 2x2 (`crop=640:400:0:160`), `-crf 18`,
e `setpts=4*PTS` para 0,25x.

Vídeos do jogo (Movie Maker, 30 qps, 1920x1080; depois `ffmpeg -an -vf scale=1280:720 -preset slow -crf 26 -r 30` e
`scale=1280:720,setpts=4*PTS` para 0,25x; os de Morvath com `-t 30` e `-t 24`):

```sh
MIRROR=$M RES=1920x1080 FPS=30 tools/movie.sh C:/Users/danie/tools/e1a_lab/fight.avi 420 --bot --stress=9 --stress-ids=skeleton,mage,guard --seed=5
MIRROR=$M RES=1920x1080 FPS=30 tools/movie.sh C:/Users/danie/tools/e1a_lab/boss_walk.avi 900 --bot --start=boss --boons=5 --seed=5
MIRROR=$M RES=1920x1080 FPS=30 tools/movie.sh C:/Users/danie/tools/e1a_lab/boss.avi 1500 --bot --start=boss --boons=25 --boss-hp=0.2 --seed=5
```

Quadro na GPU (na tomada; 3 vezes):

```sh
MIRROR=$M tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --disable-vsync \
  -s C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave --seed=5 --stress=150 --probe-settle=240
MIRROR=$M tools/gpu.sh shot <saida>.png --stress=150 --seed=5 --shot-at=8     # fps com vsync, referência
```

## 4. Avaliação visual (perguntas da diretriz), olhando as imagens acima

- **A animação é adequada?** Não. Na folha e nas tiras, o andar segura cada pose por 2 a 3 quadros (43 a 65% dos pares
  repetem) e a morte por 5 a 6 quadros (82%): a 0,25x é stop motion claro, e a 1x a multidão "engasga" ao lado do herói,
  que anima contínuo. O golpe sofrido são 4 poses em 0,33 s e não desloca o corpo (vídeo da luta a 0,25x: o inimigo
  clareia e inclina, mas não recua). O andar do esqueleto, de perto, tem o tronco muito curvado e a cabeça escondida
  atrás da ombreira na maior parte do ciclo (folha, quadros 4 a 11).
- **Os inimigos são legíveis?** Na câmera do jogo, sim pela silhueta e pela arma: Escudo com escudo e espada, mago de
  capuz com cajado e orbes violeta, esqueleto de tanga vermelha (`stills/fight_f100.jpg`); Morvath lê bem pelo tamanho,
  coroa e manto violeta. Avisos no chão e barras ajudam. A leitura cai nas armas.
- **Armas (VX-07)**: as do KayKit destoam das figuras pintadas (`weapons/weapons_all_front.jpg`): cutelo do esqueleto em
  duas faixas chapadas (cinza claro e marrom) e grande; besta do besteiro como uma peça branca chapada enorme sobre a
  cabeça; cajados do mago e do sacerdote ancião marrom liso com anéis lilás chapados; escudo redondo do Cavaleiro cinza
  sem pintura; o gancho de Morvath em laranja-amarelo saturado, longe do ouro velho. Só o Escudo (arma e escudo do próprio
  modelo do Meshy) está no estilo.
- **Parece jogo comercial?** Cenário, luz e HUD sim; os inimigos em movimento ainda não: a cadência de poses e as armas
  de plástico são o que mais denuncia o protótipo no quadro, e é exatamente o escopo da E1a.

## 5. Achados

- **Ferramenta, média: `tools/enemy_lab.gd` não compila com `-s` no `10944b1`** (`Compile Error: Identifier not found:
  Controls` ao compilar a dependência `Fx`, seguido de `Nonexistent function 'soft_dot'` e `count` em `Nil`). Um script
  meu com as mesmas referências estáticas (`CrowdRenderer.new()`) saiu com figuras vazias na GPU; carregando
  `crowd_renderer.gd` em tempo de execução (`load(...)`) funciona, e é o contorno dos scripts de `before/tools/`. O aceite
  do E1a-4 cita o `enemy_lab`; ele precisa voltar a funcionar antes disso. Reproduzir:
  `~/tools/godot/godot --headless --path . -s tools/enemy_lab.gd -- /tmp/x walk 0 skeleton`. Responsável sugerido:
  `gameplay-engineer` (provável origem: o `Fx` passou a citar o autoload `Controls` na vibração do C12d; não confirmei
  pelo histórico).
- `RESULT` não é JSON (B-c, já no backlog como E1a-5): `"attacks": { &"scythe": 9, ...}` nas saídas em `logs/`.

## 6. Limitações

- Os quadros das tiras e da folha são o renderizador de multidão do jogo numa cena de laboratório (fundo liso, uma luz),
  não a sala; o vídeo da partida mostra o resto. A câmera das tiras tem a inclinação do jogo, mais de perto.
- O quadro na GPU é do notebook na tomada, com a escala 1,5 do Windows (render 2880x1620). O Movie Maker gravou som, mas
  os mp4 saem sem áudio e nada foi ouvido. Robô, não gente. Smoke de 300 s sem semente, como pedido (as 8 descidas têm
  semente).
