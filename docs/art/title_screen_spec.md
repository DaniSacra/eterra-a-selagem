# Tela de título cinematográfica: especificação

Data: 2026-11-15. Autor: Art Director. Implementa: `ui-ux-designer` (tela, botões, efeitos 2D); o Game Director
gera a cópia limpa da imagem (botões pintados apagados).

Referência aprovada pelo Daniel: `assets/ui/title/title_screen_reference.png` (1672 x 941, feita por IA, já declarada
em `docs/steam-ia.md`). **Todas as medidas abaixo estão em pixels dessa imagem** (origem no canto superior esquerdo,
x para a direita, y para baixo), tiradas dos pixels (varredura de cor por linha e coluna, recortes ampliados com
grade). Onde está escrito "720p" o valor já foi multiplicado por 1280 / 1672 = 0,7656.

Decisão do Game Director: o logotipo fica na pintura (nada de recriar com fonte, nada duplicado); só os quatro
botões pintados são apagados numa cópia limpa, e botões reais da Godot são desenhados exatamente por cima.

A imagem é arte final desta tela (não é provisória). Limite conhecido: 1672 x 941 é ampliada 1,15 vez em 1920 x 1080,
1,53 em 2560 x 1440 e 2,3 em 4K. Uma versão maior da mesma arte depende do Daniel (ver Pendências).

## 1. Medidas

Eixo vertical comum do logotipo e do menu: **x = 1151** (gema central do logotipo, centro dos quatro botões).

### 1.1 Logotipo (fica na pintura, intocado)

| Item | Retângulo (x0, y0) a (x1, y1) | Tamanho |
|---|---|---|
| Logotipo inteiro (espigão de cima ao de baixo, cauda do A) | (895, 28) a (1420, 360) | 525 x 332 |
| Margem de proteção (nenhum efeito ou botão entra) | (880, 20) a (1432, 368) | 552 x 348 |

O topo do brilho do botão Iniciar começa em y = 388: a folga entre logotipo e menu é de 28 px. A máscara de apagar
não pode subir de y = 378.

### 1.2 Botão Iniciar

Forma: hexágono alongado com um losango de ouro em cada ponta.

| Item | Valor |
|---|---|
| Moldura (contorno externo) | (926, 401) a (1375, 490), 450 x 90, centro (1151; 445,5) |
| Vértices do hexágono | (926, 446), (977, 401), (1324, 401), (1375, 446), (1324, 490), (977, 490) |
| Faixa de ouro da moldura | 7 px de espessura (y 401 a 407 em cima, 483 a 490 embaixo) |
| Filete interno | 1 px, 5 px para dentro da faixa (y = 412 em cima) |
| Losangos das pontas | centros (952, 446) e (1349, 446), meia diagonal 24; gema prateada no meio, meia diagonal 9 |
| Brilho âmbar externo | chega a 12 px fora da moldura: x 916 a 1385, y 388 a 502 |
| Miolo onde fica ícone e texto | (990, 414) a (1312, 478) |
| Triângulo (play) | (1056, 428) a (1088, 466), 33 x 39, centro (1072, 447) |
| Texto "Iniciar" | (1117, 429) a (1242, 462); borda esquerda x = 1117, linha de base y = 462, altura de maiúscula 33 |
| Tamanho da fonte | 51 px na imagem (39 px em 720p) |

**Área a apagar** (com margem de segurança):
- polígono (preferido): (910, 446), (970, 387), (1331, 387), (1391, 446), (1331, 504), (970, 504);
- retângulo equivalente: (906, 378) a (1396, 506).

Atenção: uma tocha do cenário fica atrás da ponta direita do botão (chama em x 1345 a 1360, y 383 a 425). O polígono
preserva a parte da chama acima de y = 408; o retângulo apaga a chama inteira. Por isso o polígono é o preferido.

Cores amostradas:

