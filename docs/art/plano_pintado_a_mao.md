# Plano: A Selagem com arte que parece pintada à mão, em todos os mapas

Art Director, 2026-11-22. Só plano: nenhum código, captura ou crédito do Meshy. **Resposta curta**: só com código o jogo fica limpo e estilizado,
não pintado. O salto vem de **4 folhas de textura pintadas, usadas por todas as salas**, recoloridas por sala pelo shader, mais luz com borda de
pincel, fundos pintados e figuras no mesmo traço. Não são 11 pinturas: é um jogo de folhas e 11 paletas. O maior risco é a folha não prestar; por isso o piloto.

Evidência (olhada, existente): `F` = `C:\Users\danie\tools\shots\f__NN.png` (22/11; 00 a 13 Salão, 15 a 21 Fenda, 22 e 23 Cripta); `B` = `b_morvath.png`, `b_elder_worn.png` (mesma
pasta, chefe no Salão, só figuras); `A` = `docs/gallery/art_review_1121_after/`; `L7` = `docs/gallery/lote7/`; `CV` = `docs/gallery/ciclo_visual_1120/`; `LV` = `docs/gallery/lote_visual/`.
R1 = referência pintada do Daniel (`docs/art/ref/stylized_2026-11-18/01_...`, só local). Números: `tools/frame_stats.py --scene --hue` e caixas de luma de 200 x 150.
A, CV e LV são de 20 e 21/11: **antes do piloto, uma rodada nova de 11 capturas de base** pela sessão principal.

## 1. Diagnóstico
**Causa raiz (lida no código): fora a paleta chapada do KayKit, nenhuma pedra ou chão tem textura de cor.** Pedra e chão são conta (`masonry.gdshaderinc`, `catacomb_floor.gdshaderinc`: ruído de valor `fract(sin)`);
a única imagem é o relevo de rocha CC0 (`rock_surface`, normal e altura). As figuras têm textura do Meshy, meio realista. São dois traços na mesma tela. Em toda sala:
- **D1 Bloco liso com tracinho.** Cada bloco é uma cor, uma junta e uma mancha; nada conta como ele gastou. F05 (muro à direita do portal) e A08 (muro de perto).
- **D2 Luz de refletor.** Borda da luz é curva perfeita de spot: A09 (disco âmbar, embaixo à direita), A08 (clarões em volta do herói), F23 (disco na coluna).
- **D3 Chão calmo demais.** A regra "p90 menos p10 até 30" (ENV-HB2, `CALM_FLOOR`) tirou o detalhe junto com o ruído: Salão, em duas caixas **45/54/71** e 53/72/88 (p10/p50/p90); R1 52/83/91. Na Cripta (38/65/111) e nas Runas (21/35/101) a amplitude vem da borda da luz e da junta, não de pintura.
- **D4 Um matiz por tela.** F19 é índigo, L7 garden é oliva, CV altar é marrom: luz, base e sombra quase na mesma cor. Pintura varia a temperatura; nossa sombra só multiplica (`paint_shadow`).
- **D5 Silhueta de caixa.** Balaústre, degrau, pilar e bloco do abismo são retos e repetidos (F23, borda de baixo; CV altar, dentes da borda).
- **D6 Vazio sem pintura.** Barras verticais e neblina lisa (F23 à esquerda, CV trial, F19 ao fundo preto).
- **D7 Adesivos.** Poeira de osso e juntas extras lidas como colagem: F05 (930..1060, 690..780): mancha (125;120;111) sobre laje (55;54;51), luma 120 contra 54.

