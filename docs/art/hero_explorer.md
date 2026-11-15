# Herói "Explorador": análise da folha, pedido ao Meshy e critérios

Folha conceitual aprovada pelo Daniel em 2026-11-14 (feita por IA; fora do repositório, no scratchpad da sessão:
`hero/sheet.png`, 1536 x 1024). Recortes que vão ao Meshy: `tools/meshy/ref/hero_explorer/` (`front`, `side`, `back`,
`threequarter`, 1200 x 1200, sem espada). Este modelo substitui o "Sombra" (`assets/models/meshy/hero_sombra/`) como
herói do jogo. A espada Emeth é outro asset (seção 4).

Medidas tiradas dos recortes (pixels em 1200 x 1200) e da folha; cores pela média de 7 x 7 pixels no ponto.

## 1. Análise da folha

### Proporções (vista de frente, `front.png`)

| Marco | Altura na imagem (px, de cima) | Fração da altura, a partir do chão |
|---|---|---|
| Topo do cabelo | 35 | 1,00 |
| Topo do crânio (sem o volume do cabelo) | cerca de 60 | 0,98 |
| Queixo | 192 | 0,86 |
| Topo das ombreiras | 250 | 0,81 |
| Cinto (fivela) | 465 | 0,62 |
| Entreperna | 680 | 0,43 |
| Ponta dos dedos | 670 | 0,44 |
| Punho das botas (joelho) | 880 | 0,26 |
| Sola | 1175 | 0 |

- **Altura**: cerca de 7,5 cabeças contando o volume do cabelo; cerca de 8,5 medindo só do crânio ao queixo. É
  proporção heroica adulta, não cabeçuda: nada de Slender para encolher a cabeça.
- **Ombro e quadril**: ombros com as ombreiras 350 px; cintura no cinto cerca de 190 px. Razão perto de 1,8: tronco
  em V, atlético. Os braços são nus do ombro ao antebraço e bem definidos (o ponto mais perto de "bárbaro" da folha;
  ver perguntas).
- **Pernas**: entreperna a 0,43 da altura (a calça larga e o saiote baixam a leitura; a perna é longa). Botas altas
  até o joelho com punho largo de couro e latão.
- **Mãos**: punhos meio fechados, braços quase colados ao corpo (não está em pose A; ver riscos).

### Paleta (hex tirado da imagem)

| Parte | Luz | Meio | Sombra | Amostra da paleta da folha |
|---|---|---|---|---|
| Cabelo cobre | `#e15e26` | `#a9340d` | `#49150a` | |
| Cachecol e manto (azul-petróleo) | `#5a8767` | `#395c4a` | `#173025` | `#234648` |
| Túnica (aba da frente, verde acinzentado) | | `#495749` | | |
| Couro escuro (colete, cinto) | | `#4b2e29` | `#402621` | `#362727` |
| Couro claro (correias, bolsas) | `#bf702c` | `#975b36` | | |
| Calça | | `#3d2a26` | `#231e22` | |
| Botas, braçadeiras e luvas | `#b77c50` | `#573223` | `#4c271b` | `#5a3d30` |
| Dourado e latão (fivela, broche, estrela, barra do manto) | `#e6c970` | `#d4973b` | `#7f6c37` | `#b87b40` |
| Aço das ombreiras (morno, reflete o ambiente) | `#977e82` | | `#464349` | |
| Pele | `#f3ac7c` | `#e28e61` | `#c68164` | |
| Verde da Emeth (só a espada) | | | | `#20a462` |

Leitura: corpo de valores escuros e quentes (couro e calça perto de `#3d2a26`), dois blocos de cor que contam a
silhueta (cobre no topo, azul-petróleo no pescoço e nas costas) e o dourado em acentos pequenos. O verde saturado e
brilhante é só da espada; o azul-petróleo do pano é apagado e não deve virar verde de efeito.

### Materiais e camadas (de dentro para fora)

1. Túnica de pano verde acinzentado, aparece no peito entre as correias e numa aba que desce na frente até o meio
   da coxa.
2. Colete de couro escuro sem mangas; braços nus.
3. Correias de couro claro cruzadas no peito (X com placa quadrada no meio); cinto largo com fivela retangular de
   latão (a folha põe "אמת" na fivela); segundo cinto baixo, bolsas pequenas no quadril direito e esquerdo.
