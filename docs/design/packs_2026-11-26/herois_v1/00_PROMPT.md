# Eterra — Redesign dos heróis V1
## Prompt para Claude Code
Implemente o design descrito neste pacote no repositório DaniSacra/eterra-a-selagem. Este pacote substitui propostas anteriores conflitantes de controles e kits. Leia o HEAD atual, confirme branch (referência anterior arpg-3d), git status, instruções do projeto e testes antes de editar. Não sobrescreva alterações alheias. Não faça push nem compre assets sem autorização.

Prioridade: Guerreiro e Maga. Preserve modelos, animações, direção pintada à mão, progressão roguelike, salas, saves, Santuário e sistemas existentes. Não implemente Ladina/Paladino agora. A arquitetura deve permitir heróis com recursos, passivas e habilidades contextuais distintos, sem impor quantidade fixa de habilidades.

Ordem: inventário do código e baseline de testes; inputs e abstração de ações; Guerreiro; Maga; Dons; Bênçãos/HUD/saves; testes e documentação. Consulte HeroDef, ComboTree, ArcaneKit, Arcane, Celestial, BoonState, HeroLoadout, GiftState, UltDef/UltCharge, InputMap, HUD e geradores de recursos. Confirme nomes e caminhos atuais antes de modificar.

Valores explicitamente aprovados: Guerreiro 40 HP, 30 Mana inicial (também capacidade base 30, interpretação a validar); Maga 30 HP, 50 Mana; controles abaixo; passivas automáticas; especiais consumidores; preservar golpe carregado atual do Guerreiro no novo Especial. Demais números são baseline de protótipo, não balanceamento definitivo. Registre decisões e divergências, não invente mudanças silenciosas.

Ao terminar entregue resumo por sistema, arquivos alterados, testes executados/resultados, riscos, decisões pendentes e instruções de teste manual. Não declare testes aprovados sem executá-los.
