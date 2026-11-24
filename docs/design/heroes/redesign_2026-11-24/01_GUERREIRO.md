# Guerreiro — redesign

## Aprovado
Identidade física, sem poderes mágicos novos. Remover Fúria e ramo Guerra. Três ramos de quatro Dons: Combo, Ímpeto e Domínio. Sustento pertence à Videira. Dons independentes da arma. Um Supremo por arma. Emeth continua nome da espada atual, não de um ramo. Preservar Brado e Investida como habilidades básicas. Ômega deve deixar de ser nome apresentado ao jogador; proposta provisória: Golpe Carregado (terminologia final pendente).

## Baseline observado
Em data/heroes/warrior.tres e scripts/core/hero_def.gd: vida 40, Mana 50, uma esquiva, recarga 0,8 s, invulnerabilidade após dano 0,7 s, +2 Mana por finalizador, +3 por Quebra. Verificar HEAD e manter demais valores atuais. Não confundir Investida com esquiva.

## Dons (nomes e números provisórios, identidades e ápices conceitualmente aprovados)
| Ramo | Dom | Efeito proposto |
|---|---|---|
| Combo | Disciplina | Preserva sequência após esquiva por até 2 s. |
| Combo | Cadência | +8% velocidade de ataque por golpe sucessivo; reinicia ao terminar/perder sequência. |
| Combo | Maestria Marcial | Expande combo de 3 para 5 golpes. |
| Combo | Apogeu | Último golpe causa 150% da soma do dano efetivo dos golpes anteriores da sequência. |
| Ímpeto | Força Concentrada | +40% dano dos golpes carregados. |
| Ímpeto | Determinação | Dobra recuperação de Mana por ataques básicos. |
| Ímpeto | Concentração | Reduz tempo de carregamento em 30%. |
| Ímpeto | Força Titânica | Golpes carregados custam o dobro de Mana e causam o triplo de dano. |
| Domínio | Ruptura | +50% Quebra em finalizadores. |
| Domínio | Voz do Leão | Amplia Brado e capacidade de interrupção. |
| Domínio | Imposição | +50% duração de CC elegível. |
| Domínio | Investida Implacável | Investida atravessa e atordoa todos os alvos atingidos por 2 s; chefes resistentes recebem contribuição de Quebra. |

Combo: DPS sustentado, esquivar não deve punir excessivamente. Ímpeto: poucos golpes físicos muito fortes, esgotamento de Mana e recuperação ativa. Domínio: controle e abertura de oportunidades. Nenhum ramo deve dominar todos os cenários.

## Regras técnicas propostas
Apogeu depende de Maestria Marcial. Acumular apenas dano dos ataques próprios anteriores do combo, sem contar reações, dano periódico ou o próprio Apogeu; evitar multiplicação recursiva e duplicação por múltiplos alvos. Definir política de acúmulo por alvo antes de finalizar balanceamento (recomendação: por alvo). Resetar em término, expiração, morte e mudança de sala. Determinar ordem de multiplicadores e custo de Ímpeto em testes; não permitir Mana negativa. Preservar imunidades de chefes e regra de golpes comuns sem stun. Investida Implacável é exceção explícita de Dom. Valores de alcance do Brado e Quebra contra chefes ainda pendentes.

## Supremo
Proposta: Corte do Juízo como único Supremo da Emeth. Reservar Voragem para eventual arma futura, sem opção de seleção na árvore. Não excluir assets reutilizáveis. Confirmar associação antes de tornar definitiva.
