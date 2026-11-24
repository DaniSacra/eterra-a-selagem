# Maga — Design v3 elemental

## Direção aprovada
Substituir o ciclo marcar/agrupar/detonar por combinações de fogo, gelo e eletricidade simultaneamente na mesma arma. Remover Selos e Ressonância exclusivos da Maga; não remover Marca das Bênçãos de Qeshael. Preservar modelo de cabelo curto preto, capa marfim, roupa azul profunda, bastão rúnico de duas pontas, Passo Etéreo e Suspensão Arcana. Sem barra adicional. Começar fraca e crescer durante a run. Paleta: fogo âmbar/laranja, gelo ciano, eletricidade branco/dourado; violeta reservado a Morvath e esmeralda à Emeth.

## Baseline real
Data/heroes/maga.tres e HeroDef: vida 30, Mana 50, duas esquivas, recarga 1 s, invulnerabilidade após dano 0,7 s, +1 Mana por finalizador e +3 por Quebra no kit anterior. Mana cheia no início da sala. Conferir HEAD. Nova recuperação de Centelha abaixo substitui a passiva antiga para evitar dupla contagem.

## Kit proposto (números configuráveis)
| Comando | Habilidade | Efeito |
|---|---|---|
| Esquerdo | Centelha | Projétil fogo, 8 dano, alcance 11 m, custo zero, +1 Mana por acerto; três acertos no mesmo alvo aplicam Queimadura. |
| Esquerdo segurado | Combustão | Esfera explode no primeiro inimigo, 35 dano, raio 2 m, 15 Mana, carga 0,6 s, aplica Queimadura imediatamente. |
| Direito | Estilhaço | Projétil gelo penetrante, 6 dano por alvo, zero Mana, recarga 4 s, Frio e lentidão 30% por 2 s. |
| Direito segurado | Geada | Área no cursor, raio 2,5 m, 3 dano/s por 4 s, 20 Mana, Frio progressivo até congelar. |
| Q | Arco Voltaico | Eletricidade, 12 dano por alvo, até 3 alvos, zero Mana, recarga 8 s, aplica Eletrizado. |
| E | Suspensão Arcana | Preservar domo atual: raio 2,6 m, 2,5 s, recarga 14 s, suspende projéteis, lentidão 40%, sem dano. |
| Espaço | Passo Etéreo | Preservar teletransporte atual, 4,5 m, duas cargas, 1 s por carga, sem dano. |
| Shift | Convergência Elemental | Supremo único do bastão; ver abaixo. |

## Reações
| Estados | Reação | Efeito inicial |
|---|---|---|
| Queimadura + Frio | Choque Térmico | 20 dano adicional no alvo. |
| Queimadura + Eletrizado | Sobrecarga | 15 dano em área. |
| Frio + Eletrizado | Cristalização | Congelamento de comuns por 0,8 s; chefes recebem Quebra em vez de congelamento. |

Ordem indiferente; consumir os dois estados; sem custo adicional; reações não geram outras reações por padrão. Estados expiram. Aplicações e reações devem ser determinísticas por alvo, sem duplicação por frame ou tick. Limpar estados em morte e troca de sala. Separar estado elemental da Marca de Qeshael. Não criar loops infinitos por Bênçãos ou áreas persistentes.

Pendências de balanceamento: duração e DPS da Queimadura, duração de Eletrizado, janela de três acertos, limiar de Frio, raio da Sobrecarga, alcance dos saltos, recarga/carga de Geada, relação entre recargas de toque e segurado, tetos de Mana e contribuição de Quebra. Usar dados configuráveis; documentar defaults de protótipo e pedir validação. Não tratar números como aprovados. Preservar limites de KitFeed e não recuperar Mana por cada tick/reação sem regra explícita.

## Supremo — Convergência Elemental
Proposta: área 5 m, duração 4,5 s, 90 dano direto total mais reações, Maestria 2, carga por Mana gasta. Fases gelo → fogo → eletricidade. Garantir que a fase elétrica tenha estado elegível para reação: como Choque Térmico consome ambos, prever reaplicação explícita de fogo/frio em ticks posteriores ou aceitar ausência de reação se não houver estado; decisão final pendente. Não criar segunda ultimate selecionável. Preservar imunidades e infraestrutura UltCharge. Limiar de carga pendente.

## Dons
Três ramos de quatro pontos, sem sustento. Elementalismo (reações), Conjuração (persistência e controle territorial), Feitiçaria (encadeamento e Mana). Nomes e pontos individuais ainda não aprovados. Não inventar 12 Dons definitivos nem publicar árvore incompleta como final. Prototipar kit independentemente dos Dons; apresentar propostas de ápices para revisão separada.

## Progressão
Início: projéteis únicos, áreas pequenas, reações simples. Meio/fim: Bênçãos podem aumentar projéteis, alcance, áreas, propagação e frequência. Não entregar reações em cadeia ilimitadas no kit básico. Adaptar as sete famílias de Bênçãos compartilhadas, sem duplicar catálogo; definir compatibilidade entre estados de Bênçãos e estados nativos antes de habilitar interações cruzadas.
