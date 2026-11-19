# RS-C1: Cripta A e B, um elemento funerário dominante por variante

- **Data**: 2026-11-19. **Autor**: art-director. **Para**: environment-artist (cenário, luz), via Game Director.
- **Item**: RS-C1 do `docs/backlog.md` seção 9 ("na câmera do jogo, A e B se distinguem de relance").
- **Base**: `docs/art/room_redesign_lotA_spec.md` (Parte 2), `docs/art/room_redesign_lotA_review.md` (itens 1 a 10, já
  feitos), `scripts/game/crypt_look.gd`, `_crypt` do `tools/make_data.gd`, capturas
  `docs/gallery/redesign/lotA/02_cripta_A_stylized.jpg` e `03_cripta_B_stylized.jpg`.
- **Referências internas** (sensação, não forma): a árvore de pedra do Jardim (um volume vertical no meio do quadro,
  com luz própria) e a travessia da Ponte B (uma figura de composição que nomeia a variante).
- **Só perfil STYLIZED** (padrão do exe). Tudo novo em `kit.styled()` ou com `ArenaKit.style_only`; o que muda em peça
  existente passa por `VisualProfile.vary`. **O clássico não muda** (ele é o look aprovado de antes e o
  `test_room_style.gd` exige ida e volta idêntica; levar estas peças ao clássico fica como decisão futura, não agora).
- Colisão, `RoomLayout`, `_crypt`, chão andável, nascimentos, portas, câmera, avisos e raio-x: intocados. Meshy zero.

---

## 1. Diagnóstico (capturas da galeria do Lote A, RTX, 1920 x 1080, semente 5)

Hoje A e B dividem tudo o que pesa no quadro: o mesmo petróleo, os dois braseiros da porta norte como as manchas
quentes mais fortes (x 1270 e 1485, y 250 a 310), as velas dos nichos, os estandartes, o monte a nordeste. A diferença
real é uma massa escura (o muro do Ossuário) no terço superior direito da B e o túmulo grande no meio da A, e os dois
têm o mesmo valor da pedra em volta. Reduzidas a miniatura (320 x 180), as duas leem como "a mesma sala com móveis
trocados". A figura velada da B (3 m, topo a 6,2 m) fica abaixo da cornija (6,5 m), entre o estandarte de x 1,5 e o
nicho da estátua de x -2,5: some no ruído da parede.

Princípio desta spec: **cada variante ganha uma temperatura, um lugar no quadro e uma silhueta própria.**

| | A, "o túmulo coroado" | B, "a velada do ossuário" |
|---|---|---|
| Temperatura dominante | quente (velas) sobre o petróleo | fria (lanterna e facho) sobre o petróleo |
| Lugar no quadro | coluna do meio (x 860 a 1120), do topo ao túmulo | terço superior direito (x 1170 a 1270), acima da cornija |
| Silhueta | eixo vertical: coroa de velas pendurada sobre o túmulo | figura vertical que rompe a linha da parede |
| O que se cala | braseiros um passo abaixo, as outras velas abaixo da coroa | braseiros apagados, estandarte e velas ao lado da figura |

Os nomes da tabela são de trabalho (nada vai para o texto do jogo). Nenhum diz quem está no túmulo nem quem é a
figura (lore com o Daniel).

## 2. Câmera e mapa de tela

Câmera do jogo: yaw 35, pitch 30, fov 24 vertical, distância 54; na Cripta o alvo fica preso em (1,0; 1,5) com folga
de 2,5 m (`cam_target`, `cam_reach`). Projeção conferida contra as capturas da galeria (túmulo, porta norte e figura
caem a menos de 15 px do lugar medido). Posições na tela a 1920 x 1080 com o alvo em (1,0; 1,5), que é a câmera do
`tools/arena_lab.gd` sem `--cam-at`:

| Ponto (x, y, z em metros; x leste, z sul) | Tela (px) |
|---|---|
| Túmulo grande, topo no meio (0,5; 1,5; 0) | (981, 444) |
| Coroa, anel a y 6,0: oeste, norte, leste, sul | (919, 233), (1025, 226), (1047, 269), (937, 277) |
| Corrente da coroa, topo a y 10,0 | (983, 64); o relógio do HUD ocupa x 900 a 1020, y 0 a 58 |
| Figura da B: pé a y 3,6 e topo a y 8,0 em (0,5; -9,5) | (1207, 225) e (1218, 33) |
| Cornija da parede norte (y 6,5) atrás da figura | y 66 a 77 |
| Lanterna da figura (0,5; 5,45; -9,0) | (1195, 147) |
| Braseiros da porta norte, chama (1,5 e 7,1; 1,4; -11,4) | (1279, 281), (1490, 337) |
| Estandarte sobre o braseiro de x 1,5 (y 3,6 a 6,0) | x 1279 a 1285, y 105 a 201 |
| Parede norte lisa entre nichos (-5; 2,5 a 4; -11,1) | x 1051, y 129 a 185 |

O bot e o herói deslocam a câmera até 2,5 m; nas capturas do jogo as caixas podem andar até uns 60 px. As medidas de
aceite são no laboratório (alvo fixo, sem personagens); as do jogo são de leitura.

---

## 3. Variante A: o túmulo coroado

O túmulo grande (obstáculo `_sarcophagus(0.5, 0.0, 4.0, 2.0, 1.5)`, de x -1,5 a 2,5 e z -1 a 1, topo 1,5 m, com a
efígie A1 e o facho frio) já está no meio do quadro. Falta ele mandar: uma coroa de velas pendurada sobre ele, a poça
quente que ela faz no chão em volta, e um pano sobre o túmulo que o separa da pedra.

### A-D1. Coroa de velas (o elemento dominante)

| Item | Valor |
|---|---|
| Centro do anel | (0,5; 6,0; 0,0), sobre o meio do túmulo |
| Anel | ferro, raio 1,5 m (de fora), seção 0,07 m, 24 segmentos; um segundo aro fino de raio 1,2 m a y 6,06, ligado ao primeiro por 8 raios curtos |
| Velas | 16 sobre o anel de fora, em pratinhos de ferro de 0,1 m; 11 acesas (`Masonry.candle`, altura 0,12 a 0,22, raio 0,04 a 0,05) e 5 apagadas (`candle_out`) espalhadas, nunca duas apagadas juntas |
| Correntes | três, saindo do anel a 0, 120 e 240 graus, que se juntam num gancho em (0,5; 9,2; 0,0); dali uma só até y 10,0 e acaba (`ArenaKit.chain`, `size` 0,8, sem barriga). Topo a y 10,0 = tela y 64, abaixo do relógio |
| Materiais | ferro: o `TombKit.iron()` do estilizado (`stylize_metal`); cera `Masonry.STY_WAX`; chama âmbar do STY-10. Ferro, cera e chama na versão que abre em pontilhado em volta do herói (`see()`, `Masonry.candle(..., open = true)`, `candle_wax_see`, `flame_see`): com o herói a uns 6 m a noroeste do túmulo a coroa passa na frente da cabeça dele |
| Sombra | nenhuma peça da coroa projeta sombra (`cast_shadow` desligado) |
| Luz própria | uma `OmniLight3D` em (0,5; 5,7; 0,0), cor `CANDLE_COLOR` da sala, `omni_range` 9,0, atenuação 1,0, sem sombra, `light_cull_mask` = ~`Arena.CROWD_LAYER` como as outras velas; é fogo, então o `stylize_fires` faz a poça; força pela meta `ArenaKit.FIRE_SHARE` (começar em 2,2 e acertar pelo aceite 5.1) |
| Brilho | chamas e halo abaixo do teto da tela (`ScreenTone.fit`, maior canal até 1,0 no material); nada acima de 235 na tela fora do miolo das chamas |