| Parte | Hex |
|---|---|
| Ouro da moldura, corpo | `#ffca46` |
| Ouro, reflexo claro | `#fdf9c9` |
| Ouro, tom fundo | `#fcaf11` |
| Ouro, borda de sombra | `#cf6e0b` |
| Miolo escuro (centro) | `#331e0e` |
| Miolo junto à moldura de cima | `#572f0d` |
| Miolo, clarão âmbar junto à moldura de baixo (8 px) | `#c86702` |
| Brilho âmbar externo (5 px fora / 11 px fora) | `#b06520` / `#4b3c37`; cor de emissão sugerida `#ff9a1f` |
| Texto | `#f0e8ce`, sombra marrom `#2a1405` deslocada (0, 2) |
| Triângulo | `#fbde97` (aresta clara `#f9eed0`) |
| Gema dos losangos | `#a3bdb0` a `#bddace` |

### 1.3 Botões Como Jogar, Configurações e Sair

> **E2-06 (2026-11-16)**: entrou "O Guerreiro" logo abaixo de Iniciar. Os quatro botões pequenos ficam com 52 px de
> altura a cada 62 px a partir de y 506 (O Guerreiro 506, Como Jogar 568, Configurações 630, Sair 692; termina em 744,
> ainda na faixa escura da arte limpa); texto a 35,5 px do topo, ícone no meio (o do herói é uma espada de pé). As
> medidas abaixo são as da pintura original, de três botões.

Forma: hexágono alongado, fundo escuro, linha fina de bronze apagado, um pequeno ornamento em cada ponta. Os três
são iguais e ficam a cada 71 px.

| Botão | Moldura | Centro y | Vértices do hexágono |
|---|---|---|---|
| Como Jogar | (1008, 515) a (1294, 570) | 542,5 | (1008, 543), (1033, 515), (1270, 515), (1294, 543), (1270, 570), (1033, 570) |
| Configurações | (1008, 586) a (1294, 641) | 613,5 | os mesmos, com y + 71 |
| Sair | (1008, 657) a (1294, 712) | 684,5 | os mesmos, com y + 142 |

Tamanho de cada um: 287 x 56 (220 x 43 em 720p). Vão entre eles: 15 px. Vão entre Iniciar e Como Jogar: 24 px de
moldura a moldura.

| Item | Como Jogar | Configurações | Sair |
|---|---|---|---|
| Ícone (retângulo) | livro: (1052, 529) a (1089, 557) | engrenagem: (1054, 597) a (1088, 632) | energia: (1055, 669) a (1086, 703) |
| Centro do ícone | (1070, 543) | (1071, 614) | (1070, 686) |
| Texto (caixa) | (1115, 536) a (1236, 556) | (1115, 606) a (1258, 627) | (1116, 678) a (1155, 694) |
| Linha de base do texto | y = 552 | y = 623 | y = 694 |

Texto: borda esquerda x = 1115, altura de maiúscula 17, fonte de 26 px na imagem (20 px em 720p).
Miolo onde ficam ícone e texto: x 1040 a 1280, com 10 px de folga em cima e embaixo.

**Área a apagar**:
- polígono por botão (6 px de margem): (1000, cy), (1029, topo - 6), (1274, topo - 6), (1302, cy), (1274, base + 6),
  (1029, base + 6), com (topo, base, cy) = (515, 570, 543), (586, 641, 614), (657, 712, 685);
- retângulo por botão: (1000, 509) a (1302, 576); (1000, 580) a (1302, 647); (1000, 651) a (1302, 718).

Cores amostradas:

| Parte | Hex |
|---|---|
| Linha da moldura (2 px) | `#675b4c` (trechos mais apagados `#534b43`) |
| Fundo escuro | `#111216` no de cima, `#18181d` no do meio, `#1a1a26` no de baixo (levemente translúcido); usar `#131318` com alfa 0,94 |
| Texto | núcleo `#decaae`; usar `UiKit.PARCHMENT` (`#d8c8a8`) |
| Ícones | `#b6a185` a `#baa88e`; usar `#b8a488` |

### 1.4 Menu inteiro

Caixa do menu (os quatro botões com brilho): (906, 378) a (1396, 722), em 720p (694, 289) a (1069, 553).

### 1.5 Tabela em 720p (para o `ui-ux-designer`)

Posição na tela = origem da imagem na tela + pixel da imagem x escala (ver seção 3).

