# Revisão de arte: Sworn P1 (SW-G1, SW-G2, SW-G3, SW-C1, SW-F1, SW-K1), mais RS-C1 e LC

Autor: `art-director`, 2026-11-19. Build revisado: `d2ff05d` (Sworn P1 entrou em `41f8b91`, `e950142` e `bbe3872`).
Contexto: o Daniel testou esse build e disse "ainda precisa de muitas melhorias". **A aprovação artística final é dele.**

Material avaliado (todas capturas reais na RTX 5060, Forward+, perfil STYLIZED, que é o padrão do exe):
- esta pasta: `before_*`/`after_*` (vitrine 5 s e luta 9 s de cada sala, clássico e laboratório), `g3_*`, `c1_*`,
  `f1_*` (com recortes `*_detail_*` e `*_compat_after`) e `k1_*`;
- `docs/gallery/redesign/rs_c1/` (coroa de velas e a velada da Cripta) e `docs/gallery/lc/windup/after2/` (besteiro e
  sacerdote);
- `docs/art/sworn_reference_ideas.md` (as ideias e os limites) e o `CLAUDE.md` (seção "Sworn P1, chão").
- Medida minha: `python3 -I tools/frame_stats.py --hue --scene` em `before/after_stylized_garden0_9.jpg` e
  `before/after_stylized_hall_9.jpg` (Jardim: cena luma p50 48 para 49, p90 90 para 97, sat p50 0,21 para 0,26, verde
  0,1 para 0,4%; Salão: cena p50 60 para 65, p90 99 para 113, saturação igual). Os números do environment-artist no
  `CLAUDE.md` batem com o que vejo nas imagens.

Nada aqui foi implementado por mim. Prioridades: **P0** bloqueia o teste do Daniel, **P1** corrigir neste ciclo, **P2**
quando houver folga.

## Veredito curto

| Item | Veredito |
|---|---|
| SW-G1 manchas do bioma | **Aprovado.** O chão do meio abriu (faixa p10 a p90 +10 a +24) sem passar do teto de saturação; o Jardim ficou mais verde, mas na faixa do musgo seco (matiz da cena 91, verde 0,4%) |
| SW-G2 sombra recortada | **Aprovado com P2.** Lê como luz filtrada no Jardim e no Santuário; no Santuário as nervuras quase não se distinguem de mancha (G-2) |
| SW-G3 lajes emolduradas | **Aprovado com P1** no Salão (podem ler como placas de pressão, S-1) e **não verificável** no Santuário (não aparecem na câmera do jogo, S-2) |
| SW-C1 lajes tumulares | **Aprovado com P1**: as tumulares novas leem bem; as escuras perto da borda sul leem como alçapão ou buraco (C-1) |
| SW-F1 coluna tombada | **Desvio de material aprovado** (cantaria no lugar da pedra funda); **forma reprovada** como está: lê como cano ou viga que dá para andar (F-1, F-2) |
| SW-K1 gaiolas | **Aprovado.** Silhuetas claras, longe de Morvath, sem brilho; P2 de escala (K-1) |
| RS-C1 Criptas | **Aprovado.** A coroa de velas é a melhor peça nova do estilizado; P2 no excesso de grupos de velas (R-1) |
| LC besteiro e sacerdote | **Aprovado para leitura**, P2 de acabamento: os traços brancos leem como interface sobreposta, não como pintura (L-1) |

## 1. SW-G1 e SW-G2, o chão

| Bate | Difere |
|---|---|
| O chão do meio tem variação em escala grande (manchas de 3 a 8 m) por baixo da luta, como o princípio P1 pede; avisos e figuras com o mesmo contraste (fio da mira menos o chão: diferença de no máximo 5 para menos na Cripta B) | O Salão ficou mais claro no todo (cena p50 60 para 65, p90 99 para 113): o portal e os braseiros perderam um pouco de destaque relativo (`after_stylized_hall_9.jpg`) |
| Jardim: sombra de folhas debaixo da copa; liga o chão à árvore | No Jardim o verde das manchas soma com o musgo pintado e a grama: o chão inteiro lê "verde", e os cristais ciano na base da árvore (de antes) ficam ainda mais isolados como o único ponto saturado (`after_stylized_garden0_9.jpg`) |
| Santuário: fachos com recorte | As nervuras da abóbada leem como manchas comuns na câmera do jogo; só no recorte de perto se vê a forma (`after_stylized_sanct0_5.jpg`) |

## 2. SW-G3 e SW-C1, lajes emolduradas e tumulares

- **Salão** (`g3_hall_vit_after.jpg`, `g3_hall_detail_after.jpg`): os dois pares dos lados do eixo do altar leem como
  quatro quadrados iguais, claros, de moldura baixa. O ritmo no eixo melhora, mas: (a) são idênticos em tamanho, valor
  e rotação, e (b) num jogo com Câmara das Runas (lajes que ferem) quatro placas quadradas e mais claras que o chão em
  volta podem ser lidas como **placas de pressão**. Ver S-1.