Composição: túmulo (y 400 a 510), efígie, facho frio de cima e a coroa (y 205 a 290) com as correntes até y 64
formam um eixo vertical no meio do quadro, como a árvore do Jardim, com o quente embaixo e em cima e o frio do facho
cruzando no túmulo. O anel é fino e vazado: o chão atrás dele (em volta de (-5; -8)) continua visível.

### A-D2. Pano sobre o túmulo

| Item | Valor |
|---|---|
| Onde | dois panos pendurados rente às faces do corpo de cima do túmulo, no lado sul (o que a câmera vê de frente) e na ponta leste; saem de logo abaixo da borda da tampa e descem até 0,45 m do chão, sempre dentro do contorno do obstáculo menos 0,1 m (nunca além do degrau) |
| Medidas | sul 2,0 m de largura (centrado em x 0,5) por 0,9 m; leste 1,2 m por 0,9 m |
| Pano | petróleo fundo (0,06; 0,14; 0,15), barra de ouro velho do estilizado (0,42; 0,31; 0,13) de 0,06 m a 0,08 m da borda e franja curta; no meio do pano sul um losango de ouro velho de 0,22 m (o do filete das cartas) |
| Material | o do estandarte (`banner_lion.gdshader` com o emblema desligado, ou o `reliquary_cloth.gdshader`), sem brilho; pano parado (sem vento numa cripta) |

O leão no pano diria que o túmulo é de alguém do leão: isso é lore. **Pergunta ao Daniel (via Game Director)**: o pano
pode levar o leão? Até a resposta, losango sem emblema.

**Decidido pelo Daniel (PO), 2026-11-19**: o pano pode levar o leão. O pano sul leva o leão de ouro velho do pano do
relicário (`reliquary_cloth.gdshader`, campo `lion_sdf.res`, nada novo) no lugar do losango; o pano leste fica sem
emblema.

### A: o que calar (só estilizado, só na A)

| Peça | Hoje | Pedido |
|---|---|---|
| Luz das velas do degrau oeste do túmulo (`_light_at(west, true)` em `_candles`) | acesa | apagada (`FIRE_SHARE` 0 ou `visible` falso); as velas ficam. A coroa faz essa luz |
| Luz da vela do sarcófago norte (0,5; -5,6) | 1,0 | `FIRE_SHARE` 0,6 (sem isso as duas poças viram uma mancha só) |
| Luzes das velas aos pés das estátuas (A4, as duas) | 1,0 | `FIRE_SHARE` 0,5 |
| Braseiros da porta norte (`BOWL`) | `bowl_gain` 1,5 | `FIRE_SHARE` 0,75 nos dois: continuam acesos, um passo abaixo da coroa |
| Facho frio sobre o túmulo | 1,6 | 1,1 no estilizado da A (`vary` na `light_energy`); continua com sombra e poeira |

Saldo de luzes da A no estilizado: mais 1 (a coroa), menos 1 (a do degrau oeste) = igual. Sombras iguais (a lua de
chave e o facho).

---

## 4. Variante B: a velada do ossuário

O muro do Ossuário (`_sarcophagus(0.5, -7.0, 0.8, 7.0, 3.2, &"block", true)`: x 0,1 a 0,9, z -10,5 a -3,5, topo 3,2 m)
já está no terço superior direito. A figura que hoje fica em cima dele (B1, 3 m) vira o elemento dominante: maior,
acima da cornija, segurando uma lanterna fria, no facho frio, com a parede atrás dela limpa.

### B-D1. A figura velada, monumental

