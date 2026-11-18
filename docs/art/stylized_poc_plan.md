# Eterra Stylized Art: diagnóstico e plano da prova de conceito

- **Data**: 2026-11-18. **Autor**: game-director. **Commit lido**: `b279433` (HEAD de `arpg-3d`, AP-1 integrado).
- **Pedido**: diretriz do PO `docs/art/po_directive_stylized_2026-11-18.md` (texto dele na íntegra). **Só planejamento**:
  nada aqui foi implementado, nenhum crédito do Meshy, nenhuma ferramenta paga, nada voltado à Steam.
- **Referências (complemento do PO de 2026-11-18, que aprovou a estrutura deste plano)**, imagens de IA, só locais,
  nunca asset nem evidência:
  - **Principal (R1)**: `docs/art/ref/stylized_2026-11-18/01_referencia_principal_gameplay_stylized.png`, o gameplay
    estilizado que motivou a mudança: pedra pintada à mão, tochas quentes e profundidade fria, estátuas encapuzadas,
    nichos com potes, estandartes rasgados, ponte em arcos sobre o abismo, meia-lua esmeralda, aviso vermelho claro,
    personagens de silhueta forte.
  - **Secundária (R2)**: `docs/art/ref/stylized_2026-11-18/02_prancha_conceitual_relicarios_cripta_livro_morvath.png`, só
    apoio conceitual. As duas **não se misturam**: o alvo do salão é a R1.
  - Análise medida, valores e matriz: **`docs/art/stylized_spec.md`** (STY-01). O que a R1 tem e Eterra recusa (estrela
    de quatro pontas, cruz, estandarte vermelho, círculo no chão, HUD, personagens, layout) está na seção 7 dela.
- **Critério de aprovação**: visual, do PO, no lado a lado. **Nenhuma porcentagem de semelhança é critério** (as
  estimativas da 1.2 antiga saíram). A estética tem de funcionar sem depender de filtro de pós-processamento.
- **Lido**: `CLAUDE.md` (renderizador, shaders, assados, C18, AP-1), `docs/arte/estetica.md`, `docs/art/art_direction.md`,
  `docs/art/art_polish_backlog.md`, `docs/art/asset_inventory.md`, `docs/qa/asset_report.md`, `docs/art/meshy_asset_plan.md`,
  `docs/qa/e6_audio_perf.md` (iGPU), `docs/gallery/ap1/README.md`; código: `Game._build_world`, `GraphicsQuality`,
  `RoomMood._apply_grade`, `HeroBody._fill`, cabeçalhos de `masonry.gdshader`, `crowd.gdshader`, `screen.gdshader`,
  `ground.gdshader`, `catacomb_floor.gdshader`, `project.godot` (`shader_globals`).
- **Capturas abertas por mim**: a prancha; `docs/gallery/ap1/after/vitrine_1080.jpg`, `ap1/after/boss_1080.jpg`,
  `c18/after/jogo.jpg`.
- O que é opinião minha está dito. Os custos de GPU abaixo são **estimativas**: a prova de conceito existe para medi-los.
- **Atualização do art-director (STY-01, 2026-11-18)**: a 1.1 foi escrita contra a prancha (hoje R2) e fica como
  histórico; o diagnóstico contra a R1 está na seção 0 da `stylized_spec.md`. Resumo: a R1 tem a **mesma câmera** que a
  nossa (giro e inclinação batem pelas bordas das lajes) mas mais perto (herói cerca de 174 px a 1080 contra 105);
  é **mais clara** (luma 67 contra 54) e **menos saturada** (p90 15 contra 23); a pedra é **morna** (umbra-oliva, matiz
  28 a 40) com o frio só no abismo e nos vãos (o nosso chão sai lilás, matiz 244 a 252); os personagens são **mais
  escuros que o chão**, separados por borda de luz morna e contorno fino.

---

## 1. Diagnóstico

### 1.1 O que a referência provisória tem que nós não temos

Comparando a prancha (quadros Cripta e Morvath) com `ap1/after/vitrine_1080.jpg` e `c18/after/jogo.jpg`, na mesma
família de cor (ardósia azulada, velas quentes, ouro velho, violeta de Morvath), a diferença não é de paleta, é de
**acabamento**:

1. **Pedra pintada à mão**: cada bloco tem a aresta de cima clara e lascada, a face com pinceladas de duas ou três cores,
   o vão escuro; a nossa cantaria (`masonry.gdshader`) tem as juntas e o relevo, mas a luz é física (`diffuse_burley`,
   `specular_schlick_ggx`) e o valor varia pouco dentro do bloco.