- **Cripta** (`c1_crypt0_detail_after.jpg`, `c1_crypt1_detail_after.jpg`): as tumulares novas, com sulco e o leão
  pequeno, são do valor do chão e leem como "chão de cripta", que era o objetivo. O par emoldurado dos lados do túmulo
  grande funciona. Porém as lajes escuras que já existiam antes do SW-C1 (as antigas, peças da Cripta do C12, por exemplo a de
  (165, 620) no recorte da A e a de (690, 560) no da B) são quase pretas com moldura clara: leem como **alçapão,
  grade ou buraco**, e o jogo tem buracos de verdade (D-28). Ver C-1.
- **Santuário** (`g3_sanct0_vit_after.jpg`, `g3_sanct0_fight_after.jpg`): as três lajes diante da grade não se
  distinguem na vitrine nem na luta. Ou estão debaixo da passadeira e das oferendas, ou o relevo é fraco demais nessa
  luz. Ver S-2.

## 3. SW-F1, a coluna tombada das Fendas

Capturas: `f1_rift0_vit_after.jpg`, `f1_rift0_detail_before.jpg` e `_after.jpg`, `f1_rift1_fight_after.jpg`.

**O desvio de material (cantaria da sala no lugar da pedra funda): aprovado.** A spec pedia pedra funda; o
environment-artist mostrou que ela ficava preta contra o escuro da fenda e não lia. Uma peça que não se vê não cumpre o
objetivo ("um marco que só as Fendas têm"). A cantaria é a pedra certa para algo que caiu da sala.

**A forma, como está: reprovada.**
1. **Lê como cano ou viga, não como coluna.** Os tambores são cilindros lisos do mesmo raio (0,55 m), sem caneluras,
   anel, base nem capitel; de cima, a 54 m, o que se vê é um tubo atravessando o buraco, com uma corrente. No recorte
   `f1_rift0_detail_after.jpg` a metade leste lê literalmente como um cano saindo de uma parede.
2. **Lê como passagem.** Com o topo a -0,3 m nos lábios e o valor igual ao do chão (cantaria acesa pela mesma luz), ela
   parece uma viga em que dá para andar por cima do vão. Não colide e não deve: isso promete uma rota que não existe.
3. **Some na câmera do jogo.** O pedaço do meio fica atrás da ponte sul (dito no `CLAUDE.md`) e as duas pontas são
   curtas: na vitrine da A sobra um toco junto ao lábio oeste que lê como bloco solto.

Pedido de correção: F-1 e F-2 abaixo.

## 4. SW-K1, gaiolas da Câmara do Selo

Capturas: `k1_fase1_stylized.jpg`, `k1_detalhe_oeste.jpg`, `k1_detalhe_leste.jpg`, `k1_fase4_stylized.jpg`.
Bate: silhueta de gaiola inequívoca, ferro escuro sem brilho, longe de Morvath, balançando devagar; uma de porta aberta
dá história sem lore. Difere: a de cima à esquerda (`k1_fase1_stylized.jpg`, (320, 330)) fica pequena perto da corrente
grossa (o elo tem quase o tamanho da gaiola), o que achata a escala: corrente de navio, gaiola de passarinho. Ver K-1.

## 5. RS-C1, Criptas

Capturas: `rs_c1/after_game_0_9.jpg`, `after_game_1_9.jpg`, `after_lab_*`.
- **A, coroa de velas**: é o foco que a Cripta não tinha; anel quente no alto, correntes, poça sobre o túmulo, pano
  petróleo com o leão. Aprovado.
- **B, a velada**: lê de longe como figura grande que guarda o ossuário; a lanterna fria dá o contraponto. Aprovado.
- **Difere**: há grupos de três velas em quase todo nicho, tampa e coluna (conto 12 grupos acesos na A, além da coroa).
  O quente fica em pontos espalhados e a coroa compete com eles. Ver R-1.

## 6. LC, besteiro e sacerdote

Capturas: `lc/windup/after2/archer_aim_strip_before_after.jpg`, `priest_back_strip_before_after.jpg`,
`mixed_stylized_t26_before_after.jpg`.
- Besteiro: a besta em traços de 64 a 70 px lê a 1080 e aponta para onde a mira aponta; a linha da ponta até o fio do
  chão liga quem mira a por onde o virote passa. Leitura aprovada.
- Sacerdote: o V dos braços em luz violeta lê de costas e no meio de outros. Leitura aprovada.
- **Difere**: os dois são desenhos vetoriais brancos ou violeta por cima do corpo; ao lado das figuras pintadas leem
  como sobreposição de interface (um ícone colado na figura), não como luz do mundo. É o preço da leitura e aceito para
  o teste; ver L-1.

