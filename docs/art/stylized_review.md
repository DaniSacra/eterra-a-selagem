# Parecer de arte da prova estilizada (STY-09)

- **Data**: 2026-11-18. **Autor**: art-director. **Commit lido**: `03fc59b` (`arpg-3d`, STY-03 a STY-07 juntos), mais os
  ajustes de número deste parecer (seção 5), ainda sem commit.
- **Base**: os 12 critérios da `docs/art/stylized_spec.md` seção 8; números medidos pelas frentes em
  `docs/art/stylized_poc_plan.md` 2.4; referência principal R1 (só local, imagem de IA, nunca evidência).
- **Capturas** (nossas, RTX 5060, Forward+, Alta, `tools/gpu.sh`, 1920 x 1080 e 1280 x 720, `--seed=5`), só no scratchpad
  da sessão, como o Daniel pediu (nada de imagem no repositório): para cada look (`--look=classic` e `--look=stylized`)
  o jogo `--bot --autopick --shot-at=9`, a vitrine `--showcase --shot-at=2`, o golpe `--shot-on=swing` e `--shot-on=hit`,
  o estudo `--cam-dist=33` (jogo e vitrine; câmera fora do jogo, só para avaliação) e o jogo a 720. Depois dos ajustes:
  o estilizado de novo (jogo, vitrine, golpe, estudo), o estudo com `--paint-pass=1` e o clássico de novo para conferir
  que não mudou.
- **Como medi**: `python3 -I tools/frame_stats.py` no quadro inteiro; caixas de pixels (média RGB, matiz, saturação, luma
  Rec. 709 p10, p50 e p90) nas lajes, paredes, potes, herói e lâmina; contagem de pixels com os três canais acima de 235
  sobre o herói; diferença pixel a pixel entre o clássico antes e depois dos ajustes.
- Sem porcentagem de semelhança: descrevo as diferenças que sobram. A aprovação da direção é do Daniel.

## 1. Os 12 critérios

