# VFX pintado à mão, lote 1: cortes do Guerreiro e acerto (2026-11-27)

Dono: `art-director`. Gera as folhas: `ai-art-producer` (gpt-image-2). Liga no jogo: `technical-artist`. Só visual:
nenhum tempo, alcance, dano ou janela muda; `RESULT` do `--smoke --seed=5` igual. Contexto: salas pintadas (GP-8,
`docs/art/painted_gpt/README.md`), efeitos atuais em `docs/reference/art_fx.md`. Tudo começa atrás de `--painted-fx`
(desligado) até o Daniel aprovar a captura.

## 1. Princípios (o que faz um efeito de jogo pintado se ler; só princípio, nada de forma, asset ou nome alheio)
1. **Hierarquia de valor**: chão (luma média 68 a 92 nas salas escuras) < personagens (100 a 150) < efeito (corpo
   170 a 210, miolo 220 a 235). O efeito é a coisa mais clara e mais saturada da tela, mas por pouco tempo.
2. **Silhueta antes de brilho**: forma cheia e gorda, borda limpa de pincel, uma cor chapada com uma luz por dentro.
   Nada de névoa difusa ou gradiente de partícula: tem de ler em preto e branco e em 1/4 do tamanho.
3. **Quadro de arrasto (smear)**: o corte aparece já inteiro no quadro do golpe, como mancha larga; os quadros seguintes
   só afinam, abrem e se desfazem. Quem anima a lâmina é o modelo; o efeito é o rastro.
4. **Vida curta**: 4 a 8 quadros a 60 fps. Começa no quadro em que o golpe acerta (o `_draw_swing`), nunca antes.
5. **Antecipação fica no corpo**: a preparação já existe (windup, brilho do finalizador, `fx.blade_pulse`); a folha
   não desenha preparação.
6. **Pisca no acertado**: 1 a 2 quadros do inimigo quente e claro, mais o hit stop que já existe. O pisca diz "acertou"
   antes de qualquer partícula.
7. **Tinta por baixo**: uma sombra de tinta escura e estreita sob o corte separa a luz do chão claro das poças de tocha.

## 2. Cores do lote (valores em sRGB; perto dos que o `Fx` já usa, para o resto do jogo concordar)
| Papel | Cor | De onde vem |
|---|---|---|
| Miolo do corte (aço quente) | `#F4EEDC` marfim, nunca branco puro | lerp atual para o branco (0,35) |
| Corpo do corte (ouro) | `#FFD161` | `Fx.GOLD` |
| Borda de fora, que some primeiro | `#F2B84D` | `Fx.OLD_GOLD` |
| Fio da Emeth (só a 10% interna do arco, junto da lâmina) | `#4DFF73` | `Combat.EMETH`; esmeralda é só da Emeth, nunca o corpo |
| Tinta por baixo | `#2A2620` a 35 a 45% | `slash_ink.gdshader` |
| Faísca do acerto, miolo / aro | `#FFF6E0` / `#FF8F42` | `hit_warm` do `crowd.gdshader` |
| Pisca do inimigo | `hit_warm` (1, 0,56, 0,26), `hit_gold` (1, 0,84, 0,46), piso 0,32 | já no `crowd.gdshader`, não muda |
Proibido no lote: violeta (só Morvath), verde fora do fio da Emeth, vermelho de sangue (a morte é pó de osso).
Com Bênção, a família tinge o corpo (`Combat.color_of`); a folha é desenhada em escala de cinza quente e o shader
pinta. Teto da tela: `ScreenTone.SAFE` 226, absoluto 235; só o miolo encosta no teto.

## 3. Cada efeito
Escala de referência, câmera Perto (37 m, cerca de 28 m de largura na tela): 1 m dá uns 69 px em 1920x1080; o herói tem
uns 1,8 m (125 px). O raio da carta é sempre o `draw_reach` que o `Combat` já passa, nunca um número fixo na folha.

