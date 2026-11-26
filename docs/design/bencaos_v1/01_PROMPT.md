# Prompt para Claude Code

Implemente exclusivamente o redesign dos sete anjos e suas bênçãos conforme os arquivos deste pacote, no repositório DaniSacra/eterra-a-selagem. Confira a branch ativa e o estado do worktree antes de editar; referência de design: arpg-3d. Preserve alterações locais.

1. Audite data/angels, data/boons, tools/make_data.gd, scripts/core/boon.gd, scripts/game/combat.gd, sorteio, HUD e testes. Identifique IDs, tags, pré-requisitos, recursos e compatibilidade de saves.
2. Implemente a camada universal de bênçãos por ação sem mudar a implementação nativa das ações. Use adaptadores/eventos de bênção e preserve a distinção entre Q, E, esquiva e Supremo, inclusive ataques carregados.
3. Migre o catálogo ativo para os 63 poderes especificados, mantendo IDs existentes quando semanticamente compatíveis. Não apague dados antigos necessários a saves. Desative no sorteio conteúdo fora do escopo, sem destruir recursos.
4. Implemente elegibilidade, raridades, bloqueio de slots e fallback de encontros conforme 02_REGRAS.md. Atualize descrições, HUD e feedback de bênçãos reaproveitando artes existentes.
5. Execute os testes existentes e novos critérios de aceite. Relate arquivos alterados, mapeamento de IDs, resultados reais e pendências. Não declare teste visual realizado sem executar.

PROIBIDO: alterar controles, armas, atributos base, mana base, habilidades nativas, animações de heróis, árvore de Dons, Videira, Forja, progressão, IA de inimigos ou design de salas. Não implementar Supremo celestial independente: neste ciclo, a bênção de Supremo modifica a ativação existente. Não criar companheiros, Duos, laboratório ou novos heróis. Se um efeito exigir alteração fora da camada de bênçãos, reporte o bloqueio e preserve o comportamento atual. Não improvise redesign.

As novas regras de status e crítico descritas são locais às bênçãos, não novos sistemas nativos dos heróis. Valores são provisórios e configuráveis.