4. Saiote de couro em abas com borda de latão sobre a calça, até o meio da coxa.
5. Ombreiras de aço com borda de latão nos dois ombros (a esquerda fica sob o pano).
6. Cachecol azul-petróleo grosso, enrolado alto no pescoço, como um capuz caído atrás.
7. Manto curto azul-petróleo: preso no ombro esquerdo por um broche redondo dourado, cai pelas costas até a
   panturrilha em ponta, barra irregular com filete dourado e uma estrela dourada de quatro pontas nas costas.
8. Braçadeiras de couro com anéis de latão, luvas sem dedos, calça larga escura presa nas botas, botas de couro
   com punho largo debruado de latão e fivelas no peito do pé.

Materiais: pano fosco (cachecol e manto), couro fosco e gasto, aço pouco polido, latão envelhecido. Tudo pintado
à mão, sem brilho especular forte. No jogo vale o mesmo: `enable_pbr` desligado, a luz é da Godot.

### Silhueta e leitura na câmera do jogo (cerca de 90 px de altura)

Redução da folha para 95 px de altura (`hx/at90.png` no scratchpad) e captura do herói atual
(`shots/h0.png`, 1672 x 941, `--bot --seed=5`, em golpe; recorte em `shots/h0_hero.png`):

- O que lê a 90 px: a mancha cobre do cabelo, o bloco azul-petróleo do cachecol e do manto (nas costas é a maior
  área de cor, com a estrela dourada visível como cruz), a faixa dourada do cinto, as botas claras com o punho.
- O que some: rosto, correias, broche, bolsas, a inscrição da fivela (ilegível em qualquer resolução do jogo).
- A câmera vê o herói de cima e na maior parte do tempo pelas costas e pelos ombros: o manto e o topo do cabelo são
  o que mais aparece. É por isso que o manto e o cabelo são os itens de fidelidade mais importantes.
- Herói atual (Sombra): na captura ele quase some no chão (preto e cinza sobre ardósia, cerca de 65 px agachado no
  golpe). O Explorador resolve isso pela cor: cobre e azul-petróleo separam bem do chão frio.

### Riscos para o rigging (Meshy auto-rig, 24 ossos, sem ossos de dedo nem de pano)

- **Manto até a panturrilha**: o rig automático pesa a barra do manto nas coxas e canelas; correndo, o pano estica
  e atravessa as pernas. Mitigação: aceitar no jogo (a 90 px quase não se vê), ou reduzir o peso da barra para
  `Spine`/`Hips` num editor 3D. Se ficar ruim, encurtar o manto até o joelho numa nova geração.
- **Aba da frente e saiote**: presos às coxas; abrem e fecham com a passada. Aceitável.
- **Ombreiras**: presas ao braço; nos golpes por cima da cabeça entram no pescoço e no cachecol. Verificar no
  `tools/pose_lab.gd` com os golpes do ataque e o Ômega.
- **Cabelo**: volume rígido na cabeça, sem problema; só o topete pode atravessar o cachecol ao inclinar a cabeça.
- **Pose**: na folha os braços estão quase colados e as mãos tocam as bolsas e a borda do manto. Sem `pose_mode`
  a-pose, mão, bolsa e manto saem fundidos e o rig falha. Manter a-pose.
- **Mãos**: sem ossos de dedo, a mão fica como foi gerada. Na folha é um punho meio fechado, o que serve para
  segurar a espada; se vier aberta, a espada flutua na palma (só aparece em close, na tela de título).

## 2. Pedido ao Meshy

### Recomendações (uma linha cada)

- **Modelo `latest` (Meshy 7.1)**: manter; é o que reconstrói melhor cabelo e pano a partir de várias vistas, e o
  6-lite economiza só 15 créditos num asset que aparece em toda tela.
- **`pose_mode` a-pose**: manter; separa mãos, bolsas e manto, e o rig e o `Retarget` partem dessa pose.
- **Polígonos 30000 triângulos**: manter; o Sombra tem 12000, mas a tela de título mostra o herói grande e o cabelo
  e a barra do manto precisam de forma. A Godot gera LOD sozinha na importação para a câmera do jogo.
