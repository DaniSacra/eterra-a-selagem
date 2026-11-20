# Ciclo visual 2026-11-20 (pedido do Daniel, parecer da direção artística sobre o pacote ASelagem_revisao_2026-11-19.zip)

Texto colado pelo Daniel em 2026-11-20, guardado como veio. Ele responde às perguntas abertas dos benchmarks:
cor do estilizado sobe (teste só no Salão nesta build), chão em duas escalas (juntas discretas entre lajes vizinhas,
variação larga por manchas de luz, material e marcos), hub com luz localizada nas estações, anjos só com o selo.

Game Director de Crônicas de Eterra: A Selagem, consolide o próximo ciclo visual a partir da revisão do último push e do pacote ASelagem_revisao_2026-11-19.zip.

PARECER DA DIREÇÃO ARTÍSTICA

O último commit encontrado na branch arpg-3d foi e51f21e. Ele documenta o benchmark de estilo. O commit anterior, 98781f4, documenta o benchmark de layout. As capturas do ZIP são da build 4098f7a, com o visual STYLIZED, Forward+ e câmera Perto na maior parte das cenas. Portanto, use o ZIP como base visual para os comparativos. As propostas dos dois documentos ainda precisam ser testadas no jogo.

A Câmara do Selo, o Jardim e a Ponte B são nossas referências internas mais fortes. A Câmara tem a melhor hierarquia de cor e luz. O Jardim tem um marco reconhecível pela silhueta. A Ponte B comunica a travessia e o espaço de luta pela própria arquitetura. A Emeth em esmeralda, o ouro velho das elites, o violeta de Morvath e o retrato ilustrado do Guerreiro no Livro já dão identidade a Eterra.

Use Hades II como referência de hierarquia visual em combate e clareza nas escolhas, SWORN para compor salas que se distinguem pela forma e Ravenswatch para dar personalidade aos lugares e personagens pela ambientação. Resolva a aparente divergência entre o chão calmo de Hades II e a variedade de SWORN em duas escalas: juntas e textura discretas entre lajes vizinhas, com manchas de luz, mudanças de material e marcos arquitetônicos visíveis no conjunto da sala.

1. SALÃO DAS CATACUMBAS. PRIMEIRO TESTE DE ACABAMENTO

Execute juntos ENV-HB1 e ENV-HB2 no Salão. Nas capturas 01 e 02, a grade escura das juntas tem quase o mesmo peso visual dos contornos dos inimigos. Aproxime o valor das juntas ao das lajes vizinhas, devolva azul-petróleo à pedra e use a luz âmbar para marcar áreas da sala. Mantenha os contrastes grandes entre setores. Depois, experimente ENV-HB3 no mesmo cenário, com bordas de sombra e elementos de primeiro plano nos cantos. Preserve a visão do Guerreiro, dos inimigos, dos avisos e das saídas.

Use as métricas do benchmark para diagnosticar o resultado. A decisão de espalhar o tratamento deve vir do comparativo em combate, com a mesma seed e o mesmo enquadramento. Deixe o teste restrito ao Salão nesta build.

2. SANTUÁRIO DA VIGÍLIA. FOCO NA ESTAÇÃO E NO PERSONAGEM

Nas capturas de chegada, o portal domina e a praça inteira tem iluminação parecida. Faça uma passada de luz localizada na Forja e no Livro de Ahk. A Forja deve ler pelo fogo, pela bancada e pelo forjador. O Livro deve ler pela mesa, pelo manuscrito e pela luz de leitura. Na passagem entre as estações, deixe a praça e os caminhos visíveis. Use o mesmo princípio para o Vendedor e a Árvore de Dons quando o teste funcionar. O portal deve continuar fácil de encontrar no quadro de chegada.

Valide a plaqueta da tecla e do verbo com um jogador, tanto no hub quanto na descida. O 4098f7a acrescentou Pegar, Comprar e Entrar, mas o código esconde essa plaqueta para o robô. A captura automatizada, sozinha, não confirma que o aviso funciona no fluxo normal.

