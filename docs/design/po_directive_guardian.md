# Diretriz do Product Owner: aprovação da arquitetura do Guardião (2026-11-16)

> **2026-11-16, correção do PO**: o primeiro herói é **o Guerreiro** (não o Explorador nem o Guardião). Especificação canônica: `docs/design/warrior_spec.md`; onde este arquivo diz Explorador/Guardião para o herói, vale o Guerreiro (o texto abaixo fica como histórico).


Colada pelo Daniel depois do commit `10944b1` (auditoria e `docs/design/guardian_spec.md`). Manda sobre a especificação
onde as duas divergirem. Este arquivo resume as decisões; o texto inteiro está na conversa do dia.

## Objetivo
- Só o Explorador/Guardião até a experiência dele estar no nível buscado. Nenhum herói novo.
- Game feel: referência Hades II. Identidade, talentos, evolução e descobertas: referência Ravenswatch. Aprender, não copiar.
- Duas prioridades absolutas, que são **critérios de qualidade**, não itens de backlog: (1) game feel (resposta, impacto,
  combos fluidos, habilidades fortes, prazer em derrotar inimigos); (2) excelência visual (personagens, animação, efeitos,
  cenário, identidade). Nada de crescer em conteúdo enquanto combate ou apresentação estiverem abaixo do padrão.

## Regra central (preservar em arquitetura, interface e documentação)
**DOM DEFINE O HERÓI. BÊNÇÃO DEFINE A PARTIDA. SALMO TRANSFORMA O PODER.**

## Sistemas aprovados
- **Maestria**: progressão permanente e individual; XP guardado mesmo na derrota; destrava possibilidades, Dons e
  ultimates; **não** deixa o herói muito mais forte a cada partida.
- **Dons**: talentos exclusivos do Guardião, destravados pela Maestria, escolhidos e equipados antes da descida, mudam o
  estilo de combate. Catálogo com Devoção (D-58).
- **Bênçãos**: as três cartas de hoje; comum, rara, épica, lendária; temporárias; combinam diferente conforme os Dons.
- **Salmos**: descobertas especiais que transformam um Dom, uma Bênção ou a combinação; mudança mecânica e visual
  perceptível; temas dos Salmos bíblicos respeitando o cânone; assinatura musical original.

## Decisões sobre a especificação
| ID | Decisão do Daniel | O que muda na spec |
|---|---|---|
| D-50 | **Opção A**: só o texto do jogador muda ("dom" da partida vira "Bênção"); classes `Boon`, ids, cartas, dados e registro ficam | nada no código além de `text_pt.tres` quando entrar |
| D-54 | Carga pela Magia gasta nos Ômegas (regra A) **aprovada**; duas ultimates, uma escolhida antes da partida **aprovado**. **A U-2 muda**: as duas têm de ser ofensivas e satisfatórias; a 2ª pode controlar área, mas fere e parece poderosa (ex.: área de luz que acerta várias vezes, mexe na posição dos inimigos e deixa o Guardião seguir atacando). Nada de ficar parado dentro de uma proteção | U-2 "Muralha de Luz" (defensiva) **recusada**; o `gameplay-engineer` apresenta duas propostas ofensivas com controle (`docs/design/ultimate_u2_proposals.md`); nomes ainda pendentes |
| D-56 | **P-A, Brilho da Emeth**, provisória | os 2 de Magia por finalizador não são número definitivo: validar em teste |
| D-57 | 20 níveis aprovados; 25 a 30 partidas é hipótese, não obrigação; desbloqueios frequentes e interessantes no começo; priorizar o que transforma o jogo, não bônus numérico; XP guardado na derrota; compatível com saves antigos | rever a ordem do catálogo para pôr Dons que mudam a ação nos primeiros níveis |
| D-58 | Catálogo com Devoção aprovado, **mas começar pequeno**: cerca de seis Dons excelentes, cada um com efeito claro, impacto perceptível, sinergia com Bênçãos, retorno visual quando preciso, critério de teste e de balanço | os 20 ficam como planejamento; a E2 entrega o conjunto pequeno |
| D-59, D-60 | Temas bíblicos com música e efeitos originais aprovados; Sentinela, Abrigo, Pastor e Rocha como boa proposta, sujeita a validar os efeitos. **Não** fazer quatro de uma vez: primeiro Dons e Bênçãos funcionando juntos, depois **um Salmo completo** como prova de conceito, que surpreenda | a E4 começa com um Salmo |
| D-61 | Planejar a descida de 10 salas antes de Morvath; as salas a mais com variedade, eventos, escolhas e evolução; manter os modos curtos de teste | sem mudança de lugar (E3), com o aceite de variedade |

**Ficam pendentes** (não aprovadas por tabela): nomenclatura (D-48 nome do herói, D-49, D-55 nomes das ultimates, nomes
dos Dons, de Devoção e dos Salmos), origem narrativa das Bênçãos (D-51), raridades e multiplicador (D-52, D-53), texto do
Compêndio (D-62), Juramentos (D-63) e todo ponto de cânone aberto. Nenhuma recomendação da spec vale por padrão.

## Outras decisões
Sem equipamento tradicional; sem troca de arma; a Emeth é a identidade do Guardião; o Elo fica, adaptado às Bênçãos; os
outros três heróis fora do escopo; sem Fase 2; sem cânone novo sem aprovação; sem Meshy nem serviço pago sem
autorização; nada de implementar todos os sistemas de uma vez.

## Execução
- E1 a E6 continuam como planejamento, com **entregas pequenas e verificáveis**. Ordem de produto: E1 game feel e visual,
  E2 Maestria e Dons, E3 Bênçãos, E4 Salmos, E5 exploração, E6 balanceamento. Mudança de dependência técnica só justificada.
- E1: auditar e atuar só sobre lacunas demonstráveis, sem refazer o que os ciclos anteriores validaram.
- **Primeira execução autorizada: só a primeira entrega priorizada** (a E1a, `docs/backlog.md` seção 6). Não começar a
  seguinte sozinho. Não declarar o Guardião pronto porque os testes passam.

## Como avaliar (cada entrega relevante)
Testes automáticos são obrigatórios para regressão, mas **não provam diversão**. Para cada entrega, responder com
evidência (capturas, vídeos, medidas):
- **Game feel**: comandos respondem na hora? ataques têm impacto? dá para encadear? habilidades dão prazer? alguma
  animação ou pausa atrapalha?
- **Visual**: o poder impressiona? efeitos na direção de arte? herói e inimigos legíveis? animação adequada? parece jogo
  comercial acabado?
- **Progressão** (a partir da E2): muda alguma decisão? há combinações interessantes? dá vontade de outra build? o
  desbloqueio recompensa? há algo novo a descobrir?
Teste humano é a validação, ao fim de uma versão inteira, nunca a cada ajuste.

## Resultado buscado
O jogador escolhe o Guardião porque gosta de como ele luta, sente prazer em mover, atacar e usar a Emeth, quer melhorar a
própria mão, destrava Dons que ampliam possibilidades, encontra Bênçãos diferentes a cada descida, descobre combinações e
Salmos, e quer outra partida mesmo depois de vencer Morvath. "Nossa prioridade não é fazer Eterra crescer rapidamente. É
fazer Eterra ficar extraordinariamente bom de jogar."
