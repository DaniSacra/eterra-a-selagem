# Revisão de arte: TA-HB1, TA-HB2, HB3 e clarão do herói (2026-11-20)

Revisor: art-director. Só capturas existentes (a GPU estava com o Daniel); medidas com `tools/frame_stats.py --hue` e
diferença por pixel no ffmpeg. Nada implementado.

## 1. TA-HB1, linha de tinta nas peças (`PaintPass` modo ink)

Capturas: `ink_hall_off_on_400x300.png`, `ink_crypt_off_on_400x300.png`, `ink_sanctuary_off_on_400x300.png`,
`ink_full/ink_<sala>_0|1.jpg` (1920 x 1080, RTX, estilizado Alta).

O que bate:
- A linha só aparece onde há salto de profundidade: tampa e base do sarcófago da Cripta, anéis e silhueta da coluna do
  Santuário, balaustradas do Salão. Separa a peça do chão sem desenhar nas juntas das lajes nem nos avisos (que não
  escrevem profundidade). É o traço de contorno que faltava para a cena ler como pintura (HB1 do benchmark).
- Discreta: muda 0,75% dos pixels no Salão, 1,0% na Cripta, 0,49% no Santuário (diferença acima de 24); luma p50 da
  cena cai 0 a 1; matiz e saturação iguais. Não escurece o quadro nem mexe na moldura do Salão.
- Nas figuras soma por cima da casca do STY-06: o herói ganha um contorno mais firme no manto, sem virar silhueta, e a
  Emeth continua inteira. O pontilhado do raio-x não ganha linha.

O que difere ou falta ver:
- Nenhuma captura com multidão densa (12 ou mais inimigos com casca mais tinta) nem com a câmera Perto. Risco: as duas
  linhas juntas engrossarem o contorno dos esqueletos de longe.
- Nenhuma captura na Média (escala 0,85: a linha de 2 px pode serrilhar).

**Decisão: aprovado ligar por padrão no estilizado, Alta e Média** (`INK_DEFAULT_ON` true; Baixa e Compatibility
continuam sem). Condição para o technical-artist, na primeira janela livre da GPU: uma captura com
`--stress=12 --stress-ids=skeleton,skeleton_elite,mage --seed=5` na Perto e uma na Média a 1080; se a multidão ficar
pesada, tirar a tinta das figuras (máscara pela camada da multidão) e manter só nas peças. Aprovação final do Daniel.

## 2. TA-HB2, EdgeKit

Capturas: `edge_kit_classic.png`, `edge_kit_stylized_hero_behind_pillar.png` (tabuleiro `tools/edge_lab.gd`, chão
nu, sem a luz das salas: a pedra pintada sai quase preta ali, isso é do tabuleiro, não da peça).

Por peça:
- `broken_pillar`: aprovado. Silhueta clara (fuste partido e dois tambores caídos), o pontilhado abre em volta do
  herói como os obeliscos.
- `broken_arch`: aprovado. Aduelas com falha no meio leem como arco quebrado, não como dois postes.
- `rubble`: aprovado.
- `root_curtain`: aprovado só preso. No tabuleiro os fios pendem do nada e leem como pente; usar sempre com o topo
  escondido sob um peitoril, aduela, tabuleiro de ponte ou beira de parede.
- `ivy`: aprovado só preso, como as raízes. Verde-amarelo pálido e esparso: fica longe do verde da Emeth, bom; não
  saturar mais.
- `chain_weight`: **não aprovado**. A corrente sai torcida em dupla hélice (lê como mola ou DNA) e o peso é um cubo
  pequeno. Pedido ao technical-artist: elos alternando 90 graus numa linha só (como `ArenaKit.chains`), leve catenária
  quando presa nas duas pontas, contrapeso com pelo menos 0,6 m e forma de pedra lavrada ou argola de ferro.

