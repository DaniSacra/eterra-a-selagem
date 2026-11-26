# Catálogo V2 — 81 propostas
Ordem de cada seção: ataque, especial, Q, esquiva, Supremo; depois quatro complementares. Preservar IDs V1 compatíveis (ver IMPLEMENTACAO.md), gerar novos IDs apenas para novos poderes. Descrições abaixo são comportamento alvo, não números finais. Conferir efeito atual em make_data.gd antes do diff.

## Sarael — Chama
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe em Brasa | Aplica queimadura. |
| Especial | Peso em Brasa | Queimadura mais intensa; se já queimando, antecipa fração restante. |
| Q | Poder em Brasa | Zona de fogo. |
| Esquiva | Passo em Brasa | Rastro de fogo. |
| Supremo | Chuva de Brasas | Supremo gera chuva e aplica queimadura. |
| Complementar | Combustão | Três aplicações geram reação em área; antecipa fração dos DoTs com orçamento. |
| Complementar | Chama Contagiosa | Derrota espalha queimadura uma vez. |
| Complementar | Brasa Persistente | Ações distintas renovam duração dentro do teto. |
| Complementar | Fogo Crescente | Intensifica queimadura; DoTs distintos dão bônus limitado. |

## Nivael — Geada
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe de Geada | Aplica frio. |
| Especial | Toque da Geada | Mais frio. |
| Q | Poder Glacial | Área glacial. |
| Esquiva | Flocos Errantes | Flocos aplicam frio com intervalo. |
| Supremo | Peso do Inverno | Manifestação glacial e estilhaço elegível. |
| Complementar | Estilhaçamento | Primeiro hit elegível gera fragmentos em área. |
| Complementar | Inverno Prolongado | Prolonga frio; preserva DoTs com orçamento limitado. |
| Complementar | Geada Profunda | Slow maior; frio ajuda impacto quando presente. |
| Complementar | Cristais Errantes | Estilhaço espalha frio e fração de DoTs. |

## Lumael — Luz
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Radiante | Chance crítica no ataque. |
| Especial | Peso Radiante | Chance e multiplicador crítico no especial. |
| Q | Poder Radiante | Chance crítica no Q. |
| Esquiva | Clarão | Esquiva prepara crítico da próxima ação. |
| Supremo | Julgamento da Luz | Raios do Supremo podem critar; priorizam alvos condicionados. |
| Complementar | Luz Crescente | Críticos sucessivos elevam multiplicador; fortalecem próxima aplicação elegível. |
| Complementar | Prosperidade | Ouro adicional. |
| Complementar | Fortuna Celestial | Chance crítica global. |
| Complementar | Esplendor | Multiplicador global; crítico intensifica aplicação elegível. |

## Shomael — Vigília
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Firme | Impacto no ataque. |
| Especial | Peso Firme | Mais impacto; pode estilhaçar alvo elegível. |
| Q | Poder Inabalável | Onda de impacto. |
| Esquiva | Passo Firme | Proteção temporária. |
| Supremo | Abalo Celestial | Onda do Supremo; completa ruptura próxima do limiar. |
| Complementar | Ruptura | Reduz limiar de impacto; antecipa fração DoT se houver. |
| Complementar | Força Inabalável | Bônus contra alvo rompido; onda de impacto limitada. |
| Complementar | Peso da Vigília | Duração do impacto; condições distintas ajudam preservação. |
| Complementar | Amparo | Prolonga proteção; escudo consumido fortalece próximo impacto, sem parry nativo. |