- **Textura 2K, sem PBR**: manter; pintado à mão com luz da Godot.
- **Imagens: as quatro, nesta ordem (frente, lado, costas, três quartos)**: o "três quartos" é a única vista que
  mostra o lado esquerdo (o do broche e do manto); o perfil mostra só o direito.
- **Limpar `side.png` antes**: há um resto da figura vizinha da folha (filete amarelo) perto de x 340, y 885; pintar
  com o fundo `#16181f`. As faixas laterais um pouco mais claras nos quatro recortes (`#202732` contra `#16181f`)
  não devem atrapalhar a remoção do fundo.
- **Não enviar `texture_prompt` na primeira geração**: se enviado, ele substitui as imagens como guia da textura, e
  o que dá fidelidade (estrela nas costas, broche no ombro certo, cores do pano e do couro) vem das imagens. O texto
  fica guardado como plano B, para uma retextura se a textura sair borrada ou com as cores trocadas.
- **Simetria**: o personagem é assimétrico (manto e broche à esquerda). Se o endpoint de várias imagens aceitar
  `symmetry_mode`, usar `off`; o `meshy.mjs` não envia esse campo hoje (o padrão é `auto`). Conferir na documentação
  da API antes de gerar; não é bloqueante.
- **Custo**: 30 créditos (geração) + 5 (esqueleto) = 35. As animações não precisam do Meshy: `tools/bake_hero.gd`
  transfere as da Quaternius.

### Texture prompt final (plano B, 764 caracteres, em inglês)

```
Stylized hand-painted dark fantasy game character, painterly matte materials. Young adult male explorer, warm fair skin, tousled copper-red hair with orange highlights and deep auburn shadows. Deep teal scarf wrapped high around the neck; short teal mantle over the back, pinned at the left shoulder by a small round gold brooch, ragged hem with thin gold trim and one large gold four-pointed star on the back. Dark brown leather vest over a muted teal tunic, crossed brown leather straps, wide brown belt with a plain rectangular brass buckle, small leather pouches. Worn steel shoulder guards with brass rims. Dark charcoal-brown trousers, brown fingerless leather gloves and bracers, brown leather boots with brass-rimmed cuffs. No text, no letters, no weapons.
```

O texto pede a fivela lisa de propósito: o Meshy não escreve hebraico e inventaria letras falsas. Se o Daniel
quiser "אמת" na fivela, ela é pintada à mão na textura depois (de graça, sem nova geração).

O endpoint não tem prompt negativo; os pontos do negativo do Daniel que importam estão cobertos assim: "no weapons"
(arma fundida), a-pose e as imagens (membros, dedos, acessórios soltos), "matte painterly" (fotorrealista), as
próprias imagens (capacete, armadura pesada, capa longa, pedestal).

### `prompts.json` recomendado (o Game Director aplica)

Troca `texture_prompt` por `texture_prompt_fallback`, que o `meshy.mjs` ignora; o resto igual.

```json
    "hero_explorer": {
      "ai_model": "latest",
      "pose": "a-pose",
      "polycount": 30000,
      "images": [
        "tools/meshy/ref/hero_explorer/front.png",
        "tools/meshy/ref/hero_explorer/side.png",
        "tools/meshy/ref/hero_explorer/back.png",
        "tools/meshy/ref/hero_explorer/threequarter.png"
      ],
      "texture_prompt_fallback": "Stylized hand-painted dark fantasy game character, painterly matte materials. Young adult male explorer, warm fair skin, tousled copper-red hair with orange highlights and deep auburn shadows. Deep teal scarf wrapped high around the neck; short teal mantle over the back, pinned at the left shoulder by a small round gold brooch, ragged hem with thin gold trim and one large gold four-pointed star on the back. Dark brown leather vest over a muted teal tunic, crossed brown leather straps, wide brown belt with a plain rectangular brass buckle, small leather pouches. Worn steel shoulder guards with brass rims. Dark charcoal-brown trousers, brown fingerless leather gloves and bracers, brown leather boots with brass-rimmed cuffs. No text, no letters, no weapons."
    }
```

Conferir depois com `node tools/meshy/meshy.mjs image hero_explorer --dry`: o corpo enviado não deve ter
`texture_prompt`.

## 3. Critérios de fidelidade do modelo gerado

