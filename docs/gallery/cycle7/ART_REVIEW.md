# Ciclo 7: revisão de arte

Revisão do Art Director sobre capturas reais do jogo (Godot 4.7.2, placa de vídeo RTX 5060 Laptop, Vulkan Forward+).
Nenhuma imagem desta pasta foi gerada por IA nem retocada; a única arte feita por IA que aparece nas capturas é a
ilustração de fundo da tela de título (declarada em `docs/steam-ia.md`). Comandos de cada captura:
[CAPTURAS.md](CAPTURAS.md). Especificação do ciclo: [cycle7_spec.md](../../art/cycle7_spec.md). Relatório de QA:
[latest_report.md](../../qa/latest_report.md).

As medidas abaixo foram refeitas por mim nos JPG desta pasta (luminância L = 0,2126 R + 0,7152 G + 0,0722 B, caixas em
pixels de 1672 x 941; `tools/art_metrics.py` para a arena). JPG perde um pouco de cor nas bordas finas; números perto do
limite do critério estão marcados como "no limite". A aprovação artística final é do Daniel, depois da revisão externa.

## A. Resumo

| Item | Valor |
|---|---|
| Branch | `arpg-3d` |
| Commit inicial | `5429394` (opções de captura, especificação e capturas de antes); a tela de título veio antes, em `f226778` |
| Commit final | ver o log da branch `arpg-3d`; evidências em `51a18e3` (capturas tiradas no `7fb5b4b`) |
| Commits do ciclo | `f226778` título, `5429394` opções e especificação, `760f335` inimigos, `10c54ff` HUD, `31098c5` herói, `ff949f8` Emeth, `7fb5b4b` arena, `51a18e3` evidências |

**Objetivos** (pedido do Daniel, por prioridade): P0 tela de título; P1 impacto da Emeth; P1 leitura do Explorador em
lutas de 40 e 90 inimigos; P1 leitura do papel de cada inimigo sem trocar modelo; P2 retoques de arena; P2 polimento
do HUD. Regra do ciclo: só apresentação, nenhum número de jogo muda (as partidas do robô deram a mesma linha
`RESULT` antes e depois).

**O que foi implementado**
- Tela de título nova com a ilustração aprovada pelo Daniel como fundo e o menu real da Godot por cima.
- Emeth: uma fita só por golpe, afinando na cauda; talho e lascas só em acerto real; números pálidos (esmeralda só
  em finalizador e Ômega); meia-lua fina só no finalizador; Seta de Luz como dardo esmeralda reto; círculo de luz
  como aro fino com marcas girando, sem disco creme.
- Explorador: coberto, aparece nas próprias cores com borda quente fina (fim do fantasma ciano); sem silhueta branca
  ao levar golpe; a Emeth desenhada através da multidão; cunha de direção no anel; luz de recorte fraca.
- Inimigos: assinatura por silhueta e pose (lâmina longa do Esqueleto, Corredor curvado em osso quente, orbe violeta
  no cajado do Feiticeiro, besta maior em metal claro, escudo fixo à frente, postura de oferenda e aro de ritual do
  Sacerdote); preparos de ataque num MultiMesh só (`EnemyFx`); ouro do elite só no metal; Morvath violeta com coroa
  clara; barras mais finas na multidão.
- Arena: estátuas encapuzadas com pregas, mangas e rosto recuado; brilhos violeta do abismo rasgados; três grupos de
  ruínas na névoa; portal sem estouro (miolo pequeno, véus lentos) com a luz mais baixa nos umbrais e degraus;
  medalhão com aro chanfrado, runas mais fundas e roseta entalhada.
- HUD: rosto pintado do Explorador no medalhão, barras com fundo ardósia e rastro de perda, estados de pronto e
  recarga, ações translúcidas sobre quem está atrás delas, sombra em todo texto, divisas de ouro velho para elites,
  guardiões e chefe fora da tela, um só ouro e uma só espessura de moldura.