| Item | Valor |
|---|---|
| Plinto | bloco de 1,3 m (x) por 1,1 m (z) por 0,4 m, de y 3,2 a 3,6, centrado em (0,5; -9,5) sobre a ponta norte do muro. Passa 0,25 m do muro de cada lado em x: acima de 2,6 m, permitido. Duas mísulas sob as abas, de y 2,75 a 3,2, afinando para baixo (nunca abaixo de 2,7 m) |
| Figura | `Masonry.hooded_statue` de **4,4 m** (era 3,0) com o pé a y 3,6 e o topo a **8,0 m**, virada para o sul (o lado da câmera), em (0,5; -9,5) |
| Valor | `ArenaKit.STATUE_VALUE` vezes `VEILED_VALUE` 1,5 (era 1,35); camada `STATUE_LAYER` como hoje |
| Material | pedra da figura com `see()` como hoje (abre em pontilhado com o herói atrás do muro); plinto e mísulas na pedra do muro, também com `see()` |
| Silhueta | o topo (tela y 33) passa a cornija (tela y 66 a 77) por uns 35 px: a cabeça velada se recorta contra o fundo escuro, como a copa da árvore do Jardim sobre as paredes |

Atrás da figura na tela fica só a parede norte e o que está além dela: a figura não cobre chão de luta (o chão que se
alinharia com o pé dela está atrás da parede, em torno de (-2,7; -14)).

### B-D2. A lanterna fria

| Item | Valor |
|---|---|
| Onde | pendurada das mãos da figura por uma corrente curta de 0,35 m: mãos em (0,5; 6,0; -9,05), meio da lanterna em (0,5; 5,45; -9,0), sobre o muro (dentro do contorno dele) |
| Peça | `ArenaRoom.hanging_lantern` com uma variante fria (parâmetro novo de cor: hoje ela usa só `TombKit.WARM`): tamanho (0,32; 0,42; 0,32), ferro do estilizado, vidro frio (0,70; 0,86; 0,95) pelo `ScreenTone.fit`, maior canal na tela até 220 |
| Luz | `OmniLight3D` no meio da lanterna, cor `STY_COLD` (0,66; 0,82; 0,92), difusa (`light_specular` 0, como os fachos do Lote B: sem anel no chão), sem sombra, `omni_range` 9,0, atenuação 1,2, `NOT_FIRE` (o `stylize_fires` não mexe), `light_cull_mask` = ~`Arena.CROWD_LAYER`. Acende o topo do muro, os nichos de ossos das duas faces e o chão frio dos dois lados do muro até uns 5 m; força pelo aceite 5.2 |
| O que não pode | verde, ciano vivo (matiz 170 a 190) ou partículas; é luz fria de lanterna, não magia |

### B-D3. O facho frio na figura

O facho frio da B hoje cai no chão na ponta sul do muro (`_cold_shaft`, alvo (0,5; -2,7)). No estilizado da B:

| Item | Valor |
|---|---|
| Origem e alvo | da frente e de cima, (2,5; 14,0; -3,0), mirando o peito e o capuz da figura, (0,5; 6,4; -9,5) (`vary` na transformação do `SpotLight3D`) |
| Cone, cor, força | `spot_angle` 14, `STY_COLD`, 1,6; continua com sombra (o número de sombras não muda) |
| Poeira | a poeira do facho (`arena._dust`) acompanha: no estilizado da B ela cai sobre o topo do muro, embaixo da figura, ou fica escondida; nunca num lugar sem facho |
| Luz própria da figura (B3, `statue_glow`) | fica, energia ajustada junto com o facho pelo aceite 5.2 |

### B: o que calar (só estilizado, só na B)

| Peça | Hoje | Pedido |
|---|---|---|
| Os dois braseiros da porta norte | acesos | **apagados**: chama, halo e luz invisíveis, a tigela de cinza e ferro frio do Lote D (`ArenaKit.brazier(..., lit = false)`, `_cold_metal`); colisão igual (é o obstáculo `_bowl`, nada muda nele) |
| Estandarte sobre o braseiro de x 1,5 | visível | invisível (fica o de x 7,1): era o vizinho da figura na tela |
| Velas aos pés da estátua do nicho norte (x -2,5, A4) | 5 acesas e uma luz | apagadas (`candle_out`) e sem luz: na tela ficam a 80 px da figura |
| Brilho frio da porta norte (`DOOR_GLOW_FOOT_B`) | (0,38; 0,46; 0,50) | igual; é o eco da lanterna. Se passar a figura no aceite, (0,30; 0,38; 0,42) |
| Velas das tampas dos sarcófagos sul | `STY_LID_LIGHT` 0,6 | iguais: são o pouco quente da B |