2. **Luz em faixas e sombra colorida**: na prancha a sombra é azul-petróleo e violeta, nunca preta; a luz quente das velas
   faz poças de borda definida; o luar faz um facho frio com poeira. Nós temos sombra escura e neutra e transições suaves.
3. **Borda de luz nos personagens** (rim) e corpo com poucos tons; o herói e Morvath parecem pintados sobre o cenário. O
   nosso herói usa `StandardMaterial3D` com a textura do Meshy e um preenchimento (`HeroBody._fill`), os inimigos o
   `crowd.gdshader` com luz `diffuse_lambert`.
4. **Vida no cenário**: hera e musgo pendurados, estandartes, entulho, velas em grupos; nós temos parte disso (velas,
   estandartes, potes) e nada de vegetação no salão.
5. **Enquadramento mais próximo**: a prancha mostra a sala de bem mais perto que a nossa câmera (distância 54, campo 24,
   herói de cerca de 130 px a 1080). Opinião minha: parte grande da sensação de "pintura" da prancha vem desse zoom, e
   a diretriz manda manter a câmera. A prova vai mostrar a estética **na câmera do jogo**, que é o que importa.

### 1.2 O que se alcança só com o Godot

(Revisado no STY-01: as porcentagens de antes saíram; o PO avalia visualmente.)

| Camada | Só Godot? |
|---|---|
| Valor da sala (chão claro e morno no meio, profundidade fria), luz em faixas, poças das tochas, sombra projetada nítida | sim: `light()` nos shaders, ambiente, luzes do salão (só números) |
| Pedra e chão pintados (pincelada em duas escalas, aresta clara, junta desenhada, valor por bloco, menos relevo fotográfico) | sim: ruído e faixas no `masonry` e no `catacomb_floor`, triplanar, sem UV novo |
| Personagens coerentes com o cenário (faixas, corpo mais escuro que o chão, rim morno, contorno de casca, menos detalhe fotográfico) | sim: `crowd.gdshader`, `crowd_outline.gdshader` e um shader do herói; os modelos não mudam |
| Acabamento pictórico na tela (Kuwahara, contorno de tela) | **opcional**, só Forward+; descartado se borrar, perder detalhe ou custar demais (`stylized_spec.md` 5.2) |
| Vida no cenário (paredes em cantaria, estandartes petróleo, nichos, facho de lua) | quase: `Masonry`, `ArenaKit.banner`, `moon_shaft` já existem |
| Esculpido pintado (estátuas, moldura do portal, ornamento, armas próprias) e texturas pintadas à mão nos personagens | não: pede modelo novo ou repintura (Meshy ou artista); só estimativa |

Por que a aposta é boa (opinião): a R1 tem a nossa câmera e a nossa família de peças; o que muda é a maneira de
sombrear e o valor da sala, e isso um shader troca sem tocar em modelo.

### 1.3 Modelos que ficam

| Asset | Fica? | Por quê |
|---|---|---|
| O Guerreiro (Meshy, `hero_explorer`) e as animações | **fica** | aprovado, proporção certa, textura já com cara de pintura; o estilo entra pelo shader do herói (novo, só no perfil estilizado) |
| A Emeth (Meshy) | **fica** | o `emeth.gdshader` já é próprio; ganha faixas e o brilho pintado |
| Os nove inimigos e Morvath (Meshy, assados por vértice) | **ficam** | o `crowd.gdshader` desenha todos; estilizar é mudar a luz nele, sem reassar nem tocar no `BakedModel` |
| Pedra procedural (`Masonry`, `catacomb_floor`, estátuas encapuzadas em código) | **fica** | é o lugar onde a pincelada entra mais barata (triplanar, sem UV) |
| KayKit de masmorra (velas, potes, barris, caixotes, entulho, escadas) | **fica na prova** | forma grossa e legível combina com o estilizado; a paleta única recebe um material estilizado no perfil |
| KayKit nas paredes e pilares do salão | fica na prova, **sai depois** | lê como tijolo de brinquedo (já é o ART-03.1); a cantaria procedural substitui na migração |
| Partículas, fitas, avisos, raio-x | **ficam** | são a leitura do combate; só se confere o contraste delas sobre o chão novo |

### 1.4 O que pede trabalho adicional (sem Meshy)