Avaliar o GLB antes do esqueleto (gastar os 5 créditos do rig só se nada for BAIXA), com quatro vistas renderizadas
na Godot ao lado dos recortes, e depois uma captura real em jogo (`RES=1672x941 tools/shot.sh ... --bot --seed=5`) e
na vitrine.

| Item | ALTA | MÉDIA | BAIXA (refazer) | Corrige na Godot sem gerar de novo |
|---|---|---|---|---|
| Cabelo | volume alto e despenteado, mechas para a frente e para cima, cobre `#a9340d` a `#e15e26` | volume certo, mechas lisas ou cor puxando para marrom ou laranja | careca, capacete, cabelo curto rente ou liso comprido | cor (tom e saturação na textura) |
| Rosto | adulto jovem, queixo marcado, sobrancelha baixa, determinado | genérico mas adulto e proporcional | infantil, caricato, deformado | quase nada; só aparece na tela de título |
| Cachecol | grosso, alto no pescoço, caído atrás como capuz | presente mas fino ou baixo | ausente ou fundido ao manto como bloco | cor |
| Manto | um ombro (broche à esquerda), costas até a panturrilha em ponta, barra dourada, estrela nas costas | manto simétrico nos dois ombros ou sem a estrela | capa longa até o chão, ou sem manto | cor; estrela pintada à mão na textura; comprimento não |
| Armadura | couro leve, correias em X, ombreiras pequenas de aço, saiote em abas | correias simplificadas, ombreiras maiores | peitoral de placa, armadura pesada, braços cobertos de metal | cor do metal e do couro |
| Paleta | blocos da tabela da seção 1 (desvio pequeno de tom) | um bloco trocado (pano verde vivo, couro preto) | dominado por uma cor só, ou fotorrealista | tom, saturação e valor por região na textura (editor de imagem) ou geral pelo material |
| Proporções | 7 a 8 cabeças, tronco em V, pernas longas | 6,5 a 7 cabeças ou ombros estreitos | cabeçudo (menos de 6) ou músculos exagerados | escala total (`HeroBody.MODEL_HEIGHT`); cabeça e pernas por escala de osso (o `Slender` faz isso para a multidão) |
| Silhueta a 90 px | cobre no topo, azul-petróleo nas costas, botas claras: lê de costas e de cima | lê, mas o manto some no corpo | mancha escura sem forma | contorno ou luz de recorte do herói (Environment Artist), não a malha |
| Materiais | fosco, pintado, sem plástico | um pouco brilhante ou borrado | metálico ou plástico em tudo | `roughness`, `metallic`, `specular` no material |
| Malha | mãos separadas do corpo, sem membros nem dedos extras, nada solto | pequenos furos ou pano atravessando | mão fundida ao quadril ou ao manto, pernas unidas | não (fusão impede o rig) |

Aprovado para o rig: nenhum BAIXA e cabelo, manto e paleta em ALTA. Aprovado para o jogo: mais a captura real
mostrando a leitura de costas e de cima. A aprovação final é do Daniel.

Integração (Environment Artist com o Game Director, depois do rig): novo caminho em `HeroBody.MODEL` e `ANIMS`,
`MODEL_HEIGHT` medido no GLB, `OUT` e o modelo em `tools/bake_hero.gd`, rodar o bake (refaz a pegada da espada
pelo manequim) e conferir no `tools/pose_lab.gd`.

## 4. Espada Emeth (asset separado, não gerar agora)

### Medidas da folha (vista grande, no centro da folha, cerca de 500 px de comprimento)

- Lâmina 0,64 do comprimento total; empunhadura 0,2; guarda com 0,24 do comprimento de largura.
- Guarda: asas douradas angulosas com pontas viradas para baixo, losango central com esmeralda, e um colar dourado
  que desce pela base da lâmina com uma segunda esmeralda. Pomo: losango dourado vazado com esmeralda. Empunhadura
  de couro escuro enrolado.
- Lâmina: cristal verde translúcido facetado, miolo claro quase branco, borda verde saturada (`#20a462`), com
  rastros de luz em espiral (efeito, não geometria).
