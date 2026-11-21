# PROMPT MESTRE — Game Director / Claude Code

Você é o Game Director de **Crônicas de Eterra: A Selagem**. Recebe neste ZIP um pacote de arte **Santuário da Vigília Rev. 02**. Leia **todos** os arquivos deste pacote antes de implementar, com esta precedência: `03_07_DIRECAO_ARTISTICA_E_IMPLEMENTACAO.md` > `02_planta_superior_medidas.png`/`.svg` > `01_pintura_conceitual_isometrica.png` > painel/referências. **Implemente o redesign no código do jogo, não somente documentação.** Use o backlog existente e inclua tarefas com dependência, responsáveis e evidências. Não faça commit ou push sem autorização expressa do proprietário.

## Mudanças decididas pelo proprietário

- **O Guerreiro não nasce no meio do hub**. O spawn após derrota e carregamento de save é no **canto sudeste**, ocupando o espaço anteriormente previsto como expansão futura. A escada chega pelo lado sul/sudeste. O Portal fica ao norte, muito legível no campo de visão, e a caminhada da primeira parte do hub incentiva conhecer o Livro, Fonte e demais estações. O selo de retorno é acolhedor e secundário.
- Existe uma **sexta estação física**, o **Alquimista**, entre o Vendedor e a Forja, na lateral oeste. Sua presença é direção de arte aprovada neste pedido, **mas a mecânica de Alquimia ainda não existe** e está em choque com a recomendação anterior do estudo de Ofícios. Reservar footprint/visual/área de chegada sem inventar receitas, NPC de lore ou bônus.
- Manter **Portal, Forjador, Vendedor, Árvore de Dons, Livro de Ahk e Fonte do Leão** nas funções e geografia descritas no caderno. A Fonte é decorativa. O hub tem ~50×32 m, câmera yaw 35°, tilt 30°, FOV 24°, distância 37–54 m, herói 2,5 m.
- O pátio precisa ser **bom de caminhar**, com caminhos em anel, espaço central tranquilo, visibilidade do Portal do spawn e deslocamento alvo <=4 segundos entre estações (medir e iterar com a velocidade real).
- Tom cristão aventureiro; Yah é Deus, luz de Elun, emblema do leão. Sem cruzes, deuses, disco solar estilizado, estrelas ou ícones não canônicos. Calcário morno, sombra petróleo, ouro velho, âmbar, Portal verde-pálido; mais acolhedor que as catacumbas.
- Manter F7 `CLASSIC` íntegro. Padrão estilizado do jogo sem introduzir dependências de assets pagos.

## Antes de tocar no código, leia no repositório

1. `CLAUDE.md`, `scripts/game/hub_look.gd`, `HubPlan`, cenas e hub UI/StationSign/HubPanel, arquivos de save e fluxo morte/carregamento, câmera/Feel/VisualProfile.
2. `docs/design/oficios/README.md`, `02_visao_e_grafo.md`, `07_npcs_e_encomendas.md`, `09_receitas_e_ferramentas.md`, `15_prototipo.md`, `22_decisoes_pendentes.md`.
3. `docs/art/visual_review.md`, backlog de hub e referências internas. Preserve a lógica de **Dom permanente / Bênção da run / Salmo transformação**, os saves e a economia existentes.
4. Revise o HEAD atual (o pacote foi preparado usando `52fcbb1`), não presuma que o repositório parou.

## Sequência de execução

**A. Greybox funcional (P0)**. Construir/alterar planta com objeto central da fonte, footprint de seis estações, spawn sudeste e Portal norte. Manter caminho acessível em cada versão de câmera. Corrigir caminhos de spawn da morte e do save. Evidência: mapa navegável, coordenadas convertidas corretamente do referencial local à moldura do HubPlan.

**B. Circulação e enquadramento (P0)**. Captura real do spawn com Portal visto do canto, Fonte e ao menos dois pontos de interesse. Medir tempos entre TODAS as duplas de estações, caminho até Portal e rotas alternativas; onde exceder 4s, ajustar posição/passeio em vez de acelerar o herói arbitrariamente. Deixar ~4–5 m no eixo principal e >=3 m secundário. Um humano deve conseguir circular sem ver setas de HUD.

**C. Pintura 3D (P1)**. Lajes com variação suave, calcário morno, sombra petróleo, portal verde-pálido, luz âmbar na Forja/Loja/Livro, árvore em pedra/ouro, Alquimista de verde dessaturado, penhasco e bruma. Coloque a maior riqueza nas bordas; preserve luz na Fonte e o caminho central calmo. Garantir portais, placas E e NPCs não ocluídos. Respeitar a câmera e as regras do `HubLook` e `CLASSIC`.

**D. Estações (P1)**. Portal/Forja/Vendedor/Dons/Livro com leituras funcionais e visuais; Alquimista como placeholder de arte. Sem criar um sexto sistema de progressão independente. Articule visualmente: ferramentas da Forja -> pedidos do Vendedor -> Livro de Ahk -> descidas, como laço proposto em Ofícios. Não marque propostas como entregues.

**E. Evolução visual (P2)**. Aplique somente as cinco mudanças descritas em `03_07`, cada uma acionada por estado persistente real; se não houver feature de gameplay, mantenha a peça inativa/oculta com feature flag.

## Obrigatório na entrega

- Build integrada, testes de navegação/save/interação e comparação `CLASSIC`/`STYLIZED`; nenhuma mudança de lore não aprovada.
- Captura em jogo da câmera real na entrada sudeste, norte/Portal e pelo anel; plano superior marcado com coordenadas resultantes, colisões e portas.
- Close de cada estação, reconhecimento de longe, plano de luz e lista de peças **Essenciais** versus **Clima** para qualquer asset novo.
- Relatório honesto: o que mudou, o que não mudou, o que é só cenário reservado e o que depende de decisões Q-OF.
- Backlog priorizado com IDs e critérios de aceite. Não gastar créditos Meshy; não fazer push sem autorização explícita.

**Regra permanente do diretor de arte:** NUNCA solicite ao ChatGPT somente a pintura. Para **qualquer material visual novo**, exija (1) pintura da câmera real, (2) planta superior com medidas aproximadas, posições de portas, herói, obstáculos, cobertura e interações, (3) lista de **ESSENCIAL** vs **CLIMA**, (4) notas de luz, colisão e leitura visual, (5) entrega lado a lado para reconstrução na Godot com mínima adivinhação.
