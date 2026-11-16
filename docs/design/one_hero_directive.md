# Diretriz do Daniel: um herói definitivo (2026-11-16)

> **2026-11-16, correção do PO**: o primeiro herói é **o Guerreiro** (não o Explorador nem o Guardião). Especificação canônica: `docs/design/warrior_spec.md`; onde este arquivo diz Explorador/Guardião para o herói, vale o Guerreiro (o texto abaixo fica como histórico).


Colada pelo Daniel depois do commit `19af96b`. Base da auditoria e da especificação em `docs/design/guardian_spec.md`.

## Decisões aprovadas
1. Apenas o Explorador/Guardião será desenvolvido até atingir a qualidade desejada.
2. Não implementar os outros três heróis agora.
3. Game feel e excelência visual continuam sendo prioridades absolutas.
4. Maestria é progressão permanente individual do herói.
5. Dons são talentos exclusivos do herói, desbloqueados conforme a Maestria aumenta.
6. Bênçãos são as três opções oferecidas durante a descida, com raridades comum, rara, épica e lendária.
7. Salmos são descobertas especiais que transformam Dons, Bênçãos ou suas combinações.
8. Salmos podem usar temas dos Salmos bíblicos, com músicas e efeitos originais.
9. Sem equipamentos tradicionais nem troca de armas.
10. A Emeth continua sendo a arma do Explorador.
11. A Câmara do Selo e Morvath permanecem como conclusão da primeira região.
12. Não implementar a Fase 2 neste momento.

## Missão do Game Director nesta rodada
- Auditoria: o que se reutiliza, o que se adapta, o que exige migração de dados, o que afeta o balanceamento, as
  dependências, a compatibilidade com os saves.
- Atualizar `docs/design/benchmark_ravenswatch.md` com as decisões.
- Especificação completa do Explorador/Guardião: identidade de combate, kit inicial, passiva, duas opções de ultimate,
  progressão de Maestria, catálogo ou árvore de Dons, Bênçãos compatíveis, regras de raridade, combinação e Elo,
  Salmos e transformações, descoberta, Compêndio, progressão durante e entre partidas. Não inventar cânone; nomes e
  poderes como propostas para aprovação.
- Roadmap em entregas incrementais preservando o histórico, nesta prioridade: 1 game feel e qualidade visual,
  2 Maestria e Dons do Guardião, 3 Bênçãos e combinações, 4 Salmos e descobertas, 5 eventos e exploração,
  6 balanceamento completo da primeira região. Para cada entrega: escopo, dependências, agentes, aceite, testes,
  evidências.
- **Nesta rodada só auditoria, especificação e backlog.** Não implementar a nova progressão. Sem Meshy, sem serviço
  pago. Commit e push da documentação no `arpg-3d`.
- Objetivo: um Guardião tão bem desenvolvido que os próximos heróis possam ser construídos sobre uma arquitetura
  validada, sem sacrificar a identidade de cada personagem.