3. ENCONTRO DOS ANJOS, BÊNÇÃOS E FORJA. PRIMEIRO LOTE DE INTERFACE

O Livro já tem uma linguagem visual própria. A página ilustrada do Guerreiro é a melhor referência de acabamento. Já as telas de encontro e de Bênçãos têm cartas altas, com espaço sobrando, e a Forja usa duas páginas amplas para informação curta.

- Anjos e Bênçãos: dê presença ao selo existente de cada anjo. Na tela seguinte, mantenha as três opções comparáveis de relance, com nome, ação afetada, efeito e valor. Quando houver troca, mostre claramente o que entra e o que sai. Use os selos enquanto o visual dos anjos estiver em aberto.
- Forja: coloque a Emeth como peça principal. Organize posto atual, melhoria seguinte, custo e saldo perto da ação de forjar. Use a própria espada e os materiais existentes para compor a página.
- Compêndio e Dons: para o lote seguinte, use a imagem da criatura ou de um Dom descoberto como detalhe da entrada selecionada. Na árvore, diferencie equipado, disponível e selado pela forma ou pelo ícone, além da cor. Preserve a leitura rápida de custo e pré-requisitos.
- Pausa, Juramentos, Configurações, Músicas e fim de partida: unifique foco, tipografia e ações com os componentes aprovados no primeiro lote. Em vitória e derrota, dê prioridade ao que o jogador trouxe e à próxima ação. Na Ponte A, confira se o contador de golpes disputa espaço com inimigos ou barras de vida e teste aproximá-lo do HUD.

4. CENÁRIOS E COMBATE. MANTENHA O QUE JÁ FUNCIONA

- Criptas A/B: as lajes funerárias já ajudam a comunicar o tema, mas os dois quadros ainda se parecem. Use luz e posição para que a efígie ou o sarcófago dominem uma vista e o conjunto de nichos e urnas domine a outra. Trabalhe com os marcos disponíveis.
- Fendas e Ponte: dê profundidade ao espaço além da borda com arcos, rocha e correntes. Preserve o contorno das travessias e dos buracos. Nas Runas, mantenha a grade de repouso discreta e reserve o âmbar forte para a ativação.
- Fonte, Loja, Altar e Provação: confira se o objeto e a recompensa são reconhecíveis na câmera Perto. Priorize a leitura da Fonte, que fica na borda da captura, e a distinção entre a escolha do Altar e o risco da Provação.
- Inimigos e Morvath: preserve o ouro velho e os sinais de ataque já aprovados. Depois da mudança de materiais, confira Besteiro, Feiticeiro e Sacerdote juntos e as quatro fases de Morvath. Use a Câmara do Selo como referência de separação entre piso, personagem e efeito. Mantenha a câmera Perto como base do teste e compare com Longe nos casos de borda, travessia e área segura.

ENTREGA DO CICLO

Integre o teste do Salão, a passada de iluminação na Forja e no Livro e a revisão das telas de Bênçãos e Forja numa build jogável. Use os assets atuais, com zero créditos de Meshy, e mantenha o F7 disponível para comparação. Agrupe as propostas de layout que mudem dimensões, cobertura ou posição de portas para decisão própria, com evidência de jogo.

Entregue o SHA, um antes/depois do Salão em combate, um trecho de chegada ao Santuário até uma estação e capturas das escolhas e da Forja a 720p e 1080p. Use Forward+ e faça uma checagem em Compatibility nas cenas de combate alteradas. Atualize o backlog reaproveitando os IDs ENV-HB, UI-HB, BH e RS-C1.

A decisão após essa build é se o tratamento do Salão pode ser replicado. Ele passa se o olho encontrar primeiro o Guerreiro e o perigo, e se a sala continuar reconhecível pela arquitetura e pela luz.
