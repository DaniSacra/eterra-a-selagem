# Capturas finais do C10 ("Limpar e medir")

Tiradas em 2026-11-16 pelo QA no HEAD `6bab080` (o C10 é o `dcf6632` e o `196f33c`; o C11 veio por cima, então a luta
já é na Câmara do Selo). Mesmas condições do `docs/gallery/boss_arena/CAPTURAS.md`: Godot 4.7.2 de Windows na RTX 5060,
Vulkan Forward+, 1920 x 1080, na tomada, JPG 85 pela própria Godot, nada editado. `shot` = `RES=1920x1080 tools/gpu.sh shot
<saída.png> --nosave --seed=5 --start=boss` seguido das opções. As capturas de trabalho do ciclo continuam em `work/`.

| Arquivo | Opções do `shot` | O que mostra |
|---|---|---|
| `golpe_final_sem_branco.jpg` | `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:victory --shot-after=0.4` | 3,0 s; o golpe final: Morvath escurece com o brilho verde da magia saindo, **nenhum branco** no corpo (B1) |
| `escudo_ritual.jpg`, `escudo_ritual_zoom.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=1.2` (o mesmo quadro da `boss_arena/05`; o zoom é um recorte de 720 x 540) | 5,8 s; escudo de vidro esmeralda com runas, **sem os pontos brancos** do ciclo 9 (compare `boss_arena/before_after_ritual.jpg`, onde o antes tem a bola branca) |
| `orbe_feiticeiro.jpg`, `orbe_feiticeiro_zoom.jpg` | `--nosave --seed=5 --stress=4 --stress-ids=mage --shot-at=5` (sala 1, sem robô, recorte de 760 x 520 no zoom) | 5,0 s; quatro feiticeiros com o orbe violeta no cajado, sem branco |
| `contador_ritual.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=ritual-left:2 --shot-after=0.1` | 8,8 s; barra do chefe com os losangos do ritual (dois de pé) e "Derrube os mortos" |
| `opcoes.jpg` | `--nosave --title --screen=options --shot-at=2` | a tela de opções com o grupo Conforto: tremor de câmera, clarões de impacto, câmera lenta, separação de cores |
| `derrotado_por.jpg` | `--hero-hp=1 --shot-at=1 --shot-on=end --shot-after=1.5` (sem robô) | 5,5 s; "A luz não se apaga", "Derrotado por: Foice Sepulcral" |
| `golpe_sofrido_comum.jpg` | `--shot-at=1 --shot-on=hurt --shot-after=0.1` (sem robô) | 5,6 s; foice acertou (18/30): tinta só nas bordas da tela, curta |
| `golpe_sofrido_amaldicoado.jpg` | `--boss-hp=0.3 --boss-only=curse --shot-at=2 --shot-on=hurt-cursed --shot-after=0.1` | 7,5 s; golpe com a maldição ativa (12/30): borda violeta e fraca, "Amaldiçoado", especial com cadeado |
| `queimadura_fogo.jpg`, `_t7`, `_t12` | `--bot --boon-ids=golpe_brasa,pesado_brasa,circulo_brasa,brasas --shot-at=10` (e `7`, `12`) | 9,8 s, 6,8 s e 11,7 s; Morvath queimando. **Aos 6,8 s ele está na cor dele com a brasa; aos 9,8 e 11,7 s fica quase todo branco** (ver o relatório de QA, achado M-1) |
| `queimadura_fogo_196f33c.jpg` | o mesmo `--shot-at=10` no `196f33c` (fim do C10, salão) | 9,8 s; o mesmo corpo quase branco: **já existia no C10**, não veio da câmara |
| `queimadura_salao_comum.jpg` | `--nosave --seed=5 --bot --boon-ids=... --shot-at=9` (sala 1) | 8,8 s; esqueletos queimando no salão comum |
| `fase4_clima.jpg` | `--bot --boss-hp=0.14 --shot-at=6` | 5,9 s; fase 4: veios violeta orgânicos no chão, raio da porta azul, o resto da câmara no mesmo ar |