| Item | x | y | largura | altura |
|---|---|---|---|---|
| Iniciar, moldura | 708,9 | 307,0 | 344,5 | 68,9 |
| Como Jogar, moldura | 771,7 | 394,3 | 219,7 | 42,9 |
| Configurações, moldura | 771,7 | 448,6 | 219,7 | 42,9 |
| Sair, moldura | 771,7 | 503,0 | 219,7 | 42,9 |
| Eixo central | 881,1 | | | |
| Texto Iniciar: esquerda / linha de base | 855,1 | 353,7 | fonte 39 | |
| Textos pequenos: esquerda / linhas de base | 853,6 | 422,6 / 476,9 / 531,3 | fonte 20 | |
| Centro dos ícones | 820,7 (Iniciar) / 819,3 | 342,2 / 415,7 / 470,1 / 525,2 | | |

Calcular sempre a partir dos pixels da imagem e da escala real; a tabela é só conferência.

## 2. Ícones (desenhados em vetor na Godot, sem arquivo externo)

| Botão | Ícone | Como desenhar | Tamanho na imagem |
|---|---|---|---|
| Iniciar | triângulo de play | triângulo cheio apontando para a direita, vértices (1056, 428), (1056, 466), (1088, 447); cor `#fbde97` com a metade de cima um pouco mais clara (`#f9eed0`) | 33 x 39 |
| Como Jogar | livro aberto | duas páginas espelhadas com leve curva em cima, lombada no meio, três riscos horizontais em cada página, base dupla (a capa aparece por baixo) | 37 x 28 |
| Configurações | engrenagem | 8 dentes retos, furo central com 40% do diâmetro | 35 x 35 |
| Sair | energia (power) | arco de 300 graus aberto em cima, traço de 4 px, e um traço vertical do centro para cima passando da abertura | 31 x 34 |

Os três ícones pequenos são chapados, numa cor só (`#b8a488`), sem contorno. Mesmo desenho em todos os estados; só a
cor muda.

## 3. Regiões protegidas e regra de escala

### 3.1 Regiões que nunca podem ser cortadas nem cobertas

| Região | Retângulo | Observação |
|---|---|---|
| Rosto do Explorador (com o cabelo) | (430, 300) a (600, 485) | ponto focal da tela |
| Lâmina da Emeth (guarda à ponta, com o brilho) | (145, 655) a (640, 935) | a ponta está a 16 px da borda de baixo |
| Os quatro heróis | (10, 15) a (900, 941) | cruz do clérigo começa em y = 19; adaga da ladina em x = 12; capa do Explorador até x = 895 |
| Orbe da maga | (661, 140) a (850, 273) | |
| Logotipo | (895, 28) a (1420, 360) | |
| Menu | (906, 378) a (1396, 722) | |
| Portal com as duas estátuas | (1390, 250) a (1625, 470) | núcleo verde (1470, 300) a (1560, 440) |
| Lua | (600, 21) a (752, 121) | |

A união vai de x = 10 a 1625 e de y = 15 a 935: **a pintura não tem sobra para cortar**. O que pode sumir sem dano:
até 8 px à esquerda, 12 em cima, 6 embaixo e 47 à direita (o estandarte e a borda do esqueleto do canto).

### 3.2 Regra

- **Conter, nunca cobrir**: escala = min(largura da tela / 1672, altura da tela / 941), imagem centrada nos dois
  eixos, tamanho arredondado para cima. A proporção da imagem (1,7768) é a de 16:9 (1,7778) com erro de meio pixel.
- Com o esticamento do projeto (`canvas_items` / `expand`, base 1280 x 720) a imagem ocupa sempre cerca de 1280 x 720
  unidades lógicas, e os botões seguem a imagem (mesma origem, mesma escala). O menu nunca é ancorado na tela.

| Tela | Unidades lógicas | Imagem | Sobra |
|---|---|---|---|
| 1280 x 720, 1600 x 900, 1920 x 1080 (16:9) | 1280 x 720 | tela cheia | nenhuma |
| 16:10 (1280 x 800, 1920 x 1200) | 1280 x 800 | 1280 x 720 | faixas de 40 em cima e embaixo |
| 4:3 (1024 x 768, 1600 x 1200) | 1280 x 960 | 1280 x 720 | faixas de 120 em cima e embaixo |
| 21:9 (2560 x 1080, 3440 x 1440) | 1680 x 720 | 1280 x 720 | faixas de 200 de cada lado |