- Na ilustração principal a espada mede cerca de 0,6 da altura do herói (cerca de 1,5 m num herói de 2,5 m). A
  procedural de hoje (`EmethSword`, `SWORD_SCALE` 1) tem cerca de 1,8 m, 0,73 da altura. Decisão do Daniel
  (pergunta 5); maior lê melhor a 90 px.

### Opções

| Opção | Custo | Prós | Contras |
|---|---|---|---|
| A. Meshy imagem para 3D do recorte da espada (`latest`, textura 2K) | 30 | ornamento da guarda e do pomo esculpido | os rastros em espiral e o brilho do recorte viram geometria ou textura suja; o brilho controlado tem de ser da Godot de qualquer jeito; a 90 px a guarda tem 3 ou 4 px |
| B. Meshy `meshy-6-lite`, só a empunhadura (guarda, cabo, pomo), lâmina procedural | 15 | ornamento real onde ele aparece (título), lâmina com brilho sob controle | dois assets para casar; ainda pede recorte limpo sem a lâmina |
| C. Melhorar a `EmethSword` procedural | 0 | brilho, cor e tamanho sob controle total; sem créditos; troca imediata | ornamento simplificado em close |

**Recomendação: C agora, B depois se a tela de título pedir detalhe.** No jogo a espada tem 30 a 40 px; o que lê é a
lâmina verde e o ponto dourado da guarda, e as duas coisas a procedural já faz.

Pedido para a C (Environment Artist, `scripts/render/emeth_sword.gd`):
- Guarda com o desenho da folha: asas em ângulo com pontas para baixo (hoje sobem), losango central maior, colar
  dourado descendo 0,12 do comprimento pela lâmina com a segunda esmeralda.
- Pomo em losango dourado (hoje é esfera) com a esmeralda no centro.
- Lâmina: borda `#20a462` com miolo quase branco (o miolo já existe); manter o brilho só na lâmina e nas esmeraldas.
- Proporções: lâmina 0,64, empunhadura 0,2, guarda 0,24 do comprimento total.
- Brilho controlado: o `BLADE_GLOW` (1,7) não pode estourar sobre o cabelo nem esconder a mão; critério: na captura
  em 1672 x 941 a lâmina é a coisa mais clara do herói, mas o cabelo cobre continua com cor (não vira branco) ao lado
  dela. Conferir também com `DRIVER=opengl3` (navegador, glow mais fraco).
- Encaixe: continua no `BoneAttachment3D` do osso `RightHand` montado por `HeroBody._arm`, com a pegada medida pelo
  `tools/bake_hero.gd` (`grip_at`, `grip_dir`); o novo modelo só exige rodar o bake de novo.

Prompt para a opção B, se autorizada (texto para a retextura e para conferir o recorte): "Ornate fantasy sword
hilt only, no blade: angular gold crossguard with wings pointing down, a diamond-shaped center holding a green
emerald, short gold collar below it with a second small emerald, dark brown leather wrapped grip, diamond-shaped open
gold pommel with an emerald, stylized hand-painted, matte antique gold, no glow, no text."

## 5. Perguntas ao Daniel

1. **Nome**: a folha chama o herói "Emeth, O Portador da Verdade", mas a regra do projeto é que Emeth é a espada.
   O herói se chama Emeth, ou o título fica "O Portador da Emeth" (ou outro)? Nada muda no jogo até ele decidir.
2. **Fivela "אמת"**: quer a palavra pintada à mão na textura da fivela (não se lê no jogo, só na tela de título), ou
   só no material de divulgação?
3. **Estrela dourada de quatro pontas** (broche e costas do manto): fica como está na folha? Ela tem nome ou
   significado no cânone ("luz contra as trevas" na folha)? Não acrescentamos outros símbolos.
4. **Braços nus e bem definidos**: como na folha, ou quer braços menos musculosos ou com mangas, para ficar mais
   longe de "bárbaro"?
5. **Tamanho da espada**: como na folha (cerca de 1,5 m, 0,6 da altura dele) ou como hoje (cerca de 1,8 m, lê
   melhor de longe)?
6. **Créditos**: 35 (30 da geração + 5 do esqueleto); a espada procedural não gasta nada. Autoriza quando recarregar?
7. **Substituição**: o Explorador substitui o Sombra também na tela de título? E ele é o `PALADIN_1` (ele não usa
   armadura de paladino) ou outro personagem?
