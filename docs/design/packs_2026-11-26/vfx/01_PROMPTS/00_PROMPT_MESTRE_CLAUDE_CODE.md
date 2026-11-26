# PROMPT MESTRE — GAME DIRECTOR / VFX EXCLUSIVOS

Game Director, este pacote é a **diretriz de direção artística dos VFX** de Crônicas de Eterra: A Selagem. O PO mantém **outra frente independente responsável por salas, arquitetura, portas e decoração**. Não conflitar, não assumir posse de cenas do cenário nem duplicar backlog.

## Missão
Dar ao combate sensação de **pintura viva**, com pinceladas de energia, textura artesanal, matérias que se rompem, bordas imperfeitas e silhuetas claras. Referências de princípios: Hades II (leitura), SWORN (assinatura das habilidades), Ravenswatch (coesão e profundidade), Ember & Blade (impacto e gesto pictórico). Criar linguagem autoral de Eterra; não copiar artes, modelos ou sinais alheios.

## Fontes de verdade e triagem
1. Primeiro leia o HEAD `arpg-3d`, `CLAUDE.md`, `docs/art/art_direction.md` (inclusive seção 2.1.1), `docs/art/vfx_pass_spec.md`, `docs/gallery/vfx_pass/ART_REVIEW.md`, `docs/art/stylized_spec.md`, `docs/qa/qa_2026-11-26b.md` e os scripts/shaders mencionados. Os documentos de 20/11 NÃO provam que o problema continua em 26/11.
2. Monte uma tabela **efeito | script/shader atual | status HEAD (confirmado em código + captura) | situação histórica | ação | proprietário**. Marque `FEITO`, `MELHORAR`, `NÃO CONFIRMADO` ou `FORA DE ESCOPO`. Evite refazer item concluído.
3. Preserve todas as mudanças já aprovadas: sem néon na estocada, esmeralda separada de Morvath, giro como pincelada em vez de anel fechado, partículas não redondas, herói legível, tinta de contorno sutil.
4. Confronte o novo sistema de Guerreiro/Maga (24/11) com instruções antigas: um Supremo por arma, Guerreiro sem Fúria, Maga com Convergência Elemental. Nomes obsoletos como Voragem são referências HISTÓRICAS, não escopo de implementação sem validação.

## Responsabilidades
- `technical-artist`: shaders, formas, materiais, otimização visual.
- `gameplay-engineer`: apenas ligação visual no evento real quando necessária (RewardShaft, contatos). Nenhuma mudança de regras.
- `combat-feel-director`: comprovar sincronia do efeito com hitbox/dano/avisos; não alterá-los.
- `art-director`: comparar capturas e vídeos contra diretriz, aprovar P0/P1.
- `environment-artist` / `room-designer`: não receber tarefas de cenário deste pacote.

## Sequência obrigatória
### Fase A — Auditoria de estado e evidência
- Capturar no HEAD atual, 1080p Alta STYLIZED e 720p Baixa, câmera do jogo com HUD, mesma seed/ação para antes e depois. Inspecionar Forward+ e Compatibility; verificar F7.
- Incluir: 3 golpes e finalizador, Corte Veloz, especial, Círculo, Ômegas disponíveis, Supremo da Emeth; Maga: tiros/elementos/Convergência se implementados; 7 famílias de Bênçãos; inimigos comuns e elites; Morvath fases 1–4; recompensas, loja e fonte.
- Basear prioridades no que realmente se vê. Capturar em 3 instantes: ANTECIPAÇÃO → CONTATO → DISSIPAÇÃO. Não usar apenas foto do pico luminoso.

