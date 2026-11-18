# Prova estilizada (STY-09): parecer de combate

Autor: `combat-feel-director`, 2026-11-18, versão `03fc59b` (STY-03 a STY-07 no `arpg-3d`).
Escopo: o que o perfil `--look=stylized` muda na leitura do combate, comparado com o `--look=classic` nas mesmas
sementes e no mesmo quadro. Nada de tempo, dano ou estado muda com o perfil (é só desenho); a cadência não foi
reavaliada, só a leitura.

## Veredito

**Reprovado tecnicamente para adotar o estilo como está.** A prova no Salão das Catacumbas passa no combate (avisos,
"vai bater", pisca, raio-x e corte leem, vários com mais contraste que no clássico). O que reprova é a **fase 4 de
Morvath**: no estilizado o chão da Câmara do Selo vira um ciano claro (luma 120 a 132 contra 63 a 75 no clássico) e as
faixas da Tempestade das Seis Almas, o ataque que mais mata, perdem o vermelho (saturação 0,48 para 0,24, cor rosada).
Como o F7 troca o jogo inteiro e o plano leva o estilo à câmara, o estilo só pode virar padrão depois de corrigir o P1-1.

## Como foi medido

- GPU: RTX 5060, Vulkan, Forward+, Alta, 60 f/s fixos, espelho próprio do projeto. Semente 5 em tudo, só `--look`
  diferente.
- **Avisos no salão** (script de captura no scratchpad, fora do projeto): na abertura, o mundo congelado (modo de
  escolha, só o desenho anda), quatro avisos reais pelo `Ground` (mira em fio, investida em linha, círculo, arco de 120
  graus) mais a mira de um besteiro de verdade; cada quadro capturado duas vezes no mesmo instante, com e sem a camada do
  `Ground`. A diferença dá a máscara exata do aviso; "chão" é a luma sob o aviso no quadro sem ele. Preenchimento em
  50% (antes dos últimos 30%) e em 90% (dentro deles). Quadros a 1280 x 720.
- **Morvath**: `--start=boss --boss-only=storm|scythe|eruptions` (fase 4 por `--boss-hp=0.14`, erupções na 3 por
  `--boss-hp=0.3`), quadro congelado 0,6 s (foice e tempestade) e 0,9 s (erupções) depois do começo do ataque, com e sem
  o `Ground`. 1280 x 720.
- **Pisca, "vai bater" e raio-x**: um esqueleto posto ao lado do herói com `flash_t` cheio e sem; em preparação a 0,69
  (pose armada, antes do segurar) e a 0,97 (no segurar, com o `tell_light`); um Cavaleiro entre o herói e a câmera,
  com o herói visível e escondido.
- **Corte**: `--lab` (corte congelado em 0,2, 0,45 e 0,7 da vida) e `--shot-on=swing|hit` com o robô, 1920 x 1080.
- **Sonda de sensação** `tools/feel_probe_run.gd --start=fountain` nos dois perfis.
- Luma = 0,299 R + 0,587 G + 0,114 B. "Aro" = mediana dos 15% de pixels que mais subiram com o aviso.
- As capturas ficaram no scratchpad da sessão (o Daniel não quer imagens no repositório).

## Medidas

### Avisos no salão (critério da spec 3.3: aro 40 acima da laje, preenchimento nos últimos 30% 20 acima)

| Aviso | Clássico: chão / aro / meio a 90% | Estilizado: chão / aro / meio a 90% | Aro - chão (cl / est) | Meio - chão a 90% (cl / est) |
|---|---|---|---|---|
| Mira em fio (largura 1,3) | 82 / 113 / 117 | 81 / 140 / 127 | +31 / **+58** | +34 / **+46** |
| Investida em linha | 73 / 121 / 120 | 91 / 159 / 148 | +48 / **+67** | +47 / **+57** |
| Círculo | 70 / 113 / 113 | 75 / 154 / 128 | +43 / **+79** | +43 / **+53** |
| Arco 120 graus | 64 / 127 / 109 | 81 / 160 / 132 | +63 / **+79** | +45 / **+51** |
| Mira real do besteiro (fio de 6 px) | 58 / 108 | 74 / 134 | +50 / **+60** | |

