# Ciclo 5: revisão final (Art Director, 2026-11-15)

Pedido do Daniel: o mesmo jogo, os mesmos personagens e a mesma arena, com acabamento claramente superior; o que
piorar volta. Especificação: `cycle5_spec.md`. Capturas reais (Vulkan, 1672 x 941, `--seed=5`), fora do git, em
`<scratchpad>/c5/`: `antes/` e `depois/` (pares `cmp_1_arena`, `cmp_2_combate`, `cmp_5_medalhao`; `6_horda`,
`7_morvath`, `8_sacerdote`, `3_lab_*`), recortes desta revisão em `c5/rv/`, navegador em `env/F1_arena_gl.png`,
HUD em `ui/cmp_1920_hud.png`. Os nove inimigos novos do Meshy não estão no jogo e não entram aqui.

## Por área

| Área | Resultado | Evidência |
|---|---|---|
| Sacerdote / Ancião | **Melhorou** | Contorno amarelo sumiu; capuz escuro emoldura o crânio, olhos roxos legíveis (`rv/lab_cmp.png`). Amarelo saturado no corpo 10,7% para 1,9% (`8_sacerdote`, aceite <= 2%). Ouro velho na coroa e frisos. |
| Cavaleiro e elites | **Melhorou** | Amarelo saturado 14,4% para 1,5%, L > 200 14,2% para 0,6% (`4_elite`, aceite 2% e 3%). Continua distinto do comum pela barra amarela e pelo porte. |
| Explorador | **Melhorou muito** | Modelo do Meshy aprovado: cabelo com mechas (não o disco laranja), cachecol e manto petróleo, couros em valores diferentes, rosto, botas (`rv/hero_cmp.png`). Maior na tela (altura 2,75 e câmera 54). Emeth lê esmeralda, não ciano. |
| Medalhão | **Melhorou** | O traço dourado fino virou um anel de pedra com 16 juntas, chanfros claro e escuro, fio de bronze interrompido, rachaduras e lasca (`rv/med_d.png`). Mais perto da faixa esculpida da pintura. Aviso vermelho por cima continua contínuo (`cmp_2_combate`). Runas quase invisíveis a 60 m. |
| Luz e materiais | **Melhorou** | Vitrine: p1 1,6 para 4,9; abaixo de 20 de 19% para 14%; p50 44,8 para 45,3 (brilho geral não subiu). Fundo com arcos góticos e cantaria em vez de painéis petróleo lisos (`rv/nw_cmp.png`). Falham por pouco: p95 104,4 (meta 105), p99 166,5 (meta 170), quentes 0,5% (meta 0,7%). Velas ainda com pavio esverdeado. |
| Abismo | **Melhorou pouco** | Saturação da faixa alta 0,98 para 0,76; janelas chapadas 26 para 20 (meta <= 8); detalhe 7,6 para 7,5 (meta 9,5); esquerda detalhe 4,2 para 5,6, escuro 42% para 39% (meta 32%). Lanterna com caixilho. O cartão violeta à esquerda virou uma mancha borrada com buracos redondos que parecem letras (`rv/ab_cmp.png`); o cartão à direita no `7_morvath` ainda tem borda reta. |
| HUD | **Melhorou** | Moldura escura com friso de ouro velho, degradê na vida, Magia azul-petróleo, retrato do Explorador com cachecol, ícones em pergaminho (`ui/cmp_1920_hud.png`). Posição e tamanho iguais. |
| Combate cercado | **Igual** | `6_horda`: o herói continua sem ser achado no bolo (só o vulto claro do raio-x, `rv/blob_cmp.png`). Não piorou; inimigos seguem legíveis contra o chão. |
| Morvath | **Melhorou** | Halo roxo neon saiu; capa roxa dessaturada com contorno escuro; o herói ao lado fica do tamanho certo (`rv/mv_cmp.png`). Aviso vermelho intacto. |
| Navegador | Igual (sem peça faltando) | `env/F1_arena_gl.png`. |

## Veredito

Aprovado para o teste do Daniel. Nenhuma área piorou; nada a reverter. Sacerdote, Ancião, elites, Explorador,
medalhão, HUD e Morvath são reconhecivelmente os mesmos, com acabamento superior. O abismo só avançou em cor.

Quick fixes recomendados (opcionais, antes da build):
1. `assets/shaders/abyss_glow.gdshader`: `breakup` 0.4 para 0.25 (menos buracos na mancha violeta da esquerda).
2. `scripts/game/catacomb_hall.gd`: `EAST_FOOT_GLOW_ENERGY` 3.5 para 2.5, para o
   retângulo violeta no `7_morvath` não ler como painel.

## Fica para depois

- Herói achável no bolo de 90 (raio-x na cor do herói, item A2 da spec): `gameplay-engineer`.
- Abismo: faixa alta ainda com 20 painéis chapados e pouco detalhe; arcos e ruínas mais recortados, bancos de bruma.
- Fogo com mais miolo quente; velas creme sob a luz fria.
- Runas do medalhão legíveis de perto (hoje quase apagadas).
- Elite na arena das catacumbas: o `4_elite` ainda é da arena antiga (modo horda); falta a captura em sala comum.
- Os nove inimigos do Meshy aprovados pelo Daniel: integrar e revisar no próximo ciclo.