- **Shader do herói**: hoje é `StandardMaterial3D` (`HeroBody._fill`); no perfil estilizado precisa de um shader próprio
  com as mesmas faixas e rim dos inimigos, sem quebrar os três passes do raio-x (`xray_depth`, `xray`, `xray_edge`).
- **Paredes e pilares do salão** em cantaria pintada (sai o KayKit das paredes; é o ART-03.1 na língua nova).
- **Hera, musgo e entulho** no salão por cartões procedurais (reuso de `canopy.gdshader` e `root_moss.gdshader`).
- **Facho de lua** no salão (reuso do `ArenaRoom.moon_shaft`), como o feixe frio da prancha.
- **Estandartes**: o vermelho deles é o do perigo (ART-02.4, Q-22 respondida com o pano petróleo e o leão em ouro velho
  no relicário); no estilizado entram já no tom decidido.
- **Medalhão do chão e runas**: o filtro de pintura pode apagar o traço fino; precisam de linha mais grossa ou de ficar
  fora do filtro.

### 1.5 Modelos que justificariam o Meshy no futuro (nenhum agora)

**Regra do PO (2026-11-18, depois da diretriz)**: nenhum crédito do Meshy é gasto sem o "pode" explícito dele, e antes
de qualquer gasto ele recebe uma estimativa. Por isso a tabela abaixo é **só estimativa: nada está autorizado**. Cada
linha diz o modelo, os créditos de cada um, o total e por que o Godot sozinho não basta. Quando um lote ficar maduro, o
`technical-artist` manda ao Daniel a estimativa daquele lote (peças, créditos, prompts, o que sai do jogo) e só então ele
decide.

Custos do `tools/meshy/meshy.mjs` e do `meshy_asset_plan.md`: modelo parado com textura 15, repintura da mesma malha
(`retexture`, mesma malha e UV) 10. **Saldo 500; gasto autorizado: ZERO** (complemento do PO de 2026-11-18). Estimativas
de repintura ou substituição são permitidas; nenhuma operação paga sem autorização explícita dele.

| Lote (estimativa, aguarda estimativa formal e aprovação do PO) | Modelos | Créditos cada | Total | Por que o Godot sozinho não basta |
|---|---|---|---|---|
| A. Repintura "hand-painted" (só se a prova mostrar que o shader não basta; sem mexer em malha, esqueleto nem animação; os inimigos são reassados) | herói, Emeth, Morvath, nove inimigos (12) | 10 | 120 | o shader muda a luz, não o que está pintado na textura: o detalhe fotográfico do Meshy só some repintando; risco: herói aprovado mudar de cara (regra 3 da diretriz) |
| B. Esculpidos do salão | estátua encapuzada, moldura do portal, obelisco, braseiro (4) | 15 | 60 | forma esculpida com volume (pregas, ornamento, chifres de pedra) não sai de caixas e shader; a estátua aparece 4 vezes |
| C. Armas próprias dos inimigos e a foice de Morvath (era parte da Q-18) | cajado, besta, cutelo, foice (4) | 20 a 30 | cerca de 120 | as do KayKit repintadas são paliativo (VX-07); silhueta de arma é forma, não cor |
| D. Repintura das elites (era parte da Q-18, espera a Q-11) | 6 tipos com elite | 10 | 60 | o ouro por shader pinta o aço inteiro; peças e desgaste próprios só na textura |
| **Total estimado** | | | **até 360** | reserva de 140 dos 500 para refazer o que sair ruim |

**Q-18 substituída**: a autorização anterior (estátua e armas no Meshy, até 135 créditos, depois do AP-3) **não vale
mais**. Estátua e armas (lotes B e C) ficam como "aguardando estimativa e aprovação do PO", como todo o resto.

### 1.6 Melhor sequência de migração (se a prova for aprovada)

1. **Prova no salão** (este plano, STY-01 a STY-09). Nada mais muda.
2. **Base comum**: o perfil estilizado vira o padrão em tudo o que é compartilhado (inimigos, herói, Emeth, efeitos, a
   cantaria e o chão comuns): as outras salas já mudam uns 60% de graça por herdarem os shaders.
3. **Câmara do Selo** (a luta de Morvath, a sala de maior emoção e a outra metade da prancha).
4. **Arenas, uma por vez, dentro do AP-3** ("Masmorras com alma" vira a migração: Cripta, Santuário, Jardim, Fendas,
   Ponte, Runas, câmaras de evento), cada uma com antes e depois e o orçamento da iGPU.