## Folha de quadros: quadro de impacto em preto e branco

Duas gravações da mesma luta (kit do vídeo do ciclo 9, `--start=boss --bot --bot-reaction=0.25 --seed=1
--boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno`), feitas na Godot de Linux no WSL com
OpenGL (Compatibility) na mesma RTX 5060 pelo D3D12 do Mesa e uma tela virtual (`xvfb-run`), `--fixed-fps 60
--write-movie <x>.avi --quit-after 7500`, 1280 x 720. Por que não no `gpu.sh`: para desligar o quadro de impacto é preciso
o save com `"impact_frames": false` (não há opção de linha de comando, e o `--nosave` ignora o save); o save do Linux é do
QA, o do Windows é do Daniel e não foi tocado. O save do Linux foi copiado antes e restaurado depois.

- **Ligado** (`--nosave`, o padrão): 7500 quadros (125 s). Saturação média de cada quadro pelo `ffmpeg signalstats`
  (`SATAVG`, mediana da luta 23,2): **4 quadros de impacto**, cada um de 4 quadros de vídeo com SATAVG de 2,6 a 3,1 (aos
  16,7 s, 28,8 s, 87,7 s e 107,7 s). Meta de no máximo 12 em 2 min: **cumprida**.
- **Desligado** (save com `impact_frames` false, sem `--nosave`): **0 quadros** abaixo de SATAVG 8 (fora o escurecer da
  carga) em 6979 quadros (116 s). A Godot do Linux caiu duas vezes com "D3D12: Removing Device" (o driver do WSL; a
  primeira tentativa, com 6087 quadros, também deu 0). A meta de 0: **cumprida**, com 116 s em vez de 120.
- `folha_quadros_2min.jpg`: um quadro a cada 5 s da gravação ligada mais os quatro quadros P&B, com o tempo.
- `folha_quadros_pb_ligado_desligado.jpg`: cada quadro P&B ao lado do mesmo quadro da gravação desligada (em cor). As
  três primeiras linhas são o mesmo instante; a quarta já não (o relógio da partida mostra 1:44 contra 1:31: as duas lutas
  se separaram depois do meio).

## Vídeo do bloqueio de corpo (REG-001)

`bloqueio_de_corpo.mp4`, 27,5 s, 1280 x 720, sem som: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080
--fixed-fps 60 --write-movie C:/.../body.avi --quit-after 2400 -- --nosave --seed=5 --bot --stress=10
--stress-ids=guard,skeleton,guard,runner --shot=C:/.../x.png --shot-at=999`, cortado de 1,5 s a 29 s e convertido com
`libx264 -crf 24`. **Limite**: é o robô lutando na sala 1 no meio de dez corpos sólidos (Escudos, esqueletos e corredores),
com a vida de teste do `--stress`; não é o herói andando de propósito contra uma fila deles. Mostra ele parando e
contornando os corpos e esquivando através deles quando cercado, mas não um deslizar longo e limpo. Para um vídeo
dirigido falta uma opção de teste (dono `gameplay-engineer`), por exemplo `--walk-to=x,z` (o herói anda reto até o ponto,
sem atacar) e `--dash-at=s` (esquiva naquele segundo), com `--stress-ids=guard --stress-line=x,z` para pôr a fila.

## Registro de partidas

`runs_exemplo.jsonl`: três linhas que o jogo escreveu com `--runlog=<arquivo>` (`tools/smoke.sh 900 --seed=1
--bot-reaction=0.25`, o mesmo com `--seed=3`, e `tools/smoke.sh 600 --start=boss --seed=2 --bot-reaction=0.25
--boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,firmeza`): uma morte para as erupções, uma vitória,
uma morte para a maldição; cada uma com dons, `device`, Ômegas, esquivas, último golpe sofrido e `defeated_by`.