| # | Critério | Veredito | Por quê (medido no estilizado, depois dos ajustes da seção 5, salvo dito) |
|---|---|---|---|
| 1 | Leitura sem filtro | **passa** | Com o `PaintPass` desligado a pedra lê pintada a 1080 na câmera do jogo: cada laje com valor próprio, pincelada em manchas largas, junta escura desenhada, uma laje em várias puxando para o oliva, topo das balaustradas e pilares com a aresta clara. Nada disso depende do filtro |
| 2 | Valor da sala | **passa com ressalva** | Luma média do quadro 67 a 70 (meta 60 a 72; clássico 54); saturação p90 16 a 18 (meta 14 a 22; clássico 23 a 26). Meio do chão p50 77 a 84 (meta 65 a 80: passa do teto em até 4 na laje mais iluminada); borda do chão 50 a 63 (meta 50 a 62); frente da balaustrada sul 45 (era 61 antes do ajuste da chave, acima do chão de borda); abismo e vãos azuis, a profundidade é o mais escuro. A ordem da 1.3 está certa |
| 3 | Luz | **não passa** | Frio só na profundidade: sim (pedra matiz 36 a 42, abismo 209). Nenhuma parede lavada por luz sem fonte: sim. Sombra projetada do herói: antes do ajuste **invisível** (a chave vinha 17 graus da linha da câmera e a faixa de sombra guardava 42% da chave: a sombra caía atrás do corpo e quase não escurecia); depois, visível e definida ao lado dos pés, ainda fraca contra a R1. **Poças das tochas: não existem.** Ao lado do braseiro leste a laje mede luma 33 a 69 e o meio da sala 79 a 84: o fogo não faz poça nenhuma; as velas viraram cilindros creme com chama pequena, sem calor em volta. Testei o braseiro a 0,9 da energia (era 0,5) e a laje não mudou (voltei para 0,5): o ambiente forte e a chave encobrem o fogo. É o pedido 1 da seção 4 |
| 4 | Material | **passa com ressalva** | Lajes vizinhas com valores diferentes (63 a 104 na mesma caixa, em degraus, não em ruído), 2 a 3 tons dentro da laje, aresta clara visível nas balaustradas e pilares a 1080, nenhum relevo fotográfico de rocha a 1080. Ressalva: o medalhão do chão perdeu o ouro (pedido da spec) e também a leitura das runas, que viram manchas no anel; o anel ficou com a borda dupla e mole. A pintura aprovada de 2026-11-14 tem as runas gravadas |
| 5 | Personagens | **passa com ressalva** | Herói achado em menos de 1 s nas capturas de luta a 1080 e a 720 (cabelo vermelho, anel petróleo, contorno escuro contínuo, Emeth). Contorno contínuo nos inimigos a 1080: sim, 1 a 2 px. Mas **os corpos não ficaram mais escuros que o chão**: os esqueletos medem p50 86 sobre laje de 79 a 84 (osso claro sobre pedra clara, separados só pelo contorno: no clássico o osso claro sobre a laje escura lia melhor); no herói o forro creme da capa é a mancha mais clara do corpo e a borda morna não é a mais clara da tela. Elites: nenhuma nas capturas desta semente, não verificado |
| 6 | Coerência | **passa com ressalva** | Pedra, chão, figuras e props passam pela mesma luz em faixas e o mesmo rim morno. Achei uma peça fora: os potes eram `StandardMaterial3D` com o barro de antes e, sob a chave estilizada, saíam laranja vivo (luma 120, saturação 0,69, a cor mais forte do salão depois do fogo): corrigido (seção 5), agora barro umbra (saturação 0,47). Ficam de brinquedo: as velas grandes (cilindros creme lisos) e os caixotes do KayKit, nos dois looks |
| 7 | Combate | **passa com ressalva** | O corte do `--shot-on=swing` mostra a metade de trás em pinceladas partidas; miolo da fita luma 177 (teto 235). O fio da borda de ataque estoura (311 pixels acima de 235; o clássico tem 275, é herdado). A Emeth estourava mais que no clássico (155 pixels brancos na lâmina erguida contra 47; 41 sobre o herói em luta contra 11): corrigido para 67 e 26 (seção 5), o que sobra fica onde o clássico também estoura. Aviso e fio da mira: +50 de luma sobre a laje (medida do STY-06/08; meta 40), não refiz. Raio-x: não capturado aqui, testes verdes. **A palavra final da leitura é do `combat-feel-director`** |
| 8 | Identidade | **passa** | Estandartes petróleo com o leão em ouro velho, um rasgado; nenhum símbolo recusado entrou (sem estrela, cruz, estandarte vermelho, marca circular); o medalhão de quatro pontas segue sem ouro (S-Q6 aberta); cores reservadas no matiz (Emeth esmeralda, petróleo do herói, violeta só nos feitiços, verde do portal); vermelho saturado só nas barras de vida, no HUD e nos avisos (os potes laranja saíram) |
| 9 | Fantasia sombria, não infantil | **passa com ressalva** | Paleta sóbria, nada de cor de doce, contorno de casca fino (0,04 e 0,045 m, 1,5 a 2 px a 1080), proporções iguais. Ressalva: sem as poças de fogo e com as figuras no mesmo valor do chão, a sala fica clara e uniforme e perde parte do peso do clássico; velas e caixotes acentuam o ar de brinquedo |
| 10 | Filtro (`PaintPass`) | **descartado, concordo** | Conferi no estudo com `--paint-pass=1`: o quadrifólio gravado no meio do medalhão quase some e as runas borram (critério de descarte 2); o technical-artist mediu o mesmo nas rachaduras e pontos escuros nos corpos (1) e o conflito com o MSAA da Alta. Custo passa (0,14 ms, teto 1,0), mas lado a lado não aponto pintura que o material ainda não dê (4). Fica desligado (`DEFAULT_ON` false) |
| 11 | Clássico intacto | **passa** | O clássico capturado depois dos meus ajustes contra o de antes: só mudam os pixels das chamas e brasas (todos nas células dos braseiros), nada mais acima de 2 por canal. `test_visual_profile` e `test_stylized_figures` verdes |
| 12 | O que depende de asset | **lista na seção 6** | Forma esculpida (estátua encapuzada, braseiro em pedestal, moldura do portal), velas e caixotes de brinquedo, armas próprias. Só estimativa, gasto zero |