**O que está pendente** (detalhes nas seções C e D)
- Herói mais difícil de achar no bolo de 90 do que antes (B5 do QA).
- Inimigos atingidos ainda viram mancha branca chapada; no Ômega ela cobre o herói (B4).
- Luz verde do portal continua nos degraus quando o portal fica vermelho (sala de Morvath, B2).
- Herói atrás do obelisco lê como se estivesse em cima dele (B3).
- Grupos de números de dano acima do limite de 8 em lutas grandes; barras vermelhas um pouco acima da meta no bolo.
- Regressão de CPU com hordas grandes (M1), em correção, a medir de novo.
- Capturas auxiliares do contrato não feitas: `08b_emeth_circulo`, `15b_porta_amarela`, `22b_hud_2560`.
- Peças provisórias continuam provisórias: estátuas, moldura do portal e ruínas (formas simples à espera dos modelos
  do `docs/art/meshy_asset_plan.md`); nada deste ciclo eleva a fidelidade à pintura de referência.

## B. Referências

**Antes** (estado anterior ao ciclo)
- Ciclo 6, mesmo enquadramento: [final_vitrine](../jogo/final_vitrine.jpg), [final_luta](../jogo/final_luta.jpg),
  [final_boss](../jogo/final_boss.jpg), [11_titulo](../jogo/11_titulo.jpg), [8_horda90](../jogo/8_horda90.jpg),
  [9_cercado40](../jogo/9_cercado40.jpg), [3_sacerdote](../jogo/3_sacerdote.jpg), [4_elite](../jogo/4_elite.jpg),
  [5_medalhao](../jogo/5_medalhao.jpg), [10_combate_1920](../jogo/10_combate_1920.jpg).
- Inimigos no laboratório: [_todos_game](../enemies/_todos_game.jpg), [_todos_front](../enemies/_todos_front.jpg) e
  as faixas por inimigo em [../enemies/](../enemies/).
- Capturas de antes feitas para este ciclo (commit `c561101`/`5429394`):
  [emeth_ataque](../../art/shots/cycle7_before/emeth_ataque.jpg),
  [emeth_impacto](../../art/shots/cycle7_before/emeth_impacto.jpg),
  [emeth_especial](../../art/shots/cycle7_before/emeth_especial.jpg),
  [emeth_circulo](../../art/shots/cycle7_before/emeth_circulo.jpg),
  [emeth_omega](../../art/shots/cycle7_before/emeth_omega.jpg),
  [explorador_idle](../../art/shots/cycle7_before/explorador_idle.jpg),
  [explorador_corrida](../../art/shots/cycle7_before/explorador_corrida.jpg),
  [guardiao_cavaleiro](../../art/shots/cycle7_before/guardiao_cavaleiro.jpg),
  [sala_fonte](../../art/shots/cycle7_before/sala_fonte.jpg).

**Depois** (esta pasta, commit `7fb5b4b`)
- Contrato: [01](01_titulo_1280.jpg), [02](02_titulo_1920.jpg), [03](03_titulo_hover.jpg),
  [04](04_explorador_idle.jpg), [05](05_explorador_corrida.jpg), [06](06_emeth_ataque.jpg),
  [06b](06b_emeth_omega.jpg), [07](07_emeth_impacto.jpg), [08](08_emeth_especial.jpg),
  [09](09_inimigos_comparativo.jpg), [10](10_inimigos_em_combate.jpg), [11](11_inimigo_elite.jpg),
  [12](12_guardiao.jpg), [12b](12b_guardiao_anciao.jpg), [13](13_morvath.jpg), [14](14_arena_geral.jpg),
  [15](15_portal.jpg), [16](16_estatuas.jpg), [17](17_abismo.jpg), [18](18_medalhao.jpg),
  [19](19_combate_40_inimigos.jpg), [20](20_combate_90_inimigos.jpg), [21](21_hud_1280.jpg), [22](22_hud_1920.jpg).