| Sala (captura) | Medido na cena (matiz, sat, luma p10/p50/p90) | O que mais impede, nela |
|---|---|---|
| Salão (F05) | 209, 0,39, 31/62/110 | D1 nas paredes; D3; soldado de capuz luma 45 sobre chão 72 some no preto, sem forma interna; D7 |
| Cripta (F23) | 195, 0,37, 13/43/95 | um quarto da tela é muro escuro sem desenho; tampas e tumbas com filete reto; D6 |
| Fenda (F17, F19) | 254, 0,41, 16/43/89 | um matiz; lajes sem borda pintada (F19 no meio); fundo preto; ponte de tábua rosa sem veio |
| Jardim (L7 garden) | 82, 0,28, 17/46/82 | árvore e raiz com a mesma textura do chão; folha e capim viram mancha; inimigo some no oliva |
| Santuário (A08) | 50, **0,18**, 30/69/115 | a mais cinza: chão luma 124 contra sombra perto de 30, sem cor na sombra; colunas lisas; buraco azul chapado |
| Ponte (A09) | 224, 0,39, 18/42/110 | melhor contraste quente e frio do jogo; discos de luz perfeitos; blocos iguais |
| Runas (A10) | 233, 0,29, 10/44/92 | grade de azulejo de planilha, junta reta e fina; terço de baixo vazio |
| Câmara de Morvath (A11) | 250, 0,43, 9/41/87 | **a mais perto de pintura**: laje irregular, junta grossa, poça violeta. Morvath branco e preto, sem meio-tom; abismo com costuras verticais |
| Provação (CV trial near) | 267, 0,32, 13/42/88 | metade da tela é neblina lilás lisa; veias finas como linha de CAD |
| Altar (CV env3 near) | 30, 0,42, 20/42/94 | tijolo grande igual em tudo, um marrom só; metade esquerda vazia; altar pequeno |
| Santuário hub (LV hub) | 45, 0,30, 21/44/79 | pedra irregular boa, cinza e escura demais; folhas e brasão mostarda; nada de primeiro plano pintado |

## 2. O que já existe e por que não basta
- **`paint.gdshaderinc`**: três faixas de luz, poça com borda, pincelada de ruído em 3 degraus (0,88 a 1,12; no chão calmo 0,95 a 1,05, **invisível**). Ruído não é pincelada: não segue a forma nem
  decide onde fica o claro. É a fundação certa; falta alimentá-la com imagem.
- **`masonry_paint`, `catacomb_floor_paint`, `rune_floor_paint`, `kaykit_paint`, `root_moss_paint`**: cor por bloco, lábio claro, junta fria. Boa notícia: já calculam **o id e a posição dentro de cada
  bloco**, o que permite colar uma laje pintada diferente em cada um, sem repetição visível. `STYLE` por sala (`ArenaKit.paint_look`) já leva cor por sala. A Câmara usa `chamber_floor` (sem `PAINT`).
- **`PaintPass`**: Kuwahara (0,14 ms) desligado: borra runa e rachadura e briga com o MSAA; com textura pintada não é preciso. **Tinta** (contorno por profundidade) ligada: fica, mais leve (3h).
- **Figuras** (`figure_paint`, `hero_paint`, `crowd`): faixas, contorno e `style_flat` 0,35 sobre textura realista.
- **Faltam**: (a) folhas pintadas de valor, borda e desgaste; (b) paleta de 4 a 5 cores por sala com sombra de outra temperatura; (c) borda de luz em pincel; (d) silhueta gasta;
  (e) fundo e primeiro plano pintados; (f) decalques pintados; (g) figuras repintadas no mesmo traço.

## 3. Receita por camada
Custos são **estimativa minha, a medir no piloto**. GPU em ms na RTX 5060, 1080, Alta (hoje a sala custa 2,4 a 2,8 ms de GPU). Teto total: **+1,0 ms**. H = horas de agente (biblioteca, valem para todas as salas).