5. **Meshy por lote**, só onde a prova e as revisões apontarem forma esculpida faltando (1.5).
6. **Clássico aposentado** só depois de tudo migrado e do Daniel decidir (até lá o perfil fica reversível).

---

## 2. Prova de conceito: o Salão das Catacumbas em estilizado

**Objetivo em uma frase**: o Salão das Catacumbas (sala 1 da descida, `CatacombHall`) rodando de verdade no Godot num
perfil visual estilizado, com os modelos que existem, comparável lado a lado com o clássico no mesmo quadro.

### 2.1 O perfil visual reversível (proposta; a forma é decisão da sessão principal)

- **`VisualProfile`** (`scripts/core/visual_profile.gd`, lógica pura com teste GUT): `CLASSIC` e `STYLIZED`, cada um uma
  linha de números como o `GraphicsQuality.LEVELS` (ambiente, exposição, contraste, saturação, LUT de base, cor e energia
  da lua, cor da sombra, globais dos shaders). `current()` lê `--look=classic|stylized`; sem a opção, `CLASSIC`.
- **Uma global de shader `art_style`** (0 ou 1) em `project.godot` (`shader_globals`, ao lado de `hero_pos` e
  `room_air`), posta uma vez pelo `VisualProfile.apply`. Os shaders que mudam leem um include comum novo,
  `assets/shaders/paint.gdshaderinc` (faixas de luz, sombra colorida, rim, ruído de pincel, aresta clara), e só o usam
  quando `art_style > 0.5`. Ramo por uniforme é coerente na GPU (custo perto de zero). Alternativa descartada por mim:
  cópias `*_paint.gdshader` de cada shader, que dobram a manutenção.
- **Pós de pintura** (`PaintPass`, `CompositorEffect` no `Camera3D.compositor`, só Forward+): ligado só no perfil
  estilizado e na qualidade Alta e Média; no Compatibility e na Baixa não existe (ver riscos).
- **Composição com o `RoomMood`**: o perfil troca a LUT de base (`_base.grade`); o `RoomMood` continua somando a dele por
  cima (fogo, abismo, fase 4). Nada do `RoomMood` muda.
- **Opção nas Configurações**: não na prova (só `--look`). Se o Daniel quiser alternar jogando, uma linha "Estilo visual:
  Clássico / Pintura" no Vídeo, chave `look` do save, do `ui-ux-designer`, meio dia. Recomendo deixar para depois da
  decisão.
- **Garantia do clássico**: com `art_style` 0 o quadro tem de ser o mesmo de hoje (captura do `--showcase --seed=5` e do
  combate antes e depois da mudança: diferença máxima de 2 níveis por canal, `tools/frame_stats.py` igual a uma casa).

### 2.2 O que muda em cada camada (os números estão na `stylized_spec.md`, que prevalece onde diferir desta tabela)

Ajustes do STY-01 sobre a tabela abaixo: a pedra no perfil estilizado é **morna** (umbra-oliva) com o frio só na
profundidade, e a sombra dentro da sala é quase neutra, não petróleo e violeta (a R1 é assim; pergunta S-Q5); a
saturação p90 do quadro **desce** para 14 a 22 (a R1 mede 15); os personagens ficam **mais escuros que o chão** com rim
morno e contorno de casca em todos (`crowd_outline.gdshader`), em vez da multidão clara sobre chão escuro; hera e musgo
saem do salão (a R1 não tem) e entram estandartes petróleo, cantaria, nichos opcionais e um facho de lua opcional.