**Veredito pela regra da spec**: um critério não passa (3, poças das tochas). Formalmente a prova **volta ao STY-04 só
nesse item**; todo o resto está pronto para o Daniel julgar. Como o lado a lado já mostra a direção inteira (pedra,
valor, figuras, golpe), recomendo que o Game Director mande ao Daniel junto com a correção das poças, sem esperar outra
rodada de revisão minha se a medida do pedido 1 bater.

## 2. O que ficou bom

- **A pedra**: é a maior conquista e funciona sem filtro. O salão deixou o lilás (matiz 244 a 261) e virou a pedra
  umbra-oliva da R1 (matiz 36 a 42), com laje de valor próprio, pincelada e junta desenhada; o abismo continua azul e
  frio, então o frio está só na profundidade, como na R1.
- **Valor e saturação do quadro** dentro das faixas da spec, a R1 medida (67 e 15) quase exata.
- **Estandartes petróleo com o leão**: leem como peça de Eterra, não como os vermelhos que gritavam perigo.
- **Estátuas e cantaria** na pedra morna leem esculpidas e pesadas; com a chave de lado as estátuas projetam sombra.
- **Contorno de casca** em todas as figuras: fino, contínuo, sem manchas por dentro do pano; separa as figuras do chão
  claro sem cara de desenho animado.
- **Emeth em duas faixas e corte com cauda em pinceladas**: é o traço da R1 que mais vende "pintado" em movimento.
- **Reversível e barato**: F7 troca ao vivo, o clássico fica igual, o quadro custa o mesmo na RTX (2,63 ms contra 2,80) e
  na iGPU (15,75 contra 15,05 ms), nenhuma textura nova.

## 3. O que falta para a adoção

1. **Poças de fogo** (critério 3): braseiros e velas fazendo luz quente de borda definida no chão, como na R1. Hoje o
   fogo não pesa nada na sala.
2. **Figuras mais escuras que o chão** (critério 5): esqueletos e capa do herói estão no valor da laje; a R1 tem corpo
   médio-escuro com borda morna.
3. **Medalhão**: runas e quadrifólio legíveis a 1080 (traço de 3 px no valor da junta) e a decisão S-Q6 (as quatro pontas).
4. **Decisão S-Q5** do Daniel (pedra morna no estilizado contra a regra "cenário frio" do `art_direction.md`).
5. **Revisão do `combat-feel-director`** (avisos, golpe, herói legível em luta cheia) e do technical-artist (orçamento final).
6. **Compatibility e iGPU na Baixa** conferidos depois destes ajustes (não capturei: o Daniel julga no desktop primeiro).
7. **Migração** (plano 1.6): só o salão está pintado; as arenas e a Câmara do Selo herdam figuras e efeitos mas não a
   pedra nem a luz. Até lá, F7 numa arena mostra uma mistura.

## 4. Pedidos de correção (valores e responsável)