- Corte permitido em 21:9 e em 4:3: **zero** (a regra de conter resolve os dois).
- **Preenchimento das faixas** (nada de barra preta chapada, que denuncia a moldura): atrás da imagem, a mesma arte
  limpa em modo cobrir, centrada, bem desfocada e escurecida para 30% (basta uma cópia pequena já desfocada, por
  exemplo 160 x 90, ampliada com filtro linear). As bordas da imagem principal que tocam uma faixa somem num degradê
  de 48 unidades lógicas. Cor de limpeza por baixo de tudo: `#0b0d1c`.
- As camadas de névoa e as brasas cobrem a tela inteira, por cima da emenda, para costurar faixa e pintura.
- Textura: filtro linear com mipmaps; sem compressão com perda visível (o ouro do logotipo denuncia blocos).

## 4. Atmosfera

Regra geral: **a pintura não se mexe**. Nada de deformar, ondular, respirar ou paralaxe nos corpos, nos rostos, na
lâmina ou no logotipo. Tudo abaixo é camada por cima, com mistura aditiva ou alfa baixo.

### 4.1 Névoa (um único shader num retângulo de tela cheia, com uma textura de ruído contínuo de 256)

| Camada | Onde (px da imagem) | Cor | Alfa máximo | Velocidade (px da imagem por segundo) |
|---|---|---|---|---|
| N1, névoa baixa do exército | x 700 a 1672, y 700 a 941; some em degradê entre x 600 e 760 e entre y 700 e 780 | `#6a4fc8` | 0,18 | 8 para a direita |
| N2, névoa do vale e da ponte | x 780 a 1672, y 520 a 760, bordas em degradê de 80 | `#4a3aa0` | 0,12 | 4 para a esquerda |
| N3, bruma verde nos degraus do portal | (1380, 400) a (1640, 520), bordas em degradê de 50 | `#3cff7a` | 0,10 | 5 para cima |

- À esquerda de x = 600 a névoa só existe abaixo de y = 900, com alfa de no máximo 0,06.
- Dentro do rosto do Explorador, da lâmina da Emeth e do logotipo: alfa de névoa 0.
- A névoa fica **abaixo** dos botões (N2 passa atrás do menu, nunca por cima do texto).
- Nas faixas laterais e de cima e de baixo (telas fora de 16:9) N1 continua com alfa 0,10.

### 4.2 Portal

- Partículas: emissão no retângulo (1470, 300) a (1560, 440); 28 partículas; sobem a 20 a 40 px/s com leve desvio
  lateral; vida de 1,6 a 2,4 s; tamanho de 2 a 5 px; cor de `#7dffa0` para `#2bd65a` sumindo no fim; mistura aditiva.
- Halo: um disco suave centrado em (1515, 370), raio 110, cor `#36ff6e`, alfa oscilando entre 0,10 e 0,18, período de
  3,2 s. Verde só aqui e na Emeth (regra do projeto).

### 4.3 Brasas

- Deriva geral: 24 brasas nascendo na borda de baixo entre x 900 e 1672 (sobre o exército), subindo a 25 a 60 px/s
  com balanço lateral de até 12 px; vida de 4 a 7 s; tamanho de 1,5 a 3 px; cor de `#ffb347` para `#ff6a1a`, alfa de
  0,8 a 0; aditiva. Não passam por cima do logotipo (morrem antes de y = 380) nem do texto dos botões (ficam
  **abaixo** da camada dos botões).
- Tochas do cenário: 3 brasas por tocha em (1352, 400), (1636, 400), (1563, 495) e (1354, 558), mesmas cores, vida
  de 1 a 1,8 s, subida de 30 px/s.
- Opcional (segunda camada, só se sobrar orçamento): 10 faíscas violeta `#c58cff` em volta do orbe da maga, centro
  (756, 205), raio 70; 8 faíscas `#9dffb8` soltando da lâmina entre (300, 730) e (600, 890), subindo devagar. A lâmina
  e a mão em si não mudam.