| Camada | Como | Quem faz | H | GPU | Risco |
|---|---|---|---|---|---|
| 3a Folhas pintadas | 4 atlas 2048 (BC7, cerca de 22 MB de vídeo): **lajes** (12 a 16 células), **blocos** (idem), **faixas** (borda de degrau, tampa, coluna, madeira, metal), **manchas e decalques** com alfa. Em **cinza (valor)**: a cor vem da paleta. Cada bloco sorteia a célula pelo id e espelha | **Daniel/ChatGPT pinta**; agente recorta, nivela valores (média 0,5, p10 a p90 0,38 a 0,62) e tira a luz embutida (`ffmpeg`/Godot). Plano B: folha feita em código, que fica "bordada", não pintada | 6 + 2 por folha | +0,15 (pode cair: troca ruído por leitura, hipótese) | **Alto**: IA entrega perspectiva ou luz forte; até 3 rodadas por folha |
| 3b Paleta por sala | rampa de 4 cores mais acento em função do valor final (seção 5), aplicada **na textura e na luz** (sombra puxa para a cor de sombra, sem multiplicar cinza) | código + `STYLE` | 4 | +0,03 | médio: invadir cor reservada (vermelho, esmeralda, violeta) |
| 3c Luz com borda de pincel | desloca o corte das faixas e a borda da poça por uma textura de pincelada em mundo (amplitude 0,12 de N·L, 0,4 a 1,2 m); poça com 2 anéis quebrados | código + 1 textura 512 de pincel (feita em código serve) | 3 | +0,05 | baixo; cuidado com cintilação no movimento |
| 3d Silhueta | variantes por código: cantos comidos, tampas tortas (1 a 3 graus), coluna afinada, degrau gasto, 3 alturas de balaústre; teto: não muda colisão nem `RESULT` | código | 8 | 0 a +0,1 | médio: chamadas de desenho |
| 3e Fundo, primeiro plano | 3 camadas de cartões pintados com alfa (perto, meio, longe) e cortina de neblina de bordas pinceladas; o giro da câmera é fixo, cartão 2D funciona. Moldura: 1 peça escura por canto fora do miolo | **Daniel/ChatGPT pinta** 1 folha por família (6: catacumba, abismo, ruína, floresta, templo, hub) | 5 + 1 por sala | +0,20 (sobreposição) | médio: cobrir aviso ou herói |
| 3f Decalques | troca poeira, musgo, rachadura e sombra de canto por recortes da folha 4; luma máxima do decalque = chão + 25 | código | 3 | +0,05 | baixo |
| 3g Figuras | textura repintada por script **sem IA**: luz do alto, 3 degraus, sombra colorida, aresta clara, rosto e mãos legíveis (a UV do Meshy é picada: à mão não dá). Começa por Guerreiro, esqueleto, arqueiro, Escudo; depois Morvath e elites | `technical-artist`, Godot/ffmpeg | 10 | 0 | alto: rosto do herói (guardar o original; o Daniel aprova) |
| 3h Pós | nenhum filtro de tela novo; só tinta de 0,7 para 0,45 de alfa nas paredes | código | 1 | 0 | baixo |

