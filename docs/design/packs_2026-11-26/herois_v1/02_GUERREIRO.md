# Guerreiro — Punho de Elun
Identidade física, ofensiva, sem parry, sem magia elemental intrínseca. Emeth é a arma inicial, não o nome de uma ação universal. Bênçãos podem adicionar elementos. HP 40; Mana inicial 30, capacidade base proposta 30; sem regeneração natural; uma esquiva, recarga 0,8s. Preservar arte e modelo.

## Kit
| Slot | Habilidade | Dano | Mana |
|---|---|---|---|
| Ataque | Combo Marcial, três golpes | 15/15/30 | gera |
| Ataque Potente | Golpe Esmagador, curto alcance, elevada Quebra | 75 | 12 |
| Poder | Corte Circular, 360°, afastamento | 35 | 8 |
| Especial | Lança da Emeth | 150 | 20 |
| Supremo | Corte do Juízo | manter configuração validada | carga própria |
| Esquiva | Passo Marcial | 0 | 0 |

Especial: mover o golpe atualmente executado segurando mouse esquerdo para segurar direito. Preservar comportamento real, alcance, hitbox, animação, VFX, SFX, dano e recuperação; última leitura paladin.tres indicava lance 150, custo20, alcance13,5, largura1,8, carga0,8s, recuperação0,78s, bidirecional. Verificar HEAD e não recriar por aproximação. Com 30 Mana, apenas um Especial consecutivo sem recuperação. Retirar Brado e Investida como botões independentes. Supremo único Emeth: Corte do Juízo; Voragem pode ficar reservada para arma futura, não selecionável na Emeth.

## Economia e passiva
Acertos básicos recuperam Mana; finalizador dá recuperação adicional, Quebra recupera Mana. Baseline anterior observado: 0,5 por acerto, +2 finalizador, +3 Quebra com limites; conferir implementação e calibrar com capacidade 30. Não assumir +5 por combo como aprovado. Sem recuperação natural. Preservar política existente de entrada de sala inicialmente, documentar e testar; não confundir regen com reset entre salas.

Ritmo de Batalha: completar combo com acerto do finalizador prepara estado por 3s, não acumula. Próxima ação consumidora executada consome estado: Ataque Potente ganha Quebra, Poder atordoa comuns, Especial ganha dano e alcance. Magnitudes ainda não definidas; prototipar em parâmetros configuráveis, registrar. Brilho dourado da Emeth e indicador discreto; sem barra nova. Cancelamento não consome estado; limpar em morte/transição de sala. Chefes não recebem stun, usar Quebra conforme regras existentes. Carga do Supremo por Mana efetivamente gasta, sem contar cancelamentos.

## Dons (3 ramos x 4)
Combo: Disciplina (esquiva preserva combo, referência 2s); Cadência (+8% velocidade por golpe, proposta); Maestria Marcial (3→5 golpes); Apogeu (último golpe causa 150% da soma dos danos anteriores, proposta). Definir contabilização por alvo, sem recursão de procs; testar interrupções, alvos diferentes, reset.

Ímpeto: Força Concentrada (+40% dano carregado); Determinação (dobro da recuperação por básicos); Concentração (-30% tempo de carga); Força Titânica (dobro custo, triplo dano dos carregados). ATENÇÃO: Especial 20×2=40 supera capacidade base 30. Não publicar Dom inutilizável: proposta para protótipo é elevar capacidade efetiva apenas com esse Dom para pelo menos 40, sem alterar base 30; alternativa é revisar custo/multiplicador. Registrar e solicitar validação antes de consolidar balanceamento. Evitar Mana negativa e stacking multiplicativo acidental.

Domínio: Ruptura (+50% Quebra de finalizadores como referência); Imposição (+50% duração CC); Alcance Marcial (amplia Poder, valor a calibrar); Investida Implacável (esquiva passa a atordoar inimigos comuns atravessados, referência 2s; resistentes recebem Quebra conforme regras). Não acrescentar botão. Sem dano mágico intrínseco. Sustento fica na Videira; remover Fúria e ramos obsoletos. Preservar Maestria, Memória, Vagas e compra/equipamento existentes.