- Montagens de antes e depois (mesmo comando, mesmo instante, `RESULT` iguais):
  [título](before_after_titulo.jpg), [arena](before_after_arena.jpg), [combate](before_after_combate.jpg),
  [inimigos](before_after_inimigos.jpg).

## C. Comparação por área

### 1. Tela inicial

**Antes**: painel escuro à esquerda com título em texto, premissa e quatro botões; à direita o herói do jogo parado
numa sala escura do KayKit; linha de controles no rodapé.
**Mudou**: a ilustração aprovada pelo Daniel ocupa a tela inteira (contida, sem corte; faixas desfocadas em outras
proporções), logotipo da própria ilustração, botões pintados apagados numa cópia limpa e o menu real por cima
(Iniciar, Como Jogar, Configurações, Sair), névoa, brasas e partículas do portal que não passam por rostos, lâmina
ou logotipo.

![Título antes e depois](before_after_titulo.jpg)

Depois em 1920 x 1080 e com o mouse sobre Como Jogar:

![Título 1920](02_titulo_1920.jpg)
![Título hover](03_titulo_hover.jpg)

**Melhorias percebidas**: primeira impressão no nível de um jogo comercial; hierarquia clara (Iniciar maior, em
moldura de ouro; os outros três menores); estado de foco visível (Como Jogar aceso em `03`); legível em 1280 x 720 e
1920 x 1080; o Explorador da ilustração é o mesmo do jogo (cabelo cobre, cachecol petróleo, Emeth verde).
**Diferenças que ficam**: o estilo da ilustração (pintura detalhada) é bem mais rico que o jogo 3D; quem vem do
título para a sala 1 sente a queda. A ilustração mostra quatro heróis, um deles lançando magia violeta; no jogo o
violeta é a cor da magia inimiga e os quatro paladinos ainda não estão definidos no cânone (`PALADIN_1` a
`PALADIN_4`). Como é a imagem aprovada pelo Daniel, ela prevalece; fica só registrado.
**Limitações técnicas**: arte de fundo feita por IA (declarada em `docs/steam-ia.md`); a cópia sem botões foi
apagada à mão sobre a pintura. Não há captura de outras proporções (ultralarga) nem do navegador.

### 2. Explorador

**Antes**: em campo aberto já lia bem; coberto, virava fantasma ciano chapado (metade ciano, metade normal quando
coberto pela metade); ao levar golpe, silhueta branca inteira; anel sem direção.
**Mudou**: coberto, é desenhado nas próprias cores com borda quente fina; sem branco ao levar golpe; a Emeth passa
pela multidão; cunha mais clara no anel do lado para onde olha; luz de recorte fraca.

| Antes | Depois |
|---|---|
| ![Corrida antes](../../art/shots/cycle7_before/explorador_corrida.jpg) | ![Corrida depois](05_explorador_corrida.jpg) |
| ![Parado antes](../../art/shots/cycle7_before/explorador_idle.jpg) | ![Parado depois](04_explorador_idle.jpg) |

Golpe recebido no meio dos inimigos (à esquerda o antes com a silhueta branca, à direita o depois):

![Inimigos antes e depois](before_after_inimigos.jpg)

**Melhorias percebidas**: acabou o personagem partido em dois (`05`: pernas ciano antes, corpo inteiro nas cores dele
agora); ao levar golpe ele continua sendo ele (montagem acima, centro); no bolo de 90 o recorte 4x mostra cabelo
cobre, cachecol petróleo e borda quente (medido na caixa (575,330)-(640,470) de `20`: cabelo cobre 21%, petróleo 5,0%
no limite da meta de 5%, ciano 1,3% contra máximo de 3%). Em `19` (caixa (255,520)-(330,620)): cobre 22%, petróleo
9,2%.
**Diferenças que ficam**:
- B3: atrás do obelisco ele é desenhado inteiro através da pedra e o anel fica por cima do topo do obelisco; lê como
  se estivesse em pé em cima dele (`05`, `11`). Antes acontecia o mesmo, só que em ciano.