| Camada | Arquivos | No perfil estilizado |
|---|---|---|
| **Materiais e texturas** | `masonry.gdshader`, `catacomb_floor.gdshaderinc` (e o `chamber_floor` herda), `paint.gdshaderinc` | ruído de pincel em mundo (2 escalas, sem textura nova ou com uma de 512 em BC4) que quebra a cor em manchas de 2 a 3 tons; aresta de cima clara e lascada em cada bloco (já existe `bevel_light`, `top_light`: ficam mais fortes e em faixa); vão e junta mais escuros e frios; relevo da rocha mais fraco (o detalhe fotográfico é o que mais destoa da pintura) |
| **Luz e sombra** | `paint.gdshaderinc` (`light()`), `VisualProfile` (ambiente e lua), `CatacombHall` (só números) | luz em 3 faixas suaves (borda da faixa de 0,08 a 0,15, nunca degrau duro); a sombra puxa para petróleo frio e violeta (cor da sombra no `light()` e ambiente colorido), nunca preta (valor mínimo da pedra na sombra proposto em 0,12); a lua com cor e um facho no meio do salão (`moon_shaft`); as poças das velas e braseiros com borda mais definida; o preenchimento do ambiente sobe para as paredes não morrerem |
| **Paleta** | `VisualProfile` (LUT), `art_direction.md` 2 | as cores reservadas não mudam (Emeth, petróleo do herói, vermelho do perigo, âmbar, verdes e violetas de Morvath); muda o cenário: menos cinza neutro, mais petróleo nas sombras e ouro velho morno nas luzes; saturação p90 do quadro na faixa de hoje (24 a 28) ou até 32 com aprovação do art-director |
| **Personagens** | `crowd.gdshader` (inimigos e Morvath), shader novo do herói (`hero_paint.gdshader`), `HeroBody` | as mesmas faixas e a sombra colorida do cenário (coerência); rim de luz fino da cor do ar da sala; menos detalhe da textura do Meshy (mistura para a cor média por região, `paint_flat`); o pisca do golpe, o "vai bater" (`tell_light`), a queimadura e o ouro das elites continuam iguais e abaixo do `flash_cap` |
| **Emeth** | `emeth.gdshader`, `emeth_wave.gdshader`, `slash.gdshader` (só números) | lâmina com duas faixas de esmeralda e o fio central marfim pintado (sem luz nova); a onda e o corte com a borda de ataque em pincelada (ruído na borda, não no meio); nada acima do limiar do glow, nada sobre o rosto do herói |
| **Acabamento pictórico (opcional)** | `PaintPass` (novo, Forward+), `screen.gdshader` (uma uniforme) | **opcional e descartável** (critério na `stylized_spec.md` 5.2: borrão, perda de detalhe, custo acima de 1,0 ms na Alta, ou ganho nulo); a prova é julgada com ele desligado. Se ficar: filtro Kuwahara de 4 setores, raio de 2 a 3 px a 1080, **só sobre o opaco** (antes dos transparentes: avisos no chão, fitas, partículas, raio-x e números ficam nítidos); contorno suave por profundidade e normal, colorido (petróleo escuro), nunca linha preta de quadrinho; no `screen.gdshader` só um tom dividido leve (sombras frias, luzes mornas) |
| **Coerência herói e cenário** | tudo acima | o herói usa a mesma luz pintada que a pedra; o rim dele é o mais claro da tela; o anel, o raio-x e a fita do corte não mudam |

### 2.3 O que fica igual

Câmera (`Feel.cam_*`, `CamFrame`), layout do salão (`CatacombHall`, `RoomLayout`), colisão, simulação, dados
(`make_data.gd` não é tocado), animações e assados, HUD e menus, avisos no chão (forma, tempo e cor), números de dano,
hit stop e câmera lenta. **Nenhum arquivo de `scripts/core/` além do `VisualProfile`, nenhum `.tres` de dados.** A prova
passa a suíte e a sonda de game feel sem mudar uma linha de lógica.

### 2.4 Entregas e responsáveis