| Efeito | Forma | Quadros e vida | Tamanho no chão | Mistura |
|---|---|---|---|---|
| Corte 1 (`cut1`, 150 graus) | arco em gota: cabeça grossa (25% do raio) na ponta da lâmina, cauda afinando até um fio; borda de fora reta de pincel, de dentro serrilhada seca | 6 quadros, 130 ms (`SLASH_TIME` 0,12 mais o mínimo) | raio = `draw_reach`, lâmina visível `BLADE_REACH` 2,9 m | corpo premultiplicado, miolo aditivo |
| Corte 2 (`cut2`, 150 graus, espelhado) | o mesmo arco, 15% mais largo e com 2 riscos de pincel soltos na cauda (diferença de 1 para 2) | 6 quadros, 160 ms | igual | igual; `flip` espelha a UV |
| Corte 3 (`cut3`, giro, finalizador) | anel aberto de 330 graus, grosso (35% do raio), cabeça no fim da volta, com a meia-lua que sai (`Fx.crescent`) mais clara e mais fina | 8 quadros, 300 ms (`FINISHER_SLASH_TIME`); meia-lua 340 ms crescendo 1,7x | raio 3 m no giro; meia-lua até 5 m | igual |
| Pesado (Golpe Esmagador, `smash`, 120 graus) | cunha curta e muito grossa (45% do raio), quase um leque cheio, que bate no chão: o último terço vira o anel do `Fx.shock` (já existe) | 6 quadros, 200 ms; anel e pedras como hoje | raio 2,6 m; anel 2,4 m | corpo premultiplicado, miolo aditivo |
| Investida (`dash`) | faixa reta (`Fx.thrust`) com bico na frente e 3 rasgos de pincel atrás; poeira do `dash_trail` fica | 6 quadros, 160 ms | comprimento = alcance, largura 0,8 m | igual |
| Faísca do acerto (`Fx.contact`) | 3 lascas DESIGUAIS em leque para onde a lâmina ia (a maior 2x a menor), miolo redondo pequeno; nunca estrela simétrica | 4 quadros, 80 ms (`CONTACT_TIME`); pesado 6 quadros, 110 ms | 0,4 a 0,9 m; pesado 0,6 a 1,4 m (`CONTACT_SPIKES*`) | aditiva |
| Anel pequeno do acerto | anel de pincel quebrado (abre em 2 ou 3 trechos, não fechado), achatado no chão, sob o acertado | 5 quadros, 120 ms, cresce 1,0 a 1,4x | 0,9 m de diâmetro; pesado 1,4 m | premultiplicado |
| Pisca do inimigo | não é folha: o `crowd.gdshader` como está, 1 quadro `hit_gold` no pesado e depois `hit_warm` | 2 quadros | - | - |

Sobre a **Investida**: hoje a árvore não tem golpe saindo da esquiva (`dodge_window` 0 em `tools/make_data.gd`); o
`dash_trail` sai em golpes com a etiqueta `dash` (Bênçãos da esquiva). A folha entra no lote, mas o Game Director
confirma se existe golpe de investida antes de ligar.

## 4. Folhas para o gerador (ai-art-producer)
Regras comuns a todas:
- **Tamanho pedido 1536x1024, grade 3x2, célula 512x512** (6 quadros). Giro e faísca pesada: duas folhas 3x2 (quadros
  1 a 6 e 7 a 8 mais 4 vazios), ou o produtor junta em 2048x1024 4x2 de 512 depois de cortar.
- **Fundo preto puro `#000000`**, sem textura nem vinheta. O shader tira a alfa do canal maior (preto = transparente).
  Não confiar em fundo transparente do gerador.
- **Desenho em escala de cinza quente** (marfim ao ocre), miolo quase branco; a cor final vem do shader.
- **Registro**: o centro de cada célula é o pé do herói (para arcos) ou o ponto do golpe (faísca, anel). O arco começa à
  direita (0 grau) e gira no sentido anti-horário; a abertura e o raio externo (90% da meia célula) são os mesmos em todos
  os quadros. O produtor confere sobrepondo os 6 quadros: a borda de fora não pode andar mais que 8 px.
- **Progressão**: Q1 mancha cheia (o smear, maior área e mais claro); Q2 igual com a cabeça mais nítida; Q3 a cauda
  começa a afinar; Q4 a borda de fora se parte em riscos de pincel; Q5 só a cabeça e riscos; Q6 2 ou 3 riscos finos.
  Faísca: Q1 miolo e lascas, Q2 lascas mais longas e finas, Q3 só pontas, Q4 dois pontos.
- **Estilo**: pinceladas visíveis, borda de tinta seca, chapado com uma luz interna; a mesma mão das salas pintadas.
- **Não pode aparecer**: espada, mão, herói ou inimigo; texto, número, marca d'água, moldura ou linha da grade;
  estrela de muitas pontas, sol com raios, cruz (nenhuma forma com 4 braços iguais); leão ou outro símbolo dentro do
  efeito; violeta; sangue; desfoque de câmera ou brilho de lente; perspectiva (o arco é desenhado visto de cima, plano).