- B5: no bolo de 90, em tamanho real, ele leva mais tempo para ser achado do que o fantasma ciano antigo (montagem de
  combate, linha de baixo). A causa não é só o herói: a multidão ficou mais colorida neste ciclo (osso quente do
  Corredor, orbes violeta, números pálidos) e ele deixou de ser o único corpo saturado da tela.
**Limitações técnicas**: herói do Meshy, a escala e a colisão não mudaram; o raio-x é de tela, então não sabe a
diferença entre "atrás de pedra" e "atrás de inimigo".

### 3. Emeth

**Antes**: leque de 4 ou 5 faixas iguais, sem direção; no golpe forte, clarão branco que apagava herói e inimigos;
meia-lua do Ômega com 73% da largura da tela e faixas listradas; Seta de Luz como fileira de bolas de fogo amarelas;
círculo de luz como disco creme opaco; marca de acerto em anel com cruz; números verdes uns sobre os outros.
**Mudou**: ver resumo (fita única, talho, dardo, aro fino, meia-lua fina, números pálidos).

| Antes | Depois |
|---|---|
| ![Ataque antes](../../art/shots/cycle7_before/emeth_ataque.jpg) | ![Ataque depois](06_emeth_ataque.jpg) |
| ![Ômega antes](../../art/shots/cycle7_before/emeth_omega.jpg) | ![Ômega depois](06b_emeth_omega.jpg) |
| ![Especial antes](../../art/shots/cycle7_before/emeth_especial.jpg) | ![Especial depois](08_emeth_especial.jpg) |
| ![Impacto antes](../../art/shots/cycle7_before/emeth_impacto.jpg) | ![Impacto depois](07_emeth_impacto.jpg) |

O círculo de luz aparece aceso em `06` e `08` (aro fino com marcas); a captura dedicada `08b` não foi feita. Antes:
[emeth_circulo](../../art/shots/cycle7_before/emeth_circulo.jpg).

**Melhorias percebidas**: o golpe leve tem uma fita só e um lado claro (`06`, (840,350)-(910,450)); a estocada é um
feixe estreito sem listras (`07`); a Seta de Luz é um dardo verde reto saindo da lâmina, sem halo quente (`08`); o
círculo deixou de apagar o chão (as juntas das lajes aparecem dentro dele em `06` e `08`); a meia-lua do Ômega caiu
para cerca de 420 px de largura (25% da tela, meta 45%) e ficou fina; sem aberração cromática visível no centro. Pixels
brancos (três canais acima de 235) numa caixa de 300 x 220 em volta do herói: 1,5% no golpe leve de `06` (meta 3%).
**Diferenças que ficam**:
- B4: no Ômega (`06b`) os dois inimigos atingidos viram uma mancha branca única que cobre a metade de baixo do herói:
  14,3% de brancos na caixa de 300 x 220 (meta 10% no golpe grande) e 40% na caixa justa do herói. O pedido era branco
  por no máximo 2 quadros e herói fora do branco; sem rajada não dá para provar a duração, e o quadro mostra a mancha.
- Em `19` um só grupo tem cerca de 16 números sobrepostos (meta: no máximo 8 por grupo).
- Nenhum quadro mostra um aviso vermelho cruzando a borda do círculo de luz: o critério F3 (aviso com a mesma cor
  dentro e fora do círculo) ficou sem evidência.
**Limitações técnicas**: medidas em quadro parado; a sensação do golpe em movimento (tempo de vida, pulso da lâmina)
só aparece jogando.

### 4. Inimigos

**Antes**: Esqueleto e Corredor com a mesma paleta; gemas do Feiticeiro como quadrados brancos; besta do Arqueiro
como toco marrom; escudo carvão que ia para o lado; Sacerdote sem sinal de ritual; ouro do elite cobrindo a caveira;
Morvath cinza e marrom no jogo; grade de barras vermelhas sobre o bolo.
**Mudou**: ver resumo.