| ID | Entrega | Responsável | Arquivos (donos distintos) | Pronto quando | Estado |
|---|---|---|---|---|---|
| STY-01 | **Especificação da prova**: alvo em valores (faixas, cores de sombra, rim, pincelada, filtro), o que não fazer (branco, amarelo, partícula sobre o herói, vermelho fora de aviso), análise medida da R1, matriz de correspondência, critérios do parecer | `art-director` | `docs/art/stylized_spec.md` | **entregue em 2026-11-18**; aprovado pela sessão principal antes do STY-03 |
| STY-02 | **Linha de base clássica**: capturas e vídeos do clássico (2.5), FPS e memória, inventário "reaproveita / substitui" inicial | `qa-performance` (capturas, FPS), `technical-artist` (memória, inventário) | `docs/gallery/stylized_poc/classic/` | tudo da 2.5 no clássico, no mesmo commit |
| STY-03 | **Perfil**: `VisualProfile`, `--look`, global `art_style`, `paint.gdshaderinc` vazio, teste GUT, prova de que o clássico não mudou | `environment-artist` (sessão principal liga no `Game._build_world` e no `project.godot`) | `scripts/core/visual_profile.gd`, `tests/test_visual_profile.gd` | GUT verde; captura do clássico igual à linha de base | **feito em 2026-11-18** (F7 troca ao vivo; clássico igual fora das chamas e partículas animadas) |
| STY-04 | **Pedra, chão e luz do salão** pintados | `environment-artist` | `masonry.gdshader`, `catacomb_floor.gdshaderinc`, `paint.gdshaderinc`, números no `CatacombHall` | captura aprovada pelo art-director na 2.6 | **feito em 2026-11-18**, falta o parecer do art-director |
| STY-05 | **Vida no salão**: paredes do KayKit trocadas pela cantaria, estandartes petróleo com o leão, props KayKit com material pintado; opcionais nichos com potes, arcos sob a borda sul e um facho de lua (hera e musgo saíram: a R1 não tem) **só no perfil estilizado** | `environment-artist` | `catacomb_hall.gd` (ramo pelo perfil) | `fit_probe` do salão sem fantasma novo; colisão igual (`test_arenas.gd`) | **feito em 2026-11-18**: o salão não tem parede nem pilar do KayKit (já era cantaria), então só estandartes e props; nichos, arcos e facho de lua ficaram de fora; colisão igual (`test_visual_profile.gd`) |
| STY-06 | **Personagens e Emeth**: `crowd.gdshader` no include, `hero_paint.gdshader`, `emeth.gdshader` | `environment-artist`; `combat-feel-director` revisa leitura | `crowd.gdshader`, `hero_paint.gdshader`, `hero_body.gd` (só a troca de material pelo perfil), `emeth.gdshader` | testes do raio-x e do pisca verdes (`test_burn_flash.gd`, `test_hero_look.gd`); captura `--shot-on=hit` e `swing` <br>**Feito (technical-artist, 2026-11-18)**: multidão em três faixas com borda morna e `paint_flat`, casca em todos (0,04 m), `hero_paint.gdshader` e `hero_outline.gdshader` trocados pelo `VisualProfile.vary` (raio-x, anel, pisca e maldição seguem), Emeth em duas faixas sob 0,98, cauda do corte em pinceladas (`style_cap` 0,55), lascas esmeralda finas, avisos com ganho 1,6 no aro e 1,5 no preenchimento (fio da mira 130 a 138 de luma contra 72 a 86 da laje: +50). Clássico igual (`tests/test_stylized_figures.gd`). RTX 1080 Alta: 2,80 ms GPU clássico, 2,63 estilizado, 756 e 818 chamadas, 330 e 332 MB; iGPU Baixa 720: 15,05 e 15,75 ms. Sonda 40/40 nos dois looks. Chips do golpe ainda vivem 0,4 s (a spec pede 0,15: `fx.gd`/`combat.gd`, não são do technical-artist) |
| STY-07 | **Pós de pintura, opcional** (`PaintPass`: Kuwahara e contorno, só opaco, só Forward+, raio pela escala 3D) e medida de custo isolada; descartado pelo critério da `stylized_spec.md` 5.2 | `technical-artist` | `scripts/render/paint_pass.gd`, `assets/shaders/paint_pass.glsl` | custo medido por conta própria na RTX e na iGPU (2.7); liga e desliga por `--paint-pass=0` <br>**Feito e desligado (2026-11-18)**: `PaintPass` funciona (dois despachos de computação, cor para rascunho e de volta), custa 0,14 ms de GPU e 7,5 MB na RTX a 1080, mas cai nos critérios 1 e 2 da 5.2 (runas do medalhão e rachaduras viram borrão, pontos escuros nos corpos) e o MSAA da Alta apaga o trabalho dele (ligado, ele desliga o MSAA). `DEFAULT_ON` false; `--paint-pass=1` para ver |
| STY-08 | **Evidências e medidas** (2.5, 2.7) | `qa-performance` | `docs/gallery/stylized_poc/` | tudo da 2.5 nas duas versões |
| STY-09 | **Revisões**: art-director (estética, paleta, hierarquia), technical-artist (orçamento, lista final reaproveita / substitui, o que pediria Meshy), combat-feel-director (avisos, golpes, herói legível; pode reprovar) | os três | `docs/gallery/stylized_poc/ART_REVIEW.md`, `TECH_REVIEW.md`, `FEEL_REVIEW.md` | três pareceres com captura citada e veredito |

Paralelo seguro: STY-01 e STY-02 juntos; STY-04/05/06 (environment-artist) e STY-07 (technical-artist) juntos, arquivos
distintos. `gameplay-engineer` e `ui-ux-designer` não entram.

