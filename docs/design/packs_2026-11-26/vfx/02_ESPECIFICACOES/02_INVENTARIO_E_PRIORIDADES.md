# Diagnóstico de partida — baseado nos documentos do repositório

**ATENÇÃO:** os itens abaixo são status do histórico até a revisão de 20/11. Não afirmam o estado visual atual sem captura de 26/11.

## Já aprovado no relatório histórico (não refazer sem motivo)
- V-01 corte voltou à esmeralda, retirando ciano.
- V-02 giro saiu da elipse perfeita.
- V-04 estocada/Ômega deixaram de ler como sabre de néon.
- V-11 magia comum mais escura e diferente da de Morvath, com polimento pendente.
- V-12 explosão do corredor deixou de estourar o branco.
- V-16 foice/Ceifa sem fio ciano, contorno violeta, com refinamento opcional.
- Partículas redondas substituídas na maior parte do Lote 1.
- Contorno de tinta STYLIZED e leitura de corpo do Guerreiro aprovados em captura histórica.

## Pendências registradas em 20/11 — confirmar no HEAD primeiro
| Histórico | Arquivo ou sistema candidato | Verificação | Prioridade se reproduzido |
|---|---|---|---|
| RewardShaft criado mas não ligado à recompensa real | `RewardShaft`, salas, loja, fonte | Foto 1 s após sala vencida e vídeo do pickup | P0 |
| Contact discóide/saturado e sobras em cruz | `contact.gdshader` e `Fx.contact` | 3 frames no acerto real, pico<=226 da spec | P1 |
| Traço vertical branco sobre vítima | `Fx.gash` ou impacto | screenshot `s_hit` 60 fps | P1 |
| Glint atravessa corpo do Guerreiro | `glint.gdshader` | frame do finalizador com herói parado | P1 |
| Lascas luminosas acima da cabeça | `Fx.BURSTS light` | Omega e Círculo | P1 |
| Flash de Morvath perde a paleta violeta | materiais/flash do boss | foto do boss sofrendo golpe | P1 |
| V-06 acerto da onda em cruz de 4 pontas | especial / impacto | foto real de onda atingindo | P1 |
| V-07 Círculo com disco branco chapado | ground / circle | frame de cast + permanência | P1 |
| V-13 preparo do Feiticeiro acima do teto | `EnemyFx` | frame de windup, não ataque | P1 |
| Famílias usam a mesma forma, muda só cor | `Skills`, `Fx.ring`, `Game.column` | sequência família por família | P1 |
| Elos/Salmos com violeta contaminando Morvath | código atual de cores | captura escolha + gameplay | P1 |
| Virote do besteiro sem foto comparável | projétil | movimento de tiro | P2 |

## Sistemas novas versões
- Atualização 24/11: Guerreiro sem Fúria; **um Supremo por arma**; uso de Emeth e Corte do Juízo.
- Maga: fogo, frio, eletricidade, Convergência Elemental; classificar se já integrado em produção antes de pedir efeitos.
- Seven angels: Sarael, Nivael, Lumael, Shomael, Velael, Galael, Qeshael; conservar diferenciação por família.
- A revisão QA 26/11b relata correção no cache `BoonState.stat` e monitoramento de stress; não confundir custo de CPU de hit com VFX novos.

## Ordem sugerida
1. Auditoria atual + arrumar P0 comprovados de leitura/coleta.
2. Vertical slice: Guerreiro e Emeth, ondas e contato.
3. Assinatura da Maga + das sete famílias.
4. Inimigos/Morvath e recompensas refinados.
5. Finalização do custo GPU/QA; integração com a tela de escolha sem mexer em UI.

**Não substituir o backlog do Claude:** acrescentar links a itens que ainda existem, fechar duplicatas e registrar o proprietário de cada arquivo.
