# ETERRA — REDESIGN ARTÍSTICO COMPLETO DAS SALAS

## Diretriz do Product Owner

Quero redesenhar artisticamente todas as salas de Crônicas de Eterra: A Selagem. As referências anexadas são conceitos originais de direção de arte, e as imagens de Sworn são inspiração de **riqueza, composição, contraste, diversidade e leitura**, não modelos para copiar. O jogo continua com identidade própria: fantasia sombria ilustrada em 3D isométrico, pedra azul-petróleo, ouro antigo, esmeralda de Emeth, mistério ancestral e corrupção violeta. Cada bioma pode ter paleta, vegetação, arquitetura, silhueta e iluminação distintas. Não homogeneizar as salas com um único shader.

**IMPORTANTE:** As 18 imagens de `conceitos/` são propostas artísticas, NÃO screenshots do Godot, NÃO mapas de colisão, NÃO blueprint 1:1. Confrontar cada proposta com o layout, gameplay, câmera e código reais. Os painéis `prancha_*.png` apresentam a visão de conjunto. A imagem original de Sworn enviada pelo PO não deve ser copiada literalmente.

## Guardrails

1. Trabalhar na branch `arpg-3d`, ler `CLAUDE.md`, `docs/art/stylized_poc_plan.md`, `docs/art/art_direction.md`, `docs/art/art_polish_backlog.md`, `docs/arte/estetica.md`, `docs/gallery/rooms_2026-11-18/LEIAME.md`, código real de `RoomLayout`, `CatacombHall`, `RoomMood`, shaders e câmeras antes de implementar.
2. Preservar navegação, mapa da descida, progressão, conexões, seed determinística, spawn, IA, animações, combate, esquiva, hitboxes, telegraphs, raio-x, câmera de gameplay e boss. Não colocar props bloqueando áreas de combate. Garantir rotas livres, visibilidade e espaço para o Guerreiro se movimentar.
3. **Meshy: saldo 500; gasto autorizado ZERO.** Não consumir créditos, nem contratar serviços pagos. Reutilizar modelos, materiais, meshes existentes, geometria procedural, decals, shaders, iluminação e assets licenciados disponíveis. Qualquer custo futuro requer estimativa e aprovação explícita do PO.
4. O visual CLASSIC deve permanecer reversível até a aprovação; `STYLIZED` pode ser desenvolvido por bioma/arena. Evitar misturar arte nova e velha na mesma sala.
5. A arte deve ser boa na câmera real de gameplay. Imagens de conceito têm enquadramento mais cinematográfico e **não autorizam** mudar a câmera. Avaliar capturas de combate com HUD e ataques.
6. Não copiar personagens, símbolos, interfaces, arquitetura singular ou marcas de Sworn. Os símbolos do mundo devem seguir o cânone de Eterra; estandartes de leão são apenas uma hipótese visual a validar no art direction, não lore automaticamente aprovada.
7. Novas interações ou perigos ambientais não estão autorizados por este redesign. Propor separadamente ao room-designer, com telegraph, impacto também nos inimigos e aprovação antes de mudar gameplay.

## Linguagem visual comum

- **Geometria**: pedras esculpidas e lascadas, arcos e pilares assimétricos, pisos de grandes placas legíveis, silhuetas fortes, poucos adereços bem posicionados. Variar altura aparente nas bordas, sem interferir com colisão ou câmera.
- **Materiais**: aparência hand-painted com variação de valor e cor, bordas iluminadas, juntas profundas, desgaste controlado; evitar plástico, ruído excessivo, repetição óbvia de texturas e efeito 'brinquedo'.
- **Luz**: pools de luz quente, preenchimento frio, acentos por bioma; sombras coloridas, não pretas. Herói e telegraphs devem permanecer distinguíveis.
- **Foco**: cada sala precisa de um marco arquitetônico identificável na primeira olhada, um ponto de entrada/saída claro e um centro de combate limpo.
- **Narrativa ambiental**: inscrições, estátuas, estandartes, ruínas e objetos contam a história de Eterra sem poluir a jogabilidade.
- **Performance**: medir RTX 1080p Alta e iGPU 720p Baixa; LOD, batching, culling e instancing quando couber; sem custo de pós-processamento desnecessário.