A 50% de preenchimento (antes dos últimos 30%) a subida mediana é igual nos dois (28 a 29 clássico, 31 a 33
estilizado): o "fraco até o fim" do preparo continua. **Passa** o critério em todos.
Cor na tela (média da área em 90%): clássico rgb(232, 58, 68), matiz 356, sobre chão de matiz 257 a 323;
estilizado rgb(230, 86, 65), matiz 8, sobre chão de matiz 35 a 38. O aviso soma (`blend_add`) sobre um chão morno e
vira vermelho-alaranjado; a distância de matiz até o chão cai de 35 a 100 graus para 27 a 30. A mira em fio, fina,
sofre mais: mediana rgb(123, 84, 61), saturação 0,46 contra 0,61 no clássico.

### Morvath na Câmara do Selo

| Ataque | Chão sob o aviso (cl / est) | Aro (cl / est) | Saturação do aviso (cl / est) | Cor mediana do aviso (est) |
|---|---|---|---|---|
| Foice (fase 1) | 47 / 47 | 111 / 133 | 0,64 / 0,47 | rgb(123, 49, 61) |
| Erupções (fase 3) | 54 / 55 | 192 / 194 | 0,36 / 0,28 | rgb(165, 65, 81) |
| Tempestade (fase 4) | **75 / 132** | 187 / 202 | **0,48 / 0,24** | **rgb(182, 155, 164)** |

Chão da câmara sem avisos, mesma caixa ao sul do selo: fase 1 luma 36 (clássico) e 38 (estilizado); **fase 4 luma 63,
matiz 210 (clássico) e luma 120, matiz 187 (estilizado)**. Nas fases 1 a 3 a câmara fica igual nos dois perfis e os
avisos leem; na 4 o estilizado lava o chão de ciano.

Morvath (corpo, fase 3, sem avisos): clássico rgb(65, 51, 83), matiz 265, saturação 0,39; estilizado rgb(74, 63, 77),
matiz 288, saturação 0,18.

### Corpo dos inimigos e herói

| Medida | Clássico | Estilizado |
|---|---|---|
| Pisca do golpe: subida p90 / luma p90 do corpo | 168 / 236 | 159 / 228 |
| "Vai bater" (`tell_light`, 0,97 contra 0,69 do preparo): subida mediana / p90 | 27,6 / 64,7 | 23,6 / 59,3 |
| Raio-x do herói atrás do Cavaleiro: luma do fio (top 15%) / subida p90 | 204 / 137 | 216 / 149 |
| Herói sem cobertura (caixa com chão, golpe real): herói / chão em volta | luma 102 / 71, matiz 33 / 267 | luma 115 / 93, matiz 36 / 41 |

### Corte

| Medida (`--lab`, 0,2 da vida, sobre a multidão) | Clássico | Estilizado |
|---|---|---|
| Área do corte (px a 1080) | 3705 | 6280 (+70%) |
| Luma mediana dentro do corte | 106 | 138 |
| Borda de ataque (top 15% / p90) | 229 / 249 | 175 / 212 |

A cauda em pinceladas aparece (riscos soltos na metade de trás). O miolo fica dentro da meta da spec (205 a 230 e
nada acima de 235; o clássico passa de 235). Sonda de sensação: **40/40 nos dois perfis**; tempos, hit stop, tranco e
quadro do acerto não mudam.

## Problemas

### P0
Nenhum. O perfil não mexe em estado, tempo, colisão nem entrada.

### P1
- **P1-1, fase 4 de Morvath lavada no estilizado (reprova).** Chão da câmara na fase 4 de luma 63 para 120 a 132,
  ciano; as faixas da Tempestade das Seis Almas ficam rosadas (saturação 0,48 para 0,24, mediana rgb(182, 155, 164)) e o
  chão vira o maior claro do quadro, acima do herói e do aviso: a ordem "aviso que fere agora > herói" cai justo no
  ataque que mais mata (`docs/qa/e2_morvath.md`). Causa provável (inferência, a conferir pelo environment-artist):
  `RoomMood.LAST_BREATH` leva a luz direcional a `key` (0,5; 0,8; 0,78) vezes `key_gain` 1,8; no estilizado essa luz é
  a chave de trás da câmera (`VisualProfile.KEY_ENERGY` 1,6, `KEY_ROTATION`), que cobre o chão inteiro de frente, em vez
  da lua rasante do clássico. Fases 1 a 3 não mudam. **Aceite**: fase 4 estilizada com chão da câmara de luma 55 a 80 na
  caixa ao sul do selo (a do clássico é 63), faixas da tempestade com saturação mediana de 0,4 ou mais e aro 40 acima do
  chão, medido como aqui (com e sem o `Ground`, `--boss-hp=0.14 --boss-only=storm`, 0,6 s).