**Dias (estimativa)**: dia 1 STY-01, STY-02, STY-03; dias 2 e 3 STY-04, STY-05, STY-07; dia 4 STY-06 e a integração do
pós; dia 5 STY-08 e STY-09; dia 6 de folga para correções da revisão. **5 a 6 dias**, depois o Daniel decide.

### 2.5 Evidências (as da diretriz, com o como)

Pasta `docs/gallery/stylized_poc/` com `classic/` e `stylized/`, todas na RTX 5060 em Forward+ (`tools/gpu.sh`), mesma
semente, mesmo commit, só `--look` diferente:

1. **Mesmo quadro**: vitrine `--showcase --seed=5` (o enquadramento da pintura) e combate `--bot --autopick --seed=5
   --shot-at=9` (o quadro do `c18/after/jogo.jpg`), a 1080 e 720; os pares juntos numa imagem lado a lado. **Câmera do
   jogo, sem mudança**: é nela que a prova é julgada.
1b. **Captura de estudo mais perto, só para avaliação artística** (pedido do PO): a mesma câmera com `--cam-dist=33` (o
   herói fica do tamanho da R1, cerca de 160 a 175 px a 1080), combate e vitrine, nas duas versões, rotulada "estudo,
   câmera fora do jogo". A câmera de gameplay não muda sem aprovação.
1c. **Com e sem o pós** (se o STY-07 existir): os mesmos quadros com `--paint-pass=0`, para provar que a estética vale
   sem filtro.
2. **Momentos de combate**: `--shot-on=swing`, `hit`, `special` e um aviso de inimigo no chão, nas duas versões.
3. **Vídeo curto de combate**, 8 a 10 s em cada versão, mesma semente (`--frames` com `--count` e `--every`, montado com
   ffmpeg), com golpe, esquiva, especial e um abate.
4. **Compatibility** (`--rendering-driver opengl3`) e **iGPU na Baixa** (`--gpu-index 1`, 1280 x 720), uma captura de cada
   nas duas versões.
5. **FPS e memória**: RTX Alta a 1080 (quadro e GPU em ms, como na E6), iGPU Baixa a 1280 x 720 (qps em duas rodadas),
   VRAM (`tools/asset_probe.gd -- vram`), memória de processo, tamanho do pacote se entrar textura.
6. **Medidas do quadro** (`tools/frame_stats.py`): luma, saturação p90, vermelho saturado (só nos avisos), caixa do herói.
7. **Pareceres** do art-director e do technical-artist (e do combat-feel-director).
8. **Listas**: assets reaproveitados como estão; reaproveitados com shader; que precisariam ser substituídos (com o
   motivo e, se for o caso, o lote do Meshy da 1.5).

### 2.6 Critérios de aceite medíveis (proposta)

- **Clássico intacto**: diferença máxima de 2 por canal nas capturas de base; suíte inteira verde; sonda 40/40.
- **Orçamento** (opinião minha, a confirmar pelo technical-artist): RTX Alta a 1080 no máximo **+1,0 ms de GPU** com o
  pós; iGPU Baixa a 720 no salão **no máximo 3 qps abaixo** do clássico (hoje 55 a 58), sem o pós; VRAM **até +16 MB**;
  pacote **até +5 MB**.
- **Leitura** (combat-feel-director): contraste do aviso sobre o chão no estilizado igual ou maior que no clássico
  (luma do aviso menos a do chão em volta, medida na mesma caixa); o fio da mira (6 px) e o fio marfim do raio-x
  visíveis a 1080; herói achado em 1 s nas capturas de combate; nenhum golpe ou aviso trocou de tempo (a lógica não
  muda, mas a sonda roda).
- **Paleta**: nenhum pixel acima de 235 sobre o herói; vermelho saturado só nos avisos; cores reservadas no mesmo matiz
  (`art_direction.md` 2.1).
- **Sem filtro**: a estética tem de aparecer com o `PaintPass` desligado (material e luz); o filtro é opcional e sai
  pelo critério da `stylized_spec.md` 5.2.
- **Arte**: o parecer do art-director segue os 12 critérios da `stylized_spec.md` 8; sem porcentagem de semelhança.
- **Decisão**: **o PO avalia visualmente**, no lado a lado, e só ele aprova a direção. Recomendação do game-director pela
  regra: aprovar se ele preferir o estilizado **e** o orçamento e a leitura passarem; se o pós falhar no orçamento,
  aprovar a direção só com as camadas de material e luz e descartar o pós.

### 2.7 Riscos

