# Efeitos visuais e preparo técnico da arte

Índice. Efeitos (VFX, cores das famílias, `RewardShaft`), preparação dos atiradores, Compatibility, passes de VFX, AP-2 e AP-4, escudo do Cavaleiro, efeitos do Guerreiro e das Bênçãos V2. O texto fica nos arquivos da pasta `art_fx/`; leia só o que a tarefa pede.

| Arquivo | Do que trata | Seções |
|---|---|---|
| [art_fx/lc-and-technical-passes.md](art_fx/lc-and-technical-passes.md) | Ciclo LC (preparação dos atiradores, Compatibility) e Lote 2B / TA-HB | Ciclo LC, preparação dos atiradores; Ciclo LC, Compatibility; Lote 2B e TA-HB, parte do technical-artist |
| [art_fx/vfx-pass-and-ap.md](art_fx/vfx-pass-and-ap.md) | Passe de VFX (Lote 1, correções, Lote 2), AP-2, AP-4 e Lote 4 de 2026-11-21 | Passe de VFX, Lote 1, parte do technical-artist; Passe de VFX, correções do Lote 1 e Lote 2, parte do te; AP-2 "Combate que se lê", parte do technical-artist; AP-4, esboço em traço dos inimigos e motivos dos Dons; ... |
| [art_fx/combat-fx-2026-11-22-27.md](art_fx/combat-fx-2026-11-22-27.md) | Efeitos de 2026-11-22 a 27: leitura do combate, escudo do Cavaleiro, força dos efeitos, chegada, GP-3, Bênçãos V2, espada pintada | Combate C1: leitura na tela; N2; Escudo do Cavaleiro de verdade; Lote E; ... |

## VFX da Maga (F7, 2026-11-28)
- `scripts/game/maga_fx.gd` (`MagaFx`, filho do `Arcane` como `arcane.vfx`) e `assets/shaders/maga_spell.gdshader`: um shader procedural (ruído para borda irregular, células de gelo rachado, núcleo quente) com 8 formas: cone, geada, arco, orbe, anel, vapor, rastro, cristais. Nenhuma textura nem arte por IA (nada a declarar em `steam-ia.md`).
- Centelha: brilho na ponta do bastão e 3 rastros afilados em leque. Sopro: cone de névoa com borda de cristais. Combustão: esfera que cresce na ponta enquanto segura (`hold_orb`), anel irregular com línguas e clarão no impacto. Inverno: disco de prévia mais tênue, geada rachada rasteira que derrete no fim. Tempestade: arco grosso e dois ramos finos por salto. Reações: térmico (vapor branco, anéis âmbar e azul), sobrecarga (anel dourado, brilho laranja), cristalização (cristais e arco curto).
- Limites: no máximo 24 cartas vivas (`MAX_LIVE`), cartas de chão com alfa até 0,6 e `render_priority` -2 (desenham antes de qualquer aviso), a 0,07 m do chão. Paleta âmbar, gelo, marfim, dourado; sem violeta, sem vermelho. Testes: `tests/test_maga_fx.gd`.
- Aquecimento: o orbe de segurar nasce oculto no `_ready` para a colheita (`tools/make_warmup.sh`, rodada `--hero=maga`).
- Pendente: aprovação do art-director por captura na GPU; sons novos não feitos (reaproveita os atuais).