## Redesign das 18 vistas

As variantes A/B são propostas de composição para as salas existentes, não criação automática de novos nós na descida.

### 01 — Salão das Catacumbas (`01_salao_catacumbas.png`)
A entrada solene na descida: grande salão de pedra azul, arcos em profundidade, dois conjuntos de estátuas e estandartes, braseiros âmbar, círculo de piso discreto, portal esmeralda ao fundo. Estabelece a identidade do mundo. Manter piso central amplo, rotas e câmera. O portal não pode parecer um efeito neon plano.

### 02 — Cripta dos Esquecidos A (`02_cripta_A.png`)
Cripta funerária íntima, sarcófagos baixos, velas agrupadas, névoa azul-fria e nichos nas paredes. Narrativa de memória e abandono. Sarcófagos apenas nas margens ou em posições aprovadas pelo room-designer; não bloquear esquiva.

### 03 — Cripta dos Esquecidos B (`03_cripta_B.png`)
Cripta ritual de arquitetura vertical: figura de pedra velada, urnas, pequenas escadas e uma luz verde distante. Diferenciar da A pela monumentalidade e pelo vazio central, não apenas pela cor.

### 04 — Salão das Fendas A (`04_fendas_A.png`)
Ruína sobre abismo violeta, plataformas de pedra quebrada, correntes e arcos fraturados. Fendas profundas legíveis como bordas do cenário, nunca armadilhas implícitas sem telegraph. Centro seguro e aberto.

### 05 — Salão das Fendas B (`05_fendas_B.png`)
Fenda cósmica maior: arco circular parcialmente destruído, fragmentos suspensos e vórtice violeta distante. A energia fica no plano de fundo; não mascarar projéteis nem avisos vermelhos.

### 06 — Jardim das Raízes Mortas A (`06_jardim_A.png`)
Bosque subterrâneo corrompido, árvore antiga com raízes retorcidas, folhas vermelhas, fungos e água turquesa, ruínas engolidas pela vegetação. Criar contraste orgânico com as catacumbas. Raízes decorativas não podem interferir com navegação.

### 07 — Jardim das Raízes Mortas B (`07_jardim_B.png`)
Pátio de pedra invadido por raízes, pequenas cascatas e vegetação bioluminescente. Centro de combate mais amplo e seco; iluminação azul/verde pontual e vermelho vegetal nas bordas. Evitar excesso de brilho verde.

### 08 — Santuário Desmoronado A (`08_santuario_A.png`)
Templo abandonado, estátuas encapuzadas, grandes arcos, faixas de luz dourada, estandartes envelhecidos, entulho e uma escadaria cerimonial ao fundo. Sensação de grandeza perdida. A área do guardião deve ficar legível.

### 09 — Santuário Desmoronado B (`09_santuario_B.png`)
Variante aberta para ruínas exteriores e céu crepuscular, arcos partidos e plataforma circular. Contraste com o santuário interior. Não assumir mudança real de horário ou céu sem validar coerência com a descida subterrânea.

### 10 — Ponte dos Condenados A (`10_ponte_A.png`)
Ponte monumental sobre abismo azul, arcos de sustentação, correntes, tochas e colunas. A composição longitudinal guia o jogador; a largura funcional precisa respeitar o combate existente.

### 11 — Ponte dos Condenados B (`11_ponte_B.png`)
Ponte parcialmente desabada com pilares e passarelas ao fundo, neblina e lanternas suspensas. Variação de ritmo visual, sem introduzir buracos jogáveis não existentes.

### 12 — Câmara das Runas Instáveis A (`12_runas_A.png`)
Laboratório rúnico antigo, obeliscos com glifos esmeralda, mecanismo circular dourado e arcos no fundo. Runas de piso com traços claros, não parecidos com telegraphs de dano. As cores dos avisos de combate têm precedência.