| Risco | Probabilidade (opinião) | Mitigação |
|---|---|---|
| **Custo do filtro de pintura na iGPU**: Kuwahara de 4 setores e raio 3 lê cerca de 64 texels por pixel; a 1280 x 720 isso pode passar de 2 ms numa iGPU | média | o pós roda na resolução 3D interna (na Baixa, metade), mas por isso mesmo ele **não entra na Baixa**; raio escalado pela escala 3D; medir isolado no STY-07 antes de integrar |
| **Compatibility sem `CompositorEffect`** | certa | navegador e celular ficam só com material e luz (memória do projeto: só o desktop precisa ficar ótimo); nenhum filtro de tela no `screen.gdshader`, que passaria por cima dos avisos |
| **Avisos menos legíveis**: são `blend_add` sobre o chão; chão pintado mais claro ou mais variado come o contraste | alta | o filtro só pega o opaco; a mancha do pincel fica fraca no miolo da sala; medida de contraste no aceite; combat-feel-director pode reprovar |
| **Raio-x e herói borrados**: o filtro pega o corpo opaco do herói (cerca de 130 px), pode apagar o rosto | média | raio de 2 px; se a captura mostrar, máscara do herói (stencil, já usado pela multidão) ou o pós só no cenário; o raio-x é desenhado depois e não é filtrado |
| **Medalhão e runas do chão apagados pelo filtro** | média | traço mais grosso no perfil ou medalhão fora do filtro |
| **Brilho estourado**: faixas e rim sobem as luzes | média | `ScreenTone` e o teto 226/235 valem igual; luz sempre abaixo do limiar do glow |
| **Conflito de arquivos** com AP-2 (`crowd.gdshader`, raio-x) e C19 | alta se correrem juntos | nada de AP-2 enquanto a prova estiver aberta; C19 não toca esses arquivos |
| **Clássico mudar sem querer** (o include entra em shaders compartilhados) | média | captura de base e diferença de 2 por canal no aceite |
| **Tentação de migrar tudo** | alta | a prova só é julgada no salão; as outras salas recebem uma captura cada só para provar que não quebram |
| **Misturar as duas referências** | média | resolvido no STY-01: a R1 manda no salão; da R2 só o pano petróleo dos estandartes e o facho frio |
| **Pedra morna contra a regra "cenário frio"** | certa (decisão) | S-Q5; a especificação segue a R1 e diz como voltar à pedra fria |

---

## 3. Perguntas ao PO (só as necessárias)

| ID | Pergunta | Opções | Recomendação |
|---|---|---|---|
| ~~S-Q1~~ | Referência que não tinha chegado | | **Respondida (2026-11-18)**: a R1 é a principal, a prancha é a R2 |
| ~~S-Q2~~ | Captura extra mais perto | | **Respondida**: sim, só para avaliação, câmera do jogo intacta (2.5, item 1b) |
| ~~S-Q3~~ | Filtro de pintura | | **Respondida**: opcional, descartado se borrar, perder detalhe ou custar demais (`stylized_spec.md` 5.2) |
| S-Q4 | Se a prova mostrar que a textura dos personagens do Meshy destoa, quer receber a **estimativa** da repintura na mesma malha (lote A da 1.5: `retexture`, 10 créditos cada, 120 no todo) para decidir? | (a) sim, só a estimativa, nada gasto; (b) não, personagens só por shader | (a): é só um documento; o gasto e a cara do herói continuam sendo decisão sua |
| **S-Q5** | A R1 tem pedra **morna** (umbra-oliva) com o frio só no abismo; o nosso guia diz "cenário frio" e o chão do salão hoje sai lilás. No perfil estilizado, a pedra segue a R1? | (a) sim, pedra morna, frio só na profundidade; (b) pedra fria, só pintada | (a): é a imagem que você escolheu e o calor faz o herói e a Emeth saltarem; a especificação está escrita para (a) e diz como fazer (b) |
| **S-Q6** | O medalhão gravado do salão (da pintura aprovada de 2026-11-14) tem quatro pontas longas, que leem como estrela de quatro pontas, símbolo proibido. | (a) fica na prova, sem ouro nem brilho; (b) as pontas mudam ou somem numa entrega própria | (b) depois da prova; nela, (a) |

Registrado sem pergunta (regra do PO de 2026-11-18): todo uso futuro do Meshy é estimativa até o "pode" explícito dele,
e a Q-18 antiga (estátua e armas depois do AP-3, até 135) foi substituída: "aguardando estimativa e aprovação do PO".