### Fase B — P0: legibilidade e bugs de VFX
- Verificar se fachos `RewardShaft` já estão ligados ao evento de sala vencida, loja e fonte. Se não, corrigir usando a especificação existente; não criar outro facho concorrente.
- Verificar e corrigir apenas se ainda presentes: `Fx.contact` com miolo branco saturado / pontas em cruz, faixa branca vertical de impacto, aro de `glint` cobrindo o guerreiro, partículas acima do ombro, excesso de luz no flash de Morvath.
- Conferir cores do herói, dos inimigos e do chefe, limites de luminância e a cor do Salmo/Elo; respeitar `art_direction.md` do HEAD e não trocar paleta aprovada.
- Medir regressão de Shader-compilation no primeiro encontro de cada bioma (QA 21/11 relatou grandes travas): evitar novos shaders/canais sem justificativa e medir cold/warm.

### Fase C — Vertical slice ARTÍSTICO, 6 assinaturas
1. **Emeth / combo / impacto**: pincelada que nasce da lâmina e estalo duro de contato; verde da Emeth, núcleo escuro, borda marfim-menta; sem sabre néon nem estrela em cruz.
2. **Guerreiro / especial / Supremo Corte do Juízo**: meia-lua real versus fenda do Supremo, formas distintas, sem disco chapado.
3. **Maga / 3 estados**: fogo = línguas e brasas; frio = facetas e farpas; raio = zigue-zague quebrado. Na Convergência, uma fase de cada vez; nunca esmeralda/violeta.
4. **Famílias angelicais**: Chama, Geada, Luz, Vigília, Véu, Maré e Marca com gramática própria por material, contorno e dinâmica; não apenas sete recolorações do mesmo `Fx.ring`.
5. **Inimigos / Morvath**: magia dos mortos com borda suja e miolo escuro; Morvath com alma rasgada e violeta reservado; distinguir os efeitos dos ataques do jogador em cinza.
6. **Coleta**: facho de cima, volume baixo, repouso persistente e retirada no pickup; nunca usar coluna de elite para recompensa.

### Fase D — Prova em gameplay
- Não gerar sprites a partir de recortes da pintura de referência. Recriar movimento com shaders, meshes e traços de pincel compatíveis com a câmera.
- Testar cada assinatura com vídeo de 3 a 5 s em 30/60 fps; manter mesma câmera, HUD, seeds e ações em antes/depois. Uma cena com 12 inimigos, uma com chefe na fase 4, outra com 5 itens de loja.
- Validar leitura em 720p e preto e branco: herói versus Morvath, dois tipos de Bênçãos, perigo versus recompensa. Checar que o gesto gráfico está sincronizado com o quadro de dano.
- Comparar desempenho na GPU dedicada 1080 Alta e integrada 720 Baixa; custo de compilação cold/warm; sem aumento significativo dos objetos renderizados.

## Regras duras
- NÃO tocar RoomLayout, geometria, posicionamento das portas, fundo de arenas, colisão de cenário, hazard gameplay, personagens canônicos, esquema de câmera, dano, consumo de recursos, tempos de aviso, alcance, hitboxes nem seed.
- Não introduzir símbolos de cruz, auréola solar ou emblemas religiosos externos. Leão é identidade de Eterra. Sem terror/gore.
- Não usar o violeta de Morvath na Maga, no Salmo ou no Elo.
- Não criar um Supremo selecionável: no estado atual é um por arma; o Guerreiro usa Corte do Juízo e a Maga Convergência Elemental. Confirme pelo HEAD.
- Renderizar em cena real sem bloom exagerado. Preservar `CLASSIC`, F7 e reversibilidade. Sem Meshy. Sem push sem autorização.

## Entregáveis ao PO (um pacote auditável)
1. Inventário e evidências do HEAD (`confirmado` vs `histórico`).
2. Capturas antes/depois de cada efeito aprovado e vídeos com as três fases.
3. Tabela de assinatura visual (forma, cor, textura, timing, dispersão).
4. Métricas de luminância, matiz, leitura em 64/100% e grayscale, FPS e shader cold/warm.
5. Logs de testes, SHA inicial/final, arquivos tocados, risco de regressão, rollback.
6. Parecer do art-director listando as decisões que ainda precisam de aprovação do PO.

Implemente P0 somente após diagnóstico do HEAD. Consolide o primeiro vertical slice; não espalhe os novos efeitos para todas as famílias até termos uma amostra aprovada visualmente.