### 13 — Câmara das Runas Instáveis B (`13_runas_B.png`)
Câmara rúnica danificada, cristal central luminoso, placas deslocadas, marcas de energia e pedestal. O cristal não pode ocultar inimigos; manter leitura do piso.

### 14 — Câmara da Provação (`14_camara_provacao.png`)
Arena ritual de julgamento: piso geométrico, estandartes antigos, arcos, braseiros e um símbolo central de Eterra. A atmosfera comunica desafio antes de qualquer texto. Não modificar regras da Provação.

### 15 — Altar Esquecido (`15_altar_esquecido.png`)
Recinto sagrado silencioso, estátua/figura velada, altar de pedra, luz dourada discreta e oferendas envelhecidas. Diferenciar de Provação pelo recolhimento e pela ausência de linguagem de combate. Respeitar o simbolismo e lore já aprovados.

### 16 — Loja (`16_loja.png`)
Posto de mercador sob velas e tecido vermelho envelhecido, prateleiras, frascos, mapas e objetos antigos. Layout acolhedor, mas ainda coerente com a fantasia sombria. Área de interação óbvia, props longe da circulação; preservar economia e UI.

### 17 — Fonte (`17_fonte.png`)
Pátio de repouso, fonte de pedra com bica de leão **se validada pelo cânone**, água azul-turquesa, musgo e flores discretas, luz de descanso. A fonte deve ser reconhecível em 1 segundo e não confundir com loja ou altar.

### 18 — Câmara do Selo / Morvath (`18_camara_do_selo_morvath.png`)
Grande arena de clímax: arcos de pedra destruídos, correntes, vazio violeta, selo circular no piso e portal cósmico distante. Morvath é o centro da narrativa, não o portal. A atmosfera evolui por fase sem esconder telegraphs, ataques e silhueta do chefe. Preservar lógica das quatro fases, câmeras, colisões e animações.

## Método de execução

### Etapa 0 — Auditoria e documentação
Mapear cada conceito para a sala real, listar o que já existe, o que pode ser reaproveitado e o que é inviável sem novas malhas. Criar `docs/art/room_redesign_matrix.md` com as 18 vistas, paleta, iluminação, ponto focal, props, riscos de legibilidade, esforço e dependências. Registrar decisões de lore/simbologia para aprovação do PO.

### Etapa 1 — Biblioteca artística compartilhada
Criar materiais/shaders reutilizáveis de pedra, metal, madeira, tecido, musgo, água e runas; presets de luz por bioma, sistema de props/decals/vegetação e critérios de densidade. Preservar `CLASSIC`. Não fazer um filtro global que deixe tudo igual.

### Etapa 2 — Produção em lotes
Lote A: Salão e Criptas. Lote B: Fendas e Pontes. Lote C: Jardins e Santuários. Lote D: Runas, Provação, Altar, Loja e Fonte. Lote E: Câmara de Morvath. Para cada lote, capturas antes/depois com mesma câmera, vídeo curto, testes e aprovação antes de avançar. Pode reorganizar a sequência conforme dependências reais, mas justificar.

### Etapa 3 — QA visual e técnico
Capturas 1080p e 720p, gameplay real com Guerreiro e inimigos, contraste de telegraphs, silhuetas, câmera, entradas/saídas, rota livre, FPS, VRAM, shader compile, regressão de testes e mapa da descida. Acessibilidade visual e leitura do combate são requisitos, não acabamento opcional.

## Entregas e aprovação

1. Matriz de redesign por sala com captura do estado atual e imagem conceitual correspondente.
2. Lista de mudanças por sala e de assets compartilhados, separando shader/prop/modelo.
3. Estimativa de esforço e riscos; **estimativa Meshy apenas se inevitável, nunca execução**.
4. Plano de lotes com commits pequenos, evidências, métricas e rollback.
5. Primeira implementação aprovada do Lote A antes de avançar para os demais.

**Não assumir que as 18 artes são viáveis 1:1.** A missão é entregar identidade visual comparável em qualidade e riqueza, adaptada à geometria e à jogabilidade reais de Eterra, com a aprovação do PO em cada lote.
