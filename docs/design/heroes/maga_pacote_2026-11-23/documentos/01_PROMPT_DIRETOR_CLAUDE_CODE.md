# Prompt para o Diretor do Jogo / Claude Code

Atue como **Diretor do Jogo** de *Crônicas de Eterra: A Selagem*.
Leia este pacote e atualize o backlog e o plano de implementação da **Maga** como segundo herói jogável.

## Objetivo

Implementar a primeira versão jogável da Maga sem quebrar a arquitetura atual do projeto. A personagem deve entrar no fluxo do Santuário, save, Maestria, Dons, bênçãos, hub e descidas.

## Decisão de direção já aprovada

A Maga **não** deve seguir a interpretação genérica anterior. A direção visual correta e prioritária é:

- **traços asiáticos/leste-asiáticos**, tomando como base a foto da modelo
- **cabelo curto preto**
- **identidade de Maga de Fogo**
- **traje com capa marfim e roupas azul profundo**
- **bastão/cajado de duas pontas**, com emissão de fogo/luz nas extremidades
- linguagem visual **dark fantasy painterly**, alinhada com o restante de Eterra e próxima do acabamento mais pintado à mão

Use a arte `01_maga_aprovada_principal.png` como **âncora visual principal**.

## Filosofia de progressão

Manter a regra já estabelecida para Eterra:

- **Santuário**: evolução compartilhada entre heróis
- **Herói**: Maestria, Dons e armas evoluem por herói
- **Run / Descida**: bênçãos, encantos, salmos e build são temporários

## Entregas sugeridas

### M1 — Maga jogável (prioridade máxima)
Entregar a primeira versão funcional da Maga, com:
- seleção do herói
- corpo/identidade da Maga
- kit base com 5 ações
- passiva exclusiva de Ressonância
- integração com HUD, save e fluxo de run
- compatibilidade mínima com o sistema atual de bênçãos

### M2 — Progressão da Maga
- árvore de Dons própria
- Maestria própria
- supremas iniciais
- integração melhor com bênçãos e possíveis adaptações por herói

### M3 — Rejogabilidade e expansão
- armas alternativas
- refinamento de VFX/animações
- desbloqueio narrativo mais elaborado
- melhor integração com Codex e Livro de Ahk

## Pedido principal

1. Analise o estado atual do projeto
2. Quebre a Maga em tarefas claras de backlog
3. Priorize junto do restante do projeto
4. Aponte dependências e riscos
5. Sugira a forma menos arriscada de implementação incremental

## Critério central de aceite para M1

A Maga deve ser jogável do início ao fim da descida das Catacumbas, com identidade de combate claramente diferente do Guerreiro, preservando a fantasia de **Maga de Fogo** com controle de área, marcas e explosões.
