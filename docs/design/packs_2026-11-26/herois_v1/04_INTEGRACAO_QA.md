# Integração e critérios de aceite
## Bênçãos
Última leitura: V1 tinha sete anjos, 9 poderes cada, 5 principais (Ataque, Especial, Q/Brado, Esquiva, Supremo), 4 complementares; discussão paralela prevê novos anjos. Não assumir catálogo atual sem inspeção. Remapear fontes semânticas para Ataque, Ataque Potente, Poder, Especial, Esquiva, Supremo. Proposta: manter quatro famílias principais agrupando toque/hold por botão ou separar carregados se aprovado; não alterar quantidade de anjos/poderes nem remover IDs sem alinhar frente roguelike. Mapear antigos Q/E para substitutos coerentes ou reservar IDs, preservar saves e testes. Usar fonte da ação, não tags ambíguas. Garantir três ofertas quando catálogo permite; manter regras de slots, raridade, complementares, convidados. Documentar matriz por herói e casos de interação Arcane/Celestial. Não duplicar dano/estados por dois sistemas.

## HUD e meta
HUD quatro grupos de comandos (M1, M2, Espaço, Shift), com identificação clara das variantes toque/hold e custos. Mostrar carga de Supremo e esquivas disponíveis, Mana máxima correta por herói, Ritmo preparado por indicador discreto, estados elementais legíveis. E apenas interação, Q não combate. Atualizar tutorial, antessala, tooltips, livro, textos e controles. Não redesenhar arte oficial sem necessidade. Dons 12 por herói, árvore radial, clique detalhes, segurar compra, equipar conforme Vagas; preservar regras de Maestria/Memória. Remover seletores de Supremo incompatíveis com arma única. Sustento na Videira, armas na Forja. Migração de saves idempotente, IDs antigos preservados ou mapeados; proposta de restituição de Memória para Dons removidos deve ser validada, não apagar progresso.

## Testes mínimos
- Baseline e suíte completa após mudanças, headless e smoke real se disponível.
- Guerreiro 40/30, Maga 30/50; clamp, custo, recuperação, cancelamento, Mana insuficiente, entrada/saída de sala, morte, saves antigos e novos.
- Toque/hold ambos botões, sem duplo disparo, E interação, Shift Supremo, Q sem ação, mouse/controle, pause e perda de foco.
- Especial Guerreiro preserva comportamento anterior; com 30 Mana não executa dois seguidos sem recuperação. Testar Força Titânica com capacidade/custo compatíveis; nenhuma build desbloqueada inutilizável.
- Ritmo: acerto finalizador, expiração, consumo por cada slot, cancelamento, boss e reset. Apogeu por alvo, Disciplina, Investida Implacável, limites de Quebra e CC.
- Maga: regen andando/esquivando, sem ganho básico, seis ordens de pares elementais, consumo estados, intervalos, chefes, áreas, Trindade/Confluência/Transcendência, sem loops, Supremo com terceira fase útil.
- Bênçãos: todos slots e fontes, raridades, convidados, saves, ausência de duplicação Arcane/Celestial; comparar catálogo antes/depois.
- Balanceamento: medir DPS sustentado, burst, tempo sem Mana, controle, sobrevivência, tempo por sala e Morvath; usar mesmas seeds e builds sem meta e com cada ápice. Não ajustar apenas pelo DPS. Avaliar se Maga é incentivada a jogar e não só esperar regen.

## Pendências explícitas
Valores novos não são finais; passiva Ritmo e seus multiplicadores, custos novos, carga dos Supremos, recargas, interação elemental, nomenclatura e Dons da Maga são baseline proposto. Decisão de capacidade com Força Titânica e política de Bênçãos precisam validação. Última leitura do repo não equivale a HEAD atual; conferir docs antigos de Selos/Ressonância, Fúria, dois Supremos e controles antigos. Atualizar documentação canônica e marcar versões obsoletas. Não implementar heróis futuros nesta entrega.
