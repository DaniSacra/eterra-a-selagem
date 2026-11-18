# C18, a tela de um jogo acabado (cenário)

As capturas foram feitas na RTX 5060 (Forward+, `tools/gpu.sh shot`, 1920 x 1080), com os mesmos comandos do relatório
de arte de 2026-11-18.

- A pasta `before/` traz as capturas desse relatório.
- As capturas de antes de `bridge_b`, `sanctuary_b` e `runes_b` vêm do relatório de cenário, em 1672 x 941 e com outro
  enquadramento.

Os números foram medidos com `python3 -I tools/frame_stats.py`, pelo mesmo método do relatório: imagem reduzida a 640 px
de largura, na faixa de TV. "Violeta" é matiz entre 250 e 320 com saturação acima de 60%.

| Captura | Luma média (antes / depois) | Saturação p90 | Violeta > 60% (% da tela) |
|---|---|---|---|
| altar | 55 / **54** | 38 / **24** | 0.0 / **0.2** |
| boss1 | 50 / **58** | 50 / **29** | 20.1 / **3.6** |
| boss3 | 53 / **60** | 52 / **31** | 20.2 / **3.5** |
| bridge | 45 / **55** | 24 / **22** | 0.1 / **0.0** |
| bridge_b | 44 / **56** | 22 / **20** | 0.1 / **0.0** |
| crypt | 37 / **57** | 9 / **12** | 0.0 / **0.0** |
| garden | 51 / **57** | 17 / **17** | 2.0 / **0.1** |
| jogo | 56 / **58** | 39 / **25** | 2.4 / **0.0** |
| rift | 46 / **55** | 30 / **29** | 19.1 / **2.5** |
| ritual | 53 / **60** | 50 / **28** | 19.2 / **2.9** |
| runes | 46 / **56** | 15 / **18** | 0.0 / **0.0** |
| runes_b | 45 / **57** | 18 / **19** | 0.0 / **0.0** |
| sanctuary | 62 / **68** | 12 / **12** | 0.0 / **0.0** |
| sanctuary_b | 55 / **62** | 10 / **10** | 0.0 / **0.0** |
| shop | 57 / **57** | 40 / **28** | 5.6 / **0.9** |
| storm | 61 / **66** | 51 / **26** | 47.9 / **7.6** |
| trial | 30 / **43** | 12 / **11** | 7.2 / **0.5** |
| vitrine | 56 / **57** | 35 / **27** | 1.1 / **0.0** |

Cores na caixa de 300 x 300 px em volta do herói (verde ou ciano / rosa, matiz 300 a 345):

| Captura | Antes | Depois |
|---|---|---|
| boss3 (dentro da erupção) | 3,4% / 34,4% | 0,0% / 11,5% |
| storm (fase 4) | 10,5% / 1,1% | 1,9% / 0,3% |

## Aceite

| Critério | Resultado |
|---|---|
| Luma entre 55 e 70 em toda luta | Cumprido: de 55 a 68. Fora de luta, o altar fica em 54 e a Provação em 43 (câmara de evento, com o quadro quase todo de fundo). |
| Saturação p90 até 32 no salão e na câmara | Cumprido: salão de 25 a 28, câmara de 26 a 31. |
| Violeta acima de 60% em no máximo 5% da tela | Cumprido em todas as capturas menos a fase 4: 7,6%, contra 47,9% antes. Sobram as meias-luas de Morvath (efeito que precisa ser lido) e os veios da fase 4. |
| Herói dentro da erupção sem tinta rosa | Cumprido: a erupção é vermelha translúcida (alfa até 0,24), sem magenta nem ciano, e o herói mantém as próprias cores. Os 11,5% de rosa na caixa vêm da aura da maldição (violeta de propósito) e dos traços lilás da runa. |
| `fit_probe` | Ponte B, área fantasma: de 8,67 para 2,76 m². Santuário B, beira falsa: de 16,56 para 9,52 m². Salão em x 13 a 15: de 2,48 para 0,21 m². |
| Nenhuma peça `dungeon/` na vitrine | Cumprido: o entulho do KayKit virou pedra da `Masonry`. |
| iGPU na Baixa | Ver a tabela abaixo. |

Sobre o `fit_probe`: agora ele também conta os círculos e as caixas de colisão da própria sala.

## iGPU na qualidade Baixa

Medido a 1280 x 720 com `--smoke=12`.

| Sala | Quadros por segundo |
|---|---|
| Fendas | 59 |
| Jardim | 58 |
| Santuário | 58 |
| Cripta | 62 |
| Salão | 53 a 58 |
| Câmara | 56 a 57 |

A mesma sala varia até 5 quadros por segundo entre uma execução e outra. A primeira execução da sessão deu 29 nas
Fendas e não se repetiu.