Total: no máximo 80 partículas na tela (100 com as opcionais).

### 4.4 Pulso do Iniciar

- Só o brilho âmbar externo e o clarão interno de baixo pulsam: intensidade entre 0,76 e 1,00 (seno, período de
  2,4 s). Moldura, texto e ícone não mudam de tamanho nem de cor. Sem escala (no máximo 1%).
- Com foco: período de 1,6 s e intensidade entre 0,90 e 1,15.

### 4.5 Entrada e saída

| Momento | Tempo |
|---|---|
| Entrada: pintura do preto ao normal | 0,9 s, desacelerando |
| Entrada: botões | começam em 0,6 s; 0,35 s cada, subindo 6 unidades lógicas, um após o outro com 0,06 s de intervalo |
| Entrada aceita comando | a partir de 0,6 s; qualquer tecla antes disso completa a entrada na hora |
| Saída ao escolher Iniciar | 0,45 s até o preto (`#000000`), botões travados |
| Saída ao escolher Sair | 0,25 s até o preto |
| Abrir Como Jogar ou Configurações | a pintura escurece para 45% em 0,2 s atrás do painel; volta em 0,2 s |

### 4.6 Orçamento

- Menos de 0,3 ms por quadro para toda a atmosfera, na placa do Daniel e no renderizador Compatibility.
- Névoa: um shader, no máximo 3 leituras da textura de ruído por pixel, sem ruído calculado no shader.
- Partículas: `GPUParticles2D` ou `CPUParticles2D`, no máximo 4 emissores, 80 partículas (100 com as opcionais).
- Nenhuma leitura da tela (sem desfoque ao vivo, sem `SCREEN_TEXTURE`); o fundo desfocado das faixas é textura pronta.
- Para captura: com `--shot` os efeitos usam semente fixa, para duas capturas iguais serem comparáveis.

## 5. Tipografia e estados

- **Fonte dos rótulos: Alegreya Sans Bold** (`assets/fonts/AlegreyaSans-Bold.ttf`, `UiKit.BOLD_FONT`). Conferido
  renderizando as duas fontes do projeto e medindo: "Iniciar" pintado tem 126 px de largura, Alegreya Sans Bold a
  51 px dá 126; "Como Jogar" pintado 122, Bold a 26 a 27 px dá 118 a 122; "Sair" pintado 40, Bold a 26 px dá 40. A
  Cinzel não serve (só maiúsculas, 30% mais larga): fica para o logotipo, que é da pintura.
- Tamanhos em 720p: **Iniciar 39 px; os outros 20 px**. Alinhados à esquerda nas posições da seção 1, nunca
  centrados (o ícone ocupa a esquerda). Sem contorno; sombra só no Iniciar.
- Textos em `data/text_pt.tres`, sem travessão: "Iniciar", "Como Jogar", "Configurações", "Sair".
- Nenhum outro texto na tela (as linhas de controles da tela antiga vão para dentro de Como Jogar).

Estados:

| Estado | Iniciar | Botões pequenos |
|---|---|---|
| Normal | como na pintura (seção 1.2), com o pulso | como na pintura (seção 1.3) |
| Mouse em cima ou foco | brilho mais forte (seção 4.4), gemas dos losangos acesas `#e8fff4` | linha da moldura `#ffca46`, fundo `#1e150c`, texto `#f0e8ce`, ícone `#ffca46`, brilho âmbar de 6 px com alfa 0,35 |
| Apertado | desce 1 unidade, miolo 15% mais escuro, brilho a 60%, por 0,08 s | desce 1 unidade, fundo `#2a1a0a` |
| Desativado | moldura `#6b5a3a`, sem brilho nem pulso, texto `#8a8478` | linha `#3a3530`, texto e ícone `#6f6a70`, alfa 0,6 |

- Foco inicial no Iniciar. O mouse em cima passa o foco (regra do `UiKit`): mouse, teclado e controle concordam.
- **Anel de foco** (teclado e controle): hexágono paralelo à moldura, 3 unidades lógicas para fora, linha de 2
  unidades, cor `#fff2b8`, alfa 0,9. Só aparece depois do primeiro comando de navegação por teclado ou controle (não
  aparece no foco inicial nem com o mouse), para a tela parada ficar igual à pintura.
