# AT-Q0: os quebráveis, spec de arte

Dono: `art-director`. Para: `environment-artist` (peças), `technical-artist` (quebra, cacos, água, som: AT-Q2 e AT-Q3),
`room-designer` (lugares: AT-Q4), `gameplay-engineer` (lógica: AT-Q1). Data: 2026-11-21. Lido: `docs/backlog.md`
(pacotes do PO de 2026-11-20, P.2 e P.3), o atlas do PO, `docs/design/rooms_progression.md` (RP-12, RP-24),
`docs/art/vfx_pass_spec.md` (3 e 4), `docs/art/sw_g7_hazard_grammar.md`. Sem Meshy: peças procedurais no `Masonry` e no
`ArenaKit` (há `Masonry.urn`, `Masonry.crate`, `TombKit.bench`), cacos pela MultiMesh de lascas do `Fx`.

Decisões que valem aqui (Q-AT2 a): quebrável **não dá nada** no primeiro lote; **nenhum no hub**; MVP sem barrar corpo
nem tiro (raio até 0,45 m). Nada do que segue muda essas regras.

## 1. A regra em cinco frases

1. Quebrável é **coisa comum de quem viveu ali**: terra, barro, madeira, galho. Fosco, sem metal brilhante, sem luz
   própria, sem marca gravada.
2. **Nunca a gramática do perigo** (SW-G7): sem divisa, sem fenda com brasa, sem junta escura, sem ferro com rebites, sem
   âmbar. Nunca verde da Emeth, nunca vermelho do perigo (349 a 4) nem o carmim e magenta dos inimigos (330 a 355), nunca
   violeta nem lilás (o lilás é da Provação).
3. **Baixo e encostado**: 0,35 a 1,0 m de altura, sempre em grupo de 2 a 5 encostado em parede, balaustrada, coluna ou
   peça; nunca no meio do chão de luta, nunca no eixo de uma sala.
4. **Lê contra o chão, some contra as figuras**: o corpo no valor do chão em volta, separado dele por um lábio claro em
   cima e uma sombra de contato embaixo; sempre mais baixo e mais apagado que qualquer figura.
5. **Quebra limpa e curta**: o objeto some no quadro do golpe; cacos do material voam baixo, caem, ficam 4 s no chão e
   afundam; nada barra depois.

## 2. Por material

Tamanho é a altura (a largura cabe no raio de 0,45 m). Valores de material no estilizado; o clássico usa a mesma peça com
o `kaykit`/`masonry` de sempre.

### 2.1 Cerâmica (vaso, urna, oferenda)

- **Vaso**: 0,5 a 0,8 m, barriga larga, pescoço estreito e boca com lábio virado (a silhueta da ânfora sem alças, ou com
  duas alças pequenas); **urna**: 0,6 a 1,0 m, ombro alto e tampa baixa; **oferenda**: 0,35 a 0,5 m, tigela larga, jarro
  pequeno ou pilha de duas tigelas.
- Material: barro fosco com uma **faixa pintada** (um anel de 0,05 m no ombro, de cor do bioma, tabela 3), boca escura por
  dentro, base mais escura. Nenhum brilho especular acima de 0,15.
- **Quebra**: 6 a 10 cacos curvos (forma lente do `chip.gdshader`, `Fx.SHAPE_*`), o lado de fora na cor do corpo e o de
  dentro um passo mais claro (barro sem pintura); a boca sai inteira em 1 caco maior; 3 fiapos de pó do barro (`Fx.wisps`,
  cor do barro a 1,3) subindo 0,6 m e se desfazendo em 0,5 s; cacos com gravidade, quicam uma vez, saltam no máximo 0,5 m.
- Oferendas de altar e de presbitério (Santuário, Altar, Provação) podem ter 2 ou 3 contas, pão de pedra ou pétalas
  secas dentro que caem junto (cacos claros pequenos); nunca moedas (não dá ouro).

### 2.2 Vaso de água

- Silhueta: vaso alto de 0,6 a 0,8 m com **boca larga** e **faixa úmida escura** da metade para baixo (valor 0,7 do corpo,
  brilho especular 0,25 só nela) e uma gota escura no chão em volta do pé (decalque de 0,6 m, alfa 0,3): é isso que diz
  "tem água" antes de quebrar.
