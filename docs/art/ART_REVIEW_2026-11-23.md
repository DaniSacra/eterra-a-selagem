# Revisão de arte, 2026-11-23 (Fase 4 do backlog)

Revisor: `art-director`. Só capturas reais da GPU (Forward+, estilizado, câmera Perto) que estão no repositório.
Escala: P0 atrapalha ler o jogo ou parece defeito; P1 destoa e deve entrar no próximo lote; P2 polimento.
Coordenadas em pixels da própria captura (x, y a partir do canto de cima à esquerda). A aprovação final é do Daniel.

## Capturas usadas
- `docs/gallery/review_2026-11-23/`: `encontro_dois_anjos.png`, `encanto.png`, `dicas.png`, `maga_bastao.png`,
  `comuns_trinca_varredor.png`, `porta_caixa.png` (1672 x 941).
- `docs/gallery/meta_2026-11-23/`: `videira_1080.png`, `forja_1080.png`, `vendedor_1080.png`, `dons_pedestal.png`.
- `docs/gallery/dons_2026-11-23/dons_clareza_1080.png` (depois da passada de clareza).
- `docs/gallery/morvath_light/morvath_hard_2026-11-23.png`, `docs/gallery/channeler/lab_game.png`.

## Resumo por prioridade
| # | Item | Veredito | Prio | Dono |
|---|------|----------|------|------|
| 1 | Laje armada como retângulo vermelho cheio (sala 2) | AJUSTAR | P0 | `technical-artist` |
| 2 | Forja: disco preto no pomo e no guarda-mão | AJUSTAR | P0 | `ui-ux-designer` |
| 3 | Dons: nomes dos ramos longe dos nós | AJUSTAR | P1 | `ui-ux-designer` |
| 4 | Dons: número do nó escuro não diz "Maestria" | AJUSTAR | P1 | `ui-ux-designer` |
| 5 | Videira: broto comprado perde o nome | AJUSTAR | P1 | `ui-ux-designer` |
| 6 | Encanto: o mesmo ícone nas três cartas | AJUSTAR | P1 | `ui-ux-designer` |
| 7 | GR-8 raio-x de pontinhos (ainda `bayer4`) | AJUSTAR | P1 | `technical-artist` |
| 8 | Retrato da Maga no HUD fotográfico | AJUSTAR (asset) | P1 | `ui-ux-designer` + pedido ChatGPT |
| 9 | Legenda da última habilidade ao lado de "Espaço" | AJUSTAR | P2 | `ui-ux-designer` |
| 10 | Encontro dos anjos: HUD por cima | AJUSTAR | P2 | `ui-ux-designer` |
| 11 | Vendedor | FEITO (placeholder) | P2 | `ui-ux-designer` |
| 12 | Medalhão dos Dons no Santuário | FEITO | - | - |
| 13 | Dicas da primeira descida | FEITO | - | - |
| 14 | Maga com o bastão aceso | FEITO | - | - |
| 15 | Luz morna da Câmara de Morvath | FEITO | - | - |
| 16 | GR-17 letras do golpe de Morvath | SAI (Morvath sem marca no chão, `159f206`) | - | - |
| 17 | GR-19 fio da mira | SAI provável (besteiro mudo pelo PT-1); confirmar | - | - |
| 18 | Trinca e Varredor, Canalizador em jogo, portas, Suspensão, GR-18, GR-20, GR-26, GR-27 (dano por tempo) | SEM CAPTURA útil | - | ver lista no fim |

## Itens

