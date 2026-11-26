# Maga — Mestra dos Elementos
Identidade: conjuração à distância, preparação territorial, reações, reposicionamento. Preservar modelo aprovado, cabelo curto, manto marfim, roupa azul, bastão de duas pontas. HP30, Mana50, duas esquivas, recarga1s, teleporte4,5m (conferir HEAD).

## Kit
| Slot | Habilidade | Dano | Mana |
|---|---|---|---|
| Ataque | Centelha (fogo) | 8 | grátis, não gera |
| Ataque Potente | Arco Voltaico (eletricidade) | 12 por alvo, até 3 | 10 |
| Poder | Estilhaço (gelo, atravessa alvos) | 6 | 5 |
| Especial | Geada (área persistente) | 5/s por 4s | 20 |
| Supremo | Convergência Elemental | preservar baseline 90 direto + reações | carga própria |
| Esquiva | Passo Etéreo | 0 | 0 |

Centelha aplica Queimadura após três acertos no mesmo alvo (janela anterior 4s). Arco passa de Q para hold esquerdo, aplica Eletrificação; Estilhaço aplica Frio; Geada aplica Frio progressivamente, raio anterior 2,5m. Remover Combustão e Suspensão Arcana do kit básico; preservar assets/código reutilizável sem expor ações antigas. Combustão pode retornar via Dom futuro, não implementar automaticamente. Custos novos são propostas; revisar recargas antigas de Arco e Estilhaço para não duplicar restrições desnecessariamente, medir antes de decidir.

## Economia e passiva
Regeneração natural proposta 2 Mana/s inclusive movimento e esquiva, sem geração por Centelha. Não duplicar recuperação antiga por finalizador/Quebra sem decisão explícita. Reações podem recuperar Mana via Dom Reciprocidade, não no kit base. Supremo carrega por reações efetivas, calibrar limiar e limitar ganho por conjuração para não carregar instantaneamente em grupos. Não permitir que Supremo se recarregue indefinidamente com suas próprias reações.

Reações automáticas, independentes da ordem, consomem ambos estados:
- Fogo + Gelo: Choque Térmico, 35 dano adicional.
- Fogo + Eletricidade: Sobrecarga, 25 dano em área, raio anterior 1,8m.
- Gelo + Eletricidade: Cristalização, congelamento 0,8s em comuns; resistentes recebem Quebra (baseline anterior 25, confirmar).
Baseline anterior: estados 3s, queimadura 4 DPS, Frio 30% lentidão, congelamento por 3 acúmulos, intervalo de reação 0,5s. Confirmar ArcaneKit e regras de chefes. Sem cadeia infinita; evitar duplicação Arcane/Celestial. Bênçãos elementais devem ter contrato explícito de interoperabilidade; não fundir estados silenciosamente.

Convergência: três fases elementais, baseline 4,5s raio5m. Garantir que consumo de estados nas fases anteriores não torne a terceira fase inútil; testar reações reais e registrar solução. Um Supremo por bastão.

## Dons (3 x 4, propostas de protótipo)
Elementalismo: Afinidade (+50% duração estados); Catalisador (+30% dano reações); Propagação (espalha um elemento a próximos); Trindade (reação deixa resíduo temporário, terceiro elemento provoca reação tripla). Definir janela, dano e alcance configuráveis, sem recursão.

Conjuração: Permanência (+30% duração áreas); Expansão (+25% tamanho); Manifestação (reações de fogo deixam área flamejante); Confluência (áreas sobrepostas provocam reações periódicas). Limitar frequência por alvo e impedir áreas geradas por reação de se reproduzirem indefinidamente.

Feitiçaria: Fluxo Arcano (regen natural maior); Agilidade Arcana (carga mais rápida); Reciprocidade (Mana por reação, referência +2 uma vez por conjuração); Transcendência (três reações tornam próxima habilidade carregada instantânea e gratuita). Definir consumo de benefício na execução, não no cancelamento. Sem carga de Supremo por ações gratuitas se a regra depender de custo; aqui Supremo depende de reações. Limitar procs de áreas persistentes e limpar estado nas transições.

Não transformar árvore em três elementos isolados. Sustento permanece Videira. Manter sistema de Dons radial, Maestria, Memória e Vagas.
