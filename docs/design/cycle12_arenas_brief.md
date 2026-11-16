<!-- Pedido do Daniel de 2026-11-16, colado na sessão, guardado na íntegra para o game-director. As cinco imagens
conceituais (feitas por IA, docs/steam-ia.md) ficam só locais em docs/art/ref/cycle12_maps/: 01 prancha "Mapa de
Catacumbas em Eterra" (vista com herói, escala de salas pequena/média/comprida, oito miniaturas, módulos), 02 salão com
fenda no meio ("Catedral Gótica Sobre o Abismo Místico"), 03 árvore com pontes sobre o abismo ("Diorama Gótico no Abismo
Violeta"), 04 jardim da árvore com sarcófagos ("Catacumba Gótica com Árvore Encantada"), 05 quatro faixas: fendas, árvore,
ponte, cripta ("Catacumbas Góticas: Quatro Reinos Perdidos"). Daniel, ao colar: "acrescentar no seu backlog e priorizar.
no final me fala o que o diretor do jogo sugere." Ainda não aprovado para implementação. -->

# CRÔNICAS DE ETERRA: A SELAGEM
# CICLO 12: DIVERSIDADE DE ARENAS, EXPLORAÇÃO E COMBATE ESPACIAL

## MISSÃO DO GAME DIRECTOR

Acione o agente `game-director` para analisar, priorizar e planejar o próximo ciclo de desenvolvimento de Eterra.

Estamos construindo uma vertical slice premium da Fase 1, Catacumbas de Morvath.

O projeto já possui combate, progressão de salas, inimigos, dons e uma arena exclusiva para o chefe Morvath, chamada Câmara do Selo.

O problema que queremos resolver agora é a repetição dos ambientes.

Não queremos que o jogador entre em salas que parecem cópias umas das outras, apenas com inimigos diferentes.

Queremos que cada ambiente produza uma experiência distinta de movimentação, combate, exploração e descoberta.

Estou anexando imagens conceituais de novas arenas.

Use essas imagens como referência de direção artística e geometria, não como mapas técnicos exatos.

## 1. PRINCÍPIO FUNDAMENTAL

As salas NÃO devem ter todas o mesmo tamanho.

A geometria de cada sala deve ser determinada pela experiência desejada.

Queremos:

- Salas pequenas e claustrofóbicas.
- Salas grandes e abertas.
- Salas estreitas e compridas.
- Salas assimétricas.
- Salas com múltiplas plataformas.
- Salas com buracos intransponíveis.
- Salas com árvores e obstáculos centrais.
- Salas com passagens alternativas.
- Salas com diferenças de altura visual.
- Salas com áreas perigosas temporárias.
- Salas com elementos destrutíveis.
- Salas que exijam deslocamento antes do combate.

O jogador deve sentir que está descendo por catacumbas antigas, atravessando lugares diferentes.

Não estamos criando um survivor com uma arena infinita.

Estamos criando um roguelite de ação e exploração inspirado na qualidade de combate de Hades II, mas com a identidade própria de Eterra.

## 2. PRESERVAR A CÂMARA DO SELO

A Câmara do Selo de Morvath foi recentemente redesenhada e aprovada como base.

Ela é uma arena circular exclusiva do chefe.

Não reutilizar sua geometria nas salas comuns.

Não modificar a luta de Morvath neste ciclo, salvo correções necessárias para regressões comprovadas.

Preservar as quatro fases, a narrativa da Selagem e a conclusão do combate.

## 3. OITO ARQUÉTIPOS DE AMBIENTE

Avalie os oito conceitos abaixo e as imagens anexadas.

### MAPA 01: SALÃO DAS FENDAS

Formato: grande e irregular.

Elemento principal: um abismo atravessa parte do piso.

Características:
- Plataformas de pedra.
- Buracos no chão.
- Passagens laterais.
- Pontes e corredores de ligação.
- Vista do abismo violeta.
- Arquitetura parcialmente destruída.

Gameplay:
- O jogador precisa contornar as fendas.
- Projéteis podem atravessar alguns espaços abertos.
- Inimigos terrestres precisam encontrar caminhos válidos.
- O dash não pode atravessar abismos sem uma habilidade específica.
- Nenhum inimigo pode surgir em uma área inacessível.

Dificuldade: média.

### MAPA 02: JARDIM DAS RAÍZES MORTAS

Formato: largo e assimétrico.

Elemento principal: uma árvore antiga e petrificada.

Características:
- Tronco monumental.
- Raízes atravessando o piso.
- Cristais espectrais.
- Pequenas ruínas.
- Vegetação morta.
- Passagens em torno da árvore.

Gameplay:
- O tronco bloqueia movimentação.
- Raízes maiores criam obstáculos.
- O jogador pode usar a árvore como cobertura.
- Inimigos precisam contornar o tronco.
- Projéteis devem respeitar a cobertura quando apropriado.

A árvore deve ser visualmente impressionante, mas não esconder permanentemente o protagonista.

Dificuldade: média.

### MAPA 03: PONTE DOS CONDENADOS

Formato: muito comprido e estreito.

Elemento principal: plataformas ligadas por pontes sobre um abismo.

Características:
- Duas ou três áreas principais.
- Pontes de pedra.
- Correntes monumentais.
- Arcos góticos.
- Abismo profundo.
- Passagens laterais ocasionais.

Gameplay:
- O jogador precisa administrar o posicionamento.
- Inimigos podem pressionar as entradas das pontes.
- Evitar situações de bloqueio inevitável.
- Combates mais intensos devem ocorrer em plataformas com espaço suficiente.
- Não colocar o jogador em uma ponte estreita com ataques impossíveis de evitar.

Dificuldade: alta.

### MAPA 04: CRIPTA DOS ESQUECIDOS

Formato: pequeno e compartimentado.

Elemento principal: sarcófagos e pilares.

Características:
- Túmulos.
- Colunas.
- Pequenos corredores.
- Velas.
- Nichos funerários.
- Ruínas e pedras quebradas.

Gameplay:
- Obstáculos bloqueiam ataques.
- O jogador utiliza cobertura.
- Inimigos corpo a corpo precisam contornar objetos.
- Inimigos à distância procuram linhas de tiro.
- A quantidade de inimigos deve ser compatível com o espaço disponível.

Dificuldade: média.

### MAPA 05: CÂMARA DAS RUNAS INSTÁVEIS

Formato: médio, circular imperfeito.

Elemento principal: inscrições mágicas perigosas.

Características:
- Piso ritualístico.
- Runas antigas.
- Círculos de energia.
- Cristais corrompidos.
- Pequenos altares.
- Colunas danificadas.

Gameplay:
- Algumas runas ativam periodicamente.
- O chão indica a área perigosa antes do efeito.
- O jogador precisa se reposicionar.
- Os efeitos não devem ocupar toda a arena simultaneamente.
- As runas não devem esconder avisos dos ataques inimigos.

Dificuldade: alta.

### MAPA 06: BIBLIOTECA SEPULTADA

Formato: comprido, em L ou irregular.

Elemento principal: uma biblioteca antiga destruída.

Características:
- Estantes tombadas.
- Livros e pergaminhos.
- Colunas.
- Corredores.
- Escombros.
- Salas parcialmente conectadas.

Gameplay:
- Estantes criam cobertura.
- Alguns objetos podem ser destruídos.
- Destruição pode abrir novas passagens.
- Inimigos precisam recalcular caminhos quando necessário.
- A sala deve incentivar deslocamento e exploração.

Dificuldade: média.

### MAPA 07: RESERVATÓRIO DAS ALMAS

Formato: grande e aberto, com ilhas de pedra.

Elemento principal: água sobrenatural.

Características:
- Água rasa.
- Plataformas secas.
- Canais.
- Pontes.
- Ruínas submersas.
- Reflexos azul-espectrais.

Gameplay:
- Água rasa pode alterar a velocidade de movimento.
- O efeito deve ser claramente indicado.
- O jogador deve conseguir identificar as áreas secas.
- Inimigos devem respeitar as mesmas regras de terreno quando fizer sentido.
- Não criar lentidão permanente sem possibilidade de reação.

Dificuldade: alta.

### MAPA 08: SANTUÁRIO DESMORONADO

Formato: amplo e assimétrico.

Elemento principal: um antigo salão sagrado em ruínas.

Características:
- Arcos monumentais.
- Vitrais quebrados.
- Altares.
- Pilares destruídos.
- Plataformas.
- Grandes áreas de combate.

Gameplay:
- Combates com inimigos de diferentes funções.
- Cobertura parcial.
- Espaços amplos para esquiva.
- Boa visibilidade.
- Possibilidade de encontros especiais e guardiões.

Dificuldade: baixa a média.

## 4. TAMANHOS VARIÁVEIS

Não utilize um único valor global de largura e comprimento para todas as salas.

Crie categorias de tamanho, mas permita dimensões específicas por arena.

Como referência inicial, sujeita à validação do Game Director:

- Pequena: aproximadamente 18 a 24 metros na dimensão principal.
- Média: aproximadamente 25 a 36 metros.
- Grande: aproximadamente 37 a 52 metros.
- Comprida: aproximadamente 45 a 65 metros no eixo principal.

Esses números são propostas iniciais, não exigências rígidas.

O tamanho final deve considerar:

- Velocidade do Explorador.
- Alcance da câmera.
- Dash.
- Alcance das armas.
- Quantidade de inimigos.
- Tempo de travessia.
- Obstáculos.
- Pontos de entrada e saída.
- Ritmo dos encontros.

Não escale todas as salas proporcionalmente.

Uma ponte pode ser longa e estreita.

Uma cripta pode ser compacta.

Um santuário pode ser largo e aberto.

## 5. DESLOCAMENTO E CÂMERA

Este é um requisito essencial.

Queremos que o jogador sinta que está atravessando um ambiente real.

Em salas grandes ou compridas:

- A câmera acompanha o Explorador.
- Não é necessário mostrar todo o cenário simultaneamente.
- Novas áreas são reveladas durante o deslocamento.
- O cenário pode conter passagens, escadas e corredores.
- A câmera não deve atravessar paredes ou revelar áreas inacessíveis de forma confusa.

Em salas pequenas:

- A câmera deve enquadrar adequadamente o combate.
- Não aproximar excessivamente a ponto de prejudicar a visão.

Preservar a identidade isométrica e a legibilidade de combate.

Evitar mudanças bruscas de zoom.

Se necessário, propor limites de câmera específicos por mapa.

## 6. OBSTÁCULOS COM FUNÇÃO REAL

Não basta colocar objetos decorativos.

Classifique os obstáculos em:

A. Decoração sem colisão.

B. Obstáculos sólidos que bloqueiam movimentação.

C. Obstáculos que bloqueiam projéteis.

D. Obstáculos destrutíveis.

E. Abismos intransponíveis.

F. Terrenos com efeitos temporários.

Cada objeto deve ter comportamento consistente com sua aparência.

Exemplos:

- Tronco de árvore: bloqueia movimentação e projéteis.
- Sarcófago: bloqueia movimentação.
- Coluna: bloqueia movimentação e linha de tiro.
- Abismo: não pode ser atravessado por movimento normal.
- Água rasa: pode reduzir velocidade.
- Runa: aplica perigo temporário após aviso.

Evitar colisões invisíveis.

## 7. NAVEGAÇÃO E INTELIGÊNCIA DOS INIMIGOS

Este é um dos maiores riscos técnicos.

Antes de implementar:

- Audite a navegação atual.
- Verifique como os inimigos perseguem o Explorador.
- Verifique ataques à distância.
- Verifique o sistema de spawn.
- Verifique o dash.
- Verifique como a câmera lida com obstáculos.

Requisitos:

- Inimigos não podem atravessar paredes.
- Inimigos terrestres não podem caminhar sobre abismos.
- Não podem ficar permanentemente presos.
- Inimigos à distância precisam respeitar a linha de tiro.
- Spawns devem ocorrer em áreas válidas.
- O jogador precisa ter uma rota para concluir a sala.
- A saída deve permanecer acessível.
- Obstáculos destrutíveis precisam atualizar a navegação quando necessário.

Não implementar o sistema inteiro sem testes de navegação.

## 8. REGRAS DE COMBATE

Preservar a filosofia atual de Eterra:

- Poucos inimigos simultâneos.
- Ataques legíveis.
- Esquiva importante.
- Inimigos com funções diferentes.
- Dificuldade baseada em padrões e posicionamento.

O limite global de 20 inimigos simultâneos continua válido.

Entretanto, cada mapa deve ter seu próprio orçamento de inimigos.

Exemplo:

Uma cripta pequena pode comportar quatro a seis inimigos.

Um santuário amplo pode comportar oito a doze.

Uma ponte estreita deve usar menos inimigos simultâneos e evitar bloqueios injustos.

Não usar a quantidade máxima apenas porque o sistema permite.

## 9. VARIAÇÕES E REJOGABILIDADE

Queremos evitar a repetição entre partidas.

Proponha um sistema com:

- Oito arquétipos de arena.
- Duas ou três variações por arquétipo.
- Posições alternativas de obstáculos.
- Diferentes entradas e saídas.
- Variações de iluminação e decoração.
- Diferentes composições de inimigos.
- Sementes reproduzíveis.

Não implementar geração procedural totalmente aleatória se isso prejudicar a qualidade dos mapas.

Prefira arenas desenhadas manualmente com variações modulares controladas.

Regras:

- Evitar repetir a mesma arena-base em salas consecutivas.
- Distribuir a dificuldade espacial ao longo da descida.
- Não colocar as arenas mais complexas nas primeiras salas.
- Manter lojas, fontes e áreas de descanso com tratamento próprio.
- Manter a Câmara do Selo exclusiva de Morvath.

## 10. PROGRESSÃO DA FASE 1

O Game Director deve revisar como essas arenas se encaixam na descida pelas Catacumbas.

Não queremos simplesmente adicionar oito salas fixas em sequência.

Queremos uma seleção variada de ambientes a cada partida.

Propor:

- Quantidade de encontros por partida.
- Distribuição de arenas pequenas, médias e grandes.
- Progressão de dificuldade.
- Momentos de descanso.
- Guardiões.
- Recompensas.
- Loja.
- Caminho até Morvath.

A estrutura deve valorizar exploração sem tornar as partidas excessivamente longas.

Não expandir a duração total sem justificar a mudança.

## 11. DIREÇÃO ARTÍSTICA

Usar as imagens anexadas como referência visual.

Manter:

- Fantasia sombria estilizada.
- Arquitetura gótica.
- Pedra azul-acinzentada.
- Abismos violetas.
- Magia esmeralda.
- Fogo âmbar.
- Correntes monumentais.
- Estátuas encapuzadas.
- Banners vermelhos.
- Ruínas antigas.
- Atmosfera misteriosa.

Evitar:

- Salas genéricas.
- Repetição excessiva do mesmo piso.
- Plataformas todas quadradas.
- Geometria sem função.
- Iluminação excessivamente uniforme.
- Obstáculos que escondem o Explorador.

As imagens são conceitos artísticos, não screenshots da Godot.

O objetivo é aproximar a implementação 3D da qualidade das referências, respeitando o orçamento técnico do jogo.

## 12. ARQUITETURA REUTILIZÁVEL

Antes de criar os oito mapas, defina uma estrutura que permita adicionar novos ambientes facilmente.

Avalie componentes como:

- ArenaDefinition.
- ArenaBounds.
- ArenaHazard.
- ArenaObstacle.
- SpawnZone.
- CameraZone.
- ExitZone.
- ArenaVariant.

Esses nomes são sugestões, não exigências.

Priorize integração com a arquitetura existente.

Evite criar sistemas paralelos ou duplicar funcionalidades.

Não refatore componentes estáveis sem necessidade.

## 13. AGENTES

O Game Director decide a divisão do trabalho.

Sugestão:

Art Director:
- Comparar as imagens com o jogo.
- Definir identidade visual.
- Avaliar composição e legibilidade.

Environment Artist:
- Construir cenários e módulos.
- Criar obstáculos.
- Configurar materiais e iluminação.

Gameplay Engineer:
- Implementar navegação.
- Colisões.
- Terrenos especiais.
- Spawns.
- Integração com o combate.

UI/UX Designer:
- Avaliar avisos de perigo.
- Clareza das saídas.
- Comunicação dos efeitos de terreno.

QA/Performance:
- Validar caminhos.
- Testar colisões.
- Testar câmera.
- Medir desempenho.
- Capturar evidências.

Game Director:
- Priorizar.
- Coordenar.
- Aprovar decisões técnicas.
- Atualizar o backlog.
- Planejar a entrega.

## 14. PROPOSTA DE IMPLEMENTAÇÃO INCREMENTAL

Não implemente automaticamente os oito mapas em uma única entrega.

O Game Director deve decidir o escopo viável.

Minha sugestão inicial é:

Primeira entrega:
- Salão das Fendas.
- Jardim das Raízes Mortas.
- Cripta dos Esquecidos.
- Câmara das Runas Instáveis.

Segunda entrega:
- Ponte dos Condenados.
- Biblioteca Sepultada.
- Reservatório das Almas.
- Santuário Desmoronado.

A primeira entrega deve validar a arquitetura e as regras de navegação antes de ampliar o conteúdo.

Se houver riscos técnicos importantes, reduza o escopo e registre as justificativas.

## 15. TESTES OBRIGATÓRIOS

Validar:

- Entrada e saída de cada arena.
- Navegação do Explorador.
- Dash próximo a obstáculos.
- Dash próximo a abismos.
- IA contornando obstáculos.
- Inimigos à distância.
- Spawns válidos.
- Rotas de saída.
- Câmera.
- Colisões.
- Obstáculos destrutíveis.
- Efeitos de terreno.
- Performance.
- Ausência de travamentos.

Criar testes com sementes reproduzíveis.

Testar situações em que o jogador tenta atravessar obstáculos ou fica cercado.

Não considerar o mapa aprovado apenas por renderizar corretamente.

## 16. EVIDÊNCIAS

Criar:

`docs/gallery/cycle12_maps/`

Para cada arena implementada, salvar:

- Screenshot completo sem personagens.
- Screenshot com Explorador.
- Screenshot de combate.
- Screenshot mostrando o obstáculo principal.
- Screenshot de entrada e saída.
- Comparativo com a referência artística.

Capturar imagens reais da Godot.

Não gerar screenshots fictícios.

Se possível, gravar vídeos curtos de travessia.

Precisamos enxergar a sensação de deslocamento, não apenas o cenário parado.

Criar:

`docs/gallery/cycle12_maps/ART_REVIEW.md`

Registrar:

- Diferenças em relação à referência.
- Geometria.
- Dimensões.
- Mecânicas.
- Navegação.
- Legibilidade.
- Desempenho.
- Problemas conhecidos.

## 17. ATUALIZAÇÃO DO BACKLOG

O Game Director deve criar ou atualizar os itens de variedade de arenas em:

`docs/backlog.md`

Cada item deve ter:

- ID.
- Prioridade.
- Responsável.
- Justificativa.
- Critérios de aceite.
- Dependências.
- Evidências.
- Estado.

Distinguir propostas de itens aprovados.

Não considerar as oito arenas automaticamente aprovadas para implementação.

## 18. DECISÃO E EXECUÇÃO

Quero que o Game Director faça primeiro uma avaliação da proposta.

Ele deve:

1. Ler o estado atual do repositório.
2. Examinar as imagens anexadas.
3. Verificar a arquitetura existente.
4. Avaliar o impacto no combate.
5. Identificar riscos.
6. Definir o escopo do próximo ciclo.
7. Atualizar o backlog.
8. Registrar as decisões de design.
9. Coordenar a implementação do escopo selecionado.
10. Executar testes.
11. Capturar evidências.
12. Fazer commit e push na branch `arpg-3d`.

Não utilizar Meshy nem serviços pagos.

Não solicitar testes intermediários.

Não iniciar a implementação da Fase 2.

Não alterar a Câmara do Selo sem necessidade comprovada.

Se uma decisão exigir mudar profundamente a direção aprovada, registre-a como pendência em vez de presumir aprovação.

## OBJETIVO FINAL

Transformar as Catacumbas de Morvath em um ambiente variado, vivo e memorável.

O jogador deve sentir que está explorando um lugar real, não apenas repetindo arenas com inimigos diferentes.

Cada mapa deve criar decisões próprias de movimentação, posicionamento e combate.

A variedade de tamanho, formato, obstáculos e perigos deve contribuir para a rejogabilidade.

O Game Director é responsável por decidir o escopo, priorizar as entregas e garantir que a qualidade da Fase 1 continue sendo nossa principal meta.
