# Revisão de arte, 2026-11-26 (antes da entrega)

Revisor: art-director. Capturas reais na GPU (1672x941, estilizado, câmera Perto) desta rodada:
- `docs/gallery/e1-e3_2026-11-25/`: `comet_falling.png`, `comet_impact.png`, `antessala_tip_attack.png`, `antessala_stream.png`, `vine_figure.png`
- `docs/gallery/pt26_2026-11-25/`: `forge_intro.png`, `angel_single_cards.png`, `cards_mouse_icons.png`, `hud_8_boons.png`, `hud_named_slots.png`
- `docs/gallery/e4-e5_2026-11-25/`: `hall_canal.png`, `hub_blockout_arrival.png` (blockout: só direção)

Referências: `docs/art/ref/sala01_2026-11-25/01-arte-aprovada.jpg` + `04-paleta-e-iluminacao.md` (Salão),
`docs/art/ref/hub01_2026-11-25/eterra_hub/01-arte-aprovada.jpg` + `04-paleta-e-iluminacao.md` (Santuário).
Já registrados no pente fino de 2026-11-25 (`ART_REVIEW_2026-11-25_sweep.md`) e ainda visíveis aqui: obelisco em degraus na
frente da chegada (item "já conhecido"), cristais da chegada em verde chapado, mureta da frente tapando o herói (P1-7).
Não repito; só confirmo quando a captura mostra.

## P0 (nenhum bloqueia a entrega)

Nenhum defeito desta rodada impede o teste do Daniel. Os P1 abaixo são o que ele vai notar primeiro.

## P1

1. **Braseiro do cenário por trás da barra de habilidades** (`hud_8_boons.png`, `hall_canal.png`). Com a câmera Perto, um
   braseiro da borda sul cai exatamente atrás dos losangos de Ataque/Especial: a chama laranja cobre os ícones e o contador
   de recarga. Em `hall_canal.png` o braseiro de canto (14,2; 12,9) fica atrás do "Esquiva"/moeda. Qualquer fogo ou luz forte
   na faixa de baixo da tela vai repetir isso.
   Correção: uma placa de tinta escura atrás da barra de habilidades (gradiente de baixo para cima, 0 a 55% de preto,
   cerca de 150 px a 941 de altura, cantos cortados como a `HudVeil`), no `scripts/ui/hud.gd`, reaproveitando `HudVeil`
   ou um `TextureRect` com gradiente. Não mexer no cenário por isso. Dono: **ui-ux-designer**.

2. **Coluna de Bênçãos da direita cortada pela borda da tela** (`hud_8_boons.png`). Com 8 Bênçãos, a última fileira
   (dois ícones em x 1610 a 1672) sai pela direita; o "Nv.1" das linhas de cima encosta na borda.
   Correção: margem direita mínima de 16 px para a coluna inteira; quando passar de 6 itens, quebrar em duas colunas para
   a esquerda (não para fora). Procurar o bloco da coluna de Bênçãos em `scripts/ui/hud.gd`. Critério: com 8 e com 12
   Bênçãos todos os ícones inteiros e 16 px longe da borda. Dono: **ui-ux-designer**.

3. **Meio-fio do canal virou um traço preto** (`hall_canal.png`; antes, em `hud_named_slots.png`, era uma faixa branca).
   O escurecimento do commit 448503d4 passou do ponto: a margem norte do rio do Salão lê como um contorno de tinta preta
   de 2 a 3 px, não como pedra baixa. A referência mostra margem de pedra no mesmo valor do piso, um pouco mais escura,
   com musgo.
   Correção em `scripts/game/canal.gd`: `KERB_STONE` de `Color(0.12, 0.115, 0.11)` para cerca de `Color(0.26, 0.25, 0.235)`
   (o "#494D56 pedra fria de base" escurecido, sRGB), `KERB_SIDE` de `(0.11, 0.12, 0.14)` para cerca de `(0.17, 0.18, 0.20)`.
   Critério: a margem se lê como uma pedra mais escura que o piso, não como linha preta nem como faixa clara. Dono:
   **environment-artist**.

