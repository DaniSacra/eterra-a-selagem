# Redesenho das salas, Lote E: Câmara do Selo (só fundo e atmosfera)

- **Data**: 2026-11-18. **Autor**: art-director. **Para**: environment-artist, depois do Lote D.
- **Depende de**: biblioteca do Lote A (ar estilizado e F7, `vary`). Regras e aceite comum: `room_redesign_matrix.md`
  0.3, 0.4 e 4. Decisão: só fundo e atmosfera; Morvath é o centro; nada de sol negro, portal cósmico ou braseiros no
  anel.
- Só STYLIZED; clássico igual; Meshy zero.
- Conceito (clima): `conceitos/18_camara_selo.png`.

## 1. O que não se toca

- O círculo de 12,5 m e tudo dentro dele: chão (`chamber_floor.gdshader`), selo com o leão (`chamber_seal.gdshaderinc`),
  `SealLook` (cinco estados, `HUSH`), balaustrada, velas, pilaretes, sarcófagos com a espada erguida, fachada com a porta
  selada, escada sul com o véu. `tests/test_chamber_look.gd` (nada dentro do círculo) tem de passar igual.
- A pedra da câmara não ganha preset de bioma: a câmara já foi revista (P1 a P6, C11, C18) e a leitura da luta de
  Morvath (avisos violeta e vermelhos, tempestade, erupções, meias-luas violeta) foi medida nela. Nenhum `paint_stone`
  novo aqui.
- `RoomMood.LAST_BREATH` (fase 4) e a correção do STY-10 (ar lido depois de a câmara se vestir) continuam.

## 2. Medida e alvo

| | Hoje estilizado | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 252 | 276 | 250 a 265 (igual) |
| Luma p50 do quadro | 37 | 54 | 37 a 46 (o fundo um pouco mais lido, o chão igual) |
| Fundo (caixa acima da fachada e nas laterais do abismo) | | | camadas: três profundidades distinguíveis, p90 menos p10 de 15 ou mais |
| Violeta acima de 60% | | | até 5% da tela na fase 1; até 8% na fase 4 (com o `LAST_BREATH`) |

## 3. Peças novas (só estilizado; todas além do anel distante ou fora dos 12,5 m mais 6 m)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| E1 | Arcos partidos no anel distante | entre os arcos do `FAR_RING` (raio 38), três a cinco arcos quebrados a meia altura (`Masonry.voussoir_arch` com aduelas faltando, uma pendurada) | pedra do `SPIRE_STONE`/`FAR_*` de hoje, sem luz nova |
| E2 | Correntes a mais | duas ou três correntes grossas cruzando o abismo de lado (leste-oeste), abaixo da faixa de cima da câmera do jogo e acima da altura dos sarcófagos na tela | `kit.chain`, `CHAIN_SIZE`; nunca na frente de Morvath (conferir na captura da fase 1 com ele no selo) |
| E3 | Cacos parados no ar | 20 a 30 blocos de pedra no abismo, entre 14 e 30 m do centro, y -2 a -12, girados, imóveis (ou girando 0,01 volta por s) | sem brilho; a bruma violeta das `COLUMNS` passa por eles |
| E4 | Ar distante | `vary` na névoa e no céu: céu do azul-marinho de hoje mais profundo de valor (0,9 do atual), as `SPIRE_*` um degrau mais claras na borda (`SPIRE_EDGE` x 1,15) | o fundo fica mais lido sem clarear o chão |

Recusado: sol negro, portal no céu, vórtice atrás de Morvath, braseiros no anel, qualquer círculo novo.

## 4. Medir e entregar

- `RES=1920x1080 tools/gpu.sh shot <saída> --look=stylized --start=boss --bot --autopick --seed=5 --shot-at=5`, mais
  fase 4 (`--boss-hp=0.14 --boss-only=storm --shot-at=...` como no STY-10), mais ritual (`--shot-on=boss:ritual` ou o
  momento equivalente do `Boss.moment`), 1080 e 720; o clássico igual.
- `tools/chamber_lab.gd` com `--showcase` e `--phase=1..4`, `--look=stylized` (conferir que o laboratório honra o look).
- Leitura: numa captura de cada fase, Morvath e o herói achados em 1 s; aro dos avisos 40 ou mais acima do chão; meias-
  luas violeta com maior canal 40 ou mais acima do fundo atrás delas.
- `tools/test.sh -gselect=test_chamber_look`, `test_boss_chamber`, `test_seal_victory`; `sty_probe` na fase 4 (RTX
  Alta, iGPU Baixa: até 3 qps abaixo).
- Saída em `docs/gallery/redesign/lotE/`.

Esforço: 1 a 2 sessões.

## 5. Fim do redesenho

Com os cinco lotes aceitos, a decisão da noite liga o estilizado como padrão do exe (F7 volta ao clássico). Antes disso:
uma volta completa da descida com o robô (`tools/smoke.sh 900 --seed=5 --look=stylized`) sem erro de shader no log, e
uma captura de cada uma das 18 vistas na mesma linha da galeria de 2026-11-18, em `docs/gallery/redesign/final/`, para a
minha revisão em `docs/art/visual_review.md` e a do Daniel.