| Antes | Depois |
|---|---|
| ![Todos antes](../enemies/_todos_game.jpg) | ![Todos depois](09_inimigos_comparativo.jpg) |
| ![Elite antes](../jogo/4_elite.jpg) | ![Elite depois](11_inimigo_elite.jpg) |
| ![Guardião antes](../../art/shots/cycle7_before/guardiao_cavaleiro.jpg) | ![Guardião depois](12_guardiao.jpg) |
| ![Morvath antes](../jogo/final_boss.jpg) | ![Morvath depois](13_morvath.jpg) |
| ![Sacerdote antes](../jogo/3_sacerdote.jpg) | ![Ancião depois](12b_guardiao_anciao.jpg) |

Em combate, mesmo instante antes e depois:

![Inimigos em combate](10_inimigos_em_combate.jpg)

**Melhorias percebidas**: Morvath finalmente lê violeta no jogo (36% dos pixels da caixa do corpo em `13` são
violeta; meta 25%) e a coroa clara recorta contra o chão; o orbe do Feiticeiro é um ponto violeta em vez de quadrado
branco; o Corredor ficou curvado e de osso mais quente, separado do Esqueleto pela postura; o escudo do Escudo fica na
frente; a caveira do elite continua marfim.
**Diferenças que ficam**:
- O ouro do elite ficou tão discreto que, em `11`, o que separa elite de comum é quase só a barra amarela e o
  contorno; a uma distância de jogo o metal dourado mal aparece.
- Barras vermelhas no bolo de `20`: 2,3% da caixa (300,420)-(700,640) (meta 2%; antes cerca de 3,4%). Melhorou, ainda
  forma faixas sobre as cabeças.
- O aro de ritual do Sacerdote não aparece em nenhuma captura do contrato; não posso confirmar.
- O laboratório `09` deixa as figuras pequenas (cerca de 100 px de altura) num quadro de 1672 x 1882 quase vazio: o
  teste de silhueta J1 não dá para fazer com segurança nele. Teste sem cor (J2) em `10`: identifiquei pela forma
  Esqueletos, Corredores e o Feiticeiro (orbe); Arqueiro e Sacerdote no fundo do bolo se confundem entre si (dois
  capuzes escuros).
- Inimigo atingido continua branco chapado de corpo inteiro (`06`, `07`, `08`), ver B4 na seção 3.
**Limitações técnicas**: modelos do Meshy mantidos (regra do ciclo); poses vêm de clipes da Quaternius e do KayKit;
nenhum objeto com símbolo novo (lore pendente com o Daniel).

### 5. Arena

**Antes**: estátuas lisas com capuz que lia como furo; abismo com painéis violeta de borda reta; portal com 75% da
folha estourada; aro do medalhão quase sem relevo.
**Mudou**: ver resumo.

![Arena antes e depois](before_after_arena.jpg)

| Antes | Depois |
|---|---|
| ![Vitrine antes](../jogo/final_vitrine.jpg) | ![Vitrine depois](14_arena_geral.jpg) |
| ![Medalhão antes](../jogo/5_medalhao.jpg) | ![Medalhão depois](18_medalhao.jpg) |
| ![Fonte antes](../../art/shots/cycle7_before/sala_fonte.jpg) | ![Portal de perto](15_portal.jpg) |

Detalhes novos: ![Estátuas](16_estatuas.jpg) ![Abismo](17_abismo.jpg)

**Melhorias percebidas** (medido em `14` contra `final_vitrine`, mesma câmera):
- Portal: canal em 250 ou mais em 18% da caixa `portal_open` (antes 75%, meta até 25%); mediana de L 159 (meta 150 a
  190); desvio 53 (meta 40 ou mais). A folha tem miolo e borda em vez de um verde chapado.
- Fachada: verde 0,146 (antes 0,218, meta 0,20); detalhe da fachada 11,4 (antes 9,2).
- Estátuas: desvio de L 18,5 na direita do portal (antes 11,5) e 27,1 na esquerda (antes 23,1); pregas e mangas
  visíveis em `15` e `16`; a nordeste não fica mais amarela.
