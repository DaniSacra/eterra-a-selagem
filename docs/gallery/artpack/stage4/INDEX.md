# Pacote de direção de arte, etapa 4: cenário (salas e Câmara do Selo)

Prancha `07-salas-combate.png` (só local em `docs/art/ref/direcao_2026-11-17/`). Capturas reais na RTX 5060, Forward+,
a 1280 x 720 (`_720`) e 1920 x 1080 (`_1080`); `before_*` é o commit `fe07159`, `after_*` é esta entrega.
`compat_*` é o renderizador do navegador (OpenGL na mesma GPU), só depois.

| Arquivo | Comando (depois de `tools/gpu.sh shot <saída>`) | O que olhar |
|---|---|---|
| `*_garden_*` | `--arena=garden --hero-at=-2,-2 --shot-at=2.5` | musgo ao longo das raízes, no pé do tronco e das paredes; peitoris das janelas e contraforte fora do chão |
| `*_garden_b_*` | `--arena=garden --variant=1 --hero-at=2,3 --shot-at=2.5` | a variante B |
| `*_rift_*` | `--arena=rift --shot-at=2.5` | lascas dos lábios um degrau abaixo do chão; balaustrada quebrada longe da cabeceira da ponte |
| `*_blades_*` | `--start=boss --boss-only=blades --shot-on=boss:blades_fire --shot-after=0.25 --shot-at=1` | Lâminas das Almas em violeta frio com núcleo claro |
| `*_storm_*` | `--start=boss --boss-hp=0.14 --boss-only=storm --shot-on=boss:storm_fire --shot-after=0.4 --shot-at=1` | Tempestade na fase 4: meias-luas violeta, rachadura e veios do selo apagados sob o ataque |
| `*_jogo_*` | `--bot --autopick --seed=5 --shot-at=9` | salão, verificação padrão |
| `*_vitrine_*` | `--showcase --seed=5 --shot-at=2` | salão, verificação padrão (sem mudança esperada) |

`fit_*_before.png` e `fit_*_after.png`: `tools/fit_probe.gd -- --arena=garden|rift --png=...` (vista de cima, 0,1 m por
célula, ampliada 3 vezes). Vermelho: desenho acima do joelho no chão livre; azul: peça que bloqueia sem desenho; amarelo:
superfície de chão fora do chão. Medido (m²):

| Sala | fantasma | peça sem desenho | borda falsa |
|---|---|---|---|
| Jardim A | 8,77 para 1,99 | 3,00 para 1,62 | 2,66 para 2,66 |
| Jardim B | 8,97 para 1,99 | 2,47 para 1,62 | 2,66 para 2,66 |
| Fendas A | 3,74 para 1,49 | 0 | 11,11 para 5,10 |
| Fendas B | 3,22 para 1,49 | 0 | 8,59 para 4,99 |

O que sobra de fantasma fica nas bocas das portas (bochechas da escada, que só viram chão com a porta usada); a borda
falsa que sobra no Jardim é o degrau do patamar sudoeste e, nas Fendas, a base da torre a 1,5 m da borda oeste.
