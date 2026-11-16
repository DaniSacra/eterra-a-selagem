# Capturas e vídeos do ciclo 9 (luta de Morvath)

Capturas reais da Godot 4.7.2 (Windows) na placa de vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan
1.4.357, Forward+), tiradas em 2026-11-15 pelo QA. Nenhuma imagem foi gerada por IA, editada ou retocada: cada arquivo
é o quadro que o jogo salvou (`--shot`), só regravado de PNG para JPG com qualidade 85 (`Image.save_jpg(caminho, 0.85)`
da própria Godot). As montagens só juntam quadros inteiros lado a lado, reduzidos a 1440 x 810, com uma faixa de rótulo
**acima** de cada um (`ffmpeg scale`, `pad`, `drawtext`, fonte Alegreya Sans Bold do projeto).

- **Depois**: `b29e372` (o `1f9d49c` atual só muda `.claude/agents/` e `CLAUDE.md`), espelho padrão
  `C:/Users/danie/tools/eterra-gpu`.
- **Antes**: `3b22cea` (começo do ciclo 9), extraído por `git archive 3b22cea | tar -x -C /home/dani/games/c9-before`
  e espelhado em `C:/Users/danie/tools/eterra-gpu-c9before` (`MIRROR=... /home/dani/games/c9-before/tools/gpu.sh`).
  Cópia e espelho apagados ao fim.
- `shot` abaixo = `RES=1920x1080 tools/gpu.sh shot <saída.png> --nosave --seed=5 --start=boss` seguido das opções
  (janela em `--fixed-fps 30`, o padrão do `gpu.sh shot`). Nenhuma captura usa dom de fogo: nenhum `--boon-ids` nem
  `--boons` (só o golpe que o `--start=boss` já traz). "Momento" é `time` da linha `RESULT`.
- `--shot-on=boss:<momento>` espera o `Boss.moment` com esse nome e salva `--shot-after` segundos de tempo real depois.
  Nenhum momento novo foi preciso (não mexi em `boss.gd`).
- Descartadas (olhadas e trocadas): `05` com `--shot-after=0.6` (só o aviso vermelho) e `0.9` (ele ainda parado),
  `04` com `--seed=3` (as lâminas encobertas pelo herói), `09` com `momento ritual_end` (é o escudo quebrando, não
  erupção), `09` com `--shot-after=0.75` (só os círculos), `17` com `--shot-after=2.8` (o fluxo já tinha chegado ao
  portal; ficou o de 2,2 s, com o fluxo de energia indo para o altar). As três primeiras tentativas de `11`, `13` e `14`
  travaram ou foram canceladas: com o robô de reação 0 a maldição nunca pega (ele desvia sempre), então `11` e `12`
  são sem robô.

| Arquivo | Comando | Momento e o que se vê |
|---|---|---|
| `01_morvath_fase1.jpg` | shot `--bot --shot-at=7` | 6,8 s, fase 1, Morvath com 5793; herói golpeando junto dele no círculo, barra com as marcas de fase |
| `02_foice_preparacao.jpg` | shot `--bot --boss-only=scythe --shot-at=3 --shot-on=boss:scythe_warn --shot-after=0.5` | 5,1 s; foice erguida, setor de meia-volta no chão (vermelho), "O Despertar" |
| `03_foice_ataque.jpg` | shot `--bot --boss-only=scythe --shot-at=3 --shot-on=boss:scythe_strike --shot-after=0.08` | 5,5 s; arco violeta com borda verde-azulada cruzando o setor |
| `04_laminas_almas.jpg` | shot `--bot --boss-only=blades --shot-at=3 --shot-on=boss:blades_fire --shot-after=0.3` | 5,1 s; as duas meias-luas saindo, o herói colado em Morvath |
| `05_investida.jpg` | shot `--boss-only=dash --shot-at=2 --shot-on=boss:dash --shot-after=1.05` (sem robô: a investida só vale a 9 m ou mais) | 5,2 s; Morvath no meio da investida sobre a faixa violeta com bordas verde-azuladas |
| `06_transicao_fase2.jpg` | shot `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:phase --shot-after=0.5` | 4,1 s; rugido, anel violeta, almas na mão, "O Ritual dos Mortos" e a dica |
| `07_ritual_escudo.jpg` | shot `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=1.2` | 7,0 s; escudo esmeralda e violeta com runas, primeiro morto subindo da coluna, círculos de invocação |
| `08_ritual_invocacao.jpg` | shot `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=3.0` | 8,7 s; 4 de pé, mortos dos dois lados, avisos de erupção em runa sob o herói |
| `09_erupcoes.jpg` | shot `--bot --boss-hp=0.5 --boss-only=eruptions --shot-at=2 --shot-on=boss:eruptions --shot-after=1.0` | 5,0 s; colunas espectrais saindo dos círculos de runa. Começa direto na fase 2 (a dica do ritual aparece, mas não há ritual: efeito do `--boss-hp`) |
| `10_transicao_fase3.jpg` | shot `--bot --boss-hp=0.34 --shot-at=2 --shot-on=boss:phase --shot-after=0.5` | 4,1 s; rugido, "A Maldição dos Condenados", "Golpes pesados o atordoam!" |
| `11_maldicao_aplicacao.jpg` | shot `--boss-hp=0.3 --boss-only=curse --shot-at=2 --shot-on=boss:cursed --shot-after=0.1` (sem robô) | 7,1 s; a maldição acabou de pegar: "Maldição!", selo "Amaldiçoado", especial com cadeado, tela tingida de vermelho do dano (24/30) |
| `12_explorador_amaldicoado.jpg` | o mesmo com `--shot-after=1.2` | 8,2 s; herói com runas violetas em volta, cadeado no especial, Morvath já em outro ataque |
| `13_transicao_fase4.jpg` | shot `--bot --boss-hp=0.16 --shot-at=2 --shot-on=boss:phase --shot-after=0.5` | 4,1 s; rugido, "O Último Suspiro", portal ao fundo já azul |
| `14_tempestade_seis_almas.jpg` | shot `--bot --boss-hp=0.14 --boss-only=storm --shot-at=2 --shot-on=boss:storm_fire --shot-after=0.25` | 5,3 s; seis meias-luas abrindo em leque, Morvath com a borda verde corrompida, portal verde-azulado |
| `15_combate_final.jpg` | shot `--bot --boss-hp=0.14 --shot-at=9` | 8,9 s; combinação da fase 4: faixas de aviso cruzando a sala inteira |
| `16_morvath_derrota.jpg` | shot `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:victory --shot-after=0.4` | 5,5 s; golpe final em câmera lenta com desfoque radial; Morvath pálido, quase branco |
| `17_portal_selagem.jpg` | shot `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:victory --shot-after=2.2` | 7,0 s; o fluxo de energia indo para o portal, que volta ao verde; legenda "A magia de Morvath se desfaz..." |
| `18_tela_vitoria.jpg` | shot `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:fallen --shot-after=1.5` | 9,0 s; "Morvath foi selado", espólios, Continuar e Descer de novo |