## Velael — Véu
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Velado | Fraqueza. |
| Especial | Peso Velado | Fraqueza prolongada. |
| Q | Poder Velado | Área de fraqueza. |
| Esquiva | Fios de Cinza | Névoa de fraqueza na esquiva. |
| Supremo | Crepúsculo | Supremo aplica fraqueza e prolonga condições existentes com teto. |
| Complementar | Vulnerabilidade | Dano recebido maior em alvo enfraquecido; bônus por condições distintas. |
| Complementar | Essência Restauradora | Mana ao derrotar enfraquecido; bônus limitado por diversidade. |
| Complementar | Véu Persistente | Fraqueza dura mais e prolonga outras condições com teto. |
| Complementar | Névoa Profunda | Redução de dano inimigo; diversidade melhora até teto. |

## Galael — Vento
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe dos Ventos | Velocidade de ataque. |
| Especial | Peso dos Ventos | Rajada que propaga fração de DoTs. |
| Q | Poder da Tempestade | Redução de recarga e vórtice de agrupamento de comuns. |
| Esquiva | Passos Leves | Carga extra de esquiva; manter até playtest. |
| Supremo | Vendaval | Supremo acelera; ações geram rajadas com CD. |
| Complementar | Cadência | Ações sucessivas acumulam velocidade. |
| Complementar | Turbilhão | Cadência máxima gera vórtice e propagação limitada. |
| Complementar | Brisa Favorável | Movimento; esquiva prepara rajada da próxima ação. |
| Complementar | Fluxo Contínuo | Janela de cadência maior; ações distintas aceleram acúmulo. |

## Qeshael — Penumbra
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Marcado | Marca. |
| Especial | Peso da Penumbra | Eco contra marcado; aplica sangramento proporcional ao hit. |
| Q | Poder da Penumbra | Eco do Q. |
| Esquiva | Olhar Rápido | Esquiva marca. |
| Supremo | Exército de Ecos | Supremo habilita ecos temporários e antecipação limitada de sangramento. |
| Complementar | Eco Crescente | Aumenta eco; avaliar intensificação de sangramento sem duplicar Supremo. |
| Complementar | Marca Persistente | Duração e transferência única ao derrotar. |
| Complementar | Sombra Revelada | Eco mais forte em marcado; crítico aplica sangramento se elegível. |
| Complementar | Ressonância | Reduz CD de eco; condição distinta em marcado reduz CD restante com teto. |

## Zerael — Peste (novo)
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Pestilento | Aplica veneno. |
| Especial | Peso da Peste | Aplica múltiplos stacks calibrados. |
| Q | Poder da Peste | Zona de contaminação com intervalo. |
| Esquiva | Passo Pestilento | Rastro de contaminação. |
| Supremo | Epidemia Celestial | Supremo intensifica veneno e contamina alvos elegíveis. |
| Complementar | Saturação | Limiar de stacks gera reação em área com CD. |
| Complementar | Peste Persistente | Stacks duram mais; frio ajuda preservação limitada. |
| Complementar | Deterioração | Veneno ganha intensidade progressiva; outros DoTs ajudam com CD. |
| Complementar | Contágio | Derrota espalha veneno uma vez; bônus limitado por alvos contaminados. |

## Baraqel — Trovão (novo)
| Slot | Bênção | Proposta |
|---|---|---|
| Ataque | Golpe Voltaico | Aplica eletrificação. |
| Especial | Peso do Trovão | Mais cargas e descarga elegível. |
| Q | Poder da Tormenta | Área elétrica aplica cargas com intervalo. |
| Esquiva | Passo Voltaico | Esquiva prepara aplicação elétrica ou deixa zona curta. |
| Supremo | Tempestade Celestial | Supremo gera descargas limitadas. |
| Complementar | Descarga | Limiar de cargas libera dano elétrico; CD por alvo. |
| Complementar | Condução | Descarga salta a alvos próximos com limite e perda de intensidade. |
| Complementar | Sobrecarga | Dano recebido pelo alvo eletrificado alimenta cargas; ticks DoT elegíveis com intervalo. |
| Complementar | Ressonância Elétrica | Cargas em alvos próximos potencializam descarga; crítico/ruptura podem ajudar com orçamento, sem recursão. |