Total: **cerca de 48 H de biblioteca** (28 no piloto, o resto dentro dos lotes 2 a 6) mais **3 a 4 H por sala**. Créditos do Meshy: **zero**. iGPU já está no limite (cerca de 17 ms em 720 Baixa):
`GraphicsQuality` Baixa usa folha de 1024, sem cartões do meio; se passar de +0,5 ms lá, volta ao shader de hoje.
**`docs/steam-ia.md` ganharia (não editado agora)**: na seção "Pré-gerado", uma linha por folha ("texturas de cenário `assets/textures/paint/*`, geradas por IA pelo Daniel no ChatGPT, tratadas em código; vão no
jogo"), outra para os cartões de fundo e outra: "as texturas das figuras do Meshy são retocadas por script, sem gerador". Se o Daniel pintar à mão, diz-se isso. Prompts e originais ficam só locais (`docs/art/ref/`).
Folha com texto, símbolo religioso ou logotipo é descartada; entregar só o que o Daniel puder usar comercialmente.

## 4. Fases
**Fase 0 (Daniel, 1 a 2 h)**: gerar 3 folhas de teste (lajes, blocos, faixas) com os prompts da seção 5. **Portão**: se nenhuma passar no recorte de teste (sem luz embutida, sem perspectiva, valores na faixa), paramos e o Daniel decide
entre pintor humano, pintar ele mesmo ou folha por código. Nenhuma hora de agente gasta antes disso, fora o recortador.

**Fase 1, piloto: o Salão** (1 lote: `environment-artist` e `technical-artist`, até 28 H). Por quê: é a sala de abertura, da loja, da Fonte e do guardião; tem a R1 e a arena do Daniel para comparar; usa todas as peças.
Entram 3a, 3b, 3c, 3f e Guerreiro + esqueleto da 3g; o resto do Salão ganha só o que couber. Troca pelo perfil (`VisualProfile.vary`); F7 continua o antes e depois. Prova: **4 pares antes/depois** pela sessão principal
(vitrine; luta aos 9 s; sala com perigo e mira armados `--stress=7`; loja), mesma semente, Perto, estilizado, 1080; mais `docs/art/visual_review.md`.
**Aceite** (medir no Salão; todos têm de passar):
1. **Valores**: chão nu p10 a p90 entre 30 e 42, luma p50 52 a 62; cena 31/62/110 com tolerância de 8; nenhum ponto de cenário acima de luma 200 (fora as chamas); até 5% da cena abaixo de 12.
2. **Pintura**: 5 blocos vizinhos sem a mesma célula na mesma posição; numa caixa de 100 px de parede, 3 valores separados por 12 ou mais de luma; sombra com matiz a 20 graus ou mais da base (hoje não medido: medir no antes).
3. **Contraste**: herói p90 a 60 ou mais acima do chão (hoje 144 contra 72); corpo do inimigo com p50 a 15 ou mais do chão e **p90 a 40 ou mais acima do chão em rosto, mãos ou arma** (hoje arqueiro 45/76 contra 72: passa no p50, reprova no p90; caixa com um pouco de chão); forma interna em pelo menos 3 valores.
4. **Perigo**: aro do aviso com luma 40 ou mais acima da laje, matiz 345 a 10; fora do aviso, vermelho saturado até 0,5% da cena; nenhum decalque ou cartão sobre aviso, herói ou inimigo. Um estranho aponta o aviso em 1 s.
5. **Desempenho**: RTX 5060 a 1080, Alta, sala normal: 60 qps travados, GPU +1,0 ms no máximo sobre a medida do mesmo dia; `--stress=300` com perda até 2 qps (base registrada 52 a 53 a 1672x941); entrada na sala sem engasgo novo; memória de vídeo +60 MB; exe +25 MB.
6. **Regressão**: `RESULT` do `--smoke` igual na mesma semente; quadro clássico igual ao de antes; suíte `test_visual_profile` verde.
7. **Daniel**: diz "pintado" olhando o par; critério de veto, sem percentual de semelhança. Se disser não, o piloto para e nada se espalha.
**Fase 2, as outras 10**, depois do "sim" (um lote por vez, 2 agentes, 2 a 3 salas por lote, 11 capturas do conjunto no fim de cada):

| Lote | Salas | Por quê | H |
|---|---|---|---|
| 2 | Cripta, Altar | mesmas folhas de laje e bloco, cripta é a sala mais escura | 10 |
| 3 | Fenda, Ponte | mesmos blocos, cartões de abismo (6 folhas: 2 novas) | 10 |
| 4 | Runas, Provação | chão próprio (`rune_floor_paint`), estado das lajes não pode mudar | 11 |
| 5 | Santuário, Jardim | a mais cinza e a única orgânica (folhas, casca, copa: 1 folha extra) | 12 |
| 6 | Hub, Câmara de Morvath + elites, sacerdote, Ancião, Morvath | a Câmara é a mais próxima: só paleta e borda de pincel, **sem mexer no valor** e nada no telegraph dele | 14 |

Total: **6 lotes** (piloto + 5), 85 H mais cerca de 10 de captura e revisão (os H da tabela incluem o resto da biblioteca: 3d, 3e, 3g, 3h), 10 a 11 folhas do Daniel (4 base, 6 de fundo, 1 de folhagem). Se precisar de menos: piloto + lotes 2 e 3 já cobrem as salas mais vistas.
Antes do piloto, sem pintura nenhuma, valem como consertos baratos: GR-1 a GR-8 ainda abertos de `review_2026-11-21b.md` (poças, tambores, ossos, musgo, soldados no preto). O resto espera.
Cuidado com decisões anteriores: a paleta respeita a matriz de matizes (benchmark 7.2) e as cores reservadas; a R1 é morna e o Daniel já escolheu o Salão azul-petróleo: fica azul, com **sombra violeta-fria e luz morna**.

## 5. Paleta, prompt de textura e mapa de valores por sala
Paleta = sombra, meia, base, luz (luma perto de 24, 40, base, 104); o acento ocupa até 5% da tela. Proposta de partida, ajustada no piloto.

| Sala | Paleta | Acento | Complemento do prompt de textura | Mapa de valores (claro 60% / meio 35% / escuro 12%) |
|---|---|---|---|---|
| Salão | `#161823` `#212934` `#2F3E4A` `#706758` | âmbar; esmeralda só no portal | laje larga gasta no meio, junta funda | centro do chão / muros / abismo e cantos; luz do alto à esquerda, 2 poças quentes |
| Cripta | `#141820` `#202A2F` `#27373A` `#746654` | chama de vela | pedra úmida, tampa de túmulo lisa, cera escorrida | efígie / lajes / nichos; 3 poças de vela |
| Fenda | `#161724` `#282638` `#363148` `#71665D` | âmbar das lanternas | laje rachada, borda partida, tábua com veio | chão norte / bordas / fenda; luz fria rasante |
| Ponte | `#171725` `#242835` `#303747` `#766653` | âmbar da travessia | cantaria lavada pela água, limo só embaixo | tabuleiro / torres / bruma; quente no meio, frio dos lados |
| Runas | `#191724` `#272736` `#3A3B50` `#6C685D` | âmbar só na laje acesa | laje quadrada polida, quina gasta, sem desenho | lajes / moldura / vazio; luz do alto, uniforme |
| Jardim | `#101B15` `#212B1E` `#323928` `#6F6850` | folha ferrugem, até 4% | casca de árvore de pedra, terra batida, folha seca | clareira / raízes / copa; luz filtrada em manchas |
| Santuário | `#15181C` `#2A2A28` `#433E34` `#706853` | petróleo dos estandartes | calcário claro, quina arredondada, poeira no canto | nave / colunas / buraco e cantos; 2 fachos mornos |
| Provação | `#191724` `#2C2636` `#392E42` `#726472` | lilás da maldição | pedra trincada, cinza, sem veio desenhado | selo / chão / muro; luz fraca do centro |
| Altar | `#1D1618` `#322623` `#382E28` `#77664C` | chama de vela | barro e pedra terrosa, fuligem no alto | altar / chão / muro; poça única no altar |
| Hub | `#16181D` `#2A2826` `#3D382C` `#75674D` | fogo das estações | pedra irregular limpa, capim na junta | estações / praça / borda; uma poça por estação |
| Câmara | `#1B1623` `#2A2638` `#2E2B3F` `#796555` | violeta de Morvath | só rever a laje atual, sem textura nova | selo / laje / abismo; âmbar ao fundo, violeta à esquerda |

Gerador de imagem erra grade exata: por isso pede **peças soltas** e o agente recorta, alinha, nivela e monta o atlas. A folha base é cinza e serve a todas; o complemento só muda o que o desgaste da sala pede.
- **Prompt base da folha**: *"Doze pedras de piso retangulares, soltas, com espaço entre elas, sobre fundo verde liso, para textura de jogo. Pintadas à mão com pincel largo e opaco, vistas exatamente de cima, sem perspectiva, luz difusa uniforme, sem sombra projetada,
  sem brilho, sem contorno preto, sem texto, sem símbolo, sem pessoas. Só tons de cinza: médio 50%, claros até 65%, escuros até 35%. Pinceladas grandes seguindo a forma, borda de cima gasta e mais clara, cantos lascados, cada peça diferente. Visual próprio,
  sem imitar jogo, estúdio ou artista."* Blocos: trocar por "doze blocos de muro, proporção 2 por 1, sujeira na base". Faixas: "degraus, tampas, colunas, tábuas e ferragens". Manchas: "musgo, poeira, rachadura e folhas, peças soltas de tom médio". Acrescentar no fim o complemento da sala.
- **Prompt do mapa de valores (Salão)**: *"Estudo de valores, vista alta inclinada de uma sala de catacumba sobre o abismo, só três tons chapados, sem detalhe e sem textura: claro 60% no centro do chão, meio 35% nos muros, escuro 12% no abismo e nos cantos; luz do alto à esquerda e duas poças pequenas claras."* Nas outras, trocar pela última coluna. É guia para o agente, **nunca vai para o jogo**.
- **Prompt de fundo (Salão)**: *"Abismo de catacumba com pilares e arcos quebrados em três planos, o de longe só silhueta, neblina de pincel entre eles, azul-petróleo, cada plano solto sobre fundo verde liso, sem texto nem símbolo, sem imitar jogo ou artista."*
Perguntas ao Daniel: (1) as folhas saem do seu ChatGPT, da sua mão ou de um pintor? (2) aceita retocar as texturas das figuras, com o original guardado? (3) o Salão como piloto serve?
