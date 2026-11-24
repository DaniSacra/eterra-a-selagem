# Integração, migração e critérios de aceite

## Sistemas compartilhados
- Dons: três ramos de quatro pontos por herói como padrão; Guerreiro definido conceitualmente, Maga pendente de desenho dos pontos. Preservar Maestria, Memória, Vagas, desbloqueio/equipamento e UI radial com centro e compra por pressionar. Proposta: sem pontes nesta primeira versão; validar custos e pré-requisitos antes de fechar.
- Videira: sustento (vida, regeneração, provisão, perseverança), não dano. Migrar Firmeza, Respiro e Ainda de Pé do Guerreiro conceitualmente; não transferir automaticamente bônus de Mana ou mobilidade sem revisar escopo. Não duplicar nós existentes. Manter Videira separada da Forja.
- Armas: um Supremo fixo por arma, desbloqueio conforme progressão; remover seleção de Supremos da árvore. Não obrigar troca de arma ou criar novos modelos agora.
- Saves: inventariar IDs removidos e versões. Migração idempotente, preservar progresso dos três slots, Maestria, moedas e compras válidas. Propor restituição de Memória para Dons removidos e liberar Vagas ocupadas; política econômica precisa aprovação. Não apagar saves nem conceder benefícios duplicados. Tratar seleção antiga de Supremo e dados de Fúria/Ressonância obsoletos.
- UI: remover indicadores antigos dos heróis afetados, atualizar tooltips, textos PT e demais idiomas existentes, HUD e Livro de Ahk. Estados elementais legíveis acima dos inimigos, sem confundir avisos vermelhos. Não alterar outros heróis desnecessariamente.
- Atualizar docs/design/heroes/maga.md, especificações do Guerreiro, docs/art/dons_medallion_spec.md e geradores de recursos relevantes, evitando regenerar dados antigos sobre novos.

## Aceite e testes ao final
- [ ] Ambos jogáveis, controles teclado/mouse e gamepad existentes preservados.
- [ ] Vida/Mana iniciais 40/50 e 30/50 respectivamente (confirmar divergências no HEAD).
- [ ] Guerreiro sem Fúria ativa; 12 Dons, três ramos; combo continua após esquiva conforme Dom; Apogeu sem recursão; Ímpeto consome Mana corretamente; Investida aplica CC a cada alvo elegível.
- [ ] Maga usa três elementos na mesma arma; todas as habilidades do kit acessíveis; sem Selos/Ressonância antigos; seis ordens possíveis de pares elementais testadas; estados consumidos e expiram; sem reação duplicada.
- [ ] Testar múltiplos alvos, elites, chefes, áreas persistentes, alvos mortos, mudança de sala, Mana insuficiente, cancelamento de carga e interação de toque/segurar.
- [ ] Supremo único por arma, carga e desbloqueio corretos; fases da Convergência verificadas.
- [ ] Bênçãos compartilhadas sem regressões, Marca de Qeshael preservada; nenhuma cadeia infinita.
- [ ] Migração de saves antigos e novos, repetição da migração sem duplicar recursos, compra/equipamento de Dons e Videira.
- [ ] Testes automatizados existentes e novos; executar Godot headless e smoke test conforme comandos reais do repo. Relatar comandos, resultados e limitações. Comparar DPS, consumo de Mana e CC em cenários equivalentes e várias sementes; não declarar balanceamento final sem playtest.

## Fontes consultadas na preparação
Branch arpg-3d: scripts/core/hero_def.gd, data/heroes/warrior.tres, data/heroes/maga.tres, docs/design/heroes/maga.md; contexto anterior de docs/design/warrior_spec.md, docs/design/kit_c1c.md, docs/art/dons_medallion_spec.md e scripts/ui/dons_screen.gd. Não foi feita auditoria integral do HEAD nem alteração de código na preparação deste pacote. Verificar todos os caminhos e versões localmente.