- Abismo: detalhe das colunas da esquerda 5,1 (antes 4,1, meta 5,0); ruínas na névoa visíveis em `16` e `17`.
- Medalhão: aro chanfrado, runas contáveis e roseta entalhada (`18`), sem emissão; o aviso vermelho continua mais claro
  que ele (`10`).
- Verde no chão em frente ao portal: 17,4% (antes 18,1%, meta 12% a 20%): a assinatura da pintura ficou.
**Diferenças que ficam**:
- B2: na sala de Morvath o portal fica vermelho, mas os degraus e o chão em frente continuam verdes (`13`).
- A estátua gigante caiu para desvio 17,3 (antes 19,7, meta 18): no limite, sem ganho de volume na vitrine.
- O vão do capuz das estátuas ainda é um oval escuro que, de perto (`15`, `16`), lê como furo; o rosto recuado não
  aparece.
- De perto (`15`) a folha do portal ainda é uma área grande de verde saturado com pouca estrutura.
**Limitações técnicas**: estátuas, moldura do portal e ruínas são formas simples feitas em código, provisórias até
os modelos do `meshy_asset_plan.md` (nada gerado, depende de autorização e créditos do Daniel).

### 6. HUD

**Antes**: retrato vetorial simples (rosto rosa, espada de palito); parte vazia da Magia preta; ícones de ação iguais
em peso; nome do golpe verde sobre o verde do portal; relógio sumindo sobre a corrente.
**Mudou**: ver resumo.

| Antes | Depois |
|---|---|
| ![HUD antes](../jogo/final_luta.jpg) | ![HUD 1280](21_hud_1280.jpg) |
| ![HUD 1920 antes](../jogo/10_combate_1920.jpg) | ![HUD 1920](22_hud_1920.jpg) |

**Melhorias percebidas**: o medalhão mostra o rosto do Explorador da ilustração do título, no mesmo estilo da tela
inicial; barras com fundo ardósia e números alinhados; em `21` as ações ficam translúcidas com um Feiticeiro atrás
delas (o inimigo aparece através); nome do golpe em marfim com sombra (contraste bom sobre o verde do portal em `07`,
`12`); relógio legível sobre a corrente (`19`, `20`); divisa de ouro ao lado da etiqueta "Fonte de luz" (`04`, `05`).
**Diferenças que ficam**:
- O retrato é um recorte da ilustração feita por IA (`assets/ui/hud/hero_portrait.png`), não o busto do modelo do
  jogo pedido na especificação (U1). Fica coerente com o título; precisa constar em `docs/steam-ia.md` como derivado
  da arte do título.
- Ultralargo 2560 x 1080 (U10) e divisa para guardião ou elite fora da tela (U8) sem captura.
- Com as ações translúcidas e em recarga ao mesmo tempo (`21`), as quatro ficam fracas demais; pronto e recarga se
  separam, mas o conjunto quase some.
**Limitações técnicas**: fontes Cinzel e Alegreya Sans (OFL), sem mudança.

### 7. Combate com hordas

**Antes**: herói ciano no meio do bolo, fácil de achar mas sem cor nem direção; números verdes empilhados; grade de
barras vermelhas.
**Mudou**: herói nas próprias cores, números pálidos, barras mais finas, preparos de ataque dos inimigos.

![Combate antes e depois](before_after_combate.jpg)

| Antes | Depois |
|---|---|
| ![40 antes](../jogo/9_cercado40.jpg) | ![40 depois](19_combate_40_inimigos.jpg) |
| ![90 antes](../jogo/8_horda90.jpg) | ![90 depois](20_combate_90_inimigos.jpg) |