### 1. Laje armada vira tapete vermelho (P0, `technical-artist`)
`porta_caixa.png` (1410..1580, 200..330): retângulo vermelho saturado e opaco, com chevrons ">>" ao lado, perto da saída.
Pela posição e pelos chevrons é a laje que empurra (RP-13): `GroundLook.set_plate` leva `PLATE_REST_COLOR` até
`HAZARD_COLOR` (o vermelho de aviso) já em `hot` 0,25 e com `HAZARD_STRENGTH`, então a laje fica vermelha cheia quase o
preparo inteiro. É perigo de sala (o PT-1 o deixa marcado), mas lê como tapete ou caixa de interface e é a maior mancha
vermelha da sala.
Pedido: o preparo da laje é brasa, não aviso. Corpo da laje fica na pedra (`PLATE_REST_COLOR`); o `HazardPiece` da
fissura acende em âmbar (1,0; 0,62; 0,25) de fora para dentro durante o preparo; o vermelho de aviso só como aro de
0,12 m nos últimos 0,35 s (o mesmo `Feel.bang_lead` do "!"), preenchimento com alfa até 0,25. Aceite: captura GPU com
a laje armada em que não há área vermelha cheia maior que o aro; o chão da laje ainda lê como pedra.

### 2. Forja: disco preto no pomo (P0, `ui-ux-designer`)
`forja_1080.png` (285..340, 365..420) e (712..758, 458..505): `ForgeBench._gem` desenha um círculo quase preto
(0,03; 0,025; 0,03) de 19 px quando o Despertar não tem gema, e `_rings` faz o mesmo no anel do especial vazio. Leem
como furo ou defeito sobre o bronze.
Pedido: engaste vazio = cavidade de bronze. Fundo (0,20; 0,13; 0,07), sombra interna de 3 px mais escura só na
metade de cima, aro `UiKit.OLD_GOLD` 2 px a 70%, e dentro a silhueta da gema (ou do "F" no anel) em pergaminho a 18%.
Mesmo tratamento no anel do especial vazio. Aceite: na captura nenhum ponto da espada tem luma abaixo de 25 dentro dos
engastes; o pomo ainda lê como "aqui entra algo".

### 3. Dons: nomes dos ramos soltos sobre a figura (P1, `ui-ux-designer`)
`dons_clareza_1080.png`: "Combo" (730, 509), "Sustento" (1113, 473), "Emeth" (1115, 659), "Fúria" (775, 705),
"Magia" (955, 773) estão em `MedallionView.LABEL_R` 138 (palco 1280 x 720), enquanto os nós ficam a cerca de 230..330
do centro. A etiqueta fica no peito do herói, a 100 px ou mais do próprio ramo; "Fúria" e "Magia" quase se tocam e
"Faltam 2 de Memória" (690..885, 760) cobre a de Fúria.
Pedido: raio por ramo = menor raio dos nós do ramo menos 42 (palco), no ângulo médio do ramo como hoje; um traço de
1 px na tinta do ramo (`ink` a 50%) da etiqueta até o primeiro nó. Se duas etiquetas ficarem a menos de 24 px, empurrar
a de ângulo maior pelo arco. A dica do nó em foco nunca por cima de etiqueta (deslocar para o lado de dentro oposto).
Aceite: cada etiqueta a no máximo 50 px (1080p) do nó mais interno do seu ramo, nenhuma sobreposição.

### 4. Dons: número grande nos nós escuros (P1, `ui-ux-designer`)
Mesma captura: "16" (603, 372), "18" (590, 740), "20" (1217, 820) e (889, 946) em fonte maior que os ícones e
maior que tudo no anel; não dizem o que medem. A legenda (1450, 975) diz "Escuro: falta Maestria ou outro Dom", sem
ligar ao número.
Pedido: no nó escuro, o leão pequeno da Maestria (o mesmo glifo da coroa) em cima, a 35% da altura do nó, e o número
embaixo com no máximo 60% do tamanho atual, em pergaminho a 70%. Nós escuros todos do mesmo tamanho dos nós abertos
do mesmo nível (hoje 16, 18 e 20 são maiores e puxam o olho para o que não se pode usar). Legenda: "Escuro: o número é
a Maestria que falta" (texto novo em `text_pt.tres`). Aceite: o maior elemento do anel é um nó aceso ou o em foco,
nunca um escuro.