- **Quebra**: os cacos da cerâmica, mais 8 traços curtos de água cinza-azulada (forma farpa, matiz 200 a 210,
  saturação até 0,25, valor até 0,7, nunca brilho acima de 200 na tela) espirrando baixo (até 0,4 m); **decalque de água**
  no chão (`floor_decal`): mancha escura de borda irregular que se abre de 0,3 a 1,0 a 1,4 m de raio em 0,25 s, um brilho
  fino de borda (0,04 m, valor 0,6), e **seca em 3 s da borda para o meio** (o brilho some primeiro).
- Proibido (a Fonte e a cura): nada verde, nada que brilhe por si, nenhum anel, nenhuma subida de partículas claras.

### 2.3 Madeira (caixote, tábua, banco rachado)

- **Caixote**: 0,6 a 1,0 m, cubo de tábuas com duas travessas e as cabeças dos pregos escuras (sem metal claro);
  **tábua solta**: 1,0 m encostada inclinada numa parede ou empilhada de 3 deitadas (0,35 m); **banco rachado**: meio banco
  de 1,0 m com uma perna quebrada e a tábua do assento rachada no meio, apoiado no chão por uma ponta.
- Material: madeira velha fosca a 0,5 da saturação e 0,8 do valor (o `wood_*` do `masonry.gdshaderinc`, como os
  caixotes do Salão), lábio claro das tábuas a 0,35.
- **Caixote, dois golpes**: o 1º racha uma tábua da frente (risco escuro diagonal, a tábua cede 2 graus), 3 farpas; o 2º
  quebra.
- **Quebra**: 6 a 8 farpas longas (forma farpa, 0,1 a 0,3 m) e 2 ou 3 pedaços de tábua que caem deitados e ficam 4 s; pó
  de madeira pálido em 3 fiapos.

### 2.4 Galho (galho seco, muda frágil)

- **Galho seco**: feixe de 3 a 5 galhos tortos de 0,6 a 1,0 m, de pé encostados na parede ou caídos em monte de 0,35 m,
  casca cinza-castanha (matiz 25 a 35, saturação até 0,25, valor 0,35 a 0,45).
- **Muda frágil**: 0,35 a 0,5 m, caule fino e 6 a 10 folhas **redondas e moles**, **pálidas** (marfim-ocre, matiz 40 a
  55, saturação 0,15 a 0,30, valor 0,55 a 0,70), crescendo de terra solta, nunca de uma laje. É o contrário da Planta
  Hostil (escura, alta, pontuda, numa laje com divisa: SW-G7 3.5).
- **Quebra**: galho estala em 2 ou 3 pedaços que caem e ficam 4 s, 6 fibras finas (forma farpa, 0,08 m); muda dobra no
  caule e 6 a 10 folhas caem devagar (gravidade 0,4, balançando de lado), ficando no chão como as folhas caídas do Jardim
  (`kind` 3) por 4 s.

## 3. Cor por bioma (na tela, estilizado; o room-designer escolhe os materiais pela coluna "Quebráveis" do P.2)

| Sala | Materiais | Corpo (matiz, saturação, valor do material) | Faixa pintada ou detalhe |
|---|---|---|---|
| Salão, Fonte, Loja | vasos, urnas menores, banco rachado; vasos de água na Fonte a 5 m ou mais da bacia; caixotes e cerâmica na Loja a 3 m ou mais dos relicários | barro cinza-terra (22 a 30; 0,25 a 0,35; 0,38 a 0,48) | petróleo apagado (190 a 200; 0,30; 0,30), não o petróleo saturado do herói |
| Cripta A e B | cerâmica funerária, vasos menores, restos de bancos | barro claro cinza-osso (30 a 38; 0,10 a 0,18; 0,45 a 0,55) | terra escura (20; 0,30; 0,25) |
| Fendas A e B | madeira solta e caixotes junto dos acessos | madeira cinza (25 a 35; 0,18 a 0,25; 0,35 a 0,45) | tábuas sem pintura; silhueta quadrada contra o arco e a laje das pontes |
| Ponte A e B | tábuas soltas e caixotes longe da linha principal | como as Fendas | idem |
| Jardim A e B | galhos secos, mudas frágeis, vasos de água perto da borda úmida | barro terracota apagado (18 a 25; 0,30 a 0,40; 0,35 a 0,45) com musgo seco oliva no pé | faixa de ocre pálido (40; 0,30; 0,50) |
| Santuário A e B, Guardião | recipientes de oferenda nas laterais e no presbitério, longe das lajes | barro calcário claro (32 a 40; 0,15 a 0,25; 0,50 a 0,60) | ocre (38; 0,40; 0,45) |
| Runas A e B | suportes de madeira e recipientes de pedra encostados nas paredes | pedra-sabão cinza (215 a 230; 0,08 a 0,12; 0,40 a 0,50), madeira cinza | sem faixa; nada âmbar, nada redondo grande (as Runas são retas, D-29: tigelas baixas e caixas) |
| Provação | oferendas de cerâmica comum | barro cinza-terra do Salão | **nunca lilás**, nunca na pedra da estela |
| Altar | oferendas longe do degrau e das velas acesas | barro morno (20 a 28; 0,30 a 0,40; 0,40 a 0,50) | terra (16; 0,35; 0,30) |
| Câmara do Selo | só no patamar de entrada e na periferia de 11 a 12 m | barro escuro (230 a 250 de matiz no ar da câmara; 0,10; 0,30 a 0,38) | sem faixa; nunca violeta |