## 7. Pedidos de correção

| Id | Prioridade | O quê, com valores | Critério de aprovação (captura) | Dono |
|---|---|---|---|---|
| F-1 | **P1** | Coluna tombada que lê como coluna: caneluras rasas no shader ou na malha (12 a 16 sulcos), um toro de base numa ponta e o capitel quebrado (ábaco quadrado, como `ArenaRoom.column_kind`) caído junto da quebra, tambores com raio variando 0,5 a 0,62 e girados entre si; raio maior, 0,7 m, para ler a 54 m | Na vitrine da A e da B (`--arena=rift --variant=0/1 --look=stylized --showcase --shot-at=5`, 1920 x 1080) alguém de fora diz "coluna caída" sem dica; ponta oeste e quebra visíveis fora da ponte | environment-artist |
| F-2 | **P1** | Coluna que não promete passagem: valor a 0,7 da cantaria (entre a cantaria e a pedra funda, fica legível e abaixo do chão), topo a -0,6 m nos lábios (era -0,3), afundando mais para a quebra (`FALLEN_COLUMN_SAG` 7 para 12 graus), e uma das metades torcida 15 a 20 graus no plano para quebrar a reta lábio-lábio | Na mesma captura, luma p50 da coluna 15 a 25 abaixo do chão em volta e acima do fundo da fenda; nenhum trecho reto e contínuo de lábio a lábio | environment-artist |
| C-1 | **P1** | Lajes tumulares escuras da Cripta (as antigas, de antes do SW-C1; o SW-C1 as deixou iguais de propósito, mas agora elas destoam das novas): interior no valor do chão vezes 0,85 a 1,0, nunca abaixo de 0,7, moldura e sulco como as novas; nada preto dentro de um retângulo no chão andável | `--arena=crypt --variant=0/1 --look=stylized`, luta 9 s: nenhuma laje com luma p50 menor que 0,7 da luma do chão a 1 m dela (hoje cerca de 0,3) | environment-artist |
| S-1 | **P1** | Salão: as quatro lajes emolduradas com tamanhos e valores diferentes (2,0 a 2,8 m, `framed_lip` mais baixo, interior a 1,0 do chão, não mais claro), uma com o leão gravado (GRAVE) e uma com a moldura partida num canto; nunca as quatro iguais | Vitrine e luta do Salão: as lajes leem como piso nobre, não como botões; nenhuma mais clara que o chão em volta (luma p50 dentro de ±8) | environment-artist |
| S-2 | **P2** | Santuário: as três lajes diante da grade visíveis na câmera do jogo (mover para fora da passadeira ou subir o relevo para o do Salão) | Vitrine do Santuário A: as três lajes visíveis | environment-artist |
| G-1 | **P2** | Salão: devolver o destaque do portal depois do SW-G1 (`patch_rest` 0,9 do Salão ou mancha mais fraca na faixa entre o medalhão e a escada) | `after_stylized_hall_9` refeita: luma p90 da cena até 105 (hoje 113) com o portal igual | environment-artist |
| G-2 | **P2** | Santuário: nervuras do gobo mais nítidas e mais escuras (até 0,35 no facho, só ali) | Na vitrine, a abóbada partida reconhecível na mancha do facho | technical-artist |
| K-1 | **P2** | Gaiolas um terço maiores (ou a corrente das gaiolas um terço mais fina que a das arcadas), uma com um osso ou trapo dentro (sem lore) | `k1_fase1_stylized` refeita: gaiola pelo menos 2,5 vezes a largura de um elo da corrente | environment-artist |
| R-1 | **P2** | Cripta A: apagar metade dos grupos de velas de nichos e tampas (como o VX-13 fez no Salão), deixando a coroa, o túmulo grande e as estátuas | Luta 9 s: parte quente fora da coroa menor que a da coroa | environment-artist |
| L-1 | **P2** | Besteiro e sacerdote: traços com a borda da tinta mais grossa e o corpo do traço no tom da madeira/osso da arma (besteiro) e no violeta mais escuro (sacerdote), mantendo o tamanho; nada de branco puro | Tira de antes e depois: mesma área do ícone e luma p50 do traço 170 a 200 (hoje 217 a 219) | technical-artist |

## 8. O que depende de modelo que não existe

- Coluna tombada esculpida e o arco desmoronado (SW-A3, 15 créditos) melhorariam F-1, mas o procedural resolve; não pedir.
- Crânios para o ossuário (SW-A1) seguem fora do P1.

## 9. Para o Daniel testar

Sworn P1 pode ir no mesmo pacote do hub, **depois de F-1, F-2 e C-1**: hoje a coluna e as lajes escuras prometem coisas
de jogo (passagem, buraco) que não existem, e isso o Daniel vai sentir como "estranho". O resto está aprovado
tecnicamente.