- **Uma chamada por vez** (`--http1.1`), custo anotado no `painted_gpt/README.md`; a folha entra em `docs/steam-ia.md`.
- **Plano B** (o gerador costuma errar o registro entre quadros): pedir UMA forma por efeito (o Q1, em 1024x1024) e o
  shader faz a progressão (cauda que some pela UV, erosão por ruído, como o `slash.gdshader` já faz). Aceitar o plano B
  se a folha falhar duas vezes.
Arquivos: `assets/textures/fx/painted/{cut1,cut2,spin,smash,dash,contact,contact_heavy,hit_ring}.png`.

## 5. Como ligar (technical-artist)
- Ganchos que já existem: `Combat._draw_swing` (`scripts/game/combat.gd`, chama `fx.slash`, `fx.crescent`, `fx.thrust`,
  `fx.dash_trail` e `fx.blade_pulse` no quadro do golpe) e `Combat._draw_hit` (`fx.gash`, `fx.contact`, `fx.family_hit`,
  `fx.chips`). Em `scripts/game/fx.gd`: `slash()` (l. 875), `thrust()`, `crescent()`, `contact()`, `shock()`, `ring()`.
- Modelo de folha a copiar: `Fx.puff` com `puff.gdshader` (flipbook 4x2, `frame_at`, `PUFF_TEX`, pool `_puff_pool`).
- Arcos, investida, anel: **carta plana no chão** (y 0,9 como o corte de hoje; anel a 0,05), girada por `dir`, espelhada
  por `flip`, escalada por `draw_reach`; quadro = `floor(life / time * N)` sem interpolar entre quadros (é o que dá o
  ar de desenho). Faísca: **billboard** virado para a câmera, girado na direção da lâmina projetada na tela.
- Mistura: um shader `painted_fx.gdshader` (unshaded, `blend_premul_alpha`, `depth_draw_never`) com `color`, `core`
  (miolo aditivo somado por cima), `life`, `frames`, `grid`. A tinta por baixo continua sendo o `slash_ink` (sem folha).
- Com `--painted-fx` ligado, a carta substitui a malha do `slash`/`thrust`/`crescent` e o `contact`; `gash`, `chips`,
  `shock`, `hit_light` e o pisca do `crowd.gdshader` ficam. Pools e `budget` como os de hoje.
- Registrar o shader novo no aquecimento (`scripts/render/warmup.gd`, como o `puff.gdshader`). Compatibility: mesma
  carta sem o miolo aditivo.
- Teste GUT pequeno: o quadro escolhido vai de 0 a N-1 na vida e o efeito some no fim; `RESULT` igual.

## 6. Aceite (capturas na GPU, uma por vez, pela sessão principal)
Comandos (todas com `--seed=5 --stress=5 --stress-ids=skeleton,guard,skeleton`, uma vez sem e uma com `--painted-fx`):
`--bot --shot-on=swing --shot-after=0.03` (corte 1 ou 2), `--shot-on=spin --shot-after=0.05`, `--shot-on=hit
--shot-after=0.02`, e o Esmagador com `--shot-on=omega` se o robô o usar. Lado a lado: antes, depois, e
`docs/art/painted_gpt/` (a sala pintada) para conferir a mão.
Passa se:
1. Em 1/4 do tamanho e em preto e branco, o corte se lê como forma (arco com cabeça e cauda), não como névoa.
2. Miolo é o ponto mais claro da tela (220 a 235 no `tools/frame_stats.py`), corpo acima dos personagens, e o chão em
   volta não clareia mais que 15 de luma (nada de lavar a sala).
3. Os cortes 1, 2 e 3 são distinguíveis entre si numa folha de quadros; o Esmagador é o mais grosso e o mais curto.
4. A faísca não lê como estrela, sol ou cruz; o anel não fecha; o inimigo pisca quente no quadro do acerto.
5. Herói, inimigos e avisos vermelhos no chão continuam legíveis por cima e por baixo do efeito.
6. Nenhuma cor proibida; o verde só no fio junto da lâmina.
7. Sobre uma poça de tocha o corte ainda tem borda (a tinta por baixo aparece).
8. fps e `step_ms` da linha `RESULT` na GPU sem queda visível contra a captura sem `--painted-fx`.
Registro em `docs/art/visual_review.md`; aprovação final do Daniel.
