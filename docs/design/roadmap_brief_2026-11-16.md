# Pedido do Daniel: revisão executiva e próximos ciclos (2026-11-16)

Colado pelo Daniel depois do commit `87ba686`. É a base do planejamento em `docs/design/roadmap_plan.md` e do `docs/backlog.md`.
Resumo fiel das partes normativas (o texto completo está na conversa da sessão):

- **Auditoria primeiro**: ler CLAUDE.md, backlog, decisões, QA, galerias; o código e as evidências mais recentes
  prevalecem para dizer o que está feito; decisões aprovadas não são trocadas em silêncio.
- **Objetivo**: concluir uma Fase 1 que o jogador queira repetir. Cada melhoria precisa servir a diversão, clareza do
  combate, variedade, progressão, arte ou técnica. Não iniciar a Fase 2.
- **Hipóteses da revisão externa** (validar, não são bugs confirmados): A exploração (sensação de catacumbas
  interligadas), B árvore e raízes influenciam o combate?, C a escuridão da Cripta atrapalha a leitura?, D Morvath:
  transições, impacto, justiça e legibilidade antes de novos ataques, E descida curta, F som.
- **Ciclos propostos** (a ordem pode mudar com justificativa):
  - **C12c Qualidade da experiência atual**: telemetria humana se houver, atiradores, guardiões, leitura na Cripta,
    obstáculos do Jardim, Fendas, ritmo das transições, câmera e navegação comprovadas, transições de Morvath. Não
    rebalancear só pelo robô; separar correções comprovadas, hipóteses que pedem teste humano e decisões do Product Owner.
    Aceite: nenhum bug crítico de navegação, nenhuma sala impossível de concluir, avisos legíveis, câmera funcional,
    testes aprovados, evidências atualizadas.
  - **C13 Progressão e rejogabilidade**: descida de 10 salas e Morvath na 11 (manter a curta para teste), distribuição
    de arenas, economia de recompensas, dons e sua evolução, loja, ouro, curva até Morvath, partida de cerca de 10 a 13
    min. "Não copiar mecanicamente o sistema de Hades II; usar o benchmarking para entender princípios."
  - **C14 Arenas II**: Santuário Desmoronado, Ponte dos Condenados, Câmara das Runas Instáveis (faixas e ladrilhos, não
    círculo); Biblioteca e Reservatório só depois. Cada arena precisa de uma decisão de combate que as outras não têm.
  - **C15 Som e polimento**: ataques, Emeth, esquiva, inimigos, avisos sonoros, música de combate e de Morvath,
    ambiência, volume. Sem material sem licença, sem serviço pago.
- **Limites**: teto de 20 inimigos de pé; dificuldade por combinação, posição, padrões, terreno, reação, progressão.
  Morvath: não redesenhar; não mexer em vida e dano sem evidência. Câmara do Selo só do chefe.
- **Backlog**: manter a estrutura e o histórico; por item: ID, ciclo, prioridade P0 a P3, descrição, problema,
  valor para o jogador, aceite, dependências, responsável, estado, evidência.
- **Métricas**: gameplay, exploração, técnica e experiência humana; nunca inventar; separar real de simulação.
- **Evidências**: capturas e vídeos reais da Godot por ciclo (`docs/gallery/cycleNN/`); vídeo com som para o som; partida
  completa para progressão.
- **Regras**: pode analisar, planejar, delegar, implementar o próximo ciclo priorizado, testar, capturar, commit e push
  no `arpg-3d`. Sem Meshy, sem serviço pago, sem Fase 2, sem apagar evidências, sem pedir testes intermediários, um ciclo
  por vez, não iniciar o ciclo seguinte sozinho. A entrega fica pronta para o teste final do Daniel.
- **Entregáveis do diretor antes de implementar**: A diagnóstico, B roadmap, C backlog priorizado, D aceite, E plano de
  testes, F plano de evidências, G decisões pendentes (só as que exigem o Daniel), H próxima execução e por quê.
- **Relatório final** em português: estado (versão, commit, ciclos), planejamento, entrega (o que, quem, testes,
  problemas), evidências (caminhos), próxima decisão. Qualidade da experiência acima de quantidade de conteúdo.
