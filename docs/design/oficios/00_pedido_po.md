# Pedido do PO: Ofícios e Descobertas do Santuário (2026-11-20)

O Daniel colou a diretriz "Ecossistema de Progressão, Ofícios, Descobertas e Interdependência entre Mecânicas" (23
seções) e pediu que o Game Director escolha os melhores agentes para analisá-la. Etapa só de estudo e planejamento:
nada é implementado, só documentação em `docs/design/oficios/`; ao fim, recomendações ao PO e espera da aprovação.

Resumo do pedido (o texto inteiro está na conversa de 2026-11-20 e é a fonte):
- Camada nova, nome provisório "Ofícios e Descobertas do Santuário": recursos achados nas descidas viram ferramentas
  (ex.: picareta), componentes (ex.: óleo do Alquimista para o Forjador), descobertas (manuscritos ligados aos Dons) e
  abrem possibilidades em outros sistemas. Rede de dependências entre sistemas também fora do combate, com vários
  caminhos, sem ciclos nem bloqueios.
- Coleta física, por recompensa de sala ou híbrida (avaliar ritmo, controles, UI, risco de "simulador de mineração").
- Identidade econômica por região/bioma real; o mapa pode mostrar oportunidades; geração pela semente, garantias
  mínimas, sem farming abusivo nem softlock.
- NPCs por especialidade (Forjador, Artesão, Alquimista/Ervanário, Guardião dos Manuscritos, Mercador), sem duplicar os
  existentes; encomendas e relações entre NPCs; crafting enxuto (ferramentas, componentes, melhorias, consumíveis,
  descobertas).
- Economia: não criar moedas à toa; o ouro continua da descida; matriz econômica por recurso.
- Integração com Maestria, Dons, Devoção, Forja, Encantos, Bênçãos (sem virar item fabricado), Salmos, Juramentos,
  mapa, Livro de Ahk e Compêndio.
- Progressão vertical e horizontal (preferência pela horizontal); orçamento de complexidade do primeiro capítulo.
- Propostas próprias (5 interações, 5 cadeias, 5 descobertas de revisita, 3 fontes alternativas, 3 anti-grind, 3
  horizontais, 3 riscos), cada uma com problema, funcionamento, sistemas, diversão, custo, rejogabilidade,
  dependências, riscos e recomendação.
- Protótipo vertical (sugestão: "A Jornada da Primeira Picareta"), arquitetura sobre o código existente (saves em três
  espaços, migração, semente, integridade), backlog em épicos e histórias com aceite, roadmap A/B/C, experiência das
  primeiras descidas, métricas (metas separadas de medidas), 15 entregáveis, decisões pendentes.
- Restrições: só o Guerreiro; sem armas novas; sem mudar o combate de Emeth; sem NPC canônico nem mudança em Ahk sem
  aprovação; nada de simulador de sobrevivência; não implementar nada nesta etapa.