- Navegação: cima e baixo percorrem os quatro, sem dar a volta; confirmar aciona; no navegador o Sair fica oculto
  e a navegação termina em Configurações.
- Cobertura: o desenho de cada botão real cobre a moldura pintada inteira (hexágonos da seção 1), com fundo opaco no
  Iniciar e alfa de pelo menos 0,92 nos pequenos, para esconder qualquer resto do apagamento.

## 6. Critérios de aprovação

Capturas reais da tela de título na placa de vídeo (`tools/gpu.sh shot <saída> --title --shot-at=3`, com `RES` para
cada tamanho), comparadas com a referência reduzida para o mesmo tamanho.

1. **Alinhamento**: em 1280 x 720, cada moldura de botão a no máximo 2 px da posição pintada (3 px da imagem);
   borda esquerda e linha de base de cada texto a no máximo 2 px; centro de cada ícone a no máximo 2 px; largura de
   cada texto a no máximo 4% da pintada.
2. **Nada duplicado**: nenhum resto de botão pintado visível (borda dupla, texto fantasma, brilho âmbar sobrando,
   mancha do apagamento fora do botão), olhando a 100% e a 200%. Um só logotipo, o da pintura, e nenhum título
   escrito com fonte.
3. **Pintura intacta**: fora dos polígonos de apagar, a cópia limpa é idêntica à referência (diferença zero pixel a
   pixel). A chama da tocha continua aparecendo acima da ponta direita do Iniciar.
4. **Aparência dos botões**: lado a lado com a pintura, o Iniciar tem moldura de ouro com losangos e gema, miolo
   marrom escuro com clarão âmbar embaixo e brilho externo; os pequenos têm fundo escuro, linha de bronze apagado e
   os ícones certos (livro, engrenagem, energia). Cores a no máximo 10% das amostradas.
5. **Regiões protegidas** (seção 3.1) inteiras em 1280 x 720, 1600 x 900, 1920 x 1080, 1920 x 1200, 2560 x 1080 e
   1024 x 768; menu sobre a pintura na mesma posição relativa em todas; faixas preenchidas, sem barra preta nem
   emenda dura.
6. **Corpos parados**: duas capturas com 1 s de intervalo não diferem dentro do rosto do Explorador, da lâmina e do
   logotipo (além de ruído de compressão); névoa, brasas e partículas só onde a seção 4 manda.
7. **Leitura**: os quatro rótulos legíveis em 1280 x 720; contraste do texto pequeno sobre o fundo do botão igual ou
   maior que o da pintura; nenhuma partícula ou névoa por cima de texto.
8. **Estados**: capturas de foco em cada um dos quatro botões pelo teclado mostram o anel; apertado e desativado
   distinguíveis do normal.
9. **Entrada e saída**: tempos da seção 4.5, sem quadro com botões antes da pintura.
10. **Desempenho**: custo da atmosfera abaixo de 0,3 ms (medido com e sem ela); `fps` da linha `RESULT` sem queda.
11. **Texto**: tudo em `data/text_pt.tres`, em português do Brasil, sem travessão.

Não declarar fidelidade sem a captura lado a lado. A aprovação final é do Daniel.

## Pendências (para o Game Director levar ao Daniel)

- **Resolução da arte**: 1672 x 941 fica macia acima de 1080p. Pedir ao Daniel a mesma imagem em tamanho maior
  (2560 x 1440 ou mais); se não houver, decidir com ele se vale ampliar (outra etapa de IA, a declarar).
- **Quem são os quatro heróis**: a pintura mostra o Explorador, uma ladina de capuz roxo, uma maga e um clérigo;
  nomes e papel deles não foram inventados aqui (o `CLAUDE.md` registra a dúvida entre quatro paladinos e um paladino
  com quatro guardiões).
- **Apagamento**: o `removelogo` do ffmpeg borra áreas grandes (o Iniciar tem 450 x 90). Como os botões reais cobrem
  a área, o borrão só importa na franja do brilho; se aparecer fora do botão, estreitar o polígono ou retocar à mão.