### P2
- **P2-1, avisos alaranjados sobre o chão morno.** Matiz do aviso na tela de 356 para 8 graus, distância até o chão de
  35 a 100 para 27 a 30 graus; a mira em fio cai a saturação 0,46. O contraste em luma sobra, mas o vermelho deixa de
  ser só do perigo e encosta no âmbar das chamas, das brasas da queimadura e do perigo das Runas (`HAZARD_COLOR`).
  Não medido sobre a poça de uma tocha. Recomendação: no estilizado, escurecer o fundo sob o aviso antes de somar (a
  opção já escrita na spec 3.3, fundo vezes 0,8 dentro da forma) ou puxar o `WARNING_COLOR` só pelo perfil para manter o
  matiz 350 a 360 na tela. Aceite: matiz na tela entre 350 e 360 sobre a laje do meio do salão, saturação da mira em
  fio 0,55 ou mais.
- **P2-2, Morvath perde o violeta.** Saturação do corpo 0,39 para 0,18 (borda morna e `style_flat`). Ele continua
  legível como silhueta escura, mas a cor que diz "chefe" e que casa com as meias-luas violeta some. Aceite: saturação
  0,3 ou mais no corpo, matiz 255 a 285 (art-director).
- **P2-3, corte mais véu do que lâmina.** A fita ocupa 70% mais área e a mediana dentro dela sobe de 106 para 138,
  cobrindo mais os inimigos atingidos; a borda de ataque cai de 229 para 175 (top 15%). Lê como pincelada, mas a ponta
  que corta deixa de ser o claro dominante. Recomendação: véu (`slash_ink` e o corpo da fita) com alfa 25 a 30% menor no
  estilizado, borda de ataque de volta a 205 ou mais (dentro do teto de 235 e do `style_cap`). Aceite: área até 1,3 vez a
  do clássico, borda de ataque top 15% de 205 a 230.
- **P2-4, herói mais perto do chão em matiz.** No golpe real, a caixa do herói e o chão em volta ficam com o mesmo
  matiz (36 e 41; no clássico 33 e 267) e a diferença de luma cai de +31 para +22. Ele continua achado pelo cabelo, pelo
  contorno e pelo anel, mas a separação por cor some. Medida grosseira (caixa com chão): pedir ao qa-performance a medida
  com máscara do herói (com e sem ele, como no raio-x). Aceite: herói com 30 ou mais de diferença de luma para a laje
  em volta, ou borda de luz dele a mais clara da tela fora dos efeitos (critério 5 da spec).
- **P2-5, "vai bater" um pouco mais fraco.** Subida mediana 23,6 contra 27,6 (85% do clássico) por causa do corpo mais
  escuro (`style_light` 0,32). Lê, mas no limite: com mais corpos claros (borda morna) em volta, perde para eles.
  Recomendação: `tell_light` vezes 1,2 só no estilizado. Aceite: subida mediana de 27 ou mais.
- **P2-6 (inferência, sem medida).** A borda morna marfim dos inimigos fica perto do fio marfim do raio-x do herói
  (luma 216 no estilizado). Na luta cerrada do `--lab` ainda se separam (o herói tem o miolo iluminado e o anel), mas
  vale o art-director olhar a borda dos comuns contra o fio do herói.

## O que continua bom (não mexer)
- Aro e preenchimento dos avisos de inimigos comuns no salão: de 51 a 79 acima da laje, melhor que o clássico (31 a 63).
- O preenchimento continua fraco antes dos últimos 30%: a leitura do tempo do golpe não muda.
- Pisca do golpe abaixo do teto e do mesmo tamanho; raio-x do herói mais claro que no clássico.
- O contorno de casca separa melhor cada inimigo na multidão.
- Foice e erupções na câmara (fases 1 a 3): iguais ao clássico.
- Sonda 40/40 nos dois perfis.

## O que precisa mudar antes de adotar o estilo
1. P1-1: a fase 4 da Câmara do Selo no estilizado com o chão no valor do clássico e a tempestade vermelha (environment-
   artist, pelo Game Director; reavaliar pelo combat-feel-director com a mesma medida).
2. P2-1 e P2-3 antes de virar padrão: matiz dos avisos e véu do corte (technical-artist).
3. P2-2, P2-4 a P2-6 podem ir junto com a migração da câmara (passo 3 do plano), com o art-director.
4. Qualquer arena nova estilizada (passo 4 do plano) entra com a mesma medida dos avisos (com e sem o `Ground`)
   antes da entrega, também com os ares de fase e de evento (`RoomMood`) ligados.