**Melhorias percebidas**: os números não brigam mais com o verde da Emeth; a leitura de cada tipo de inimigo no
bolo melhorou (Corredor pela postura, Feiticeiro pelo orbe); as barras ocupam menos; em luta pequena (`21`, linha de
cima da montagem) o quadro está mais limpo que antes.
**Diferenças que ficam**:
- B5 (o maior problema do ciclo): no bolo de 90 o herói é mais difícil de achar de relance do que antes. Os números
  da caixa justa passam, mas a tela inteira tem mais ruído: orbes violeta flutuando sobre o bolo, osso quente, capas
  vermelhas, 15 a 16 números pálidos num grupo.
- B6: em `19` o herói está a cerca de 17% da largura da tela (x perto de 290 de 1672), no limite dos 18% do
  `CamFrame.SAFE`, metade escondido atrás da balaustrada.
- Os orbes violeta dos Feiticeiros somados viram uma nuvem de pontos no bolo de 90; a especificação previa limite de
  brilho (1,8) e conferência em `20`: não estouram, mas poluem.
**Limitações técnicas**: lido em quadro parado; a leitura em movimento precisa de gente jogando.

## D. Aceite por área

| Área | Veredito | Motivo |
|---|---|---|
| 1 Tela inicial | APROVADO COM RESSALVAS | Fluxo 12/12, legível em 1280 e 1920, arte aprovada pelo Daniel. Ressalvas: queda de estilo do título para o jogo; quatro heróis e magia violeta num herói, a confirmar com o cânone; sem captura ultralarga |
| 2 Explorador | APROVADO COM RESSALVAS | Fantasma ciano e silhueta branca resolvidos, cores dele medidas no bolo. Ressalvas: B3 (obelisco) e B5 (achável mais devagar no bolo de 90) |
| 3 Emeth | APROVADO COM RESSALVAS | Fita, dardo, estocada, aro do círculo e meia-lua dentro dos números. Ressalvas: B4 (mancha branca dos atingidos cobre o herói no Ômega, 14% de brancos contra 10%); grupos de até 16 números em `19`; `08b` sem captura |
| 4 Inimigos | APROVADO COM RESSALVAS | Morvath violeta (36%), orbe do Feiticeiro, Corredor por postura, caveira do elite marfim. Ressalvas: ouro do elite quase invisível; barras 2,3% contra 2%; aro do Sacerdote sem evidência; Arqueiro e Sacerdote se confundem no fundo |
| 5 Arena | APROVADO COM RESSALVAS | Portal sem estouro (18%, mediana 159), fachada menos verde, estátuas com pregas, ruínas, medalhão com relevo. Ressalvas: B2 (verde com portal vermelho); capuz ainda lê como furo de perto; peças provisórias |
| 6 HUD | APROVADO COM RESSALVAS | Retrato no estilo do título, barras, contraste dos textos, translucidez sobre inimigos. Ressalvas: retrato derivado da arte de IA a declarar; U8 e U10 sem captura; ações translúcidas em recarga quase somem |
| 7 Combate com hordas | PENDENTE | B5: herói mais difícil de achar no bolo de 90 que antes; ruído de orbes e números; B6 no limite da borda; regressão de CPU (M1) em correção |

Nenhuma área recebe APROVADO TECNICAMENTE sem ressalva: todas têm pelo menos um critério sem captura ou fora da meta.
A aprovação artística final é do Daniel, depois da revisão externa.

## E. Desempenho

Do relatório de QA (números reais, não estimados): NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan Forward+, Godot 4.7.2
Windows, janela 1672 x 941, `--fixed-fps 30 --disable-vsync`, `--seed=5`; mediana de três rodadas de 300 quadros,
antes `5429394` e depois `7fb5b4b`.

