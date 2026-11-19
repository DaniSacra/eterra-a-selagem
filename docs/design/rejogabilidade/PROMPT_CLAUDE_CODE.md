# DIRETRIZ PARA O GAME DIRECTOR — CLAUDE CODE

Você é o Game Director de **Crônicas de Eterra: A Selagem**. O PO aprovou a **direção geral** de aprofundar a rejogabilidade do Guerreiro por meio da integração de Dons, bênçãos, Salmos, Emeth, Forja, Encantos, materiais, descobertas e escolhas de caminho.

## PRIMEIRO: auditar, não implementar
1. Verifique `git status`, branch e HEAD; leia o histórico recente. Não sobrescreva alterações locais.
2. Leia integralmente `docs/design/warrior_spec.md`, `docs/design/po_directive_guardian.md`, `docs/design/hades2_sistemas.md`, `docs/backlog.md`, decisões D-xx e cânone verdadeiro (`../dungeon-rpg/docs/mundo/canone.md`, se acessível).
3. Inspecione código/dados/UI/saves/testes para Maestria, Dons, Devoção, Bênçãos, Elos, Salmos, Juramentos, Emeth, Ômegas, ultimate, `RunMap`, `Rooms`, `Reward`, Provação, Altar, lojas, Hub e Forjador.
4. Para cada ideia deste pacote, classifique JÁ EXISTE, PARCIAL, PROPOSTA, CONFLITO ou DEPENDE DO CÂNONE, citando arquivos e decisões. Identifique sobreposição entre Encantos e `WeaponUpgrade`/Lapidação já estudada, e entre novos recursos e custos existentes.
5. Entregue uma especificação integrada, plano de migração de saves e backlog de pequenas entregas. **Pare e peça aprovação antes de implementar.**

## REGRAS INEGOCIÁVEIS
- Somente o Guerreiro. Nada de desenvolver os outros heróis.
- Emeth é a arma única. Não adicionar inventário de armas equipáveis.
- Combate ofensivo; sem bloqueio, aparo ou escudo. Preservar ataques com pés plantados, cancelamento por esquiva e game feel aprovado.
- Preservar sistemas existentes, seeds determinísticas, HUD, controles e saves.
- Regra-mãe: **Dom define o herói. Bênção define a partida. Salmo transforma o poder.**
- Não criar um baralho de tarô: a árvore de Dons já cumpre essa função.
- Não inventar anjos, personagens, títulos de Elun, símbolos sagrados ou eventos do cânone sem aprovação. Não representar Deus como NPC.
- Não implementar tudo de uma vez, não criar sistemas redundantes e não solicitar assets pagos sem autorização.

## DIREÇÃO APROVADA EM PRINCÍPIO
A. **Dons:** manter árvore conectada, Maestria e Devoção; estudar Fragmentos de Memória como custo opcional, somente se agregar decisão real.
B. **Forja:** Temperar, Refinar e Despertar Emeth; materiais Prata Antiga, Brasas da Forja, Fragmentos Esmeralda (nomes provisórios). Uma espada, diferentes aprimoramentos. Descobrir ferramentas perdidas do Forjador para desbloquear funções.
C. **Encantos:** modificações TEMPORÁRIAS dos golpes de Emeth durante a descida, inspiradas no papel dos Martelos de Dédalo. Estudar primeiro reutilizar a Lapidação/WeaponUpgrade já proposta no repo. Criar 6 ideias, testar exclusões e sinergias.
D. **Bênçãos:** encontro em duas etapas: escolha entre 2 entidades, depois entre até 3 bênçãos elegíveis da escolhida. Preservar famílias, raridades e Elos. Estudar Discernimento (reroll, prévia, substituição limitada) como controle progressivo do RNG.
E. **Mapa:** portas com escolhas realmente distintas (bênção vs vida, Encanto vs material, elite vs loja, Salmo vs bênção). Auditar `RunMap.Kind`/`Reward` antes de adicionar novas salas.
F. **Economia:** ouro de run separado de recursos persistentes. Cada material precisa de fonte, gasto exclusivo, frequência, custos, teto, persistência e utilidade no endgame.

## ENTREGÁVEIS DA PRIMEIRA ETAPA
- Diagnóstico auditado e matriz de compatibilidade com decisões D-xx.
- Arquitetura de sistemas e economia.
- Catálogo inicial de 6 Encantos e proposta de 4 identidades mecânicas de bênção, sem canonizar entidades.
- Wireframes e fluxo de UI de Dons, Forja, encontro celestial e mapa.
- Simulação de distribuição de recompensas e custo de progressão.
- Backlog por slices com testes, riscos e aprovações pendentes.
- Lista explícita do que NÃO implementar.

**Critério de sucesso:** cada descida permite uma build distinta, cada bifurcação cria trade-off, cada material tem função e o Guerreiro continua prazeroso sem depender de upgrades.

Não alterar o repo nesta fase. Apresente proposta ao PO e aguarde aprovação.