4. **O rio do Salão não segue a pintura aprovada** (`hall_canal.png` contra `01-arte-aprovada.jpg`). Na referência o rio é
   largo (cerca de um terço da largura do piso no oeste), entra pela esquerda alto, desce até a borda de baixo e sai pela
   mureta, com pedras e um arco quebrado na margem; reflete azul-cinza (#536F7A) e dourado perto dos braseiros. No jogo é
   uma cobra de cerca de 1 m que começa e termina no meio do piso (em `hall_canal.png` termina em x 230, y 580, antes da
   mureta) e a água é ardósia escura com pintas laranja que leem como brasa ou lava, não como folhas sob a água.
   Correção: (a) o traçado do rio no `CatacombHall._ground` deve ir até a mureta oeste/sul, com largura de 2,5 a 3,5 m no
   trecho de baixo; (b) em `shallow_water.gdshader`/`Canal`, trocar as pintas laranja por musgo (#53613B) com menos
   densidade e subir o reflexo (`reflect_*`) para mostrar o azul-cinza e um brilho dourado perto dos braseiros.
   Critério: rio largo na metade esquerda, encostando na mureta, sem pinta laranja. Atenção: o Salão é a sala de entrada
   e a esquiva por cima do rio não é mecânica dele; largura maior não pode bloquear o miolo (seguir `02-planta-dados.json`).
   Dono: **environment-artist** (traçado), **technical-artist** (shader).

5. **Faixa azul saturada e chapada no alto da Antessala** (`antessala_tip_attack.png`, de x 950 a 1672, y 60 a 210).
   Parece um plano sem luz nem textura (azul elétrico, bordas retas), fora da paleta. Em `antessala_stream.png` o mesmo
   canal aparece escuro e texturizado, então pode ser uma ordem de captura antiga ou um estado do shader (reflexo da
   `view_yaw` estourado em um ângulo). Correção: conferir com a captura extra A (abaixo); se ainda aparecer, travar o
   reflexo do `shallow_water.gdshader` num máximo (o azul nunca acima do #536F7A). Dono: **technical-artist**.

6. **Rachaduras do piso leem como fios** (`antessala_tip_attack.png`, `antessala_stream.png`, `hall_canal.png`). Linhas
   pretas finas e compridas atravessam as lajes como cabos ou cabelos; não são rachaduras pintadas.
   Correção em `scripts/game/hall_life.gd`: `CRACK_WIDTH` de 0,07 para 0,13, cor da rachadura no valor da sombra do piso
   (não preto), e `CRACKS` de 7 para 4; as pernas (`CRACK_LEG`) mais curtas. Critério: a 1672 nenhuma rachadura lê como
   linha contínua de 1 px. Dono: **environment-artist**.

7. **Lajes soltas claras demais, leem como folhas de papel** (todas as capturas de sala: em `antessala_stream.png` x 430,
   y 520 e x 1380, y 680; em `hud_8_boons.png` x 690, y 520). O valor delas é perto de branco, muito acima das lajes
   iluminadas da paleta (#77736D). Correção: o material das lajes soltas no tom do piso, no máximo 10% mais claro, com a
   mesma textura pintada. Dono: **environment-artist** (procurar a peça em `hall_life.gd`/`breakable_kit.gd`).

8. **Cabeça do cometa é um disco amarelo grande** (`comet_falling.png`). Lê como um sol ou uma bola de luz borrada, não
   como cometa; o sol também é símbolo de Elun que não usamos sem o Daniel. Correção em `scripts/game/arrival_scene.gd`:
   `HEAD_SIZE` 1,8 para 1,0, núcleo branco quente pequeno com halo dourado (não um disco uniforme), cauda mais fina e mais
   longa (`TAIL_STEP` 0,03 para 0,045) e 6 a 10 faíscas soltando da cauda. Critério: na captura a 2,0 s a cabeça ocupa
   menos de 50 px a 941 e a cauda tem pelo menos 3 vezes o tamanho da cabeça. Dono: **technical-artist**.

9. **Cristais da chegada deitados e chapados** (`comet_impact.png`, confirma o item já conhecido). No impacto aparecem
   quatro losangos verde e branco do tamanho de pedrinhas, sem altura. A spec diz 1,2 a 2,0 m (`CRYSTAL_TALL`). Pode ser
   só o instante (estão nascendo); a captura extra B tira a dúvida. Se a 3,0 s ainda forem planos, o `crystal_edge` não está
   no material. Dono: **technical-artist**.

10. **Herói nasce na borda esquerda da tela no Salão** (`hall_canal.png`, 0:01, herói em x 50, y 620, quase fora do quadro).
    A pintura põe o herói no meio do piso. Se é a entrada pelo oeste, a câmera deve começar nele (Perto segue o herói) e a
    entrada deve ficar dentro do piso, não na mureta. Dono: **environment-artist** (ponto de entrada do Salão), conferir com
    o **gameplay-engineer** se a câmera ainda está na transição da chegada.

## P2

11. **Salão sem vegetação** (`hall_canal.png` contra a referência). A pintura tem musgo nas juntas, hera na mureta e nas
    pilastras, e folhas vermelhas e laranja nos cantos; a nossa sala está quase só pedra (as folhas foram escurecidas por
    lerem como confete). Correção: musgo nas juntas do piso pelo shader do chão (máscara de junta com #53613B, 20 a 30%
    das juntas perto das paredes e do rio), hera pendurada (`kind` 2 que já existe) em 3 pilastras da mureta oeste, e folhas
    de volta só em 3 montes junto às paredes, em vermelho escuro (#7A2E22) e não amarelo. Dono: **environment-artist**.

12. **Inimigos visíveis antes do herói pousar** (`comet_falling.png`): dois esqueletos com barra de vida e um caído perto
    do rio enquanto o cometa ainda cai; em `comet_impact.png` sumiram. Lê como sala já em luta. Se é efeito do
    `--arrival-hold` (congela o relógio mas não a sala), é só da captura; senão, esconder inimigos e barras até o fim da
    chegada. Dono: **gameplay-engineer** (conferir; não é arte).

13. **Videira: o rosto do Leão é um emoji** (`vine_figure.png`). Duas sobrancelhas e um triângulo no centro da figura
    leem como rosto triste, não como leão. Também: dois vértices do polígono à direita (x 890, y 515 e x 785, y 690) não têm
    nó nem rótulo e parecem quebrados; o rodapé diz "3 de 11" e só aparecem 6 nós; e não há verde de videira (#94A76A) na
    tela, só bege e dourado. Correção: trocar o rosto por uma constelação simples de juba (5 a 7 estrelas fracas no
    `RING_DIM`, sem traço de rosto) em `scripts/ui/vine_sky.gd`; vértices sem nó viram estrela apagada com cadeado ou saem;
    rótulos dos nós comprados com filete verde #94A76A. Dono: **ui-ux-designer**.

14. **Carta "Peso em Brasa" com números que se contradizem** (`angel_single_cards.png`): texto "brasa por 3 s: 4 de dano por
    segundo", linha de números "Dano: 4  A cada: 4 s". "A cada 4 s" contradiz "por segundo". Corrigir o rótulo do número
    (é a recarga? a duração?) ou o valor. Dono: **ui-ux-designer** (rótulo), **balance-designer** se o número estiver errado.

15. **Forja, tela de explicação** (`forge_intro.png`): quatro parágrafos de texto corrido; o "Confirme para começar" em
    lilás (fora da paleta da tela) e sem a tecla. Correção: três linhas curtas, cada uma com o ícone da melhoria; o fecho
    vira o mesmo botão do rodapé ("[Enter] Começar"), em dourado. Os títulos de cima (Despertar, Refinar, Inscrever,
    Temperar) estão com espaçamento desigual (Inscrever e Temperar colados); se seguem os pontos da lâmina, tudo bem, mas
    então pôr um fio ligando título e ponto. Dono: **ui-ux-designer**.

16. **Contadores de Q e E com marcas diferentes** (`hud_named_slots.png`: Q mostra "(4)", E mostra "-2-"). Se são a mesma
    coisa (recarga ou cargas), usar a mesma marca; se são coisas diferentes, a diferença tem de ser de forma (anel de recarga
    contra pontos de carga), não de pontuação. O rótulo "Magia" depois da barra azul some sobre o cenário (sem a `HudVeil`).
    Dono: **ui-ux-designer**.

## Quickwins (menos de meia hora cada)

- `canal.gd`: `KERB_STONE`/`KERB_SIDE` (item 3).
- `hall_life.gd`: `CRACK_WIDTH` 0,13, `CRACKS` 4 (item 6).
- `arrival_scene.gd`: `HEAD_SIZE` 1,0, `TAIL_STEP` 0,045 (item 8).
- Painel da Videira: metade de baixo do painel da direita vazia (`vine_figure.png`); encolher o painel até o botão ou
  mostrar ali o próximo nó do ramo. Dono: ui-ux-designer.
- Cartas de Bênção: com os ícones de mouse no painel "Habilidades" (`cards_mouse_icons.png`), o selo de tecla dentro da
  carta ainda diz "Clique esquerdo"/"Clique direito" em texto; usar o mesmo ícone de mouse ali para as duas lerem igual.
  Dono: ui-ux-designer.

## O que está bom (não mexer)

- Herói: cabelo vermelho, cachecol azul-petróleo e Emeth esmeralda legíveis a 1672 com câmera Perto; o anel ciano no chão
  separa bem o herói do piso.
- Cartas da Saraël: hierarquia clara (nome, tecla, efeito, números), anjo grande à esquerda, painel de habilidades com a
  linha da carta acesa. Os ícones de mouse dourados com o nome sob cada losango (`hud_named_slots.png`) resolvem a leitura
  da barra.
- Anel dourado do impacto da chegada no chão (`comet_impact.png`): forma e cor certas.
- Salão: estátuas encapuzadas, estandartes carmim, escada e portas no nordeste seguem a pintura; o facho de luz entrando
  pelo oeste dá a profundidade pedida.

## Santuário (blockout, `hub_blockout_arrival.png`): só direção

- **Paleta errada para o hub**: o blockout usa a pedra cinza-escura e a luz baixa das catacumbas. O Santuário é calcário
  claro (#D3C5A7, sombra #8F8775), luz quente de noroeste e céu aberto (`eterra_hub/04-paleta-e-iluminacao.md`). Mesmo no
  blockout, o material de base já deveria ser o calcário para medir valor e leitura.
- **Painel cinza liso ocupando 40% da esquerda**: placas verticais sem luz que leem como cerca. No lugar: céu/penhasco ao
  fundo com névoa fria (#527F8C), mais baixo que o piso, para o hub parecer no alto de um morro.
- **Chegada**: pela pintura, o primeiro ponto do fluxo é o Ponto de Vigília (fogo, oeste). O herói deve nascer de frente
  para ele, num pátio aberto, não espremido entre um bloco e um buraco. Do ponto de chegada deve dar para ver a Videira
  (centro, fonte) e o caminho dourado.
- Vegetação (ciprestes #52683D, videira #94A76A, flores roxas como acento) faz parte da silhueta do hub; prever os lugares
  já no blockout.
- Dono: **environment-artist** (já em andamento).

## Capturas extras pedidas (no máximo 3, só a sessão principal captura, uma por vez)

A. Antessala no build atual, para os itens 3, 5, 6 e 7:
   `tools/gpu.sh shot <scratchpad>/antessala_now.png --bot --autopick --seed=5 --shot-at=4`
B. Chegada depois do impacto, para os itens 8 e 9 (cristais em pé, herói se formando):
   `tools/gpu.sh shot <scratchpad>/arrival_3s.png --arrival --arrival-hold=3.0 --seed=5`
C. Salão em luta a 1080, para os itens 1, 2 e 10 (braseiro atrás da barra, coluna de Bênçãos):
   `RES=1920x1080 tools/gpu.sh shot <scratchpad>/hall_fight_1080.png --bot --autopick --boons=8 --seed=5 --shot-at=9`

## Veredito

Aprovado para o teste do Daniel como está (sem P0). Antes de entregar, se houver tempo, fazer os três quickwins de
constante (meio-fio, rachaduras, cometa) e a placa atrás da barra de habilidades (item 1), que são os defeitos mais
visíveis na tela de luta. Rio largo e vegetação do Salão (itens 4 e 11) ficam para a próxima rodada de cenário. Placeholder
ainda: Santuário inteiro (blockout). A aprovação artística final é do Daniel.