| Cena | Quadro antes | Quadro depois | Diferença | FPS antes / depois | GPU antes / depois (ms) | CPU de desenho antes / depois (ms) | Chamadas antes / depois | Primitivas depois |
|---|---|---|---|---|---|---|---|---|
| Luta (`--bot --autopick`) | 2,67 ms | 2,76 ms | +0,09 | 375 / 362 | 2,56 / 2,66 | 0,86 / 0,87 | 1002 / 971 | 938 mil |
| 40 inimigos | 2,71 ms | 2,74 ms | +0,03 | 369 / 365 | 2,62 / 2,68 | 0,85 / 0,88 | 1021 / 995 | 788 mil |
| 90 inimigos | 3,65 ms | 4,13 ms | +0,48 | 274 / 242 | 2,58 / 2,60 | 1,00 / 1,07 | 1100 / 1080 | 1,35 milhão |
| 300 inimigos | 7,70 ms | 8,89 ms | +1,19 | 130 / 112 | 3,04 / 3,12 | 1,16 / 1,32 | 1002 / 978 | 2,29 milhões |
| Salão sem luta (`--start=fountain`) | 2,41 ms | 2,46 ms | +0,06 | | 2,27 / 2,32 | | | |

- Vitrine `--showcase`: NÃO MEDIDO (a sonda lê o viewport errado nesse modo; o número não é confiável).
- Celular, navegador real (Compatibility), placa de vídeo fraca, versões exportadas: NÃO MEDIDO.
- Contra o orçamento da especificação (seção 1, regra 5): luta +0,09 (limite +0,2) passa; 90 inimigos +0,48 (limite
  +0,4) e 300 inimigos +1,19 (limite +0,5) passam do limite. A GPU quase não mudou; o custo é de CPU por quadro
  (M1, regressão média do ciclo). **Uma correção de M1 está sendo feita agora** e os números de 90 e 300 inimigos
  serão medidos de novo depois dela.

## F. Testes

Do relatório de QA, no commit `7fb5b4b`:
- Importação e `tools/check.gd`: 0 `SCRIPT ERROR`, 0 `Parse Error`.
- `tools/test.sh`: 21 arquivos, 219 testes, 218 passando, 0 falhando, 1 arriscado (`test_only_finishers_glint`, sem
  asserção, já conhecido).
- `tools/title_flow_check.gd`: FLOW ok, 12 de 12.
- Partidas do robô: as sementes 1, 2, 3, 5 e 7 e as de chefe, guardião, fonte, loja e estresse dão linhas `RESULT`
  idênticas às do ciclo 6 (nenhuma regra de jogo mudou); `--seed=5` em 300 s: 183,5 s, 20 abates, Morvath com 2623.
- Problemas conhecidos: `ERROR: 1 resources still in use at exit` e `2 ObjectDB instances were leaked` ao sair (igual
  ao ciclo 6, B7); `tests/test_fx_on_hit.gd.uid` gerado pela importação e fora do commit (B1); o robô não encontra
  elites numa partida normal (vistos por `--stress-ids`). Sem som verificado; sem gente jogando.

## Os três problemas mais importantes que ficam

1. **Herói difícil de achar no bolo de 90 (B5).** Responsável: Gameplay Engineer, frente B, com a frente C. Pedido:
   subir a luz de recorte do herói (até 0,35) e a cunha do anel (1,8 vez o aro), e baixar o ruído da multidão em volta
   dele (orbe parado do Feiticeiro na metade do brilho quando houver mais de 24 de pé; o preparo continua acendendo). Nunca voltar ao ciano chapado.
   Aceite: em `20`, achar o herói em 1 s por quem não sabe onde ele está (teste com o Daniel) e G1 a G3 continuam.
2. **Mancha branca dos inimigos atingidos (B4).** Responsável: Gameplay Engineer, frente C. Pedido: o pisca vira o
   próprio inimigo 60% mais claro (como o herói), branco chapado só no 1º quadro e nunca por cima do herói. Aceite:
   em `06b`, no máximo 10% de brancos na caixa de 300 x 220 em volta do herói e cabelo cobre visível (30 pixels ou mais).
3. **Verde do portal com o portal vermelho (B2).** Responsável: Environment Artist. Pedido: `Arena.open_door` e
   `ArenaKit.light_portal` levam a cor da folha também para o derrame dos degraus (`SPILL_COLOR` de
   `catacomb_hall.gd`). Aceite: em `13`, degraus e chão em frente ao portal sem pixels com G > R + 40.