| # | Pedido | Valores | Responsável | Aceite (medido em captura da RTX a 1080, câmera do jogo) |
|---|---|---|---|---|
| 1 | Poças de fogo no salão | partir de `CatacombHall.STY_BOWL_GAIN` 0,5 para 1,4 e `STY_CANDLE_GAIN` 0,6 para 1,2, `paint_pool` 0,06 para 0,1 (borda mais alta), e compensar o meio com `VisualProfile.AMBIENT_GAIN` 1,2 para 1,0; se a laje ao lado do braseiro não subir (o fogo está alto, no pilar), luz de poça própria sem sombra no pé de cada braseiro, `omni_range` 2,5 m, só no estilizado | `environment-artist` | laje a 1,5 m de um braseiro ou grupo de velas acesas com luma 110 a 150, matiz 28 a 34; borda da poça visível; meio da sala ainda 65 a 80; luma média do quadro 60 a 72 |
| 2 | Corpos mais escuros que o chão | multidão: `style_light` 0,32 para cerca de 0,24 até o esqueleto ficar com p50 de 50 a 60 (hoje 86); herói: `value` 0,34 para 0,28 e `rim` 0,5 para 0,7, para a borda morna ser o mais claro do corpo e o forro creme da capa descer; pisca, "vai bater" e elites iguais | `technical-artist` | esqueleto p50 50 a 60 sobre laje de 75 a 85; borda do herói luma 150 a 180; nenhum pixel acima de 235 no corpo (a Emeth à parte) |
| 3 | Medalhão legível | runas e quadrifólio com traço de pelo menos 3 px a 1080 no valor da junta, anel sem borda dupla | `environment-artist` | runas contáveis na captura de estudo e reconhecíveis como gravura na do jogo |
| 4 | Fio da borda de ataque do corte | o fio do `slash.gdshader` no estilizado abaixo de 235 (hoje 311 pixels estouram; no clássico 275) | `technical-artist`, com o `combat-feel-director` | fio contínuo, sem pixels acima de 235 |

## 5. Ajustes de número que fiz (só no perfil estilizado; o clássico não muda)

| Arquivo | De | Para | Critério | Efeito medido |
|---|---|---|---|---|
| `scripts/core/visual_profile.gd`, `KEY_ROTATION` | (-60, 52, 0) | (-52, 100, 0) | 3, 2 | a chave vem da direita da câmera e um pouco de trás: a sombra das figuras cai ao lado (para a esquerda na tela, como na R1) e não atrás delas; as frentes viradas para a câmera escurecem (balaustrada sul 61 para 45), a ordem de valor da 1.3 fecha. Chão no meio igual (77 a 84) |
| `assets/shaders/paint.gdshaderinc`, `paint_values.x` (só os shaders pintados do cenário) | 0,42 | 0,25 | 3 | a faixa de sombra guardava 42% da chave e a sombra sumia; agora a sombra do herói aparece ao lado dos pés. Quadro 67 a 70 de luma |
| `assets/shaders/emeth.gdshader`, `style_cap` | 0,98 | 0,6 | 7, 5.4 | teto da luz da lâmina no estilizado |
| `assets/shaders/emeth.gdshader`, `style_lit` (novo, só no ramo estilizado) | 1,0 (implícito) | 0,25 | 7, 5.4 | a lâmina recebia a chave de 1,6 no albedo do cristal e estourava em branco; agora a cor dela é a das duas faixas. Pixels acima de 235 na lâmina erguida 155 para 67 (clássico 47); sobre o herói em luta 41 para 26 (clássico 11) |
| `scripts/render/emeth_sword.gd`, `STYLE_CORE` | (0,72; 0,95; 0,8) | (0,56; 0,76; 0,63) | 7 | o fio marfim-menta do meio ia a 255 na tela (exposição 1,25); fica abaixo do teto |
| `scripts/game/masonry.gd`, `STY_CLAY` (novo) com `VisualProfile.vary` no barro dos potes | barro do clássico (0,45; 0,18; 0,1) | (0,3; 0,21; 0,16) | 6, 8, 9 | potes de laranja vivo (saturação 0,69, luma 120) para barro umbra (0,47) |
| `assets/shaders/kaykit_paint.gdshader` e `assets/models/kaykit_paint.tres` | `value` 1,0, sem `saturation` | `value` 0,85, `saturation` 0,55 (novo) | 6, 9 | a paleta do KayKit no estilizado mais apagada e um degrau abaixo: caixotes e velas menos de brinquedo |

