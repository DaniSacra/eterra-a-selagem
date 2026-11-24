# Eterra — Redesign dos heróis

Leia todos os arquivos deste pacote antes de implementar. Repositório DaniSacra/eterra-a-selagem, branch arpg-3d. Confira HEAD, git status e instruções locais. Não sobrescreva alterações alheias. Compare as especificações com os recursos e scripts atuais; código e dados atuais são fonte de verdade para atributos não explicitamente alterados. Documentação antiga de design deve ser reconciliada com os novos requisitos.

## Ordem de execução
1. Inventariar HeroDef, ComboTree, ArcaneKit, Arcane, KitFeed, HeroLoadout, GiftState, UltDef/UltCharge, controles, HUD, Dons, saves, Videira, Forja, Bênçãos, textos, geradores de dados e testes. Localizar consumidores de Fúria, Selos, Ressonância e Ômega.
2. Implementar infraestrutura compartilhada: um Supremo por arma, 12 Dons por herói, migração de sustento, compatibilidade de saves e terminologia.
3. Redesenhar Guerreiro conforme 01.
4. Redesenhar Maga conforme 02. Preservar modelos, animações e efeitos compatíveis.
5. Adaptar UI, Bênçãos, documentação e dados gerados. Não modificar Ladina/Paladino além de compatibilidade necessária.
6. Executar testes integrados ao final da implementação, conforme preferência do responsável pelo projeto. Não afirmar sucesso sem evidência. Corrigir regressões e apresentar relatório.

## Limites
Decisões aprovadas são requisitos. Números propostos são baselines configuráveis, não balanceamento validado. Não inventar decisões de design pendentes: registrar e solicitar aprovação quando necessário. Não gerar assets pagos nem fazer push sem autorização específica para esta entrega. Não adicionar barras de recurso. Preservar os três saves, progressão e Livro de Ahk.

Entregar relatório com arquivos alterados, decisões, testes executados, resultados, migrações, riscos e pendências. Ver 03 para critérios de aceite.