Saldo de luzes da B no estilizado: mais 1 (a lanterna), menos 2 (braseiros), menos 1 (velas da estátua norte) = menos
2. Sombras iguais.

---

## 5. Aceite (mensurável)

### Como capturar

- Medidas: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- C:/.../crypt_a.png
  --arena=crypt --variant=0 --bare --look=stylized` e o mesmo com `--variant=1`; mais as duas com `--look=classic`
  (prova do clássico). O alvo fica em (1,0; 1,5), o da tabela 2.
- Leitura: `RES=1920x1080 tools/gpu.sh shot <saída> --look=stylized --arena=crypt --variant=0 --bot --autopick --seed=5
  --shot-at=5` e `--shot-at=9` (luta com aviso), A e B; 1280 x 720 também.
- Medir: `python3 -I tools/frame_stats.py <imagem> --hue --scene --box=<caixa> ...` (caixas a 1920 x 1080: x, y, largura,
  altura). "Quente" é a faixa quente do `--hue`.
- Antes e depois em `docs/gallery/redesign/rs_c1/` (A e B, clássico e estilizado, laboratório e jogo).

### 5.1 A (laboratório, estilizado)

| Caixa | Medida | Alvo |
|---|---|---|
| Coroa `905,200,160,95` | quente; luma p90; acima de 235 | quente 15% ou mais; p90 170 ou mais; pixels acima de 235 até 0,5% da caixa |
| Coluna do meio `860,60,260,480` | quente | **8% ou mais** |
| Poça noroeste do túmulo `895,395,80,45` e sudeste `1000,575,80,45` | luma p50, matiz | luma p50 **90 a 120**, matiz 25 a 40 |
| Chão leste do Lote A `1152,432,192,162` | luma p50, saturação, matiz | luma p50 até **80**, saturação 0,12 a 0,19, matiz 200 a 215 (a poça não lava a sala) |
| Pano sul do túmulo (dentro de `900,470,110,40`) | luma p50, matiz | luma p50 25 a 50, matiz 180 a 200; o leão (antes o losango) visível (p90 da caixa 80 ou mais) |
| Tampa do túmulo sob o facho | luma | até 200 (nunca branca) |
| Cena (`--scene`) | quente | **4 a 9%** |
| Relógio `900,0,120,60` | diferença contra o antes | nenhum pixel novo (corrente para em y 64) |

### 5.2 B (laboratório, estilizado)

| Caixa | Medida | Alvo |
|---|---|---|
| Figura `1170,25,100,215` | luma p50, matiz, saturação p50 | luma p50 **70 a 105**, matiz 195 a 215, saturação p50 até 0,30 |
| Parede de referência `1030,120,45,60` | luma p50 | a figura **30 ou mais acima** dela |
| Cabeça acima da cornija `1195,30,40,32` | luma p50 | 40 ou mais (o fundo além da cornija fica abaixo de 30) |
| Lanterna `1175,125,45,45` | luma p90, matiz | p90 **150 a 220**, matiz 190 a 215; nada entre 170 e 190 com saturação acima de 0,3 |
| Braseiros `1235,215,90,90` e `1445,265,90,90` | quente, luma p90 | quente até 1%, p90 até 100 |
| Chão dos dois lados do muro `1085,330,70,50` e `1270,330,70,50` | luma p50, matiz | 60 a 80, matiz 198 a 215 |
| Cena (`--scene`) | quente | **1 a 3%** |

### 5.3 De relance (A contra B)

- Na mesma câmera: o quente da cena da A pelo menos **duas vezes** o da B; na caixa da coluna do meio
  `860,60,260,480`, A 8% ou mais e B até 2%; na caixa da figura, B 30 ou mais de luma p50 acima da A.
- Miniaturas de 320 x 180 (`ffmpeg -i x.png -vf scale=320:-1`) das capturas de jogo A e B em `--shot-at=5` e `9`
  embaralhadas: o art-director acerta as quatro sem olhar o nome. (A aprovação final é do Daniel no teste.)

### 5.4 Combate e regras

- Capturas `--shot-at=9`: herói achado em 1 s; avisos dos inimigos com o aro 40 ou mais acima do chão também dentro da
  poça da coroa (a poça é a parte mais clara do chão de luta da A: conferir um aviso nela; se perder, baixar a poça,
  nunca mexer no aviso). Nenhum inimigo escondido atrás da coroa ou da figura (a coroa abre em volta do herói; a
  figura fica sobre a parede).
- `tools/fit_probe.gd -- --arena=crypt --variant=0` e `1`, `--look=classic` e `stylized`: fantasma e peça sem desenho
  iguais aos de hoje (até 0,1 m² de diferença).
- `tests/test_room_style.gd` passa (ida e volta das duas variantes, nada do estilizado sobre o chão livre entre 0,3 e
  2,6 m, colisão igual); o teste ganha: as peças novas só no estilizado, número de luzes com sombra igual, número de
  luzes acesas no estilizado igual ou menor (A igual, B menos 2).
- 8 sementes do robô em cada variante (`tools/smoke.sh 120 --arena=crypt --seed=N` e `--variant=1`), nenhum `stuck`.
- Clássico: capturas A e B iguais às da galeria do Lote A (diferença só em chamas e partículas).
- Nada de cruz, sol, auréola, caveira nova, verde ou ciano vivo; nenhum texto nas peças.

### 5.5 Quadro

- `tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 --gpu-index 1 -s tools/sty_probe.gd -- --nosave --bot
  --autopick --seed=5 --look=stylized --arena=crypt --quality=baixa --probe-wait=6 --probe-for=6` (e `--variant=1`), duas
  rodadas antes e duas depois: a média de qps depois **não abaixo** da média de antes menos 1 qps (ruído medido nos
  lotes: cerca de 1). O mesmo na RTX a 1080 Alta, até 0,1 ms a mais de GPU.
- Peças novas mescladas pelo `Masonry` nos materiais que já existem (ferro, cera, chama, pedra, pano): no máximo 4
  chamadas de desenho a mais por variante. Correntes por `ArenaKit.chain` (MultiMesh).
- Compatibility (`DRIVER=opengl3 tools/shot.sh`, uma por variante): sem erro de shader; poça da coroa até luma 140.

---

## 6. Riscos

1. **A coroa sobre a cabeça do herói**: com o herói uns 6 m a noroeste do túmulo, a coroa fica entre ele e a câmera.
   Por isso ferro, cera e chama abrem em pontilhado (`see()`); se a abertura não bastar no aceite 5.4, subir o anel
   até y 6,6 (tela y 205 a 260) antes de afiná-lo.
2. **Poça clara demais**: a coroa e o facho frio somam no túmulo. Ajustar a coroa pelo `FIRE_SHARE` e o facho da A pela
   energia; nunca acender a pedra ao redor para equilibrar.
3. **Figura grande demais para a sala**: 4,4 m sobre o muro dá o topo a 8 m, 1,5 m acima da cornija da parede de
   trás (6,5). É de propósito (é o marco), mas se no teste parecer gigante, 4,0 m com o topo a 7,6 ainda passa a cornija.
4. **B escura demais sem braseiros**: o chão da B continua no alvo do Lote A (60 a 78) pela lanterna, o ambiente e as
   velas das tampas; se cair, subir a lanterna, não reacender os braseiros.
5. **Pano com leão**: decidido pelo Daniel em 2026-11-19 (seção A-D2): leva o leão.

## 7. Esforço

1 a 1,5 sessão do environment-artist (coroa e pano 0,5; figura, lanterna fria e facho 0,5; calar, medir e teste 0,5),
mais a revisão do art-director e uma passada do QA nas capturas de luta.