## 4. Leitura contra o chão e as figuras

| Medida (captura Perto com HUD, 1920 x 1080, `frame_stats.py --box`) | Alvo |
|---|---|
| Corpo do quebrável contra o chão a 1 m | luma p50 entre 0,85 e 1,15 do chão; separação pelo lábio e pela sombra |
| Lábio claro de cima (0,03 a 0,05 m) | luma 1,25 a 1,45 do corpo |
| Sombra de contato (decalque de 0,2 m em volta do pé) | 0,6 a 0,75 do chão |
| Saturação p50 do corpo | 0,10 a 0,40 (sempre abaixo da do herói, do perigo armado e dos efeitos) |
| Contra o esqueleto e o Escudo ao lado | altura até 0,5 da figura; nenhum quebrável mais claro que o osso da figura na mesma luz |
| Contra o perigo | nenhum pixel do quebrável na faixa âmbar com saturação acima de 0,30 |

Silhuetas por material para lerem diferentes de relance: cerâmica redonda e cheia, água redonda com a faixa escura e a
gota no chão, madeira quadrada de arestas retas, galho linear e espetado, muda baixa e redonda. Cada grupo de uma sala usa
1 ou 2 materiais, nunca os quatro.

## 5. Quebra na luta (para o AT-Q2)

- No máximo 3 quebras cheias por quadro; as outras só com cacos (orçamento próprio no `FxBudget`, separado das lascas do
  combate). Cacos nunca acima de 200 na tela, nunca na caixa de 300 x 300 px do herói com mais de 4 de uma vez (eles
  caem em volta da peça, longe dele quando ele está a mais de 1,5 m).
- Os cacos caem no chão (gravidade, um quique), ficam 4 s e afundam 0,05 m em 0,5 s até sumir; não colidem.
- Quebrar não dá número, não dá pisca, não dá câmera lenta, não para o mundo (sem hit stop).
- Som por material (AT-Q3) abaixo dos avisos de Morvath e dos golpes do herói.

## 6. Aceite

1. Tabuleiro de referência (`tools/edge_lab.gd` ou um laboratório novo no molde) com os nove objetos inteiros e quebrados,
   e uma captura Perto com HUD em cada sala do Atlas 1 (Salão, Cripta A e B, Jardim B, Santuário A e B) com os grupos no
   lugar e uma luta em curso; as medidas da seção 4 na legenda.
2. A muda frágil e a Planta Hostil na mesma captura do Jardim B (SW-G7 3.5); a cerâmica e a urna de óleo na mesma
   captura da Cripta tardia (SW-G7 3.10).
3. Três quebrando juntas com o herói e um aviso vermelho no quadro: o herói e o aviso legíveis (combat-feel-director).
4. Clássico com as peças (são jogo), F7 exato, iGPU 720 Baixa até 0,5 ms com 12 peças na sala.

Pendente: as capturas de referência pedidas pelo AT-Q0 dependem das peças existirem (AT-Q2); até lá as referências na
câmera são os vasos e urnas de cenário que já estão nas salas (`Masonry.urn` da Cripta e do Santuário, caixotes do Salão,
`kind` 3 das folhas do Jardim), que servem de régua de tamanho e valor.