### 5. Videira: broto comprado só com o visto (P1, `ui-ux-designer`)
`videira_1080.png` (360..550, 640..710) e (768..960, 550..620): a etiqueta virada mostra só o ✓ verde, e o jogador não
sabe o que comprou (`VineTag`, "blank back with a green check").
Pedido: verso com o nome (mesma fonte, pergaminho escuro) e o visto pequeno (18 px) à esquerda do nome, sem preço;
fundo da etiqueta um tom mais verde (0,36; 0,42; 0,26) para separar de "à venda". Junto: preço fora de alcance em
rubrica sobre barro tem pouco contraste ("10" em (320, 505)); rubrica mais escura (0,55; 0,10; 0,08) com contorno
pergaminho de 1 px. Aceite: nas 9 etiquetas o nome é lido em todas as situações.
Placeholder: vaso retangular (620..845, 905..1070) e treliça; esperam a arte do ChatGPT.

### 6. Encanto: três ichthys iguais (P1, `ui-ux-designer`)
`encanto.png`: o medalhão de cada carta (470..600, 270..400 e os outros dois) é o mesmo peixe; o que muda entre as
cartas só aparece na linha pequena "Muda: Ataque/Esquiva".
Pedido: o medalhão mostra o glifo do golpe que muda (os mesmos da barra de ações), a 70% do diâmetro; o ichthys vira
selo pequeno (28 px) no canto inferior direito do medalhão. Aceite: cartas que mudam golpes diferentes têm medalhões
diferentes à primeira vista. Placeholder: a espada na pedra à esquerda (20..315, 245..770) é vetor chapado e destoa dos
anjos pintados; espera arte.

### 7. GR-8 raio-x de pontinhos (P1, `technical-artist`)
`dicas.png` (480..690, 430..640): o bloco ao lado do herói mostra a grade de pontos. `assets/shaders/see_through.gdshaderinc`
ainda usa `bayer4`. Pedido: no Forward+ o esmaecimento contínuo (alfa até 0,35 com borda suave de 0,6 m ao redor do
herói); o pontilhado fica só no Compatibility. Aceite: captura GPU 1080p com o herói atrás de pilar sem grade de pontos
visível.

### 8. Retrato da Maga no HUD (P1, asset)
`maga_bastao.png` (30..125, 815..910): rosto de aspecto fotográfico ao lado do retrato pintado do Guerreiro; quebra a
identidade. Pedido: retrato pintado no mesmo traço do Guerreiro (pedido ao ChatGPT pelo Daniel; ela é do norte, traços
orientais, âmbar). Até lá, recorte do modelo dela no jogo. Dono: `ui-ux-designer` troca o arquivo.

### 9. Legenda da habilidade ao lado de "Espaço" (P2, `ui-ux-designer`)
`dicas.png` (1015, 893): "Brado de Guerra" aparece colado ao losango Espaço (a esquiva), e o Brado é o E. Pedido: a
legenda sobe acima do losango que foi usado, ou some. Aceite: nome e tecla sempre do mesmo losango.

### 10. Encontro dos anjos (P2, `ui-ux-designer`)
`encontro_dois_anjos.png`: composição boa (anjos nas laterais, painel embaixo, título no alto). Por cima ficam
"Sala 1 de 14" (30, 31), o relógio "0:00" (835, 27) e a coluna de Dons atravessando a asa do anjo da direita
(1620..1660, 260..600). Pedido: durante o encontro esconder relógio, contador de sala e coluna da direita (como já se
faz com a barra de ações). FEITO no resto.

### 11. Vendedor (FEITO como placeholder, P2)
`vendedor_1080.png`: a balança lê bem, a troca está clara, "Erguida" funciona. Faixa vazia de 900 a 1080 e toldo
chapado; esperam a arte do ChatGPT (`assets/ui/shop/`).

### 12 a 15. FEITOS
- Medalhão dos Dons (`dons_pedestal.png`): lê como peça própria, o leão aparece, o halo marca a estação. O rótulo da
  captura ainda diz "Árvore de Dons"; o texto já é "Medalhão dos Dons" (`f942580`), a captura é anterior. A Videira no
  Santuário (1350..1430, 440..520) é um vasinho pequeno demais para a estação; fica para a arte da Videira (P2,
  `environment-artist`).