Testes: `tools/test.sh -gselect=test_visual_profile` (6 de 6), `test_stylized_figures` (6 de 6), `test_hero_look` (12 de
12), `test_screen_tone` (8 de 8); `tools/check.gd` sem erro. Clássico capturado de novo: igual fora das chamas.

## 6. Assets: o que se reaproveita e o que precisaria ser trocado

**Reaproveitados como estão**: o Guerreiro do Meshy e as animações dele; a Emeth; os nove inimigos e Morvath assados; a
geometria procedural do salão (cantaria `Masonry`, chão, estátuas encapuzadas, estandartes, obeliscos, balaustradas,
ponte, torre, correntes, cartões de ruína e bruma do abismo); avisos, fitas, partículas, raio-x, anel; HUD e fontes.

**Reaproveitados com shader do perfil** (já feito): herói (`hero_paint`, `hero_outline`), multidão (`crowd`, casca em
todos), Emeth, corte e lascas, pedra (`masonry_paint`), chão (`catacomb_floor_paint`), props do KayKit (`kaykit_paint`),
potes e velas (números do perfil).

**Precisariam ser substituídos** (estimativa, nenhum crédito gasto; custos do `meshy_asset_plan.md`: modelo parado 15,
repintura da mesma malha 10, arma 20 a 30):

| Prioridade | Peça | Por quê | Créditos (estimativa) |
|---|---|---|---|
| 1 | Braseiro em pedestal | a poça de fogo da R1 nasce de braseiros dentro da sala, em pedestal; os nossos são tigelas no alto dos pilares das bordas; também resolve parte do pedido 1 | 15 |
| 1 | Estátua encapuzada | aparece 4 vezes e é o que mais lê na moldura; a procedural não tem as pregas fundas da R1 | 15 |
| 2 | Velas em grupo, caixote, barril, jogo de potes | as velas (cilindros lisos) e os caixotes do KayKit leem de brinquedo nos dois looks | 4 x 15 = 60 |
| 2 | Moldura do portal e obelisco | ornamento esculpido que caixas não dão | 2 x 15 = 30 |
| 3 | Armas próprias (cajado, besta, cutelo, foice) | silhueta é forma, não cor; as do KayKit repintadas são paliativo | cerca de 120 |
| só se o Daniel quiser | Repintura dos personagens (lote A) | o shader bastou: a textura do Meshy não destoa da pedra pintada; o problema que sobra (corpo claro demais) é número, pedido 2 | 120 |
| só se o Daniel quiser | Repintura das elites (lote D) | não verificado nesta prova | 60 |

Total recomendado (prioridades 1 a 3): cerca de **240**. Com os lotes opcionais: cerca de **420**. Nada autorizado: o
`technical-artist` leva ao Daniel a estimativa formal de cada lote quando ele decidir.

## 7. Recomendação

**Recomendo adotar a estética estilizada como direção**, porque a pedra pintada, o valor da sala e o contorno das figuras
funcionam sem filtro, custam o mesmo que o clássico e se aproximam da R1 no que importa (quadro mais claro e menos
saturado, pedra morna, frio só no abismo). Antes de adotar:

1. corrigir as poças de fogo (pedido 1) e escurecer os corpos (pedido 2): sem isso a sala fica clara e chapada e o osso
   dos esqueletos se perde no chão;
2. o Daniel responder S-Q5 (pedra morna) e S-Q6 (medalhão), e ver o lado a lado com F7 no exe;
3. o parecer do `combat-feel-director` sobre avisos e golpes no chão claro;
4. só depois disso a migração da 1.6 do plano (base comum, Câmara do Selo, arenas uma a uma), com o clássico reversível
   até o fim, e o Meshy só por lote aprovado (seção 6).