## Antes e depois (`3b22cea` contra `b29e372`, mesmo comando, mesma semente)

| Arquivo | Quadros | Comando (igual nas duas versões) |
|---|---|---|
| `before_after_foice.jpg` | preparo (em cima) e golpe (embaixo) | os de `02` e `03` |
| `before_after_ritual.jpg` | ritual + 1,2 s e + 3 s | os de `07` e `08` |
| `before_after_maldicao.jpg` | 5,2 s depois do ataque `curse` (a maldição já pegou nas duas) | shot `--boss-hp=0.3 --boss-only=curse --shot-at=2 --shot-on=boss:curse --shot-after=5.2` (o `3b22cea` não tem o momento `cursed`) |
| `before_after_tempestade.jpg` | `storm_fire` + 0,25 s | o de `14` |
| `before_after_vitoria.jpg` | em cima: antes `fallen` + 0,1 s, depois `victory` + 0,4 s (o `3b22cea` não tem `victory`); embaixo: `fallen` + 1,5 s nas duas | `--bot --boss-hp=0.02 --shot-at=1` com o momento indicado |

Antes e depois não são a mesma pose: o `b29e372` mudou os tempos dos ataques, então o mesmo momento cai em quadros
diferentes. As montagens comparam o mesmo comando.

## Vídeos (gravação da própria Godot, `--write-movie`)

Gravados na GPU com `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --write-movie
C:/.../<nome>.avi [--quit-after N] -- --nosave --seed=5 <opções>` (MJPEG). **A gravação saiu em 1280 x 720**, apesar do
`--resolution 1920x1080` (a linha do Godot: "Movie Maker mode enabled, recording movie in 1280×720 @ 60 FPS"; é o
tamanho do projeto, `viewport_width` 1280). **Sem som**: o `--shot` (usado para manter a janela e encerrar depois da
vitória) silencia o jogo; a trilha gravada tem -91 dB e foi descartada. Convertidos com `ffmpeg -c:v libx264 -preset slow
-pix_fmt yuv420p -movflags +faststart -an`.

| Arquivo | Tamanho | Duração | Como |
|---|---|---|---|
| `morvath_full_fight.mp4` | 34,0 MB (crf 28; com crf 26 dava 46,3 MB) | 2:13 | uma luta inteira sem cortes: `--start=boss --bot --bot-reaction=0.25 --seed=1 --boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno --shot=C:/.../fight_end.png --shot-on=boss:fallen --shot-after=4`. Do carregamento até 4 s de tela de vitória. `RESULT`: venceu (`ENDING`), luta de 121,3 s, fases em 32,2 / 85,2 / 105,4 s, ritual 17,9 s, 8 mortos levantados, 2 maldições, terminou com 14 de vida |
| `morvath_attacks_showcase.mp4` | 29,9 MB (crf 26) | 1:31 | oito trechos emendados (`concat`), cada um sem os primeiros 1,5 s e com um rótulo embaixo (`drawtext`): Foice (`--bot --boss-only=scythe`, 720 quadros), Lâminas (`--bot --boss-only=blades`, 720), Investida (`--boss-only=dash` sem robô, 540), Fase 2 e Ritual (`--bot --boss-hp=0.67`, 1200), Erupções (`--bot --boss-hp=0.5 --boss-only=eruptions`, 720), Maldição (`--boss-hp=0.3 --boss-only=curse` sem robô, 600), Tempestade (`--bot --boss-hp=0.14 --boss-only=storm`, 840), Queda e vitória (`--bot --boss-hp=0.02 --shot-on=boss:fallen --shot-after=4`). Os trechos com `--quit-after N` usam `--shot=C:/.../x.png --shot-at=999` só para manter a janela no tamanho |

Conferidos por folhas de quadros extraídos (`ffmpeg select`, 6 quadros da luta e 9 da vitrine): a luta mostra fase 1,
escudo do ritual, fase 3, fase 4 com o portal mudado, o fim e a tela "Morvath foi selado"; cada trecho da vitrine mostra
o ataque do rótulo.