- Dicas (`dicas.png`): caixa escura com borda fina, centro baixo, não cobre o herói. Bom.
- Maga com o bastão aceso (`maga_bastao.png`): a esfera âmbar marca a arma; silhueta lê sobre o chão.
- Luz morna de Morvath (`morvath_hard_2026-11-23.png`): chão quente com borda violeta, Morvath escuro e herói legíveis,
  sem marca no chão fora do selo.

### 16 e 17. SAI
- GR-17: desde `159f206` Morvath não desenha fita no chão (só erupções e o "!"); a captura de Morvath não mostra fita.
- GR-19: o besteiro não tem `ground_warning` (PT-1), então a mira não é desenhada. Confirmar com a captura 6 abaixo; se a
  linha ainda aparecer, volta como AJUSTAR (`technical-artist`, proposta original da revisão 2026-11-21b).

### 18. Sem captura útil
- Trinca e Varredor (`comuns_trinca_varredor.png`): não dá para apontar qual figura é a Trinca (baixa, larga, três
  corcundas) nem ver a faixa do Varredor; as figuras grandes estão cortadas na borda esquerda e as barras de vida se
  empilham (250..500, 470). Captura 1.
- Canalizador: só o laboratório (`lab_game.png`, silhueta com orbes distinta do feiticeiro, bom); falta em jogo e a morte.
  Captura 2.
- Portas com anel, selo e caixa (PT-10): `porta_caixa.png` não mostra porta nenhuma. Captura 3.
- Película e relógio da Suspensão Absoluta: captura 4.
- GR-18 besta (código igual: `INK_EDGE` 0,09) e GR-19: captura 6. GR-20 arco do giro (`body_sat` 0,5 no
  `crescent.gdshader`, igual): captura 5. GR-26 duas barras do guardião: captura 7. GR-27: os números diretos
  ("55", "35") leem brancos com contorno, bom; falta o dano por tempo: captura 8.

## Capturas que faltam (sessão principal, uma por vez)
1. `tools/gpu.sh shot docs/gallery/review_2026-11-23/trinca_varredor.png --stress=4 --stress-ids=trinca,varredor --hero-hp=99999 --seed=5 --shot-at=3`
2. `tools/gpu.sh shot docs/gallery/review_2026-11-23/canalizador.png --stress=3 --stress-ids=canalizador --hero-hp=99999 --bot --seed=5 --shot-at=6`
3. `tools/gpu.sh shot docs/gallery/review_2026-11-23/portas.png --bot --autopick --seed=5 --shot-on=reward --shot-after=1.5`
4. `tools/gpu.sh shot docs/gallery/review_2026-11-23/suspensao.png --bot --autopick --seed=5 --hero=maga --ultimate=dome_abs --ult-full --shot-on=ult --shot-after=2`
5. `tools/gpu.sh shot docs/gallery/review_2026-11-23/giro.png --bot --autopick --seed=5 --shot-on=spin --shot-after=0.1`
6. `tools/gpu.sh shot docs/gallery/review_2026-11-23/besteiro.png --stress=3 --stress-ids=archer --hero-hp=99999 --seed=5 --shot-at=4`
7. `tools/gpu.sh shot docs/gallery/review_2026-11-23/guardiao.png --bot --autopick --start=miniboss --seed=5 --shot-at=8`
8. `tools/gpu.sh shot docs/gallery/review_2026-11-23/numeros_dot.png --bot --autopick --boons=25 --seed=5 --shot-at=9`
9. Laje armada depois do item 1: a mesma sala de `porta_caixa.png` (o comando que gerou essa captura), no momento da laje acesa.

Se `--shot-on=spin` ou `--shot-on=reward` não existirem com esse nome, `--shot-at` no segundo certo serve.