Regras de uso para o environment-artist (vale para todas):
- Nunca sobre chão andável nem cobrindo saída, escada, porta ou aviso na tela; nada colide (já é assim).
- Peças altas na frente da câmera (sul e leste da sala, faixa de baixo da tela) só com o `see_through` e sem passar
  de 0,35 da altura da tela; a faixa de baixo continua mais escura que o meio (regra do ENV-HB3).
- Pedra pela cantaria da sala (já é); nenhuma luz própria.

Onde (por ordem de ganho):
1. Fendas: `broken_arch` sobre a boca norte (no lugar do arco de hoje, se ficar melhor) e `root_curtain` sob o
   tabuleiro das pontes; `rubble` fora do chão, ao longo dos lábios quebrados.
2. Jardim: `root_curtain` saindo do corte noroeste e dos peitoris das janelas cegas; `ivy` nas paredes norte e oeste.
3. Santuário: `broken_pillar` e `rubble` na borda sul, fora da nave, como primeiro plano com pontilhado.
4. Cripta: `ivy` e `rubble` nas baías do norte, sob os nichos (sem competir com a coroa de velas da A nem com a velada
   da B).
5. Ponte: `broken_arch` no abismo, longe; `chain_weight` dos pilones só depois da correção.
Salão: não mexer agora (o ENV-HB3 já tem colunas no abismo e foi aprovado).

## 3. HB3, figuras sobre o petróleo do Salão (só CPU)

Capturas: `hb3_hall_figures_cpu_classic.jpg`, `hb3_hall_figures_cpu_stylized.jpg` (1280 x 720, llvmpipe).

O que bate: os mortos comuns ficam escuros com a borda morna sobre o chão petróleo (esqueleto da esquerda luma p50 75,
caixa 440,380); o Escudo elite lê pelo ouro; o sacerdote com a besta do LC-1b lê; o fio da mira e o arco dos avisos
leem.

O que difere: o herói, dentro do aviso, perde o verde (caixa 605,255,60,120: verde 1,8% no clássico, 0% no
estilizado; luma p50 111 para 129) e a Emeth sai amarelo-branca; o vermelho do aviso sobre o petróleo lê rosa. Pode
ser o quadro de golpe sofrido, ou o llvmpipe, ou o aviso por cima do corpo; a captura de CPU não decide.

**Decisão: não suficiente.** Figuras contra o chão: aprovado em princípio. Herói dentro do aviso: pendente de uma
captura na GPU (`--start=` salão, `--stress=6 --stress-ids=guard_elite,skeleton,priest,archer --seed=5 --hero-at=0,0`,
quadros a cada 0,1 s, estilizado e clássico) quando o Daniel liberar. Se o herói seguir sem o verde fora do quadro de
golpe, o pedido vai ao technical-artist (`ground_fill` ou glow sobre o corpo) com meta: verde do herói na caixa dele
pelo menos 1% e a Emeth no matiz 130 a 150.

## 4. Clarão do herói ao levar golpe (`docs/gallery/c19/hurt_flash/`)

Capturas: `hurt_flash_before_after_60fps.png`, `after_stylized_0.017.png`, `after_classic_0.017.png`.

Antes: dois quadros com o herói marfim chapado, sem rosto nem cores (silhueta). Depois: o próprio corpo mais claro
com borda morna, cabelo vermelho, manto petróleo e Emeth lidos em todo quadro; luma do pico 154 para 121 (105 em
repouso). Cumpre a regra do CLAUDE.md (nunca silhueta branca).

**Decisão: aprovado.**

## Resumo

| Item | Decisão | Responsável do que falta |
|---|---|---|
| TA-HB1 tinta | Ligar no estilizado Alta e Média | technical-artist: captura de multidão na Perto e na Média |
| TA-HB2 EdgeKit | Aprovado menos `chain_weight`; raízes e hera só presas | technical-artist (corrente); environment-artist (uso) |
| HB3 figuras no Salão | Não suficiente (só CPU) | captura na GPU quando livre |
| Clarão do herói | Aprovado | nada |
